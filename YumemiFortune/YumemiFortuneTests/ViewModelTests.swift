//
//  ViewModelTests.swift
//  YumemiFortuneTests
//
//  Created by tkt on 2025/10/21.
//

import XCTest
import Combine
@testable import YumemiFortune

/// ViewModel層のテスト
@MainActor
final class ViewModelTests: XCTestCase {
    
    // MARK: - FortuneViewModel Tests
    
    func testFortuneViewModelInitialState() {
        // Given
        let mockRepository = MockFortuneRepository()
        let useCase = FetchFortuneUseCase(repository: mockRepository)
        let viewModel = FortuneViewModel(useCase: useCase)
        
        // Then
        XCTAssertEqual(viewModel.name, "")
        XCTAssertEqual(viewModel.bloodType, "a")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.fortune)
    }
    
    func testFortuneViewModelSubmitButtonEnabled() {
        // Given
        let mockRepository = MockFortuneRepository()
        let useCase = FetchFortuneUseCase(repository: mockRepository)
        let viewModel = FortuneViewModel(useCase: useCase)
        
        // When: 名前が空
        viewModel.name = ""
        
        // Then: ボタンが無効
        XCTAssertFalse(viewModel.isSubmitButtonEnabled)
        
        // When: 名前を入力
        viewModel.name = "テスト太郎"
        
        // Then: ボタンが有効
        XCTAssertTrue(viewModel.isSubmitButtonEnabled)
    }
    
    func testFortuneViewModelFetchFortuneSuccess() async {
        // Given
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
        let viewModel = FortuneViewModel(useCase: useCase)
        
        // When
        viewModel.name = "テスト太郎"
        viewModel.bloodType = "a"
        viewModel.fetchFortune()
        
        // 非同期処理を待つ
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.fortune?.name, "富山県")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testFortuneViewModelFetchFortuneNetworkError() async {
        // Given
        let mockRepository = MockFortuneRepository()
        mockRepository.shouldThrowError = true
        
        let useCase = FetchFortuneUseCase(repository: mockRepository)
        let viewModel = FortuneViewModel(useCase: useCase)
        
        // When
        viewModel.name = "テスト太郎"
        viewModel.bloodType = "a"
        viewModel.fetchFortune()
        
        // 非同期処理を待つ
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.fortune)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testFortuneViewModelFetchFortuneValidationError() async {
        // Given
        let mockRepository = MockFortuneRepository()
        let useCase = FetchFortuneUseCase(repository: mockRepository)
        let viewModel = FortuneViewModel(useCase: useCase)
        
        // When: 空の名前で実行
        viewModel.name = ""
        viewModel.bloodType = "a"
        viewModel.fetchFortune()
        
        // 非同期処理を待つ
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.fortune)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testFortuneViewModelClearError() {
        // Given
        let mockRepository = MockFortuneRepository()
        let useCase = FetchFortuneUseCase(repository: mockRepository)
        let viewModel = FortuneViewModel(useCase: useCase)
        
        // テスト用ヘルパーを使用
        viewModel.setErrorMessage("テストエラー")
        
        // When
        viewModel.clearError()
        
        // Then
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFortuneViewModelClearFortune() {
        // Given
        let mockRepository = MockFortuneRepository()
        let useCase = FetchFortuneUseCase(repository: mockRepository)
        let viewModel = FortuneViewModel(useCase: useCase)
        
        let prefecture = Prefecture(
            name: "富山県",
            capital: "富山市",
            citizenDay: nil,
            hasCoastLine: true,
            logoURL: "https://example.com/logo.png",
            brief: "説明"
        )
        
        // テスト用ヘルパーを使用
        viewModel.setFortune(prefecture)
        
        // When
        viewModel.clearFortune()
        
        // Then
        XCTAssertNil(viewModel.fortune)
    }
    
    // MARK: - ResultViewModel Tests
    
    func testResultViewModelProperties() {
        // Given
        let prefecture = Prefecture(
            name: "富山県",
            capital: "富山市",
            citizenDay: MonthDay(month: 5, day: 9),
            hasCoastLine: true,
            logoURL: "https://japan-map.com/wp-content/uploads/toyama.png",
            brief: "富山県は日本の中部地方に位置する県。"
        )
        
        // When
        let viewModel = ResultViewModel(prefecture: prefecture)
        
        // Then
        XCTAssertEqual(viewModel.prefectureName, "富山県")
        XCTAssertEqual(viewModel.capital, "富山市")
        XCTAssertEqual(viewModel.citizenDay, "5月9日")
        XCTAssertEqual(viewModel.coastLine, "あり")
        XCTAssertNotNil(viewModel.logoURL)
        XCTAssertTrue(viewModel.brief.contains("富山県"))
    }
    
    func testResultViewModelWithoutCitizenDay() {
        // Given
        let prefecture = Prefecture(
            name: "東京都",
            capital: "新宿区",
            citizenDay: nil,
            hasCoastLine: true,
            logoURL: "https://example.com/tokyo.png",
            brief: "東京都の説明"
        )
        
        // When
        let viewModel = ResultViewModel(prefecture: prefecture)
        
        // Then
        XCTAssertEqual(viewModel.citizenDay, "なし")
    }
    
    func testResultViewModelWithoutCoastLine() {
        // Given
        let prefecture = Prefecture(
            name: "埼玉県",
            capital: "さいたま市",
            citizenDay: nil,
            hasCoastLine: false,
            logoURL: "https://example.com/saitama.png",
            brief: "埼玉県の説明"
        )
        
        // When
        let viewModel = ResultViewModel(prefecture: prefecture)
        
        // Then
        XCTAssertEqual(viewModel.coastLine, "なし")
    }
    
    // MARK: - Helper: MockFortuneRepository
    
    class MockFortuneRepository: FortuneRepositoryProtocol {
        var shouldThrowError = false
        var mockPrefecture: Prefecture?
        
        func fetchFortune(request: FortuneRequest) async throws -> Prefecture {
            if shouldThrowError {
                throw APIError.networkError(URLError(.notConnectedToInternet))
            }
            
            guard let prefecture = mockPrefecture else {
                throw APIError.unknown
            }
            
            return prefecture
        }
    }
}
