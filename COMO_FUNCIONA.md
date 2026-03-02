# 📡 Visuales UCLV - Cómo Funciona la App

## 🎯 **Explicación Completa del Funcionamiento**

---

## 1️⃣ **Arquitectura de la App**

```
┌─────────────────────────────────────────────────────────┐
│                    USUARIO                              │
│         (Interfaz Flutter - Pantallas)                  │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                  PROVIDERS                              │
│    (Gestión de Estado - Provider Package)               │
│  • MediaProvider    • SearchProvider                    │
│  • DownloadProvider • SettingsProvider                  │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                   SERVICES                              │
│    (Lógica de Negocio)                                  │
│  • ApiService       • ParserService                     │
│  • SearchService    • DownloadService                   │
│  • CacheService     • SyncService                       │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                    DATA                                 │
│  • Modelos (MediaItem, DownloadTask, etc.)             │
│  • SharedPreferences (Cache)                            │
│  • Servidor Remoto (visuales.uclv.cu)                   │
└─────────────────────────────────────────────────────────┘
```

---

## 2️⃣ **Rutas y Conexión al Servidor**

### **URL Base**

La app se conecta a:
```
https://visuales.uclv.cu
```

### **Archivos que busca la app:**

| Archivo | Ruta | Propósito |
|---------|------|-----------|
| **listado.txt** | `/listado.txt` | Listado principal de contenido |
| **listado.html** | `/listado.html` | Alternativa si no existe .txt |
| **Categorías** | `/Peliculas/` | Películas |
| **Categorías** | `/Series/` | Series de TV |
| **Categorías** | `/Documentales/` | Documentales |
| **Categorías** | `/Animados/` | Animados/Anime |
| **Categorías** | `/Cursos/` | Cursos educativos |

### **Configuración en el código:**

Archivo: `lib/config/constants.dart`

```dart
class Constants {
  // URLs del servidor
  static const String baseUrl = 'https://visuales.uclv.cu';
  static const String listadoUrl = '$baseUrl/listado.txt';
  static const String listadoHtmlUrl = '$baseUrl/listado.html';

  // Rutas de categorías
  static const String rutasPeliculas = '/Peliculas/';
  static const String rutasSeries = '/Series/';
  static const String rutasDocumentales = '/Documentales/';
  static const String rutasAnimados = '/Animados/';
  static const String rutasCursos = '/Cursos/';
}
```

---

## 3️⃣ **Flujo de Funcionamiento**

### **Paso 1: Inicio de la App**

```
┌──────────────────────────────────────┐
│  Splash Screen                       │
│  • Muestra logo animado              │
│  • Inicializa providers              │
│  • Carga configuración               │
└──────────────────────────────────────┘
              ↓ (2 segundos)
┌──────────────────────────────────────┐
│  Carga desde Caché                   │
│  • Lee SharedPreferences             │
│  • Muestra contenido cacheado        │
│  • Permite uso offline               │
└──────────────────────────────────────┘
              ↓
┌──────────────────────────────────────┐
│  Sincronización (si hay internet)    │
│  • Conecta a visuales.uclv.cu        │
│  • Descarga listado.txt              │
│  • Compara con caché                 │
│  • Actualiza si hay cambios          │
└──────────────────────────────────────┘
```

### **Paso 2: Obtención del Listado**

**La app hace lo siguiente:**

1. **Petición HTTP** al servidor:
```
GET https://visuales.uclv.cu/listado.txt
```

2. **Recibe el contenido** (ejemplo):
```
# Listado de contenido - Visuales UCLV
# Actualizado: 2024-01-15

[Pelicula] Avatar 2009 | 1080p | Español | 2.5GB | /Peliculas/Avatar_2009_1080p.mp4
[Pelicula] Inception 2010 | 720p | Inglés | 1.2GB | /Peliculas/Inception_2010_720p.mp4
[Serie] Breaking Bad S01E01 | 1080p | Inglés | 500MB | /Series/Breaking_Bad_S01E01.mp4
[Documental] Planet Earth | 4K | Español | 5GB | /Documentales/Planet_Earth_4K.mp4
[Animado] Spirited Away | 1080p | Japonés | 1.8GB | /Animados/Spirited_Away_1080p.mp4
```

3. **ParserService procesa** cada línea:
```dart
// Formato esperado:
[CATEGORIA] Título | Calidad | Idioma | Tamaño | URL

// Se parsea a:
MediaItem {
  id: "123456",
  title: "Avatar",
  type: MediaType.movie,
  quality: Quality.hd1080,
  language: "Español",
  size: "2.5GB",
  downloadUrl: "/Peliculas/Avatar_2009_1080p.mp4"
}
```

### **Paso 3: Mostrar Contenido**

```
┌──────────────────────────────────────┐
│  Home Screen                         │
│  • AppBar con botón de sync          │
│  • Barra de búsqueda                 │
│  • Chips de categorías               │
│  • Grid de películas/series          │
└──────────────────────────────────────┘
```

