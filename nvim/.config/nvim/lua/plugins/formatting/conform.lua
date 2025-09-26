-- LazyVim 공식 방법으로 conform.nvim 설정
return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        sql = function(bufnr)
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          if bufname == "" then
            return {}
          end

          local path = vim.fs.dirname(bufname)
          local is_dbt = vim.fs.find({ "dbt_project.yml" }, { path = path, upward = true })[1] ~= nil

          -- dbt 프로젝트인 경우에만 sqlfmt, 아니면 포매터 없음
          return is_dbt and { "sqlfmt" } or {}
        end,
        python = { "ruff_format", "ruff_organize_imports" },
      },
    },
  },
}
