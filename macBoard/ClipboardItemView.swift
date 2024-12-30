//
//  ClipboardItemView.swift
//  macBoard
//
//  Created by Aadi Shiv Malhotra on 12/29/24.
//

import SwiftUI

// Displays a single clipboard item with actions.

struct ClipboardItemView: View {
    @EnvironmentObject var manager: ClipboardManager
    let item: ClipboardItem

    @State private var isCopied: Bool = false
    @State private var isHovered: Bool = false
    @State private var hoveredButton: String? = nil
    @State private var showPreview: Bool = false

    private let buttonSize: CGFloat = 32
    private let previewThreshold = 150

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isCopied {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .imageScale(.medium)
                    Text("Copied to clipboard")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(0.1))
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95)),
                    removal: .opacity.combined(with: .scale(scale: 1.05))
                ))
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    // Content
                    Text(item.content)
                        .font(.system(size: 13))
                        .lineLimit(3)
                        .truncationMode(.tail)
                        .padding(.trailing, isHovered ? 100 : 0)

                    HStack(alignment: .center) {
                        // Timestamp with icon
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                            Text(formatTimestamp(item.timestamp))
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.secondary)
                        .opacity(isHovered ? 0.7 : 1.0)

                        Spacer()

                        // Action buttons
                        if isHovered {
                            HStack(spacing: 4) {
                                // Preview button (only shows for long content)
                                if item.content.count > previewThreshold {
                                    ActionButton(
                                        icon: "eye",
                                        color: .blue,
                                        isHovered: hoveredButton == "preview",
                                        action: { showPreview = true }
                                    )
                                    .onHover { hover in
                                        hoveredButton = hover ? "preview" : nil
                                    }
                                    .help("Preview")
                                }

                                // Copy button
                                ActionButton(
                                    icon: "doc.on.doc",
                                    color: .blue,
                                    isHovered: hoveredButton == "copy",
                                    action: handleCopy
                                )
                                .onHover { hover in
                                    hoveredButton = hover ? "copy" : nil
                                }
                                .help("Copy")

                                // Paste button
                                ActionButton(
                                    icon: "arrow.down.doc",
                                    color: .blue,
                                    isHovered: hoveredButton == "paste",
                                    action: { pasteContent(item.content) }
                                )
                                .onHover { hover in
                                    hoveredButton = hover ? "paste" : nil
                                }
                                .help("Paste")

                                // Delete button
                                ActionButton(
                                    icon: "trash",
                                    color: .red,
                                    isHovered: hoveredButton == "delete",
                                    action: {
                                        withAnimation(.spring(response: 0.3)) {
                                            manager.deleteItem(item.id)
                                        }
                                    }
                                )
                                .onHover { hover in
                                    hoveredButton = hover ? "delete" : nil
                                }
                                .help("Delete")
                            }
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
                .opacity(isHovered ? 0.6 : 0)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .onTapGesture(count: 2) {
            handleCopy()
        }
        .popover(isPresented: $showPreview) {
            PreviewPopup(content: item.content, isPresented: $showPreview)
        }
    }

    // MARK: - Copy Logic

    private func handleCopy() {
        copyToClipboard(item.content)
        manager.markContentAsCopied(item.content) // Notify manager

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isCopied = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
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
        // First, copy the content to clipboard
        copyToClipboard(text)

        // Then simulate Cmd+V using NSEvent
        let source = CGEventSource(stateID: .hidSystemState)

        // Create the 'v' key press with Command modifier
        let keyVDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        let keyVUp = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: false)

        keyVDown?.flags = .maskCommand
        keyVUp?.flags = .maskCommand

        // Post the events
        DispatchQueue.main.async {
            keyVDown?.post(tap: .cgAnnotatedSessionEventTap)
            keyVUp?.post(tap: .cgAnnotatedSessionEventTap)
        }
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Clipboard Item

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

// MARK: - ClipboardButtonStyle

struct ClipboardButtonStyle: ButtonStyle {
    var isDestructive: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(
                isDestructive
                    ? (configuration.isPressed ? .red.opacity(0.7) : .red)
                    : (configuration.isPressed ? .blue.opacity(0.7) : .blue)
            )
            .padding(4)
            .background(
                configuration.isPressed
                    ? Color(NSColor.controlBackgroundColor).opacity(0.8)
                    : Color.clear
            )
            .cornerRadius(4)
    }
}

// MARK: - ActionButton

struct ActionButton: View {
    let icon: String
    let color: Color
    let isHovered: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isHovered ? .white : color)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isHovered ? color : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(color.opacity(0.2), lineWidth: 1)
                                .opacity(isHovered ? 0 : 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.2), value: isHovered)
    }
}

// MARK: - PreviewPopup

struct PreviewPopup: View {
    let content: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Content Preview")
                    .font(.headline)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }

            ScrollView {
                Text(content)
                    .font(.system(size: 13))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .frame(width: 400, height: 300)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
