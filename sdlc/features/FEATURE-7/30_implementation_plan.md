# Implementation Plan

**Feature ID**: FEATURE-7  
**Last Updated**: 2025-12-26  
**Estimated Effort**: 2-3 weeks

## Implementation Overview

GitHub Projects v2 と SDLC システムを統合し、commit/push された `.metadata` の変更を GitHub Actions で自動的に Project に同期する。実装は 2 つのフェーズに分けて段階的に行う。

**確定した Decision**:
1. install.sh で Project を自動セットアップ
2. push 時に変更された Feature のみ更新
3. カスタムフィールドは最小限の 4 つ（Status, Feature ID, Risk Level, Decision Status）

## Phase Breakdown

### Phase 1: Project セットアップと GitHub Actions ワークフロー作成
**Goal**: install.sh で GitHub Project を自動作成し、GitHub Actions ワークフローを配置する  
**Duration**: 1 week  
**Dependencies**: なし

**Tasks**:
- [ ] ⚠️ **高リスク (R001)**: GitHub Projects v2 GraphQL API の調査と PoC 実装
  - Project 作成 API (`createProjectV2`) の動作確認
  - カスタムフィールド作成 API (`createProjectV2Field`) の動作確認
  - 基本的な CRUD 操作のテスト
- [ ] install.sh に Project セットアップロジックを追加
  - GitHub 認証確認（gh CLI または GITHUB_TOKEN）
  - Project 自動作成
  - 4つのカスタムフィールド作成（Status, Feature ID, Risk Level, Decision Status）
  - Field ID を `.sdlc-config` に保存
- [ ] ⚠️ **高リスク (R004)**: カスタムフィールド ID のキャッシュ機構実装
  - `.sdlc-config` への保存処理
  - Field ID の検証と再取得ロジック
- [ ] `.github/workflows/sync-projects.yml` テンプレートを作成
  - `sdlc/features/**` の変更を監視
  - git diff で変更された .metadata を検出
  - 同期処理の骨格を実装（詳細は Phase 2）
- [ ] エラーハンドリング実装
  - 認証失敗時のメッセージ
  - Project 作成権限がない場合の対処
  - リトライ機構

**Deliverables**:
- 更新された `install.sh`
- `.sdlc-config` ファイル（自動生成）
- `.github/workflows/sync-projects.yml`
- PoC コード（検証用）

---

### Phase 2: 自動同期ロジックの実装
**Goal**: GitHub Actions で .metadata の変更を検出し、Project に同期する  
**Duration**: 1-2 weeks  
**Dependencies**: Phase 1 完了

**Tasks**:
- [ ] ⚠️ **中リスク (R002)**: 変更検出ロジックの実装
  - git diff で変更された .metadata を検出
  - Feature ID のリスト抽出
  - rename/move の考慮
- [ ] GraphQL 同期処理の実装
  - Issue URL から Issue の node_id を取得
  - Project に Item が存在するか確認
  - 存在しない場合: `addProjectV2ItemById` で追加
  - 存在する場合: Item ID を取得
  - 4つのカスタムフィールドを `updateProjectV2ItemFieldValue` で更新
- [ ] ⚠️ **中リスク (R002)**: API レート制限対策
  - レート制限残数の監視
  - 指数バックオフによるリトライ（最大 3 回）
  - バッチ処理の最適化
- [ ] ⚠️ **中リスク (R003)**: 既存ワークフローとの統合テスト
  - `/sdlc-init` 実行後の同期確認
  - `/sdlc-decision` 実行後の同期確認
  - `/sdlc-coding` 実行後の同期確認
  - 複数 Feature の同時変更テスト
- [ ] エラーハンドリングとログ出力
  - 同期成功/失敗のログ
  - エラー詳細の記録
  - アラート設定

**Deliverables**:
- 完全な `.github/workflows/sync-projects.yml`
- 同期処理スクリプト（bash または Go/Python）
- テスト結果レポート

## Technical Tasks

### Backend
- [ ] GraphQL クライアントの実装（bash + curl または専用ライブラリ）
- [ ] `.metadata` パーサーの実装
- [ ] `.sdlc-config` の読み書き処理
- [ ] Project Item CRUD 操作の実装
- [ ] カスタムフィールド更新ロジック

### Infrastructure
- [ ] GitHub Actions ワークフローの設定
- [ ] GitHub Token の権限確認（Project への write 権限）
- [ ] リポジトリシークレットの設定（必要に応じて）

### Testing
- [ ] PoC の動作確認
- [ ] install.sh の統合テスト
- [ ] GitHub Actions ワークフローの E2E テスト
- [ ] API レート制限のストレステスト
- [ ] エラーケースのテスト（認証失敗、権限不足、API エラー）

### Documentation
- [ ] README に Project 統合機能を追加
- [ ] install.sh の使用方法を更新
- [ ] トラブルシューティングガイドの作成
- [ ] API レート制限に関する注意事項を記載

