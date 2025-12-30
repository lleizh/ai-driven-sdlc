# Test Plan（テスト計画）

**Feature ID**: FEATURE-42  
**Last Updated**: 2025-12-30  
**Test Owner**（テスト責任者）: TBD  
**Risk Level**: MEDIUM

---

## Test Strategy Overview（テスト戦略概要）

**Testing Approach**（テストアプローチ）:

Medium Risk Feature として、以下のテスト戦略を採用します：
1. Unit Testing: コア機能（PR 検出、分類ロジック、ドキュメント生成）
2. Integration Testing: GitHub API との連携、実際の PR を使ったテスト
3. E2E Testing: 実際のワークフローで `/sdlc-review-summary` コマンドを実行

**Testing Levels**（テストレベル）:
- ✅ Unit Testing - ≥80%
- ✅ Integration Testing - 主要シナリオ全て
- ✅ E2E Testing - Low/Medium/High Risk Feature で各1回
- ⚠️ Performance Testing - 不要（GitHub API の制約内）
- ⚠️ Security Testing - 最小限（GitHub CLI の認証チェックのみ）

---

## Test Scope（テスト範囲）

### In Scope（テスト対象）

- `/sdlc-review-summary` コマンドの実行
- PR 自動検出ロジック
- Review Comments 取得ロジック
- 分類エンジン（Critical/Important/Suggestions）
- `40_review_findings.md` 生成ロジック
- エラーハンドリング（PR なし、API エラー等）
- AI Review 統合（Phase 2）

### Out of Scope（テスト対象外）

- GitHub API 自体の動作（GitHub の責任）
- GitHub CLI (`gh`) のインストール・認証（前提条件）
- 他のコマンド（`/sdlc-pr-design`, `/sdlc-pr-code` 等）への影響
- マルチリポジトリ対応（現時点では単一リポジトリのみ）

### Key Test Areas（重点テスト領域）

- **PR 検出の正確性**: 正しい PR を選択できるか
- **分類ロジックの精度**: Critical/Important/Suggestions の分類が適切か
- **エラーハンドリング**: 各種エラーケースで適切なメッセージを表示するか
- **GitHub API 連携**: Rate Limit やネットワークエラーに対応できるか

---

## Unit Tests（ユニットテスト）

### Target Coverage（目標カバレッジ）
- **Overall**: ≥ 80%
- **Critical Functions**: 100%

### Test Cases（テストケース）

#### TestPRDetection（PR 検出）:
- [ ] 正常系: `feature/{FEATURE_ID}` ブランチの open PR を検出できる
- [ ] 正常系: open PR がない場合、最新の merged PR を検出できる
- [ ] 異常系: PR が全く存在しない場合、適切なエラーメッセージを表示する
- [ ] 異常系: 複数の open PR がある場合、最新のものを選択する
- [ ] 境界値: PR の状態が "closed" の場合、選択されない

#### TestReviewExtraction（Review 抽出）:
- [ ] 正常系: PR の Review comments を全て取得できる
- [ ] 正常系: Inline comments も全て取得できる
- [ ] 正常系: Reviewer の state (APPROVED/CHANGES_REQUESTED 等) を取得できる
- [ ] 異常系: Review comments がない場合、空のリストを返す
- [ ] 異常系: GitHub API エラー時、適切なエラーメッセージを表示する

#### TestClassificationEngine（分類エンジン）:
- [ ] 正常系: "critical" キーワードを含むコメントは Critical に分類される
- [ ] 正常系: ❌ emoji を含むコメントは Critical に分類される
- [ ] 正常系: `CHANGES_REQUESTED` state のコメントは Critical に分類される
- [ ] 正常系: "important" キーワードを含むコメントは Important に分類される
- [ ] 正常系: ⚠️ emoji を含むコメントは Important に分類される
- [ ] 正常系: "suggestion" キーワードを含むコメントは Suggestions に分類される
- [ ] 正常系: 💡 emoji を含むコメントは Suggestions に分類される
- [ ] 境界値: キーワードも emoji もない場合、Important に分類される（デフォルト）
- [ ] 境界値: 複数のキーワードがある場合、最も重要度の高いものに分類される
- [ ] 異常系: 空のコメントは Suggestions に分類される

