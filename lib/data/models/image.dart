/// Image Model for property images
class ImageModel {
  final int id;
  final String imagePath;
  final String? thumbnailPath;
  final String? imageableType;
  final int? imageableId;
  final int? sortOrder;
  final DateTime? createdAt;

  ImageModel({
    required this.id,
    required this.imagePath,
    this.thumbnailPath,
    this.imageableType,
    this.imageableId,
    this.sortOrder,
    this.createdAt,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'] ?? 0,
      imagePath: json['image_path'] ?? '',
      thumbnailPath: json['thumbnail_path'],
      imageableType: json['imageable_type'],
      imageableId: json['imageable_id'],
      sortOrder: json['sort_order'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_path': imagePath,
      'thumbnail_path': thumbnailPath,
      'imageable_type': imageableType,
      'imageable_id': imageableId,
      'sort_order': sortOrder,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String get imageUrl {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return 'https://wavemart.et/storage/$imagePath';
  }

  String get thumbnailUrl {
    if (thumbnailPath != null) {
      if (thumbnailPath!.startsWith('http')) return thumbnailPath!;
      return 'https://wavemart.et/storage/$thumbnailPath';
    }
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    final parts = imagePath.split('/');
    if (parts.isEmpty) return imageUrl;

    final filename = parts.last;
    final directory = parts.take(parts.length - 1).join('/');

    final thumbPath =
        directory.isEmpty ? 'thumb_$filename' : '$directory/thumb_$filename';
    return 'https://wavemart.et/storage/$thumbPath';
  }

  @override
  String toString() => 'Image(id: $id, path: $imagePath)';
}

class SitePlan {
  final int id;
  final String imagePath;
  final String? sitePlanableType;
  final int? sitePlanableId;
  final DateTime? createdAt;

  SitePlan({
    required this.id,
    required this.imagePath,
    this.sitePlanableType,
    this.sitePlanableId,
    this.createdAt,
  });

  factory SitePlan.fromJson(Map<String, dynamic> json) {
    return SitePlan(
      id: json['id'] ?? 0,
      imagePath: json['image_path'] ?? '',
      sitePlanableType: json['site_planable_type'],
      sitePlanableId: json['site_planable_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_path': imagePath,
      'site_planable_type': sitePlanableType,
      'site_planable_id': sitePlanableId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String get imageUrl {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return 'https://wavemart.et/storage/$imagePath';
  }
}
