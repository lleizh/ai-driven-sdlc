# Decisions

**Feature ID**: FEATURE-15  
**Last Updated**: 2025-12-26

---

## Decision 1: develop ブランチの作成方法

**Status**: PENDING  
**Date**: 2025-12-26  
**Decision Maker**: TBD

### Context

`develop` ブランチが存在しないため、新規作成する必要がある。Issue では master から分岐する案が提示されているが、他の選択肢も検討すべき。

### Options Considered

#### Option A: master から develop を作成（Issue 提案）
**Pros**:
- シンプルで明確
- master の安定したコードベースから開始
- 最新の本番コードと同期した状態でスタート

**Cons**:
- 現在 master にない変更がある場合、手動で同期が必要
- 既存の feature ブランチとの統合に追加作業が必要

**Cost/Effort**: 低（コマンド数行で完了）

#### Option B: 現在の HEAD から develop を作成
**Pros**:
- 現在の作業状態をそのまま継承
- 追加の同期作業が不要

**Cons**:
- どのコミットを基準にするか不明確
- 不安定な状態から開始する可能性

**Cost/Effort**: 低（コマンド数行で完了）

#### Option C: 最新の PR ブランチから develop を作成
**Pros**:
- 最新の開発状況を反映
- 既存の PR との整合性が高い

**Cons**:
- どの PR を基準にするか判断が必要
- レビュー前のコードを含む可能性

**Cost/Effort**: 中（基準とする PR の選定が必要）

### Decision
**Chosen Option**: PENDING

**Rationale**:
チームでの議論が必要。master から作成するのが一般的だが、既存の開発状況を考慮して決定すべき。

**Accepted Risks**:
- TBD

**Non-Negotiables**:
- develop ブランチは今後すべての feature/design ブランチの基準となる
- 一度作成したら簡単に作り直せない

### Impact
- **Technical**: すべての新規ブランチの分岐元となる
- **Team**: 全開発者が develop ベースでブランチを作成する必要がある
- **Timeline**: develop 作成後、すぐに運用開始可能
- **Cost**: 低

### Follow-up Actions
- [ ] チームで Option を議論
- [ ] 決定後、develop ブランチを作成
- [ ] 開発者に周知

---

## Decision 2: 既存 PR の base 変更方法

**Status**: PENDING  
**Date**: 2025-12-26  
**Decision Maker**: TBD

### Context

Issue では既存の PR（例: #14）の base を develop に変更すると提案されているが、タイミングと方法を決定する必要がある。

### Options Considered

#### Option A: develop 作成後、すぐに既存 PR の base を変更（Issue 提案）
**Pros**:
- 一気に新しいブランチ戦略に移行
- 中途半端な状態を避けられる

**Cons**:
- レビュー中の PR に影響を与える可能性
- 急激な変更でチームが混乱する可能性

**Cost/Effort**: 低（gh pr edit コマンドで実行）

#### Option B: 新規 PR のみ develop base にし、既存 PR は master のまま
**Pros**:
- 既存のレビュープロセスを中断しない
- 段階的な移行が可能

**Cons**:
- 一時的に 2 つの戦略が並存
- 既存 PR が master にマージされた後、develop への反映が必要

**Cost/Effort**: 低（手動で PR 作成時に base を選択）

#### Option C: 既存 PR をマージ完了後、develop を作成
**Pros**:
- 既存の作業を中断しない
- クリーンな状態で新戦略をスタート

**Cons**:
- develop 作成が遅れる
- その間の新規 PR の扱いが不明確

**Cost/Effort**: 中（既存 PR の完了を待つ必要）

### Decision
**Chosen Option**: PENDING

**Rationale**:
既存 PR の状態とレビューの進捗状況を確認してから決定すべき。

**Accepted Risks**:
- TBD

**Non-Negotiables**:
- レビュー中の PR の作業を無駄にしない
- 開発者に明確な方針を示す

### Impact
- **Technical**: PR の統合プロセスに影響
- **Team**: レビュワーと PR 作成者に影響
- **Timeline**: Option によって develop 運用開始時期が変わる
- **Cost**: 低〜中

### Follow-up Actions
- [ ] 既存 PR (#14など) の状態を確認
- [ ] チームで Option を議論
- [ ] 決定後、PR の base 変更またはマージを実行

---

## Decision 3: Workflow トリガーの実装方法

**Status**: PENDING  
**Date**: 2025-12-26  
**Decision Maker**: TBD

### Context

Issue では branches に master, develop, 'feature/**', 'design/**' を追加すると提案されているが、これが最適な実装かを検討する必要がある。

### Options Considered

#### Option A: branches に全パターンを追加（Issue 提案）
**Pros**:
- シンプルで理解しやすい
- すべてのブランチで同じトリガー条件

**Cons**:
- 不要なブランチ（例: hotfix, experimental）でもトリガーされる可能性
- Workflow の実行回数が増加

**Cost/Effort**: 低（YAML の branches セクションを編集）

#### Option B: branches-ignore で不要なブランチを除外
**Pros**:
- 明示的に除外するブランチを指定できる
- 柔軟性が高い

**Cons**:
- branches と branches-ignore の併用はできない
- 除外リストの管理が必要

**Cost/Effort**: 中（除外するブランチのリストアップが必要）

#### Option C: paths と branches の組み合わせでより厳密に制御
**Pros**:
- `.metadata` ファイルの変更のみに限定できる
- 無駄な実行を最小化

**Cons**:
- 設定が複雑になる
- Issue では paths は既に指定されている（"sdlc/features/**/.metadata"）

**Cost/Effort**: 低（既に paths 指定あり、branches 追加のみ）

### Decision
**Chosen Option**: PENDING

**Rationale**:
Option A がシンプルで Issue の提案通りだが、実行回数の増加が許容範囲かを確認すべき。

**Accepted Risks**:
- TBD

**Non-Negotiables**:
- `.metadata` 変更時に必ず GitHub Projects が更新される
- master ブランチの既存動作を変更しない

### Impact
- **Technical**: GitHub Actions の実行回数に影響
- **Team**: 開発者のブランチ命名規則に影響する可能性
- **Timeline**: 実装は即座に可能
- **Cost**: GitHub Actions の実行時間（無料枠内で対応可能と想定）

### Follow-up Actions
- [ ] 既存 Workflow の実行頻度を確認
- [ ] GitHub Actions の無料枠を確認
- [ ] Option を決定して実装

---

## Quick Reference

### All Confirmed Decisions
（まだ確定した Decision はありません）

### Pending Decisions
1. **develop ブランチの作成方法**: Awaiting チーム議論 - TBD
2. **既存 PR の base 変更方法**: Awaiting 既存 PR 状態確認 - TBD
3. **Workflow トリガーの実装方法**: Awaiting 実行回数の確認 - TBD

---

## Notes

- すべての Decision は PENDING 状態です
- Issue では具体的な実装方法（How）が提案されていますが、他の選択肢も検討する価値があります
- チームでの議論と承認が必要です
