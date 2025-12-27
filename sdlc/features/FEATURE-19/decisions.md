# Decisions（決定事項）

**Feature ID**: FEATURE-19  
**Last Updated**: 2025-12-27

---

## Decision 1: Workflow Trigger Timing

**Status**: CONFIRMED  
**Date**（日付）: 2025-12-27  
**Decision Maker**（意思決定者）: lleizh

### Context（背景）

PR が develop にマージされたタイミングで STATUS を更新する必要があるが、どのタイミングで Workflow をトリガーするかを決定する必要がある。

### Options Considered（検討した選択肢）

#### Option A: PR merged event (on pull_request closed + merged condition)
**Pros**（長所）:
- PR マージ直後に即座に実行される
- GitHub の標準イベントを使用
- 実装がシンプル

**Cons**（短所）:
- マージ直後のため、CI/CD の他の処理と並行実行される可能性
- タイミングによっては競合が発生する可能性

**Cost/Effort**（コスト・工数）: 低（標準的な実装）

**Decision**: REJECTED

#### Option B: push event to develop branch
**Pros**（長所）:
- マージ後の develop ブランチへの push を確実に検知
- 他の Workflow との実行順序を制御しやすい

**Cons**（短所）:
- 直接 develop への push も検知してしまう（feature ブランチ以外）
- Feature ID の抽出が複雑になる

**Cost/Effort**（コスト・工数）: 中（条件判定の追加実装が必要）

**Decision**: ✅ CHOSEN

#### Option C: workflow_run event (after other workflows complete)
**Pros**（長所）:
- 他の Workflow 完了後に実行できる
- 競合を避けられる

**Cons**（短所）:
- 実行タイミングが遅れる
- 依存する Workflow の設定が必要
- 実装が複雑

**Cost/Effort**（コスト・工数）: 高（複雑な依存関係の設定が必要）

**Decision**: REJECTED

### Decision（決定）
**Chosen Option**（選択した選択肢）: Option B (push event to develop branch)

**Rationale**（理由）:
- push event を使用することで実行条件をより精確に制御し、不要な workflow 実行を避けられる
- スクリプト内で feature ブランチからの merge かどうかを判定し、条件に合わない場合は早期に exit することで Actions 使用量を節約できる
- pull_request event より制御しやすく、誤トリガーを減らせる
- GitHub Actions の無料使用量制限を考慮し、workflow 実行を正確に制御する必要がある

**Accepted Risks**（受け入れたリスク）:
- push が feature ブランチからの merge かどうかを判定する追加ロジックが必要
- Feature ID の抽出がやや複雑（ただし commit message または git log から取得可能）

