//
//  ModelTests.swift
//  YumemiFortuneTests
//
//  Created by tkt on 2025/10/21.
//

import XCTest
@testable import YumemiFortune

/// モデル層（YearMonthDay、MonthDay、FortuneRequest、Prefecture）のテスト
final class ModelTests: XCTestCase {
    
    // MARK: - YearMonthDay Tests
    
    func testYearMonthDayValidation() {
        // 有効な日付
        let validDate = YearMonthDay(year: 2000, month: 1, day: 27)
        XCTAssertTrue(validDate.isValid)
        
        // 無効な月
        let invalidMonth = YearMonthDay(year: 2000, month: 13, day: 1)
        XCTAssertFalse(invalidMonth.isValid)
        
        // 無効な日（2月30日は存在しない）
        let invalidDay = YearMonthDay(year: 2000, month: 2, day: 30)
        XCTAssertFalse(invalidDay.isValid)
    }
    
    func testYearMonthDayToday() {
        let today = YearMonthDay.today
        XCTAssertTrue(today.isValid)
    }
    
    // MARK: - MonthDay Tests
    
    func testMonthDayValidation() {
        // 有効な月日
        let validMonthDay = MonthDay(month: 5, day: 9)
        XCTAssertTrue(validMonthDay.isValid)
        
        // うるう年の2月29日は有効
        let leapDay = MonthDay(month: 2, day: 29)
        XCTAssertTrue(leapDay.isValid)
        
        // 無効な月
        let invalidMonth = MonthDay(month: 13, day: 1)
        XCTAssertFalse(invalidMonth.isValid)
        
        // 無効な日（2月30日は存在しない）
        let invalidDay = MonthDay(month: 2, day: 30)
        XCTAssertFalse(invalidDay.isValid)
        
        // 4月31日は存在しない
        let invalidApril = MonthDay(month: 4, day: 31)
        XCTAssertFalse(invalidApril.isValid)
    }
    
    func testMonthDayFormatted() {
        let monthDay = MonthDay(month: 5, day: 9)
        XCTAssertEqual(monthDay.formatted, "5月9日")
    }
    
    // MARK: - FortuneRequest Tests
    
    func testFortuneRequestValidation() {
        let birthday = YearMonthDay(year: 2000, month: 1, day: 27)
        let today = YearMonthDay.today
        
        // 有効なリクエスト
        let validRequest = FortuneRequest(
            name: "テスト太郎",
            birthday: birthday,
            bloodType: "a",
            today: today
        )
        XCTAssertTrue(validRequest.isValid)
        
        // 名前が空
        let emptyName = FortuneRequest(
            name: "",
            birthday: birthday,
            bloodType: "a",
            today: today
        )
        XCTAssertFalse(emptyName.isValid)
        
        // 無効な血液型
        let invalidBloodType = FortuneRequest(
            name: "テスト太郎",
            birthday: birthday,
            bloodType: "x",
            today: today
        )
        XCTAssertFalse(invalidBloodType.isValid)
    }
    
    func testFortuneRequestCodable() throws {
        let birthday = YearMonthDay(year: 2000, month: 1, day: 27)
        let today = YearMonthDay(year: 2023, month: 5, day: 5)
        
        let request = FortuneRequest(
            name: "ゆめみん",
            birthday: birthday,
            bloodType: "ab",
            today: today
        )
        
        // エンコード
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        
        // デコード
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(FortuneRequest.self, from: data)
        
        // 検証
        XCTAssertEqual(decoded.name, "ゆめみん")
        XCTAssertEqual(decoded.bloodType, "ab")
    }
    
    // MARK: - Prefecture Tests
    
    func testPrefectureCodable() throws {
        let json = """
        {
            "name": "富山県",
            "capital": "富山市",
            "citizen_day": {
                "month": 5,
                "day": 9
            },
            "has_coast_line": true,
            "logo_url": "https://japan-map.com/wp-content/uploads/toyama.png",
            "brief": "富山県の説明"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let prefecture = try decoder.decode(Prefecture.self, from: json)
        
        XCTAssertEqual(prefecture.name, "富山県")
        XCTAssertEqual(prefecture.capital, "富山市")
        XCTAssertEqual(prefecture.citizenDay?.month, 5)
        XCTAssertEqual(prefecture.hasCoastLine, true)
    }
    
    func testPrefectureWithoutCitizenDay() throws {
        let json = """
        {
            "name": "東京都",
            "capital": "新宿区",
            "citizen_day": null,
            "has_coast_line": true,
            "logo_url": "https://example.com/logo.png",
            "brief": "東京都の説明"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let prefecture = try decoder.decode(Prefecture.self, from: json)
        
        XCTAssertEqual(prefecture.name, "東京都")
        XCTAssertNil(prefecture.citizenDay)
        XCTAssertEqual(prefecture.citizenDayText, "なし")
    }
    
    // MARK: - APIError Tests
    
    func testAPIErrorMessages() {
        // クライアントエラー（4xx）
        let clientError = APIError.httpError(statusCode: 404)
        XCTAssertTrue(clientError.message.contains("クライアントエラー"))
        
        // サーバーエラー（5xx）
        let serverError = APIError.httpError(statusCode: 500)
        XCTAssertTrue(serverError.message.contains("サーバーエラー"))
        
        // validationErrorのテスト
        let validationError = APIError.validationError("入力内容が不正です")
        XCTAssertEqual(validationError.message, "入力内容が不正です")
        
        // その他のエラー
        let otherError = APIError.httpError(statusCode: 301)
        XCTAssertTrue(otherError.message.contains("エラーが発生しました"))
        
        // 他のエラーメッセージ
        XCTAssertEqual(APIError.invalidURL.message, "無効なURLです")
        XCTAssertEqual(APIError.networkError(NSError(domain: "", code: 0)).message,
                       "ネットワーク接続を確認してください")
    }
    
    func testAPIErrorDebugDescription() {
        let error = APIError.httpError(statusCode: 404)
        // CustomDebugStringConvertibleが使われる
        let debugOutput = "\(error)"
        XCTAssertTrue(debugOutput.contains("404"))
    }
}
