# SDLC Commands Flow Summary

**分析日**: 2025-12-29
**Feature**: FEATURE-29
**目的**: コマンドの標準化とモジュール化

---

## /sdlc-issue (107 lines)

**Steps**:
1. 対話内容を分析（Why, What, How, Risk Level）
2. Issue 内容を生成
3. GitHub Issue 作成（`gh issue create`）
4. Issue 番号を取得
5. Feature ID を更新（FEATURE-TBD → FEATURE-{number}）

**使用共享脚本**: ❌

---

## /sdlc-init (153 lines)

**Steps**:
1. Issue を取得（`gh issue view`）
2. Feature ID を抽出
3. Risk Level を判定
4. Git ブランチ作成（`git checkout -b feature/{FEATURE_ID}`）
5. ディレクトリ作成（`mkdir -p sdlc/features/{FEATURE_ID}`）
6. `.metadata` を作成
7. テンプレート読取（Risk Level に応じて）
8. プレースホルダーを埋める
9. ファイル書込（Write ツール）
10. Commit と Push

**使用共享脚本**: ❌

---

## /sdlc-pr-design (164 lines) ✅ 優化済み

**Steps**:
1. 前提確認（Feature 存在 + ブランチ確認）← **統合**
2. Rebase with develop（`scripts/rebase-with-develop.sh`）
3. Metadata 更新（`scripts/update-metadata.sh`）- STATUS=design
4. Commit と Push
5. ドキュメント読取（Read ツール）
6. PR Description 生成
7. PR 作成（`gh pr create`）

**使用共享脚本**: ✅

**優化内容**:
- Step 1 と 2 を統合（Feature 確認 + ブランチ確認）
- "ブランチ作成を提案"ロジックを削除（異常ケースは報錯）
- "完了メッセージ"を独立ステップから削除（出力であって操作ではない）
- 9 steps → 7 steps

---

## /sdlc-decision (178 lines) ✅ 優化済み

**Steps**:
1. 前提確認（Feature 存在 + ブランチ確認 + decisions.md 確認）
2. ドキュメント読取（decisions, context, risks, design）
3. ユーザー入力を収集（Topic, Chosen, Rejected, etc.）
4. 矛盾チェック（Blocker 判定）
5. decisions.md を更新（Status: CONFIRMED）
6. design.md を更新（Status: FROZEN）
7. メタデータ更新（DECISION_STATUS=confirmed）
8. Commit & Push

**使用共享脚本**: ✅（優化後）

**優化内容**:
- 前提確認に共有スクリプトを追加
- sed を `update-metadata.sh` に置き換え
- 7 steps → 8 steps

**特殊性**: 唯一の矛盾チェック機能（Blocker/Warning）

---

## /sdlc-impl-plan (138 lines) ✅ 優化完了

**Steps**:
1. 前提確認（Feature 存在 + ブランチ確認 + Decision Status 確認）
2. ドキュメント読取（context, decisions, risks, design）
3. テンプレート読取（`sdlc/templates/30_implementation_plan.md`）
4. Implementation Plan 生成
   - Phases に分割
   - タスクリスト作成
   - 高リスクタスクをマーク
   - Testing Strategy
   - Timeline
5. ファイル書込（Write ツール）
6. Metadata 更新（`scripts/update-metadata.sh`）
7. Commit と Push

**使用共享脚本**: ✅

**優化内容**:
- ✅ Step 1 と 2 を統合（前提確認）
- ✅ ブランチ確認を追加
- 8 steps → 7 steps

---

## /sdlc-coding (156 lines) ✅ 優化済み

**Steps**:
1. 前提確認（Feature 存在 + Decision Status + ブランチ確認）← **統合**
2. ドキュメント読取（decisions.md の Chosen Options を中心に）
3. 実装（コード + テスト + ビルド確認）
4. メタデータ更新（STATUS=implementing）

**使用共享脚本**: ✅

