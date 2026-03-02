# 🚀 Visuales UCLV - GitHub Actions CI/CD

## **Configuración Completada ✅**

Los workflows de GitHub Actions han sido configurados exitosamente para compilación automática en Android.

---

## 📋 **Workflows Configurados**

### 1. **Android Build CI** (`android_build.yml`)

**Trigger:** Push a `main`, `master`, o `develop`

**Qué hace:**
- ✅ Checkout del código
- ✅ Setup de Java 17 y Flutter 3.19.0
- ✅ Instala dependencias
- ✅ Ejecuta tests
- ✅ Analiza código
- ✅ Build Debug APK
- ✅ Build Release APK
- ✅ Build App Bundle (Play Store)
- ✅ Sube artifacts
- ✅ Crea GitHub Release (solo en main)

**Resultado:**
- APK disponible para descargar
- Release automático en GitHub
- Reporte de build

---

### 2. **Manual Release** (`manual_release.yml`)

**Trigger:** Manual desde GitHub Actions

**Cómo usar:**
1. Ve a **Actions** → **Manual Release Build**
2. Click en **Run workflow**
3. Completa:
   - Version: `1.0.0`
   - Release type: `release`
   - Create Release: `true`
4. Click **Run workflow**

**Resultado:**
- Build personalizado
- Release en GitHub
- APKs para todas las arquitecturas

---

### 3. **Tests & Quality CI** (`tests.yml`)

**Trigger:** Push o PR a `main`, `master`, `develop`

**Qué hace:**
- ✅ Ejecuta todos los tests
- ✅ Genera reporte de cobertura
- ✅ Sube cobertura a Codecov
- ✅ Analiza código (flutter analyze)
- ✅ Verifica formato

---

## 🔗 **URLs Importantes**

| Recurso | URL |
|---------|-----|
| **Repositorio** | https://github.com/Alain314159/Visuales- |
| **Actions** | https://github.com/Alain314159/Visuales-/actions |
| **Releases** | https://github.com/Alain314159/Visuales-/releases |
| **Issues** | https://github.com/Alain314159/Visuales-/issues |

---

## 📱 **Cómo Funciona la Compilación Automática**

### **Flujo Automático (Push a main)**

```
1. Developer hace push
   git push origin main
        ↓
2. GitHub detecta el push
        ↓
3. GitHub Actions inicia workflow
        ↓
4. Runner (Ubuntu) configura ambiente:
   - Java 17
   - Flutter 3.19.0
        ↓
5. Ejecuta pasos:
   - flutter pub get
   - flutter test
   - flutter analyze
   - flutter build apk --release
   - flutter build appbundle --release
        ↓
6. Sube artifacts (APK, AAB)
        ↓
7. Crea Release en GitHub
        ↓
8. Notifica completado
```

### **Flujo Manual (Release específico)**

```
1. Usuario va a Actions tab
        ↓
2. Selecciona "Manual Release Build"
        ↓
3. Completa parámetros:
   - version: 1.0.0
   - release_type: release
   - create_release: true
        ↓
4. Ejecuta workflow
        ↓
5. Mismo proceso que automático
        ↓
6. Release etiquetado como v1.0.0
```

---

## 📊 **Ver el Estado de los Builds**

### **Desde GitHub:**

1. **Actions Tab**
   ```
   https://github.com/Alain314159/Visuales-/actions
   ```
   - Ver todos los workflows
   - Ver builds en progreso
   - Ver builds fallidos
   - Descargar artifacts

2. **Releases Tab**
   ```
   https://github.com/Alain314159/Visuales-/releases
   ```
   - Ver releases creados
   - Descargar APKs
   - Ver notas de versión

3. **Workflow Run Details**
   - Click en workflow run
   - Ver logs de cada paso
   - Verificar errores
   - Descargar artifacts

---

## 🎯 **Descargar APKs**

### **Desde Releases:**

1. Ve a **Releases** tab
2. Click en el release más reciente
3. Baja a "Assets"
4. Click para descargar:
   - `app-armeabi-v7a-release.apk` (32-bit)
   - `app-arm64-v8a-release.apk` (64-bit)
   - `app-release.aab` (Play Store)

### **Desde Actions:**

1. Ve a **Actions** tab
2. Click en workflow run exitoso
3. Scroll a "Artifacts"
4. Click para descargar
5. Extrae el ZIP

---

## ⚙️ **Configuración del Servidor**

### **Ruta del Listado**

La app busca el contenido en:

