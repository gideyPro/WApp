import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/listing.dart';
import '../../../data/models/address.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/car_providers.dart';
import '../../providers/auth_provider.dart';
import '../../../core/constants/app_spacing.dart';
import '../../widgets/common/wave_card.dart';
import '../../widgets/common/wave_liquid_glass.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_upgrade_card.dart';
import '../listing/widgets/listing_gallery.dart';
import '../listing/widgets/listing_report_sheet.dart';
import '../../../data/services/listing_service.dart';



class CarDetailScreen extends ConsumerStatefulWidget {
  final int listingId;

  const CarDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends ConsumerState<CarDetailScreen> {
  bool _isVipLoading = false;
  bool _isFeatureLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(carDetailProvider.notifier).loadListing(widget.listingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(carDetailProvider);

    if (state.isLoading) {
      return _buildSkeletonLoader();
    }

    if (state.errorMessage != null) {
      return _buildErrorView(state.errorMessage!, isSubscriptionGate: state.requiresSubscription);
    }

    if (state.listing == null) {
      return _buildNotFound();
    }

    return _buildContent(state.listing!);
  }

  Widget _buildSkeletonLoader() {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Shimmer.fromColors(
              baseColor: context.shimmerBase,
              highlightColor: context.shimmerHighlight,
              child: Column(
                children: [
                  Container(height: 56, color: context.shimmerHighlight),
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Container(color: context.shimmerHighlight),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Shimmer.fromColors(
                baseColor: context.shimmerBase,
                highlightColor: context.shimmerHighlight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 28, width: 200, decoration: BoxDecoration(color: context.shimmerHighlight, borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 12),
                    Container(height: 28, width: 140, decoration: BoxDecoration(color: context.shimmerHighlight, borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 16),
                    Container(height: 18, width: double.infinity, decoration: BoxDecoration(color: context.shimmerHighlight, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 8),
                    Container(height: 14, width: 180, decoration: BoxDecoration(color: context.shimmerHighlight, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 24),
                    Container(height: 16, width: 120, decoration: BoxDecoration(color: context.shimmerHighlight, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 12),
                    ...List.generate(5, (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(height: 14, width: double.infinity, decoration: BoxDecoration(color: context.shimmerHighlight, borderRadius: BorderRadius.circular(4))),
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message, {bool isSubscriptionGate = false}) {
    final l10n = AppLocalizations.of(context);

    if (isSubscriptionGate) {
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: AppBar(title: Text(l10n.listingDetail)),
      body: WaveMessageScreen(
        type: WaveMessageType.warning,
        title: l10n.subscriptionRequiredTitle,
        subtitle: l10n.subscriptionRequiredDetailsSubtitle,
        actionLabel: l10n.listingUpgradeNow,
        onAction: () => context.pushReplacement('/subscriptions'),
      ),
    );
  }

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(title: Text(l10n.listingDetail)),
      body: WaveMessageScreen.error(
        title: l10n.listingsLoadError,
        subtitle: message,
        onRetry: () => ref.read(carDetailProvider.notifier).loadListing(widget.listingId),
      ),
    );
  }

  Widget _buildNotFound() {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(title: Text(l10n.listingDetail)),
      body: WaveMessageScreen.empty(
        title: l10n.listingsNotFound,
        subtitle: l10n.listingsNotFoundSubtitle,
        onAction: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildContent(Listing listing) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.listingDetail),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareListing(listing),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageGallery(listing),
            const SizedBox(height: 24),
            _buildPriceAndTitle(listing),
            const Divider(height: 32),
            _buildSpecsSection(listing),
            if (listing.description != null && listing.description!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSection(
                title: l10n.listingDescriptionLabel,
                child: Text(listing.description!, style: AppTextStyles.bodyMedium.copyWith(color: context.theme.textTertiary, height: 1.6)),
              ),
            ],
            if (listing.carFeatures != null && listing.carFeatures!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSection(
                title: l10n.listingsKeyFeatures,
                child: _buildFeatureChips(listing.carFeatures!),
              ),
            ],
            if (listing.vipBlocked) ...[
              const SizedBox(height: 24),
              UpgradeCard(
                icon: Icons.diamond_outlined,
                iconColor: AppColors.vip,
                title: l10n.listingUpgradeToVip,
                subtitle: l10n.subscriptionRequiredDetailsSubtitle,
                buttonLabel: l10n.ordersUpgradePlan,
              ),
            ],
            const SizedBox(height: 24),
            _buildActionSection(listing),
            const SizedBox(height: 32),
            _buildSimilarListings(listing),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceAndTitle(Listing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          listing.getLocalizedPrice(context),
          style: AppTextStyles.headline2.copyWith(
            color: AppColors.emerald600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          listing.carTitle,
          style: AppTextStyles.headline4,
        ),
        if (listing.address != null) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: context.textSecondary),
              const SizedBox(width: 4),
              Expanded(child: Text(
                _formatAddress(listing.address!),
                style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
              )),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 14, color: context.textSecondary.withValues(alpha: 0.7)),
            const SizedBox(width: 4),
            Text(DateFormat('MMM d, yyyy').format(listing.createdAt), style: AppTextStyles.labelSmall.copyWith(color: context.textSecondary.withValues(alpha: 0.7))),
            const Spacer(),
            Icon(Icons.visibility_outlined, size: 14, color: context.textSecondary.withValues(alpha: 0.7)),
            const SizedBox(width: 4),
            Text('${listing.viewCount}', style: AppTextStyles.labelSmall.copyWith(color: context.textSecondary.withValues(alpha: 0.7))),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.title),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildActionSection(Listing listing) {
    final l10n = AppLocalizations.of(context);
    final subState = ref.read(subscriptionProvider);
    final authState = ref.read(authStateProvider);
    final currentUserId = authState.user?.id;
    final isOwner = currentUserId != null && listing.userId == currentUserId;

    return WaveCard(
      useLiquidGlass: true,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      isGlass: true,
      color: null,
      padding: AppSpacing.paddingLg,
      child: Column(
        children: [
          if (isOwner) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editListing(listing),
                    icon: const Icon(Icons.edit, size: 20),
                    label: Text(l10n.commonEdit),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: context.theme.divider),
                      foregroundColor: context.isDarkMode ? AppColors.primary300 : AppColors.primary600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteListing(listing),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: Text(l10n.commonDelete),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.error),
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (listing.isFeaturedActive)
              LiquidGlass(
                borderRadius: 8,
                blur: 20,
                tint: AppColors.success,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 18, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(
                      l10n.listingUpgradeToFeature.replaceFirst('Feature', 'Featured'),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _isFeatureLoading ? null : () => _unfeatureListing(listing),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.stone500,
                      ),
                      child: _isFeatureLoading
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(
                              'Unfeature',
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.stone500),
                            ),
                    ),
                  ],
                ),
              )
            else
              subState.canFeatureListing
                  ? SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isFeatureLoading ? null : () => _featureListing(listing),
                        icon: _isFeatureLoading
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.workspace_premium_outlined, size: 20),
                        label: Text(_isFeatureLoading ? '' : l10n.listingFeatureThis),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.accent500),
                          foregroundColor: AppColors.accent500,
                        ),
                      ),
                    )
                  : UpgradeCard(
                      icon: Icons.workspace_premium_outlined,
                      iconColor: AppColors.accent500,
                      title: l10n.listingUpgradeToFeature,
                      subtitle: l10n.subscriptionRequiredFeatureSubtitle,
                    ),
            const SizedBox(height: 12),
            if (listing.isVipActive)
              LiquidGlass(
                borderRadius: 8,
                blur: 20,
                tint: AppColors.vip,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 18, color: AppColors.vip),
                    const SizedBox(width: 8),
                    Text(
                      l10n.markAsVip,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.vip,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _isVipLoading ? null : () => _unvipListing(listing),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.stone500,
                      ),
                      child: _isVipLoading
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(
                              'Un-VIP',
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.stone500),
                            ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isVipLoading ? null : () => _vipListing(listing),
                  icon: _isVipLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.diamond_outlined, size: 20),
                  label: Text(_isVipLoading ? '' : l10n.markAsVip),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.vip),
                    foregroundColor: AppColors.vip,
                  ),
                ),
              ),
          ],
          if (!isOwner && listing.sellerPhone != null && listing.sellerPhone!.isNotEmpty) ...[
            _buildSellerContact(listing),
          ],
          if (!isOwner) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showReportSheet(listing),
                icon: const Icon(Icons.flag_outlined, size: 16),
                label: Text(l10n.reportListing),
                style: TextButton.styleFrom(
                  foregroundColor: context.textSecondary,
                  visualDensity: VisualDensity.compact,
                  textStyle: AppTextStyles.labelSmall,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSellerContact(Listing listing) {
    final l10n = AppLocalizations.of(context);
    final phone = listing.sellerPhone!;
    final name = listing.sellerName ?? 'Seller';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(l10n.carContactSeller, style: AppTextStyles.titleSmall.copyWith(color: context.textPrimary)),
        ),
        WaveCard(
          useLiquidGlass: true,
          isGlass: true,
          showBorder: false,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: context.theme.cardBg,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'S',
                      style: AppTextStyles.titleSmall.copyWith(color: AppColors.accent600, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: AppTextStyles.bodySmall.copyWith(color: context.textPrimary, fontWeight: FontWeight.w600)),
                        Text(phone, style: AppTextStyles.labelSmall.copyWith(color: context.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ContactButton(
                      icon: Icons.phone,
                      label: l10n.carCall,
                      hint: l10n.carCallHint,
                      color: const Color(0xFF4CAF50),
                      onTap: () => _launchUrl('tel:$phone'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ContactButton(
                      icon: Icons.chat_bubble_outline,
                      label: l10n.carWhatsapp,
                      hint: l10n.carWhatsappHint,
                      color: const Color(0xFF25D366),
                      onTap: () => _launchUrl('https://wa.me/${phone.replaceAll(RegExp(r'[^0-9]'), '')}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ContactButton(
                      icon: Icons.send,
                      label: l10n.carTelegram,
                      hint: l10n.carTelegramHint,
                      color: const Color(0xFF0088CC),
                      onTap: () => _launchUrl('https://t.me/+${phone.replaceAll(RegExp(r'[^0-9]'), '')}'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _editListing(Listing listing) async {
    final result = await context.push<bool>(
      '/cars/${listing.id}/edit',
      extra: listing,
    );
    if (result == true && mounted) {
      ref.read(carDetailProvider.notifier).refreshListing(listing.id);
    }
  }

  Future<void> _deleteListing(Listing listing) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.listingDeleteConfirmTitle),
        content: Text(l10n.listingDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final service = ListingService();
      final result = await service.deleteListing(listing.id);
      if (result.success && mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).commonError), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _vipListing(Listing listing) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.markAsVipTitle),
        content: Text(l10n.markAsVipMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.markAsVip),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isVipLoading = true);
    try {
      final msg = await ref.read(carDetailProvider.notifier).vipListing(listing.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg ?? 'Success'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).commonError), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isVipLoading = false);
    }
  }

  Future<void> _unvipListing(Listing listing) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove VIP Status?'),
        content: const Text('Your listing will no longer be a VIP listing. You can mark it as VIP again later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove VIP'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isVipLoading = true);
    try {
      final msg = await ref.read(carDetailProvider.notifier).unvipListing(listing.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg ?? 'Success'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).commonError), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isVipLoading = false);
    }
  }

  Future<void> _featureListing(Listing listing) async {
    final subState = ref.read(subscriptionProvider);
    if (!subState.canFeatureListing) {
      if (mounted) context.push('/subscriptions');
      return;
    }

    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${l10n.listingFeatureThis}?'),
        content: const Text('Your listing will be featured on the home page and search results for 30 days.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.listingFeatureNow),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isFeatureLoading = true);
    try {
      final msg = await ref.read(carDetailProvider.notifier).featureListing(listing.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg ?? 'Success'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).commonError), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isFeatureLoading = false);
    }
  }

  Future<void> _unfeatureListing(Listing listing) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unfeature Listing?'),
        content: const Text('Your listing will no longer appear as featured. You can feature it again later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Unfeature'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isFeatureLoading = true);
    try {
      final msg = await ref.read(carDetailProvider.notifier).unfeatureListing(listing.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg ?? 'Success'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).commonError), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isFeatureLoading = false);
    }
  }

  void _showReportSheet(Listing listing) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ListingReportSheet(listingId: listing.id),
    );
  }

  Widget _buildImageGallery(Listing listing) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 280,
        child: ListingGallery(listing: listing),
      ),
    );
  }

  Widget _buildFeatureChips(List<String> features) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: features.map((f) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: context.divider.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 16, color: AppColors.accent500),
            const SizedBox(width: 6),
            Text(
              f,
              style: AppTextStyles.labelMedium.copyWith(
                color: context.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildSpecsSection(Listing listing) {
    final l10n = AppLocalizations.of(context);
    final specs = <MapEntry<String, String>>[];
    void add(String label, String? value) {
      if (value != null && value.isNotEmpty) specs.add(MapEntry(label, value));
    }
    final cat = listing.carVehicleCategory;
    add(l10n.listingVehicleCategory, cat);
    add(l10n.listingMake, listing.carMake);
    add(l10n.listingModel, listing.carModel);
    if (cat != 'bicycle') {
      add(l10n.listingYear, listing.carYear?.toString());
    }
    if (cat != 'bicycle') {
      final unit = cat == 'construction_equipment' ? 'Hours' : 'km';
      add('${l10n.listingMileage} ($unit)', listing.carMileageKm != null ? NumberFormat("#,###").format(listing.carMileageKm!.toInt()) : null);
    }
    if (cat == 'car' || cat == 'construction_equipment') {
      add(l10n.listingBodyType, listing.carBodyType);
    }
    add(l10n.listingColor, listing.carColor);
    add(l10n.listingCondition, listing.carCondition);
    if (cat == 'car' || cat == 'construction_equipment') {
      add(l10n.listingVin, listing.carVin);
    }

    if (specs.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.listingSpecifications, style: AppTextStyles.title),
        const SizedBox(height: 12),
        WaveCard(
          useLiquidGlass: true,
          isGlass: true,
          showBorder: false,
          padding: EdgeInsets.zero,
          child: Column(
            children: specs.asMap().entries.map((entry) {
              final index = entry.key;
              final spec = entry.value;
              return Column(
                children: [
                  Padding(
                    padding: AppSpacing.paddingLg,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          spec.key,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary500,
                          ),
                        ),
                        Text(
                          spec.value,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < specs.length - 1) const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarListings(Listing listing) {
    final l10n = AppLocalizations.of(context);
    final similarAsync = ref.watch(similarCarsProvider(listing.id));

    return similarAsync.when(
      data: (response) {
        final listings = response.listings;
        if (listings.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1),
            const SizedBox(height: 24),
            Text(l10n.listingsSimilarListings, style: AppTextStyles.title.copyWith(color: context.textPrimary)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: listings.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final similar = listings[index];
                  return SizedBox(
                    width: 200,
                    child: _buildSimilarCard(similar),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSimilarCard(Listing similar) {
    final imageUrl = similar.images.isNotEmpty
        ? similar.images.first.imageUrl
        : '';
    return GestureDetector(
      onTap: () {
        context.pushReplacement('/cars/${similar.id}');
      },
      child: WaveCard(
        useLiquidGlass: true,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.primary100,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    )
                  : Container(
                      color: AppColors.primary100,
                      child: const Icon(Icons.image_not_supported),
                    ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      similar.carTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600, color: context.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      similar.getLocalizedPrice(context),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.emerald600,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (similar.carYear != null || similar.carMileageKm != null)
                      Text(
                        '${similar.carYear ?? ''}${similar.carYear != null && similar.carMileageKm != null ? ' · ' : ''}${similar.carMileageKm != null ? '${similar.carMileageKm!.toInt()} km' : ''}',
                        style: AppTextStyles.caption.copyWith(color: context.textSecondary),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAddress(Address address) {
    final parts = <String>[];
    if (address.region != null) parts.add(address.region!);
    if (address.zone != null) parts.add(address.zone!);
    if (address.woreda != null) parts.add(address.woreda!);
    if (address.kebele != null) parts.add(address.kebele!);
    return parts.join(', ');
  }

  Future<void> _shareListing(Listing listing) async {
    final l10n = AppLocalizations.of(context);
    final shareText = '''
${listing.carTitle}
${listing.getLocalizedPrice(context)}
${listing.description?.isNotEmpty == true ? '\n${listing.description}' : ''}

${l10n.shareListingTitle}
''';

    await Share.share(
      shareText,
      subject: '${l10n.shareListingMessage}${listing.carTitle}',
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open: $url'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.hint,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: hint,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 4),
                Text(label, style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
