--dh_Toolkit_core.lua
-- version 1.0
-- Author: Dennis R. Horn
-- Date: 2025-04-20

---------------------------------------------
-- Copyright (c) 2025 Dennis R. Horn
-- License: GNU General Public License version 3

-- Uses Lokasenna_GUI v2 for widgets and interactivity:
-- https://github.com/jalovatt/Lokasenna_GUI

-- Uses json.lua for encoding/decoding data to/from ext state:
-- https://github.com/rxi/json.lua

---------------------------------------------
-- DISCLAIMER: This script has been tested on Reaper 6.23 
--   running on Windows 10-x64 with no issues. 
--   The author is not responsible for any loss of data that
--   may result in the event that the script crashes Reaper.

---------------------------------------------
-- DESCRIPTION:

-- A module encapsulating of all functionality pertaining to
-- window_settings, theming and scaling of app.
-- This includes a Preferences window to change such settings.
-- Preferences window provides an optional option box which
-- may be utilized for script specific options.

--zztop
--======================================
  --------       DATA       --------
--======================================
-- Should be able to declare local that which is only used in core.
-- Prefix with DHTK that which needs to be exposed.
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
--zz0425
-- z-layers used by "Preferences" window.
-- This will be used to show / hide "Preferences" window.
-- Made public so Main script can add other layers.
DHTK.prefsLayers = {9,10,11,12,13,14,15,16,17,18,19,20}

-- Layer 9 is used for "user_themes" display.
local USER_THEMES_DISPLAY_LAYERS = 9

