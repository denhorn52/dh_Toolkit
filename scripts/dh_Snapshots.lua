--dh_Snapshots.lua 
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
-- Save and restore Mixer Control Panel configurations.
-- See accompanying doc files for usage and features.

---------------------------------------------
-- CONVENTIONS USED:

--   camelCase used for var and function names pertaining to GUI.
--   snake_case used for other var and function names.
--   Comments starting with --zz are bookmarks.
--   Comments starting with --<<< denotes code used for testing.
--   Comments ending with -->>> denotes end of block used for testing.
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
--[==[

> reaper.BR_GetMediaTrackByGUID(ReaProject proj, string guidStringIn)

> When scaling window draws functions are called twice.
  Not a huge deal, but I'd like to fix if possible.
  Something to do with resize in dh_Main?
  Every attempt messes thing up!
  Better left alone?

> Maybe add rename by right-clicking on listbox item.

> Save snapshot before applying another, or warn.
  Now leaving it to user to be careful.
  May need to save start state in projExtState.
  What to call it? 
  
> **** Options to save fx and params. ****
  This can yield large file sizes, and is probably overkill.
  One way is to have checklist of what to save. This can be enormous
    as some fx have huge number of params.
    Probably best to save fx chunk.
  Another way is to save only enabled fx.
    or Some combination of above.
  
> ??? Popup window to select fx/params to save?
  Would probably require checkboxes with sub-checkboxes.
  Ignoring fx individual parameters for now,
  can list tracks in checkbox or maybe custom scrollable menubar.
  Tracks:
  FX:

> ??? Add popup window with checklist for save/ restore options?
Options:
  use_volume
  use_pan
  use_solo
  use_mute
  selected
  show in mcp
  fx_enabled
  -- Works, but slow
  fx params: {param1, param2, ...}
  -- Not implemented
  sends : this can get involved.
  phase
  pan laws

--]==]

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
-- Disable all console messages by setting this to false. 
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

GUI.req("Classes/Class - Button.lua")()
GUI.req("Classes/Class - Frame.lua")()
--GUI.req("Classes/Class - Knob.lua")()
GUI.req("Classes/Class - Label.lua")()
GUI.req("Classes/Class - Listbox.lua")()
--GUI.req("Classes/Class - Menubar.lua")()
--GUI.req("Classes/Class - Menubox.lua")()
--GUI.req("Classes/Class - Options.lua")() 
--GUI.req("Classes/Class - Slider.lua")()
--GUI.req("Classes/Class - Tabs.lua")()
GUI.req("Classes/Class - Textbox.lua")()
--GUI.req("Classes/Class - Textedit.lua")()
--GUI.req("Classes/Class - Window.lua")()

-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end

GUI.name = "dh_Snapshots v1.0"

--Hide the version number since I'm using a small window.
--GUI.Draw_Version = function () end

-- Lighten up shadow color.
-- !!! Would like to make this part of theming.
GUI.colors["shadow"] = {0,0,0,32}

--======================================
-- dh_Toolkit requirements 
--======================================
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

----------------------------------------
DHTK = require "common/dh_Toolkit_core"
----------------------------------------

DHTK.EXT_STATE_NAME = "dh_Snapshots"

-- Script window dimensions at 1.00x scale.
DHTK.APP_WIDTH = 640
DHTK.APP_HEIGHT = 400

--------------------------------

-- Custom Lokasenna's class to use as bordered Frame.
local dh_frame = require "classes/dh_Frame"

-- Revised Lokasenna's Menubox class for GUI.Val to return selected item number AND name.
local dh_mbx = require "classes/dh_Menubox"

-- I revised Lokasenna's Options class to use my color theming.
local dh_opt = require "classes/dh_Options"

-- I revised Lokasenna's Slider class to allow changing track thickness and handle size.
--local dh_opt = require "classes/dh_Slider"

-- I revised Lokasenna's Window class to use my color theming.
--local dh_wnd = require "classes/dh_Window"

--------------------------------
-- !!! Necessary. Must be after req dh_Options
DHTK.init_DHTK()
--------------------------------

local dhtks = require "common/dh_Toolkit_shared"
local json = require "common/json"

--======================================
  --------      My Data      --------
--======================================
--zzdata
-- Pre-declare variables here so every function has access to it.

-- Dimensions at 1.00x scale.
-- These need to be declared before function definitions.
local POPUP_WIDTH = 480
local POPUP_HEIGHT = 256
local POPUP_LEFT = 60
local POPUP_TOP = 56

--------------------------------------------
-- List of snapshot names. Each name must be unique. Sorted alphabetically.
-- Used for GUI listbox display for selecting snapshot. 
-- Snapshot name used as a lookup key in snapshots_table.
local snapshots_names = {}

-- Table of snapshot instances.
-- Usage: snapshot_table[snapshot_name] = snapshot_instance
local snapshots_table = {}

--------------------------------------------
------  SNAPSHOT INSTANCE STRUCTURE  ------
--------------------------------------------
--[===[
snapshot_instance is a list of reaper track data.
Created in saveSnapshot() call to buildTrackList().
Used by applySnapshot().       
       
    snapshot_instance: {   
      --entries <individual tracks>
      ss_track : {
        name : string = reaper_track_name,  
        guid : string? = reaper_track_guid,
        selected : boolean = reaper_track_selected,
        use_volume : number = reaper_track_volume,
        use_pan : number = reaper_track_pan, 
        use_solo : boolean = [true, false],
        use_mute : boolean = [true, false],,
        --show_in_mcp : boolean = [true, false],
        show_in_mixer : boolean = [true, false],

        -- <list of track effects>
        fx_table : {
            --entries <list of individual effects>
            fx_instance : {
              fx_guid : string = reaper fx guid
              enabled : boolean = [true, false]
              params : {
                --entries <list of individual params>
                {
                  param_idx : integer = reaper param index
                  param_val : number = reaper param value
                }
              }
            }
        }
      }  -- end ss_track
    } -- end snapshot_instance

--]===]
  
--zzopt
-- Default option settings.  
-- Will use this to save options to projExtState.
-- and for conditionals in script functions.
-- Updated whenever options checklist changes.