### **Paso 4: Búsqueda**

```
Usuario escribe → SearchProvider filtra → Muestra resultados

Filtros disponibles:
  • Tipo (Película, Serie, etc.)
  • Calidad (4K, 1080p, 720p, etc.)
  • Año
  • Género
```

### **Paso 5: Descarga**

```
1. Usuario toca "Descargar"
        ↓
2. DownloadProvider inicia descarga
        ↓
3. DownloadService gestiona:
   • Verifica permisos
   • Obtiene ruta de descarga
   • Inicia descarga en background
   • Muestra progreso
        ↓
4. Archivo guardado en:
   /storage/emulated/0/Download/Visuales/
```

---

## 4️⃣ **ParserService - Cómo interpreta el listado**

### **Formatos que soporta:**

**Formato 1: Pipe (|)**
```
Título | 1080p | Español | 2GB | /ruta/al/archivo.mp4
```

**Formato 2: Ruta**
```
/Peliculas/Avatar_2009_1080p.mp4
```

**Formato 3: Simple**
```
Avatar 2009
```

### **Proceso de parsing:**

```dart
// 1. Divide por líneas
lines = content.split('\n')

// 2. Ignora comentarios y líneas vacías
if (line.startsWith('#') || line.isEmpty) continue

// 3. Detecta formato
if (line.contains('|')) {
  // Parsea formato pipe
  parts = line.split('|')
  title = parts[0]
  quality = parts[1]
  language = parts[2]
  size = parts[3]
}

// 4. Detecta tipo de contenido
if (title.contains('S01E01') || title.contains('Temporada')) {
  type = MediaType.series
} else if (title.contains('Documental')) {
  type = MediaType.documentary
} else {
  type = MediaType.movie
}

// 5. Construye URL completa
downloadUrl = 'https://visuales.uclv.cu' + ruta
```

---

## 5️⃣ **Servicios Principales**

### **ApiService**
```dart
// Conecta al servidor
- fetchListado() → Obtiene listado.txt
- fetchDirectoryIndex() → Obtiene índice de carpeta
- downloadFile() → Descarga archivo
- isConnected() → Verifica conexión
```

### **ParserService**
```dart
// Interpreta el contenido
- parseTxtList() → Parsea listado.txt
- parseHtmlIndex() → Parsea índice HTML
- _parseLine() → Parsea línea individual
```

### **SearchService**
```dart
// Busca y filtra
- search() → Búsqueda por texto
- advancedSearch() → Búsqueda con filtros
- filterByType() → Filtra por tipo
- filterByQuality() → Filtra por calidad
```

### **DownloadService**
```dart
// Gestiona descargas
- startDownload() → Inicia descarga
- pauseDownload() → Pausa descarga
- resumeDownload() → Reanuda descarga
- cancelDownload() → Cancela descarga
```

### **CacheService**
```dart
// Almacena localmente
- saveMediaList() → Guarda en SharedPreferences
- getMediaList() → Obtiene desde caché
- isCacheExpired() → Verifica si caché expiró
```

### **SyncService**
```dart
// Sincroniza contenido
- sync() → Sincronización completa
- syncCategory() → Sincroniza categoría específica
- forceSync() → Fuerza sincronización
```

---

## 6️⃣ **Providers - Gestión de Estado**

### **MediaProvider**
```dart
// Estado del contenido
- mediaItems → Lista completa
- isLoading → Estado de carga
- error → Error actual
- sync() → Sincroniza
- getByType() → Filtra por tipo
```

### **SearchProvider**
```dart
// Estado de búsqueda
- searchResults → Resultados
- isSearching → Buscando
- filterType → Filtro de tipo
- search() → Ejecuta búsqueda
```

### **DownloadProvider**
```dart
// Estado de descargas
- tasks → Todas las tareas
- activeTasks → Tareas activas
- startDownload() → Inicia descarga
- pauseDownload() → Pausa descarga
```

### **SettingsProvider**
```dart
// Configuración
- isDarkMode → Tema oscuro
- autoSyncOnStart → Auto-sync
- gridColumns → Columnas del grid
- setDarkMode() → Cambia tema
```

---

## 7️⃣ **Pantallas (Screens)**

### **SplashScreen**
```
• Animación de logo (1.5s)
• Inicializa providers
• Carga caché
• Navega a Home
```

### **HomeScreen**
```
• AppBar con título y sync
• Barra de búsqueda
• Chips de categorías
• Grid de contenido (2 columnas)
• Bottom navigation
```

### **SearchScreen**
```
• Barra de búsqueda con sugerencias
• Filtros expandibles:
  - Tipo
  - Calidad
  - Año
  - Género
• Lista de resultados
```

### **CategoryScreen**
```
• Título de categoría
• Grid de contenido
• Pull-to-refresh
• Búsqueda en categoría
```

### **DetailScreen**
```
• AppBar expandido
• Ícono/Portada
• Título y metadata
• Descripción
• Botones: Descargar, Abrir
• Información técnica
```

