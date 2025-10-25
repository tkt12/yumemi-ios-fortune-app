//
//  StringLocalizationTests.swift
//  YumemiFortuneTests
//
//  Created by tkt on 2025/10/26.
//

import XCTest
@testable import YumemiFortune

final class StringLocalizationTests: XCTestCase {
    
    func testLocalizedJapanese() {
        let localized = "fortune.title".localized(language: "ja")
        XCTAssertEqual(localized, "都道府県相性占い")
    }
    
    func testLocalizedEnglish() {
        let localized = "fortune.title".localized(language: "en")
        XCTAssertEqual(localized, "Prefecture Fortune")
    }
    
    func testLocalizedWithCurrentLanguage() {
        // Given: 言語を英語に設定
        LocalizationManager.shared.setLanguage("en")
        
        // When: 言語指定なしでローカライズ
        let localized = "fortune.button.submit".localized()
        
        // Then: 現在の言語（英語）で取得される
        XCTAssertEqual(localized, "Fortune")
        
        // Cleanup
        LocalizationManager.shared.setLanguage("ja")
    }
    
    func testLocalizedKeyNotFound() {
        // 存在しないキー
        let localized = "nonexistent.key".localized()
        
        // フォールバック: キー自体が返される
        XCTAssertEqual(localized, "nonexistent.key")
    }
}
