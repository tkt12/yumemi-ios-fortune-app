//
//  LocalizationManager..swift
//  YumemiFortune
//
//  Created by tkt on 2025/10/26.
//

import Foundation
import Combine

/// アプリ内言語切り替えを管理するマネージャー
final class LocalizationManager: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = LocalizationManager()
    
    // MARK: - Published Properties
    
    /// 現在選択されている言語コード（"ja" or "en"）
    @Published private(set) var currentLanguage: String
    
    // MARK: - Constants
    
    private enum Keys {
        static let selectedLanguage = "selectedLanguage"
    }
    
    private enum SupportedLanguages {
        static let japanese = "ja"
        static let english = "en"
        static let `default` = japanese
    }
    
    // MARK: - Initialization
    
    private init() {
        // UserDefaultsから保存された言語を取得
        if let saved = UserDefaults.standard.string(forKey: Keys.selectedLanguage) {
            self.currentLanguage = saved
        } else {
            // デフォルトは日本語
            self.currentLanguage = SupportedLanguages.default
        }
    }
    
    // MARK: - Public Methods
    
    /// 言語を切り替える
    func toggleLanguage() {
        currentLanguage = (currentLanguage == SupportedLanguages.japanese)
        ? SupportedLanguages.english
        : SupportedLanguages.japanese
        
        // UserDefaultsに保存
        UserDefaults.standard.set(currentLanguage, forKey: Keys.selectedLanguage)
    }
    
    /// 指定した言語に設定する
    /// - Parameter languageCode: 言語コード（"ja" or "en"）
    func setLanguage(_ languageCode: String) {
        guard [SupportedLanguages.japanese, SupportedLanguages.english].contains(languageCode) else {
            return
        }
        
        currentLanguage = languageCode
        UserDefaults.standard.set(languageCode, forKey: Keys.selectedLanguage)
    }
    
    /// 現在の言語が日本語かどうか
    var isJapanese: Bool {
        currentLanguage == SupportedLanguages.japanese
    }
    
    /// 現在の言語が英語かどうか
    var isEnglish: Bool {
        currentLanguage == SupportedLanguages.english
    }
}
