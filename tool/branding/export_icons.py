#!/usr/bin/env python3
"""Export the shared Icon Composer source; requires Xcode 26+ and Pillow.

Run from any directory: python3 tool/branding/export_icons.py
Apple builds compile AppIcon.icon directly, including older-OS renditions.
The PNG exports are for Android, Flutter's drawer, and macOS's legacy catalog.
"""
import json
import subprocess
import tempfile
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'ios/Runner/AppIcon.icon'
XCODE = Path(subprocess.check_output(['xcode-select', '-p'], text=True).strip()).parent
ICTOOL = XCODE / 'Applications/Icon Composer.app/Contents/Executables/ictool'


def export(destination, platform, size, rendition='Default'):
    subprocess.run([str(ICTOOL), str(SOURCE), '--export-image', '--output-file',
                    str(destination), '--platform', platform, '--rendition', rendition,
                    '--width', str(size), '--height', str(size), '--scale', '1'], check=True)


def resize(source, destination, size):
    with Image.open(source) as image:
        image.resize((size, size), Image.Resampling.LANCZOS).save(destination)


if __name__ == '__main__':
    export(ROOT / 'images/app_icon.png', 'iOS', 1024)
    resize(ROOT / 'images/app_icon.png', ROOT / 'images/app_icon.png', 1024)
    resize(ROOT / 'images/app_icon.png', ROOT / 'images/app_icon_clear.png', 512)
    for density, size in [('mdpi',48), ('hdpi',72), ('xhdpi',96), ('xxhdpi',144), ('xxxhdpi',192)]:
        resize(ROOT / 'images/app_icon.png', ROOT / f'android/app/src/main/res/mipmap-{density}/launcher_icon.png', size)
    with tempfile.TemporaryDirectory() as temporary:
        master = Path(temporary) / 'mac.png'
        export(master, 'macOS', 1024)
        catalog = ROOT / 'macos/Runner/Assets.xcassets/AppIcon.appiconset'
        for entry in json.loads((catalog / 'Contents.json').read_text())['images']:
            size = round(float(entry['size'].split('x')[0]) * float(entry['scale'].removesuffix('x')))
            resize(master, catalog / entry['filename'], size)
    previews = ROOT / 'tool/branding/previews'
    previews.mkdir(exist_ok=True)
    for name, rendition in [('default', 'Default'), ('dark', 'Dark'), ('tinted', 'TintedDark'), ('clear', 'ClearLight')]:
        export(previews / f'{name}.png', 'iOS', 256, rendition)
    print('Exported Flutter, Android, macOS, and appearance previews.')
