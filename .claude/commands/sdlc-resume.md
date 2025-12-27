---
description: Revision または blocked 状態から実装を再開する
---

# Command: /sdlc-resume

Decision Revision 完了後、または blocked 状態解除後に実装を再開します。

## 使用方法

```
/sdlc-resume <feature-id>
```

## 実行内容

### 1. 前提条件チェック

- Feature が存在する
- STATUS が `blocked` または DECISION_STATUS が `revised`
- 中/高リスクの場合：Revision PR が merged されている（該当する場合）

### 2. 現在の状態を確認

`.metadata` を読み取り、以下を確認：
- 現在の STATUS
- PREVIOUS_STATUS（blocked の場合）
- DECISION_STATUS
- REVISION_COUNT

### 3. Implementation Plan 更新の確認

Revision がある場合、ユーザーに確認：

```
⚠️ Decision が修訂されています (Revision #{N})

実装計画を再生成しますか？

[Y] はい - 影響が大きい場合、30_implementation_plan.md を再生成
[N] いいえ - 影響が小さい場合、既存の計画で続行

Revision の内容:
{REVISION_{N}_REASON}

選択 [Y/N]:
```

### 4. Implementation Plan の更新（Y を選択した場合）

```bash
/sdlc-impl-plan {FEATURE_ID}
```

自動的に実施計画を再生成し、修訂後の Decision に基づいて更新。

### 5. ブランチ確認と最新取得

```bash
# feature ブランチに切り替え
git checkout feature/{FEATURE_ID}

# develop から最新の文書を取得（rebase）
git pull origin develop --rebase

# rebase コンフリクトがある場合
if [ $? -ne 0 ]; then
  echo "⚠️ Rebase conflicts detected. Please resolve and run:"
  echo "   git rebase --continue"
  echo "   Then re-run /sdlc-resume {FEATURE_ID}"
  exit 1
fi
```

### 6. メタデータ更新

`.metadata` を更新：

```bash
# PREVIOUS_STATUS から STATUS を復元（なければ implementing に設定）
if grep -q "^PREVIOUS_STATUS=" sdlc/features/${FEATURE_ID}/.metadata; then
  previous_status=$(grep "^PREVIOUS_STATUS=" sdlc/features/${FEATURE_ID}/.metadata | cut -d= -f2)
  sed -i '' "s/^STATUS=.*/STATUS=${previous_status}/" sdlc/features/${FEATURE_ID}/.metadata
else
  sed -i '' 's/^STATUS=.*/STATUS=implementing/' sdlc/features/${FEATURE_ID}/.metadata
fi

# blocked 関連フィールドを削除
sed -i '' '/^BLOCKED_REASON=/d' sdlc/features/${FEATURE_ID}/.metadata
sed -i '' '/^BLOCKED_DATE=/d' sdlc/features/${FEATURE_ID}/.metadata
sed -i '' '/^BLOCKED_BY=/d' sdlc/features/${FEATURE_ID}/.metadata
sed -i '' '/^PREVIOUS_STATUS=/d' sdlc/features/${FEATURE_ID}/.metadata

# 再開情報を記録
current_date=$(date +%Y-%m-%d)
echo "RESUMED_DATE=${current_date}" >> sdlc/features/${FEATURE_ID}/.metadata

# LAST_UPDATED を更新
if grep -q "^LAST_UPDATED=" sdlc/features/${FEATURE_ID}/.metadata; then
  sed -i '' "s/^LAST_UPDATED=.*/LAST_UPDATED=${current_date}/" sdlc/features/${FEATURE_ID}/.metadata
else
  echo "LAST_UPDATED=${current_date}" >> sdlc/features/${FEATURE_ID}/.metadata
fi
```

### 7. Commit と Push

```bash
# .metadata の変更を commit
git add sdlc/features/${FEATURE_ID}/.metadata
git commit -m "chore(${FEATURE_ID}): resume from blocked status

Related: #<issue-number>"

git push origin feature/${FEATURE_ID}
```

### 8. 完了メッセージ

```
✅ 実装を再開しました

📋 現在の状態:
- Feature ID: {FEATURE_ID}
- Branch: feature/{FEATURE_ID}
- STATUS: {復元された STATUS} (was: blocked)
- DECISION_STATUS: {current status}
- Implementation Plan: {更新済み/既存を使用}

📝 Revision 情報 (該当する場合):
- Revision Count: {N}
- Last Revision: {REVISION_{N}_REASON}
- Revision Date: {REVISION_{N}_DATE}

📌 次のステップ:
1. 修訂後の Decision を確認:
   - sdlc/features/{FEATURE_ID}/decisions.md

2. 必要に応じて既存コードを修正

3. 実装完了後:
   /sdlc-test {FEATURE_ID}
   /sdlc-check {FEATURE_ID}
   /sdlc-pr-code {FEATURE_ID}
```

---

## 使用シーン

### シーン 1: Decision Revision 後

```bash
# Revision PR が merged 済み
/sdlc-resume FEATURE-24

# 実装計画の再生成を確認
[Y] はい

# 自動実行:
# - /sdlc-impl-plan FEATURE-24
# - STATUS=implementing (復元)
# - git checkout feature/FEATURE-24
# - git pull origin develop

✅ 実装を再開しました
```

### シーン 2: 外部依赖阻塞解除後

```bash
# 手動で blocked を設定していた
# STATUS=blocked
# BLOCKED_REASON="Waiting for external API v2"

# API v2 がリリースされた
/sdlc-resume FEATURE-24

# 自動実行:
# - STATUS=implementing (復元)
# - BLOCKED_REASON="" (クリア)

✅ 実装を再開しました
```

### シーン 3: 資源阻塞解除後

```bash
# STATUS=blocked
# BLOCKED_REASON="Team member on leave"

# メンバーが復帰
/sdlc-resume FEATURE-24

✅ 実装を再開しました
```

---

## エラー処理

- Feature 不存在 → `❌ Feature が見つかりません`
- STATUS が blocked でも revised でもない → `⚠️ 再開する必要はありません (現在: {STATUS})`
- Revision PR 未マージ (中/高リスク) → `❌ Revision PR をマージしてください`
- ブランチが存在しない → `❌ feature/{FEATURE_ID} ブランチが見つかりません`
- git pull でコンフリクト → `⚠️ マージコンフリクトを解決してください`

---

## 制約

- 自動でコードを修正しない
- ユーザーが手動で修訂後の Decision に基づいてコードを調整する必要がある
- Revision が複数回ある場合、最新の Revision のみを表示

---

## 関連コマンド

- `/sdlc-revise` - Decision を修訂し blocked 状態にする
- `/sdlc-impl-plan` - 実装計画を生成/更新
- `/sdlc-check` - 実装と Decision の一致性を確認
