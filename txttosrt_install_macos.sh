#!/bin/bash

# Installe l'application macOS depuis le dossier extrait de la release.
set -euo pipefail

# Retrouver le dossier où se trouve ce script pour installer l'app incluse à côté.
TXTTOSRT_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TXTTOSRT_APP_SOURCE="$TXTTOSRT_SCRIPT_DIR/SRT Converter.app"
TXTTOSRT_APP_TARGET="/Applications/SRT Converter.app"

# Vérifier que l'application est bien présente dans le package de release.
if [ ! -d "$TXTTOSRT_APP_SOURCE" ]; then
    echo "Application introuvable: $TXTTOSRT_APP_SOURCE"
    echo "Gardez le script à côté de SRT Converter.app dans le dossier extrait."
    exit 1
fi

# Demander confirmation avant de remplacer une installation existante.
if [ -d "$TXTTOSRT_APP_TARGET" ]; then
    printf "SRT Converter existe déjà dans Applications. Remplacer ? [y/N] "
    read -r TXTTOSRT_CONFIRM
    case "$TXTTOSRT_CONFIRM" in
        y|Y|yes|YES|Yes)
            ;;
        *)
            echo "Installation annulée."
            exit 0
            ;;
    esac
fi

# Copier le bundle complet en conservant sa structure macOS et sa signature ad-hoc.
/usr/bin/ditto "$TXTTOSRT_APP_SOURCE" "$TXTTOSRT_APP_TARGET"

echo "SRT Converter est installé dans /Applications."
