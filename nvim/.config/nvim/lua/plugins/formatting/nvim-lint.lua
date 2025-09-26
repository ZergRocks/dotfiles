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
          condition = function(ctx)
            -- dbt 프로젝트가 아닌 경우에만 sqlfluff 사용
            return not vim.fs.find({"dbt_project.yml"}, { path = ctx.dirname, upward = true })[1]
          end,
        },
      },
    },
  },
}