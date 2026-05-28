#!/usr/bin/env bash
# ============================================================================
#  一键部署脚本 — Eric's Blog → GitHub Pages
#  用法：
#    cd 到博客根目录（包含 hugo.toml 的目录），然后跑：
#        bash deploy.sh
#  做什么：
#    1. 检查 git / gh 是否就绪（缺什么就告诉你怎么装）
#    2. 用 gh 登录 GitHub（已登过就跳过）
#    3. 创建 public 仓库 AC-Reaper.github.io（已存在就复用）
#    4. git init / commit / push 到 main 分支
#    5. 把 GitHub Pages source 切到 "GitHub Actions"
#    6. 打开 Actions 页面，等构建完成后打开博客主页
# ============================================================================

set -euo pipefail

REPO_OWNER="AC-Reaper"
REPO_NAME="AC-Reaper.github.io"
REPO_FULL="${REPO_OWNER}/${REPO_NAME}"
REPO_URL="https://github.com/${REPO_FULL}"
SITE_URL="https://${REPO_NAME}/"

# ---------- 颜色 -------------------------------------------------------------
RED='\033[0;31m'; GRN='\033[0;32m'; YEL='\033[1;33m'; BLU='\033[0;34m'; NC='\033[0m'
step() { echo -e "\n${BLU}▶ $1${NC}"; }
ok()   { echo -e "${GRN}✓ $1${NC}"; }
warn() { echo -e "${YEL}! $1${NC}"; }
die()  { echo -e "${RED}✗ $1${NC}"; exit 1; }

# ---------- 检查 -------------------------------------------------------------
step "1/6  检查 git 和 gh"

command -v git >/dev/null 2>&1 || die "git 没装。Mac: \`xcode-select --install\` 或装 Xcode 命令行工具。"

if ! command -v gh >/dev/null 2>&1; then
  warn "gh (GitHub CLI) 没装。"
  echo "    Mac:    brew install gh"
  echo "    其他:   https://github.com/cli/cli#installation"
  exit 1
fi
ok "git $(git --version | awk '{print $3}') / gh $(gh --version | head -1 | awk '{print $3}')"

# ---------- 登录 -------------------------------------------------------------
step "2/6  GitHub 登录"

if gh auth status >/dev/null 2>&1; then
  ok "已登录：$(gh api user --jq .login 2>/dev/null || echo unknown)"
else
  warn "首次需要登录。一会儿浏览器会弹出 GitHub 授权页，按提示走完即可。"
  gh auth login --hostname github.com --git-protocol https --web --scopes "repo,workflow"
  ok "登录完成。"
fi

# 确认登录的就是 AC-Reaper
ACTUAL_USER=$(gh api user --jq .login)
if [ "$ACTUAL_USER" != "$REPO_OWNER" ]; then
  warn "当前 gh 登录的是 \"$ACTUAL_USER\"，不是 \"$REPO_OWNER\"。"
  read -p "    要继续用这个账号创建仓库吗？仓库名仍会是 $REPO_NAME（建议改名）。[y/N] " ans
  [[ "$ans" =~ ^[Yy] ]] || die "已退出。请重新登录正确账号：gh auth logout && gh auth login"
fi

# ---------- 创建仓库 ---------------------------------------------------------
step "3/6  创建 GitHub 仓库"

if gh repo view "$REPO_FULL" >/dev/null 2>&1; then
  warn "仓库 $REPO_FULL 已存在，将复用。"
else
  gh repo create "$REPO_FULL" --public --description "Eric's personal blog · Hugo + PaperMod" --homepage "$SITE_URL"
  ok "仓库已创建。"
fi

# ---------- git 初始化 + 推送 ------------------------------------------------
step "4/6  本地 git 初始化并推送到 main"

if [ ! -d .git ]; then
  git init -b main
  ok "已 git init"
fi

# 确保 branch 名是 main
git branch -M main 2>/dev/null || true

# 远程
if git remote get-url origin >/dev/null 2>&1; then
  CUR_REMOTE=$(git remote get-url origin)
  if [ "$CUR_REMOTE" != "${REPO_URL}.git" ] && [ "$CUR_REMOTE" != "$REPO_URL" ]; then
    git remote set-url origin "${REPO_URL}.git"
    warn "已把 origin 改成 ${REPO_URL}.git"
  fi
else
  git remote add origin "${REPO_URL}.git"
  ok "已加 origin"
fi

git add .
if git diff --cached --quiet; then
  warn "没有需要提交的改动，跳过 commit。"
else
  git commit -m "init: hugo + papermod blog (bilingual)" || true
  ok "已 commit"
fi

git push -u origin main
ok "已推送到 $REPO_URL"

# ---------- 开启 Pages -------------------------------------------------------
step "5/6  开启 GitHub Pages（source = GitHub Actions）"

# 先看 Pages 状态
if gh api "repos/${REPO_FULL}/pages" >/dev/null 2>&1; then
  CUR_TYPE=$(gh api "repos/${REPO_FULL}/pages" --jq .build_type 2>/dev/null || echo unknown)
  if [ "$CUR_TYPE" = "workflow" ]; then
    ok "Pages 已配置为 workflow 模式。"
  else
    gh api -X PUT "repos/${REPO_FULL}/pages" -f build_type=workflow >/dev/null && \
      ok "已切换 Pages 到 workflow 模式。"
  fi
else
  gh api -X POST "repos/${REPO_FULL}/pages" -f build_type=workflow >/dev/null && \
    ok "已启用 Pages（workflow 模式）。"
fi

# ---------- 等构建 + 打开浏览器 ----------------------------------------------
step "6/6  等 GitHub Actions 跑完并打开博客"

echo "    Actions:  ${REPO_URL}/actions"
echo "    Settings: ${REPO_URL}/settings/pages"
echo "    Site:     ${SITE_URL}"

# 等最近一次 workflow run 完成（最多等 5 分钟）
TIMEOUT=300
WAITED=0
INTERVAL=10
LAST_STATUS=""

while [ $WAITED -lt $TIMEOUT ]; do
  STATUS=$(gh run list --repo "$REPO_FULL" --limit 1 --json status,conclusion --jq '.[0] | "\(.status):\(.conclusion // "")"' 2>/dev/null || echo "")
  if [ "$STATUS" != "$LAST_STATUS" ]; then
    echo "    [${WAITED}s] $STATUS"
    LAST_STATUS="$STATUS"
  fi
  if [[ "$STATUS" == "completed:success" ]]; then
    ok "构建成功！"
    break
  elif [[ "$STATUS" == completed:* ]]; then
    die "构建失败：$STATUS — 去 ${REPO_URL}/actions 看红色那一步的报错。"
  fi
  sleep $INTERVAL
  WAITED=$((WAITED + INTERVAL))
done

if [ $WAITED -ge $TIMEOUT ]; then
  warn "等了 ${TIMEOUT}s 还没结束，自己去 ${REPO_URL}/actions 看进度吧。"
fi

# 用系统默认浏览器打开
if command -v open >/dev/null 2>&1; then
  open "$SITE_URL"
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$SITE_URL"
fi

echo
echo -e "${GRN}════════════════════════════════════════════════${NC}"
echo -e "${GRN}  🎉 部署完成！${NC}"
echo -e "${GRN}  你的博客：${SITE_URL}${NC}"
echo -e "${GRN}  首次 DNS 生效可能要再等 1-2 分钟。${NC}"
echo -e "${GRN}════════════════════════════════════════════════${NC}"
