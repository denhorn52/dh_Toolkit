--dh_ArrangeViews.lua 
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
-- Save and switch between arrange views.
-- Quickly navigate to regions.
-- See accompanying doc files for usage and features.

---------------------------------------------
-- CONVENTIONS USED:

--   camelCase used for var and function names pertaining to GUI.
--   snake_case used for other var and function names.
--   Comments starting with --zz are bookmarks.
--   Comments starting with --<<< denotes code used for testing.
--   Sometimes -->>> denotes end of block used for testing.
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

> Clicking on script buttons focuses script window.
  If I want to return focus back to reaper then choose where.
    btn_Go_Click             maybe
    btn_Go_Right_Click       maybe
    btn_Add_View_Click       maybe on success
    btn_Delete_View_Click    maybe on success
    btn_Select_Region_Click  maybe

x Menubox.lua opens gfx menu with upper right at mouse position.
    Change Menubox.lua to facilitate different positioning.
    Maybe offer option?

x Selecting MIDI item opens MIDI editor - I don't want that.

> Put Lokasenna logo on Prefs page. 
    Probably not without modifying Core.lua. See Core.lua line 539 GUI.Draw_Version.

> THEME EDITOR: This may take some doing.
  Can use color tiles to select elm colors. Display in real time.
  Have reset button to clear.
  Have save button to write code block to console so that it can
    be copied to dh_Themes.lua,
    or can save to ext state (maybe file?).
    
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
GUI.req("Classes/Class - Label.lua")()
--GUI.req("Classes/Class - Listbox.lua")()
--GUI.req("Classes/Class - Menubox.lua")()
--GUI.req("Classes/Class - Options.lua")()
--GUI.req("Classes/Class - Tabs.lua")()
GUI.req("Classes/Class - Textbox.lua")()
--GUI.req("Classes/Class - Window.lua")()

-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end

GUI.name = "dh_ArrangeViews v1.0"

--Hide the version number since I'm using a small window.
GUI.Draw_Version = function () end

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
DHTK.EXT_STATE_NAME = "dh_ArrangeViews"

DHTK.MULTIPLE_HEIGHTS = true

-- Script window dimensions at 1.00x scale.
DHTK.APP_WIDTH = 640

-- Design heights of the window states.
DHTK.APP_MIN_HEIGHT = 48
DHTK.APP_EXP_HEIGHT = 88
DHTK.PREFS_HEIGHT = 400

-- Scaled heights of the window states.
DHTK.s_APP_MIN_HEIGHT = DHTK.APP_MIN_HEIGHT
DHTK.s_APP_EXP_HEIGHT = DHTK.APP_EXP_HEIGHT
DHTK.s_PREFS_HEIGHT = DHTK.PREFS_HEIGHT

-----------------------------------------
-- Revised Lokasenna's Menubox class for dynamic entries.
local dh_mbx = require "classes/dh_Menubox"

-- Revised Lokasenna's Options class to use my color theming.
local dh_opt = require "classes/dh_Options"

-- Revised Lokasenna's Window class to use my color theming.
--local dh_wnd = require "classes/dh_Window"

-----------------------------------------
-- !!! Necessary. Must be after req dh_Options
DHTK.init_DHTK()
-----------------------------------------

local dhtks = require "common/dh_Toolkit_shared"
local json = require "common/json"

--======================================
  --------      My Data      --------
--======================================
--zzdata   
-- Pre-declare variables here so every function has access to it.

-- List of view names. Each name must be unique. Sorted alphabetically.
-- Used for GUI menubox display for selecting view. 
-- View name used as a lookup key in arrange_views_table.
local arrange_views_names = {}

-- Table of arrange view instances.
-- Usage: arrange_views_table[arrange_view_name] = arrange_view_instance
local arrange_views_table = {}

--------------------------------------------
----  ARRANGE VIEW INSTANCE STRUCTURE  ----
--------------------------------------------
--[===[ 
view_instance is a list of view_data 
Created during createView()

    view_instance : {
        start_time = number, 
        end_time = number, 
        cursor_position = number,
        loop_starttime = number,
        loop_endtime = number,
        selected_track = reaper_track_guid
        <list of reaper selected items iguids as strings>	
    	  sel_items = {
	        --entries
	        iguid : number
    	}
    }
--]===]

--zzopt
-- Default option settings.
-- Will use this to save options to projExtState.
-- and for conditionals in script functions.
-- Updated whenever options checklist changes.

local view_options = {
  use_selected_items = true,
  use_cursor_pos = true,
  use_loop_time_range = true,
  use_vert_scroll = true,
  auto_del_ghost_tracks = false
}

-- Ordered list for options checklist display.
local view_options_names = {
  "use_selected_items",
  "use_cursor_pos",
  "use_loop_time_range",
  "use_vert_scroll",
  "auto_del_ghost_tracks"
}

-- Default selected values
local view_options_selected = {} 

for _, opt in ipairs(view_options_names) do
    table.insert(view_options_selected, view_options[opt])
end

-- List of regions
local regions_list = {}

-- List of region names for menubox.
local region_names_list = {}

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

--??? Seems okay if my_function is declared before gui_function call.
--]==]

local function dh_update_textbox(elm)
    if GUI.elms[elm].curr_opt == 0 then return end
	local _, val = GUI.Val(elm)
	GUI.Val('tbx_ViewName', val)
end

-------------------------------  
------   RENAME VIEW    ------
-------------------------------
--zzrename