**優化内容**:
- Step 1 "前提チェック" → "前提確認" に変更（命名統一）
- Rebase を削除（前提確認は検査のみ）
- Commit/Push を削除（Command は metadata 更新のみ）
- "完了メッセージ"を独立ステップから削除
- 7 steps → 4 steps

---

## /sdlc-test (189 lines) ✅ 優化済み

**Steps**:
1. 前提確認（Feature 存在 + ブランチ確認 + Test Plan 存在）← **統合**
2. テスト計画読み込み（コマンド抽出、E2E 実行判断）
3. メタデータ更新（テスト開始、STATUS=testing）← **独立**
4. テスト実行 & 結果収集
5. Test Plan への結果記録
6. メタデータ更新（テスト完了、TEST_RESULT）

**使用共享脚本**: ✅

**優化内容**:
- Step 1 "前提チェック" → "前提確認" に変更（命名統一）
- ブランチ確認を追加（`check-branch.sh`）
- Step 3 メタデータ更新（テスト開始）を独立させる
- "結果サマリー表示" を削除（出力のみ）
- Commit/Push を削除（Command は metadata 更新のみ）
- "完了メッセージ" を削除（出力のみ）
- 9 steps → 6 steps

---

## /sdlc-check (163 lines) ✅ 優化済み

**Steps**:
1. 前提確認（Feature 存在 + ブランチ確認）← **追加**
2. ドキュメント & コード読取（decisions, risks, design, impl_plan, git diff）← **統合**
3. タスク完成度 & 一致性チェック（タスク分析、Decision 一致、リスク管理）
4. 結果分析 & 表示（ブロッカー/警告判定、ターミナル出力のみ）

**使用共享脚本**: ✅（優化後）

**優化内容**:
- 前提確認を追加（Feature 存在 + ブランチ確認）
- 共有スクリプトを使用（`check_feature_exists()`, `check-branch.sh`）
- Step 1-2 を統合（ドキュメント & コード読取）
- Step 3-4 を統合（タスク完成度 & 一致性チェック）
- "結果を表示" を Step 4 に統合（分析と表示を一緒に）
- 5 steps → 4 steps

**特徴**:
- 唯一、結果をファイルに書き込まない（Self-Check）
- 唯一、metadata を更新しない
- 何度でも実行可能

---

## /sdlc-pr-code (160 lines) ✅ 優化済み

**Steps**:
1. 前提確認（Feature 存在 + Decision Status + ブランチ確認）
2. メタデータ更新（STATUS=review）
3. Commit & Push
4. Feature ドキュメント読取
5. PR Description 生成
6. PR 作成

**使用共享脚本**: ✅

**優化内容**:
- "前提チェック" → "前提確認" に変更
- Rebase を削除
- 9 steps → 6 steps

---

## /sdlc-revise (253 lines) ✅ 優化済み

**Steps**:
1. 前提確認（Feature 存在 + ブランチ確認 + Decision Status + 実装フェーズ）
2. ユーザー入力を収集（Why/What/Impact/NewRisks/Maker）
3. decisions.md を更新（REVISED エントリ追加）
4. risks.md を更新（New Risks がある場合）
5. impl_plan.md を更新（Revision Alert）
6. design.md を更新（Status: REVISED、Revision History）
7. メタデータ更新（STATUS=blocked、Revision 情報）
8. Commit & Push

**使用共享脚本**: ✅（優化後）

**優化内容**:
- 前提確認に共有スクリプトを使用
- Metadata 更新に `update-metadata.sh` を使用
- PR 作成を削除（ユーザーが手動で行う）
- 7 steps → 8 steps

**特殊性**: 最も複雑（5ファイル更新、STATUS=blocked）

---

## /sdlc-resume (222 lines) ✅ 優化済み

**Steps**:
1. 前提確認（Feature 存在 + ブランチ確認 + STATUS=blocked）
2. 現在の状態を確認（Metadata 読取）
3. Implementation Plan 更新の確認（ユーザー入力）
4. Implementation Plan の更新（Y の場合）
5. メタデータ更新（STATUS 復元、blocked フィールド削除）
6. Commit & Push

