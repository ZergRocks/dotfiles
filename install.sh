#!/usr/bin/env bash

set -e

# ================================================
# COLORS & FORMATTING
# ================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Helper functions
print_section() {
  echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}${BLUE}  $1${NC}"
  echo ""
  echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_info() {
  echo -e "${YELLOW}→ $1${NC}"
}

print_status() {
  echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
  echo -e "${RED}✗ $1${NC}"
}

print_warning() {
  echo -e "${YELLOW}⚠ $1${NC}"
}

command_exists() {
  command -v "$1" &>/dev/null
}

# ================================================
# PARSE ARGUMENTS
# ================================================
FORCE_MODE=false
for arg in "$@"; do
  case $arg in
  --force | -f)
    FORCE_MODE=true
    shift
    ;; 
  --help | -h)
    echo "Usage: ./install.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --force, -f    Force reinstall everything (backup existing configs)"
    echo "  --help, -h     Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./install.sh           # Normal install/update"
    echo "  ./install.sh --force   # Force reinstall everything"
    exit 0
    ;; 
  esac
done

# ================================================
# ARCHITECTURE DETECTION
# ================================================
ARCH=$(uname -m)
IS_APPLE_SILICON=false
IS_INTEL=false

if [[ "$ARCH" == "arm64" ]]; then
  IS_APPLE_SILICON=true
  HOMEBREW_PREFIX="/opt/homebrew"
elif [[ "$ARCH" == "x86_64" ]]; then
  IS_INTEL=true
  HOMEBREW_PREFIX="/usr/local"
fi

# ================================================
# PATH SETUP FOR HOMEBREW
# ================================================
setup_homebrew_path() {
  if [[ -x "$HOMEBREW_PREFIX/bin/brew" ]]; then
    eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
  fi
}

# Setup PATH immediately
setup_homebrew_path

# ================================================
# STARTUP CHECKS
# ================================================
print_section "Dotfiles Setup & Update"

# Show architecture info
if $IS_APPLE_SILICON; then
  print_info "Detected: Apple Silicon (arm64)"
elif $IS_INTEL; then
  print_info "Detected: Intel Mac (x86_64)"
fi

if $FORCE_MODE; then
  print_warning "FORCE MODE: Will reinstall everything!"
  echo -e "${YELLOW}This will backup and replace all existing configs.${NC}"
  read -p "Continue? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Cancelled by user"
    exit 1
  fi
fi

# Check if in dotfiles directory
if [[ ! -f "install.sh" ]] || [[ ! -d "nvim" ]]; then
  print_error "Please run from dotfiles directory!"
  exit 1
fi

# Check update mode
UPDATE_MODE=false
if ! $FORCE_MODE; then
  if [[ -f "$HOME/.dotfiles_installed" ]] || ([[ -L "$HOME/.config/nvim" ]] && [[ -L "$HOME/.config/fish" ]]); then
    UPDATE_MODE=true
    print_info "Running in UPDATE mode..."
  else
    print_info "Running in INSTALL mode..."
  fi
else
  print_info "Running in FORCE mode..."
fi

# Git pull for dotfiles updates
if $UPDATE_MODE || $FORCE_MODE; then
  print_info "Pulling latest dotfiles..."
  git pull || print_warning "Git pull failed (local changes may exist)"
fi

# ================================================
# 1. HOMEBREW INSTALLATION & UPDATE
# ================================================
print_section "1. Homebrew Setup"

if ! command_exists brew; then
  print_info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Setup PATH permanently
  echo "eval \"\$($HOMEBREW_PREFIX/bin/brew shellenv)\"" >>~/.zprofile
  setup_homebrew_path
  print_status "Homebrew installed"
else
  print_status "Homebrew already installed"

  # Always update Homebrew in update mode
  if $UPDATE_MODE || $FORCE_MODE; then
    print_info "Updating Homebrew..."
    brew update
  fi
fi

