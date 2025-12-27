# Decisions（決定事項）

**Feature ID**: FEATURE-24  
**Last Updated**: 2025-12-27

---

## Decision 1: Workflow トリガーとラベル名

**Status**: CONFIRMED  
**Date**（日付）: 2025-12-27  
**Decision Maker**（意思決定者）: lleizh

### Context（背景）

Issue を GitHub Projects に自動追加するために、どのラベルをトリガーとして使用するかを決定する必要がある。Issue に記載された初期案では `sdlc:track` を提案している。

### Options Considered（検討した選択肢）

#### Option A: `sdlc:track` ラベルを使用（Issue 提案）
**Pros**（長所）:
- 明確な命名（SDLC 管理対象であることが明示的）
- 既存のラベル体系と整合性がある（`sdlc:` プレフィックス）
- `install.sh` で自動作成可能

**Cons**（短所）:
- 新しいラベルを追加する必要がある
- 既存 Issue には手動でラベル追加が必要

**Cost/Effort**（コスト・工数）: Low（`install.sh` への追加のみ）

#### Option B: 既存の `feature` / `bug` ラベルを使用
**Pros**（長所）:
- 新しいラベルが不要
- 既存 Issue が自動的に対象になる

**Cons**（短所）:
- すべての feature/bug が自動的に Projects に追加される（選択性がない）
- ラベル削除時の智能的な判断ロジックが複雑になる
- Issue の種類とプロジェクト管理を混同

**Cost/Effort**（コスト・工数）: Low

#### Option C: `projects:auto-add` など汎用的な名前
**Pros**（長所）:
- より汎用的な命名
- 将来的に複数プロジェクトに対応しやすい

**Cons**（短所）:
- SDLC 特化システムとしての一貫性が低い
- やや冗長

**Cost/Effort**（コスト・工数）: Low

### Decision（決定）
**Chosen Option**（選択した選択肢）: Option A - `sdlc:track` ラベルを使用

**Rationale**（理由）:
- SDLC 管理対象であることが明示的で、チームにとって理解しやすい
- 既存のラベル体系（`sdlc:` プレフィックス）と整合性がある
- `install.sh` で自動作成可能であり、Non-Negotiables を満たす
- 選択的に Issue を管理できる（すべての Issue が自動追加されない）

**Accepted Risks**（受け入れたリスク）:
- 既存 Issue には手動でラベル追加が必要（影響は限定的）

**Non-Negotiables**（譲れない点）:
- ラベルは `install.sh` で自動作成可能であること ✓
- 既存のラベル体系と整合性があること ✓

### Impact（影響）
- **Technical**（技術的）: Workflow のトリガー設定に影響
- **Team**（チーム）: チームメンバーがラベルの使い方を理解する必要
- **Timeline**（タイムライン）: 実装に影響なし
- **Cost**（コスト）: なし

### Follow-up Actions（フォローアップアクション）
- [ ] ラベル名を確定
- [ ] `install.sh` に追加
- [ ] ドキュメントを更新

---

## Decision 2: ラベル削除時の智能的な削除ロジック

**Status**: CONFIRMED  
**Date**（日付）: 2025-12-27  
**Decision Maker**（意思決定者）: lleizh

### Context（背景）

Issue からラベルを削除したときに、Projects からも削除するかを判断する必要がある。Issue では以下のロジックを提案：
- `.metadata` が存在しない（未初期化）→ Projects から削除
- `.metadata` が存在する（初期化済み）→ Projects に保持

### Options Considered（検討した選択肢）

#### Option A: `.metadata` の有無で判断（Issue 提案）
**Pros**（長所）:
- 論理的で一貫性がある
- `/sdlc-init` 実行済みの Feature は保持される
- 誤ってラベルを削除しても Feature は残る

**Cons**（短所）:
- Repository checkout が必要（API 呼び出しが増える）
- ファイルシステムアクセスが必要

**Cost/Effort**（コスト・工数）: Medium（checkout 処理が必要）

#### Option B: 常に Projects から削除
**Pros**（長所）:
- シンプルな実装
- Checkout 不要

**Cons**（短所）:
- `/sdlc-init` 実行済みの Feature も削除される
- `sync-projects.yml` が再度追加するため、不整合が発生する可能性

**Cost/Effort**（コスト・工数）: Low

#### Option C: 常に Projects に保持
**Pros**（長所）:
- シンプルな実装
- データロスのリスクなし

