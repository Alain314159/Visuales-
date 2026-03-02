import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../providers/download_provider.dart';
import '../models/enums.dart';
import '../config/routes.dart';
import '../widgets/media_card.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';

/// Pantalla de categoría
class CategoryScreen extends StatelessWidget {
  final String categoryName;

  const CategoryScreen({
    super.key,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = MediaTypeExtension.fromString(categoryName);

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.search,
                arguments: '',
              );
            },
          ),
        ],
      ),
      body: Consumer<MediaProvider>(
        builder: (context, mediaProvider, child) {
          if (mediaProvider.isLoading && mediaProvider.mediaItems.isEmpty) {
            return const LoadingWidget(message: 'Cargando...');
          }

          final items = mediaProvider.getByType(type);

          if (items.isEmpty) {
            return EmptyStateWidget(
              message: 'No hay contenido en esta categoría',
              subtitle: 'El contenido se cargará cuando sincronices',
              icon: Icons.folder_open,
              onAction: () {
                mediaProvider.sync();
              },
              actionLabel: 'Sincronizar',
            );
          }

          return RefreshIndicator(
            onRefresh: () => mediaProvider.sync(),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return MediaCard(
                    item: item,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.detail,
                        arguments: item.id,
                      );
                    },
                    onDownload: () {
                      context.read<DownloadProvider>().startDownload(item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Descargando: ${item.title}'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
