import '../../../core/network/v2/api_v2_client.dart';
import '../../../core/network/v2/api_v2_constants.dart';
import '../../../core/network/v2/paginated.dart';
import '../../models/v2/conference.dart';

/// Scheduled and direct calls for the authenticated participant.
///
/// Lifecycle actions are idempotent on the backend: joining twice, leaving
/// twice, ending an ended call and cancelling a cancelled call all return the
/// current state instead of failing.
class ConferenceServiceV2 {
  final ApiV2Client _client;

  ConferenceServiceV2({ApiV2Client? client})
      : _client = client ?? ApiV2Client();

  /// The viewer's calls, newest first.
  Future<Paginated<CallConference>> fetch({
    CallStatus? status,
    String? cursor,
    int limit = ApiV2Constants.defaultLimit,
  }) {
    return _client.getCollection(
      ApiV2Constants.conferences,
      parse: CallConference.fromJson,
      query: {
        if (status != null && status != CallStatus.unknown)
          'status': status.wireValue,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': _clampLimit(limit),
      },
    );
  }

  Future<CallConference> fetchConference(int id) async {
    final data = await _client.getItem(ApiV2Constants.conference(id));
    return CallConference.fromJson(data);
  }

  /// The latest call still ringing the viewer, if any.
  Future<IncomingCallState> incoming() async {
    final data = await _client.getItem(ApiV2Constants.conferencesIncoming);
    return IncomingCallState.fromJson(data);
  }

  /// Schedule a call about a listing.
  ///
  /// The caller owns [submissionKey]; reusing it returns the existing call
  /// instead of scheduling a duplicate.
  Future<CallConference> schedule({
    required String submissionKey,
    required int listingId,
    required List<int> participantIds,
    DateTime? scheduledAt,
    bool isVideo = false,
    String? notes,
  }) async {
    final key = submissionKey.trim();

    if (key.isEmpty) {
      throw ArgumentError.value(
        submissionKey,
        'submissionKey',
        'Submission key cannot be empty',
      );
    }

    if (participantIds.isEmpty) {
      throw ArgumentError.value(
        participantIds,
        'participantIds',
        'Invite at least one participant',
      );
    }

    if (participantIds.toSet().length != participantIds.length) {
      throw ArgumentError.value(
        participantIds,
        'participantIds',
        'Participants must be unique',
      );
    }

    final trimmedNotes = notes?.trim();

    final data = await _client.sendItem(
      ApiV2Constants.conferences,
      method: 'POST',
      body: {
        'submission_key': key,
        'listing_id': listingId,
        'participant_ids': participantIds,
        if (scheduledAt != null)
          'scheduled_at': scheduledAt.toUtc().toIso8601String(),
        'is_video': isVideo,
        if (trimmedNotes != null && trimmedNotes.isNotEmpty)
          'notes': trimmedNotes,
      },
    );

    return CallConference.fromJson(data);
  }

  /// Start an immediate call from an existing chat thread.
  Future<CallConference> startDirect({
    required int conversationId,
    bool isVideo = false,
  }) async {
    final data = await _client.sendItem(
      ApiV2Constants.conferencesDirect,
      method: 'POST',
      body: {
        'conversation_id': conversationId,
        'is_video': isVideo,
      },
    );

    return CallConference.fromJson(data);
  }

  /// Join a call and receive the Jitsi room credentials.
  Future<CallJoinResult> join(int id) async {
    final data = await _client.sendItem(
      ApiV2Constants.conferenceJoin(id),
      method: 'POST',
    );

    return CallJoinResult.fromJson(data);
  }

  /// Leave a call; the backend accumulates the session duration.
  Future<CallParticipantState> leave(int id) async {
    final data = await _client.sendItem(
      ApiV2Constants.conferenceLeave(id),
      method: 'POST',
    );

    return CallParticipantState.fromJson(data);
  }

  /// End an active call. The host or staff only.
  Future<CallConference> end(int id) async {
    final data = await _client.sendItem(
      ApiV2Constants.conferenceEnd(id),
      method: 'POST',
    );

    return CallConference.fromJson(data);
  }

  /// Cancel a scheduled call. The host only.
  Future<CallConference> cancel(int id) async {
    final data = await _client.sendItem(
      ApiV2Constants.conferenceCancel(id),
      method: 'POST',
    );

    return CallConference.fromJson(data);
  }

  static int _clampLimit(int limit) {
    if (limit <= 0) return ApiV2Constants.defaultLimit;
    return limit > ApiV2Constants.maxLimit ? ApiV2Constants.maxLimit : limit;
  }
}
