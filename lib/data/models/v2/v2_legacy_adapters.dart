import '../../models/address.dart';
import '../../models/car_form_data.dart';
import '../../models/image.dart';
import '../../models/job_form_data.dart';
import '../../models/listing.dart';
import '../../models/listing_form_data.dart';
import '../../models/message.dart' as msg;
import '../../models/notification.dart' as app;
import '../../models/payment.dart';
import '../../models/subscription.dart';
import '../../services/order_service.dart';
import 'app_notification.dart';
import 'buyer_order.dart';
import 'conversation.dart';
import 'listing_detail.dart';
import 'listing_summary.dart';
import 'owner_listing.dart';
import 'payment_state.dart';
import 'plan.dart';
import 'subscription_state.dart';

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
    } else if (!video.blocked) {
      // Video may be processing — set pending so the screen starts polling
      // the /listings/{id}/video endpoint for status updates.
      vp = const VideoProcessing(
        status: VideoProcessingStatus.pending,
        processedUrl: null,
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

extension BuyerOrderLegacyAdapter on BuyerOrder {
  Order toLegacyOrder() {
    final addr = address != null
        ? Address(
            id: address!.id,
            region: address!.region,
            zone: address!.zone,
            woreda: address!.woreda,
            kebele: address!.kebele,
            specificLocation: address!.fullAddress,
          )
        : null;

    return Order(
      id: id,
      type: switch (type) {
        ListingKind.car => 'car',
        ListingKind.job => 'job',
        ListingKind.house => 'house',
        ListingKind.land => 'land',
        _ => 'house',
      },
      listingType: listingType,
      holdingType: holdingType,
      facingDirection: facingDirection,
      minBudget: budget.min,
      maxBudget: budget.max,
      minArea: area.min,
      maxArea: area.max,
      description: description,
      status: status.wireValue,
      createdAt: createdAt?.toIso8601String() ?? '',
      updatedAt: null,
      address: addr,
    );
  }
}

extension ChatConversationLegacyAdapter on ChatConversation {
  msg.Conversation toLegacyConversation({int? currentUserId}) {
    final part = otherParticipant;
    return msg.Conversation(
      id: id,
      senderId: currentUserId ?? 0,
      receiverId: part?.id ?? 0,
      listingId: listing?.id,
      type: 'direct',
      subject: title,
      lastMessage: lastMessage?.body,
      lastMessageAt: lastMessage?.createdAt,
      unreadCount: unreadCount,
      createdAt: createdAt ?? DateTime.now(),
      otherParticipantId: part?.id,
      otherParticipantFirstName: part?.firstName,
      otherParticipantLastName: part?.lastName,
      otherParticipantAvatar: part?.avatarUrl,
      listingTitle: listing?.title,
      listingImageUrl: listing?.coverImage?.url,
    );
  }
}

extension ChatMessageLegacyAdapter on ChatMessage {
  msg.Message toLegacyMessage() {
    return msg.Message(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      body: body,
      isRead: isRead,
      createdAt: createdAt ?? DateTime.now(),
      readAt: readAt,
      senderFirstName: sender?.firstName,
      senderLastName: sender?.lastName,
      senderAvatar: sender?.avatarUrl,
    );
  }
}

extension AppNotificationLegacyAdapter on AppNotification {
  app.Notification toLegacyNotification() {
    final nType = switch (type) {
      'listing_approved' => app.NotificationType.listingApproved,
      'listing_rejected' => app.NotificationType.listingRejected,
      'new_interest' => app.NotificationType.newInterest,
      'favorite' => app.NotificationType.favorite,
      'payment_success' => app.NotificationType.paymentSuccess,
      'payment_failed' => app.NotificationType.paymentFailed,
      'subscription_activated' => app.NotificationType.subscriptionActivated,
      'subscription_expired' => app.NotificationType.subscriptionExpired,
      'kyc_update' => app.NotificationType.kycUpdate,
      'conference_invite' => app.NotificationType.conferenceInvite,
      'conference_update' => app.NotificationType.conferenceUpdate,
      'incoming_call' => app.NotificationType.incomingCall,
      'suggestion' => app.NotificationType.suggestion,
      _ => app.NotificationType.systemAnnouncement,
    };

    return app.Notification(
      id: id,
      userId: 0,
      title: title,
      body: message,
      type: nType,
      actionUrl: actionUrl,
      data: data,
      isRead: isRead,
      readAt: readAt,
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}

extension PaymentStateLegacyAdapter on PaymentState {
  Payment toLegacyPayment() {
    final pStatus = switch (status) {
      PaymentStatusV2.pending => PaymentStatus.pending,
      PaymentStatusV2.success => PaymentStatus.success,
      PaymentStatusV2.failed => PaymentStatus.failed,
      PaymentStatusV2.cancelled => PaymentStatus.cancelled,
      PaymentStatusV2.unknown => PaymentStatus.pending,
    };

    return Payment(
      id: id,
      userId: 0,
      transactionReference: txRef,
      paymentType: PaymentType.subscription,
      amount: amount,
      currency: currency,
      status: pStatus,
      paymentMethod: paymentMethod,
      paidAt: paidAt,
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}

extension PlanLegacyAdapter on Plan {
  SubscriptionPlan toSubscriptionPlan() {
    return SubscriptionPlan(
      id: id,
      name: name,
      slug: slug,
      description: description ?? '',
      price: cycles.isNotEmpty ? cycles.first.price : 0,
      priceUsd: cycles.isNotEmpty ? cycles.first.priceUsd : 0,
      billingCycles: cycles
          .map((c) => PlanBillingCycle(
                months: c.months,
                price: c.price,
                priceUsd: c.priceUsd,
                listingDurationDays: c.listingDays ?? 30,
                discountPercent: c.discountPercent,
                badge: c.badge,
                originalPrice: c.originalPrice,
                originalPriceUsd: c.originalPriceUsd,
              ))
          .toList(),
      features: features,
      maxListings: limits.listings,
      maxRentalListings: limits.rentalListings,
      maxVehicles: limits.vehicles,
      maxRentalVehicles: limits.rentalVehicles,
      maxJobs: limits.jobs,
      viewVip: true,
      trialDays: trialDays,
      canStartTrial: canStartTrial,
      isActive: true,
    );
  }
}

extension SubscriptionStateLegacyAdapter on SubscriptionState {
  Subscription toLegacySubscription() {
    return Subscription(
      id: id,
      userId: 0,
      planId: planId ?? 0,
      plan: plan != null
          ? SubscriptionPlan(
              id: plan!.id,
              name: plan!.name,
              slug: plan!.slug,
              price: 0,
              listingDurationDays: listingDurationDays,
            )
          : null,
      status: status,
      startsAt: startsAt ?? DateTime.now(),
      endsAt: endsAt ?? DateTime.now().add(const Duration(days: 30)),
      trialEndsAt: trialEndsAt,
      billingCycleMonths: billingCycleMonths,
      listingDurationDays: listingDurationDays,
      listingsUsed: listingsUsed,
      rentalListingsUsed: rentalListingsUsed,
      vehiclesUsed: vehiclesUsed,
      rentalVehiclesUsed: rentalVehiclesUsed,
      jobsUsed: jobsUsed,
    );
  }
}

extension ListingFormDataV2Adapter on ListingFormData {
  Map<String, dynamic> toV2Payload(String submissionKey) {
    return {
      'type': type,
      'submission_key': submissionKey,
      'listing_type': listingType,
      if (priceFixed != null) 'price': priceFixed,
      if (isRental && rentalPeriodUnit != null)
        'rental_period': rentalPeriodUnit,
      if (addressId != null) 'address_id': addressId,
      if (specificLocation != null && specificLocation!.isNotEmpty)
        'specific_location': specificLocation,
      if (description != null && description!.isNotEmpty)
        'description': description,
      'attributes': {
        if (useType.isNotEmpty) 'use_type': useType,
        if (facingDirection != null) 'facing_direction': facingDirection,
        if (totalSquareMeters != null) 'total_square_meters': totalSquareMeters,
        if (frontAreaSqm != null) 'front_area_sqm': frontAreaSqm,
        if (sideAreaSqm != null) 'side_area_sqm': sideAreaSqm,
        if (hasDebtOrEncumbrance) 'has_debt_or_encumbrance': true,
        if (debtAmount != null) 'debt_amount': debtAmount,
        'holding_type': holdingType,
      },
      'details': {
        if (bedrooms != null) 'bedrooms': bedrooms,
        if (bathrooms != null) 'bathrooms': bathrooms,
        if (kitchens != null) 'kitchens': kitchens,
        if (yearBuilt != null) 'year_built': yearBuilt,
        if (houseType != null) 'house_type': houseType,
        'parking_available': parkingAvailable,
        'electricity': electricity,
        'water': water,
      },
      'holding_details': {
        if (holdingType == 'Free Hold')
          'private': {
            if (taxPaidUntilYear != null)
              'tax_paid_until_year': taxPaidUntilYear,
            if (acquisitionClarification != null)
              'acquisition_clarification': acquisitionClarification,
          },
        if (holdingType == 'Lease Hold')
          'lease': {
            if (leasedYear != null) 'leased_year': leasedYear,
            if (leasePricePerSqm != null)
              'lease_price_per_sqm': leasePricePerSqm,
            if (buildType != null) 'build_type': buildType,
            if (annualPayment != null) 'annual_payment': annualPayment,
          },
        if (holdingType == 'Cooperative')
          'cooperative': {
            if (cooperativeName != null) 'cooperative_name': cooperativeName,
            if (cooperativeCode != null) 'cooperative_code': cooperativeCode,
            if (buildingStatus != null) 'building_status': buildingStatus,
          },
      },
    };
  }
}

extension CarFormDataV2Adapter on CarFormData {
  Map<String, dynamic> toV2Payload(String submissionKey) {
    return {
      'submission_key': submissionKey,
      'listing_type': isForRent ? 'rental' : 'sale',
      if (priceFixed != null) 'price': priceFixed,
      if (isForRent && rentalPeriodUnit.isNotEmpty)
        'rental_period': rentalPeriodUnit,
      if (addressId != null) 'address_id': addressId,
      if (specificLocation.isNotEmpty) 'specific_location': specificLocation,
      if (vehicleCategory.isNotEmpty) 'vehicle_category': vehicleCategory,
      if (make.isNotEmpty) 'make': make,
      if (model.isNotEmpty) 'model': model,
      if (year.isNotEmpty) 'year': int.tryParse(year),
      if (mileageKm.isNotEmpty) 'mileage_km': double.tryParse(mileageKm),
      if (bodyType.isNotEmpty) 'body_type': bodyType,
      if (color.isNotEmpty) 'color': color,
      if (condition.isNotEmpty) 'condition': condition,
      if (vin.isNotEmpty) 'vin': vin,
      if (features.isNotEmpty) 'features': features,
      if (description.isNotEmpty) 'description': description,
    };
  }
}

extension JobFormDataV2Adapter on JobFormData {
  Map<String, dynamic> toV2Payload(String submissionKey) {
    return {
      'submission_key': submissionKey,
      'title': title ?? '',
      if (companyName != null && companyName!.isNotEmpty)
        'company_name': companyName,
      'job_type': jobType,
      'job_category': jobCategory,
      'positions_count': positionsCount,
      'salary_type': salaryType,
      if (salaryMin != null) 'salary_min': salaryMin,
      if (salaryMax != null) 'salary_max': salaryMax,
      'salary_currency': salaryCurrency,
      if (reqEducation != null) 'education': reqEducation,
      if (reqExperience != null) 'experience': reqExperience,
      'gender': reqGender,
      if (deadline != null)
        'deadline': deadline!.toIso8601String().split('T').first,
      if (addressId != null) 'address_id': addressId,
      if (specificLocation != null && specificLocation!.isNotEmpty)
        'specific_location': specificLocation,
      if (description != null && description!.isNotEmpty)
        'description': description,
    };
  }
}
