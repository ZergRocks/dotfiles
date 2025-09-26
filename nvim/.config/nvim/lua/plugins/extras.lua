-- LazyVim extras 가져오기
return {
  -- Python 언어 지원 (ruff 포함)
  { import = "lazyvim.plugins.extras.lang.python" },
  -- TypeScript 언어 지원 (tsserver 포함)
  { import = "lazyvim.plugins.extras.lang.typescript" },
  -- 추가 포매터 지원
  { import = "lazyvim.plugins.extras.formatting.prettier" },
}