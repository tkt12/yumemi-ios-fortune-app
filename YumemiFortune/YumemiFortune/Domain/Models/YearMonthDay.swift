//
//  YearMonthDay.swift
//  YumemiFortune
//
//  Created by tkt on 2025/10/20.
//

import Foundation

/// 年月日を表す構造体
/// APIリクエストで使用する日付フォーマット
struct YearMonthDay: Codable, Equatable {
    let year: Int
    let month: Int
    let day: Int
    
    // MARK: - Validation
    
    /// 有効な日付かどうかを検証
    var isValid: Bool {
        // 月の範囲チェック
        guard (1...12).contains(month) else { return false }
        
        // 日の範囲チェック（おおまかに）
        guard (1...31).contains(day) else { return false }
        
        // 実際にDateに変換できるかチェック
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        
        // Calendarで実際に日付を作れるかチェック
        guard let date = Calendar.current.date(from: components) else {
            return false
        }
        
        // 作成した日付が指定した年月日と一致するか確認
        // （例: 2月30日を指定すると3月2日になってしまうのを防ぐ）
        let resultComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return resultComponents.year == year &&
        resultComponents.month == month &&
        resultComponents.day == day
    }
    
    // MARK: - Initialization
    
    /// 今日の日付で初期化
    static var today: YearMonthDay {
        let now = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        
        return YearMonthDay(year: year, month: month, day: day)
    }
    
    /// Dateから初期化
    init(from date: Date) {
        let calendar = Calendar.current
        self.year = calendar.component(.year, from: date)
        self.month = calendar.component(.month, from: date)
        self.day = calendar.component(.day, from: date)
    }
    
    /// 直接指定で初期化
    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }
}
