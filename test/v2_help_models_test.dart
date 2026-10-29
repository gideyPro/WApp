import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/v2/paginated.dart';
import 'package:wavemart/data/models/v2/help_content.dart';
import 'package:wavemart/data/models/v2/help_ticket.dart';

import 'v2_fixtures.dart';

void main() {
  group('help.index fixture', () {
    late HelpHome home;

    setUp(() {
      home = HelpHome.fromJson(
        loadV2Fixture('help.index.json')['data'] as Map<String, dynamic>,
      );
    });

    test('parses categories and article groups', () {
      expect(home.categories, hasLength(1));
      expect(home.featuredArticles, hasLength(1));
      expect(home.recentArticles, hasLength(1));
      expect(home.ticketStats, isNull);
      expect(home.isSignedIn, isFalse);

      final category = home.categories.single;
      expect(category.name, 'Getting Started');
      expect(category.slug, 'general');
      expect(category.articlesCount, 4);

      final featured = home.featuredArticles.single;
      expect(featured.isFeatured, isTrue);
      expect(featured.category?.slug, 'general');
      expect(featured.tags, ['getting-started']);
      expect(featured.updatedAt?.toUtc(), DateTime.utc(2026, 10, 20, 8));
    });

    test('parses ticket stats for signed-in users', () {
      final signedIn = HelpHome.fromJson({
        ...loadV2Fixture('help.index.json')['data'] as Map<String, dynamic>,
        'ticket_stats': {
          'total': 4,
          'open': 1,
          'in_progress': 2,
          'resolved': 1,
          'waiting_customer': 0,
        },
      });

      expect(signedIn.isSignedIn, isTrue);
      expect(signedIn.ticketStats?.total, 4);
      expect(signedIn.ticketStats?.inProgress, 2);
      expect(signedIn.ticketStats?.resolved, 1);
    });
  });

  group('help.article fixture', () {
    late HelpArticle article;

    setUp(() {
      article = HelpArticle.fromJson(
        loadV2Fixture('help.article.json')['data'] as Map<String, dynamic>,
      );
    });

    test('parses content and related articles', () {
      expect(article.slug, 'what-is-wavemart');
      expect(article.content, contains('marketplace'));
      expect(article.formattedContent, contains('marketplace'));
      expect(article.hasProvidedFeedback, isFalse);
      expect(article.relatedArticles, hasLength(1));
      expect(article.relatedArticles.single.slug, 'how-to-create-listing');
    });

    test('normalizes legacy JSON-string tags', () {
      final parsed = HelpArticleSummary.fromJson({
        'id': 1,
        'slug': 'legacy',
        'title': 'Legacy article',
        'tags': '["guide","payments"]',
      });

      expect(parsed.tags, ['guide', 'payments']);
    });
  });

  group('help.tickets.index fixture', () {
    late Paginated<HelpTicketSummary> page;

    setUp(() {
      page = Paginated.fromJson(
        loadV2Fixture('help.tickets.index.json'),
        HelpTicketSummary.fromJson,
      );
    });

    test('parses the collection and unread state', () {
      expect(page.items, hasLength(1));
      expect(page.hasMore, isFalse);
      expect(page.nextCursor, isNull);
      expect(page.perPage, 20);

      final ticket = page.items.single;
      expect(ticket.ticketNumber, 'WM-2026-00001');
      expect(ticket.status, HelpTicketStatus.inProgress);
      expect(ticket.status.canRate, isFalse);
      expect(ticket.priority, HelpTicketPriority.high);
      expect(ticket.category?.slug, 'listings');
      expect(ticket.rating, isNull);
      expect(ticket.isRated, isFalse);
      expect(ticket.unreadMessages, 1);
      expect(ticket.hasUnreadMessages, isTrue);
      expect(ticket.lastMessage?.isStaff, isTrue);
      expect(ticket.lastMessage?.isRead, isFalse);
    });
  });

  group('help.ticket.show fixture', () {
    late HelpTicket ticket;

    setUp(() {
      ticket = HelpTicket.fromJson(
        loadV2Fixture('help.ticket.show.json')['data'] as Map<String, dynamic>,
      );
    });

    test('parses the description and thread', () {
      expect(ticket.message, contains('photo upload'));
      expect(ticket.ratingComment, isNull);
      expect(ticket.messages, hasLength(2));
      expect(ticket.messages.first.isStaff, isFalse);
      expect(ticket.messages.last.isStaff, isTrue);
      expect(ticket.messages.last.isRead, isTrue);
      expect(ticket.messages.last.createdAt?.toUtc(),
          DateTime.utc(2026, 10, 29, 9, 30));
    });

    test('parses attachments and a resolved rating', () {
      final rated = HelpTicket.fromJson({
        'ticket_number': 'WM-2026-00002',
        'subject': 'Resolved ticket',
        'status': 'resolved',
        'priority': 'medium',
        'category': null,
        'rating': 4,
        'unread_messages': 0,
        'last_message': null,
        'created_at': '2026-10-28T09:00:00Z',
        'updated_at': '2026-10-29T09:00:00Z',
        'resolved_at': '2026-10-29T09:00:00Z',
        'closed_at': null,
        'message': 'Thanks for the help.',
        'rating_comment': 'Resolved quickly.',
        'messages': [
          {
            'id': 90,
            'body': 'Here is the screenshot.',
            'is_staff': false,
            'attachments': [
              {'url': 'https://cdn.test/attachments/screen.png'},
            ],
            'is_read': true,
            'created_at': '2026-10-28T09:05:00Z',
          },
        ],
      });

      expect(rated.status, HelpTicketStatus.resolved);
      expect(rated.status.canRate, isTrue);
      expect(rated.rating, 4);
      expect(rated.isRated, isTrue);
      expect(rated.ratingComment, 'Resolved quickly.');
      expect(rated.resolvedAt, isNotNull);
      expect(rated.messages.single.hasAttachments, isTrue);
      expect(rated.messages.single.attachments.single.url,
          'https://cdn.test/attachments/screen.png');
    });
  });

  group('help helpers', () {
    test('parses ticket status and priority wire values', () {
      expect(HelpTicketStatus.parse('open'), HelpTicketStatus.open);
      expect(
        HelpTicketStatus.parse('waiting_customer'),
        HelpTicketStatus.waitingCustomer,
      );
      expect(HelpTicketStatus.parse('closed').canRate, isTrue);
      expect(HelpTicketStatus.parse('archived'), HelpTicketStatus.unknown);

      expect(HelpTicketPriority.parse('urgent'), HelpTicketPriority.urgent);
      expect(HelpTicketPriority.parse(null), HelpTicketPriority.unknown);
    });

    test('parses a repeat article vote', () {
      final feedback = HelpArticleFeedback.fromJson({
        'article_id': 10,
        'is_helpful': true,
        'recorded': false,
        'helpful_count': 22,
        'not_helpful_count': 1,
      });

      expect(feedback.alreadyVoted, isTrue);
      expect(feedback.helpfulCount, 22);
    });

    test('defaults missing help payloads safely', () {
      final home = HelpHome.fromJson(const {});
      expect(home.categories, isEmpty);
      expect(home.isSignedIn, isFalse);

      final ticket = HelpTicket.fromJson(const {});
      expect(ticket.status, HelpTicketStatus.unknown);
      expect(ticket.priority, HelpTicketPriority.unknown);
      expect(ticket.messages, isEmpty);
      expect(ticket.message, '');
    });
  });
}
