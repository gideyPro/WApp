import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/listing.dart';
import '../../../data/models/address.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/car_providers.dart';
import '../../widgets/common/wave_liquid_glass.dart';
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.primary50,
      appBar: AppBar(
        title: const Text(CarStrings.listingDetail),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.errorMessage!, style: const TextStyle(color: AppColors.stone500)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.read(carDetailProvider.notifier).loadListing(widget.listingId),
                        child: Text(l10n.commonRetry),
                      ),
                    ],
                  ),
                )
              : state.listing == null
                  ? const SizedBox()
                  : _buildContent(context, state.listing!, l10n),
    );
  }

  Widget _buildContent(BuildContext context, Listing listing, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageGallery(listing),
          const SizedBox(height: 12),
          LiquidGlass(
            borderRadius: 12,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.carTitle,
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.local_offer, size: 16, color: AppColors.accent600),
                    const SizedBox(width: 4),
                    Text(
                      listing.getLocalizedPrice(context),
                      style: AppTextStyles.titleSmall.copyWith(color: AppColors.accent600),
                    ),
                  ],
                ),
                if (listing.address != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.stone500),
                      const SizedBox(width: 4),
                      Expanded(child: Text(_formatAddress(listing.address!), style: AppTextStyles.bodySmall)),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: AppColors.stone400),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d, yyyy').format(listing.createdAt),
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.stone400),
                    ),
                    const Spacer(),
                    Text('${listing.viewCount} views', style: AppTextStyles.labelSmall.copyWith(color: AppColors.stone400)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSpecsSection(listing),
          if (listing.description != null && listing.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            LiquidGlass(
              borderRadius: 12,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(CarStrings.listingDescription, style: AppTextStyles.titleSmall),
                  const SizedBox(height: 8),
                  Text(listing.description!, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
          if (listing.carFeatures != null && listing.carFeatures!.isNotEmpty) ...[
            const SizedBox(height: 12),
            LiquidGlass(
              borderRadius: 12,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(CarStrings.listingFeatures, style: AppTextStyles.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: listing.carFeatures!.map((f) => Chip(
                      label: Text(f, style: AppTextStyles.labelSmall),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildImageGallery(Listing listing) {
    if (listing.images.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 240,
          color: AppColors.stone200,
          child: const Center(
            child: Icon(Icons.directions_car, size: 64, color: AppColors.stone400),
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
                color: AppColors.stone200,
                child: const Icon(Icons.broken_image, color: AppColors.stone400),
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

    return LiquidGlass(
      borderRadius: 12,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(CarStrings.listingSpecifications, style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          ...specs.map((spec) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(spec.key, style: AppTextStyles.labelSmall.copyWith(color: AppColors.stone500)),
                ),
                Expanded(child: Text(spec.value, style: AppTextStyles.bodySmall)),
              ],
            ),
          )),
        ],
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
}
