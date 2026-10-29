import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/v2/api_v2_client.dart';
import '../../../core/network/v2/api_v2_constants.dart';
import '../../models/v2/listing_summary.dart';
import '../../models/v2/owner_listing.dart';

/// Per-listing media uploads. The backend accepts media only while the listing
/// is a draft or rejected, so callers should gate the UI on
/// [OwnerListing.canEditMedia].
class ListingMediaServiceV2 {
  /// The backend rejects more than 20 images per listing.
  static const int maxImages = 20;

  final ApiV2Client _client;

  ListingMediaServiceV2({ApiV2Client? client})
      : _client = client ?? ApiV2Client();

  Future<List<ListingImage>> uploadImages(
    int listingId,
    List<File> images,
  ) async {
    if (images.isEmpty) {
      throw ArgumentError.value(
          images, 'images', 'At least one image required');
    }
    if (images.length > maxImages) {
      throw ArgumentError.value(
        images,
        'images',
        'At most $maxImages images per request',
      );
    }

    final form = FormData();
    for (final image in images) {
      form.files.add(
        MapEntry('images[]', await _multipart(image)),
      );
    }

    return _client.sendFormList(
      ApiV2Constants.listingImages(listingId),
      formData: form,
      parse: ListingImage.fromJson,
    );
  }

  Future<void> deleteImage(int listingId, int imageId) async {
    await _client.send(
      ApiV2Constants.listingImage(listingId, imageId),
      method: 'DELETE',
    );
  }

  Future<VideoState> fetchVideo(int listingId) async {
    final data = await _client.getItem(
      ApiV2Constants.listingVideo(listingId),
    );
    return VideoState.fromJson(data);
  }

  Future<VideoState> uploadVideo(int listingId, File video) async {
    final form = FormData.fromMap({'video': await _multipart(video)});
    final data = await _client.sendFormItem(
      ApiV2Constants.listingVideo(listingId),
      formData: form,
    );
    return VideoState.fromJson(data);
  }

  Future<void> deleteVideo(int listingId) async {
    await _client.send(
      ApiV2Constants.listingVideo(listingId),
      method: 'DELETE',
    );
  }

  Future<MediaAsset> uploadSitePlan(int listingId, File file) async {
    return _uploadDocument(
      ApiV2Constants.listingSitePlan(listingId),
      file,
    );
  }

  Future<void> deleteSitePlan(int listingId) async {
    await _client.send(
      ApiV2Constants.listingSitePlan(listingId),
      method: 'DELETE',
    );
  }

  Future<MediaAsset> uploadDebtDocument(int listingId, File file) async {
    return _uploadDocument(
      ApiV2Constants.listingDebtDocument(listingId),
      file,
    );
  }

  Future<void> deleteDebtDocument(int listingId) async {
    await _client.send(
      ApiV2Constants.listingDebtDocument(listingId),
      method: 'DELETE',
    );
  }

  Future<MediaAsset> uploadOwnershipProof(int listingId, File file) async {
    return _uploadDocument(
      ApiV2Constants.listingOwnershipProof(listingId),
      file,
    );
  }

  Future<void> deleteOwnershipProof(int listingId) async {
    await _client.send(
      ApiV2Constants.listingOwnershipProof(listingId),
      method: 'DELETE',
    );
  }

  Future<MediaAsset> _uploadDocument(String path, File file) async {
    final form = FormData.fromMap({'file': await _multipart(file)});
    final data = await _client.sendFormItem(path, formData: form);
    return MediaAsset.fromJson(data);
  }

  static Future<MultipartFile> _multipart(File file) {
    final segments = file.uri.pathSegments;
    final filename = segments.isEmpty ? 'upload' : segments.last;
    return MultipartFile.fromFile(file.path, filename: filename);
  }
}
