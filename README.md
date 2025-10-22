# 都道府県相性占いアプリ

<div align="center">
  <img src="https://img.shields.io/badge/Swift-6.1.2-orange.svg" />
  <img src="https://img.shields.io/badge/iOS-18.5+-blue.svg" />
  <img src="https://img.shields.io/badge/Xcode-16.4-blue.svg" />
</div>

## 📱 概要

ゆめみiOSコーディングテストの課題として作成した、ユーザーの名前・生年月日・血液型から相性の良い都道府県を占うiOSアプリです。

## ✨ 機能

### 入力画面
- 名前入力
- 生年月日選択（DatePicker）
- 血液型選択（A/B/AB/O型）
- リアルタイムバリデーション
- ローディング表示
- エラーアラート

### 結果画面
- 都道府県名の表示
- 都道府県ロゴ画像（Kingfisher使用）
- 詳細情報
  - 県庁所在地
  - 県民の日
  - 海岸線の有無
- 都道府県の概要
- スクロール対応

## 🏗️ アーキテクチャ

### 採用パターン
**MVVM + Repository Pattern + Clean Architecture**
```
┌─────────────────────────────┐
│   Presentation Layer        │
│   - View (SwiftUI)          │
│   - ViewModel               │
└─────────────────────────────┘
            ↓
┌─────────────────────────────┐
│   Domain Layer              │
│   - Models                  │
│   - UseCases                │
└─────────────────────────────┘
            ↓
┌─────────────────────────────┐
│   Data Layer                │
│   - Repository              │
│   - APIClient               │
└─────────────────────────────┘
```

### レイヤー構成

| レイヤー | 責務 | 主要コンポーネント |
|---------|------|------------------|
| **Presentation** | UI表示、ユーザー操作、状態管理 | FortuneView, ResultView, ViewModels |
| **Domain** | ビジネスロジック、データモデル | Models, UseCases |
| **Data** | データ取得、API通信 | Repository, APIClient |

### データフロー
```
ユーザー操作
    ↓
View (SwiftUI)
    ↓
ViewModel (@Published)
    ↓
UseCase (ビジネスロジック)
    ↓
Repository (抽象化)
    ↓
APIClient (HTTP通信)
    ↓
API Server
```

## 🛠️ 技術スタック

### 言語・フレームワーク
- Swift 6.1.2
- SwiftUI
- Combine
- async/await

### ライブラリ（SPM）
- **Kingfisher**: 画像の非同期読み込み・キャッシング

### 開発ツール
- Xcode 16.4
- Git / GitHub

## 📦 セットアップ

### 必要要件
- macOS 15.0以降
- Xcode 16.0以降
- iOS 18.5以降のデバイスまたはシミュレータ

### インストール手順

1. **リポジトリをクローン**
```bash
git clone https://github.com/tkt12/yumemi-ios-fortune-app
cd yumemi-ios-fortune-app
```

2. **Xcodeでプロジェクトを開く**
```bash
open YumemiFortune/YumemiFortune.xcodeproj
```

3. **依存ライブラリの自動ダウンロード**
   - SPMが自動的にKingfisherをダウンロードします
   - 初回ビルド時に少し時間がかかります

4. **ビルド＆実行**
   - Command + R でアプリを起動

## 🎨 工夫した点

### アーキテクチャ設計
- **Clean Architecture**で責務を明確に分離
  - Presentation層、Domain層、Data層の3層構造
  - 各層の依存関係を一方向に保つ
- **Protocol-Oriented Programming**でテスタビリティを向上
  - `FortuneRepositoryProtocol`でデータソースを抽象化
  - `URLSessionProtocol`でネットワーク層をモック可能に
- **依存性注入（DI）**で疎結合な設計
  - ファクトリーメソッド（`makeDefault()`）でプロダクション用インスタンスを提供
  - テスト時はモックを注入

### コード品質
- **ユニットテスト**を各レイヤーに実装
  - モデル層: Codable、バリデーションのテスト
  - Repository層: データ取得ロジックのテスト
  - ViewModel層: 状態管理とビジネスロジックのテスト
  - APIClient層: HTTP通信とエラーハンドリングのテスト
- **エラーハンドリング**を徹底
  - 独自の`APIError`型で詳細なエラー分類
  - ユーザーフレンドリーなエラーメッセージ
  - HTTPステータスコード別のエラーメッセージ（4xx: クライアントエラー、5xx: サーバーエラー）
- **型安全性**を重視
  - Codableで型安全なJSON変換
  - Enumで状態を表現
  - `@MainActor`でメインスレッド実行を保証

