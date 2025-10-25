//
//  LocalizationManagerTests.swift
//  YumemiFortuneTests
//
//  Created by tkt on 2025/10/26.
//

import XCTest
@testable import YumemiFortune

@MainActor
final class LocalizationManagerTests: XCTestCase {
    
    var sut: LocalizationManager!
    
    override func setUp() {
        super.setUp()
        sut = LocalizationManager.shared
        // テスト前にデフォルト言語にリセット
        sut.setLanguage("ja")
    }
    
    func testInitialLanguageIsJapanese() {
        XCTAssertEqual(sut.currentLanguage, "ja")
        XCTAssertTrue(sut.isJapanese)
        XCTAssertFalse(sut.isEnglish)
    }
    
    func testToggleLanguage() {
        // Given: 初期状態は日本語
        XCTAssertEqual(sut.currentLanguage, "ja")
        
        // When: 切り替え
        sut.toggleLanguage()
        
        // Then: 英語になる
        XCTAssertEqual(sut.currentLanguage, "en")
        XCTAssertTrue(sut.isEnglish)
        
        // When: もう一度切り替え
        sut.toggleLanguage()
        
        // Then: 日本語に戻る
        XCTAssertEqual(sut.currentLanguage, "ja")
        XCTAssertTrue(sut.isJapanese)
    }
    
    func testSetLanguage() {
        // When: 英語に設定
        sut.setLanguage("en")
        
        // Then
        XCTAssertEqual(sut.currentLanguage, "en")
        
        // When: 日本語に設定
        sut.setLanguage("ja")
        
        // Then
        XCTAssertEqual(sut.currentLanguage, "ja")
    }
    
    func testSetInvalidLanguage() {
        // Given: 初期状態
        let initial = sut.currentLanguage
        
        // When: 無効な言語コード
        sut.setLanguage("fr")
        
        // Then: 変更されない
        XCTAssertEqual(sut.currentLanguage, initial)
    }
}
