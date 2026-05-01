# SRT Converter

Application macOS native pour convertir des fichiers de sous-titres `.txt` en `.srt`.

## Fonctionnalités

- Conversion d'un ou plusieurs fichiers `.txt` en une seule fois
- Glisser-déposer ou sélection via le bouton de l'application
- Interface en français et en anglais
- Lecture des fichiers TXT en UTF-8, UTF-16, Windows-1252 et ISO Latin 1
- Création des fichiers `.srt` dans le même dossier que les fichiers d'origine
- Application autonome, sans dépendance à installer pour l'utilisateur
- Compatible avec macOS 11 ou plus récent

## Installation

1. Téléchargez la dernière archive `.zip` depuis la page GitHub Releases.
2. Décompressez l'archive.
3. Glissez `SRT Converter.app` dans le dossier `Applications`.
4. Au premier lancement, si macOS bloque l'app, faites clic droit sur `SRT Converter`, puis `Ouvrir`.

Vous pouvez aussi utiliser l'application directement depuis le dossier extrait.

## Utilisation

1. Ouvrez `SRT Converter`.
2. Glissez un ou plusieurs fichiers `.txt` dans la zone centrale, ou cliquez pour les sélectionner.
3. Cliquez sur `Convert to SRT` / `Convertir en SRT`.
4. Les fichiers `.srt` sont créés à côté des fichiers `.txt` d'origine.

## Format accepté

Entrée `.txt`:

```txt
00:00:01:14 - 00:00:03:13
Texte du sous-titre
```

Sortie `.srt`:

```srt
1
00:00:01,560 --> 00:00:03,520
Texte du sous-titre
```

L'application accepte aussi les timecodes SRT déjà écrits avec `-->`.

## Compilation

Pour recréer l'application depuis les sources:

```bash
./build.sh
```

L'application générée se trouve dans `build/SRT Converter.app`.

## Version

Version actuelle: `1.1.0`

## Changelog

### 1.1.0 - 2026-05-01

- Nouvelle icône macOS intégrée correctement dans l'application.
- Release macOS fournie avec l'application finale et le README.
- Lecture plus robuste des fichiers TXT exportés avec différents encodages.
