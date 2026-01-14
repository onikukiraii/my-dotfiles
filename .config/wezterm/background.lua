local wezterm = require("wezterm")

-- 背景画像フォルダ
local backgrounds_dir = wezterm.config_dir .. "/backgrounds"

-- 画像リスト（手動で追加）
local images = {
  backgrounds_dir .. "/shinobu.png",
  backgrounds_dir .. "/azusa.png",
}

-- ランダムに選択
math.randomseed(os.time())
local selected_image = images[math.random(#images)]

-- 壁紙の設定
return {
  -- 一番下のレイヤー: 単色背景
  {
    source = { Color = "#030000" },
    opacity = 1.0,
    width = "100%",
    height = "100%",
  },
  -- 画像レイヤー
  {
    source = { File = selected_image },
    repeat_x = "NoRepeat",
    repeat_y = "NoRepeat",
    height = "Contain",
    width = "Contain",
    horizontal_align = "Right",
    vertical_align = "Bottom",
    opacity = 0.7,
    hsb = {
      brightness = 0.5,
      saturation = 1.0,
    },
  },
  -- 上に半透明のレイヤー
  {
    source = { Color = "#000000" },
    width = "100%",
    height = "100%",
    opacity = 0.5,
  },
}
