//
//  ContentView.swift
//  macBoard
//
//  Created by Aadi Shiv Malhotra on 12/29/24.
//

import SwiftUI

/// The main UI showing clipboard history and navigation options.
struct ContentView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    
    var body: some View {
        VStack(spacing: 8) {
            Text("macBoard")
                .font(.headline)
            
            Divider()
            
            // Display clipboard items or show a placeholder if empty
            if clipboardManager.items.isEmpty {
                Text("No clipboard items yet.")
                    .foregroundColor(.secondary)
            } else {
                ScrollView {
                    ForEach(clipboardManager.items, id: \.self) { item in
                        ClipboardItemView(item: item)
                    }
                }
            }
            
            Divider()
            
            Button("Settings") {
                clipboardManager.showSettings = true
            }
        }
        .padding()
        .frame(width: 420)
        .onAppear {
            clipboardManager.startListening()
        }
    }
}
