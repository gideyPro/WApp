import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import '../../l10n/app_localizations.dart';
import 'image.dart';

/// Complete form data for create/edit listing
class ListingFormData {
  // --- Basics ---
  String type; // 'house' | 'land'
  String holdingType; // 'Free Hold' | 'Lease Hold' | 'Cooperative'
  String listingType; // 'sale' | 'rental'
  String useType; // 'Residential' | 'Commercial' | 'Mixed' | 'Investment'
  String? specificLocation;
  double? priceFixed;
  String? rentalPeriodUnit; // 'day' | 'week' | 'month' | 'year'

  // --- Free Hold ---
  int? taxPaidUntilYear;
  String?
      acquisitionClarification; // 'Purchased' | 'Inherited' | 'Gift' | 'Assignment' | 'Other'

  // --- Lease Hold ---
  int? leasedYear;
  double? leasePricePerSqm;
  String? buildType;
  double? annualPayment;
  bool isTransferable = true;

  // --- Cooperative ---
  String? cooperativeName;
  String? cooperativeCode;
  String? buildingStatus; // 'Finished' | 'Unfinished'

  // --- House Details ---
  int? totalRooms;
  int? bedrooms;
  int? bathrooms;
  int? kitchens;
  int? salons;
  int? floors;
  int? yearBuilt;
  String? houseType; // 'villa' | 'apartment' | 'condominium' | 'townhouse' | 'bungalow' | 'cooperative_140' | ...
  bool electricity = false;
  bool water = false;
  bool parkingAvailable = false;

  // --- Area ---
  double? totalSquareMeters;
  double? frontAreaSqm;
  double? sideAreaSqm;

  // --- Common ---
  String? facingDirection; // 'north' | 'south' | 'east' | 'west' | ...
  String? description;
  String? serviceType;

  // --- Address ---
  String? addressRegion;
  String? addressZone;
  String? addressWoreda;
  String? addressKebele;
  int? addressId;

  // --- Debt ---
  bool hasDebtOrEncumbrance = false;
  double? debtAmount;
  String? debtHolder;

  // --- Options ---
  bool isVip = false;

  // --- Terms ---
  bool termsAccepted = false;

  // --- Media (not persisted to Hive, kept in memory only) ---
  List<XFile> images = [];
  XFile? sitePlan;
  XFile? ownershipProof;
  XFile? videoFile;

  // --- Existing Media (for Edit mode) ---
  List<ImageModel> existingImages = [];
  List<int> removedImageIds = [];
  String? existingSitePlanUrl;
  bool removeExistingSitePlan = false;
  bool deleteVideo = false;
  String? existingOwnershipProofUrl;
  String? existingVideoUrl;

  ListingFormData({
    this.type = 'house',
    this.holdingType = 'Free Hold',
    this.listingType = 'sale',
    this.useType = 'Residential',
    this.specificLocation,
    this.priceFixed,
    this.rentalPeriodUnit,
    this.taxPaidUntilYear,
    this.acquisitionClarification,
    this.leasedYear,
    this.leasePricePerSqm,
    this.buildType,
    this.annualPayment,
    this.isTransferable = true,
    this.cooperativeName,
    this.cooperativeCode,
    this.buildingStatus,
    this.totalRooms,
    this.bedrooms,
    this.bathrooms,
    this.kitchens,
    this.salons,
    this.floors,
    this.yearBuilt,
    this.houseType,
    this.electricity = false,
    this.water = false,
    this.parkingAvailable = false,
    this.totalSquareMeters,
    this.frontAreaSqm,
    this.sideAreaSqm,
    this.facingDirection,
    this.description,
    this.serviceType,
    this.addressRegion,
    this.addressZone,
    this.addressWoreda,
    this.addressKebele,
    this.addressId,
    this.hasDebtOrEncumbrance = false,
    this.debtAmount,
    this.debtHolder,
    this.isVip = false,
    this.termsAccepted = false,
    this.existingImages = const [],
    this.removedImageIds = const [],
    this.existingSitePlanUrl,
    this.removeExistingSitePlan = false,
    this.deleteVideo = false,
    this.existingOwnershipProofUrl,
    this.existingVideoUrl,
  });

  /// Create empty form data with defaults
  factory ListingFormData.empty() => ListingFormData();

