//
//  FortuneViewModel.swift
//  YumemiFortune
//
//  Created by tkt on 2025/10/21.
//

import Foundation
import Combine

/// 占い入力画面のViewModel
@MainActor
final class FortuneViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 名前
    @Published var name: String = ""
    
    /// 生年月日
    @Published var birthday: Date = Date()
    
    /// 血液型（a, b, ab, o）
    @Published var bloodType: String = "a"
    
    /// ローディング中かどうか
    @Published private(set) var isLoading: Bool = false
    
    /// エラーメッセージ
    @Published private(set) var errorMessage: String?
    
    /// 占い結果
    @Published private(set) var fortune: Prefecture?
    
    // MARK: - Private Properties
    
    private let useCase: FetchFortuneUseCase
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    /// 占うボタンが有効かどうか
    var isSubmitButtonEnabled: Bool {
        !name.isEmpty && !isLoading
    }
    
    // MARK: - Initialization
    
    /// ViewModelを初期化
    /// - Parameter useCase: FetchFortuneUseCase（依存性注入）
    init(useCase: FetchFortuneUseCase) {
        self.useCase = useCase
    }
    
    /// プロダクション用のデフォルトインスタンスを生成
    static func makeDefault() -> FortuneViewModel {
        return FortuneViewModel(useCase: FetchFortuneUseCase.makeDefault())
    }
    
    // MARK: - Public Methods
    
    /// 占いを実行する
    func fetchFortune() {
        // 既にローディング中なら何もしない
        guard !isLoading else { return }
        
        // エラーをクリア
        errorMessage = nil
        fortune = nil
        
        // ローディング開始
        isLoading = true
        
        Task {
            do {
                // 生年月日をYearMonthDayに変換
                let birthdayYMD = YearMonthDay(from: birthday)
                
                // UseCaseを実行
                let result = try await useCase.execute(
                    name: name,
                    birthday: birthdayYMD,
                    bloodType: bloodType.lowercased()
                )
                
                // 成功: 結果を設定
                fortune = result
                
            } catch let error as APIError {
                // APIエラー: ユーザーフレンドリーなメッセージを表示
                errorMessage = error.message
            } catch {
                // その他のエラー
                errorMessage = "予期しないエラーが発生しました"
            }
            
            // ローディング終了
            isLoading = false
        }
    }
    
    /// エラーを消去
    func clearError() {
        errorMessage = nil
    }
    
    /// 結果をクリア
    func clearFortune() {
        fortune = nil
    }
    
    // MARK: - Testing Helpers
    
#if DEBUG
    /// テスト用: エラーメッセージを直接設定
    /// - Parameter message: エラーメッセージ
    func setErrorMessage(_ message: String?) {
        self.errorMessage = message
    }
    
    /// テスト用: 占い結果を直接設定
    /// - Parameter prefecture: 都道府県情報
    func setFortune(_ prefecture: Prefecture?) {
        self.fortune = prefecture
    }
#endif
}
