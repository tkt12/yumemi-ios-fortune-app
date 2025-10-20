//
//  MonthDay.swift
//  YumemiFortune
//
//  Created by tkt on 2025/10/20.
//

import Foundation

/// 月日を表す構造体
/// 都道府県の「県民の日」などで使用
struct MonthDay: Codable, Equatable {
    let month: Int
    let day: Int
    
    // MARK: - Validation
    
    /// 有効な月日かどうかを検証
    var isValid: Bool {
        // 月の範囲チェック
        guard (1...12).contains(month) else { return false }
        
        // 日の範囲チェック
        guard (1...31).contains(day) else { return false }
        
        return true
    }
    
    // MARK: - Formatting
    
    /// "M月d日"形式の文字列を返す
    var formatted: String {
        "\(month)月\(day)日"
    }
}
