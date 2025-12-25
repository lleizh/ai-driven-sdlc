#!/usr/bin/env bash
# AI-Driven SDLC インストールスクリプト

set -e

VERSION="1.0.0"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}\n"
}

show_help() {
    cat << EOF
AI-Driven SDLC Installer v${VERSION}

使用方法:
  ./install.sh [options]

オプション:
  --minimal       最小構成（Issue テンプレートのみ）
  --no-templates  テンプレートをスキップ
  --force         既存ファイルを強制上書き
  --update        既存ファイルごとに上書き確認
  --dry-run       実行せず、コピーされるファイルのみ表示
  --help          このヘルプを表示

例:
  ./install.sh                    # フルインストール（既存ファイルはスキップ）
  ./install.sh --minimal          # Issue テンプレートのみ
  ./install.sh --force            # 既存ファイルを強制上書き
  ./install.sh --update           # 既存ファイルごとに確認
  ./install.sh --dry-run          # 確認のみ

EOF
}

# Parse arguments
MINIMAL=false
NO_TEMPLATES=false
DRY_RUN=false
FORCE=false
UPDATE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --minimal)
            MINIMAL=true
            shift
            ;;
        --no-templates)
            NO_TEMPLATES=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --update)
            UPDATE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            print_error "不明なオプション: $1"
            show_help
            exit 1
            ;;
    esac
done

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if in git repository
if [[ ! -d ".git" ]]; then
    print_error "Git リポジトリ内で実行してください"
    exit 1
fi

print_header "AI-Driven SDLC インストーラー v${VERSION}"

# Show what will be installed
if [[ "$DRY_RUN" == true ]]; then
    print_info "Dry run モード（実際のコピーは行いません）"
    echo ""
fi

if [[ "$MINIMAL" == true ]]; then
    print_info "最小構成でインストールします"
else
    print_info "フル構成でインストールします"
fi

if [[ "$FORCE" == true ]]; then
    print_warning "強制上書きモード: 既存ファイルはすべて上書きされます"
elif [[ "$UPDATE" == true ]]; then
    print_info "更新モード: 既存ファイルごとに確認します"
else
    print_info "既存ファイルはスキップします"
fi

echo ""
print_info "インストール内容:"

FILES_TO_COPY=()

# Issue template (always)
FILES_TO_COPY+=(".github/ISSUE_TEMPLATE/feature.md")

if [[ "$MINIMAL" == false ]]; then
    # Claude Code commands (list all sdlc-*.md files)
    for cmd_file in "${SCRIPT_DIR}/.claude/commands/sdlc-"*.md; do
        if [[ -f "$cmd_file" ]]; then
            FILES_TO_COPY+=(".claude/commands/$(basename "$cmd_file")")
        fi
    done

    # CLI tool
    FILES_TO_COPY+=("sdlc-cli")

    # Documentation
    FILES_TO_COPY+=("AI_SDLC.md")

    # Templates
    if [[ "$NO_TEMPLATES" == false ]]; then
        FILES_TO_COPY+=("sdlc/templates/")
    fi
fi

for file in "${FILES_TO_COPY[@]}"; do
    echo "  - ${file}"
done

echo ""

# Confirm
if [[ "$DRY_RUN" == false ]]; then
    read -p "インストールを続行しますか？ (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "キャンセルされました"
        exit 0
    fi
fi

# Install function
install_file() {
    local src="$1"
    local dst="$2"

    if [[ "$DRY_RUN" == true ]]; then
        if [[ -f "$dst" ]] || [[ -d "$dst" ]]; then
            print_info "[DRY RUN] $dst (既存)"
        else
            print_info "[DRY RUN] $dst (新規)"
        fi
        return
    fi

    # Create directory if needed
    mkdir -p "$(dirname "$dst")"

    # Check if file exists
    if [[ -f "$dst" ]] || [[ -d "$dst" ]]; then
        if [[ "$FORCE" == true ]]; then
            # Force overwrite
            print_info "$dst を上書き中..."
        elif [[ "$UPDATE" == true ]]; then
            # Ask user
            read -p "$(echo -e ${YELLOW}?${NC}) $dst は既に存在します。上書きしますか？ (y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_warning "$dst をスキップしました"
                return
            fi
            print_info "$dst を上書き中..."
        else
            # Skip by default
            print_warning "$dst は既に存在します（スキップ）"
            return
        fi

        # Remove existing file/directory before copying
        rm -rf "$dst"
    fi

    # Copy file or directory
    if [[ -d "$src" ]]; then
        cp -r "$src" "$dst"
    else
        cp "$src" "$dst"
    fi

    print_success "$dst"
}

echo ""
print_header "インストール中"

# Install Issue template
install_file "${SCRIPT_DIR}/.github/ISSUE_TEMPLATE/feature.md" ".github/ISSUE_TEMPLATE/feature.md"

if [[ "$MINIMAL" == false ]]; then
    # Install Claude Code commands (each file individually)
    for cmd_file in "${SCRIPT_DIR}/.claude/commands/sdlc-"*.md; do
        if [[ -f "$cmd_file" ]]; then
            local cmd_name=$(basename "$cmd_file")
            install_file "${cmd_file}" ".claude/commands/${cmd_name}"
        fi
    done

    # Install CLI tool
    install_file "${SCRIPT_DIR}/sdlc-cli" "sdlc-cli"

    if [[ "$DRY_RUN" == false ]] && [[ -f "sdlc-cli" ]]; then
        chmod +x sdlc-cli
        print_success "sdlc-cli に実行権限を付与"
    fi

    # Install documentation
    install_file "${SCRIPT_DIR}/AI_SDLC.md" "AI_SDLC.md"

    # Install templates
    if [[ "$NO_TEMPLATES" == false ]]; then
        install_file "${SCRIPT_DIR}/sdlc/templates" "sdlc/templates"
    fi
fi

if [[ "$DRY_RUN" == true ]]; then
    echo ""
    print_info "Dry run 完了（実際のファイルはコピーされていません）"
    exit 0
fi

echo ""
print_header "インストール完了"

print_success "AI-Driven SDLC のインストールが完了しました！"

echo ""
print_info "次のステップ:"

if [[ "$MINIMAL" == true ]]; then
    echo "1. GitHub で新しい Issue を作成（feature テンプレートを使用）"
    echo "2. Risk Level を選択"
else
    echo "1. gh CLI をインストール: brew install gh"
    echo "2. gh CLI で認証: gh auth login"
    echo "3. GitHub で新しい Issue を作成"
    echo "4. Claude Code で実行: /sdlc-init <issue-url>"
fi

echo ""
print_info "詳細: AI_SDLC.md を参照"

echo ""
print_info "Git に追加する場合:"
echo "  git add .github .claude sdlc-cli AI_SDLC.md sdlc/"
echo "  git commit -m \"Add AI-Driven SDLC framework\""
