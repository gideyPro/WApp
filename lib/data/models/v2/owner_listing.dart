import '../../../core/utils/type_utils.dart';
import 'listing_summary.dart';

/// Moderation state of a listing as seen by its owner.
///
/// The public catalog only ever returns published listings, so this enum also
/// carries `draft`, which never appears in catalog responses.
enum OwnerListingStatus {
  draft('draft'),
  pending('pending'),
  active('active'),
  rejected('rejected'),
  frozen('frozen'),
  unknown('unknown');

  final String wireValue;

  const OwnerListingStatus(this.wireValue);

  static OwnerListingStatus parse(dynamic value) {
    switch (value?.toString()) {
      case 'draft':
        return OwnerListingStatus.draft;
      case 'pending':
        return OwnerListingStatus.pending;
      case 'active':
        return OwnerListingStatus.active;
      case 'rejected':
        return OwnerListingStatus.rejected;
      case 'frozen':
        return OwnerListingStatus.frozen;
      default:
        return OwnerListingStatus.unknown;
    }
  }

  bool get isDraft => this == OwnerListingStatus.draft;

  bool get isPublished => this == OwnerListingStatus.active;

  /// Drafts and rejected listings may be edited and submitted again.
  bool get isEditable => isDraft || this == OwnerListingStatus.rejected;
}

/// Processing state of the optional walkthrough video.
enum VideoStateStatus {
  none('none'),
  pending('pending'),
  processing('processing'),
  ready('ready'),
  failed('failed'),
  unknown('unknown');

  final String wireValue;

  const VideoStateStatus(this.wireValue);

  static VideoStateStatus parse(dynamic value) {
    switch (value?.toString()) {
      case 'none':
        return VideoStateStatus.none;
      case 'pending':
        return VideoStateStatus.pending;
      case 'processing':
        return VideoStateStatus.processing;
      case 'ready':
        return VideoStateStatus.ready;
      case 'failed':
        return VideoStateStatus.failed;
      default:
        return VideoStateStatus.unknown;
    }
  }

  bool get isBusy =>
      this == VideoStateStatus.pending || this == VideoStateStatus.processing;

  bool get hasVideo =>
      this != VideoStateStatus.none && this != VideoStateStatus.unknown;
}

/// Video block returned by the owner feed, detail and media endpoints.
class VideoState {
  final VideoStateStatus status;
  final String? url;
  final String? thumbnailUrl;
  final String? errorMessage;
  final DateTime? uploadedAt;

  const VideoState({
    this.status = VideoStateStatus.none,
    this.url,
    this.thumbnailUrl,
    this.errorMessage,
    this.uploadedAt,
  });

  bool get isReady => status == VideoStateStatus.ready && hasUrl;

  bool get hasVideo => status.hasVideo;

  bool get hasUrl => url != null && url!.isNotEmpty;

  factory VideoState.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return VideoState(
      status: VideoStateStatus.parse(map['status']),
      url: _text(map['url']),
      thumbnailUrl: _text(map['thumbnail_url']),
      errorMessage: _text(map['error_message']),
      uploadedAt: _date(map['uploaded_at']),
    );
  }
}

/// A site plan, debt document or proof URL returned by a media upload.
class MediaAsset {
  final int? id;
  final String? url;

  const MediaAsset({this.id, this.url});

  bool get hasUrl => url != null && url!.isNotEmpty;

  factory MediaAsset.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return MediaAsset(
      id: TypeUtils.safeInt(map['id']),
      url: _text(map['url']),
    );
  }
}

/// Current feature/VIP state returned by the promotion action endpoints.
class PromotionState {
  final int listingId;
  final bool isFeatured;
  final DateTime? featuredUntil;
  final bool isVip;

  const PromotionState({
    required this.listingId,
    this.isFeatured = false,
    this.featuredUntil,
    this.isVip = false,
  });

  factory PromotionState.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return PromotionState(
      listingId: TypeUtils.safeInt(map['listing_id']) ?? 0,
      isFeatured: TypeUtils.safeBool(map['is_featured']),
      featuredUntil: _date(map['featured_until']),
      isVip: TypeUtils.safeBool(map['is_vip']),
    );
  }
}

/// Owner-facing listing row returned by `/v2/me/listings` and every write
/// response. Unlike [ListingSummary] it exposes moderation state and the
/// affordances the owner currently has.
class OwnerListing {
  final int id;
  final int? userId;
  final ListingKind kind;
  final String listingType;
  final String title;
  final String? description;
  final ListingPrice price;
  final ListingLocation location;
  final ListingImage? coverImage;
  final int imagesCount;
  final SummaryDetails summaryDetails;
  final OwnerListingStatus status;
  final String? rejectionReason;
  final bool isFeatured;
  final DateTime? featuredUntil;
  final bool isVip;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? nextEditAt;
  final bool canEdit;
  final bool canEditMedia;
  final bool canSubmit;
  final bool canDelete;
  final VideoState video;

  const OwnerListing({
    required this.id,
    this.userId,
    required this.kind,
    required this.listingType,
    required this.title,
    this.description,
    required this.price,
    required this.location,
    this.coverImage,
    this.imagesCount = 0,
    this.summaryDetails = const SummaryDetails(),
    this.status = OwnerListingStatus.unknown,
    this.rejectionReason,
    this.isFeatured = false,
    this.featuredUntil,
    this.isVip = false,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.nextEditAt,
    this.canEdit = false,
    this.canEditMedia = false,
    this.canSubmit = false,
    this.canDelete = false,
    this.video = const VideoState(),
  });

  bool get isDraft => status == OwnerListingStatus.draft;

  bool get isRejected => status == OwnerListingStatus.rejected;

  /// True while moderation is running and every edit is blocked.
  bool get isLocked => status == OwnerListingStatus.pending;

  factory OwnerListing.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return OwnerListing(
      id: TypeUtils.safeInt(map['id']) ?? 0,
      userId: TypeUtils.safeInt(map['user_id']),
      kind: ListingKind.parse(map['type']),
      listingType: map['listing_type']?.toString() ?? 'sale',
      title: map['title']?.toString() ?? '',
      description: _text(map['description']),
      price: ListingPrice.fromJson(map['price']),
      location: ListingLocation.fromJson(map['location']),
      coverImage: map['cover_image'] is Map
          ? ListingImage.fromJson(map['cover_image'])
          : null,
      imagesCount: TypeUtils.safeInt(map['images_count']) ?? 0,
      summaryDetails: SummaryDetails.fromJson(map['details']),
      status: OwnerListingStatus.parse(map['status']),
      rejectionReason: _text(map['rejection_reason']),
      isFeatured: TypeUtils.safeBool(map['is_featured']),
      featuredUntil: _date(map['featured_until']),
      isVip: TypeUtils.safeBool(map['is_vip']),
      expiresAt: _date(map['expires_at']),
      createdAt: _date(map['created_at']),
      updatedAt: _date(map['updated_at']),
      nextEditAt: _date(map['next_edit_at']),
      canEdit: TypeUtils.safeBool(map['can_edit']),
      canEditMedia: TypeUtils.safeBool(map['can_edit_media']),
      canSubmit: TypeUtils.safeBool(map['can_submit']),
      canDelete: TypeUtils.safeBool(map['can_delete']),
      video: VideoState.fromJson(map['video']),
    );
  }
}

String? _text(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
