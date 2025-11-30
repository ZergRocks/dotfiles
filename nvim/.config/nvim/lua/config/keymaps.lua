-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap
local opts = { noremap = true, silent = false }


-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- Save with root permission (not working for now)
--vim.api.nvim_create_user_command('W', 'w !sudo tee > /dev/null %', {})


-- New tab
keymap.set("n", "te", ":tabedit<CR>", opts)
keymap.set("n", "<tab>", ":tabnext<Return>", opts)
keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)

-- DBT SQL 포맷팅 단축키
keymap.set("n", "<leader>fs", function()
  if vim.b.is_dbt_sql then
    vim.cmd("ConformFormat")
    vim.notify("Formatted with sqlfmt", vim.log.levels.INFO)
  else
    vim.notify("Not a DBT SQL file", vim.log.levels.WARN)
  end
end, { desc = "Format DBT SQL with sqlfmt" })

-- 수동으로 sqlfmt 실행
keymap.set("n", "<leader>fS", function()
  local file = vim.fn.expand("%:p")
  if vim.fn.filereadable(file) == 1 then
    vim.cmd("!sqlfmt " .. file)
  end
end, { desc = "Format file with sqlfmt (external)" })

-- DBT SQL 진단 토글
keymap.set("n", "<leader>td", function()
  if vim.b.is_dbt_sql then
    local enabled = vim.diagnostic.is_enabled({ bufnr = 0 })
    vim.diagnostic.enable(not enabled, { bufnr = 0 })
    vim.notify("SQL diagnostics " .. (enabled and "disabled" or "enabled"), vim.log.levels.INFO)
  else
    vim.notify("Not a DBT SQL file", vim.log.levels.WARN)
  end
end, { desc = "Toggle SQL diagnostics for DBT file" })

-- NeoTree Float 모드 (긴 파일명 볼 때 유용)
keymap.set("n", "<leader>E", function()
  require("neo-tree.command").execute({ action = "show", source = "filesystem", position = "float" })
end, { desc = "Explorer (float mode)" })

-- 비주얼 모드에서 선택한 영역 주석 토글
keymap.set("v", "<C-/>", "gc", { remap = true, desc = "주석 토글" })
keymap.set("v", "<C-_>", "gc", { remap = true, desc = "주석 토글" }) -- 터미널에서 Ctrl+/는 Ctrl+_로 인식

-- Normal 모드에서 현재 줄 주석 토글
keymap.set("n", "<C-/>", "gcc", { remap = true, desc = "주석 토글 (현재 줄)" })
keymap.set("n", "<C-_>", "gcc", { remap = true, desc = "주석 토글 (현재 줄)" })

-- Copilot 토글 (attach/detach)
keymap.set("n", "<leader>at", ":Copilot toggle<CR>", { desc = "Copilot toggle" })
