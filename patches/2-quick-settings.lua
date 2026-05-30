-- Quick Settings tab for KOReader top menu
-- Adds a new tab at the far left with Wi-Fi, action buttons, and frontlight/warmth sliders.
-- Works in both File Manager and Book Reader views.

local Blitbuffer = require("ffi/blitbuffer")
local CenterContainer = require("ui/widget/container/centercontainer")
local Device = require("device")
local Event = require("ui/event")
local FileManager = require("apps/filemanager/filemanager")
local Font = require("ui/font")
local FrameContainer = require("ui/widget/container/framecontainer")
local Geom = require("ui/geometry")
local HorizontalGroup = require("ui/widget/horizontalgroup")
local HorizontalSpan = require("ui/widget/horizontalspan")
local IconWidget = require("ui/widget/iconwidget")
local InputContainer = require("ui/widget/container/inputcontainer")
local ImageWidget = require("ui/widget/imagewidget")
local Math = require("optmath")
local NetworkMgr = require("ui/network/manager")
local Button = require("ui/widget/button")
local ConfirmBox = require("ui/widget/confirmbox")
local ButtonProgressWidget = require("ui/widget/buttonprogresswidget")
local ProgressWidget = require("ui/widget/progresswidget")
local ReaderUi = require("apps/reader/readerui")
local RenderImage = require("ui/renderimage")
local Size = require("ui/size")
local TextWidget = require("ui/widget/textwidget")
local TextBoxWidget = require("ui/widget/textboxwidget")
local UIManager = require("ui/uimanager")
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")
local gettext = require("gettext")
local Screen = Device.screen


local GestureRange = require("ui/gesturerange")

local CoverButton = InputContainer:extend{}

function CoverButton:init()
    self.image_widget = IconWidget:new{
        image = self.image,
        width = self.width,
        height = self.height,
    }

    self[1] = self.image_widget
    self.dimen = self.image_widget:getSize()

    self.ges_events = {
        TapCover = {
            GestureRange:new{
                ges = "tap",
                range = self.dimen,
            },
        },
    }
end

function CoverButton:onTapCover()
    if self.callback then
        self.callback()
    end
    return true
end


-- ============================================================
-- LOCALIZATION
-- ============================================================

local PATCH_L10N = {
    en = {
        -- Confirmations
        ["Are you sure you want to restart KOReader ?"] = "Are you sure you want to restart KOReader ?",
        ["Are you sure you want to exit KOReader ?"] = "Are you sure you want to exit KOReader ?",
        ["OPDS plugin not activated."] = "OPDS plugin not activated.",
        ["Calibre plugin not activated."] = "Calibre plugin not activated.",
        ["Unknown author"] = "Unknown author",
        ["Unknown title"] = "Unknown title",
        -- Actions
        ["Restart"] = "Restart",
        ["Exit"] = "Exit",
        ["Night"] = "Night",
        ["Light"] = "Light",
        ["Rotate"] = "Rotate",
        ["Sleep"] = "Sleep",
        -- Settings menu
        ["Quick settings"] = "Quick settings",
        ["Select actions controls"] = "Select actions controls",
        ["Arrange actions"] = "Arrange actions",
        ["Show actions controls"] = "Show actions controls",
        ["Show actions controls labels"] = "Show actions controls labels",
        ["Show frontlight controls"] = "Show frontlight controls",
        ["Show warmth controls"] = "Show warmth controls",
        ["Show location controls"] = "Show location controls",
        ["Show search controls"] = "Show search controls",
        ["Show info controls"] = "Show info controls",
        ["Show skim controls"] = "Show skim controls",
        ["Always open on this tab"] = "Always open on this tab"
    },
    fr = {
        -- Confirmations
        ["Are you sure you want to restart KOReader ?"] = "Êtes vous sur de vouloir redémarrer KOReader ?",
        ["Are you sure you want to exit KOReader ?"] = "Êtes vous sur de vouloir quitter KOReader ?",
        ["OPDS plugin not activated."] = "Le plugin OPDS n'est pas activé.",
        ["Calibre plugin not activated."] = "Le plugin Calibre n'est pas activé.",
        ["Unknown author"] = "Auteur inconnu",
        ["Unknown title"] = "Titre inconnu",
        -- Actions
        ["Restart"] = "Redémarrer",
        ["Exit"] = "Quitter",
        ["Night"] = "Nuit",
        ["Light"] = "Éclairage",
        ["Rotate"] = "Tourner",
        ["Sleep"] = "Suspendre",
        -- Settings menu
        ["Quick settings"] = "Configuration rapide",
        ["Select actions controls"] = "Sélectionner les contrôles d'actions",
        ["Arrange actions"] = "Organiser les actions",
        ["Show actions controls"] = "Afficher les contrôles d'action",
        ["Show actions controls labels"] = "Afficher les étiquettes des contrôles d'actions",
        ["Show frontlight controls"] = "Afficher les contrôles d'éclairage",
        ["Show warmth controls"] = "Afficher les contrôles de température",
        ["Show location controls"] = "Afficher les contrôles d'emplacement",
        ["Show search controls"] = "Afficher les contrôles de recherche",
        ["Show info controls"] = "Afficher les contrôles d'information",
        ["Show skim controls"] = "Afficher les contrôles de feuilletage",
        ["Always open on this tab"] = "Toujours ouvrir sur cet onglet"
    },
    pt = {
        -- Confirmations
        ["Are you sure you want to restart KOReader ?"] = "Tem certeza que deseja reiniciar o KOReader ?",
        ["Are you sure you want to exit KOReader ?"] = "Tem certeza que deseja sair do KOReader ?",
        ["OPDS plugin not activated."] = "Plugin OPDS não ativado.",
        ["Calibre plugin not activated."] = "Plugin Calibre não ativado.",
        ["Unknown author"] = "Autor desconhecido",
        ["Unknown title"] = "Título desconhecido",
        -- Actions
        ["Restart"] = "Reiniciar",
        ["Exit"] = "Sair",
        ["Night"] = "Noite",
        ["Light"] = "Luz",
        ["Rotate"] = "Girar",
        ["Sleep"] = "Suspender",
        -- Settings menu
        ["Quick settings"] = "Configurações rápidas",
        ["Select actions controls"] = "Selecione controles de ações",
        ["Arrange actions"] = "Organizar acções",
        ["Show actions controls"] = "Mostrar controles de açãoes",
        ["Show actions controls labels"] = "Mostrar rótulos de controles de ações",
        ["Show frontlight controls"] = "Mostrar controles de luz frontal",
        ["Show warmth controls"] = "Mostrar controles de temperatura",
        ["Show location controls"] = "Mostrar controles de locations",
        ["Show search controls"] = "Mostrar controles de pesquisa",
        ["Show info controls"] = "Mostrar controles de informação",
        ["Show skim controls"] = "Mostrar controles de skim",
        ["Always open on this tab"] = "Sempre abrir nesta aba"
    }
}

local function l10nLookup(msg)
    local lang = "en"
    if G_reader_settings and G_reader_settings.readSetting then
        lang = G_reader_settings:readSetting("language") or "en"
    end
    local lang_base = lang:match("^([a-z]+)") or lang
    local map = PATCH_L10N[lang] or PATCH_L10N[lang_base] or PATCH_L10N.en or {}
    return map[msg]
