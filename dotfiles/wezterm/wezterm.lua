local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.default_prog = {
    os.getenv("SHELL"),
    "-c",
    "zellij",
}

config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
config.font_size = 12
config.font_rules = {
    {
        italic = false,
        intensity = "Bold",
        font = wezterm.font("JetBrainsMono Nerd Font Mono", { weight = "Bold" }),
    },
}
config.custom_block_glyphs = false
config.bold_brightens_ansi_colors = "BrightAndBold"

config.enable_tab_bar = true
config.tab_max_width = 48
config.enable_scroll_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false

config.window_padding = {
    top = 0,
    left = 0,
    right = 0,
    bottom = 0,
}

config.color_scheme = "Catppuccin Latte"

config.hyperlink_rules = wezterm.default_hyperlink_rules()

wezterm.on("gui-startup", function(cmd)
    select(3, wezterm.mux.spawn_window(cmd or {})):gui_window():maximize()
end)

local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
    options = {
        theme = "Catppuccin Latte",
        tab_separators = "",
        section_separators = "",
        component_separators = "",
    },
})

return config