## File Changes

### New Files
```
.sdlc-config (自動生成)
.github/workflows/sync-projects.yml
scripts/sync-github-project.sh (または .go/.py)
```

### Modified Files
```
install.sh - Project セットアップロジックを追加
README.md - GitHub Projects v2 統合機能の説明を追加
```

### Deleted Files
```
なし
```

## Dependencies

### External Dependencies
- **GitHub Projects v2 API**: GraphQL API を使用、認証には gh CLI または GITHUB_TOKEN
- **GitHub Actions**: ワークフロー実行環境

### Internal Dependencies
- **既存の install.sh**: Project セットアップを統合
- **既存の SDLC コマンド**: `/sdlc-init`, `/sdlc-decision`, `/sdlc-coding` など
- **.metadata ファイル**: 同期のデータソース

## Migration Plan

### Pre-deployment
1. GitHub 認証の確認（`gh auth status` または GITHUB_TOKEN の設定）
2. Project 作成権限の確認
3. 既存の Feature がある場合、手動で Project に追加するか検討

### Deployment Steps
1. `install.sh` を実行して Project をセットアップ
2. `.sdlc-config` が正しく生成されたか確認
3. `.github/workflows/sync-projects.yml` が配置されたか確認
4. テスト用の Feature で動作確認（`/sdlc-init` → commit/push → Project 確認）
5. 既存の Feature を一括同期（必要に応じて手動または専用スクリプト）

### Post-deployment
1. GitHub Project UI で Feature が正しく表示されているか確認
2. カスタムフィールドの値が正しいか確認
3. GitHub Actions のログで同期状況を監視

### Rollback Plan
1. `.github/workflows/sync-projects.yml` を削除または無効化
2. `.sdlc-config` を削除（または Project ID を空にする）
3. GitHub Project は手動で削除または放置（データは保持される）
4. 既存の SDLC ワークフローは影響を受けない

## Testing Strategy

- **PoC テスト**: Phase 1 で GraphQL API の基本操作を確認
- **Unit tests**: `.metadata` パーサー、Field ID 管理ロジックのテスト
- **Integration tests**: install.sh + GitHub Actions の統合テスト
- **E2E tests**: `/sdlc-init` → commit/push → Project 同期の全体フロー
- **Performance tests**: API レート制限テスト、複数 Feature の同時同期テスト

## Risk Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| R001: GitHub Projects v2 API の複雑性 | High | Phase 1 で PoC 実装、公式ドキュメントと事例を調査、段階的開発 |
| R002: API レート制限による同期失敗 | Medium | 変更検出最適化、バッチ化、指数バックオフリトライ、レート制限監視 |
| R003: 既存ワークフローへの影響 | Medium | 段階的ロールアウト、非同期処理、詳細なエラーログ、ドキュメント整備 |
| R004: カスタムフィールド ID 管理の複雑性 | Medium | `.sdlc-config` にキャッシュ、ID 不整合時は自動再取得、エラーメッセージ改善 |

## Success Criteria

- [ ] install.sh 実行で GitHub Project が自動作成される
- [ ] 4つのカスタムフィールド（Status, Feature ID, Risk Level, Decision Status）が正しく設定される
- [ ] `.metadata` を変更して push すると GitHub Actions が自動的にトリガーされる
- [ ] 変更された Feature のみが Project に同期される
- [ ] 同期成功率 > 95%
- [ ] GitHub Actions の実行時間 < 5 分
- [ ] API レート制限に到達しない
- [ ] 全てのテストが通過する
- [ ] ドキュメントが更新される

## Timeline

```
Week 1: Phase 1
  - Day 1-2: GitHub Projects v2 API の調査と PoC
  - Day 3-4: install.sh の拡張実装
  - Day 5: GitHub Actions ワークフローテンプレート作成、テスト

Week 2-3: Phase 2
  - Day 1-3: 変更検出ロジックと GraphQL 同期処理の実装
  - Day 4-5: API レート制限対策とエラーハンドリング
  - Day 6-7: 統合テストと E2E テスト
  - Day 8-9: バグ修正と改善
  - Day 10: ドキュメント作成と最終確認
```

## Notes

- **Phase 1 の PoC は重要**: GitHub Projects v2 API の複雑性（R001）が High Risk のため、Phase 1 で必ず PoC を実装して API の動作を確認する
- **カスタムフィールドは 4 つのみ**: Decision 3 で確定した通り、Status, Feature ID, Risk Level, Decision Status のみ実装（Branch, PR Link は含まない）
- **既存ワークフローを破壊しない**: SDLC コマンド自体は変更せず、commit/push 後に GitHub Actions が自動同期する設計
- **段階的ロールアウト推奨**: まず一部のメンバーでテストし、問題なければ全体展開
