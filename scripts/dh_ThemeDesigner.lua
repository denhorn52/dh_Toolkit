--dh_ThemeDesigner.lua 
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

-- Script for use with Reaper DAW.

-- Design user themes for scripts using Lokasenna_GUI v2
-- and dh_Toolkit.

---------------------------------------------
-- CONVENTIONS USED:
--   camelCase used for var and function names pertaining to GUI.
--   snake_case used for other var and function names.
--   Comments starting with --zz are bookmarks.
--   Code between --<<< and -->>> denotes optional code used as example.
--   Comments starting with --!!! denote needs attention or importance.
--   Comments starting with --??? denote question about code.
--   Comments starting with --xxx denote code to toggle for testing.
--   Block comments --[==[ denote info or notes.
--   Block comments --[===[ denote documentaion.

--zztop
---------------------------------------
  --------      TODO      --------
---------------------------------------
--zztodo

---------------------------------------
  --------      NOTES      --------
---------------------------------------
-- dh_ThemeDesigner.lua retains all of the functionality that
-- was transferred to dh_Toolkit_core.lua. Because of the
-- interaction required it would be impractical to separate
-- them here.
-- dh_ThemeDesigner.lua has its own option boxes for selecting themes
-- and scaling app. Therefore probably can't use core.set_theme.
-- Also because it has additional functionality that would
-- require a callback.
-- Maybe I can transfer scaling to DHTK.

--------------------------------------
-- dh_log (used during development)
--------------------------------------
-- Disable all console messages by setting this to false. 
local dh_log_active = false

function dh_log(msg)
	if dh_log_active then
		reaper.ShowConsoleMsg(msg .. "\n")
	end
end

--====================================
-- Using Lokasenna's GUI
--====================================
local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
if not lib_path or lib_path == "" then
    reaper.MB("Couldn't load the Lokasenna_GUI library. Please install 'Lokasenna's GUI library v2 for Lua', available on ReaPack, then run the 'Set Lokasenna_GUI v2 library path.lua' script in your Action List.", "Whoops!", 0)
    return
end
loadfile(lib_path .. "Core.lua")()

--[[ DEV NOTE: Comment out classes not being used. ]]

GUI.req("Classes/Class - Button.lua")()
GUI.req("Classes/Class - Frame.lua")()
GUI.req("Classes/Class - Knob.lua")()
GUI.req("Classes/Class - Label.lua")()
GUI.req("Classes/Class - Listbox.lua")()
GUI.req("Classes/Class - Menubar.lua")()
GUI.req("Classes/Class - Menubox.lua")()
GUI.req("Classes/Class - Options.lua")() 
GUI.req("Classes/Class - Slider.lua")()
GUI.req("Classes/Class - Tabs.lua")()
GUI.req("Classes/Class - Textbox.lua")()
GUI.req("Classes/Class - TextEditor.lua")()
--GUI.req("Classes/Class - Window.lua")()

-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end

GUI.name = "dh_ThemeDesigner v1.0"

--Hide the version number since I'm using a small window.
--GUI.Draw_Version = function () end

-- Lighten up shadow color.
-- !!! Would like to make this part of theming.
GUI.colors["shadow"] = {0,0,0,32}

--====================================
-- dh_Toolkit requirements 
--====================================
-- Adds current directory to path.

-- Next line from XRaym Preset script.lua. 
--local script_folder = debug.getinfo(1).source:match("@?(.*[\\|/])")
--package.path = package.path .. ";" .. script_folder .. "?.lua"

local dhtk_path = reaper.GetExtState("dh_Toolkit", "lib_path_v1")
if not dhtk_path or dhtk_path == "" then
    reaper.MB("Couldn't load dh_Toolkit. Please install 'dh_Toolkit v1 for Lua', available on ReaPack, then run the 'Set dh_Toolkit v1 library path.lua' script in your Action List.", "Whoops!", 0)
    return
end

--loadfile(dhtk_path .. "common/dh_Toolkit_core.lua")()
package.path = package.path .. ";" .. dhtk_path .. "?.lua"

-----------------------------------------
DHTK = require "common/dh_Toolkit_core"
-----------------------------------------
DHTK.EXT_STATE_NAME = "dh_ThemeDesigner"

-- Script window dimensions at 1.00x scale.
DHTK.APP_WIDTH = 640
DHTK.APP_HEIGHT = 640
DHTK.PREFS_HEIGHT = 300 -- Set same as TOOLS_TOP

--------------------------------------------
-- Custom Lokasenna's class to use as bordered Frame.
local dh_frame = require "classes/dh_Frame"

-- Revised Lokasenna's Menubox class for dynamic entries.
local dh_mbx = require "classes/dh_Menubox"

-- Revised Lokasenna's Options class to use my color theming.
local dh_opt = require "classes/dh_Options"

-- Revised Lokasenna's Slider class.
local dh_sld = require "classes/dh_Slider"

--------------------------------------
-- !!! Necessary. Must be after req dh_Options
DHTK.init_DHTK()
--------------------------------------

local dhtks = require "common/dh_Toolkit_shared"
local dhth = require "common/dh_Toolkit_themes"
local json = require "common/json"

local DH_THEMES = dhth.DH_THEMES
local DH_THEME_NAMES = dhth.DH_THEME_NAMES

--====================================
  --------    My Data    --------
--====================================
--zzdata  
-- Pre-declare variables here so every function has access to it.
     
-- Layout dimensions at 1.00x scale.
local TAB_HEIGHT = 32
local DISPLAY_HEIGHT = 268
local TOOLS_TOP = 300
local TOOLS_HEIGHT = 340

--------------------------------------
--zzoptions

-- template_options provided as an example.
local template_options = {
  option1 = true,
  option2 = true,
  option3 = true,
  option4 = false
}

local options_names = {}    -- Options checklist display
local options_selected = {} -- Default selected values

for name, sel in pairs(template_options) do
    table.insert(options_names, name)
    table.insert(options_selected, sel)
end
table.sort(options_names)

--------------------------------------
--zzthemes 

-- The whole purpose of this script.
-- Fetched in "Window Settings" so the elements know what colors to use.
-- This is available because dh_Toolkit has been initialized.
local USER_THEMES = DHTK.USER_THEMES

-- For menubox display. 
-- Populated before element creation (in "Window Settings")
local USER_THEME_NAMES = DHTK.USER_THEME_NAMES

-- # Should move this to requires.
local COLOR_USES = dhth.COLOR_USES

--local COLOR_NAMES = {}    -- Display in menubox
local COLOR_NAMES = dhth.COLOR_NAMES

-- Add GUI colors for display frames.
GUI.colors["start_color"] = {0,0,0,255}
GUI.colors["new_color"] = {0,0,0,255}

--====================================
  ------     My Functions    ------
--====================================
--zzfunc
-- Functions called by an element action, e.g.,button click,
-- needs to be here before elements creation.

local function dh_save_user_themes_ext()
    local json_string = json.encode(USER_THEMES)
    reaper.SetExtState("dh_Toolkit", "user-themes", json_string, true)
end

--====================================
  -----   Element Functions   -----
--====================================
--zzelemc 

--zzthemeset
-- Much of this is duplication of core setTheme().
-- It's either duplicate it here, or make it public in core.
-- Really, only need (user)theme name.

local function btn_SetThemeClick()

    -- # Prompt when setting a theme --
    local msg = 'Setting a theme will reset the theme you are designing!\n' ..
                 'Be sure to save your theme first.\n Do you wish to Continue?'
                
    local retval = reaper.ShowMessageBox(msg, " Warning!!!", 4)	-- retval 6 is yes							
     
    if retval ~= 6 then return end
    
    -- OK. Proceed to set theme --
    local theme_index, theme_name = GUI.Val("mbx_dhThemes")

    -- # If "User" then get user theme name from menubox.
    if theme_name == "User" then
    
        local _, user_theme_name  = GUI.Val("mbx_UserThemes")

        -- # Check if user theme exists --
        -- Shouldn't have to verify, but doesn't hurt.
        if not USER_THEMES[user_theme_name] then
            reaper.MB("User theme: " .. user_theme_name .. " : not found!", "Whoops!", 0)
            return
        else
            -- User theme exists.
            DHTK.window_settings.theme = theme_name
            DHTK.window_settings.user_theme = user_theme_name
            GUI.elms.lbl_CurrDhTheme.caption = DHTK.window_settings.theme
            GUI.elms.lbl_CurrUserTheme.caption = DHTK.window_settings.user_theme
            GUI.Val("tbx_UserThemeName", DHTK.window_settings.user_theme)
            dhth.set_theme(USER_THEMES[user_theme_name], true)            
        end
    else
        --Native theme, not user.
        DHTK.window_settings.theme = theme_name
        GUI.elms.lbl_CurrDhTheme.caption = DHTK.window_settings.theme
        GUI.elms.lbl_CurrUserTheme.caption = ""
        GUI.Val("tbx_UserThemeName", DHTK.window_settings.theme)
        dhth.set_theme(DH_THEMES[theme_name], true)            
    end
    dh_log("btn_SetThemeClick: theme is set ")     

    -- # Update vars and gui --
    
    -- Update color elements --
    GUI.Val("mbx_ColorNames", 1)
    GUI.elms.lbx_ColorUses.list = COLOR_USES["wnd_bg"]
        
    GUI.colors.start_color = dhth.set_color(GUI.colors.wnd_bg)
    GUI.colors.new_color = dhth.set_color(GUI.colors.wnd_bg)

    -- Update sliders --
    GUI.Val("slider_Red", math.floor((GUI.colors.start_color[1] * 255) + 0.5))
    GUI.Val("slider_Green", math.floor((GUI.colors.start_color[2] * 255) + 0.5))
    GUI.Val("slider_Blue", math.floor((GUI.colors.start_color[3] * 255) + 0.5)) 

    -- Necessary!
    GUI.update_elms_list(true)
	
	GUI.redraw_z[0] = true

end --<btn_SetThemeClick>

--zzthemesave
local function btn_SaveUserThemeClick()

    -- # Get name for user theme from tbx_UserThemeName --
    local retval, new_name = dhtks.validate_name(GUI.Val("tbx_UserThemeName"))
    
    if not retval then return end

    -- Should I check if name already exists --
    -- !!! Maybe better to prompt!
    if USER_THEMES[new_name] then
        new_name = new_name .. "$"
    end
    
    -- # Build theme --
    -- If I want themes saved in a particular order
    -- I will maybe need to add colors to theme one by one.
    -- That creates a maintenance issue.
    
    -- !!! This doesn't order list!
    local new_theme = {}

    for i, col_name in ipairs(COLOR_NAMES) do
        new_theme[col_name] = {}
        local col = GUI.colors[col_name]
        new_theme[col_name][1] = math.floor((col[1] * 256) + 0.5)
        new_theme[col_name][2] = math.floor((col[2] * 256) + 0.5)
        new_theme[col_name][3] = math.floor((col[3] * 256) + 0.5)
        new_theme[col_name][4] = math.floor((col[4] * 256) + 0.5)
    end    
    
    USER_THEMES[new_name] = new_theme
    --dh_save_user_themes_ext()
    
    -- # Sort names --
    
    table.insert(USER_THEME_NAMES, new_name)
    table.sort(USER_THEME_NAMES)

    -- Update Menubox -- Not necessary!
    --GUI.elms.mbx_UserThemes.optarray = USER_THEME_NAMES
    
    local idx = dhtks.table_index_from_value(USER_THEME_NAMES, new_name)
    GUI.Val("mbx_UserThemes", idx)
    
    DHTK.window_settings.user_theme = new_name
    
end --<btn_SaveUserThemeClick>

--zzthemedelete
-- Delete user theme.
-- Will delete theme and theme name listed in menubox.
-- If currently loaded will not affect theme in progress.

local function btn_DeleteUserThemeClick()

    -- # Prompt when deleting a theme --
    local msg = "Are you sure you want to delete selected user theme?"
                   
    local retval = reaper.ShowMessageBox(msg, "Warning", 4)	-- retval 6 is yes							

    -- OK. Proceed to set theme.
    
    if retval == 6 then
    
        -- # Get user theme name --
        
        local ut_idx, ut_name = GUI.Val("mbx_UserThemes")
        table.remove(USER_THEME_NAMES, ut_idx)
        -- ??? Should I need to do this? Not necessary!
        --GUI.elms.mbx_UserThemes.optarray = USER_THEME_NAMES
        
        if #USER_THEME_NAMES == 0 then
            GUI.Val("mbx_UserThemes", 0) 
        else
            GUI.Val("mbx_UserThemes", 1) 
        end
         
        USER_THEMES[ut_name] = nil
    
    end

end --<btn_DeleteUserThemeClick>

--zzthemerename  
-- Rename user theme listed in menubox with name in textbox.
-- If theme is currently loaded it will not affect theme in progress,
-- although user theme no longer available as a starting point
-- until it is again saved.

local function btn_RenameUserThemeClick()
    
    -- # Get user theme name --
    --if #USER_THEME_NAMES == 0 then        
    if #GUI.elms.mbx_UserThemes.optarray == 0 then
        reaper.MB("No User theme to rename.", "Error!", 0)
        return
    else
        local retval reaper.MB("Attempting to rename user theme. Continue?", "Warning!", 4)
        if retval == 5 then return end
    end
        
    local mbx_idx, mbx_name = GUI.Val("mbx_UserThemes")
    
    ---- # Get new name ----
    local retval, tbx_name = dhtks.validate_name(GUI.Val("tbx_UserThemeName"))
    
    if not retval then return end
    
    if mbx_name == tbx_name then
        reaper.MB("New Name is same as existing name.", "Error!", 0)
        return
    end
    
    -- # Update names list --
    table.remove(USER_THEME_NAMES, mbx_idx)
    table.insert(USER_THEME_NAMES, tbx_name)
    table.sort(USER_THEME_NAMES)

    -- # Select renamed theme --
    mbx_idx = dhtks.table_index_from_value(USER_THEME_NAMES, tbx_name)

    -- ??? Should I need to do this?
    --GUI.elms.mbx_UserThemes.optarray = USER_THEME_NAMES
    
    GUI.Val("mbx_UserThemes", mbx_idx)
     
    -- # Update themes --
    USER_THEMES[tbx_name] = USER_THEMES[mbx_name]
    USER_THEMES[mbx_name] = nil

end --<btn_RenameUserThemeClick>

--zzmovecolor
-- Set frm_StartColor.col_fill to new_color.
-- Same effect as saving edit.

local function btn_MoveColorClick()
    dh_log("** in btn_MoveColorClick\n")
    GUI.elms_hide[65] = false
    GUI.elms_hide[66] = false
end

local function btn_CancelMoveColorClick()
    GUI.elms_hide[65] = true
    GUI.elms_hide[66] = true
end

local function btn_ConfirmMoveColorClick()
    GUI.elms.frm_StartColor.col_fill = dhth.set_color(GUI.colors.new_color)
    GUI.elms.frm_StartColor:init()
    GUI.elms.frm_StartColor:redraw()
    GUI.elms_hide[65] = true
    GUI.elms_hide[66] = true
end

--====================================
  --------    ELEMENTS    --------
--====================================
 --zzelem --zzelm 

GUI.New("tabs_ThemeDesigner", "Tabs", {
    z = 1,
    x = 0, 
    y = 0, 
    tab_w = 96, 
    tab_h = TAB_HEIGHT, 
    fullwidth = true,
    opts = "Themes,Lokasenna,dh_Toolkit",
    bg = "elm_bg",
    col_tab_a = "tab_act", --"wnd_bg",   -- active tab
    col_tab_b = "tab_bg",     -- inactive tab
    col_txt = "txt",
	font_a = "sans22",
	font_b = "sans20"
})
--zztabs
GUI.elms.tabs_ThemeDesigner:update_sets({ 
    --[1] = {31,32,33,34,35,36,37,38,39,40}, 
    --[2] = {45,46,47,48,49,50,51,52,53,57,58,59,60},    
    --[3] = {65,66,67,68,69,70,71,72,73,77,78,79,80}, 
    [1] = {5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20},   
    [2] = {25,26,27,28,29,30,31,32,33,37,38,39,40},    
    [3] = {45,46,47,48,49,50,51,52,53,57,58,59,60}, 
})

-----------------------------------
--------  Tab 1 Elements  --------
-----------------------------------
--zztab1 
-- !!! Tab1 holds Prefs, layers 9 - 20 defined in dh_Toolkit_core.lua.

GUI.New("frm_UserThemesSection", "Frame", {
    z = 18,
    x = 368,
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

GUI.New("lbl_UserThemeTitle", "Label", {
    z = 17,
    x = 380, 
    y = 28 + TAB_HEIGHT, 
    caption = "User Theme Name",
    --bg = "wnd_bg", 
    --color = "txt",
    font = "sans22",
})

GUI.New("tbx_UserThemeName", "Textbox", {
    z = 8,
    x = 376, 
    y = 52 + TAB_HEIGHT, 
    w = 168, 
    h = 32, 
    caption = "",
    font_b = "mono16",   --textbox needs mono font
    color = "txt2",
})

GUI.New("btn_SaveUserTheme", "Button", {
    z = 7,
    x = 408, 
    y = 92 + TAB_HEIGHT, 
    w = 104, 
    h = 32, 
    caption = "Save Theme",
    font = "sans22",
    col_txt = "txt",
    col_fill = "btn_face",	
	func = btn_SaveUserThemeClick
})

GUI.New("btn_DeleteUserTheme", "Button", {
    z = 6,
    x = 408, 
    y = 136 + TAB_HEIGHT, 
    w = 104, 
    h = 32, 
    caption = "Delete",
    font = "sans22",
    --col_txt = "txt",
    col_fill = "btn_face",	
	func = btn_DeleteUserThemeClick
})

GUI.New("btn_RenameUserTheme", "Button", {
    z = 5,
    x = 408, 
    y = 180 + TAB_HEIGHT,  
    w = 104, 
    h = 32, 
    caption = "Rename",
    font = "sans22",
    --col_txt = "txt",
    col_fill = "btn_face",	
	func = btn_RenameUserThemeClick
})

-- Adjustments to "Prefs" elements where they differ from core.

if GUI.elms["frm_Preferences"] then
    GUI.elms["frm_Preferences"].y = 32
    GUI.elms["frm_Preferences"].h = DISPLAY_HEIGHT
end
if GUI.elms["lbl_Preferences"] then GUI.elms["lbl_Preferences"] = nil end
if GUI.elms["btn_ClosePrefs"] then GUI.elms["btn_ClosePrefs"] = nil end

--DHTK.prefsLayers = {9,10,11,12,13,14,15,16,17,18,19,20}

-----------------------------------
--------  Tab 2 Elements  --------
-----------------------------------
--zztab2

GUI.New("frm_Tab2_Lokasenna", "Frame", {
    z = 40,
    x = 0,
    y = TAB_HEIGHT,
    w = DHTK.APP_WIDTH, 
    h = DISPLAY_HEIGHT,
    fill = false,
    --text = "", 
    --bg = "wnd_bg",
    --color = "elm_frame",
    --col_txt = "txt",
})

GUI.New("menu_Tab2_Lokasenna", "Menubar", {
    z = 38,
    x = 0, 
    y = 8 + TAB_HEIGHT, 
    w = 272, 
    h = 24,
    fullwidth = true,
    menus = {
      {title = "Menu", options = {"Hello",nil}},
      {title = "Bar", options = {"There",nil}} 
    }
})
-----------------------------------
GUI.New("lbl_Tab2_chkl", "Label", {
    z = 39,
    x = 24, 
	y = 48 + TAB_HEIGHT, 
    caption = "Lokasenna Options",
    --bg = "wnd_bg",      
    --color = "txt",
    --font = "sans24",
})

--zzoptions
GUI.New("chkl_Tab2", "Checklist", {
	z = 32, 
    x = 16, 	
    y = 72 + TAB_HEIGHT,  
    w = 156, 
    h = 112,
	frame = true,
	caption = "",
	--opt_size = 16,
	opts = options_names,
	
	--bg = "elm_fill",  -- text bg color
	--col_fill = "elm_bg",
	--col_txt = "txt", 
	--opt_frame = "opt_frame",
	--opt_fill = "opt_fill",
	
	--font_a = "sans22",
	--font_b = "sans22",
	--dir = "h", 
	--pad = 8, 
})

-- Set template options default values
-- These may get changed when loading project ext state
GUI.Val("chkl_Lokasenna", options_selected)

GUI.New("btn_Tab2", "Button", {
    z = 31,
    x = 28,  
    y = 196 + TAB_HEIGHT,  
    w = 128, 
    h = 32, 
    caption = "Button",
    --font = "sans22",
    --col_txt = "txt",
    --col_fill = "btn_face",
})

-----------------------------------
GUI.New("frm_Tab2_2", "Frame", {
    z = 30,
    x = 184,
    y = 40 + TAB_HEIGHT,
    w = 440, 
    h = 200, 
    fill = false, 
    radius = 16, 
})

GUI.New("lbl_Tab2_2", "Label", {
    z = 29,
    x = 208, 
	y = 48 + TAB_HEIGHT, 
    caption = "This is a Label in a Lokasenna Frame",
    --font = "sans24",
    --bg = "wnd_bg",      
    --color = "txt",
})

GUI.New("mbx_Tab2", "Menubox", {
    z = 28,
    x = 208, 
    y = 88 + TAB_HEIGHT, 
    w = 128, 
    h = 32, 
    caption = "",
    noarrow = false,
    opts = {"Menubox"},
    retval = 1,
    align = 0
})

GUI.New("lbx_Tab2", "Listbox", {
    z = 27,
    x = 208, 
    y = 128 + TAB_HEIGHT, 
    w = 128, 
    h = 96, 
    list = {"Listbox"},
    multi = false, --!!! Do not change
    caption = "",
    --font_a = "sans16",        -- caption font not used
    --font_b = "sans24",        -- list font
    --bg = "elm_bg",            -- box bg
    color = "txt",
    --col_fill = "elm_fill",    -- scrollbar fill
    --cap_bg = "wnd_bg",
    --pad = 4
})
--zztabc --zzslider
-----------------------------------
GUI.New("slider_Tab2", "Slider", {
    z = 26,
    x = 368, 
    y = 100 + TAB_HEIGHT, 
    w = 200, 
    caption = "Slider",
    min = 0,
    max = 10,
    defaults = 0,
    --show_values = true,
    --font_a = "sans20",
    --font_b = "sans18",
    --bg = "elm_fill",
    --col_txt = "txt",
    --col_hnd = "knob_face",
    --col_fill = "elm_border"
})

GUI.New("knob_Tab2", "Knob", {
    z = 25,
    x = 468, 
    y = 160 + TAB_HEIGHT, 
    w = 30, 
    caption = "Knob",
    min = 0,
    max = 10,
    default = 0,
    vals = true,
    --font_a = "sans20",
    --font_b = "sans18",
    --bg = "elm_fill",
    --col_txt = "txt",
    --col_head = "txt2", --"elm_fill",
    --col_body = "knob_face"
})

-----------------------------------
--------  Tab 3 Elements  --------
-----------------------------------
--zztab3
GUI.New("frm_Tab3_Toolkit", "Frame", {
    z = 60,
    x = 0,
    y = TAB_HEIGHT,
    w = DHTK.APP_WIDTH, 
    h = DISPLAY_HEIGHT, 
    fill = false, 
    --bg = "wnd_bg",
    --color = "elm_frame"
    --col_txt = "txt",
})

GUI.New("menu_Tab3_Toolkit", "Menubar", {
    z = 58,
    x = 0, 
    y = 8 + TAB_HEIGHT, 
    w = 272, 
    h = 24,
    fullwidth = true,
    menus = {
      {title = "Menu", options = {"Hello",nil}},
      {title = "Bar", options = {"There",nil}}
    }
})
-----------------------------------
GUI.New("lbl_Tab3_chkl", "Label", {
    z = 59,
    x = 24, 
	y = 48 + TAB_HEIGHT, 
    caption = "dh_Toolkit Options",
    --bg = "wnd_bg",      
    --font = "sans24",
    --color = "txt",
})

--zzoptions
GUI.New("chkl_Tab3", "dh_Checklist", {
	z = 52, 
    x = 16, 	
    y = 72 + TAB_HEIGHT,  
    w = 156, 
    h = 112,
	frame = true,
	caption = "",
	opt_size = 16,
	opts = options_names,
	
	--bg = "elm_fill",  -- text bg color
	--col_fill = "elm_bg",
	opt_frame = "opt_frame",
	opt_fill = "opt_fill",
	
	font_a = "sans22",
	font_b = "sans22",
	--col_txt = "txt", 
	--dir = "h", 
	--pad = 8, 
})

-- Set template options default values
-- These may get changed when loading project ext state
GUI.Val("chkl_Toolkit", options_selected)

GUI.New("btn_Tab3", "Button", {
    z = 51,
    x = 28,  
    y = 196 + TAB_HEIGHT,  
    w = 128, 
    h = 32, 
    caption = "Button",
    font = "sans22",
    col_txt = "txt",
    col_fill = "btn_face",
})

-----------------------------------
GUI.New("frm_Tab3", "dh_Frame", {
    z = 50,
    x = 184,
    y = 40 + TAB_HEIGHT,
    w = 440, 
    h = 200, 
    fill = true, 
    border_width = 8, 
    radius = 8, 
    col_border = "elm_border",	
    color_fill = "wnd_bg"
})

GUI.New("lbl_Tab3", "Label", {
    z = 49,
    x = 208, 
	y = 48 + TAB_HEIGHT, 
    caption = "This is a Label in a dh_Frame",
    --bg = "wnd_bg",      
    --font = "sans24",
    --color = "txt",
})

GUI.New("mbx_Tab3", "dh_Menubox", {
    z = 48,
    x = 208, 
    y = 88 + TAB_HEIGHT, 
    w = 128, 
    h = 32,
    caption = "",
    noarrow = false,
    col_txt = "txt2",
    optarray = {"Menubox"},
    curr_opt = 1,
    align = 0
})

GUI.New("lbx_Tab3", "Listbox", {
    z = 47,
    x = 208, 
    y = 128 + TAB_HEIGHT, 
    w = 128, 
    h = 96,
    list = {"Listbox"},
    multi = false, --!!! Do not change
    caption = "",
    --font_a = "sans16",        -- caption font not used
    --font_b = "sans24",        -- list font
    color = "txt2",
    --col_fill = "elm_fill",    -- scrollbar fill
    --bg = "elm_bg",            -- box bg
    --cap_bg = "wnd_bg",
    --pad = 4
})

-----------------------------------
--zztabc --zzslider3
GUI.New("slider_Tab3", "dh_Slider", {
    z = 46,
    x = 368, 
    y = 100 + TAB_HEIGHT, 
    w = 200,
    thk = 12, 
    caption = "dh_Slider",
    min = 0,
    max = 10,
    defaults = 0,
    show_values = true,
    font_a = "sans20",
    font_b = "sans18",
    bg = "elm_fill",
    col_txt = "txt",
    col_hnd = "knob_face",
    col_fill = "elm_border"
})

GUI.New("knob_Tab3", "Knob", {
    z = 45,
    x = 468, 
    y = 160 + TAB_HEIGHT, 
    w = 30, 
    caption = "Knob",
    min = 0,
    max = 10,
    default = 0,
    vals = true,
    font_a = "sans20",
    font_b = "sans18",
    bg = "elm_fill",
    col_txt = "txt",
    col_head = "txt2", --"elm_fill",
    col_body = "knob_face"
})

--------------------------------
--------  Tools Panel  --------
--------------------------------
--zztools 

GUI.New("frm_Tools", "dh_Frame", {
    z = 85,
    x = 0,
    y = TOOLS_TOP,
    w = DHTK.APP_WIDTH,
    h = TOOLS_HEIGHT,
    fill = true,
    border_width = 2, 
    col_border = "elm_frame",
    col_fill = "wnd_bg",
    --col_txt = "txt"
})

-------------------------------
----       Column 1      ----
-------------------------------
--zzcol1

GUI.New("lbl_ColorNames", "Label", {
    z = 83,
    x = 36, 
    y = 16 + TOOLS_TOP, 
    caption = "Color Names",
    font = "sans22",
    bg = "wnd_bg",      
    color = "txt",
})

GUI.New("mbx_ColorNames", "dh_Menubox", {
    z = 79,
    x = 32, 
    y = 40 + TOOLS_TOP, 
    w = 156, 
    h = 32, 
    caption = "",
    noarrow = false,
    optarray = COLOR_NAMES,
    curr_opt = 0,
    --font_a = "sans16",
    font_b = "sans22",
    --bg = "wnd_bg",
    col_txt = "txt2",
    --col_cap = "txt",
    --pad = 4, 
    align = 0
})

GUI.New("lbl_ColorUses", "Label", {
    z = 73,
    x = 36, 
    y = 88 + TOOLS_TOP, 
    caption = "Color Uses",
    --bg = "wnd_bg",      
    font = "sans22",
    --color = "txt",
})

--zzlbx
GUI.New("lbx_ColorUses", "Listbox", {
    z = 78,
    x = 32, 
    y = 112 + TOOLS_TOP, 
    w = 156, 
    h = 156, 
    list = COLOR_USES["wnd_bg"],
    multi = false, --!!! Do not change
    caption = "",
    font_a = "sans16",        -- caption font not used
    font_b = "sans20",        -- list font
    color = "txt2",
    --col_fill = "elm_fill",    -- scrollbar fill
    --bg = "elm_bg",            -- box bg
    --cap_bg = "wnd_bg",
    pad = 4
})
--[[
GUI.New("lbl_CurrTheme", "Label", {
    z = 83,
    x = 36, 
    y = 216 + TOOLS_TOP, 
    caption = "Current Theme",
    --font = "sans24",
    --bg = "wnd_bg",      
    --color = "txt",
})

GUI.New("tbx_UserThemeName", "Textbox", {
    z = 77,
    x = 32, 
    y = 240 + TOOLS_TOP, 
    w = 156, 
    h = 32, 
    caption = "",
    font_b = "mono16",   --textbox needs mono font
    color = "txt2",
})

GUI.New("btn_SaveUserTheme", "Button", {
    z = 76,
    x = 48, 
    y = 288 + TOOLS_TOP,  
    w = 124, 
    h = 32, 
    caption = "Save Theme",
    font = "sans22",
    col_txt = "txt",
    col_fill = "btn_face",	
	func = btn_SaveUserThemeClick
})
--]]
-------------------------------
------     Column 2    ------
-------------------------------
--zzcol2
--[[
GUI.New("lbl_Red", "Label", {
    z = 63,
    x = 224, 
    y = 16 + TOOLS_TOP, 
    caption = "Red",
    --font = "sans24",
    --bg = "wnd_bg",      
    --color = "txt",
})
--]]
-- Label for slider value
GUI.New("lbl_RedVal", "Label", {
    z = 75,
    x = 500, 
    y = 16 + TOOLS_TOP, 
    caption = "0",
    font = "mono18",
    --bg = "wnd_bg",      
    --color = "txt",
})
--zzslider4
GUI.New("slider_Red", "dh_Slider", {
    z = 74,
    x = 224, 
    y = 48 + TOOLS_TOP,
    w = 384,
    thk = 12, 
    caption = "Red",
    min = 0,
    max = 255,
    defaults = 0,
    show_values = false,
    font_a = "sans22",
    font_b = "sans18",
    bg = "elm_fill",
    col_txt = "txt",
    col_hnd = "knob_face",
    col_fill = "elm_border"    
})

--------------------------------------
--[[
GUI.New("lbl_Green", "Label", {
    z = 83,
    x = 224, 
    y = 72 + TOOLS_TOP, 
    caption = "Green",
    --font = "sans24",
    --bg = "wnd_bg",      
    --color = "txt",
})
--]]
-- Label for slider value
GUI.New("lbl_GreenVal", "Label", {
    z = 73,
    x = 500, 
    y = 72 + TOOLS_TOP, 
    caption = "0",
    font = "mono18",
    --bg = "wnd_bg",      
    --color = "txt",
})
--zzslider
GUI.New("slider_Green", "dh_Slider", {
    z = 72,
    x = 224, 
    y = 104 + TOOLS_TOP, 
    w = 384,
    thk = 12, 
    caption = "Green",
    min = 0,
    max = 255,
    defaults = 0,
    show_values = false,
    font_a = "sans22",
    font_b = "sans18",
    bg = "elm_fill",
    col_txt = "txt",
    col_hnd = "knob_face",
    col_fill = "elm_border"    
})

--------------------------------------
-- Label for slider value
GUI.New("lbl_BlueVal", "Label", {
    z = 71,
    x = 500, 
    y = 128 + TOOLS_TOP, 
    caption = "0",
    font = "mono18",
    --bg = "wnd_bg",      
    --color = "txt",
})
--zzslider
GUI.New("slider_Blue", "dh_Slider", {
    z = 70,
    x = 224, 
    y = 160 + TOOLS_TOP, 
    w = 384,
    thk = 12,     
    caption = "Blue",
    min = 0,
    max = 255,
    defaults = 0,
    show_values = false,
    font_a = "sans20",
    font_b = "sans18",
    bg = "elm_fill",
    col_txt = "txt",
    col_hnd = "knob_face",
    col_fill = "elm_border"    
})

-------------------------------------
--zzcolor

GUI.New("lbl_StartColor", "Label", {
    z = 83,
    x = 232, 
    y = 200 + TOOLS_TOP, 
    caption = "Start Color",
    font = "sans22",
    --bg = "wnd_bg",      
    --color = "txt",
})

GUI.New("frm_StartColor", "dh_Frame", {
    z = 68,
    x = 224,
    y = 224 + TOOLS_TOP,
    w = 96,
    h = 96,
    border_width = 4, 
    radius = 8, 
    fill = true,
    col_border = "elm_border",	
    col_fill = "start_color"
})

GUI.New("btn_MoveColor", "Button", {
    z = 67,
    x = 374, 
    y = 240 + TOOLS_TOP,  --232
    w = 80, 
    h = 28, 
    caption = "< Move",
    font = "sans22",
    col_txt = "txt",
    col_fill = "btn_face",
    func = btn_MoveColorClick
})

GUI.New("btn_CancelMoveColor", "Button", {
    z = 65,
    x = 364, 
    y = 276 + TOOLS_TOP,  --232
    w = 48, 
    h = 28, 
    caption = "No",
    font = "sans22",
    col_txt = "txt",
    col_fill = "btn_face",
    func = btn_CancelMoveColorClick
})

GUI.New("btn_ConfirmMoveColor", "Button", {
    z = 66,
    x = 420, 
    y = 276 + TOOLS_TOP,  --232
    w = 48, 
    h = 28, 
    caption = "Yes",
    font = "sans22",
    col_txt = "txt",
    col_fill = "btn_face",
    func = btn_ConfirmMoveColorClick
})

GUI.New("lbl_NewColor", "Label", {
    z = 83,
    x = 516, 
    y = 200 + TOOLS_TOP, 
    caption = "New Color",
    font = "sans22",
    --bg = "wnd_bg",      
    --color = "txt",
})

GUI.New("frm_NewColor", "dh_Frame", {
    z = 69,
    x = 512, 
    y = 224 + TOOLS_TOP,
    w = 96,
    h = 96,
    border_width = 4, 
    radius = 8, 
    fill = true,
    col_border = "elm_border",	
    col_fill = "new_color"
})

--dh_log("-- Elements done loading --\n")
--====================================
  ------   Method Overrides  ------
--====================================
--zzoverrides 

--------------------------------------
--zzsliders
-- Draw caption at slider x.
function GUI.Slider:drawcaption()

    --!!! Do NOT run the slider's normal method.

    GUI.font(self.font_a)
    local str_w, str_h = gfx.measurestr(self.caption)
    --gfx.x = self.x + (self.w - str_w) / 2 + self.cap_x
    gfx.x = self.x
    gfx.y = self.y - (self.dir ~= "v" and self.h or self.w) - str_h + self.cap_y
    GUI.text_bg(self.caption, self.bg)
    GUI.shadow(self.caption, self.col_txt, "shadow")

end

--zzslider
function GUI.elms.slider_Red:ondrag()

	-- Run the element's normal method --
	-- Sets current handle retval.
	GUI.Slider.ondrag(self)

	-- Add our code --
	
	-- Returns a table of values. Size of table is number of handles.
	local retval = GUI.Val("slider_Red")
	
	-- Update readout --
	GUI.Val("lbl_RedVal", tostring(retval))
	
	-- Update frm_NewColor --
	-- # Be sure frm_NewColor col_fill is set to "new_color".
	-- # Watch performance!
	GUI.colors["new_color"][1] = retval / 255
	GUI.elms.frm_NewColor:init()
	GUI.elms.frm_NewColor:redraw()
    
end	

function GUI.elms.slider_Red:onwheel()

	-- Run the element's normal method --
	-- Sets current handle retval.
	GUI.Slider.onwheel(self)

	-- Add our code --
	
	-- Returns a table of values. Size of table is number of handles.
	local retval = GUI.Val("slider_Red")
	
	-- Update readout --
	GUI.Val("lbl_RedVal", tostring(retval))
	
	-- Update frm_NewColor --
	-- # Be sure frm_NewColor col_fill is set to "new_color".
	-- # Watch performance!
	GUI.colors["new_color"][1] = retval / 255
	GUI.elms.frm_NewColor:init()
	GUI.elms.frm_NewColor:redraw()
    
end	

function GUI.elms.slider_Green:ondrag()

	-- Run the element's normal method --
	-- Sets current handle retval.
	GUI.Slider.ondrag(self)

	-- Add our code --
	
	-- Returns a table of values. Size of table is number of handles.
	local retval = GUI.Val("slider_Green")
	
	-- Update readout --
	GUI.Val("lbl_GreenVal", tostring(retval))
	
	-- Update frm_NewColor --
	-- # Be sure frm_NewColor col_fill is set to "new_color".
	-- # Watch performance!
	GUI.colors["new_color"][2] = retval / 255
	GUI.elms.frm_NewColor:init()
	GUI.elms.frm_NewColor:redraw()

end	

function GUI.elms.slider_Green:onwheel()

	-- Run the element's normal method --
	-- Sets current handle retval.
	GUI.Slider.onwheel(self)

	-- Add our code --
	
	-- Returns a table of values. Size of table is number of handles.
	local retval = GUI.Val("slider_Green")
	
	-- Update readout --
	GUI.Val("lbl_GreenVal", tostring(retval))
	
	-- Update frm_NewColor --
	-- # Be sure frm_NewColor col_fill is set to "new_color".
	-- # Watch performance!
	GUI.colors["new_color"][2] = retval / 255
	GUI.elms.frm_NewColor:init()
	GUI.elms.frm_NewColor:redraw()
    
end	

function GUI.elms.slider_Blue:ondrag()

	-- Run the element's normal method --
	-- Sets current handle retval.
	GUI.Slider.ondrag(self)

	-- Add our code --
	
	-- Returns a table of values. Size of table is number of handles.
	local retval = GUI.Val("slider_Blue")
	
	-- Update readout --
	GUI.Val("lbl_BlueVal", tostring(retval))
	
	-- Update frm_NewColor --
	-- # Be sure frm_NewColor col_fill is set to "new_color".
	-- # Watch performance!
	GUI.colors["new_color"][3] = retval / 255
	GUI.elms.frm_NewColor:init()
	GUI.elms.frm_NewColor:redraw()

end	

function GUI.elms.slider_Blue:onwheel()

	-- Run the element's normal method --
	-- Sets current handle retval.
	GUI.Slider.onwheel(self)

	-- Add our code --
	
	-- Returns a table of values. Size of table is number of handles.
	local retval = GUI.Val("slider_Blue")
	
	-- Update readout --
	GUI.Val("lbl_BlueVal", tostring(retval))
	
	-- Update frm_NewColor --
	-- # Be sure frm_NewColor col_fill is set to "new_color".
	-- # Watch performance!
	GUI.colors["new_color"][3] = retval / 255
	GUI.elms.frm_NewColor:init()
	GUI.elms.frm_NewColor:redraw()
    
end	

--------------------------------------------------
--zzcolor

-- Click on frm_StartColor to reset new color to start color,

function GUI.elms.frm_StartColor:onmouseup()
    
    -- No need to run normal method as it is empty.
    
    -- Get color name -- 
    -- dh_Menubox val returns index, name.
    local _, colname = GUI.Val("mbx_ColorNames")
    
    -- Update GUI color --
    GUI.colors[colname] = dhth.set_color(GUI.colors.start_color)
    
    -- Update GUI --
    for key, __ in pairs(GUI.elms) do
        GUI.elms[key]:init()
        GUI.elms[key]:redraw()
    end
    
    GUI.redraw_z[0] = true	

end

---- Click on frm_NewColor to update window with new_color----

function GUI.elms.frm_NewColor:onmouseup()

    -- No need to run normal method as it is empty.
    
	-- Get color name -- 
	-- dh_Menubox val returns index, name.
	local _, colname = GUI.Val("mbx_ColorNames")
	
	-- Update GUI color --
	GUI.colors[colname] = dhth.set_color(GUI.colors.new_color)
	
	-- Update GUI --
	for key, __ in pairs(GUI.elms) do
        GUI.elms[key]:init()
        GUI.elms[key]:redraw()
    end

    GUI.redraw_z[0] = true	
end

-- number, string, nil, and boolean are value types. 
-- table, function, userdata, and thread are reference types. 

function GUI.elms.mbx_ColorNames:onmouseup()
	-- Run the element's normal method
	GUI.dh_Menubox.onmouseup(self)
	
	-- Add our code
	
	-- Get current selection in Menubox and populate Listbox --
	local _, val = GUI.Val("mbx_ColorNames")
	GUI.elms.lbx_ColorUses.list = COLOR_USES[val]
	GUI.elms.lbx_ColorUses:redraw()
	
	-- Update frm_StartColor and frm_NewColor color --
	GUI.colors.start_color = dhth.set_color(GUI.colors[val])
	GUI.colors.new_color = dhth.set_color(GUI.colors[val])
	
	GUI.elms.frm_StartColor:init()
	GUI.elms.frm_StartColor:redraw()
    	
    GUI.elms.frm_NewColor:init()
    GUI.elms.frm_NewColor:redraw()
    
    -- Update Sliders --
    GUI.Val("slider_Red", math.floor((GUI.colors.start_color[1] * 255) + 0.5))
    GUI.elms.slider_Red:redraw()
    GUI.Val("slider_Green", math.floor((GUI.colors.start_color[2] * 255) + 0.5))
    GUI.elms.slider_Green:redraw()
    GUI.Val("slider_Blue", math.floor((GUI.colors.start_color[3] * 255) + 0.5)) 
    GUI.elms.slider_Blue:redraw()
		
end

--====================================
  --------   SCRIPT FLOW   --------
--====================================
--zzflow
--[==[
> Script load.
  Must save user themes in reaper ext state so they are 
    available to other scripts.
      reaper.SetExtState("dh_Toolkit", "user_themes", user_theme, true)
  window settings are also saved to reaper ext state
    (that includes w, h, scale, and theme).
      reaper.SetExtState("dh_Template", "window_settings", true)
  ? ThemeDesigner needs to save to reaper ext state as it is project independent.

> Setting a theme starts design process.

-- Set theme --
Put theme name in tbx_UserThemeNameName.
  This is name that will be used when saving theme.
  If name exists prompt to save theme or change name.
  ? Autosave theme on script exit? Can use name autosave?
  Copy colors to EDIT_COLORS. Are they 0-255 or 0-1?
  Theme is loaded. GUI.colors contain theme colors.
      
-- Now I want to edit colors --
Select color_name from mbx_ColorNames.
  Update lbx_ColorUses to display pertinent element color fields.
  Update frm_StartColor with GUI.colors[color_name].
  Update frm_NewColor with GUI.colors[color_name].
    
-- Use sliders to adjust new color --
Update slider readout.
Update frm_NewColor.
  GUI.colors[new_name] = <newcolor>
      
Click frm_NewColor to update theme with new color. Updates GUI.
  GUI.colors[color_name] = <new_color>
    
Click frm_StartColor to update theme with start color. Updates GUI.
      
Click btn_MoveColor to copy new color to frm_StartColor. No going back.
    
Click btn_SetThemeClick will reset current pending theme.
--]==]

--====================================
  --------      EXIT      --------
--====================================
--zzexit  
-- Code to execute before window closes, such as saving states and window position.

local function Exit()
    DHTK.saveWindowSettings()
end 

-- Calls Exit when script is ending.
reaper.atexit(Exit)

--====================================
  ------  Script Initialize  ------
--====================================
--zzinit 
----------------------------------------
--  Initialize GUI Elements
--  Done here - after element creation
----------------------------------------
--[[ DEV NOTE: Necessary!!! ]]--
DHTK.init_scale_elms()

-- Reassign button click function.
GUI.elms["btn_SetTheme"].func = btn_SetThemeClick

-- Layers to hide at script start.
GUI.elms_hide[65] = true
GUI.elms_hide[66] = true

--GUI.elms.mbx_ColorNames.optarray = COLOR_NAMES
GUI.Val("mbx_ColorNames", 1)

GUI.elms.lbx_ColorUses.list = COLOR_USES["wnd_bg"]

-- ??? May need verification.
if DHTK.window_settings.theme == "User" then
    GUI.Val("tbx_UserThemeName", DHTK.window_settings.user_theme)
else
    GUI.Val("tbx_UserThemeName", DHTK.window_settings.theme)
end

-- Set color frames colors.
GUI.colors.start_color = dhth.set_color(GUI.colors.wnd_bg)
GUI.colors.new_color = dhth.set_color(GUI.colors.wnd_bg)

-- Update sliders
-- GUI not yet initialized so no need to convert values.

GUI.Val("slider_Red", GUI.colors.start_color[1])
GUI.Val("slider_Green", GUI.colors.start_color[2])
GUI.Val("slider_Blue", GUI.colors.start_color[3])

-------------------------------
--   Non GUI Initialization
-------------------------------


--======================================
  ------   MAIN LOOP <dhMain>   ------
--======================================
--zzmain  	
--[==[ 
  Gleaned from core.lua

  GUI.Main is run on every update loop of the GUI script; anything you would put
    inside a reaper.defer() loop should go here in dhMain. 
    The function name doesn't matter, I use dhMain.
      
  GUI.Main calls:
     GUI.Main_Update_State() checks if script window w or h changed:
       Yes: updates GUI.cur_w and GUI.cur_h, sets GUI.resized = true,
         and calls GUI.onresize().
       No: sets GUI.resized = false
     GUI.Main_Update_Elms()
       Iterates GUI.elms_list in reverse z-order updating each elm.
   > Runs user function <dhMain> if defined.
     GUI.Main_Draw()
       Checks if script asked for anything to be redrawn.
         If yes, redraws all non-hidden layers in reverse z-order.
--]==]

local function dhMain()

	if GUI.resized then
        -- If the window's size has been changed, reopen it
        -- at the current position with the size we specified.	
		local __,x,y,w,h = gfx.dock(-1,0,0,0,0)
		gfx.quit()
		gfx.init(GUI.name, GUI.w, GUI.h, 0, x, y)
		GUI.redraw_z[0] = true
	end
    
end  --<dhMain>

-- Open the script window and initialize a few things.
GUI.Init()

-- Tell the GUI library to run dhMain on each update loop.
-- Individual elements are updated first, then GUI.func is run, then the GUI is redrawn.
GUI.func = dhMain

-- How often (in seconds) to run GUI.func. 0 = every loop.
GUI.freq = 0

-- Start the main loop
GUI.Main()

--zzend