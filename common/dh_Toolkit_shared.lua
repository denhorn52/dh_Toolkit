--dh_Toolkit_shared.lua
-- version 1.0
-- Author: Dennis R. Horn
-- Date: 2025-03-30

-------------------------------------------------
local dh_Toolkit_shared = {}

dh_Toolkit_shared.main_hwnd = reaper.BR_Win32_GetMainHwnd()

function dh_Toolkit_shared.return_focus_to_reaper()
  	if dh_Toolkit_shared.main_hwnd then 
  	    reaper.BR_Win32_SetFocus(dh_Toolkit_shared.main_hwnd) 
  	end
end

-- @param t: keyed table
function dh_Toolkit_shared.keyed_table_length(t) 
  local count = 0
  for key, _ in pairs(t) do
    count = count + 1
  end  
  return count        
end

-- Get index from indexed table using value.
-- @param tbl: indexed table
-- @param val: number - value to search for
-- returns 0 if table length is 0.
-- returns index number if val found.
-- else returns 1.

function dh_Toolkit_shared.table_index_from_value(tbl, val)
    if #tbl == 0 then return 0 end
    for i, v in ipairs(tbl) do
        if v == val then return i end
    end
    return 1
end

-- Normalize metric - converts scaled value to 1.00 scale.
-- @param num: number - element metric to be normalized.
-- @param scale: number - current scale of GUI. 
-- returns normalized metric.

function dh_Toolkit_shared.normalize_metric(num, scale)
  return math.floor((num / prevscale) + 0.5)
end

-- Scale metric
-- @param num: number - element metric to be scaled.
-- @param scale: number - new scale of GUI.
-- returns scaled metric.

function dh_Toolkit_shared.scale_metric(num, scale)
    return math.floor((num * scale) + 0.5)
end

-- Normalize and Scale metric
-- Previously scaled number must be normalized before it is rescaled.
-- @param num: number  current scaled value of a metric.
-- @param prevscale: number - current scale of GUI.
-- @param newscale: number - new scale of GUI.

function dh_Toolkit_shared.norm_scale_metric(num, prevscale, newscale)
    --dh_log("shared.norm_scale_metric num is: " .. tostring(num) .. "\n")
    --dh_log("shared.norm_scale_metric prevscale is: " .. tostring(prevscale) .. "\n")
    --dh_log("shared.norm_scale_metric newscale is: " .. tostring(newscale) .. "\n")
    -- return to 1.00 scale --
    local m = math.floor((num / prevscale) + 0.5)
    -- calculate new value --
    return math.floor((m * newscale) + 0.5)
end

----------------------------------- 
------    SCALE  ELEMENTS   ------
-----------------------------------
-- This uses reference to GUI. OK? Appears so.

-- Scale elements.
-- Iterates GUI elements and rescales them to new scale.
-- @param prevscale: number - current scale of GUI.
-- @param newscale: number - new scale of GUI.

