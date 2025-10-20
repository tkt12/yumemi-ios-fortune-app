//
//  APIError.swift
//  YumemiFortune
//
//  Created by tkt on 2025/10/20.
//

import Foundation

/// API通信で発生するエラー
enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case encodingError(Error)
    case unknown
    
    // MARK: - User Friendly Message
    
    /// ユーザーに表示するエラーメッセージ
    var message: String {
        switch self {
        case .invalidURL:
            return "無効なURLです"
        case .networkError:
            return "ネットワーク接続を確認してください"
        case .invalidResponse:
            return "サーバーからの応答が無効です"
        case .httpError(let statusCode):
            return "サーバーエラーが発生しました（ステータスコード: \(statusCode)）"
        case .decodingError:
            return "データの解析に失敗しました"
        case .encodingError:
            return "リクエストの作成に失敗しました"
        case .unknown:
            return "不明なエラーが発生しました"
        }
    }
    
    // MARK: - Debug Description
    
    /// デバッグ用の詳細メッセージ
    var debugDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Encoding error: \(error.localizedDescription)"
        case .unknown:
            return "Unknown error"
        }
    }
}
