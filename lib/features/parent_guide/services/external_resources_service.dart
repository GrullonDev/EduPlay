// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';

/// One curated RSS/Atom source. Editing this list is the only "content
/// maintenance" this feature needs — no CMS, no admin panel, no app release:
/// whatever the source publishes next shows up in the app on the next load.
class ArticleFeedSource {
  const ArticleFeedSource({
    required this.feedUrl,
    required this.sourceName,
    required this.subject,
    required this.color,
  });

  /// Public RSS feed URL — verified reachable and parseable before adding.
  final String feedUrl;

  /// Shown as the article's attribution (RSS is meant to be redisplayed with
  /// a link back to the source — this is that link's label).
  final String sourceName;

  /// Subject badge shown on the resource tile (e.g. 'CRIANZA').
  final String subject;
  final Color color;
}

const kArticleFeedSources = <ArticleFeedSource>[
  ArticleFeedSource(
    feedUrl: 'https://www.serpadres.es/feed/',
    sourceName: 'Ser Padres',
    subject: 'CRIANZA',
    color: Color(0xFF8E44AD),
  ),
  ArticleFeedSource(
    feedUrl: 'https://www.educaciontrespuntocero.com/feed/',
    sourceName: 'Educación 3.0',
    subject: 'EDUCACIÓN',
    color: Color(0xFF3498DB),
  ),
];

class ExternalArticle {
  const ExternalArticle({
    required this.title,
    required this.summary,
    required this.url,
    required this.sourceName,
    required this.subject,
    required this.color,
    this.publishedAt,
  });

  final String title;
  final String summary;
  final String url;
  final String sourceName;
  final String subject;
  final Color color;
  final DateTime? publishedAt;
}

/// Pulls real, ever-changing article content from public RSS feeds — no
/// backend, no stored copies, no API key. A feed that's slow or briefly
/// down never breaks the page: it's just skipped for that load.
class ExternalResourcesService {
  static Future<List<ExternalArticle>> fetchArticles({
    int perFeedLimit = 6,
  }) async {
    final perSource = await Future.wait(
      kArticleFeedSources.map((s) => _fetchFeed(s, perFeedLimit)),
    );
    final articles = perSource.expand((x) => x).toList()
      ..sort((a, b) {
        final ap = a.publishedAt;
        final bp = b.publishedAt;
        if (ap == null && bp == null) return 0;
        if (ap == null) return 1;
        if (bp == null) return -1;
        return bp.compareTo(ap);
      });
    return articles;
  }

  static Future<List<ExternalArticle>> _fetchFeed(
    ArticleFeedSource source,
    int limit,
  ) async {
    try {
      final response = await http
          .get(Uri.parse(source.feedUrl))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return const [];

      final feed = RssFeed.parse(response.body);
      return (feed.items ?? const [])
          .take(limit)
          .map((item) {
            final title = item.title?.trim() ?? '';
            final link = item.link?.trim() ?? '';
            if (title.isEmpty || link.isEmpty) return null;
            return ExternalArticle(
              title: title,
              summary: _stripHtml(item.description ?? ''),
              url: link,
              sourceName: source.sourceName,
              subject: source.subject,
              color: source.color,
              publishedAt: item.pubDate,
            );
          })
          .whereType<ExternalArticle>()
          .toList();
    } catch (_) {
      // Network hiccup or unexpected markup on one feed — the rest of the
      // page (and the other feeds) should still work.
      return const [];
    }
  }

  static final _tagRegExp = RegExp(r'<[^>]*>');
  static final _whitespaceRegExp = RegExp(r'\s+');

  static String _stripHtml(String input) {
    final withoutTags = input.replaceAll(_tagRegExp, ' ');
    final decoded = withoutTags
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#8217;', '’')
        .replaceAll('&#8220;', '“')
        .replaceAll('&#8221;', '”');
    return decoded.replaceAll(_whitespaceRegExp, ' ').trim();
  }
}
