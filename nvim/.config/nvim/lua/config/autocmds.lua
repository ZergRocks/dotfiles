-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  command = "set nopaste"
})

-- Disable the concealing in some file formats
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonc", "markdown" },
  callback = function()
    vim.opt.conceallevel = 0
  end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = vim.api.nvim_create_augroup("json_conceal", { clear = true }),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- dbt SQL 파일 감지 및 LSP 비활성화
vim.api.nvim_create_autocmd({ "BufEnter", "BufRead" }, {
  group = vim.api.nvim_create_augroup("dbt_sql_config", { clear = true }),
  pattern = { "*.sql" },
  callback = function()
    local buf_path = vim.api.nvim_buf_get_name(0)
    local dbt_project = vim.fs.find({"dbt_project.yml"}, { path = vim.fs.dirname(buf_path), upward = true })[1]

    if dbt_project then
      -- dbt 프로젝트 내 SQL 파일로 표시
      vim.b.is_dbt_sql = true

      -- dbt 프로젝트에서는 SQL LSP 비활성화 (jinja 템플릿 때문)
      vim.schedule(function()
        local bufnr = vim.api.nvim_get_current_buf()
        if vim.api.nvim_buf_is_valid(bufnr) then
          -- SQL LSP 클라이언트 분리
          local clients = vim.lsp.get_clients({ bufnr = bufnr })
          for _, client in ipairs(clients) do
            if client.name == "sqlls" then
              vim.lsp.buf_detach_client(bufnr, client.id)
            end
          end

          -- 진단도 비활성화
          vim.diagnostic.enable(false, { bufnr = bufnr })

          -- treesitter highlight 비활성화 (jinja 템플릿 파싱 에러 방지)
          if vim.treesitter.stop then
            vim.treesitter.stop(bufnr)
          end
        end
      end)
    else
      -- 일반 SQL 파일로 표시
      vim.b.is_dbt_sql = false
    end
  end,
})