local wezterm = require("wezterm")

local config = wezterm.config_builder()

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
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false

config.window_padding = {
    top = 0,
    left = 0,
    right = 0,
    bottom = 0,
}

config.color_scheme = "Catppuccin Latte"
local scheme = wezterm.get_builtin_color_schemes()[config.color_scheme]

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
        theme_overrides = {
            tab = {
                active = {
                    fg = scheme.tab_bar.active_tab.fg_color,
                    bg = scheme.tab_bar.active_tab.bg_color,
                },
                inactive = {
                    fg = scheme.tab_bar.inactive_tab.fg_color,
                    bg = scheme.tab_bar.inactive_tab.bg_color,
                },
                inactive_hover = {
                    fg = scheme.tab_bar.inactive_tab_hover.fg_color,
                    bg = scheme.tab_bar.inactive_tab_hover.bg_color,
                },
            },
        },
    },
    sections = {
        tab_active = {
            { Attribute = { Intensity = "Bold" } },
            "index",
            { Attribute = { Intensity = "Bold" } },
            "process",
            { Attribute = { Intensity = "Bold" } },
            { "cwd", padding = { left = 0, right = 1 } },
            { "zoomed", padding = 0 },
        },
        tab_inactive = {
            "index",
            "process",
            { "cwd", padding = { left = 0, right = 1 } },
            { "zoomed", padding = 0 },
        },
    },
})

return config
