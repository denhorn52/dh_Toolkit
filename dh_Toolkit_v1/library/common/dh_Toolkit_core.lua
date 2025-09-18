--dh_Toolkit_core.lua
-- version 1.0
-- Author: Dennis R. Horn
-- Date: 2025-09-08

------------------------------------------------------------
-- Copyright (c) 2025 Dennis R. Horn
-- License: GNU General Public License version 3

-- Uses Lokasenna_GUI v2 for widgets and interactivity:
-- https://github.com/jalovatt/Lokasenna_GUI
-- License: GNU General Public License version 3

-- Uses json.lua for encoding/decoding data to/from ext state:
-- https://github.com/rxi/json.lua
-- License: MIT

------------------------------------------------------------
-- DISCLAIMER: This script has been tested on Reaper 6.23 
--   running on Windows 10-x64 with no issues. 
--   The author is not responsible for any loss of data that
--   may result in the event that the script crashes Reaper.

------------------------------------------------------------
-- DESCRIPTION:

-- A module encapsulating of all functionality pertaining to theming and scaling of scripts
-- using the Lokasenna GUI. Also saving and fetching pertinent window_settings. 
-- This includes a GUI Preferences window to change such settings.
-- Preferences window provides an optional option box which
-- may be utilized for external script specific options.

------------------------------------------------------------
--CHANGELOG:

------------------------------------------------------------
-- Requires that Lokasenna_GUI v2 be loaded.

if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end
------------------------------------------------------------

--zztop
--======================================
  --------       DATA       --------
--======================================
-- Items declared local are only used in core.
-- Items prefixed with DHTK are exposed so they can be used by external scripts.
-- Some things exposed only because they're needed by dh_ThemeDesigner.

----------------------------------------
local DHTK = {}
----------------------------------------
DHTK.version = 1
DHTK.EXT_STATE_NAME = "My_Script"

DHTK.MULTIPLE_HEIGHTS = false
DHTK.APP_WIDTH = 640
DHTK.APP_HEIGHT = 400
DHTK.APP_MIN_HEIGHT = 48
DHTK.APP_EXP_HEIGHT = 88
DHTK.PREFS_HEIGHT = 400

-- z-layers used by "Preferences" window.
-- Made public so external script can add other layers by appending to this list.
-- Added layers must be 1-8.
-- Layer 485 - 489 are already available for external scripts.
-- Can add more if necessary.
--DHTK.prefsLayers = {8,9,10,11,12,13,14,15,16,17,18,19,20}

DHTK.PREFS_LAYERS = {485,486,487,488,489,490,491,492,493,494,495,496,497,498,499,500}

-- Store any visible layers before hiding them when Preference window is opened.
DHTK.layers_to_restore = {}

-- Layer 11 is used for "user_themes" display.
-- This layer gets its visibility toggled.
-- Using plural in case may update to list in the future.
local USER_THEMES_DISPLAY_LAYERS = 491

-- Needs to be public for Theme Designer.
DHTK.window_settings = {
  left = 0,
  top = 0,
  scale = "1.00",    
  theme = "Default",
  user_theme = " ",
  is_window_expanded = false, -- This is used for multiple window height scripts.
}

-- Used when scaling app.
local APP_SCALE_FACTORS = {
  "0.75", 
  "1.00",
  "1.25",     
  "1.50", 
  "2.00"
}

local APP_SCALE = 1

-- Populated in getUserThemes. Make public for Theme Designer.
DHTK.USER_THEMES = {}

-- For menubox display. 
-- Populated before element creation (in "Window Settings")
-- Make public for Theme Designer.
DHTK.USER_THEME_NAMES = {}

local dhtks = require "common/dh_Toolkit_shared"
local dhth = require "common/dh_Toolkit_themes"
local json = require "common/json"

--======================================
  --------     FUNCTIONS     --------
--======================================
--zzsettings  
------------------------------
----      SETTINGS      ----
------------------------------
-- Get saved window settings --
-- If no saved settings will use defaults.

