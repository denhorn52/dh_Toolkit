-- NoIndex: true

--dh_Toolkit_GUI Builder.lua 
-- version 1.0 
-- Author: Dennis R. Horn
-- Enhanced GUI Builder for Lokasenna_GUI v2.9
-- Modified by Dennis R. Horn 20260330

--[[
    2025-04-09. 
      Added ability to save and recall window position and prefs from reaper ext state.
      Added save and load projects.
      Added json.lua to accomplish above.
      Added extra font sizes.
    2025-09-20 Add dh_Toolkit import.
    2025-10-11 Added GB_frm_ws (workspace background panel)
               to accommodate when project size is less than min workspace size.
               Added WORKSPACE_MIN_W and WORKSPACE_MIN_H.
    2026-04-21 Added z_sets editor.
]]--

--====================================
--        TO DO:
--====================================
-- Delete old DH_GUI_Builder ext state

--!!! Disable for deployment.
--reaper.ClearConsole()
--====================================
--  Lokasenna's GUI requirements
--====================================

local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
if not lib_path or lib_path == "" then
    reaper.MB("Couldn't load the Lokasenna_GUI library. Please install 'Lokasenna's GUI library v2 for Lua', available on ReaPack, then run the 'Set Lokasenna_GUI v2 library path.lua' script in your Action List.", "Whoops!", 0)
    return
end
loadfile(lib_path .. "Core.lua")()

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
GUI.req("Classes/Class - Window.lua")()

--======================================
--    GUI Globals 
--======================================

-- Name displayed in Title bar.
GUI.name = "GUI Builder"

-- Override shadow distance here.
GUI.shadow_dist = 2
 
-- Add additional grid colors to GUI.
GUI.colors["dark_gray"] = {64, 64, 64, 255}
GUI.colors["light_gray"] = {192, 192, 192, 255}

--======================================
--  dh_Toolkit requirements 
--======================================
-- Adds current directory to path.

local dhtk_path = reaper.GetExtState("dh_Toolkit", "lib_path_v1")
if not dhtk_path or dhtk_path == "" then
    reaper.MB("Couldn't load dh_Toolkit. Please install 'dh_Toolkit v1 for Lua', available on ReaPack, then run the 'Set dh_Toolkit v1 library path.lua' script in your Action List.", "Whoops!", 0)
    return
end

--loadfile(dhtk_path .. "common/dh_Toolkit_core_gb.lua")()
package.path = package.path .. ";" .. dhtk_path .. "?.lua"

-- !!! Load GUI.overrides.
require "common/GUI_overrides"

------------------------------------------
DHTK = require "common/dh_Toolkit_core"
------------------------------------------
-- Set to true if script uses dh_Toolkit Prefs window.
-- Set to false if script handles Prefs in its own way (as with GUI Builder).)
DHTK.USE_DHTK_PREFS = false

DHTK.EXT_STATE_NAME = "dh_GUI_builder"
     
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
require "classes/dh_Slider_V"
require "classes/dh_Tabs"
require "classes/dh_Textbox"
require "classes/dh_TextEditor"
require "classes/dh_Window"
--------------------------------------
--!!! This needs to be after load modules.
--!!! Necessary. Must be after req dh_Classes as some
--     classes are required by DHTK.init_DHTK()

DHTK.init_DHTK()
--------------------------------------
--GUI.Msg("dhtk_path : " .. dhtk_path)  -- E:\Reaper6\Scripts\dh_Toolkit\library\
-- Make local copies if needed.
local dhth = require "common/dh_Toolkit_themes"
local json = require "common/json"

-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end

--======================================
--     GB Modules 
--======================================
-- Must be after DHTK classes as some of these may use them.
package.path = package.path .. ";" .. GUI.script_path .. "modules/?.lua"

Element     = GUI.req(GUI.script_path .. "modules/func_Elements.lua")()
Export      = GUI.req(GUI.script_path .. "modules/func_Export.lua")()
Properties  = GUI.req(GUI.script_path .. "modules/tab_Properties.lua")()
Project     = GUI.req(GUI.script_path .. "modules/wnd_Project.lua")()
Prefs       = GUI.req(GUI.script_path .. "modules/wnd_Prefs.lua")()
Menu        = GUI.req(GUI.script_path .. "modules/func_Menu.lua")()
Dialog      = GUI.req(GUI.script_path .. "modules/wnd_Dialog.lua")()
-- These have to be after WIDTH and HEIGHT.
--Editor      = GUI.req(GUI.script_path .. "modules/func_Editor.lua")()
--Help        = GUI.req(GUI.script_path .. "modules/wnd_Help.lua")()

