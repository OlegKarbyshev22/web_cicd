#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/opt/fastapi-ci-cd-lab"
REPO_URL="${REPO_URL:-git@github.com:YOUR_USERNAME/YOUR_REPOSITORY.git}"
BRANCH="${BRANCH:-main}"
SERVICE_NAME="${SERVICE_NAME:-fastapi-ci-cd-lab}"

if [ ! -d "$APP_DIR/.git" ]; then
  sudo mkdir -p "$APP_DIR"
  sudo chown "$USER":"$USER" "$APP_DIR"
  git clone --branch "$BRANCH" "$REPO_URL" "$APP_DIR"
fi

cd "$APP_DIR"
git fetch origin "$BRANCH"
git reset --hard "origin/$BRANCH"

python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

sudo systemctl restart "$SERVICE_NAME"