**使用共享脚本**: ✅（優化後）

**優化内容**:
- 前提確認に共有スクリプトを使用
- すべての sed を `update-metadata.sh` に置き換え
- Rebase を削除
- 8 steps → 6 steps

---

## Summary Table

| Command | Lines | Shared Scripts | sed -i | Complexity | Priority |
|---------|-------|----------------|--------|------------|----------|
| sdlc-issue | 107 | ❌ | ✅ | Low | 低 |
| sdlc-init | 153 | ❌ | ✅ | High | 低 |
| sdlc-pr-design | 164 | ✅ | ✅ | Medium | ✅ 完了 |
| sdlc-decision | 178 | ✅ | ✅ | High | ✅ 優化済み |
| sdlc-impl-plan | 138 | ✅ | ✅ | Medium | ✅ 完了 |
| sdlc-coding | 156 | ✅ | ✅ | Medium | ✅ 優化済み |
| sdlc-test | 189 | ✅ | ✅ | Medium | ✅ 優化済み |
| sdlc-check | 163 | ✅ | ✅ | Medium | ✅ 優化済み |
| sdlc-pr-code | 160 | ✅ | ✅ | Medium | ✅ 優化済み |
| sdlc-revise | **253** | ✅ | ✅ | **Very High** | ✅ 優化済み |
| sdlc-resume | **222** | ✅ | ✅ | High | ✅ 優化済み |

---

## Common Patterns（重複する処理）

### Pattern 1: Feature 存在確認
- **出現**: sdlc-decision, sdlc-impl-plan, sdlc-coding, sdlc-check, sdlc-pr-design, sdlc-pr-code, sdlc-revise, sdlc-resume
- **改善**: `check_feature_exists()` を使用

### Pattern 2: Decision Status 確認
- **出現**: sdlc-impl-plan, sdlc-coding, sdlc-pr-code
- **改善**: `get_metadata_value()` を使用

### Pattern 3: Metadata 更新
- **出現**: ほぼ全てのコマンド
- **問題**: sdlc-decision, sdlc-resume で sed -i を使用
- **改善**: `scripts/update-metadata.sh` を使用

### Pattern 4: ブランチ確認
- **出現**: sdlc-coding, sdlc-pr-design, sdlc-pr-code
- **改善**: `scripts/check-branch.sh` を使用

### Pattern 5: Rebase with develop
- **出現**: sdlc-coding, sdlc-pr-design, sdlc-pr-code, sdlc-resume
- **改善**: `scripts/rebase-with-develop.sh` を使用

---

## Refactoring Priority（重構優先順位）

### 🔴 High Priority

1. **sdlc-revise** (253 lines)
   - 最も長く複雑
   - 複数ファイルを更新する複雑なロジック
   - Revision ロジックを `scripts/` に抽出すべき

2. **sdlc-resume** (222 lines)
   - 多数の sed -i コマンド
   - metadata 更新を `update-metadata.sh` に置き換え
   - rebase ロジックを `scripts/rebase-with-develop.sh` に置き換え

3. **sdlc-decision** (178 lines)
   - sed -i を使用
   - metadata 更新を `update-metadata.sh` に置き換え

### 🟡 Medium Priority

4. **sdlc-check** (163 lines)
   - 共有スクリプトを使用していない
   - `check_feature_exists()` を追加

### 🟢 Low Priority

5. **sdlc-init** - 初期化コマンドなので詳細が必要
6. **sdlc-issue** - シンプルで問題なし

---

## Next Steps

1. **sdlc-resume.md** - sed -i を update-metadata.sh に置き換え
2. **sdlc-decision.md** - sed -i を update-metadata.sh に置き換え
3. **sdlc-revise.md** - 複雑なロジックを簡素化
4. **sdlc-check.md** - 共有関数を追加
