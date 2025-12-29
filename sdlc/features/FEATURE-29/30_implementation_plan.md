# Implementation Plan（実装計画）

**Feature ID**: FEATURE-29  
**Last Updated**: 2025-12-29  
**Estimated Effort**（見積工数）: 6週間（約30営業日）

## Implementation Overview（実装概要）

FEATURE-29は、11個のSDLCコマンドを体系的にリファクタリングし、コード重複の削減、複雑性の簡素化、標準化、プラットフォーム互換性の確保を実現します。

**確定済みの決定事項**:
- **Decision 1**: Bashスクリプトで共有スクリプトを実装
- **Decision 2**: Phase 1→2→3→4の順序で実装
- **Decision 3**: 互換性のあるコマンドのみ使用（macOS/Linux対応）
- **Decision 4**: 単体テスト + 統合テストのバランス型（80%カバレッジ目標）

**実装戦略**:
各フェーズは独立したPRとして実装され、後方互換性を維持しながら段階的に改善します。

---

## Phase Breakdown（フェーズ分解）

### Phase 1: 共有スクリプト抽出
**Goal**（目標）: 重複するロジックを共通スクリプトとして抽出し、DRY原則を適用  
**Duration**（期間）: 2週間  
**Dependencies**（依存関係）: なし

**Tasks**（タスク）:
- [x] 共有スクリプトディレクトリの作成 `scripts/`
- [x] `update-metadata.sh` の実装（Metadata更新の統一処理）
  - macOS/Linux両対応（互換コマンド使用）
  - 入力バリデーション追加
  - エラーハンドリング強化
- [x] `check-branch.sh` の実装（ブランチ検証の統一処理）
  - 現在ブランチの取得と検証
  - 標準化されたエラーメッセージ
- [x] `rebase-with-develop.sh` の実装（rebase処理の統一）
  - コンフリクト検出とメッセージ
  - ロールバック処理
- [x] `common-functions.sh` の実装（共通ユーティリティ関数）
  - `log_info`, `log_error`, `log_success` 関数
  - `check_feature_exists` 関数
  - `check_gh_auth` 関数
  - `get_os_type` 関数（プラットフォーム判定）
- [x] 1-2個のコマンドで試験的に共有スクリプトを使用（例: `/sdlc-init`）
- [x] 問題がなければ全11コマンドに展開
- [x] 単体テスト実装（BATS使用）
  - `test_update_metadata.bats`
  - `test_check_branch.bats`
  - `test_common_functions.bats`

**Deliverables**（成果物）:
- `scripts/update-metadata.sh`
- `scripts/check-branch.sh`
- `scripts/rebase-with-develop.sh`
- `scripts/common-functions.sh`
- `tests/unit/test_*.sh` (単体テスト)
- 更新された11個のSDLCコマンド

**高リスクポイント**: なし（基盤構築フェーズ）

---

### Phase 2: コマンド標準化
**Goal**（目標）: 全コマンドの構造、Commitメッセージ、エラーメッセージを統一  
**Duration**（期間）: 1週間  
**Dependencies**（依存関係）: Phase 1完了

**Tasks**（タスク）:
- [x] 全11コマンドのコマンド構造を統一
  - Usage（使用方法）セクション
  - Prerequisites（前提条件）セクション
  - Execution（実行内容）セクション
  - Constraints（制約）セクション
  - Error Handling（エラー処理）セクション
- [x] Commitメッセージ形式の統一
  - `<type>(<FEATURE_ID>): <description>` 形式に統一
  - types: `docs`, `feat`, `fix`, `refactor`
- [x] エラーメッセージの標準化
  - `❌ Error: <問題>` 形式
  - `Context: <文脈>` 行
  - `Action: <対処法>` 行
- [ ] 統合テスト実装
  - 各コマンドが共有スクリプトを正しく呼び出すかテスト
  - エラーケースのテスト

**Deliverables**（成果物）:
- 標準化された11個のSDLCコマンド
- `tests/integration/test_command_*.sh` (統合テスト)
- 更新されたドキュメント（.claude/commands/sdlc-*.md）

**高リスクポイント**: なし（標準化作業）

---

### Phase 3: 複雑性簡素化
**Goal**（目標）: 複雑なコマンドを簡素化し、保守性を向上  
**Duration**（期間）: 2週間  
**Dependencies**（依存関係）: Phase 1, Phase 2完了