#### TestDocumentGeneration（ドキュメント生成）:
- [ ] 正常系: `40_review_findings.md` が正しいフォーマットで生成される
- [ ] 正常系: Feature ID, Date, Reviewers が自動入力される
- [ ] 正常系: Review Type が label から自動判定される（design-review → Design Review）
- [ ] 正常系: 分類されたコメントが適切なセクションに配置される
- [ ] 正常系: 既存の `40_review_findings.md` がある場合、上書きされる
- [ ] 異常系: Template が見つからない場合、エラーメッセージを表示する
- [ ] 境界値: コメントが0件の場合でも生成される

#### TestAIBotIdentification（AI Bot 識別 - Phase 2）:
- [ ] 正常系: "coderabbitai" ユーザーを AI Bot と識別できる
- [ ] 正常系: "github-actions[bot]" ユーザーを AI Bot と識別できる
- [ ] 正常系: "copilot" ユーザーを AI Bot と識別できる
- [ ] 正常系: 通常のユーザーを Human と識別できる
- [ ] 境界値: 未知の Bot（リストにない）は Human として扱われる

---

## Integration Tests（統合テスト）

### Test Scenarios（テストシナリオ）

#### Scenario 1: Low Risk Feature での実行

**Description**（説明）:
Low Risk Feature（Code PR のみ）で `/sdlc-review-summary` を実行し、`40_review_findings.md` が生成されることを確認。

**Steps**（手順）:
1. テスト用の Low Risk Feature を作成（`FEATURE-TEST-LOW`）
2. Code PR を作成し、Review comments を追加
3. `/sdlc-review-summary FEATURE-TEST-LOW` を実行
4. `sdlc/features/FEATURE-TEST-LOW/40_review_findings.md` が生成されることを確認
5. 内容が正しいフォーマットであることを確認

**Expected Result**（期待結果）:
- `40_review_findings.md` が生成される
- Review Type が "Code Review" と記載される
- 全ての Review comments が適切に分類される
- Feature ID, Date, Reviewers が正しく記載される

**Status**: ⬜ Not Started

---

#### Scenario 2: Medium Risk Feature での実行（Design PR）

**Description**（説明）:
Medium Risk Feature の Design PR で `/sdlc-review-summary` を実行。

**Steps**（手順）:
1. テスト用の Medium Risk Feature を作成（`FEATURE-TEST-MEDIUM`）
2. Design PR を作成し、Review comments を追加（Critical/Important/Suggestions を含む）
3. `/sdlc-review-summary FEATURE-TEST-MEDIUM` を実行
4. `40_review_findings.md` が生成されることを確認
5. Review Type が "Design Review" と記載されることを確認

**Expected Result**（期待結果）:
- `40_review_findings.md` が生成される
- Review Type が "Design Review" と記載される
- Critical/Important/Suggestions が正しく分類される

**Status**: ⬜ Not Started

---

#### Scenario 3: PR が存在しない場合

**Description**（説明）:
PR が作成されていない Feature で `/sdlc-review-summary` を実行し、適切なエラーメッセージが表示されることを確認。

**Steps**（手順）:
1. テスト用の Feature を作成（`FEATURE-TEST-NO-PR`）
2. PR を作成せずに `/sdlc-review-summary FEATURE-TEST-NO-PR` を実行
3. エラーメッセージが表示されることを確認

**Expected Result**（期待結果）:
- エラーメッセージ: "Error: No PR found for feature/FEATURE-TEST-NO-PR. Please create a PR first."
- コマンドが異常終了する（exit code ≠ 0）
- `40_review_findings.md` は生成されない

