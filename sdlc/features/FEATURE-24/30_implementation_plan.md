# Implementation Plan（実装計画）

**Feature ID**: FEATURE-24  
**Last Updated**: 2025-12-27  
**Estimated Effort**（見積工数）: 3-4 days

## Implementation Overview（実装概要）

この実装では、Issue にラベル（`sdlc:track`）を追加/削除することで、GitHub Projects への自動追加/削除を行う GitHub Actions Workflow を作成します。

**主な実装内容**:
1. 新規 Workflow: `.github/workflows/auto-add-issues.yml` の作成
2. install.sh の更新: `sdlc:track` ラベルと Backlog Status の追加
3. README.md の更新: 最小限のドキュメント追加

**実装方針**:
- 既存の `sync-projects.yml` のパターンを踏襲
- GraphQL API を使用して Projects を操作
- Retry 機構とエラーハンドリングを実装
- `.metadata` の有無に基づく智能的な削除ロジック

## Phase Breakdown（フェーズ分解）

### Phase 1: Workflow ファイルの作成
**Goal**（目標）: 新規 Workflow `auto-add-issues.yml` を実装  
**Duration**（期間）: 1-1.5 days  
**Dependencies**（依存関係）: なし

**Tasks**（タスク）:
- [ ] `.github/workflows/auto-add-issues.yml` ファイルを作成
- [ ] `add-to-project` job を実装（ラベル追加時）
- [ ] `remove-from-project` job を実装（ラベル削除時）
- [ ] `.sdlc-config` 読み込み処理を実装
- [ ] GraphQL query/mutation を実装
- [ ] Retry 機構を実装（既存パターンを踏襲）
- [ ] エラーハンドリングを実装

**Deliverables**（成果物）:
- `.github/workflows/auto-add-issues.yml`

**⚠️ 高リスク**: Risk R001 (Medium) - `.metadata` ファイル確認の実装複雑性

### Phase 2: install.sh の更新
**Goal**（目標）: `sdlc:track` ラベルと Backlog Status を追加  
**Duration**（期間）: 0.5 days  
**Dependencies**（依存関係）: Phase 1 完了後（テスト用）

**Tasks**（タスク）:
- [ ] `initialize_labels()` 関数に `sdlc:track` を追加
- [ ] `setup_github_project()` 関数の Status options に `Backlog` を追加

**Deliverables**（成果物）:
- 更新された `install.sh`

### Phase 3: README.md の更新
**Goal**（目標）: 最小限のドキュメントを追加  
**Duration**（期間）: 0.5 days  
**Dependencies**（依存関係）: Phase 1 完了後

**Tasks**（タスク）:
- [ ] `sdlc:track` ラベルの説明を追加
- [ ] Backlog 状態の説明を追加
- [ ] 正しいワークフロー（`.metadata` 編集 → 自動同期）を明記

**Deliverables**（成果物）:
- 更新された `README.md`

**⚠️ 高リスク**: Risk R002 (Medium) - GitHub API レート制限

### Phase 4: テストと検証
**Goal**（目標）: 全シナリオで動作確認  
**Duration**（期間）: 1 day  
**Dependencies**（依存関係）: Phase 1-3 完了

**Tasks**（タスク）:
- [ ] ラベル追加時の動作確認（新規 Issue）
- [ ] ラベル追加時の重複防止テスト（既存 Issue）
- [ ] ラベル削除時の動作確認（`.metadata` なし → 削除）
- [ ] ラベル削除時の動作確認（`.metadata` あり → 保持）
- [ ] `sync-projects.yml` との共存テスト
- [ ] Backlog Status の設定確認
- [ ] エラーケースのテスト

**Deliverables**（成果物）:
- テスト結果レポート
- バグ修正

## Technical Tasks（技術タスク）

### GitHub Actions Workflow
- [ ] Trigger 設定（`issues.labeled` / `issues.unlabeled`）
- [ ] Conditional 実行（`label.name == 'sdlc:track'`）
- [ ] `.sdlc-config` 読み込み
- [ ] Issue node ID の取得
- [ ] GraphQL query: 既存 Item チェック
- [ ] GraphQL mutation: `addProjectV2ItemById`
- [ ] GraphQL mutation: `deleteProjectV2Item`
- [ ] Repository checkout（`.metadata` 確認用）
- [ ] FEATURE_ID 抽出（正規表現: `FEATURE-\d+`）
- [ ] ファイル存在確認（`sdlc/features/{FEATURE_ID}/.metadata`）
- [ ] Retry 機構（3 回、指数バックオフ）
- [ ] 詳細ログ出力

### install.sh Updates
- [ ] `LABELS` 配列に `sdlc:track` を追加
- [ ] Status options に `Backlog` を追加

### Documentation
- [ ] README.md に必要最小限の情報を追加

