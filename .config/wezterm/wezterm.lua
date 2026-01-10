local wezterm = require("wezterm")
local config = wezterm.config_builder()
local background = require("background")

-- セッション保存・復元プラグイン
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
resurrect.periodic_save()

-- ウィンドウを閉じる前に自動保存
wezterm.on("window-close-requested", function(window, pane)
  resurrect.save_state(resurrect.workspace_state.get_workspace_state())
  return false
end)

config.automatically_reload_config = true
config.font = wezterm.font_with_fallback({
  "NotoMono Nerd Font",
  "Noto Sans CJK JP",
})
config.font_size = 14.0
config.use_ime = true

-- マウスでペインサイズを変更可能にする
config.adjust_window_size_when_changing_font_size = false
config.pane_focus_follows_mouse = true

-- 非アクティブなペインを控えめに暗くする
config.inactive_pane_hsb = {
  saturation = 1.0,
  brightness = 0.85,
}



-- 新しいウィンドウを既存ウィンドウのタブとして開く
config.prefer_to_spawn_tabs = true

-- 通知設定（Claude Code等からの通知を有効化）
config.audible_bell = "Disabled"  -- ビープ音は無効
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = "CursorColor",
}
-- バックグラウンドでも通知を受け取る
config.notification_handling = "AlwaysShow"

-- 壁紙を設定
config.background = background
-- ウィンドウ全体の透過度（0.0〜1.0、低いほど透明）
config.window_background_opacity = 0.7
config.macos_window_background_blur = 20

----------------------------------------------------
-- Tabs
----------------------------------------------------
-- タイトルバーを非表示
config.window_decorations = "RESIZE"
-- タブバーの表示
config.show_tabs_in_tab_bar = true
-- タブが一つの時は非表示
config.hide_tab_bar_if_only_one_tab = true
-- falseにするとタブバーの透過が効かなくなる
-- config.use_fancy_tab_bar = false

-- タブバーの透過
config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}

-- タブバーを背景色に合わせる（壁紙使用時は無効化）
-- config.window_background_gradient = {
--   colors = { "#000000" },
-- }

-- タブの追加ボタンを非表示
config.show_new_tab_button_in_tab_bar = false
-- nightlyのみ使用可能
-- タブの閉じるボタンを非表示
config.show_close_tab_button_in_tabs = false

-- タブ同士の境界線を非表示
config.colors = {
  tab_bar = {
    inactive_tab_edge = "none",
  },
}

-- タブの形をカスタマイズ
-- タブの左側の装飾
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
-- タブの右側の装飾
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#5c6d74"
  local foreground = "#FFFFFF"
  local edge_background = "none"
  if tab.is_active then
    background = "#ae8b2d"
    foreground = "#FFFFFF"
  end
  local edge_foreground = background
  local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "
  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

----------------------------------------------------
-- keybinds
----------------------------------------------------
config.disable_default_key_bindings = true
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables
config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 2000 }

return config

