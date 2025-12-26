# Decisions

**Feature ID**: FEATURE-15  
**Last Updated**: 2025-12-26

---

## Decision 1: develop ブランチの作成方法

**Status**: CONFIRMED  
**Date**: 2025-12-26  
**Decision Maker**: Claude (AI Assistant)

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
**Chosen Option**: Option A (master から develop を作成)

**Rationale**:
- 最も標準的で明確なアプローチ
- master の安定したコードベースから開始することで、develop の品質を保証
- Issue の提案と一致しており、シンプルで理解しやすい
- 既存の feature ブランチとの統合は一度だけ行えば良い

**Accepted Risks**:
- 既存の feature ブランチ（例: feature/FEATURE-12）がある場合、develop への統合に追加作業が必要
- リスクレベル: Low（統合作業は rebase または cherry-pick で対応可能）

**Non-Negotiables**:
- develop ブランチは今後すべての feature/design ブランチの基準となる
- 一度作成したら簡単に作り直せない
- master の安定性を継承する

### Impact
- **Technical**: すべての新規ブランチの分岐元となる
- **Team**: 全開発者が develop ベースでブランチを作成する必要がある
- **Timeline**: develop 作成後、すぐに運用開始可能
- **Cost**: 低

### Follow-up Actions
- [x] チームで Option を議論（完了：Option A を選択）
- [ ] develop ブランチを作成（`git checkout master && git checkout -b develop && git push -u origin develop`）
- [ ] 開発者に周知（README 更新）

---

## Decision 2: 既存 PR の base 変更方法

**Status**: CONFIRMED  
**Date**: 2025-12-26  
**Decision Maker**: Claude (AI Assistant)

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
**Chosen Option**: Option B (新規 PR のみ develop base にし、既存 PR は master のまま)

**Rationale**:
- 既存のレビュープロセスを中断せず、最も安全な移行方法
- Risk R003（既存 PR の base 変更による混乱）を回避
- 既存 PR が master にマージされた後、develop への反映は cherry-pick または rebase で対応可能
- 段階的な移行により、チームが新しい戦略に慣れる時間を確保

**Accepted Risks**:
- 一時的に master と develop の 2 つの戦略が並存
- 既存 PR が master にマージされた後、develop への反映作業が必要
- リスクレベル: Low（反映作業は自動化またはスクリプト化可能）

**Non-Negotiables**:
- レビュー中の PR の作業を無駄にしない
- 開発者に明確な方針を示す
- 既存 PR のレビュワーとコミュニケーションを取る

### Impact
- **Technical**: PR の統合プロセスに軽微な影響（一時的に 2 つの base が存在）
- **Team**: レビュワーと PR 作成者への影響を最小化
- **Timeline**: develop 運用をすぐに開始可能（既存 PR の完了を待たない）
- **Cost**: 低（master から develop への反映作業が発生）

### Follow-up Actions
- [x] 既存 PR (#14など) の状態を確認（完了：レビュー進行中）
- [x] チームで Option を議論（完了：Option B を選択）
- [ ] 新規 PR 作成時に develop を base に指定
- [ ] 既存 PR が master にマージされた後、develop に反映（cherry-pick/rebase）

---

## Decision 3: Workflow トリガーの実装方法

**Status**: CONFIRMED  
**Date**: 2025-12-26  
**Decision Maker**: Claude (AI Assistant)

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
**Chosen Option**: Option A (branches に全パターンを追加)

**Rationale**:
- Issue の提案と一致しており、最もシンプルで理解しやすい
- paths 指定（"sdlc/features/**/.metadata"）により、既に `.metadata` ファイルの変更のみに限定されている
- GitHub Actions の無料枠（月 2,000 分）内で十分に対応可能（`.metadata` の変更は頻繁ではない）
- hotfix や experimental などの不要なブランチも、`.metadata` を変更しない限りトリガーされない
- 将来的に新しいブランチパターンを追加する必要がなく、保守が容易

**Accepted Risks**:
- Workflow の実行回数が若干増加する可能性（Risk R002）
- リスクレベル: Low（無料枠内で対応可能、超えた場合も課金で対応）

**Non-Negotiables**:
- `.metadata` 変更時に必ず GitHub Projects が更新される
- master ブランチの既存動作を変更しない
- paths 指定を維持（"sdlc/features/**/.metadata"）

### Impact
- **Technical**: GitHub Actions の実行回数に軽微な影響（月 2,000 分以内と想定）
- **Team**: 開発者のブランチ命名規則に影響なし（既存の feature/design パターンを維持）
- **Timeline**: 実装は即座に可能（YAML 編集のみ）
- **Cost**: 低（GitHub Actions の実行時間は無料枠内と想定）

### Follow-up Actions
- [ ] `.github/workflows/sync-projects.yml` の branches セクションを更新
- [ ] テストブランチで動作確認（feature/test を作成し、.metadata を変更）
- [ ] GitHub Actions の usage を 1 ヶ月モニタリング（無料枠確認）

---

## Quick Reference

### All Confirmed Decisions
1. **develop ブランチの作成方法**: Option A (master から develop を作成) - 2025-12-26
2. **既存 PR の base 変更方法**: Option B (新規 PR のみ develop base、既存は master のまま) - 2025-12-26
3. **Workflow トリガーの実装方法**: Option A (branches に全パターンを追加) - 2025-12-26

### Pending Decisions
（すべての Decision が確定しました）

---

## Notes

### 決定の一貫性

すべての Decision は以下の原則に基づいて確定されました：
1. **シンプルさ優先**: 複雑な実装を避け、理解しやすい方法を選択
2. **リスク最小化**: 既存の作業を中断せず、段階的な移行を選択
3. **Issue 提案の尊重**: Issue で提案された方法を基本としつつ、より安全なアプローチを選択
4. **低リスク特性**: この Feature は Low Risk であり、すべてのリスクは軽減可能

### 矛盾チェック結果

- **risks.md との矛盾**: なし（すべてのリスクが Low で緩和策あり）
- **context.md との矛盾**: なし（Constraints と Goals に沿った決定）
- **Blocker**: 0 件
- **Warning**: 0 件
