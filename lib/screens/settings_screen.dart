import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../providers/settings_provider.dart';

/// Pantalla de configuración
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        children: [
          // Sección: Apariencia
          _buildSectionHeader(theme, 'Apariencia'),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return SwitchListTile(
                title: const Text('Modo oscuro'),
                subtitle: const Text('Usar tema oscuro'),
                value: settings.isDarkMode,
                onChanged: (value) {
                  settings.setDarkMode(value);
                  // Actualizar tema de la app
                  // Esto se maneja en app.dart
                },
                secondary: Icon(
                  settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
              );
            },
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return SwitchListTile(
                title: const Text('Mostrar portadas'),
                subtitle: const Text('Mostrar imágenes de portada'),
                value: settings.showCoverImages,
                onChanged: (value) {
                  settings.setShowCoverImages(value);
                },
                secondary: const Icon(Icons.image),
              );
            },
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return ListTile(
                leading: const Icon(Icons.grid_on),
                title: const Text('Columnas de cuadrícula'),
                subtitle: Text('${settings.gridColumns} columnas'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (settings.gridColumns > 1) {
                          settings.setGridColumns(settings.gridColumns - 1);
                        }
                      },
                    ),
                    Text('${settings.gridColumns}'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (settings.gridColumns < 4) {
                          settings.setGridColumns(settings.gridColumns + 1);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),

          // Sección: Descargas
          _buildSectionHeader(theme, 'Descargas'),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return SwitchListTile(
                title: const Text('Solo WiFi'),
                subtitle: const Text('Descargar solo cuando esté conectado a WiFi'),
                value: settings.wifiOnly,
                onChanged: (value) {
                  settings.setWifiOnly(value);
                },
                secondary: const Icon(Icons.wifi),
              );
            },
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return SwitchListTile(
                title: const Text('Reintentar automáticamente'),
                subtitle: const Text('Reintentar descargas fallidas'),
                value: settings.autoRetry,
                onChanged: (value) {
                  settings.setAutoRetry(value);
                },
                secondary: const Icon(Icons.autorenew),
              );
            },
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Descargas simultáneas'),
                subtitle: Text('${settings.maxConcurrentDownloads} descargas'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (settings.maxConcurrentDownloads > 1) {
                          settings.setMaxConcurrentDownloads(settings.maxConcurrentDownloads - 1);
                        }
                      },
                    ),
                    Text('${settings.maxConcurrentDownloads}'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (settings.maxConcurrentDownloads < 5) {
                          settings.setMaxConcurrentDownloads(settings.maxConcurrentDownloads + 1);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Máximo de reintentos'),
                subtitle: Text('${settings.maxRetries} reintentos'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (settings.maxRetries > 0) {
                          settings.setMaxRetries(settings.maxRetries - 1);
                        }
                      },
                    ),
                    Text('${settings.maxRetries}'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (settings.maxRetries < 5) {
                          settings.setMaxRetries(settings.maxRetries + 1);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),

          // Sección: Sincronización
          _buildSectionHeader(theme, 'Sincronización'),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return SwitchListTile(
                title: const Text('Sincronizar al iniciar'),
                subtitle: const Text('Actualizar contenido al abrir la app'),
                value: settings.autoSyncOnStart,
                onChanged: (value) {
                  settings.setAutoSyncOnStart(value);
                },
                secondary: const Icon(Icons.sync),
              );
            },
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Duración de caché'),
                subtitle: Text('${settings.cacheDurationHours} horas'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (settings.cacheDurationHours > 1) {
                          settings.setCacheDurationHours(settings.cacheDurationHours - 1);
                        }
                      },
                    ),
                    Text('${settings.cacheDurationHours}h'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (settings.cacheDurationHours < 72) {
                          settings.setCacheDurationHours(settings.cacheDurationHours + 1);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Limpiar caché', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Eliminar datos cacheados'),
            onTap: () {
              _showClearCacheDialog(context);
            },
          ),
          const Divider(),

          // Sección: Búsqueda
          _buildSectionHeader(theme, 'Búsqueda'),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return SwitchListTile(
                title: const Text('Búsqueda fuzzy'),
                subtitle: const Text('Permitir errores ortográficos'),
                value: settings.enableFuzzySearch,
                onChanged: (value) {
                  settings.setEnableFuzzySearch(value);
                },
                secondary: const Icon(Icons.search),
              );
            },
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Historial de búsquedas'),
                subtitle: Text('Máximo ${settings.searchHistoryLimit} elementos'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (settings.searchHistoryLimit > 5) {
                          settings.setSearchHistoryLimit(settings.searchHistoryLimit - 1);
                        }
                      },
                    ),
                    Text('${settings.searchHistoryLimit}'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (settings.searchHistoryLimit < 50) {
                          settings.setSearchHistoryLimit(settings.searchHistoryLimit + 1);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),

          // Sección: Acerca de
          _buildSectionHeader(theme, 'Acerca de'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Versión'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Licencia'),
            subtitle: const Text('MIT'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar caché'),
        content: const Text('¿Estás seguro de que deseas eliminar todos los datos cacheados? Se volverá a sincronizar el contenido.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<MediaProvider>().forceSync();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Caché eliminada'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
