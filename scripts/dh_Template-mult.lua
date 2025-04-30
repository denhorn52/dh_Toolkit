--dh_Template-mult.lua 
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
-- Used in conjunction with Lokasenna GUI v2.

-- Template providing basic framework to use dh_Toolkit theming and scaling.
-- dh_Toolkit provides the theming and scaling capabilities.
-- dh_Toolkit provides a "Preferences" window to select scale and theme options,
--   and an optional Checklist which can be used for project specific options.
-- The "Preferences" window is designed at 600 x 400 using z-layers 9-20.
-- This template provides for three window heights'
-- The dh_Toolkit directory contains the scripts that can be used
--   within Reaper. It is to be placed in your Reaper "scripts" directory.
-- dh_Toolkit subdirectory "common" contains the files:
--   "dh_Toolkit_core.lua" which contains the core functionality of dh_Toolkit.
--   "dh_Toolkit_shared.lua" which defines common functions.
--   "dhToolkit_themes.lua" which defines dh_Toolkit themes and font scaling code.
-- dh_Toolkit subdirectory "classes" contains a few modified or custom Lokasenna classes.

-- Script scale, theme, and metrics are stored in reaper ext state.
-- It provides a basic framework for saving and fetching
--   project specific data on script start, exit, and when changing project tabs.
     
-- This script is heavily commented and contains some API references.
-- The template is organized into sections.
-- The order of some sections are significant for
--   proper execution of script.

---------------------------------------------
-- CONVENTIONS USED:

-- This template uses comments containing implementation instructions.
-- They will be specified by --[[ DEV NOTE: ]]
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
--[==[
  During development I have had times when a script would crash Reaper.
  I believe the crashes were related to one of the following:
  
  json.encode using json.lua
  Trying to encode values which are unrepresentable in JSON will never result in type conversion or other magic: 
  sparse arrays, tables with mixed key types or invalid numbers (NaN, -inf, inf) will raise an error.

  Lokasenna elements use reaper's graphics engine gfx.
  gfx.showmenu will crash Reaper if string parameter is nil or empty. 
    Need at least " ".
  gfx.drawstring may do the same. (I think it needs at least an empty string.)  
  Be sure to provide proper string to elements requiring them.
--]==]

---------------------------------------
-- dh_log (used during development)
---------------------------------------
-- Disable all console messages using dh_log() by setting this to false. 

local dh_log_active = false

function dh_log(msg)
	if dh_log_active then
		reaper.ShowConsoleMsg(msg .. "\n")
	end
end

--======================================
-- Lokasenna's GUI requirements.
--======================================
local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
if not lib_path or lib_path == "" then
    reaper.MB("Couldn't load the Lokasenna_GUI library. Please install 'Lokasenna's GUI library v2 for Lua', available on ReaPack, then run the 'Set Lokasenna_GUI v2 library path.lua' script in your Action List.", "Whoops!", 0)
    return
end
loadfile(lib_path .. "Core.lua")()

--[[ DEV NOTE: Comment out classes not being used. ]]

GUI.req("Classes/Class - Button.lua")()
GUI.req("Classes/Class - Frame.lua")()
--GUI.req("Classes/Class - Knob.lua")()
GUI.req("Classes/Class - Label.lua")()
--GUI.req("Classes/Class - Listbox.lua")()
--GUI.req("Classes/Class - Menubar.lua")()
--GUI.req("Classes/Class - Menubox.lua")()
GUI.req("Classes/Class - Options.lua")() 
--GUI.req("Classes/Class - Slider.lua")()
--GUI.req("Classes/Class - Tabs.lua")()
--GUI.req("Classes/Class - Textbox.lua")()
--GUI.req("Classes/Class - Textedit.lua")()
--GUI.req("Classes/Class - Window.lua")()

-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end

--[[ DEV NOTE: Insert your script name ]]--
GUI.name = "dh_Template-mult v1.0"

--Hide the version number since I'm using a small window.
GUI.Draw_Version = function () end

-- Lighten up shadow color.
-- !!! Would like to make this part of theming.
GUI.colors["shadow"] = {0,0,0,32}

--======================================
-- dh_Toolkit requirements 
--======================================
-- Adds current directory to path.

local dhtk_path = reaper.GetExtState("dh_Toolkit", "lib_path_v1")
if not dhtk_path or dhtk_path == "" then
    reaper.MB("Couldn't load dh_Toolkit. Please install 'dh_Toolkit v1 for Lua', available on ReaPack, then run the 'Set dh_Toolkit v1 library path.lua' script in your Action List.", "Whoops!", 0)
    return
end

--loadfile(dhtk_path .. "common/dh_Toolkit_core.lua")()
package.path = package.path .. ";" .. dhtk_path .. "?.lua"

