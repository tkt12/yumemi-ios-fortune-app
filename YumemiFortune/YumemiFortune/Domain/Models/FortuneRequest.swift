//
//  FortuneRequest.swift
//  YumemiFortune
//
//  Created by tkt on 2025/10/20.
//

import Foundation

/// 占いAPIへのリクエストモデル
struct FortuneRequest: Codable {
    let name: String
    let birthday: YearMonthDay
    let bloodType: String
    let today: YearMonthDay
    
    // MARK: - CodingKeys
    
    /// APIのキー名（snake_case）とSwiftのプロパティ名（camelCase）をマッピング
    enum CodingKeys: String, CodingKey {
        case name
        case birthday
        case bloodType = "blood_type"
        case today
    }
    
    // MARK: - Validation
    
    /// リクエストが有効かどうかを検証
    var isValid: Bool {
        // 名前が空でないこと
        guard !name.isEmpty else { return false }
        
        // 日付が有効であること
        guard birthday.isValid, today.isValid else { return false }
        
        // 血液型が正しいこと
        let validBloodTypes = ["a", "b", "ab", "o"]
        guard validBloodTypes.contains(bloodType.lowercased()) else {
            return false
        }
        
        // 誕生日が今日より未来でないこと
        guard !isBirthdayInFuture else { return false }
        
        return true
    }
    
    /// 誕生日が未来の日付かどうか
    private var isBirthdayInFuture: Bool {
        if birthday.year > today.year {
            return true
        } else if birthday.year == today.year {
            if birthday.month > today.month {
                return true
            } else if birthday.month == today.month {
                return birthday.day > today.day
            }
        }
        return false
    }
}
