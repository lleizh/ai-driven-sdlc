# Requirements（要件）

**Feature ID**: FEATURE-42  
**Last Updated**: 2025-12-30

## Functional Requirements（機能要件）

### Must Have (P0)（必須）

#### Phase 1: 基礎実装
- [ ] `/sdlc-review-summary <feature-id>` コマンドで実行できる
- [ ] `feature/{FEATURE_ID}` ブランチから PR を自動検出できる
- [ ] open PR を優先的に選択する（なければ最新の merged）
- [ ] PR が見つからない場合に適切なメッセージを表示する
- [ ] PR の Review comments を取得できる
- [ ] Inline comments も取得できる
- [ ] キーワードと emoji で Critical/Important/Suggestions に分類できる
- [ ] Reviewer の state を考慮できる（CHANGES_REQUESTED 等）
- [ ] `40_review_findings.md` を正しいフォーマットで生成できる
- [ ] Feature ID, Date, Reviewers が自動入力される
- [ ] Review Type (Design/Code) が label から自動判定される
- [ ] 分類された内容が適切なセクションに配置される
- [ ] `.claude/commands/sdlc-review-summary.md` が作成されている
- [ ] コマンドの使用方法と例が記載されている
- [ ] PR 未作成時のエラーメッセージが適切
- [ ] GitHub API エラー時の処理が適切

### Should Have (P1)（推奨）

#### Phase 2: AI Review 統合
- [ ] `--include-ai` オプションで AI Review を統合できる
- [ ] 主要な AI Bot を識別できる（CodeRabbit, Copilot 等）
- [ ] AI comments と Human comments を分離できる
- [ ] AI findings の統計を取得できる（Critical/Warning/Info）
- [ ] 重要な AI 発見事項を抽出できる
- [ ] 適用された AI 提案を記録できる
- [ ] Human と AI 両方が発見した問題を識別できる
- [ ] Human のみ発見した問題を識別できる
- [ ] AI のみ発見した問題を識別できる
- [ ] AI Review Summary セクションが生成される
- [ ] `--include-ai` オプションの説明が追加されている
- [ ] AI Review の扱いについて記載されている

### Nice to Have (P2)（あれば良い）

- [ ] 複数 PR がある場合に選択できる
- [ ] PR 番号を明示的に指定できる（`--pr <number>` オプション）
- [ ] Review Type を手動指定できる（`--type design|code` オプション）
- [ ] 特定の Reviewer のコメントのみ抽出できる
- [ ] 過去の Review Findings と比較する機能