### UI/UX
- **Human Interface Guidelines**に準拠
  - タップ領域を44pt以上確保
  - システムカラーとSF Symbolsを使用
  - Safe Areaを考慮したレイアウト
- **視覚的フィードバック**
  - ローディング中は半透明オーバーレイで明確に表示
  - エラー時はアラートで適切に通知
- **リアルタイムバリデーション**
  - 名前が空の場合は「占う」ボタンを無効化
  - ボタンの色でも状態を視覚的に表現
- **レスポンシブデザイン**
  - ScrollViewで全情報にアクセス可能
  - iPhone SE〜Pro Maxまで対応
  - ランドスケープモードも考慮

### パフォーマンス
- **async/await**でモダンな非同期処理
  - コールバック地獄を回避
  - 読みやすく保守しやすいコード
- **Kingfisher**で画像のキャッシング
  - 自動的にメモリ・ディスクキャッシュ
  - リトライ機能で安定した画像読み込み
- **メモリリーク対策**
  - `[weak self]`を適切に使用
  - Delegateは`weak`参照
  - 値型（struct）を積極的に活用

### セキュリティ
- **アクセス制御**を適切に設定
  - `private`、`fileprivate`で外部アクセスを制限
  - `private(set)`で読み取り専用プロパティ
- **APIエンドポイント**を定数化
  - ハードコーディングを避ける
  - 変更が一箇所で済む

## 🧪 テスト

### ユニットテスト
以下のレイヤーでテストを実装:

- **モデル層**
  - Codableのエンコード/デコード
  - バリデーションロジック
  - エッジケース（無効な日付など）

- **Repository層**
  - データ取得の成功ケース
  - エラーハンドリング

- **ViewModel層**
  - 初期状態の確認
  - 状態遷移のテスト
  - エラー時の振る舞い

- **APIClient層**
  - HTTP通信の成功ケース
  - HTTPエラー（4xx、5xx）のハンドリング
  - ネットワークエラーのハンドリング
  - CancellationErrorの適切な処理

### テスト実行
```bash
# Xcodeで Command + U
# または
xcodebuild test -scheme YumemiFortune -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

### テストカバレッジ
重要なビジネスロジックは80%以上のカバレッジを目指しました。

## 📁 プロジェクト構成
```
YumemiFortune/
├── App/
│   └── YumemiFortuneApp.swift          # アプリのエントリーポイント
├── Presentation/
│   ├── Fortune/
│   │   ├── FortuneView.swift           # 入力画面
│   │   └── FortuneViewModel.swift      # 入力画面のViewModel
│   └── Result/
│       ├── ResultView.swift            # 結果画面
│       └── ResultViewModel.swift       # 結果画面のViewModel
├── Domain/
│   ├── Models/
│   │   ├── YearMonthDay.swift          # 年月日型
│   │   ├── MonthDay.swift              # 月日型
│   │   ├── FortuneRequest.swift        # リクエストモデル
│   │   └── Prefecture.swift            # レスポンスモデル
│   └── UseCases/
│       └── FetchFortuneUseCase.swift   # 占い実行のユースケース
├── Data/
│   ├── Network/
│   │   ├── APIClient.swift             # API通信クライアント
│   │   ├── APIError.swift              # エラー型定義
│   │   └── URLSessionProtocol.swift    # URLSessionの抽象化
│   └── Repositories/
│       └── FortuneRepository.swift     # データ取得の抽象化
└── Resources/
    └── Assets.xcassets                 # アセット

YumemiFortuneTests/
├── MockURLSession.swift                # テスト用モック
├── APIClientTests.swift                # APIClientのテスト
├── ModelTests.swift                    # モデル層のテスト
├── RepositoryTests.swift               # Repository層のテスト
└── ViewModelTests.swift                # ViewModel層のテスト
```

## 🌟 今後の拡張案

課題範囲外ですが、以下のような機能拡張が可能です：

- [ ] 占い履歴の保存（UserDefaults/CoreData）
- [ ] お気に入り機能
- [ ] SNSシェア機能
- [ ] ダークモード対応の強化
- [ ] ローカライゼーション（多言語対応）
- [ ] アニメーション追加
- [ ] Widgetの実装
- [ ] オフラインモード

## 📖 参考資料

- [課題ページ](https://yumemi-ios-junior-engineer-codecheck.app.swift.cloud/)
- [評価基準（Qiita記事）](https://qiita.com/lovee/items/d76c68341ec3e7beb611)
- [Kingfisher](https://github.com/onevcat/Kingfisher)
- [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

## 📝 開発期間

約7日間（2025年10月20日~）