--======================================
--     Project Settings
--======================================
--zzz
-- Get project settings.
--!!! Make provision to load current project!

if reaper.HasExtState("dh_GUI_builder", "gb_settings") then
    local json_string = reaper.GetExtState("dh_GUI_builder", "gb_settings")
    local settings = json.decode(json_string)
    -- Prefs needs to be before Project.
    if settings.prefs then
        --Prefs.populate_settings(settings.prefs)
        Prefs.load_settings(settings.prefs)        
    end    
    if settings.proj then
        --Project.populate_settings(settings.proj)
        Project.load_settings(settings.proj)
    end

end

--!!! This should have been done during load_settings.
Project.proj_settings.w = tonumber(Project.proj_settings.w)
Project.proj_settings.h = tonumber(Project.proj_settings.h)

-- Design sizes at 1.00x scale.
--!!! These should never be scaled directly.
--!!! Must be before any element creation.

WORKSPACE_MIN_W = 480
WORKSPACE_MIN_H = 480
WORKSPACE_WIDTH = math.max(Project.proj_settings.w, WORKSPACE_MIN_W)
WORKSPACE_HEIGHT = math.max(Project.proj_settings.h, WORKSPACE_MIN_H)

SIDEBAR_WIDTH = 320
-- Use this until rename. Renamed everywhere but wnd_Sidebar.
Sidebar_w = SIDEBAR_WIDTH 
SIDEBAR_BORDER_WIDTH = 8

-- Replaces Menu.h
MENUBAR_HEIGHT = 28

-- Should I just use WORKSPACE_WIDTH
function Sidebar_ref_x() return (GUI.cur_w or GUI.w or gfx.w) - Sidebar_w end

DHTK.APP_WIDTH = WORKSPACE_WIDTH + SIDEBAR_WIDTH
DHTK.APP_HEIGHT = WORKSPACE_HEIGHT + MENUBAR_HEIGHT 

--Help        = GUI.req(GUI.script_path .. "modules/wnd_Help.lua")()
--[=[
GUI.elms.GB_wnd_help.x = 16
GUI.elms.GB_wnd_help.y = 16
GUI.elms.GB_wnd_help.w = DHTK.APP_WIDTH - 32
GUI.elms.GB_wnd_help.h = WORKSPACE_MIN_H
GUI.elms.GB_wnd_help_lbx.x = 16
GUI.elms.GB_wnd_help_lbx.y = 16
GUI.elms.GB_wnd_help_lbx.w = DHTK.APP_WIDTH - 64
GUI.elms.GB_wnd_help_lbx.h = WORKSPACE_MIN_H - 64
--]=]

--======================================
--    GUI ELEMENTS 
--======================================
--zzelem
--GUI.Msg("SCRIPT ready to load elements")

--[=[   Z LAYERS  
GB_wnd_proj             499
GB_wnd_proj_name        498
GB_wnd_proj_x           498
GB_wnd_proj_y           498
GB_wnd_proj_w           498
GB_wnd_proj_h           498
GB_wnd_proj_anchor      498
GB_wnd_proj_corner      498
GB_wnd_proj_scripts_dir 498
GB_wnd_proj_OK          498

GB_wnd_prefs            497
GB_wnd_prefs_grid_snap  496
GB_wnd_prefs_grid_show  496
GB_wnd_prefs_grid_size  496
GB_wnd_prefs_grid_color 496
GB_wnd_prefs_grid_font  496
GB_wnd_prefs_grid_font_scale  496
GB_wnd_prefs_OK         496

GB_editor_pnl           495
GB_editor_sidebar_pnl   495
GB_editor_type_lbl      494
GB_editor_info_lbl      494
GB_editor_close_btn     494

GB_wnd_help             493
GB_wnd_help_lbx         492

GB_frm_ws               491
GB_frm_bg               490
GB_side_bg                9
GB_side_elm_type          5
GB_mnu_bar                2

-- exists only when called --
GB_dlg_ws_overlay         2
GB_dlg_panel_form         2
GB_dlg_panel_title        1
GB_dlg_panel_message      1
GB_dlg_panel_input1       1
GB_dlg_panel_confirm      1
GB_dlg_panel_cancel       1

--]=]

-- Initial metrics at 1.00x scale. Will scale at DHTK.setup_window().

