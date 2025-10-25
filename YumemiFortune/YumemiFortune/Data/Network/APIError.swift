//
//  APIError.swift
//  YumemiFortune
//
//  Created by tkt on 2025/10/20.
//

import Foundation

/// API通信で発生するエラー
enum APIError: Error, CustomDebugStringConvertible {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case encodingError(Error)
    case validationError(String)
    case unknown
    
    // MARK: - User Friendly Message
    
    /// ユーザーに表示するエラーメッセージ
    var message: String {
        switch self {
        case .invalidURL:
            return "error.invalidURL".localized()
        case .networkError:
            return "error.network".localized()
        case .invalidResponse:
            return "error.invalidResponse".localized()
        case .httpError(let statusCode):
            // ステータスコードの範囲で適切なメッセージを返す
            if (400...499).contains(statusCode) {
                return String(format: "error.client".localized(), statusCode)
            } else if (500...599).contains(statusCode) {
                return "error.server".localized()
            } else {
                return String(format: "error.http".localized(), statusCode)
            }
        case .decodingError:
            return "error.decoding".localized()
        case .encodingError:
            return "error.encoding".localized()
        case .validationError(let message):
            return message
        case .unknown:
            return "error.unknown".localized()
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
        case .validationError(let message):
            return "Validation error: \(message)"
        case .unknown:
            return "Unknown error"
        }
    }
}

// MARK: - LocalizedError

extension APIError: LocalizedError {
    /// ユーザー向けのエラー説明（localizedDescriptionで取得可能）
    var errorDescription: String? {
        message
    }
}
