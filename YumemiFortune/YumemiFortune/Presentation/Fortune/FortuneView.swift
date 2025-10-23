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
            .navigationTitle("都道府県相性占い")
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
    }
    
    // MARK: - Subviews
    
    /// ヘッダービュー
    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)
            
            Text("あなたと相性の良い都道府県を占います")
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
                Text("名前")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                TextField("山田太郎", text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.name)
            }
            
            // 生年月日入力
            VStack(alignment: .leading, spacing: 8) {
                Text("生年月日")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                DatePicker(
                    "生年月日",
                    selection: $viewModel.birthday,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
            }
            
            // 血液型選択
            VStack(alignment: .leading, spacing: 8) {
                Text("血液型")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Picker("血液型", selection: $viewModel.bloodType) {
                    Text("A型").tag("a")
                    Text("B型").tag("b")
                    Text("AB型").tag("ab")
                    Text("O型").tag("o")
                }
                .pickerStyle(.segmented)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))  // ダークモード対応
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
                Text("占う")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                viewModel.isSubmitButtonEnabled
                ? Color.accentColor  // システムのアクセントカラー（自動対応）
                : Color(.systemGray3)
            )
            .foregroundStyle(.white)
            .cornerRadius(12)
        }
        .disabled(!viewModel.isSubmitButtonEnabled)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isSubmitButtonEnabled)
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
                
                Text("占い中...")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))  // ダークモード対応
            )
            .shadow(radius: 20)
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
