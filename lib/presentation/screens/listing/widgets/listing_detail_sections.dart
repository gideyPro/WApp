import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/models/listing.dart';
import '../../../widgets/common/wave_card.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/ethiopian_date_helper.dart';
import '../../../widgets/common/wave_upgrade_card.dart';
import '../../../widgets/common/wave_liquid_glass.dart';
import '../../../widgets/video/video_player_widget.dart';
import '../../../providers/app_providers.dart';
import '../../../../l10n/app_localizations.dart';

class ListingDetailSections extends ConsumerWidget {
  final Listing listing;

  const ListingDetailSections({super.key, required this.listing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPriceAndTitle(context, ref),
        const SizedBox(height: 16),
        _buildBadges(context),
        const SizedBox(height: 8),
        _buildLocation(context, ref),
        const Divider(height: 32),
        _buildKeyFeatures(context, l10n),
        const SizedBox(height: 24),
        _buildAmenities(context, l10n),
        const SizedBox(height: 24),
        _buildDescription(context, l10n),
        const SizedBox(height: 24),
        _buildPropertyDetails(context, ref, l10n),
      ],
    );
  }

  Widget _buildPriceAndTitle(BuildContext context, WidgetRef ref) {
    final cache = ref.watch(addressCacheProvider);
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
          listing.getLocalizedTitle(context, cache),
          style: AppTextStyles.headline4,
        ),
      ],
    );
  }

  Widget _buildBadges(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totalRooms = listing.totalRooms;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildBadge(
          listing.propertyType == PropertyType.house
              ? l10n.listingHouse.toUpperCase()
              : l10n.listingLand.toUpperCase(),
          AppColors.primary900,
        ),
        if (listing.listingType == ListingType.sale)
          _buildBadge(l10n.listingForSale.toUpperCase(), AppColors.emerald600)
        else
          _buildBadge(l10n.listingForRent.toUpperCase(), AppColors.accent600),
        if (listing.isFeatured)
          _buildBadge(l10n.listingFeatured.toUpperCase(), AppColors.accent500),
        if (listing.isVip)
          _buildBadge(l10n.vipBadge, AppColors.vip),
        if (listing.isNew)
          _buildBadge(l10n.listingNew.toUpperCase(), AppColors.warning),
        if (listing.status == ListingStatus.frozen)
          _buildBadge('FROZEN', AppColors.error),
        if (listing.imageCount != null && listing.imageCount! > 0)
          _buildBadge(
            l10n.listingPhotosCount(listing.imageCount!),
            AppColors.primary700,
          ),
        if (listing.propertyType == PropertyType.house && totalRooms > 0)
          _buildBadge(
            '$totalRooms ${l10n.listingTotalRooms.toLowerCase()}',
            AppColors.emerald700,
          ),
        if (listing.propertyType == PropertyType.house &&
            listing.houseType != null &&
            listing.houseType!.isNotEmpty)
          _buildBadge(
            listing.getLocalizedHouseType(context).toUpperCase(),
            AppColors.stone700,
          ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLocation(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cache = ref.watch(addressCacheProvider);

    final subState = ref.watch(subscriptionProvider);
    final isRestricted = !subState.canSeeFullAddress;

    final location = listing.address?.getLocalizedAddress(context, cache, isRestricted) ??
        l10n.listingUnknownLocation;

    return Row(
      children: [
        const Icon(Icons.location_on, size: 18, color: AppColors.accent500),
        const SizedBox(width: 4),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  location,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary600,
                  ),
                ),
              ),
              if (isRestricted) ...[
                const SizedBox(width: 6),
                Icon(Icons.lock_outline, size: 14, color: context.theme.textMuted),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyFeatures(BuildContext context, AppLocalizations l10n) {
    final features = <Widget>[];

    if (listing.propertyType == PropertyType.house) {
      if ((listing.bedrooms ?? 0) > 0) {
        features.add(_buildFeatureChip(context, 
          icon: Icons.bed,
          label: l10n.listingsBedrooms(listing.bedrooms!),
        ));
      }
      if ((listing.bathrooms ?? 0) > 0) {
        features.add(_buildFeatureChip(context, 
          icon: Icons.bathtub,
          label: l10n.listingsBathrooms(listing.bathrooms!),
        ));
      }
      if ((listing.salons ?? 0) > 0) {
        features.add(_buildFeatureChip(context, 
          icon: Icons.weekend,
          label: l10n.listingsSalons(listing.salons!),
        ));
      }
      if ((listing.kitchens ?? 0) > 0) {
        features.add(_buildFeatureChip(context, 
          icon: Icons.kitchen,
          label: l10n.listingKitchensCount(listing.kitchens!),
        ));
      }
    }

    if (listing.totalSquareMeters != null && listing.totalSquareMeters! > 0) {
      features.add(_buildFeatureChip(context, 
        icon: Icons.square_foot,
        label: l10n.listingUnitM2(listing.totalSquareMeters!.toInt()),
      ));
    }

    if (listing.facingDirection != null) {
      features.add(_buildFeatureChip(context, 
        icon: Icons.compass_calibration,
        label: listing.getLocalizedFacingDirection(context),
      ));
    }

    if (listing.holdingType != null) {
      features.add(_buildFeatureChip(context, 
        icon: Icons.folder_copy,
        label: listing.getLocalizedHoldingType(context),
      ));
    }

    final locale = Localizations.localeOf(context).languageCode;
    final dateText = EthiopianDateHelper.formatEthiopian(listing.createdAt, locale);
    features.add(_buildFeatureChip(context, 
      icon: Icons.access_time,
      label: dateText,
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.listingsKeyFeatures, style: AppTextStyles.title),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: features.isNotEmpty
              ? features
              : [Text(l10n.listingsNoFeatures, style: AppTextStyles.caption)],
        ),
      ],
    );
  }

  Widget _buildFeatureChip(BuildContext context, {required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: context.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accent500),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenities(BuildContext context, AppLocalizations l10n) {
    final amenities = <Widget>[];

    if (listing.electricity) {
      amenities.add(_buildAmenityChip(context,
        Icons.bolt,
        l10n.listingElectricity,
      ));
    }
    if (listing.water) {
      amenities.add(_buildAmenityChip(context,
        Icons.water_drop,
        l10n.listingWater,
      ));
    }
    if (listing.parkingAvailable) {
      amenities.add(_buildAmenityChip(context,
        Icons.local_parking,
        l10n.listingParking,
      ));
    }
    if (listing.yearBuilt != null && listing.yearBuilt! > 0) {
      amenities.add(_buildAmenityChip(context,
        Icons.calendar_today,
        '${l10n.listingYearBuilt}: ${EthiopianDateHelper.formatYear(listing.yearBuilt!)}',
      ));
    }

    if (amenities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.listingAmenities, style: AppTextStyles.title),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: amenities,
        ),
      ],
    );
  }

  Widget _buildAmenityChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: context.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accent500),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.listingsDescription, style: AppTextStyles.title),
        const SizedBox(height: 8),
        Text(
          listing.description?.isNotEmpty == true
              ? listing.description!
              : l10n.listingsNoDescription,
          style: AppTextStyles.bodyMedium.copyWith(
            color: context.theme.textTertiary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyDetails(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final details = <Map<String, String>>[];

    if (listing.propertyType == PropertyType.land) {
      if ((listing.frontAreaSqm ?? 0) > 0) {
        details.add({
          'label': l10n.listingsFrontArea,
          'value': l10n.listingUnitM2(listing.frontAreaSqm!.toInt())
        });
      }
      if ((listing.sideAreaSqm ?? 0) > 0) {
        details.add({
          'label': l10n.listingsSideArea,
          'value': l10n.listingUnitM2(listing.sideAreaSqm!.toInt())
        });
      }
    }

    if (listing.useType != null) {
      details.add({
        'label': l10n.listingsUseType,
        'value': listing.getLocalizedUseType(context)
      });
    }
    if (listing.holdingType != null) {
      details.add({
        'label': l10n.listingsHoldingType,
        'value': listing.getLocalizedHoldingType(context)
      });

      if (listing.holdingType == 'Free Hold') {
        if (listing.taxPaidUntilYear != null) {
          details.add({
            'label': l10n.listingTaxPaid,
            'value': EthiopianDateHelper.formatYear(listing.taxPaidUntilYear!)
          });
        }
        if (listing.acquisitionType != null) {
          details.add({
            'label': l10n.listingAcquisition,
            'value': listing.getLocalizedAcquisitionType(context)
          });
        }
      }

      if (listing.holdingType == 'Lease Hold') {
        if (listing.leasedYear != null) {
          details.add({
            'label': l10n.listingLeasedYear,
            'value': EthiopianDateHelper.formatYear(listing.leasedYear!)
          });
        }
        if (listing.leasePricePerSqm != null) {
          details.add({
            'label': l10n.listingLeasePrice,
            'value': '${listing.leasePricePerSqm!.toInt()} ETB'
          });
        }
        if (listing.annualPayment != null) {
          details.add({
            'label': l10n.listingAnnualPayment,
            'value': '${listing.annualPayment!.toInt()} ETB'
          });
        }
        if (listing.buildType != null) {
          details.add(
              {'label': l10n.listingBuildType, 'value': listing.buildType!});
        }
        details.add({
          'label': l10n.listingIsTransferable,
          'value': listing.isTransferable
              ? l10n.listingTransferable
              : l10n.listingNotTransferable,
        });
      }

      if (listing.holdingType == 'Cooperative') {
        if (listing.cooperativeName != null) {
          details.add({
            'label': l10n.listingCooperativeName,
            'value': listing.cooperativeName!
          });
        }
        if (listing.cooperativeCode != null) {
          details.add({
            'label': l10n.listingCooperativeCode,
            'value': listing.cooperativeCode!
          });
        }
        if (listing.buildingStatus != null) {
          details.add({
            'label': l10n.listingBuildingStatus,
            'value': listing.buildingStatus == 'Finished'
                ? l10n.listingFinished
                : l10n.listingUnfinished
          });
        }
      }
    }
    if (listing.facingDirection != null) {
      details.add({
        'label': l10n.listingsFacing,
        'value': listing.getLocalizedFacingDirection(context)
      });
    }
    if (listing.priceRevisionPossible) {
      details.add(
          {'label': l10n.searchPriceRange, 'value': l10n.listingsNegotiable});
    }
    if (listing.hasDebtOrEncumbrance) {
      final debtAmount = listing.debtAmount;
      final amount = debtAmount != null
          ? l10n.listingsEncumbranceYes(debtAmount.toInt())
          : l10n.listingsYes;
      details.add({'label': l10n.listingsEncumbrance, 'value': amount});
    }
    bool hasVideo = (listing.videoUrl != null && listing.videoUrl!.isNotEmpty) || listing.videoBlocked;
    bool hasVideoProcessing = listing.hasVideoProcessing;
    bool vipBlocked = listing.vipBlocked;

    if (details.isEmpty && !hasVideo && !hasVideoProcessing && !vipBlocked) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasVideo) _buildVideoSection(context, ref, l10n),
        if (vipBlocked) _buildVipBlockedSection(l10n),
        Text(l10n.listingsPropertyDetails, style: AppTextStyles.title),
        const SizedBox(height: 12),
        WaveCard(
          useLiquidGlass: true,
          isGlass: true,
          showBorder: false,
          padding: EdgeInsets.zero,
          child: Column(
            children: details.asMap().entries.map((entry) {
              final index = entry.key;
              final detail = entry.value;
              return Column(
                children: [
                  Padding(
                    padding: AppSpacing.paddingLg,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          detail['label']!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary500,
                          ),
                        ),
                        Text(
                          detail['value']!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < details.length - 1) const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSection(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.videocam, size: 20, color: AppColors.accent500),
              const SizedBox(width: 8),
              Text(l10n.listingsVideoTour, style: AppTextStyles.title),
              if (listing.videoProcessing != null && listing.videoProcessing!.status != VideoProcessingStatus.none) ...[
                const SizedBox(width: 8),
                _buildVideoStatusBadge(listing.videoProcessing!.status),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _buildVideoContent(context, ref, l10n),
        ],
      ),
    );
  }

  Widget _buildVipBlockedSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: UpgradeCard(
        icon: Icons.diamond_outlined,
        iconColor: AppColors.vip,
        title: l10n.listingUpgradeToVip,
        subtitle: l10n.subscriptionRequiredDetailsSubtitle,
        buttonLabel: l10n.ordersUpgradePlan,
      ),
    );
  }

  Widget _buildVideoStatusBadge(VideoProcessingStatus status) {
    final (Color bg, Color fg, String text) = switch (status) {
      VideoProcessingStatus.pending ||
      VideoProcessingStatus.processing =>
        (AppColors.warningLight, AppColors.warning, 'Processing'),
      VideoProcessingStatus.ready =>
        (AppColors.successLight, AppColors.success, 'Ready'),
      VideoProcessingStatus.failed =>
        (AppColors.errorLight, AppColors.error, 'Failed'),
      VideoProcessingStatus.none =>
        (AppColors.successLight, AppColors.success, 'Available'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildVideoContent(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    if (listing.videoBlocked) {
      return UpgradeCard(
        icon: Icons.workspace_premium_outlined,
        iconColor: AppColors.accent500,
        title: l10n.subscriptionVideoUpgrade,
        subtitle: l10n.subscriptionRequiredDetailsSubtitle,
        buttonLabel: l10n.ordersUpgradePlan,
      );
    }

    final vp = listing.videoProcessing;

    if (vp == null) {
      return VideoPlayerWidget(
        videoUrl: listing.videoUrl!,
        autoPlay: false,
        looping: false,
        title: l10n.listingsVideoTour,
      );
    }

    return switch (vp.status) {
      VideoProcessingStatus.pending ||
      VideoProcessingStatus.processing =>
        _buildProcessingIndicator(l10n),
      VideoProcessingStatus.ready => Column(
          children: [
            VideoPlayerWidget(
              videoUrl: listing.processedVideoUrl ?? listing.videoUrl!,
              thumbnailUrl: vp.thumbnailUrl,
              autoPlay: false,
              looping: false,
              title: l10n.listingsVideoTour,
            ),
            const SizedBox(height: 8),
            _buildViewOriginalLink(context, l10n, listing.videoUrl!),
          ],
        ),
      VideoProcessingStatus.failed => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VideoPlayerWidget(
              videoUrl: listing.videoUrl!,
              thumbnailUrl: vp.thumbnailUrl,
              autoPlay: false,
              looping: false,
              title: l10n.listingsVideoTour,
            ),
            if (vp.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  vp.errorMessage!,
                  style: AppTextStyles.caption.copyWith(color: AppColors.error),
                ),
              ),
          ],
        ),
      VideoProcessingStatus.none => VideoPlayerWidget(
          videoUrl: listing.videoUrl!,
          thumbnailUrl: vp.thumbnailUrl,
          autoPlay: false,
          looping: false,
          title: l10n.listingsVideoTour,
        ),
    };
  }

  Widget _buildProcessingIndicator(AppLocalizations l10n) {
    return SizedBox(
      height: 200,
      child: LiquidGlass(
        borderRadius: 4,
        blur: 20,
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.accent500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.listingsVideoOptimizing,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary600,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildViewOriginalLink(BuildContext context, AppLocalizations l10n, String originalUrl) {
    return InkWell(
      onTap: () {
        context.push('/video', extra: originalUrl);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.listingsViewOriginal,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.accent500,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.open_in_new, size: 14, color: AppColors.accent500),
          ],
        ),
      ),
    );
  }
}