GUI.New("GB_mnu_bar", "dh_Menubar", {
    z = 2,  -- was 1
    x = 0, 
    y = 0, 
    w = DHTK.APP_WIDTH, 
    h = MENUBAR_HEIGHT,
    fullwidth = true,
    shadow = true,
    menus = Menu.menu,

})

--GUI.Msg("**** create workspace ****" )
--GUI.Msg("load WORKSPACE_WIDTH : " .. tostring(WORKSPACE_WIDTH))
--GUI.Msg("load WORKSPACE_HEIGHT : " .. tostring(WORKSPACE_HEIGHT))

-- This is workspace background with checkerboard grid
-- for when project is less than min size.
GUI.New("GB_frm_ws", "dh_Panel", {
    z = 491, --493, --494,  -- 495 causes wrong drawing?,
    x = 0,
    y = MENUBAR_HEIGHT,
    w = WORKSPACE_WIDTH, 
    h = WORKSPACE_HEIGHT, 
    border_width = 0, 
    radius = 0, 
    col_bg = "gray",
})

-- This is project background with lines grid.
--!!! Would like to rename this GB_frm_proj.
GUI.New("GB_frm_bg", "dh_Panel", {
    z = 490, --492,  --493,
    x = 0,
    y = MENUBAR_HEIGHT,
    w = Project.proj_settings.w, 
    h = Project.proj_settings.h, 
    border_width = 0, 
    radius = 0, 
    col_border = "panel_border",  	
    col_bg = "wnd_bg",  
})

-- For highlighting the current element
GUI.New("GB_frm_sel_elm", "Frame", 1, 1, 1, 1, 1)

---- Sidebar elements ----

-- Sidebar background
GUI.New("GB_side_bg", "dh_Panel", {
    z = 9,
    x = WORKSPACE_WIDTH,   -- 640
    y = MENUBAR_HEIGHT,    --  28
    w = SIDEBAR_WIDTH,     -- 280 
    h = WORKSPACE_HEIGHT,  -- 480 
    border_width = SIDEBAR_BORDER_WIDTH, 
    radius = 0, 
    col_border = "panel_border",  	
    col_bg = "panel_bg",   
})

-- Elm type is displayed top left of sidebar.
GUI.New("GB_side_elm_type", "dh_Label", {
    z = 5,
    x = WORKSPACE_WIDTH + 12, 
    y = MENUBAR_HEIGHT + 8, 
    text = "No element selected",
    col_bg = "panel_bg",      
    col_text = "panel_txt",      
    font = "sans24",        
})

-- Need to declare these here because it uses earlier parameters.

Editor = GUI.req(GUI.script_path .. "modules/func_Editor.lua")()
Editor.load_editor_elms()
Help = GUI.req(GUI.script_path .. "modules/wnd_Help.lua")()

--======================================
--    Workspace element overrides
--======================================
-- Override init to draw grids.
function GUI.elms.GB_frm_ws:init()

    self.buff = GUI.GetBuffer()

    --GUI.Msg("init WORKSPACE_WIDTH : " .. tostring(WORKSPACE_WIDTH))
    --GUI.Msg("init WORKSPACE_HEIGHT : " .. tostring(WORKSPACE_HEIGHT))
    
    self.w = WORKSPACE_WIDTH * DHTK.APP_SCALE
    self.h = WORKSPACE_HEIGHT * DHTK.APP_SCALE
    
    local w, h = self.w, self.h

    gfx.dest = self.buff
    gfx.setimgdim(self.buff, -1, -1)
    gfx.setimgdim(self.buff, w, h)

    Project.draw_ws_grid(self)

end

-- Override init to draw grids.
function GUI.elms.GB_frm_bg:init()

    --GUI.Msg("\n>>>>  GUI.elms.GB_frm_bg:init  <<<<")

    self.buff = GUI.GetBuffer()

    self.w = Project.proj_settings.w * DHTK.APP_SCALE
    self.h = Project.proj_settings.h * DHTK.APP_SCALE
    
    local w, h = self.w, self.h
    local mh = MENUBAR_HEIGHT * DHTK.APP_SCALE
    
    gfx.dest = self.buff
    gfx.setimgdim(self.buff, -1, -1)
    gfx.setimgdim(self.buff, w, h)
    
    GUI.color("wnd_bg")
    
    --!!! Should have scaled workspace size.
    gfx.rect(0, 0, self.w, self.h, true)
    
    if Prefs.preferences.grid_show then    
        Prefs.draw_grid(self)
    end
    
end