# ================================================
# 2. WEZTERM NIGHTLY INSTALLATION
# ================================================
print_section "2. WezTerm Nightly Setup"

# WezTerm Nightly 설치/업데이트
if $UPDATE_MODE || $FORCE_MODE; then
  print_info "Installing/Updating WezTerm Nightly..."
  brew install --cask wezterm@nightly --force 2>/dev/null || {
    brew upgrade --cask wezterm@nightly --force 2>/dev/null || true
  }
  print_status "WezTerm Nightly installed/updated"
else
  if ! brew list --cask wezterm@nightly &>/dev/null 2>&1 && ! brew list --cask wezterm &>/dev/null 2>&1; then
    print_info "Installing WezTerm Nightly..."
    brew install --cask wezterm@nightly
    print_status "WezTerm Nightly installed"
  else
    print_status "WezTerm already installed"
  fi
fi

# ================================================
# 3. CORE DEVELOPMENT TOOLS
# ================================================
print_section "3. Core Development Tools"

# Essential packages (NOTE: git is intentionally excluded - see git setup section)
BREW_PACKAGES=(
  # Editor & Shell
  "neovim" # LazyVim core (>= 0.11.2)
  "fish"   # Smart shell
  "starship" # Shell prompt

  # LazyVim essentials
  "ripgrep"     # Telescope grep search
  "fd"          # Telescope file search
  "lazygit"     # Git integration
  "tree-sitter" # Syntax highlighting

  # Additional tools
  "curl"  # Mason LSP downloader
  "wget"  # Alternative downloader
  "bat"   # Better file previews
  "delta" # Better git diffs
  "fzf"   # Fuzzy finder
  "tmux"  # Terminal multiplexer

  # Languages
  "node" # JavaScript/TypeScript
  "go"   # Go development
  "rust" # Rust development (needed for blink.cmp plugin)

  # Kubernetes
  "kubectl"  # Kubernetes CLI
  "kubectx"  # Context/namespace switcher (includes kubens)
  "k9s"      # Kubernetes TUI dashboard

  # AWS
  "awscli"    # AWS CLI
  "aws-vault" # AWS credentials manager
)

# Update mode: 모든 패키지 업그레이드
if $UPDATE_MODE || $FORCE_MODE; then
  print_info "Upgrading all brew packages..."
  for package in "${BREW_PACKAGES[@]}"; do
    if brew list "$package" &>/dev/null 2>&1; then
      print_info "Upgrading $package..."
      brew upgrade "$package" 2>/dev/null || print_status "$package is latest"
    else
      print_info "Installing $package..."
      brew install "$package"
    fi
  done
else
  # Install mode: 없는 것만 설치
  for package in "${BREW_PACKAGES[@]}"; do
    if brew list "$package" &>/dev/null 2>&1; then
      print_status "$package already installed"
    else
      print_info "Installing $package..."
      brew install "$package"
    fi
  done
fi

# ================================================
# 3.1 GIT SETUP (Use system git to avoid libcurl issues)
# ================================================
print_section "3.1 Git Setup"

# Homebrew git has libcurl compatibility issues on newer macOS
# System git (/usr/bin/git) works reliably, so we use that instead
if brew list git &>/dev/null 2>&1; then
  print_warning "Homebrew git detected - may have libcurl issues"
  print_info "Uninstalling Homebrew git (will use system git)..."
  brew uninstall git 2>/dev/null || true
  print_status "Now using system git"
fi

# Verify git works
if command_exists git; then
  GIT_VERSION=$(git --version)
  print_status "$GIT_VERSION"
  
  # Test git https connectivity
  if git ls-remote https://github.com/LazyVim/starter.git HEAD &>/dev/null; then
    print_status "Git HTTPS connectivity OK"
  else
    print_error "Git HTTPS not working - check network or curl installation"
  fi
else
  print_error "Git not found! Install Xcode Command Line Tools: xcode-select --install"
fi

