# 🔥 Configuración de Firebase

Este documento explica cómo configurar Firebase para Crashlytics y Analytics.

## Pasos de Configuración

### 1. Crear Proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Click en "Add project" o "Crear proyecto"
3. Ingresa el nombre: **Visuales UCLV**
4. Desactiva Google Analytics (opcional, ya usamos firebase_analytics)
5. Click en "Create project"

### 2. Agregar App Android

1. En el Dashboard de Firebase, click en "Add app" → Android
2. Ingresa el **Package name**: `com.visuales.uclv.visuales_uclv`
   - Para verificar tu package name actual:
     ```bash
     grep "^namespace" android/app/build.gradle
     ```
3. Ingresa el "App nickname": Visuales UCLV
4. **NO descargues el google-services.json todavía**

### 3. Configurar google-services.json

#### Opción A: Manual (Recomendada para desarrollo)

1. Descarga el `google-services.json` desde Firebase Console
2. Colócalo en: `android/app/google-services.json`
3. **IMPORTANTE**: No subas este archivo al repositorio público

#### Opción B: Usando Variables de Entorno (CI/CD)

Para CI/CD, usa secrets en lugar del archivo:

```yaml
# En tu workflow de GitHub Actions
- name: Setup Firebase
  run: |
    echo "${{ secrets.FIREBASE_GOOGLE_SERVICES_JSON }}" | base64 -d > android/app/google-services.json
```

### 4. Actualizar build.gradle (Android)

El archivo `android/build.gradle` ya debe tener:

```gradle
buildscript {
    dependencies {
        // Agregar esto si no existe
        classpath 'com.google.gms:google-services:4.4.0'
        classpath 'com.google.firebase:firebase-crashlytics-gradle:2.9.9'
    }
}
```

El archivo `android/app/build.gradle` ya debe tener:

```gradle
plugins {
    id "com.android.application"
    id "dev.flutter.flutter-gradle-plugin"
    id "com.google.gms.google-services"  // ← Agregar esto
    id "com.google.firebase.crashlytics" // ← Agregar esto
}
```

### 5. Habilitar Crashlytics

1. En Firebase Console, ve a "Crashlytics"
2. Click en "Get started"
3. Sigue los pasos (ya completamos la mayoría)

### 6. Verificar Instalación

Ejecuta la app en modo debug:

```bash
flutter run
```

En Firebase Console → Crashlytics, deberías ver tu app registrada después de unos minutos.

### 7. Configurar para Producción

Para habilitar Crashlytics en producción:

1. Build release:
   ```bash
   flutter build apk --release
   ```

2. Sube los símbolos de debug (mapping.txt):
   ```bash
   # Los símbolos se generan automáticamente en:
   # build/app/outputs/mapping/release/
   ```

## 🔧 Solución de Problemas

### Error: "google-services.json not found"

```bash
# Verifica que el archivo existe
ls android/app/google-services.json

# Si no existe, descárgalo de Firebase Console
```

### Error: "Package name mismatch"

Verifica el package name en:
- `android/app/build.gradle` → `namespace`
- `android/app/src/main/AndroidManifest.xml` → `package`
- Firebase Console → Tu app

### Crashlytics no reporta errores

1. Verifica que `ENABLE_CRASHLYTICS=true` en `.env`
2. Espera 24-48 horas para que aparezcan los primeros reportes
3. Para testing, fuerza un crash:
   ```dart
   throw Exception("Test Crash");
   ```

## 📊 Usando Crashlytics

### Reportar errores no fatales

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

try {
  // Tu código
} catch (error, stackTrace) {
  await FirebaseCrashlytics.instance.recordError(
    error,
    stackTrace,
    reason: 'Error capturado manualmente',
  );
}
```

### Agregar logs personalizados

```dart
await FirebaseCrashlytics.instance.log('Usuario inició sesión');
await FirebaseCrashlytics.instance.setCustomKey('user_id', '12345');
```

### Identificar usuarios

```dart
await FirebaseCrashlytics.instance.setUserIdentifier('user_123');
```

## 🔐 Seguridad

**NUNCA subas al repositorio:**
- `google-services.json` con tus keys reales
- `firebase_options.dart` con credentials

Usa `.gitignore` para excluirlos:

```
# Firebase
**/google-services.json
**/firebase_options.dart
```

## 📚 Recursos

- [Firebase Crashlytics Docs](https://firebase.google.com/docs/crashlytics)
- [Firebase Analytics Docs](https://firebase.google.com/docs/analytics)
- [Flutter Firebase Plugin](https://pub.dev/packages/firebase_core)

---

**Hecho con ❤️ para la comunidad estudiantil cubana**
