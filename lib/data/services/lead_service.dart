import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/api_envelope.dart';
import '../../core/network/error_handler.dart';

class Lead {
  final int id;
  final int userId;
  final int listingId;
  final int? orderId;
  final int? assignedTo;
  final String source;
  final String stage;
  final String? buyerMessage;
  final String? adminNotes;
  final String? lostReason;
  final String? contactedAt;
  final String? closedAt;
  final String? readAt;
  final String createdAt;
  final String? updatedAt;
  final Map<String, dynamic>? listing;
  final Map<String, dynamic>? order;

  Lead({
    required this.id,
    required this.userId,
    required this.listingId,
    this.orderId,
    this.assignedTo,
    required this.source,
    required this.stage,
    this.buyerMessage,
    this.adminNotes,
    this.lostReason,
    this.contactedAt,
    this.closedAt,
    this.readAt,
    required this.createdAt,
    this.updatedAt,
    this.listing,
    this.order,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      listingId: json['listing_id'] ?? 0,
      orderId: json['order_id'],
      assignedTo: json['assigned_to'],
      source: json['source'] ?? 'interest',
      stage: json['stage'] ?? 'new',
      buyerMessage: json['buyer_message'],
      adminNotes: json['admin_notes'],
      lostReason: json['lost_reason'],
      contactedAt: json['contacted_at'],
      closedAt: json['closed_at'],
      readAt: json['read_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'],
      listing: json['listing'],
      order: json['order'],
    );
  }

  bool get isNew => stage == 'new';
  bool get isContacted => stage == 'contacted';
  bool get isNegotiating => stage == 'negotiating';
  bool get isOffer => stage == 'offer';
  bool get isWon => stage == 'won';
  bool get isLost => stage == 'lost';

  bool get isFromInterest => source == 'interest';
  bool get isFromSuggestion => source == 'suggestion';

  bool get isSuggestionPending => source == 'suggestion' && stage == 'new';
  bool get isSuggestionAccepted => source == 'suggestion' && (stage == 'negotiating' || stage == 'offer' || stage == 'won');
  bool get isSuggestionDeclined => source == 'suggestion' && stage == 'lost';

  String? get listingTitle {
    if (listing == null) return null;
    return listing!['title'] ?? listing!['description'] ?? 'Listing #$listingId';
  }

  double? get listingPrice {
    if (listing == null) return null;
    final price = listing!['price_fixed'];
    if (price == null) return null;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    return null;
  }

  String get stageLabel {
    switch (stage) {
      case 'new': return 'New';
      case 'contacted': return 'Contacted';
      case 'negotiating': return 'Negotiating';
      case 'offer': return 'Offer';
      case 'won': return 'Won';
      case 'lost': return 'Lost';
      default: return stage;
    }
  }
}

class LeadResponse {
  final bool success;
  final String message;
  final List<Lead> leads;
  final Lead? lead;

  const LeadResponse({
    required this.success,
    this.message = '',
    this.leads = const [],
    this.lead,
  });
}

class LeadService {
  final ApiClient _apiClient;

  LeadService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<LeadResponse> getMyInterests({int page = 1, int perPage = 15}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.myInterests,
        queryParameters: {'page': page, 'per_page': perPage},
      );
      if (response.statusCode == 200) {
        final dataList = ApiEnvelope.extractList(
          response.data,
          itemKeys: const ['leads', 'interests', 'items'],
        );
        final leads = dataList
            .whereType<Map>()
            .map((json) => Lead.fromJson(json as Map<String, dynamic>))
            .toList();
        return LeadResponse(success: true, leads: leads);
      }
      return LeadResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch interests'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return LeadResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<LeadResponse> expressInterest({
    required int listingId,
    String? message,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.expressInterest}/$listingId/interest',
        data: {if (message != null && message.isNotEmpty) 'message': message},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final lead = (data is Map && data['data'] is Map)
            ? Lead.fromJson(Map<String, dynamic>.from(data['data'] as Map))
            : null;

        return LeadResponse(
          success: true,
          message: ApiEnvelope.extractMessage(data, 'Interest expressed'),
          lead: lead,
        );
      }
      return LeadResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to express interest'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return LeadResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<LeadResponse> cancelInterest(int leadId) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.cancelInterest}/$leadId',
      );
      if (response.statusCode == 200) {
        return LeadResponse(
          success: true,
          message: ApiEnvelope.extractMessage(response.data, 'Interest cancelled'),
        );
      }
      return LeadResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to cancel interest'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return LeadResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<LeadResponse> getSuggestions(int orderId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.apiBase}/orders/$orderId/suggestions',
      );
      if (response.statusCode == 200) {
        final dataList = ApiEnvelope.extractList(
          response.data,
          itemKeys: const ['suggestions', 'leads', 'items'],
        );
        return LeadResponse(
          success: true,
          leads: dataList
              .whereType<Map>()
              .map((j) => Lead.fromJson(j as Map<String, dynamic>))
              .toList(),
        );
      }
      return LeadResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch suggestions'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return LeadResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<LeadResponse> acceptSuggestion(int suggestionId) async {
    try {
      final response = await _apiClient.dio.patch(
        '${ApiConstants.apiBase}/orders/suggestions/$suggestionId/accept',
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final lead = (data is Map && data['data'] is Map)
            ? Lead.fromJson(Map<String, dynamic>.from(data['data'] as Map))
            : null;

        return LeadResponse(
          success: true,
          message: ApiEnvelope.extractMessage(data, 'Suggestion accepted'),
          lead: lead,
        );
      }
      return LeadResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to accept suggestion'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return LeadResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<LeadResponse> declineSuggestion(int suggestionId) async {
    try {
      final response = await _apiClient.dio.patch(
        '${ApiConstants.apiBase}/orders/suggestions/$suggestionId/decline',
      );
      if (response.statusCode == 200) {
        return LeadResponse(
          success: true,
          message: ApiEnvelope.extractMessage(response.data, 'Suggestion declined'),
        );
      }
      return LeadResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to decline suggestion'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return LeadResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  factory LeadService.withClient(ApiClient client) => LeadService(apiClient: client);

}
