---@meta
---Reload after editing with Mod+Shift+R.
---@module 'oxwm'

--------------------------------------------------------------------------------
-- Palette: loaded from the active theme's colors.lua.
--------------------------------------------------------------------------------
local ok, theme = pcall(dofile, os.getenv("HOME") .. "/.config/oxwm/colors.lua")
local colors = (ok and type(theme) == "table") and theme or {
    background     = 0x232634,
    background_alt = 0x414559,
    foreground     = 0xc6d0f5,
    primary        = 0xe5c890,
    secondary      = 0x8caaee,
    alert          = 0xe5c890,
    disabled       = 0x6c7086,
    border         = 0x232634,
}
local catppuccin = require("catppuccin");
--------------------------------------------------------------------------------
-- Core
--------------------------------------------------------------------------------
local modkey = "Mod4" -- Super, matching dwm's MODKEY (Mod4Mask)

oxwm.set_modkey(modkey)
-- st is bundled in this repo if you prefer it: oxwm.set_terminal("st")
oxwm.set_terminal("kitty")
oxwm.set_tags({
    "", -- 1: Terminal
    "󰊯", -- 2: Browser
    "󰕼", -- 3: Media
    "", -- 4: Tmux and coding
    "󰙯", -- 5: Telegram
    "󱇤", -- 6: Work
    "", -- 7: Misc
    "󰊴", -- 8: Games
    "", -- 9: Files
})
oxwm.auto_tile(true)
local default_layout = "dwindle" -- single source of truth; Mod+Alt+R resets to this
oxwm.set_layout(default_layout) -- default layout for all tags (fibonacci spiral)
oxwm.bar.set_hide_vacant_tags(false)
oxwm.set_floating_position("center") -- floating windows (incl. toggled) open centered & raised

--------------------------------------------------------------------------------
-- Appearance
--------------------------------------------------------------------------------
oxwm.border.set_width(2)
oxwm.border.set_focused_color(colors.secondary)
oxwm.border.set_unfocused_color(colors.background_alt)

oxwm.gaps.set_smart(true)
oxwm.gaps.set_inner(8, 8) -- (horizontal, vertical) in pixels
oxwm.gaps.set_outer(8, 8) -- (horizontal, vertical) in pixels

oxwm.set_layout_symbol("tiling", "󰙀")
oxwm.set_layout_symbol("monocle", "󰕮")
oxwm.set_layout_symbol("normie", "󰕰") -- normie == floating layout
oxwm.set_layout_symbol("grid", "󰝘")
oxwm.set_layout_symbol("dwindle", "󰕴")
oxwm.set_layout_symbol("scrolling", "󰓡") -- horizontal-scroll (swap if you prefer another glyph)

