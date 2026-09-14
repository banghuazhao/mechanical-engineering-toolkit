# App identity

The editable master is `ios/Runner/AppIcon.icon`. Both the iOS and macOS Xcode
projects compile this same document using **Xcode 26 or later**. Xcode generates
the runtime Liquid Glass appearances and the static renditions for earlier OS
versions. Keep the app icon build setting named `AppIcon`.

The icon uses the app's bronze palette, a frosted eight-tooth precision gear,
and a separate hexagonal hub. Its SVG layers contain no baked shadows, blur,
mask, or glass highlights. Icon Composer supplies those effects and adapts the
same silhouette to default, dark, tinted, and clear appearances.

To edit the design, open the `.icon` document in Icon Composer. To regenerate
Android launcher PNGs, the Flutter drawer image, and the macOS legacy catalog:

```sh
python3 tool/branding/export_icons.py
```

This requires the selected Xcode installation to include Icon Composer and
Python to have Pillow installed. Apple targets use the native document, not the
rounded PNG preview; do not regenerate an iOS AppIcon asset catalog with
`flutter_launcher_icons`. Keep the source in the Resources phase of both targets.

The iOS launch storyboard uses `LaunchSurface`, which follows the system light
or dark appearance and matches `AppTheme`'s `#FFFBF8` / `#171210` surfaces.
Android uses the same colors and its standard Android 12+ launcher-icon splash.
A native launch screen cannot read Flutter's saved theme override; that takes
effect when Flutter draws its first frame.

Design references:
- https://developer.apple.com/documentation/xcode/creating-your-app-icon-using-icon-composer
- https://developer.apple.com/design/human-interface-guidelines/app-icons
- https://developer.apple.com/design/human-interface-guidelines/launching
