-- mason.nvim 도구 설치
return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "sqlfmt",   -- SQL 포매터 (dbt 프로젝트용)
        "sqlfluff", -- SQL 린터 (일반 SQL 파일용)
        "sqlls",    -- SQL LSP
        "ruff",     -- Python 포매터/린터
      })
    end,
  },
}