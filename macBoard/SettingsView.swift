//
//  SettingsView.swift
//  macBoard
//
//  Created by Aadi Shiv Malhotra on 12/29/24.
//

import SwiftUI

/// Provides settings for clipboard preservation time.
struct SettingsView: View {
    @ObservedObject var manager: ClipboardManager
    
    var body: some View {
        Form {
            Picker("Preserve Items For", selection: $manager.preservationTime) {
                Text("30 minutes").tag(1800.0)
                Text("1 hour").tag(3600.0)
                Text("5 hours").tag(18000.0)
                Text("10 hours").tag(36000.0)
            }
            .pickerStyle(RadioGroupPickerStyle())
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("All items will be cleared every \(Int(manager.preservationTime / 60)) minute(s).")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .frame(width: 300)
    }
}
