local wezterm = require("wezterm")
local act = wezterm.action
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

-- Show which key table is active in the status area
wezterm.on("update-right-status", function(window, pane)
  local name = window:active_key_table()
  if name then
    name = "TABLE: " .. name
  end
  window:set_right_status(name or "")
end)

return {
  keys = {
    {
      -- workspaceの切り替え
      key = "w",
      mods = "LEADER",
      action = act.ShowLauncherArgs({ flags = "WORKSPACES", title = "Select workspace" }),
    },
    {
      --workspaceの名前変更
      key = "$",
      mods = "LEADER",
      action = act.PromptInputLine({
        description = "(wezterm) Set workspace title:",
        action = wezterm.action_callback(function(win, pane, line)
          if line then
            wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
          end
        end),
      }),
    },
    {
      key = "W",
      mods = "LEADER|SHIFT",
      action = act.PromptInputLine({
        description = "(wezterm) Create new workspace:",
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            window:perform_action(
              act.SwitchToWorkspace({
                name = line,
              }),
              pane
            )
          end
        end),
      }),
    },
    -- コマンドパレット表示
    { key = "p", mods = "SUPER", action = act.ActivateCommandPalette },
    -- Tab移動 (iTerm風: Cmd + Shift + [ / ])
    { key = "[", mods = "SUPER|SHIFT", action = act.ActivateTabRelative(-1) },
    { key = "]", mods = "SUPER|SHIFT", action = act.ActivateTabRelative(1) },
    { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
    { key = "Tab", mods = "SHIFT|CTRL", action = act.ActivateTabRelative(-1) },
    -- Tab入れ替え
    { key = "{", mods = "LEADER", action = act({ MoveTabRelative = -1 }) },
    { key = "}", mods = "LEADER", action = act({ MoveTabRelative = 1 }) },
    -- Tab新規作成
    { key = "t", mods = "SUPER", action = act({ SpawnTab = "CurrentPaneDomain" }) },
    -- ペイン/タブを閉じる (iTerm風: Cmd + W でペインを閉じる、最後のペインならタブも閉じる)
    { key = "w", mods = "SUPER", action = act({ CloseCurrentPane = { confirm = true } }) },

    -- 画面フルスクリーン切り替え
    { key = "Enter", mods = "ALT", action = act.ToggleFullScreen },

    -- Shift+Enter で改行（CLIツール用） - kitty keyboard protocol対応
    { key = "Enter", mods = "SHIFT", action = act.SendString("\x1b[13;2u") },

    -- コピーモード
    { key = "[", mods = "LEADER", action = act.ActivateCopyMode },
    -- コピー
    { key = "c", mods = "SUPER", action = act.CopyTo("Clipboard") },
    -- 貼り付け
    { key = "v", mods = "SUPER", action = act.PasteFrom("Clipboard") },
    -- 検索モード (Cmd + F)
    { key = "f", mods = "SUPER", action = act.Search("CurrentSelectionOrEmptyString") },
    -- クイックセレクト (Cmd + Shift + Space) - URL、パス、ハッシュなどを素早く選択
    { key = "Space", mods = "SUPER|SHIFT", action = act.QuickSelect },

    -- Pane作成 (iTerm風: Cmd + D で縦分割、Cmd + Shift + D で横分割)
    { key = "d", mods = "SUPER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "d", mods = "SUPER|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    -- Leader版も残す
    { key = "d", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "r", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    -- Paneを閉じる leader + x
    { key = "x", mods = "LEADER", action = act({ CloseCurrentPane = { confirm = true } }) },
    -- Pane移動 (iTerm風: Cmd + Option + 矢印、Cmd + [ / ])
    { key = "[", mods = "SUPER", action = act.ActivatePaneDirection("Prev") },
    { key = "]", mods = "SUPER", action = act.ActivatePaneDirection("Next") },
    { key = "LeftArrow", mods = "SUPER|ALT", action = act.ActivatePaneDirection("Left") },
    { key = "RightArrow", mods = "SUPER|ALT", action = act.ActivatePaneDirection("Right") },
    { key = "UpArrow", mods = "SUPER|ALT", action = act.ActivatePaneDirection("Up") },
    { key = "DownArrow", mods = "SUPER|ALT", action = act.ActivatePaneDirection("Down") },
    -- Leader版も残す (ijkl: i=上, k=下, j=左, l=右)
    { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
    { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
    { key = "i", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
    { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
    -- Pane選択
    { key = "o", mods = "SUPER", action = act.PaneSelect },
    -- 選択中のPaneのみ表示 (iTerm風: Cmd + Shift + Enter)
    { key = "Enter", mods = "SUPER|SHIFT", action = act.TogglePaneZoomState },
    { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
    -- ペインの位置を入れ替え
    { key = "Space", mods = "LEADER", action = act.RotatePanes("Clockwise") },
    { key = "Space", mods = "LEADER|SHIFT", action = act.RotatePanes("CounterClockwise") },

    -- フォントサイズ切替
    { key = "+", mods = "CTRL", action = act.IncreaseFontSize },
    { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
    -- フォントサイズのリセット
    { key = "0", mods = "CTRL", action = act.ResetFontSize },

    -- タブ切替 Cmd + 数字
    { key = "1", mods = "SUPER", action = act.ActivateTab(0) },
    { key = "2", mods = "SUPER", action = act.ActivateTab(1) },
    { key = "3", mods = "SUPER", action = act.ActivateTab(2) },
    { key = "4", mods = "SUPER", action = act.ActivateTab(3) },
    { key = "5", mods = "SUPER", action = act.ActivateTab(4) },
    { key = "6", mods = "SUPER", action = act.ActivateTab(5) },
    { key = "7", mods = "SUPER", action = act.ActivateTab(6) },
    { key = "8", mods = "SUPER", action = act.ActivateTab(7) },
    { key = "9", mods = "SUPER", action = act.ActivateTab(-1) },

    -- コマンドパレット
    { key = "p", mods = "SHIFT|CTRL", action = act.ActivateCommandPalette },
    -- 設定再読み込み
    { key = "r", mods = "SHIFT|CTRL", action = act.ReloadConfiguration },

    -- セッション保存・復元 (resurrect)
    {
      key = "S",
      mods = "LEADER|SHIFT",
      action = wezterm.action_callback(function(win, pane)
        resurrect.save_state(resurrect.workspace_state.get_workspace_state())
        resurrect.window_state.save_window_action()
      end),
    },
    {
      key = "R",
      mods = "LEADER|SHIFT",
      action = wezterm.action_callback(function(win, pane)
        resurrect.fuzzy_load(win, pane, function(id, label)
          local type = string.match(label, "^([^/]+)") -- "workspace" or "window"
          id = string.match(id, "([^/]+)$") -- session name
          if type == "workspace" then
            local state = resurrect.load_state(id, "workspace")
            resurrect.workspace_state.restore_workspace(state, {
              relative = true,
              restore_text = true,
              on_pane_restore = resurrect.tab_state.default_on_pane_restore,
            })
          elseif type == "window" then
            local state = resurrect.load_state(id, "window")
            resurrect.window_state.restore_window(pane:window(), state, {
              relative = true,
              restore_text = true,
              on_pane_restore = resurrect.tab_state.default_on_pane_restore,
            })
          end
        end)
      end),
    },

    -- キーテーブル用
    { key = "s", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
    {
      key = "a",
      mods = "LEADER",
      action = act.ActivateKeyTable({ name = "activate_pane", timeout_milliseconds = 1000 }),
    },
  },
  -- キーテーブル
  -- https://wezfurlong.org/wezterm/config/key-tables.html
  key_tables = {
    -- Paneサイズ調整 leader + s (ijkl: i=上, k=下, j=左, l=右)
    resize_pane = {
      { key = "j", action = act.AdjustPaneSize({ "Left", 1 }) },
      { key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
      { key = "i", action = act.AdjustPaneSize({ "Up", 1 }) },
      { key = "k", action = act.AdjustPaneSize({ "Down", 1 }) },

      -- Cancel the mode by pressing escape
      { key = "Enter", action = "PopKeyTable" },
    },
    activate_pane = {
      { key = "j", action = act.ActivatePaneDirection("Left") },
      { key = "l", action = act.ActivatePaneDirection("Right") },
      { key = "i", action = act.ActivatePaneDirection("Up") },
      { key = "k", action = act.ActivatePaneDirection("Down") },
    },
    -- copyモード leader + [ (ijkl: i=上, k=下, j=左, l=右)
    copy_mode = {
      -- 移動
      { key = "j", mods = "NONE", action = act.CopyMode("MoveLeft") },
      { key = "k", mods = "NONE", action = act.CopyMode("MoveDown") },
      { key = "i", mods = "NONE", action = act.CopyMode("MoveUp") },
      { key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
      -- 最初と最後に移動
      { key = "^", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
      { key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
      -- 左端に移動
      { key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
      { key = "o", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
      { key = "O", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
      --
      { key = ";", mods = "NONE", action = act.CopyMode("JumpAgain") },
      -- 単語ごと移動
      { key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
      { key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
      { key = "e", mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },
      -- ジャンプ機能 t f
      { key = "t", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = true } }) },
      { key = "f", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = false } }) },
      { key = "T", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
      { key = "F", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
      -- 一番下へ
      { key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
      -- 一番上へ
      { key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
      -- viweport
      { key = "H", mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
      { key = "L", mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
      { key = "M", mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
      -- スクロール
      { key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
      { key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
      { key = "d", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },
      { key = "u", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },
      -- 範囲選択モード
      { key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
      { key = "v", mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },
      { key = "V", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Line" }) },
      -- コピー
      { key = "y", mods = "NONE", action = act.CopyTo("Clipboard") },

      -- コピーモードを終了
      {
        key = "Enter",
        mods = "NONE",
        action = act.Multiple({ { CopyTo = "ClipboardAndPrimarySelection" }, { CopyMode = "Close" } }),
      },
      { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
      { key = "c", mods = "CTRL", action = act.CopyMode("Close") },
      { key = "q", mods = "NONE", action = act.CopyMode("Close") },
    },
  },
}

