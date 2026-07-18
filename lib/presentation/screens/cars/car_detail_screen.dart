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
import '../../widgets/common/wave_card.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_upgrade_card.dart';
import 'car_strings.dart';

class CarDetailScreen extends ConsumerStatefulWidget {
  final int listingId;

  const CarDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends ConsumerState<CarDetailScreen> {
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
        appBar: AppBar(title: const Text(CarStrings.listingDetail)),
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
      appBar: AppBar(title: const Text(CarStrings.listingDetail)),
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
      appBar: AppBar(title: const Text(CarStrings.listingDetail)),
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
        title: const Text(CarStrings.listingDetail),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareListing(listing),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageGallery(listing),
            const SizedBox(height: 12),
            _buildTitleCard(listing),
            if (listing.vipBlocked) ...[
              const SizedBox(height: 12),
              UpgradeCard(
                icon: Icons.diamond_outlined,
                iconColor: AppColors.vip,
                title: l10n.listingUpgradeToVip,
                subtitle: l10n.subscriptionRequiredDetailsSubtitle,
                buttonLabel: l10n.ordersUpgradePlan,
              ),
            ],
            const SizedBox(height: 12),
            _buildSpecsSection(listing),
            if (listing.description != null && listing.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSection(
                title: CarStrings.listingDescription,
                child: Text(listing.description!, style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary, height: 1.5)),
              ),
            ],
            if (listing.carFeatures != null && listing.carFeatures!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSection(
                title: CarStrings.listingFeatures,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: listing.carFeatures!.map((f) => Chip(
                    label: Text(f, style: AppTextStyles.labelSmall.copyWith(color: context.textSecondary)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    backgroundColor: context.theme.cardBg,
                    side: BorderSide.none,
                  )).toList(),
                ),
              ),
            ],
            if (listing.sellerPhone != null && listing.sellerPhone!.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildContactSection(listing),
            ],
            const SizedBox(height: 24),
            _buildSimilarListings(listing),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleCard(Listing listing) {
    return WaveCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(listing.carTitle, style: AppTextStyles.title.copyWith(color: context.textPrimary)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.local_offer, size: 16, color: AppColors.accent600),
              const SizedBox(width: 4),
              Text(listing.getLocalizedPrice(context), style: AppTextStyles.titleSmall.copyWith(color: AppColors.accent600, fontWeight: FontWeight.w700)),
            ],
          ),
          if (listing.address != null) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: context.textSecondary),
                const SizedBox(width: 4),
                Expanded(child: Text(_formatAddress(listing.address!), style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary))),
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
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return WaveCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleSmall.copyWith(color: context.textPrimary)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildContactSection(Listing listing) {
    final phone = listing.sellerPhone!;
    final name = listing.sellerName ?? 'Seller';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(CarStrings.contactSeller, style: AppTextStyles.titleSmall.copyWith(color: context.textPrimary)),
        ),
        WaveCard(
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
                      label: CarStrings.call,
                      hint: CarStrings.callHint,
                      color: const Color(0xFF4CAF50),
                      onTap: () => _launchUrl('tel:$phone'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ContactButton(
                      icon: Icons.chat_bubble_outline,
                      label: CarStrings.whatsapp,
                      hint: CarStrings.whatsappHint,
                      color: const Color(0xFF25D366),
                      onTap: () => _launchUrl('https://wa.me/${phone.replaceAll(RegExp(r'[^0-9]'), '')}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ContactButton(
                      icon: Icons.send,
                      label: CarStrings.telegram,
                      hint: CarStrings.telegramHint,
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

  Widget _buildImageGallery(Listing listing) {
    if (listing.images.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 240,
          color: context.theme.card,
          child: Center(
            child: Icon(Icons.directions_car, size: 64, color: context.textSecondary.withValues(alpha: 0.4)),
          ),
        ),
      );
    }
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: listing.images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              listing.images[index].imageUrl,
              width: MediaQuery.of(context).size.width - 24,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: MediaQuery.of(context).size.width - 24,
                color: context.theme.card,
                child: Icon(Icons.broken_image, color: context.textSecondary.withValues(alpha: 0.4)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpecsSection(Listing listing) {
    final specs = <MapEntry<String, String>>[];
    void add(String label, String? value) {
      if (value != null && value.isNotEmpty) specs.add(MapEntry(label, value));
    }
    add(CarStrings.listingMake, listing.carMake);
    add(CarStrings.listingModel, listing.carModel);
    add(CarStrings.listingYear, listing.carYear?.toString());
    add('${CarStrings.listingMileage} (km)', listing.carMileageKm != null ? NumberFormat("#,###").format(listing.carMileageKm!.toInt()) : null);
    add(CarStrings.listingTransmission, listing.carTransmission);
    add(CarStrings.listingBodyType, listing.carBodyType);
    add(CarStrings.listingFuelType, listing.carFuelType);
    add('${CarStrings.listingEngineSize} (L)', listing.carEngineSize != null ? '${listing.carEngineSize}L' : null);
    add(CarStrings.listingColor, listing.carColor);
    add(CarStrings.listingCondition, listing.carCondition);
    add('VIN', listing.carVin);
    add(CarStrings.listingDoors, listing.carDoors?.toString());
    add(CarStrings.listingSeats, listing.carSeats?.toString());

    if (specs.isEmpty) return const SizedBox();

    return _buildSection(
      title: CarStrings.listingSpecifications,
      child: Column(
        children: specs.map((spec) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(spec.key, style: AppTextStyles.labelSmall.copyWith(color: context.textSecondary)),
              ),
              Expanded(child: Text(spec.value, style: AppTextStyles.bodySmall.copyWith(color: context.textPrimary))),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildSimilarListings(Listing listing) {
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
            Text('Similar Cars', style: AppTextStyles.title.copyWith(color: context.textPrimary)),
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
