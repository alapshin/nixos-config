local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.default_prog = { "zellij" }

config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
config.font_size = 10
config.custom_block_glyphs = false
config.bold_brightens_ansi_colors = "BrightAndBold"

config.enable_tab_bar = true
config.tab_max_width = 40
config.enable_scroll_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false

config.color_scheme = "Catppuccin Latte"

wezterm.on("gui-startup", function(cmd)
    select(3, wezterm.mux.spawn_window(cmd or {})):gui_window():maximize()
end)

return config
