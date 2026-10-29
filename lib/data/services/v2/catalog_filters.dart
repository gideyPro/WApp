/// Sort options accepted by `/v2/listings` and `/v2/cars`.
enum CatalogSort {
  newest('newest'),
  oldest('oldest'),
  priceLow('price_low'),
  priceHigh('price_high');

  final String wireValue;

  const CatalogSort(this.wireValue);
}

/// Sort options accepted by `/v2/jobs`.
enum JobSort {
  newest('newest'),
  oldest('oldest');

  final String wireValue;

  const JobSort(this.wireValue);
}

/// Filters for `GET /v2/listings`.
class ListingFilters {
  final String? type;
  final String? listingType;
  final String? rentalPeriodUnit;
  final String? location;
  final double? priceMin;
  final double? priceMax;
  final double? areaMin;
  final double? areaMax;
  final int? minBedrooms;
  final int? minBathrooms;
  final bool? isFeatured;
  final CatalogSort sort;

  const ListingFilters({
    this.type,
    this.listingType,
    this.rentalPeriodUnit,
    this.location,
    this.priceMin,
    this.priceMax,
    this.areaMin,
    this.areaMax,
    this.minBedrooms,
    this.minBathrooms,
    this.isFeatured,
    this.sort = CatalogSort.newest,
  });

  Map<String, dynamic> toQuery() {
    return {
      if (type != null) 'type': type,
      if (listingType != null) 'listing_type': listingType,
      if (rentalPeriodUnit != null) 'rental_period_unit': rentalPeriodUnit,
      if (location != null && location!.trim().isNotEmpty)
        'location': location!.trim(),
      if (priceMin != null) 'price_min': priceMin,
      if (priceMax != null) 'price_max': priceMax,
      if (areaMin != null) 'area_min': areaMin,
      if (areaMax != null) 'area_max': areaMax,
      if (minBedrooms != null) 'bedrooms': minBedrooms,
      if (minBathrooms != null) 'bathrooms': minBathrooms,
      if (isFeatured != null) 'is_featured': isFeatured,
      'sort': sort.wireValue,
    };
  }
}

/// Filters for `GET /v2/cars`.
class CarFilters {
  final String? listingType;
  final String? location;
  final double? priceMin;
  final double? priceMax;
  final String? make;
  final String? model;
  final int? yearMin;
  final int? yearMax;
  final double? mileageMax;
  final String? condition;
  final String? bodyType;
  final String? vehicleCategory;
  final String? transmission;
  final String? fuelType;
  final CatalogSort sort;

  const CarFilters({
    this.listingType,
    this.location,
    this.priceMin,
    this.priceMax,
    this.make,
    this.model,
    this.yearMin,
    this.yearMax,
    this.mileageMax,
    this.condition,
    this.bodyType,
    this.vehicleCategory,
    this.transmission,
    this.fuelType,
    this.sort = CatalogSort.newest,
  });

  Map<String, dynamic> toQuery() {
    return {
      if (listingType != null) 'listing_type': listingType,
      if (location != null && location!.trim().isNotEmpty)
        'location': location!.trim(),
      if (priceMin != null) 'price_min': priceMin,
      if (priceMax != null) 'price_max': priceMax,
      if (make != null && make!.trim().isNotEmpty) 'make': make!.trim(),
      if (model != null && model!.trim().isNotEmpty) 'model': model!.trim(),
      if (yearMin != null) 'year_min': yearMin,
      if (yearMax != null) 'year_max': yearMax,
      if (mileageMax != null) 'mileage_max': mileageMax,
      if (condition != null) 'condition': condition,
      if (bodyType != null) 'body_type': bodyType,
      if (vehicleCategory != null) 'vehicle_category': vehicleCategory,
      if (transmission != null) 'transmission': transmission,
      if (fuelType != null) 'fuel_type': fuelType,
      'sort': sort.wireValue,
    };
  }
}

/// Filters for `GET /v2/jobs`.
class JobFilters {
  final String? search;
  final String? location;
  final String? jobCategory;
  final String? jobType;
  final String? educationLevel;
  final double? salaryMin;
  final double? salaryMax;
  final JobSort sort;

  const JobFilters({
    this.search,
    this.location,
    this.jobCategory,
    this.jobType,
    this.educationLevel,
    this.salaryMin,
    this.salaryMax,
    this.sort = JobSort.newest,
  });

  Map<String, dynamic> toQuery() {
    return {
      if (search != null && search!.trim().isNotEmpty) 'search': search!.trim(),
      if (location != null && location!.trim().isNotEmpty)
        'location': location!.trim(),
      if (jobCategory != null) 'job_category': jobCategory,
      if (jobType != null) 'job_type': jobType,
      if (educationLevel != null) 'education_level': educationLevel,
      if (salaryMin != null) 'salary_min': salaryMin,
      if (salaryMax != null) 'salary_max': salaryMax,
      'sort': sort.wireValue,
    };
  }
}