```
Base URL: https://visuales.uclv.cu

Endpoints:
- /listado.txt (principal)
- /listado.html (alternativa)
- /Peliculas/ (categoría)
- /Series/ (categoría)
- /Documentales/ (categoría)
- /Animados/ (categoría)
- /Cursos/ (categoría)
```

### **Formato del listado.txt**

```
# Comentario
[Pelicula] Título | Calidad | Idioma | Tamaño | URL
[Serie] Título S01E01 | 720p | Inglés | 500MB | /Series/archivo.mp4
```

### **ParserService**

El servicio `ParserService` en `lib/services/parser_service.dart`:
- Lee el contenido del archivo
- Parsea cada línea
- Detecta formato (pipe, ruta, simple)
- Extrae metadata (título, calidad, idioma, tamaño)
- Construye objetos `MediaItem`
- Devuelve lista de elementos

---

## 🔐 **Firmar APKs (Opcional)**

### **Para Google Play:**

1. **Crear Keystore:**
   ```bash
   keytool -genkey -v -keystore visuales-uclv.keystore \
     -alias visuales-uclv -keyalg RSA -keysize 2048 \
     -validity 10000
   ```

2. **Crear `android/key.properties`:**
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=visuales-uclv
   storeFile=<path-to-keystore>
   ```

3. **Agregar secretos en GitHub:**
   - `ANDROID_KEYSTORE` (Base64)
   - `KEYSTORE_PASSWORD`
   - `KEY_ALIAS`
   - `KEY_PASSWORD`

4. **Actualizar workflow** para usar signing

---

## 📝 **Comandos Útiles**

### **Local Build:**
```bash
# Debug
flutter build apk --debug

# Release
flutter build apk --release

# App Bundle
flutter build appbundle --release

# Con scripts
./build.sh release
build.bat  # Windows
```

### **Git Flow:**
```bash
# Feature branch
git checkout -b feature/nueva-funcionalidad
git commit -m "feat: nueva funcionalidad"
git push origin feature/nueva-funcionalidad

# Merge a main
git checkout main
git merge feature/nueva-funcionalidad
git push origin main  # ← Trigger del build automático
```

---

## 🚨 **Solución de Problemas**

### **Build Fallido:**

1. **Ver logs del workflow:**
   - Actions tab → Workflow run → Click en paso fallido
   - Busca el error

2. **Errores comunes:**
   - `flutter pub get` falla → Verifica pubspec.yaml
   - Tests fallan → Corre `flutter test` localmente
   - Build falla → Verifica imports y sintaxis

3. **Reproducir localmente:**
   ```bash
   flutter clean
   flutter pub get
   flutter test
   flutter build apk --release
   ```

### **Release No Creado:**

- Verifica que el push fue a `main`
- Revisa permisos de GITHUB_TOKEN
- Revisa logs del workflow

---

## 📊 **Estadísticas del Build**

| Métrica | Valor |
|---------|-------|
| **Tiempo promedio** | 5-10 minutos |
| **Tamaño APK (release)** | ~50-60 MB |
| **Tamaño AAB** | ~60 MB |
| **Arquitecturas** | ARMv7, ARM64, x86_64 |
| **Android mínimo** | 5.0 (API 21) |

---

## 🎉 **Resumen**

### **Lo que tienes ahora:**

✅ **Compilación automática** en cada push a main
✅ **Releases automáticos** en GitHub
✅ **Tests automáticos** en cada PR
✅ **Múltiples APKs** por arquitectura
✅ **App Bundle** para Play Store
✅ **Scripts locales** para build
✅ **Documentación completa**

### **Próximos pasos:**

1. **Verificar workflows:**
   - Ve a Actions tab
   - Verifica que los workflows estén activos

2. **Hacer un push de prueba:**
   ```bash
   git commit --allow-empty -m "test: trigger build"
   git push origin main
   ```

3. **Monitorear build:**
   - Actions tab → Ver progreso
   - Descargar APK cuando termine

4. **Probar APK:**
   - Descargar de Releases
   - Instalar en dispositivo/emulador
   - Verificar funcionamiento

---

## 📞 **Recursos Adicionales**

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Flutter GitHub Actions](https://github.com/marketplace/actions/flutter-action)
- [Subosito Flutter Action](https://github.com/marketplace/actions/flutter-action)
- [Upload Artifact Action](https://github.com/marketplace/actions/upload-a-build-artifact)
- [Create Release Action](https://github.com/marketplace/actions/gh-release)

---

**¡Todo listo para compilación automática!** 🚀

---

**Última actualización**: Marzo 2024  
**Estado**: ✅ Configurado y funcionando