**Tasks**（タスク）:
- [ ] `/sdlc-init` のリファクタリング（44ステップ→30ステップ以下）
  - Issue取得を関数化
  - テンプレート処理を関数化
  - Git操作を共有スクリプト化
  - inline処理を関数・スクリプト呼び出しに置換
- [ ] `/sdlc-decision` のリファクタリング（Blockerチェック簡素化）
  - 複雑なネストを関数化
  - `check_decision_blockers()` 関数の実装
  - `check_pending_decisions()` 関数の実装
  - `check_unresolved_risks()` 関数の実装
- [ ] `/sdlc-check` の外部化検討
  - 長いチェックロジックを外部スクリプト化
- [ ] 統合テスト更新
  - 簡素化されたコマンドのテスト

**Deliverables**（成果物）:
- 簡素化された `/sdlc-init`
- 簡素化された `/sdlc-decision`
- 簡素化された `/sdlc-check`
- 更新された統合テスト

**高リスクポイント**: 
- ⚠️ `/sdlc-init` の44ステップを30ステップに削減する際、既存機能を破壊しないこと
- ⚠️ `/sdlc-decision` のBlockerチェックロジックの整合性を保つこと

---

### Phase 4: バリデーション強化
**Goal**（目標）: 全コマンドのエラー処理とバリデーションを強化  
**Duration**（期間）: 1週間  
**Dependencies**（依存関係）: Phase 1, Phase 2, Phase 3完了

**Tasks**（タスク）:
- [x] 入力バリデーションの追加
  - Feature ID形式チェック（FEATURE-[0-9]+）
  - 必須引数の存在チェック
- [x] 環境チェックの追加
  - GitHub認証チェック（`gh auth status`）
  - Git設定チェック（`git config user.name`, `user.email`）
- [x] 前提条件チェックの強化
  - Feature存在確認
  - ブランチチェック
  - Decision statusチェック
- [ ] 実行時エラーハンドリングの改善
  - Git操作失敗時の適切なメッセージとロールバック
  - ファイル操作失敗時の処理
  - 外部コマンド失敗時の処理
- [ ] E2Eテスト（重要パステスト）実装
  - `/sdlc-init` → `/sdlc-decision` → `/sdlc-coding` ワークフロー
  - エラーケースのE2Eテスト

**Deliverables**（成果物）:
- バリデーション強化された全11コマンド
- `tests/e2e/test_workflow_*.sh` (E2Eテスト)
- テストカバレッジレポート（80%以上達成確認）

**高リスクポイント**: なし（品質向上作業）

---

## Technical Tasks（技術タスク）

### Scripts（スクリプト）
- [x] `scripts/update-metadata.sh` - Metadata更新の統一処理
- [x] `scripts/check-branch.sh` - ブランチ検証の統一処理
- [x] `scripts/rebase-with-develop.sh` - rebase処理の統一
- [x] `scripts/common-functions.sh` - 共通ユーティリティ関数

### Commands（コマンド）
- [x] `.claude/commands/sdlc-init.md` - 共有スクリプト使用、標準化（簡素化は未完了）
- [x] `.claude/commands/sdlc-decision.md` - 共有スクリプト使用、標準化（簡素化は未完了）
- [x] `.claude/commands/sdlc-check.md` - 共有スクリプト使用、標準化（外部化は未完了）
- [x] `.claude/commands/sdlc-coding.md` - 共有スクリプト使用、標準化
- [x] その他7個のコマンド - 共有スクリプト使用、標準化

### Testing（テスト）
- [x] `tests/unit/` - 単体テスト（共有スクリプト）- 実装済み、一部テスト失敗中
- [ ] `tests/integration/` - 統合テスト（コマンド呼び出し）
- [ ] `tests/e2e/` - E2Eテスト（ワークフロー）
- [x] `tests/test_helper.bash` - テストヘルパー関数
- [ ] `.github/workflows/test.yml` - CI/CD統合（macOS/Linux）

### Documentation（ドキュメント）
- [x] `scripts/README.md` - 共有スクリプトの使用方法
- [x] `tests/README.md` - テストの実行方法
- [x] `.claude/commands/sdlc-*.md` - 標準化されたコマンドドキュメント
- [ ] `CHANGELOG.md` - 変更履歴の記録

---

## File Changes（ファイル変更）