----------------------------------------
DHTK = require "common/dh_Toolkit_core"
----------------------------------------

--[[ DEV NOTE: Replace with a name you choose. ]]--
-- This is the name to be used as the section name when 
-- saving settings to reaper ext state (usually the name of the script).
DHTK.EXT_STATE_NAME = "dh_Template-mult"

--[[ DEV NOTE: Must be true when using multiple window heights. ]]--
DHTK.MULTIPLE_HEIGHTS = true

-- Script window dimensions at 1.00x scale.
-- 600 x 340 is minimum size for "Preferences" window.
DHTK.APP_WIDTH = 600

-- Heights of the window states.
DHTK.APP_MIN_HEIGHT = 48
DHTK.APP_EXP_HEIGHT = 88
-- Preferences display needs 300 min. height.
DHTK.PREFS_HEIGHT = 400

-- These are used for resizing the windows.
DHTK.s_APP_MIN_HEIGHT = DHTK.APP_MIN_HEIGHT
DHTK.s_APP_EXP_HEIGHT = DHTK.APP_EXP_HEIGHT
DHTK.s_PREFS_HEIGHT = DHTK.PREFS_HEIGHT

----------------------------------------
--[[ DEV NOTE: Custom or modified Lokasenna classes.
     Comment out classes not used. 
     dh_Menubox and dh_Options are needed for "Preferences" window.]]--

-- Custom Lokasenna's class to use as bordered Frame.
--local dh_frame = require "classes/dh_Frame"

-- Revised Lokasenna's Menubox class for GUI.Val to return selected item number AND name.
local dh_mbx = require "classes/dh_Menubox"

-- Revised Lokasenna's Options class to use my color theming.
local dh_opt = require "classes/dh_Options"

-- I revised Lokasenna's Slider class to allow changing track thickness and handle size.
--local dh_opt = require "classes/dh_Slider"

-- Revised Lokasenna's Window class to use my color theming.
--local dh_wnd = require "classes/dh_Window"

----------------------------------------
-- !!! Necessary. Must be after req dh_Options
DHTK.init_DHTK()
-----------------------------------------

-- May be used to access some toolkit functions.
-- Or may use DHTK.shared
local dhtks = require "common/dh_Toolkit_shared"

-- May be used for saving and loading ext states.
local json = require "common/json"

--======================================
  --------      My Data      --------
--======================================
--zzdata   
-- Declare variables here so every function has access to it.


----------------------------------------
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- template_options provided as an example.
-- It may be used to provide a checklist of script specific options
-- that will be displayed in the Preferences window.
-- dh_ArrangeViews.lua uses view_options.
-- dh_Snapshots.lua uses snapshot_options.
-- If renaming be sure to rename in "Script Init" section also.
-- May safely remove if not using.

local template_options = {
  option1 = true,
  option2 = true,
  option3 = true,
  option4 = false
}

-- Ordered list for options checklist display.
local template_options_names = {
  "option1",
  "option2",
  "option3",
  "option4"
}

-- Default selected values
local template_options_selected = {} 

for _, opt in ipairs(template_options_names) do
    table.insert(template_options_selected, template_options[opt])
end
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

--======================================
  --------   My Functions  --------
--======================================
--zzfunc
--[==[ Reference:
-- Functions can be declared 'local' if they are called by Lokasenna GUI, i.e., clicking a button.
-- If called from within another function they must be global (no 'local') or it crashes script.

-- Example function. Called from GUI element function. 
local function call_from_gui_function()
	my_function()
end

-- If this is declared as local it crashes script.
function my_function()
	-- do stuff --
end

--??? Seems okay if my_function is declared before call_from_gui_function call.
--]==]
-----------------------------------------------------        
--[[ DEV NOTE: Insert your functions here.
     These can be called direct from GUI element func,
     or from your own code. ]]--

--======================================
  ------   Element Functions   ------
--======================================
--zzelemfunc  

--[[ DEV NOTE: This section provided for organization.
     These can just as well be in My Functions section,
     but I found it convenient to have a separate section.
     Example: GUI element func = btnScaleAppClick 
     Functions called by, say, clicking a button must be 
       before element creation.
     Functions called from within those functions must be
       before said function.
--]]

-- Put your element functions here --


-- Toggles Main window expanded or not.

local function btn_MinMaxClick()
	if DHTK.window_settings.is_window_expanded then
		-- unexpand --
		GUI.elms.btn_MinMax.caption = "+"
		DHTK.window_settings.is_window_expanded = false
		GUI.h = DHTK.s_APP_MIN_HEIGHT
	else
		-- expand --
		GUI.elms.btn_MinMax.caption = "-"
		DHTK.window_settings.is_window_expanded = true
		GUI.h = DHTK.s_APP_EXP_HEIGHT	
	end
	GUI.resized = true

