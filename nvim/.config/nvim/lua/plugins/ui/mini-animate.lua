-- UI 관련 플러그인 설정
return {
  -- mini.animate 비활성화
  {
    "nvim-mini/mini.animate",
    enabled = false,
  },
  -- mini.indentscope 애니메이션 완전 비활성화
  {
    "nvim-mini/mini.indentscope",
    opts = {
      draw = {
        animation = function() return 0 end, -- 애니메이션 시간을 0으로
        delay = 0, -- 지연시간 0
      },
      -- 옵션 추가로 확실히 비활성화
      options = {
        try_as_border = false,
        indent_at_cursor = false,
      },
    },
    init = function()
      -- 완전 비활성화를 위한 추가 설정
      vim.g.miniindentscope_disable = false
      -- 애니메이션 관련 변수들 비활성화
      vim.g.miniindentscope_animate = false
    end,
  },
  -- Noice.nvim 커서 이동 알림 비활성화
  {
    "folke/noice.nvim",
    opts = {
      routes = {
        {
          filter = {
            event = "notify",
            kind = "trace",
          },
          opts = { skip = true },
        },
      },
      presets = {
        lsp_doc_border = false,
      },
    },
  },
}