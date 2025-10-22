//
//  APIClientTests.swift
//  YumemiFortuneTests
//
//  Created by tkt on 2025/10/20.
//

import XCTest
@testable import YumemiFortune

/// APIClientの単体テスト
final class APIClientTests: XCTestCase {
    
    // MARK: - Properties
    
    /// テスト対象（System Under Test）
    var sut: APIClient!
    
    /// モックURLSession
    var mockSession: MockURLSession!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        sut = APIClient(session: mockSession)
    }
    
    override func tearDown() {
        sut = nil
        mockSession = nil
        super.tearDown()
    }
    
    // MARK: - Success Tests
    
    /// 正常系: APIからのレスポンスを正しくデコードできるか
    func testFetchFortuneSuccess() async throws {
        // Given: 正常なJSONレスポンスを準備
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
        
        mockSession.data = json
        mockSession.response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When: APIを呼び出す
        let request = FortuneRequest(
            name: "テスト太郎",
            birthday: YearMonthDay(year: 2000, month: 1, day: 1),
            bloodType: "a",
            today: YearMonthDay.today
        )
        
        let prefecture = try await sut.fetchFortune(request: request)
        
        // Then: 正しくデコードされている
        XCTAssertEqual(prefecture.name, "富山県")
        XCTAssertEqual(prefecture.capital, "富山市")
        XCTAssertEqual(prefecture.citizenDay?.month, 5)
        XCTAssertEqual(prefecture.citizenDay?.day, 9)
        XCTAssertTrue(prefecture.hasCoastLine)
    }
    
    /// 県民の日がnullの場合も正しく処理できるか
    func testFetchFortuneWithNullCitizenDay() async throws {
        // Given: citizen_dayがnullのレスポンス
        let json = """
        {
            "name": "東京都",
            "capital": "新宿区",
            "citizen_day": null,
            "has_coast_line": true,
            "logo_url": "https://example.com/tokyo.png",
            "brief": "東京都の説明"
        }
        """.data(using: .utf8)!
        
        mockSession.data = json
        mockSession.response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let request = FortuneRequest(
            name: "テスト太郎",
            birthday: YearMonthDay(year: 2000, month: 1, day: 1),
            bloodType: "a",
            today: YearMonthDay.today
        )
        
        let prefecture = try await sut.fetchFortune(request: request)
        
        // Then: citizen_dayがnilになっている
        XCTAssertEqual(prefecture.name, "東京都")
        XCTAssertNil(prefecture.citizenDay)
    }
    
    // MARK: - Network Error Tests
    
    /// ネットワークエラー時に適切なエラーが投げられるか
    func testFetchFortuneNetworkError() async {
        // Given: ネットワークエラーをモック
        mockSession.error = URLError(.notConnectedToInternet)
        
        let request = FortuneRequest(
            name: "テスト太郎",
            birthday: YearMonthDay(year: 2000, month: 1, day: 1),
            bloodType: "a",
            today: YearMonthDay.today
        )
        
        // When/Then: networkErrorが投げられる
        do {
            _ = try await sut.fetchFortune(request: request)
            XCTFail("エラーが投げられるべき")
        } catch let error as APIError {
            // APIError.networkErrorであることを確認
            guard case .networkError = error else {
                XCTFail("networkErrorが期待されるが、\(error)が投げられた")
                return
            }
            // 成功: 期待通りnetworkErrorが投げられた
        } catch {
            XCTFail("APIErrorが期待されるが、\(error)が投げられた")
        }
    }
    
    // MARK: - HTTP Error Tests
    
    /// 404エラー時に適切なエラーが投げられるか（クライアントエラー）
    func testFetchFortuneHTTP404Error() async {
        // Given: 404レスポンスをモック
        mockSession.data = Data()
        mockSession.response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )
        
        let request = FortuneRequest(
            name: "テスト太郎",
            birthday: YearMonthDay(year: 2000, month: 1, day: 1),
            bloodType: "a",
            today: YearMonthDay.today
        )
        
        // When/Then: httpErrorが投げられる
        do {
            _ = try await sut.fetchFortune(request: request)
            XCTFail("エラーが投げられるべき")
        } catch let error as APIError {
            guard case .httpError(let statusCode) = error else {
                XCTFail("httpErrorが期待されるが、\(error)が投げられた")
                return
            }
            // 成功: 期待通りhttpErrorが投げられた
            XCTAssertEqual(statusCode, 404)
            XCTAssertTrue(error.message.contains("クライアントエラー"))
        } catch {
            XCTFail("APIErrorが期待されるが、\(error)が投げられた")
        }
    }
    
    /// 500エラー時に適切なエラーが投げられるか（サーバーエラー）
    func testFetchFortuneHTTP500Error() async {
        // Given: 500レスポンスをモック
        mockSession.data = Data()
        mockSession.response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )
        
        let request = FortuneRequest(
            name: "テスト太郎",
            birthday: YearMonthDay(year: 2000, month: 1, day: 1),
            bloodType: "a",
            today: YearMonthDay.today
        )
        
        // When/Then: httpErrorが投げられる
        do {
            _ = try await sut.fetchFortune(request: request)
            XCTFail("エラーが投げられるべき")
        } catch let error as APIError {
            guard case .httpError(let statusCode) = error else {
                XCTFail("httpErrorが期待されるが、\(error)が投げられた")
                return
            }
            // 成功: 期待通りhttpErrorが投げられた
            XCTAssertEqual(statusCode, 500)
            XCTAssertTrue(error.message.contains("サーバーエラー"))
        } catch {
            XCTFail("APIErrorが期待されるが、\(error)が投げられた")
        }
    }
    
    // MARK: - Decoding Error Tests
    
    /// 不正なJSONの場合にdecodingErrorが投げられるか
    func testFetchFortuneDecodingError() async {
        // Given: 不正なJSONをモック
        let invalidJSON = "this is not json".data(using: .utf8)!
        
        mockSession.data = invalidJSON
        mockSession.response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let request = FortuneRequest(
            name: "テスト太郎",
            birthday: YearMonthDay(year: 2000, month: 1, day: 1),
            bloodType: "a",
            today: YearMonthDay.today
        )
        
        // When/Then: decodingErrorが投げられる
        do {
            _ = try await sut.fetchFortune(request: request)
            XCTFail("エラーが投げられるべき")
        } catch let error as APIError {
            guard case .decodingError = error else {
                XCTFail("decodingErrorが期待されるが、\(error)が投げられた")
                return
            }
            // 成功: 期待通りdecodingErrorが投げられた
        } catch {
            XCTFail("APIErrorが期待されるが、\(error)が投げられた")
        }
    }
}
