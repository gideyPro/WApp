import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/models/listing.dart';

class ListingGallery extends StatefulWidget {
  final Listing listing;

  const ListingGallery({super.key, required this.listing});

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
              return CachedNetworkImage(
                imageUrl: images[index].imageUrl,
                fit: BoxFit.cover,
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
                if (listing.viewCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility_outlined, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '${listing.viewCount}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (listing.viewCount > 0 && images.length > 1)
                  const SizedBox(width: 6),
                if (images.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
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
