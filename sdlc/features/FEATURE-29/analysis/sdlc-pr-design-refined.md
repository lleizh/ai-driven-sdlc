# /sdlc-pr-design - 流程整理

## 文档依据

- **AI_SDLC.md**: 中/高リスクのみ設計 Review、"10分で理解"ルール
- **SDLC_FLOW.md**: Step 4 - Design Review PR を作成
- **STATUS_MANAGEMENT.md**: STATUS = design

---

## 命令目的

設計レビュー PR を作成し、チームで設計方向性を議論する。

**重要**: このコマンドは**中/高リスク**のみ実行する（低リスクはスキップ）

---

## 前提条件

**必須**:
- ✅ Feature が存在（`/sdlc-init` で作成済み）
- ✅ Risk Level = Medium または High
- ✅ SDLC 文書が生成済み（context, decisions, risks）

**非必須**:
- ブランチは存在しても未存在でも OK（このコマンドで作成・切替）

---

## 実行フロー

### 1. 前提確認

```bash
source scripts/common-functions.sh

# Feature 存在確認
check_feature_exists "$FEATURE_ID" || exit 1

# ブランチ確認
scripts/check-branch.sh "$FEATURE_ID" || exit 1
```

**目的**: 
- Feature ディレクトリが存在するか確認
- 現在のブランチが `feature/{FEATURE_ID}` か確認

**エラー時の対応**:
- Feature 不存在 → `/sdlc-init` を先に実行
- ブランチ不一致 → 正しいブランチに切り替え

**補足**: 通常は `/sdlc-init` で Feature とブランチが同時作成済み

---

### 2. Rebase with develop

```bash
scripts/rebase-with-develop.sh "$FEATURE_ID" || exit 1
```

**目的**: 
- develop ブランチから最新の変更を取得
- コンフリクトを事前に解決

**重要**: Design Review PR 作成前に必ず rebase

---

### 3. Metadata 更新

```bash
scripts/update-metadata.sh "$FEATURE_ID" "STATUS" "design"
scripts/update-metadata.sh "$FEATURE_ID" "LAST_UPDATED" "$(date +%Y-%m-%d)"
```

**変更内容**:
- `STATUS`: `planning` → `design`
- `LAST_UPDATED`: 現在の日付

**目的**: STATUS を更新して Design Review 段階に入ったことを記録

---

### 4. Commit と Push

```bash
ISSUE_NUMBER=$(get_metadata_value "$FEATURE_ID" "ISSUE_URL" | grep -oE '[0-9]+$')

git add "sdlc/features/${FEATURE_ID}/.metadata"
git commit -m "chore(${FEATURE_ID}): update STATUS to design

Related: #${ISSUE_NUMBER}"

# 新しいブランチの場合は -u、既存の場合は通常 push
git push origin "feature/${FEATURE_ID}" || \
git push -u origin "feature/${FEATURE_ID}"
```

**目的**: Metadata の変更を commit & push

**Commit メッセージ形式**:
- タイトル: `chore({FEATURE_ID}): update STATUS to design`
- Footer: `Related: #{ISSUE_NUMBER}`

---

### 5. Feature ドキュメント読取

Read ツールで以下のファイルを読み取る：

**必須**:
- `.metadata`
- `00_context.md`
- `decisions.md`
- `risks.md`

**オプション**（存在する場合）:
- `10_requirements.md`
- `20_design.md`

**目的**: PR Description を生成するためのデータ収集

---

### 6. PR Description 生成

**構成**（AI_SDLC.md の "10分で理解"ルール準拠）:

#### 📖 レビュアーへ：必読ファイル

**目的**: レビュアーが最小限の時間で理解できるようにする

```markdown
✅ 必読（これだけ読めばOK）:
  - Issue（GitHub）
  - decisions.md（PENDING 状態）
  - risks.md
  - 20_design.md（DRAFT 状態、存在する場合）

📎 参考（optional）:
  - 00_context.md
  - 10_requirements.md
```