local function getWindowSettings()

    local section_name = DHTK.EXT_STATE_NAME

    if reaper.HasExtState(section_name, "window_settings") then

        local json_string = reaper.GetExtState(section_name, "window_settings")
        --dh_log("json_string in dh_Toolkit_prefs getWindowSettings is\n " .. json_string  .. "\n")
        
        local saved_settings = json.decode(json_string)
        if saved_settings.left then DHTK.window_settings.left = saved_settings.left end
        if saved_settings.top then DHTK.window_settings.top = saved_settings.top end
        --dh_log("> APP_SCALE_FACTORS is: " .. tostring(APP_SCALE_FACTORS[1]))
        
        
        if saved_settings.scale then
            for i, v in ipairs(APP_SCALE_FACTORS) do
                if saved_settings.scale == v then
                    DHTK.window_settings.scale = saved_settings.scale
                    APP_SCALE = tonumber(v)
                    break
                end
            end
        end

        -- If App uses changing window heights get state.
        if saved_settings.is_window_expanded then 
            DHTK.window_settings.is_window_expanded = saved_settings.is_window_expanded 
        end
        
        if saved_settings.theme then DHTK.window_settings.theme = saved_settings.theme end
        if saved_settings.user_theme then DHTK.window_settings.user_theme = saved_settings.user_theme end

    end
end

function DHTK.saveWindowSettings()

    local section_name = DHTK.EXT_STATE_NAME

	-- Save window settings --
	local _, cur_x, cur_y = gfx.dock(-1, 0, 0, 0, 0)
	DHTK.window_settings.left = cur_x
	DHTK.window_settings.top = cur_y

    local json_string = json.encode(DHTK.window_settings)
	--dh_log("json_string at exit is\n " .. json_string  .. "\n")
	reaper.SetExtState(section_name, 'window_settings', json_string, true)

    -- No longer need json_string. Maybe unnecessary as it is local.    
	json_string = nil

end 

----------------------------
----      THEMES      ----
----------------------------
--zzthemes  
--  Fetch user themes.
-- Stored in dh_Toolkit ext state so all scripts have access.

local function getUserThemes()
    --GUI.Msg("**** in getUserThemes ****")         
    if reaper.HasExtState("dh_Toolkit", "user-themes") then
    
        json_string = reaper.GetExtState("dh_Toolkit", "user-themes")
        
        fetched_themes = json.decode(json_string)
        
        if type(fetched_themes) == "table" and
            dhtks.hash_table_length(fetched_themes) > 0 then
            DHTK.USER_THEMES = fetched_themes
          
            for name, _ in pairs(DHTK.USER_THEMES) do
                table.insert(DHTK.USER_THEME_NAMES, name)
                table.sort(DHTK.USER_THEME_NAMES)
            end
                   
        end
        
    end
                  
    if DHTK.window_settings.theme == "User" then

        -- Should set to user_theme if exists.
        if not DHTK.USER_THEMES[DHTK.window_settings.user_theme] then
            DHTK.window_settings.theme = "Default"
            reaper.MB("User theme: " .. DHTK.window_settings.user_theme .. " : not found!\nLoading Default.", "Whoops!", 0)
            dhth.set_theme(dhth.DH_THEMES["Default"], false)
        else
            -- USER THEME --
            dhth.set_theme(DHTK.USER_THEMES[DHTK.window_settings.user_theme], false)
        end
    else
        if not dhth.DH_THEMES[DHTK.window_settings.theme] then
            DHTK.window_settings.theme = "Default"
        end    
        -- DH THEME --
        dhth.set_theme(dhth.DH_THEMES[DHTK.window_settings.theme], false)
    end

end

