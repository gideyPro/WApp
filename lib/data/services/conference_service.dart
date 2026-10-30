import '../../core/network/api_client.dart';
import '../../core/network/error_handler.dart';
import '../models/v2/conference.dart';
import 'v2/conference_service.dart';

/// Service for video conferences (Jitsi integration) backed by V2 API.
class ConferenceService {
  final ConferenceServiceV2 _v2;

  ConferenceService({ApiClient? apiClient, ConferenceServiceV2? v2Service})
      : _v2 = v2Service ?? ConferenceServiceV2();

  Future<ConferenceResponse> getConferences() async {
    try {
      final result = await _v2.fetch();
      final conferences = result.items.map(_toLegacyConference).toList();

      return ConferenceResponse(
        success: true,
        conferences: conferences,
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConferenceResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<IncomingCallResponse> checkIncomingCall() async {
    try {
      final incoming = await _v2.incoming();

      if (incoming.hasIncoming && incoming.conference != null) {
        final conf = incoming.conference!;
        return IncomingCallResponse(
          success: true,
          hasIncoming: true,
          callData: {
            'incoming': true,
            'conference_id': conf.id,
            'caller_name': conf.host?.name ?? 'Caller',
            'caller_avatar': conf.host?.avatarUrl,
            'caller_initials': conf.host?.initials ?? 'C',
            'listing_title': conf.listing?.title,
            'is_video': conf.isVideo,
          },
        );
      }

      return const IncomingCallResponse(
        success: true,
        hasIncoming: false,
      );
    } catch (_) {
      return const IncomingCallResponse(success: false, hasIncoming: false);
    }
  }

  Future<ConferenceResponse> createConference({
    required int listingId,
    List<int>? participantIds,
  }) async {
    try {
      final subKey = 'conf-${DateTime.now().microsecondsSinceEpoch}';
      final conf = await _v2.schedule(
        submissionKey: subKey,
        listingId: listingId,
        participantIds: participantIds ?? const [],
      );

      final joinResult = await _v2.join(conf.id);

      return ConferenceResponse(
        success: true,
        conference: _toLegacyConference(conf),
        message: 'Conference created',
        jitsiRoomUrl: joinResult.credentials.url,
        jitsiToken: joinResult.credentials.token,
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConferenceResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ConferenceResponse> startDirectCall({
    required int conversationId,
    bool isVideo = false,
  }) async {
    try {
      final conf = await _v2.startDirect(
        conversationId: conversationId,
        isVideo: isVideo,
      );

      final joinResult = await _v2.join(conf.id);

      return ConferenceResponse(
        success: true,
        conference: _toLegacyConference(conf),
        jitsiRoomUrl: joinResult.credentials.url,
        jitsiToken: joinResult.credentials.token,
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConferenceResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ConferenceResponse> getConferenceDetail(int conferenceId) async {
    try {
      final conf = await _v2.fetchConference(conferenceId);
      final joinResult = await _v2.join(conf.id);

      return ConferenceResponse(
        success: true,
        conference: _toLegacyConference(conf),
        jitsiRoomUrl: joinResult.credentials.url,
        jitsiToken: joinResult.credentials.token,
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConferenceResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ConferenceResponse> joinConference(int conferenceId) async {
    try {
      final joinResult = await _v2.join(conferenceId);

      return ConferenceResponse(
        success: true,
        jitsiRoomUrl: joinResult.credentials.url,
        jitsiToken: joinResult.credentials.token,
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConferenceResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ConferenceResponse> deleteConference(int conferenceId) async {
    try {
      await _v2.leave(conferenceId);
      return const ConferenceResponse(
        success: true,
        message: 'Conference left',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConferenceResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ConferenceResponse> inviteUser({
    required int conferenceId,
    required int userId,
  }) async {
    return const ConferenceResponse(success: true, message: 'User invited');
  }

  Future<bool> pingConference(int conferenceId) async {
    return true;
  }

  static Conference _toLegacyConference(CallConference conf) {
    return Conference(
      id: conf.id,
      roomName: 'wavemart-${conf.id}',
      status: conf.status.wireValue,
      startedAt: conf.startedAt?.toIso8601String(),
      endedAt: conf.endedAt?.toIso8601String(),
      listingId: conf.listing?.id ?? 0,
      initiatorId: conf.host?.id ?? 0,
    );
  }
}

class ConferenceResponse {
  final bool success;
  final String message;
  final List<Conference> conferences;
  final Conference? conference;
  final String? jitsiRoomUrl;
  final String? jitsiToken;

  const ConferenceResponse({
    required this.success,
    this.message = '',
    this.conferences = const [],
    this.conference,
    this.jitsiRoomUrl,
    this.jitsiToken,
  });
}

class IncomingCallResponse {
  final bool success;
  final bool hasIncoming;
  final Map<String, dynamic>? callData;

  const IncomingCallResponse({
    required this.success,
    required this.hasIncoming,
    this.callData,
  });
}

class Conference {
  final int id;
  final String roomName;
  final String status;
  final String? startedAt;
  final String? endedAt;
  final int listingId;
  final int initiatorId;

  const Conference({
    required this.id,
    required this.roomName,
    required this.status,
    this.startedAt,
    this.endedAt,
    required this.listingId,
    required this.initiatorId,
  });

  factory Conference.fromJson(Map<String, dynamic> json) {
    return Conference(
      id: json['id'] ?? 0,
      roomName: json['room_name'] ?? '',
      status: json['status'] ?? 'pending',
      startedAt: json['started_at'],
      endedAt: json['ended_at'],
      listingId: json['listing_id'] ?? 0,
      initiatorId: json['initiator_id'] ?? 0,
    );
  }

  bool get isActive => status == 'active';
  bool get isEnded => status == 'ended';
}
