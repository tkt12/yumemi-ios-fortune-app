//
//  MonthDay.swift
//  YumemiFortune
//
//  Created by tkt on 2025/10/20.
//

import Foundation

/// 月日を表す構造体
/// 都道府県の「県民の日」などで使用
struct MonthDay: Codable, Equatable, Sendable {
    let month: Int
    let day: Int
    
    // MARK: - Validation
    
    /// 有効な月日かどうかを検証
    var isValid: Bool {
        // 月の範囲チェック（1〜12月）
        guard (1...12).contains(month) else { return false }
        
        // 日の範囲チェック（1〜31日）
        guard (1...31).contains(day) else { return false }
        
        // 実際のカレンダー上で有効な日付かチェック
        var components = DateComponents()
        components.year = 2000  // うるう年を使用して2月29日を許可
        components.month = month
        components.day = day
        
        // Calendarで実際に日付を作成できるかチェック
        guard let date = Calendar.current.date(from: components) else {
            return false
        }
        
        // 作成された日付が指定した月日と一致するか確認
        // （Calendarが自動補正していないかチェック）
        let resultComponents = Calendar.current.dateComponents([.month, .day], from: date)
        return resultComponents.month == month && resultComponents.day == day
    }
    
    // MARK: - Formatting
    
    /// "M月d日"形式の文字列を返す
    var formatted: String {
        "\(month)月\(day)日"
    }
}