### New Files（新規ファイル）
```
scripts/update-metadata.sh
scripts/check-branch.sh
scripts/rebase-with-develop.sh
scripts/common-functions.sh
scripts/README.md
tests/unit/test_update_metadata.sh
tests/unit/test_check_branch.sh
tests/unit/test_common_functions.sh
tests/integration/test_sdlc_init.sh
tests/integration/test_sdlc_decision.sh
tests/integration/test_sdlc_coding.sh
tests/e2e/test_workflow_happy_path.sh
tests/e2e/test_workflow_error_cases.sh
tests/test_helper.sh
tests/README.md
.github/workflows/test.yml
```

### Modified Files（変更ファイル）
```
.claude/commands/sdlc-init.md - 共有スクリプト使用、簡素化、バリデーション追加
.claude/commands/sdlc-decision.md - 共有スクリプト使用、簡素化、バリデーション追加
.claude/commands/sdlc-check.md - 外部化、標準化、バリデーション追加
.claude/commands/sdlc-coding.md - 共有スクリプト使用、標準化、バリデーション追加
.claude/commands/sdlc-review.md - 共有スクリプト使用、標準化、バリデーション追加
.claude/commands/sdlc-merge.md - 共有スクリプト使用、標準化、バリデーション追加
.claude/commands/sdlc-test.md - 共有スクリプト使用、標準化、バリデーション追加
その他4個のSDLCコマンド - 同様の更新
```

### Deleted Files（削除ファイル）
```
なし（全て既存ファイルの改善）
```

---

## Dependencies（依存関係）

### External Dependencies（外部依存）
- **BATS (Bash Automated Testing System)**: テストフレームワーク
  - Version: 1.10.0+
  - Reason: Bashスクリプトの単体テスト・統合テストに使用
  - Installation: `brew install bats-core` (macOS), `apt-get install bats` (Linux)
- **GitHub CLI (gh)**: 既存依存（変更なし）
  - Version: 2.0.0+
  - Reason: Issue取得、認証チェックに使用
- **Git**: 既存依存（変更なし）
  - Version: 2.30.0+
  - Reason: バージョン管理

### Internal Dependencies（内部依存）
なし（単一リポジトリ内で完結）

---

## Migration Plan（マイグレーション計画）

### Pre-deployment（デプロイ前）
1. 全てのPRがマージされる前に、各フェーズで十分なテストを実施
2. macOSとLinuxの両環境でテストを実行
3. 既存のSDLCワークフローが破壊されていないことを確認

### Deployment Steps（デプロイ手順）
1. **Phase 1デプロイ**:
   - 共有スクリプトをマージ
   - 1-2個のコマンドで動作確認
   - 問題なければ全コマンドに展開
2. **Phase 2デプロイ**:
   - 標準化されたコマンドをマージ
   - 全コマンドで動作確認
3. **Phase 3デプロイ**:
   - 簡素化されたコマンドをマージ
   - 重点的に `/sdlc-init`, `/sdlc-decision` をテスト
4. **Phase 4デプロイ**:
   - バリデーション強化をマージ
   - 全ワークフローでE2Eテスト

### Post-deployment（デプロイ後）
1. 本番環境（実際の開発フロー）で1週間モニタリング
2. ユーザーフィードバックを収集
3. 必要に応じて微調整

### Rollback Plan（ロールバック計画）
1. 各フェーズは独立したPRのため、問題があれば該当PRをrevert
2. Git履歴により、任意のフェーズ前の状態に戻すことが可能
3. 後方互換性を維持しているため、部分的なロールバックも可能

---

## Testing Strategy（テスト戦略）

### Unit tests（ユニットテスト）
- **対象**: 共有スクリプト（`scripts/*.sh`）
- **フレームワーク**: BATS
- **カバレッジ目標**: 90%以上
- **実行時間**: 数秒
- **テスト内容**:
  - `update-metadata.sh`の全機能（正常系・異常系）
  - `check-branch.sh`のブランチ検証ロジック
  - `common-functions.sh`の全ユーティリティ関数

### Integration tests（統合テスト）
- **対象**: SDLCコマンド全体
- **フレームワーク**: BATS
- **カバレッジ目標**: 80%以上
- **実行時間**: 数十秒
- **テスト内容**:
  - 各コマンドが共有スクリプトを正しく呼び出すか
  - Metadata更新が正しく行われるか
  - エラーケースで適切なメッセージが表示されるか