**重要**: Issue → decisions.md → risks.md の順で読めば 10 分で理解できる

---

#### 🎯 目標（3行以内）

`00_context.md` の Goals から抽出

**目的**: 何を実現したいかを簡潔に伝える

---

#### 📋 背景

- Background と Problem Statement
- Issue URL
- Risk Level

**目的**: なぜこの機能が必要かを説明

---

#### 🔑 主要な決定事項（最大3つ）

`decisions.md` から抽出：
- 各 Decision の Options
- Status: **PENDING**
- 確認が必要な内容

**重要**: 
- Status は PENDING のまま（AI_SDLC.md 準拠）
- Design Review で議論して決定する

---

#### 🏗️ 設計方案

`20_design.md` から抽出（存在する場合）:
- 推奨方案
- Trade-offs（利点と制約）

---

#### ⚠️ リスク評価（Top 5）

`risks.md` から Top 5 を抽出：

| Risk ID | リスク | レベル | 緩和策 |
|---------|--------|--------|--------|
| R1 | ... | High | ... |
| R2 | ... | Medium | ... |

**目的**: 高リスクを可視化

---

#### 👀 レビュアーへ：重点確認事項（3つ）

Decisions/Risks から最も議論が必要な問題を抽出

**例**:
1. Decision D1 の Option A vs B の選択
2. Risk R1 の緩和策は十分か？
3. アーキテクチャの方向性は妥当か？

---

#### 📚 関連ドキュメント

- Issue URL
- ファイルパス（sdlc/features/{FEATURE_ID}/...）

---

#### ✅ マージ条件

```markdown
- [ ] Decisions が CONFIRMED
- [ ] チーム合意
```

**重要**: Design Review 完了後、`/sdlc-decision` で Decisions を CONFIRMED にする

---

### 7. PR 作成

```bash
gh pr create \
  --title "Design: ${FEATURE_ID} - {タイトル}" \
  --body "{生成した PR Description}" \
  --label "design-review" \
  --base develop
```

**PR 属性**:
- Title: `Design: {FEATURE_ID} - {タイトル}`
- Label: `design-review`
- Base branch: `develop`

**目的**: Design Review PR を作成してチームレビューを開始

**完了メッセージ**:
```
✅ Design Review PR を作成しました

📋 PR 情報:
- URL: {GitHub PR URL}
- Branch: feature/{FEATURE_ID}
- Label: design-review
- Status: design

次のステップ:
- チームメンバーをレビュアーに追加
- Decisions を議論・確定
- decisions.md の Status を CONFIRMED に更新
- PR をマージ
```

---

## 状態変化

### .metadata
- **STATUS**: `planning` → `design`
- **LAST_UPDATED**: 更新

### Git
- **Commit**: Metadata 更新を commit
- **Push**: リモートに push

### GitHub
- **PR**: Design Review PR 作成
- **Label**: `design-review`

### GitHub Projects
- **次回同期**: `sync-projects.yml` が実行され、STATUS が `Design` に更新

---

## エラー処理

### Feature 不存在
```
❌ エラー: Feature が見つかりません: {FEATURE_ID}

Action: /sdlc-init {Issue URL} を先に実行してください
```

### ブランチ不一致（ユーザーが作成を拒否）
```
⚠️ 警告: ブランチが一致しません

Action: feature/{FEATURE_ID} ブランチに切り替えてください
```

### Rebase 失敗
```
❌ エラー: Rebase に失敗しました

Context: コンフリクトがあります
Action:
1. git rebase --abort
2. 手動でコンフリクトを解決
3. git rebase --continue
4. 再度 /sdlc-pr-design {FEATURE_ID} を実行
```

### PR 作成失敗
```
❌ エラー: PR の作成に失敗しました

Context: {エラー詳細}
Action:
- git push が成功しているか確認
- gh auth status を確認
```

---

## AI_SDLC.md との整合性