local function setTheme()

    -- # Get theme name from menubox.
    local theme_index, theme_name = GUI.Val("mbx_dhThemes")
    
    -- # If "User" then get user theme name from menubox.
    if theme_name == "User" then
    
        local _, user_theme_name  = GUI.Val("mbx_UserThemes")

        -- # Check if user theme exists.

        -- Shouldn't have to verify, but doesn't hurt.
        if not DHTK.USER_THEMES[user_theme_name] then
            reaper.MB("User theme: " .. user_theme_name .. " : not found!", "Whoops!", 0)
            return
        else
            -- User theme exists.
            
            DHTK.window_settings.theme = theme_name
            DHTK.window_settings.user_theme = user_theme_name
            GUI.elms.lbl_CurrDhTheme.text = DHTK.window_settings.theme
            GUI.elms.lbl_CurrUserTheme.text = DHTK.window_settings.user_theme
            dhth.set_theme(DHTK.USER_THEMES[user_theme_name], true)
        end
    else
        -- Native theme, not user.
        
        DHTK.window_settings.theme = theme_name
        GUI.elms.lbl_CurrDhTheme.text = DHTK.window_settings.theme
        GUI.elms.lbl_CurrUserTheme.text = ""
        dhth.set_theme(dhth.DH_THEMES[theme_name], true)
    end

    -- Necessary!
    GUI.update_elms_list(true)
	
	GUI.redraw_z[0] = true

end --<setTheme>

----------------------------------
------   SCALE  FUNCTIONS   ------
----------------------------------
--zzscale
-- Normalize metric - converts scaled value to 1.00 scale.
-- @param num: number - element metric to be normalized.
-- @param scale: number - current scale of GUI. 
-- returns normalized metric.

-- Appears no longer using.
local function normalize_metric(num, scale)
  return math.floor((num / prevscale) + 0.5)
end

-- Scale metric
-- @param num: number - element metric to be scaled.
-- @param scale: number - new scale of GUI.
-- returns scaled metric.

function DHTK.scale_metric(num, scale)
    return math.floor((num * scale) + 0.5)
end

-- Normalize and Scale metric
-- Previously scaled number must be normalized before it is rescaled.
-- @param num: number  current scaled value of a metric.
-- @param prevscale: number - current scale of GUI.
-- @param newscale: number - new scale of GUI.

local function norm_scale_metric(num, prevscale, newscale)
    -- return to 1.00 scale.
    local m = math.floor((num / prevscale) + 0.5)
    -- calculate new value.
    return math.floor((m * newscale) + 0.5)
end

----------------------------------
------   SCALE  ELEMENTS   ------
----------------------------------

local ELEMENT_METRICS = {'x', 'y', 'w', 'h', 'tab_w', 'tab_h', 'round', 'pad', 'opt_size', 'txt_indent', 'txt_pad', 
   'border_width', 'radius', 'thk', 'scrollbar_width','pad_top_val',}

-- Scale elements.
-- Iterates GUI elements and rescales them to new scale.
-- It does this by scaling all element fields that left, top, width, or height. 
-- @param prevscale: number - current scale of GUI.
-- @param newscale: number - new scale of GUI.

function DHTK.scale_elements(prevscale, newscale)

    for elmname, _ in pairs(GUI.elms) do
        for _, metric in ipairs(ELEMENT_METRICS) do
        
            if GUI.elms[elmname][metric] then
                GUI.elms[elmname][metric] = norm_scale_metric(GUI.elms[elmname][metric], prevscale, newscale)
            end

        end
        --if elmname == "menu_Tab3_Toolkit" then
        --    GUI.Msg("**** scale_elements: menu_Tab3_Toolkit w : " .. tostring(GUI.elms.menu_Tab3_Toolkit.w))
        --end        
    end
    
end