-- Needs to be public for Theme Designer.
DHTK.window_settings = {
  left = 0,
  top = 0,
  scale = "1.00",    
  theme = "Default",
  user_theme = " ",
  -- This is used in dh_ArrangeViews script.
  is_window_expanded = false,
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

    -- No longer need json_string    
	json_string = nil

end 

----------------------------
----      THEMES      ----
----------------------------
--zzthemes  
--  Fetch user themes  --
-- Stored in dh_Toolkit ext state so all scripts have access.

local function getUserThemes()

    if reaper.HasExtState("dh_Toolkit", "user-themes") then
    
        json_string = reaper.GetExtState("dh_Toolkit", "user-themes")
        
        fetched_themes = json.decode(json_string)
        
        if type(fetched_themes) == "table" and
            dhtks.keyed_table_length(fetched_themes) > 0 then
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

    -- # Get theme name from menubox --
    local theme_index, theme_name = GUI.Val("mbx_dhThemes")
    
    -- # If "User" then get user theme name from menubox --
    if theme_name == "User" then
    
        local _, user_theme_name  = GUI.Val("mbx_UserThemes")

        -- # Check if user theme exists --

        -- Shouldn't have to verify, but doesn't hurt.
        if not DHTK.USER_THEMES[user_theme_name] then
            reaper.MB("User theme: " .. user_theme_name .. " : not found!", "Whoops!", 0)
            return
        else
            -- User theme exists.
            
            DHTK.window_settings.theme = theme_name
            DHTK.window_settings.user_theme = user_theme_name
            GUI.elms.lbl_CurrDhTheme.caption = DHTK.window_settings.theme
            GUI.elms.lbl_CurrUserTheme.caption = DHTK.window_settings.user_theme
            dhth.set_theme(DHTK.USER_THEMES[user_theme_name], true)
        end
    else
        -- Native theme, not user.
        
        DHTK.window_settings.theme = theme_name
        GUI.elms.lbl_CurrDhTheme.caption = DHTK.window_settings.theme
        GUI.elms.lbl_CurrUserTheme.caption = ""
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
    -- return to 1.00 scale --
    local m = math.floor((num / prevscale) + 0.5)
    -- calculate new value --
    return math.floor((m * newscale) + 0.5)
end

----------------------------------
------   SCALE  ELEMENTS   ------
----------------------------------
-- Scale elements.
-- Iterates GUI elements and rescales them to new scale.
-- @param prevscale: number - current scale of GUI.
-- @param newscale: number - new scale of GUI.

function DHTK.scale_elements(prevscale, newscale)
    
    for elmname, _ in pairs(GUI.elms) do
        -- Will need to check each metric.
        if GUI.elms[elmname].x then 
            GUI.elms[elmname].x = norm_scale_metric(GUI.elms[elmname].x, prevscale, newscale)
        end
        if GUI.elms[elmname].y then 
            GUI.elms[elmname].y = norm_scale_metric(GUI.elms[elmname].y, prevscale, newscale)
        end
        if GUI.elms[elmname].w then 
            GUI.elms[elmname].w = norm_scale_metric(GUI.elms[elmname].w, prevscale, newscale)
        end
        if GUI.elms[elmname].h then 
            GUI.elms[elmname].h = norm_scale_metric(GUI.elms[elmname].h, prevscale, newscale)
        end
        if GUI.elms[elmname].tab_h then 
            GUI.elms[elmname].tab_h = norm_scale_metric(GUI.elms[elmname].tab_h, prevscale, newscale)
        end        
        if GUI.elms[elmname].round then 
            GUI.elms[elmname].round = norm_scale_metric(GUI.elms[elmname].round, prevscale, newscale)
        end
        if GUI.elms[elmname].pad then 
            GUI.elms[elmname].pad = norm_scale_metric(GUI.elms[elmname].pad, prevscale, newscale)
        end
        if GUI.elms[elmname].opt_size then 
            GUI.elms[elmname].opt_size = norm_scale_metric(GUI.elms[elmname].opt_size, prevscale, newscale)
        end
        if GUI.elms[elmname].txt_indent then 
            GUI.elms[elmname].txt_indent = norm_scale_metric(GUI.elms[elmname].txt_indent, prevscale, newscale)
        end
        if GUI.elms[elmname].txt_pad then 
            GUI.elms[elmname].txt_pad = norm_scale_metric(GUI.elms[elmname].txt_pad, prevscale, newscale)
        end
        if GUI.elms[elmname].border_width then 
            GUI.elms[elmname].border_width = norm_scale_metric(GUI.elms[elmname].border_width, prevscale, newscale)
        end
        if GUI.elms[elmname].radius then 
            GUI.elms[elmname].radius = norm_scale_metric(GUI.elms[elmname].radius, prevscale, newscale)
        end
    end

end --<scale_elements>

----------------------------------
------     SCALE  APP    ------
----------------------------------
--zzscale  
local function scaleApp()
    
    -- # Set APP_SCALE --
    
    local prevscale = APP_SCALE
    
    local _, scale = GUI.Val("mbx_Scale")
    DHTK.window_settings.scale = scale
    GUI.elms.lbl_CurrScale.caption = DHTK.window_settings.scale
    
    APP_SCALE = tonumber(scale)
    
    --dh_log("> scaleApp new APP_SCALE is: " .. tostring(APP_SCALE))
    
    -- # Update fonts --
    dhth.set_scaled_fonts(scale)
    
    -- # Set Window METRICS -- 
    
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

    -- # Convert colors to integer (0..255) format --
    for name, col in pairs(GUI.colors) do 
        col[1] = math.floor((col[1] * 255) + 0.5)
        col[2] = math.floor((col[2] * 255) + 0.5)
        col[3] = math.floor((col[3] * 255) + 0.5)
        col[4] = math.floor((col[4] * 255) + 0.5)
    end
      
    -- GUI.Init() converts colors back to 0..1 format.
    GUI.Init()
    GUI.resized = true
                     
end --<scaleApp>

----------------------------------------

--[[ DEV NOTE: 
     I'm using layers 9-20 for Preferences Window.
     May want to reserve a few more just in case.
     The following two functions are to hide and show them.
     These need to correspond to z-layers of element definitions.
--]]

local function hidePrefsWindow()
    --dh_log("** core hidePrefsWindow **")
        
    for _, lyr in ipairs(DHTK.prefsLayers) do
        GUI.elms_hide[lyr] = true
    end	
    	
	if DHTK.MULTIPLE_HEIGHTS then
	    if DHTK.window_settings.is_window_expanded then
		    GUI.h = DHTK.s_APP_EXP_HEIGHT
	    else 
		    GUI.h = DHTK.s_APP_MIN_HEIGHT
	    end
	GUI.resized = true	
	
	end
end

function DHTK.showPrefsWindow()
    --dh_log("** core showPrefsWindow **")
    
    for _, lyr in ipairs(DHTK.prefsLayers) do
        GUI.elms_hide[lyr] = false
    end	
    
    if GUI.elms.mbx_UserThemes.visibility == "visible" then
        GUI.elms_hide[9] = false
    else
        GUI.elms_hide[9] = true
    end
    
end

--======================================
  --------      ELEMENTS      --------
--======================================
--zzelem

local function createPrefsWindow()

-- !!! Changed indent for elements definitions for ease of maintenance.

------------------------------------
------  Preferences Window  ------
------------------------------------

GUI.New("frm_Preferences", "Frame", {
    z = 20,
    x = 0,
    y = 0,
    w = DHTK.APP_WIDTH,
    h = DHTK.PREFS_HEIGHT,
    shadow = false,
    fill = true,
    color = "elm_fill",
    bg = "elm_fill", 
    round = 0,
    text = "",
    txt_indent = 0,
    txt_pad = 0,
    pad = 8, 
    font = "sans16",
    col_txt = "txt",
})

GUI.New("lbl_Preferences", "Label", {
    z = 19,
    x = 16, 
    y = 8, 
    caption = "Preferences:",
    shadow = false,
    font = "sans24",
})

GUI.New("btn_ClosePrefs", "Button", {
    z = 19,
    x = 496, 
    y = 12, 
    w = 80, 
    h = 28, 
    caption = "Close",
    font = "sans24",
    col_txt = "txt",
    col_fill = "btn_face",
    --func = btn_ClosePrefsClick
    func = hidePrefsWindow
})

------------------------------------
------    Scale Section   ------
------------------------------------
--zzscale   

GUI.New("lbl_ScaleSectionTitle", "Label", { 
    z = 18,
    x = 20, 
    y = 32, 
    caption = "App Scale",
    shadow = false,
    font = "sans22",
})

GUI.New("frm_ScaleSection", "Frame", {
    z = 18,
    x = 16,
    y = 56,
    w = 152,
    h = 236,
    shadow = false,
    fill = false,
    round = 0,
    bg = "elm_fill", 
    color = "opt_frame",
    col_txt = "txt",
    font = "sans16",
    text = "",
    txt_indent = 0,
    txt_pad = 0,
    pad = 8, 
})
----------------------------------------
GUI.New("lbl_CurrScaleTitle", "Label", {
    z = 17,
    x = 24, 
	y = 60, 
    caption = "Current Scale",
    shadow = false,
    font = "sans22",
})

GUI.New("lbl_CurrScale", "Label", {
    z = 16,
    x = 40, 
	y = 80, 
    caption = "1.00",
    shadow = true,
    font = "sans24",
})

GUI.New("mbx_Scale", "dh_Menubox", {
    z = 15,
    x = 24, 
    y = 202, 
    w = 136, 
    h = 32,  
    caption = "",
    noarrow = false,
    --optarray = dhth.DH_THEME_NAMES,
    optarray = APP_SCALE_FACTORS,
    curr_opt = 1,
    align = 0,
    font_b = "sans22",
    col_txt = "txt2"
})

GUI.New("btn_ScaleApp", "Button", {
    z = 14,
    x = 44, 
    y = 248, 
    w = 96, 
    h = 32,  
    caption = "Scale App",
    font = "sans22",
    col_txt = "txt",
    col_fill = "btn_face",
    func = scaleApp,
    --params = false   -- Only one window height
})

------------------------------------
------   Themes Section   ------ 
------------------------------------
--zztheme 
   
GUI.New("lbl_ThemesSectionTitle", "Label", { 
    z = 18,
    x = 180, 
    y = 32,
    caption = "Themes",
    shadow = false,
    font = "sans22",
})

GUI.New("frm_ThemesSection", "Frame", {
    z = 18,
    x = 176,
    y = 56,
    w = 184,
    h = 236,
    shadow = false,
    fill = false,
    round = 0,
    bg = "elm_fill", 
    color = "opt_frame",
    col_txt = "txt",
    font = "sans16",
    text = "",
    txt_indent = 0,
    txt_pad = 0,
    pad = 8, 
})
----------------------------------------
GUI.New("lbl_CurrDhThemeTitle", "Label", {
    z = 17,
    x = 184, 
	y = 60,
    caption = "Current dh_theme:",
    shadow = false,
    font = "sans22",
})

GUI.New("lbl_CurrDhTheme", "Label", {
    z = 12,
    x = 196, 
	y = 82,
    caption = "Default",
    shadow = true,
    font = "sans24",
})

GUI.New("mbx_dhThemes", "dh_Menubox", {
    z = 13,
    x = 184, 
    y = 110, 
    w = 168, 
    h = 32,  
    caption = "",
    noarrow = false,
    optarray = dhth.DH_THEME_NAMES,
    curr_opt = 1,
    align = 0,
    font_b = "sans22",
    col_txt = "txt2"
})

GUI.New("lbl_CurrUserThemeTitle", "Label", {
    z = 17,
    x = 184, 
	y = 152,
    caption = "Current User theme:",
    shadow = false,
    font = "sans22",
})

GUI.New("lbl_CurrUserTheme", "Label", {
    z = 11,
    x = 196, 
	y = 174,
    caption = "<None>",
    shadow = true,
    font = "sans24",
})

GUI.New("mbx_UserThemes", "dh_Menubox", {
    z = 9,
    x = 184, 
    y = 202, 
    w = 168, 
    h = 32, 
    caption = "",
    noarrow = false,
    --optarray = {},
    optarray = DHTK.USER_THEME_NAMES,
    curr_opt = 0, -- Set this in script init.
    align = 0,
    font_b = "sans22",
    col_txt = "txt2",
    visibility = "hidden"
})

GUI.New("btn_SetTheme", "Button", {
    z = 10,
    x = 220, 
    y = 248, 
    w = 96, 
    h = 32, 
    caption = "Set Theme",
    font = "sans22",
    col_txt = "txt",
    col_fill = "btn_face",
    func = setTheme
})

------------------------------------
------   Optional Section   ------ 
------------------------------------
--zzoptions
--[[ DEV NOTE: 
     !!! Define optional section in MainScript.
     Can use this as a template. 
--]]
--[[
GUI.New("lbl_Options", "Label", {
    z = 19, 
    x = 372, 
    y = 32, 
    caption = "Options", 
    font = "sans22",
})

GUI.New("chkl_Options",	"dh_Checklist",	{
	z = 10, 
    x = 368, 	
    y = 56,  
    w = 220, 
    h = 236,
    --shadow = false,  
	frame = true,
	caption = "",
	opt_size = 16, 
	--opts = template_options_names, -- defined in "my data"
	opts= {},
	bg = "elm_fill",  -- text bg color
	col_fill = "elm_bg",
	opt_frame = "opt_frame",
	opt_fill = "opt_fill",
	font_a = "sans22",
	font_b = "sans22",
	col_txt = "txt", 
	--dir = "h", 
	pad = 8, 
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
    
    if DHTK.window_settings.theme == "User" then
        if DHTK.window_settings.user_theme then
            GUI.Val("mbx_UserThemes", dhtks.table_index_from_value(DHTK.USER_THEME_NAMES, DHTK.window_settings.user_theme))
            GUI.Val("lbl_CurrUserTheme", DHTK.window_settings.user_theme)  
            GUI.elms.mbx_UserThemes.visibility = "visible"
        else
            GUI.Val("lbl_CurrUserTheme", "")  
            GUI.elms.mbx_UserThemes.visibility = "hidden"
        end
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
    
    	-- Add our code
	
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

    function GUI.elms.mbx_UserThemes:onmouseup()
        -- Run the element's normal method
        GUI.dh_Menubox.onmouseup(self)
    
    	-- Add our code
        GUI.Val("lbl_CurrUserTheme", self.optarray[self.curr_opt])
    
    end

end --<createPrefsWindow> 

--======================================
  --------    INIT CODE    --------
--======================================
--zz0425
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
    
    --GUI.Msg("**** setup_window APP_SCALE is : " .. tostring(APP_SCALE))
    --GUI.Msg("**** setup_window GUI.h is : " .. tostring(GUI.h))
    --GUI.Msg("**** setup_window APP_HEIGHT is : " .. tostring(APP_HEIGHT))
    --GUI.Msg("**** setup_window DHTK.APP_HEIGHT is : " .. tostring(DHTK.APP_HEIGHT))
end

--zzinit
-- This needs to be called in Main script after defining window sizes. 

function DHTK.init_DHTK()
    --dh_log("**** in DHTK.init_DHTK ****")
    
    getWindowSettings()
    getUserThemes()
    createPrefsWindow()
    setup_window()
    
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