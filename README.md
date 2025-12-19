# SRT Converter - Native macOS Application

## ✅ Project Status: COMPLETE & FUNCTIONAL

A fully native macOS Swift application for converting subtitle files from TXT format to SRT format.

## 📁 Project Structure

```
TXT_to_SRT_Native/
├── TXT_to_SRT/              # Source code
│   ├── main.swift           # App entry point
│   ├── AppDelegate.swift    # Application lifecycle
│   ├── ViewController.swift # Main UI and logic
│   ├── DropZoneView.swift   # Drag-and-drop functionality
│   ├── SubtitleConverter.swift # Conversion engine
│   └── Localizable.swift    # Multi-language support (EN/FR)
├── build/                   # Compiled application
│   └── SRT Converter.app    # Ready-to-use app
└── build.sh                 # Build script
```

## ✨ Features

- **Multi-file batch conversion** - Process multiple files at once
- **Smart format detection** - Handles both TXT and SRT formats
- **Windows/Unix line endings** - Automatically normalizes `\r\n` and `\n`
- **Multi-language UI** - English (default) and French
- **Modern dark UI** - Glassmorphism design with vibrant colors
- **Drag-and-drop** - Easy file selection
- **Standalone** - No dependencies, ~2 MB

## 🚀 Usage

1. **Run the app**: Double-click `build/SRT Converter.app`
2. **Select files**: Drag TXT files or click to browse
3. **Convert**: Click the green "Convert to SRT" button
4. **Done**: SRT files are created in the same folder as originals

## 🔧 Building

```bash
./build.sh
```

The compiled app will be in `build/SRT Converter.app`

## 📝 Supported Formats

**Input (TXT):**
```
00:00:01:14 - 00:00:03:13
Subtitle text here
```

**Output (SRT):**
```
1
00:00:01,560 --> 00:00:03,520
Subtitle text here
```

Also handles mixed formats and files with existing SRT timecodes.

## 🌍 Languages

- **English** (default)
- **Français**

Toggle with the EN/FR button in the bottom right.

## 📦 Distribution

To share the app:
1. Compress `SRT Converter.app` to ZIP
2. Send to users
3. Users: Decompress and drag to Applications folder
4. First launch: Right-click → Open (security bypass)

## ⚙️ Technical Details

- **Language**: Swift
- **Framework**: Cocoa (native macOS)
- **Min OS**: macOS 10.13+
- **Size**: ~2 MB
- **Dependencies**: None

## 🐛 Bug Fixes

- ✅ Windows line endings (`\r\n`) support
- ✅ Mixed format files (TXT + SRT)
- ✅ Proper subtitle numbering
- ✅ Multi-file drag-and-drop

## 📄 License

© 2025 - For internal use

---

**Version**: 4.0.0  
**Last Updated**: December 2025