end

local function _(msg)
    local custom = l10nLookup(msg)
    if custom then
        return custom
    end
    return gettext(msg)
end

-- ============================================================
-- Configuration
-- ============================================================

local config_default = {
    action_order = {
        "wifi",
        "night",
        "rotate",
        "light",
        "usb",
        "restart",
        "exit",
        "sleep",
        "ssh",
        "calibre"
    },
    show_actions = {
        wifi = true,
        night = true,
        light = true,
        rotate = true,
        usb = true,
        restart = true,
        exit = false,
        sleep = false,
        ssh = false,
        calibre = false
    },
    show_action_visible = true,
    show_action_label = false,
    show_frontlight = true,
    show_warmth = true,
    show_location = true,
    show_search = true,
    show_info = true,
    show_skim = true,
    open_on_start = true
}

local config

local function loadConfig()
    config = G_reader_settings:readSetting("quick_settings_panel", config_default)
    for k, v in pairs(config_default) do
        if config[k] == nil then
            config[k] = v
        end
    end
    if type(config.show_actions) == "table" then
        for k, v in pairs(config_default.show_actions) do
            if config.show_actions[k] == nil then
                config.show_actions[k] = v
            end
        end
    else
        config.show_actions = config_default.show_actions
    end
    if type(config.action_order) ~= "table" then
        config.action_order = config_default.action_order
    else
        -- Ensure all known actions are in the order list
        local known = {}
        for _, id in ipairs(config.action_order) do
            known[id] = true
        end
        for _, id in ipairs(config_default.action_order) do
            if not known[id] then
                table.insert(config.action_order, id)
            end
        end
    end
end

local function saveConfig()
    G_reader_settings:saveSetting("quick_settings_panel", config)
end

loadConfig()

-- Returns true if a plugin slot is loaded in the active UI; fails open if no UI yet.
local function hasPlugin(slot)
    local ok_f, FM = pcall(require, "apps/filemanager/filemanager")
    local ok_r, RU = pcall(require, "apps/reader/readerui")
    local ui = (ok_f and FM.instance) or (ok_r and RU.instance)
    return ui == nil or ui[slot] ~= nil
end

-- ============================================================
-- Action definitions (data-driven)
-- ============================================================

local action_defs = {
    wifi = {
        icon = "quick_wifi",
        label = _("Wi-Fi"),
        label_func = function()
            if NetworkMgr:isWifiOn() then
                local net = NetworkMgr:getCurrentNetwork()
                if net and net.ssid then
                    return net.ssid
                end
            end
            return "Wi-Fi"
        end,
        active_func = function() return NetworkMgr:isWifiOn() end,
        callback = function(touch_menu)
            if NetworkMgr:isWifiOn() then
                NetworkMgr:toggleWifiOff()
            else
                NetworkMgr:toggleWifiOn()
            end
            UIManager:scheduleIn(1, function()
                if touch_menu.item_table and touch_menu.item_table.panel then
                    touch_menu:updateItems(1)
                end
            end)
        end,
        hold_callback = function(touch_menu)
            -- Long-hold: (re)connect and show the AP picker.
            -- If Wi-Fi is currently on, turn it off first, then bring it
            -- back up with long_press=true so the network list appears.
            -- If already off, go straight to the long-press connect flow.
            local function do_connect()
                NetworkMgr:toggleWifiOn(function()
                    UIManager:scheduleIn(0.5, function()
                        if touch_menu.item_table and touch_menu.item_table.panel then
                            touch_menu:updateItems(1)
                        end
                    end)
                end, true, true)
            end
            if NetworkMgr:isWifiOn() then
                NetworkMgr:toggleWifiOff(function()
                    do_connect()
                end, true)
            else
                do_connect()
            end
        end
    },
    night = {
        icon = "quick_night",
        label = _("Night"),
        active_func = function() return G_reader_settings:isTrue("night_mode") end,
        callback = function(touch_menu)
            UIManager:broadcastEvent(Event:new("ToggleNightMode"))
            touch_menu:updateItems(1)
            UIManager:setDirty("all", "full") -- refresh screen
        end
    },
    light = {
        icon = "quick_light",
        label = _("Light"),
        -- powerd remembers fl_intensity across off/on, so toggle restores the prior level on its own.
        active_func = function() return Device:getPowerDevice():isFrontlightOn() end,
        callback = function(touch_menu)
            Device:getPowerDevice():toggleFrontlight()
            touch_menu:updateItems(1)
        end
    },
    rotate = {
        icon = "quick_rotate",
        label = _("Rotate"),
        active_func = function() return G_reader_settings:isTrue("input_lock_gsensor") end,
        callback = function()
            UIManager:broadcastEvent(Event:new("SwapRotation"))
        end,
        hold_callback = function(touch_menu)
            if Device:hasGSensor() then
                UIManager:broadcastEvent(Event:new("LockGSensor"))
                touch_menu:updateItems(1)
            else
                UIManager:broadcastEvent(Event:new("InvertRotation"))
            end
        end
    },
    usb = {
        icon = "quick_usb",
        label = _("USB"),
        callback = function()
            if Device.canToggleMassStorage and Device:canToggleMassStorage() then
                UIManager:broadcastEvent(Event:new("RequestUSBMS"))
            end
        end
    },
    restart = {
        icon = "quick_restart",
        label = _("Restart"),
        callback = function()
            UIManager:show(ConfirmBox:new{
                text = _("Are you sure you want to restart KOReader ?"),
                ok_text = _("Restart"),
                ok_callback = function()
                    UIManager:broadcastEvent(Event:new("Restart"))
                end
            })
        end
    },
    exit = {
        icon = "quick_exit",
        label = _("Exit"),
        callback = function()
            UIManager:show(ConfirmBox:new{
                text = _("Are you sure you want to exit KOReader ?"),
                ok_text = _("Exit"),
                ok_callback = function()
                    UIManager:broadcastEvent(Event:new("Exit"))
                end
            })
        end
    },
    sleep = {
        icon = "quick_sleep",
        label = _("Sleep"),
        callback = function()
            if Device:canSuspend() then
                UIManager:broadcastEvent(Event:new("RequestSuspend"))
            elseif Device:canPowerOff() then
                UIManager:broadcastEvent(Event:new("RequestPowerOff"))
            end
        end
    },
    -- core plugin
    ssh = {
        icon = "quick_ssh",
        label = _("SSH"),
        visible_func = function() return hasPlugin("SSH") end,
        active_func = function()
            local util = require("util")
            return util.pathExists("/tmp/dropbear_koreader.pid")
        end,
        callback = function(touch_menu)
            UIManager:broadcastEvent(Event:new("ToggleSSHServer"))
            UIManager:scheduleIn(
                2,
                function()
                    if touch_menu.item_table and touch_menu.item_table.panel then
                        touch_menu:updateItems(1)
                    end
                end
            )
        end
    },
    calibre = {
        icon = "quick_calibre",
        label = _("Calibre"),
        visible_func = function() return hasPlugin("calibre") end,
        active_func = function()
            local CW = package.loaded["wireless"]
            return CW ~= nil and CW.calibre_socket ~= nil
        end,
        callback = function(touch_menu)
            local CW = package.loaded["wireless"]
            if CW and CW.calibre_socket ~= nil then
                UIManager:broadcastEvent(Event:new("CloseWirelessConnection"))
            else
                UIManager:broadcastEvent(Event:new("StartWirelessConnection"))
            end
            UIManager:scheduleIn(1, function()
                touch_menu:updateItems(1)
            end)
        end
    }
}


