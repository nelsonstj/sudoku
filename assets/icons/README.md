This folder contains the vector app icon `app_icon.svg` and generated PNGs.

To generate PNGs from the SVG (recommended before creating platform launcher icons):

1. Install CairoSVG:

   ```bash
   python -m pip install --upgrade pip
   pip install cairosvg
   ```

2. Run the generator script from the project root:

   ```bash
   python tools/generate_pngs.py
   ```

3. The PNG files will be written to `assets/icons/generated/`.

Generating launcher icons (example using flutter_launcher_icons):

1. Add `flutter_launcher_icons` as a dev dependency and configure `pubspec.yaml`:

   ```yaml
   dev_dependencies:
     flutter_launcher_icons: ^0.10.0

   flutter_icons:
     android: true
     ios: true
     image_path: "assets/icons/generated/app_icon_1024.png"
   ```

2. Run:

   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons:main
   ```

Notes:
- The included `tools/generate_pngs.py` script uses CairoSVG which requires libffi and cairo installed on some platforms. On Windows you can install via `pip` but you might need to install GTK/GTK runtime. See CairoSVG docs.
- If you prefer not to install CairoSVG, you can use any vector editor (Inkscape, Illustrator) to export PNGs at the requested sizes.
