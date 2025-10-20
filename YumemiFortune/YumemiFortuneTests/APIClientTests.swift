//
//  APIClientTests.swift
//  YumemiFortuneTests
//
//  Created by tkt on 2025/10/20.
//

import XCTest
@testable import YumemiFortune

final class APIClientTests: XCTestCase {
    
    var sut: APIClient!
    
    override func setUp() {
        super.setUp()
        sut = APIClient()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Request Validation Tests
    
    func testFortuneRequestIsValid() {
        // 有効なリクエスト
        let request = FortuneRequest(
            name: "テスト太郎",
            birthday: YearMonthDay(year: 2000, month: 1, day: 1),
            bloodType: "a",
            today: YearMonthDay.today
        )
        
        XCTAssertTrue(request.isValid)
    }
    
    func testFortuneRequestWithEmptyName() {
        // 空の名前は無効
        let request = FortuneRequest(
            name: "",
            birthday: YearMonthDay(year: 2000, month: 1, day: 1),
            bloodType: "a",
            today: YearMonthDay.today
        )
        
        XCTAssertFalse(request.isValid)
    }
    
    func testFortuneRequestWithInvalidBloodType() {
        // 無効な血液型
        let request = FortuneRequest(
            name: "テスト太郎",
            birthday: YearMonthDay(year: 2000, month: 1, day: 1),
            bloodType: "x",
            today: YearMonthDay.today
        )
        
        XCTAssertFalse(request.isValid)
    }
    
    // MARK: - Error Message Tests
    
    func testAPIErrorMessages() {
        XCTAssertEqual(APIError.invalidURL.message, "無効なURLです")
        XCTAssertEqual(APIError.networkError(NSError(domain: "", code: 0)).message, "ネットワーク接続を確認してください")
        XCTAssertEqual(APIError.invalidResponse.message, "サーバーからの応答が無効です")
        XCTAssertEqual(APIError.httpError(statusCode: 404).message, "サーバーエラーが発生しました（ステータスコード: 404）")
    }
    
    // MARK: - JSON Encoding/Decoding Tests
    
    func testFortuneRequestEncoding() throws {
        let request = FortuneRequest(
            name: "ゆめみん",
            birthday: YearMonthDay(year: 2000, month: 1, day: 27),
            bloodType: "ab",
            today: YearMonthDay(year: 2023, month: 5, day: 5)
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        
        // JSONに変換できることを確認
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["name"] as? String, "ゆめみん")
        XCTAssertEqual(json?["blood_type"] as? String, "ab")
    }
    
    func testPrefectureDecoding() throws {
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
        XCTAssertEqual(prefecture.citizenDay?.day, 9)
        XCTAssertTrue(prefecture.hasCoastLine)
    }
}
