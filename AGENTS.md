# Agents Guide

## Commands

- Install/Update: `./install.sh` (auto-detects mode) or `./install.sh --force`
- No build/test commands - this is a dotfiles configuration repo

## Repository Structure

- `nvim/.config/nvim/` - Neovim/LazyVim config (Lua)
- `wezterm/.config/wezterm/` - WezTerm terminal (Lua)
- `fish/.config/fish/` - Fish shell config
- `tmux/.config/tmux/` - tmux config
- `opencode/.config/opencode/` - OpenCode AI config
- `install.sh` - Main setup script (Bash)

## Code Style

- **Lua (Neovim/WezTerm)**: 2-space indent, use `local`, double quotes for strings
- **Bash**: Use functions, colored output helpers, `set -e` at top
- **Fish**: `set -gx` for exports, `fish_add_path` for PATH

## Conventions

- Configs use stow-compatible structure: `app/.config/app/`
- Keep comments in Korean where they exist
- LazyVim: follow [LazyVim plugin spec](https://www.lazyvim.org/)
- Local/sensitive config goes in untracked `*.local.*` files
- AI tool directories (`.serena/`, `.claude/`, `.cursor/`, etc.) are gitignored

## Key Files

- `nvim/.config/nvim/lua/config/options.lua` - Neovim options
- `wezterm/.config/wezterm/wezterm.lua` - Terminal config
- `fish/.config/fish/config.fish` - Shell config
- `tmux/.config/tmux/tmux.conf` - tmux config
- `opencode/.config/opencode/opencode.json` - OpenCode permissions & MCP servers
