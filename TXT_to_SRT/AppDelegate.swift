//
//  AppDelegate.swift
//  TXT to SRT Converter
//
//  Application delegate
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Activate the application
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        // Create window
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 750, height: 700),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Convertisseur TXT → SRT"
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentViewController = ViewController()
        
        // Prevent resizing
        window.styleMask.remove(.resizable)
        
        // Show window
        window.makeKeyAndOrderFront(nil)
        
        // Ensure app is in front
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Cleanup if needed
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
