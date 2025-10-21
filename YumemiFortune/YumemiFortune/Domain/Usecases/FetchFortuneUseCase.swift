//
//  FetchFortuneUseCase.swift
//  YumemiFortune
//
//  Created by tkt on 2025/10/21.
//

import Foundation

/// 占い結果を取得するユースケース
final class FetchFortuneUseCase {
    
    // MARK: - Properties
    
    private let repository: FortuneRepositoryProtocol
    
    // MARK: - Initialization
    
    /// ユースケースを初期化
    /// - Parameter repository: 占いリポジトリ（依存性注入、デフォルト値なし）
    init(repository: FortuneRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Factory Method
    
    /// プロダクション用のデフォルトインスタンスを生成
    /// - Returns: デフォルト設定のFetchFortuneUseCase
    static func makeDefault() -> FetchFortuneUseCase {
        return FetchFortuneUseCase(repository: FortuneRepository.makeDefault())
    }
    
    // MARK: - Public Methods
    
    /// 占い結果を取得する
    func execute(
        name: String,
        birthday: YearMonthDay,
        bloodType: String,
        today: YearMonthDay = .today
    ) async throws -> Prefecture {
        // リクエストを構築
        let request = FortuneRequest(
            name: name,
            birthday: birthday,
            bloodType: bloodType,
            today: today
        )
        
        // バリデーション
        guard request.isValid else {
            throw APIError.validationError("入力内容が正しくありません")
        }
        
        // リポジトリからデータを取得
        return try await repository.fetchFortune(request: request)
    }
}
