-- fzf-lua SQL 파일 previewer 에러 해결용 오버라이드
return {
  {
    "ibhagwan/fzf-lua",
    ---@param opts table
    opts = function(_, opts)
      opts = opts or {}
      opts.previewers = opts.previewers or {}
      opts.previewers.builtin = opts.previewers.builtin or {}

      -- 프리뷰 창에서는 syntax/treesitter를 아예 끈다
      opts.previewers.builtin.syntax = false
      opts.previewers.builtin.treesitter = {
        enabled = false,
        disabled = true,
      }

      -- sql 파일은 bat/cat 같은 외부 도구로만 보여주기
      local exts = opts.previewers.builtin.extensions or {}
      exts["sql"] = exts["sql"] or { "bat", "cat" }
      opts.previewers.builtin.extensions = exts

      return opts
    end,
  },
}
