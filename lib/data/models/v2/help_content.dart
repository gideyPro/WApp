import 'dart:convert';

import '../../../core/utils/type_utils.dart';

/// One help category from `/v2/help`.
class HelpCategory {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;
  final int sortOrder;
  final int articlesCount;

  const HelpCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
    this.sortOrder = 0,
    this.articlesCount = 0,
  });

  factory HelpCategory.fromJson(Map<String, dynamic> json) {
    return HelpCategory(
      id: TypeUtils.safeInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: _text(json['description']),
      icon: _text(json['icon']),
      sortOrder: TypeUtils.safeInt(json['sort_order']) ?? 0,
      articlesCount: TypeUtils.safeInt(json['articles_count']) ?? 0,
    );
  }
}

/// Article list projection. `content` is loaded only on detail.
class HelpArticleSummary {
  final int id;
  final String slug;
  final String title;
  final String? summary;
  final HelpCategory? category;
  final bool isFeatured;
  final List<String> tags;
  final int views;
  final int helpfulCount;
  final int notHelpfulCount;
  final DateTime? updatedAt;

  const HelpArticleSummary({
    required this.id,
    required this.slug,
    required this.title,
    this.summary,
    this.category,
    this.isFeatured = false,
    this.tags = const [],
    this.views = 0,
    this.helpfulCount = 0,
    this.notHelpfulCount = 0,
    this.updatedAt,
  });

  bool get hasCategory => category != null;

  factory HelpArticleSummary.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category'];

    return HelpArticleSummary(
      id: TypeUtils.safeInt(json['id']) ?? 0,
      slug: json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      summary: _text(json['summary']),
      category: rawCategory is Map
          ? HelpCategory.fromJson(Map<String, dynamic>.from(rawCategory))
          : null,
      isFeatured: TypeUtils.safeBool(json['is_featured']),
      tags: _tags(json['tags']),
      views: TypeUtils.safeInt(json['views']) ?? 0,
      helpfulCount: TypeUtils.safeInt(json['helpful_count']) ?? 0,
      notHelpfulCount: TypeUtils.safeInt(json['not_helpful_count']) ?? 0,
      updatedAt: _date(json['updated_at']),
    );
  }
}

/// Full article payload from `/v2/help/articles/{slug}`.
class HelpArticle extends HelpArticleSummary {
  final String content;
  final String formattedContent;
  final bool hasProvidedFeedback;
  final List<HelpArticleSummary> relatedArticles;

  const HelpArticle({
    required super.id,
    required super.slug,
    required super.title,
    super.summary,
    super.category,
    super.isFeatured,
    super.tags,
    super.views,
    super.helpfulCount,
    super.notHelpfulCount,
    super.updatedAt,
    this.content = '',
    this.formattedContent = '',
    this.hasProvidedFeedback = false,
    this.relatedArticles = const [],
  });

  factory HelpArticle.fromJson(Map<String, dynamic> json) {
    final summary = HelpArticleSummary.fromJson(json);
    final rawRelated = json['related_articles'];

    return HelpArticle(
      id: summary.id,
      slug: summary.slug,
      title: summary.title,
      summary: summary.summary,
      category: summary.category,
      isFeatured: summary.isFeatured,
      tags: summary.tags,
      views: summary.views,
      helpfulCount: summary.helpfulCount,
      notHelpfulCount: summary.notHelpfulCount,
      updatedAt: summary.updatedAt,
      content: json['content']?.toString() ?? '',
      formattedContent: json['formatted_content']?.toString() ?? '',
      hasProvidedFeedback: TypeUtils.safeBool(json['has_provided_feedback']),
      relatedArticles: rawRelated is List
          ? rawRelated
              .whereType<Map>()
              .map((item) =>
                  HelpArticleSummary.fromJson(Map<String, dynamic>.from(item)))
              .toList(growable: false)
          : const [],
    );
  }
}

/// Ticket counters shown on the help home screen for signed-in users.
class HelpTicketStats {
  final int total;
  final int open;
  final int inProgress;
  final int resolved;
  final int waitingCustomer;

  const HelpTicketStats({
    this.total = 0,
    this.open = 0,
    this.inProgress = 0,
    this.resolved = 0,
    this.waitingCustomer = 0,
  });

  factory HelpTicketStats.fromJson(Map<String, dynamic> json) {
    return HelpTicketStats(
      total: TypeUtils.safeInt(json['total']) ?? 0,
      open: TypeUtils.safeInt(json['open']) ?? 0,
      inProgress: TypeUtils.safeInt(json['in_progress']) ?? 0,
      resolved: TypeUtils.safeInt(json['resolved']) ?? 0,
      waitingCustomer: TypeUtils.safeInt(json['waiting_customer']) ?? 0,
    );
  }
}

/// `GET /v2/help` payload.
class HelpHome {
  final List<HelpCategory> categories;
  final List<HelpArticleSummary> featuredArticles;
  final List<HelpArticleSummary> recentArticles;
  final HelpTicketStats? ticketStats;

  const HelpHome({
    this.categories = const [],
    this.featuredArticles = const [],
    this.recentArticles = const [],
    this.ticketStats,
  });

  bool get isSignedIn => ticketStats != null;

  factory HelpHome.fromJson(Map<String, dynamic> json) {
    final rawStats = json['ticket_stats'];

    return HelpHome(
      categories: _categories(json['categories']),
      featuredArticles: _articles(json['featured_articles']),
      recentArticles: _articles(json['recent_articles']),
      ticketStats: rawStats is Map
          ? HelpTicketStats.fromJson(Map<String, dynamic>.from(rawStats))
          : null,
    );
  }
}

/// Result of voting an article helpful/not helpful.
class HelpArticleFeedback {
  final int articleId;
  final bool isHelpful;
  final bool recorded;
  final int helpfulCount;
  final int notHelpfulCount;

  const HelpArticleFeedback({
    required this.articleId,
    required this.isHelpful,
    this.recorded = false,
    this.helpfulCount = 0,
    this.notHelpfulCount = 0,
  });

  /// False when the same user/IP already voted; counters are unchanged.
  bool get alreadyVoted => !recorded;

  factory HelpArticleFeedback.fromJson(Map<String, dynamic> json) {
    return HelpArticleFeedback(
      articleId: TypeUtils.safeInt(json['article_id']) ?? 0,
      isHelpful: TypeUtils.safeBool(json['is_helpful']),
      recorded: TypeUtils.safeBool(json['recorded']),
      helpfulCount: TypeUtils.safeInt(json['helpful_count']) ?? 0,
      notHelpfulCount: TypeUtils.safeInt(json['not_helpful_count']) ?? 0,
    );
  }
}

List<HelpCategory> _categories(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((item) => HelpCategory.fromJson(Map<String, dynamic>.from(item)))
      .toList(growable: false);
}

List<HelpArticleSummary> _articles(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((item) =>
          HelpArticleSummary.fromJson(Map<String, dynamic>.from(item)))
      .toList(growable: false);
}

List<String> _tags(dynamic raw) {
  if (raw is List) {
    return raw.map((tag) => tag.toString()).toList(growable: false);
  }

  if (raw is String && raw.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((tag) => tag.toString()).toList(growable: false);
      }
    } on FormatException {
      return const [];
    }
  }

  return const [];
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