✅ **高リスクのみ設計 Review**:
- このコマンドは中/高リスクのみ実行
- 低リスクは `/sdlc-decision` に直接進む

✅ **Review 方針 A: 設計 Review**:
- 目的: 盲点発見（投票ではない）
- 対象: Context / Design方向性 / Risks の3点のみ

✅ **"10分で理解"ルール**:
- PR Description で Issue → decisions.md → risks.md の読み順を明示
- 必読ファイルを最小限に絞る

✅ **Decision Gate**:
- decisions.md は PENDING のまま
- Design Review で議論
- `/sdlc-decision` で CONFIRMED にする

---

## SDLC_FLOW.md との整合性

✅ **Step 4**: /sdlc-pr-design
- Design Review PR を作成
- decisions: PENDING
- Label: design-review

✅ **次のステップ**: Step 5 - Design Review (Peer)
- レビュー対象: Context / Design 方向性 / Risks
- 目的: 盲点発見

---

## STATUS_MANAGEMENT.md との整合性

✅ **STATUS 遷移**:
```
planning → design
   ↓         ↓
/sdlc-   /sdlc-pr-design
init
```

✅ **.metadata 更新**:
- `STATUS=design` ✅
- `LAST_UPDATED` 更新 ✅

✅ **次の STATUS**: 
- Design Review 完了後 → `/sdlc-decision` → STATUS は変わらない
- その後 `/sdlc-coding` → `implementing`

---

## 共有スクリプトの使用

✅ **使用している共有スクリプト**:
- `source scripts/common-functions.sh`
- `check_feature_exists()` - Feature 存在確認
- `get_metadata_value()` - Metadata 値取得
- `scripts/check-branch.sh` - ブランチ検証
- `scripts/rebase-with-develop.sh` - Rebase 処理
- `scripts/update-metadata.sh` - Metadata 更新

**評価**: ✅ 完璧に共有スクリプトを活用している

---

## 流程評価

### ✅ 合理的な点

1. **ブランチ確認 → Rebase → Metadata 更新 → PR 作成**
   - 論理的な順序
   - Rebase を先にすることでコンフリクトを事前解決

2. **共有スクリプトの活用**
   - コードが簡潔
   - エラー処理を共有スクリプトに委譲

3. **PR Description の構造**
   - "10分で理解"ルールに準拠
   - レビュアーフレンドリー

### ⚠️ 確認点

**Q1**: ブランチ確認（Step 2）で、ブランチが存在しない場合にユーザーに確認するのは必要？

**現状**:
```bash
scripts/check-branch.sh "$FEATURE_ID" || {
    echo "ブランチを作成・切り替えますか？ (y/N)"
    read -r response
    ...
}
```

**考察**:
- ✅ 安全性: ユーザーに確認するのは良い
- ⚠️ 通常ケース: `/sdlc-init` でブランチ作成済みなので、このケースは稀

**判断**: 現状のまま OK（安全性優先）

---

**Q2**: Step 4 と Step 5 を統合できる？

**現状**:
```
4. Metadata 更新
5. Commit と Push
```

**統合案**:
```
4. Metadata 更新 + Commit + Push
```

**考察**:
- 統合しても問題なし
- ただし、現状の方が各ステップが明確

**判断**: 現状のまま OK（明確性優先）

---

## まとめ

### このコマンドの役割
1. Design Review PR を作成（中/高リスクのみ）
2. STATUS を `design` に更新
3. チームで設計方向性を議論する場を提供

### 流程評価
- ✅ **ステップ数**: 9 ステップ（適切）
- ✅ **共有スクリプト**: 完璧に活用
- ✅ **論理性**: 明確で合理的
- ✅ **最適化不要**: このままで十分

### 次のステップ
- Design Review（人間）
- `/sdlc-decision` で Decisions を CONFIRMED
- `/sdlc-impl-plan` で実装計画生成（任意）
- `/sdlc-coding` で実装開始