local function renameView(menubox)
    --dh_log("****  renameView  ****")
        
    local retval, new_name = dhtks.validate_name(GUI.Val("tbx_ViewName"))
    
    if not retval then return end

    ---- Check if new_name already exists ----
    
    local view_name_found = false
    
    for i, vname in ipairs(arrange_views_names) do
        if new_name == vname then
            view_name_found = true
            break
        end
    end
    
    local mbx_idx, mbx_name = GUI.Val(menubox)
              
    if view_name_found then	
        reaper.ShowMessageBox("View name already exists!\n", "Error", 0)
        return
    else
        -- If not name already exists - rename --
        arrange_views_names[mbx_idx] = new_name

        table.sort(arrange_views_names)

        GUI.elms.mbx_ArrangeView01.optarray = arrange_views_names
        GUI.elms.mbx_ArrangeView02.optarray = arrange_views_names
        
        -- Update arrange_views_table --
        
        arrange_views_table[new_name] = arrange_views_table[mbx_name]
        arrange_views_table[mbx_name] = nil
        
        -- Update menubox text --
        GUI.Val(menubox, dhtks.table_index_from_value(arrange_views_names, new_name))
        
        --GUI.redraw_z[11] = true
	    GUI.elms.mbx_ArrangeView01:redraw()
	    GUI.elms.mbx_ArrangeView02:redraw()
    end

end

-------------------------------  
------   CREATE VIEW    ------
-------------------------------
--zzcreateview  --zzadd  

-- new = true if "Add" button clicked.
-- new = false if by shift + clicking a "Go" button.
--       (overwriting is assumed.)

