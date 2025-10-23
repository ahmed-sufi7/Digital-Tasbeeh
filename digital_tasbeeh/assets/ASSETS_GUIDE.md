# Digital Tasbeeh Assets Guide

## Folder Structure

```
assets/
├── images/          # App images, backgrounds, logos
├── icons/           # Custom icons and graphics
├── sounds/          # Audio files for feedback
└── ASSETS_GUIDE.md  # This guide
```

## How to Add Assets

### 1. Images
Place your image files in `assets/images/`:
- `logo.png` - App logo
- `background.png` - Background images
- Any other UI graphics

### 2. Icons
Place your custom icons in `assets/icons/`:
- `home.png` - Home navigation icon
- `settings.png` - Settings icon
- `stats.png` - Statistics icon
- Any other custom icons

### 3. Sounds
Place your audio files in `assets/sounds/`:
- `tap.mp3` - Counter tap sound
- `complete.mp3` - Round completion sound
- `notification.mp3` - Alert/notification sound

## Using Assets in Code

### Method 1: Direct Path
```dart
Image.asset('assets/images/logo.png')
AssetImage('assets/icons/home.png')
```

### Method 2: Using AppAssets Helper
```dart
import 'package:digital_tasbeeh/constants/app_assets.dart';

// Predefined assets
Image.asset(AppAssets.logo)
Image.asset(AppAssets.homeIcon)

// Dynamic assets
Image.asset(AppAssets.image('my_image.png'))
Image.asset(AppAssets.icon('my_icon.png'))
```

## Supported Formats

### Images & Icons
- PNG (recommended for icons with transparency)
- JPG (for photos)
- SVG (vector graphics)
- WebP (modern format)

### Audio
- MP3 (recommended, widely supported)
- WAV (uncompressed, larger files)
- AAC (good compression)
- OGG (open source format)

## Best Practices

1. **Naming**: Use lowercase with underscores (e.g., `tap_sound.mp3`)
2. **Size**: Optimize images for mobile (keep file sizes small)
3. **Resolution**: Provide @2x and @3x variants for different screen densities
4. **Audio**: Keep sound files short (< 2 seconds for UI feedback)
5. **Organization**: Group related assets in subfolders if needed

## Example File Structure
```
assets/
├── images/
│   ├── logo.png
│   ├── logo@2x.png
│   ├── logo@3x.png
│   └── background.jpg
├── icons/
│   ├── home.png
│   ├── settings.png
│   └── stats.png
└── sounds/
    ├── tap.mp3
    ├── complete.mp3
    └── notification.mp3
```

## Notes
- All assets are automatically included in the app build
- Assets are configured in `pubspec.yaml`
- Use the `AppAssets` class for type-safe asset references
- Test assets on different devices and screen sizes