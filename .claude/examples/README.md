# SDLC コマンド統合例

このディレクトリには、共有スクリプトを既存のSDLCコマンドに統合する方法の例が含まれています。

## ファイル一覧

### 1. shared-scripts-integration-guide.md
共有スクリプト統合の完全ガイド。

**内容**:
- 統合パターン
- 実装例
- ベストプラクティス
- トラブルシューティング

### 2. sdlc-impl-plan-integrated.sh
`/sdlc-impl-plan` コマンドの統合例（実行可能）。

**使用方法**:
```bash
.claude/examples/sdlc-impl-plan-integrated.sh <FEATURE_ID>
```

**統合された機能**:
- ✅ `check_feature_exists()` - Feature存在確認
- ✅ `get_metadata_value()` - Metadata値取得
- ✅ `check-branch.sh` - ブランチ検証
- ✅ `update-metadata.sh` - Metadata更新
- ✅ `log_*()` - 統一ログ出力

**削減効果**: 約50行のコード削減

---

## 使用方法

### 統合例の実行

```bash
# プロジェクトルートから実行
cd /path/to/ai-driven-sdlc

# 統合例を実行
.claude/examples/sdlc-impl-plan-integrated.sh FEATURE-29

# 期待される出力
✅ Feature exists: FEATURE-29
✅ Decision status: confirmed
✅ Correct branch: feature/FEATURE-29
✅ Implementation Plan 処理完了
```

### 他のコマンドへの適用

1. `shared-scripts-integration-guide.md` を参照
2. 統合パターンを選択
3. 既存のコマンドに適用
4. 動作確認

---

## 統合の効果

### Before（統合前）
```bash
# Feature存在確認（10行）
if [[ ! -d "sdlc/features/${FEATURE_ID}" ]]; then
    echo "❌ Error: Feature not found"
    echo "   Context: Directory not found"
    echo "   Action: Run /sdlc-init first"
    exit 1
fi

if [[ ! -f "sdlc/features/${FEATURE_ID}/.metadata" ]]; then
    echo "❌ Error: Metadata not found"
    exit 1
fi

# Metadata値取得（5行）
STATUS=$(grep "^STATUS=" sdlc/features/${FEATURE_ID}/.metadata | cut -d'=' -f2)
if [[ -z "$STATUS" ]]; then
    echo "❌ Error: STATUS not found"
    exit 1
fi
```

### After（統合後）
```bash
# Feature存在確認（1行）
check_feature_exists "$FEATURE_ID" || exit 1

# Metadata値取得（1行）
STATUS=$(get_metadata_value "$FEATURE_ID" "STATUS")
```

**削減**: 15行 → 2行（87%削減）

---

## 次のステップ

### Phase 1 完了に向けて
1. ✅ 統合例の作成（完了）
2. ⏳ 1-2個のコマンドで実運用
3. ⏳ 全11個のコマンドに展開

### Phase 2 以降
- コマンド構造の標準化
- 複雑なコマンドの簡素化
- バリデーションの強化

---

## 関連リソース

- [共有スクリプトドキュメント](../../scripts/README.md)
- [テストガイド](../../tests/README.md)
- [FEATURE-29 Implementation Plan](../../sdlc/features/FEATURE-29/30_implementation_plan.md)
- [FEATURE-29 Design](../../sdlc/features/FEATURE-29/20_design.md)

---

## 変更履歴

- **2025-12-29**: 初版作成（Phase 1統合例）
