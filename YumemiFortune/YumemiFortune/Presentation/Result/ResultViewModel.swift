//
//  ResultViewModel.swift
//  YumemiFortune
//
//  Created by tkt on 2025/10/21.
//

import Foundation
import Combine

/// 占い結果画面のViewModel
@MainActor
final class ResultViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 都道府県情報
    @Published private(set) var prefecture: Prefecture
    
    // MARK: - Computed Properties
    
    /// 都道府県名
    var prefectureName: String {
        prefecture.name
    }
    
    /// 県庁所在地
    var capital: String {
        prefecture.capital
    }
    
    /// 県民の日（表示用）
    var citizenDay: String {
        prefecture.citizenDayText
    }
    
    /// 海岸線の有無（表示用）
    var coastLine: String {
        prefecture.coastLineText
    }
    
    /// ロゴURL
    var logoURL: URL? {
        URL(string: prefecture.logoURL)
    }
    
    /// 概要
    var brief: String {
        prefecture.brief
    }
    
    // MARK: - Initialization
    
    /// ViewModelを初期化
    /// - Parameter prefecture: 都道府県情報
    init(prefecture: Prefecture) {
        self.prefecture = prefecture
    }
}
