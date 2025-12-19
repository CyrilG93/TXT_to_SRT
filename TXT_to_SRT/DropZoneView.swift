//
//  DropZoneView.swift
//  TXT to SRT Converter
//
//  Custom view that handles drag-and-drop of files
//

import Cocoa

protocol DropZoneViewDelegate: AnyObject {
    func dropZoneView(_ view: DropZoneView, didReceiveFileURLs urls: [URL])  // Changed to array
    func dropZoneViewWasClicked(_ view: DropZoneView)
}

class DropZoneView: NSView {
    
    weak var delegate: DropZoneViewDelegate?
    private var isDraggingOver = false
    private let loc = Localizable.shared
    private var textLabel: NSTextField!
    private var hintLabel: NSTextField!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
        registerForDraggedTypes([.fileURL])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        registerForDraggedTypes([.fileURL])
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.cornerRadius = 15
        layer?.borderWidth = 3
        layer?.borderColor = NSColor(red: 0.741, green: 0.765, blue: 0.78, alpha: 1.0).cgColor
        layer?.backgroundColor = NSColor(red: 0.925, green: 0.941, blue: 0.945, alpha: 1.0).cgColor
        
        // Add click gesture
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(viewClicked))
        addGestureRecognizer(clickGesture)
        
        // Add labels
        let iconLabel = NSTextField(labelWithString: "📄")
        iconLabel.font = NSFont.systemFont(ofSize: 64)
        iconLabel.alignment = .center
        iconLabel.frame = NSRect(x: 0, y: 80, width: bounds.width, height: 80)
        iconLabel.autoresizingMask = [.width]
        addSubview(iconLabel)
        
        textLabel = NSTextField(labelWithString: "")
        textLabel.font = NSFont.systemFont(ofSize: 18, weight: .semibold)
        textLabel.textColor = NSColor(red: 0.172, green: 0.243, blue: 0.314, alpha: 1.0)
        textLabel.alignment = .center
        textLabel.frame = NSRect(x: 0, y: 50, width: bounds.width, height: 25)
        textLabel.autoresizingMask = [.width]
        addSubview(textLabel)
        
        hintLabel = NSTextField(labelWithString: "")
        hintLabel.font = NSFont.systemFont(ofSize: 14)
        hintLabel.textColor = NSColor(red: 0.498, green: 0.549, blue: 0.553, alpha: 1.0)
        hintLabel.alignment = .center
        hintLabel.frame = NSRect(x: 0, y: 30, width: bounds.width, height: 20)
        hintLabel.autoresizingMask = [.width]
        addSubview(hintLabel)
        
        updateLanguage()
    }
    
    func updateLanguage() {
        textLabel.stringValue = loc.string("dropzone.text")
        hintLabel.stringValue = loc.string("dropzone.hint")
    }
    
    @objc private func viewClicked() {
        delegate?.dropZoneViewWasClicked(self)
    }
    
    // MARK: - Drag and Drop
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let fileURLs = getFileURLs(from: sender)
        let txtFiles = fileURLs.filter { $0.pathExtension.lowercased() == "txt" }
        
        if !txtFiles.isEmpty {
            isDraggingOver = true
            updateAppearance()
            return .copy
        }
        return []
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isDraggingOver = false
        updateAppearance()
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        isDraggingOver = false
        updateAppearance()
        
        let fileURLs = getFileURLs(from: sender)
        let txtFiles = fileURLs.filter { $0.pathExtension.lowercased() == "txt" }
        
        guard !txtFiles.isEmpty else {
            return false
        }
        
        delegate?.dropZoneView(self, didReceiveFileURLs: txtFiles)
        return true
    }
    
    private func getFileURLs(from draggingInfo: NSDraggingInfo) -> [URL] {
        guard let items = draggingInfo.draggingPasteboard.pasteboardItems else {
            return []
        }
        
        var urls: [URL] = []
        for item in items {
            if let urlString = item.string(forType: .fileURL),
               let url = URL(string: urlString) {
                urls.append(url)
            }
        }
        return urls
    }
    
    private func updateAppearance() {
        if isDraggingOver {
            layer?.borderColor = NSColor(red: 0.204, green: 0.596, blue: 0.859, alpha: 1.0).cgColor  // #3498db
            layer?.backgroundColor = NSColor(red: 0.89, green: 0.949, blue: 0.992, alpha: 1.0).cgColor  // #e3f2fd
        } else {
            layer?.borderColor = NSColor(red: 0.741, green: 0.765, blue: 0.78, alpha: 1.0).cgColor  // #bdc3c7
            layer?.backgroundColor = NSColor(red: 0.925, green: 0.941, blue: 0.945, alpha: 1.0).cgColor  // #ecf0f1
        }
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        for trackingArea in trackingAreas {
            removeTrackingArea(trackingArea)
        }
        
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways]
        let trackingArea = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
    }
    
    override func mouseEntered(with event: NSEvent) {
        NSCursor.pointingHand.set()
    }
    
    override func mouseExited(with event: NSEvent) {
        NSCursor.arrow.set()
    }
}