end

-- Opens Preferences window.
local function btn_MinMaxRightClick()
	GUI.h = DHTK.s_PREFS_HEIGHT
	GUI.resized = true
	DHTK.showPrefsWindow()
end

local function btn_ShowPrefsWindow()
	GUI.h = DHTK.s_PREFS_HEIGHT
	GUI.resized = true
	DHTK.showPrefsWindow()
end

--======================================
  --------      ELEMENTS      --------
--======================================
--zzelements 

--[[ DEV NOTE: Add your elements here. ]]--

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- This frame is optional. It is provided as possible starting point.
GUI.New("frm_Main", "Frame", {
    z = 100,
    x = 0,
    y = 0,
    w = DHTK.APP_WIDTH, 
    h = DHTK.APP_MIN_HEIGHT, 
    shadow = false,
    fill = false,
    color = "wnd_bg",
    bg = "wnd_bg",
    round = 0,
    text = "",
    txt_indent = 0,
    txt_pad = 0,
    pad = 8, 
    font = "sans16",
    col_txt = "txt"
})
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--[[ DEV NOTE: 
     Need a way to open Preferences Window.
     Using a button on z-layer 99.
     Feel free to move to another layer,
       or have other mechanism to open and close "Preferences" window. 
--]]
GUI.New("btn_Prefs", "Button", {
    z = 99,
    x = 456, 
    y = 8, 
    w = 80, 
    h = 28, 
    caption = "Prefs",
    font = "sans24",
    col_txt = "txt",
    col_fill = "btn_face",	
	func = btn_ShowPrefsWindow
})
--zz0406
GUI.New("btn_MinMax", "Button", {
    z = 35,
    x = 552, 
    y = 8, 
    w = 32, 
    h = 32, 
    caption = "+",
    font = "sans32",
    col_txt = "txt",
    col_fill = "btn_face",	
    func = btn_MinMaxClick,
    r_func = btn_MinMaxRightClick,
    r_params = {} -- Must include if using r_func or script crashes.
})

------------------------------------
------   Options Section   ------ 
------------------------------------
--zzoptions
--[[ DEV NOTE: 
     !!! Define optional section in MainScript.
     Can use this as a template. 
--]]

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

----------------------------------------
------      Tips Display      ------
----------------------------------------
--zztips
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--[[ DEV NOTE:
     There is some extra room at bottom of "Preferences" window. 
     I used it to include some useful tips.
     You may use, alter, or discard. ]]--
--GUI.New("lbl_tip_01", "Label", 19, 18, 332, "Go button Click - go to view indicated by menubox.", false, "sans20", "txt", "elm_fill" )
--GUI.New("lbl_tip_02", "Label", 19, 18, 352, "Go button Shift + Click - update view indicated by menubox.", false, "sans20", "txt", "elm_fill" )
--GUI.New("lbl_tip_03", "Label", 19, 18, 372, "Go button Alt + Click - rename view with text in textbox.", false, "sans20", "txt", "elm_fill" )
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

--======================================
  ------   Method Overrides  ------
--======================================
--zzoverrides 
--[[ DEV NOTE:
     Place to add additional functionality to GUI events.
     These need to be after element creation ("My Elements" section). 
--]]

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--[[ DEV NOTE: This is optional.
     I used it for selecting script specific options 
       that I displayed in "Preferences" window. 
     Remove if removing chkl_Options element. 
--]]
     
function GUI.elms.chkl_Options:onmouseup()
	-- Run the element's normal method --
	GUI.Checklist.onmouseup(self)
		
	-- Add our code --
    	
end
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

--======================================
  ------      SCRIPT FLOW      ------
--======================================
--zzflow
--[[ DEV NOTE: 
     I used this section to summarize the flow of the script.
     I found it useful while developing.
     This section can be placed anywhere it is convenient.
--]]

--======================================
  ------   GET PROJECT DATA   ------    
--======================================
--zzpopulate
--[[ DEV NOTE: 
     This section is a place to load data from reaper ext state,
       or reaper project ext state.
       
     This is how I did it in dh_Toolkit scripts.
     Updates options list on init and when changing tabs.
     Get data from current project ext state.
--]]

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--[[ DEV NOTE: Use for loading data from project ext state. 
     This illustrates loading template_options. ]]--
     
local function populateLists(proj)

    -- Get saved options --	
	
    local retval, json_string = reaper.GetProjExtState(proj, DHTK.EXT_STATE_NAME, "template_options")

    if (retval == 1) then
        local opts = json.decode(json_string) -- should return Lua table
            
        if type(opts) == "table" and dhtks.keyed_table_length(opts) > 0 then
            template_options = opts
          
            -- Update checklist --
            local bool_table = {}
            for _, opt in ipairs(template_options_names) do
                table.insert(bool_table, template_options[opt])
            end
            GUI.Val('chkl_Options', bool_table)
        end
    end

    --!!! Can get rid of json string when done loading?
    json_string = nil

