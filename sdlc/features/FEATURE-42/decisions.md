# Decisions（決定事項）

**Feature ID**: FEATURE-42  
**Last Updated**: 2025-12-30

---

## Decision 1: PR 検出方法

**Status**: PENDING  
**Date**（日付）: 2025-12-30  
**Decision Maker**（意思決定者）: TBD

### Context（背景）

Feature ID から対応する PR を検出する方法を決定する必要があります。複数の PR が存在する場合や、open/merged 状態が混在する場合の挙動を明確にする必要があります。

### Options Considered（検討した選択肢）

#### Option A: 完全自動検出（最新の open PR 優先）

**Pros**（長所）:
- ユーザーは feature-id のみ指定すれば良い
- 標準的なワークフローで最も使いやすい
- SDLC_FLOW.md の順序（Design → Code）に従えば自動判別可能

**Cons**（短所）:
- 複数の open PR がある場合の挙動が不明確
- エッジケースで誤った PR を選択する可能性

**Cost/Effort**（コスト・工数）: 低（実装は比較的シンプル）

#### Option B: PR 番号を必須パラメータにする

**Pros**（長所）:
- 明示的で誤判定のリスクがない
- 複数 PR がある場合も対応可能

**Cons**（短所）:
- ユーザーが PR 番号を調べる必要がある（手間）
- コマンドが冗長になる
- 「Convention over Configuration」の原則に反する

**Cost/Effort**（コスト・工数）: 低

#### Option C: 対話式選択

**Pros**（長所）:
- 複数 PR がある場合にユーザーが選択できる
- 誤判定を防げる

**Cons**（短所）:
- 自動化スクリプトで使いにくい
- CI/CD パイプラインでの実行が困難
- 実装が複雑

**Cost/Effort**（コスト・工数）: 中

### Decision（決定）
**Chosen Option**（選択した選択肢）: TBD

**Rationale**（理由）:


**Accepted Risks**（受け入れたリスク）:
- 

**Non-Negotiables**（譲れない点）:
- ユーザビリティを最優先にする
- 標準的なワークフローで最も使いやすい方法を選ぶ

### Impact（影響）
- **Technical**（技術的）: PR 検出ロジックの実装方針が決まる
- **Team**（チーム）: コマンドの使い方に影響
- **Timeline**（タイムライン）: Option A/B は影響なし、Option C は +1-2日
- **Cost**（コスト）: 実装工数への影響

### Follow-up Actions（フォローアップアクション）
- [ ] 選択した Option に基づいて実装する
- [ ] エラーメッセージを適切に設計する
- [ ] ドキュメントにエッジケースの挙動を記載する

---

## Decision 2: Review Type 判定方法

**Status**: PENDING  
**Date**（日付）: 2025-12-30  
**Decision Maker**（意思決定者）: TBD

### Context（背景）

PR が Design Review なのか Code Review なのかを判定する必要があります。`40_review_findings.md` には Review Type を記載する必要があるため、これを自動判定するか手動指定するかを決める必要があります。

### Options Considered（検討した選択肢）

#### Option A: PR Label から自動判定

**Pros**（長所）:
- 完全自動化
- `/sdlc-pr-design` と `/sdlc-pr-code` が label を付与するため、判定可能
- ユーザーの手間なし

**Cons**（短所）:
- label が付与されていない PR では判定不可
- label 命名規則への依存

**Cost/Effort**（コスト・工数）: 低

#### Option B: 手動指定（`--type design|code`）

**Pros**（長所）:
- 明示的で確実
- label がない PR でも対応可能

**Cons**（短所）:
- ユーザーが毎回指定する必要がある
- 「Convention over Configuration」に反する

**Cost/Effort**（コスト・工数）: 低

#### Option C: 時系列から推論

**Pros**（長所）:
- 完全自動化
- SDLC_FLOW.md の順序（Design → Code）に基づいて推論

**Cons**（短所）:
- Low Risk Feature では Design PR がない場合がある
- 推論が複雑になる

**Cost/Effort**（コスト・工数）: 中

### Decision（決定）
**Chosen Option**（選択した選択肢）: TBD

**Rationale**（理由）:


**Accepted Risks**（受け入れたリスク）:
- 

**Non-Negotiables**（譲れない点）:
- `/sdlc-pr-design` と `/sdlc-pr-code` との整合性を保つ
- 自動化を優先する

### Impact（影響）
- **Technical**（技術的）: Review Type 判定ロジックの実装
- **Team**（チーム）: コマンドの使い方に影響
- **Timeline**（タイムライン）: Option A/B は影響なし、Option C は +1日
- **Cost**（コスト）: 実装工数への影響

### Follow-up Actions（フォローアップアクション）
- [ ] 選択した Option に基づいて実装する
- [ ] `/sdlc-pr-design` と `/sdlc-pr-code` の label 付与を確認する
- [ ] エッジケースの処理を実装する

---

## Decision 3: AI Review 統合のタイミング

