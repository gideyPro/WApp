import '../../../core/utils/type_utils.dart';
import 'listing_summary.dart';

/// Lifecycle of a scheduled or direct call.
enum CallStatus {
  scheduled('scheduled'),
  active('active'),
  ended('ended'),
  cancelled('cancelled'),
  unknown('unknown');

  final String wireValue;

  const CallStatus(this.wireValue);

  static CallStatus parse(dynamic value) {
    switch (value?.toString()) {
      case 'scheduled':
        return CallStatus.scheduled;
      case 'active':
        return CallStatus.active;
      case 'ended':
        return CallStatus.ended;
      case 'cancelled':
        return CallStatus.cancelled;
      default:
        return CallStatus.unknown;
    }
  }

  bool get isScheduled => this == CallStatus.scheduled;

  bool get isActive => this == CallStatus.active;

  bool get isFinished =>
      this == CallStatus.ended || this == CallStatus.cancelled;
}

/// Role of a participant inside a call.
///
/// `host` is derived from the creator, so a legacy staff participant that did
/// not create the call is exposed as `moderator`.
enum CallParticipantRole {
  host('host'),
  moderator('moderator'),
  seller('seller'),
  buyer('buyer'),
  unknown('unknown');

  final String wireValue;

  const CallParticipantRole(this.wireValue);

  static CallParticipantRole parse(dynamic value) {
    switch (value?.toString()) {
      case 'host':
        return CallParticipantRole.host;
      case 'moderator':
        return CallParticipantRole.moderator;
      case 'seller':
        return CallParticipantRole.seller;
      case 'buyer':
        return CallParticipantRole.buyer;
      default:
        return CallParticipantRole.unknown;
    }
  }

  bool get isHost => this == CallParticipantRole.host;
}

/// A participant on a call. Phone numbers and emails are never exposed.
class CallParticipant {
  final int id;
  final String? firstName;
  final String? lastName;
  final String name;
  final String initials;
  final String? avatarUrl;
  final CallParticipantRole role;
  final bool isHost;
  final bool joined;
  final DateTime? joinedAt;
  final DateTime? leftAt;
  final int durationSeconds;

  const CallParticipant({
    required this.id,
    this.firstName,
    this.lastName,
    this.name = '',
    this.initials = '',
    this.avatarUrl,
    this.role = CallParticipantRole.unknown,
    this.isHost = false,
    this.joined = false,
    this.joinedAt,
    this.leftAt,
    this.durationSeconds = 0,
  });

  String get displayName {
    if (name.trim().isNotEmpty) return name;
    final parts = [firstName, lastName]
        .map((part) => part?.trim())
        .whereType<String>()
        .where((part) => part.isNotEmpty);
    return parts.join(' ');
  }

  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  factory CallParticipant.fromJson(dynamic json) {
    final map = json is Map ? json : const {};

    return CallParticipant(
      id: TypeUtils.safeInt(map['id']) ?? 0,
      firstName: _text(map['first_name']),
      lastName: _text(map['last_name']),
      name: map['name']?.toString() ?? '',
      initials: map['initials']?.toString() ?? '',
      avatarUrl: _text(map['avatar_url']),
      role: CallParticipantRole.parse(map['role']),
      isHost: TypeUtils.safeBool(map['is_host']),
      joined: TypeUtils.safeBool(map['joined']),
      joinedAt: _date(map['joined_at']),
      leftAt: _date(map['left_at']),
      durationSeconds: TypeUtils.safeInt(map['duration_seconds']) ?? 0,
    );
  }
}

/// What the current viewer may do with a call.
class CallViewer {
  final CallParticipantRole role;
  final bool isHost;
  final bool joined;
  final bool canJoin;
  final bool canStart;
  final bool canEnd;
  final bool canCancel;

  const CallViewer({
    this.role = CallParticipantRole.unknown,
    this.isHost = false,
    this.joined = false,
    this.canJoin = false,
    this.canStart = false,
    this.canEnd = false,
    this.canCancel = false,
  });

  factory CallViewer.fromJson(dynamic json) {
    final map = json is Map ? json : const {};

    return CallViewer(
      role: CallParticipantRole.parse(map['role']),
      isHost: TypeUtils.safeBool(map['is_host']),
      joined: TypeUtils.safeBool(map['joined']),
      canJoin: TypeUtils.safeBool(map['can_join']),
      canStart: TypeUtils.safeBool(map['can_start']),
      canEnd: TypeUtils.safeBool(map['can_end']),
      canCancel: TypeUtils.safeBool(map['can_cancel']),
    );
  }
}

/// A scheduled or direct call from `/v2/conferences`.
///
/// Named [CallConference] so it can coexist with the legacy `Conference` model
/// while the call screens migrate.
class CallConference {
  final int id;
  final CallStatus status;
  final bool isVideo;
  final ListingSummary? listing;
  final CallParticipant? host;
  final int participantCount;
  final CallViewer? viewer;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? notes;
  final int? conversationId;
  final List<CallParticipant> participants;