### **DownloadsScreen**
```
• Secciones:
  - En progreso
  - Fallidas
  - Completadas
• Progress bars
• Controles: Pausar, Reanudar, Cancelar
```

### **SettingsScreen**
```
• Apariencia:
  - Modo oscuro
  - Mostrar portadas
  - Columnas
• Descargas:
  - Solo WiFi
  - Reintentar
  - Concurrentes
• Sincronización:
  - Auto-sync
  - Duración caché
• Búsqueda:
  - Fuzzy search
  - Historial
```

---

## 8️⃣ **Flujo Completo de Usuario**

```
1. Usuario abre app
        ↓
2. Splash Screen (2s)
        ↓
3. Carga contenido cacheado
        ↓
4. Muestra Home Screen
        ↓
5. Usuario busca contenido
        ↓
6. Toca en película/serie
        ↓
7. Ve detalles
        ↓
8. Toca "Descargar"
        ↓
9. Descarga inicia
        ↓
10. Progreso mostrado
        ↓
11. Descarga completada
        ↓
12. Archivo en /Download/Visuales/
```

---

## 9️⃣ **Permisos de Android**

La app requiere:

```xml
<!-- Internet -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>

<!-- Almacenamiento (descargas) -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>

<!-- Para Android 13+ -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
```

---

## 🔟 **Estructura de Descargas**

### **Ruta de descarga:**
```
/storage/emulated/0/Download/Visuales/
├── Peliculas/
│   ├── Avatar_2009_1080p.mp4
│   └── Inception_2010_720p.mp4
├── Series/
│   ├── Breaking_Bad_S01E01.mp4
│   └── Breaking_Bad_S01E02.mp4
└── Documentales/
    └── Planet_Earth_4K.mp4
```

---

## 1️⃣1️⃣ **Características Especiales**

### **Modo Offline**
```
• Contenido cacheado disponible sin internet
• Búsquedas funcionan offline
• Descargas pausadas se reanudan al conectar
```

### **Auto-Sync**
```
• Al iniciar la app (configurable)
• Compara hash del contenido
• Solo descarga si hay cambios
• Ahorra datos y tiempo
```

### **Descargas Inteligentes**
```
• Cola de descargas
• Máximo 3 descargas simultáneas
• Reintento automático (configurable)
• Solo WiFi (configurable)
```

### **Búsqueda Fuzzy**
```
• Tolera errores ortográficos
• "Avatr" encuentra "Avatar"
• Umbral de coincidencia: 60%
```

---

## 1️⃣2️⃣ **Resumen Visual**

```
┌──────────────────────────────────────────────────────────┐
│                    FLUJO COMPLETO                        │
└──────────────────────────────────────────────────────────┘

  USUARIO
     ↓
  [Splash Screen] ────→ Inicializa
     ↓
  [Home Screen] ──────→ Muestra contenido
     ↓
  [Search/Category] ──→ Filtra/Búsqueda
     ↓
  [Detail Screen] ────→ Ve información
     ↓
  [Download] ─────────→ Descarga archivo
     ↓
  [Downloads Screen] ─→ Gestiona descargas
     ↓
  [Settings] ─────────→ Configura app
     ↓
  SERVIDOR (visuales.uclv.cu)
     ↓
  /listado.txt ───────→ Lista de contenido
  /Peliculas/ ────────→ Películas
  /Series/ ───────────→ Series
  /Documentales/ ─────→ Documentales
  /Animados/ ─────────→ Animados
  /Cursos/ ───────────→ Cursos
```

---

## 📝 **Preguntas Frecuentes**

### **¿La app funciona sin internet?**
✅ Sí, con contenido cacheado. Pero necesita internet para sincronizar.

### **¿Dónde se guardan las descargas?**
📁 `/storage/emulated/0/Download/Visuales/`

### **¿Puedo cambiar la ruta de descarga?**
🔧 Sí, en Settings → Descargas → Ruta de descarga

### **¿La app descarga automáticamente?**
❌ No, el usuario debe iniciar cada descarga manualmente.

### **¿Funciona en iOS?**
📱 El código está listo, pero necesita configuración de iOS.

### **¿Es oficial de la UCLV?**
❌ No, es un proyecto estudiantil no oficial.

---

## 🎉 **Conclusión**

La app **Visuales UCLV** es un cliente Flutter que:

1. ✅ Se conecta a `https://visuales.uclv.cu`
2. ✅ Lee `/listado.txt` para obtener contenido
3. ✅ Parsea el contenido a objetos MediaItem
4. ✅ Muestra en una interfaz moderna
5. ✅ Permite buscar y filtrar
6. ✅ Descarga archivos al dispositivo
7. ✅ Funciona offline con caché
8. ✅ Se auto-actualiza (sync)

**¡Todo listo para compilar y usar!** 🚀

---

**Última actualización**: Marzo 2024  
**Versión**: 1.0.0
