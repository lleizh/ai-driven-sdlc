# Decisions（決定事項）

**Feature ID**: FEATURE-33  
**Last Updated**: 2025-12-27

---

## Decision 1: Issue クローズ時のコメント内容

**Status**: CONFIRMED  
**Date**（日付）: 2025-12-27  
**Decision Maker**（意思決定者）: lleizh

### Context（背景）

Issue を自動的にクローズする際に、どのようなコメントを付けるかを決定する必要があります。コメントの内容によって、開発者が後から確認した際の理解のしやすさが変わります。

### Options Considered（検討した選択肢）

#### Option A: シンプルなメッセージ ✅ CHOSEN
**Pros**（長所）:
- コメントが短く、読みやすい
- 実装がシンプル

**Cons**（短所）:
- 詳細情報が不足する可能性がある
- どの PR でマージされたかが不明

**Cost/Effort**（コスト・工数）: 低

**Example**: `✅ Feature completed and merged to develop. Automatically closed by workflow.`

**Decision**: ✅ CHOSEN

#### Option B: 詳細情報を含むメッセージ
**Pros**（長所）:
- PR 番号、commit SHA などの詳細情報を含む
- トレーサビリティが高い
- デバッグがしやすい

**Cons**（短所）:
- コメントが長くなる
- 実装がやや複雑

**Cost/Effort**（コスト・工数）: 中

**Example**: `✅ Feature completed and merged to develop via PR #{PR_NUMBER} (commit: {SHA}). Automatically closed by workflow.`

**Decision**: REJECTED

#### Option C: リンク付きメッセージ
**Pros**（長所）:
- PR や commit への直接リンクを含む
- 最も詳細な情報提供
- ワンクリックで関連情報にアクセス可能

**Cons**（短所）:
- コメントが最も長い
- 実装が最も複雑

**Cost/Effort**（コスト・工数）: 高

**Example**: `✅ Feature completed and merged to develop via [PR #{PR_NUMBER}]({PR_URL}) ([commit {SHA_SHORT}]({COMMIT_URL})). Automatically closed by workflow.`

**Decision**: REJECTED

### Decision（決定）
**Chosen Option**（選択した選択肢）: Option A (シンプルなメッセージ)

**Rationale**（理由）:
- 最もシンプルで実装しやすい
- コメント内容が短く読みやすい
- 自動化によるクローズであることが明確
- Low Risk の Feature であり、シンプルな実装で十分
- 必要に応じて Issue から関連 PR を確認できる

**Accepted Risks**（受け入れたリスク）:
- PR 番号が直接表示されないため、Issue から PR を辿る必要がある
- デバッグ時に若干の手間が増える可能性

**Non-Negotiables**（譲れない点）:
- 自動化によるクローズであることを明記する
- 英語でのメッセージ（GitHub の標準言語）
- 視覚的に分かりやすい絵文字（✅）を使用

### Impact（影響）
- **Technical**（技術的）: コメント生成ロジックの複雑さ
- **Team**（チーム）: トレーサビリティの度合い
- **Timeline**（タイムライン）: 実装工数に影響
- **Cost**（コスト）: 最小限

### Follow-up Actions（フォローアップアクション）
- [ ] チームで議論して Option を決定
- [ ] 選択した Option での実装を確認

---

## Decision 2: エラーハンドリング戦略

**Status**: CONFIRMED  
**Date**（日付）: 2025-12-27  
**Decision Maker**（意思決定者）: lleizh

### Context（背景）

`.metadata` に ISSUE_URL が存在しない場合や、Issue 番号の抽出に失敗した場合のエラーハンドリング方法を決定する必要があります。

### Options Considered（検討した選択肢）

#### Option A: 警告を出してスキップ ✅ CHOSEN
**Pros**（長所）:
- workflow が失敗しない
- 他の処理に影響を与えない
- ノイズが少ない

**Cons**（短所）:
- Issue がクローズされないことに気づきにくい
- ログを確認しないと問題が分からない

**Cost/Effort**（コスト・工数）: 低

**Decision**: ✅ CHOSEN

#### Option B: エラーで失敗させる
**Pros**（長所）:
- 問題を明確に通知できる
- Issue がクローズされなかったことが明白
- 問題の修正を強制できる

**Cons**（短所）:
- workflow 全体が失敗扱いになる
- STATUS 更新は成功しているのに失敗と見える可能性

**Cost/Effort**（コスト・工数）: 低

**Decision**: REJECTED

### Decision（決定）
**Chosen Option**（選択した選択肢）: Option A (警告を出してスキップ)

**Rationale**（理由）:
- STATUS 更新は正常に完了しており、Issue クローズは付加的な機能
- Issue クローズ失敗で workflow 全体を失敗扱いにするのは過剰
- ログに明確な警告メッセージを出力することで問題を把握可能
- 手動で Issue をクローズする代替手段が存在する
- workflow の安定性を優先

**Accepted Risks**（受け入れたリスク）:
- ログを確認しない場合、Issue がクローズされていないことに気づかない可能性
- 手動での Issue クローズ作業が発生する可能性

**Non-Negotiables**（譲れない点）:
- エラー時のログは明確に出力する（⚠️ 警告マークを使用）
- ISSUE_URL の存在確認は必須
- `.metadata` ファイルの存在確認は必須
- Issue 番号抽出失敗時のエラーメッセージを詳細に記録

### Impact（影響）
- **Technical**（技術的）: エラーハンドリングの実装
- **Team**（チーム）: 問題発見の容易さ
- **Timeline**（タイムライン）: 最小限
- **Cost**（コスト）: なし

### Follow-up Actions（フォローアップアクション）
- [ ] チームで議論して Option を決定
- [ ] エラーケースのテスト方法を検討

---

## Decision History（決定履歴）

### Revisions（改訂）

（まだ改訂なし）

---

## Quick Reference（クイックリファレンス）

### All Confirmed Decisions（全確定済み決定）
1. **Issue クローズ時のコメント内容**: Option A (シンプルなメッセージ) - 2025-12-27 by lleizh
2. **エラーハンドリング戦略**: Option A (警告を出してスキップ) - 2025-12-27 by lleizh

### Pending Decisions（保留中の決定）
（なし）

---

## Notes（備考）

- Issue の How セクションに初期案が記載されているが、これを Option A として扱い、他の選択肢も検討する
- FEATURE-19 の実装パターンを参考にできる