  const CallConference({
    required this.id,
    required this.status,
    this.isVideo = false,
    this.listing,
    this.host,
    this.participantCount = 0,
    this.viewer,
    this.scheduledAt,
    this.startedAt,
    this.endedAt,
    this.durationSeconds = 0,
    this.createdAt,
    this.updatedAt,
    this.notes,
    this.conversationId,
    this.participants = const [],
  });

  bool get isScheduled => status.isScheduled;

  bool get isActive => status.isActive;

  bool get isFinished => status.isFinished;

  bool get hasListing => listing != null;

  bool get hasHost => host != null;

  bool get hasNotes => notes != null && notes!.isNotEmpty;

  bool get hasParticipants => participants.isNotEmpty;

  bool get isHost => viewer?.isHost ?? false;

  bool get canJoin => viewer?.canJoin ?? false;

  bool get canStart => viewer?.canStart ?? false;

  bool get canEnd => viewer?.canEnd ?? false;

  bool get canCancel => viewer?.canCancel ?? false;

  String get title {
    final listingTitle = listing?.title;
    if (listingTitle != null && listingTitle.isNotEmpty) return listingTitle;

    return hasHost ? host!.displayName : 'Call';
  }

  factory CallConference.fromJson(Map<String, dynamic> json) {
    final rawListing = json['listing'];
    final rawHost = json['host'];
    final rawViewer = json['viewer'];
    final rawParticipants = json['participants'];

    return CallConference(
      id: TypeUtils.safeInt(json['id']) ?? 0,
      status: CallStatus.parse(json['status']),
      isVideo: TypeUtils.safeBool(json['is_video']),
      listing: rawListing is Map
          ? ListingSummary.fromJson(Map<String, dynamic>.from(rawListing))
          : null,
      host: rawHost is Map
          ? CallParticipant.fromJson(Map<String, dynamic>.from(rawHost))
          : null,
      participantCount: TypeUtils.safeInt(json['participant_count']) ?? 0,
      viewer: rawViewer is Map
          ? CallViewer.fromJson(Map<String, dynamic>.from(rawViewer))
          : null,
      scheduledAt: _date(json['scheduled_at']),
      startedAt: _date(json['started_at']),
      endedAt: _date(json['ended_at']),
      durationSeconds: TypeUtils.safeInt(json['duration_seconds']) ?? 0,
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
      notes: _text(json['notes']),
      conversationId: TypeUtils.safeInt(json['conversation_id']),
      participants: rawParticipants is List
          ? rawParticipants
              .whereType<Map>()
              .map((item) => CallParticipant.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList(growable: false)
          : const [],
    );
  }
}

/// Jitsi room credentials returned by join.
class CallCredentials {
  final String room;
  final String domain;
  final String? appId;
  final String method;
  final String? token;
  final String url;
  final bool isVideo;

  const CallCredentials({
    this.room = '',
    this.domain = '',
    this.appId,
    this.method = 'jaas',
    this.token,
    this.url = '',
    this.isVideo = false,
  });

  bool get isJaas => method == 'jaas';

  bool get isCommunity => method == 'community';

  bool get hasToken => token != null && token!.isNotEmpty;

  factory CallCredentials.fromJson(dynamic json) {
    final map = json is Map ? json : const {};

    return CallCredentials(
      room: map['room']?.toString() ?? '',
      domain: map['domain']?.toString() ?? '',
      appId: _text(map['app_id']),
      method: map['method']?.toString() ?? 'jaas',
      token: _text(map['token']),
      url: map['url']?.toString() ?? '',
      isVideo: TypeUtils.safeBool(map['is_video']),
    );
  }
}

/// Result of `POST /v2/conferences/{id}/join`.
class CallJoinResult {
  final CallConference conference;
  final CallCredentials credentials;

  const CallJoinResult({
    required this.conference,
    required this.credentials,
  });

  factory CallJoinResult.fromJson(Map<String, dynamic> json) {
    final rawConference = json['conference'];

    return CallJoinResult(
      conference: CallConference.fromJson(
        rawConference is Map
            ? Map<String, dynamic>.from(rawConference)
            : const {},
      ),
      credentials: CallCredentials.fromJson(json['call']),
    );
  }
}

/// Poll result from `/v2/conferences/incoming`.
class IncomingCallState {
  final bool incoming;
  final CallConference? conference;

  const IncomingCallState({this.incoming = false, this.conference});

  bool get hasIncoming => incoming && conference != null;

  factory IncomingCallState.fromJson(Map<String, dynamic> json) {
    final rawConference = json['conference'];

    return IncomingCallState(
      incoming: TypeUtils.safeBool(json['incoming']),
      conference: rawConference is Map
          ? CallConference.fromJson(Map<String, dynamic>.from(rawConference))
          : null,
    );
  }
}

/// Result of leaving a call.
class CallParticipantState {
  final int conferenceId;
  final CallStatus status;
  final CallParticipant participant;

  const CallParticipantState({
    required this.conferenceId,
    required this.status,
    required this.participant,
  });

  factory CallParticipantState.fromJson(Map<String, dynamic> json) {
    return CallParticipantState(
      conferenceId: TypeUtils.safeInt(json['conference_id']) ?? 0,
      status: CallStatus.parse(json['status']),
      participant: CallParticipant.fromJson(json['participant']),
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