**Cons**（短所）:
- ラベルを削除しても Projects から削除されない（直感に反する）
- 不要な Issue が Projects に残り続ける

**Cost/Effort**（コスト・工数）: Low

### Decision（決定）
**Chosen Option**（選択した選択肢）: Option A - `.metadata` の有無で判断

**Rationale**（理由）:
- `/sdlc-init` 実行済みの Feature を保護できる（Non-Negotiables を満たす）
- `sync-projects.yml` との競合を回避（重複防止機構により安全）
- 論理的で一貫性のある動作（`.metadata` を唯一の真実の源として尊重）
- 既存の `sync-projects.yml` のパターンを踏襲（実装リスク軽減）

**Accepted Risks**（受け入れたリスク）:
- Risk R001 (Medium): `.metadata` ファイル確認の実装複雑性
  - 軽減策: 既存パターンの再利用、十分なエラーハンドリング
- API 呼び出しの増加（repository checkout が必要）
  - 軽減策: Retry 機構の実装

**Non-Negotiables**（譲れない点）:
- `/sdlc-init` 実行済みの Feature は Projects に保持されること ✓
- `sync-projects.yml` との競合がないこと ✓

### Impact（影響）
- **Technical**（技術的）: Workflow の複雑性と API 使用量に影響
- **Team**（チーム）: ラベル削除の挙動を理解する必要
- **Timeline**（タイムライン）: Option A は実装に時間がかかる
- **Cost**（コスト）: Option A は API レート制限への影響あり

### Follow-up Actions（フォローアップアクション）
- [ ] 削除ロジックを確定
- [ ] Workflow を実装
- [ ] テストケースを作成

---

## Decision 3: Backlog 状態の導入

**Status**: CONFIRMED  
**Date**（日付）: 2025-12-27  
**Decision Maker**（意思決定者）: lleizh

### Context（背景）

Issue に記載された実装タスクには、GitHub Projects の Status フィールドに "Backlog" オプションを追加することが含まれている。これは `sdlc:track` ラベルで追加された Issue の初期状態として使用される。

**Backlog 状態の定義：**
- Issue が `sdlc:track` ラベルで Projects に追加された直後の状態
- まだ `/sdlc-init` を実行していない（`.metadata` なし）
- 初期分析待ち、SDLC 管理前の状態

**状態遷移：**
```
Backlog → Planning → Design → Implementation → Testing → Review → Done
  ↑          ↑
  label    /sdlc-init
```

### Options Considered（検討した選択肢）

#### Option A: Backlog 状態を追加（Issue 提案）
**Pros**（長所）:
- Issue のライフサイクル全体を可視化
- `/sdlc-init` 実行前の Issue を明確に区別
- PM が未着手の Issue を一目で把握可能

**Cons**（短所）:
- 新しい状態を追加（既存の状態管理システムへの影響）
- `.metadata` に記録されない特殊な状態（他の状態と一貫性がない）
- `sync-projects.yml` が Backlog → Planning に更新する必要

**Cost/Effort**（コスト・工数）: Medium（`install.sh` と `sync-projects.yml` の更新が必要）

#### Option B: Planning 状態のまま開始
**Pros**（長所）:
- 既存の状態管理システムを変更しない
- シンプル

**Cons**（短所）:
- `/sdlc-init` 実行前と実行後の区別ができない
- Issue のライフサイクルが不明確

**Cost/Effort**（コスト・工数）: Low

#### Option C: カスタムフィールドで管理
**Pros**（長所）:
- Status フィールドを変更しない
- より柔軟な管理が可能

**Cons**（短所）:
- 新しいフィールドを追加する必要がある
- UI が複雑になる
- 既存のフィールド体系と整合性が取れない

**Cost/Effort**（コスト・工数）: High

### Decision（決定）
**Chosen Option**（選択した選択肢）: Option A - Backlog 状態を追加

**Rationale**（理由）:
- Issue のライフサイクル全体を可視化できる（PM/管理層の要求を満たす）
- `/sdlc-init` 実行前と実行後を明確に区別できる
- 既存の SDLC フローと整合性がある（状態遷移が自然）
- Medium 工数だが、長期的な可視性向上のメリットが大きい

**Accepted Risks**（受け入れたリスク）:
- `.metadata` に記録されない特殊な状態（Backlog のみ例外）
  - 軽減策: ドキュメントで明記、`sync-projects.yml` が自動的に Planning に更新
