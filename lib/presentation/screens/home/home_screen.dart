import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/listing_provider.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/listing_card.dart';
import '../search/search_screen.dart';
import '../notifications/notifications_screen.dart';
import '../listing/listing_detail_screen.dart';
import '../listing/my_listings_screen.dart';
import '../favorites/favorites_screen.dart';
import '../auth/otp_login_screen.dart';
import '../../../data/models/listing.dart';
import '../../../l10n/app_localizations.dart';

/// Home Screen - Modern premium header with glassmorphism & animations
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Set<int> _togglingFavorites = {};
  late AnimationController _headerAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(featuredListingsProvider.notifier).loadFeaturedListings();
      ref.read(listingsProvider.notifier).loadListings();
      ref.read(authStateProvider.notifier).loadUser();
      _headerAnimationController.forward();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final state = ref.read(listingsProvider);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !state.isLoading &&
        !state.isLoadingMore &&
        state.hasMore) {
      ref
          .read(listingsProvider.notifier)
          .loadListings(page: state.currentPage + 1);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  bool _isFavorite(int listingId) {
    final favState = ref.read(favoritesProvider);
    return favState.favorites.any((f) => f is Listing && f.id == listingId);
  }

  Future<void> _toggleFavorite(int listingId) async {
    setState(() => _togglingFavorites.add(listingId));
    await ref.read(favoritesProvider.notifier).toggleFavorite(listingId);
    if (mounted) setState(() => _togglingFavorites.remove(listingId));
  }

  bool _isToggling(int listingId) => _togglingFavorites.contains(listingId);

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final featuredState = ref.watch(featuredListingsProvider);
    final listingsState = ref.watch(listingsProvider);
    final unreadCountAsync = ref.watch(unreadCountProvider);
    final l10n = AppLocalizations.of(context);
    ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.zinc50,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(featuredListingsProvider.notifier).loadFeaturedListings(),
            ref.read(listingsProvider.notifier).loadListings(),
            ref.read(authStateProvider.notifier).loadUser(),
          ]);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _HeaderDelegate(
                authState: authState,
                unreadCountAsync: unreadCountAsync,
                onSearchTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
                onProfileTap: () => _showProfileModal(context, ref, authState),
                onNotificationsTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      _buildSectionHeader(context,
                          l10n.listingsFeatured, isFeatured: true),
                      _buildFeaturedListings(featuredState),
                      _buildSectionHeader(
                          context, l10n.listingsTitle, isFeatured: false),
                    ],
                  ),
                ),
              ),
            ),
            _buildLatestListings(listingsState),
          ],
        ),
      ),
    );
  }

  void _showProfileModal(
      BuildContext context, WidgetRef ref, AuthState authState) {
    final user = authState.user;
    final profileState = ref.read(profileProvider);
    final stats = profileState.stats;
    final l10n = AppLocalizations.of(context);
    String initialsTemp = l10n.commonAppInitials;
    if (user?.initials.isNotEmpty == true) {
      initialsTemp = user!.initials;
    } else if (user != null && user.firstName.isNotEmpty) {
      initialsTemp = user.firstName.substring(0, 1).toUpperCase();
    }
    final initials = initialsTemp;
    final fullName =
        (user?.fullName.isNotEmpty ?? false) ? user!.fullName : l10n.commonUser;
    final phone = (user?.phoneNumber.isNotEmpty ?? false)
        ? user!.phoneNumber
        : (user?.email ?? l10n.commonNA);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.45,
        minChildSize: 0.35,
        maxChildSize: 0.55,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.zinc300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Avatar and name
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.wave500, AppColors.wave600],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.wave500.withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.navy950,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                phone,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.navy400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Stats row
                    Row(
                      children: [
                        _buildModalStatItem(
                          value: stats?.totalListings.toString() ?? '0',
                          label: l10n.profileStatsListings,
                          onTap: () {
                            Navigator.pop(ctx);
                            _navigateToMyListings();
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildModalStatItem(
                          value: stats?.totalFavorites.toString() ?? '0',
                          label: l10n.profileStatsFavorites,
                          onTap: () {
                            Navigator.pop(ctx);
                            _navigateToFavorites();
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildModalStatItem(
                          value: user?.isKycVerified == true
                              ? l10n.profileKycStatusVerified
                              : l10n.profileKycStatusPending,
                          label: l10n.profileVerificationKyc,
                          valueColor: user?.isKycVerified == true
                              ? AppColors.emerald600
                              : AppColors.warning,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 8),

                    // Action buttons
                    _buildModalAction(
                      icon: Icons.logout,
                      title: l10n.authLogout,
                      textColor: AppColors.error,
                      iconColor: AppColors.error,
                      onTap: () async {
                        Navigator.pop(ctx);
                        await ref.read(authStateProvider.notifier).logout();
                        if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const OtpLoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToMyListings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MyListingsScreen()),
    );
  }

  void _navigateToFavorites() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
    );
  }

  Widget _buildModalStatItem({
    required String value,
    required String label,
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: onTap != null ? AppColors.zinc50 : AppColors.zinc50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.zinc200),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? AppColors.wave600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.navy400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor ?? AppColors.navy600,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor ?? AppColors.navy950,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, String title, {
    bool isFeatured = false,
  }) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy950,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isFeatured
                    ? l10n.homeFeaturedPremium
                    : l10n.homeLatestRecently,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.navy400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchScreen(isFeatured: isFeatured),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.wave50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.wave200),
              ),
              child: Text(
                l10n.homeViewAll,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.wave700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedListings(ListingsState state) {
    if (state.isLoading) {
      return SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          itemBuilder: (context, index) => const Padding(
            padding: EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 280,
              child: FeaturedListingCard(
                listing: null,
                isLoading: true,
              ),
            ),
          ),
        ),
      );
    }
    if (state.listings.isEmpty) {
      return SizedBox(
          height: 80,
          child: Center(
              child: Text(AppLocalizations.of(context).listingsNoResults)));
    }
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.listings.length,
        itemBuilder: (context, index) {
          final listing = state.listings[index];
          final fav = _isFavorite(listing.id);
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 280,
              child: FeaturedListingCard(
                listing: listing,
                isFavorite: fav,
                isTogglingFavorite: _isToggling(listing.id),
                onFavorite: () => _toggleFavorite(listing.id),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) =>
                          ListingDetailScreen(listingId: listing.id)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLatestListings(ListingsState state) {
    if (state.isLoading && state.listings.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            for (int i = 0; i < 3; i++)
              const PropertyListingCard(isLoading: true),
          ]),
        ),
      );
    }
    if (state.listings.isEmpty) {
      return SliverFillRemaining(
          child: Center(
              child: Text(AppLocalizations.of(context).listingsNoResults)));
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == state.listings.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final listing = state.listings[index];
            final fav = _isFavorite(listing.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PropertyListingCard(
                listing: listing,
                isFavorite: fav,
                isTogglingFavorite: _isToggling(listing.id),
                onFavorite: () => _toggleFavorite(listing.id),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) =>
                          ListingDetailScreen(listingId: listing.id)),
                ),
              ),
            );
          },
          childCount: state.listings.length + (state.isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }
}

