//
//  Prefecture.swift
//  YumemiFortune
//
//  Created by tkt on 2025/10/20.
//

import Foundation

/// 都道府県情報のレスポンスモデル
struct Prefecture: Codable, Equatable, Sendable {
    let name: String
    let capital: String
    let citizenDay: MonthDay?  // 県民の日がない県もあるからOptional
    let hasCoastLine: Bool
    let logoURL: String
    let brief: String
    
    // MARK: - CodingKeys
    
    /// APIのキー名とSwiftのプロパティ名をマッピング
    enum CodingKeys: String, CodingKey {
        case name
        case capital
        case citizenDay = "citizen_day"
        case hasCoastLine = "has_coast_line"
        case logoURL = "logo_url"
        case brief
    }
    
    // MARK: - Computed Properties
    
    /// 県民の日の表示用テキスト
    var citizenDayText: String {
        if let citizenDay = citizenDay {
            return citizenDay.formatted
        } else {
            return "なし"
        }
    }
    
    /// 海岸線の有無の表示用テキスト
    var coastLineText: String {
        hasCoastLine ? "あり" : "なし"
    }
}