**Status**: ⬜ Not Started

---

#### Scenario 4: AI Review Bot のコメントがある場合（Phase 2）

**Description**（説明）:
CodeRabbit などの AI Review Bot がコメントしている PR で `--include-ai` オプションを使用。

**Steps**（手順）:
1. AI Review Bot がコメントしている PR を用意
2. `/sdlc-review-summary FEATURE-TEST-AI --include-ai` を実行
3. AI Review Summary セクションが生成されることを確認
4. Human と AI のコメントが分離されていることを確認

**Expected Result**（期待結果）:
- AI Review Summary セクションが追加される
- Human comments と AI comments が分離される
- クロス分析が記載される

**Status**: ⬜ Not Started

---

#### Scenario 5: 複数の open PR がある場合

**Description**（説明）:
同じ feature ブランチで複数の open PR がある場合、最新のものが選択されることを確認。

**Steps**（手順）:
1. テスト用の Feature で2つの open PR を作成
2. `/sdlc-review-summary FEATURE-TEST-MULTI-PR` を実行
3. 最新の PR が選択されることを確認（PR 番号が表示される）
4. 警告メッセージが表示されることを確認

**Expected Result**（期待結果）:
- 最新の PR が選択される
- 警告メッセージ: "Warning: Multiple open PRs found. Using the latest one: #123"
- `40_review_findings.md` が生成される

**Status**: ⬜ Not Started

---

## E2E Tests（E2Eテスト）

### User Scenarios（ユーザーシナリオ）

#### E2E-1: 実際のワークフローでの使用（Low Risk）

**User Story**（ユーザーストーリー）:
開発者が Low Risk Feature の Code PR を作成し、レビューを受けた後、`/sdlc-review-summary` で Review Findings を記録する。

**Steps**（手順）:
1. `/sdlc-init` で Feature を作成
2. `/sdlc-decision` で Decision を確定
3. `/sdlc-coding` で実装を開始・完了
4. `/sdlc-pr-code` で Code PR を作成
5. GitHub で Review を実施（複数の Reviewer が comments を追加）
6. `/sdlc-review-summary {FEATURE_ID}` を実行
7. `40_review_findings.md` の内容を確認

**Expected Result**（期待結果）:
- 全てのコマンドが正常に動作
- `40_review_findings.md` が正しく生成される
- Review comments が適切に分類される
- ワークフローがスムーズに進む

**Status**: ⬜ Not Started

---

#### E2E-2: 実際のワークフローでの使用（Medium Risk）

**User Story**（ユーザーストーリー）:
開発者が Medium Risk Feature の Design PR と Code PR を作成し、それぞれのレビュー後に Review Findings を記録する。

**Steps**（手順）:
1. `/sdlc-init` で Medium Risk Feature を作成
2. `/sdlc-pr-design` で Design PR を作成
3. Design Review を実施
4. `/sdlc-review-summary {FEATURE_ID}` を実行（Design Review の記録）
5. `/sdlc-decision` で Decision を確定
6. `/sdlc-coding` で実装
7. `/sdlc-pr-code` で Code PR を作成
8. Code Review を実施
9. `/sdlc-review-summary {FEATURE_ID}` を再実行（Code Review で上書き）
10. `40_review_findings.md` の内容を確認

**Expected Result**（期待結果）:
- Design PR の Review Findings が記録される
- Code PR の Review Findings で上書きされる（最新の PR が優先）
- Review Type が正しく判定される

**Status**: ⬜ Not Started

---

## Performance Tests（パフォーマンステスト）

Medium Risk のため、本格的なパフォーマンステストは不要ですが、以下の基準を確認します：

### Performance Criteria（パフォーマンス基準）
- **Response Time**: <10秒（通常の PR）
- **API Calls**: 最小限（PR 1件につき 3-5 calls）
- **Rate Limit**: 通常の使用で Rate Limit に達しない

