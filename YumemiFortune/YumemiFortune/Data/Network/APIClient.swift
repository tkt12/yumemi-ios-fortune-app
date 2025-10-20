//
//  APIClient.swift
//  YumemiFortune
//
//  Created by tkt on 2025/10/20.
//

import Foundation

/// API通信を担当するクライアント
final class APIClient {
    
    // MARK: - Properties
    
    private let session: URLSession
    
    // MARK: - Constants
    
    private enum Constants {
        static let baseURL = "https://yumemi-ios-junior-engineer-codecheck.app.swift.cloud"
        static let endpoint = "/my_fortune"
        static let apiVersion = "v1"
        static let timeoutInterval: TimeInterval = 30
    }
    
    // MARK: - Initialization
    
    /// 初期化
    /// - Parameter session: URLSession（テスト時にモックを注入可能）
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Public Methods
    
    /// 占いAPIを呼び出す
    /// - Parameter request: 占いリクエスト
    /// - Returns: 都道府県情報
    /// - Throws: APIError
    func fetchFortune(request: FortuneRequest) async throws -> Prefecture {
        // 1. URLを構築
        guard let url = buildURL() else {
            throw APIError.invalidURL
        }
        
        // 2. URLRequestを作成
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = Constants.timeoutInterval
        
        // 3. ヘッダーを設定
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(Constants.apiVersion, forHTTPHeaderField: "API-Version")
        
        // 4. リクエストボディをエンコード
        do {
            let encoder = JSONEncoder()
            urlRequest.httpBody = try encoder.encode(request)
        } catch {
            throw APIError.encodingError(error)
        }
        
        // 5. API通信を実行
        let (data, response) = try await performRequest(urlRequest)
        
        // 6. レスポンスを検証
        try validateResponse(response)
        
        // 7. レスポンスをデコード
        do {
            let decoder = JSONDecoder()
            let prefecture = try decoder.decode(Prefecture.self, from: data)
            return prefecture
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    // MARK: - Private Methods
    
    /// URLを構築
    private func buildURL() -> URL? {
        let urlString = Constants.baseURL + Constants.endpoint
        return URL(string: urlString)
    }
    
    /// リクエストを実行
    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    /// HTTPレスポンスを検証
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // ステータスコードが200番台以外ならエラー
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
    }
}
