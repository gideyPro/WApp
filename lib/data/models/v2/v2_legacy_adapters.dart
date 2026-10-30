import '../../models/address.dart';
import '../../models/image.dart';
import '../../models/listing.dart';
import 'listing_detail.dart';
import 'listing_summary.dart';
import 'owner_listing.dart';

RentalPeriod? _parseRentalPeriod(String? period) {
  if (period == null) return null;
  return switch (period.toLowerCase()) {
    'day' => RentalPeriod.day,
    'month' => RentalPeriod.month,
    'year' => RentalPeriod.year,
    _ => null,
  };
}

/// Bidirectional adapters bridging V2 models with existing UI domain models.
///
/// This lets existing screen controllers, cards, widgets and lists consume V2
/// API responses without touching or modifying any screen or component UI code.
extension ListingSummaryLegacyAdapter on ListingSummary {
  Listing toListing() {
    final propType = switch (kind) {
      ListingKind.car => PropertyType.car,
      ListingKind.job => PropertyType.job,
      ListingKind.house => PropertyType.house,
      ListingKind.land => PropertyType.land,
      ListingKind.unknown => PropertyType.house,
    };

    final listType =
        listingType == 'rental' ? ListingType.rental : ListingType.sale;

    final primaryImg = coverImage?.url;
    final imageModels = primaryImg != null && primaryImg.isNotEmpty
        ? [ImageModel(id: coverImage?.id ?? 0, imagePath: primaryImg)]
        : <ImageModel>[];

    final addr = Address(
      id: 0,
      region: location.displayRegion,
      zone: location.displayZone,
      woreda: location.woreda,
      kebele: location.kebele,
      specificLocation: location.specificLocation,
    );

    return Listing(
      id: id,
      propertyType: propType,
      listingType: listType,
      priceFixed: price.amount,
      rentalPeriodUnit: _parseRentalPeriod(price.period),
      isFeatured: isFeatured,
      isVip: isVip,
      specificLocation: location.specificLocation,
      address: addr,
      images: imageModels,
      createdAt: createdAt ?? DateTime.now(),
      // Job specific fields
      jobTitle: kind == ListingKind.job ? title : null,
      // Car specific fields
      carMake: kind == ListingKind.car ? title : null,
    );
  }
}