----------------------------------
------     SCALE  APP    ------
----------------------------------
--zzscale  
local function scaleApp()
    
    -- # Set APP_SCALE
    
    local prevscale = APP_SCALE
    
    local _, scale = GUI.Val("mbx_Scale")
    DHTK.window_settings.scale = scale
    GUI.elms.lbl_CurrScale.text = DHTK.window_settings.scale
    
    APP_SCALE = tonumber(scale)
    
    --dh_log("> scaleApp new APP_SCALE is: " .. tostring(APP_SCALE))
    
    -- # Update fonts
    dhth.set_scaled_fonts(scale)
    
    -- # Set Window METRICS 
    
    -- Scale window width and height.
     if DHTK.MULTIPLE_HEIGHTS then
        -- Multiple window heights.
        GUI.w = DHTK.scale_metric(DHTK.APP_WIDTH, APP_SCALE)
        GUI.h = norm_scale_metric(GUI.h, prevscale, APP_SCALE)
        
        -- The main script will need these.
        DHTK.s_APP_MIN_HEIGHT = DHTK.scale_metric(DHTK.APP_MIN_HEIGHT, APP_SCALE)
        DHTK.s_APP_EXP_HEIGHT = DHTK.scale_metric(DHTK.APP_EXP_HEIGHT, APP_SCALE)
        DHTK.s_PREFS_HEIGHT = DHTK.scale_metric(DHTK.PREFS_HEIGHT, APP_SCALE)
    
    else
        -- Non-changing window height.
        GUI.w = DHTK.scale_metric(DHTK.APP_WIDTH, APP_SCALE)
        GUI.h = DHTK.scale_metric(DHTK.APP_HEIGHT, APP_SCALE)
    end
    
    --dh_log("> scaleApp new GUI.w is: " .. tostring(GUI.w))
    --dh_log("> scaleApp prevscale is: " .. tostring(prevscale))
    --dh_log("> scaleApp APP_SCALE is: " .. tostring(APP_SCALE))
        
    -- # Scale elements
    DHTK.scale_elements(prevscale, APP_SCALE)
    
    -- Do this if calling GUI.Init() because
    -- GUI.Init() converts colors back to 0..1 format.
    
    -- # Convert colors to integer (0..255) format.
    for name, col in pairs(GUI.colors) do 
        col[1] = math.floor((col[1] * 255) + 0.5)
        col[2] = math.floor((col[2] * 255) + 0.5)
        col[3] = math.floor((col[3] * 255) + 0.5)
        col[4] = math.floor((col[4] * 255) + 0.5)
    end
      
    GUI.Init()
    
   --[==[    
        GUI.Init() calls: 
          gfx.init(GUI.name, GUI.w, GUI.h, GUI.dock or 0, GUI.x, GUI.y)
          
          Converts color presets from 0..255 to 0..1          
        
          GUI.update_elms_list(true) iterates GUI.elms
            If true calls GUI.elms[key]:init()
            
        If calling GUI.Init after script is open 
          we need colors with integers 0..255 for reinitialization.
          
        Elements draw themselves to a buffer once on :init()
          and then just blit/rotate/etc as needed afterward.
          
        GUI.Main is run on every update loop of the GUI script; anything you would put
        inside a reaper.defer() loop should go here. (The function name doesn't matter)
            
        GUI.Main <main loop> calls:
           GUI.Main_Update_State() checks if script window w or h changed:
             Yes: updates GUI.cur_w and GUI.cur_h, sets GUI.resized = true,
               and calls GUI.onresize().
             No: sets GUI.resized = false
             
           GUI.Main_Update_Elms()
             Iterates GUI.elms_list in reverse z-order updating each elm,
               *** but only if they are not hidden or frozen.
               It doesn't initialize them.
           
           --****  
           Runs user function <dhMain> if defined.
             ??? Here I am calling if GUI.resized then gfx.init() and GUI.redraw_z[0] = true
           
           GUI.update_elms_list()
           
           GUI.Main_Draw()
             if need_redraw or global_redraw then 
               iterates GUI.elms_list from highest z to lowest
               calls GUI.elms[elm]:draw(), but only for non-hidden elms.  
             gfx.update()
             
    --]==]
    
    -- Need to redraw everything, even hidden layers.
         
    for key, elmslist in pairs(GUI.elms_list) do
        if type(elmslist) == "table" then
            for idx, elmval in ipairs(elmslist) do
                --dh_log("> GUI.elms.list zkey is: " .. zkey .. " : elmval is: " .. elmval .. "\n")
                --GUI.elms[elmval]:init()
                GUI.elms[elmval]:redraw() 
            end
        end
    end
    
    GUI.resized = true
                     
end --<scaleApp>

----------------------------------------
--[[ DEV NOTE: 
     --I'm using layers 9-20 for Preferences Window.
     I'm using layers 489-500 for Preferences Window.
     May want to reserve a few more just in case.
     The following two functions are to hide and show them.
     These need to correspond to z-layers of element definitions.
--]]
    
local function hidePrefsWindow()
    --GUI.Msg("**** in hidePrefsWindow ****")         
    -- Hide Preferences.
    for _, lyr in ipairs(DHTK.PREFS_LAYERS) do
        --GUI.Msg("> hide lyr : " .. tostring(lyr))         
        GUI.elms_hide[lyr] = true
    end	

    if GUI.elms.mbx_UserThemes.visibility == "visible" then
        GUI.elms_hide[USER_THEMES_DISPLAY_LAYERS] = false
    else
        GUI.elms_hide[USER_THEMES_DISPLAY_LAYERS] = true
    end
    
	if DHTK.MULTIPLE_HEIGHTS then
	    if DHTK.window_settings.is_window_expanded then
		    GUI.h = DHTK.s_APP_EXP_HEIGHT
	    else 
		    GUI.h = DHTK.s_APP_MIN_HEIGHT
	    end
	    GUI.resized = true
	end        

    -- Restore saved.
    for _, lyr in ipairs(DHTK.layers_to_restore) do
        --GUI.Msg("> show lyr : " .. tostring(lyr))             
        GUI.elms_hide[lyr] = false
        GUI.redraw_z[lyr] = true
    end

end

function DHTK.showPrefsWindow()
    --GUI.Msg("** core showPrefsWindow **")
    
    -- Store any visible layers, and then hide them.

    DHTK.layers_to_restore = {}
    
    -- GUI.elms_hide holds z.
    -- GUI.elms_list key is layer, val is list of elm names.

    for z, _ in pairs(GUI.elms_list) do
        if not GUI.elms_hide[z] then
            --GUI.Msg("> showPrefsWindow layers_to_restore : " .. tostring(z))          
            table.insert(DHTK.layers_to_restore, z)
            GUI.elms_hide[z] = true
        end
    end   
     
    --DHTK.layers_to_restore = layers_to_restore
    
    -- Show Preferences.

    for _, lyr in ipairs(DHTK.PREFS_LAYERS) do
        GUI.elms_hide[lyr] = false
    end	
    
    if GUI.elms.mbx_UserThemes.visibility == "visible" then
        GUI.elms_hide[USER_THEMES_DISPLAY_LAYERS] = false
    else
        GUI.elms_hide[USER_THEMES_DISPLAY_LAYERS] = true
    end
    
end


--======================================
  --------      ELEMENTS      --------
--======================================
--zzelem
--[[
    Z LAYER ASSIGNMENTS
    Not absolutely necessary to separate. 
    # On own layer because so it can redraw separately.
    Next is necessary for visibility toggled layers.
    #v designates elements that visibility gets toggled.
    
    This is the set of layers that make up the Preferences window.
    Used to show/hide Preferences window.
    It includes options layer 9 that can be used by external scripts.
    If external script uses additional layers then those layers need to be appended to set.
    --DHTK.prefsLayers = {8,9,10,12,13,14,15,16,17,18,19,20}
    DHTK.PREFS_LAYERS = {488,489,490,491,492,493,494,495,496,497,498,499,500}
    
    This is the layer that gets visibility toggled; currently 491.
    USER_THEMES_DISPLAY_LAYERS = 491
    
    Layers 485 - 489 reserved for external script use for elements to be added to Preferences window.

    Element                 Layer  was
       
    frm_Preferences          500  --20
    lbl_Preferences          499  --19
    btn_ClosePrefs           499  --19

    lbl_ScaleSectionTitle    499  --19
    pnl_ScaleSection         498  --18
    lbl_CurrScaleTitle       497  --17
    # lbl_CurrScale          496  --16 
    # mbx_Scale              495  --15 
    # btn_ScaleApp           494  --14 

    lbl_ThemesSectionTitle   499  --19
    pnl_ThemesSection        498  --18
    lbl_CurrDhThemeTitle     497  --17
    # mbx_dhThemes           493  --13 
    lbl_CurrUserThemeTitle   497  --17
    # lbl_CurrDhTheme        492  --12 
    #v lbl_CurrUserTheme     491  --11
    #v mbx_UserThemes        491  --11 
    # btn_SetTheme           490  --10 
    
    -- For external script use.
    lbl_Options              499  --19
    chkl_Options             489  -- 9
--]]

local function createPrefsWindow()

-- !!! Changed indent for elements definitions for ease of maintenance.

------------------------------------
------  Preferences Window  ------
------------------------------------

GUI.New("frm_Preferences", "dh_Panel", {
    z = 500, --20,
    x = 0,
    y = 0,
    w = DHTK.APP_WIDTH,
    h = DHTK.PREFS_HEIGHT,
    shadow = false,
    border_width = 2,
    radius = 0,
    col_border = "elm_frame", -- default
    col_bg = "wnd_bg",        -- default
    col_text = "txt"          -- default

})

GUI.New("lbl_Preferences", "dh_Label", {
    z = 499, --19,
    x = 16, 
    y = 8, 
    text = "Preferences:",
    shadow = false,
    font = "sans24",
})

GUI.New("btn_ClosePrefs", "dh_Button", {
    z = 499, --19,
    x = 496, 
    y = 12, 
    w = 80, 
    h = 28, 
    text = "Close",
    font = "sans24",
    col_bg = "btn_face", --"panel_bg",
    col_border = "btn_outline", --"panel_border",
    col_text = "btn_txt",
    --func = btn_ClosePrefsClick,
    func = hidePrefsWindow,
})

------------------------------------
------    Scale Section   ------
------------------------------------
--zzscale   

GUI.New("lbl_ScaleSectionTitle", "dh_Label", { 
    z = 499, --18,
    x = 20, 
    y = 32, 
    text = "App Scale",
    shadow = false,
    font = "sans22",
})

GUI.New("pnl_ScaleSection", "dh_Panel", {
    z = 498, --18,
    x = 16,
    y = 56,
    w = 152,
    h = 236,
    shadow = false,
    fill = true,
    border_width = 1, 
    radius = 0, 
    col_border = "panel_border",	
    col_bg = "panel_bg",
    col_text = "panel_txt",        
})
----------------------------------------
GUI.New("lbl_CurrScaleTitle", "dh_Label", {
    z = 497, --17,
    x = 24, 
	y = 60, 
    text = "Current Scale",
    shadow = false,
    col_bg = "panel_bg",
    col_text = "panel_txt",    
    font = "sans22",
})

GUI.New("lbl_CurrScale", "dh_Label", {
    z = 496, --16,
    x = 40, 
	y = 80, 
    text = "1.00",
    shadow = true,
    col_bg = "panel_bg",
    col_text = "panel_txt",        
    font = "sans24",
})

GUI.New("mbx_Scale", "dh_Menubox", {
    z = 495, --15,
    x = 24, 
    y = 202, 
    w = 136, 
    h = 32,  
    text = "",
    noarrow = false,
    optarray = APP_SCALE_FACTORS,
    curr_opt = 1,
    align = 0,
    font_text = "sans24",
    col_text = "elm_txt",
})

GUI.New("btn_ScaleApp", "dh_Button", {
    z = 494, --14,
    x = 44, 
    y = 248, 
    w = 96, 
    h = 32,  
    text = "Scale App",
    font = "sans22",
    col_bg = "btn_face",
    col_text = "btn_txt",    

    func = scaleApp,
    --params = false   -- Only one window height
})

------------------------------------
------   Themes Section   ------ 
------------------------------------
--zztheme 
   
GUI.New("lbl_ThemesSectionTitle", "dh_Label", { 
    z = 499, --18,
    x = 180, 
    y = 32,
    text = "Themes",
    shadow = false,
    font = "sans22",
})
--zz0504
GUI.New("pnl_ThemesSection", "dh_Panel", {
    z = 498, --18,
    x = 176,
    y = 56,
    w = 184,
    h = 236,
    shadow = false,
    fill = true,
    border_width = 1, 
    radius = 0, 
    col_border = "panel_border",	
    col_bg = "panel_bg", 
})
----------------------------------------
GUI.New("lbl_CurrDhThemeTitle", "dh_Label", {
    z = 497, --17,
    x = 184, 
	y = 60,
    text = "Current dh_theme:",
    shadow = false,
    col_bg = "panel_bg",
    col_text = "panel_txt",    
    font = "sans22",
})

GUI.New("lbl_CurrDhTheme", "dh_Label", {
    z = 492, --12,
    x = 196, 
	y = 82,
    text = "Default",
    shadow = true,
    col_bg = "panel_bg",
    col_text = "panel_txt",    
    font = "sans24",
})

GUI.New("mbx_dhThemes", "dh_Menubox", {
    z = 493, --13,
    x = 184, 
    y = 110, 
    w = 168, 
    h = 32,  
    text = "",
    noarrow = false,
    optarray = dhth.DH_THEME_NAMES,
    curr_opt = 1,
    align = 0,
    font_text = "sans22",
    col_text = "elm_txt"
})

GUI.New("lbl_CurrUserThemeTitle", "dh_Label", {
    z = 497, --17,
    x = 184, 
	y = 152,
    text = "Current User theme:",
    shadow = false,
    col_bg = "panel_bg",
    col_text = "panel_txt",    
    font = "sans22",
})
--zzz
GUI.New("lbl_CurrUserTheme", "dh_Label", {
    z = 491, --11,
    x = 196, 
	y = 174,
    text = "<None>",
    shadow = true,
    col_bg = "panel_bg",
    col_text = "panel_txt",    
    font = "sans24",
})

GUI.New("mbx_UserThemes", "dh_Menubox", {
    z = 491, --11,
    x = 184, 
    y = 202, 
    w = 168, 
    h = 32, 
    text = "",
    noarrow = false,
    optarray = DHTK.USER_THEME_NAMES,
    curr_opt = 0, -- Set this in script init.
    align = 0,
    font_text = "sans24",
    col_text = "elm_txt",
    visibility = "hidden"
})

GUI.New("btn_SetTheme", "dh_Button", {
    z = 490, --10,
    x = 220, 
    y = 248, 
    w = 96, 
    h = 32, 
    text = "Set Theme",
    font = "sans22",
    col_bg = "btn_face",
    col_text = "btn_txt",    
    func = setTheme
})

------------------------------------
------   Optional Section   ------ 
------------------------------------
--zzoptions
--[[ DEV NOTE: 
     !!! Define optional section in Main Script.
     Can use this as a template. 

GUI.New("lbl_Options", "dh_Label", {
    z = 499, --19, 
    x = 372, 
    y = 32, 
    text = "Options", 
    font = "sans22",
})

GUI.New("chkl_Options",	"dh_Checklist",	{
	z = 489, --9, 
    x = 368, 	
    y = 56,  
    w = 220, 
    h = 236,
	caption = "",
	--shadow = false,
	--opts = template_options_names, -- defined in "my data"
	opts= {},
	dir = "v", 
	pad = 8,	
    
	frame = true,
    field = false,
    border_width = 0, 
    radius = 0,
        
    col_border = "panel_border",	
	--col_cap_bg = "panel_bg",  -- caption bg color
	col_text = "txt", 
	col_field = "panel_bg",
	font_caption = "sans22",
	font_text = "sans24",	
    opt_size = 16,
})

--]]

-- Indent back to normal indent.
    ------------------------------------
    ------  Initialize Elements  ------
    ------------------------------------

    -- Set preferences options.
    GUI.Val("mbx_Scale", dhtks.table_index_from_value(APP_SCALE_FACTORS, DHTK.window_settings.scale))
    GUI.Val("lbl_CurrScale", DHTK.window_settings.scale)
    
    GUI.Val("mbx_dhThemes", dhtks.table_index_from_value(dhth.DH_THEME_NAMES, DHTK.window_settings.theme))
    GUI.Val("lbl_CurrDhTheme", DHTK.window_settings.theme)
    --dh_log("init elms window_settings.theme is: " .. DHTK.window_settings.theme) 
    
    if DHTK.window_settings.theme == "User" then
        if DHTK.window_settings.user_theme then
            GUI.Val("mbx_UserThemes", dhtks.table_index_from_value(DHTK.USER_THEME_NAMES, DHTK.window_settings.user_theme))
            GUI.Val("lbl_CurrUserTheme", DHTK.window_settings.user_theme)  
            GUI.elms.mbx_UserThemes.visibility = "visible"
            GUI.elms_hide[USER_THEMES_DISPLAY_LAYERS] = false
        end    
    else
        GUI.Val("lbl_CurrUserTheme", "<None>")  
        GUI.elms.mbx_UserThemes.visibility = "hidden"
        GUI.elms_hide[USER_THEMES_DISPLAY_LAYERS] = true
    end

    hidePrefsWindow()

    ----------------------------------
    ------   Method Overrides  ------
    ----------------------------------
    --zzoverrides
    -- !!! Overrides can not be local. They will be added to GUI.

    function GUI.elms.mbx_dhThemes:onmouseup()
        -- Run the element's normal method
        GUI.dh_Menubox.onmouseup(self)
    
    	-- Add our code.
	
    	if self.optarray[self.curr_opt] == "User" then
    	    GUI.elms.mbx_UserThemes.visibility = "visible"
            GUI.elms_hide[USER_THEMES_DISPLAY_LAYERS] = false
    	else
    	    GUI.elms.mbx_UserThemes.visibility = "hidden"
    	    GUI.elms_hide[USER_THEMES_DISPLAY_LAYERS] = true
    	    GUI.Val("lbl_CurrUserTheme", "<None>")
    	    GUI.redraw_z[USER_THEMES_DISPLAY_LAYERS] = true
     	end
    end
    
--[[ Should only update lbl_CurrUserTheme when setting theme!
    function GUI.elms.mbx_UserThemes:onmouseup()
        -- Run the element's normal method
        GUI.dh_Menubox.onmouseup(self)
    
    	-- Add our code
        GUI.Val("lbl_CurrUserTheme", self.optarray[self.curr_opt])
    
    end
--]]

end --<createPrefsWindow> 

--======================================
  --------    INIT CODE    --------
--======================================

local function setup_window()
    GUI.x = DHTK.window_settings.left
    GUI.y = DHTK.window_settings.top
    GUI.w = DHTK.scale_metric(DHTK.APP_WIDTH, APP_SCALE)    
   
    if DHTK.MULTIPLE_HEIGHTS then
        if DHTK.window_settings.is_window_expanded == false then
            GUI.h = DHTK.APP_MIN_HEIGHT
        else
            GUI.h = DHTK.APP_EXP_HEIGHT
        end
        
        -- The main script will need these.
        DHTK.s_APP_MIN_HEIGHT = DHTK.scale_metric(DHTK.APP_MIN_HEIGHT, APP_SCALE)
        DHTK.s_APP_EXP_HEIGHT = DHTK.scale_metric(DHTK.APP_EXP_HEIGHT, APP_SCALE)
        DHTK.s_PREFS_HEIGHT = DHTK.scale_metric(DHTK.PREFS_HEIGHT, APP_SCALE)
                 
    else
        DHTK.window_settings.is_window_expanded = nil
        GUI.h = DHTK.APP_HEIGHT
    end
    GUI.h = DHTK.scale_metric(GUI.h, APP_SCALE)
    
    --dh_log("**** setup_window APP_SCALE is : " .. tostring(APP_SCALE))
    --dh_log("**** setup_window GUI.h is : " .. tostring(GUI.h))
    --dh_log("**** setup_window APP_HEIGHT is : " .. tostring(APP_HEIGHT))
    --dh_log("**** setup_window DHTK.APP_HEIGHT is : " .. tostring(DHTK.APP_HEIGHT))
end

--zzinit
-- This needs to be called in Main script after defining window sizes. 

function DHTK.init_DHTK()
    --GUI.Msg("**** in DHTK.init_DHTK ****")
    
    getWindowSettings()
    getUserThemes()
    createPrefsWindow()
    setup_window()
    
    -- Used for development.
    --if DHTK.window_settings.theme ~= "User" then
    --    GUI.elms_hide[USER_THEMES_DISPLAY_LAYERS] = true
    --end
end

function DHTK.init_scale_elms()
    --  Initialize GUI Elements
    DHTK.scale_elements(1, APP_SCALE)
    dhth.set_scaled_fonts(DHTK.window_settings.scale, false)

end


----------------------------------------
return DHTK
----------------------------------------

--zzend