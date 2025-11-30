-- nvim-lint 린터 설정
return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        python = { "ruff" },
        sql = { "sqlfluff" },
      },
      linters = {
        sqlfluff = {
          condition = function()
            -- dbt SQL(vim.b.is_dbt_sql == true)이면 sqlfluff 비활성화
            return vim.b.is_dbt_sql ~= true
          end,
        },
      },
    },
  },
}