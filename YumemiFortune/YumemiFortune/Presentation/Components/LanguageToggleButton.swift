//
//  LanguageToggleButton.swift
//  YumemiFortune
//
//  Created by tkt on 2025/10/26.
//

import SwiftUI

/// 言語切り替えボタン
struct LanguageToggleButton: View {
    
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                localizationManager.toggleLanguage()
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "globe")
                    .font(.system(size: 14, weight: .semibold))
                
                Text(localizationManager.isJapanese ? "EN" : "JA")
                    .font(.system(size: 12, weight: .bold))
                    .monospacedDigit()
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color("CardBackground"))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Light Mode") {
    LanguageToggleButton()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    LanguageToggleButton()
        .preferredColorScheme(.dark)
}
