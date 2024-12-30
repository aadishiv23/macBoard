//
//  macBoardApp.swift
//  macBoard
//
//  Created by Aadi Shiv Malhotra on 12/29/24.
//

import SwiftUI
import AppKit

/// The main entry point for the macOS clipboard manager app.
@main
struct macBoardApp: App {
    /// A shared instance of ClipboardManager accessible across views.
    @StateObject private var clipboardManager = ClipboardManager()
    
    var body: some Scene {
        MenuBarExtra("Clipboard", systemImage: "clipboard") {
            // Pass ClipboardManager to ContentView
            ContentView()
                .environmentObject(clipboardManager)
        }
        .menuBarExtraStyle(.window)
        
        // Settings view for configuring clipboard preservation time.
        Settings {
            SettingsView(manager: clipboardManager)
        }
    }
}
