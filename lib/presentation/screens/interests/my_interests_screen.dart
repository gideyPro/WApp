import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_card.dart';
import '../listing/listing_detail_screen.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../data/models/listing.dart';
import '../../widgets/listing_card.dart';

class MyInterestsScreen extends ConsumerStatefulWidget {
  const MyInterestsScreen({super.key});

  @override
  ConsumerState<MyInterestsScreen> createState() => _MyInterestsScreenState();
}

class _MyInterestsScreenState extends ConsumerState<MyInterestsScreen> {
  final Set<int> _cancellingInterests = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myInterestsProvider.notifier).loadInterests();
    });
  }

  Color _stageColor(String? stage) {
    switch (stage) {
      case 'contacted':
        return AppColors.primary900;
      case 'new':
        return AppColors.warning;
      case 'negotiating':
      case 'offer':
        return AppColors.emerald500;
      case 'won':
        return AppColors.emerald600;
      case 'lost':
        return AppColors.error;
      default:
        return AppColors.primary400;
    }
  }

  String _stageLabel(String? stage) {
    switch (stage) {
      case 'new':
        return 'New';
      case 'contacted':
        return 'Contacted';
      case 'negotiating':
        return 'Negotiating';
      case 'offer':
        return 'Offer';
      case 'won':
        return 'Won';
      case 'lost':
        return 'Lost';
      default:
        return stage ?? 'Unknown';
    }
  }

  Future<void> _cancelInterest(int interestId) async {
    setState(() => _cancellingInterests.add(interestId));
    final service = ref.read(leadServiceProvider);
    final response = await service.cancelInterest(interestId);
    if (mounted) {
      setState(() => _cancellingInterests.remove(interestId));
      if (response.success) {
        ref.read(myInterestsProvider.notifier).loadInterests();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.message), backgroundColor: AppColors.success));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.message), backgroundColor: AppColors.error));
      }
    }
  }

  void _handleListingTap(int listingId) {
    if (listingId <= 0) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingDetailScreen(listingId: listingId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final interestsState = ref.watch(myInterestsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(
        title: Text(l10n.profileMyInterests),
        centerTitle: false,
      ),
      body: _buildBody(interestsState, l10n),
    );
  }

  Widget _buildBody(MyInterestsState state, AppLocalizations l10n) {
    if (state.isLoading) {
      return ListView.builder(
        padding: AppSpacing.paddingLg,
        itemCount: 5,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: PropertyListingCard(isLoading: true),
        ),
      );
    }

    if (state.errorMessage != null) {
      return WaveMessageScreen.error(
        title: l10n.commonError,
        subtitle: state.errorMessage!,
        onRetry: () => ref.read(myInterestsProvider.notifier).loadInterests(),
        isEmbedded: true,
      );
    }

    if (state.interests.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(myInterestsProvider.notifier).loadInterests(),
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: WaveEmptyState(
                icon: Icons.interests_outlined,
                title: 'No interests yet',
                subtitle: 'Properties you express interest in will appear here',
                actionLabel: l10n.commonBrowseProperties,
                onAction: () {
                  ref.read(selectedTabProvider.notifier).state = 0;
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(myInterestsProvider.notifier).loadInterests(),
      child: ListView.builder(
        padding: AppSpacing.paddingLg,
        itemCount: state.interests.length,
        itemBuilder: (context, index) {
          final lead = state.interests[index];
          final listingJson = lead.listing;
          final listing = listingJson != null ? Listing.fromJson(listingJson as Map<String, dynamic>) : null;
          final stage = lead.stage;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Stack(
              children: [
                if (listing != null)
                  PropertyListingCard(
                    listing: listing,
                    hideFavoriteButton: true,
                    onTap: () => _handleListingTap(listing.id),
                  )
                else
                  _buildMissingListingCard(lead.listingId),
                
                // Interest Status Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _stageColor(stage),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _stageLabel(stage).toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                // Close/Cancel button
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: _cancellingInterests.contains(lead.id)
                        ? null
                        : () => _cancelInterest(lead.id),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: _cancellingInterests.contains(lead.id)
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.close, size: 18, color: Colors.white),
                    ),
                  ),
                ),

                // Message Preview Overlay (at the bottom of the image section)
                if (lead.buyerMessage != null && lead.buyerMessage!.isNotEmpty)
                  Positioned(
                    top: 160, // Approximate bottom of image in 4:3 aspect ratio
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.message_outlined, size: 14, color: Colors.white70),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              lead.buyerMessage!,
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMissingListingCard(int listingId) {
    return WaveCard(
      useLiquidGlass: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.broken_image_outlined, size: 48, color: AppColors.error),
          const SizedBox(height: 8),
          Text('Listing #$listingId is no longer available', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