local snapshot_options = {
    use_volume = true,
    use_pan = true,
    use_solo = true,
    use_mute = true,
    selected = true,
    --show_in_mcp = true,
    show_in_mixer = true,
    fx_enabled = true,
    fx_params = false,
    auto_del_ghost_items = false
 }

-- Ordered list for options checklist display.
local snapshot_options_names = {
    "use_volume",
    "use_pan",
    "use_solo",
    "use_mute",
    "selected",
    --"show_in_mcp",
    "show_in_mixer",
    "fx_enabled",
    "fx_params",
    "auto_del_ghost_items"
}

-- Default selected values  
local snapshot_options_selected = {}

for _, opt in ipairs(snapshot_options_names) do
    table.insert(snapshot_options_selected, snapshot_options[opt])
end

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

-- if this is declared as local it crashes script.
function my_function()
	-- do stuff --
end

--??? Seems okay if my_function is declared before gui_function call.
--]==]

-----------------------------------  
------   RENAME SNAPSHOT   ------
-----------------------------------
--zzrename 

local function renameSnapshot()
    --dh_log(" ****  renameSnapshot  ****")
        
    -- Validate textbox text --
    local retval, new_name = dhtks.validate_name(GUI.Val("tbx_SnapshotName"))
    
    if not retval then return end
    
    ---- Check if new_name already exists ----
    local ss_name_found = false
    
    for i, ss_name in ipairs(snapshots_names) do
        if new_name == ss_name then
            ss_name_found = true
            break
        end
    end
    
	local orig_name = snapshots_names[GUI.Val("lbx_SnapshotsNames")]
	
    if ss_name_found then	
        reaper.ShowMessageBox("Snapshot name already exists!\n", "Error", 0)
        return
    else
        -- If not name already exists - rename --
        snapshots_names[GUI.Val("lbx_SnapshotsNames")] = new_name

        table.sort(snapshots_names)
        
        --??? Is this assignment necessary?
        
        GUI.elms.lbx_SnapshotsNames.list = snapshots_names
        
        -- Update snapshots_table --
        
        snapshots_table[new_name] = snapshots_table[orig_name]
        snapshots_table[orig_name] = nil

		-- Ask for a redraw on the next update 
        --xxx Either works.
        -- Second is preferred as it is valid even if z layer changed.
        --GUI.redraw_z[28] = true
	    GUI.elms.lbx_SnapshotsNames:redraw()

        hideSaveSnapshotDialogBox()
    end

end  --<renameSnapshot>

-------------------------------------
--------  BUILD TRACK LIST  --------
-------------------------------------

-- Saves state current track visibilty in Mixer Control Panel - not including Master track.
-- ??? Must Mixer be visible? How to check? Will there be issues if not visible?
-- {guid=track_guid, name=track_name, show_in_mixer=[0=hidden, 1=visible], mute=[0=muted, 1=not muted], solo=[0=not solo, 1=solo]} 

-- !!! If this is declared as local then script crashes [attempt to call a nil value (global 'test_track_list')]
-- It seems fine after I move it before GUI button that calls.

local function buildTrackList()

    --dh_log("****  BUILD TRACK LIST  ****")

	local track_list = {}
	local r_track_count = reaper.CountTracks(0)
	
    --dh_log(" > buildTrackList r_track_count: " .. r_track_count)
    
    -- Iterate reaper tracks to fetch data --
    
	for i = 0, r_track_count - 1 do
		local r_track = reaper.GetTrack(0, i)

		local _, rt_name = reaper.GetTrackName(r_track)

        local ss_track = {}

        ss_track["guid"] = reaper.GetTrackGUID(r_track)
        ss_track["name"] = rt_name
        ss_track["selected"] = reaper.GetMediaTrackInfo_Value(r_track, "I_SELECTED")
        ss_track["use_volume"] = reaper.GetMediaTrackInfo_Value(r_track, "D_VOL")
        ss_track["use_pan"] = reaper.GetMediaTrackInfo_Value(r_track, "D_PAN")
        ss_track["use_solo"] = reaper.GetMediaTrackInfo_Value(r_track, "I_SOLO")
        ss_track["use_mute"] = reaper.GetMediaTrackInfo_Value(r_track, "B_MUTE")
        ss_track["show_in_mixer"] = reaper.GetMediaTrackInfo_Value(r_track, "B_SHOWINMIXER")

        --dh_log(" > buildTrackList ss_track['name']: " .. ss_track["name"])
        --dh_log(" > buildTrackList ss_track['use_volume']: " .. ss_track["use_volume"])

--      ******** START FX ********
--[==[ 
     It may be impractical to list all parameters.
     Slows performance and can greatly increase file size.
     Some fx have way too many parameters, many/most never used.
     Ideally is to have checklist for which fx/params to allow.
     Reaper workflow suggestion: 
       Maybe preferable to have duplicate fx with 
       alternate params and use enabled. 
       Then no need to save params.
     TRY: Save only if fx is enabled.  
     Perhaps use fx statechunk. 
--]==]

		local fx_table = {}
		local rfx_count = reaper.TrackFX_GetCount(r_track)
		
		-- Iterate reaper track effects --

        for rfx_idx = 0, rfx_count - 1 do
        
            local fx_instance = {}
                   
            fx_instance["fx_guid"] = reaper.TrackFX_GetFXGUID(r_track , rfx_idx)
            
            local is_fx_enabled = reaper.TrackFX_GetEnabled(r_track, rfx_idx)
            fx_instance["enabled"] = is_fx_enabled
            
            local params = {}

		    -- No need to save params of disabled fx.
		    if is_fx_enabled and snapshot_options.fx_params then
		      
		        --dh_log("> save: fx_guid : " .. fx_instance["fx_guid"])
		        --dh_log("> save: is_fx_enabled : " .. tostring(is_fx_enabled))
		            		          
		        -- Iterate effect params --
		        local paramcount = reaper.TrackFX_GetNumParams(r_track, rfx_idx)
		        --dh_log("> save: paramcount : " .. paramcount)
		          
		        for p_idx = 0, paramcount - 1 do
		            local param = {}
		            param["param_idx"] = p_idx
		            param["param_val"] = reaper.TrackFX_GetParam(r_track, rfx_idx, p_idx)
		            --dh_log("> p_idx : " .. p_idx .. ":: param_val : " .. param['param_val'])
		              
		            table.insert(params, param)
		        end
		          
		    end
		   
		    fx_instance["params"] = params
		   
		    --dh_log(">>> size of params : " .. dhtks.keyed_table_length(fx_instance["params"]))
		   
		    table.insert(fx_table, fx_instance)

        end

		ss_track["fx_table"] = fx_table