## File Changes（ファイル変更）

### New Files（新規ファイル）
```
.github/workflows/auto-add-issues.yml
```

### Modified Files（変更ファイル）
```
install.sh - initialize_labels() と setup_github_project() を更新
README.md - GitHub Projects セクションを追加
```

### Deleted Files（削除ファイル）
なし

## Dependencies（依存関係）

### External Dependencies（外部依存）
- GitHub CLI (`gh`) - 既存（テスト用）
- GitHub Projects v2 API - 既存
- `secrets.GH_PAT` - 既存（`repo` と `project` スコープ必要）

### Internal Dependencies（内部依存）
- `.sdlc-config` - 既存（`install.sh` で生成）
- `sync-projects.yml` - 既存（共存する必要あり）
- `.metadata` ファイル - 既存（`/sdlc-init` で生成）

## Migration Plan（マイグレーション計画）

### Pre-deployment（デプロイ前）
1. `install.sh` を実行して `sdlc:track` ラベルと Backlog Status を作成
2. `.sdlc-config` が存在することを確認
3. `secrets.GH_PAT` の権限を確認（`repo` と `project`）

### Deployment Steps（デプロイ手順）
1. `auto-add-issues.yml` を `.github/workflows/` に配置
2. `install.sh` と `README.md` を更新
3. Git commit & push
4. GitHub Actions が自動的に有効化される

### Post-deployment（デプロイ後）
1. テスト Issue を作成し、`sdlc:track` ラベルを追加
2. Projects に Issue が追加されることを確認
3. ラベルを削除し、Projects から削除されることを確認
4. Workflow のログを確認

### Rollback Plan（ロールバック計画）
1. `auto-add-issues.yml` を削除
2. Git revert & push
3. Workflow が無効化される
4. 手動で Projects を修正（必要に応じて）

## Testing Strategy（テスト戦略）

### Manual Tests（手動テスト）
- **シナリオ 1**: 新規 Issue に `sdlc:track` ラベルを追加 → Projects に追加
- **シナリオ 2**: 既存 Issue（Projects 内）に `sdlc:track` ラベルを追加 → 重複しない
- **シナリオ 3**: `/sdlc-init` 未実行の Issue からラベルを削除 → Projects から削除
- **シナリオ 4**: `/sdlc-init` 実行済みの Feature からラベルを削除 → Projects に保持
- **シナリオ 5**: `.sdlc-config` が存在しない → Workflow がスキップ
- **シナリオ 6**: 両方の Workflow を同時実行 → 競合なし

### Workflow Logs（ワークフローログ）
- 各ステップの実行結果を確認
- エラーメッセージの明確性を確認
- Retry 処理が正しく動作することを確認

### Performance Tests（パフォーマンステスト）
- 10 件の Issue に一斉にラベルを追加 → すべて正常に処理

## Risk Mitigation（リスク軽減）

| リスク | 影響度 | 軽減策 |
|--------|--------|--------|
| `.metadata` ファイル確認の実装複雑性 (R001) | Medium | 既存の `sync-projects.yml` パターンを踏襲、十分なエラーハンドリング |
| GitHub API レート制限 (R002) | Medium | Retry 機構を実装、API 呼び出しを最小化 |
| `sync-projects.yml` との競合 (R003) | Low | 重複防止機構を実装、統合テストを実施 |
| ラベル誤削除によるデータ不整合 (R004) | Low | ドキュメントで周知、復旧手順を明記 |

## Success Criteria（成功基準）

- [x] All decisions confirmed（全 Decision 確定済み） ✓
- [ ] All tests passing（全テスト成功）
- [ ] Code review approved（コードレビュー承認）
- [ ] Documentation updated（ドキュメント更新完了）
- [ ] No conflicts with sync-projects.yml（`sync-projects.yml` との競合なし）
- [ ] API rate limit not exceeded（API レート制限内）

## Timeline（タイムライン）

```
Day 1: Phase 1 - Workflow 実装（add-to-project job）
Day 2: Phase 1 - Workflow 実装（remove-from-project job）+ Phase 2 - install.sh 更新
Day 3: Phase 3 - README.md 更新 + Phase 4 - テスト開始
Day 4: Phase 4 - テスト完了、バグ修正、Code Review
```

**Total**: 3-4 days

## Notes（備考）

- **Backlog 状態の特殊性**: Backlog は `.metadata` に記録されない唯一の状態（ラベル追加時のみ）。`/sdlc-init` 実行後は自動的に Planning に更新される。
- **既存パターンの踏襲**: `sync-projects.yml` の実装を参考にし、一貫性を保つ。
- **段階的なロールアウト**: まずテストリポジトリで検証してから本番適用を推奨。
- **ドキュメントの最小化**: Decision 4 に従い、必要最小限の情報のみ追加。
