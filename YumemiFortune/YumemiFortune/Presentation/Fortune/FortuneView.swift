//
//  ContentView.swift
//  YumemiFortune
//
//  Created by tkt on 2025/10/20.
//

import SwiftUI

/// 占い入力画面
struct FortuneView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = FortuneViewModel.makeDefault()
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var showingResult = false
    @State private var showingError = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景色（ダークモード対応）
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                // メインコンテンツ
                ScrollView {
                    VStack(spacing: 24) {
                        // ヘッダー
                        headerView
                        
                        // 入力フォーム
                        inputForm
                        
                        // 占うボタン
                        fortuneButton
                    }
                    .padding()
                }
                
                // ローディングオーバーレイ
                if viewModel.isLoading {
                    loadingOverlay
                }
            }
            .navigationTitle("fortune.title".localized())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    LanguageToggleButton()
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .alert("エラー", isPresented: $showingError) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .navigationDestination(isPresented: $showingResult) {
                if let prefecture = viewModel.fortune {
                    ResultView(prefecture: prefecture)
                }
            }
            .onChange(of: viewModel.fortune) { _, newValue in
                if newValue != nil {
                    showingResult = true
                }
            }
            .onChange(of: viewModel.errorMessage) { _, newValue in
                showingError = newValue != nil
            }
        }
        .id(localizationManager.currentLanguage) // 言語変更時に再描画
    }
    
    // MARK: - Subviews
    
    /// ヘッダービュー
    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("fortune.header.message".localized())
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    /// 入力フォーム
    private var inputForm: some View {
        VStack(spacing: 20) {
            // 名前入力
            VStack(alignment: .leading, spacing: 8) {
                Text("fortune.input.name.label".localized())
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                TextField("fortune.input.name.placeholder".localized(), text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.name)
            }
            
            // 生年月日入力
            VStack(alignment: .leading, spacing: 8) {
                Text("fortune.input.birthday.label".localized())
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                DatePicker(
                    "fortune.input.birthday.label".localized(),
                    selection: $viewModel.birthday,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
            }
            
            // 血液型選択
            VStack(alignment: .leading, spacing: 8) {
                Text("fortune.input.bloodtype.label".localized())
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Picker("fortune.input.bloodtype.label".localized(), selection: $viewModel.bloodType) {
                    Text("fortune.input.bloodtype.a".localized()).tag("a")
                    Text("fortune.input.bloodtype.b".localized()).tag("b")
                    Text("fortune.input.bloodtype.ab".localized()).tag("ab")
                    Text("fortune.input.bloodtype.o".localized()).tag("o")
                }
                .pickerStyle(.segmented)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("CardBackground"))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    /// 占うボタン
    private var fortuneButton: some View {
        Button {
            viewModel.fetchFortune()
        } label: {
            HStack {
                Image(systemName: "sparkles")
                Text("fortune.button.submit".localized())
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                (viewModel.isSubmitButtonEnabled
                 ? Color.accentColor
                 : Color(.systemGray3))
                .animation(.easeInOut(duration: 0.2), value: viewModel.isSubmitButtonEnabled)
            )
            .foregroundStyle(.white)
            .cornerRadius(12)
        }
        .disabled(!viewModel.isSubmitButtonEnabled)
    }
    
    /// ローディングオーバーレイ
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("fortune.loading.message".localized())
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("CardBackground"))
            )
            .shadow(color: Color.black.opacity(0.3), radius: 20)
        }
    }
}

// MARK: - Preview

#Preview("Light Mode") {
    FortuneView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    FortuneView()
        .preferredColorScheme(.dark)
}
