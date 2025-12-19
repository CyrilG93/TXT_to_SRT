//
//  ViewController.swift
//  TXT to SRT Converter
//
//  Main view controller with drag-and-drop interface and multi-language support
//

import Cocoa

class ViewController: NSViewController {
    
    // UI Elements
    private var dropZoneView: DropZoneView!
    private var statusLabel: NSTextField!
    private var fileInfoLabel: NSTextField!
    private var convertButton: NSButton!
    private var languageButton: NSButton!
    private var titleLabel: NSTextField!
    private var subtitleLabel: NSTextField!
    private var footerLabel: NSTextField!
    private var buttonLabel: NSTextField!
    
    private let converter = SubtitleConverter()
    private var selectedFileURLs: [URL] = []
    private let loc = Localizable.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateLanguage()
    }
    
    private func setupUI() {
        // Set vibrant gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            NSColor(red: 0.4, green: 0.494, blue: 0.918, alpha: 1.0).cgColor,
            NSColor(red: 0.463, green: 0.294, blue: 0.635, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.wantsLayer = true
        view.layer?.insertSublayer(gradientLayer, at: 0)
        
        // Container view (dark glassmorphism)
        let containerView = NSView(frame: NSRect(x: 0, y: 0, width: 650, height: 540))
        containerView.wantsLayer = true
        containerView.layer?.backgroundColor = NSColor(white: 0.15, alpha: 0.85).cgColor
        containerView.layer?.cornerRadius = 24
        containerView.layer?.shadowColor = NSColor.black.cgColor
        containerView.layer?.shadowOpacity = 0.5
        containerView.layer?.shadowOffset = CGSize(width: 0, height: 20)
        containerView.layer?.shadowRadius = 60
        view.addSubview(containerView)
        
        // Center the container
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 650),
            containerView.heightAnchor.constraint(equalToConstant: 540)
        ])
        
        // Header
        titleLabel = NSTextField(labelWithString: "")
        titleLabel.font = NSFont.systemFont(ofSize: 26, weight: .bold)  // Reduced from 32
        titleLabel.textColor = .white
        titleLabel.alignment = .center
        titleLabel.frame = NSRect(x: 20, y: 470, width: 610, height: 40)  // Reduced width to avoid overlap
        titleLabel.drawsBackground = false
        titleLabel.isBordered = false
        containerView.addSubview(titleLabel)
        
        subtitleLabel = NSTextField(labelWithString: "")
        subtitleLabel.font = NSFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = NSColor(red: 0.8, green: 0.8, blue: 1.0, alpha: 0.9)
        subtitleLabel.alignment = .center
        subtitleLabel.frame = NSRect(x: 0, y: 445, width: 650, height: 20)
        subtitleLabel.drawsBackground = false
        subtitleLabel.isBordered = false
        containerView.addSubview(subtitleLabel)
        
        // Drop zone
        dropZoneView = DropZoneView(frame: NSRect(x: 40, y: 240, width: 570, height: 170))
        dropZoneView.delegate = self
        containerView.addSubview(dropZoneView)
        
        // File info label
        fileInfoLabel = NSTextField(labelWithString: "")
        fileInfoLabel.font = NSFont.systemFont(ofSize: 14, weight: .semibold)
        fileInfoLabel.textColor = NSColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0)
        fileInfoLabel.alignment = .center
        fileInfoLabel.frame = NSRect(x: 40, y: 205, width: 570, height: 20)
        fileInfoLabel.drawsBackground = false
        fileInfoLabel.isBordered = false
        fileInfoLabel.isHidden = true
        containerView.addSubview(fileInfoLabel)
        
        // Custom convert button
        let buttonView = NSView(frame: NSRect(x: 175, y: 130, width: 300, height: 60))
        buttonView.wantsLayer = true
        
        let buttonGradient = CAGradientLayer()
        buttonGradient.frame = buttonView.bounds
        buttonGradient.colors = [
            NSColor(red: 0.2, green: 0.8, blue: 0.5, alpha: 1.0).cgColor,
            NSColor(red: 0.15, green: 0.65, blue: 0.4, alpha: 1.0).cgColor
        ]
        buttonGradient.startPoint = CGPoint(x: 0, y: 0)
        buttonGradient.endPoint = CGPoint(x: 1, y: 1)
        buttonGradient.cornerRadius = 30
        buttonView.layer?.insertSublayer(buttonGradient, at: 0)
        buttonView.layer?.cornerRadius = 30
        buttonView.layer?.shadowColor = NSColor(red: 0.2, green: 0.8, blue: 0.5, alpha: 0.6).cgColor
        buttonView.layer?.shadowOpacity = 1.0
        buttonView.layer?.shadowOffset = CGSize(width: 0, height: 8)
        buttonView.layer?.shadowRadius = 20
        
        buttonLabel = NSTextField(labelWithString: "")
        buttonLabel.font = NSFont.systemFont(ofSize: 20, weight: .bold)
        buttonLabel.textColor = .white
        buttonLabel.alignment = .center
        buttonLabel.frame = NSRect(x: 0, y: 18, width: 300, height: 28)
        buttonLabel.drawsBackground = false
        buttonLabel.isBordered = false
        buttonLabel.isEditable = false
        buttonLabel.isSelectable = false
        buttonView.addSubview(buttonLabel)
        
        convertButton = NSButton(frame: buttonView.bounds)
        convertButton.title = ""
        convertButton.isBordered = false
        convertButton.wantsLayer = true
        convertButton.layer?.backgroundColor = NSColor.clear.cgColor
        convertButton.target = self
        convertButton.action = #selector(convertButtonClicked)
        convertButton.isEnabled = false
        buttonView.addSubview(convertButton)
        
        containerView.addSubview(buttonView)
        
        // Status label
        statusLabel = NSTextField(labelWithString: "")
        statusLabel.font = NSFont.systemFont(ofSize: 15, weight: .medium)
        statusLabel.textColor = NSColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1.0)
        statusLabel.alignment = .center
        statusLabel.frame = NSRect(x: 40, y: 70, width: 570, height: 50)
        statusLabel.maximumNumberOfLines = 2
        statusLabel.drawsBackground = false
        statusLabel.isBordered = false
        containerView.addSubview(statusLabel)
        
        // Footer
        footerLabel = NSTextField(labelWithString: "")
        footerLabel.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        footerLabel.textColor = NSColor(red: 0.7, green: 0.7, blue: 0.8, alpha: 0.8)
        footerLabel.alignment = .center
        footerLabel.frame = NSRect(x: 0, y: 25, width: 650, height: 20)
        footerLabel.drawsBackground = false
        footerLabel.isBordered = false
        containerView.addSubview(footerLabel)
        
        // Language button as clickable view with text
        let langButtonView = NSView(frame: NSRect(x: 520, y: 35, width: 50, height: 28))
        langButtonView.wantsLayer = true
        langButtonView.layer?.backgroundColor = NSColor.white.cgColor
        langButtonView.layer?.cornerRadius = 14
        langButtonView.layer?.shadowColor = NSColor.black.cgColor
        langButtonView.layer?.shadowOpacity = 0.2
        langButtonView.layer?.shadowOffset = CGSize(width: 0, height: 1)
        langButtonView.layer?.shadowRadius = 3
        
        let langLabel = NSTextField(labelWithString: "EN")
        langLabel.font = NSFont.systemFont(ofSize: 13, weight: .bold)
        langLabel.textColor = NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        langLabel.alignment = .center
        langLabel.frame = NSRect(x: 0, y: 6, width: 50, height: 18)
        langLabel.drawsBackground = false
        langLabel.isBordered = false
        langButtonView.addSubview(langLabel)
        
        // Invisible button on top for clicking
        languageButton = NSButton(frame: langButtonView.bounds)
        languageButton.title = ""
        languageButton.isBordered = false
        languageButton.wantsLayer = true
        languageButton.layer?.backgroundColor = NSColor.clear.cgColor
        languageButton.target = self
        languageButton.action = #selector(toggleLanguage)
        languageButton.toolTip = "Change language / Changer de langue"
        langButtonView.addSubview(languageButton)
        
        containerView.addSubview(langButtonView)
        
        // Store reference to label for updates
        self.languageLabel = langLabel
    }
    
    private var languageLabel: NSTextField!
    
    @objc private func toggleLanguage() {
        loc.currentLanguage = (loc.currentLanguage == .english) ? .french : .english
        updateLanguage()
        dropZoneView.updateLanguage()
    }
    
    private func updateLanguage() {
        titleLabel.stringValue = loc.string("header.title")
        subtitleLabel.stringValue = loc.string("header.subtitle")
        buttonLabel.stringValue = loc.string("button.convert")
        footerLabel.stringValue = loc.string("footer.text")
        languageLabel.stringValue = loc.currentLanguage == .english ? "EN" : "FR"
        
        // Update window title
        view.window?.title = loc.string("window.title")
        
        // Update file info if files are selected
        if !selectedFileURLs.isEmpty {
            let count = selectedFileURLs.count
            let key = count > 1 ? "files.selected" : "file.selected"
            fileInfoLabel.stringValue = "📄 \(count) \(loc.string(key))"
        }
    }
    
    @objc private func convertButtonClicked() {
        guard !selectedFileURLs.isEmpty else { return }
        
        let fileCount = selectedFileURLs.count
        let filesText = loc.string("status.files")
        statusLabel.stringValue = "\(loc.string("status.converting")) \(fileCount) \(filesText)"
        convertButton.isEnabled = false
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            var successCount = 0
            var errorCount = 0
            
            for (index, fileURL) in self.selectedFileURLs.enumerated() {
                do {
                    _ = try self.converter.convertFile(inputURL: fileURL)
                    successCount += 1
                    
                    DispatchQueue.main.async {
                        self.statusLabel.stringValue = "\(self.loc.string("status.progress")) (\(index + 1)/\(fileCount))"
                    }
                } catch {
                    errorCount += 1
                }
            }
            
            DispatchQueue.main.async {
                if errorCount == 0 {
                    self.statusLabel.stringValue = "✅ \(successCount) \(self.loc.string("status.success"))"
                } else {
                    let successText = self.loc.string("status.error")
                    let errorText = self.loc.string("status.errors")
                    self.statusLabel.stringValue = "⚠️ \(successCount) \(successText), \(errorCount) \(errorText)"
                }
                self.selectedFileURLs = []
                self.fileInfoLabel.isHidden = true
                self.convertButton.isEnabled = false
            }
        }
    }
}

// MARK: - DropZoneViewDelegate
extension ViewController: DropZoneViewDelegate {
    func dropZoneView(_ view: DropZoneView, didReceiveFileURLs urls: [URL]) {
        selectedFileURLs = urls
        let count = urls.count
        let key = count > 1 ? "files.selected" : "file.selected"
        fileInfoLabel.stringValue = "📄 \(count) \(loc.string(key))"
        fileInfoLabel.isHidden = false
        convertButton.isEnabled = true
        statusLabel.stringValue = ""
    }
    
    func dropZoneViewWasClicked(_ view: DropZoneView) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["txt"]
        
        openPanel.begin { [weak self] response in
            if response == .OK, !openPanel.urls.isEmpty {
                self?.selectedFileURLs = openPanel.urls
                let count = openPanel.urls.count
                let key = count > 1 ? "files.selected" : "file.selected"
                self?.fileInfoLabel.stringValue = "📄 \(count) \(self?.loc.string(key) ?? "")"
                self?.fileInfoLabel.isHidden = false
                self?.convertButton.isEnabled = true
                self?.statusLabel.stringValue = ""
            }
        }
    }
}
