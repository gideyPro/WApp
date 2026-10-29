import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/v2/api_v2_client.dart';
import '../../../core/network/v2/api_v2_constants.dart';
import '../../../core/network/v2/paginated.dart';
import '../../models/v2/help_content.dart';
import '../../models/v2/help_ticket.dart';

/// Public help center plus the authenticated support-ticket flow.
class HelpServiceV2 {
  final ApiV2Client _client;

  HelpServiceV2({ApiV2Client? client}) : _client = client ?? ApiV2Client();

  Future<HelpHome> fetchHome() async {
    final data = await _client.getItem(ApiV2Constants.help);
    return HelpHome.fromJson(data);
  }

  Future<HelpCategory> fetchCategory(String slug) async {
    final data = await _client.getItem(ApiV2Constants.helpCategory(slug));
    return HelpCategory.fromJson(data);
  }

  Future<Paginated<HelpArticleSummary>> fetchArticles({
    String? category,
    String? query,
    String? cursor,
    int limit = ApiV2Constants.defaultLimit,
  }) {
    final term = query?.trim();

    return _client.getCollection(
      ApiV2Constants.helpArticles,
      parse: HelpArticleSummary.fromJson,
      query: {
        if (category != null && category.isNotEmpty) 'category': category,
        if (term != null && term.isNotEmpty) 'q': term,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': _clampLimit(limit),
      },
    );
  }

  Future<HelpArticle> fetchArticle(String slug) async {
    final data = await _client.getItem(ApiV2Constants.helpArticle(slug));
    return HelpArticle.fromJson(data);
  }

  /// Record one helpful/not-helpful vote.
  ///
  /// [HelpArticleFeedback.recorded] is false when the caller already voted;
  /// the API then returns 200 instead of 201, which is not an error.
  Future<HelpArticleFeedback> submitArticleFeedback(
    String slug, {
    required bool isHelpful,
    String? comment,
  }) async {
    final data = await _client.sendItem(
      ApiV2Constants.helpArticleFeedback(slug),
      method: 'POST',
      body: {
        'is_helpful': isHelpful,
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
      },
    );

    return HelpArticleFeedback.fromJson(data);
  }

  Future<Paginated<HelpTicketSummary>> fetchTickets({
    String? cursor,
    int limit = ApiV2Constants.defaultLimit,
  }) {
    return _client.getCollection(
      ApiV2Constants.helpTickets,
      parse: HelpTicketSummary.fromJson,
      query: {
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': _clampLimit(limit),
      },
    );
  }

  Future<HelpTicket> createTicket({
    int? categoryId,
    required String subject,
    required String message,
    HelpTicketPriority? priority,
  }) async {
    final data = await _client.sendItem(
      ApiV2Constants.helpTickets,
      method: 'POST',
      body: {
        if (categoryId != null) 'category_id': categoryId,
        'subject': subject,
        'message': message,
        if (priority != null) 'priority': priority.wireValue,
      },
    );

    return HelpTicket.fromJson(data);
  }

  Future<HelpTicket> fetchTicket(String ticketNumber) async {
    final data = await _client.getItem(
      ApiV2Constants.helpTicket(ticketNumber),
    );

    return HelpTicket.fromJson(data);
  }

  /// Reply to a ticket.
  ///
  /// Uses multipart when [attachments] is non-empty; the backend accepts at
  /// most five files per message.
  Future<HelpTicketMessage> sendMessage(
    String ticketNumber, {
    required String message,
    List<File> attachments = const [],
  }) async {
    if (attachments.length > 5) {
      throw ArgumentError.value(
        attachments,
        'attachments',
        'At most 5 attachments per message',
      );
    }

    final path = ApiV2Constants.helpTicketMessages(ticketNumber);

    if (attachments.isEmpty) {
      final data = await _client.sendItem(
        path,
        method: 'POST',
        body: {'message': message},
      );

      return HelpTicketMessage.fromJson(data);
    }

    final form = FormData()..fields.add(MapEntry('message', message));
    for (final attachment in attachments) {
      form.files.add(
        MapEntry('attachments[]', await _multipart(attachment)),
      );
    }

    final data = await _client.sendFormItem(path, formData: form);

    return HelpTicketMessage.fromJson(data);
  }

  /// Rate a resolved or closed ticket. Re-rating overwrites the score.
  Future<HelpTicketRating> rateTicket(
    String ticketNumber, {
    required int rating,
    String? comment,
  }) async {
    if (rating < 1 || rating > 5) {
      throw ArgumentError.value(rating, 'rating', 'Rating must be 1-5');
    }

    final data = await _client.sendItem(
      ApiV2Constants.helpTicketRating(ticketNumber),
      method: 'POST',
      body: {
        'rating': rating,
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
      },
    );

    return HelpTicketRating.fromJson(data);
  }

  static Future<MultipartFile> _multipart(File file) {
    final segments = file.uri.pathSegments;
    final filename = segments.isEmpty ? 'upload' : segments.last;
    return MultipartFile.fromFile(file.path, filename: filename);
  }

  static int _clampLimit(int limit) {
    if (limit <= 0) return ApiV2Constants.defaultLimit;
    return limit > ApiV2Constants.maxLimit ? ApiV2Constants.maxLimit : limit;
  }
}
