import 'package:flutter_test/flutter_test.dart';
import 'package:visuales_uclv/models/media_item.dart';
import 'package:visuales_uclv/models/enums.dart';
import 'package:visuales_uclv/models/download_task.dart';
import 'package:visuales_uclv/services/parser_service.dart';
import 'package:visuales_uclv/services/search_service.dart';

void main() {
  group('MediaItem Tests', () {
    test('MediaItem creation', () {
      const item = MediaItem(
        id: '1',
        title: 'Test Movie',
        type: MediaType.movie,
        downloadUrl: 'http://example.com/movie.mp4',
        year: 2023,
        quality: Quality.hd1080,
      );

      expect(item.id, '1');
      expect(item.title, 'Test Movie');
      expect(item.type, MediaType.movie);
      expect(item.year, 2023);
      expect(item.quality, Quality.hd1080);
    });

    test('MediaItem toJson and fromJson', () {
      const item = MediaItem(
        id: '1',
        title: 'Test Movie',
        type: MediaType.movie,
        downloadUrl: 'http://example.com/movie.mp4',
      );

      final json = item.toJson();
      final fromJson = MediaItem.fromJson(json);

      expect(fromJson.id, item.id);
      expect(fromJson.title, item.title);
      expect(fromJson.type, item.type);
    });
  });

  group('MediaType Tests', () {
    test('MediaTypeExtension fromString', () {
      expect(MediaTypeExtension.fromString('pelicula'), MediaType.movie);
      expect(MediaTypeExtension.fromString('serie'), MediaType.series);
      expect(
          MediaTypeExtension.fromString('documental'), MediaType.documentary);
      expect(MediaTypeExtension.fromString('animado'), MediaType.animated);
      expect(MediaTypeExtension.fromString('curso'), MediaType.course);
      expect(MediaTypeExtension.fromString('unknown'), MediaType.other);
    });

    test('MediaTypeExtension value', () {
      expect(MediaType.movie.value, 'Pelicula');
      expect(MediaType.series.value, 'Serie');
      expect(MediaType.documentary.value, 'Documental');
      expect(MediaType.animated.value, 'Animado');
      expect(MediaType.course.value, 'Curso');
      expect(MediaType.other.value, 'Otro');
    });
  });

  group('Quality Tests', () {
    test('QualityExtension fromString', () {
      expect(QualityExtension.fromString('1080p'), Quality.hd1080);
      expect(QualityExtension.fromString('720p'), Quality.hd720);
      expect(QualityExtension.fromString('4K'), Quality.hd4k);
      expect(QualityExtension.fromString('480p'), Quality.sd480);
      expect(QualityExtension.fromString('unknown'), Quality.unknown);
    });

    test('QualityExtension value', () {
      expect(Quality.hd4k.value, '4K');
      expect(Quality.hd1080.value, '1080p');
      expect(Quality.hd720.value, '720p');
      expect(Quality.sd480.value, '480p');
      expect(Quality.sd360.value, '360p');
      expect(Quality.unknown.value, 'Unknown');
    });
  });

  group('ParserService Tests', () {
    test('parseTxtList empty content', () {
      final parser = ParserService();
      final result = parser.parseTxtList('');
      expect(result, isEmpty);
    });

    test('parseTxtList with comments', () {
      final parser = ParserService();
      final content = '''
# This is a comment
Movie 2023 | 1080p | Spanish | 2GB
# Another comment
''';
      final result = parser.parseTxtList(content);
      expect(result.length, greaterThan(0));
    });

    test('parseTxtList with pipe format', () {
      final parser = ParserService();
      final content = 'Test Movie | 1080p | English | 1.5GB';
      final result = parser.parseTxtList(content);

      expect(result.length, 1);
      expect(result.first.title, contains('Test Movie'));
      expect(result.first.quality, Quality.hd1080);
      expect(result.first.language, 'English');
      expect(result.first.size, '1.5GB');
    });
  });

  group('SearchService Tests', () {
    test('SearchService initialization', () {
      final items = <MediaItem>[];
      final service = SearchService(items);
      expect(service, isNotNull);
    });

    test('SearchService with sample data', () {
      final items = [
        const MediaItem(
          id: '1',
          title: 'Test Movie',
          type: MediaType.movie,
          downloadUrl: 'http://example.com/movie.mp4',
        ),
        const MediaItem(
          id: '2',
          title: 'Test Series',
          type: MediaType.series,
          downloadUrl: 'http://example.com/series.mp4',
        ),
      ];

      final service = SearchService(items);
      final results = service.search('Test');

      expect(results.length, 2);
    });

    test('SearchService filter by type', () {
      final items = [
        const MediaItem(
          id: '1',
          title: 'Movie 1',
          type: MediaType.movie,
          downloadUrl: 'http://example.com/movie1.mp4',
        ),
        const MediaItem(
          id: '2',
          title: 'Series 1',
          type: MediaType.series,
          downloadUrl: 'http://example.com/series1.mp4',
        ),
      ];

      final service = SearchService(items);
      final movies = service.filterByType(MediaType.movie);
      final series = service.filterByType(MediaType.series);

      expect(movies.length, 1);
      expect(series.length, 1);
      expect(movies.first.type, MediaType.movie);
      expect(series.first.type, MediaType.series);
    });
  });

  group('DownloadTask Tests', () {
    test('DownloadTask creation', () {
      const media = MediaItem(
        id: '1',
        title: 'Test Download',
        type: MediaType.movie,
        downloadUrl: 'http://example.com/file.mp4',
      );

      final task = DownloadTask(
        id: '1',
        media: media,
        savePath: '/downloads',
        startTime: DateTime.now(),
      );

      expect(task.id, '1');
      expect(task.media.title, 'Test Download');
      expect(task.status, DownloadStatus.queued);
      expect(task.progress, 0.0);
    });

    test('DownloadTask progress calculation', () {
      const media = MediaItem(
        id: '1',
        title: 'Test',
        type: MediaType.movie,
        downloadUrl: 'http://example.com/file.mp4',
      );

      final task = DownloadTask(
        id: '1',
        media: media,
        savePath: '/downloads',
        totalBytes: 1000,
        downloadedBytes: 500,
        startTime: DateTime.now(),
      );

      expect(task.progress, 0.5);
      expect(task.progressPercent, 50);
    });

    test('DownloadTask format bytes', () {
      expect(
          DownloadTask(
            id: '1',
            media: const MediaItem(
              id: '1',
              title: 'Test',
              type: MediaType.movie,
              downloadUrl: 'http://example.com/file.mp4',
            ),
            savePath: '/downloads',
            startTime: DateTime.now(),
          ).downloadedFormatted,
          '0 B');
    });
  });
}
