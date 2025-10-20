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
    
    /// APIクライアントを初期化
    /// - Parameter session: URLSession（テスト時にモックを注入可能）
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Public Methods
    
    /// 占いAPIを呼び出して都道府県情報を取得する
    ///
    /// このメソッドはYumemi占いAPIにPOSTリクエストを送信し、
    /// ユーザーの情報に基づいて相性の良い都道府県を取得します。
    ///
    /// - Parameter request: 占いリクエスト（名前、誕生日、血液型、今日の日付を含む）
    /// - Returns: 都道府県情報（名前、県庁所在地、県民の日、海岸線有無、ロゴURL、概要）
    ///
    /// - Throws:
    ///   - `APIError.invalidURL`: URLの構築に失敗した場合
    ///   - `APIError.encodingError`: リクエストボディのエンコードに失敗した場合
    ///   - `APIError.networkError`: ネットワークエラーが発生した場合
    ///   - `APIError.invalidResponse`: レスポンスが無効な場合
    ///   - `APIError.httpError`: HTTPステータスコードが200番台以外の場合
    ///   - `APIError.decodingError`: レスポンスのデコードに失敗した場合
    ///
    /// - Note:
    ///   - HTTPヘッダー:
    ///     - `Content-Type: application/json`
    ///     - `Accept: application/json`
    ///     - `API-Version: v1`
    ///   - タイムアウト: 30秒
    ///
    /// - Example:
    /// ```swift
    /// let request = FortuneRequest(
    ///     name: "山田太郎",
    ///     birthday: YearMonthDay(year: 2000, month: 1, day: 1),
    ///     bloodType: "a",
    ///     today: YearMonthDay.today
    /// )
    ///
    /// do {
    ///     let prefecture = try await apiClient.fetchFortune(request: request)
    ///     print(prefecture.name) // "東京都"
    /// } catch {
    ///     print(error.localizedDescription)
    /// }
    /// ```
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
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
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
    
    /// URLを構築（安全なパス結合）
    private func buildURL() -> URL? {
        guard let baseURL = URL(string: Constants.baseURL) else {
            return nil
        }
        
        // スラッシュを除去してから安全に結合
        let endpoint = Constants.endpoint.trimmingCharacters(
            in: CharacterSet(charactersIn: "/")
        )
        
        return baseURL.appendingPathComponent(endpoint)
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
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
    }
}
