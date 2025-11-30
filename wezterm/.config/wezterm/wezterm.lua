local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- 아키텍처 감지 (Apple Silicon vs Intel)
local handle = io.popen("uname -m")
local arch = handle:read("*a"):gsub("%s+", "")
handle:close()

local homebrew_prefix = arch == "arm64" and "/opt/homebrew" or "/usr/local"
local fish_path = homebrew_prefix .. "/bin/fish"

config.enable_tab_bar = true
config.enable_scroll_bar = true
-- crash 방지 옵션들
config.front_end = "WebGpu"  -- 또는 "OpenGL"
config.native_macos_fullscreen_mode = false

-- 테마
config.color_scheme = "Silk Dark (base16)"

-- 패널 경계 설정
config.underline_thickness = "3px" -- 패널 경계를 더 두껍게
config.colors = {
	split = "#ffffff", -- 기본 흰색 패널 경계
	-- 선택 영역 색상 (눈에 띄는 밝은 노란색)
	selection_fg = "#000000",
	selection_bg = "#ffe066",
}

-- 비활성 패널의 색조를 변경하여 포커스된 패널과 구분
config.inactive_pane_hsb = {
	hue = 0.95,
	saturation = 0.6,
	brightness = 0.3,
}

config.foreground_text_hsb = {
	hue = 1.0, -- 색조 (기본값)
	saturation = 1.0, -- 채도 (기본값)
	brightness = 2, -- 밝기 (1.0이 기본값이며, 이보다 높으면 더 밝아집니다)
}

-- 커서 설정
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500 -- 500ms 간격으로 깜빡임
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- D2Coding 폰트 설정
config.font = wezterm.font_with_fallback({
	"D2CodingLigature Nerd Font",
	"D2Coding Nerd Font",
})

-- TERM 설정 (tmux 호환성)
config.term = "xterm-256color"

-- Fish 셸 (동적 경로)
config.default_prog = { fish_path, "-l" }

-- 탭바 설정
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false

-- 투명도 설정
config.window_background_opacity = 1
-- config.macos_window_background_blur = 80

-- Mac 키바인딩
config.keys = {
	-- 패널 분할
	{
		key = "d",
		mods = "CMD",
		action = act.SplitVertical({
			args = { fish_path, "-l" }
		})
	},
	{
		key = "d",
		mods = "CMD|SHIFT",
		action = act.SplitHorizontal({
			args = { fish_path, "-l" }
		})
	},

	-- 패널 닫기
	{ key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = false }) },

	-- WezTerm 패널 이동: cmd+hjkl
	{ key = "h", mods = "CMD", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "CMD", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "CMD", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "CMD", action = act.ActivatePaneDirection("Right") },

	-- 패널 줌/언줌: cmd+enter
	{ key = "Enter", mods = "CMD", action = act.TogglePaneZoomState },

	-- Resize panes
	{ key = "H", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
	{ key = "J", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
	{ key = "K", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
	{ key = "L", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },

}

return config