  /// Save to Hive for draft persistence
  Future<void> saveDraft() async {
    try {
      final box = await Hive.openBox('listing_drafts');
      final data = {
        'type': type,
        'holdingType': holdingType,
        'listingType': listingType,
        'useType': useType,
        'specificLocation': specificLocation,
        'priceFixed': priceFixed,
        'rentalPeriodUnit': rentalPeriodUnit,
        'taxPaidUntilYear': taxPaidUntilYear,
        'acquisitionClarification': acquisitionClarification,
        'leasedYear': leasedYear,
        'leasePricePerSqm': leasePricePerSqm,
        'buildType': buildType,
        'annualPayment': annualPayment,
        'isTransferable': isTransferable,
        'cooperativeName': cooperativeName,
        'cooperativeCode': cooperativeCode,
        'buildingStatus': buildingStatus,
        'totalRooms': totalRooms,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'kitchens': kitchens,
        'salons': salons,
        'floors': floors,
        'yearBuilt': yearBuilt,
        'houseType': houseType,
        'electricity': electricity,
        'water': water,
        'parkingAvailable': parkingAvailable,
        'totalSquareMeters': totalSquareMeters,
        'frontAreaSqm': frontAreaSqm,
        'sideAreaSqm': sideAreaSqm,
        'facingDirection': facingDirection,
        'description': description,
        'serviceType': serviceType,
        'addressRegion': addressRegion,
        'addressZone': addressZone,
        'addressWoreda': addressWoreda,
        'addressKebele': addressKebele,
        'addressId': addressId,
        'hasDebtOrEncumbrance': hasDebtOrEncumbrance,
        'debtAmount': debtAmount,
        'debtHolder': debtHolder,
        'isVip': isVip,
        'termsAccepted': termsAccepted,
        'savedAt': DateTime.now().toIso8601String(),
      };
      await box.put('current_draft', data);
    } catch (_) {
      // Silently fail - drafts are non-critical
    }
  }

  /// Restore from Hive
  static ListingFormData? loadDraft() {
    try {
      final box = Hive.box('listing_drafts');
      final data = box.get('current_draft');
      if (data == null) return null;

      // Check if draft is older than 24 hours - discard stale drafts
      final savedAt = data['savedAt'];
      if (savedAt != null) {
        final savedTime = DateTime.parse(savedAt);
        if (DateTime.now().difference(savedTime).inHours > 24) {
          box.delete('current_draft');
          return null;
        }
      }

      return ListingFormData(
        type: data['type'] ?? 'house',
        holdingType: data['holdingType'] ?? 'Free Hold',
        listingType: data['listingType'] ?? 'sale',
        useType: data['useType'] ?? 'Residential',
        specificLocation: data['specificLocation'],
        priceFixed: data['priceFixed'],
        rentalPeriodUnit: data['rentalPeriodUnit'],
        taxPaidUntilYear: data['taxPaidUntilYear'],
        acquisitionClarification: data['acquisitionClarification'],
        leasedYear: data['leasedYear'],
        leasePricePerSqm: data['leasePricePerSqm'],
        buildType: data['buildType'],
        annualPayment: data['annualPayment'],
        isTransferable: data['isTransferable'] ?? true,
        cooperativeName: data['cooperativeName'],
        cooperativeCode: data['cooperativeCode'],
        buildingStatus: data['buildingStatus'],
        totalRooms: data['totalRooms'],
        bedrooms: data['bedrooms'],
        bathrooms: data['bathrooms'],
        kitchens: data['kitchens'],
        salons: data['salons'],
        floors: data['floors'],
        yearBuilt: data['yearBuilt'],
        houseType: data['houseType'],
        electricity: data['electricity'] ?? false,
        water: data['water'] ?? false,
        parkingAvailable: data['parkingAvailable'] ?? false,
        totalSquareMeters: data['totalSquareMeters'],
        frontAreaSqm: data['frontAreaSqm'],
        sideAreaSqm: data['sideAreaSqm'],
        facingDirection: data['facingDirection'],
        description: data['description'],
        serviceType: data['serviceType'],
        addressRegion: data['addressRegion'],
        addressZone: data['addressZone'],
        addressWoreda: data['addressWoreda'],
        addressKebele: data['addressKebele'],
        addressId: data['addressId'],
        hasDebtOrEncumbrance: data['hasDebtOrEncumbrance'] ?? false,
        debtAmount: data['debtAmount'],
        debtHolder: data['debtHolder'],
        isVip: data['isVip'] ?? false,
        termsAccepted: data['termsAccepted'] ?? false,
      );
    } catch (_) {
      return null;
    }
  }

