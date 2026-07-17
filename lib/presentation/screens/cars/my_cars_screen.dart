import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/listing.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/car_providers.dart';
import '../../widgets/common/wave_liquid_glass.dart';
import 'car_strings.dart';

class MyCarsScreen extends ConsumerStatefulWidget {
  const MyCarsScreen({super.key});

  @override
  ConsumerState<MyCarsScreen> createState() => _MyCarsScreenState();
}

class _MyCarsScreenState extends ConsumerState<MyCarsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(carListingsProvider.notifier).loadListings();
    });
  }

  Future<void> _deleteListing(Listing listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(CarStrings.confirmDelete),
        content: const Text(CarStrings.deleteConfirmation),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(context).commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context).commonDelete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final response = await ref.read(carServiceProvider).deleteListing(listing.id);

    if (response.success && mounted) {
      ref.read(carListingsProvider.notifier).loadListings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(CarStrings.listingDeleted)),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(carListingsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.primary50,
      appBar: AppBar(
        title: const Text(CarStrings.myCars),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/cars/create'),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.listings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.directions_car, size: 64, color: AppColors.stone300),
                      const SizedBox(height: 16),
                      Text(CarStrings.noListings, style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.push('/cars/create'),
                        child: const Text(CarStrings.addNewListing),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(carListingsProvider.notifier).loadListings(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.listings.length,
                    itemBuilder: (context, index) {
                      final listing = state.listings[index];
                      return _buildCarCard(listing, l10n);
                    },
                  ),
                ),
    );
  }

  Widget _buildCarCard(Listing listing, AppLocalizations l10n) {
    final statusColor = listing.status == ListingStatus.active
        ? AppColors.emerald600
        : listing.status == ListingStatus.pending
            ? AppColors.stone500
            : Colors.red.shade500;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LiquidGlass(
        borderRadius: 12,
        padding: const EdgeInsets.all(12),
        child: InkWell(
          onTap: () => context.push('/cars/${listing.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: listing.images.isNotEmpty
                    ? Image.network(
                        listing.images.first.thumbnailUrl,
                        width: 80, height: 80, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _carPlaceholder(80),
                      )
                    : _carPlaceholder(80),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.carTitle,
                      style: AppTextStyles.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.getLocalizedPrice(context),
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.accent600),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          listing.status.toString().split('.').last,
                          style: AppTextStyles.labelSmall.copyWith(color: statusColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') context.push('/cars/${listing.id}/edit', extra: listing);
                  if (v == 'delete') _deleteListing(listing);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Text(l10n.commonEdit)),
                  PopupMenuItem(value: 'delete', child: Text(l10n.commonDelete, style: const TextStyle(color: Colors.red))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _carPlaceholder(double size) {
    return Container(
      width: size, height: size,
      color: AppColors.stone200,
      child: const Icon(Icons.directions_car, color: AppColors.stone400),
    );
  }
}
