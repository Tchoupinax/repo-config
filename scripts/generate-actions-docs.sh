#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "Generating documentation for shared GitHub Actions..."

find shared-actions -name "action.yml" | while read -r action_file; do
  action_dir="$(dirname "$action_file")"
  echo "  - $action_dir"
  (
    cd "$action_dir"
    npx --yes action-docs --update-readme
  )
done

echo "Documentation generation completed."
