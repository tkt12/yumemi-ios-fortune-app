//
//  String+Localization.swift
//  YumemiFortune
//
//  Created by tkt on 2025/10/26.
//

import Foundation

extension String {
    /// Localizable.stringsから翻訳を取得
    /// - Parameter language: 言語コード（nilの場合は現在の設定言語）
    /// - Returns: ローカライズされた文字列
    func localized(language: String? = nil) -> String {
        let lang = language ?? LocalizationManager.shared.currentLanguage
        
        guard let path = Bundle.main.path(forResource: lang, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            // フォールバック: キーをそのまま返す
            return self
        }
        
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}