- `install.sh` と `sync-projects.yml` の更新が必要（Medium 工数）
  - 軽減策: 既存のコードパターンを踏襲

**Non-Negotiables**（譲れない点）:
- Issue のライフサイクルが明確であること ✓
- 既存の SDLC フローと整合性があること ✓

### Impact（影響）
- **Technical**（技術的）: `install.sh` と `sync-projects.yml` の更新が必要
- **Team**（チーム）: 新しい状態の意味を理解する必要
- **Timeline**（タイムライン）: Option A は実装に時間がかかる
- **Cost**（コスト）: Option A は中程度の工数

### Follow-up Actions（フォローアップアクション）
- [ ] Backlog 状態の導入を決定
- [ ] `install.sh` を更新
- [ ] `sync-projects.yml` を更新
- [ ] ドキュメントを更新

---

## Decision 4: README.md への只読ベストプラクティスの追加

**Status**: CONFIRMED  
**Date**（日付）: 2025-12-27  
**Decision Maker**（意思決定者）: lleizh

### Context（背景）

Issue の実装タスクには、GitHub Projects を只読展示層として使用するベストプラクティスを README.md に追加することが含まれている。これにより、チームメンバーが Projects で手動編集を行わないようにする。

### Options Considered（検討した選択肢）

#### Option A: README.md に只読ベストプラクティスを追加（Issue 提案）
**Pros**（長所）:
- データの一貫性を保証（`.metadata` が唯一の真実の源）
- 誤操作を防止
- 正しいワークフローを強制
- Projects が純粋なダッシュボードとして機能

**Cons**（短所）:
- ドキュメントが長くなる
- チームメンバーが読む必要がある
- 只読権限の設定が必要（オプション）

**Cost/Effort**（コスト・工数）: Low（README.md への追加のみ）

#### Option B: 最小限のドキュメント追加
**Pros**（長所）:
- シンプル
- ドキュメントが短い

**Cons**（短所）:
- 手動編集のリスクが残る
- データの一貫性が保証されない

**Cost/Effort**（コスト・工数）: Very Low

#### Option C: ドキュメント追加なし
**Pros**（長所）:
- 工数ゼロ

**Cons**（短所）:
- チームが Projects の正しい使い方を理解できない
- データの不整合が発生する可能性が高い

**Cost/Effort**（コスト・工数）: None

### Decision（決定）
**Chosen Option**（選択した選択肢）: Option B - 最小限のドキュメント追加

**Rationale**（理由）:
- 必要最小限の情報で Non-Negotiables を満たせる
- ドキュメントをシンプルに保つ（過度な記述を避ける）
- 正しいワークフロー（`.metadata` 編集 → 自動同期）は既に記載されている
- Non-Goals に従い、完全な只読化は推奨だが必須ではない

**Accepted Risks**（受け入れたリスク）:
- 手動編集のリスクが残る（ただし `sync-projects.yml` が自動修正）
- 詳細なベストプラクティスは記載されない（必要に応じて追加可能）

**Non-Negotiables**（譲れない点）:
- Projects の正しい使い方が明確であること ✓
- データの一貫性を保つ方法が文書化されていること ✓

### Impact（影響）
- **Technical**（技術的）: なし
- **Team**（チーム）: ドキュメントを読んで理解する必要
- **Timeline**（タイムライン）: なし
- **Cost**（コスト）: なし

### Follow-up Actions（フォローアップアクション）
- [ ] README.md の構成を決定
- [ ] セクションを追加
- [ ] チームに周知

---

## Decision History（決定履歴）

### Revisions（改訂）

（まだ改訂なし）

---

## Quick Reference（クイックリファレンス）

### All Confirmed Decisions（全確定済み決定）
1. **Workflow トリガーとラベル名**: `sdlc:track` ラベルを使用 - lleizh (2025-12-27)
2. **ラベル削除時の智能的な削除ロジック**: `.metadata` の有無で判断 - lleizh (2025-12-27)
3. **Backlog 状態の導入**: Backlog 状態を追加 - lleizh (2025-12-27)
4. **README.md への只読ベストプラクティスの追加**: 最小限のドキュメント追加 - lleizh (2025-12-27)

### Pending Decisions（保留中の決定）
（すべて確定済み）

---

## Notes（備考）

- すべての Decision は Issue の How セクションに記載された初期案に基づいている
- 技術的選択肢は複数あるため、チームでの議論が必要
- 各 Decision は独立しているが、全体として整合性を保つ必要がある
