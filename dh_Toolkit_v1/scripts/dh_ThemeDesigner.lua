--dh_ThemeDesigner.lua 
-- version 1.0
-- Author: Dennis R. Horn
-- Date: 20260330

------------------------------------------------------------
-- Copyright (c) 2025 Dennis R. Horn
-- License: GNU General Public License version 3

-- Uses Lokasenna_GUI v2 for widgets and interactivity:
-- https://github.com/jalovatt/Lokasenna_GUI

-- Uses json.lua for encoding/decoding data to/from ext state:
-- https://github.com/rxi/json.lua

------------------------------------------------------------
-- DISCLAIMER: This script has been tested on Reaper 6.23 
--   running on Windows 10-x64 with no issues. 
--   The author is not responsible for any loss of data that
--   may result in the event that the script crashes Reaper.

------------------------------------------------------------
-- DESCRIPTION:

-- Design user themes for scripts using Lokasenna_GUI v2 and dh_Toolkit.

------------------------------------------------------------
--CHANGELOG:
-- 2025-04-30 Added chkl_AutoSaveOnExit. Renamed to chkl_SaveToConsole. Used for development.
--            During development it is used to allow writing formatted theme to console.
--            Several bug fixes.
-- 2025-05-12 Added tab for colors. Click on color to update tools panel.
-- 2025-06-20 Revised saving and loading of current edit state.
-- 2025-08-28 Many tweaks, improvements, and bug fixes.
-- 2026-02-04 Many tweaks, improvements, and bug fixes.