/// Modern Premium Header Delegate - Fixed height 100, no shrink
class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final AuthState authState;
  final AsyncValue<int> unreadCountAsync;
  final VoidCallback onSearchTap;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationsTap;

  _HeaderDelegate({
    required this.authState,
    required this.unreadCountAsync,
    required this.onSearchTap,
    required this.onProfileTap,
    required this.onNotificationsTap,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final user = authState.user;
    final userFirstName = user?.firstName ?? 'WaveMart';
    final userInitials = _getInitials(context, user?.firstName, user?.lastName);
    final isScrolled = overlapsContent;
    final l10n = AppLocalizations.of(context);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.navy950.withOpacity(isScrolled ? 0.98 : 0.95),
                AppColors.navy900.withOpacity(isScrolled ? 0.96 : 0.90),
              ],
            ),
            boxShadow: isScrolled
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: AppColors.wave500.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, -2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onProfileTap,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          _buildAvatar(userInitials),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.homeGreeting(userFirstName),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                    height: 1.2,
                                  ),
                                ),
                                Text(
                                  l10n.homeDiscover,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.65),
                                    fontWeight: FontWeight.w400,
                                    height: 1.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildActionButton(
                        icon: Icons.notifications_outlined,
                        onTap: onNotificationsTap,
                        badgeProvider: () => unreadCountAsync,
                      ),
                      const SizedBox(width: 8),
                      _buildSearchButton(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String initials) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.wave500, AppColors.wave600],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.wave500.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required AsyncValue<int> Function() badgeProvider,
  }) {
    final badgeValue = badgeProvider();

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
          if (badgeValue.hasValue && badgeValue.value! > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                decoration: BoxDecoration(
                  color: AppColors.wave500,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: AppColors.navy950,
                    width: 2,
                  ),
                ),
                child: Text(
                  badgeValue.value! > 99 ? '99+' : '${badgeValue.value}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return GestureDetector(
      onTap: onSearchTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.wave500.withOpacity(0.9),
              AppColors.wave600,
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.wave500.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          Icons.search_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  String _getInitials(BuildContext context, String? firstName, String? lastName) {
    final l10n = AppLocalizations.of(context);
    if (firstName == null && lastName == null) return l10n.commonAppInitials;
    final first = firstName?.substring(0, 1).toUpperCase() ?? '';
    final last = lastName?.substring(0, 1).toUpperCase() ?? '';
    return (first + last).isEmpty ? l10n.commonAppInitials : first + last;
  }

  @override
  double get maxExtent => 100;
  @override
  double get minExtent => 100;

  @override
  bool shouldRebuild(_HeaderDelegate oldDelegate) {
    return oldDelegate.authState != authState ||
        oldDelegate.unreadCountAsync != unreadCountAsync;
  }
}