--      ********  END FX ********	
			
		table.insert(track_list, ss_track)

	end -- <Iterate reaper tracks r_track_count>
			
	return track_list

end -- <buildTrackList>

----------------------------------
--------  SAVE SNAPSHOT  --------
----------------------------------
--zzsave  --zzadd

local function saveSnapshot(is_new)

    dh_log("---------------------------")
    dh_log("****  SAVING SNAPSHOT  ****")
    dh_log("---------------------------")
    
    local retval = false
	local snapshot_name = GUI.Val("tbx_SnapshotName")
	
    -- If updating by shift + clicking Add button
	-- there is no need to validate snapshot_name.
	
	if is_new == true then
	    retval, snapshot_name = dhtks.validate_name(snapshot_name)
        if not retval then return end
	end

    -----------------------------------------------------------------------	
	-- Check if snapshot name already exists. If so ask to overwrite.
	-- If snapshot name exists and we don't want to overwrite then cancel.
	-----------------------------------------------------------------------
	local may_overwrite = false

    --dh_log("** Check if snapshot name already exists **")	
	
  	for i, sn in ipairs(snapshots_names) do
		
		if sn == snapshot_name then
			local retval = reaper.ShowMessageBox("Snapshot name \"" .. snapshot_name .. "\" already exists! Do you want to overwrire it?\n", "Warning", 4)								

			if retval == 6 then -- 6 is yes
				may_overwrite = true
				break
			else
				return
			end

		end

	end

    ------------------------------------------------------
	----    GET TRACK LIST    ----
	-- Should now have good snapshot name.
  	-- Add snapshot to snapshots list. If new it will be added. 
  	-- If it already exists it will be overwritten.
    ------------------------------------------------------

	local track_list = buildTrackList()
	 
    --dh_log("**** entering if track_list ****")	 

	if track_list then

		-- If overwriting then replace snapshot in list.
		if may_overwrite then
		  	snapshots_table[snapshot_name] = track_list
		  	--dh_log("**** Snapshot overwritten! ****")
	  	else
	  	
            -- Adding new snapshot --

            --dh_log("**** Snapshot added! ****")
 		
		  	-- Add snapshot name to list.

	  		table.insert(snapshots_names, snapshot_name)
		  	table.sort(snapshots_names)
	
		  	-- Add snapshot to snapshots_table

		  	snapshots_table[snapshot_name] = track_list
			
		end
		
		--??? Is this assignment necessary?
		GUI.elms.lbx_SnapshotsNames.list = snapshots_names
		
		-- Ask for a redraw on the next update 
		--xxx Either works.
		GUI.elms.lbx_SnapshotsNames:redraw()
		--GUI.redraw_z[28] = true 
		
    else
		reaper.ShowMessageBox("Couldn't find any tracks! Aborting Save.\n", "Error", 0)								
	end

	hideSaveSnapshotDialogBox()
	
end -- <saveSnapshot>

--------------------------------  
------  APPLY SNAPSHOT  ------
--------------------------------
--zzapply 

--[==[ !!! CAUTION:
When opening script the current track state is what it is.
When applying a snapshot, the current track state is overwritten.
Undo takes care of it, but not if tab is changed.
If I want to restore it I will need to save it somewhere.
Maybe save to "restore" and have a "restore" button.
Alt., Can add a "restore" entry to list box.
  Can make it first item and disallow renaming.
  Update on script open, or maybe before first applying snapshot.
  Would I need to save on every "apply"?
  Alt., Use a timestamp?
--]==]

local function applySnapshot()

    dh_log("---------------------------")
    dh_log("****   applySnapshot   ****")
    dh_log("---------------------------")
    
	local ghost_tracks_list = {}
	
	--??? TODO:
	-- If tab changed (or script opened) save track state.
	-- or leave it to user to save current state before applying.
	--saveSnapshot(restore)

    -- Get index -- 
    
	local lbx_idx = GUI.Val("lbx_SnapshotsNames")
	
	-- If nothing selected --
	
	if lbx_idx == nil then
		reaper.ShowMessageBox("Select a snapshot or create one! .\n", "Error", 0)	
		return
	end
	
	--dh_log("> getting snapshot_name")

    -- Get snapshot name from snapshots_names to use as key to snapshots_table.

	local snapshot_name = snapshots_names[lbx_idx]

	-- Get snapshot instance from snapshots_table using snapshot_name.
    -- snapshots_names was built from snapshots_table so they should correspond.
    	
    local snapshot_instance = snapshots_table[snapshot_name]

	--??? Maybe unnecessary check since building snapshots_names from snapshots_table.
	if snapshot_instance == nil then
	    local retval = reaper.ShowMessageBox("Snapshot not found!\nDo you want to delete Snapshot name?\n", "Error", 4)
		if retval == 6 then
		     table.remove(snapshots_names, lbx_idx)
	         -->>>GUI.elms.lbx_SnapshotsNames.list = snapshots_names	
	         GUI.elms.lbx_SnapshotsNames:redraw()
		end
		return
	end
	
-------------------------------------
  	reaper.PreventUIRefresh(1)
  	reaper.Undo_BeginBlock()
