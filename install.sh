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
  --force         既存ファイルを強制上書き
  --update        既存ファイルごとに上書き確認
  --dry-run       実行せず、コピーされるファイルのみ表示
  --help          このヘルプを表示

例:
  ./install.sh                    # フルインストール（既存ファイルはスキップ）
  ./install.sh --force            # 既存ファイルを強制上書き
  ./install.sh --update           # 既存ファイルごとに確認
  ./install.sh --dry-run          # 確認のみ

EOF
}

# Parse arguments
DRY_RUN=false
FORCE=false
UPDATE=false

while [[ $# -gt 0 ]]; do
    case $1 in
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

print_info "フル構成でインストールします"

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

# Issue template
FILES_TO_COPY+=(".github/ISSUE_TEMPLATE/feature.md")

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
FILES_TO_COPY+=("sdlc/templates/")

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

# Install Claude Code commands (each file individually)
for cmd_file in "${SCRIPT_DIR}/.claude/commands/sdlc-"*.md; do
    if [[ -f "$cmd_file" ]]; then
        cmd_name=$(basename "$cmd_file")
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
install_file "${SCRIPT_DIR}/sdlc/templates" "sdlc/templates"

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
echo "1. gh CLI をインストール: brew install gh"
echo "2. gh CLI で認証: gh auth login"
echo "3. GitHub で新しい Issue を作成"
echo "4. Claude Code で実行: /sdlc-init <issue-url>"

echo ""
print_info "詳細: AI_SDLC.md を参照"

echo ""
print_info "Git に追加する場合:"
echo "  git add .github .claude sdlc-cli AI_SDLC.md sdlc/"
echo "  git commit -m \"Add AI-Driven SDLC framework\""

# Initialize GitHub Labels
initialize_labels() {
  # Check if gh command exists
  if ! command -v gh &> /dev/null; then
    echo ""
    print_warning "'gh' コマンドが見つかりません。GitHub Label の自動作成をスキップします。"
    print_info "Label を手動で作成するか、gh CLI をインストールして再実行してください:"
    echo "  brew install gh"
    echo "  gh auth login"
    return
  fi

  # Check if in git repository
  if [[ ! -d ".git" ]]; then
    return
  fi

  # Get remote URL
  REMOTE_URL=$(git remote get-url origin 2>/dev/null)
  if [[ -z "$REMOTE_URL" ]]; then
    return
  fi

  # Extract repo (owner/repo) from remote URL
  REPO=$(echo "$REMOTE_URL" | sed -E 's/.*[:\\/]([^\\/]+\\/[^\\/]+)(\.git)?$/\1/' | sed 's/\.git$//')

  echo ""
  print_info "GitHub Label を初期化中..."

  # Define labels: name:color:description
  LABELS=(
    "feature:0e8a16:新機能リクエスト"
    "bug:d73a4a:バグ修正"
    "risk:high:d93f0b:高リスク機能（Design Review 必須）"
    "design-review:1d76db:Design Review PR"
    "implementation:5319e7:Implementation PR"
    "decision-revision:fbca04:Decision 修正 PR"
  )

  # Check each label and create if not exists
  for LABEL_DEF in "${LABELS[@]}"; do
    IFS=':' read -r NAME COLOR DESC <<< "$LABEL_DEF"

    # Check if label already exists
    if gh label list --repo "$REPO" 2>/dev/null | grep -q "^$NAME"; then
      # Label exists, skip
      continue
    fi

    # Create label
    if gh label create "$NAME" --color "$COLOR" --description "$DESC" --repo "$REPO" 2>/dev/null; then
      print_success "Label '$NAME' を作成しました"
    else
      print_warning "Label '$NAME' の作成に失敗しました（スキップします）"
    fi
  done

  print_success "GitHub Label の初期化が完了しました"
}

# Run label initialization
if [[ "$DRY_RUN" == false ]]; then
  initialize_labels
fi

# Setup GitHub Project
setup_github_project() {
  # Check if gh command exists
  if ! command -v gh &> /dev/null; then
    echo ""
    print_warning "'gh' コマンドが見つかりません。GitHub Project のセットアップをスキップします。"
    print_info "gh CLI をインストールして再実行してください:"
    echo "  brew install gh"
    echo "  gh auth login"
    return
  fi

  # Check authentication
  if ! gh auth status &> /dev/null; then
    echo ""
    print_warning "GitHub 認証が必要です。GitHub Project のセットアップをスキップします。"
    print_info "認証: gh auth login"
    return
  fi

  # Check if .sdlc-config already exists
  if [[ -f ".sdlc-config" ]]; then
    print_info ".sdlc-config が既に存在します。GitHub Project のセットアップをスキップします。"
    return
  fi

  echo ""
  print_info "GitHub Projects v2 をセットアップ中..."

  # Get repository owner
  REPO_OWNER=$(gh repo view --json owner -q .owner.login 2>/dev/null || echo "")
  REPO_NAME=$(gh repo view --json name -q .name 2>/dev/null || echo "")

  if [[ -z "$REPO_OWNER" ]] || [[ -z "$REPO_NAME" ]]; then
    print_warning "リポジトリ情報を取得できません。GitHub Project のセットアップをスキップします。"
    return
  fi

  print_info "Repository: $REPO_OWNER/$REPO_NAME"

  # Get owner node ID
  OWNER_ID=$(gh api graphql -f query='
    query($login: String!) {
      user(login: $login) {
        id
      }
    }
  ' -f login="$REPO_OWNER" --jq '.data.user.id' 2>/dev/null || echo "")

  if [[ -z "$OWNER_ID" ]]; then
    print_warning "Owner ID を取得できません。GitHub Project のセットアップをスキップします。"
    return
  fi

  # Create Project
  PROJECT_TITLE="SDLC Project - $REPO_NAME"
  print_info "Project を作成中: $PROJECT_TITLE"

  CREATE_RESULT=$(gh api graphql -f query='
    mutation($ownerId: ID!, $title: String!) {
      createProjectV2(input: {
        ownerId: $ownerId
        title: $title
      }) {
        projectV2 {
          id
          number
          url
        }
      }
    }
  ' -f ownerId="$OWNER_ID" -f title="$PROJECT_TITLE" 2>&1)

  if echo "$CREATE_RESULT" | grep -q "errors"; then
    print_warning "Project 作成に失敗しました。権限を確認してください。"
    echo "$CREATE_RESULT" | jq -r '.errors[0].message' 2>/dev/null || echo "$CREATE_RESULT"
    return
  fi

  PROJECT_ID=$(echo "$CREATE_RESULT" | jq -r '.data.createProjectV2.projectV2.id')
  PROJECT_NUMBER=$(echo "$CREATE_RESULT" | jq -r '.data.createProjectV2.projectV2.number')
  PROJECT_URL=$(echo "$CREATE_RESULT" | jq -r '.data.createProjectV2.projectV2.url')

  print_success "Project 作成成功: $PROJECT_URL"

  # Create custom fields (4 fields as per Decision 3)
  print_info "カスタムフィールドを作成中..."

  # Field 1: SDLC Status (Single Select)
  STATUS_FIELD_ID=$(gh api graphql -f query='
    mutation($projectId: ID!) {
      createProjectV2Field(input: {
        projectId: $projectId
        dataType: SINGLE_SELECT
        name: "SDLC Status"
        singleSelectOptions: [
          {name: "Planning", color: GRAY, description: "Planning phase"},
          {name: "Designing", color: BLUE, description: "Design phase"},
          {name: "Implementing", color: YELLOW, description: "Implementation phase"},
          {name: "Reviewing", color: ORANGE, description: "Review phase"},
          {name: "Completed", color: GREEN, description: "Completed"}
        ]
      }) {
        projectV2Field {
          ... on ProjectV2SingleSelectField {
            id
          }
        }
      }
    }
  ' -f projectId="$PROJECT_ID" --jq '.data.createProjectV2Field.projectV2Field.id' 2>/dev/null || echo "")

  if [[ -n "$STATUS_FIELD_ID" ]]; then
    print_success "SDLC Status フィールド作成成功"
  else
    print_warning "SDLC Status フィールド作成に失敗"
  fi

  # Field 2: Feature ID (Text)
  FEATURE_FIELD_ID=$(gh api graphql -f query='
    mutation($projectId: ID!) {
      createProjectV2Field(input: {
        projectId: $projectId
        dataType: TEXT
        name: "Feature ID"
      }) {
        projectV2Field {
          ... on ProjectV2Field {
            id
          }
        }
      }
    }
  ' -f projectId="$PROJECT_ID" --jq '.data.createProjectV2Field.projectV2Field.id' 2>/dev/null || echo "")

  if [[ -n "$FEATURE_FIELD_ID" ]]; then
    print_success "Feature ID フィールド作成成功"
  else
    print_warning "Feature ID フィールド作成に失敗"
  fi

  # Field 3: Risk Level (Single Select)
  RISK_FIELD_ID=$(gh api graphql -f query='
    mutation($projectId: ID!) {
      createProjectV2Field(input: {
        projectId: $projectId
        dataType: SINGLE_SELECT
        name: "Risk Level"
        singleSelectOptions: [
          {name: "Low", color: GREEN, description: "Low risk"},
          {name: "Medium", color: YELLOW, description: "Medium risk"},
          {name: "High", color: RED, description: "High risk"}
        ]
      }) {
        projectV2Field {
          ... on ProjectV2SingleSelectField {
            id
          }
        }
      }
    }
  ' -f projectId="$PROJECT_ID" --jq '.data.createProjectV2Field.projectV2Field.id' 2>/dev/null || echo "")

  if [[ -n "$RISK_FIELD_ID" ]]; then
    print_success "Risk Level フィールド作成成功"
  else
    print_warning "Risk Level フィールド作成に失敗"
  fi

  # Field 4: Decision Status (Single Select)
  DECISION_FIELD_ID=$(gh api graphql -f query='
    mutation($projectId: ID!) {
      createProjectV2Field(input: {
        projectId: $projectId
        dataType: SINGLE_SELECT
        name: "Decision Status"
        singleSelectOptions: [
          {name: "Pending", color: GRAY, description: "Decision pending"},
          {name: "Confirmed", color: GREEN, description: "Decision confirmed"},
          {name: "Revised", color: YELLOW, description: "Decision revised"}
        ]
      }) {
        projectV2Field {
          ... on ProjectV2SingleSelectField {
            id
          }
        }
      }
    }
  ' -f projectId="$PROJECT_ID" --jq '.data.createProjectV2Field.projectV2Field.id' 2>/dev/null || echo "")

  if [[ -n "$DECISION_FIELD_ID" ]]; then
    print_success "Decision Status フィールド作成成功"
  else
    print_warning "Decision Status フィールド作成に失敗"
  fi

  # Save to .sdlc-config
  print_info ".sdlc-config を作成中..."
  cat > .sdlc-config << EOF
# AI-Driven SDLC Configuration
# Generated: $(date +"%Y-%m-%d %H:%M:%S")

# Repository
REPO_OWNER=$REPO_OWNER
REPO_NAME=$REPO_NAME

# GitHub Project
PROJECT_ID=$PROJECT_ID
PROJECT_NUMBER=$PROJECT_NUMBER
PROJECT_URL=$PROJECT_URL

# Custom Field IDs
FIELD_ID_STATUS=$STATUS_FIELD_ID
FIELD_ID_FEATURE_ID=$FEATURE_FIELD_ID
FIELD_ID_RISK_LEVEL=$RISK_FIELD_ID
FIELD_ID_DECISION_STATUS=$DECISION_FIELD_ID
EOF

  print_success ".sdlc-config を作成しました"

  echo ""
  print_success "GitHub Project のセットアップが完了しました！"
  print_info "Project URL: $PROJECT_URL"
  echo ""
  print_info "次のステップ:"
  echo "  1. .github/workflows/sync-projects.yml を配置（Phase 2）"
  echo "  2. .sdlc-config を git に追加"
  echo "     git add .sdlc-config"
  echo "     git commit -m \"chore: add GitHub Project configuration\""
}

# Run GitHub Project setup
if [[ "$DRY_RUN" == false ]]; then
  setup_github_project
fi
