#!/usr/bin/env bash
#
# Copyright 2024 Igor Bogdanov
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

# Must be run as the target (non-root) user after they've been added to 'sudo'
if [ "$EUID" -eq 0 ]; then
  echo "Please run this script as the regular user (not root)."
  exit 1
fi

# Cache sudo credentials up front (prompts once)
sudo -v

# 1) Packages
if command -v apt-get >/dev/null 2>&1; then
  # Debian/Ubuntu
  sudo apt-get update -y
  sudo apt-get install -y zsh vim git curl fzf
elif command -v dnf >/dev/null 2>&1; then
  # Fedora/CentOS/AlmaLinux
  # util-linux-user is for chsh
  # fzf is not in default repos for AlmaLinux/RHEL, will be installed from git
  sudo dnf install -y zsh vim git curl util-linux-user
elif [[ "$(uname)" == "Darwin" ]]; then
  # macOS
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  brew install zsh vim git curl fzf
else
  echo "Unsupported package manager. Please install zsh, vim, git, curl, fzf and chsh manually." >&2
  exit 1
fi

# 2) Oh My Zsh (keep our .zshrc, don't auto-run/auto-chsh)
export RUNZSH=no
export CHSH=no
export KEEP_ZSHRC=yes
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 3) Make zsh the default shell for this user
sudo chsh -s "$(command -v zsh)" "$USER"

# 4) Plugins (clone only if missing)
ZSH_CUSTOM=${ZSH_CUSTOM:-"$HOME/.oh-my-zsh/custom"}
[ -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ] || \
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
[ -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ] || \
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"

# 5) Spaceship prompt (sourced directly)
SPACESHIP_DIR="$HOME/.zsh/spaceship"
[ -d "$SPACESHIP_DIR" ] || \
  git clone --depth=1 https://github.com/spaceship-prompt/spaceship-prompt.git "$SPACESHIP_DIR"

# 6) fzf via git installer if not present (complements apt package)
if [ ! -d "$HOME/.fzf" ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all
fi

# 7) Update ~/.zshrc (idempotent)
ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"

# Ensure plugin list in correct order (syntax-highlighting last)
if grep -q '^plugins=' "$ZSHRC"; then
  sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC"
else
  printf '\nplugins=(git zsh-autosuggestions zsh-syntax-highlighting)\n' >> "$ZSHRC"
fi

append_once() {
  local line="$1"
  grep -qxF "$line" "$ZSHRC" || printf '%s\n' "$line" >> "$ZSHRC"
}

append_once ""  # spacer
append_once "# --- custom zsh setup ---"
append_once 'source $ZSH/oh-my-zsh.sh'
append_once 'SPACESHIP_TIME_SHOW=true'
append_once 'SPACESHIP_PROMPT_ORDER=(user dir host git exec_time line_sep jobs exit_code char)'
append_once 'source "$HOME/.zsh/spaceship/spaceship.zsh"'
append_once '[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"'
append_once "# --- end custom zsh setup ---"

# 8) Simple Vim config
echo "set number" > "$HOME/.vimrc"

# 9) Start zsh now
exec zsh -l