--------------------------------------------------------------------------------
-- Window rules (translated from dwm's rules[])
--------------------------------------------------------------------------------
oxwm.rule.add({ class = "Gimp", tag = 9, focus = true })
oxwm.rule.add({ class = "mpv", floating = true, focus = true })
oxwm.rule.add({ class = "Pavucontrol", floating = true, focus = true })
oxwm.rule.add({ class = "qimgv", floating = true, focus = true })

--------------------------------------------------------------------------------
-- Bar
--------------------------------------------------------------------------------
oxwm.bar.set_font("Iosevka Nerd Font Propo:size=12")

-- Tags: gold underline + alt bg on the selected tag, grey for empties
-- (scheme args are fg, bg, underline)
oxwm.bar.set_scheme_normal(colors.disabled, colors.background, colors.background)
oxwm.bar.set_scheme_occupied(colors.foreground, colors.background, colors.background)
oxwm.bar.set_scheme_selected(colors.foreground, colors.background_alt, colors.primary)
oxwm.bar.set_scheme_urgent(colors.background, colors.alert, colors.alert)

-- The polybar look is "gold label + white value". oxwm blocks take one color
-- each, so each metric is a gold static label followed by its value block.
local function label(text)
    return oxwm.bar.block.static({
        text = text, format = "", interval = 999999999,
        color = colors.primary, underline = false,
    })
end
local function pipe()
    return oxwm.bar.block.static({
        text = "|", format = "", interval = 999999999,
        color = catppuccin.sep, underline = false,
    })
end

-- CPU % from /proc/stat, diffed against the previous tick (no sleep, no deps).
-- A stateless shell block would have to sample-sleep-sample in one call; instead
-- we stash the last sample in a state file so each tick is non-blocking (~2ms)
-- and the bar never stalls at startup. The % is averaged over the block interval.
local cpu_cmd =
    "f=\"${XDG_RUNTIME_DIR:-/tmp}/oxwm-cpu.prev\"; " ..
    "N=$(awk 'NR==1{print $2+$3+$4+$5+$6+$7+$8, $5}' /proc/stat); " ..
    "P=$(cat \"$f\" 2>/dev/null || echo \"$N\"); printf '%s' \"$N\" > \"$f\"; " ..
    "echo $P $N | awk '{d=$3-$1; i=$4-$2; if(d>0) printf \"%d\", (d-i)*100/d; else print 0}'"

oxwm.bar.set_blocks({
    oxwm.bar.block.shell({
        format = "󰌌 {}",
        command = 'xkblayout-state print "%s"',
        interval = 1,
        color = catppuccin.blue,
        underline = true,
    }),
    pipe(),
    oxwm.bar.block.ram({
        format = "  {used}/{total}GB", interval = 2, color = catppuccin.light_blue, underline = true,
    }),
    pipe(),
    oxwm.bar.block.shell({
        command = cpu_cmd,
        format = "󰍛 {}%", interval = 2, color = colors.primary, underline = true,
    }),
    pipe(),
    oxwm.bar.block.shell({
        command = "df -h / | awk 'NR==2{print $5}'",
        format = "󰋊 {}", interval = 30, color = catppuccin.purple, underline = true,
    }),
    pipe(),
    oxwm.bar.block.shell({
        format = "{}",
        command = "~/.config/oxwm/scripts/network.sh",
        interval = 1,
        color = catppuccin.red,
        underline = true,
	click = { command = "~/.config/oxwm/scripts/hyprltm-net", floating = true },
    }),
    pipe(),
    oxwm.bar.block.shell({
        format = "{}",
        command = "~/.config/oxwm/scripts/bluetooth.sh",
        interval = 1,
        color = catppuccin.blue,
        underline = true,
	click = { command = "kitty -- bluetui", floating = true },
    }),
    pipe(),
    oxwm.bar.block.shell({
        command = "pamixer --get-volume 2>/dev/null || echo 0",
        format = "󰕾 {}%", interval = 2, color = catppuccin.fg, underline = true,
        -- Click opens pulsemixer (TUI) floating + centered (set_floating_position).
        click = { command = "kitty -- pulsemixer", floating = true },
    }),
    pipe(),
    oxwm.bar.block.shell({
        format = "{}",
        command = "~/.config/oxwm/scripts/battery.sh",
        interval = 10,
        color = catppuccin.green,
        underline = true,
	click = { command = "tlpui", floating = true },
    }),
    pipe(),
    oxwm.bar.block.datetime({
        format = "󰸘 {}", date_format = "%a, %b %d - %-I:%M %p",
        interval = 1, color = catppuccin.cyan, underline = true,
	click = { command = "kitty -- khal interactive", floating = true },
    }),
    pipe(),
    oxwm.bar.block.systray({
        color = catppuccin.lavender,
        underline = false,
    })
})

--------------------------------------------------------------------------------
-- Keybinds (Super = modkey, mirroring dwm)
--------------------------------------------------------------------------------

-- Apps / session
oxwm.key.bind({ modkey }, "Return", oxwm.spawn_terminal())
oxwm.key.bind({ modkey }, "Space",
    oxwm.spawn({ "sh", "-c", "rofi -show drun -theme ~/.config/rofi/launchers/type-2/style-4.rasi" }))
oxwm.key.bind({ modkey }, "V",
    oxwm.spawn({ "sh", "-c", "CM_LAUNCHER=\"rofi\" clipmenu -p \"Clipboard\" -i -theme ~/.config/rofi/clipboard/type-1/style-1.rasi" }))
oxwm.key.bind({ modkey }, "F", oxwm.spawn({ "thunar" }))
oxwm.key.bind({ modkey }, "B", oxwm.spawn({ "brave-browser-stable" }))
oxwm.key.bind({ modkey }, "E", oxwm.spawn({ "kitty -- nvim" }))
oxwm.key.bind({ modkey }, "Q", oxwm.client.kill())
oxwm.key.bind({ modkey, "Shift" }, "Q", oxwm.quit())
oxwm.key.bind({ modkey, "Shift" }, "R", oxwm.restart())
oxwm.key.bind({ modkey, "Shift" }, "Slash", oxwm.show_keybinds())
-- Screenshots (sh -c so ~ expands; saves to ~/Screenshots/)
oxwm.key.bind({ modkey, "Shift" }, "S",
    oxwm.spawn({ "sh", "-c", "flameshot gui --path ~/Screenshots/" }))
oxwm.key.bind({ modkey }, "S",
    oxwm.spawn({ "sh", "-c", "flameshot full --path ~/Screenshots/" }))
oxwm.key.bind({ modkey, "Shift" }, "E",
    oxwm.spawn({ "sh", "-c", "~/.config/oxwm/scripts/power" }))

oxwm.key.bind({ modkey, "Shift" }, "C",
    oxwm.spawn({ "sh", "-c", "xcolor -s clipboard" }))

-- Media keys
oxwm.key.bind({}, "XF86AudioRaiseVolume",
    oxwm.spawn({ "sh", "-c", "~/.config/oxwm/scripts/changevolume up" }))
oxwm.key.bind({}, "XF86AudioLowerVolume",
    oxwm.spawn({ "sh", "-c", "~/.config/oxwm/scripts/changevolume down" }))
oxwm.key.bind({}, "XF86AudioMute",
    oxwm.spawn({ "sh", "-c", "~/.config/oxwm/scripts/changevolume mute" }))

-- Volume on Super+F12/F11/F10 (mirrors the bspwm sxhkd binds)
oxwm.key.bind({ modkey }, "F12",
    oxwm.spawn({ "sh", "-c", "~/.config/oxwm/scripts/changevolume up" }))
oxwm.key.bind({ modkey }, "F11",
    oxwm.spawn({ "sh", "-c", "~/.config/oxwm/scripts/changevolume down" }))
oxwm.key.bind({ modkey }, "F10",
    oxwm.spawn({ "sh", "-c", "~/.config/oxwm/scripts/changevolume mute" }))

-- Focus / move within stack (arrows = dwm-faithful, hjkl = ergonomic)
oxwm.key.bind({ modkey }, "Left", oxwm.client.focus_stack(-1))
oxwm.key.bind({ modkey }, "Right", oxwm.client.focus_stack(1))
oxwm.key.bind({ modkey }, "K", oxwm.client.focus_stack(-1))
oxwm.key.bind({ modkey }, "J", oxwm.client.focus_stack(1))
oxwm.key.bind({ modkey, "Shift" }, "Left", oxwm.client.move_stack(-1))
oxwm.key.bind({ modkey, "Shift" }, "Right", oxwm.client.move_stack(1))
oxwm.key.bind({ modkey, "Shift" }, "K", oxwm.client.move_stack(-1))
oxwm.key.bind({ modkey, "Shift" }, "J", oxwm.client.move_stack(1))

oxwm.key.bind({ modkey, "Shift" }, "Space", oxwm.client.toggle_floating())
oxwm.key.bind({ modkey, "Shift" }, "F", oxwm.client.toggle_fullscreen())

-- Master area / gaps
oxwm.key.bind({ modkey, "Control" }, "Left", oxwm.set_master_factor(-5))
oxwm.key.bind({ modkey, "Control" }, "Right", oxwm.set_master_factor(5))
oxwm.key.bind({ modkey }, "H", oxwm.set_master_factor(-5))
oxwm.key.bind({ modkey }, "L", oxwm.set_master_factor(5))
-- nmaster (dwm: Mod+Alt+Tab = fewer, Mod+Alt+Shift+Tab = more)
oxwm.key.bind({ modkey, "Mod1" }, "Tab", oxwm.inc_num_master(-1))
oxwm.key.bind({ modkey, "Mod1", "Shift" }, "Tab", oxwm.inc_num_master(1))
oxwm.key.bind({ modkey }, "A", oxwm.toggle_gaps())
oxwm.key.bind({ modkey, "Control" }, "B", oxwm.toggle_bar())

-- Layouts (dwm-style: Shift+Ctrl+number; Mod+N cycles)
oxwm.key.bind({ modkey }, "N", oxwm.layout.cycle())
-- Mod+Alt+R: reset/return the current tag to the defined default layout.
oxwm.key.bind({ modkey, "Mod1" }, "R", oxwm.layout.set(default_layout))
oxwm.key.bind({ "Shift", "Control" }, "1", oxwm.layout.set("dwindle")) -- default
oxwm.key.bind({ "Shift", "Control" }, "2", oxwm.layout.set("tiling"))
oxwm.key.bind({ "Shift", "Control" }, "3", oxwm.layout.set("scrolling"))
oxwm.key.bind({ "Shift", "Control" }, "4", oxwm.layout.set("grid"))
oxwm.key.bind({ "Shift", "Control" }, "5", oxwm.layout.set("monocle"))
oxwm.key.bind({ "Shift", "Control" }, "6", oxwm.layout.set("normie")) -- floating
-- Pan the scrolling layout (no-op in other layouts)
oxwm.key.bind({ modkey }, "bracketleft", oxwm.layout.scroll_left())
oxwm.key.bind({ modkey }, "bracketright", oxwm.layout.scroll_right())

-- Multi-monitor (focus on Ctrl+Shift+arrows; send window stays on Mod+Shift+,/.)
oxwm.key.bind({ "Control", "Shift" }, "Left", oxwm.monitor.focus(-1))
oxwm.key.bind({ "Control", "Shift" }, "Right", oxwm.monitor.focus(1))
oxwm.key.bind({ modkey, "Shift" }, "Comma", oxwm.monitor.tag(-1))
oxwm.key.bind({ modkey, "Shift" }, "Period", oxwm.monitor.tag(1))

-- Tag navigation
oxwm.key.bind({ modkey }, "Tab", oxwm.tag.view_next())
oxwm.key.bind({ modkey, "Shift" }, "Tab", oxwm.tag.view_previous())
oxwm.key.bind({ modkey, "Control" }, "Tab", oxwm.tag.view_next_nonempty())
-- Adjacent-tag view on Mod+,/. (comma/period = previous/next workspace)
oxwm.key.bind({ modkey }, "Comma", oxwm.tag.view_previous())
oxwm.key.bind({ modkey }, "Period", oxwm.tag.view_next())

-- Per-tag keys (dwm TAGKEYS: view / move / toggleview / toggletag)
local tag_keys = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }
for i, key in ipairs(tag_keys) do
    oxwm.key.bind({ modkey }, key, oxwm.tag.view(i - 1))
    oxwm.key.bind({ modkey, "Shift" }, key, oxwm.tag.move_to(i - 1))
    oxwm.key.bind({ modkey, "Control" }, key, oxwm.tag.toggleview(i - 1))
    oxwm.key.bind({ modkey, "Control", "Shift" }, key, oxwm.tag.toggletag(i - 1))
end

--------------------------------------------------------------------------------
-- Autostart (run once at launch; replaces the old autostart.sh)
--------------------------------------------------------------------------------
oxwm.autostart("xsettingsd")
oxwm.autostart("clipmenud")
oxwm.autostart("caffeine start")
oxwm.autostart("lxqt-policykit-agent")
oxwm.autostart("dunst -config ~/.config/dunst/dunstrc")
oxwm.autostart("picom --config ~/.config/oxwm/picom/picom.conf -b")
oxwm.autostart("sh -c ~/.fehbg")
oxwm.autostart("sh -c 'command -v unclutter >/dev/null 2>&1 && unclutter -idle 1 -root'")
oxwm.autostart("xss-lock -- betterlockscreen -l")
oxwm.autostart("octoxbps-notifier")
oxwm.autostart("onboard")
oxwm.autostart("udiskie --smart-tray")
-- Keyboard layout toggle (US, Armenian and Russian layouts using Alt + Shift)
oxwm.autostart("setxkbmap -layout us,am,ru -variant ,phonetic,phonetic -option grp:alt_shift_toggle")
