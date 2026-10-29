import '../../../core/utils/type_utils.dart';

/// Moderation state of the latest KYC submission.
enum KycStatus {
  none('none'),
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  unknown('unknown');

  final String wireValue;

  const KycStatus(this.wireValue);

  static KycStatus parse(dynamic value) {
    switch (value?.toString()) {
      case 'none':
        return KycStatus.none;
      case 'pending':
        return KycStatus.pending;
      case 'approved':
        return KycStatus.approved;
      case 'rejected':
        return KycStatus.rejected;
      default:
        return KycStatus.unknown;
    }
  }

  bool get isPending => this == KycStatus.pending;

  bool get isApproved => this == KycStatus.approved;

  bool get isRejected => this == KycStatus.rejected;
}

/// One submission as seen by its owner.
///
/// The API deliberately omits the uploaded document paths; only the moderation
/// metadata is exposed.
class KycVerification {
  final int id;
  final String documentType;
  final KycStatus status;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? verifiedAt;

  const KycVerification({
    required this.id,
    this.documentType = 'national_id',
    this.status = KycStatus.pending,
    this.rejectionReason,
    this.submittedAt,
    this.verifiedAt,
  });

  factory KycVerification.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return KycVerification(
      id: TypeUtils.safeInt(map['id']) ?? 0,
      documentType: map['document_type']?.toString() ?? 'national_id',
      status: KycStatus.parse(map['status']),
      rejectionReason: _text(map['rejection_reason']),
      submittedAt: _date(map['submitted_at']),
      verifiedAt: _date(map['verified_at']),
    );
  }
}

/// `GET /kyc` payload.
class KycOverview {
  final bool verified;
  final KycStatus status;
  final bool canSubmit;
  final KycVerification? verification;

  const KycOverview({
    this.verified = false,
    this.status = KycStatus.none,
    this.canSubmit = true,
    this.verification,
  });

  bool get hasSubmission => verification != null;

  /// Whether the latest rejection should be shown to the user.
  bool get showRejection =>
      status.isRejected &&
      verification?.rejectionReason != null &&
      verification!.rejectionReason!.isNotEmpty;

  factory KycOverview.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return KycOverview(
      verified: TypeUtils.safeBool(map['verified']),
      status: KycStatus.parse(map['status']),
      canSubmit: TypeUtils.safeBool(map['can_submit'], defaultValue: true),
      verification: map['verification'] is Map
          ? KycVerification.fromJson(map['verification'])
          : null,
    );
  }
}

/// `POST /kyc/phone/send-otp` payload.
class KycPhoneDispatch {
  final String channel;
  final String destination;

  const KycPhoneDispatch({
    required this.channel,
    required this.destination,
  });

  bool get sentBySms => channel == 'sms';

  bool get sentByEmail => channel == 'email';

  factory KycPhoneDispatch.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return KycPhoneDispatch(
      channel: map['channel']?.toString() ?? 'sms',
      destination: map['destination']?.toString() ?? '',
    );
  }
}

/// `POST /kyc/phone/verify` payload.
class KycPhoneVerified {
  final String phoneNumber;
  final bool phoneVerified;

  const KycPhoneVerified({
    required this.phoneNumber,
    this.phoneVerified = true,
  });

  factory KycPhoneVerified.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return KycPhoneVerified(
      phoneNumber: map['phone_number']?.toString() ?? '',
      phoneVerified: TypeUtils.safeBool(map['phone_verified']),
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
