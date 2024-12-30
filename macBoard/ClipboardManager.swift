//
//  ClipboardManager.swift
//  macBoard
//
//  Created by Aadi Shiv Malhotra on 12/29/24.
//

import AppKit
import SwiftUI

/// Manages clipboard content and updates the UI accordingly.
class ClipboardManager: ObservableObject {
    // MARK: - Published Properties
    
    @Published var items: [ClipboardItem] = []
    @Published var showSettings: Bool = false
    @Published var preservationTime: TimeInterval = 3600 // Default: 1 hour
    
    // MARK: - Private Properties
    
    private var pollTimer: Timer?
    private var cleanupTimer: Timer?
    private var lastChangeCount = NSPasteboard.general.changeCount
    
    /// Tracks explicitly copied content to prevent duplicates.
    private var lastExplicitlyCopiedContent: String?
    
    // MARK: - Clipboard Polling
    
    func startListening() {
        stopListening()
        
        pollTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            let newChangeCount = NSPasteboard.general.changeCount
            if newChangeCount != self.lastChangeCount {
                self.lastChangeCount = newChangeCount
                
                if let newContent = NSPasteboard.general.string(forType: .string) {
                    DispatchQueue.main.async {
                        // Check if the content is explicitly copied
                        if newContent == self.lastExplicitlyCopiedContent {
                            self.lastExplicitlyCopiedContent = nil
                            return
                        }
                        
                        // Avoid duplicate entries
                        if self.items.first?.content != newContent {
                            let newItem = ClipboardItem(
                                id: UUID(),
                                content: newContent,
                                timestamp: Date()
                            )
                            self.items.insert(newItem, at: 0)
                        }
                    }
                }
            }
        }
        
        startCleanupTimer()
    }
    
    func stopListening() {
        pollTimer?.invalidate()
        pollTimer = nil
        cleanupTimer?.invalidate()
        cleanupTimer = nil
    }
    
    private func startCleanupTimer() {
        cleanupTimer?.invalidate()
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: preservationTime, repeats: true) { _ in
            DispatchQueue.main.async {
                self.items.removeAll()
            }
        }
    }
    
    func deleteItem(_ id: UUID) {
        items.removeAll { $0.id == id }
    }
    
    /// Explicitly marks a piece of content as copied.
    func markContentAsCopied(_ content: String) {
        lastExplicitlyCopiedContent = content
    }
}