extension ListingDetailLegacyAdapter on ListingDetail {
  Listing toListing() {
    final propType = switch (kind) {
      ListingKind.car => PropertyType.car,
      ListingKind.job => PropertyType.job,
      ListingKind.house => PropertyType.house,
      ListingKind.land => PropertyType.land,
      ListingKind.unknown => PropertyType.house,
    };

    final listType =
        listingType == 'rental' ? ListingType.rental : ListingType.sale;

    final imageModels = images
        .where((img) => img.url != null && img.url!.isNotEmpty)
        .map((img) => ImageModel(
              id: img.id ?? 0,
              imagePath: img.url!,
            ))
        .toList();

    final addr = Address(
      id: 0,
      region: location.displayRegion,
      zone: location.displayZone,
      woreda: location.woreda,
      kebele: location.kebele,
      specificLocation: location.specificLocation,
    );

    VideoProcessing? vp;
    if (video.hasUrl) {
      vp = VideoProcessing(
        status: VideoProcessingStatus.ready,
        processedUrl: video.url,
      );
    }

    return Listing(
      id: id,
      propertyType: propType,
      listingType: listType,
      priceFixed: price.amount,
      priceRevisionPossible: attributes.priceRevisionPossible,
      rentalPeriodUnit: _parseRentalPeriod(price.period),
      status: ListingStatus.active,
      isFeatured: isFeatured,
      isVip: isVip,
      description: description,
      specificLocation: attributes.specificLocation ?? location.specificLocation,
      useType: attributes.useType,
      facingDirection: attributes.facingDirection,
      totalSquareMeters: attributes.totalSquareMeters ?? details.areaSqm,
      frontAreaSqm: attributes.frontAreaSqm,
      sideAreaSqm: attributes.sideAreaSqm,
      hasDebtOrEncumbrance: attributes.hasDebtOrEncumbrance,
      debtAmount: attributes.debtAmount,
      videoLink: video.url,
      videoProcessing: vp,
      holdingType: attributes.holdingType,
      // Private / freehold
      taxPaidUntilYear: holdingDetails.private?.taxPaidUntilYear,
      acquisitionType: holdingDetails.private?.acquisitionClarification,
      // Lease
      leasedYear: holdingDetails.lease?.leasedYear,
      leasePricePerSqm: holdingDetails.lease?.leasePricePerSqm,
      buildType: holdingDetails.lease?.buildType,
      annualPayment: holdingDetails.lease?.annualPayment,
      // Cooperative
      cooperativeName: holdingDetails.cooperative?.cooperativeName,
      cooperativeCode: holdingDetails.cooperative?.cooperativeCode,
      buildingStatus: holdingDetails.cooperative?.buildingStatus,
      // House details
      bedrooms: details.bedrooms,
      bathrooms: details.bathrooms,
      kitchens: details.kitchens,
      yearBuilt: details.yearBuilt,
      houseType: details.houseType,
      electricity: details.electricity,
      water: details.water,
      parkingAvailable: details.parkingAvailable,
      images: imageModels,
      address: addr,
      createdAt: createdAt ?? DateTime.now(),
      // Seller / contact
      sellerName: seller.name,
      sellerPhone: seller.phone,
      contactRevealed: viewer.contactRevealed,
      contactRemaining: viewer.contactsRemaining,
      contactMax: viewer.contactsMax,
      revealedContact: viewer.contactRevealed ? seller.phone : null,
      revealedName: viewer.contactRevealed ? seller.name : null,
      // Car fields
      carVehicleCategory: details.vehicleCategory,
      carMake: details.make,
      carModel: details.model,
      carYear: details.year,
      carMileageKm: details.mileageKm,
      carBodyType: details.bodyType,
      carColor: details.color,
      carCondition: details.condition,
      // Job fields
      jobTitle: details.companyName != null ? title : null,
      jobCompanyName: details.companyName,
      jobType: details.jobType,
      jobCategory: details.jobCategory,
      jobPositionsCount: details.positionsCount,
      jobSalaryType: details.salaryType,
      jobSalaryMin: details.salaryMin,
      jobSalaryMax: details.salaryMax,
      jobSalaryCurrency: details.salaryCurrency,
      jobReqEducation: details.education,
      jobDeadline: details.deadline,
    );
  }
}

extension OwnerListingLegacyAdapter on OwnerListing {
  Listing toListing() {
    final propType = switch (kind) {
      ListingKind.car => PropertyType.car,
      ListingKind.job => PropertyType.job,
      ListingKind.house => PropertyType.house,
      ListingKind.land => PropertyType.land,
      ListingKind.unknown => PropertyType.house,
    };

    final listType =
        listingType == 'rental' ? ListingType.rental : ListingType.sale;

    final lStatus = switch (status) {
      OwnerListingStatus.active => ListingStatus.active,
      OwnerListingStatus.pending => ListingStatus.pending,
      OwnerListingStatus.draft => ListingStatus.pending,
      OwnerListingStatus.rejected => ListingStatus.rejected,
      OwnerListingStatus.frozen => ListingStatus.frozen,
      OwnerListingStatus.unknown => ListingStatus.pending,
    };

    final primaryImg = coverImage?.url;
    final imageModels = primaryImg != null && primaryImg.isNotEmpty
        ? [ImageModel(id: coverImage?.id ?? 0, imagePath: primaryImg)]
        : <ImageModel>[];

    return Listing(
      id: id,
      propertyType: propType,
      listingType: listType,
      priceFixed: price.amount,
      rentalPeriodUnit: _parseRentalPeriod(price.period),
      status: lStatus,
      isFeatured: isFeatured,
      isVip: isVip,
      specificLocation: location.specificLocation,
      images: imageModels,
      createdAt: createdAt ?? DateTime.now(),
      jobTitle: kind == ListingKind.job ? title : null,
      carMake: kind == ListingKind.car ? title : null,
    );
  }
}