### E2E tests（E2Eテスト）
- **対象**: SDLCワークフロー全体
- **フレームワーク**: BATS
- **カバレッジ目標**: 主要パスをカバー
- **実行時間**: 数分
- **テスト内容**:
  - `/sdlc-init` → `/sdlc-decision` → `/sdlc-coding` の正常フロー
  - エラー時のロールバックとリカバリー
  - 両プラットフォーム（macOS/Linux）での動作

### Performance tests（パフォーマンステスト）
- **対象**: 簡素化後のコマンド（特に `/sdlc-init`）
- **基準**: Phase 3実施前後で実行時間を比較
- **目標**: 実行時間が増加しないこと（微減が理想）

### Platform Compatibility tests（プラットフォーム互換性テスト）
- **環境**: GitHub Actionsマトリックステスト
  - macOS latest
  - Ubuntu 20.04
  - Ubuntu 22.04
- **頻度**: 全PR、全Push時に自動実行

---

## Risk Mitigation（リスク軽減）

| リスク | 影響度 | 軽減策 |
|--------|--------|--------|
| Bashエラー処理が複雑になる | Medium | 共通のエラー処理関数を作成、徹底的なテストでカバー |
| `/sdlc-init`の簡素化で機能破壊 | High | Phase 3前に十分な統合テストを実装、段階的にリファクタリング |
| プラットフォーム互換性問題 | Medium | CI/CDで両プラットフォームテスト、互換コマンドのみ使用 |
| テスト実装の工数超過 | Low | Phase 1から段階的にテスト追加、テストヘルパー関数で効率化 |
| 後方互換性の破壊 | High | 各フェーズでインターフェース変更なし、既存ワークフローを常にテスト |

---

## Success Criteria（成功基準）

- [ ] All tests passing（全テスト成功）: 単体・統合・E2Eテスト全てグリーン（現状: 単体テストのみ実装、74%成功率）
- [ ] Code review approved（コードレビュー承認）: 各フェーズのPRがレビュー承認
- [x] Documentation updated（ドキュメント更新完了）: 全コマンドと共有スクリプトのドキュメント完備
- [ ] Coverage benchmarks met（カバレッジ基準達成）: 80%以上のテストカバレッジ（現状: 測定不可）
- [ ] Platform compatibility confirmed（プラットフォーム互換性確認）: macOS/Linux両方でテスト成功（現状: macOSのみ確認）
- [ ] Performance maintained（パフォーマンス維持）: コマンド実行時間が増加していない
- [x] Backward compatibility verified（後方互換性検証）: 既存ワークフローが全て動作
- [x] Code duplication reduced（コード重複削減）: 50%以上削減達成
- [ ] `/sdlc-init` complexity reduced（複雑性削減）: 30ステップ以下達成（未着手）

---

## Timeline（タイムライン）

```
Week 1-2: Phase 1 - 共有スクリプト抽出
  - Day 1-3: スクリプト実装
  - Day 4-6: 試験導入と展開
  - Day 7-10: 単体テスト実装

Week 3: Phase 2 - コマンド標準化
  - Day 1-3: 構造標準化
  - Day 4-5: 統合テスト実装

Week 4-5: Phase 3 - 複雑性簡素化
  - Day 1-4: /sdlc-init リファクタリング
  - Day 5-8: /sdlc-decision, /sdlc-check リファクタリング
  - Day 9-10: テスト更新

Week 6: Phase 4 - バリデーション強化
  - Day 1-3: バリデーション実装
  - Day 4-5: E2Eテスト実装

継続的: コードレビュー、テスト、ドキュメント更新
```

**Total Duration**: 6週間（約30営業日）

---

## Notes（備考）

### 実装の原則
- **DRY原則**: コードの重複を徹底的に排除
- **KISS原則**: シンプルな設計を優先
- **YAGNI原則**: 必要な機能のみ実装（将来の仮想要件は実装しない）
- **後方互換性**: 既存ワークフローを絶対に破壊しない

### 注意事項
- 各フェーズは独立したPRとして実装し、マージ前に十分なレビューとテストを実施
- macOSとLinuxの両環境で必ずテストを実行
- Decisions.mdで確定した内容を厳守し、実装中に設計を変更しない
- 問題が発生した場合は、該当Decisionを再検討（新しいDecisionとして記録）

### フォローアップ
- 実装完了後、FEATURE-27で指摘された67個の問題が解決されたか検証
- ユーザーフィードバックを収集し、次の改善に活かす
- 定期的にテストカバレッジを確認し、80%以上を維持