-- Display names for the settings menu (resolved at call-time so language changes are respected)
local function getActionDisplayNames()
    return {
        wifi = _("Wi-Fi"),
        night = _("Night"),
        rotate = _("Rotate"),
        light = _("Light"),
        usb = _("USB"),
        restart = _("Restart"),
        exit = _("Exit"),
        sleep = _("Sleep"),
        ssh = _("SSH"),
        calibre = _("Calibre")
    }
end

-- ============================================================
-- Panel builder — returns panel widget + refs for tap handling
-- ============================================================

local function createQuickSettingsPanel(touch_menu)
    local panel_width = touch_menu.item_width
    local padding = Screen:scaleBySize(10)
    local inner_width = panel_width - padding * 2
    local powerd = Device:getPowerDevice()
    local reader = ReaderUi.instance
    local filemanager = FileManager.instance

    -- Refs table: stored on touch_menu for gesture handling
    local refs = { buttons = {} }

    -- ----- action section -----

    -- Collect visible actions in order
    local visible_actions = {}
    for _, id in ipairs(config.action_order) do
        if config.show_actions[id] and action_defs[id] then
            local def = action_defs[id]
            if not def.visible_func or def.visible_func() then
                table.insert(visible_actions, { id = id, def = def })
            end
        end
    end

    local num_actions = #visible_actions
    local action_btn_size = math.min(math.floor(inner_width / num_actions), Screen:scaleBySize(64))
    local icon_size = math.floor(action_btn_size * 0.5)

    -- Active styling
    local normal_border = Screen:scaleBySize(2)

    local function makeActionButton(icon_name, label_text, isactive, islabel)
        local icon = IconWidget:new{
            icon = icon_name,
            width = icon_size,
            height = icon_size,
            alpha = true
        }
        local circle = FrameContainer:new{
            width = action_btn_size,
            height = action_btn_size,
            radius = math.floor(action_btn_size / 2),
            bordersize = normal_border,
            background = isactive and Blitbuffer.COLOR_LIGHT_GRAY or Blitbuffer.COLOR_WHITE,
            padding = 0,
            CenterContainer:new{
                dimen = Geom:new{
                    w = action_btn_size - normal_border * 2,
                    h = action_btn_size - normal_border * 2
                },
                icon
            }
        }

        local label = TextWidget:new{
            text = label_text,
            face = Font:getFace("xx_smallinfofont"),
            max_width = action_btn_size + Screen:scaleBySize(4),
        }

        if islabel then
            local group = VerticalGroup:new{
                align = "center",
                circle,
                VerticalSpan:new{ width = Screen:scaleBySize(2) },
                label
            }
            return group, circle
        else
            local group = VerticalGroup:new{
                align = "center",
                circle
            }
            return group, circle
        end
    end

    -- Build action row
    local action_row = HorizontalGroup:new{ align = "center" }

    if num_actions > 0 then
        local btn_gap = math.floor((inner_width - num_actions * action_btn_size) / math.max(num_actions - 1, 1))

        for i, entry in ipairs(visible_actions) do
            local def = entry.def
            local label_text = def.label
            if def.label_func then
                label_text = def.label_func()
            end
            local isactive = def.active_func and def.active_func() or false
            local btn_widget, btn_circle = makeActionButton(def.icon, label_text, isactive, config.show_action_label)

            table.insert(refs.buttons, {
                widget = btn_circle,
                callback = function()
                    def.callback(touch_menu)
                end,
                hold_callback = def.hold_callback and function()
                    def.hold_callback(touch_menu)
                end or nil,
                })

            table.insert(action_row, btn_widget)
            if i < num_actions then
                table.insert(action_row, HorizontalSpan:new{ width = btn_gap })
            end
        end
    end

    --

    local section_span = VerticalSpan:new{ width = Screen:scaleBySize(8) }

   -- ----- Frontlight section -----

    local frontlight_group = VerticalGroup:new{ align = "center" }
    if config.show_frontlight and Device:hasFrontlight() then
        -- variable
        local frontlight_btn_width = Screen:scaleBySize(50)
        local frontlight_gap = Screen:scaleBySize(4)
        local frontlight_slider_width = inner_width - 2 * frontlight_btn_width - 2 * frontlight_gap
        local frontlight_text_size = 16

        -- Special character
        local frontlight_text = "✺"
        local frontlight_prev_text = "\u{25C1}"
        local frontlight_next_text = "\u{25B7}"

        -- Frontlight state
        local fl = {
            min = powerd.fl_min,
            max = powerd.fl_max,
            cur = powerd:frontlightIntensity()
        }

        -- Ticks for the progress bar
        local fl_steps = fl.max - fl.min + 1
        local fl_stride = math.ceil(fl_steps * (1 / 25))
        local fl_ticks = {}
        local fl_num_ticks = math.ceil(fl_steps / fl_stride)
        if (fl_num_ticks - 1) * fl_stride < fl.max - fl.min then
            fl_num_ticks = fl_num_ticks + 1
        end
        fl_num_ticks = math.min(fl_num_ticks, fl_steps)
        for i = 1, fl_num_ticks - 2 do
            table.insert(fl_ticks, i * fl_stride)
        end

        -- Create buttons first to measure height
        local fl_minus = Button:new{
            text = frontlight_text .. frontlight_prev_text,
            width = frontlight_btn_width,
            text_font_size = frontlight_text_size,
            show_parent = touch_menu.show_parent,
            callback = function() end, -- placeholder, set below
            hold_callback = function() end -- placeholder, set below
        }

        local frontlight_btn_height = fl_minus:getSize().h

        local fl_progress = ProgressWidget:new{
            width = frontlight_slider_width,
            height = frontlight_btn_height,
            percentage = fl.cur / fl.max,
            ticks = fl_ticks,
            tick_width = Screen:scaleBySize(0.5),
            last = fl.max
        }

        local function setBrightness(intensity)
            if intensity ~= fl.min and intensity == fl.cur then return end
            intensity = math.max(fl.min, math.min(fl.max, intensity))
            powerd:setIntensity(intensity)
            fl.cur = powerd:frontlightIntensity()
            fl_progress:setPercentage(fl.cur / fl.max)
            touch_menu:updateItems(1)
        end

        -- Now wire up the real callback
        fl_minus.callback = function() setBrightness(fl.cur - 1) end
        fl_minus.hold_callback = function() setBrightness(fl.min) end

        local fl_plus = Button:new{
            text = frontlight_next_text .. frontlight_text,
            width = frontlight_btn_width,
            text_font_size = frontlight_text_size,
            show_parent = touch_menu.show_parent,
            callback = function() setBrightness(fl.cur + 1) end,
            hold_callback = function() setBrightness(fl.max) end
        }

        -- Inline row: [−] [slider] [+]
        local fl_row = HorizontalGroup:new{
            align = "center",
            fl_minus,
            HorizontalSpan:new{ width = frontlight_gap },
            fl_progress,
            HorizontalSpan:new{ width = frontlight_gap },
            fl_plus
        }

        -- Store progress ref for tap/pan handling
        refs.fl_progress = fl_progress
        refs.fl_state = fl
        refs.setBrightness = setBrightness

        table.insert(frontlight_group, section_span)
        table.insert(frontlight_group, fl_row)
    end

    -- ----- Warmth section (conditional) -----

    local warmth_group = VerticalGroup:new{ align = "center" }
    if config.show_warmth and Device:hasNaturalLight() then
        -- variable
        local warmth_btn_width = Screen:scaleBySize(50)
        local warmth_gap = Screen:scaleBySize(4)
        local warmth_slider_width = inner_width - 2 * warmth_btn_width - 2 * warmth_gap
        local warmth_text_size = 16

        -- Special character
        local warmth_text = "⊛"
        local warmth_minus_text = "⊛\u{25C1}" -- ⊛◁   💡
        local warmth_plus_text = "\u{25B7}⊛" -- ▷⊛    💡

        -- Warmth state
        local warmth = {
            min = powerd.fl_warmth_min,
            max = powerd.fl_warmth_max,
            cur = powerd:toNativeWarmth(powerd:frontlightWarmth())
        }

        --
        local warmth_steps = warmth.max - warmth.min + 1
        local warmth_stride = math.ceil(warmth_steps * (1 / 25))
        local warmth_num_buttons = math.ceil(warmth_steps / warmth_stride)
        if (warmth_num_buttons - 1) * warmth_stride < warmth.max - warmth.min then
            warmth_num_buttons = warmth_num_buttons + 1
        end
        warmth_num_buttons = math.min(warmth_num_buttons, warmth_steps)

        -- Create buttons first to measure height
        local warmth_minus = Button:new{
            text = warmth_minus_text,
            width = warmth_btn_width,
            text_font_size = warmth_text_size,
            show_parent = touch_menu.show_parent,
            callback = function() end, -- placeholder, set below
            hold_callback = function() end, -- placeholder, set below
        }

        local warmth_btn_height = warmth_minus:getSize().h

        local warmth_progress = ButtonProgressWidget:new{
            width = warmth_slider_width,
            height = warmth_btn_height,
            font_size = warmth_text_size,
            padding = 0,
            thin_grey_style = false,
            num_buttons = warmth_num_buttons - 1,
            position = math.floor(warmth.cur / warmth_stride),
            default_position = math.floor(warmth.cur / warmth_stride),
            callback = function(i)
                local new_native = Math.round(i * warmth_stride)
                new_native = math.min(new_native, warmth.max)
                powerd:setWarmth(powerd:fromNativeWarmth(new_native))
                warmth.cur = powerd:toNativeWarmth(powerd:frontlightWarmth())
                touch_menu:updateItems(1)
            end,
            show_parent = touch_menu.show_parent,
            enabled = true
        }

        local function setWarmth(value)
            if value == warmth.cur then return end
            value = math.max(warmth.min, math.min(warmth.max, value))
            powerd:setWarmth(powerd:fromNativeWarmth(value))
            warmth.cur = powerd:toNativeWarmth(powerd:frontlightWarmth())
            warmth_progress:setPosition(math.floor(warmth.cur / warmth_stride), warmth_progress.default_position)
            touch_menu:updateItems(1)
        end

        -- Now wire up the real callback
        warmth_minus.callback = function() setWarmth(warmth.cur - 1) end
        warmth_minus.hold_callback = function() setWarmth(warmth.min) end

        local warmth_plus = Button:new{
            text = warmth_plus_text,
            width = warmth_btn_width,
            text_font_size = warmth_text_size,
            show_parent = touch_menu.show_parent,
            callback = function() setWarmth(warmth.cur + 1) end,
            hold_callback = function() setWarmth(warmth.max) end
        }

        -- Inline row: [−] [slider] [+]
        local warmth_row = HorizontalGroup:new{
            align = "center",
            warmth_minus,
            HorizontalSpan:new{ width = warmth_gap },
            warmth_progress,
            HorizontalSpan:new{ width = warmth_gap },
            warmth_plus,
        }

        table.insert(warmth_group, section_span)
        table.insert(warmth_group, warmth_row)
    end

        -- ----- Location section -----

    local location_group = VerticalGroup:new{ align = "center" }
    if config.show_location then
        -- variable
        local location_gap = Screen:scaleBySize(4)
        local location_btn_width = Math.round( (inner_width - location_gap * 2 ) / 3 )
        local location_text_size = 22

        -- Special character
        local location_history_text = "\u{F1DA}"
        local location_collections_text = "\u{F0C9}"
        local location_favorites_text = "\u{F005}"

        local location_history = Button:new{
            text = location_history_text .. " " .. _("History"),
            width = location_btn_width,
            text_font_size = location_text_size,
            show_parent = touch_menu.show_parent,
            callback = function()
                touch_menu:closeMenu()
                if filemanager and filemanager.history then
                    filemanager.history:onShowHist()
                end
                if reader and reader.history then
                    reader.history:onShowHist()
                end
            end,
            hold_callback = function()
                touch_menu:closeMenu()
                if filemanager and filemanager.menu then
                    filemanager.menu:onOpenLastDoc()
                end
                if reader  then
                    reader:onOpenLastDoc()
                end
            end
        }

        local location_collections = Button:new{
            text = location_collections_text .. " " .. _("Collections"),
            width = location_btn_width,
            text_font_size = location_text_size,
            show_parent = touch_menu.show_parent,
            callback = function()
                touch_menu:closeMenu()
                if filemanager and filemanager.collections then
                    filemanager.collections:onShowCollList()
                end
                if reader and reader.collections then
                    reader.collections:onShowCollList()
                end
            end,
            hold_callback = function()
                touch_menu:closeMenu()
            end
        }

        local location_favorites = Button:new{
            text = location_favorites_text .. " " .. _("Favorites"),
            width = location_btn_width,
            text_font_size = location_text_size,
            show_parent = touch_menu.show_parent,
            callback = function()
                touch_menu:closeMenu()
                if filemanager and filemanager.collections then
                    filemanager.collections:onShowColl()
                end
                if reader and reader.collections then
                    reader.collections:onShowColl()
                end
            end,
            hold_callback = function()
                touch_menu:closeMenu()
            end
        }

        -- Inline row: [Hystory] [Collections] [Favorites]
        local location_row = HorizontalGroup:new{
            align = "center",
            location_history,
            HorizontalSpan:new{ width = location_gap },
            location_collections,
            HorizontalSpan:new{ width = location_gap },
            location_favorites
        }

        table.insert(location_group, section_span)
        table.insert(location_group, location_row)
    end

    -- ----- search section -----

    local search_group = VerticalGroup:new{ align = "center" }
    if config.show_search and filemanager then
        -- variable
        local search_gap = Screen:scaleBySize(4)
        local search_btn_width = Math.round( (inner_width - search_gap * 2 ) / 3 )
        local search_text_size = 22

        -- Special character
        local search_file_text = "\u{F002}"
        local search_dictionary_text = "\u{F02D}"
        local search_cloud_text = "\u{F0C2}"

        --
        local search_cloud = Button:new{
            text = search_cloud_text .. " " .. _("Cloud"),
            width = search_btn_width,
            text_font_size = search_text_size,
            show_parent = touch_menu.show_parent,
            callback = function()
                touch_menu:closeMenu()
                UIManager:broadcastEvent(Event:new("ShowCloudStorage"))
            end,
            hold_callback = function()
                touch_menu:closeMenu()
                if hasPlugin("opds") then
                    UIManager:broadcastEvent(Event:new("ShowOPDSCatalog"))
                else
                    UIManager:show(ConfirmBox:new{
                        text = _("OPDS plugin not activated."),
                        ok_text = _("Exit"),
                        ok_callback = function() end -- do nothing
                    })
                end
            end
        }

        local search_file = Button:new{
            text = search_file_text .. " " .. _("Search"),
            width = search_btn_width,
            text_font_size = search_text_size,
            show_parent = touch_menu.show_parent,
            callback = function()
                touch_menu:closeMenu()
                UIManager:broadcastEvent(Event:new("ShowFileSearch"))
            end,
            hold_callback = function()
                touch_menu:closeMenu()
                if hasPlugin("calibre") then
                    UIManager:broadcastEvent(Event:new("CalibreSearch"))
                else
                    UIManager:show(ConfirmBox:new{
                        text = _("Calibre plugin not activated."),
                        ok_text = _("Exit"),
                        ok_callback = function() end -- do nothing
                    })
                end
            end
        }

        local search_dictionary = Button:new{
            text = search_dictionary_text .. " " .. _("Dictionary"),
            width = search_btn_width,
            text_font_size = search_text_size,
            show_parent = touch_menu.show_parent,
            callback = function()
                touch_menu:closeMenu()
                UIManager:broadcastEvent(Event:new("ShowDictionaryLookup"))
            end,
            hold_callback = function()
                touch_menu:closeMenu()
                UIManager:broadcastEvent(Event:new("ShowWikipediaLookup"))
            end,
        }

        -- Inline row: [Hystory] [Collections] [Favorites]
        local search_row = HorizontalGroup:new{
            align = "center",
            search_file,
            HorizontalSpan:new{ width = search_gap },
            search_dictionary,
            HorizontalSpan:new{ width = search_gap },
            search_cloud
        }

        table.insert(search_group, section_span)
        table.insert(search_group, search_row)
    end
    -- ----- Info section -----

    local info_group = VerticalGroup:new{ align = "center" }
    if  config.show_info and reader then
        -- variable
        local info_gap = Screen:scaleBySize(4)
        local info_btn_width = Screen:scaleBySize(50)
        local info_txt_width = inner_width - info_btn_width - info_gap
        local info_text_size = 22

        -- Special character
        local info_title_text = "\u{F02D}"
        local info_chapter_text = "\u{F0C9}"
        local info_authors_text = "\u{F040}"
        local info_description_text = "\u{F075}"
        local info_cover_text = "\u{F1C5}"

        -- info state
        local info = {
            curr_page = reader:getCurrentPage()
        }

        -- Create buttons
        local info_title = TextBoxWidget:new{
            text = (reader.doc_props.display_title or reader.props.title or _("Unknown title")),
            width = info_txt_width,
            alignment = "center",
            face = Font:getFace("ffont"),
            bold  = true
        }

        local info_authors = TextBoxWidget:new{
            text = (reader.doc_props.authors or _("Unknown author")),
            width = info_txt_width,
            alignment = "center",
            face = Font:getFace("ffont")
        }

        local info_chapter = TextBoxWidget:new{
            text = (reader.toc:getTocTitleByPage(info.curr_page) or _("Unknown chapter")),
            width = info_txt_width,
            alignment = "center",
            face = Font:getFace("smallffont")
        }

        local info_description = Button:new{
            text = info_description_text,
            width = info_btn_width,
            text_font_size = info_text_size,
            show_parent = touch_menu.show_parent,
            callback = function()
                touch_menu:closeMenu()
                reader.bookinfo:onShowBookDescription(false, reader.document.file)
            end,
            hold_callback = function() end -- placeholder, set below
        }

        --
        local info_column = VerticalGroup:new{
            align = "center",
            info_title,
            info_authors,
            info_chapter
        }
        local info_column1 = VerticalGroup:new{
            align = "center",
            info_description
        }

        -- Inline row: [Authors] [Title]
        local info_row = HorizontalGroup:new{
            align = "center",
            info_column,
            HorizontalSpan:new{ width = info_gap },
            info_column1
        }

        -- thumbnail
        local thumbnail = reader.bookinfo:getCoverImage(reader.document)

        if thumbnail then
            -- calculate thumbnail height to fit text
            local max_h = info_description:getSize().h * 3

            -- resize thumbnail
            local w, h = thumbnail:getWidth(), thumbnail:getHeight()

            if h > max_h then
                w = math.floor(w * max_h / h + 0.5)
                h = max_h
                thumbnail = RenderImage:scaleBlitBuffer(thumbnail, w, h, true)
            end

            local info_thumbnail = CoverButton:new{
                image = thumbnail,
                width = w,
                height = h,
                callback = function()
                    touch_menu:closeMenu()
                    reader.bookinfo:onShowBookCover(reader.document.file)
                end,
            }

            -- recalculate width to fit info_thumbnail
            info_txt_width = inner_width - w - info_btn_width - 2 * info_gap

            for _, widget in ipairs({ info_authors, info_title, info_chapter }) do
                widget.width = info_txt_width
                widget:init()
            end



            -- insert info_thumbnail
            table.insert(info_row, 1, HorizontalSpan:new{ width = info_gap })
            table.insert(info_row, 1, info_thumbnail)
        end

        --
        table.insert(info_group, section_span)
        table.insert(info_group, info_row)
    end

    -- ----- Skim section -----

    local skim_group = VerticalGroup:new{ align = "center" }
    if config.show_skim and reader then
        -- variable
        local skim_gap = Screen:scaleBySize(4)
        local skim_btn_width = Screen:scaleBySize(50)
        local skim_gap2 = Math.round( ( inner_width - 7 * skim_btn_width - 4 * skim_gap ) / 2 )
        local skim_chapter_width = inner_width - 6 * skim_btn_width - 6 * skim_gap
        local skim_progress_width = inner_width - 2 * skim_btn_width - 2 * skim_gap
        local skim_text_size = 16

        -- Special character
        local skim_page_text = "\u{F0F6}"
        local skim_chapter_text = "\u{F0C9}"
        local skim_prev_text = "\u{25C1}"
        local skim_next_text = "\u{25B7}"
        local skim_bookmark_enabled_text = "\u{F02E}"
        local skim_bookmark_disabled_text = "\u{F097}"

        -- skim state
        local skim = {
            curr_page = reader:getCurrentPage(),
            page_count = reader.document:getPageCount()
        }

         local skim_current_page = Button:new{
            text = tostring(skim.curr_page),
            width = skim_btn_width,
            text_font_size = skim_text_size,
            show_parent = touch_menu.show_parent,
            callback = function() end, -- placeholder, set below
            hold_callback = function() end -- placeholder, set below
        }

        local skim_bookmark_toggle = Button:new{
            text_func = function()
                return reader.view.dogear_visible and skim_bookmark_enabled_text or skim_bookmark_disabled_text
            end,
            width = skim_btn_width,
            text_font_size = skim_text_size,
            show_parent = touch_menu.show_parent,
            callback = function() end, -- placeholder, set below
            hold_callback = function() end -- placeholder, set below
        }

        local skim_btn_height = skim_bookmark_toggle:getSize().h

        local skim_progress = ProgressWidget:new{
            width = skim_progress_width,
            height = skim_btn_height,
            percentage = skim.curr_page / skim.page_count,
            ticks = reader.toc:getTocTicksFlattened(),
            tick_width = Size.line.medium,
            last = skim.page_count,
            alt = reader.document.flows,
            initial_pos_marker = true,
        }

        local function updateSkimWidgets()
            if skim.curr_page <= 0 then
                skim.curr_page = 1
            end
            if skim.curr_page > skim.page_count then
                skim.curr_page = skim.page_count
            end
            skim_progress:setPercentage(skim.curr_page / skim.page_count)
            skim_current_page:setText(tostring(skim.curr_page), skim_current_page.width)
            skim_bookmark_toggle:setText(skim_bookmark_toggle:text_func(), skim_bookmark_toggle.width)
            touch_menu:updateItems(1)
        end

        function addOriginToLocationStack()
            -- Only add the page from which we launched the SkimToWidget to the location stack
            if not skim.orig_page_added_to_stack then
                reader.link:addCurrentLocationToStack()
                skim.orig_page_added_to_stack = true
            end
        end

        function goToOrigPage()
            if skim.orig_page_added_to_stack then
                reader.link:onGoBackLink()
                skim.curr_page = reader:getCurrentPage()
                updateSkimWidgets()
                skim.orig_page_added_to_stack = nil
            end
        end

        local function goToPage(page)
            skim.curr_page = page
            addOriginToLocationStack()
            reader:handleEvent(Event:new("GotoPage", skim.curr_page))
            updateSkimWidgets()
        end

        function goToByEvent(event_name)
            addOriginToLocationStack()
            reader:handleEvent(Event:new(event_name, false))
            -- add_current_location_to_stack=false, as we handled it here
            skim.curr_page = reader:getCurrentPage()
            updateSkimWidgets()
        end

        -- Now wire up the real callback
        skim_bookmark_toggle.callback = function()
            goToByEvent("ToggleBookmark")
        end
        skim_bookmark_toggle.hold_callback = function()
            touch_menu:closeMenu()
            goToByEvent("ShowBookmark")
        end

        skim_current_page.callback = function()
            touch_menu:closeMenu()
            goToByEvent("ShowGotoDialog")
        end

        skim_current_page.hold_callback = function()
            goToOrigPage()
        end

        local skim_bookmark_next = Button:new{
            text = skim_next_text .. skim_bookmark_disabled_text,
            width = skim_btn_width,
            text_font_size = skim_text_size,
            show_parent = touch_menu.show_parent,
            callback = function()
                goToByEvent("GotoNextBookmarkFromPage")
            end,
            hold_callback = function()
                goToByEvent("GotoLastBookmark")
            end
        }

        local skim_bookmark_prev = Button:new{
            text = skim_bookmark_disabled_text .. skim_prev_text,
            width = skim_btn_width,
            text_font_size = skim_text_size,
            show_parent = touch_menu.show_parent,
            callback = function()
                goToByEvent("GotoPreviousBookmarkFromPage")
            end,
            hold_callback = function()
                goToByEvent("GotoFirstBookmark")
            end
        }

        local skim_chapter_next = Button:new{
            text = skim_next_text .. skim_chapter_text,
            width = skim_btn_width,
            text_font_size = skim_text_size,
            show_parent = touch_menu.show_parent,
            callback = function()
                local page = reader.toc:getNextChapter(skim.curr_page)
                if page and page >= 1 and page <= skim.page_count then
                    goToPage(page)
                end
            end,
            hold_callback = function()
                goToPage(skim.page_count)
            end
        }

        local skim_chapter_prev = Button:new{
            text = skim_chapter_text .. skim_prev_text,
            width = skim_btn_width,
            text_font_size = skim_text_size,
            show_parent = touch_menu.show_parent,
            callback = function()
                local page = reader.toc:getPreviousChapter(skim.curr_page)
                if page and page >= 1 and page <= skim.page_count then
                    goToPage(page)
                end
            end,
            hold_callback = function()
                goToPage(1)
            end
        }

        local skim_chapter_toggle = Button:new{
            text = skim_chapter_text,
            width = skim_btn_width,
            text_font_size = skim_text_size,
            show_parent = touch_menu.show_parent,
            callback = function()
                touch_menu:closeMenu()
                goToByEvent("ShowToc")
            end,
            hold_callback = function()
                touch_menu:closeMenu()
                goToByEvent("ShowBookMap")
            end
        }

        local skim_page_next = Button:new{
            text = skim_next_text .. skim_page_text,
            width = skim_btn_width,
            text_font_size = skim_text_size,
            show_parent = touch_menu.show_parent,
            callback = function()
                goToPage(skim.curr_page + 1)
            end,
            hold_callback = function()
                goToPage(skim.page_count)
            end
        }

        local skim_page_prev = Button:new{
            text = skim_page_text .. skim_prev_text,
            width = skim_btn_width,
            text_font_size = skim_text_size,
            show_parent = touch_menu.show_parent,
            callback = function()
                goToPage(skim.curr_page - 1)
            end,
            hold_callback = function()
                goToPage(1)
            end
        }

        -- Inline row: [-] [Slider] [+]
        local skim_row1 = HorizontalGroup:new{
            align = "center",
            skim_page_prev,
            HorizontalSpan:new{ width = skim_gap },
            skim_progress,
            HorizontalSpan:new{ width = skim_gap },
            skim_page_next
        }

        -- Inline row: [<] [Chapter] [>] [CurrentPage] [<] [Bookmark] [>]
        local skim_row2 = HorizontalGroup:new{
            align = "center",
            skim_chapter_prev,
            HorizontalSpan:new{ width = skim_gap },
            skim_chapter_toggle,
            HorizontalSpan:new{ width = skim_gap },
            skim_chapter_next,
            HorizontalSpan:new{ width = skim_gap2 },
            skim_current_page,
            HorizontalSpan:new{ width = skim_gap2 },
            skim_bookmark_prev,
            HorizontalSpan:new{ width = skim_gap },
            skim_bookmark_toggle,
            HorizontalSpan:new{ width = skim_gap },
            skim_bookmark_next,
        }

        -- Store progress ref for tap/pan handling
        refs.skim_progress = skim_progress
        refs.skim_state = skim
        refs.goToPage = goToPage

        table.insert(skim_group, section_span)
        table.insert(skim_group, skim_row1)
        table.insert(skim_group, section_span)
        table.insert(skim_group, skim_row2)
    end

    -- ----- Assemble panel -----

    local panel = VerticalGroup:new{
        align = "center",
        VerticalSpan:new{ width = Screen:scaleBySize(12) }
    }

    if num_actions > 0 and config.show_action_visible then
        table.insert(panel, CenterContainer:new{
            dimen = Geom:new{ w = panel_width, h = action_row:getSize().h },
            action_row
        })
    end

    if #frontlight_group > 0 then
        table.insert(panel, frontlight_group)
    end
    if #warmth_group > 0 then
        table.insert(panel, warmth_group)
    end
    if #location_group > 0 then
        table.insert(panel, location_group)
    end
    if #search_group > 0 then
        table.insert(panel, search_group)
    end
    if #info_group > 0 then
        table.insert(panel, info_group)
    end
    if #skim_group > 0 then
        table.insert(panel, skim_group)
    end

    -- Store refs on the touch_menu for gesture handlers
    touch_menu._qs_refs = refs

    return panel
