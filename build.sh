#!/bin/bash

# Script de compilation de l'application Swift native
# Ce script compile l'app sans nécessiter Xcode UI

echo "============================================================"
echo "🎬 Compilation de l'application native Swift"
echo "============================================================"

cd "$(dirname "$0")"

# Vérifier que swiftc est disponible
if ! command -v swiftc &> /dev/null; then
    echo "❌ Erreur: Swift compiler non trouvé"
    echo "   Installez Xcode Command Line Tools:"
    echo "   xcode-select --install"
    exit 1
fi

echo "✓ Swift compiler trouvé"

# Créer le dossier de build
mkdir -p build

echo "📦 Compilation des fichiers Swift..."

# Compiler l'application
swiftc \
    -o build/TXT_to_SRT \
    -framework Cocoa \
    -sdk $(xcrun --show-sdk-path --sdk macosx) \
    TXT_to_SRT/main.swift \
    TXT_to_SRT/Localizable.swift \
    TXT_to_SRT/AppDelegate.swift \
    TXT_to_SRT/ViewController.swift \
    TXT_to_SRT/DropZoneView.swift \
    TXT_to_SRT/SubtitleConverter.swift

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de la compilation"
    exit 1
fi

echo "✓ Compilation réussie"

# Créer la structure .app
echo "📁 Création du bundle .app..."

APP_NAME="SRT Converter.app"
APP_PATH="build/$APP_NAME"

mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

# Copier l'exécutable
cp build/TXT_to_SRT "$APP_PATH/Contents/MacOS/"

# Créer Info.plist
cat > "$APP_PATH/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>TXT_to_SRT</string>
    <key>CFBundleIdentifier</key>
    <string>com.subtitle.converter</string>
    <key>CFBundleName</key>
    <string>SRT Converter</string>
    <key>CFBundleDisplayName</key>
    <string>SRT Converter</string>
    <key>CFBundleVersion</key>
    <string>4.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>4.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>© 2025</string>
</dict>
</plist>
EOF

# Convertir l'icône si elle existe
if [ -f "../TXT_to_SRT_Converter/app_icon.png" ]; then
    echo "🎨 Conversion de l'icône..."
    
    mkdir -p app_icon.iconset
    
    # Générer toutes les tailles
    sips -z 16 16     ../TXT_to_SRT_Converter/app_icon.png --out app_icon.iconset/icon_16x16.png
    sips -z 32 32     ../TXT_to_SRT_Converter/app_icon.png --out app_icon.iconset/icon_16x16@2x.png
    sips -z 32 32     ../TXT_to_SRT_Converter/app_icon.png --out app_icon.iconset/icon_32x32.png
    sips -z 64 64     ../TXT_to_SRT_Converter/app_icon.png --out app_icon.iconset/icon_32x32@2x.png
    sips -z 128 128   ../TXT_to_SRT_Converter/app_icon.png --out app_icon.iconset/icon_128x128.png
    sips -z 256 256   ../TXT_to_SRT_Converter/app_icon.png --out app_icon.iconset/icon_128x128@2x.png
    sips -z 256 256   ../TXT_to_SRT_Converter/app_icon.png --out app_icon.iconset/icon_256x256.png
    sips -z 512 512   ../TXT_to_SRT_Converter/app_icon.png --out app_icon.iconset/icon_256x256@2x.png
    sips -z 512 512   ../TXT_to_SRT_Converter/app_icon.png --out app_icon.iconset/icon_512x512.png
    sips -z 1024 1024 ../TXT_to_SRT_Converter/app_icon.png --out app_icon.iconset/icon_512x512@2x.png
    
    # Convertir en ICNS
    iconutil -c icns app_icon.iconset -o "$APP_PATH/Contents/Resources/AppIcon.icns"
    
    # Ajouter l'icône au Info.plist
    /usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string AppIcon" "$APP_PATH/Contents/Info.plist" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Set :CFBundleIconFile AppIcon" "$APP_PATH/Contents/Info.plist"
    
    # Nettoyer
    rm -rf app_icon.iconset
    
    echo "✓ Icône ajoutée"
fi

# Signer l'application (ad-hoc)
echo "✍️  Signature de l'application..."
codesign --force --deep --sign - "$APP_PATH"

echo "✓ Application signée"

# Mettre à jour la date de modification pour que l'utilisateur voie le changement
touch "$APP_PATH"

echo ""
echo "============================================================"
echo "✅ Application créée avec succès!"
echo "============================================================"
echo ""
echo "📁 Emplacement: build/$APP_NAME"
echo ""
echo "📝 Pour tester:"
echo "   1. Double-cliquez sur l'application dans le dossier 'build'"
echo "   2. Glissez un fichier .txt directement sur la fenêtre"
echo "   3. Ou cliquez pour sélectionner"
echo ""
echo "============================================================"
