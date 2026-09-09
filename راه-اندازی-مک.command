#!/bin/bash
cd "$(dirname "$0")"
if ! command -v node >/dev/null 2>&1; then
  echo ""
  echo "Node.js نصب نیست."
  echo "از nodejs.org نسخهٔ LTS را نصب کنید و دوباره امتحان کنید."
  open https://nodejs.org
  read -p "Enter بزنید تا بسته شود…"
  exit 1
fi
node setup.js
read -p "Enter بزنید تا بسته شود…"