local function createView(new, menubox)

	--dh_log("**** create View function ****")

    local retval = false
    local view_name = ""
	local view_name_found = false
				
	-- If updating by right clicking GoTo button (new=false)
	-- there is no need to validate view_name.
	
	if new then
	
	    --dh_log(">***  Clicked on Add button ***")
	    
	    retval, view_name = dhtks.validate_name(GUI.Val("tbx_ViewName"))
	    
        if not retval then return end

		--  Check if view name already exists  --
        		
		for i = 1, #arrange_views_names do
		    if view_name == arrange_views_names[i] then
		        view_name_found = true
		        break
		    end
		    --dh_log("view name is: " .. arrange_views_names[i])
	    end
		 			
		if view_name_found then	
		
		    -- If name already exists --
		    
		    -- ask to overwrite	
			local retval = reaper.ShowMessageBox("View name \"" .. view_name .. "\" already exists! Do you want to overwrire it?\n", "Warning", 4)								
			if retval == 5 then -- 5 is no
				return
			end
			
		else	
		    -- If not name already exists --
		     
		    -- add to list
			table.insert(arrange_views_names, view_name)
			table.sort(arrange_views_names)
			--dh_log("> create: size of arrange_views_names is: <" .. tostring(#arrange_views_names) .. ">")

            --??? Is this reassignment necessary? Doesn"t hurt.
			GUI.elms.mbx_ArrangeView01.optarray = arrange_views_names
			GUI.elms.mbx_ArrangeView02.optarray = arrange_views_names
			
			--??? What about menubox display? Seems ok (redrawn).
			
		end
			
	else 
	    --dh_log(">*** Shift clicked on Go button ***")
        
        --!!! Menubox may be empty.
        -- Else it should have a good view name.
        -- This should return menubox.curr_opt and view_name.

        local mbx_idx = 0
        mbx_idx, view_name = GUI.Val(menubox)
       
        if mbx_val == 0 then
            reaper.ShowMessageBox("Attempting to update a non-existing view!\n", "Error", 0)
            return	    
        end
        
	end
	 
	--  We have a good name. Create a view  --
	
	-- If not overwriting make a new entry.
	-- When creating collect all view options.
	--dh_log("view name is: <" .. view_name .. ">")
		
	local new_view = {}
	
	-- Get start and end times --
	
	local start_time, end_time = reaper.GetSet_ArrangeView2(0, false, 0, 0)
	--dh_log("start_time is: " .. tostring(start_time) .. " ; end_time is: " .. tostring(end_time))
	new_view['start_time'] = start_time
	new_view['end_time'] = end_time	

	-- Get selected items --
	
	--[==[
	     ??? From reaper api:
	     Discouraged, because GetSelectedMediaItem can be 
	     inefficient if media items are added, rearranged, or deleted in between calls. 
	     Instead see CountMediaItems, GetMediaItem, IsMediaItemSelected.
	     !!! Seems to work fine.
	--]==]
	
	local sel_items_list = {}
	local r_sel_items_count = reaper.CountSelectedMediaItems(0)
	--dh_log("sel_items_count is: " .. tostring(r_sel_items_count))
	
	for i=0, r_sel_items_count -1 do
		local sel_item = reaper.GetSelectedMediaItem(0, i)
		--??? Should I validate?
		--boolean reaper.ValidatePtr2(ReaProject proj, identifier pointer, string ctypename)
		local retval, statechunk = reaper.GetItemStateChunk(sel_item,"",false)
		local iguid = statechunk:match("IGUID( .-)%c")
        
        if iguid ~= nil then
		    table.insert(sel_items_list, iguid)
		end
  	end	
  	
	new_view['sel_items'] = sel_items_list
	
	-- Get cursor position --
	
	local cursor_position = reaper.GetCursorPosition()
	new_view['cursor_position'] = cursor_position
	
	-- Get loop time range --
--zz0425 create view
	local loop_starttime, loop_endtime = reaper.GetSet_LoopTimeRange(false, true, 0, 0, false)
	new_view['loop_starttime'] = loop_starttime
	new_view['loop_endtime'] = loop_endtime
	
	-- Get First Selected track --
	
	local track_count = reaper.CountSelectedTracks2(0, false)
	
	if track_count > 0 then
		--for i = 0, track_count - 1 do
		--	local selected_track = reaper.GetSelectedTrack(0, i) -- i is selected track index
		--	local track_guid = reaper.GetTrackGUID(selected_track)
		--	dh_log("track_guid is: " .. track_guid)
		--end
		local selected_track = reaper.GetSelectedTrack(0, 0) -- get first selected track
		local track_guid = reaper.GetTrackGUID(selected_track)
		new_view['selected_track'] = track_guid	
	end

	-- Add view to table. Do this after all view parameters are set.		
	arrange_views_table[view_name] = new_view	
	
end --<createView>

-------------------------------  
------   DELETE VIEW    ------
-------------------------------
--zzdelete 
 
-- Delete view indicated in Textbox from arrange_views_table.
-- Delete references in arrange_ views_names.
-- Delete references in Menuboxes.
-- ??? Should I clear Textbox?

local function deleteView()

	--dh_log("**** deleteView ****")
	
	-- Abort if no saved views --
	if not(dhtks.keyed_table_length(arrange_views_table) > 0) then return end

    -- Get name from textbox --
    
    -- No need to sanitize view_name, it is only used for lookup.
    -- If Textbox was populated by selecting from a Menubox
    -- it should have a valid name, although it may have been altered.

	local view_name = GUI.Val('tbx_ViewName')
	--dh_log("view name from textbox is: <" .. view_name .. "n")

    -- Prompt before delete -- 
    
    -- This protects against accidental button clicks.
    
    local retval = reaper.ShowMessageBox("Attempting to delete view: " .. view_name .. "\nContinue?", "Confirm", 4)								
    
    if retval == 7 then   -- 6 is yes ; 7 is no
        return
    end

    -- If view exists delete it --
    
    local arr_view_found = false
    
    for k, v in pairs(arrange_views_table) do
        if k == view_name then
            arr_view_found = true
            arrange_views_table[view_name] = nil
            break
        end
    end

	-- Delete view_name from arrange_views_names --
    
    if arr_view_found then
    
        local newopt = 0
    
        for i = 1, #arrange_views_names do
            if view_name == arrange_views_names[i] then
                table.remove(arrange_views_names, i)
                --dh_log("view name is: " .. arrange_views_names[i])
                newopt = i
                break
            end

        end
    
        GUI.elms.mbx_ArrangeView01.optarray = arrange_views_names
        GUI.elms.mbx_ArrangeView02.optarray = arrange_views_names
        
        --!!! Need to update curr_opt(s) and display.
        if newopt > #arrange_views_names then newopt = #arrange_views_names end

        GUI.Val("mbx_ArrangeView01", newopt)
        GUI.Val("mbx_ArrangeView02", newopt)
    
    else
    
        reaper.ShowMessageBox("View name : " .. view_name ..  " not found!", "Confirm", 0)								
     
    end 

end --<deleteView>

-----------------------------------  
------  GO TO ARRANGE VIEW  ------
-----------------------------------  
--zzgoto   

-- Go to view that is indicated in accompanying Menubox.

local function goToArrangeView(menubox)

	--dh_log("**** goToArrangeView ****")

    -- Abort if no saved view to go to --
	if not(dhtks.keyed_table_length(arrange_views_table) > 0) then return end

    ---- Get name from menubox ----
    	
    -- Returns index of currently selected item.
    -- dh_Menubox.optarray may be empty.

    local mbx_idx, view_name = GUI.Val(menubox)
    
    if view_name == nil or view_name == " " or view_name == " " then 
        return 
    end
		
    ------  Get view  ------
    
    local view
    local arr_view_found = false
    
    -- If view exists - get it --
    	
	for k, v in pairs(arrange_views_table) do
		if k == view_name then
		    view = v
		    arr_view_found = true
		    break		
		end

	end

    -- If view name found but no corresponding view found --
	-- Prompt to remove reference then return.

	if not arr_view_found then 
	
	    local retval = reaper.ShowMessageBox("Arrange view : " .. view_name ..  " not found. \nDo you want to delete the reference?", "Confirm", 4)								
	    if retval == 6 then   -- 6 is yes; 7 is no

	        for i = 1, #arrange_views_names do
	            if view_name == arrange_views_names[i] then
	                table.remove(arrange_views_names, i)
	                GUI.elms.mbx_ArrangeView01.optarray = arrange_views_names
	                GUI.elms.mbx_ArrangeView02.optarray = arrange_views_names

	                break
	            end
	        end
	        
	    end
	    return	
	end
    
	----------------------------
	reaper.PreventUIRefresh(1)
	reaper.Undo_BeginBlock()	
	----------------------------

	-- Set start and end times --
	
	if view.start_time and view.end_time then
		reaper.GetSet_ArrangeView2(0, true, 0, 0, view.start_time, view.end_time)
	end

	-- Set cursor_position --

	if view_options.use_cursor_pos and view.cursor_position then
	    reaper.SetEditCurPos(view.cursor_position, false, false)	
    end

	-- Set loop time range --
--zz0425  goto	
    if view_options.use_loop_time_range and view.loop_starttime and view.loop_endtime then
	 	reaper.GetSet_LoopTimeRange(true, true, view.loop_starttime, view.loop_endtime, false)	
    end   
  	
	-- Deselect current media items --

    if view_options.use_selected_items then
		--dh_log("use_selected_items is: " .. tostring(view_options.use_selected_items))
		
        -- First deselect any current selected items --
		local r_sel_items_count = reaper.CountSelectedMediaItems(0)
		
		--dh_log("in if r_sel_items_count before deselect is: " .. tostring(r_sel_items_count))
		
		if (r_sel_items_count > 0) then
			for i=0, r_sel_items_count-1 do
				local r_sel_item = reaper.GetSelectedMediaItem(0, 0)
				reaper.SetMediaItemSelected(r_sel_item, false)
			end
		end
		
	    -- Set selected media items --
		-- For each entry in our list, iterate through reaper media items looking for match.
		-- Value is item guid.
		
		media_item_found = false
		local ghost_media_items = {}

		for si_idx, si_guid in ipairs(view.sel_items) do
							
		    for r_idx = 0, reaper.CountMediaItems(0) - 1 do
		        local media_item = reaper.GetMediaItem(0, r_idx)
				
			    if media_item then

				    local retval, statechunk = reaper.GetItemStateChunk(media_item,"",false)
				    statechunk = statechunk:match("IGUID( .-)%c")
		  	        if statechunk == si_guid then
		  			    
		  			    -- Get the index of the active take in this media item
    				    local itemTake = reaper.GetMediaItemInfo_Value(media_item, "I_CURTAKE");
    				
    				    -- Get pointer to active take in this media item
    				    local thisTake = reaper.GetMediaItemTake(media_item, itemTake);
    				
    				    -- Make sure current take in this item is not MIDI.
    			        -- because selecting MIDI item opens MIDI editor.
		  		        if reaper.TakeIsMIDI(thisTake) == false then
		  		            media_item_found = true
		  				    reaper.SetMediaItemSelected(media_item, true)
		  		        end
		  		        
		  		        break -- returns to for s_idx loop
		  	        end	

		  	    end --<if media_item>
		  	  
		    end --<for r_idx>
--zzghost
		    if media_item_found then 
		        media_item_found = false
		    else
		        track.insert(ghost_media_items, s_idx)
		    end

        end --<for s_idx>

        if #ghost_media_items > 0 then
        
            -- Alert --
		    local retval = 6
		    
            if snapshot_options.auto_del_ghost_tracks == false then
                local msg = 'One or more media items could not be found!\n' ..
                     'They were probably removed from project.\n' ..
                     'Do you want to remove their reference from the Snapshot?'
            
                retval = reaper.ShowMessageBox(msg, "Warning", 4)	-- retval 6 is yes							
            end
            
            if retval == 6 then
                for i, idx in ipairs(ghost_media_items) do
                    table.remove(view.sel_items, idx)
                end
            end
        end
         
    end --<if view.sel_items>
        
--zzsel  

    -- Set Selected track (and scroll to) --
        
    if view.selected_track and view.selected_track ~= "" then
        
        local r_track_found = false
    	local r_track_count = reaper.CountTracks(0)
    	
    	for i = 0, r_track_count - 1 do
    		local r_track = reaper.GetTrack(0, i)
    		local r_guid = reaper.GetTrackGUID(r_track)
    			
    		if view.selected_track == r_guid then
    		    --dh_log("selected_track_guid is: " .. selected_track_guid)
    		    r_track_found = true
    			reaper.SetOnlyTrackSelected(r_track)
    			
    			--!!! This works alright - not sure how.
    			-- Actually it breaks if the track is hidden, even if once again visible.
    
    			if view_options.use_vert_scroll then
    			    local tcpY = reaper.GetMediaTrackInfo_Value(r_track,'I_TCPY');
    			    --dh_log("selected_track_Y is: " .. tostring(tcpY))
    			    reaper.CSurf_OnScroll(0, math.ceil(tcpY/8));
    				
    			    -- Seems corrected when I add this in.
    			    reaper.Main_OnCommand(40193, 0)
    			end
    			
    			break
    			
    		end
    
    	end
    	
    --zzghost	
    
        if not r_track_found then
        
        	-- Alert --
        	local retval = 6
        	
        	if snapshot_options.auto_del_ghost_tracks == false then
        	    local msg = 'Track to be selected could not be found!\n' ..
        	          'It was probably removed from project.\n' ..
        	          'Do you want to remove its reference from the snapshot table?"'
        	
        	    retval = reaper.ShowMessageBox(msg, "Warning", 4)	-- retval 6 is yes							
        	end
        	
        	if retval == 6 then
        	    view.selected_track = ""
        	end
        	
        end
        
    end --<if view.selected_track ~= "">
    
	-- Set textbox value to view name --
	
	GUI.Val('tbx_ViewName', view_name)
	-----------------------------------------------------
  	reaper.Undo_EndBlock("Restore Tracks Visibility", -1)
  	reaper.UpdateArrange()
  	reaper.PreventUIRefresh(-1)
	-----------------------------------------------------
	
  	dhtks.return_focus_to_reaper()
 	
end --<goToArrangeView>

---------------------------------  
------  REGION FUNCTIONS  ------
---------------------------------  
--zzregions  

local function selectRegion()

	--dh_log("**** selectRegion ****")

	if #region_names_list > 0 then

		-- Menubox.Val returns index and name.
		local idx, reg_name = GUI.Val("mbx_Regions")
		--dh_log("region name index is: " .. tostring(idx) .. " ; " .. "region name is: " .. reg_name)
		
		if idx == 0 then return end
		
		local reg_id
		
		for k,v in pairs(regions_list) do
		    if k == reg_name then
		        reg_id = v
		        break
		    end
		end		
			
		local num_all, num_markers, num_regions = reaper.CountProjectMarkers(0)
		local region_found = false
		local retval, isrgn, start_time, end_time, name, markrgnindexnumber
   
		for i = 0, num_all - 1 do
		    retval, isrgn, start_time, end_time, name, markrgnindexnumber = reaper.EnumProjectMarkers2(0, i)
		    --dh_log("retval is " .. tostring(retval) .. " ; isrgn is " .. tostring(isrgn))
		    -- Get only region that matches reg_id.
		    if isrgn and (markrgnindexnumber == reg_id) then
		        --dh_log("markrgnindexnumber is: " .. tostring(markrgnindexnumber) .. " ; id is: " .. tostring(reg_id))
		        region_found = true		   	
		        break
		    end
		end
		
		dh_log("region select start time is : " .. tostring(start_time) .. " ; end time is : " .. tostring(end_time))
		
		if region_found then
			--dh_log("\nSelected region name is: " .. name)
			--dh_log("retval is: " .. tostring(retval))
			--dh_log("region start_time is: " .. tostring(start_time) .. " ; end_time is: " .. tostring(end_time))
			
			local display_factor = (end_time - start_time) * 0.06
			local adj_start_time = start_time - display_factor
			local adj_end_time = end_time + display_factor
			reaper.GetSet_ArrangeView2(0, true, 0, 0, adj_start_time, adj_end_time)
--zz0425  region
		    reaper.GetSet_LoopTimeRange(true, true, starttime, endtime, false)	
		else
			reaper.ShowMessageBox("Region not found!\n", "Error", 0)
			return
		end
	
	end
  	
  	dhtks.return_focus_to_reaper()
		
end --<selectRegion>

local function refreshRegionsList()

    --dh_log("**** refreshRegionsList ****")

 	region_names_list = {}

	local num_all, num_markers, num_regions = reaper.CountProjectMarkers(0)
	--dh_log("num_all is " .. tostring(num_all))
	--dh_log("num_regions is " .. tostring(num_regions))

	if num_regions > 0 then 
	
		-- Loop through all markers and regions.
		 
		for i = 0, num_all - 1 do
		    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers2(0, i)
		    
		    -- Get only regions (not markers) --
		    
		    if isrgn then
		        --dh_log("retval is " .. tostring(retval) .. " ; isrgn is " .. tostring(isrgn))
		        --dh_log("region name is " .. name)
		        --dh_log("markrgnindexnumber is " .. tostring(markrgnindexnumber))
		        table.insert(region_names_list, name)
		    
		        regions_list[name] = markrgnindexnumber
		    end
		
		end

		if #region_names_list > 0 then
			--dh_log("#region_names_list is " .. tostring(#region_names_list))
			
			table.sort(region_names_list)

			GUI.elms.mbx_Regions.optarray = region_names_list
			GUI.elms.mbx_Regions.curr_opt = 1
			
		end
		 
	end 
end --<refreshRegionsList>

--======================================
  ------   Element Functions   ------
--======================================
--zzelem 
 
-- Go to view 1. Shift<8>+click to update view. Alt<16>+click to rename. Ctl<4>

local function btn_Go_1_Click()
    if GUI.mouse.cap & 8 == 8 then        --Shift
	    createView(false, 'mbx_ArrangeView01')
	elseif GUI.mouse.cap & 16 == 16 then  --Alt
	    renameView('mbx_ArrangeView01')
	else
	    goToArrangeView('mbx_ArrangeView01')
	end
	--dhtks.return_focus_to_reaper()
end

-- Go to view 2. Shift<8>+click to update view. Alt<16>+click to rename. Ctl<4>

local function btn_Go_2_Click()
    if GUI.mouse.cap & 8 == 8 then       -- Shift
        createView(false, 'mbx_ArrangeView02')
    elseif GUI.mouse.cap & 16 == 16 then  --Alt
        renameView('mbx_ArrangeView02')
	else
	    goToArrangeView('mbx_ArrangeView02')
	end
	--dhtks.return_focus_to_reaper()
end

-- Toggles Main window expanded or not.
--zzmore
local function btn_MoreClick()
	if DHTK.window_settings.is_window_expanded then
		-- unexpand --
		GUI.elms.btn_More.caption = "+"
		DHTK.window_settings.is_window_expanded = false
		GUI.h = DHTK.s_APP_MIN_HEIGHT
	else
		-- expand --
		GUI.elms.btn_More.caption = "-"
		DHTK.window_settings.is_window_expanded = true
		GUI.h = DHTK.s_APP_EXP_HEIGHT	
	end
	GUI.resized = true

end

-- Opens Preferences window.

local function btn_MoreRightClick()
	GUI.h = DHTK.s_PREFS_HEIGHT
	GUI.resized = true
	DHTK.showPrefsWindow()
end

local function btn_AddViewClick()
	createView(true, nil)  -- true is new
	--dhtks.return_focus_to_reaper()	
end

local function btn_DeleteViewClick()
	deleteView()
	--dhtks.return_focus_to_reaper()
end

local function btn_SelectRegionClick()
	selectRegion()
	--dhtks.return_focus_to_reaper()
end

--======================================
  --------      ELEMENTS      --------
--======================================
--zzelem  --zzelms 
  
-- Probably should keep each menubox in it's own layer.

GUI.New("Frame1", "Frame", {
    z = 50,
    x = 0,
    y = 0,
    w = DHTK.APP_WIDTH,
    h = DHTK.APP_EXP_HEIGHT,
    shadow = false,
    fill = false,        -- Fill in the frame.Defaults to false.
    color = "elm_frame", -- Frame (and fill) color. Defaults to "elm_frame".
    bg = "elm_fill",     -- Color to be drawn underneath the text. Defaults to "wnd_bg",
                         -- but will use the frame's fill color instead if fill = true    
    round = 0,
    text = "",
    txt_indent = 0,
    txt_pad = 0,
    pad = 8, 
    font = "sans16",
    col_txt = "txt"
})

--------------------------------
--------    Top row    --------
--------------------------------
GUI.New("mbx_ArrangeView01", "dh_Menubox", {
    z = 31,
    x = 16, 
    y = 8, 
    w = 224, 
    h = 32, 
    caption = "",
    optarray = {},
    curr_opt = 0,
    font_a = "sans16",
    font_b = "sans24",
    col_txt = "txt2",
    col_cap = "txt",
    bg = "wnd_bg",
    pad = 4, 
    noarrow = false,
    align = 0
})
--zzbtn
GUI.New("btn_Go_1", "Button", {
    z = 32,
    x = 256, 
    y = 8, 
    w = 32, 
    h = 32, 
    caption = "Go",
    font = "sans22",
    col_txt = "txt",
    col_fill = "btn_face",	
    func = btn_Go_1_Click,
    --r_func = btn_Go_1_RightClick,
    --r_params = {} -- Must include if using r_func or script crashes.
})

GUI.New("btn_Go_2", "Button", {
    z = 33,
    x = 304, 
    y = 8, 
    w = 32, 
    h = 32, 
    caption = "Go",
    font = "sans22",
    col_txt = "txt",
    col_fill = "btn_face",	
    func = btn_Go_2_Click,
    --r_func = btn_Go_2_RightClick,
    --r_params = {} -- Must include if using r_func or script crashes.
})

GUI.New("mbx_ArrangeView02", "dh_Menubox", {
    z = 34,
    x = 352, 
    y = 8, 
    w = 224, 
    h = 32, 
    caption = "",
    optarray = {},
    curr_opt = 0,
    font_a = "sans16",
    font_b = "sans24",
    col_txt = "txt2",
    col_cap = "txt",
    bg = "wnd_bg",
    pad = 4, 
    noarrow = false,
    align = 0
})

GUI.New("btn_More", "Button", {
    z = 35,
    x = 592, 
    y = 8, 
    w = 32, 
    h = 32, 
    caption = "+",
    font = "sans32",
    col_txt = "txt",
    col_fill = "btn_face",	
    func = btn_MoreClick,
    r_func = btn_MoreRightClick,
    r_params = {} -- Must include if using r_func or script crashes.
})

--------------------------------
--------  Bottom row  --------
--------------------------------
--zzbtn
GUI.New("btn_AddView", "Button", {
    z = 36,
    x = 16, 
    y = 48, 
    w = 36, 
    h = 32, 
    caption = "Add",
    font = "sans22",
    col_txt = "txt",
    col_fill = "btn_face",	
    func = btn_AddViewClick
})

--!!! Keep this with its own z to prevent unnecessary 
-- redraws when textbox is focused.
GUI.New("tbx_ViewName", "Textbox", {
    z = 37,
    x = 66, 
    y = 48, 
    w = 224, 
    h = 32, 
    caption = "",
    font_b = "mono18",   --textbox needs mono font
    col_txt = "txt2",
    col_fill = "elm_frame"
})
--zzbtn
GUI.New("btn_DeleteView", "Button", {
    z = 38,
    x = 304, 
    y = 48, 
    w = 36, 
    h = 32, 
    caption = "Del",
    font = "sans22",
    col_txt = "txt",
    col_fill = "btn_face",	
    func = btn_DeleteViewClick
})
 
GUI.New("mbx_Regions", "dh_Menubox", {
    z = 39,
    x = 352, 
    y = 48, 
    w = 224, 
    h = 32, 
    caption = "",
    optarray = {},
    curr_opt = 0,
    font_a = "sans16",
    font_b = "sans24",
    col_txt = "txt2",
    col_cap = "txt",
    bg = "wnd_bg",
    pad = 4, 
    noarrow = false,
    align = 0
})

GUI.New("btn_SelectRegion", "Button", {
    z = 40,
    x = 592, 
    y = 48, 
    w = 32, 
    h = 32, 
    caption = "Go",
    font = "sans22",
    col_txt = "txt",
    col_fill = "btn_face",	
    func = btn_SelectRegionClick,
    r_func = refreshRegionsList,
    r_params = {} --!!! Must include if using r_func or script crashes.
})

------------------------------------
------   Options Section   ------ 
------------------------------------
-- This gets added to Preferences window. Watch those z layers.
--zzoptions 

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
    opts = view_options_names,
	--opts= {},
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
------   Tips Display   ------
--------------------------------
--zztips
-- There is some extra room at bottom of "Preferences" window. 
-- I used it to include some useful tips.
GUI.New("lbl_tip_01", "Label", 19, 18, 296, "Go button Click - go to view indicated by menubox.", false, "sans20", "txt", "elm_fill" )
GUI.New("lbl_tip_02", "Label", 19, 18, 316, "Go button Shift + Click - update view indicated by menubox.", false, "sans20", "txt", "elm_fill" )
GUI.New("lbl_tip_03", "Label", 19, 18, 336, "Go button Alt + Click - rename view with text in textbox.", false, "sans20", "txt", "elm_fill" )

--======================================
  ------   Method Overrides  ------
--======================================
--zzoverrides  
-- Use to add additional functionality to GUI functions.

--dh_log("**** Method Overrides ****")

function GUI.elms.mbx_ArrangeView01:onmouseup()
	-- Run the element's normal method
	GUI.dh_Menubox.onmouseup(self)
	-- Add our code
	dh_update_textbox('mbx_ArrangeView01')
end

function GUI.elms.mbx_ArrangeView02:onmouseup()
	-- Run the element's normal method
	GUI.dh_Menubox.onmouseup(self)
	-- Add our code
	dh_update_textbox('mbx_ArrangeView02')
end

--zzopt 
-- Update view_options --
function GUI.elms.chkl_Options:onmouseup()

	-- Run the element's normal method --
	GUI.dh_Checklist.onmouseup(self)
		
	-- Add our code --
    -- Update view_options --
    view_options[view_options_names[self.optindex]] = self.optsel[self.optindex]
    	
end

--======================================
  ------      SCRIPT FLOW      ------
--======================================
--zzflow
--dh_log("**** SCRIPT FLOW ****")

--[===[
  Start script:
    Store reference to init project.
    Initialize and position window.
      Get window settings from current project ext state.
    Populate lists.
      Get data from current project ext state.
        --Early version didn't save arrange_views_names but
        --built it from arrange_views_table.
        --Check if arrange_views_names in ext state.
      Get views options from current project ext state. 
  Change project tab:
    Save views data to previous project ext state (only if list has data).
    Save views options to previous project ext state.
    Clear tables and repopulate with current project ext state.
  Exit script:
    Save window settings to current project ext state.
    Save views data to current project ext state.
    Save views options to current project ext state.
--]===]

--======================================
  ------   GET PROJECT DATA   ------    
--======================================
--zzpopulate

-- Update lists on init and when changing tabs.
-- Get data from current project external state.
-- Will be building views_names from views_table.

local function populateLists(proj)

    --dh_log("--------------------------")
    --dh_log("****  POPULATE LISTS  ****")
    --dh_log("--------------------------")
    
    --<<< testing
	local projname = reaper.GetProjectName(proj)
	--dh_log(" > projname: " .. projname)
    -->>>
    
    --------------------------------------
    ------ Get arrange_views_table ------
    --------------------------------------
    arrange_views_names = {} -- Used for display in menuboxes
    arrange_views_table = {} -- Actual view data
    
    local has_views = false
  	local temp_views_table = nil
  	local json_string = ""
  	    	 
    -- retval = 0 if it extstate doesn't exist
    -- retval = 1 if extstata has any value including ([], "", " ")
    -- If retval = 0 then json_decode throws error.

    local retval, ret_string = reaper.GetProjExtState(0, 'dh_ArrangeViews', 'arrange_views')
    
    --dh_log("> populate: json_string of arrange_views_table is\n " .. ret_string  .. "\n")
 
    if (retval == 1) then
        
        -- Decode ret_string --
        
        if ret_string and ret_string ~= "" then
            temp_views_table = json.decode(ret_string)  -- should return Lua table
        end
    
        if type(temp_views_table) == "table" then 
    
            -- Remove any key(s) that are " ".
            --!!! Probably don't need this here - doesn't hurt.
            
            for k, v in pairs(temp_views_table) do
                if k == " " or k == "" or type(k) ~= "string" then
                    temp_views_table[k] = nil
                end
            end

            if dhtks.keyed_table_length(temp_views_table) > 0 then
                has_views = true
                arrange_views_table = temp_views_table
            end
          
        end

    end -- <retval arrange_views>
    
    if has_views then
    
        --dh_log(">** if HAS_arrange_views_table **")
        
        ---------------------------------------------------------
        -- Build arrange_views_names from arrange_views_table --
        ---------------------------------------------------------
        --dh_log("-- Building arrange_views_names from arrange_views_table --")
        
        for k, v in pairs(arrange_views_table) do
            --dh_log("> build table view name is: " .. k)
            table.insert(arrange_views_names, k)
        end
        
        table.sort(arrange_views_names)
        
        GUI.elms.mbx_ArrangeView01.optarray = arrange_views_names
        GUI.elms.mbx_ArrangeView02.optarray = arrange_views_names
      
        --------------------------------
        --     Get current views     --
        --------------------------------
	    --dh_log("---- Get current views ----")
        
        retval, ret_string = reaper.GetProjExtState(0, 'dh_ArrangeViews', 'current_views')

        if retval == 1 then 
        
            local current_views = json.decode(ret_string)
            if ret_string then
            
                if type(current_views) == "table" and dhtks.keyed_table_length(current_views) == 2 then
                    if current_views[1] == 0 then current_views[1] = 1 end
                    if current_views[2] == 0 then current_views[2] = 1 end
                    GUI.Val("mbx_ArrangeView01", current_views[1])
                    GUI.Val("mbx_ArrangeView02", current_views[2])
                end
            
            end
        
        end
          
    end -- <has_views>
     
    -- If retval==0, no table, or empty table.
        	
    if not has_views then
    	
   	    --dh_log("> if NOT has_arrange_views_table")
        
        GUI.elms.mbx_ArrangeView01.optarray = arrange_views_names
        GUI.elms.mbx_ArrangeView02.optarray = arrange_views_names
        GUI.Val("mbx_ArrangeView01", 0)	  
        GUI.Val("mbx_ArrangeView02", 0)	  
        
    end

    -------------------------------
    ----   Get view options   ----
    -------------------------------
    -- If unsucessful, view_options will keep previous values.
    -- Otherwise it will update "chkl_Options" from bool_table 

    retval, ret_string = reaper.GetProjExtState(0, "dh_ArrangeViews", "view_options")

    --dh_log("----   Get view options   ----")

    if (retval == 1) then
    
    	local opts = json.decode(ret_string)  -- should return Lua table 

        if type(opts) == "table" and dhtks.keyed_table_length(opts) > 0 then
            view_options = opts
            --dh_log("> SIZE of view_options: " .. dhtks.keyed_table_length(view_options))
            
            -- Update checklist selected --
            
            local bool_table = {}
            
            for _, opt in ipairs(view_options_names) do
                table.insert(bool_table, view_options[opt])
            end
                    
            GUI.Val('chkl_Options', bool_table)

        end
    end
    
    --xxx
    refreshRegionsList()

    -- Get rid of json string when done loading.
    json_string = nil
    	 
end --<populateLists>

--======================================
  ------  SAVE PROJ EXT STATE  ------    
--======================================
--zzsave
-- Save ext state on script exit and on project tab change.

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

local function saveProjExtState(proj)

    --dh_log("-------------------------------")
    --dh_log("****  SAVE PROJ EXT STATE  ****")
    --dh_log("-------------------------------")
    
    --<<< testing
    --local projname = reaper.GetProjectName(projname)
    --dh_log("> saveProjExtState projname: " .. projname)
    -->>>
    
    local json_string = ""
    local has_table = false
    
    ----  Save views table  ----

    -- arrange_views_table should not have any empty keys.
    -- But if somehow possible this happens:
 
    ---- Remove item(s) with empty keys ----
    -- Type of arrange_views_table should always be "table" by design.
    --!!! Could probably use arrange_views_name instead.
    
    if type(arrange_views_table) == "table" then 
        for k, v in pairs(arrange_views_table) do
            --dh_log("> arrange_views_table key: <" .. k .. ">")
            --dh_log("> arrange_views_table key type is: <" .. type(k) .. ">")
            if k == " " or k == "" then
                arrange_views_table[k] = nil
            end
        end
    end

    -- When starting script or changing tabs arrange_views_table = {}
    -- Therefore after encoding json_string is at least = {}.
    -- Check it anyway? 

    ---- Encode arrange_views_table ----
       
    -- If, for some reason, arrange_views_table isn't table
    -- then json_string is "".    
        
    if (type(arrange_views_table) == "table") then
        if dhtks.keyed_table_length(arrange_views_table) > 0 then
            has_table = true
        end
        json_string = json.encode(arrange_views_table)
    end

    --dh_log("> saving ext: json_string of arrange_views_table is\n " .. json_string  .. "\n")
    reaper.SetProjExtState(proj, "dh_ArrangeViews", "arrange_views", json_string)

    ---- Save current views ----

    if has_table then
        local current_views = {}
        current_views[1], _ = GUI.Val('mbx_ArrangeView01')
        current_views[2], _ = GUI.Val('mbx_ArrangeView02')
        json_string = json.encode(current_views)
    else
        json_string = ""
    end
    
    --dh_log("> encoded current_views json_string: <" .. json_string .. ">") 

    reaper.SetProjExtState(proj, 'dh_ArrangeViews', 'current_views', json_string)
    
    ---- Save view options ----
    
    json_string = json.encode(view_options)
    reaper.SetProjExtState(proj, 'dh_ArrangeViews', 'view_options', json_string)
    
    json_string = nil
    
end  --<saveProjExtState>

--======================================
  --------      EXIT      --------
--======================================
--zzexit
--dh_log("**** exit section ****")

-- Code to execute before window closes, such as saving states and window position.
-- projExtState is saved to section name DHTK.EXT_STATE_NAME.

local function Exit()
	--dh_log("**** EXITING: ****")
	
    DHTK.saveWindowSettings()
    
    --xxx Save current project ext state.
    saveProjExtState(0)
    
end --<EXIT>

-- Calls Exit when script is ending.
reaper.atexit(Exit)

--======================================
  ------  Script Initialize  ------
--======================================
--zzinit  
--dh_log("**** SCRIPT INIT ****")

----------------------------------------
--  GUI Elements Initialization
--  Done here - after element creation
----------------------------------------
-- Set checklist options default values
--GUI.elms.chkl_Options.optarray = view_options_names
GUI.Val("chkl_Options", view_options_selected)

if DHTK.window_settings.is_window_expanded == false then
    GUI.elms.btn_More.caption = "+"
else
    GUI.elms.btn_More.caption = "-"
end

-- Need to call this here to scale both GUI elms and user elms.
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
--[==[
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
    
        proj_name_before_change = curr_proj_name
    
        --dh_log("-----------------------------")
        --dh_log("#### -- CHANGING TABS -- ####")
        --dh_log("-----------------------------")
        --dh_log(curr_proj_name)
        
        --xxx
        saveProjExtState(proj_before_change)
    
        proj_before_change = curr_proj
        
        --xxx
        populateLists(curr_proj)
    
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