function dh_Toolkit_shared.scale_elements(prevscale, newscale)
    
    for elmname, _ in pairs(GUI.elms) do
        -- Will need to check each metric.
        if GUI.elms[elmname].x then 
            GUI.elms[elmname].x = dh_Toolkit_shared.norm_scale_metric(GUI.elms[elmname].x, prevscale, newscale)
        end
        if GUI.elms[elmname].y then 
            GUI.elms[elmname].y = dh_Toolkit_shared.norm_scale_metric(GUI.elms[elmname].y, prevscale, newscale)
        end
        if GUI.elms[elmname].w then 
            GUI.elms[elmname].w = dh_Toolkit_shared.norm_scale_metric(GUI.elms[elmname].w, prevscale, newscale)
            --dh_log("# elmname is: " .. elmname .. " : width is: " .. GUI.elms[elmname].w .. "\n")
        end
        if GUI.elms[elmname].h then 
            GUI.elms[elmname].h = dh_Toolkit_shared.norm_scale_metric(GUI.elms[elmname].h, prevscale, newscale)
        end
        if GUI.elms[elmname].tab_h then 
            GUI.elms[elmname].tab_h = dh_Toolkit_shared.norm_scale_metric(GUI.elms[elmname].tab_h, prevscale, newscale)
        end        
        if GUI.elms[elmname].round then 
            GUI.elms[elmname].round = dh_Toolkit_shared.norm_scale_metric(GUI.elms[elmname].round, prevscale, newscale)
        end
        if GUI.elms[elmname].pad then 
            GUI.elms[elmname].pad = dh_Toolkit_shared.norm_scale_metric(GUI.elms[elmname].pad, prevscale, newscale)
        end
        if GUI.elms[elmname].opt_size then 
            GUI.elms[elmname].opt_size = dh_Toolkit_shared.norm_scale_metric(GUI.elms[elmname].opt_size, prevscale, newscale)
        end
        if GUI.elms[elmname].txt_indent then 
            GUI.elms[elmname].txt_indent = dh_Toolkit_shared.norm_scale_metric(GUI.elms[elmname].txt_indent, prevscale, newscale)
        end
        if GUI.elms[elmname].txt_pad then 
            GUI.elms[elmname].txt_pad = dh_Toolkit_shared.norm_scale_metric(GUI.elms[elmname].txt_pad, prevscale, newscale)
        end
        if GUI.elms[elmname].border_width then 
            GUI.elms[elmname].border_width = dh_Toolkit_shared.norm_scale_metric(GUI.elms[elmname].border_width, prevscale, newscale)
        end
        if GUI.elms[elmname].radius then 
            GUI.elms[elmname].radius = dh_Toolkit_shared.norm_scale_metric(GUI.elms[elmname].radius, prevscale, newscale)
        end
    end

end --<scale_elements>

----------------------------------- 
----  VALIDATE  NAME  ----
-----------------------------------

-- Validate name.
-- Performs certain validation procedures on a string.
-- @param name: string - string to be validated.
-- returns success, validated string

function dh_Toolkit_shared.validate_name(name, show_msg)

    local show_msg = show_msg or true

    -- Must have at least one alphanumeric char --
    
    local test_str = string.match(name, "%w")
    
    if (test_str == nil) or (#name == 0)then
        if show_msg then reaper.ShowMessageBox("Proposed name is invalid!\n", "Error", 0) end  
        return false, ""
    end
    
    ---- Strip leading and trailing whitespace ----
    
    --s:match"^%s*(.*)" leading
    --s:match"^(.*%S)%s*$" trailing
    --s:match"^()%s*$" and "" or s:match"^%s*(.*%S)" crashes
    
    name = name:match"^%s*(.*)"
    name = name:match"^(.*%S)%s*$"
    
    if name == nil or name == "" then
        dh_log("name after trim is nil or empty\n")
        if show_msg then reaper.ShowMessageBox("Proposed name is invalid!\n", "Error", 0) end
        return false, ""
    end
    
    ---- Clean up and verify snapshot name ----
      
	-- Replace spaces with underscores.
	name = string.gsub(name, " ", "_")
	
	--[==[ 
	    !!! Allowed characters: alphanumeric chars, _, -, $, &, and +.	
	    [%a all letters, %d 0-9, %s whitespace, %w alphanumeric,%g all printable chars, ^ complement of set]
	    I find that in pattern matching set I have to escape(%)_ and -, otherwise sometimes it works, sometimes not.)  
	--]==]
	
	local chr = ""

	for i = 1, #name do
		 chr = name:sub(i,i)
		 --dh_log(chr .. " ")
		 chr = string.match(chr, "[%w%_%-%+%&%$]")
		 if chr == nil then
			 if show_msg then reaper.ShowMessageBox("Proposed name is invalid!\n", "Error", 0) end
			 return false, ""
		 end
	end

    return true, name
    
end --<validate_name>

return dh_Toolkit_shared




