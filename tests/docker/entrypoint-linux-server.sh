#!/bin/bash
# GitHub Actions Linux jobs: install with dotfiles_profile=server and run verify_install.sh.
set -e
EXIT_CODE=0
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --source /home/testuser/dotfiles \
  --override-data '{"dotfiles_profile":"server"}' || EXIT_CODE=$?
export DOTFILES_PROFILE=server
/home/testuser/dotfiles/tests/verify_install.sh || EXIT_CODE=$?
/home/testuser/collect_debug.sh || true
exit "$EXIT_CODE"
