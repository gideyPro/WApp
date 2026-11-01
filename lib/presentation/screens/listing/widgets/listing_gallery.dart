import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/models/listing.dart';

class ListingGallery extends StatefulWidget {
  final Listing listing;
  final BoxFit fit;

  const ListingGallery({
    super.key,
    required this.listing,
    this.fit = BoxFit.cover,
  });

  @override
  State<ListingGallery> createState() => _ListingGalleryState();
}

class _ListingGalleryState extends State<ListingGallery> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final images = listing.images;

    if (images.isEmpty) {
      return Container(
        color: context.cardBg,
        child: Center(
          child: Icon(Icons.image_not_supported,
              size: 64, color: context.textMuted),
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
              final imageUrl = images[index].imageUrl;

              if (widget.fit == BoxFit.contain) {
                return Container(
                  color: context.isDarkMode
                      ? AppColors.cardNavyDark
                      : Colors.black,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Ambient blurred background matching the photo's colors
                      Opacity(
                        opacity: 0.35,
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          memCacheWidth: 200,
                          placeholder: (_, __) => const SizedBox.shrink(),
                          errorWidget: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(color: Colors.transparent),
                      ),
                      // Foreground full uncropped photo
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        memCacheWidth: 1080,
                        placeholder: (_, __) => Container(
                          color: Colors.transparent,
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image,
                              size: 64, color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return CachedNetworkImage(
                imageUrl: imageUrl,
                fit: widget.fit,
                memCacheWidth: 1080,
                placeholder: (_, __) => Container(
                  color: AppColors.primary100,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.primary100,
                  child: const Icon(Icons.broken_image, size: 64),
                ),
              );
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (images.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentImageIndex + 1}/${images.length}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
