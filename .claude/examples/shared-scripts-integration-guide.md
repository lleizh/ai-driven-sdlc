# 共有スクリプト統合ガイド

このガイドでは、SDLCコマンドに共有スクリプトを統合する方法を説明します。

## 概要

Phase 1 で作成した共有スクリプトを使用することで、SDLCコマンドのコードを大幅に簡素化できます。

**利用可能な共有スクリプト**:
- `scripts/common-functions.sh` - 共通ユーティリティ関数
- `scripts/update-metadata.sh` - Metadata更新
- `scripts/check-branch.sh` - ブランチ検証
- `scripts/rebase-with-develop.sh` - Rebase処理

---

## 統合パターン

### パターン 1: 共通関数の直接使用

```bash
#!/usr/bin/env bash
set -euo pipefail

# 共通関数を読み込み
source scripts/common-functions.sh

# Feature 存在確認
if ! check_feature_exists "$FEATURE_ID"; then
    exit 1
fi

# Metadata値の取得
STATUS=$(get_metadata_value "$FEATURE_ID" "STATUS")

# ログ出力
log_info "Processing feature ${FEATURE_ID}"
log_success "Operation completed"
```

### パターン 2: スクリプトの呼び出し

```bash
#!/usr/bin/env bash
set -euo pipefail

# ブランチ確認
if ! scripts/check-branch.sh "$FEATURE_ID"; then
    exit 1
fi

# Metadata更新
scripts/update-metadata.sh "$FEATURE_ID" "STATUS" "implementing"
scripts/update-metadata.sh "$FEATURE_ID" "LAST_UPDATED" "$(date +%Y-%m-%d)"
```

---

## 実装例

### 例 1: sdlc-impl-plan コマンド

完全な統合例は `.claude/examples/sdlc-impl-plan-integrated.sh` を参照してください。

**主な改善点**:
- `check_feature_exists()` で Feature 存在確認
- `get_metadata_value()` で Decision Status 取得
- `check-branch.sh` でブランチ検証
- `update-metadata.sh` で Metadata 更新
- `log_*` 関数で統一されたログ出力

**削減されるコード**: 約 50行

---

### 例 2: 簡単なコマンド

```bash
#!/usr/bin/env bash
set -euo pipefail

FEATURE_ID="$1"

# 共通関数を読み込み
source scripts/common-functions.sh

# === 統合前（20行） ===
# if [[ ! -d "sdlc/features/${FEATURE_ID}" ]]; then
#     echo "❌ Error: Feature not found"
#     exit 1
# fi
# 
# if [[ ! -f "sdlc/features/${FEATURE_ID}/.metadata" ]]; then
#     echo "❌ Error: Metadata not found"
#     exit 1
# fi
# 
# current_branch=$(git branch --show-current)
# if [[ "$current_branch" != "feature/${FEATURE_ID}" ]]; then
#     echo "❌ Error: Wrong branch"
#     exit 1
# fi

# === 統合後（3行） ===
check_feature_exists "$FEATURE_ID" || exit 1
scripts/check-branch.sh "$FEATURE_ID" || exit 1
log_success "All checks passed"
```

**削減されるコード**: 約 17行（85%削減）

---

## 利用可能な関数

### common-functions.sh

#### ログ出力
- `log_info "message"` - 情報ログ（青色）
- `log_error "message"` - エラーログ（赤色、stderr）
- `log_success "message"` - 成功ログ（緑色）
- `log_warning "message"` - 警告ログ（黄色）

#### バリデーション
- `validate_feature_id "$feature_id"` - Feature ID形式検証
- `check_feature_exists "$feature_id"` - Feature存在確認
- `check_gh_auth` - GitHub CLI認証確認
- `check_git_config` - Git設定確認

#### ユーティリティ
- `get_os_type` - OS判定（macos/linux/unknown）
- `get_current_branch` - 現在のブランチ名取得
- `get_metadata_value "$feature_id" "$key"` - Metadata値取得
- `display_error "$summary" "$context" "$action"` - 標準化エラー表示

---

## 統合のベストプラクティス

### 1. エラーハンドリング

**推奨**:
```bash
# 共通関数のエラーをそのまま伝播
if ! check_feature_exists "$FEATURE_ID"; then
    exit 1  # 関数が既にエラーメッセージを表示済み
fi
```

**非推奨**:
```bash
# エラーメッセージを重複させない
if ! check_feature_exists "$FEATURE_ID"; then
    echo "❌ Feature check failed"  # 重複メッセージ
    exit 1
fi
```

### 2. パスの扱い

**推奨**:
```bash
# プロジェクトルートに移動してから実行
cd "$PROJECT_ROOT"
scripts/update-metadata.sh "$FEATURE_ID" "STATUS" "implementing"
```

**非推奨**:
```bash
# 相対パスを直接使用しない
../../scripts/update-metadata.sh "$FEATURE_ID" "STATUS" "implementing"
```

### 3. ログ出力の統一

**推奨**:
```bash
log_info "Starting process"
# 処理
log_success "Process completed"
```

**非推奨**:
```bash
echo "Starting process"  # 色なし、形式不統一
# 処理
echo "✅ Process completed"  # 形式は良いが関数を使うべき
```

---

## 統合の段階的アプローチ

### Phase 1: 試験的統合（現在）
1. ✅ 1-2個のコマンドで試験（例: sdlc-impl-plan）
2. 動作確認と改善

### Phase 2: 主要コマンドへの展開
1. `/sdlc-init`
2. `/sdlc-decision`
3. `/sdlc-coding`

### Phase 3: 全コマンドへの展開
1. 残り8個のコマンド
2. 完全な統一化

---

## テスト方法

### 統合後の動作確認

```bash
# 統合例を実行
.claude/examples/sdlc-impl-plan-integrated.sh FEATURE-29

# 期待される出力:
# ℹ️  Starting implementation plan generation
# ✅ Feature exists
# ✅ Decision status: confirmed
# ✅ Correct branch
# ✅ Implementation Plan 処理完了
```

### 単体テスト

```bash
# 共有スクリプトの単体テストを実行
bats tests/unit/*.bats

# 現在の通過率: 69% (27/39)
# 目標: 100%
```

---

## トラブルシューティング

### 問題: 共通関数が見つからない

**エラー**:
```
bash: scripts/common-functions.sh: No such file or directory
```

**解決**:
```bash
# プロジェクトルートに移動
cd "$(git rev-parse --show-toplevel)"
source scripts/common-functions.sh
```

### 問題: Permission denied

**エラー**:
```
Permission denied: scripts/update-metadata.sh
```

**解決**:
```bash
chmod +x scripts/*.sh
```

### 問題: Feature not found（テスト環境）

**原因**: テストの一時ディレクトリから実行している

**解決**: プロジェクトルートから実行するか、絶対パスを使用

---

## 参考リソース

- [共有スクリプトドキュメント](../../scripts/README.md)
- [テストガイド](../../tests/README.md)
- [Implementation Plan](../../sdlc/features/FEATURE-29/30_implementation_plan.md)
- [Design Document](../../sdlc/features/FEATURE-29/20_design.md)

---

## 変更履歴

- **2025-12-29**: 初版作成（Phase 1統合ガイド）
