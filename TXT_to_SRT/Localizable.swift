//
//  Localizable.swift
//  TXT to SRT Converter
//
//  Localization strings for the application
//

import Foundation

enum Language: String {
    case english = "en"
    case french = "fr"
}

class Localizable {
    static var shared = Localizable()
    
    var currentLanguage: Language = .english {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "AppLanguage")
        }
    }
    
    init() {
        // Load saved language preference
        if let savedLang = UserDefaults.standard.string(forKey: "AppLanguage"),
           let language = Language(rawValue: savedLang) {
            currentLanguage = language
        }
    }
    
    func string(_ key: String) -> String {
        return translations[currentLanguage]?[key] ?? translations[.english]?[key] ?? key
    }
    
    private let translations: [Language: [String: String]] = [
        .english: [
            // Window and titles
            "window.title": "TXT to SRT Converter",
            "header.title": "🎬 Subtitle Converter",
            "header.subtitle": "TXT → SRT",
            
            // Drop zone
            "dropzone.text": "Drop your TXT files here",
            "dropzone.hint": "or click to browse",
            
            // File info
            "file.selected": "File selected",
            "files.selected": "files selected",
            
            // Buttons
            "button.convert": "🎬 Convert to SRT",
            "button.language": "🌐 Language",
            
            // Status messages
            "status.converting": "Converting",
            "status.files": "file(s) in progress...",
            "status.progress": "Converting...",
            "status.success": "file(s) converted successfully!",
            "status.error": "succeeded",
            "status.errors": "error(s)",
            
            // Footer
            "footer.text": "SRT files will be created in the original folder",
            
            // Menu
            "menu.english": "English",
            "menu.french": "Français"
        ],
        
        .french: [
            // Window and titles
            "window.title": "Convertisseur TXT vers SRT",
            "header.title": "🎬 Convertisseur de Sous-titres",
            "header.subtitle": "TXT → SRT",
            
            // Drop zone
            "dropzone.text": "Glissez vos fichiers TXT ici",
            "dropzone.hint": "ou cliquez pour parcourir",
            
            // File info
            "file.selected": "fichier sélectionné",
            "files.selected": "fichiers sélectionnés",
            
            // Buttons
            "button.convert": "🎬 Convertir en SRT",
            "button.language": "🌐 Langue",
            
            // Status messages
            "status.converting": "Conversion de",
            "status.files": "fichier(s) en cours...",
            "status.progress": "Conversion...",
            "status.success": "fichier(s) converti(s) avec succès!",
            "status.error": "réussi(s)",
            "status.errors": "erreur(s)",
            
            // Footer
            "footer.text": "Les fichiers SRT seront créés dans le dossier d'origine",
            
            // Menu
            "menu.english": "English",
            "menu.french": "Français"
        ]
    ]
}
