# Zyppi app icon

Traced to vector from the bike mark in `assets/icons/appLogo.png`, so it stays sharp at any size.

| File | Size | Use |
| --- | --- | --- |
| `zyppi-mark.svg` | vector | Master artwork — export any size from this |
| `app_icon.png` | 1024 × 1024, white background | Legacy launcher icon / iOS |
| `app_icon_foreground.png` | 1024 × 1024, transparent | Android adaptive icon foreground (mark inside the 66 dp safe zone) |
| `play_store_512.png` | 512 × 512 | Google Play listing icon |

## pubspec.yaml (replace the existing flutter_launcher_icons block)

```yaml
flutter_launcher_icons:
  android: "launcher_icon"
  ios: false
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
  min_sdk_android: 21
```

Then run `fvm dart run flutter_launcher_icons`. Set `ios: true` (and add `remove_alpha_ios: true`) when you build for iOS.
