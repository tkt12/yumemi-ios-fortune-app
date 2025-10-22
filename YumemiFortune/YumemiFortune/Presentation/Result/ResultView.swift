//
//  ResultView.swift
//  YumemiFortune
//
//  Created by tkt on 2025/10/21.
//

import SwiftUI
import Kingfisher

/// 占い結果画面
struct ResultView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel: ResultViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Initialization
    
    init(prefecture: Prefecture) {
        _viewModel = StateObject(wrappedValue: ResultViewModel(prefecture: prefecture))
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // ヘッダー
                headerView
                
                // 都道府県情報カード
                prefectureCard
                
                // 詳細情報
                detailsSection
                
                // 概要
                briefSection
            }
            .padding()
        }
        .navigationTitle("占い結果")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text("閉じる")
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    /// ヘッダービュー
    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.fill")
                .font(.system(size: 50))
                .foregroundStyle(.yellow.gradient)
            
            Text("あなたと相性が良いのは...")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text(viewModel.prefectureName)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.primary)
        }
        .padding(.top, 20)
    }
    
    /// 都道府県カード
    private var prefectureCard: some View {
        VStack(spacing: 16) {
            // ロゴ画像
            if let logoURL = viewModel.logoURL {
                KFImage(logoURL)
                    .placeholder {
                        ProgressView()
                    }
                    .retry(maxCount: 3, interval: .seconds(2))
                    .onFailure { _ in
                        // 画像読み込み失敗時はプレースホルダーが表示される
                        // Kingfisherが自動リトライするため追加処理は不要
                    }
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding()
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    /// 詳細情報セクション
    private var detailsSection: some View {
        VStack(spacing: 12) {
            DetailRow(label: "県庁所在地", value: viewModel.capital, icon: "building.2.fill")
            DetailRow(label: "県民の日", value: viewModel.citizenDay, icon: "calendar")
            DetailRow(label: "海岸線", value: viewModel.coastLine, icon: "water.waves")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    /// 概要セクション
    private var briefSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundStyle(.blue)
                Text("概要")
                    .font(.headline)
            }
            
            Text(viewModel.brief)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - DetailRow

/// 詳細情報の行
private struct DetailRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 120, alignment: .leading)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ResultView(
            prefecture: Prefecture(
                name: "富山県",
                capital: "富山市",
                citizenDay: MonthDay(month: 5, day: 9),
                hasCoastLine: true,
                logoURL: "https://japan-map.com/wp-content/uploads/toyama.png",
                brief: "富山県（とやまけん）は、日本の中部地方に位置する県。県庁所在地は富山市。\n中部地方の日本海側、新潟県を含めた場合の北陸地方のほぼ中央にある。"
            )
        )
    }
}