end

-- ============================================================
-- Gesture handler for panel taps/pans
-- ============================================================

local function handlePanelGesture(touch_menu, ges, is_hold)
    local refs = touch_menu._qs_refs
    if not refs then return false end

    -- Check frontlight progress bar (ProgressWidget doesn't handle its own taps)
    if refs.fl_progress and refs.fl_progress.dimen and ges.pos:intersectWith(refs.fl_progress.dimen) then
        local percent = refs.fl_progress:getPercentageFromPosition(ges.pos)
        if percent and refs.setBrightness then
            local brightness = Math.round(percent * refs.fl_state.max)
            refs.setBrightness(brightness)
            return true
        end
    end

    -- Check skim progress bar (ProgressWidget doesn't handle its own taps)
    if refs.skim_progress and refs.skim_progress.dimen and ges.pos:intersectWith(refs.skim_progress.dimen) then
        local percent = refs.skim_progress:getPercentageFromPosition(ges.pos)
        if percent and refs.goToPage then
            local page = Math.round(percent * refs.skim_state.page_count)
            refs.goToPage(page)
            return true
        end
    end

    -- Check buttons
    for _, btn_ref in ipairs(refs.buttons) do
        if btn_ref.widget.dimen and ges.pos:intersectWith(btn_ref.widget.dimen) then
            if is_hold and btn_ref.hold_callback then
                btn_ref.hold_callback()
                return true
            elseif not is_hold and btn_ref.callback then
                btn_ref.callback(touch_menu)
                return true
            elseif not is_hold then
                return true -- disabled button: swallow tap, do nothing
            end
            -- hold with no hold_callback: don't consume, let it fall through
            return false
        end
    end

    return false
end

-- ============================================================
-- Hook TouchMenu to support panel tabs
-- ============================================================

local TouchMenu = require("ui/widget/touchmenu")
local FocusManager = require("ui/widget/focusmanager")
local GestureRange = require("ui/gesturerange")
local datetime = require("datetime")
local BD = require("ui/bidi")

-- Hook init to
local orig_init = TouchMenu.init
    function TouchMenu:init()
        if config.open_on_start then
            self.last_index = 1
        end
        orig_init(self)
        -- Pre-set image.dimen on bar icon buttons so widgetInvert doesn't crash
        -- if a tap arrives before the first paint (nil dimen on IconWidget).
        if self.bar and type(self.bar.icon_widgets) == "table" then
            for _, btn in ipairs(self.bar.icon_widgets) do
                if btn and btn.image and not btn.image.dimen then
                    local ok_sz, sz = pcall(function() return btn.image:getSize() end)
                    if ok_sz and sz then
                        btn.image.dimen = Geom:new{ w = sz.w, h = sz.h }
                    end
                end
            end
        end
        -- Register a screen-wide hold gesture for panel button hold_callback

        -- screen_size may be nil on some devices (e.g. KindleBasic5)
        local sw = (self.screen_size and self.screen_size.w) or Screen:getWidth()
        local sh = (self.screen_size and self.screen_size.h) or Screen:getHeight()

        self.ges_events.HoldCloseAllMenus = {
            GestureRange:new{
                ges = "hold",
                range = Geom:new{ x = 0, y = 0, w = sw, h = sh },
            }
        }
        self.ges_events.PanCloseAllMenus = {
            GestureRange:new{
                ges = "pan",
                range = Geom:new{ x = 0, y = 0, w = sw, h = sh },
            }
        }
        self.ges_events.PanReleaseCloseAllMenus = {
            GestureRange:new{
                ges = "pan_release",
                range = Geom:new{ x = 0, y = 0, w = sw, h = sh },
            }
        }
        self.ges_events.MultiSwipe = {
            GestureRange:new{
                ges = "multiswipe",
                range = Geom:new{ x = 0, y = 0, w = sw, h = sh },
            }
        }
    end

-- Hook updateItems for panel rendering
local orig_updateItems = TouchMenu.updateItems

function TouchMenu:updateItems(target_page, target_item_id)
    if not self.item_table or not self.item_table.panel then
        self._qs_refs = nil -- clear refs when switching away from panel tab
        return orig_updateItems(self, target_page, target_item_id)
    end

    -- Custom panel mode: render the panel widget instead of menu items
    self.item_group:clear()
    self.layout = {}
    table.insert(self.item_group, self.bar)
    table.insert(self.layout, self.bar.icon_widgets)

    -- Build panel (also sets self._qs_refs)
    local panel_fn = self.item_table.panel
    local panel = type(panel_fn) == "function" and panel_fn(self) or panel_fn
    table.insert(self.item_group, panel)

    -- Footer (no pagination, just time/battery)
    table.insert(self.item_group, self.footer_top_margin)
    table.insert(self.item_group, self.footer)
    self.page_info_text:setText("")
    self.page_info_left_chev:showHide(false)
    self.page_info_right_chev:showHide(false)
    self.page_info_left_chev:enableDisable(false)
    self.page_info_right_chev:enableDisable(false)
    self.page_num = 1
    self.page = 1

    -- Update intensity/warmth/time/battery in footer
    local time_info_txt = ""
    local powerd = Device:getPowerDevice()

    if Device:hasFrontlight() then
        local intensity_lvl = powerd:frontlightIntensity()
        time_info_txt = BD.wrap("✺") .. BD.wrap(intensity_lvl .. "%")
        if Device:hasNaturalLight() then
            local warmth_lvl = powerd:frontlightWarmth()
            intensity_lvl = powerd:frontlightIntensity()
            time_info_txt = time_info_txt .. " " .. BD.wrap("⊛") .. BD.wrap(warmth_lvl .. "%")
        end
    end

    time_info_txt = time_info_txt .. " " .. BD.wrap(datetime.secondsToHour(os.time(), G_reader_settings:isTrue("twelve_hour_clock")))

    if Device:hasBattery() then
        local batt_lvl = powerd:getCapacity()
        local batt_symbol = powerd:getBatterySymbol(powerd:isCharged(), powerd:isCharging(), batt_lvl)
        time_info_txt = time_info_txt .. " " .. BD.wrap("⌁") .. BD.wrap(batt_symbol) .. BD.wrap(batt_lvl .. "%")
        if Device:hasAuxBattery() and powerd:isAuxBatteryConnected() then
            local aux_batt_lvl = powerd:getAuxCapacity()
            local aux_batt_symbol = powerd:getBatterySymbol(powerd:isAuxCharged(), powerd:isAuxCharging(), aux_batt_lvl)
            time_info_txt = time_info_txt .. " " .. BD.wrap("+") .. BD.wrap(aux_batt_symbol) ..  BD.wrap(aux_batt_lvl .. "%")
        end
    end

    self.time_info:setText(time_info_txt)

    -- Recalculate dimen
    local old_dimen = self.dimen:copy()
    self.dimen.w = self.width
    self.dimen.h = self.item_group:getSize().h + self.bordersize * 2 + self.padding
    self:moveFocusTo(self.cur_tab, 1, FocusManager.NOT_FOCUS)

    local keep_bg = old_dimen and self.dimen.h >= old_dimen.h
    UIManager:setDirty((self.is_fresh or keep_bg) and self.show_parent or "all", function()
        local refresh_dimen = old_dimen and old_dimen:combine(self.dimen) or self.dimen
        local refresh_type = "ui"
        if self.is_fresh then
            refresh_type = "flashui"
            self.is_fresh = false
        end
        return refresh_type, refresh_dimen
    end)
end

-- Hook onTapCloseAllMenus to intercept taps on panel widgets
local orig_onTapCloseAllMenus = TouchMenu.onTapCloseAllMenus

function TouchMenu:onTapCloseAllMenus(arg, ges_ev)
    if self._qs_refs and self.item_table and self.item_table.panel then
        if handlePanelGesture(self, ges_ev, false) then
            return true
        end
    end
    return orig_onTapCloseAllMenus(self, arg, ges_ev)
end

-- Hook onHoldCloseAllMenus to intercept holds on panel buttons
function TouchMenu:onHoldCloseAllMenus(arg, ges_ev)
    if self._qs_refs and self.item_table and self.item_table.panel then
        handlePanelGesture(self, ges_ev, true)
    end
    -- Holds outside the menu do nothing (don't close it)
    return true
end

-- Hook switchMenuTab to force quick settings tab on menu open
local orig_switchMenuTab = TouchMenu.switchMenuTab

function TouchMenu:switchMenuTab(tab_num)
    orig_switchMenuTab(self, tab_num)
    -- When "open on start" is enabled, always reset last_index to quick settings tab
    if config.open_on_start then
        self.last_index = 1
    end
end

-- Safety guards: onPrevPage / onNextPage crash when self.page is nil in panel mode (no pagination).  Consume silently.
local orig_onPrevPage = TouchMenu.onPrevPage
if orig_onPrevPage then
    function TouchMenu:onPrevPage()
        if self.item_table and self.item_table.panel then
            return true
        end
        return orig_onPrevPage(self)
    end
end

local orig_onNextPage = TouchMenu.onNextPage
if orig_onNextPage then
    function TouchMenu:onNextPage()
        if self.item_table and self.item_table.panel then
            return true
        end
        return orig_onNextPage(self)
    end
end

-- ============================================================
-- Quick Settings tab definition
-- ============================================================

local quick_settings_tab = {
    icon = "quicksettings",
    remember = false,
    panel = createQuickSettingsPanel
}
-- ============================================================
-- Settings menu builder
-- ============================================================

local function buildSettingsMenu()

    -- Action toggle sub-items
    local action_display_names = getActionDisplayNames()
    local action_toggle_items = {
        {
        text = _("Arrange actions"),
        keep_menu_open = true,
        callback = function()
            local SortWidget = require("ui/widget/sortwidget")
            local sort_items = {}
            for _, id in ipairs(config.action_order) do
                if action_defs[id] then
                    table.insert(sort_items, {
                        text = action_display_names[id],
                        orig_item = id,
                        dim = not config.show_actions[id]
                    })
            end
        end

            UIManager:show(SortWidget:new{
                title = _("Arrange actions"),
                item_table = sort_items,
                callback = function()
                    for i, item in ipairs(sort_items) do
                        config.action_order[i] = item.orig_item
                    end
                    saveConfig()
                end
            })
        end
        }
    }

    for _, id in ipairs(config_default.action_order) do
        table.insert(action_toggle_items, {
            text = action_display_names[id],
            checked_func = function() return config.show_actions[id] end,
            callback = function()
                config.show_actions[id] = not config.show_actions[id]
                saveConfig()
            end
        })
    end

    return {
        text = _("Quick settings"),
        sub_item_table = {
            {
                text = _("Show actions controls"),
                checked_func = function() return config.show_action_visible end,
                callback = function()
                    config.show_action_visible = not config.show_action_visible
                    saveConfig()
                end
            },
            {
                text = _("Select actions controls"),
                sub_item_table = action_toggle_items
            },
            {
                text = _("Show actions controls labels"),
                checked_func = function() return config.show_action_label end,
                callback = function()
                    config.show_action_label = not config.show_action_label
                    saveConfig()
                end,
                separator = true
            },
            {
                text = _("Show frontlight controls"),
                checked_func = function() return config.show_frontlight end,
                callback = function()
                    config.show_frontlight = not config.show_frontlight
                    saveConfig()
                end
            },
            {
                text = _("Show warmth controls"),
                checked_func = function() return config.show_warmth end,
                callback = function()
                    config.show_warmth = not config.show_warmth
                    saveConfig()
                end,
                separator = true
            },
            {
                text = _("Show location controls"),
                checked_func = function() return config.show_location end,
                callback = function()
                    config.show_location = not config.show_location
                    saveConfig()
                end
            },
            {
                text = _("Show search controls"),
                checked_func = function() return config.show_search end,
                callback = function()
                    config.show_search = not config.show_search
                    saveConfig()
                end
            },
            {
                text = _("Show info controls"),
                checked_func = function() return config.show_info end,
                callback = function()
                    config.show_info = not config.show_info
                    saveConfig()
                end
            },
            {
                text = _("Show skim controls"),
                checked_func = function() return config.show_skim end,
                callback = function()
                    config.show_skim = not config.show_skim
                    saveConfig()
                end,
                separator = true
            },
            {
                text = _("Always open on this tab"),
                checked_func = function() return config.open_on_start end,
                callback = function()
                    config.open_on_start = not config.open_on_start
                    saveConfig()
                end
            }
        }
    }
end

-- ============================================================
-- Inject tab and settings into both FileManager and Reader menus
-- ============================================================

local FileManagerMenu = require("apps/filemanager/filemanagermenu")
local FileManagerMenuOrder = require("ui/elements/filemanager_menu_order")
local ReaderMenu = require("apps/reader/modules/readermenu")
local ReaderMenuOrder = require("ui/elements/reader_menu_order")

local orig_fm_setUpdateItemTable = FileManagerMenu.setUpdateItemTable

function FileManagerMenu:setUpdateItemTable()
    -- Inject settings
    table.insert(FileManagerMenuOrder.setting, "----------------------------")
    table.insert(FileManagerMenuOrder.setting, "quick_settings_config")
    self.menu_items.quick_settings_config = buildSettingsMenu()
    -- Inject quick_settings_tab
    orig_fm_setUpdateItemTable(self)
    if self.tab_item_table then
        table.insert(self.tab_item_table, 1, quick_settings_tab)
    end
end

local orig_reader_setUpdateItemTable = ReaderMenu.setUpdateItemTable

function ReaderMenu:setUpdateItemTable()
    -- Inject settings
    table.insert(ReaderMenuOrder.setting, "----------------------------")
    table.insert(ReaderMenuOrder.setting, "quick_settings_config")
    self.menu_items.quick_settings_config = buildSettingsMenu()
     -- Inject quick_settings_tab
    orig_reader_setUpdateItemTable(self)
    if self.tab_item_table then
        table.insert(self.tab_item_table, 1, quick_settings_tab)
    end
end
