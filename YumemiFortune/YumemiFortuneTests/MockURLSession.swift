//
//  MockURLSession.swift
//  YumemiFortuneTests
//
//  Created by tkt on 2025/10/21.
//

import Foundation
@testable import YumemiFortune

/// テスト用のモックURLSession
/// APIClientのテストで使用し、実際のネットワーク通信をシミュレートする
final class MockURLSession: URLSessionProtocol {
    
    // MARK: - Properties
    
    /// 返すデータ（正常系のレスポンスボディ）
    var data: Data?
    
    /// 返すレスポンス（HTTPステータスコードなど）
    var response: URLResponse?
    
    /// 返すエラー（エラー系のテスト用）
    var error: Error?
    
    // MARK: - URLSessionProtocol
    
    /// URLSessionProtocol.data(for:)の実装
    /// 設定されたdata/response/errorを返す
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        // エラーが設定されていればそれを投げる
        if let error = error {
            throw error
        }
        
        // dataとresponseが両方設定されていればそれを返す
        guard let data = data, let response = response else {
            throw URLError(.unknown)
        }
        
        return (data, response)
    }
}
