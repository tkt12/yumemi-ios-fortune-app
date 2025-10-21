//
//  URLSessionProtocol.swift
//  YumemiFortune
//
//  Created by tkt on 2025/10/21.
//

import Foundation

/// URLSessionの機能を抽象化したプロトコル
/// テスト時にモックを注入できるようにする
protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

// MARK: - URLSession Extension

/// 実際のURLSessionをプロトコルに準拠させる
extension URLSession: URLSessionProtocol {
    // URLSessionはすでにdata(for:)を持っているので、何も実装する必要なし
}
