#!/usr/bin/env bash
# GitHub Projects v2 API PoC
# このスクリプトは GitHub Projects v2 GraphQL API の基本操作を検証します

set -e

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

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}\n"
}

# Check GitHub CLI
if ! command -v gh &> /dev/null; then
    print_error "gh CLI が見つかりません"
    echo "インストール: brew install gh"
    exit 1
fi

# Check authentication
if ! gh auth status &> /dev/null; then
    print_error "GitHub 認証が必要です"
    echo "実行: gh auth login"
    exit 1
fi

print_header "GitHub Projects v2 API PoC"

# Get repository owner
REPO_OWNER=$(gh repo view --json owner -q .owner.login 2>/dev/null || echo "")
if [[ -z "$REPO_OWNER" ]]; then
    print_error "リポジトリ情報を取得できません"
    exit 1
fi

print_info "Repository Owner: $REPO_OWNER"

# Get owner node ID
print_info "Owner の node ID を取得中..."
OWNER_ID=$(gh api graphql -f query='
  query($login: String!) {
    user(login: $login) {
      id
    }
  }
' -f login="$REPO_OWNER" --jq '.data.user.id' 2>/dev/null || echo "")

if [[ -z "$OWNER_ID" ]]; then
    print_error "Owner ID を取得できません"
    exit 1
fi

print_success "Owner ID: $OWNER_ID"

# Test 1: Create Project
print_header "Test 1: Project 作成"

PROJECT_TITLE="Test SDLC Project $(date +%s)"
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
        title
        url
      }
    }
  }
' -f ownerId="$OWNER_ID" -f title="$PROJECT_TITLE" 2>&1)

if echo "$CREATE_RESULT" | grep -q "errors"; then
    print_error "Project 作成に失敗"
    echo "$CREATE_RESULT"
    exit 1
fi

PROJECT_ID=$(echo "$CREATE_RESULT" | jq -r '.data.createProjectV2.projectV2.id')
PROJECT_NUMBER=$(echo "$CREATE_RESULT" | jq -r '.data.createProjectV2.projectV2.number')
PROJECT_URL=$(echo "$CREATE_RESULT" | jq -r '.data.createProjectV2.projectV2.url')

print_success "Project 作成成功"
print_info "  ID: $PROJECT_ID"
print_info "  Number: $PROJECT_NUMBER"
print_info "  URL: $PROJECT_URL"

# Test 2: Create Custom Fields
print_header "Test 2: カスタムフィールド作成"

