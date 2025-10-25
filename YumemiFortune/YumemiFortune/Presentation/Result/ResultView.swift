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
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    // MARK: - Initialization
    
    init(prefecture: Prefecture) {
        _viewModel = StateObject(wrappedValue: ResultViewModel(prefecture: prefecture))
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 背景色（ダークモード対応）
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
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
        }
        .navigationTitle("result.title".localized())
        .navigationBarTitleDisplayMode(.inline)
        .id(localizationManager.currentLanguage)
    }
    
    // MARK: - Subviews
    
    /// ヘッダービュー
    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("result.header.message".localized())
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
                            .tint(Color.accentColor)
                    }
                    .retry(maxCount: 3, interval: .seconds(2))
                    .onFailure { _ in
                        // Kingfisherの自動リトライとプレースホルダー表示により、
                        // 追加のエラーハンドリングは不要
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
                .fill(Color("CardBackground"))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    /// 詳細情報セクション
    private var detailsSection: some View {
        VStack(spacing: 12) {
            DetailRow(
                label: "result.detail.capital".localized(),
                value: viewModel.capital,
                icon: "building.2.fill"
            )
            DetailRow(
                label: "result.detail.citizenday".localized(),
                value: viewModel.citizenDay,
                icon: "calendar"
            )
            DetailRow(
                label: "result.detail.coastline".localized(),
                value: viewModel.coastLine,
                icon: "water.waves"
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CardBackground"))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    /// 概要セクション
    private var briefSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundStyle(Color.accentColor)
                Text("result.brief.title".localized())
                    .font(.headline)
                    .foregroundStyle(.primary)
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
                .fill(Color("CardBackground"))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
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
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - Preview

#Preview("Light Mode") {
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
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
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
    .preferredColorScheme(.dark)
}
