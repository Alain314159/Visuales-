import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'services/parser_service.dart';
import 'services/search_service.dart';
import 'services/download_service.dart';
import 'services/cache_service.dart';
import 'services/sync_service.dart';
import 'providers/media_provider.dart';
import 'providers/search_provider.dart';
import 'providers/download_provider.dart';
import 'providers/settings_provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/category_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/downloads_screen.dart';
import 'screens/settings_screen.dart';

/// Aplicación principal
class VisualesApp extends StatelessWidget {
  final SharedPreferences prefs;

  const VisualesApp({
    super.key,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Settings Provider (primero porque otros lo necesitan)
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(prefs: prefs),
        ),
        // API Service
        Provider(
          create: (_) => ApiService(),
        ),
        // Parser Service
        Provider(
          create: (_) => ParserService(),
        ),
        // Cache Service
        Provider(
          create: (_) => CacheService(prefs),
        ),
        // Search Service
        ProxyProvider2<ApiService, CacheService, SearchService>(
          update: (_, apiService, cacheService, __) {
            return SearchService(const []);
          },
        ),
        // Download Service
        Provider(
          create: (_) => DownloadService(),
        ),
        // Sync Service
        ProxyProvider3<ApiService, ParserService, CacheService, SyncService>(
          update: (_, api, parser, cache, __) {
            return SyncService(
              apiService: api,
              parserService: parser,
              cacheService: cache,
            );
          },
        ),
        // Media Provider
        ChangeNotifierProxyProvider2<SyncService, CacheService, MediaProvider>(
          create: (context) => MediaProvider(
            syncService: context.read<SyncService>(),
            cacheService: context.read<CacheService>(),
          ),
          update: (_, sync, cache, previous) {
            return previous ??
                MediaProvider(
                  syncService: sync,
                  cacheService: cache,
                );
          },
        ),
        // Search Provider
        ChangeNotifierProxyProvider2<SearchService, CacheService, SearchProvider>(
          create: (context) => SearchProvider(
            searchService: context.read<SearchService>(),
            cacheService: context.read<CacheService>(),
          ),
          update: (_, search, cache, previous) {
            return previous ??
                SearchProvider(
                  searchService: search,
                  cacheService: cache,
                );
          },
        ),
        // Download Provider
        ChangeNotifierProxyProvider<DownloadService, DownloadProvider>(
          create: (context) {
            final provider = DownloadProvider(
              downloadService: context.read<DownloadService>(),
            );
            // Initialize download provider
            provider.initialize();
            return provider;
          },
          update: (_, download, previous) {
            return previous ??
                DownloadProvider(
                  downloadService: download,
                );
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'Visuales UCLV',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settingsProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case AppRoutes.splash:
                  return MaterialPageRoute(
                    builder: (_) => const SplashScreen(),
                  );
                case AppRoutes.home:
                  return MaterialPageRoute(
                    builder: (_) => const HomeScreen(),
                  );
                case AppRoutes.search:
                  final query = settings.arguments as String?;
                  return MaterialPageRoute(
                    builder: (_) => SearchScreen(initialQuery: query),
                  );
                case AppRoutes.category:
                  final category = settings.arguments as String;
                  return MaterialPageRoute(
                    builder: (_) => CategoryScreen(categoryName: category),
                  );
                case AppRoutes.detail:
                  final mediaId = settings.arguments as String;
                  return MaterialPageRoute(
                    builder: (_) => DetailScreen(mediaId: mediaId),
                  );
                case AppRoutes.downloads:
                  return MaterialPageRoute(
                    builder: (_) => const DownloadsScreen(),
                  );
                case AppRoutes.settings:
                  return MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  );
                default:
                  return MaterialPageRoute(
                    builder: (_) => const SplashScreen(),
                  );
              }
            },
          );
        },
      ),
    );
  }
}