# ================================================
# 4. D2CODING NERD FONT
# ================================================
print_section "4. D2Coding Nerd Font Setup"

FONT_INSTALLED=false
if ls ~/Library/Fonts/D2Coding* &>/dev/null 2>&1; then
  FONT_INSTALLED=true
fi

if $FONT_INSTALLED && ! $FORCE_MODE; then
  print_status "D2Coding Nerd Font already installed"
else
  if $FORCE_MODE && $FONT_INSTALLED; then
    print_info "Removing existing D2Coding fonts..."
    rm -f ~/Library/Fonts/D2Coding* 2>/dev/null || true
  fi

  print_info "Installing D2Coding Nerd Font..."

  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"

  curl -fLo "D2Coding.zip" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/D2Coding.zip"

  unzip -q D2Coding.zip
  mkdir -p ~/Library/Fonts
  cp *.ttf ~/Library/Fonts/ 2>/dev/null || cp *.otf ~/Library/Fonts/ 2>/dev/null || true

  cd - >/dev/null
  rm -rf "$TEMP_DIR"

  print_status "D2Coding Nerd Font installed"
fi

# ================================================
# 5. MINICONDA SETUP
# ================================================
print_section "5. Miniconda Setup"

if command_exists conda; then
  print_status "Conda already installed"

  if $UPDATE_MODE || $FORCE_MODE; then
    print_info "Updating conda..."
    conda update -n base -c defaults conda -y 2>/dev/null || true

    print_info "Updating Python packages..."
    pip install --upgrade pip ruff neovim pynvim black debugpy ipython jupyter 2>/dev/null || true
  fi
else
  print_info "Installing Miniconda..."

  MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-$(uname -m).sh"
  curl -fsSL -o /tmp/miniconda.sh "$MINICONDA_URL"
  bash /tmp/miniconda.sh -b -p "$HOME/miniconda3"
  rm /tmp/miniconda.sh

  "$HOME/miniconda3/bin/conda" init fish bash zsh
  eval "$($HOME/miniconda3/bin/conda shell.bash hook)"

  conda install -y python=3.11 2>/dev/null || true
  pip install --upgrade pip
  pip install ruff neovim pynvim black debugpy ipython jupyter

  print_status "Miniconda installed"
fi

# ================================================
# 5.1 UV (Fast Python Package Manager) Setup
# ================================================
print_section "5.1 UV Setup"

# UV is needed for 'uvx' command (used by serena MCP server)
if command_exists uv; then
  print_status "UV already installed"
  
  if $UPDATE_MODE || $FORCE_MODE; then
    print_info "Updating UV..."
    curl -LsSf https://astral.sh/uv/install.sh | sh 2>/dev/null || true
  fi