-- Doesn't need to be visible.
function GUI.elms.GB_frm_bg:draw()

    --GUI.Msg("\n>>>>  GUI.elms.GB_frm_bg:draw  <<<<")
    
    local mh = MENUBAR_HEIGHT * DHTK.APP_SCALE
      
    gfx.blit(self.buff, 1, 0, 0, 0, self.w, self.h, 0, mh) 
           
    GUI.color("elm_bg")

    gfx.rect(   -1,
                0,
                (Project.proj_settings.w + 2) * DHTK.APP_SCALE,
                (Project.proj_settings.h + 1) * DHTK.APP_SCALE + mh,
                false)
    
end

function GUI.elms.GB_frm_bg:onmouseup()
    if GUI.mouse.cap & 8 == 8 then
        Element.deselect_elm()
    end
end

function GUI.elms.GB_frm_bg:onmouser_up()
    Element.new_elm_menu()
end

GUI.elms.GB_frm_sel_elm.bg = nil

-- We don't want the frame to pick up any user input
function GUI.elms.GB_frm_sel_elm:onupdate()
    return true
end

--!!! Maybe add pref to choose color.
function GUI.elms.GB_frm_sel_elm:draw()

    GUI.color("magenta")

    if self.elm then
        gfx.rect(   GUI.elms[self.elm].x - 4,
                    GUI.elms[self.elm].y - 4,
                    GUI.elms[self.elm].w + 8,
                    GUI.elms[self.elm].h + 8,
                    false)
    end

end

function GUI.elms.GB_side_elm_type:onmouseup()
    Element.deselect_elm()
end

--====================================
--         EXIT     
--====================================
--zzz
local function Exit()

    DHTK.saveWindowSettings()

    -- Save Project settings.
    local settings = {}
    settings.proj = Project.proj_settings
    settings.prefs = Prefs.preferences
    
    local export_str = json.encode(settings)
    
    reaper.SetExtState("dh_GUI_builder", 'gb_settings', export_str, true)
    
end --<EXIT>

-- Calls Exit function when script is ending.
reaper.atexit(Exit)

--====================================
--      INITIALIZE     
--====================================
--zzinit
--GUI.Msg("ready to initialize")

-- Scale window. 
GUI.w = DHTK.APP_WIDTH * DHTK.APP_SCALE
GUI.h = DHTK.APP_HEIGHT * DHTK.APP_SCALE
GUI.anchor, GUI.corner = "screen", "TL"


-- This will scale all GUI elms and fonts.
-- When auto-loading last project will scale them too. 
DHTK.init_scale_elms()

-- Open the script window and initialize a few things.
GUI.Init()

--======================================
-------- Things we can't do --------
-------- until Init has run --------
--======================================

-- Resizing now done in func_Project Project.update_wnd_size().

Project.add_method_overrides( GUI.elms.GB_wnd_proj:getchildelms() )
Prefs.add_method_overrides( GUI.elms.GB_wnd_prefs:getchildelms() )

--======================================
--      MAIN LOOP <dhMain>   
--======================================    
--zzmain 
local function dhMain()

	if GUI.resized then
	    --[[
	    GUI.Msg("**** dhMain : if GUI.resized ****")
	    GUI.Msg("  gfx.quit, gfx.init, GUI.redraw")
	    GUI.Msg("Project height   : " .. tostring(Project.proj_settings.h))
	    GUI.Msg("WORKSPACE_HEIGHT : " .. tostring(WORKSPACE_HEIGHT))
	    GUI.Msg("DHTK.APP_HEIGHT  : " .. tostring(DHTK.APP_HEIGHT))
	    GUI.Msg("GUI.h            : " .. tostring(GUI.h))
	    --]]
        -- If the window's size has been changed, reopen it
        -- at the current position with the size we specified.	
		local __,x,y,w,h = gfx.dock(-1,0,0,0,0)
		gfx.quit()
		-- GUI.w and GUI.h were set in DHTK.scaleApp()
		--!!! Could use DHTK.APP_WIDTH DHTK.APP_HEIGHT.
		gfx.init(GUI.name, GUI.w, GUI.h, 0, x, y)
		GUI.redraw_z[0] = true
	end
	
end  --<dhMain>


-- Tell the GUI library to run dhMain on each update loop.
-- Individual elements are updated first, then GUI.func is run, then the GUI is redrawn.
GUI.func = dhMain

-- How often (in seconds) to run GUI.func. 0 = every loop.
GUI.freq = 0

-- Start the main loop

GUI.Main()