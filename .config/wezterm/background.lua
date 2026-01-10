local wezterm = require("wezterm")

-- 壁紙の設定
return {
  -- 一番下のレイヤー: 単色背景（画像の端に合わせる）
  {
    source = {
      Color = "#030000",
    },
    opacity = 1.0,
    width = "100%",
    height = "100%",
  },
  -- 画像レイヤー
  {
    source = {
      File = wezterm.config_dir .. "/backgrounds/shinobu.png",
    },
    -- 画像の表示方法
    repeat_x = "NoRepeat",
    repeat_y = "NoRepeat",
    -- 画像のサイズ調整 (Cover, Contain, or specific size)
    height = "Contain",
    width = "Contain",
    -- 画像の位置
    horizontal_align = "Right",
    vertical_align = "Bottom",
    -- 画像の透明度 (0.0 - 1.0)
    opacity = 0.7,
    -- 明るさ調整
    hsb = {
      brightness = 0.5,
      saturation = 1.0,
    },
  },
  -- 上に半透明のレイヤーを重ねて文字を読みやすくする
  {
    source = {
      Color = "#000000",
    },
    width = "100%",
    height = "100%",
    opacity = 0.5,
  },
}
