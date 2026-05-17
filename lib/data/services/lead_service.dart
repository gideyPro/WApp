import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
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

  /// Get user's interest-based leads (my-interests)
  Future<LeadResponse> getMyInterests({int page = 1, int perPage = 15}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.myInterests,
        queryParameters: {'page': page, 'per_page': perPage},
      );
      if (response.statusCode == 200) {
        final outerData = response.data['data'] ?? response.data;
        final innerData = outerData['data'] ?? outerData;
        final leads = (innerData['data'] as List)
            .map((json) => Lead.fromJson(json))
            .toList();
        return LeadResponse(success: true, leads: leads);
      }
      return LeadResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch interests',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return LeadResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Express interest in a listing (creates a lead)
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
        final lead = response.data['data'] != null
            ? Lead.fromJson(response.data['data'])
            : null;
        return LeadResponse(
          success: true,
          message: response.data['message'] ?? 'Interest expressed',
          lead: lead,
        );
      }
      return LeadResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to express interest',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return LeadResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Cancel/remove a lead
  Future<LeadResponse> cancelInterest(int leadId) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.cancelInterest}/$leadId',
      );
      if (response.statusCode == 200) {
        return LeadResponse(
          success: true,
          message: response.data['message'] ?? 'Interest cancelled',
        );
      }
      return LeadResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to cancel interest',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return LeadResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get suggestions for an order
  Future<LeadResponse> getSuggestions(int orderId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.apiBase}/orders/$orderId/suggestions',
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? [];
        return LeadResponse(
          success: true,
          leads: (data as List)
              .map((j) => Lead.fromJson(j as Map<String, dynamic>))
              .toList(),
        );
      }
      return LeadResponse(
        success: false,
        message: response.data?['message'] ?? 'Failed to fetch suggestions',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return LeadResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Accept a suggestion lead
  Future<LeadResponse> acceptSuggestion(int suggestionId) async {
    try {
      final response = await _apiClient.dio.patch(
        '${ApiConstants.apiBase}/orders/suggestions/$suggestionId/accept',
      );
      if (response.statusCode == 200) {
        return LeadResponse(
          success: true,
          message: response.data['message'] ?? 'Suggestion accepted',
        );
      }
      return LeadResponse(
        success: false,
        message: response.data?['message'] ?? 'Failed to accept suggestion',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return LeadResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Decline a suggestion lead
  Future<LeadResponse> declineSuggestion(int suggestionId) async {
    try {
      final response = await _apiClient.dio.patch(
        '${ApiConstants.apiBase}/orders/suggestions/$suggestionId/decline',
      );
      if (response.statusCode == 200) {
        return LeadResponse(
          success: true,
          message: response.data['message'] ?? 'Suggestion declined',
        );
      }
      return LeadResponse(
        success: false,
        message: response.data?['message'] ?? 'Failed to decline suggestion',
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
