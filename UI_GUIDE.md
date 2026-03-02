# UI Components Guide - Visuales UCLV

## Overview
This guide documents all UI components used in the Visuales UCLV application.

## Color Scheme

### Light Theme
- **Primary**: Blue Accent
- **Secondary**: Blue 300
- **Tertiary**: Teal 200
- **Surface**: White
- **Background**: Grey 100

### Dark Theme
- **Primary**: Blue 400
- **Secondary**: Blue 300
- **Tertiary**: Teal 300
- **Surface**: Grey 900
- **Background**: Grey 900

## Components

### 1. MediaCard
Grid card for displaying media items.

```dart
MediaCard(
  item: mediaItem,
  onTap: () {
    // Navigate to detail
  },
  onDownload: () {
    // Start download
  },
  onFavorite: () {
    // Toggle favorite
  },
)
```

**Features:**
- Aspect ratio: 0.67 (poster format)
- Quality badge overlay
- Type indicator
- Favorite button
- Download button
- Title and metadata

### 2. MediaListTile
List tile for displaying media items in list view.

```dart
MediaListTile(
  item: mediaItem,
  showThumbnail: true,
  showDownloadButton: true,
  onTap: () {},
  onDownload: () {},
  onFavorite: () {},
)
```

**Features:**
- Thumbnail placeholder
- Title (2 lines max)
- Metadata (year, quality, size)
- Description preview
- Favorite and download actions

### 3. CustomSearchBar
Search input with suggestions support.

```dart
CustomSearchBar(
  hintText: 'Buscar...',
  controller: _controller,
  autofocus: false,
  suggestions: searchHistory,
  onChanged: (value) {},
  onSearch: (query) {},
  onClear: () {},
  onSuggestionTap: (suggestion) {},
)
```

**Features:**
- Search icon
- Clear button
- Suggestions dropdown
- Focus border highlight
- Customizable hints

### 4. CategoryChip
Filter chip for categories.

```dart
CategoryChip(
  label: 'Películas',
  icon: Icons.movie,
  isSelected: true,
  color: Colors.blue,
  onTap: () {},
)
```

**Features:**
- Optional icon
- Selected state
- Custom colors
- Material 3 styling

### 5. DownloadProgress
Progress indicator for downloads.

```dart
DownloadProgress(
  task: downloadTask,
  onPause: () {},
  onResume: () {},
  onCancel: () {},
  onRetry: () {},
  showActions: true,
)
```

**Features:**
- Progress bar
- Status icon (queued, downloading, paused, completed, failed)
- Download speed
- Time remaining
- Action buttons (pause, resume, cancel, retry)
- Color-coded status

### 6. LoadingWidget
Loading indicator.

```dart
LoadingWidget(
  message: 'Cargando...',
)
```

**Features:**
- CircularProgressIndicator
- Optional message
- Centered layout

### 7. CustomErrorWidget
Error display with retry option.

```dart
CustomErrorWidget(
  message: 'Error al cargar',
  details: 'Detalles del error',
  onRetry: () {},
  icon: Icons.error_outline,
  showRetry: true,
)
```

**Features:**
- Error icon
- Error message
- Optional details
- Retry button

### 8. EmptyStateWidget
Empty state display.

```dart
EmptyStateWidget(
  message: 'No hay contenido',
  subtitle: 'Intenta sincronizar',
  icon: Icons.inbox_outlined,
  onAction: () {},
  actionLabel: 'Sincronizar',
)
```

**Features:**
- Icon
- Message
- Optional subtitle
- Action button

## Screens

### 1. Splash Screen
- Logo animation
- Fade and scale animations
- Loading indicator
- Auto-navigation after initialization

### 2. Home Screen
- App bar with sync button
- Search bar
- Category filters (horizontal scroll)
- Media grid (2 columns)
- Bottom navigation
- Pull-to-refresh

### 3. Search Screen
- App bar with filter toggle
- Search bar with suggestions
- Expandable filters section
  - Type filter
  - Quality filter
  - Year filter
  - Clear filters button
- Results list
- Empty state

### 4. Category Screen
- App bar with search action
- Media grid
- Pull-to-refresh
- Empty state with sync action

### 5. Detail Screen
- Expanded app bar
- Backdrop with icon
- Action buttons (favorite, share)
- Title and metadata chips
- Genre filters
- Series info (seasons, episodes)
- Description
- Download and open buttons
- Technical info

### 6. Downloads Screen
- App bar with clear completed action
- Sections:
  - In Progress
  - Failed
  - Completed
- Download progress cards
- Empty state

### 7. Settings Screen
- App bar
- Settings sections:
  - Appearance (dark mode, cover images, grid columns)
  - Downloads (WiFi only, auto-retry, concurrent downloads)
  - Synchronization (auto-sync, cache duration)
  - Search (fuzzy search, history limit)
  - About (version, license)
- Clear cache dialog

## Layout Guidelines

### Grid System
- **Columns**: 2 (phone), 4 (tablet)
- **Spacing**: 8px
- **Card aspect ratio**: 0.67

### Spacing
- **Small**: 8px
- **Medium**: 16px
- **Large**: 24px
- **XLarge**: 32px

### Typography
- **Headline Large**: 32px
- **Headline Medium**: 28px
- **Title Large**: 22px
- **Title Medium**: 16px
- **Body Large**: 16px
- **Body Medium**: 14px
- **Body Small**: 12px

### Icon Sizes
- **Small**: 16px
- **Medium**: 24px
- **Large**: 32px
- **XLarge**: 64px

## Animations

### Splash Screen
```dart
Duration: 1500ms
Fade: 0.0 → 1.0
Scale: 0.8 → 1.0
Curve: easeIn / easeOutBack
```

### Page Transitions
```dart
Duration: 300ms
Type: Fade / Slide
```

## Responsive Design

### Breakpoints
- **Phone**: < 600px
- **Tablet**: 600px - 900px
- **Desktop**: > 900px

### Adaptations
- Grid columns adjust based on screen width
- Bottom navigation on phones, rail on tablets
- Expanded app bar on all screens
- Safe area handling for notches

## Accessibility

### Features
- Semantic labels on all interactive elements
- High contrast mode support
- Scalable text
- Screen reader support
- Keyboard navigation

### Best Practices
- Use `Semantics` widget for custom components
- Provide `tooltip` for icon buttons
- Ensure minimum touch target size (48x48)
- Use sufficient color contrast

## Performance Tips

1. **Use const constructors** where possible
2. **Cache widgets** that don't change
3. **Use RepaintBoundary** for expensive widgets
4. **Lazy load** images and lists
5. **Limit rebuilds** with proper state management

## Testing

### Widget Tests
```dart
testWidgets('MediaCard displays title', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MediaCard(item: testItem),
    ),
  );
  expect(find.text('Test Movie'), findsOneWidget);
});
```

### Golden Tests
```dart
testWidgets('MediaCard matches golden', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MediaCard(item: testItem),
    ),
  );
  await expectLater(
    find.byType(MediaCard),
    matchesGoldenFile('media_card.png'),
  );
});
```

---

**Last Updated**: March 2024
**Version**: 1.0.0
