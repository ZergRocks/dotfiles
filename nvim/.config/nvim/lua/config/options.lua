-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Enable LazyVim auto format
vim.g.autoformat = true

-- LazyVim root dir detection
vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

local opt = vim.opt

opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
opt.expandtab = true -- Use spaces instead of tabs
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true -- Ignore case
opt.inccommand = "nosplit" -- preview incremental substitution
opt.laststatus = 3 -- global statusline
opt.list = true -- Show some invisible characters (tabs...)
opt.mouse = "a" -- Enable mouse mode
opt.number = true -- Print line number
opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.relativenumber = true -- Relative line numbers
opt.scrolloff = 8 -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false -- Don't show mode since we have a statusline
opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.spelllang = { "en" }
opt.splitbelow = true -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true -- Put new windows right of current
opt.tabstop = 2 -- Number of spaces tabs count for
opt.termguicolors = true -- True color support
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap

-- 애니메이션 및 시각 효과 비활성화
opt.pumblend = 0 -- 팝업 투명도 비활성화 (원래 10)
opt.winblend = 0 -- 윈도우 투명도 비활성화

-- LazyVim 애니메이션 관련 설정
vim.g.snacks_animate = false -- Snacks.nvim 애니메이션 비활성화
vim.g.lazyvim_animate = false -- LazyVim 애니메이션 비활성화
vim.g.lazyvim_picker = "fzf" -- Fzf-lua 사용 (더 빠름)
vim.g.mini_animate = false -- mini.animate 완전 비활성화

-- 커서 깜빡임 설정 (WezTerm과 동일하게)
vim.o.guicursor = "n-v-c-sm:block-blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,i-ci-ve:ver25-blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,r-cr-o:hor20-blinkwait700-blinkoff400-blinkon250-Cursor/lCursor"

-- UI 설정
vim.o.showtabline = 2 -- Enable Tabline
vim.o.background = "dark" -- Dark Background
vim.g.snacks_dim = false -- Dimming 비활성화
vim.g.autoformat = false -- Auto Format Global 비활성화
vim.b.autoformat = false -- Auto Format Buffer 비활성화
