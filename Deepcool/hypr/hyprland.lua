local M = {}

M.colors = {
	-- Backgrounds & Foregrounds
	bg = "rgba(1a1b26ff)",
	bg_dark = "rgba(16161eff)",
	bg_highlight = "rgba(292e42ff)",
	terminal_black = "rgba(414868ff)",
	fg = "rgba(a9b1d6ff)",
	fg_dark = "rgba(787c99ff)",
	fg_gutter = "rgba(363c51ff)",

	-- Accent Colors
	blue = "rgba(7aa2f7ff)",
	cyan = "rgba(7dcfffff)",
	blue7 = "rgba(394b70ff)",
	purple = "rgba(bb9af7ff)",
	magenta = "rgba(bb9af7ff)",
	magenta2 = "rgba(ff007fff)",
	orange = "rgba(ff9e64ff)",
	yellow = "rgba(e0af68ff)",

	-- Status Colors
	green = "rgba(9ece6aff)",
	teal = "rgba(73dacaff)",
	red = "rgba(f7768eff)",
	comment = "rgba(565f89ff)",
}

----------------
--- MONITORS ---
----------------

local monitor1 = "DP-1"
local monitor2 = "HDMI-A-1"

hl.monitor({
	output = monitor1,
	mode = "1920x1080@60",
	position = "0x0",
	scale = 1,
})

hl.monitor({
	output = monitor2,
	mode = "1920x1080@60",
	position = "1920x0",
	scale = 1,
})

---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal = "ghostty"
local menu = "walker"

-------------------
---- AUTOSTART ----
-------------------

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:

hl.on("hyprland.start", function()
	hl.exec_cmd("uwsm-app -- quickshell")
	hl.exec_cmd("uwsm-app -- swaybg -i ~/Pictures/background.jpg")
	hl.exec_cmd("uwsm-app -- hypridle")
	hl.exec_cmd("uwsm-app -- swaync")
	hl.exec_cmd(menu .. " --gapplication-service")
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
local home = os.getenv("HOME")

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_PICTURES_DIR", home .. "/Pictures")
hl.env("HYPRSHOT_DIR", home .. "/screenshots")
-- nvidia
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
hl.config({
	ecosystem = {
		enforce_permissions = true,
	},
})

hl.permission({
	binary = "/usr/(bin|local/bin)/grim",
	type = "screencopy",
	mode = "allow",
})
hl.permission({
	binary = "/usr/(bin|local/bin)/slack",
	type = "screencopy",
	mode = "allow",
})
hl.permission({
	binary = "/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland",
	type = "screencopy",
	mode = "allow",
})
hl.permission({
	binary = "/usr/(bin|local/bin)/hyprpm",
	type = "plugin",
	mode = "allow",
})

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
	cursor = {
		no_hardware_cursors = true,
	},

	general = {
		gaps_in = 1,
		gaps_out = 0,

		border_size = 2,

		col = {
			active_border = { colors = { M.colors.purple, M.colors.blue }, angle = 45 },
			inactive_border = { colors = { M.colors.bg } },
		},

		-- Set to true to enable resizing windows by clicking and dragging on borders and gaps
		resize_on_border = false,

		-- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
		allow_tearing = false,

		layout = "dwindle",
	},

	decoration = {
		rounding = 0,

		-- Change transparency of focused and unfocused windows
		active_opacity = 1.0,
		inactive_opacity = 1.0,

		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = 0x1a1a1aee,
		},

		blur = {
			enabled = true,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},

	animations = {
		enabled = false,
	},
})

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
	dwindle = {
		preserve_split = true, -- You probably want this
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
	master = {
		new_status = "master",
	},
})

----------------
----  MISC  ----
----------------

hl.config({
	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = false,
		focus_on_activate = true,

		mouse_move_enables_dpms = true,
		key_press_enables_dpms = true,
	},
})

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		follow_mouse = 1,

		sensitivity = 0.4,

		touchpad = {
			natural_scroll = false,
		},
	},
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind("ALT + space", hl.dsp.exec_cmd(menu))

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("$HOME/.local/bin/menu"))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.exec_cmd("wlogout --protocol layer-shell"))

hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("$HOME/.local/bin/screenshot region"))
hl.bind("PRINT", hl.dsp.exec_cmd("$HOME/.local/bin/screenshot output"))

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("librewolf --private-window"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo({ action = "toggle" }))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "d" }))

-- Move focus with mainMod + vim keys
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "d" }))

-- Move window with mainMod + Shift + arrow key
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }))

for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0

	-- Switch workspaces with mainMod + [0-9]
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))

	-- Move active window to a workspace with mainMod + SHIFT + [0-9]
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Toggle special workspace (scratchpad)
hl.bind(mainMod .. " + M", hl.dsp.workspace.toggle_special("magic"))
-- Move item to the scratchpad
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.window.move({ workspace = "special:magic", follow = true }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind("ALT + mouse:272", hl.dsp.window.drag(), { mouse = true }) -- ALT + LMB: Move a window
hl.bind("ALT + mouse:273", hl.dsp.window.resize(), { mouse = true }) -- ALT + RMB: Resize a window

-- Resize window with Ctrl + mainMod + arrow key
hl.bind("CTRL + SUPER + right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
hl.bind("CTRL + SUPER + left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind("CTRL + SUPER + down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })
hl.bind("CTRL + SUPER + up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })

-- Multimedia keys for volume
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
	{ repeating = true, locked = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ repeating = true, locked = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ repeating = true, locked = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ repeating = true, locked = true }
)

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

------------------------------
--- WINDOWS AND WORKSPACES ---
------------------------------

hl.workspace_rule({ workspace = "1", monitor = monitor1, default = true })
hl.workspace_rule({ workspace = "2", monitor = monitor2, default = true })
hl.workspace_rule({ workspace = "3", monitor = monitor1, default = true })
hl.workspace_rule({ workspace = "4", monitor = monitor2, default = true })
hl.workspace_rule({ workspace = "5", monitor = monitor1, default = true })
hl.workspace_rule({ workspace = "6", monitor = monitor2, default = true })
hl.workspace_rule({ workspace = "7", monitor = monitor1, default = true })
hl.workspace_rule({ workspace = "8", monitor = monitor2, default = true })
hl.workspace_rule({ workspace = "9", monitor = monitor1, default = true })
hl.workspace_rule({ workspace = "10", monitor = monitor2, default = true })

-- Ignore maximize requests from apps.
hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

-- Floating windows
hl.window_rule({
	name = "floating-window-rule",
	match = { tag = "floating-window" },
	float = true,
	center = true,
	size = { "monitor_w * 0.5", "monitor_h * 0.5" },
})

hl.window_rule({
	name = "windowrule-4",
	match = { class = "(blueberry.py|Impala|Wiremix|org.gnome.NautilusPreviewer|com.gabm.satty|About|TUI.float)" },
	tag = "+floating-window",
})

hl.window_rule({
	name = "windowrule-5",
	match = {
		class = "(xdg-desktop-portal-gtk|sublime_text|DesktopEditors|org.gnome.Nautilus)",
		title = "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files)",
	},
	tag = "+floating-window",
})

hl.window_rule({
	name = "windowrule-6",
	match = { class = "Screensaver" },
	fullscreen = true,
})

hl.window_rule({
	name = "windowrule-7",
	match = {
		class = "^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$",
	},
	opacity = "1.0 1.0",
})

hl.window_rule({
	name = "windowrule-librewolf",
	match = { class = "^(LibreWolf|librewolf)$" },
	tile = true,
})
