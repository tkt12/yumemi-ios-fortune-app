//
//  FortuneRepository.swift
//  YumemiFortune
//
//  Created by tkt on 2025/10/21.
//

import Foundation

// MARK: - Protocol

/// 占いデータの取得を抽象化するリポジトリプロトコル
protocol FortuneRepositoryProtocol {
    func fetchFortune(request: FortuneRequest) async throws -> Prefecture
}

// MARK: - Implementation

/// FortuneRepositoryの実装
final class FortuneRepository: FortuneRepositoryProtocol {
    
    // MARK: - Properties
    
    private let apiClient: APIClient
    
    // MARK: - Initialization
    
    /// リポジトリを初期化
    /// - Parameter apiClient: APIClient（依存性注入、デフォルト値なし）
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - Factory Method
    
    /// プロダクション用のデフォルトインスタンスを生成
    /// - Returns: デフォルト設定のFortuneRepository
    static func makeDefault() -> FortuneRepository {
        return FortuneRepository(apiClient: APIClient())
    }
    
    // MARK: - FortuneRepositoryProtocol
    
    func fetchFortune(request: FortuneRequest) async throws -> Prefecture {
        return try await apiClient.fetchFortune(request: request)
    }
}
