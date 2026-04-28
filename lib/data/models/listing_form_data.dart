import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
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
  String? acquisitionClarification; // 'Purchased' | 'Inherited' | 'Gift' | 'Assignment' | 'Other'

  // --- Lease Hold ---
  int? leasedYear;
  double? leasePricePerSqm;
  String? buildType;
  double? annualPayment;

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
  int? yearBuilt;
  String? houseType;
  bool electricity = false;
  bool water = false;
  bool parkingAvailable = false;

  // --- Area ---
  double? totalSquareMeters;
  double? frontAreaSqm;
  double? sideAreaSqm;

  // --- Common ---
  String? facingDirection;
  String? description;

  // --- Address ---
  String? addressRegion;
  String? addressZone;
  String? addressWoreda;
  String? addressKebele;
  int? addressId;

  // --- Debt ---
  bool hasDebtOrEncumbrance = false;
  double? debtAmount;

  // --- Terms ---
  bool termsAccepted = false;

  // --- Media (not persisted to Hive, kept in memory only) ---
  List<XFile> images = [];
  List<XFile> sitePlans = [];
  XFile? ownershipProof;
  XFile? leaseContract;
  XFile? debtDocument;
  XFile? videoFile;

  // --- Existing Media (for Edit mode) ---
  List<ImageModel> existingImages = [];
  List<int> removedImageIds = [];
  String? existingSitePlanUrl;
  String? existingOwnershipProofUrl;
  String? existingLeaseContractUrl;
  String? existingDebtDocumentUrl;

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
    this.cooperativeName,
    this.cooperativeCode,
    this.buildingStatus,
    this.totalRooms,
    this.bedrooms,
    this.bathrooms,
    this.kitchens,
    this.salons,
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
    this.addressRegion,
    this.addressZone,
    this.addressWoreda,
    this.addressKebele,
    this.addressId,
    this.hasDebtOrEncumbrance = false,
    this.debtAmount,
    this.termsAccepted = false,
    this.existingImages = const [],
    this.removedImageIds = const [],
    this.existingSitePlanUrl,
    this.existingOwnershipProofUrl,
    this.existingLeaseContractUrl,
    this.existingDebtDocumentUrl,
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
        'cooperativeName': cooperativeName,
        'cooperativeCode': cooperativeCode,
        'buildingStatus': buildingStatus,
        'totalRooms': totalRooms,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'kitchens': kitchens,
        'salons': salons,
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
        'addressRegion': addressRegion,
        'addressZone': addressZone,
        'addressWoreda': addressWoreda,
        'addressKebele': addressKebele,
        'addressId': addressId,
        'hasDebtOrEncumbrance': hasDebtOrEncumbrance,
        'debtAmount': debtAmount,
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
        cooperativeName: data['cooperativeName'],
        cooperativeCode: data['cooperativeCode'],
        buildingStatus: data['buildingStatus'],
        totalRooms: data['totalRooms'],
        bedrooms: data['bedrooms'],
        bathrooms: data['bathrooms'],
        kitchens: data['kitchens'],
        salons: data['salons'],
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
        addressRegion: data['addressRegion'],
        addressZone: data['addressZone'],
        addressWoreda: data['addressWoreda'],
        addressKebele: data['addressKebele'],
        addressId: data['addressId'],
        hasDebtOrEncumbrance: data['hasDebtOrEncumbrance'] ?? false,
        debtAmount: data['debtAmount'],
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
    String? cooperativeName,
    String? cooperativeCode,
    String? buildingStatus,
    int? totalRooms,
    int? bedrooms,
    int? bathrooms,
    int? kitchens,
    int? salons,
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
    String? addressRegion,
    String? addressZone,
    String? addressWoreda,
    String? addressKebele,
    int? addressId,
    bool? hasDebtOrEncumbrance,
    double? debtAmount,
    bool? termsAccepted,
    List<XFile>? images,
    List<XFile>? sitePlans,
    XFile? ownershipProof,
    XFile? leaseContract,
    XFile? debtDocument,
    XFile? videoFile,
    List<ImageModel>? existingImages,
    List<int>? removedImageIds,
    String? existingSitePlanUrl,
    String? existingOwnershipProofUrl,
    String? existingLeaseContractUrl,
    String? existingDebtDocumentUrl,
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
      acquisitionClarification: acquisitionClarification ?? this.acquisitionClarification,
      leasedYear: leasedYear ?? this.leasedYear,
      leasePricePerSqm: leasePricePerSqm ?? this.leasePricePerSqm,
      buildType: buildType ?? this.buildType,
      annualPayment: annualPayment ?? this.annualPayment,
      cooperativeName: cooperativeName ?? this.cooperativeName,
      cooperativeCode: cooperativeCode ?? this.cooperativeCode,
      buildingStatus: buildingStatus ?? this.buildingStatus,
      totalRooms: totalRooms ?? this.totalRooms,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      kitchens: kitchens ?? this.kitchens,
      salons: salons ?? this.salons,
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
      addressRegion: addressRegion ?? this.addressRegion,
      addressZone: addressZone ?? this.addressZone,
      addressWoreda: addressWoreda ?? this.addressWoreda,
      addressKebele: addressKebele ?? this.addressKebele,
      addressId: addressId ?? this.addressId,
      hasDebtOrEncumbrance: hasDebtOrEncumbrance ?? this.hasDebtOrEncumbrance,
      debtAmount: debtAmount ?? this.debtAmount,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      existingImages: existingImages ?? this.existingImages,
      removedImageIds: removedImageIds ?? this.removedImageIds,
      existingSitePlanUrl: existingSitePlanUrl ?? this.existingSitePlanUrl,
      existingOwnershipProofUrl: existingOwnershipProofUrl ?? this.existingOwnershipProofUrl,
      existingLeaseContractUrl: existingLeaseContractUrl ?? this.existingLeaseContractUrl,
      existingDebtDocumentUrl: existingDebtDocumentUrl ?? this.existingDebtDocumentUrl,
    )
      ..images = images ?? this.images
      ..sitePlans = sitePlans ?? this.sitePlans
      ..ownershipProof = ownershipProof ?? this.ownershipProof
      ..leaseContract = leaseContract ?? this.leaseContract
      ..debtDocument = debtDocument ?? this.debtDocument
      ..videoFile = videoFile ?? this.videoFile;
  }

  /// Validate step 1 (Basics)
  List<String> validateStep1() {
    final errors = <String>[];
    if (type.isEmpty) errors.add('Property type is required');
    if (holdingType.isEmpty) errors.add('Holding type is required');
    if (listingType.isEmpty) errors.add('Listing type is required');
    if (useType.isEmpty) errors.add('Use type is required');
    if (addressId == null) errors.add('Please select a complete address');
    if (priceFixed == null || priceFixed! < 1000) errors.add('Price must be at least 1,000 ETB');
    
    // Holding-specific validation
    if (holdingType == 'Free Hold') {
      if (taxPaidUntilYear != null && (taxPaidUntilYear! < 2000 || taxPaidUntilYear! > DateTime.now().year + 10)) {
        errors.add('Tax paid year must be between 2000 and ${DateTime.now().year + 10}');
      }
    } else if (holdingType == 'Lease Hold') {
      if (leasedYear == null) errors.add('Leased year is required');
    } else if (holdingType == 'Cooperative') {
      if (cooperativeName == null || cooperativeName!.trim().isEmpty) errors.add('Cooperative name is required');
      if (cooperativeCode == null || cooperativeCode!.trim().isEmpty) errors.add('Cooperative code is required');
    }
    
    return errors;
  }

  /// Validate step 2 (Details)
  List<String> validateStep2() {
    final errors = <String>[];
    if (type == 'house') {
      if (totalRooms == null || totalRooms! < 1) errors.add('Total rooms is required');
      if (houseType == null || houseType!.isEmpty) errors.add('House type is required');
      if (yearBuilt != null && (yearBuilt! < 1900 || yearBuilt! > DateTime.now().year)) {
        errors.add('Year built must be between 1900 and ${DateTime.now().year}');
      }
    }
    if (totalSquareMeters == null || totalSquareMeters! <= 0) errors.add('Total area is required');
    if (description == null || description!.trim().isEmpty) errors.add('Description is required');
    return errors;
  }

  /// Validate step 3 (Media)
  List<String> validateStep3() {
    final errors = <String>[];
    if (images.isEmpty) errors.add('At least one property image is required');
    if (sitePlans.isEmpty) errors.add('At least one site plan is required');
    
    if (holdingType == 'Cooperative' && ownershipProof == null) {
      errors.add('Ownership proof is required for cooperative properties');
    }
    if (holdingType == 'Lease Hold' && leaseContract == null) {
      errors.add('Lease contract is required for lease hold properties');
    }
    return errors;
  }

  /// Validate step 4 (Review)
  List<String> validateStep4() {
    final errors = <String>[];
    if (!termsAccepted) errors.add('You must accept the Terms & Conditions');
    return errors;
  }
}
