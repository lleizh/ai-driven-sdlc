# Decisions

**Feature ID**: FEATURE-1  
**Last Updated**: 2025-12-26

**Status**: CONFIRMED

---

## Decision 1: README.md のコマンド一覧に追加するコマンドの記載方法

**Status**: CONFIRMED  
**Date**: 2025-12-26  
**Decision Maker**: AI (Claude Code)

### Context

README.md のコマンド一覧表に `/sdlc-issue` と `/sdlc-coding` を追加する必要がある。
これらのコマンドをどのように表に配置するか、説明文をどう書くかを決定する必要がある。

### Options Considered

#### Option A: 既存の順序に従って適切な位置に挿入
**Pros**:
- ワークフローの論理的な順序を維持
- ユーザーが理解しやすい

**Cons**:
- 表の中間に挿入するため、Git diff が少し複雑になる

**Cost/Effort**: 低

#### Option B: 表の最後に追加
**Pros**:
- 変更が最小限
- Git diff がシンプル

**Cons**:
- ワークフローの順序が崩れる
- ユーザーが混乱する可能性

**Cost/Effort**: 低

#### Option C: コマンドを機能別にグループ化して表を再構成
**Pros**:
- より構造化された表
- 長期的にメンテナンスしやすい

**Cons**:
- 大幅な変更が必要
- Non-Goals に反する（大幅な構造変更は避ける）

**Cost/Effort**: 中

### Decision
**Chosen Option**: Option A - 既存の順序に従って適切な位置に挿入

**Rationale**:
ワークフローの論理的な順序を維持することがユーザーにとって最も重要。
- `/sdlc-issue` は Issue 作成時（ワークフローの最初）に使用される
- `/sdlc-coding` は Decision 確定後、実装開始時に使用される
- それぞれ適切な位置に挿入することで、ユーザーがワークフローを直感的に理解できる
- Git diff の複雑さは一時的なもので、長期的なユーザー体験の方が重要

**Rejected Options**:
- **Option B**: ワークフローの順序が崩れ、ユーザーが混乱するリスクが高い
- **Option C**: Non-Goals に反する大幅な構造変更であり、必要以上の変更

**Accepted Risks**:
- Git diff が少し複雑になるが、レビュー時に問題になるレベルではない

**Non-Negotiables**:
- `/sdlc-issue` と `/sdlc-coding` は必ず追加する
- 既存のコマンドの説明は変更しない

### Impact
- **Technical**: なし
- **Team**: ドキュメント レビューが必要
- **Timeline**: 影響なし
- **Cost**: なし

### Follow-up Actions
- [x] `/sdlc-issue` を表の最初（Issue 作成後）に挿入
- [x] `/sdlc-coding` を `/sdlc-impl-plan` と `/sdlc-revise` の間に挿入
- [x] コマンドの説明文を作成

---

## Decision 2: install.sh からのオプション削除の影響範囲

**Status**: CONFIRMED  
**Date**: 2025-12-26  
**Decision Maker**: AI (Claude Code)

### Context

`--minimal` と `--no-templates` オプションを削除する。
これらのオプションが実際に使用されているかどうかを確認し、削除の影響を評価する必要がある。

### Options Considered

#### Option A: オプションとロジックを完全に削除
**Pros**:
- コードがシンプルになる
- メンテナンス負担が減る
- Issue の要件に完全に合致

**Cons**:
- もし誰かが使用していた場合、エラーになる

**Cost/Effort**: 低

#### Option B: オプションを受け付けるが警告を表示し、無視する
**Pros**:
- 既存ユーザーへの影響を最小化
- 段階的な廃止が可能

**Cons**:
- コードが複雑になる
- Issue の要件（削除）に完全には合致しない

**Cost/Effort**: 低

#### Option C: 使用状況を調査してから判断
**Pros**:
- データに基づいた意思決定
- リスクを最小化

**Cons**:
- 調査に時間がかかる
- プライベートリポジトリのため使用状況が取得困難

**Cost/Effort**: 高

### Decision
**Chosen Option**: Option A - オプションとロジックを完全に削除

**Rationale**:
- README.md にこれらのオプションが記載されていたため、実際の使用者はほぼいないと判断できる
- プロジェクト自体が新しく、ユーザー数が限定的
- コードをシンプルに保つことが長期的なメンテナンス性を向上させる
- Issue の要件（削除）に完全に合致する
- risks.md の R001 でリスクが既に評価されており、影響は Very Low と判定済み

**Rejected Options**:
- **Option B**: コードが複雑になり、Issue の要件に完全には合致しない
- **Option C**: コストが高く、プライベートリポジトリのため実施困難

**Accepted Risks**:
- もし使用者がいた場合、エラーになる（risks.md R001）
- ただし、Likelihood は Low (<10%)、Severity は Minor、Residual Risk は Very Low と評価済み

**Non-Negotiables**:
- 最終的には削除する（時期ではなく方法の問題）
- README.md には記載しない

### Impact
- **Technical**: install.sh の行数削減（約30-40行）、コードの簡潔化
- **Team**: なし
- **Timeline**: なし
- **Cost**: なし

### Follow-up Actions
- [x] `--minimal` オプションとその関連ロジックを削除
- [x] `--no-templates` オプションとその関連ロジックを削除
- [x] `MINIMAL` と `NO_TEMPLATES` 変数を削除
- [x] ヘルプメッセージから削除
- [x] 条件分岐ロジックを簡略化

---

## Quick Reference

### All Confirmed Decisions
1. **コマンド一覧の記載方法**: Option A（既存の順序に従って挿入） - 2025-12-26
2. **オプション削除の影響範囲**: Option A（完全削除） - 2025-12-26

### Pending Decisions
（すべての決定が確定しました）

---

## Notes

この Feature は Low Risk のため、決定は軽量でも問題ない。
両方の Decision を CONFIRMED とし、実装に進む。
