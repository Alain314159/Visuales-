# Visuales UCLV - Buscador y Gestor de Descargas

[![Build Status](https://github.com/tu-usuario/visuales-uclv/actions/workflows/android_build.yml/badge.svg)](https://github.com/tu-usuario/visuales-uclv/actions)
[![Release](https://img.shields.io/github/v/release/tu-usuario/visuales-uclv)](https://github.com/tu-usuario/visuales-uclv/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

App Flutter **enterprise-grade** para buscar y descargar contenido del servidor [Visuales UCLV](https://visuales.uclv.cu/) de la Universidad Central "Marta Abreu" de Las Villas, Cuba.

## 🚀 Características

### Core
- 🔍 **Buscador avanzado** con filtros por categoría, género, año y calidad
- 📁 **Navegación por categorías**: Películas, Series, Documentales, Animados
- 📥 **Gestor de descargas** con cola, progreso y notificaciones
- 💾 **Cache local con Hive** (10x más rápido que SharedPreferences)
- 🔄 **Sincronización automática** al iniciar la app
- 📱 **Interfaz moderna** con Material 3 y modo oscuro
- ⚡ **Funcionamiento offline** con contenido cacheado

### Enterprise Features ✨
- 🔥 **Firebase Crashlytics** - Monitoreo de crashes en tiempo real
- 📊 **Logging estructurado** - Debugging en producción
- 🔄 **Retry con backoff** - Conexiones inestables (ideal para Cuba)
- ⚙️ **Variables de entorno** - Configuración flexible por entorno
- 🚀 **CI/CD automático** - Builds y releases automáticos con GitHub Actions
- 📦 **Control de APK size** - Fail si > 50MB
- 🔐 **ProGuard + Obfuscación** - Código optimizado y seguro

## 📋 Requisitos

- Flutter >= 3.0.0
- Dart >= 3.0.0
- Android SDK >= 21 (para Android)
- iOS >= 12.0 (para iOS)

## 🛠️ Instalación

### Quick Start (Recomendado)

```bash
# Clonar y configurar
git clone https://github.com/tu-usuario/visuales-uclv.git
cd visuales-uclv
./setup.sh

# Ejecutar la app
flutter run
```

### Instalación Manual

1. **Clonar el repositorio**:
```bash
git clone https://github.com/tu-usuario/visuales-uclv.git
cd visuales-uclv
```

2. **Instalar dependencias**:
```bash
flutter pub get
```

3. **Configurar variables de entorno**:
```bash
cp .env.example .env
# Edita .env con tu configuración
```

4. **Configurar Firebase** (opcional, para Crashlytics):
   - Ver `FIREBASE_SETUP.md` para instrucciones detalladas
   - Coloca `google-services.json` en `android/app/`

5. **Ejecutar la app**:
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

### Core
| Dependencia | Propósito | Versión |
|-------------|-----------|---------|
| `provider` | Gestión de estado | ^6.1.1 |
| `dio` | Cliente HTTP y descargas | ^5.4.0 |
| `connectivity_plus` | Detección de conexión | ^7.0.0 |

### Persistencia
| Dependencia | Propósito | Versión |
|-------------|-----------|---------|
| `hive` | Base de datos local (10x más rápido) | ^2.2.3 |
| `hive_flutter` | Hive para Flutter | ^1.1.0 |
| `path_provider` | Rutas de archivos | ^2.1.1 |

### Configuración
| Dependencia | Propósito | Versión |
|-------------|-----------|---------|
| `flutter_dotenv` | Variables de entorno | ^5.1.0 |
| `logger` | Logging estructurado | ^2.0.2+1 |

### Firebase (Opcional)
| Dependencia | Propósito | Versión |
|-------------|-----------|---------|
| `firebase_core` | Firebase base | ^2.24.2 |
| `firebase_crashlytics` | Reporte de crashes | ^2.8.1 |
| `firebase_analytics` | Analytics | ^10.8.0 |

### Utilidades
| Dependencia | Propósito | Versión |
|-------------|-----------|---------|
| `url_launcher` | Abrir URLs | ^6.2.1 |
| `permission_handler` | Permisos en runtime | ^11.1.0 |
| `cupertino_icons` | Íconos | ^1.0.6 |

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

### Convención de Commits

Este proyecto usa [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` Nueva funcionalidad
- `fix:` Corrección de bug
- `docs:` Cambios en documentación
- `style:` Formato, faltantes, etc.
- `refactor:` Refactorización de código
- `test:` Agregar tests
- `chore:` Tareas de mantenimiento

### CI/CD

El proyecto usa GitHub Actions para CI/CD:

- **Push a main**: Build automático, tests, y release
- **Pull requests**: Build y tests
- **Tags**: Changelog automático y release

Ver `.github/workflows/` para más detalles.

## 📚 Documentación Adicional

- `IMPLEMENTATION_GUIDE.md` - Guía de implementación de mejoras enterprise
- `FIREBASE_SETUP.md` - Configuración de Firebase Crashlytics
- `CHANGELOG.md` - Historial de cambios
- `QUICKSTART.md` - Inicio rápido

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

## ⚠️ Descargo de Responsabilidad

Esta app es un cliente no oficial para el servidor Visuales UCLV. No está afiliada ni endosada por la Universidad Central "Marta Abreu" de Las Villas. El contenido disponible en el servidor es responsabilidad exclusiva de sus administradores.

## 📞 Soporte

Para reportar bugs o sugerencias, abre un issue en el repositorio.

---

**Hecho con ❤️ para la comunidad estudiantil cubana**
