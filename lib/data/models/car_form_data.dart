import 'package:image_picker/image_picker.dart';
import 'image.dart';

class CarFormData {
  String type;
  String vehicleCategory;

  String make;
  String model;
  String year;
  String mileageKm;
  String bodyType;
  String color;
  String condition;
  String vin;
  List<String> features;
  String customFeatures;

  bool isForRent;
  String rentalPeriodUnit;

  String priceFixed;

  String addressRegion;
  String addressZone;
  String addressWoreda;
  String addressKebele;
  int? addressId;
  String specificLocation;

  String description;

  List<XFile> images;

  List<ImageModel> existingImages;
  List<int> removedImageIds;

  bool isVip;

  bool termsAccepted;

  CarFormData({
    this.type = 'car',
    this.vehicleCategory = 'car',
    this.make = '',
    this.model = '',
    this.year = '',
    this.mileageKm = '',
    this.bodyType = '',
    this.color = '',
    this.condition = '',
    this.vin = '',
    List<String>? features,
    this.customFeatures = '',
    this.isForRent = false,
    this.rentalPeriodUnit = '',
    this.priceFixed = '',
    this.addressRegion = '',
    this.addressZone = '',
    this.addressWoreda = '',
    this.addressKebele = '',
    this.addressId,
    this.specificLocation = '',
    this.description = '',
    List<XFile>? images,
    List<ImageModel>? existingImages,
    List<int>? removedImageIds,
    this.isVip = false,
    this.termsAccepted = false,
  })  : features = features ?? [],
        images = images ?? [],
        existingImages = existingImages ?? [],
        removedImageIds = removedImageIds ?? [];

  CarFormData copyWith({
    String? type,
    String? vehicleCategory,
    String? make,
    String? model,
    String? year,
    String? mileageKm,
    String? bodyType,
    String? color,
    String? condition,
    String? vin,
    List<String>? features,
    String? customFeatures,
    bool? isForRent,
    String? rentalPeriodUnit,
    String? priceFixed,
    String? addressRegion,
    String? addressZone,
    String? addressWoreda,
    String? addressKebele,
    int? addressId,
    String? specificLocation,
    String? description,
    List<XFile>? images,
    List<ImageModel>? existingImages,
    List<int>? removedImageIds,
    bool? isVip,
    bool? termsAccepted,
  }) {
    return CarFormData(
      type: type ?? this.type,
      vehicleCategory: vehicleCategory ?? this.vehicleCategory,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      mileageKm: mileageKm ?? this.mileageKm,
      bodyType: bodyType ?? this.bodyType,
      color: color ?? this.color,
      condition: condition ?? this.condition,
      vin: vin ?? this.vin,
      features: features ?? this.features,
      customFeatures: customFeatures ?? this.customFeatures,
      isForRent: isForRent ?? this.isForRent,
      rentalPeriodUnit: rentalPeriodUnit ?? this.rentalPeriodUnit,
      priceFixed: priceFixed ?? this.priceFixed,
      addressRegion: addressRegion ?? this.addressRegion,
      addressZone: addressZone ?? this.addressZone,
      addressWoreda: addressWoreda ?? this.addressWoreda,
      addressKebele: addressKebele ?? this.addressKebele,
      addressId: addressId ?? this.addressId,
      specificLocation: specificLocation ?? this.specificLocation,
      description: description ?? this.description,
      images: images ?? this.images,
      existingImages: existingImages ?? this.existingImages,
      removedImageIds: removedImageIds ?? this.removedImageIds,
      isVip: isVip ?? this.isVip,
      termsAccepted: termsAccepted ?? this.termsAccepted,
    );
  }
}