------------------------------------------------------------
-- CONVENTIONS USED:
--   camelCase used for var and function names pertaining to GUI.
--   snake_case used for other var and function names.
--   Element names prefixed with a designation denoting type of class.
--   Comments starting with --zz are bookmarks.
--   Code between --<<< and -->>> denotes optional code used as example, or to be deleted.
--   Comments starting with --!!! denote needs attention or importance.
--   Comments starting with --??? denote question about code.
--   Comments starting with --xxx denote code to toggle for testing, or to delete.
--   Block comments --[==[ denote info or notes.
--   Block comments --[===[ denote documentaion.

--zztop
---------------------------------------
  --------      TODO      --------
---------------------------------------
--zztodo
-- Tried moving menubar menus to dh_ThemeDesigner_data.lua,
--   but couldn't get menu functions to execute.

---------------------------------------
  --------      NOTES      --------
---------------------------------------
-- DHTK.window_settings.theme will always have the name of the last selected theme - for this script.
-- DHTK.window_settings.user_theme will always have the name of the last selected theme
--  or nil if none exists. This only gets set when saving, renaming, or deleting a theme. 
-- Some of the core mouse events pertaining to the Preferences window (Tab 1) were overridden.


--====================================
-- dh_log (used during development)
--====================================
-- Disable all console messages by setting this to false. 
local dh_log_active = false

function dh_log(msg)
	if dh_log_active then
		reaper.ShowConsoleMsg(msg .. "\n")
	end
end

--!!! Disable for deployment.
--reaper.ClearConsole()
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
GUI.req("Classes/Class - Knob.lua")()
GUI.req("Classes/Class - Frame.lua")()
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

-- Lighten up shadow color?
-- GUI.colors["shadow"] = {0,0,0,32}

--====================================
-- dh_Toolkit requirements 
--====================================
-- Adds current directory to path.

-- Can use this if script is in dh_Toolkit directory.
local script_folder = debug.getinfo(1).source:match("@?(.*[\\|/])")
--GUI.Msg("script_folder : " .. script_folder)
--reaper.ShowConsoleMsg("script_folder : ")
package.path = package.path .. ";" .. script_folder .. "?.lua"

-- Use this when scripts are not in dh_Toolkit directory.
-- Must have run "Set dh_Toolkit v1 library path.lua" first to set path to reaper ext state. 
local dhtk_path = reaper.GetExtState("dh_Toolkit", "lib_path_v1")
if not dhtk_path or dhtk_path == "" then
    reaper.MB("Couldn't load dh_Toolkit. Please install 'dh_Toolkit v1 for Lua', available on ReaPack, then run the 'Set dh_Toolkit v1 library path.lua' script in your Action List.", "Whoops!", 0)
    return
end

package.path = package.path .. ";" .. dhtk_path .. "?.lua"

-- !!! Load GUI.overrides.
require "common/GUI_overrides"

-----------------------------------------
DHTK = require "common/dh_Toolkit_core"
-----------------------------------------
-- Set to true if script uses dh_Toolkit Prefs window.
-- Set to false if script handles Prefs in its own way (as with GUI Builder).)
DHTK.USE_DHTK_PREFS = true

DHTK.EXT_STATE_NAME = "dh_ThemeDesigner"

-- Script window dimensions at 1.00x scale.
DHTK.APP_WIDTH = 640
DHTK.APP_HEIGHT = 640
DHTK.PREFS_HEIGHT = 300 -- Set same as TOOLS_TOP
--------------------------------------------
-- dh_Toolkit classes (Modified Lokasenna's classes).

require "classes/dh_Button"
require "classes/dh_Knob"
require "classes/dh_Label"
require "classes/dh_Listbox"
require "classes/dh_Menubar"
require "classes/dh_Menubox"
require "classes/dh_Options"
require "classes/dh_Panel"
require "classes/dh_Slider_H"
require "classes/dh_Tabs"
require "classes/dh_Textbox"
require "classes/dh_TextEditor"
--------------------------------------
-- !!! Necessary. Must be after req dh_Options
DHTK.init_DHTK()
--------------------------------------
local dhth = require "common/dh_Toolkit_themes"
local dhtd = require "dh_ThemeDesigner_data"
local json = require "common/json"
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
--zzthemes 

local DH_THEMES = dhth.DH_THEMES
local DH_THEME_NAMES = dhth.DH_THEME_NAMES

-- The whole purpose of this script.
-- Fetched in "Window Settings" so the elements know what colors to use.
-- This is available because dh_Toolkit has been initialized.
local USER_THEMES = DHTK.USER_THEMES

-- For menubox display. 
-- Populated before element creation (in "Window Settings")
local USER_THEME_NAMES = DHTK.USER_THEME_NAMES

-- Used to reset colors to previous state. 
local START_COLORS = {}

--local COLOR_NAMES = {}    -- Display in menubox
local COLOR_NAMES = dhth.COLOR_NAMES
local COLOR_DISPLAY_NAMES = dhtd.COLOR_DISPLAY_NAMES
local COLOR_USES = dhtd.COLOR_USES

-- Add GUI colors for display panels and checkboxes.
GUI.colors["start_color"] = {0,0,0,255}
GUI.colors["new_color"] = {0,0,0,255}
GUI.colors["light_gray"] = {224,224,224,255}
GUI.colors["dark_gray"] = {96,96,96,255}
GUI.colors["copy_color"] = {96,96,96,255}

--------------------------------------
--zztab2

TAB2_UPDATE_ELMS = {
    "menu_Tab2_Lokasenna",
    "radio_Tab2_Properties",
    "tabs_Tab2",
    "frm_Tab2_Elements",
    "lbl_Tab2_Elements",
    "mbx_Tab2",
    "lbx_Tab2",
    "knob_Tab2",
    "btn_Tab2",
    "slider_Tab2",
    "tabs_Tab2",
    "tbx_Tab2",
    "txe_Tab2",
}

local tab2_property_assignments = dhtd.tab2_property_assignments
local tab2_display_assignments = dhtd.tab2_display_assignments

-- Elements to update when panel background changes.
TAB3_UPDATE_ELMS = {
    "menu_Tab3_Toolkit",
    "radio_Tab3_BG",
    "chkl_Tab3_UseOutline",
    "pnl_Tab3_Elements",
    "lbl_Tab3_Elements",
    "mbx_Tab3",
    "lbx_Tab3",
    "knob_Tab3",
    "btn_Tab3",
    "lbl_SelAlpha",
    "lbl_SelAlphaVal",
    "slider_SelAlpha",
    "tbx_Tab3",
    "txe_Tab3",
}

-- Elements to update when changing frame outlines.
local UPDATE_OUTLINE_ELMS = {
    "knob_Tab3",  -- this doesn't have col_backdrop
    "mbx_Tab3",
    "lbx_Tab3",
    "tbx_Tab3",
    "txe_Tab3",
    "slider_SelAlpha",
    
    "mbx_ColorNames",
    "lbx_ColorUses",    
    "slider_Red",
    "slider_Green",
    "slider_Blue",
}

local TAB3_TEXT_ELMS = {
    "mbx_Tab3",
    "lbx_Tab3",
    "tbx_Tab3",
    "txe_Tab3",
}

-- Elements to update when changing highlighted selected text values.
local SEL_TEXT_ELMS = {
    "tbx_UserThemeName",
    --"lbx_Tab3",
    --"tbx_Tab3",
    --"txe_Tab3",
    "lbx_ColorUses",
}

local SLIDER_ELMS = {
    "slider_SelAlpha",
    "slider_Red",
    "slider_Green",
    "slider_Blue",
}
    
local tab3_property_assignments = dhtd.tab3_property_assignments
local tab3_display_assignments = dhtd.tab3_display_assignments

--====================================
  ------     My Functions    ------
--====================================
--zzfunc
-- Functions called from within functions that are initiated by an element action, e.g.,button click,
-- (Need to be here before elements creation.)

local function dh_save_user_themes_ext()
    local json_string = json.encode(USER_THEMES)
    reaper.SetExtState("dh_Toolkit", "user-themes", json_string, true)
    
    --xxx FOR TESTING, not to overwrite existing.
    --reaper.SetExtState("dh_Toolkit", "user-themes-test", json_string, true)
    
end

--zzsave
local function saveUserTheme()

    local isReplacing = false    

    -- # Get name for user theme from tbx_UserThemeName.
    local retval, new_name = DHTK.validate_name(GUI.Val("tbx_UserThemeName"))
    
    if not retval then return end

    if USER_THEMES[new_name] then
        local retval reaper.MB("User theme name already exists.\n Do you want to overwrite it?", "Warning!", 4)
        if retval == 5 then
            return 
        else    
            isReplacing = true    
        end
    end
    
    -- # Build theme

    local new_theme = {}

    for _, col_name in ipairs(dhth.COLOR_NAMES) do
        new_theme[col_name] = {}
        
        local col = GUI.colors[col_name]
        new_theme[col_name][1] = math.floor((col[1] * 255) + 0.5)
        new_theme[col_name][2] = math.floor((col[2] * 255) + 0.5)
        new_theme[col_name][3] = math.floor((col[3] * 255) + 0.5)
        new_theme[col_name][4] = math.floor((col[4] * 255) + 0.5)
        
    end    
    
    USER_THEMES[new_name] = new_theme
    
    -- # Sort names
    
    if not isReplacing then
        table.insert(USER_THEME_NAMES, new_name)
        table.sort(USER_THEME_NAMES)
    end
    
    local idx = DHTK.table_index_from_value(USER_THEME_NAMES, new_name)
    GUI.Val("mbx_UserThemes", idx)
    
    DHTK.window_settings.user_theme = new_name
    
    -- # If checked then write formatted theme to console.
        
    if GUI.Val("chkl_SaveToConsole") then
        local msg = "    " .. new_name .. " = {\n"
        for i, col_name in ipairs(COLOR_NAMES) do
            --local fmsg = "        " .. col_name .. " = {" .. new_theme[col_name][1] .. ", " .. new_theme[col_name][2] .. ", " .. new_theme[col_name][3] .. ", " .. new_theme[col_name][4] .. "},\n"             
            local fmsg = "        " .. col_name .. " = {" .. GUI.clamp(new_theme[col_name][1],0,255) .. ", " .. GUI.clamp(new_theme[col_name][2],0,255) .. ", " .. GUI.clamp(new_theme[col_name][3],0,255) .. ", " .. GUI.clamp(new_theme[col_name][4],0,255) .. "},\n"                         
            msg = msg .. fmsg
        end
        msg = msg .. "    },"
        GUI.Msg(msg)    
    end 

    dh_save_user_themes_ext()
    
end --<save_user_theme>

--====================================
  -----   Element Functions   -----
--====================================
--zzelem  
-- Functions called by element actions, e.g.,button click.
-- (Needs to be here before elements creation.)
-- Some of this is duplication of core setTheme().
-- Theme is selected from either mbx_dhThemes or mbx_UserThemes.
--zzz
local function setTheme(theme_type)

    GUI.Msg("## setTheme:  ")
    
    if theme_type == "user" then
        local theme_index, theme_name = GUI.Val("mbx_UserThemes")
        DHTK.window_settings.theme = "User"
        DHTK.window_settings.user_theme = theme_name
        GUI.Val("tbx_UserThemeName", theme_name)
        dhth.set_theme(USER_THEMES[theme_name], true)
    
    else  
        local theme_index, theme_name = GUI.Val("mbx_dhThemes")
        DHTK.window_settings.theme = theme_name
        GUI.Val("tbx_UserThemeName", theme_name)
        dhth.set_theme(DH_THEMES[theme_name], true)
    
    end
    
    -------------------------------    
    -- # Update vars and gui.
    -------------------------------   
    
    -- Populate with decimal colors from GUI.colors.
    START_COLORS = {}

    for _, col_name in ipairs(COLOR_NAMES) do
        START_COLORS[col_name] = dhth.set_color(GUI.colors[col_name])
    end

    -- Update color elements.
    GUI.Val("mbx_ColorNames", 1)
    GUI.elms.lbx_ColorUses.list = COLOR_USES["wnd_bg"]
        
    GUI.colors.start_color = dhth.set_color(GUI.colors.wnd_bg)
    GUI.colors.new_color = dhth.set_color(GUI.colors.wnd_bg)

    GUI.elms.chkl_Tab3_UseOutline.optsel[1] = (GUI.colors.metadata[4] < 0.001) or false

    -------------------------------
    -- Update sliders and value labels.
    -------------------------------    
    local colval = math.floor((GUI.colors.start_color[1] * 255) + 0.5)
    GUI.Val("slider_Red", colval)
    local colval = math.floor((GUI.colors.start_color[2] * 255) + 0.5)
    GUI.Val("slider_Green", colval)
    local colval = math.floor((GUI.colors.start_color[3] * 255) + 0.5)
    GUI.Val("slider_Blue", colval)
    
    -------------------------------
    -- Update sel_alpha slider --
    -------------------------------                   
    local sel_alpha_val

    if GUI.colors.sel_txt then
        -- alpha is in decimal format.
        sel_alpha_val = math.floor(GUI.colors.sel_txt[4] * 10 + 0.5)
    else
        sel_alpha_val = 5
    end

--zzsel    
    GUI.elms.lbl_SelAlphaVal.text = tostring(sel_alpha_val) 
    GUI.Val("slider_SelAlpha", sel_alpha_val)
            
    ----------------------------          
    -- Update GUI --
    ----------------------------              
    -- GUI.MainDraw doesn't draw hidden layers.
    --GUI.update_elms_list(true)
	--GUI.redraw_z[0] = true    

	for key, __ in pairs(GUI.elms) do
        GUI.elms[key]:init()
        GUI.elms[key]:redraw()
    end    

end --<setTheme>

-- Delete user theme.
-- Will delete theme and theme name listed in mbx_UserThemes.
-- ? If will not affect the theme editing in progress.

local function deleteUserTheme()

    -- # Do not delete if it's the only user theme.
    if #USER_THEME_NAMES == 1 then
        reaper.MB("Cannot delete the only user theme!", "Error!", 0)
        return
    end

    -- # Prompt when deleting a theme.
    local msg = "Are you sure you want to delete selected user theme?"
                   
    local retval = reaper.ShowMessageBox(msg, "Warning", 4)	-- retval 6 is yes							

    -- OK. Proceed.
    
    if retval == 6 then

        -- # Get user theme index and name.
        local ut_idx, ut_name = GUI.Val("mbx_UserThemes")
        
        table.remove(USER_THEME_NAMES, ut_idx)
        USER_THEMES[ut_name] = nil
        
        if ut_idx > #USER_THEME_NAMES then
            ut_idx = #USER_THEME_NAMES
        end
        
        GUI.Val("mbx_UserThemes", ut_idx)
        
        GUI.Val("tbx_UserThemeName", USER_THEME_NAMES[ut_idx]) 
        
        --??? Don't think I need to redraw mbx.
        
        DHTK.window_settings.user_theme = USER_THEME_NAMES[ut_idx]

        dh_save_user_themes_ext()

        setTheme("user")
        
    end

end --<deleteUserTheme>

-- Rename the user theme listed in menubox with the name displayed in textbox.
-- If theme is currently loaded it will not affect theme in progress,
-- although user theme no longer available as a starting point
-- until it is again saved.

local function renameUserTheme()
    
    -- # Get user theme name.
    if #GUI.elms.mbx_UserThemes.optarray == 0 then
        reaper.MB("No User theme to rename.", "Error!", 0)
        return
    else
        local retval reaper.MB("Attempting to rename user theme. Continue?", "Warning!", 4)
        if retval == 5 then return end
    end
        
    local mbx_idx, mbx_name = GUI.Val("mbx_UserThemes")
    
    -- # Get new name.
    local retval, tbx_name = DHTK.validate_name(GUI.Val("tbx_UserThemeName"))
    
    if not retval then return end
    
    if mbx_name == tbx_name then
        reaper.MB("New Name is same as existing name.", "Error!", 0)
        return
    end
    
    -- # Update names list.
    table.remove(USER_THEME_NAMES, mbx_idx)
    table.insert(USER_THEME_NAMES, tbx_name)
    table.sort(USER_THEME_NAMES)

    -- # Select renamed theme.
    mbx_idx = DHTK.table_index_from_value(USER_THEME_NAMES, tbx_name)
    
    GUI.Val("mbx_UserThemes", mbx_idx)
    
    DHTK.window_settings.user_theme = tbx_name
     
    -- # Update themes tables.
    USER_THEMES[tbx_name] = USER_THEMES[mbx_name]
    USER_THEMES[mbx_name] = nil
    
    dh_save_user_themes_ext()

end --<renameUserTheme>

-------------------------------------------------------

-- Set pnl_NewColor.col_bg to start_color.
local function btn_ResetColorClick()

    if GUI.elms.btn_ResetColor.expanded then    
        GUI.elms_hide[62] = true
        GUI.elms_hide[63] = true
        GUI.elms.btn_ResetColor.expanded = false
    else
        GUI.elms_hide[62] = false
        GUI.elms_hide[63] = false
        GUI.elms.btn_ResetColor.expanded = true    
    end
    
    GUI.elms_hide[65] = true
    GUI.elms_hide[66] = true
    GUI.elms.btn_SaveColor.expanded = false
    
end

local function btn_CancelResetColorClick()
    GUI.elms_hide[62] = true
    GUI.elms_hide[63] = true
    GUI.elms.btn_ResetColor.expanded = false
end

local function btn_ConfirmResetColorClick()

    GUI.colors.new_color = dhth.set_color(GUI.colors.start_color)
    GUI.elms.pnl_NewColor:init()
    GUI.elms.pnl_NewColor:redraw()
    GUI.elms_hide[62] = true
    GUI.elms_hide[63] = true
    GUI.elms.btn_ResetColor.expanded = false
    
    -- Update sliders and value labels.
    local colval = math.floor((GUI.colors.start_color[1] * 255) + 0.5)
    GUI.Val("slider_Red", colval)
    GUI.elms.slider_Red:redraw()
    
    colval = math.floor((GUI.colors.start_color[2] * 255) + 0.5)
    GUI.Val("slider_Green", colval)
    GUI.elms.slider_Green:redraw()
    
    colval = math.floor((GUI.colors.start_color[3] * 255) + 0.5)
    GUI.Val("slider_Blue", colval)
    GUI.elms.slider_Blue:redraw()
        
end

------------------------------------------------------
-- Set pnl_StartColor.col_bg to new_color.
local function btn_SaveColorClick()

    if GUI.elms.btn_SaveColor.expanded then    
        GUI.elms_hide[65] = true
        GUI.elms_hide[66] = true
        GUI.elms.btn_SaveColor.expanded = false
    else
        GUI.elms_hide[65] = false
        GUI.elms_hide[66] = false
        GUI.elms.btn_SaveColor.expanded = true    
    end    
    
    GUI.elms_hide[62] = true
    GUI.elms_hide[63] = true    
    GUI.elms.btn_ResetColor.expanded = false    
end

local function btn_CancelSaveColorClick()
    GUI.elms_hide[65] = true
    GUI.elms_hide[66] = true
    GUI.elms.btn_SaveColor.expanded = false
end

local function btn_ConfirmSaveColorClick()

    GUI.colors.start_color = dhth.set_color(GUI.colors.new_color)

    -- Menubox previously had list of COLOR_NAMES.
    -- Now has list of COLOR_DISPLAY_NAMES.
    --local _, col_name = GUI.Val("mbx_ColorNames")
    
    local col_idx, _ = GUI.Val("mbx_ColorNames")
	local col_name = COLOR_NAMES[col_idx]
	    
    START_COLORS[col_name] = dhth.set_color(GUI.colors.new_color)
    GUI.elms.pnl_StartColor:init()
    GUI.elms.pnl_StartColor:redraw()
    GUI.elms_hide[65] = true
    GUI.elms_hide[66] = true
    GUI.elms.btn_SaveColor.expanded = false
end

local function btn_ClosePropertyAssignmentsClick()
    GUI.elms_hide[1] = true
    GUI.elms_hide[2] = true
    GUI.elms_hide[3] = true
end

-----------------------------------
--   Tab2 Menu functions    --
-----------------------------------
--zztab2    
local function update_tab2_elms(params)

    local elm_name, prop_name, prop_val, assign_name = table.unpack(params)
    
    --[[  
    GUI.Msg("--------------------------------")
    GUI.Msg("update_tab2_elms elm_name is : " .. elm_name)
    GUI.Msg("update_tab2_elms prop_name is : " .. prop_name)    
    GUI.Msg("update_tab2_elms prop_val is : " .. tostring(prop_val))    
    GUI.Msg("update_tab2_elms assign_name is : " .. assign_name)
    --]]
    
    -- ELEMENT TEXT: updates listbox, menubox, textbox, and texteditor.
    if assign_name == "element_text" then
    
        tab2_property_assignments["element_text"][2] = prop_val

        if GUI.Val("radio_Tab2_Properties") == 2 then  
            GUI.elms.lbx_Tab2.color = prop_val
            GUI.elms.lbx_Tab2:init()
            GUI.elms.lbx_Tab2:redraw()
            GUI.elms.mbx_Tab2.col_txt = prop_val
            GUI.elms.mbx_Tab2:init()
            GUI.elms.mbx_Tab2:redraw() 
            GUI.elms.tbx_Tab2.color = prop_val       
            GUI.elms.tbx_Tab2:init()
            GUI.elms.tbx_Tab2:redraw()
            GUI.elms.txe_Tab2.color = prop_val
            GUI.elms.txe_Tab2:init()
            GUI.elms.txe_Tab2:redraw()                                
        end                    
    
        return
    end    

    -- SCROLLBAR THUMB: updates listbox and menubox.
    if assign_name == "scrollbar_thumb" then
    
        tab2_property_assignments["scrollbar_thumb"][2] = prop_val

        if GUI.Val("radio_Tab2_Properties") == 2 then  
            GUI.elms.lbx_Tab2.col_fill = prop_val
            GUI.elms.lbx_Tab2:init()
            GUI.elms.lbx_Tab2:redraw()
            GUI.elms.txe_Tab2.col_fill = prop_val
            GUI.elms.txe_Tab2:init()
            GUI.elms.txe_Tab2:redraw()
        end  
        
        return      
    end

    -- FRAME_TEXT updates label, knob, and slider.
    if assign_name == "frame_text" then
    
        tab2_property_assignments["frame_text"][2] = prop_val

        if GUI.Val("radio_Tab2_Properties") == 2 then
            GUI.elms.lbl_Tab2_Elements.color = prop_val
            GUI.elms.lbl_Tab2_Elements:init()
            GUI.elms.lbl_Tab2_Elements:redraw()  
            GUI.elms.knob_Tab2.col_txt = prop_val
            GUI.elms.knob_Tab2:init()
            GUI.elms.knob_Tab2:redraw() 
            GUI.elms.slider_Tab2.col_txt = prop_val
            GUI.elms.slider_Tab2:init()
            GUI.elms.slider_Tab2:redraw()
        end
        
        return
    end

    -- FRAME_BG updates frame, label, knob, and slider.
    if assign_name == "frame_bg" then
    
        tab2_property_assignments["frame_bg"][2] = prop_val
        
        -- If fill is true will use frame.color 
        -- so don't update display here.
        if GUI.elms.frm_Tab2_Elements.fill == true then
            return
        end
            
        if GUI.Val("radio_Tab2_Properties") == 2 then
            GUI.elms.frm_Tab2_Elements.bg = prop_val
            GUI.elms.frm_Tab2_Elements:init()
            GUI.elms.frm_Tab2_Elements:redraw()
            GUI.elms.lbl_Tab2_Elements.bg = prop_val
            GUI.elms.lbl_Tab2_Elements:init()
            GUI.elms.lbl_Tab2_Elements:redraw()  
            GUI.elms.knob_Tab2.bg = prop_val
            GUI.elms.knob_Tab2:init()
            GUI.elms.knob_Tab2:redraw() 
            GUI.elms.slider_Tab2.bg = prop_val
            GUI.elms.slider_Tab2:init()
            GUI.elms.slider_Tab2:redraw()
        end
        
        return
    end

    -- FRAME_COLOR updates frame, label, knob, and slider,
    -- but only if fill is true, otherwise bg doesn't change.
    -- Does not update text colors.
    
    if assign_name == "frame_color" then
    
        tab2_property_assignments["frame_color"][2] = prop_val
                
        -- If fill is false then frame is using frame.bg 

        if GUI.Val("radio_Tab2_Properties") == 2 then

            -- Update frame.
            GUI.elms.frm_Tab2_Elements.color = prop_val
            GUI.elms.frm_Tab2_Elements:init()
            GUI.elms.frm_Tab2_Elements:redraw()
            
            -- Update label, knob, or slider,
            -- but only if frame is filled. 
            if GUI.elms.frm_Tab2_Elements.fill == true then
                GUI.elms.lbl_Tab2_Elements.bg = prop_val
                GUI.elms.lbl_Tab2_Elements:init()
                GUI.elms.lbl_Tab2_Elements:redraw()        
                GUI.elms.knob_Tab2.bg = prop_val
                GUI.elms.knob_Tab2:init()
                GUI.elms.knob_Tab2:redraw()                
                GUI.elms.slider_Tab2.bg = prop_val
                GUI.elms.slider_Tab2:init()
                GUI.elms.slider_Tab2:redraw()
            end
        
        end

        return
    end

    -- FRAME_FILL affects bg of frame, label, knob, and slider.
    -- If filled it uses frame.color, unfilled uses frame.bg.
    
    if assign_name == "frame_fill" then
    
        tab2_property_assignments["frame_fill"][2] = prop_val
        
        if GUI.Val("radio_Tab2_Properties") == 2 then

            local bg_color
            if prop_val == true then
                bg_color = tab2_property_assignments["frame_color"][2]            
            else
                bg_color = tab2_property_assignments["frame_bg"][2]            
            end

            GUI.elms.frm_Tab2_Elements:init()
            GUI.elms.frm_Tab2_Elements:redraw()
            GUI.elms.lbl_Tab2_Elements.bg = bg_color
            GUI.elms.lbl_Tab2_Elements:init()
            GUI.elms.lbl_Tab2_Elements:redraw() 
            GUI.elms.knob_Tab2.bg = bg_color       
            GUI.elms.knob_Tab2:init()
            GUI.elms.knob_Tab2:redraw() 
            GUI.elms.slider_Tab2.bg = bg_color               
            GUI.elms.slider_Tab2:init()
            GUI.elms.slider_Tab2:redraw()
        end 
           
        return
    end    

    -- GENERAL UPDATES:
    tab2_property_assignments[assign_name][2] = prop_val

    if GUI.Val("radio_Tab2_Properties") == 2 then 
        GUI.elms[elm_name][prop_name] = prop_val
        GUI.elms[elm_name]:init()
        GUI.elms[elm_name]:redraw()
    end

end

--zztab2  
local function show_tab2_props_in_panel()
    --GUI.Msg("show_tab2_props_in_panel")
    local list = {}
    --          "Tab text:                col_txt       -> color"
    local str = "Class   attribute:       property      -> value"
    table.insert(list, str)
    table.insert(list, " ")
    
    --GUI.Msg("radio_Tab2_Properties val is : " .. GUI.Val("radio_Tab2_Properties"))
    --GUI.Msg("radio_Tab2_Properties default is : " .. tostring(tab2_defaults["menubar_bg"]))
    --GUI.Msg("radio_Tab2_Properties override is : " .. tostring(tab2_property_assignments["menubar_bg"]))

    if GUI.Val("radio_Tab2_Properties") == 1 then
    
        --GUI.Msg("in radio_Tab2_Properties DEFAULT")
        for _, assigned in ipairs(tab2_display_assignments) do
        
            --          display string              default value
            local item = assigned[2] .. tostring(tab2_property_assignments[assigned[1]][1])
            table.insert(list, item)

        end
    else
        --GUI.Msg("in radio_Tab2_Properties OVERRIDES")

        for _, assigned in ipairs(tab2_display_assignments) do
            --          display string              overridden value                
            local item = assigned[2] .. tostring(tab2_property_assignments[assigned[1]][2])
            table.insert(list, item)
            --GUI.Msg(item)
        end        
    end        

    table.insert(list, " ")
    table.insert(list, "  * Listbox, Textbox, and TextEditor use 'color'.")
    table.insert(list, "    Menubox uses 'col_txt'.")
    table.insert(list, " ** Pointer and Highlighted Value text color.")
    table.insert(list, "*** Scrollbar in Listbox and TextEditor.")    

    GUI.elms.lbl_PropertyAssignments.text = "Lokasenna Assignments:"
    GUI.elms.lbl_PropertyAssignments:init()
    GUI.elms.lbl_PropertyAssignments:redraw()
    
    GUI.elms.lbx_PropertyAssignments.list = list
    GUI.elms.lbx_PropertyAssignments.wnd_y = 1    
    GUI.elms.lbx_PropertyAssignments:init()
    GUI.elms.lbx_PropertyAssignments:redraw()

    GUI.elms_hide[1] = false
    GUI.elms_hide[2] = false
    GUI.elms_hide[3] = false

end

local function show_tab2_props_in_console()

    GUI.Msg("\nCurrent Tab2 property assignments")
    GUI.Msg("Class   attribute:   property     -> value\n")    
    for _, assigned in ipairs(tab2_display_assignments) do
        GUI.Msg(assigned[2] .. tostring(tab2_property_assignments[assigned[1]][2]))
    end
    
    GUI.Msg(" ")    
    GUI.Msg("  * Listbox, Textbox, and TextEditor use 'color'.")
    GUI.Msg("    Menubox uses 'col_txt'.")
    GUI.Msg(" ** Pointer and Highlighted Value text color.")
    GUI.Msg("*** Scrollbar in Listbox and TextEditor.")     

end

-----------------------------------
--   Tab3 Menu functions    --
-----------------------------------
--zzupdate
-- Sometimes need to compensate for multiple elms that need updating,
-- since only one elm name passed in as parameter.
-- Maybe: Alternately can pass in a list of elm names.

local function update_tab3_elms(params)

    local elm_name, prop_name, prop_val, assign_name = table.unpack(params)
    
    --GUI.Msg("--------------------------------")
    --if elm_name then GUI.Msg("update_tab3_elms elm_name is : " .. elm_name) end
    --if prop_name then GUI.Msg("update_tab3_elms prop_name is : " .. prop_name) end    
    --if prop_val then GUI.Msg("update_tab3_elms prop_val is : " .. tostring(prop_val)) end    
    --if assign_name then GUI.Msg("update_tab3_elms assign_name is : " .. assign_name) end

    if elm_name == "slider_SelAlpha" and
       assignname ~= "slider_thickness"
    then
        tab3_property_assignments["slider_thumb"][2] = prop_val
    
        for _, elm in ipairs(SLIDER_ELMS) do
            GUI.elms[elm].col_thumb = prop_val
            GUI.elms[elm]:init()
            GUI.elms[elm]:redraw()
        end
             
        return
    end

    -- # SLIDER THICKNESS
    --!!! Need to scale thk (and h?).            
    -- Calculate here, update at end.
    if assign_name == "slider_thickness" then
        local scaled_thk = math.tointeger(prop_val * tonumber(DHTK.window_settings.scale))
        GUI.elms.slider_SelAlpha.track_thk = scaled_thk
        --GUI.elms.slider_SelAlpha.h = scaled_thk
    end
    
    -- # OPTIONS: update both radio boxes.
    if assign_name == "radio_font" then

        tab3_property_assignments["radio_font"][2] = prop_val
          
        GUI.elms.radio_Tab3_BG["font_text"] = prop_val
        GUI.elms.radio_Tab3_BG:init()
        GUI.elms.radio_Tab3_BG:redraw()

        GUI.elms.chkl_Tab3_UseOutline["font_text"] = prop_val
        GUI.elms.chkl_Tab3_UseOutline:init()
        GUI.elms.chkl_Tab3_UseOutline:redraw()
          
        return
    end
    
    -- Update text editor and listbox scrollbars.
    if string.match(assign_name, "scrollbar") then
    
        tab3_property_assignments[assign_name][2] = prop_val

        GUI.elms.lbx_Tab3[prop_name] = prop_val
        GUI.elms.lbx_Tab3:init()
        GUI.elms.lbx_Tab3:redraw()
        GUI.elms.txe_Tab3[prop_name] = prop_val
        GUI.elms.txe_Tab3:init()
        GUI.elms.txe_Tab3:redraw()
        
        return
    end
    
    -- Update the text elements.
    if string.match(assign_name, "element") then
                        
        -- Get associated text color.
        if assign_name == "element_bg" then
            
            local text_col_val               
               
            if (prop_val == "elm_bg") then
                text_col_val = "elm_txt"
            elseif (prop_val == "panel_bg") then
                text_col_val = "panel_txt"
            else
                text_col_val = "btn_txt"                      
            end
            
            tab3_property_assignments.element_bg[2] = prop_val               
            tab3_property_assignments.element_text[2] = text_col_val

        end

        if assign_name == "element_sel_text" then
            tab3_property_assignments.element_sel_text[2] = prop_val                            
        end
        
        if assign_name == "element_sel_alpha" then
            tab3_property_assignments.element_sel_alpha[2] = prop_val                            
        end        

        for _, elm_name in ipairs(TAB3_TEXT_ELMS) do
                                    
            -- Menubox doesn't have selected text.                        
            if (elm_name == "mbx_Tab3") 
                and ((assign_name == "element_sel_text") or (assign_name == "element_sel_alpha")) then
                goto next
            end
            
            --GUI.Msg("\nTAB3_TEXT_ELMS : " .. elm_name)        
            --GUI.Msg("prop_name : " .. prop_name)
            --GUI.Msg("prop_val : " .. prop_val)
            --GUI.Msg("assign_name : " .. assign_name)
            --GUI.Msg("element_bg : " .. tab3_property_assignments.element_bg[2])            
            --GUI.Msg("element_text : " .. tab3_property_assignments.element_text[2])
            --GUI.Msg("element_sel_text : " .. tab3_property_assignments.element_sel_text[2])
            --GUI.Msg("element_sel_alpha : " .. tostring(tab3_property_assignments.element_sel_alpha[2]) )    

            GUI.elms[elm_name].col_bg = tab3_property_assignments.element_bg[2]                         
            GUI.elms[elm_name].col_text = tab3_property_assignments.element_text[2]            
            GUI.elms[elm_name].col_sel_text = tab3_property_assignments.element_sel_text[2]
            GUI.elms[elm_name].sel_alpha = tab3_property_assignments.element_sel_alpha[2]

            GUI.elms[elm_name]:init()
            GUI.elms[elm_name]:redraw()

            ::next::
        end
        
        return
    end
        
    -- # PANEL BG change affects multiple elements.
    -- Change background color and change assoc text color.
    -- Should be either txt or panel_txt.
    if assign_name == "panel_bg" then

        tab3_property_assignments["panel_bg"][2] = prop_val
    
        -- Get associated text color.
        local text_col_val

        if prop_val == "wnd_bg" then  -- defaults
            text_col_val = "txt"
        else
            text_col_val = "panel_txt"
        end
        --GUI.Msg("update_tab3_elms prop_val is : " .. tostring(prop_val))    
        tab3_property_assignments["panel_text"][2] = text_col_val

        -- Update the elements.    
           
        GUI.elms.radio_Tab3_BG.col_bg = prop_val
        GUI.elms.radio_Tab3_BG.col_text = text_col_val

        GUI.elms.chkl_Tab3_UseOutline.col_bg = prop_val           
        GUI.elms.chkl_Tab3_UseOutline.col_text = text_col_val

        GUI.elms.pnl_Tab3_Elements.col_bg = prop_val
        
        GUI.elms.lbl_Tab3_Elements.col_bg = prop_val
        GUI.elms.lbl_Tab3_Elements.col_text = text_col_val

        GUI.elms.knob_Tab3.col_bg = prop_val
        GUI.elms.knob_Tab3.col_values = text_col_val
        GUI.elms.knob_Tab3.col_cap_text = text_col_val
        
        GUI.elms.lbl_SelAlpha.col_bg = prop_val
        GUI.elms.lbl_SelAlpha.col_text = text_col_val
        
        GUI.elms.lbl_SelAlphaVal.col_bg = prop_val
        GUI.elms.lbl_SelAlphaVal.col_text = text_col_val
                    
        GUI.elms.slider_SelAlpha.col_bg = prop_val
        GUI.elms.slider_SelAlpha.col_backdrop = prop_val
        GUI.elms.slider_SelAlpha.col_values = text_col_val
            
        GUI.elms.mbx_Tab3.col_backdrop = prop_val
        
        GUI.elms.lbx_Tab3.col_backdrop = prop_val
        
        GUI.elms.knob_Tab3.col_backdrop = prop_val
        
        GUI.elms.mbx_Tab3.col_backdrop = prop_val

        GUI.elms.tbx_Tab3.col_backdrop = prop_val

        GUI.elms.txe_Tab3.col_backdrop = prop_val

        for _, elm_name in ipairs(TAB3_UPDATE_ELMS) do
            GUI.elms[elm_name]:init()
            GUI.elms[elm_name]:redraw()
        end
        
        return
    end

    -- # PANEL_BORDER affects radio boxes and panel.
    if assign_name == "panel_border" then

        tab3_property_assignments["panel_border"][2] = prop_val

        GUI.elms.pnl_Tab3_Elements.col_border = prop_val
        GUI.elms.pnl_Tab3_Elements:init()
        GUI.elms.pnl_Tab3_Elements:redraw()
        
        GUI.elms.radio_Tab3_BG.col_border = prop_val
        GUI.elms.radio_Tab3_BG:init()
        GUI.elms.radio_Tab3_BG:redraw()

        GUI.elms.chkl_Tab3_UseOutline.col_border = prop_val
        GUI.elms.chkl_Tab3_UseOutline:init()
        GUI.elms.chkl_Tab3_UseOutline:redraw()

        return
    end

    -- # GENERAL UPDATE.
    tab3_property_assignments[assign_name][2] = prop_val
    
    --GUI.Msg("general update")    

    GUI.elms[elm_name][prop_name] = prop_val
    GUI.elms[elm_name]:init()
    GUI.elms[elm_name]:redraw()

end

---------------------------------------

local function show_tab3_props_in_panel()
    --GUI.Msg("show_tab3_props_in_panel")
    local list = {}
    --          "Menubar background:    col_bg           -> "},
    local str = "Class   attribute:     property         -> value"
    table.insert(list, str)
    table.insert(list, " ")
            
    -- tab3_display_assignments is list.
    -- item is {"menubar_bg",        "Menubar BG:        col_bg    -> "},
    -- tab3_property_assignments is hash.
    -- menubar_bg = {"elm_frame", "elm_frame"},

     for _, assigned in ipairs(tab3_display_assignments) do
    
        --          display string              overridden value        
        local item = assigned[2] .. tostring(tab3_property_assignments[assigned[1]][2])
        --GUI.Msg(item)
        --GUI.Msg(tostring(tab3_property_assignments[assigned[1]][2]))        
        
        table.insert(list, item)
        
    end     
    
    table.insert(list, " ")
    table.insert(list, "  * Listbox, Menubox, Textbox, and TextEditor.")
    table.insert(list, " ** Pointer and Highlighted Value text color.")
    table.insert(list, "*** Scrollbar in Listbox and TextEditor.")    

    GUI.elms.lbl_PropertyAssignments.text = "dh_Toolkit Assignments:"
    GUI.elms.lbl_PropertyAssignments:init()
    GUI.elms.lbl_PropertyAssignments:redraw()
     
    GUI.elms.lbx_PropertyAssignments.list = list
    GUI.elms.lbx_PropertyAssignments.wnd_y = 1        
    GUI.elms.lbx_PropertyAssignments:init()
    GUI.elms.lbx_PropertyAssignments:redraw()
    
    GUI.elms_hide[1] = false
    GUI.elms_hide[2] = false
    GUI.elms_hide[3] = false

end

local function show_tab3_props_in_console()

    GUI.Msg("\nCurrent Tab3 property assignments:")
    GUI.Msg("Class   attribute:  property      -> value\n")    
    for _, assigned in ipairs(tab3_display_assignments) do
        GUI.Msg(assigned[2] .. tostring(tab3_property_assignments[assigned[1]][2]))
    end
    
    GUI.Msg(" ")    
    GUI.Msg("  * Listbox,Menubox, Textbox, and TextEditor use 'color'.")
    GUI.Msg(" ** Pointer and Highlighted Value text color.")
    GUI.Msg("*** Scrollbar in Listbox and TextEditor.")     

end

-- No need to hide everything else since this is on top.
local function show_color_defaults()
    GUI.elms.lbl_PropertyAssignments.text = "Defaults Assignments:"
    GUI.elms.lbl_PropertyAssignments:init()
    GUI.elms.lbl_PropertyAssignments:redraw()
   
    GUI.elms.lbx_PropertyAssignments.list = dhtd.data_color_defaults
    GUI.elms.lbx_PropertyAssignments:init()
    GUI.elms.lbx_PropertyAssignments:redraw()

    GUI.elms_hide[1] = false
    GUI.elms_hide[2] = false
    GUI.elms_hide[3] = false
end

--====================================
  --------    ELEMENTS    --------
--====================================
--zzelem --zztabs  

GUI.New("tabs_ThemeDesigner", "dh_Tabs", {
    z = 101,
    x = 0, 
    y = 0, 
    tab_w = 96, 
    tab_h = TAB_HEIGHT,  -- !!! NOTE: tabs adds 6 pixels to height. 
    fullwidth = true,
    opts = "Themes,Lokasenna,dh_Toolkit,Colors",
    col_bg = "elm_bg",  -- default
    col_text = "btn_txt",    -- default
    col_tab_active = "tab_active",  -- "wnd_bg" is default?
    col_tab_inactive = "tab_inactive", -- "tab_bg" is default?
    font_tab_active = "sans24",
    font_tab_inactive = "sans22",
})

-- Layer 490 used by mbx_UserThemes. It needs to be handled in Tabs mouseup.
GUI.elms.tabs_ThemeDesigner:update_sets({ 
    [1] = {481,482,483,484,485,486,487,488,489,491,492,493,494,495,496,497,498,499,500},
    [2] = {21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40},    
    [3] = {41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60},
    [4] = {124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150}, 
})

-----------------------------------
--------  Tab 1 Elements  --------
-----------------------------------
--zztab1 

-- Adjustments to core elements to accommodate options..
if GUI.elms["pnl_ScaleSection"] then GUI.elms["pnl_ScaleSection"].h = 240 end
if GUI.elms["pnl_ThemesSection"] then GUI.elms["pnl_ThemesSection"].h = 240 end

-- !!! Tab1 holds Prefs, layers 490 - 500 as defined in dh_Toolkit_core.lua.

GUI.New("pnl_UserThemesSection", "dh_Panel", {
    z = 487, 
    x = 368,
    y = 56,
    w = 184,
    h = 240,
    shadow = false,
    border_width = 2, 
    radius = 0, 
    col_border = "panel_border", 	
    col_bg = "panel_bg",
    col_backdrop = "wnd_bg",    
})

GUI.New("lbl_UserThemeTitle", "dh_Label", {
    z = 486, 
    x = 380, 
    y = 28 + TAB_HEIGHT, 
    text = "User Theme Name",
    col_bg = "panel_bg",
    col_text = "panel_txt", 
    font = "sans22",
})

GUI.New("tbx_UserThemeName", "dh_Textbox", {
    z = 485, 
    x = 376, 
    y = 52 + TAB_HEIGHT, 
    w = 168, 
    h = 28,  --32, 
    caption = "",
    font_text = "mono16",   --textbox needs mono font
    col_text = "elm_txt",
    col_backdrop = "panel_bg",        
})

GUI.New("btn_RenameUserTheme", "dh_Button", {
    z = 484, 
    x = 408, 
    y = 92 + TAB_HEIGHT,  
    w = 104, 
    h = 28,  --32, 
    text = "Rename",
    font = "sans22",
    col_bg = "btn_face",
    col_text = "btn_txt",        
    func = renameUserTheme,
})

GUI.New("btn_DeleteUserTheme", "dh_Button", {
    z = 483, 
    x = 408, 
    y = 136 + TAB_HEIGHT, 
    w = 104, 
    h = 28,  --32, 
    text = "Delete",
    font = "sans22",
    col_bg = "btn_face",
    col_text = "btn_txt",		
    func = deleteUserTheme,
})

GUI.New("btn_SaveUserTheme", "dh_Button", {
    z = 482,
    x = 408, 
    y = 180 + TAB_HEIGHT, 
    w = 104, 
    h = 28,  --32, 
    text = "Save Theme",
    font = "sans22",
    col_bg = "btn_face",
    col_text = "btn_txt",	
    func = saveUserTheme,
})

GUI.New("chkl_SaveToConsole", "dh_Checklist", {
    z = 481, 
    x = 376, 	
    y = 220 + TAB_HEIGHT,  
    w = 156, 
    h = 32,
    caption = "", 
    opts = {"Save to console"},
	dir = "v", 
	pad = 8,

    border_width = 0, 
    radius = 0,
        
    col_text = "panel_txt",    
    col_border = "panel_border",  
    col_bg = "panel_bg",
    col_backdrop = "panel_bg",         
    font_text = "sans22",
    opt_size = 16,
})

--!!! Adjustments to core "Prefs" elements where they differ from core.

if GUI.elms["frm_Preferences"] then
    GUI.elms["frm_Preferences"].y = 32
    GUI.elms["frm_Preferences"].h = DISPLAY_HEIGHT
end

if GUI.elms["lbl_Preferences"] then GUI.elms["lbl_Preferences"] = nil end
if GUI.elms["btn_ClosePrefs"] then GUI.elms["btn_ClosePrefs"] = nil end
if GUI.elms["chkl_UseOutlines"] then GUI.elms["chkl_UseOutlines"] = nil end
if GUI.elms["chkl_FrameThk"] then GUI.elms["chkl_FrameThk"] = nil end

if GUI.elms.lbl_ScaleSectionTitle then 
    GUI.elms.lbl_ScaleSectionTitle.y = 34
end

if GUI.elms.lbl_ThemesSectionTitle then 
    GUI.elms.lbl_ThemesSectionTitle.y = 34
end

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
    fill = false,        -- default
    color = "elm_frame", -- default
})

GUI.New("menu_Tab2_Lokasenna", "Menubar", {
    z = 39,
    x = 0, 
    y = TAB_HEIGHT, 
    w = 640, 
    h = 28,
    fullwidth = true,
    
--[===[
    Tried to move menus to dh_ThemeDesigner_data.lua,
    but couldn't get menu functions to execute.
    --menus = dhtd.menus_tab2,
--]===]  

    menus = {

      {title = "Menubar", options = {
          {">Background color"},
              {"elm_frame", update_tab2_elms, {"menu_Tab2_Lokasenna", "col_bg", "elm_frame", "menubar_bg"}, 1},
              {"btn_face", update_tab2_elms, {"menu_Tab2_Lokasenna", "col_bg", "btn_face", "menubar_bg"}, 1},              
              {"panel_bg", update_tab2_elms, {"menu_Tab2_Lokasenna", "col_bg", "panel_bg", "menubar_bg"}, 1},
              --{"wnd_bg", update_tab2_elms, {"menu_Tab2_Lokasenna", "col_bg", "wnd_bg", "menubar_bg"}, 1},
              {"<tab_active", update_tab2_elms, {"menu_Tab2_Lokasenna", "col_bg", "tab_active", "menubar_bg"}, 1},

          {">Text color"},      
              {"txt", update_tab2_elms, {"menu_Tab2_Lokasenna", "col_txt", "txt", "menubar_text"}, 2},
              {"btn_txt", update_tab2_elms, {"menu_Tab2_Lokasenna", "col_txt", "btn_txt", "menubar_text"}, 2},
              --{"elm_txt", update_tab2_elms, {"menu_Tab2_Lokasenna", "col_txt", "elm_txt", "menubar_text"}, 2},
              {"<panel_txt", update_tab2_elms, {"menu_Tab2_Lokasenna", "col_txt", "panel_txt", "menubar_text"}, 2},
         
          {">Font size"},      
              {"2", update_tab2_elms, {"menu_Tab2_Lokasenna", "font", 2, "menubar_font"}, 3},
              {"<sans22", update_tab2_elms, {"menu_Tab2_Lokasenna", "font", "sans22", "menubar_font"}, 3},
      }},
--zzmenu2
      {title = "Frame", options = {
          {">Filled"},
              {"false", update_tab2_elms, {"frm_Tab2_Elements", "fill", false, "frame_fill"}, 1},
              {"<true", update_tab2_elms, {"frm_Tab2_Elements", "fill", true, "frame_fill"}, 1},
              
          {">Frame color"},      
              {"elm_frame", update_tab2_elms, {"frm_Tab2_Elements", "color", "elm_frame", "frame_color"}, 2},
              {"<panel_border", update_tab2_elms, {"frm_Tab2_Elements", "color", "panel_border", "frame_color"}, 2},
              
          {">Unfilled background color"},
              {"wnd_bg", update_tab2_elms, {"frm_Tab2_Elements", "bg", "wnd_bg", "frame_bg"}, 3},           
              {"elm_frame", update_tab2_elms, {"frm_Tab2_Elements", "bg", "elm_frame", "frame_bg"}, 3},
              {"<panel_bg", update_tab2_elms, {"frm_Tab2_Elements", "bg", "panel_bg", "frame_bg"}, 3},
                   
          {">Text color"},      
              {"txt", update_tab2_elms, {"frm_Tab2_Elements", "col_txt", "txt", "frame_text"}, 4},
              {"<panel_txt", update_tab2_elms, {"frm_Tab2_Elements", "col_txt", "panel_txt", "frame_text"}, 4},
      }},

      {title = "Button", options = { 
          {">Face color"},
              {"elm_frame", update_tab2_elms, {"btn_Tab2", "col_fill", "elm_frame", "button_face"}, 1},
              {"btn_face", update_tab2_elms, {"btn_Tab2", "col_fill", "btn_face", "button_face"}, 1},              
              {"<panel_bg", update_tab2_elms, {"btn_Tab2", "col_fill", "panel_bg", "button_face"}, 1},
              --{"<wnd_bg", update_tab2_elms, {"btn_Tab2", "col_fill", "wnd_bg", "button_face"}, 1},
              
          {">Text color"},      
              {"txt", update_tab2_elms, {"btn_Tab2", "col_txt", "txt", "button_text"}, 2},
              {"btn_txt", update_tab2_elms, {"btn_Tab2", "col_txt", "btn_txt", "button_text"}, 2},
              --{"elm_txt", update_tab2_elms, {"btn_Tab2", "col_txt", "elm_txt", "button_text"}, 2},
              {"<panel_txt", update_tab2_elms, {"btn_Tab2", "col_txt", "panel_txt", "button_text"}, 2},              
              
          {">Font size"},  
              {"3", update_tab2_elms, {"btn_Tab2", "font", 3, "button_font"}, 3},
              {"<sans22", update_tab2_elms, {"btn_Tab2", "font", "sans22", "button_font"}, 3},              
      }},

      {title = "Knob", options = {
          {">Knob face (body)"},
              {"elm_frame", update_tab2_elms, {"knob_Tab2", "col_body", "elm_frame", "knob_body"}, 1},
              {"btn_face", update_tab2_elms, {"knob_Tab2", "col_body", "btn_face", "knob_body"}, 1},
              {"<panel_bg", update_tab2_elms, {"knob_Tab2", "col_body", "panel_bg", "knob_body"}, 1},
          
          {">Knob pointer (head)"},      
              {"elm_fill", update_tab2_elms, {"knob_Tab2", "col_head", "elm_fill", "knob_head"}, 2},
              {"txt", update_tab2_elms, {"knob_Tab2", "col_head", "txt", "knob_head"}, 2},
              {"btn_txt", update_tab2_elms, {"knob_Tab2", "col_head", "btn_txt", "knob_head"}, 2},
              {"<panel_border", update_tab2_elms, {"knob_Tab2", "col_head", "panel_border", "knob_head"}, 2},
      }},            

      {title = "Tabs", options = {
          {">Active color"},
              {"wnd_bg", update_tab2_elms, {"tabs_Tab2", "col_tab_a", "wnd_bg", "tab_active"}, 1},
              {"panel_bg", update_tab2_elms, {"tabs_Tab2", "col_tab_a", "panel_bg", "tab_active"}, 1},
              {"btn_face", update_tab2_elms, {"tabs_Tab2", "col_tab_a", "btn_face", "tab_active"}, 1},              
              {"<tab_active", update_tab2_elms, {"tabs_Tab2", "col_tab_a", "tab_active", "tab_active"}, 1},
          
          {">Inactive color"},
              {"tab_bg", update_tab2_elms, {"tabs_Tab2", "col_tab_b", "tab_bg", "tab_inactive"}, 2},
              {"<tab_inactive", update_tab2_elms, {"tabs_Tab2", "col_tab_b", "tab_inactive", "tab_inactive"}, 2},

          {">Text color"},
              {"txt", update_tab2_elms, {"tabs_Tab2", "col_txt", "txt", "tabs_text"}, 3},              
              {"btn_txt", update_tab2_elms, {"tabs_Tab2", "col_txt", "btn_txt", "tabs_text"}, 3},
              --{"elm_txt", update_tab2_elms, {"tabs_Tab2", "col_txt", "elm_txt", "tabs_text"}, 3},
              {"<panel_txt", update_tab2_elms, {"tabs_Tab2", "col_txt", "panel_txt", "tabs_text"}, 3},
              
      }},

      {title = "More", options = {
          {">Element text"},      
              {"txt", update_tab2_elms, {"mbx_Tab2", "col_txt", "txt", "element_text"}, 1},
              {"btn_txt", update_tab2_elms, {"mbx_Tab2", "col_txt", "btn_txt", "element_text"}, 1},                    
              {"<elm_txt", update_tab2_elms, {"mbx_Tab2", "col_txt", "elm_txt", "element_text"}, 1},      

          {">Options font"},  
              {"2", update_tab2_elms, {"radio_Tab2_Properties", "font_b", 2, "radio_font"}, 2},
              {"<sans22", update_tab2_elms, {"radio_Tab2_Properties", "font_b", "sans22", "radio_font"}, 2},
              
          {">Options button fill"},  
              {"elm_fill", update_tab2_elms, {"radio_Tab2_Properties", "col_fill", "elm_fill", "option_bubble_fill"}, 3},
              {"<txt", update_tab2_elms, {"radio_Tab2_Properties", "col_fill", "txt", "option_bubble_fill"}, 3},

          {">scrollbar thumb"},      
              {"elm_fill", update_tab2_elms, {"lbx_Tab2", "col_fill", "elm_fill", "scrollbar_thumb"}, 4},
              {"btn_face", update_tab2_elms, {"lbx_Tab2", "col_fill", "btn_face", "scrollbar_thumb"}, 4},
              {"<elm_frame", update_tab2_elms, {"lbx_Tab2", "col_fill", "elm_frame", "scrollbar_thumb"}, 4},

          {">Slider track fill"},      
              {"elm_fill", update_tab2_elms, {"slider_Tab2", "col_fill", "elm_fill", "slider_track_fill"}, 5},
              {"<track_fill", update_tab2_elms, {"slider_Tab2", "col_fill", "track_fill", "slider_track_fill"}, 5},
          
          {">Slider thumb"},      
              {"elm_frame", update_tab2_elms, {"slider_Tab2", "col_hnd", "elm_frame", "slider_thumb"}, 6},
              {"<btn_face", update_tab2_elms, {"slider_Tab2", "col_hnd", "btn_face", "slider_thumb"}, 6},
              
      }},

      {title = "Show", options = {
          {"Property Assignments to panel", show_tab2_props_in_panel},
          {"Property Assignments to console", show_tab2_props_in_console},
          {"Color Defaults to panel", show_color_defaults},
      }},                              
    },
})

-----------------------------------
GUI.New("lbl_Tab2_Properties", "Label", {
    z = 38,
    x = 24, 
    y = 36 + TAB_HEIGHT, 
    caption = "Lokasenna properties",
})

--zzoptions
GUI.New("radio_Tab2_Properties", "Radio", {
    z = 37, 
    x = 16, 	
    y = 60 + TAB_HEIGHT,  
    w = 168, 
    h = 64,    
    frame = true,
    caption = "",
    opts = {"defaults","overrides"},
})

-- Set template options default values
-- These may get changed when loading project ext state
GUI.Val("radio_Tab2_Properties", 2)


GUI.New("frm_Tab2_Tabs", "Frame", {
    z = 36,
    x = 16,
    y = 156 + TAB_HEIGHT,
    w = 168, 
    h = 92, 
    fill = true,
    color = "elm_bg",     
})

--zztab2
GUI.New("tabs_Tab2", "Tabs", {
    z = 35,
    x = 18, 
    y = 156 + TAB_HEIGHT, 
    tab_w = 56, 
    tab_h = TAB_HEIGHT, 
    fullwidth = false,
    opts = "Tab1,Tab2",
})

GUI.New("frm_Tab2_Tabs_field", "Frame", {
    z = 34,
    x = 18,
    y = 156 + (2 * TAB_HEIGHT),
    w = 164, 
    h = 90 - TAB_HEIGHT, 
    fill = true,
    color = "wnd_bg",     
})

-----------------------------------
GUI.New("frm_Tab2_Elements", "Frame", {
    z = 32,
    x = 196,
    y = 40 + TAB_HEIGHT,
    w = 432, 
    h = 220, 
    fill = false,         -- default
    color = "elm_frame",  -- default  
    bg = "wnd_bg",        -- default bg color when not filled  
})

GUI.New("lbl_Tab2_Elements", "Label", {
    z = 29,
    x = 210, 
	y = 48 + TAB_HEIGHT,
	caption = "This is a Label in a Lokasenna Frame", 
    bg = "wnd_bg",  -- default
    color = "txt",  -- default
    font = 2,       -- default
})

GUI.New("mbx_Tab2", "Menubox", {
    z = 28,
    x = 210, 
    y = 78 + TAB_HEIGHT, 
    w = 128, 
    h = 32,
    caption = "",
    col_txt = "txt",    -- default
    noarrow = false,    -- default
    font_b = 4,         -- default
    opts = {"Menubox"},
    retval = 1,
    align = 0
})

GUI.New("lbx_Tab2", "Listbox", {
    z = 27,
    x = 210, 
    y = 120 + TAB_HEIGHT, 
    w = 128, 
    h = 128, 
    list = {"Listbox","Listbox 2","Listbox 3","Listbox 4","Listbox 5","Listbox 6","Listbox 7","Listbox 8","Listbox 9","Listbox 10"},
    multi = false,    --!!! Do not change
    caption = "",
    font_b = 4,       -- default list font
    color = "txt",    -- default
})

GUI.New("knob_Tab2", "Knob", {
    z = 26,
    x = 398, 
    y = 124 + TAB_HEIGHT, 
    w = 30,  
    caption = "Knob",
    min = 0,
    max = 10,
    default = 0,
    vals = true,
})

GUI.New("btn_Tab2", "Button", {
    z = 31,
    x = 364,  
    y = 212 + TAB_HEIGHT,  
    w = 96, 
    h = 32,
    caption = "Button",
    col_txt = "txt",         -- default
    col_fill = "elm_frame",  -- default
    font = 3,                -- default
})

-----------------------------------
GUI.New("slider_Tab2", "Slider", {
    z = 23,
    x = 488, 
    y = 80 + TAB_HEIGHT, 
    w = 128, 
    caption = "Slider",
    min = 0,
    max = 10,
    defaults = 0,
    font_b = 4,             -- default
    col_txt = "txt",        -- default
    col_hnd = "elm_frame",  -- default
    col_fill = "elm_fill",  -- default   
})

GUI.New("tbx_Tab2", "Textbox", {
    z = 22,
    x = 488, 
    y = 120 + TAB_HEIGHT, 
    w = 128, 
    h = 32, 
    font_b = "monospace",  -- default (needs mono font)
    color = "txt",         -- default
})

GUI.Val("tbx_Tab2", "Textbox")

GUI.New("txe_Tab2", "TextEditor", {
    z = 21,
    x = 488, 
    y = 160 + TAB_HEIGHT,  
    w = 128, 
    h = 88,
    font_b = "monospace",   -- default (needs mono font)
    color = "txt",          -- default
    col_fill = "elm_fill",  -- default
        
})

GUI.Val("txe_Tab2", "This is a \nLokasenna TextEditor.\nThis is a \nLokasenna TextEditor.\nThis is a \nLokasenna TextEditor'\n")

-----------------------------------
--------  Tab 3 Elements  --------
-----------------------------------
--zztab3

GUI.New("pnl_Tab3_Toolkit", "dh_Panel", {
    z = 60,
    x = 0,
    y = TAB_HEIGHT,
    w = DHTK.APP_WIDTH, 
    h = DISPLAY_HEIGHT,
    border_width = 2, 
    radius = 0, 
    col_border = "panel_border",	
    col_bg = "wnd_bg",
    col_backdrop = "wnd_bg",        
})    

GUI.New("menu_Tab3_Toolkit", "dh_Menubar", {
    z = 59,
    x = 0, 
    y = TAB_HEIGHT, 
    w = 640, 
    h = 28,
    fullwidth = true,
    shadow = true,
    font = "sans22",  
    col_bg = "btn_face", 
    col_over = "elm_fill",  --"sel_txt",
    col_text = "btn_txt",
     
--zzmenu3  
    
    menus = {

      {title = "Menubar", options = {
        {">Background color"},
          {"btn_face", update_tab3_elms, {"menu_Tab3_Toolkit", "col_bg", "btn_face", "menubar_bg"}, 1},
          {"aux_bg", update_tab3_elms, {"menu_Tab3_Toolkit", "col_bg", "aux_bg", "menubar_bg"}, 1},
          --{"wnd_bg", update_tab3_elms, {"menu_Tab3_Toolkit", "col_bg", "wnd_bg", "menubar_bg"}, 1},
          {"panel_bg", update_tab3_elms, {"menu_Tab3_Toolkit", "col_bg", "panel_bg", "menubar_bg"}, 1},          
          {"<tab_active", update_tab3_elms, {"menu_Tab3_Toolkit", "col_bg", "tab_active", "menubar_bg"}, 1},

        {">Text color"},
          {"btn_txt", update_tab3_elms, {"menu_Tab3_Toolkit", "col_text", "btn_txt", "menubar_text"}, 2},
          {"aux_txt", update_tab3_elms, {"menu_Tab3_Toolkit", "col_text", "aux_txt", "menubar_text"}, 2},
          {"panel_txt", update_tab3_elms, {"menu_Tab3_Toolkit", "col_text", "panel_txt", "menubar_text"}, 2},          
          {"<txt", update_tab3_elms, {"menu_Tab3_Toolkit", "col_text", "txt", "menubar_text"}, 2},

        {">Highlight color"},
          {"elm_fill", update_tab3_elms, {"menu_Tab3_Toolkit", "col_over", "elm_fill", "menubar_over"}, 3},
          {"<sel_txt", update_tab3_elms, {"menu_Tab3_Toolkit", "col_over", "sel_txt", "menubar_over"}, 3},        

        {">Font size"},      
          {"sans22", update_tab3_elms, {"menu_Tab3_Toolkit", "font", "sans22", "menubar_font"}, 4},
          {"<sans24", update_tab3_elms, {"menu_Tab3_Toolkit", "font", "sans24", "menubar_font"}, 4},
      }},

      {title = "Panel", options = {
        -- Now handled with radio_Tab3_BG for fast switching.
        --{">Background color"},
        --  {"wnd_bg", update_tab3_elms, {"pnl_Tab3_Elements", "col_bg", "wnd_bg", "panel_bg"}, 2},
        --  {"<panel_bg", update_tab3_elms, {"pnl_Tab3_Elements", "col_bg", "panel_bg", "panel_bg"}, 2},
      
        {">Border color"},      
          {"panel_border", update_tab3_elms, {"pnl_Tab3_Elements", "col_border", "panel_border", "panel_border"}, 1},
          {"<elm_frame", update_tab3_elms, {"pnl_Tab3_Elements", "col_border", "elm_frame", "panel_border"}, 1},
        
        -- Text color now automatically sets to match bg.
        --{">Text color"}, 
        --  {"txt", update_tab3_elms, {"pnl_Tab3_Elements", "col_text", "txt", "panel_text"}, 5},        
        --  {"<panel_txt", update_tab3_elms, {"pnl_Tab3_Elements", "col_text", "panel_txt", "panel_text"}, 5},

        {">Border width"},      
          {"2", update_tab3_elms, {"pnl_Tab3_Elements", "border_width", 2, "panel_border_width"}, 3},
          {"0", update_tab3_elms, {"pnl_Tab3_Elements", "border_width", 0, "panel_border_width"}, 3},
          {"1", update_tab3_elms, {"pnl_Tab3_Elements", "border_width", 1, "panel_border_width"}, 3},
          {"4", update_tab3_elms, {"pnl_Tab3_Elements", "border_width", 4, "panel_border_width"}, 3},
          {"<6", update_tab3_elms, {"pnl_Tab3_Elements", "border_width", 6, "panel_border_width"}, 3},          
          
        {">Radius"},      
          {"0", update_tab3_elms, {"pnl_Tab3_Elements", "radius", 0, "panel_radius"}, 4},
          {"2", update_tab3_elms, {"pnl_Tab3_Elements", "radius", 2, "panel_radius"}, 4},
          {"4", update_tab3_elms, {"pnl_Tab3_Elements", "radius", 4, "panel_radius"}, 4},
          {"6", update_tab3_elms, {"pnl_Tab3_Elements", "radius", 6, "panel_radius"}, 4},
          {"8", update_tab3_elms, {"pnl_Tab3_Elements", "radius", 8, "panel_radius"}, 4},
          {"<16", update_tab3_elms, {"pnl_Tab3_Elements", "radius", 16, "panel_radius"}, 4},                    
      }},

      {title = "Button", options = {
        {">Face color"},
          {"btn_face", update_tab3_elms, {"btn_Tab3", "col_bg", "btn_face", "button_face"}, 1},
          {"aux_bg", update_tab3_elms, {"btn_Tab3", "col_bg", "aux_bg", "button_face"}, 1},
          {"<panel_bg", update_tab3_elms, {"btn_Tab3", "col_bg", "panel_bg", "button_face"}, 1},          
          
        {">Outline color"}, 
          {"btn_outline", update_tab3_elms, {"btn_Tab3", "col_outline", "btn_outline", "button_outline"}, 2},
          {"elm_frame", update_tab3_elms, {"btn_Tab3", "col_outline", "elm_frame", "button_outline"}, 2},
          {"<panel_border", update_tab3_elms, {"btn_Tab3", "col_outline", "panel_border", "button_outline"}, 2},

        {">Text color"},      
          {"btn_txt", update_tab3_elms, {"btn_Tab3", "col_text", "btn_txt", "button_text"}, 3},
          {"aux_txt", update_tab3_elms, {"btn_Tab3", "col_text", "aux_txt", "button_text"}, 3},
          {"<panel_txt", update_tab3_elms, {"btn_Tab3", "col_text", "panel_txt", "button_text"}, 3},

        {">Font size"},  
          {"sans22", update_tab3_elms, {"btn_Tab3", "font", "sans22", "button_font"}, 4},
          {"<sans24", update_tab3_elms, {"btn_Tab3", "font", "sans24", "button_font"}, 4},              
      }},

      {title = "Knob", options = {
        {">Style"},          
          {"pointer", update_tab3_elms, {"knob_Tab3", "knob_style", "pointer", "knob_style"}, 4},
          {"flange", update_tab3_elms, {"knob_Tab3", "knob_style", "flange", "knob_style"}, 4},
          {"<simple", update_tab3_elms, {"knob_Tab3", "knob_style", "simple", "knob_style"}, 4},
        
        {">Face color (body)"},
          {"btn_face", update_tab3_elms, {"knob_Tab3", "col_body", "btn_face", "knob_body"}, 1},
          {"aux_bg", update_tab3_elms, {"knob_Tab3", "col_body", "aux_bg", "knob_body"}, 1},          
          {"thumb_body", update_tab3_elms, {"knob_Tab3", "col_body", "thumb_body", "knob_body"}, 1},                    
          {"<panel_bg", update_tab3_elms, {"knob_Tab3", "col_body", "panel_bg", "knob_body"}, 1},          
        
        {">Outline color"},          
          {"btn_outline", update_tab3_elms, {"knob_Tab3", "col_outline", "btn_outline", "knob_outline"}, 3},
          {"<panel_border", update_tab3_elms, {"knob_Tab3", "col_outline", "panel_border", "knob_outline"}, 3},
 
        --[=[
        -- Pointer color now automatically calculated.
        {">Pointer color (indicator)"},
          {"btn_txt", update_tab3_elms, {"knob_Tab3", "col_indicator", "btn_txt", "knob_indicator"}, 2},
          {"aux_txt", update_tab3_elms, {"knob_Tab3", "col_indicator", "aux_txt", "knob_indicator"}, 2},          
          {"txt", update_tab3_elms, {"knob_Tab3", "col_indicator", "txt", "knob_indicator"}, 2},
          {"panel_txt", update_tab3_elms, {"knob_Tab3", "col_indicator", "panel_txt", "knob_indicator"}, 2},
          {"elm_outline", update_tab3_elms, {"knob_Tab3", "col_indicator", "elm_outline", "knob_indicator"}, 2},
          {"elm_fill", update_tab3_elms, {"knob_Tab3", "col_indicator", "elm_fill", "knob_indicator"}, 2},
          {"<track_fill", update_tab3_elms, {"knob_Tab3", "col_indicator", "track_fill", "knob_indicator"}, 2},
        --]=]
        
      }},
      
      {title = "Options", options = {
        {">Font size"},
          {"sans22", update_tab3_elms, {"radio_Tab3_BG", "font_text", "sans22", "radio_font"}, 1},
          {"sans20", update_tab3_elms, {"radio_Tab3_BG", "font_text", "sans20", "radio_font"}, 1},
          {"<sans24", update_tab3_elms, {"radio_Tab3_BG", "font_text", "sans24", "radio_font"}, 1},
      }},

      {title = "Text_elms", options = {
        {">Background color"},
            {"elm_bg", update_tab3_elms, {"lbx_Tab3", "col_bg", "elm_bg", "element_bg"}, 8},
            {"panel_bg", update_tab3_elms, {"lbx_Tab3", "col_bg", "panel_bg", "element_bg"}, 8},
            {"btn_face", update_tab3_elms, {"lbx_Tab3", "col_bg", "btn_face", "element_bg"}, 8},
            {"<aux_bg", update_tab3_elms, {"lbx_Tab3", "col_bg", "aux_bg", "element_bg"}, 8},

        -- Text colors are now set to complement bg in update_tab3_elms.
        
        {">Highlight color"},
            {"sel_txt", update_tab3_elms, {"lbx_Tab3", "col_sel_text", "sel_txt", "element_sel_text"}, 9},
            {"<elm_fill", update_tab3_elms, {"lbx_Tab3", "col_sel_text", "elm_fill", "element_sel_text"}, 9},
            --{"sel_txt - darken", update_tab3_elms, {"lbx_Tab3", "col_sel_text", "sel_txt_darken", "element_sel_text"}, 9},
            --{"<elm_fill - darken", update_tab3_elms, {"lbx_Tab3", "col_sel_text", "elm_fill_darken", "element_sel_text"}, 9},
        
        -- These are used only for Tab3 text elements.
        {">sel_alpha"},
            {"-0.5", update_tab3_elms, {"lbx_Tab3", "sel_alpha", -0.5, "element_sel_alpha"}, 7},
            {"-0.4", update_tab3_elms, {"lbx_Tab3", "sel_alpha", -0.4, "element_sel_alpha"}, 7},
            {"-0.3", update_tab3_elms, {"lbx_Tab3", "sel_alpha", -0.3, "element_sel_alpha"}, 7},
            {"-0.2", update_tab3_elms, {"lbx_Tab3", "sel_alpha", -0.2, "element_sel_alpha"}, 7},            
            {"-0.1", update_tab3_elms, {"lbx_Tab3", "sel_alpha", -0.1, "element_sel_alpha"}, 7},            
            {"0.0", update_tab3_elms, {"lbx_Tab3", "sel_alpha", 0.0, "element_sel_alpha"}, 7},
            {"0.1", update_tab3_elms, {"lbx_Tab3", "sel_alpha", 0.1, "element_sel_alpha"}, 7},
            {"0.2", update_tab3_elms, {"lbx_Tab3", "sel_alpha", 0.2, "element_sel_alpha"}, 7},
            {"0.3", update_tab3_elms, {"lbx_Tab3", "sel_alpha", 0.3, "element_sel_alpha"}, 7},
            {"0.4", update_tab3_elms, {"lbx_Tab3", "sel_alpha", 0.4, "element_sel_alpha"}, 7},
            {"0.5", update_tab3_elms, {"lbx_Tab3", "sel_alpha", 0.5, "element_sel_alpha"}, 7},
            {"0.6", update_tab3_elms, {"lbx_Tab3", "sel_alpha", 0.6, "element_sel_alpha"}, 7},
            --{"0.7", update_tab3_elms, {"lbx_Tab3", "sel_alpha", 0.7, "element_sel_alpha"}, 7},
            {"0.8", update_tab3_elms, {"lbx_Tab3", "sel_alpha", 0.8, "element_sel_alpha"}, 7},
            --{"0.9", update_tab3_elms, {"lbx_Tab3", "sel_alpha", 0.9, "element_sel_alpha"}, 7},
            {"<1.0", update_tab3_elms, {"lbx_Tab3", "sel_alpha", 1.0, "element_sel_alpha"}, 7},
            
        {">Scrollbar track color"},
          {"btn_face", update_tab3_elms, {"txe_Tab3", "col_track", "btn_face", "scrollbar_track"}, 1}, 
          {"aux_bg", update_tab3_elms, {"txe_Tab3", "col_track", "aux_bg", "scrollbar_track"}, 1},
          {"<panel_bg", update_tab3_elms, {"txe_Tab3", "col_track", "panel_bg", "scrollbar_track"}, 1},          
      
        {">Scrollbar width"},
          {"8", update_tab3_elms, {"txe_Tab3", "scrollbar_width", 8, "scrollbar_width"}, 3},
          {"10", update_tab3_elms, {"txe_Tab3", "scrollbar_width", 10, "scrollbar_width"}, 3},
          {"12", update_tab3_elms, {"txe_Tab3", "scrollbar_width", 12, "scrollbar_width"}, 3},
          {"<16", update_tab3_elms, {"txe_Tab3", "scrollbar_width", 16, "scrollbar_width"}, 3},
      }},                            
      
      {title = "Slider", options = {
        --{">Slider track bg"},    
        --    {"elm_bg", update_tab3_elms, {"slider_SelAlpha", "col_fill", "elm_bg", "slider_track_bg"}, 1},
        --    {"<btn_face", update_tab3_elms, {"slider_SelAlpha", "col_hnd", "btn_face", "slider_track_bg"}, 1},

        {">Thumb color"},
          {"thumb_body", update_tab3_elms, {"slider_SelAlpha", "col_thumb", "thumb_body", "slider_thumb"}, 3},
          {"btn_face", update_tab3_elms, {"slider_SelAlpha", "col_thumb", "btn_face", "slider_thumb"}, 3},
          {"aux_bg", update_tab3_elms, {"slider_SelAlpha", "col_thumb", "aux_bg", "slider_thumb"}, 3},
          {"<panel_bg", update_tab3_elms, {"slider_SelAlpha", "col_thumb", "panel_bg", "slider_thumb"}, 3},

        {">Thumb Outline color"},          
          {"btn_outline", update_tab3_elms, {"slider_SelAlpha", "col_thumb_outline", "btn_outline", "slider_thumb_outline"}, 5},
          --{"panel_border", update_tab3_elms, {"slider_SelAlpha", "col_thumb_outline", "panel_border", "slider_thumb_outline"}, 5},
          {"<elm_frame", update_tab3_elms, {"slider_SelAlpha", "col_thumb_outline", "elm_frame", "slider_thumb_outline"}, 5},
        
        {">Track fill color"},
          {"track_fill", update_tab3_elms, {"slider_SelAlpha", "col_fill", "track_fill", "slider_track_fill"}, 2},
          {"<elm_fill", update_tab3_elms, {"slider_SelAlpha", "col_fill", "elm_fill", "slider_track_fill"}, 2},

        {">Thickness (Tab 3 only)"},
          {"4", update_tab3_elms, {"slider_SelAlpha", "track_thk", 4, "slider_thickness"}, 4},        
          {"8", update_tab3_elms, {"slider_SelAlpha", "track_thk", 8, "slider_thickness"}, 4},
          {"12", update_tab3_elms, {"slider_SelAlpha", "track_thk", 12, "slider_thickness"}, 4},
          {"<16", update_tab3_elms, {"slider_SelAlpha", "track_thk", 16, "slider_thickness"}, 4},

        --[=[
        --!!! Use for testing.
        {">Color Slider Thumb"},
          {"thumb_body", update_tab3_elms, {"slider_Red", "col_thumb", "thumb_body", "slider_thumb"}, 5},
          {"btn_face", update_tab3_elms, {"slider_Red", "col_thumb", "btn_face", "slider_thumb"}, 5},
          {"<panel_bg", update_tab3_elms, {"slider_Red", "col_thumb", "panel_bg", "slider_thumb"}, 5},
        --]=]
     }},

      {title = "Tabs", options = {
        {">Active color"},
          {"tab_active", update_tab3_elms, {"tabs_ThemeDesigner", "col_tab_active", "tab_active", "tab_active"}, 1},
          {"btn_face", update_tab3_elms, {"tabs_ThemeDesigner", "col_tab_active", "btn_face", "tab_active"}, 1},
          {"elm_frame", update_tab3_elms, {"tabs_ThemeDesigner", "col_tab_active", "elm_frame", "tab_active"}, 1},
          {"<panel_bg", update_tab3_elms, {"tabs_ThemeDesigner", "col_tab_active", "panel_bg", "tab_active"}, 1},
          --{"<wnd_bg", update_tab3_elms, {"tabs_ThemeDesigner", "col_tab_active", "wnd_bg", "tab_active"}, 1},
      
        {">Inactive color"},
          {"tab_inactive", update_tab3_elms, {"tabs_ThemeDesigner", "col_tab_inactive", "tab_inactive", "tab_inactive"}, 2},
          {"<tab_bg", update_tab3_elms, {"tabs_ThemeDesigner", "col_tab_inactive", "tab_bg", "tab_inactive"}, 2},

        {">Text color"},
          {"btn_txt", update_tab3_elms, {"tabs_ThemeDesigner", "col_text", "btn_txt", "tabs_text"}, 3},              
          {"txt", update_tab3_elms, {"tabs_ThemeDesigner", "col_text", "txt", "tabs_text"}, 3},
          {"<panel_txt", update_tab3_elms, {"tabs_ThemeDesigner", "col_text", "panel_txt", "tabs_text"}, 3},
         
      }},                              

      {title = "Show", options = {
          {"Property Assignments to panel", show_tab3_props_in_panel},
          {"Property Assignments to console", show_tab3_props_in_console},
          {"Color Defaults to panel", show_color_defaults},
      }},

    },
})

-----------------------------------

GUI.New("radio_Tab3_BG", "dh_Radio", {
    z = 57, 
    x = 16, 	
    y = 64 + TAB_HEIGHT,  
    w = 168, 
    h = 72,
    caption = "Panel Background",
    opts = {"wnd_bg","panel_bg"},
	dir = "v", 
	pad_x = 8,
    pad_y = 12,
    border_width = 2, 
    radius = 4,
    
    col_border = "panel_border", 
    col_bg = "wnd_bg", 
    col_text = "txt",
    col_backdrop = "wnd_bg",        
    font_text = "sans22",         
	shadow = false,
    --opt_size = 16,
})

GUI.New("chkl_Tab3_UseOutline", "dh_Checklist", {
    z = 55, 
    x = 16, 	
    y = 192 + TAB_HEIGHT,  
    w = 168, 
    h = 60,
    caption = "", 
    opts = {"Use Outlines", "Thicker Frames"},
	dir = "v", 
	pad_x = 8,
    pad_y = 8,
    border_width = 2, 
    radius = 4,

    col_border = "panel_border",  
    col_bg = "wnd_bg",
    col_text = "txt",
    col_backdrop = "wnd_bg",        
    font_text = "sans22",
    --opt_size = 16,

})

-----------------------------------
GUI.New("pnl_Tab3_Elements", "dh_Panel", {
    z = 52,
    x = 196,
    y = 40 + TAB_HEIGHT,
    w = 432, 
    h = 220, 
    border_width = 4, 
    radius = 4, 
    col_border = "panel_border",  
    col_bg = "wnd_bg",
    col_backdrop = "wnd_bg",                
})

GUI.New("lbl_Tab3_Elements", "dh_Label", {
    z = 49,
    x = 210, 
	y = 48 + TAB_HEIGHT,
    text = "This is a Label in a dh_Panel",
    col_bg = "wnd_bg", 
    col_text = "txt",     
})

GUI.New("mbx_Tab3", "dh_Menubox", {
    z = 48,
    x = 210, 
    y = 78 + TAB_HEIGHT, 
    w = 128, 
    h = 32,
    caption = "",
    font_text = "sans22",      
    noarrow = false,
    optarray = {"dh_Menubox"},
    curr_opt = 1,
    align_text = "left",
    col_text = "elm_txt",
    col_backdrop = "wnd_bg",        
})

GUI.New("lbx_Tab3", "dh_Listbox", {
    z = 47,
    x = 210, 
    y = 120 + TAB_HEIGHT, 
    w = 128, 
    h = 128,
    list = {"Listbox1","Listbox 2","Listbox 3","Listbox 4","Listbox 5","Listbox 6","Listbox 7","Listbox 8","Listbox 9","Listbox 10"},
    multi = false, -- !!! Must be false
    caption = "",
    pad = 4,
    shadow = false,
    font_text = "sans22",    -- list font default
    col_sel_text = "sel_txt",
    sel_alpha = 0.5,
    col_backdrop = "wnd_bg",        
})

-----------------------------------
--zzknob

GUI.New("knob_Tab3", "dh_Knob", {
    z = 46,
    x = 414, 
    y = 144 + TAB_HEIGHT, 
    w = 48,
    centered = true,
    knob_style = "pointer",  --"simple",
    min = 0,
    max = 10,
    default = 0,
    inc = 1,
         
    caption = "Knob",
    cap_pos = "bottom",
    cap_pad_x = 4,
    cap_pad_y = 0,
    font_caption = "sans22",
    shadow_caption = false,
    
    font_values = "sans22",
    font_display = "sans24",
    output = nil,
    shadow = true,
          
    col_bg = "wnd_bg",
    col_body = "btn_face",
        
    col_values = "txt",
    col_outline = "btn_outline",
    col_cap_text = "txt",
    
    allow_highlight = false,
    col_active = "elm_active",
    
    show_tickmarks = true,
    tickmark_steps = 10,
    tickmark_size = 4,
    pad_ticks = 4,
    hard_ticks = {0,5,10},
    hard_tick_size = 6,
    hard_tick_thk = true,
    show_min_max = true,
    min_max_values = {
        {0,"0"},
        {10,"10"},
    },
    show_values = false,
    pad_values = 4,
    display_style = "box",
    display_w = 40,
    display_h = 24,
    display_pos = "top",
    display_pad_x = 0,
    display_pad_y = 12,
    display_align = "center",
    col_display_bg = "elm_bg",
    col_display_text = "elm_txt",
})

GUI.New("btn_Tab3", "dh_Button", {
    z = 51,
    x = 364,  
    y = 212 + TAB_HEIGHT,  
    w = 96, 
    h = 32, 
    text = "dh_Button",
    font = "sans22", 
    col_bg = "btn_face",  
    col_text = "btn_txt", 
})
-------------------------------------
--zztab3

GUI.New("lbl_SelAlpha", "dh_Label", {
    z = 45,
    x = 488, 
	y = 48 + TAB_HEIGHT,  
    text = "sel_alpha:",
    col_bg = "wnd_bg", 
    col_text = "txt",  
    font = "sans24",
})

GUI.New("lbl_SelAlphaVal", "dh_Label", {
    z = 44,
    x = 596, 
	y = 48 + TAB_HEIGHT,  
    text = "",
    col_bg = "wnd_bg", 
    col_text = "txt",  
    font = "sans22",   
})

--zzsel
GUI.New("slider_SelAlpha", "dh_Slider_H", {
    z = 43,
    x = 488, 
    y = 76 + TAB_HEIGHT, 
    w = 128,
    h = 24,
    track_thk = 4, 
    min = 0, 
    max = 10,
    inc = 1,
    default = 0,
    thumb_style = "long",
    border_width = 0,
    radius = 0,
    shadow = true,
    caption = "",
    cap_pos = "top",    
    font_caption = "sans20",
    
    show_values = true,  
    font_values = "sans20",
    pad_values = -4,
    display_style = "none",  
    col_bg = "wnd_bg",
    col_cap_bg = "wnd_bg",
    col_values = "txt",
    col_thumb = "thumb_body",
    col_thumb_outline = "btn_outline",
    col_fill = "track_fill",
    col_backdrop = "wnd_bg",
})

GUI.New("tbx_Tab3", "dh_Textbox", {
    z = 42,
    x = 488, 
    y = 120 + TAB_HEIGHT, 
    w = 128, 
    h = 32, 
    font_text = "mono16",   --textbox needs mono font
    col_text = "elm_txt",
    col_sel_text = "sel_txt",
    col_backdrop = "wnd_bg",        
})

GUI.New("txe_Tab3", "dh_TextEditor", {
    z = 41,
    x = 488, 
    y = 160 + TAB_HEIGHT,  
    w = 128, 
    h = 88, 
    font_text = "mono16",   --textbox needs mono font
    col_text = "elm_txt",
    col_sel_text = "sel_txt",
    col_backdrop = "wnd_bg",        
})

GUI.Val("tbx_Tab3", "dh_Textbox")
GUI.Val("txe_Tab3", "This is a \ndh_TextEditor.\nThis is a \ndh_TextEditor.\nThis is a \ndh_TextEditor.\n")

--------------------------------
--------    Tab 4    --------
--------------------------------
--zztab4
GUI.New("pnl_Tab4_Toolkit", "dh_Panel", {
    z = 150,
    x = 0,
    y = TAB_HEIGHT + 6,      -- tab adds 6 px to height
    w = DHTK.APP_WIDTH, 
    h = DISPLAY_HEIGHT - 6,  -- tab adds 6 px to height 
    border_width = 2, 
    col_border = "elm_frame",
    col_bg = "wnd_bg",     
})

GUI.New("lbl_Lokasenna_defined", "dh_Label", {
    z = 149,
    x = 16,
    y = 44,
    text = "Lokasenna defined",
    col_bg = "wnd_bg",      
    font = "sans22",        
})

GUI.New("lbl_DHTK_defined", "dh_Label", {
    z = 149,
    x = 220,
    y = 44,
    text = "dh_Toolkit defined",
    col_bg = "wnd_bg",      
    font = "sans22",        
})

-- Set the metrics.
local colPage_z = 148
local colPage_column_x = 16
local colPage_column_w = 204
local colPage_row_start = 78
local colPage_row_y = 78
local colPage_row_h = 30
local colPage_row_count = 1

--zzcolor  
function pnl_ColorClick(pnl_name, col_name)

    --GUI.Msg("pnl_ColorClick self.name : " .. GUI.elms[pnl_name].name)
    --GUI.Msg("pnl_ColorClick col_name : " .. col_name .. "\n")

    -- Menubox previously had list of COLOR_NAMES.
    -- Now has list of COLOR_DISPLAY_NAMES.
    -- col_name now saved in color panel.
    -- and in pnl_NewColor when color is selected.
    
	--local col_idx, _ = GUI.Val("mbx_ColorNames")
	--local col_name = COLOR_NAMES[col_idx]
	
	GUI.elms.pnl_NewColor.curr_color = col_name
	
	-- Get index of color name and use it to populate mbx_ColorNames with display name.
	local col_idx = DHTK.table_index_from_value(COLOR_NAMES, col_name)
	GUI.Val("mbx_ColorNames", col_idx)
	
	GUI.elms.lbx_ColorUses.list = COLOR_USES[col_name]
	GUI.elms.lbx_ColorUses:redraw()
	
	-- Update pnl_StartColor and pnl_NewColor color.
	-- Give it a default in case color source is nil.
	
	GUI.colors.start_color = dhth.set_color(START_COLORS[col_name] or {0.5,0.5,0.5,1})
	GUI.colors.new_color = dhth.set_color(GUI.colors[col_name] or {0.5,0.5,0.5,1})
	
	GUI.elms.pnl_StartColor:init()
	GUI.elms.pnl_StartColor:redraw()
    	
    GUI.elms.pnl_NewColor:init()
    GUI.elms.pnl_NewColor:redraw()

    GUI.elms.pnl_StartColorActive.col_bg = "dark_gray"
    GUI.elms.pnl_StartColorActive:init()
    GUI.elms.pnl_StartColorActive:redraw()
    GUI.elms.pnl_NewColorActive.col_bg = "light_gray"
    GUI.elms.pnl_NewColorActive:init()
    GUI.elms.pnl_NewColorActive:redraw()    
    
    -- Update sliders and value labels.
    
    local colval = math.floor((GUI.colors.new_color[1] * 255) + 0.5)
    GUI.Val("slider_Red", colval)
    GUI.elms.slider_Red:redraw()
    
    colval = math.floor((GUI.colors.new_color[2] * 255) + 0.5)
    GUI.Val("slider_Green", colval)
    GUI.elms.slider_Green:redraw()
    
    colval = math.floor((GUI.colors.new_color[3] * 255) + 0.5)
    GUI.Val("slider_Blue", colval)
    GUI.elms.slider_Blue:redraw()

end
--zzcolor
function pnl_ColorRightClick(col_name)
    --GUI.Msg("pnl_ColorRightClick : " .. col_name)
    GUI.colors.copy_color = dhth.set_color(GUI.colors[col_name])
    GUI.colors.copy_color[4] = 1
    GUI.elms.pnl_CopyColor:init()
    GUI.elms.pnl_CopyColor:redraw()

end

-- Add color panels.
for _, col_name in ipairs(COLOR_NAMES) do

    -- Until I implement col_active...
    if (col_name == "elm_active") or (col_name == "metadata") then
        goto skipped
    end
    
    local pnl_name = "pnl_Color_" .. col_name
    
    --GUI.Msg("creating color panels z : " .. colPage_z)
    
    GUI.New(pnl_name, "dh_Panel", {
        z = colPage_z,
        x = colPage_column_x,
        y = colPage_row_y,
        w = 24,
        h = 24,
        border_width = 2, 
        col_border = "txt",
        col_bg = "wnd_bg",
    })
    
    -- Populate with color.
    
    --GUI.Msg("creating color panels : " .. col_name)
    GUI.elms[pnl_name].col_bg = col_name
    
    -- Add callback func.
    
    GUI.elms[pnl_name].func = pnl_ColorClick
    GUI.elms[pnl_name].params = {pnl_name, col_name}

    GUI.elms[pnl_name].r_func = pnl_ColorRightClick
    GUI.elms[pnl_name].r_params = {col_name}

    -- Update metrics.
    
    colPage_z = colPage_z - 1
    
    colPage_row_count = colPage_row_count + 1
    
    if colPage_row_count > 7 then
        colPage_row_count = 1
        colPage_row_y = colPage_row_start
        colPage_column_x = colPage_column_x + colPage_column_w
    else
        colPage_row_y = colPage_row_y + colPage_row_h
    end
    
    ::skipped::

end

-- Reset the metrics.

colPage_z = 149
colPage_column_x = 44
colPage_row_y = 78
colPage_row_count = 1


-- Add the labels.

-- line-height may be different on different operating systems which can present a problem
-- when trying to align text with adjacent elements. So I added a property "line-height-use-pixels"
-- to try to overcome that. If "line-height-use-pixels" is set it will override "line-height".

--[=[
-- Was using this, but it used 21 labels hence 21 buffers.
-- Now using 3 panels hence 3 buffers.
for idx, display_name in ipairs(COLOR_DISPLAY_NAMES) do

    -- Labels don't need a descriptive name.They're just there for labeling.
    local lbl_name = "lbl_ColorLabel_" .. tostring(idx)
    
    GUI.New(lbl_name, "dh_Label", {
        z = colPage_z,
        x = colPage_column_x,
        y = colPage_row_y,
        text = display_name,
        col_bg = "wnd_bg",      
        font = "sans22",        
    })
    
    -- Update metrics.
    
    colPage_row_count = colPage_row_count + 1
    
    if colPage_row_count > 7 then
        colPage_row_count = 1
        colPage_row_y = colPage_row_start
        colPage_column_x = colPage_column_x + colPage_column_w
    else
        colPage_row_y = colPage_row_y + colPage_row_h
    end
end
--]=]

GUI.New("pnl_Tab4_Colors1", "dh_Panel", {
    z = 149,
    x = 52,
    y = 78,
    w = 164, 
    h = 212, 
    border_width = 0, 
    col_bg = "wnd_bg",
    col_text = "txt",
    pad = 0,
    font_text = "sans22",
    use_pixels = true,
    line_height_pixels = 30,  -- * DHTK.APP_SCALE,
    text = {
      "Window BG (L)",
      "Text (L)",
      "Element BG (L)",
      "Element fill (L)",
      "Element frame (L)",
      "Element outline (L)",
      "Tab BG (inactive) (L)",
    },       
})

GUI.New("pnl_Tab4_Colors2", "dh_Panel", {
    z = 149,
    x = 256,
    y = 78,
    w = 164, 
    h = 212, 
    border_width = 0, 
    col_bg = "wnd_bg",
    col_text = "txt",
    pad = 0,
    font_text = "sans22",
    use_pixels = true,
    line_height_pixels = 30,  -- * DHTK.APP_SCALE,
    text = {
      "Button face",
      "Button outline",      
      "Button text",
      "Aux background",
      "Aux text",
      "Slider thumb",            
      --"Element active",
      --"Element thumb",
      --"Element track",
      "Slider Track fill",
    },       
})

GUI.New("pnl_Tab4_Colors3", "dh_Panel", {
    z = 149,
    x = 460,
    y = 78,
    w = 164, 
    h = 212, 
    border_width = 0, 
    col_bg = "wnd_bg",
    col_text = "txt",
    pad = 0,
    font_text = "sans22",
    use_pixels = true,
    line_height_pixels = 30,  -- * DHTK.APP_SCALE,
    text = {
      "Panel background",
      "Panel border",
      "Panel text", 
      "Element text",           
      "Selected text",
      "Tab active",
      "Tab inactive",

    },       
})

--------------------------------
--------  Tools Panel  --------
--------------------------------
--zztools 

GUI.New("pnl_Tools", "dh_Panel", {
    z = 100,
    x = 0,
    y = TOOLS_TOP,
    w = DHTK.APP_WIDTH,
    h = TOOLS_HEIGHT,
    border_width = 2, 
    col_border = "panel_border",
    col_bg = "wnd_bg",
    col_backdrop = "wnd_bg",        
})

-------------------------------
----       Column 1      ----
-------------------------------
--zzcol1
GUI.New("mbx_ColorNames", "dh_Menubox", {
    z = 98,
    x = 16, 
    y = 36 + TOOLS_TOP, 
    w = 206, 
    h = 32, 
    caption = "Color Names",
    font_text = "sans22",
    noarrow = false,
    optarray = COLOR_DISPLAY_NAMES,
    curr_opt = 1,
    align_text = "left",
    col_text = "elm_txt",
    col_backdrop = "wnd_bg",        
})

--zzlbx
GUI.New("lbx_ColorUses", "dh_Listbox", {
    z = 97,
    x = 16, 
    y = 104 + TOOLS_TOP, 
    w = 206, 
    h = 156, 
    list = COLOR_USES["wnd_bg"],
    multi = false,
    caption = "Color Uses",
    pad = 4,
    shadow = false,
    font_text = "sans22",
    col_sel_text = "sel_txt",
    col_track = "btn_face",
    col_backdrop = "wnd_bg",        
    scrollbar_width = 12,
    line_height = 1.1,
})

GUI.New("lbl_Note01", "dh_Label", {
    z = 99,
    x = 20, 
    y = 264 + TOOLS_TOP, 
    --text = "(L) Lokasenna defined",
    text = "(L) Lokasenna only\n(D)  dh_Toolkit only\n* Lokasenna fixed in code  ",    
    font = "sans20",
    col_bg = "wnd_bg",      
    col_text = "txt",
})

-------------------------------
------     Column 2    ------
-------------------------------
--zzcol2  

GUI.New("slider_Red", "dh_Slider_H", {
    z = 96,  
    x = 230,   
    y = 4 + TOOLS_TOP,
    w = 404,  
    h = 64,
    track_thk = 8,
    thumb_style = "long",
    caption = "Red",
    font_caption = "sans24", 
    cap_pad_x = -4,
    cap_pad_y = 12,
        
    min = 0,
    max = 255,
    default = 128,
    inc = 1,
    output = nil,
    
    border_width = 0,
    radius = 0,
    shadow = true,
    
    show_values = false,
    -- This also affects display values
    font_values = "sans24", 
    col_bg = "wnd_bg",
    col_backdrop = "wnd_bg",
    col_values = "txt",
    col_thumb = "thumb_body",
    col_thumb_outline = "btn_outline",
    col_fill = "track_fill",  
 
    show_tickmarks = true,  --false,
    show_min_max = false,
	min_max_values = {{0,"0"}, {255,"255"}},
			
    display_style = "box",
    display_w = 48,
    display_h = 28,  
    display_pos = "integrated",
    track_offset = 2,
    display_align = "center",
})

GUI.New("slider_Green", "dh_Slider_H", {
    z = 95, 
    x = 230,  
    y = 68 + TOOLS_TOP,
    w = 404, 
    h = 64,
    track_thk = 8,
    thumb_style = "long",
    caption = "Green",
    font_caption = "sans24",  --"sans22",
    cap_pad_x = -4,
    cap_pad_y = 12,
        
    min = 0,
    max = 255,
    default = 128,
    inc = 1,
    output = nil,
    
    border_width = 0,
    radius = 0,
    shadow = true,    
    
    show_values = false,
    -- This also affects display values
    font_values = "sans24", 
    col_bg = "wnd_bg",
    col_backdrop = "wnd_bg",
    col_values = "txt",
    col_thumb = "thumb_body",
    col_thumb_outline = "btn_outline",
    col_fill = "track_fill",  

    show_tickmarks = true,  --false,
    show_min_max = false,
	min_max_values = {{0,"0"}, {255,"255"}},
			
    display_style = "box",
    display_w = 48,
    display_h = 28, 
    display_pos = "integrated",
    track_offset = 2,
    display_align = "center",
})

GUI.New("slider_Blue", "dh_Slider_H", {
    z = 94,  
    x = 230,   
    y = 132 + TOOLS_TOP,
    w = 404,  
    h = 64,
    track_thk = 8,
    thumb_style = "long",
    caption = "Blue",
    font_caption = "sans24",  --"sans22",
    cap_pad_x = -4,
    cap_pad_y = 12,
        
    min = 0,
    max = 255,
    default = 128,
    inc = 1,
    output = nil,
    
    border_width = 0,
    radius = 0,
    shadow = true,    
    
    show_values = false,
    -- This also affects display values
    font_values = "sans24",  
    col_bg = "wnd_bg",
    col_backdrop = "wnd_bg",
    col_values = "txt",
    col_thumb = "thumb_body",
    col_thumb_outline = "btn_outline",
    col_fill = "track_fill",  
 
    show_tickmarks = true,  --false,
    show_min_max = false,
	min_max_values = {{0,"0"}, {255,"255"}},
			
    display_style = "box",
    display_w = 48,
    display_h = 28,  
    display_pos = "integrated",
    track_offset = 2,
    display_align = "center",
})

--------------------------------------
--zztools
GUI.New("pnl_StartColor", "dh_Panel", {
    z = 93,  
    x = 240,
    y = 232 + TOOLS_TOP,
    w = 96,
    h = 96,
    border_width = 4, 
    radius = 8,
    caption = "Start Color",
    cap_centered = true,
    cap_pad_x = 0, 
    col_border = "panel_border",	
    col_bg = "start_color"
})

GUI.New("btn_ResetColor", "dh_Button", {
    z = 64,  -- DO NOT CHANGE!
    x = 344, 
    y = 256 + TOOLS_TOP,  
    w = 80, 
    h = 28, 
    text = "Reset >",
    font = "sans22",
    col_text = "btn_txt",
    col_bg = "btn_face",	
    expanded = false,
    func = btn_ResetColorClick,
})

GUI.New("btn_ConfirmResetColor", "dh_Button", {
    z = 63,  -- DO NOT CHANGE!
    x = 348, 
    y = 292 + TOOLS_TOP,
    w = 28, 
    h = 28, 
    text = "Y",
    font = "sans22",
    col_text = "btn_txt",
    col_bg = "btn_face",	
    func = btn_ConfirmResetColorClick
})

GUI.New("btn_CancelResetColor", "dh_Button", {
    z = 62,  -- DO NOT CHANGE!
    x = 392, 
    y = 292 + TOOLS_TOP, 
    w = 28, 
    h = 28, 
    text = "N",
    font = "sans22",
    col_text = "btn_txt",
    col_bg = "btn_face",	
    func = btn_CancelResetColorClick
})

--------------------------------------
GUI.New("pnl_StartColorActive", "dh_Panel", {
    z = 92,  
    x = 344,
    y = 216 + TOOLS_TOP,
    w = 24,
    h = 24,
    radius = 0,
    border_width = 3, 
    col_border = "black",
    col_bg = "dark_gray" --"black",
})

GUI.New("pnl_CopyColor", "dh_Panel", {
    z = 91,  
    x = 392,
    y = 212 + TOOLS_TOP,
    w = 32,
    h = 32,
    radius = 0,
    border_width = 3, 
    col_border = "panel_border",
    col_bg = "copy_color",
    -- Add property to hold which color panel last clicked.
    curr_col_sel = "new_color_selected"
})

GUI.New("btn_CopyColor", "dh_Button", {
    z = 90, 
    x = 440, 
    y = 212 + TOOLS_TOP,
    w = 32, 
    h = 32, 
    text = ">",
    font = "mono28",
    col_text = "btn_txt",
    col_bg = "btn_face",
})

GUI.New("pnl_NewColorActive", "dh_Panel", {
    z = 89,  
    x = 496,
    y = 216 + TOOLS_TOP,
    w = 24,
    h = 24,
    radius = 0,
    border_width = 3, 
    col_border = "black",
    col_bg = "light_gray" --"white",
})

--------------------------------------
GUI.New("btn_SaveColor", "dh_Button", {
    z = 67,  -- DO NOT CHANGE!
    x = 440, 
    y = 256 + TOOLS_TOP, 
    w = 80, 
    h = 28, 
    text = "< Save",
    font = "sans22",
    col_text = "btn_txt",
    col_bg = "btn_face",
    func = btn_SaveColorClick,
})

GUI.New("btn_ConfirmSaveColor", "dh_Button", {
    z = 66,  -- DO NOT CHANGE!
    x = 444, 
    y = 292 + TOOLS_TOP,  
    w = 28, 
    h = 28, 
    text = "Y",
    font = "sans22",
    col_text = "btn_txt",
    col_bg = "btn_face",	
    func = btn_ConfirmSaveColorClick,
})

GUI.New("btn_CancelSaveColor", "dh_Button", {
    z = 65,  -- DO NOT CHANGE!
    x = 488, 
    y = 292 + TOOLS_TOP,  
    w = 28, 
    h = 28, 
    text = "N",
    font = "sans22",
    col_text = "btn_txt",
    col_bg = "btn_face",	
    func = btn_CancelSaveColorClick,
})

------------------------------------

GUI.New("pnl_NewColor", "dh_Panel", {
    z = 88, 
    x = 528, 
    y = 232 + TOOLS_TOP,
    w = 96,
    h = 96,
    border_width = 4, 
    radius = 8,
    caption = "New Color",
    cap_centered = true,
    cap_pad_x = 0,     
    col_border = "panel_border",	
    col_bg = "new_color",
    
    -- added property to hold last selected color.
    curr_color = "wnd_bg",
})

---------------------------------------
-- Display color props or assignments
---------------------------------------
--zzdisplay
GUI.New("pnl_PropertyAssignments", "dh_Panel", {
    z = 3,
    x = 0, 
    y = TAB_HEIGHT, 
    w = DHTK.APP_WIDTH, 
    h = DHTK.APP_HEIGHT - TAB_HEIGHT,
    border_width = 4, 
    radius = 0, 
    col_border = "panel_border",	
    col_bg = "wnd_bg",
    col_text = "panel_txt",
    --pad = 8,  -- from inside border?
})

GUI.New("lbl_PropertyAssignments", "dh_Label", {
    z = 2,
    x = 16, 
    y = TAB_HEIGHT + 8, 
    text = "Lokasenna Assignments:",
    font = "sans24",
    col_bg = "wnd_bg",
})

GUI.New("lbl_PropertyAssignments2", "dh_Label", {
    z = 2,
    x = 288, 
    y = TAB_HEIGHT + 8, 
    --text = "[color]; Can't be overridden\n%; Optional by overriding",
    text = "[color]; Can't be overridden",    
    font = "sans22",
    col_bg = "wnd_bg",
})

GUI.New("lbx_PropertyAssignments", "dh_Listbox", {
    z = 2,
    x = 8, 
    y = TAB_HEIGHT + 56, 
    w = DHTK.APP_WIDTH - 16, 
    h = DHTK.APP_HEIGHT - (TAB_HEIGHT + 68),  -- 44 is menu height plus pad 
    --list = {"replace","this","with","list"}, --{"item 1","item 2"},
    list = {},
    multi = false,
    caption = "",
    pad = 8,
    line_height = 1.25,
    scrollbar_width = 16,
    shadow = false,
    col_frame = "panel_txt",  --"txt",        
    col_bg = "panel_bg",
    col_text = "panel_txt",
    col_sel_text = "sel_txt", --"elm_fill",
    sel_alpha = 0.5,
    col_track = "btn_face",
    font_text = "mono16", -- list font
    frame_use_outline = true,
})

GUI.New("btn_ClosePropertyAssignments", "dh_Button", {
    z = 1,
    x = DHTK.APP_WIDTH - 44, 
    y = TAB_HEIGHT + 12, 
    w = 32, 
    h = 32, 
    text = "X",
    font = "mono22",
    col_text = "panel_txt",
    col_bg = "panel_bg",	
    func = btn_ClosePropertyAssignmentsClick,
})

GUI.elms_hide[1] = true
GUI.elms_hide[2] = true
GUI.elms_hide[3] = true

--====================================
  ------   Method Overrides  ------
--====================================
--zzoverrides

--[=[
--!!! USED FOR DEBUGGING
function GUI.elms.btn_Tab3:onmouseup()

    GUI.dh_Button.onmouseup(self)

    --GUI.Msg("\nsize GUI.buffers : " .. tostring(DHTK.hash_table_length(GUI.buffers)))
    --GUI.Msg("size GUI.freed_buffers : " .. tostring(DHTK.hash_table_length(GUI.freed_buffers)))        
--xxc    
    GUI.Msg(" clear ext state")
    reaper.SetExtState("dh_Toolkit", "user-themes-test", "", true)
end

function GUI.oncrash()

    GUI.Msg("\nsize GUI.buffers : " .. tostring(DHTK.hash_table_length(GUI.buffers)))
    GUI.Msg("size GUI.freed_buffers : " .. tostring(DHTK.hash_table_length(GUI.freed_buffers)))    

end 
--]=]
 
-- Override Menubar onmouseup.  
-- menuitem[1] is display name.
-- menuitem[2] is function.
-- menuitem[3] is param table.
-- menuitem[4] is option group ID.

function GUI.elms.menu_Tab2_Lokasenna:onmouseup()
    --GUI.Msg("Menubar:onmouseup")
    if not self.mousemnu then return end

    gfx.x, gfx.y = self.x + self:measuretitles(self.mousemnu - 1, true), self.y + self.h
    local menu_str, sep_arr = self:prepmenu()
    local opt = gfx.showmenu(menu_str)

	if #sep_arr > 0 then opt = self:stripseps(opt, sep_arr) end

    if opt > 0 then
    
        -- If item checked then return.
        local sel_str = self.menus[self.mousemnu].options[opt][1]
        if string.match(sel_str, "*") then return end
        
        -- Run function.
        
        --??? params is a table. Unpack it in function?
        local params = self.menus[self.mousemnu].options[opt][3]
        
        --[=[
        GUI.Msg("menubar mouseup opt: " .. tostring(opt))
        GUI.Msg("menubar mouseup opt[1]: " .. self.menus[self.mousemnu].options[opt][1])
        GUI.Msg("menubar mouseup type opt[2]: " .. type(self.menus[self.mousemnu].options[opt][2]))                
        GUI.Msg("menubar mouseup size of opt[3] : " .. tostring(#self.menus[self.mousemnu].options[opt][3]))
        GUI.Msg("menubar mouseup opt[3][1]] : " .. self.menus[self.mousemnu].options[opt][3][1]) 
        GUI.Msg("menubar mouseup opt[3][2]] : " .. self.menus[self.mousemnu].options[opt][3][2])         
        GUI.Msg("menubar mouseup opt[3][3]] : " .. self.menus[self.mousemnu].options[opt][3][3])         
        GUI.Msg("menubar mouseup opt[3][4]] : " .. self.menus[self.mousemnu].options[opt][3][4])                        
        --do return end
        --]=]
        self.menus[self.mousemnu].options[opt][2](params)

        -- Update checked display names. 

        -- This is selected option.
        local opt_id = self.menus[self.mousemnu].options[opt][4]

        -- Find and uncheck an item in same group using group ID.
        for _, item in pairs(self.menus[self.mousemnu].options) do
        
            local item_id = item[4]
            
            if item_id and item_id == opt_id then
                --GUI.Msg("Trying to uncheck item")
                --local str = self.menus[self.mousemnu].options[opt][1]
                local str = item[1]
                local s_idx, e_idx = string.find(str, "*")
                if s_idx then
                    str = str.gsub(str, "*", "")
                    --self.menus[self.mousemnu].options[opt][1] = str
                    item[1] = str
                    break
                end
            end

        end
        
        -- This previously added checked to "show" menu item.
        -- But then "show" function wouldn"t execute because of "*" check earlier.
        
        if #self.menus[self.mousemnu].options[opt] > 2 then
            -- Check selected item.
            sel_str = sel_str .. "*"
            self.menus[self.mousemnu].options[opt][1] = sel_str
        end
        
    end
        
	self:redraw()

end

--zzmenu3
-- Override Menubar onmouseup.  
-- menuitem[1] is display name.
-- menuitem[2] is function.
-- menuitem[3] is param table.
-- menuitem[4] is option group ID.

function GUI.elms.menu_Tab3_Toolkit:onmouseup()
    --GUI.Msg("Menubar:onmouseup")
    if not self.mousemnu then return end

    gfx.x, gfx.y = self.x + self:measuretitles(self.mousemnu - 1, true), self.y + self.h
    local menu_str, sep_arr = self:prepmenu()
    local opt = gfx.showmenu(menu_str)

	if #sep_arr > 0 then opt = self:stripseps(opt, sep_arr) end

    if opt > 0 then
    
        -- If item checked then return.
        local sel_str = self.menus[self.mousemnu].options[opt][1]
        if string.match(sel_str, "*") then return end
    
        -- Run function.
        
        --??? params is a table. Unpack it in function?
        local params = self.menus[self.mousemnu].options[opt][3]
        self.menus[self.mousemnu].options[opt][2](params)

        -- Update checked display names. 
        
        -- This is selected option.
        local opt_id = self.menus[self.mousemnu].options[opt][4]

        -- Find and uncheck an item in same group using group ID.
        for _, item in pairs(self.menus[self.mousemnu].options) do
        
            --GUI.Msg("item[1] display name : " .. item[1])
            --GUI.Msg("item[4] group id     : " .. tostring(item[4]))
        
            local item_id = item[4]
            
            if item_id and item_id == opt_id then
                --GUI.Msg("Trying to uncheck item")
                --local str = self.menus[self.mousemnu].options[opt][1]
                local str = item[1]
                local s_idx, e_idx = string.find(str, "*")
                if s_idx then
                    str = str.gsub(str, "*", "")
                    --self.menus[self.mousemnu].options[opt][1] = str
                    item[1] = str
                    break
                end
            end
        end

        if #self.menus[self.mousemnu].options[opt] > 2 then
            -- Check selected item.
            sel_str = sel_str .. "*"
            self.menus[self.mousemnu].options[opt][1] = sel_str
        end        
    end
        
	self:redraw()

end

--------------------------------------
--zzsliders
--------------------------------------

function GUI.dh_Slider_H:onmouseup()

    local val = self.curstep    
    
    -- If in display space inc/dec val.

    if GUI.mouse.y < (self.y + self.display_space) then 
        --GUI.Msg("    mouse in display space, curval is : " .. tostring(val))
        --GUI.Msg("    mouse in display space, curstep is : " .. tostring(self.curstep))    
        if GUI.mouse.x < self.x + self.display_w then
            --GUI.Msg("    mouse in top left")
            val = val - 1
            if val < 0 then val = 0 end
        elseif GUI.mouse.x > self.x + self.display_x then
            --GUI.Msg("    mouse in top right")
            val = val + 1
            if val > 255 then val = 255 end
        end
        
        -- Update slider and redraw it.
        self:val(val)
    
    end

    -- Need to know which color attribute to change.
    local i = (self.name == "slider_Red") and 1
           or (self.name == "slider_Green") and 2
           or (self.name == "slider_Blue") and 3
           
    val = val / 255       

    -- Update pnl_NewColor.
    GUI.colors.new_color[i] = val
    GUI.elms.pnl_NewColor:init()
    GUI.elms.pnl_NewColor:redraw()

end

-- Disable doubleclick.
function GUI.dh_Slider_H:ondoubleclick()
    return
end


function GUI.elms.slider_Red:onwheel()

	-- Run the element's normal method. Sets current handle retval.
	GUI.dh_Slider_H.onwheel(self)

	-- Add our code --
	
	local retval = GUI.Val("slider_Red")
	
	-- Update pnl_NewColor.
	-- # Be sure pnl_NewColor col_bg is set to "new_color".
	-- # Watch performance!
	GUI.colors.new_color[1] = retval / 255
	GUI.elms.pnl_NewColor:init()
	GUI.elms.pnl_NewColor:redraw()
    
end	

function GUI.elms.slider_Green:onwheel()

	-- Run the element's normal method. Sets current handle retval.
	GUI.dh_Slider_H.onwheel(self)

	-- Add our code --
	
	local retval = GUI.Val("slider_Green")

    local val = self.curstep 	
	-- Update pnl_NewColor.
	-- # Be sure pnl_NewColor col_bg is set to "new_color".
	-- # Watch performance!
	GUI.colors.new_color[2] = retval / 255
	GUI.elms.pnl_NewColor:init()
	GUI.elms.pnl_NewColor:redraw()
    
end	

function GUI.elms.slider_Blue:onwheel()

	-- Run the element's normal method. Sets current handle retval.
	GUI.dh_Slider_H.onwheel(self)

	-- Add our code --
	
	local retval = GUI.Val("slider_Blue")
	
	-- Update pnl_NewColor.
	-- # Be sure pnl_NewColor col_bg is set to "new_color".
	-- # Watch performance!
	GUI.colors.new_color[3] = retval / 255
	GUI.elms.pnl_NewColor:init()
	GUI.elms.pnl_NewColor:redraw()
    
end
--zzdrag
function GUI.elms.slider_Red:ondrag()

	-- Run the element's normal method. Sets current handle retval.
	GUI.dh_Slider_H.ondrag(self)

	-- Add our code --

	-- Update new color.
	GUI.colors.new_color[1] = self.retval / 255
	GUI.elms.pnl_NewColor:init()
	GUI.elms.pnl_NewColor:redraw()
    
end

function GUI.elms.slider_Green:ondrag()

	-- Run the element's normal method. Sets current handle retval.
	GUI.dh_Slider_H.ondrag(self)

	-- Add our code --

	-- Update new color.
	GUI.colors.new_color[2] = self.retval / 255
	GUI.elms.pnl_NewColor:init()
	GUI.elms.pnl_NewColor:redraw()
    
end

function GUI.elms.slider_Blue:ondrag()

	-- Run the element's normal method. Sets current handle retval.
	GUI.dh_Slider_H.ondrag(self)

	-- Add our code --

	-- Update new color.
	GUI.colors.new_color[3] = self.retval / 255
	GUI.elms.pnl_NewColor:init()
	GUI.elms.pnl_NewColor:redraw()
    
end	

--------------------------------------------------
--       BUTTONS
--------------------------------------------------
-- Click on pnl_StartColor to update GUI with start_color,
-- When color was selected its name is stored in pnl_NewColor.

function GUI.elms.pnl_StartColor:onmouseup()
    
    -- No need to run normal method as it is empty.
    
    -- Get color name. 
    -- Menubox previously had list of COLOR_NAMES.
    -- Now col_name saved in color panel.
    -- Then saved in pnl_NewColor when selection made.    
	   
	local col_name = GUI.elms.pnl_NewColor.curr_color
	
	-- Update GUI color.
    GUI.colors[col_name] = dhth.set_color(GUI.colors.start_color)
	   
	-- Update reference for copy color.
	GUI.elms.pnl_CopyColor.curr_col_sel = "start_color_selected"    

    -- If color is sel_txt then update sel_alpha slider and label.
    
	if GUI.elms.pnl_NewColor.curr_color == "sel_txt" then
	    local sel_alpha_val = math.floor(GUI.colors.start_color[4] * 10 + 0.5)

	    GUI.elms.lbl_SelAlphaVal.text = tostring(sel_alpha_val)    
	    GUI.Val("slider_SelAlpha", sel_alpha_val) 
	end 
	
    
    -- Update sliders and value labels.
    
    local colval = math.floor((GUI.colors.start_color[1] * 255) + 0.5)
    GUI.Val("slider_Red", colval)
    
    colval = math.floor((GUI.colors.start_color[2] * 255) + 0.5)
    GUI.Val("slider_Green", colval)
    
    colval = math.floor((GUI.colors.start_color[3] * 255) + 0.5)
    GUI.Val("slider_Blue", colval)
    
    GUI.elms.pnl_StartColorActive.col_bg = "light_gray" --"white"
    GUI.elms.pnl_NewColorActive.col_bg = "dark_gray" --"black"    
    
    -- Update GUI --
    
    -- Doesn't update hidden layers.
    --GUI.redraw_z[0] = true  
    --GUI.update_elms_list(true)
    
	for key, __ in pairs(GUI.elms) do
        GUI.elms[key]:init()
        GUI.elms[key]:redraw()
    end 

end

--zzmenu3a  
-- Click on pnl_NewColor to update window with new_color.
-- When color was selected its name is stored in pnl_NewColor.

function GUI.elms.pnl_NewColor:onmouseup()

    -- No need to run normal method as it is empty.
	
	local col_name = GUI.elms.pnl_NewColor.curr_color
	
	-- Update GUI color.
	GUI.colors[col_name] = dhth.set_color(GUI.colors.new_color)
	
	-- Update reference for copy color.
	GUI.elms.pnl_CopyColor.curr_col_sel = "new_color_selected"

	if GUI.elms.pnl_NewColor.curr_color == "sel_txt" then
	    local sel_alpha_val = math.floor(GUI.colors.new_color[4] * 10 + 0.5)

	    GUI.elms.lbl_SelAlphaVal.text = tostring(sel_alpha_val)    
	    GUI.Val("slider_SelAlpha", sel_alpha_val) 
	end 

    -- Update sliders and value labels.
    
    local colval = math.floor((GUI.colors.new_color[1] * 255) + 0.5)
    GUI.Val("slider_Red", colval)
    
    colval = math.floor((GUI.colors.new_color[2] * 255) + 0.5)
    GUI.Val("slider_Green", colval)
    
    colval = math.floor((GUI.colors.new_color[3] * 255) + 0.5)
    GUI.Val("slider_Blue", colval)
      	
    GUI.elms.pnl_StartColorActive.col_bg = "dark_gray" --"black"
    GUI.elms.pnl_NewColorActive.col_bg = "light_gray" --"white" 

    -- Update GUI.
    
    -- Doesn't update hidden layers.
    --GUI.redraw_z[0] = true  
    --GUI.update_elms_list(true)
    
	for key, __ in pairs(GUI.elms) do
	    --GUI.Msg("\n## pnl_NewColor:onmouseup : " .. key)         
        GUI.elms[key]:init()
        GUI.elms[key]:redraw()
    end 

end

-- Copy color to copy_color.

function GUI.elms.pnl_CopyColor:onmouseup()
    if self.curr_col_sel == "new_color_selected" then
        GUI.colors.copy_color = dhth.set_color(GUI.colors.new_color)
    else
        GUI.colors.copy_color = dhth.set_color(GUI.colors.start_color)
    end    
    GUI.elms.pnl_CopyColor:init()
    GUI.elms.pnl_CopyColor:redraw()
end

--zzcolor
-- Copy copy_color to new_color.

function GUI.elms.btn_CopyColor:onmouseup()

    GUI.colors.new_color = dhth.set_color(GUI.colors.copy_color)
    GUI.elms.pnl_NewColor:init()
    GUI.elms.pnl_NewColor:redraw()
    
    -- Update sliders and value labels.
    
    local colval = math.floor((GUI.colors.new_color[1] * 255) + 0.5)
    GUI.Val("slider_Red", colval)
    GUI.elms.slider_Red:redraw()
    
    colval = math.floor((GUI.colors.new_color[2] * 255) + 0.5)
    GUI.Val("slider_Green", colval)
    GUI.elms.slider_Green:redraw()
    
    colval = math.floor((GUI.colors.new_color[3] * 255) + 0.5)
    GUI.Val("slider_Blue", colval)
    GUI.elms.slider_Blue:redraw()
    
end

function GUI.elms.mbx_ColorNames:onmouseup()

    --GUI.Msg("\n# GUI.elms.mbx_ColorNames:onmouseup" )

	-- Run the element's normal method --
	GUI.dh_Menubox.onmouseup(self)
	
	-- Add our code --
	
	-- Get current selection in Menubox and populate Listbox.
	
	-- Originally menubox had list of COLOR_NAMES, 
	-- Now it has list of COLOR_DISPLAY_NAMES.
	--local _, col_name = GUI.Val("mbx_ColorNames")	
	
	local col_idx, _ = GUI.Val("mbx_ColorNames")
	local col_name = COLOR_NAMES[col_idx]

	GUI.elms.pnl_NewColor.curr_color = col_name

	GUI.elms.lbx_ColorUses.list = COLOR_USES[col_name]
	GUI.elms.lbx_ColorUses:redraw()
	
	-- Update pnl_StartColor and pnl_NewColor color.
	
	GUI.colors.start_color = dhth.set_color(START_COLORS[col_name] or {0.5,0.5,0.5,1})
	GUI.colors.new_color = dhth.set_color(GUI.colors[col_name] or {0.5,0.5,0.5,1})	
	
	GUI.elms.pnl_StartColor:init()
	GUI.elms.pnl_StartColor:redraw()
    	
    GUI.elms.pnl_NewColor:init()
    GUI.elms.pnl_NewColor:redraw()
     	
    GUI.elms.pnl_StartColorActive.col_bg = "dark_gray"
    GUI.elms.pnl_StartColorActive:init()
    GUI.elms.pnl_StartColorActive:redraw()
    GUI.elms.pnl_NewColorActive.col_bg = "light_gray"
    GUI.elms.pnl_NewColorActive:init()
    GUI.elms.pnl_NewColorActive:redraw()    
    
    -- Update sliders and value labels.
    
    local colval = math.floor((GUI.colors.new_color[1] * 255) + 0.5)
    GUI.Val("slider_Red", colval)
    GUI.elms.slider_Red:redraw()
    
    colval = math.floor((GUI.colors.new_color[2] * 255) + 0.5)
    GUI.Val("slider_Green", colval)
    GUI.elms.slider_Green:redraw()
    
    colval = math.floor((GUI.colors.new_color[3] * 255) + 0.5)
    GUI.Val("slider_Blue", colval)
    GUI.elms.slider_Blue:redraw()
		
end

--zztab3a
function GUI.elms.chkl_Tab3_UseOutline:onmouseup()

	-- Run the element's normal method --
	GUI.dh_Checklist.onmouseup(self)

    GUI.colors["metadata"][4] = self.optsel[1] and 0 or 1
    local thk = self.optsel[2] and 2 or 1
    tab3_property_assignments.frame_thk[2] = thk
    
    for _, elm_name in ipairs(UPDATE_OUTLINE_ELMS) do
        
        GUI.elms[elm_name].frame_thk = thk
        GUI.elms[elm_name]:init()
        GUI.elms[elm_name]:redraw()
    
    end
    
end

---------------------------------------------------------------------------------

-- This should include every attribute that can be changed from menubar.

local function setTab2ElmsProperties(state)
    GUI.elms.menu_Tab2_Lokasenna.col_bg = tab2_property_assignments.menubar_bg[state]
    GUI.elms.menu_Tab2_Lokasenna.col_txt = tab2_property_assignments.menubar_text[state]
    GUI.elms.menu_Tab2_Lokasenna.font = tab2_property_assignments.menubar_font[state]
    GUI.elms.frm_Tab2_Elements.fill = tab2_property_assignments.frame_fill[state]
    GUI.elms.frm_Tab2_Elements.color = tab2_property_assignments.frame_color[state]
    GUI.elms.frm_Tab2_Elements.bg = tab2_property_assignments.frame_bg[state]
    GUI.elms.radio_Tab2_Properties.font_b = tab2_property_assignments.radio_font[state]
    GUI.elms.radio_Tab2_Properties.col_fill = tab2_property_assignments.option_bubble_fill[state]    
    GUI.elms.tabs_Tab2.col_tab_a = tab2_property_assignments.tab_active[state]
    GUI.elms.tabs_Tab2.col_tab_b = tab2_property_assignments.tab_inactive[state]		   	    	
   
    GUI.elms.mbx_Tab2.col_txt = tab2_property_assignments.element_text[state]  
    GUI.elms.lbx_Tab2.color = tab2_property_assignments.element_text[state]
    GUI.elms.lbx_Tab2.col_fill = tab2_property_assignments.scrollbar_thumb[state]  
    GUI.elms.knob_Tab2.col_body = tab2_property_assignments.knob_body[state] 
    GUI.elms.knob_Tab2.col_head = tab2_property_assignments.knob_head[state]  
    GUI.elms.btn_Tab2.col_fill = tab2_property_assignments.button_face[state]  
    GUI.elms.btn_Tab2.col_txt = tab2_property_assignments.button_text[state] 
	GUI.elms.btn_Tab2.font = tab2_property_assignments.button_font[state]	  
    GUI.elms.slider_Tab2.col_fill = tab2_property_assignments.slider_track_fill[state] 
    GUI.elms.slider_Tab2.col_thumb = tab2_property_assignments.slider_thumb[state]

    GUI.elms.tbx_Tab2.color = tab2_property_assignments.element_text[state]  
    GUI.elms.txe_Tab2.color = tab2_property_assignments.element_text[state]
    GUI.elms.txe_Tab2.col_fill = tab2_property_assignments.scrollbar_thumb[state]
    
--zzmenu2a    
    -- label, knob, and slider background and text colors
    -- depend on frame background color.
    
    local bg_color
    
    if GUI.elms.frm_Tab2_Elements.fill == true then 
        bg_color = tab2_property_assignments.frame_color[state]    
    else
        bg_color = tab2_property_assignments.frame_bg[state]    
    end
    
    local text_color = tab2_property_assignments.frame_text[state]
    
    GUI.elms.lbl_Tab2_Elements.bg = bg_color  
    GUI.elms.lbl_Tab2_Elements.color = text_color  
    GUI.elms.knob_Tab2.bg = bg_color  
    GUI.elms.knob_Tab2.col_txt = text_color  
    GUI.elms.slider_Tab2.bg = bg_color  
    GUI.elms.slider_Tab2.col_txt = text_color  

end

function GUI.elms.radio_Tab2_Properties:onmouseup()

	-- Run the element's normal method --
	GUI.Radio.onmouseup(self)
	
	-- Our code --

	if self.retval == 1 then
	    -- Set to defaults.
	    setTab2ElmsProperties(1)
    else
        -- Set to overrides. Get from overrides table.
	    setTab2ElmsProperties(2)
    end	
	
	-- Update elements.
    for _, elm_name in ipairs(TAB2_UPDATE_ELMS) do
        GUI.elms[elm_name]:init()
        GUI.elms[elm_name]:redraw()
    end    
	
end

--zzwheel
-- Disable wheel.
function GUI.elms.radio_Tab2_Properties:onwheel()
    -- Do nothing.
end

--zzmenu3a 

local function setTab3ElmsProperties(state)
    GUI.elms.menu_Tab3_Toolkit.col_bg = tab3_property_assignments.menubar_bg[state]
    GUI.elms.menu_Tab3_Toolkit.col_text = tab3_property_assignments.menubar_text[state]
    GUI.elms.menu_Tab3_Toolkit.col_over = tab3_property_assignments.menubar_over[state]
    GUI.elms.menu_Tab3_Toolkit.font = tab3_property_assignments.menubar_font[state]
        	
	GUI.elms.radio_Tab3_BG.col_border = tab3_property_assignments.panel_border[state]        	
	GUI.elms.radio_Tab3_BG.col_bg = tab3_property_assignments.panel_bg[state]
    GUI.elms.radio_Tab3_BG.font_text = tab3_property_assignments.radio_font[state]    	
    GUI.elms.radio_Tab3_BG.col_text = tab3_property_assignments.panel_text[state]
    
	GUI.elms.chkl_Tab3_UseOutline.col_bg = tab3_property_assignments.panel_bg[state]
    GUI.elms.chkl_Tab3_UseOutline.font_text = tab3_property_assignments.radio_font[state]    	
    GUI.elms.chkl_Tab3_UseOutline.col_text = tab3_property_assignments.panel_text[state]            

    GUI.elms.pnl_Tab3_Elements.border_width = tab3_property_assignments.panel_border_width[state]
    GUI.elms.pnl_Tab3_Elements.radius = tab3_property_assignments.panel_radius[state]    
    GUI.elms.pnl_Tab3_Elements.col_bg = tab3_property_assignments.panel_bg[state]
    GUI.elms.pnl_Tab3_Elements.col_border = tab3_property_assignments.panel_border[state]
    GUI.elms.pnl_Tab3_Elements.col_backdrop = tab3_property_assignments.panel_bg[state]

    GUI.elms.lbl_Tab3_Elements.col_bg = tab3_property_assignments.panel_bg[state]
    GUI.elms.lbl_Tab3_Elements.col_text = tab3_property_assignments.panel_text[state]
        
	GUI.elms.mbx_Tab3.col_backdrop = tab3_property_assignments.panel_bg[state]  
	
	GUI.elms.lbx_Tab3.col_track = tab3_property_assignments.scrollbar_track[state]
    GUI.elms.lbx_Tab3.scrollbar_width = tab3_property_assignments.scrollbar_width[state]  
	GUI.elms.lbx_Tab3.col_backdrop = tab3_property_assignments.panel_bg[state]    	

    GUI.elms.knob_Tab3.knob_style = tab3_property_assignments.knob_style[state] 
    GUI.elms.knob_Tab3.col_bg = tab3_property_assignments.panel_bg[state] 
	GUI.elms.knob_Tab3.col_body = tab3_property_assignments.knob_body[state] 
	GUI.elms.knob_Tab3.col_outline = tab3_property_assignments.knob_outline[state]	
	--GUI.elms.knob_Tab3.col_indicator = tab3_property_assignments.knob_indicator[state]
    GUI.elms.knob_Tab3.col_values = tab3_property_assignments.panel_text[state]      	  
    GUI.elms.knob_Tab3.col_cap_text = tab3_property_assignments.panel_text[state]      	  	
	
	GUI.elms.btn_Tab3.col_bg = tab3_property_assignments.button_face[state]  
	GUI.elms.btn_Tab3.col_text = tab3_property_assignments.button_text[state]  
    GUI.elms.btn_Tab3.font = tab3_property_assignments.button_font[state]      
    
    GUI.elms.lbl_SelAlpha.col_bg = tab3_property_assignments.panel_bg[state]
    GUI.elms.lbl_SelAlpha.col_text = tab3_property_assignments.panel_text[state]    
    
    GUI.elms.lbl_SelAlphaVal.col_bg = tab3_property_assignments.panel_bg[state]
    GUI.elms.lbl_SelAlphaVal.col_text = tab3_property_assignments.panel_text[state] 
     
    GUI.elms.slider_SelAlpha.col_bg = tab3_property_assignments.panel_bg[state]
    GUI.elms.slider_SelAlpha.col_backdrop = tab3_property_assignments.panel_bg[state]    
	GUI.elms.slider_SelAlpha.col_fill = tab3_property_assignments.slider_track_fill[state] 
	GUI.elms.slider_SelAlpha.col_thumb = tab3_property_assignments.slider_thumb[state]
	GUI.elms.slider_SelAlpha.col_thumb_outline = tab3_property_assignments.slider_thumb_outline[state]
    GUI.elms.slider_SelAlpha.col_values = tab3_property_assignments.panel_text[state]    
    
    local scaled_thk = math.tointeger(tab3_property_assignments.slider_thickness[state] * tonumber(DHTK.window_settings.scale))
    GUI.elms.slider_SelAlpha.track_thk = scaled_thk       	    	          	    		   	    	
    
	GUI.elms.tbx_Tab3.col_backdrop = tab3_property_assignments.panel_bg[state] 
	
	GUI.elms.txe_Tab3.col_backdrop = tab3_property_assignments.panel_bg[state] 
	GUI.elms.txe_Tab3.col_track = tab3_property_assignments.scrollbar_track[state]
    GUI.elms.txe_Tab3.scrollbar_width = tab3_property_assignments.scrollbar_width[state]    		

end

function GUI.elms.radio_Tab3_BG:onmouseup()

    -- Run the element's normal method --
    GUI.Radio.onmouseup(self)

    -- Add our code.
    local prop_val = (self.retval == 1) and "wnd_bg" or "panel_bg"
    update_tab3_elms({nil, nil, prop_val, "panel_bg"})

end

--zzwheel
-- Disable wheel.
function GUI.elms.radio_Tab3_BG:onwheel()
    -- Do nothing.
end

function GUI.elms.tabs_ThemeDesigner:onmouseup()

	-- Run the element's normal method --
    GUI.Tabs.onmouseup(self)
    
	-- Our code --
    if self.state == 1 then
        if GUI.elms.mbx_UserThemes.visibility == "visible" then
           GUI.elms_hide[GUI.elms.mbx_UserThemes.z] = false
           GUI.elms.mbx_UserThemes:redraw()
        else
            GUI.elms_hide[GUI.elms.mbx_UserThemes.z] = true
        end    
    else
        GUI.elms_hide[GUI.elms.mbx_UserThemes.z] = true
    end    
    
    -- Hide display panel.
    GUI.elms_hide[3] = true
    GUI.elms_hide[2] = true
    GUI.elms_hide[1] = true
    
end

-- !!! Override core methods to add warning.
--zzz
function GUI.elms.mbx_dhThemes:onmouseup()

     local prev_opt = self.curr_opt
    
    -- Run the element's normal method.
    -- Gets the new selection.
    -- Menubox will not be redrawn while still within this function.
    
    GUI.dh_Menubox.onmouseup(self)
    --GUI.Msg("mbx_dhThemes:onmouseup prev_opt: " .. prev_opt)
    --GUI.Msg("mbx_dhThemes:onmouseup curr_opt: " .. self.curr_opt)    
    --GUI.Msg("mbx_dhThemes:onmouseup curr_name : " .. self.optarray[self.curr_opt])    
    
    -- No change. Clicked on current option.    
    if prev_opt == self.curr_opt then return end
    
    local new_theme_name, theme_type
    
    --GUI.Msg("mbx_dhThemes:onmouseup #USER_THEME_NAMES : " .. #USER_THEME_NAMES)     
    
    -- Needs to load user theme if there is one.
    if self.optarray[self.curr_opt] == "User" then 
        if #USER_THEME_NAMES == 0 then
            reaper.MB("There are no user themes to load!", "Whoops!", 0) 
            self.curr_opt = prev_opt                            
            return
        else
            GUI.elms.mbx_UserThemes.visibility = "visible"
            GUI.elms_hide[GUI.elms.mbx_UserThemes.z] = false 
            local _, ut_name = GUI.Val("mbx_UserThemes") 
            new_theme_name = "[User] " .. ut_name
            theme_type = "user"
        end
    
    else
        -- DH THEME selected.
        if GUI.elms.mbx_UserThemes.visibility == "visible" then
            GUI.elms.mbx_UserThemes.visibility = "hidden"
            GUI.elms_hide[GUI.elms.mbx_UserThemes.z] = true 
        end 
        local _, ut_name = GUI.Val("mbx_UserThemes")
        new_theme_name = self.optarray[self.curr_opt]
        theme_type = "dhth"
    end
    
    -- # Prompt when setting a theme.
    local msg =  'Set theme to : ' .. new_theme_name .. '\n\n' ..
                 'Setting a theme will reset the theme you are designing!\n' ..
                 'Be sure to save your theme first.\n\n    Do you wish to Continue?'

    local retval = reaper.ShowMessageBox(msg, " Warning!!!", 4)	-- retval 6 is yes							
     
    if retval ~= 6 then 
        self.curr_opt = prev_opt
        return 
    end
    
    --!!! Need to set theme name(s) here.
    
    
        local user_theme_name = self.optarray[self.curr_opt]       
    
 	setTheme(theme_type)

    --xxx TESTING
    --for k, v in pairs(GUI.elms.mbx_UserThemes.optarray) do
    --    GUI.Msg("    user theme : " .. v)
    --end

end

--zzz
function GUI.elms.mbx_UserThemes:onmouseup()

    local prev_opt = self.curr_opt

    -- Run the element's normal method.
    -- Gets the new selection.
    -- Menubox will not be redrawn while still within this function.
    
    GUI.dh_Menubox.onmouseup(self)
    
    -- No change. Clicked on current option.        
    if prev_opt == self.curr_opt then return end        
    
    -- # Prompt when setting a theme.
    local msg =  "Set theme to: [User]  " .. self.optarray[self.curr_opt] .. "\n\n" ..
                 "Setting a theme will reset the theme you are designing!\n" ..
                 "Be sure to save your theme first.\n\n    Do you wish to Continue?"
                
    local retval = reaper.ShowMessageBox(msg, " Warning!!!", 4)	-- retval 6 is yes							
     
    if retval ~= 6 then 
        self.curr_opt = prev_opt    
        return 
    end
    
    local user_theme_name = self.optarray[self.curr_opt]    
    DHTK.window_settings.user_theme = user_theme_name    

	-- tbx_UserThemeName updated in setTheme.
	
 	-- setTheme gets val from menubox.
 	setTheme("user")
 	
end

-- Disable these for now.
--[=[
function GUI.elms.mbx_dhThemes:onmouser_up()
	-- No need to run the element's normal method.
	
	-- Add our code.
	local _, val = GUI.Val("mbx_dhThemes")
	GUI.Val("tbx_UserThemeName", val)

end

function GUI.elms.mbx_UserThemes:onmouser_up()
	-- No need to run the element's normal method.
	
	-- Add our code.
	local _, val = GUI.Val("mbx_UserThemes")
	GUI.Val("tbx_UserThemeName", val)

end
--]=]

--zzsel 
-- Set text elements alpha or sel_txt alpha.

function GUI.elms.lbl_SelAlpha:onmouseup()

	-- No need to run the element's normal method --
    
    local colval = GUI.Val("slider_SelAlpha")  -- returns integer
    
    -- min -10 [0]| max 10 [21] |  default 0 [10]
    -- -10 -9 -8 -7 -6 -5 -4 -3 -2 -1  0  1  2  3  4  5  6  7  8  9 10
    --   0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20

    -- Update new color swatch if it has sel_txt.   
     
    if GUI.elms.pnl_NewColor.curr_color == "sel_txt" then
        GUI.colors.new_color[4] = colval / 10
        --??? Should I redraw?
    end
    
    GUI.colors.sel_txt[4] = colval / 10    
    GUI.Val("lbl_SelAlphaVal", colval)

    for _, elm_name in ipairs(SEL_TEXT_ELMS) do
        GUI.elms[elm_name]:redraw(GUI.elms[elm_name].z)
    end
    
    for _, elm_name in ipairs(TAB3_TEXT_ELMS) do
        GUI.elms[elm_name]:redraw(GUI.elms[elm_name].z)
    end    

end	

--====================================
  --------   SCRIPT FLOW   --------
--====================================
--zzflow  
--[==[

  Must save user themes to reaper ext state so they are 
    available to other scripts.
      reaper.SetExtState("dh_Toolkit", "user_themes", user_theme, true)
  Window settings are also saved to reaper ext state
    (that includes w, h, scale, and theme).
      reaper.SetExtState("dh_Template", "window_settings", true)
> Script load.
  If proj extstate then initialize script from it.
  Else initialize from default theme?

> Setting a theme starts design process.

-- Set theme --
Put theme name in tbx_UserThemeName.
  This is name that will be used when saving theme.
  If name exists prompt to save theme or change name.
  ? Autosave theme on script exit? Can use name autosave?
  Theme is loaded. GUI.colors contain theme colors.
      
-- Now I want to edit colors --
Select color_name from mbx_ColorNames.
  Update lbx_ColorUses to display pertinent element color fields.
  Update pnl_StartColor with GUI.colors[color_name].
  Update pnl_NewColor with GUI.colors[color_name].
    
-- Use sliders to adjust new color --
Update slider readout.
Update pnl_NewColor.
  GUI.colors["new_color"] = <newcolor>
      
Click pnl_NewColor to update theme with new color. Updates GUI.
  GUI.colors[color_name] = <new_color>
    
Click pnl_StartColor to update theme with start color. Updates GUI.
  GUI.colors[color_name] = <start_color>
      
Click btn_SaveColor -> Yes to copy new color to pnl_StartColor. "start_color" is overwritten.

Click btn_ResetColor -> Yes to copy start color to pnl_NewColor. "new_color" is overwritten.
    
Selecting a theme from a theme menubox will load the selected theme, resetting theme being edited. 

--]==]

--====================================
  --------      EXIT      --------
--====================================
--zzexit  
-- Code to execute before window closes, such as saving states and window position.

-- Save current edit state to proj extstate.
-- Although saving window settings saves theme name
-- opening script should disregard theme?

local function Exit()

    DHTK.saveWindowSettings()

    local current_colors = {}
        
    for _, col_name in ipairs(COLOR_NAMES) do
        -- Convert color to 0..255
        local col = dhth.set_color_dec2int(GUI.colors[col_name])
        current_colors[col_name] = col
    end

    local curr_proj = {}
    curr_proj.name = new_name

    local conv_colors = {}
    
    --!!! Decided to save START_COLORS as integer format.
    --curr_proj.start_colors = START_COLORS
    for col_name, col_val in pairs(START_COLORS) do
        conv_colors[col_name] = dhth.set_color_dec2int(col_val)
        --GUI.Msg("exit conv colors to decimal : " .. tostring(conv_colors[col_name][1]))
    end
    
    curr_proj.start_colors = conv_colors
    curr_proj.current_colors = current_colors

    curr_proj.tab2_property_assignments = tab2_property_assignments
    curr_proj.tab3_property_assignments = tab3_property_assignments
    local json_string = json.encode(curr_proj)
    --GUI.Msg(json_string)
    reaper.SetExtState("dh_ThemeDesigner", "curr_proj", json_string, true)
    
    --xxx FOR TESTING: So not to mess up existing project.
    -- Clears "user-themes-test" so that next start is as if there are no saved user themes. 
    --reaper.SetExtState("dh_Toolkit", "user-themes-test", "", true)

end 

-- Calls Exit when script is ending.
reaper.atexit(Exit)

--====================================
  ------  Script Initialize  ------
--====================================
--zzinit 
----------------------------------------
--   Non GUI Initialization
----------------------------------------

local function build_color_table()
    local col_table = {}
    --GUI.Msg("INIT: in build_color_table")
    for _, col_name in ipairs(COLOR_NAMES) do
        
        if not GUI.colors[col_name] then GUI.colors[col_name] = {128,128,128,255} end
        --GUI.Msg("INIT: in build_color_table col_name : " .. col_name)        
        --GUI.Msg("INIT: in build_color_table col_val : " .. GUI.colors[col_name][1])
        local newcolor = {}
        table.insert(newcolor, GUI.clamp(GUI.colors[col_name][1] / 255,0,1))
        table.insert(newcolor, GUI.clamp(GUI.colors[col_name][2] / 255,0,1))
        table.insert(newcolor, GUI.clamp(GUI.colors[col_name][3] / 255,0,1))
        table.insert(newcolor, GUI.clamp(GUI.colors[col_name][4] / 255,0,1))    

        col_table[col_name] = newcolor
    end
    --GUI.Msg("Size of newcolor is: " .. tostring(DHTK.hash_table_length(newcolor)))
    return col_table
end

-- START_COLORS are used after GUI.Init so they must be format 0..1
-- DHTK.init loads window.settings.theme.
-- If saved edit state we will override it.

local function load_saved_edit_state()

    --xxx TESTING: Mimic initial script run. start
    --do return end

    local isSuccess = false
    
    if reaper.HasExtState("dh_ThemeDesigner", "curr_proj") then
        local retval = reaper.GetExtState("dh_ThemeDesigner", "curr_proj")
        
        if retval then
            local curr_proj = json.decode(retval)
            
            if curr_proj.name then
                GUI.Val("tbx_UserThemeName", curr_proj.name)
            end            
            
            -- COLOR_NAMES will probably have at least 14 colors.
            if curr_proj.start_colors and type(curr_proj.start_colors) == "table" 
                and DHTK.hash_table_length(curr_proj.start_colors) > 14 then
                --GUI.Msg("**** INIT isSuccess = true")
                isSuccess = true

                if curr_proj.start_colors["wnd_bg"][4] > 2 then
                    -- Is integer format, convert to decimal.
                    for col_name, col_val in pairs(curr_proj.start_colors) do
                        START_COLORS[col_name] = dhth.set_color_int2dec(col_val)
                    end                
                else
                    -- Must be decimal format, okay.
                    START_COLORS = curr_proj.start_colors
                end
               
            end

            -- Override GUI.colors with saved edit state colors.
            
            for _, col_name in ipairs(COLOR_NAMES) do 
                --GUI.Msg("load_saved_edit_state: col_name is : " .. col_name)
                if not curr_proj.current_colors[col_name] then
                    GUI.colors[col_name] = {127,127,127,255}
                else
                    GUI.colors[col_name] = dhth.set_color(curr_proj.current_colors[col_name])
                end    

            end
--zzsave    
            -- Error checking if valid property value.
            -- Iterate tab3_property_assignments.
            -- Fetch saved value from curr_proj.tab3_property_assignments.
            -- Check if fetched value is legit.
            -- Must be integer, color, or font.
            -- If not valid then use default value.
            
            local assign_tables = {
                tab2_property_assignments = tab2_property_assignments,  
                tab3_property_assignments = tab3_property_assignments,  
            }
            
            for prop_table_name, prop_table in pairs(assign_tables) do
            
                if curr_proj[prop_table_name] then
                
                    local value_is_legit = false
                
                    for assign_name, assign_val in pairs(prop_table) do            
                
                        if not curr_proj[prop_table_name][assign_name] then break end
                        
                        local saved_val = curr_proj[prop_table_name][assign_name][2]
                        
                        -- Is it a number?
                        if type(saved_val) == "number" then 
                            value_is_legit = true 
                            --break    -- Go to next design properry.
                        end 
                        
                        -- Check if it a valid font.
                        if not value_is_legit then
                            for font_name, _ in pairs(GUI.fonts) do
                                if saved_val == font_name then
                                    value_is_legit = true
                                    break    -- Go to next design properry.
                                end
                            end
                        end
                        
                        -- Check if it is a valid color.
                        if not value_is_legit then
                            --GUI.Msg("LOAD: saved_val in color check : " .. tostring(saved_val))
                            for _, col_name in ipairs(COLOR_NAMES) do
                                if saved_val == col_name then
                                    if GUI.colors[saved_val] then
                                        value_is_legit = true
                                    end    
                                    break
                                end
                            end
                        end                        
                        -- If valid property not found, will keep coded default.
                        if value_is_legit then
                            prop_table[assign_name][2] = curr_proj[prop_table_name][assign_name][2]
                        end                    
                    end
                end 
                        
            end             
            
        end  --<end if retval>
        
    end  --<end HasExtState>
    
    if not isSuccess then
        --GUI.Msg("**** INIT not isSuccess")
        START_COLORS = build_color_table()
    end
    
    --GUI.Msg("Init > START_COLORS.wnd_bg : " .. START_COLORS.wnd_bg[1] .. " : " .. START_COLORS.wnd_bg[2] .. " : " .. START_COLORS.wnd_bg[3]) 
    --GUI.Msg("Init > GUI.colors.wnd_bg : " .. GUI.colors.wnd_bg[1] .. " : " .. GUI.colors.wnd_bg[2] .. " : " .. GUI.colors.wnd_bg[3]) 
    
    -- GUI is not yet initialized so it needs integer numbers.
    GUI.colors.start_color = dhth.set_color_dec2int(START_COLORS.wnd_bg)
   
end  --<end load_saved_edit_state>


load_saved_edit_state()

-- Initialize menubars checked. 
-- If init menubar checked also need to update elms.
-- Unchecked will use default - no update needed.

local function init_menubar(menus, assignment_table)

    for assignment_name, val in pairs(assignment_table) do
        
        local match_found = false
        local assigned_val = val[2]
        --local assigned_val = tostring(val[2])

        -- mnu is a list of {title, options list}.
        for _, mnu in ipairs(menus) do
            
            -- Iterate the options.
            for _, opt in ipairs(mnu.options) do

                if #opt > 2 then    -- Need this to bypass non-functional menu items.        
                      
                    if opt[3][4] == assignment_name
                    and opt[3][3] == assigned_val then
                        
                        --GUI.Msg("init_menubar option name is : " .. opt[1])
                        match_found = true
                        opt[1] = opt[1] .. "*"
                        
                        --[=[ FOR TESTING:
                        local elm_name, prop_name, prop_val, assign_name = table.unpack(opt[3])
                       
                        GUI.Msg("init_menubar elm_name is : " .. elm_name)
                        GUI.Msg("init_menubar prop_name is : " .. prop_name)    
                        GUI.Msg("init_menubar prop_val is : " .. tostring(prop_val))    
                        GUI.Msg("init_menubar assign_name is : " .. assign_name)    
                        --]=]
                        
                        --GUI.elms[elm_name][prop_name] = prop_val
                        break
                    end
                end
            end
            if match_found then break end
        end 
    end

end  --<end init_menubar>

init_menubar(GUI.elms.menu_Tab2_Lokasenna.menus, tab2_property_assignments)
init_menubar(GUI.elms.menu_Tab3_Toolkit.menus, tab3_property_assignments)

----------------------------------------
--  Initialize GUI Elements
--  Done here - after element creation
----------------------------------------
--[[ DEV NOTE: Necessary!!! ]]--
DHTK.init_scale_elms()

-- Color confirm buttons.
GUI.elms_hide[62] = true
GUI.elms_hide[63] = true
GUI.elms_hide[65] = true
GUI.elms_hide[66] = true

GUI.Val("mbx_ColorNames", 1)

GUI.elms.lbx_ColorUses.list = COLOR_USES["wnd_bg"]

-------------------------------

if DHTK.window_settings.theme == "User" then
    GUI.elms.mbx_UserThemes.visibility = "visible"
    GUI.elms_hide[GUI.elms.mbx_UserThemes.z] = false
else
    GUI.elms.mbx_UserThemes.visibility = "hidden"
    GUI.elms_hide[GUI.elms.mbx_UserThemes.z] = true
end    

-- # Prefs was set to hide during core createPrefs.
--   It should always be shown on Tab 1.
--DHTK.showPrefsWindow()

-- Should show user theme if it exists, regardless of mbx_dhThemes.
--GUI.Val("tbx_UserThemeName", (DHTK.window_settings.user_theme or ""))

if DHTK.window_settings.theme == "User" then
    GUI.Val("tbx_UserThemeName", (DHTK.window_settings.user_theme or ""))
else
    GUI.Val("tbx_UserThemeName", DHTK.window_settings.theme)
end

-------------------------------
-- Set color panels colors.
GUI.colors.start_color = dhth.set_color(GUI.colors.wnd_bg)
GUI.colors.new_color = dhth.set_color(GUI.colors.wnd_bg)

-- GUI not yet initialized so no need to convert values.

-- Initialize sliders.
GUI.Val("slider_Red", GUI.colors.start_color[1])
GUI.Val("slider_Green", GUI.colors.start_color[2])
GUI.Val("slider_Blue", GUI.colors.start_color[3])

-------------------------------
-- Initialize slider_SelAlpha.
local sel_alpha_val
--GUI.Msg("script init: START_COLORS.sel_txt[4] is : " .. tostring(START_COLORS.sel_txt[4]))
--GUI.Msg("script init: GUI.colors.sel_txt[4] is : " .. tostring(GUI.colors.sel_txt[4]))
           
-- GUI not yet initialized so value in range 0..255.  
if GUI.colors.sel_txt then
    sel_alpha_val = math.floor((GUI.colors.sel_txt[4] / 25.5) + 0.5)
    --sel_alpha_val = sel_alpha_val + 10
    --sel_alpha_val = math.floor(GUI.colors.sel_txt[4] * 10 + 0.5) 
else
    sel_alpha_val = 5
end

GUI.elms.lbl_SelAlphaVal.text = tostring(sel_alpha_val)

sel_alpha_val = sel_alpha_val - GUI.elms.slider_SelAlpha.min
GUI.Val("slider_SelAlpha", sel_alpha_val)
-------------------------------

if GUI.Val("radio_Tab2_Properties") == 1 then
    setTab2ElmsProperties(1)
else
    setTab2ElmsProperties(2)
end

setTab3ElmsProperties(2)

if tab3_property_assignments.panel_bg[2] == "wnd_bg" then
    GUI.elms.radio_Tab3_BG:val(1)
    update_tab3_elms({nil, nil, "wnd_bg", "panel_bg"})
else
    GUI.elms.radio_Tab3_BG:val(2)
    update_tab3_elms({nil, nil, "panel_bg", "panel_bg"})
end

if not GUI.colors["metadata"] then GUI.colors["metadata"] = {0, 0, 0, 1} end

--zzx should I use last selected?
GUI.elms.chkl_Tab3_UseOutline.optsel[1] = (GUI.colors.metadata[4] < 0.001) or false 
GUI.elms.chkl_Tab3_UseOutline.optsel[2] = tab3_property_assignments.frame_thk[2] 

-- Used this when testing.
--dhth.set_theme(DH_THEMES["Magenta"])
   
GUI.Val("chkl_SaveToConsole", false)

--zzx do I need this?
GUI.elms.lbx_PropertyAssignments.sel_alpha = tab3_property_assignments.sel_alpha[2]

-------------------------------

for _, elm_name in ipairs(TAB3_TEXT_ELMS) do

    GUI.elms[elm_name].col_bg = tab3_property_assignments.element_bg[2]
    GUI.elms[elm_name].col_text = tab3_property_assignments.element_text[2]

    if elm_name ~= "mbx_Tab3" then
        GUI.elms[elm_name].col_sel_text = tab3_property_assignments.element_sel_text[2]
        GUI.elms[elm_name].sel_alpha = tab3_property_assignments.element_sel_alpha[2]            
    end
    
end 

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

--[===[

--------------------------------------------------
--------   Z - LAYERS    --------
--------------------------------------------------
    ELEMENT            Z-LAYER
--------------------------------------------------

tabs_ThemeDesigner       101

-- Layer 491 requires special handling.
-- Handled with tab override.
GUI.elms.tabs_ThemeDesigner:update_sets({ 
    [1] = {481,482,483,484,485,486,487,488,489,490,491,492,493,494,495,496,497,498,499,500},
    [2] = {21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40}, -- Lokasenna elements       
    [3] = {41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60}, -- dh_Toolkit elements
    [4] = {124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150} -- colors
})

---------------------------------------
Display property assignments  
---------------------------------------
pnl_PropertyAssignments          3
lbl_PropertyAssignments          2
lbl_PropertyAssignments2         2
lbx_PropertyAssignments          2
btn_ClosePropertyAssignments     1

---------------------------------------
Tab 1 z-layers: -- Preferences 
---------------------------------------
--zztab1  --zzprefs
Tab1 holds Prefs, layers 490 - 500 defined in dh_Toolkit_core.lua.
core elms moved to layers 490 - 500, with optional at 489 down.
core "lbl_Preferences" z = 499 not used in Theme Designer.
core "btn_ClosePrefs" z = 499 not used in Theme Designer.

-- core elements
frm_Preferences        (500) from core
lbl_ScaleSectionTitle  (499) from core
 
pnl_ScaleSection       (499) from core 
lbl_CurrScaleTitle     (498) from core 
mbx_Scale              (497) from core
lbl_CurrFontScaleTitle (498) from core 
mbx_FontScale          (496) from core

chkl_UseOutlines       (495) from core
chkl_FrameThk          (494) from core
 
lbl_ThemesSectionTitle (499) from core 

pnl_ThemesSection      (499) from core 
lbl_CurrDhThemeTitle   (498) from core 
mbx_dhThemes           (491) from core 
lbl_CurrUserThemeTitle (498) from core 
mbx_UserThemes *       (490) from core 

-- toolkit elements
pnl_UserThemesSection  487
lbl_UserThemeTitle     486
tbx_UserThemeName      485
btn_RenameUserTheme    484
btn_DeleteUserTheme    483
btn_SaveUserTheme      482
chkl_SaveToConsole     481

---------------------------------------
Tab 2 z-layers: -- Lokasenna elements
---------------------------------------
frm_Tab2_Lokasenna       40
menu_Tab2_Lokasenna      39
lbl_Tab2_Properties      38
radio_Tab2_Properties    37
frm_Tab2_Tabs            36
tabs_Tab2                35
frm_Tab2_Tabs_field      34

frm_Tab2_Elements        32 
btn_Tab2                 31 
lbl_Tab2_Elements        29
lbl_Tab2_Elements2       29
mbx_Tab2                 28
lbx_Tab2                 27
knob_Tab2                26
slider_Tab2              23 
tbx_Tab2                 22 
txe_Tab2                 21 

---------------------------------------
Tab 3 z-layers: -- dh_Toolkit elements
---------------------------------------
pnl_Tab3_Toolkit         60
menu_Tab3_Toolkit        59
radio_Tab3_BG            58
chkl_Tab3_UseOutline     55

pnl_Tab3_Elements        52
btn_Tab3                 51 
lbl_Tab3_Elements        49
lbl_Tab3_Elements2       49
mbx_Tab3                 48
lbx_Tab3                 47
knob_Tab3                46
lbl_SelAlpha             45
lbl_SelAlphaVal          44
slider_SelAlpha          43
tbx_Tab3                 42
txe_Tab3                 41

---------------------------------------
Tab 4 z-layers: -- Colors
---------------------------------------
pnl_Tab4_Toolkit        150    
lbl_Lokasenna_defined   149
lbl_DHTK_defined        149
--Color Frames          123 - 147
Replaced 19 individual color labels with 3 dh_Panels.
--Color Labels          149
pnl_Tab4_Colors1        149  
pnl_Tab4_Colors2        149
pnl_Tab4_Colors3        149

---------------------------------------
Tools z-layers:    --zztools
---------------------------------------
pnl_Tools              100
mbx_ColorNames          98
lbx_ColorUses           97

lbl_Note01              99

slider_Red              96
slider_Green            95
slider_Blue             94

pnl_StartColor          93
pnl_NewColor            92

pnl_StartColorActive    91
pnl_NewColorActive      90
pnl_CopyColor           89
btn_CopyColor           88

-- Don't change
btn_ResetColor          64
btn_ConfirmResetColor   63
btn_CancelResetColor    62

-- Don't change
btn_SaveColor           67
btn_ConfirmSaveColor    66
btn_CancelSaveColor     65

-------------------------------------------
When changing a default color or property
need to check and/or update the following:

element class file
classes_chart.html page file
classes_element.html page file
dh_themedesigner_defaults.html page file

dh_Toolkit_themes.dh_Toolkit_themes.COLOR_NAMES

dh_ThemeDesigner_data.COLOR_DISPLAY_NAMES
dh_ThemeDesigner_data.COLOR_USES
dh_ThemeDesigner_data.data_color_defaults
dh_ThemeDesigner_data.tab3_property_assignments
dh_ThemeDesigner_data.tab3_display_assignments

dh_ThemeDesigner.lua menus

-------------------------------------------

--]===]