-------------------------------------

    -- # Iterate snapshot_instance  --
    -- Use snapshot data to update reaper.
    -- snapshot_instance is list of ss_tracks
    --dh_log("> ready to iterate snapshot_instance")
    --dh_log("> Size of snapshot_instance <track_list> is: " .. #snapshot_instance)

	for ss_idx, ss_track in ipairs(snapshot_instance) do
			
        local reaper_track_count = reaper.CountTracks(0)
        local reaper_track
        local reaper_track_guid
      
        local reaper_track_found = false

        -- # Iterate reaper tracks to match saved ss_track --
        --!!! There isn't a reaper.GetTrackByGuid so I'll have to find it myself.
        -- reaper.BR_GetMediaTrackByGUID(ReaProject proj, string guidStringIn)

        for rt_idx = 0, reaper_track_count - 1 do
	        reaper_track = reaper.GetTrack(0, rt_idx)
	        reaper_track_guid = reaper.GetTrackGUID(reaper_track)
		   
		    --dh_log("ss_track.guid:     " .. ss_track.guid)
		    --dh_log("reaper_track_guid: " .. reaper_track_guid)

            -- # Is Reaper track found --
		    if ss_track.guid == reaper_track_guid then
		        reaper_track_found = true
		        --dh_log("is_track_found = true")
		        --dh_log("FOUND: reaper_track_guid: " .. reaper_track_guid)
		        --local _, reaper_track_name = reaper.GetTrackName(reaper_track)
		        break
		    end

	    end -- <iterate reaper tracks>
	   
--zzghost
	    -- Reaper track NOT found --
	    -- This is where to add ghost tracks to list.
		
        if not reaper_track_found then
            --dh_log("Reaper rack using ss_idx: " ..  ss_idx .. " not found:" )
            -- Reference to ss_track to remove.
            table.insert(ghost_tracks_list, ss_idx)
        end      
            		
        ------------------------------------------------
        -- Reaper track found, update from snapshot --
        ------------------------------------------------
  
        if reaper_track_found then
		
	        --??? Do I want to update track name?
	        -- It may have been changed!

            if ss_track.use_volume and snapshot_options.use_volume then
                reaper.SetMediaTrackInfo_Value(reaper_track, "D_VOL", ss_track.use_volume)
            end
            if ss_track.use_pan and snapshot_options.use_pan then
                reaper.SetMediaTrackInfo_Value(reaper_track, "D_PAN", ss_track.use_pan)
            end
            if ss_track.use_solo and snapshot_options.use_solo then
                reaper.SetMediaTrackInfo_Value(reaper_track, "I_SOLO", ss_track.use_solo)
            end
            if ss_track.use_mute and snapshot_options.use_mute then
                reaper.SetMediaTrackInfo_Value(reaper_track, "B_MUTE", ss_track.use_mute)
            end
            if ss_track.show_in_mixer and snapshot_options.show_in_mixer then
               reaper.SetMediaTrackInfo_Value(reaper_track, "B_SHOWINMIXER", ss_track.show_in_mixer)
            end
            
            --if ss_track.selected and snapshot_options.selected then
            --    reaper.SetMediaTrackInfo_Value(reaper_track, "I_SELECTED", ss_track.selected)
            --end
            
            -- Is true and is not nil
            if snapshot_options.selected and ss_track.selected then
                reaper.SetMediaTrackInfo_Value(reaper_track, "I_SELECTED", ss_track.selected)
                --dh_log(" > if (ss_track.selected == 1) and snapshot_options.selected")
            end
            
            --dh_log(" ># APPLY: ss_track['selected']: " .. tostring(ss_track["selected"]))
            --dh_log(" > snapshot_options.selected: " .. tostring(snapshot_options.selected))
            --dh_log(" > snapshot_options.use_volume: " .. tostring(snapshot_options.use_volume))
            
            --******** START FX ********

            --??? fx_table may have been saved to projExtState as '' is table was empty.

            if snapshot_options.fx_enabled then
            
                local fx_table = ss_track["fx_table"]

                if type(fx_table) == "table" and #fx_table > 0 then
                
                    local ghost_fx_list = {}
                        
	                -- # Iterate ss fx_table --
                    for fx_idx, fx_instance in ipairs(fx_table) do
                    
                        local fx_found = false
                    
                        -- # Iterate reaper track effects to find matching guid --          
	                    local rfx_count = reaper.TrackFX_GetCount(reaper_track)

	                    for rfx_idx = 0, rfx_count - 1 do
	                        local rfx_guid = reaper.TrackFX_GetFXGUID(reaper_track, rfx_idx)
	            
	                        -- # Is fx found? --
	                        if fx_instance["fx_guid"] == rfx_guid then
	                            
	                            fx_found = true

                                local is_fx_enabled = fx_instance["enabled"]
	                            --dh_log(">>> apply: is_fx_enabled : " .. tostring(is_fx_enabled))
	                            reaper.TrackFX_SetEnabled(reaper_track, rfx_idx, is_fx_enabled)
	              
	                            if is_fx_enabled then
	                                --dh_log(">>> apply: is_fx_enabled : " .. tostring(is_fx_enabled))
	                
	                                -- # Iterate and set params --
	                                --dh_log(">>> size of fx_instance['params'] : " .. dhtks.keyed_tablelength(fx_instance["params"]))
	                 
	                                for _, param in ipairs(fx_instance["params"]) do
	                
	                                    --local p_idx = tonumber(param_idx)
	                                    --local p_val = param_val
	                                    --dh_log(">>> type of p_idx : " .. type(p_idx))
	                                    --dh_log(">>> param_val : " .. param_val)
	                                    --dh_log(">>> param_idx : <" .. param["param_idx"] .. ">:: param_val : " .. param["param_val"])
	                  
	                                    --??? Do I need to do this?
	                                    --local r_params = reaper.TrackFX_GetNumParams(reaper_track, fx_idx)   
	                 
	                                    --??? Should I notify (list) is param not found?
	                                    -- Set param returns boolean.
	                                    reaper.TrackFX_SetParam(reaper_track, rfx_idx, param["param_idx"], param["param_val"])
	                   
	                                end
	              
	                            end --<if is_fx_enabled> 
	                            break

	                        end --<if fx_instance["fx_guid"]>
	                    
	                    end -- <Iterate reaper track effects>
	                    
                        -- List any fx not found --
	                    if not fx_found then
	                        table.insert(ghost_fx_list, fx_idx)
	                    end
	        
	                end -- <for fx_idx>  
--zzghostfx	                      
	                -- Delete ghost fx --
	                
	                if #ghost_fx_list > 0 then
	                
	                     local retval
	                     if snapshot_options.auto_del_ghost_items == false then
	                         local msg = "One or more reaper fxs could not be found! They were probably removed from project. \nDo you want to remove them from the snapshot table?"
	                         retval = reaper.ShowMessageBox(msg, "Warning", 4)	-- retval 6 is yes							
	                     end
	                     
	                     if snapshot_options.auto_del_ghost_items or (retval == 6)  then
	                     
	                         --dh_log("Remove ghost items.")
	                         for i = 1, #ghost_fx_list do
	                             --dh_log("Removing ghost fx reference: index is: " ..  tostring(ghost_fx_list[i]) .. "; name is: " .. ghost_fx_list[i].name)
	                             --dh_log("Removing ghost fx reference: index is: " ..  tostring(ghost_fx_list[i]))
	                     
	                             table.remove(snapshot_instance, ghost_fx_list[i])
	                         end
	                     
	                     end
	                end     

                end --<if type(fx_table)>
            
            end --<if snapshot_options.fx_enabled>
        
            --********  END FX ********

	    end -- <reaper_track_found>

	end -- <for ss_idx> <Iterate snapshot_instance>

-----------------------------------------------------------
  	reaper.Undo_EndBlock("Restore Tracks Visibility", -1)
  	reaper.TrackList_AdjustWindows(false)
  	reaper.UpdateArrange()
  	reaper.PreventUIRefresh(-1)
-----------------------------------------------------------
--zzghost
	
	-- Remove any ghost track references --
	
	if #ghost_tracks_list > 0 then
		--Scope: vars declared local in if statements are local to if statements.
		--dh_log("ghost_tracks_list size is: " ..  #ghost_tracks_list)
		
		local retval
	
		if snapshot_options.auto_del_ghost_items == false then
			local msg = "One or more reaper tracks could not be found! They were probably removed from project. Do you want to remove them from the snapshot table?"
			retval = reaper.ShowMessageBox(msg, "Warning", 4)	-- retval 6 is yes							
		end
		
		--dh_log("MB retval is: " ..  tostring(retval))
		
		if snapshot_options.auto_del_ghost_items or (retval == 6)  then
		
		  	for i = 1, #ghost_tracks_list do
		  		--dh_log("Removing ghost track reference: index is: " ..  tostring(ghost_tracks_list[i]))
				--dh_log("snapshot instance track name is: " ..  snapshot_instance[ghost_tracks_list[i]].name)
				
		    	table.remove(snapshot_instance, ghost_tracks_list[i])
		  	end
		
		end
			
	end		

end -- <applySnapshot>

--======================================
  ------   Element Functions   ------
--======================================
--zzelements  
-- This only opens Dialog box.
-- Puts listbox value in textbox.

local function btn_AddSnapshotClick()

    --dh_log("**** btn_AddSnapshotClick clicked opens popup ****")

    -- Copy snapshot name from listbox to textbox --

	local lbx_idx = GUI.Val("lbx_SnapshotsNames")
		
    if lbx_idx then
		local snapshot_name = snapshots_names[lbx_idx]
		if snapshot_name then
			GUI.Val("tbx_SnapshotName", snapshot_name)
		end
    else		
	    GUI.Val("tbx_SnapshotName", "")
    end

    if GUI.mouse.cap & 8 == 8 then  
        --Shift + click : Update
        saveSnapshot(false)
        
    elseif GUI.mouse.cap & 16 == 16 then  
        --Alt + click : Rename
        GUI.Val("lbl_SaveSnapshotDialog", "  Rename Snapshot  ")
    	GUI.elms.btn_ConfirmSaveSnapshot.is_new = false
    	showSaveSnapshotDialogBox()
    	
    else  
        -- click : Add new
        GUI.Val("lbl_SaveSnapshotDialog",  "Create New Snapshot")
        GUI.elms.btn_ConfirmSaveSnapshot.is_new = true
        showSaveSnapshotDialogBox()
    end

end

--zzsave  --zzrename  
local function btn_ConfirmSaveSnapshotClick()
	if GUI.elms.btn_ConfirmSaveSnapshot.is_new == true then
	    saveSnapshot(true)
	else
	    renameSnapshot()
	end
end

local function btn_CancelSaveSnapshotClick()
	-- Should I clear textbox???
	--GUI.Val("tbx_SnapshotName", "")
	hideSaveSnapshotDialog()
end

--zzapply
local function btn_ApplySnapshotClick()
	applySnapshot()
end

--zzdelete
local function btn_DeleteSnapshotClick()

    --dh_log("    **** DeleteSnapshotClick ****")

    -- Get the list box's selected item --
	local lbx_idx = GUI.Val("lbx_SnapshotsNames")
	
	--if lbx_idx then dh_log(" > lbx_idx: " .. lbx_idx) end
	
	if lbx_idx == nil then
		reaper.ShowMessageBox("Select a snapshot to delete! .\n", "Error", 0)	
		return
	end
	
	local snapshot_name = snapshots_names[lbx_idx]
	--dh_log(" > btn_DeleteSnapshotClick snapshot name: " .. snapshot_name)
	 
	local retval = reaper.ShowMessageBox("Do you want to delete the current snapshot?\n" .. snapshot_name, "Warning", 4)
									
	if retval == 6 then --6 is yes
		table.remove(snapshots_names, lbx_idx)
		GUI.elms.lbx_SnapshotsNames.list = snapshots_names
		     	
		snapshots_table[snapshot_name] = nil

        -- Ask for a redraw on the next update 
        --xxx Either works.
        GUI.elms.lbx_SnapshotsNames:redraw()
        --GUI.redraw_z[28] = true
		
	end
end

--!!! Can not be local or script crashes.
function hideSaveSnapshotDialogBox()
    GUI.elms_hide[25] = true
    GUI.elms_hide[26] = true
    GUI.elms_hide[27] = true
    GUI.elms_hide[28] = true
    GUI.elms_hide[29] = true
    GUI.elms_hide[30] = true
end

--!!! Can not be local or script crashes.
function showSaveSnapshotDialogBox()
    GUI.elms_hide[25] = false
    GUI.elms_hide[26] = false
    GUI.elms_hide[27] = false
    GUI.elms_hide[28] = false
    GUI.elms_hide[29] = false
    GUI.elms_hide[30] = false

    -- Need to redraw popup after scaleApp().
    --??? Can this go somewhere else?
    --[[
    GUI.redraw_z[25] = true
    GUI.redraw_z[26] = true
    GUI.redraw_z[27] = true
    GUI.redraw_z[28] = true
    GUI.redraw_z[29] = true
    GUI.redraw_z[30] = true
    --]]
end

--======================================
  --------      ELEMENTS      --------
--======================================
--zzelements 

--------------------------------
------    Main Window    ------
--------------------------------

GUI.New("frm_Main", "Frame", {
    z = 50,
    x = 0,
    y = 0,
    w = DHTK.APP_WIDTH, 
    h = DHTK.APP_HEIGHT, 
    shadow = false,
    fill = true,         
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

GUI.New("lbl_Snapshots", "Label", {
    z = 49,
    x = 32, 
    y = 8, 
    caption = "Snapshots",
    font = "sans32",
    color = "txt",
    bg = "wnd_bg",    
    shadow = false
})

GUI.New("btn_Prefs", "Button", {
    z = 49,
    x = 488, 
    y = 12, 
    w = 80, 
    h = 28, 
    caption = "Prefs",
    font = "sans24",
    col_txt = "txt",
    col_fill = "btn_face",	
	func = DHTK.showPrefsWindow
})

GUI.New("lbx_SnapshotsNames", "Listbox", {
    z = 48,
    x = 16, 
    y = 48, 
    w = DHTK.APP_WIDTH - 32, 
    h = 272, 
    list = {},
    multi = false, --!!! Do not change
    caption = "",
    font_a = "sans16",        -- caption font not used
    font_b = "sans32",        -- list font
    color = "txt2",
    col_fill = "elm_fill",    -- scrollbar fill
    bg = "elm_bg",            -- box bg
    cap_bg = "wnd_bg",
    shadow = true,
    pad = 4
})

GUI.New("btn_AddSnapshot", "Button", {
    z = 49,
    x = 32, 
    y = 332, 
    w = 96, 
    h = 36,  
    caption = "Add",
    font = "sans28",
    col_txt = "txt",
    col_fill = "btn_face",	
	func = btn_AddSnapshotClick
})

GUI.New("btn_ApplySnapshot", "Button", {
    z = 49,
    x = 178, 
    y = 332, 
    w = 240, 
    h = 36, 
    caption = "Apply",
    font = "sans28",
    col_txt = "txt",
    col_fill = "btn_face",	
	func = btn_ApplySnapshotClick
})

GUI.New("btn_DeleteSnapshot", "Button", {
    z = 49,
    x = 472, 
    y = 332, 
    w = 96, 
    h = 36, 
    caption = "Delete",
    font = "sans28",
    col_txt = "txt",
    col_fill = "btn_face",
	func = btn_DeleteSnapshotClick
})

-------------------------------------
----  Save Snapshot Dialog Box  ----
-------------------------------------
-- Center popup windows in main window.

GUI.New("bg_SaveSnapshotDialog", "dh_Frame", {
    z = 30,
    x = 0,
    y = 0,
    w = DHTK.APP_WIDTH, 
    h = DHTK.APP_HEIGHT, 
    --shadow = false,
    border_width = 0,
    radius = 0,
    fill = true,
    col_border = "dlg_bg", --{0,0,0,144},
    col_fill = "elm_frame"
})

GUI.New("frm_SaveSnapshotDialog", "dh_Frame", {
    z = 29,
    x = POPUP_LEFT,
    y = POPUP_TOP,
    w = POPUP_WIDTH,
    h = POPUP_HEIGHT,
    --shadow = false,
    border_width = 8, 
    radius = 8, 
    fill = true,
    col_border = "elm_border",	
    color_fill = "elm_fill"
})

GUI.New("lbl_SaveSnapshotDialog", "Label", {
    z = 25,
    x = POPUP_LEFT + 120, 
    y = POPUP_TOP + 16, 
    caption = "Create new Snapshot",
    font = "sans32",
    color = "txt",
    bg = "elm_fill",    
    shadow = false
})

GUI.New("lbl_SnapshotName", "Label", {
    z = 27,
    x = POPUP_LEFT + 44,  
    y = POPUP_TOP + 64, 
	caption = [[Use only alphanumeric, $, &, +, -, or _.
	Parentheses and brackets are allowed.
	Spaces are converted to underscores.
	]],
    font = "sans24",
    color = "txt",
    bg = "elm_fill",
    shadow = false
})

--!!! Keep this with its own z to prevent unnecessary 
--    redraws when textbox is focused.

GUI.New("tbx_SnapshotName", "Textbox", {
    z = 26,
    x = POPUP_LEFT + 40, 
    y = POPUP_TOP + 148, 
    w = 400, 
    h = 36, 
    caption = "",
    font_b = "mono20",   --Need mono font in textbox
    color = "txt2"
})

GUI.New("btn_ConfirmSaveSnapshot", "Button", {
    z = 27,
    x = POPUP_LEFT + 48, 
    y = POPUP_TOP + 196, 
    w = 144, 
    h = 36, 
    caption = "Save",
    font = "sans32",
    col_txt = "txt",
    col_fill = "btn_face",	
    is_new = true,
	func = btn_ConfirmSaveSnapshotClick
})

GUI.New("btn_CancelSaveSnapshot", "Button", {
    z = 27,
    x = POPUP_LEFT + 290, 
    y = POPUP_TOP + 196, 
    w = 144, 
    h = 36, 
    caption = "Cancel",
    font = "sans32",
    col_txt = "txt",
    col_fill = "btn_face",	
	func = hideSaveSnapshotDialogBox
})

------------------------------------
------   Options Section   ------ 
------------------------------------
-- This gets added to Preferences window. Watch those z layers.
--zzoptions v--zz0425

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
	opts= snapshot_options_names,
	--opts = {},
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

--------------------------------
------  Tips Display  ------
--------------------------------
--zztips
-- There is some extra room at bottom of "Preferences" window. 
-- I used it to include some useful tips.

GUI.New("lbl_tip_01", "Label", 19, 18, 296, "Add button Click - Opens dialog box. Enter name for new snapshot.", false, "sans20", "txt", "elm_fill" )
GUI.New("lbl_tip_02", "Label", 19, 18, 316, "Add button Shift + Click - Updates selected snapshot.", false, "sans20", "txt", "elm_fill" )
GUI.New("lbl_tip_03", "Label", 19, 18, 336, "Add button Alt + Click - Opens dialog box. Enter new name to rename snapshot.", false, "sans20", "txt", "elm_fill" )

--======================================
  ------   Method Overrides  ------
--======================================
--zzoverrides 
-- Use to add additional functionality to GUI functions.

--dh_log("**** Method Overrides ****")

-- Could alternately use this event to copy listbox item into textbox here.
--[[
function GUI.elms.lbx_SnapshotsNames:onmouseup()
	-- Run the element's normal method
	GUI.Listbox.onmouseup(self)
end
--]]

--zzopts  --zz0425
-- Update snapshot_options --	
function GUI.elms.chkl_Options:onmouseup()
	
	-- Run the element's normal method
	GUI.Checklist.onmouseup(self)

	-- Add our code
    -- Update snapshot_options --
    snapshot_options[snapshot_options_names[self.optindex]] = self.optsel[self.optindex]
    
end

--======================================
  ------      SCRIPT FLOW      ------
--======================================
--zzflow
--dh_log("**** SCRIPT FLOW ****")
--[===[ 
  Start script:
    Get window settings from current project ext state.
    Initialize and position window <see position window>.
    Store reference to init project.
  Populate lists.
    Get snapshots data from current project ext state.
    Get snapshots options from current project ext state.
  Change project tab:
    Save snapshots data to previous project ext state (only if list has data).
    Save snapshots options to previous project ext state.
    Clear tables and options and repopulate with current project ext state.
  Exit script:
    Save snapshots data to current project ext state.
    Save snapshots options to current project ext state.
    Save window settings to reaper ext state.
--]===]

--======================================
  ------   GET PROJECT DATA   ------    
--======================================
--zzpopulate

-- Update lists on init and when changing tabs.
-- Get data from current project.
-- Will be building snapshots_names from snapshots_table.

local function populateLists(proj)

	dh_log("--------------------------")
    dh_log("****  POPULATE LISTS  ****")
    dh_log("--------------------------")
    
    --<<< testing
	local projname = reaper.GetProjectName(proj)
	dh_log(" > projname: " .. projname)
    -->>>
    
    ---------------------------------- 
    ------ Get snapshots_table ------
    ----------------------------------
    snapshots_names = {}  -- Used for displayed in listbox.
    snapshots_table = {}  -- Actual snapshot data.
    
	local has_snapshots = false
	local retval = 0
	local ret_string = nil
	local json_string = ""
    
    -- retval = 0 if it extstate doesn't exist
    -- retval = 1 if extstata has any value including ([], "", " ")
    -- Therefore maybe not necessary to check for retval.
    -- Only interested in returned string.

    retval, json_string = reaper.GetProjExtState(proj, "dh_Snapshots", "snapshots_table")

    -- Ext state snapshots exists
    if (retval == 1) then
       
        snapshots_table = json.decode(json_string) -- returns Lua table
        -- Check if it is table and has entries --
        if type(snapshots_table) == "table" and (dhtks.keyed_table_length(snapshots_table) > 0) then
            
            has_snapshots = true
            --dh_log(" > has_snapshots = TRUE")
            --dh_log(" > SIZE of snapshots_table: " .. dhtks.keyed_table_length(snapshots_table))
      
            ------------------------------------------------ 
            -- Build snapshots_names from snapshots_table.
            ------------------------------------------------
            --dh_log(" >>> Building snapshots_names from snapshots_table")
            
		    for k, v in pairs(snapshots_table) do
		        table.insert(snapshots_names, k)
		        --dh_log("build table snapshot name is: " .. k)
		    end
      
            table.sort(snapshots_names)            
                        
        end      

    end
    
    --??? Redundant?
    if not has_snapshots then
       snapshots_table = {}
    end
 
    --dh_log(" > END SIZE of snapshots_names: " .. #snapshots_names)
    --dh_log(" > END SIZE of snapshots_table: " .. dhtks.keyed_table_length(snapshots_table))

    -- This updates listbox.
    
    --??? Is this assignment really necessary?
    GUI.elms.lbx_SnapshotsNames.list = snapshots_names
    
    if has_snapshots then
        GUI.Val("lbx_SnapshotsNames", 1)
    else    
        --??? I think this is necessary because this function not called by GUI element.
        GUI.elms.lbx_SnapshotsNames:redraw()
    end
      
    ------------------------------------
    ------ Get snapshot_options ------
    ------------------------------------
    -- If unsucessful, snapshot_options will keep previous values.

    retval, json_string = reaper.GetProjExtState(proj, "dh_Snapshots", "snapshot_options")
    
    if (retval == 1) then
    
        local opts = json.decode(json_string) -- should return Lua table
    
        if type(opts) == "table" and dhtks.keyed_table_length(opts) > 0 then
            snapshot_options = opts
          
            -- Update checklist --
            
            local bool_table = {}
           
            for _, opt in ipairs(snapshot_options_names) do
                table.insert(bool_table, snapshot_options[opt])
            end
                    
            GUI.Val('chkl_Options', bool_table)

        end
   
    end 
   
  --!!! Can get rid of json string when done loading?
  json_string = nil
  
end  --<populateLists>

--======================================
  ------  SAVE PROJ EXT STATE  ------    
--======================================
--zzsaveext
-- Save ext state on script exit and on project tab change.

--[==[
    SetProjExtState() 
	integer reaper.SetProjExtState(ReaProject proj, string extname, string key, string value)
	Save a key/value pair for a specific extension, to be restored the next time this specific project is loaded.
	Params:
		ReaProject proj: 	The project-number. 0 for the current project.
		string extname:     The section, in which the key/value is stored. Use name of script.
		string key:  	    The key, that stores the value.
		string value:		The value, that's stored in the key.		
	If key is NULL or "", all extended data for that extname will be deleted. 
	If val is NULL or "", the data previously associated with that key will be deleted. 
	Returns the size of the state for this extname.
--]==]

local function saveProjExtState(proj)

    dh_log("-------------------------------")
    dh_log("****  SAVE PROJ EXT STATE  ****")
    dh_log("-------------------------------")
    
    --<<< testing
    --local projname = reaper.GetProjectName(proj)
    --dh_log("> saveProjExtState saving proj: " .. projname)
    -->>>
    
    local json_string = ""
  
    ---- Save snapshots table ----
    
    -- snapshots_table should not have any empty keys.
    -- But if somehow possible this happens:
     
    -- Remove item(s) with empty keys --
    -- Type of snapshots_table should always be "table" by design.
    
    if type(snapshots_table) == "table" then 
        for k, v in pairs(snapshots_table) do
            --dh_log("> snapshots_table key: <" .. k)
            --dh_log("> snapshots_table key type is: <" .. type(k) .. ">")
            if k == " " or k == "" then
                snapshots_table[k] = nil
            end
        end
    end
    
    --dh_log("> after remove bad keys size of snapshots_table: " .. dhtks.keyed_table_length(snapshots_table))

    -- When starting script or changing tabs snapshots_table = {}
    -- Therefore after encoding json_string is at least = {}.
    -- Check it anyway? 
    
    ---- Encode snapshots_table ----
        
    -- If, for some reason, snapshots_table isn't table
    -- then json_string is "".    
        
    if (type(snapshots_table) == "table") then
        json_string = json.encode(snapshots_table)
    end

    --dh_log("json_string of snapshots_table is\n " .. json_string  .. "\n")
    reaper.SetProjExtState(proj, "dh_Snapshots", "snapshots_table", json_string)
  
    ---- Save snapshot options ----
    
    json_string = json.encode(snapshot_options)
    reaper.SetProjExtState(0, "dh_Snapshots", "snapshot_options", json_string)
    
    json_string = nil
  
end --<saveProjExtState>

--[[ Functionality move to dh_Toolkit_core. Kept here for reference.
local function saveWindowSettings()

	-- Save window settings --
	--??? local
	__, cur_x, cur_y = gfx.dock(-1, 0, 0, 0, 0)
	window_settings.left = cur_x
	window_settings.top = cur_y
	
	local json_string = json.encode(window_settings)
	--dh_log(" EXIT: json_string is\n " .. json_string  .. "\n")
	reaper.SetExtState("dh_Snapshots", "window_settings", json_string, true)
	
    json_string = nil
    
end --<saveWindowSettings>
--]]

--======================================
  --------      EXIT      --------
--======================================
--zzexit
--dh_log("**** exit section ****")

-- Code to execute before window closes, such as saving states and window position.
-- projExtState is saved to section name DHTK.EXT_STATE_NAME.

local function Exit()
	
	--[[ DEV NOTE: Necessary! ]]--
    DHTK.saveWindowSettings()
    
    --xxx Save current project ext state.
    saveProjExtState(0)
    
    --dh_log("**** EXITING: ****")
    
end --<EXIT>

-- Calls Exit when script is ending.
reaper.atexit(Exit)

--======================================
  ------  Script Initialize  ------
--======================================
--zzinit  --zz0425
--dh_log("**** SCRIPT INIT ****")

-----------------------------------------
--  GUI Elements Initialization
--  Done here - after element creation
----------------------------------------

-- Hide these layers until needed.
hideSaveSnapshotDialogBox()

-- Set snapshots options default values
--GUI.elms.chkl_Options.optarray = snapshot_options_names
GUI.Val("chkl_Options", snapshot_options_selected)

--[[ DEV NOTE: Necessary! ]]--
DHTK.init_scale_elms()

----------------------------------------
--   Non GUI Initialization
----------------------------------------
-- Will need to access these in main loop (to check if tab was changed).
local proj_before_change, proj_name_before_change = reaper.EnumProjects(-1)

--xxx This initializes script specific items.
populateLists(proj_before_change)

--======================================
  ------   MAIN LOOP <dhMain>   ------
--======================================
--zzmain
--[==[ Reference:
  GUI.Main is run on every update loop of the GUI script; anything you would put
  inside a reaper.defer() loop should go here. (The function name doesn't matter)
  GUI.Main calls:
     GUI.Main_Update_State() checks if script window w or h changed:
       Yes: updates GUI.cur_w and GUI.cur_h, sets GUI.resized = true,
         and calls GUI.onresize().
       No: sets GUI.resized = false
     GUI.Main_Update_Elms()
       Iterates GUI.elms_list in reverse z-order updating each elm.
     Runs user function <dhMain> if defined.
     GUI.Main_Draw()
       Checks if script asked for anything to be redrawn.
         If yes, redraws all non-hidden layers in reverse z-order.
--]==]

local function dhMain()
    --dh_log("> In dhMain")

	if GUI.resized then
        -- If the window's size has been changed, reopen it
        -- at the current position with the size we specified
		local __,x,y,w,h = gfx.dock(-1,0,0,0,0)
		gfx.quit()
		
		--[[
		-- I did have this here, but don't remember why I removed it. 
		if is_window_rescaled then
            GUI.update_elms_list(true)
		end
		--]]
		
		gfx.init(GUI.name, GUI.w, GUI.h, 0, x, y)
		GUI.redraw_z[0] = true
	end
	
    --------------------------------------------
    --   Check if project tab was changed   --
    --------------------------------------------
    -- If so, save previous project state then repopulate with current.
    -- Save only if list has data.
    
    local curr_proj, curr_proj_name = reaper.EnumProjects(-1)
     
    if curr_proj_name ~= proj_name_before_change then
    
      proj_name_before_change = curr_proj_name
      
      --dh_log("-----------------------------")
      --dh_log("#### -- CHANGING TABS -- ####")
      --dh_log("-----------------------------")
      
      --dh_log(curr_proj_name)
      
      saveProjExtState(proj_before_change)
      
      proj_before_change = curr_proj
      
      --xxx
      populateLists(curr_proj)

    end
end  --<dhMain>

-- Open the script window and initialize a few things.
GUI.Init()

-- Tell the GUI library to run a function on each update loop.
-- Individual elements are updated first, then GUI.func is run, then the GUI is redrawn.
GUI.func = dhMain

-- How often (in seconds) to run GUI.func. 0 = every loop.
GUI.freq = 0

--dh_log("**** Ready to enter Main ****")

-- Start the main loop
GUI.Main()

--zzend