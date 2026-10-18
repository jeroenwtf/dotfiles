#!/usr/bin/env bash
set -euo pipefail

echo "== Setting fish as default shell =="
chsh -s /usr/bin/fish

echo "== Installing fisher and plugins =="
fish -c 'if not functions -q fisher; curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher; end; fisher update'