  /// Clear draft from Hive
  static Future<void> clearDraft() async {
    try {
      final box = await Hive.openBox('listing_drafts');
      await box.delete('current_draft');
    } catch (_) {}
  }

  /// Create a copy with some fields updated
  ListingFormData copyWith({
    String? type,
    String? holdingType,
    String? listingType,
    String? useType,
    String? specificLocation,
    double? priceFixed,
    String? rentalPeriodUnit,
    int? taxPaidUntilYear,
    String? acquisitionClarification,
    int? leasedYear,
    double? leasePricePerSqm,
    String? buildType,
    double? annualPayment,
    bool? isTransferable,
    String? cooperativeName,
    String? cooperativeCode,
    String? buildingStatus,
    int? totalRooms,
    int? bedrooms,
    int? bathrooms,
    int? kitchens,
    int? salons,
    int? floors,
    int? yearBuilt,
    String? houseType,
    bool? electricity,
    bool? water,
    bool? parkingAvailable,
    double? totalSquareMeters,
    double? frontAreaSqm,
    double? sideAreaSqm,
    String? facingDirection,
    String? description,
    String? serviceType,
    String? addressRegion,
    String? addressZone,
    String? addressWoreda,
    String? addressKebele,
    int? addressId,
    bool? hasDebtOrEncumbrance,
    double? debtAmount,
    String? debtHolder,
    bool? isVip,
    bool? termsAccepted,
    List<XFile>? images,
    XFile? sitePlan,
    XFile? ownershipProof,
    XFile? videoFile,
    List<ImageModel>? existingImages,
    List<int>? removedImageIds,
    String? existingSitePlanUrl,
    bool? removeExistingSitePlan,
    bool? deleteVideo,
    String? existingOwnershipProofUrl,
    String? existingVideoUrl,
  }) {
    return ListingFormData(
      type: type ?? this.type,
      holdingType: holdingType ?? this.holdingType,
      listingType: listingType ?? this.listingType,
      useType: useType ?? this.useType,
      specificLocation: specificLocation ?? this.specificLocation,
      priceFixed: priceFixed ?? this.priceFixed,
      rentalPeriodUnit: rentalPeriodUnit ?? this.rentalPeriodUnit,
      taxPaidUntilYear: taxPaidUntilYear ?? this.taxPaidUntilYear,
      acquisitionClarification:
          acquisitionClarification ?? this.acquisitionClarification,
      leasedYear: leasedYear ?? this.leasedYear,
      leasePricePerSqm: leasePricePerSqm ?? this.leasePricePerSqm,
      buildType: buildType ?? this.buildType,
      annualPayment: annualPayment ?? this.annualPayment,
      isTransferable: isTransferable ?? this.isTransferable,
      cooperativeName: cooperativeName ?? this.cooperativeName,
      cooperativeCode: cooperativeCode ?? this.cooperativeCode,
      buildingStatus: buildingStatus ?? this.buildingStatus,
      totalRooms: totalRooms ?? this.totalRooms,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      kitchens: kitchens ?? this.kitchens,
      salons: salons ?? this.salons,
      floors: floors ?? this.floors,
      yearBuilt: yearBuilt ?? this.yearBuilt,
      houseType: houseType ?? this.houseType,
      electricity: electricity ?? this.electricity,
      water: water ?? this.water,
      parkingAvailable: parkingAvailable ?? this.parkingAvailable,
      totalSquareMeters: totalSquareMeters ?? this.totalSquareMeters,
      frontAreaSqm: frontAreaSqm ?? this.frontAreaSqm,
      sideAreaSqm: sideAreaSqm ?? this.sideAreaSqm,
      facingDirection: facingDirection ?? this.facingDirection,
      description: description ?? this.description,
      serviceType: serviceType ?? this.serviceType,
      addressRegion: addressRegion ?? this.addressRegion,
      addressZone: addressZone ?? this.addressZone,
      addressWoreda: addressWoreda ?? this.addressWoreda,
      addressKebele: addressKebele ?? this.addressKebele,
      addressId: addressId ?? this.addressId,
      hasDebtOrEncumbrance: hasDebtOrEncumbrance ?? this.hasDebtOrEncumbrance,
      debtAmount: debtAmount ?? this.debtAmount,
      debtHolder: debtHolder ?? this.debtHolder,
      isVip: isVip ?? this.isVip,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      existingImages: existingImages ?? this.existingImages,
      removedImageIds: removedImageIds ?? this.removedImageIds,
      existingSitePlanUrl: existingSitePlanUrl ?? this.existingSitePlanUrl,
      removeExistingSitePlan:
          removeExistingSitePlan ?? this.removeExistingSitePlan,
      deleteVideo: deleteVideo ?? this.deleteVideo,
      existingOwnershipProofUrl:
          existingOwnershipProofUrl ?? this.existingOwnershipProofUrl,
      existingVideoUrl: existingVideoUrl ?? this.existingVideoUrl,
    )
      ..images = images ?? this.images
      ..sitePlan = sitePlan ?? this.sitePlan
      ..ownershipProof = ownershipProof ?? this.ownershipProof
      ..videoFile = videoFile ?? this.videoFile;
  }