**Status**: PENDING  
**Date**（日付）: 2025-12-30  
**Decision Maker**（意思決定者）: TBD

### Context（背景）

AI Review Bot の統合を Phase 1 で実装するか、Phase 2 で実装するかを決定する必要があります。Issue では Phase 2 として記載されていますが、実装の優先順位を明確にする必要があります。

### Options Considered（検討した選択肢）

#### Option A: Phase 2 として実装（Issue 通り）

**Pros**（長所）:
- Phase 1 で基礎を固めてから拡張できる
- リスクを分散できる
- Phase 1 の完成を優先できる

**Cons**（短所）:
- AI Review の恩恵を受けるのが遅れる
- 2回に分けて実装する必要がある

**Cost/Effort**（コスト・工数）: Phase 1: 中、Phase 2: 低

#### Option B: Phase 1 に統合して一度に実装

**Pros**（長所）:
- 一度に完成させられる
- 実装の重複を避けられる

**Cons**（短所）:
- Phase 1 の完成が遅れる
- リスクが高まる（一度に多くの機能を実装）

**Cost/Effort**（コスト・工数）: 高

#### Option C: オプション機能として Phase 1 に含める

**Pros**（長所）:
- Phase 1 で基本機能を提供しつつ、AI Review も使える
- `--include-ai` フラグで切り替え可能

**Cons**（短所）:
- Phase 1 の実装が複雑化
- テストケースが増える

**Cost/Effort**（コスト・工数）: 中〜高

### Decision（決定）
**Chosen Option**（選択した選択肢）: TBD

**Rationale**（理由）:


**Accepted Risks**（受け入れたリスク）:
- 

**Non-Negotiables**（譲れない点）:
- Phase 1 の基本機能を優先する
- 段階的なリリースを可能にする

### Impact（影響）
- **Technical**（技術的）: 実装の複雑さとテスト範囲
- **Team**（チーム）: AI Review 機能の利用可能時期
- **Timeline**（タイムライン）: Phase 1 完成時期に影響
- **Cost**（コスト）: 実装工数への影響

### Follow-up Actions（フォローアップアクション）
- [ ] 選択した Option に基づいて実装計画を立てる
- [ ] AI Bot のリストを確定する
- [ ] クロス分析のロジックを設計する

---

## Decision 4: 分類ロジックの実装方法

**Status**: PENDING  
**Date**（日付）: 2025-12-30  
**Decision Maker**（意思決定者）: TBD

### Context（背景）

Review Comments を Critical/Important/Suggestions に分類するロジックをどう実装するかを決定する必要があります。規則ベースか、LLM ベースか、ハイブリッドかを選択します。

### Options Considered（検討した選択肢）

#### Option A: 規則ベース（キーワード + Emoji）

**Pros**（長所）:
- 実装がシンプル
- 高速で確実
- デバッグしやすい
- 外部依存なし（GitHub API のみ）

**Cons**（短所）:
- キーワードにない表現は誤分類される可能性
- Emoji を使わないレビューでは精度が落ちる
- 定期的にキーワードリストのメンテナンスが必要

**Cost/Effort**（コスト・工数）: 低

#### Option B: LLM ベース（Claude API 等）

**Pros**（長所）:
- 自然言語理解により高精度
- キーワードに依存しない
- コンテキストを考慮した分類

**Cons**（短所）:
- 外部 API への依存（コスト、レイテンシ）
- Rate limit の考慮が必要
- 実装が複雑
- オフライン環境で動作しない

**Cost/Effort**（コスト・工数）: 高

#### Option C: ハイブリッド（規則 + LLM）

**Pros**（長所）:
- 明確なケースは規則で高速処理
- 曖昧なケースは LLM で高精度処理
- 柔軟性が高い

**Cons**（短所）:
- 実装が最も複雑
- どちらを使うかの判定ロジックが必要
- LLM の外部依存が残る

**Cost/Effort**（コスト・工数）: 高

### Decision（決定）
**Chosen Option**（選択した選択肢）: TBD

**Rationale**（理由）:


**Accepted Risks**（受け入れたリスク）:
- 

**Non-Negotiables**（譲れない点）:
- シンプルさを優先する
- 外部依存を最小限にする（GitHub API のみが理想）

### Impact（影響）
- **Technical**（技術的）: 分類エンジンの実装方針
- **Team**（チーム）: 分類精度への期待値
- **Timeline**（タイムライン）: Option A は影響なし、Option B/C は +2-3日
- **Cost**（コスト）: LLM API 使用料（Option B/C の場合）

### Follow-up Actions（フォローアップアクション）
- [ ] 選択した Option に基づいて実装する
- [ ] キーワードリストを作成・メンテナンスする（Option A の場合）
- [ ] LLM プロンプトを設計する（Option B/C の場合）
- [ ] 分類精度のテストケースを作成する

---

## Decision History（決定履歴）

### Revisions（改訂）

（現時点では改訂なし）
