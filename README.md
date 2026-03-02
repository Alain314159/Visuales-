# Visuales UCLV - Buscador y Gestor de Descargas

App Flutter para buscar y descargar contenido del servidor [Visuales UCLV](https://visuales.uclv.cu/) de la Universidad Central "Marta Abreu" de Las Villas, Cuba.

## 🚀 Características

- 🔍 **Buscador avanzado** con filtros por categoría, género, año y calidad
- 📁 **Navegación por categorías**: Películas, Series, Documentales, Animados
- 📥 **Gestor de descargas** con cola, progreso y notificaciones
- 💾 **Cache local** del listado de contenido
- 🔄 **Sincronización automática** al iniciar la app
- 📱 **Interfaz moderna** con Material 3 y modo oscuro
- ⚡ **Funcionamiento offline** con contenido cacheado

## 📋 Requisitos

- Flutter >= 3.0.0
- Dart >= 3.0.0
- Android SDK >= 21 (para Android)
- iOS >= 12.0 (para iOS)

## 🛠️ Instalación

1. Clonar el repositorio:
```bash
git clone https://github.com/tu-usuario/visuales-uclv.git
cd visuales-uclv
```

2. Instalar dependencias:
```bash
flutter pub get
```

3. Configurar permisos (Android):
   - Los permisos ya están configurados en `android/app/src/main/AndroidManifest.xml`

4. Ejecutar la app:
```bash
flutter run
```

## 🚀 Build Rápido

### Linux/macOS
```bash
# Configurar y construir
./build.sh setup
./build.sh release

# O todo en uno
./build.sh all
```

### Windows
```bash
# Ejecutar script de build
build.bat
```

### Comandos Disponibles
```bash
./build.sh setup      # Verificar Flutter e instalar dependencias
./build.sh test       # Ejecutar tests
./build.sh analyze    # Analizar código
./build.sh clean      # Limpiar build
./build.sh debug      # Build debug APK
./build.sh release    # Build release APK
./build.sh bundle     # Build app bundle (Play Store)
./build.sh run        # Ejecutar app
./build.sh all        # Build completo (todo en uno)
```

## 🏗️ Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada
├── app.dart                  # Configuración de la app
├── config/                   # Configuraciones
│   ├── constants.dart
│   ├── theme.dart
│   └── routes.dart
├── models/                   # Modelos de datos
│   ├── media_item.dart
│   ├── category.dart
│   ├── download_task.dart
│   └── search_result.dart
├── services/                 # Servicios y lógica de negocio
│   ├── api_service.dart
│   ├── parser_service.dart
│   ├── search_service.dart
│   ├── download_service.dart
│   └── cache_service.dart
├── providers/                # Gestión de estado
│   ├── media_provider.dart
│   ├── search_provider.dart
│   ├── download_provider.dart
│   └── settings_provider.dart
├── screens/                  # Pantallas
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── search_screen.dart
│   ├── category_screen.dart
│   ├── detail_screen.dart
│   ├── downloads_screen.dart
│   └── settings_screen.dart
├── widgets/                  # Widgets reutilizables
│   ├── media_card.dart
│   ├── media_list_tile.dart
│   ├── download_progress.dart
│   └── custom_search_bar.dart
└── utils/                    # Utilidades
    ├── extensions.dart
    └── helpers.dart
```

## 📦 Dependencias Principales

| Dependencia | Propósito |
|-------------|-----------|
| `provider` | Gestión de estado |
| `dio` | Cliente HTTP y descargas |
| `hive` | Base de datos local |
| `cached_network_image` | Cache de imágenes |
| `flutter_downloader` | Descargas en background |
| `connectivity_plus` | Detección de conexión |

## 🔧 Configuración de Descargas

La app usa `flutter_downloader` para gestionar descargas. En Android, las descargas se guardan en:
```
/storage/emulated/0/Download/Visuales/
```

## 🎨 Personalización

Puedes personalizar la app editando:
- `lib/config/theme.dart` - Colores y tema
- `lib/config/constants.dart` - URLs y configuración del servidor

## 🧪 Tests

Ejecutar tests unitarios:
```bash
flutter test
```

Ejecutar tests de integración:
```bash
flutter test integration_test/
```

## 📱 Builds

### Debug APK
```bash
flutter build apk --debug
```

### Release APK
```bash
flutter build apk --release
```

### App Bundle (Play Store)
```bash
flutter build appbundle --release
```

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'feat: añade nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

## ⚠️ Descargo de Responsabilidad

Esta app es un cliente no oficial para el servidor Visuales UCLV. No está afiliada ni endosada por la Universidad Central "Marta Abreu" de Las Villas. El contenido disponible en el servidor es responsabilidad exclusiva de sus administradores.

## 📞 Soporte

Para reportar bugs o sugerencias, abre un issue en el repositorio.

---

Hecho con ❤️ para la comunidad estudiantil cubana