  /// Validate step 1 (Basics)
  List<String> validateStep1(AppLocalizations l10n) {
    final errors = <String>[];
    if (type.isEmpty) errors.add(l10n.listingErrorPropertyTypeRequired);
    if (holdingType.isEmpty) errors.add(l10n.listingErrorHoldingTypeRequired);
    if (listingType.isEmpty) errors.add(l10n.listingErrorListingTypeRequired);
    if (useType.isEmpty) errors.add(l10n.listingErrorUseTypeRequired);
    if (addressId == null) errors.add(l10n.listingErrorAddressRequired);
    if (priceFixed == null || priceFixed! < 1000) {
      errors.add(l10n.listingErrorMinPrice);
    }

    // Holding-specific validation
    if (holdingType == 'Free Hold') {
      if (taxPaidUntilYear != null &&
          (taxPaidUntilYear! < 2000 ||
              taxPaidUntilYear! > DateTime.now().year + 10)) {
        errors.add(l10n.listingErrorTaxYearRange(
            '2000', (DateTime.now().year + 10).toString()));
      }
    } else if (holdingType == 'Lease Hold') {
      if (leasedYear == null) errors.add(l10n.listingErrorLeasedYearRequired);
    } else if (holdingType == 'Cooperative') {
      if (cooperativeName == null || cooperativeName!.trim().isEmpty) {
        errors.add(l10n.listingErrorCooperativeNameRequired);
      }
      if (cooperativeCode == null || cooperativeCode!.trim().isEmpty) {
        errors.add(l10n.listingErrorCooperativeCodeRequired);
      }
    }

    return errors;
  }

  /// Validate step 2 (Details)
  List<String> validateStep2(AppLocalizations l10n) {
    final errors = <String>[];
    if (type == 'house') {
      if (totalRooms == null || totalRooms! < 1) {
        errors.add(l10n.listingErrorRoomsRequired);
      }
      if (houseType == null || houseType!.isEmpty) {
        errors.add(l10n.listingErrorHouseTypeRequired);
      }
      if (yearBuilt != null &&
          (yearBuilt! < 1900 || yearBuilt! > DateTime.now().year)) {
        errors.add(
            l10n.listingErrorYearBuiltRange('1900', DateTime.now().year.toString()));
      }
    }
    if (totalSquareMeters == null || totalSquareMeters! <= 0) {
      errors.add(l10n.listingErrorAreaRequired);
    }
    if (description == null || description!.trim().isEmpty) {
      errors.add(l10n.listingErrorDescriptionRequired);
    }
    return errors;
  }

  /// Validate step 3 (Media)
  List<String> validateStep3(AppLocalizations l10n) {
    final errors = <String>[];

    // Check new images OR existing images that weren't removed
    final hasImages = images.isNotEmpty ||
        (existingImages.isNotEmpty &&
            existingImages.length > removedImageIds.length);
    if (!hasImages) errors.add(l10n.listingErrorImageRequired);

    // Check new site plan OR existing site plan that wasn't removed
    final hasSitePlan =
        sitePlan != null || (existingSitePlanUrl != null && !removeExistingSitePlan);
    if (!hasSitePlan) errors.add(l10n.listingErrorSitePlanRequired);

    // Ownership proof - check new upload OR existing URL
    if (holdingType == 'Cooperative') {
      final hasOwnership =
          ownershipProof != null || existingOwnershipProofUrl != null;
      if (!hasOwnership) {
        errors.add(l10n.listingErrorOwnershipProofRequired);
      }
    }

    return errors;
  }

  /// Validate step 4 (Review)
  List<String> validateStep4(AppLocalizations l10n) {
    final errors = <String>[];
    if (!termsAccepted) errors.add(l10n.listingErrorTermsRequired);
    return errors;
  }
}