# Field 1: Status (Single Select)
print_info "Status フィールドを作成中..."
STATUS_FIELD_RESULT=$(gh api graphql -f query='
  mutation($projectId: ID!) {
    createProjectV2Field(input: {
      projectId: $projectId
      dataType: SINGLE_SELECT
      name: "Status"
      singleSelectOptions: [
        {name: "Planning", color: GRAY},
        {name: "Designing", color: BLUE},
        {name: "Implementing", color: YELLOW},
        {name: "Reviewing", color: ORANGE},
        {name: "Completed", color: GREEN}
      ]
    }) {
      projectV2Field {
        ... on ProjectV2SingleSelectField {
          id
          name
          options {
            id
            name
          }
        }
      }
    }
  }
' -f projectId="$PROJECT_ID" 2>&1)

if echo "$STATUS_FIELD_RESULT" | grep -q "errors"; then
    print_error "Status フィールド作成に失敗"
    echo "$STATUS_FIELD_RESULT"
else
    STATUS_FIELD_ID=$(echo "$STATUS_FIELD_RESULT" | jq -r '.data.createProjectV2Field.projectV2Field.id')
    print_success "Status フィールド作成成功: $STATUS_FIELD_ID"
fi

# Field 2: Risk Level (Single Select)
print_info "Risk Level フィールドを作成中..."
RISK_FIELD_RESULT=$(gh api graphql -f query='
  mutation($projectId: ID!) {
    createProjectV2Field(input: {
      projectId: $projectId
      dataType: SINGLE_SELECT
      name: "Risk Level"
      singleSelectOptions: [
        {name: "Low", color: GREEN},
        {name: "Medium", color: YELLOW},
        {name: "High", color: RED}
      ]
    }) {
      projectV2Field {
        ... on ProjectV2SingleSelectField {
          id
          name
        }
      }
    }
  }
' -f projectId="$PROJECT_ID" 2>&1)

if echo "$RISK_FIELD_RESULT" | grep -q "errors"; then
    print_error "Risk Level フィールド作成に失敗"
    echo "$RISK_FIELD_RESULT"
else
    RISK_FIELD_ID=$(echo "$RISK_FIELD_RESULT" | jq -r '.data.createProjectV2Field.projectV2Field.id')
    print_success "Risk Level フィールド作成成功: $RISK_FIELD_ID"
fi

# Field 3: Decision Status (Single Select)
print_info "Decision Status フィールドを作成中..."
DECISION_FIELD_RESULT=$(gh api graphql -f query='
  mutation($projectId: ID!) {
    createProjectV2Field(input: {
      projectId: $projectId
      dataType: SINGLE_SELECT
      name: "Decision Status"
      singleSelectOptions: [
        {name: "Pending", color: GRAY},
        {name: "Confirmed", color: GREEN},
        {name: "Revised", color: YELLOW}
      ]
    }) {
      projectV2Field {
        ... on ProjectV2SingleSelectField {
          id
          name
        }
      }
    }
  }
' -f projectId="$PROJECT_ID" 2>&1)

if echo "$DECISION_FIELD_RESULT" | grep -q "errors"; then
    print_error "Decision Status フィールド作成に失敗"
    echo "$DECISION_FIELD_RESULT"
else
    DECISION_FIELD_ID=$(echo "$DECISION_FIELD_RESULT" | jq -r '.data.createProjectV2Field.projectV2Field.id')
    print_success "Decision Status フィールド作成成功: $DECISION_FIELD_ID"
fi

# Field 4: Feature ID (Text)
print_info "Feature ID フィールドを作成中..."
FEATURE_FIELD_RESULT=$(gh api graphql -f query='
  mutation($projectId: ID!) {
    createProjectV2Field(input: {
      projectId: $projectId
      dataType: TEXT
      name: "Feature ID"
    }) {
      projectV2Field {
        ... on ProjectV2Field {
          id
          name
        }
      }
    }
  }
' -f projectId="$PROJECT_ID" 2>&1)

if echo "$FEATURE_FIELD_RESULT" | grep -q "errors"; then
    print_error "Feature ID フィールド作成に失敗"
    echo "$FEATURE_FIELD_RESULT"
else
    FEATURE_FIELD_ID=$(echo "$FEATURE_FIELD_RESULT" | jq -r '.data.createProjectV2Field.projectV2Field.id')
    print_success "Feature ID フィールド作成成功: $FEATURE_FIELD_ID"
fi

# Test 3: Query all fields
print_header "Test 3: フィールド一覧取得"

FIELDS_QUERY=$(gh api graphql -f query='
  query($number: Int!, $owner: String!) {
    user(login: $owner) {
      projectV2(number: $number) {
        fields(first: 20) {
          nodes {
            ... on ProjectV2Field {
              id
              name
              dataType
            }
            ... on ProjectV2SingleSelectField {
              id
              name
              dataType
              options {
                id
                name
              }
            }
          }
        }
      }
    }
  }
' -f number="$PROJECT_NUMBER" -f owner="$REPO_OWNER" --jq '.data.user.projectV2.fields.nodes' 2>/dev/null)

print_info "作成されたフィールド:"
echo "$FIELDS_QUERY" | jq -r '.[] | "  - \(.name) (\(.dataType))"'

# Summary
print_header "PoC 完了"
print_success "GitHub Projects v2 API の基本操作を確認しました"

echo ""
print_info "作成された Project:"
echo "  URL: $PROJECT_URL"
echo "  ID: $PROJECT_ID"
echo ""
print_info "次のステップ:"
echo "  1. この Project を削除するか、手動で確認"
echo "  2. install.sh にこのロジックを統合"
echo ""
