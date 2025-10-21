//
//  FortuneRepository.swift
//  YumemiFortune
//
//  Created by tkt on 2025/10/21.
//

import Foundation

// MARK: - Protocol

/// 占いデータの取得を抽象化するリポジトリプロトコル
///
/// このプロトコルを使用することで:
/// - ViewModelがデータソースの詳細を知る必要がなくなる
/// - テスト時にモックを注入しやすくなる
/// - 将来のデータソース変更（キャッシュ追加など）が容易になる
protocol FortuneRepositoryProtocol {
    /// 占い結果を取得する
    /// - Parameter request: 占いリクエスト
    /// - Returns: 都道府県情報
    /// - Throws: APIError
    func fetchFortune(request: FortuneRequest) async throws -> Prefecture
}

// MARK: - Implementation

/// FortuneRepositoryの実装
/// APIClientを使用してデータを取得する
final class FortuneRepository: FortuneRepositoryProtocol {
    
    // MARK: - Properties
    
    private let apiClient: APIClient
    
    // MARK: - Initialization
    
    /// リポジトリを初期化
    /// - Parameter apiClient: APIClient（依存性注入）
    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }
    
    // MARK: - FortuneRepositoryProtocol
    
    /// 占い結果を取得する
    ///
    /// APIClientを使用してサーバーから占い結果を取得します。
    /// 将来的にはキャッシュ機能などを追加できます。
    ///
    /// - Parameter request: 占いリクエスト
    /// - Returns: 都道府県情報
    /// - Throws: APIError
    func fetchFortune(request: FortuneRequest) async throws -> Prefecture {
        // 現在はAPIClientをそのまま呼び出すだけ
        // 将来的にはここにキャッシュロジックなどを追加できる
        return try await apiClient.fetchFortune(request: request)
    }
}
