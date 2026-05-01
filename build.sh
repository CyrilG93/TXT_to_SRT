#!/bin/bash

# Script de compilation de l'application Swift native
# Ce script compile l'app sans nécessiter Xcode UI

echo "============================================================"
echo "🎬 Compilation de l'application native Swift"
echo "============================================================"

cd "$(dirname "$0")"

APP_VERSION="1.1.0"
APP_NAME="SRT Converter.app"
APP_EXECUTABLE="TXT_to_SRT"
APP_PATH="build/$APP_NAME"
APP_ICON_SOURCE="TXT_to_SRT/AppIcon.icns"
MACOSX_DEPLOYMENT_TARGET="11.0"
SWIFT_TARGET="$(uname -m)-apple-macosx$MACOSX_DEPLOYMENT_TARGET"

# Publier la cible de déploiement pour Swift et les outils Apple appelés par le script
export MACOSX_DEPLOYMENT_TARGET

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
    -o "build/$APP_EXECUTABLE" \
    -target "$SWIFT_TARGET" \
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

# Archiver l'ancien bundle local pour éviter de garder des fichiers obsolètes dans l'app recréée
if [ -d "$APP_PATH" ]; then
    PREVIOUS_APP_PATH="build/.previous-$(date +%Y%m%d%H%M%S)-$APP_NAME"
    mv "$APP_PATH" "$PREVIOUS_APP_PATH"
fi

mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

# Copier l'exécutable
cp "build/$APP_EXECUTABLE" "$APP_PATH/Contents/MacOS/"

# Copier l'icône officielle du projet dans les ressources du bundle
if [ ! -f "$APP_ICON_SOURCE" ]; then
    echo "❌ Erreur: icône manquante: $APP_ICON_SOURCE"
    exit 1
fi
cp "$APP_ICON_SOURCE" "$APP_PATH/Contents/Resources/AppIcon.icns"

# Créer Info.plist
cat > "$APP_PATH/Contents/Info.plist" << EOF
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
    <string>$APP_VERSION</string>
    <key>CFBundleShortVersionString</key>
    <string>$APP_VERSION</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>LSMinimumSystemVersion</key>
    <string>$MACOSX_DEPLOYMENT_TARGET</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>© 2025</string>
</dict>
</plist>
EOF

echo "✓ Icône ajoutée"

# Vérifier que le plist généré est lisible par macOS
plutil -lint "$APP_PATH/Contents/Info.plist"

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
