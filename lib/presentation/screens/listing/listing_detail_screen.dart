import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/listing.dart';
import '../../../../data/services/interest_service.dart';
import '../../providers/listing_provider.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../auth/otp_login_screen.dart';
import '../../widgets/video/video_player_widget.dart';
import '../../../../l10n/app_localizations.dart';

/// Listing Detail Screen with skeleton loaders
class ListingDetailScreen extends ConsumerStatefulWidget {
  final int listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(listingDetailProvider.notifier).loadListing(widget.listingId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listingDetailProvider);

    // Show skeleton while loading, error banner, or content
    if (state.isLoading) {
      return _buildSkeletonLoader();
    }

    if (state.errorMessage != null) {
      return _buildErrorView(state.errorMessage!);
    }

    if (state.listing == null) {
      return _buildNotFound();
    }

    return _buildContent(state.listing!);
  }

  Widget _buildSkeletonLoader() {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image skeleton
          SliverToBoxAdapter(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[200]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                children: [
                  // App bar skeleton
                  Container(
                    height: 56,
                    color: Colors.grey[300],
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  // Image skeleton
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Container(color: Colors.grey[300]),
                  ),
                  // Page indicator skeleton
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 24,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content skeleton
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Shimmer.fromColors(
                baseColor: Colors.grey[200]!,
                highlightColor: Colors.grey[100]!,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price + title
                    Container(
                      height: 28,
                      width: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 18,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Badges skeleton
                    Row(
                      children: [
                        _skeletonChip(50, 20),
                        const SizedBox(width: 8),
                        _skeletonChip(65, 20),
                        const SizedBox(width: 8),
                        _skeletonChip(55, 20),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Location skeleton
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 14,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 40),
                    // Key features skeleton
                    Container(
                      height: 16,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _skeletonChip(80, 32),
                        const SizedBox(width: 8),
                        _skeletonChip(90, 32),
                        const SizedBox(width: 8),
                        _skeletonChip(70, 32),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Description skeleton
                    Container(
                      height: 16,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: List.generate(
                        3,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            height: 14,
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonChip(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.listingsTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.signal_wifi_off_rounded,
                size: 64,
                color: AppColors.navy300,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.listingsLoadError,
                style: AppTextStyles.title,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.navy500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(listingDetailProvider.notifier)
                      .loadListing(widget.listingId);
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(l10n.commonRetry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy950,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFound() {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.listingsTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.home_outlined, size: 64, color: AppColors.navy300),
              const SizedBox(height: 16),
              Text(l10n.listingsNotFound, style: AppTextStyles.title),
              const SizedBox(height: 8),
              Text(
                l10n.listingsNotFoundSubtitle,
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.navy500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.commonOk),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Listing listing) {
    final favState = ref.watch(favoritesProvider);
    final isFavorited = favState.favorites.any((f) => f.id == listing.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image Gallery Sliver
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageGallery(listing),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: isFavorited ? Colors.red : Colors.white,
                ),
                onPressed: () => _toggleFavorite(listing.id, isFavorited),
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () => _shareListing(listing),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceAndTitle(listing),
                  const SizedBox(height: 16),
                  _buildBadges(listing),
                  const SizedBox(height: 8),
                  _buildLocation(listing),
                  const Divider(height: 32),
                  _buildKeyFeatures(listing),
                  const SizedBox(height: 24),
                  _buildDescription(listing),
                  const SizedBox(height: 24),
                  _buildPropertyDetails(listing),
                  const SizedBox(height: 24),
                  _buildActionButtons(listing),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(Listing listing) {
    final images = listing.images;

    if (images.isEmpty) {
      return Container(
        color: AppColors.navy100,
        child: const Center(
          child: Icon(Icons.image_not_supported,
              size: 64, color: AppColors.navy400),
        ),
      );
    }

    return Hero(
      tag: 'listing_image_${listing.id}',
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() => _currentImageIndex = index);
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
              imageUrl: images[index].imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: AppColors.navy100,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.navy100,
                child: const Icon(Icons.broken_image, size: 64),
              ),
            );
          },
        ),
        // Image counter
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentImageIndex + 1}/${images.length}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
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
          listing.getLocalizedTitle(context),
          style: AppTextStyles.headline4,
        ),
      ],
    );
  }

  Widget _buildBadges(Listing listing) {
    final l10n = AppLocalizations.of(context);

    // Calculate total rooms for houses
    final totalRooms = listing.totalRooms;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildBadge(
          listing.propertyType == PropertyType.house
              ? l10n.listingHouse.toUpperCase()
              : l10n.listingLand.toUpperCase(),
          AppColors.navy900,
        ),
        if (listing.listingType == ListingType.sale)
          _buildBadge(l10n.listingForSale.toUpperCase(), AppColors.emerald600)
        else
          _buildBadge(l10n.listingForRent.toUpperCase(), AppColors.wave600),
        if (listing.isFeatured)
          _buildBadge(l10n.listingFeatured.toUpperCase(), AppColors.wave500),
        if (listing.isNew)
          _buildBadge(l10n.listingNew.toUpperCase(), Colors.amber[700]!),
        // Photo count badge
        if (listing.imageCount != null && listing.imageCount! > 0)
          _buildBadge(
            l10n.listingPhotosCount(listing.imageCount!),
            AppColors.navy700,
          ),
        // Total rooms count badge (for houses only)
        if (listing.propertyType == PropertyType.house && totalRooms > 0)
          _buildBadge(
            '$totalRooms ${l10n.listingTotalRooms.toLowerCase()}',
            AppColors.emerald700,
          ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLocation(Listing listing) {
    final l10n = AppLocalizations.of(context);
    final parts = [
      listing.address?.zone,
      listing.address?.woreda,
      listing.address?.region,
    ].where((e) => e != null && e.isNotEmpty).join(', ');

    return Row(
      children: [
        const Icon(Icons.location_on, size: 18, color: AppColors.wave500),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            parts.isNotEmpty ? parts : l10n.listingUnknownLocation,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.navy600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyFeatures(Listing listing) {
    final l10n = AppLocalizations.of(context);
    final features = <Widget>[];

    // For houses: show rooms
    if (listing.propertyType == PropertyType.house) {
      if ((listing.bedrooms ?? 0) > 0) {
        features.add(_buildFeatureChip(
          icon: Icons.bed,
          label: l10n.listingsBedrooms(listing.bedrooms!),
        ));
      }
      if ((listing.bathrooms ?? 0) > 0) {
        features.add(_buildFeatureChip(
          icon: Icons.bathtub,
          label: l10n.listingsBathrooms(listing.bathrooms!),
        ));
      }
      if ((listing.salons ?? 0) > 0) {
        features.add(_buildFeatureChip(
          icon: Icons.weekend,
          label: l10n.listingsSalons(listing.salons!),
        ));
      }
      if ((listing.kitchens ?? 0) > 0) {
        features.add(_buildFeatureChip(
          icon: Icons.kitchen,
          label: l10n.listingKitchensCount(listing.kitchens!),
        ));
      }
    }

    // Square meters
    if (listing.totalSquareMeters != null && listing.totalSquareMeters! > 0) {
      features.add(_buildFeatureChip(
        icon: Icons.square_foot,
        label: l10n.listingUnitM2(listing.totalSquareMeters!.toInt()),
      ));
    }

    // Facing direction
    if (listing.facingDirection != null) {
      features.add(_buildFeatureChip(
        icon: Icons.compass_calibration,
        label: listing.getLocalizedFacingDirection(context),
      ));
    }

    // Holding type
    if (listing.holdingType != null) {
      features.add(_buildFeatureChip(
        icon: Icons.folder_copy,
        label: listing.getLocalizedHoldingType(context),
      ));
    }

    // Date posted
    final daysOld = DateTime.now().difference(listing.createdAt).inDays;
    String dateText;
    if (daysOld == 0) {
      dateText = l10n.listingToday;
    } else if (daysOld == 1) {
      dateText = l10n.listingYesterday;
    } else if (daysOld < 7) {
      dateText = l10n.listingDaysAgo(daysOld);
    } else if (daysOld < 30) {
      dateText = l10n.listingWeeksAgo((daysOld / 7).floor());
    } else {
      dateText = l10n.listingMonthsAgo((daysOld / 30).floor());
    }
    features.add(_buildFeatureChip(
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

  Widget _buildFeatureChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.navy50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.navy600),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.navy700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(Listing listing) {
    final l10n = AppLocalizations.of(context);
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
            color: AppColors.navy700,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyDetails(Listing listing) {
    final l10n = AppLocalizations.of(context);
    final details = <Map<String, String>>[];

    if (listing.propertyType == PropertyType.land) {
      // For land: front area and side area
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

      // Free Hold details
      if (listing.holdingType == 'Free Hold') {
        if (listing.taxPaidUntilYear != null) {
          details.add({
            'label': l10n.listingTaxPaid,
            'value': listing.taxPaidUntilYear.toString()
          });
        }
        if (listing.acquisitionType != null) {
          details.add({
            'label': l10n.listingAcquisition,
            'value': listing.getLocalizedAcquisitionType(context)
          });
        }
      }

      // Lease Hold details
      if (listing.holdingType == 'Lease Hold') {
        if (listing.leaseHolderName != null) {
          details.add({
            'label': l10n.listingLeaseHolder,
            'value': listing.leaseHolderName!
          });
        }
        if (listing.leaseOrganization != null) {
          details.add({
            'label': l10n.listingLeaseOrganization,
            'value': listing.leaseOrganization!
          });
        }
        if (listing.leaseExpiryDate != null) {
          details.add({
            'label': l10n.listingLeaseExpiry,
            'value': listing.leaseExpiryDate!.year.toString()
          });
        }
      }

      // Cooperative details
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
    bool hasVideo = listing.videoUrl != null && listing.videoUrl!.isNotEmpty;

    if (details.isEmpty && !hasVideo) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasVideo) _buildVideoTourSection(listing.videoUrl!),
        Text(l10n.listingsPropertyDetails, style: AppTextStyles.title),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.zinc200),
          ),
          child: Column(
            children: details.asMap().entries.map((entry) {
              final index = entry.key;
              final detail = entry.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          detail['label']!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.navy500,
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

  Widget _buildVideoTourSection(String videoUrl) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.videocam,
                size: 20,
                color: AppColors.wave500,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.listingsVideoTour,
                style: AppTextStyles.title,
              ),
            ],
          ),
          const SizedBox(height: 12),
          VideoPlayerWidget(
            videoUrl: videoUrl,
            autoPlay: false,
            looping: false,
            title: l10n.listingsVideoTour,
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite(int listingId, bool isFavorited) async {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OtpLoginScreen()),
        );
      }
      return;
    }

    final success =
        await ref.read(favoritesProvider.notifier).toggleFavorite(listingId);

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorited ? l10n.favoritesRemoved : l10n.favoritesAdded,
          ),
          backgroundColor: success ? AppColors.wave500 : AppColors.error,
        ),
      );
    }
  }

  Future<void> _shareListing(Listing listing) async {
    final shareText = '''
${listing.getLocalizedTitle(context)}
${listing.getLocalizedPrice(context)}
${listing.description?.isNotEmpty == true ? '\n${listing.description}' : ''}

Shared from WaveMart - Ethiopia's Premier Real Estate Marketplace
''';

    await Share.share(
      shareText,
      subject:
          'Check out this property on WaveMart: ${listing.getLocalizedTitle(context)}',
    );
  }

  Widget _buildActionButtons(Listing listing) {
    final l10n = AppLocalizations.of(context);

    final interestStatus = listing.userInterestStatus;
    final hasInterest = interestStatus != null;
    final isPending = interestStatus == 'pending';
    final isAccepted = interestStatus == 'accepted';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: hasInterest
                    ? OutlinedButton.icon(
                        onPressed: isAccepted
                            ? null
                            : () => _cancelInterest(
                                listing.id, listing.userInterestId),
                        icon: Icon(
                          isAccepted
                              ? Icons.check_circle
                              : isPending
                                  ? Icons.hourglass_empty
                                  : Icons.close,
                          size: 20,
                        ),
                        label: Text(
                          isAccepted
                              ? l10n.listingsInterestAccepted
                              : isPending
                                  ? l10n.listingsInterestPending
                                  : l10n.listingsInterestRejected,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: isAccepted
                                ? AppColors.emerald600
                                : isPending
                                    ? Colors.amber
                                    : AppColors.error,
                          ),
                          foregroundColor: isAccepted
                              ? AppColors.emerald600
                              : isPending
                                  ? Colors.amber[700]
                                  : AppColors.error,
                        ),
                      )
                    : OutlinedButton.icon(
                        onPressed: () => _submitInterest(listing.id),
                        icon: const Icon(Icons.handyman_outlined, size: 20),
                        label: Text(l10n.listingsImInterested),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.wave500),
                          foregroundColor: AppColors.wave600,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitInterest(int listingId, [String? message]) async {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OtpLoginScreen()),
      );
      return;
    }

    final l10n = AppLocalizations.of(context);

    try {
      final service = InterestService();
      final response = await service.expressInterest(
        listingId: listingId,
        message: message?.isNotEmpty == true ? message : l10n.listingsDefaultInterestMessage,
      );

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? l10n.listingsInterestSubmitted),
              backgroundColor: AppColors.emerald600,
            ),
          );
          ref.read(listingDetailProvider.notifier).loadListing(listingId);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? l10n.commonError),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.commonError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _cancelInterest(int listingId, int? interestId) async {
    if (interestId == null) return;

    final l10n = AppLocalizations.of(context);

    try {
      final service = InterestService();
      final response = await service.cancelInterest(interestId);

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? l10n.listingsInterestCancelled),
              backgroundColor: AppColors.emerald600,
            ),
          );
          ref.read(listingDetailProvider.notifier).loadListing(listingId);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? l10n.commonError),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.commonError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

}
