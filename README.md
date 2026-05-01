# SRT Converter

Native macOS app for converting subtitle `.txt` files to `.srt`.

## Features

- Convert one or several `.txt` files at once
- Drag and drop files, or select them from the app
- French and English interface
- Reads TXT files encoded as UTF-8, UTF-16, Windows-1252, or ISO Latin 1
- Creates `.srt` files in the same folder as the original files
- Standalone app with no extra user dependency
- Compatible with macOS 11 or newer

## Installation

1. Download the latest `.zip` archive from GitHub Releases.
2. Unzip the archive.
3. Drag `SRT Converter.app` into the `Applications` folder.
4. On first launch, if macOS blocks the app, right-click `SRT Converter`, then choose `Open`.

You can also run the app directly from the extracted folder.

## Usage

1. Open `SRT Converter`.
2. Drag one or several `.txt` files into the center drop zone, or click it to select files.
3. Click `Convert to SRT` / `Convertir en SRT`.
4. The `.srt` files are created next to the original `.txt` files.

## Supported Format

Input `.txt`:

```txt
00:00:01:14 - 00:00:03:13
Subtitle text
```

Output `.srt`:

```srt
1
00:00:01,560 --> 00:00:03,520
Subtitle text
```

The app also accepts existing SRT-style timecodes written with `-->`.

## Build

To recreate the app from source:

```bash
./build.sh
```

The generated app is available at `build/SRT Converter.app`.

## Version

Current version: `1.1.0`

## Changelog

### 1.1.0 - 2026-05-01

- Added the new macOS icon correctly inside the app.
- Provided the macOS release with the final app and README.
- Improved TXT reading for files exported with different encodings.