### Test Cases（テストケース）
- [ ] 通常の PR（コメント 10-20件）: 5秒以内に完了
- [ ] 大量のコメント（100件以上）: 30秒以内に完了
- [ ] GitHub API Rate Limit チェック: 残量を確認

---

## Security Tests（セキュリティテスト）

### Security Checklist（セキュリティチェックリスト）
- [ ] GitHub CLI の認証状態を確認（未認証時はエラー）
- [ ] Feature ID の入力検証（ディレクトリトラバーサル対策）
- [ ] GitHub API トークンの適切な扱い（`gh` CLI に委譲）
- [ ] 生成されるファイルのパーミッション確認

---

## Test Environment（テスト環境）

### Environment Setup（環境設定）
- **Repository**: lleizh/ai-driven-sdlc（実際のリポジトリ）
- **GitHub CLI**: インストール済み・認証済み
- **Test Features**: `FEATURE-TEST-*` という命名規則
- **Test PRs**: `[TEST]` プレフィックスを付けて識別

### Dependencies（依存関係）
- GitHub CLI (`gh`) ≥ 2.0
- Git
- Bash
- テスト用の PR（手動作成）

---

## Risk-Based Testing（リスクベーステスト）

| Risk ID | リスク領域 | 優先度 | テスト種別 | ステータス |
|---------|-----------|--------|-----------|-----------|
| R001 | GitHub API Rate Limit | Medium | Integration | ⬜ |
| R002 | 分類ロジックの精度 | Medium | Unit + Integration | ⬜ |
| R003 | PR 検出の誤判定 | Low | Unit + Integration | ⬜ |
| R004 | AI Bot 識別の網羅性 | Low | Unit (Phase 2) | ⬜ |

---

## Test Execution（テスト実行）

### Execution Plan（実行計画）

1. **Phase 1: Unit Tests**
   - Duration: 2-3時間
   - Owner: 実装者

2. **Phase 2: Integration Tests**
   - Duration: 3-4時間
   - Owner: 実装者

3. **Phase 3: E2E Tests**
   - Duration: 2-3時間
   - Owner: 実装者 + Reviewer

### Test Schedule（テストスケジュール）
```
Day 1: Unit Tests（実装と並行）
Day 2: Integration Tests
Day 3: E2E Tests + Bug Fix
```

---

## Exit Criteria（終了基準）

### Mandatory（必須）
- [ ] All planned tests executed（全計画テスト実行完了）
- [ ] Unit test coverage ≥ 80%
- [ ] Integration test coverage: 全シナリオ実行
- [ ] No critical bugs open（クリティカルバグなし）
- [ ] All High priority bugs fixed（高優先度バグ修正完了）

### Risk-Level Specific（リスクレベル別）

**Medium Risk**:
- [ ] E2E tests passed（E2Eテスト成功）
- [ ] No high/medium bugs open（高・中バグなし）
- [ ] Low/Medium/High Risk Feature で各1回テスト成功

---

## Test Results Summary（テスト結果サマリー）

| テストタイプ | 実行数 | 成功 | 失敗 | カバレッジ |
|-------------|-------|------|------|-----------|
| Unit | TBD | TBD | TBD | TBD |
| Integration | TBD | TBD | TBD | - |
| E2E | TBD | TBD | TBD | - |

**Test Execution Date**（実行日）: TBD

---

## Known Issues（既知の問題）

| Issue ID | 説明 | 優先度 | ステータス | 担当者 |
|----------|------|--------|-----------|--------|
| - | - | - | - | - |

---

## Notes（備考）

- テストは実際の GitHub PR を使用して実施します
- テスト用の Feature は `FEATURE-TEST-*` という命名規則を使用します
- Phase 2（AI Review 統合）のテストは Phase 1 完成後に実施します
- Rate Limit のテストは慎重に実施します（実際に制限に達しないように）