**Non-Negotiables**（譲れない点）:
- feature/* ブランチのマージのみを対象とする
- design/* ブランチは対象外
- `.metadata` ファイルが存在しない場合はスキップする

### Impact（影響）
- **Technical**（技術的）: Workflow の実装方法に影響
- **Team**（チーム）: 実行タイミングの可視性
- **Timeline**（タイムライン）: 実装工数に影響
- **Cost**（コスト）: GitHub Actions の実行時間

### Follow-up Actions（フォローアップアクション）
- [ ] チームで議論して Option を決定
- [ ] 選択した Option での PoC 実装

---

## Decision 2: Error Handling Strategy

**Status**: CONFIRMED  
**Date**（日付）: 2025-12-27  
**Decision Maker**（意思決定者）: lleizh

### Context（背景）

Workflow 実行中にエラーが発生した場合（`.metadata` ファイルが存在しない、Feature ID が抽出できないなど）の処理方法を決定する必要がある。

### Options Considered（検討した選択肢）

#### Option A: Fail workflow with error
**Pros**（長所）:
- 問題を明確に通知できる
- PR マージ後の問題を見逃さない

**Cons**（短所）:
- feature 以外のブランチでも失敗する
- ノイズが多くなる可能性

**Cost/Effort**（コスト・工数）: 低

**Decision**: ✅ CHOSEN

#### Option B: Skip silently with warning log
**Pros**（長所）:
- ノイズが少ない
- feature 以外のブランチでも問題にならない
- Workflow が失敗扱いにならない

**Cons**（短所）:
- 実際の問題を見逃す可能性
- ログを確認しないと気づかない

**Cost/Effort**（コスト・工数）: 低

**Decision**: REJECTED

#### Option C: Notify via GitHub Issue comment
**Pros**（長所）:
- 問題を PR に通知できる
- 見逃しにくい

**Cons**（短所）:
- 実装が複雑
- PR がマージ済みの場合、通知先が不明確

**Cost/Effort**（コスト・工数）: 中

**Decision**: REJECTED

### Decision（決定）
**Chosen Option**（選択した選択肢）: Option A (Fail workflow with error)

**Rationale**（理由）:
- 問題を明確に通知し、静かな失敗によるステータス不一致を避ける
- feature ブランチの merge は正しくステータスを更新すべきで、失敗は修正が必要な問題を示す
- 追加の Actions 時間を消費するが、失敗率は低いと予想される（<5%）
- Decision 1 の精確な制御戦略と一致し、必要な時のみ実行を保証

**Accepted Risks**（受け入れたリスク）:
- 設定が間違っている場合、ノイズが発生する可能性
- 失敗原因を手動で確認して修復する必要がある

**Non-Negotiables**（譲れない点）:
- ログに明確なメッセージを出力する
- feature/* ブランチ以外のケースは早期に判定して exit 0 で終了（失敗扱いにしない）

### Impact（影響）
- **Technical**（技術的）: エラーハンドリングの実装
- **Team**（チーム）: 問題発見の容易さ
- **Timeline**（タイムライン）: 実装工数に影響
- **Cost**（コスト）: 通知方法によって変わる

### Follow-up Actions（フォローアップアクション）
- [ ] チームで議論して Option を決定
- [ ] エラーケースのテスト方法を検討

---

## Decision 3: Branch Name Pattern Matching

**Status**: CONFIRMED  
**Date**（日付）: 2025-12-27  
**Decision Maker**（意思決定者）: lleizh

### Context（背景）

Feature ID をブランチ名から抽出する際の正規表現パターンを決定する必要がある。現在のブランチ命名規則 `feature/FEATURE-XXX` に従う必要がある。

### Options Considered（検討した選択肢）

#### Option A: Strict pattern (^feature/FEATURE-[0-9]+$)
**Pros**（長所）:
- 厳密なパターンマッチング
- 誤検出が少ない
- 命名規則の遵守を強制

**Cons**（短所）:
- 柔軟性がない
- 将来的な命名規則の変更に対応しにくい

**Cost/Effort**（コスト・工数）: 低

**Decision**: ✅ CHOSEN

#### Option B: Flexible pattern (feature/FEATURE-[0-9]+)
**Pros**（長所）:
- ブランチ名に追加の suffix があっても対応可能
- 柔軟性がある

**Cons**（短所）:
- 誤検出の可能性がある

**Cost/Effort**（コスト・工数）: 低

**Decision**: REJECTED

### Decision（決定）
**Chosen Option**（選択した選択肢）: Option A (Strict pattern ^feature/FEATURE-[0-9]+$)

**Rationale**（理由）:
- ブランチ命名規則を強制し、誤マッチによる誤った metadata 更新を避ける
- 厳密なマッチングにより早期段階で workflow を終了でき、Actions 使用量を節約できる
- Fail workflow 戦略と一致し、プロセスの厳密性を確保
- 開発者が誤ったブランチ名を使用した場合、早期にフィードバックを提供できる

**Accepted Risks**（受け入れたリスク）:
- 開発者が誤ったブランチ名形式を使用した場合、ブランチをリネームするか手動でステータスを更新する必要がある
- 将来的にブランチ命名規則を変更する場合、正規表現パターンも更新が必要

**Non-Negotiables**（譲れない点）:
- FEATURE-XXX の形式を厳守
- design/* ブランチは除外

### Impact（影響）
- **Technical**（技術的）: 正規表現の実装
- **Team**（チーム）: ブランチ命名規則の遵守
- **Timeline**（タイムライン）: 最小限
- **Cost**（コスト）: なし

### Follow-up Actions（フォローアップアクション）
- [ ] 既存のブランチ命名規則を確認
- [ ] 将来的な拡張性を考慮して決定

---

## Decision History（決定履歴）

### Revisions（改訂）

（まだ改訂なし）

---

## Quick Reference（クイックリファレンス）

### All Confirmed Decisions（全確定済み決定）
1. **Workflow Trigger Timing**: Option B (push event to develop branch) - 2025-12-27 by lleizh
2. **Error Handling Strategy**: Option A (Fail workflow with error) - 2025-12-27 by lleizh
3. **Branch Name Pattern Matching**: Option A (Strict pattern ^feature/FEATURE-[0-9]+$) - 2025-12-27 by lleizh

### Pending Decisions（保留中の決定）
（なし）

---

## Notes（備考）

- FEATURE-20 が完了していることを前提とする
- 既存の `sync-projects.yml` が自動的にトリガーされることを利用する
- 実装前に各 Decision の確定が必要
