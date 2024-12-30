//
//  ClipboardItemView.swift
//  macBoard
//
//  Created by Aadi Shiv Malhotra on 12/29/24.
//

import SwiftUI

/// Displays a single clipboard item with actions.
struct ClipboardItemView: View {
    @EnvironmentObject var manager: ClipboardManager
    let item: ClipboardItem

    @State private var isCopied: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if isCopied {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                    Text("Copied")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .transition(.opacity.combined(with: .scale))
                .animation(.spring(), value: isCopied)
            } else {
                VStack {
                    HStack {
                        Text(item.content)
                            .font(.system(size: 14, weight: .regular))
                            .lineLimit(3)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                        
                        HStack(spacing: 12) {
                            Button {
                                handleCopy()
                            } label: {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                            }
                            .help("Copy")
                            
                            Button {
                                pasteContent(item.content)
                            } label: {
                                Image(systemName: "arrow.down.doc")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                            }
                            .help("Paste")
                            
                            Button {
                                manager.deleteItem(item.id)
                            } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                            }
                            .help("Delete")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .animation(.spring(), value: isCopied)
                    
                    Text(formatTimestamp(item.timestamp))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 4)
                }
                
            }

           
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(width: 400)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.8))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .onTapGesture {
            handleCopy()
        }
    }

    // MARK: - Copy Logic

    private func handleCopy() {
        copyToClipboard(item.content)
        manager.markContentAsCopied(item.content) // Notify manager

        withAnimation {
            isCopied = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                isCopied = false
            }
        }
    }

    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    private func pasteContent(_ text: String) {
        copyToClipboard(text)
        DispatchQueue.main.async {
            let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: true)
            let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: false)
            keyDown?.flags = .maskCommand
            keyUp?.flags = .maskCommand
            keyDown?.post(tap: .cghidEventTap)
            keyUp?.post(tap: .cghidEventTap)
        }
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
}

/// Updated clipboard item model
struct ClipboardItem: Identifiable, Hashable {
    let id: UUID
    let content: String
    let timestamp: Date

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        lhs.id == rhs.id
    }
}
