# Requirements（要件）

**Feature ID**: FEATURE-29  
**Last Updated**: 2025-12-29

## Functional Requirements（機能要件）

### Must Have (P0)（必須）

#### フェーズ1: 共有スクリプトの抽出
- [ ] `scripts/update-metadata.sh`の実装
  - Metadata更新処理を共通化
  - 6+コマンドから使用可能
  - macOS/Linux両対応
- [ ] `scripts/check-branch.sh`の実装
  - ブランチ確認処理を共通化
  - 3コマンドから使用可能
  - エラーメッセージの標準化
- [ ] `scripts/rebase-with-develop.sh`の実装
  - Rebase処理を共通化
  - 3コマンドから使用可能
  - コンフリクト処理の明確化

#### フェーズ2: コマンド標準化
- [ ] Commitメッセージ形式の統一
  - 形式: `type(FEATURE_ID): message`
  - 全11コマンドで適用
- [ ] コマンド構造の統一
  - セクション順序: Usage → Prerequisites → Execution → Constraints → Error Handling
  - 全コマンドで同じ構造
- [ ] エラーメッセージの標準化
  - 一貫したフォーマット
  - 実行可能なアクションを含む

#### フェーズ3: 複雑性の簡素化
- [ ] `/sdlc-init`の簡素化
  - 現在の44ステップを30ステップ以下に削減
  - ロジックの明確化
- [ ] `/sdlc-decision`のBlockerチェック改善
  - 20+サブステップを10ステップ以下に削減
  - チェックロジックの明確化
- [ ] `/sdlc-check`のスクリプト外部化
  - Bash埋め込みスクリプトを外部ファイルに移動

#### フェーズ4: バリデーション強化
- [ ] Feature存在チェックの追加
  - 全コマンドに適用
  - 明確なエラーメッセージ
- [ ] GitHub認証チェックの追加
  - GitHub API使用コマンドに適用
  - 事前チェックで早期エラー検出
- [ ] Decision statusチェックの統一
  - 一貫したチェック方法
  - 標準化されたエラーメッセージ

### Should Have (P1)（推奨）
- [ ] 共有スクリプトのユニットテスト
- [ ] コマンドの統合テスト
- [ ] エラーメッセージの多言語対応検討
- [ ] パフォーマンス最適化（特に長いコマンド）

### Nice to Have (P2)（あれば良い）
- [ ] 共有スクリプトのログ出力強化
- [ ] デバッグモードの追加
- [ ] コマンド実行履歴の記録

## Non-Functional Requirements（非機能要件）

### Performance（パフォーマンス）
- Response time（応答時間）: 各コマンドの実行時間を現状から20%以上増加させない
- Throughput（スループット）: 共有スクリプト呼び出しのオーバーヘッドを最小化（<100ms）
- Resource usage（リソース使用量）: メモリ使用量を現状から増加させない

### Security（セキュリティ）
- Authentication（認証）: GitHub認証の事前チェックを実装
- Authorization（認可）: 既存のgit権限チェックを維持
- Data protection（データ保護）: Metadataファイルの整合性を保証

### Scalability（スケーラビリティ）
- Expected load（想定負荷）: 単一ユーザーの逐次実行を想定
- Growth projection（成長予測）: 将来的に並行実行に対応可能な設計

### Reliability（信頼性）
- Availability（可用性）: コマンド実行の成功率を95%以上に維持
- Error rate（エラー率）: 環境起因以外のエラーを0に近づける
- Recovery time（復旧時間）: エラー発生時に即座にロールバック可能

### Observability（可観測性）
- Logging（ログ）: 各共有スクリプトで詳細なログ出力
- Metrics（メトリクス）: コマンド実行時間、成功/失敗率を測定可能に
- Alerting（アラート）: CI/CDでのテスト失敗時に通知

### Compatibility（互換性）
- macOS（Monterey以降）での動作保証
- Linux（Ubuntu 20.04以降）での動作保証
- Bash 4.0以降をサポート

## User Stories（ユーザーストーリー）

### Story 1: 開発者としてのメンテナンス性向上
**As a**（〜として） SDLC コマンドの開発者  
**I want**（〜したい） コードの重複を削減したい  
**So that**（〜するために） バグ修正時に複数箇所を修正する必要がなくなる

**Acceptance Criteria**（受入基準）:
- [ ] Metadata更新ロジックが1箇所にまとまっている
- [ ] 共通処理を変更する際、1ファイルの修正で全コマンドに反映される
- [ ] コードレビュー時の確認箇所が減少する

### Story 2: 新規開発者としての理解容易性
**As a**（〜として） 新規参加の開発者  
**I want**（〜したい） 各コマンドの構造を素早く理解したい  
**So that**（〜するために） 短期間でコントリビュートできる

**Acceptance Criteria**（受入基準）:
- [ ] 全コマンドが同じセクション構造になっている
- [ ] 複雑なロジックが適切に分割されている
- [ ] `/sdlc-init`のステップ数が30以下になっている

### Story 3: Linux ユーザーとしてのプラットフォーム互換性
**As a**（〜として） Linux環境の開発者  
**I want**（〜したい） 全てのSDLCコマンドをLinuxで実行したい  
**So that**（〜するために） macOSユーザーと同じワークフローを使用できる

**Acceptance Criteria**（受入基準）:
- [ ] 全11コマンドがLinuxで正常に動作する
- [ ] プラットフォーム固有のエラーが発生しない
- [ ] CI/CDで両プラットフォームのテストが通過する

### Story 4: コマンドユーザーとしてのエラー対応
**As a**（〜として） SDLCコマンドのユーザー  
**I want**（〜したい） エラー発生時に明確なメッセージと対応方法を知りたい  
**So that**（〜するために） 素早く問題を解決できる

**Acceptance Criteria**（受入基準）:
- [ ] エラーメッセージが統一されたフォーマットになっている
- [ ] エラーメッセージに実行可能なアクションが含まれている
- [ ] GitHub認証エラーが事前にチェックされる

## API Specification（API仕様）

### 共有スクリプト: update-metadata.sh

**Usage**:
```bash
scripts/update-metadata.sh <FEATURE_ID> <KEY> <VALUE>
```

**Parameters**:
- `FEATURE_ID`: Feature ID (例: FEATURE-29)
- `KEY`: Metadataのキー (例: STATUS, DECISION_STATUS)
- `VALUE`: 設定する値

**Exit Codes**:
- 0: 成功
- 1: Featureディレクトリが存在しない
- 2: Metadataファイルが存在しない
- 3: 書き込み失敗

### 共有スクリプト: check-branch.sh

**Usage**:
```bash
scripts/check-branch.sh <FEATURE_ID>
```

**Parameters**:
- `FEATURE_ID`: Feature ID

**Exit Codes**:
- 0: 正しいブランチにいる
- 1: 誤ったブランチにいる
- 2: ブランチが存在しない

### 共有スクリプト: rebase-with-develop.sh

**Usage**:
```bash
scripts/rebase-with-develop.sh <FEATURE_ID>
```

**Parameters**:
- `FEATURE_ID`: Feature ID

**Exit Codes**:
- 0: Rebase成功
- 1: Rebase失敗（コンフリクト）
- 2: developブランチの取得失敗

## Dependencies（依存関係）

### 既存依存
- Git 2.0以降
- GitHub CLI (`gh`)
- Bash 4.0以降

### 新規依存
- なし（既存依存のみ）

## Assumptions（前提条件）

- ユーザーはGitとGitHub CLIの基本操作を理解している
- SDLCディレクトリ構造は変更されない
- Metadataファイル形式は維持される