end  --<populateLists>
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

--======================================
  ------  SAVE PROJ EXT STATE  ------    
--======================================
--zzsave
--[[ DEV NOTE: 
     This is a place to put anything you want to save persistantly.
     Saves to project ext state on script exit and/or on project tab change.
--]]

--[==[
  reaper.SetProjectExtState requires a string value.
  If data is a table it can be compiled into string using json_encode.
  IMPORTANT: Table must be an indexed table or keyed table.
    Mixed tables will crash script and may crash reaper.
  Although I use json.lua, any stringify method should work.
  
  Trying to encode values which are unrepresentable in JSON will never result in type conversion or other magic: 
  sparse arrays, tables with mixed key types or invalid numbers (NaN, -inf, inf) will raise an error.

  Important to know when manipulating data:
    Reaper gfx.showmenu crash Reaper if string parameter 
      is nil or empty. Need at least " ".
    Reaper gfx.drawstring will crash script and may crash Reaper 
      if string parameter is nil.
--]==]

--[==[ SetProjExtState() 
	integer reaper.SetProjExtState(ReaProject proj, string extname, string key, string value)
	Save a key/value pair for a specific extension, to be restored the next time this specific project is loaded.
	Params:
		ReaProject proj: 	The project-number. 0 for the current project.
		string extname:   The section, in which the key/value is stored. Use name of script.
		string key:  			The key, that stores the value.
		string value:			The value, that's stored in the key.		
	If key is NULL or "", all extended data for that extname will be deleted. 
	If val is NULL or "", the data previously associated with that key will be deleted. 
	Returns the size of the state for this extname.
	If val is "" it returns size = 2.
--]==]

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--[[ DEV NOTE: Use for saving data to project ext state. 
     This illustrates saving template_options. ]]--
     
local function saveProjExtState(proj)
    
    --<<< testing
    local projname = reaper.GetProjectName(projname)
    dh_log("> saveProjExtState projname: " .. projname)
    -->>>
       
    ----  If data is a table compile it to a string ----
    local json_string = json.encode(template_options)
    
    if json_string == nil then json_string = "" end

    ----  Save it  ----
    reaper.SetProjExtState(proj, DHTK.EXT_STATE_NAME, "template_options", json_string)

    -- No longer need json_string    
    json_string = nil
    
end  --<saveProjExtState>
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

--======================================
  --------      EXIT      --------
--======================================
--zzexit
-- Code to execute before window closes, such as saving project states.
-- projExtState is saved to section name DHTK.EXT_STATE_NAME.

local function Exit()
    --[[ DEV NOTE: Necessary!!! ]]--
    DHTK.saveWindowSettings()
    
    --<<<<<<<<<<<<<<<<<<<<<<<<<<<
    -- Save current project ext state.
    --xxx
    saveProjExtState(0)
    -->>>>>>>>>>>>>>>>>>>>>>>>>>>
    
end --<EXIT>

-- Calls Exit function when script is ending.
reaper.atexit(Exit)

--======================================
  ------  Script Initialize  ------
--======================================
--zzinit  

----------------------------------------
--  GUI Elements Initialization
--  Done here - after element creation
----------------------------------------

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- Set checklist options default values
GUI.elms.chkl_Options.optarray = template_options_names
GUI.Val("chkl_Options", template_options_selected)
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

--[[ DEV NOTE: Necessary!!! ]]--
DHTK.init_scale_elms()

if DHTK.window_settings.is_window_expanded == false then
    GUI.elms.btn_MinMax.caption = "+"
else
    GUI.elms.btn_MinMax.caption = "-"
end 

----------------------------------------
--   Non GUI Initialization
----------------------------------------
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- Will need to access these in main loop (to check if tab was changed).
local proj_before_change, proj_name_before_change = reaper.EnumProjects(-1)

--[[ DEV NOTE: This needs to be after proj_before_change definition,
     and after populateLists definition. 
     Will load data saved in project ext state. ]]--
--xxx
populateLists(proj_before_change)
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

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

    -------------------------------------------
    -- Check if project tab was changed.
    -------------------------------------------
    -- If so, save previous project state then repopulate with current.
    -- Save only if list has data.
  
    local curr_proj, curr_proj_name = reaper.EnumProjects(-1)

    if curr_proj_name ~= proj_name_before_change then
        --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        proj_name_before_change = curr_proj_name
        saveProjExtState(proj_before_change)

        proj_before_change = curr_proj
        populateLists(curr_proj)
        -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    end
    
end

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