else
  print_info "Installing UV (fast Python package manager)..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  
  # Add to PATH for current session
  if [[ -d "$HOME/.local/bin" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
  fi
  
  if command_exists uv; then
    print_status "UV installed (uvx command available)"
  else
    print_warning "UV installation may require shell restart"
  fi
fi

# ================================================
# 6. LAZYVIM STARTER SETUP
# ================================================
print_section "6. LazyVim Starter Setup"

LAZYVIM_STARTER_DIR="${PWD}/nvim-lazyvim-starter"
CUSTOM_CONFIG_DIR="${PWD}/nvim/.config/nvim"
LAZYVIM_REPO="https://github.com/LazyVim/starter.git"

# Clone or update LazyVim starter
if [[ ! -d "$LAZYVIM_STARTER_DIR" ]]; then
  print_info "Cloning LazyVim starter repository..."
  git clone "$LAZYVIM_REPO" "$LAZYVIM_STARTER_DIR"
  print_status "LazyVim starter cloned"
else
  if $UPDATE_MODE || $FORCE_MODE; then
    print_info "Updating LazyVim starter repository..."
    cd "$LAZYVIM_STARTER_DIR"
    git pull origin main --quiet || print_warning "LazyVim starter update failed"
    cd "$OLDPWD"
    print_status "LazyVim starter updated"
  fi
fi

# Sync LazyVim configuration
sync_lazyvim_config() {
  print_info "Syncing LazyVim configuration..."
  
  # Ensure directories exist
  mkdir -p "$CUSTOM_CONFIG_DIR/lua/config"
  mkdir -p "$CUSTOM_CONFIG_DIR/lua/plugins"
  
  # Copy base files from LazyVim starter
  if [[ ! -f "$CUSTOM_CONFIG_DIR/init.lua" ]]; then
    cp "$LAZYVIM_STARTER_DIR/init.lua" "$CUSTOM_CONFIG_DIR/init.lua"
    print_status "Copied init.lua"
  fi
  
  if [[ ! -f "$CUSTOM_CONFIG_DIR/lua/config/lazy.lua" ]]; then
    cp "$LAZYVIM_STARTER_DIR/lua/config/lazy.lua" "$CUSTOM_CONFIG_DIR/lua/config/lazy.lua"
    print_status "Copied lazy.lua"
  fi
  
  # Copy config files if they don't exist
  for file in autocmds keymaps options; do
    if [[ ! -f "$CUSTOM_CONFIG_DIR/lua/config/$file.lua" ]]; then
      if [[ -f "$LAZYVIM_STARTER_DIR/lua/config/$file.lua" ]]; then
        cp "$LAZYVIM_STARTER_DIR/lua/config/$file.lua" "$CUSTOM_CONFIG_DIR/lua/config/$file.lua"
        print_status "Created lua/config/$file.lua"
      fi
    fi
  done
  
  # Copy additional config files
  for file in .neoconf.json stylua.toml lazyvim.json; do
    if [[ -f "$LAZYVIM_STARTER_DIR/$file" ]] && [[ ! -f "$CUSTOM_CONFIG_DIR/$file" ]]; then
      cp "$LAZYVIM_STARTER_DIR/$file" "$CUSTOM_CONFIG_DIR/$file"
      print_status "Copied $file"
    fi
  done
  
  print_status "LazyVim configuration synced"
}

# Run sync
if ! $UPDATE_MODE || $FORCE_MODE; then
  sync_lazyvim_config
fi

# Clean up starter directory (no longer needed after sync)
if [[ -d "$LAZYVIM_STARTER_DIR" ]]; then
  rm -rf "$LAZYVIM_STARTER_DIR"
  print_status "Cleaned up LazyVim starter (no longer needed)"
fi

# ================================================
# 7. BACKUP & STOW CONFIGS
# ================================================
if ! $UPDATE_MODE || $FORCE_MODE; then
  print_section "7. Backing Up Existing Configs"

  for config in ".config/nvim" ".config/fish" ".config/wezterm" ".config/tmux"; do
    if [[ -e "$HOME/$config" ]]; then
      if [[ -L "$HOME/$config" ]] && $FORCE_MODE; then
        rm "$HOME/$config"
      elif [[ ! -L "$HOME/$config" ]]; then
        backup="$HOME/$config.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$HOME/$config" "$backup"
        print_status "Backed up $config"
      fi
    fi
  done
fi

print_section "8. Linking Dotfiles"

# Ensure .config directory exists
mkdir -p "$HOME/.config"

# Create direct symlinks for all configs (consistent approach)
print_info "Linking configurations..."

# Link nvim config
if [[ -d "nvim/.config/nvim" ]]; then
  ln -sfn "$PWD/nvim/.config/nvim" "$HOME/.config/nvim"
  if [[ -L "$HOME/.config/nvim" ]]; then
    print_status "Neovim config linked successfully"
  else
    print_error "Failed to link Neovim config!"
  fi
else
  print_error "Neovim config directory not found!"
fi

# Link wezterm config
if [[ -d "wezterm/.config/wezterm" ]]; then
  # If it's a real directory and not a symlink, back it up to enforce linking
  if [[ -d "$HOME/.config/wezterm" ]] && [[ ! -L "$HOME/.config/wezterm" ]]; then
    print_info "Existing WezTerm config directory found (not a link). Backing up..."
    mv "$HOME/.config/wezterm" "$HOME/.config/wezterm.backup.$(date +%Y%m%d_%H%M%S)"
  fi

  ln -sfn "$PWD/wezterm/.config/wezterm" "$HOME/.config/wezterm"
  if [[ -L "$HOME/.config/wezterm" ]]; then
    print_status "WezTerm config linked successfully"
    
    # WezTerm 플러그인 초기화 (Resurrect 등)
    if command_exists wezterm; then
      print_info "Initializing WezTerm plugins..."
      wezterm --config-file "$HOME/.config/wezterm/wezterm.lua" ls 2>/dev/null || true
      print_status "WezTerm plugins will be auto-installed on first run"
    fi
  else
    print_warning "Failed to link WezTerm config"
  fi
fi

# Link fish config
if [[ -d "fish/.config/fish" ]]; then
  ln -sfn "$PWD/fish/.config/fish" "$HOME/.config/fish"
  if [[ -L "$HOME/.config/fish" ]]; then
    print_status "Fish config linked successfully"
  else
    print_warning "Failed to link Fish config"
  fi
else
  print_error "Fish config directory not found!"
fi

# Link tmux config
if [[ -d "tmux/.config/tmux" ]]; then
  ln -sfn "$PWD/tmux/.config/tmux" "$HOME/.config/tmux"
  if [[ -L "$HOME/.config/tmux" ]]; then
    print_status "tmux config linked successfully"
  else
    print_warning "Failed to link tmux config"
  fi
fi

# Link opencode config (파일 단위 링크 - 디렉토리에 다른 파일들이 있음)
if [[ -f "opencode/.config/opencode/opencode.json" ]]; then
  mkdir -p "$HOME/.config/opencode"
  ln -sfn "$PWD/opencode/.config/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"
  if [[ -L "$HOME/.config/opencode/opencode.json" ]]; then
    print_status "OpenCode config linked successfully"
  else
    print_warning "Failed to link OpenCode config"
  fi
fi

# ================================================
# 9. OPENCODE SETUP
# ================================================
print_section "9. OpenCode Setup"

# Install OpenCode using official installer
install_opencode() {
  print_info "Installing OpenCode..."
  curl -fsSL https://opencode.ai/install | bash
  
  # Add to PATH if not already there
  if [[ -d "$HOME/.opencode/bin" ]]; then
    export PATH="$HOME/.opencode/bin:$PATH"
  fi
}

if command_exists opencode; then
  print_status "OpenCode already installed"
  
  if $UPDATE_MODE || $FORCE_MODE; then
    print_info "Updating OpenCode..."
    curl -fsSL https://opencode.ai/install | bash 2>/dev/null || true
    print_status "OpenCode updated"
  fi
else
  install_opencode
  if command_exists opencode; then
    print_status "OpenCode installed"
  else
    print_warning "OpenCode installation may require shell restart"
  fi
fi

# OpenCode config is now managed via dotfiles symlink (see "Linking Dotfiles" section)

# ================================================
# 10. FISH SHELL WITH AUTO-UPDATE
# ================================================
print_section "10. Fish Shell Configuration"

# Add fish to /etc/shells if not already there
FISH_PATH=$(which fish)
if [[ -n "$FISH_PATH" ]] && ! grep -q "$FISH_PATH" /etc/shells; then
  print_info "Adding fish to /etc/shells..."
  echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
  print_status "Fish added to valid shells"
fi

# Install Fisher
if ! fish -c "type -q fisher" 2>/dev/null || $FORCE_MODE; then
  print_info "Installing Fisher..."
  fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
fi

# Install/Update plugins
if $UPDATE_MODE || $FORCE_MODE; then
  print_info "Updating Fish plugins..."
  fish -c "fisher update"
else
  fish -c "fisher install jethrokuan/z jorgebucaran/autopair.fish PatrickF1/fzf.fish" 2>/dev/null || true
fi

# Fish 자동 업데이트 설정
print_info "Configuring Fish auto-update..."
fish -c "set -U fish_update_on_open yes" 2>/dev/null || true

print_status "Fish configured with auto-update"

# ================================================
# 11. LAZYVIM UPDATE
# ================================================
print_section "11. LazyVim Configuration"

# Update LazyVim configuration if in update mode
if $UPDATE_MODE || $FORCE_MODE; then
  sync_lazyvim_config
fi

if $FORCE_MODE; then
  print_info "Cleaning Neovim cache..."
  rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim 2>/dev/null || true
fi

# ================================================
# 11.1 NEOVIM PLUGIN HEALTH CHECK
# ================================================
# Clean up problematic plugins (wrong architecture binaries, dirty git state)
clean_nvim_plugins() {
  local LAZY_DIR="$HOME/.local/share/nvim/lazy"
  
  if [[ ! -d "$LAZY_DIR" ]]; then
    return 0
  fi
  
  print_info "Checking Neovim plugins health..."
  
  # Check for x86_64 binaries on arm64 (or vice versa)
  if $IS_APPLE_SILICON; then
    local BAD_ARCH="x86_64"
    local GOOD_ARCH="arm64"
  else
    local BAD_ARCH="arm64"
    local GOOD_ARCH="x86_64"
  fi
  
  # Find and remove plugins with wrong architecture binaries
  local PLUGINS_REMOVED=false
  for dylib in $(find "$LAZY_DIR" -name "*.dylib" -o -name "*.so" 2>/dev/null); do
    if file "$dylib" 2>/dev/null | grep -q "$BAD_ARCH"; then
      local PLUGIN_DIR=$(echo "$dylib" | sed "s|$LAZY_DIR/||" | cut -d'/' -f1)
      print_warning "Found $BAD_ARCH binary in $PLUGIN_DIR (need $GOOD_ARCH)"
      rm -rf "$LAZY_DIR/$PLUGIN_DIR"
      print_status "Removed $PLUGIN_DIR (will be rebuilt)"
      PLUGINS_REMOVED=true
    fi
  done
  
  # Clean up plugins with local modifications (dirty git state)
  for plugin_dir in "$LAZY_DIR"/*/; do
    if [[ -d "$plugin_dir/.git" ]]; then
      local changes=$(git -C "$plugin_dir" status --porcelain 2>/dev/null)
      if [[ -n "$changes" ]]; then
        local plugin_name=$(basename "$plugin_dir")
        print_warning "Plugin $plugin_name has local changes"
        rm -rf "$plugin_dir"
        print_status "Removed $plugin_name (will be reinstalled clean)"
        PLUGINS_REMOVED=true
      fi
    fi
  done
  
  # Clean up failed clone markers
  for cloning_file in "$LAZY_DIR"/*.cloning; do
    if [[ -f "$cloning_file" ]]; then
      rm -f "$cloning_file"
      print_status "Cleaned up failed clone marker"
      PLUGINS_REMOVED=true
    fi
  done
  
  if $PLUGINS_REMOVED; then
    print_status "Plugin cleanup complete - will reinstall on next nvim launch"
  else
    print_status "All plugins healthy"
  fi
}

# Run plugin health check
clean_nvim_plugins

# Verify neovim is accessible
if command_exists nvim; then
  NVIM_VERSION=$(nvim --version | head -1 | cut -d' ' -f2)
  print_status "Neovim $NVIM_VERSION found"
  
  # Update LazyVim plugins
  if $UPDATE_MODE || $FORCE_MODE; then
    print_info "Updating LazyVim plugins..."
    
    # LazyVim 자체와 모든 플러그인 업데이트
    nvim --headless "+Lazy! update" +qa 2>&1 | grep -v "^$" || {
      print_warning "Run ':Lazy update' in Neovim to update plugins"
    }
    
    # Mason으로 LSP 서버들 업데이트
    nvim --headless "+MasonUpdate" +qa 2>&1 | grep -v "^$" || true
    
    print_status "LazyVim and plugins updated"
  else
    print_info "LazyVim will auto-install on first run"
  fi
else
  print_error "Neovim not found in PATH! Installation may have failed."
  print_info "Try running: brew install neovim"
fi

# ================================================
# 12. LANGUAGE TOOLS UPDATE
# ================================================
print_section "12. Language Development Tools"

# Node.js tools
if command_exists npm; then
  if $UPDATE_MODE || $FORCE_MODE; then
    print_info "Updating Node.js tools..."
    npm update -g prettier eslint typescript typescript-language-server 2>/dev/null || true
  else
    print_info "Installing Node.js tools..."
    npm install -g prettier eslint typescript typescript-language-server 2>/dev/null || true
  fi
  print_status "Node.js tools ready"
fi

# Go tools - always get latest
if command_exists go; then
  print_info "Installing/Updating Go tools..."
  go install golang.org/x/tools/gopls@latest
  go install golang.org/x/tools/cmd/goimports@latest
  go install mvdan.cc/gofumpt@latest
  print_status "Go tools updated"
fi

# ================================================
# AUTO-UPDATE CRON SETUP (Optional)
# ================================================
if $UPDATE_MODE || ! $FORCE_MODE; then
  print_section "13. Auto-Update Setup (Optional)"

  echo ""
  read -p "Enable daily auto-updates? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Create update script
    cat >~/dotfiles/auto-update.sh <<'EOF'
#!/bin/bash
cd ~/dotfiles
git pull --quiet
./install.sh --update
EOF
    chmod +x ~/dotfiles/auto-update.sh

    # Add to crontab (daily at 10am)
    (
      crontab -l 2>/dev/null | grep -v "dotfiles/auto-update.sh"
      echo "0 10 * * * ~/dotfiles/auto-update.sh"
    ) | crontab -

    print_status "Daily auto-update enabled (10am)"
  fi
fi

# ================================================
# COMPLETION MESSAGE
# ================================================
print_section "Setup Complete!"

if $FORCE_MODE; then
  print_status "Force reinstall completed!"
elif $UPDATE_MODE; then
  print_status "Everything updated to latest!"
  echo ""
  echo "Updated:"
  echo "• Homebrew packages → latest"
  echo "• WezTerm → nightly build"
  echo "• OpenCode → latest"
  echo "• Fish plugins → latest"
  echo "• LazyVim & plugins → latest"
  echo "• Language servers → latest"
else
  print_status "Installation successful!"
fi

echo ""
print_info "System Info:"
if $IS_APPLE_SILICON; then
  echo "• Architecture: Apple Silicon (arm64)"
elif $IS_INTEL; then
  echo "• Architecture: Intel (x86_64)"
fi

echo ""
print_info "Version Info:"
echo "• WezTerm: Nightly (auto-updates)"
echo "• Fish: $(fish --version 2>/dev/null | cut -d' ' -f3)"
echo "• Neovim: $(nvim --version | head -1 | cut -d' ' -f2)"
echo "• OpenCode: $(opencode --version 2>/dev/null || echo 'Installed')"
echo "• LazyVim: Latest (auto-updates)"

echo ""
print_info "Auto-Update Settings:"
echo "• Homebrew: brew upgrade (manual or cron)"
echo "• WezTerm: Nightly build"
echo "• OpenCode: curl -fsSL https://opencode.ai/install | bash"
echo "• Fish: Auto-update on shell open"
echo "• LazyVim: :Lazy update (or auto)"

# Create installation marker
if ! $UPDATE_MODE; then
  touch "$HOME/.dotfiles_installed"
  print_status "Installation marker created"
fi