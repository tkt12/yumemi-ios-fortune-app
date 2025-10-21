//
//  RepositoryTests.swift
//  YumemiFortuneTests
//
//  Created by tkt on 2025/10/21.
//

import XCTest
@testable import YumemiFortune

/// Repository層のテスト
final class RepositoryTests: XCTestCase {
    
    // MARK: - Mock Repository
    
    /// テスト用のモックRepository
    class MockFortuneRepository: FortuneRepositoryProtocol {
        var shouldThrowError = false
        var mockPrefecture: Prefecture?
        var fetchFortuneCallCount = 0
        
        func fetchFortune(request: FortuneRequest) async throws -> Prefecture {
            fetchFortuneCallCount += 1
            
            if shouldThrowError {
                throw APIError.networkError(URLError(.notConnectedToInternet))
            }
            
            guard let prefecture = mockPrefecture else {
                throw APIError.unknown
            }
            
            return prefecture
        }
    }
    
    // MARK: - UseCase Tests
    
    func testFetchFortuneUseCaseSuccess() async throws {
        // Given: モックRepositoryを準備
        let mockRepository = MockFortuneRepository()
        mockRepository.mockPrefecture = Prefecture(
            name: "富山県",
            capital: "富山市",
            citizenDay: MonthDay(month: 5, day: 9),
            hasCoastLine: true,
            logoURL: "https://example.com/logo.png",
            brief: "富山県の説明"
        )
        
        let useCase = FetchFortuneUseCase(repository: mockRepository)
        
        // When: UseCaseを実行
        let prefecture = try await useCase.execute(
            name: "テスト太郎",
            birthday: YearMonthDay(year: 2000, month: 1, day: 1),
            bloodType: "a",
            today: YearMonthDay.today
        )
        
        // Then: 正しい結果が返される
        XCTAssertEqual(prefecture.name, "富山県")
        XCTAssertEqual(prefecture.capital, "富山市")
        XCTAssertEqual(mockRepository.fetchFortuneCallCount, 1)
    }
    
    func testFetchFortuneUseCaseInvalidRequest() async {
        // Given: モックRepository
        let mockRepository = MockFortuneRepository()
        let useCase = FetchFortuneUseCase(repository: mockRepository)
        
        // When/Then: 無効なリクエストでエラーが投げられる
        do {
            _ = try await useCase.execute(
                name: "",  // 空の名前
                birthday: YearMonthDay(year: 2000, month: 1, day: 1),
                bloodType: "a"
            )
            XCTFail("エラーが投げられるべき")
        } catch let error as APIError {
            guard case .encodingError = error else {
                XCTFail("encodingErrorが期待される")
                return
            }
            // 成功: バリデーションエラーが投げられた
        } catch {
            XCTFail("APIErrorが期待される")
        }
    }
    
    func testFetchFortuneUseCaseNetworkError() async {
        // Given: エラーを返すモックRepository
        let mockRepository = MockFortuneRepository()
        mockRepository.shouldThrowError = true
        
        let useCase = FetchFortuneUseCase(repository: mockRepository)
        
        // When/Then: ネットワークエラーが伝播される
        do {
            _ = try await useCase.execute(
                name: "テスト太郎",
                birthday: YearMonthDay(year: 2000, month: 1, day: 1),
                bloodType: "a"
            )
            XCTFail("エラーが投げられるべき")
        } catch let error as APIError {
            guard case .networkError = error else {
                XCTFail("networkErrorが期待される")
                return
            }
            // 成功: ネットワークエラーが伝播された
        } catch {
            XCTFail("APIErrorが期待される")
        }
    }
    
    // MARK: - Repository Tests
    
    func testFortuneRepositoryWithMockAPIClient() async throws {
        // Given: モックURLSessionを使ったAPIClient
        let mockSession = MockURLSession()
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
        
        let apiClient = APIClient(session: mockSession)
        let repository = FortuneRepository(apiClient: apiClient)
        
        // When: Repositoryを通してデータを取得
        let request = FortuneRequest(
            name: "テスト太郎",
            birthday: YearMonthDay(year: 2000, month: 1, day: 1),
            bloodType: "a",
            today: YearMonthDay.today
        )
        
        let prefecture = try await repository.fetchFortune(request: request)
        
        // Then: 正しくデータが取得できる
        XCTAssertEqual(prefecture.name, "東京都")
        XCTAssertEqual(prefecture.capital, "新宿区")
        XCTAssertNil(prefecture.citizenDay)
    }
}
