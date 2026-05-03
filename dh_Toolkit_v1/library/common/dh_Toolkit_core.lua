--dh_Toolkit_core.lua
-- version 1.0
-- Author: Dennis R. Horn
-- Date: 20260330

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

-- A module encapsulating of all functionality pertaining 
-- to theming and scaling of scripts using the Lokasenna GUI.
-- Also saving and fetching pertinent window_settings. 
-- This includes a GUI Preferences window to change such settings.
-- Preferences window provides an optional option box which
-- may be utilized for external script specific options.

------------------------------------------------------------
--CHANGELOG:

-- 20260116: Added color functions (used for nighlighting).

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
-- Some things exposed only because they're needed by dh_ThemeDesigner or dh_GUI_Builder.

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

-- Set to false if a script implements its own handling as with dh_GUI_Builder.
DHTK.USE_DHTK_PREFS = true

--[===[ 
Moved these to DHTK.init() as they are not required by all scripts.
-- z-layers used by "Preferences" window.
-- Made public so external script can add other layers by appending to this list.
-- Layer 485 - 489 are already available for external scripts.
-- Can add more if necessary. Must be outside of previous range.

DHTK.PREFS_LAYERS = {485,486,487,488,489,490,491,492,493,494,495,496,497,498,499,500}

-- Store any visible layers before hiding them when Preference window is opened.
DHTK.layers_to_restore = {}

-- Layer used for "user_themes" display. This layer gets its visibility toggled.
DHTK.USER_THEMES_DISPLAY_LAYER = 490
--]===]

DHTK.window_settings = {
  left = 0,
  top = 0,
  scale = "1.00",    
  theme = "Default",
  user_theme = nil,
  font_scale = "1.00",
  use_outlines = false,
  frame_thk = 2,
  is_window_expanded = false, -- This is used for multiple window height scripts.
}

DHTK.APP_SCALE_FACTORS = {
  "0.75",
  "0.90",   
  "1.00",
  "1.10",  
  "1.25",     
  "1.50", 
  "2.00"
}

DHTK.APP_SCALE = 1

DHTK.FONT_SCALE_FACTORS = {
  "0.80", 
  "0.90",
  "0.95",  
  "1.00",
  "1.05",       
  "1.10", 
  "1.20"
}

-- Expand available font set.
local new_fonts = GUI.get_OS_fonts()

GUI.fonts[1] = {new_fonts.sans, 32}
GUI.fonts[2] = {new_fonts.sans, 20}
GUI.fonts[3] = {new_fonts.sans, 16}
GUI.fonts[4] = {new_fonts.sans, 16}
GUI.fonts["monospace"] = {new_fonts.mono, 14}
GUI.fonts["version"] = {new_fonts.sans, 12}
            
GUI.fonts["sans14"] = {new_fonts.sans, 14}
GUI.fonts["sans16"] = {new_fonts.sans, 16}
GUI.fonts["sans18"] = {new_fonts.sans, 18}
GUI.fonts["sans20"] = {new_fonts.sans, 20}
GUI.fonts["sans22"] = {new_fonts.sans, 22}
GUI.fonts["sans24"] = {new_fonts.sans, 24}
GUI.fonts["sans26"] = {new_fonts.sans, 26}
GUI.fonts["sans28"] = {new_fonts.sans, 28}
GUI.fonts["sans32"] = {new_fonts.sans, 32}

GUI.fonts["mono14"] = {new_fonts.mono, 14}
GUI.fonts["mono16"] = {new_fonts.mono, 16}
GUI.fonts["mono18"] = {new_fonts.mono, 18}
GUI.fonts["mono20"] = {new_fonts.mono, 20}
GUI.fonts["mono22"] = {new_fonts.mono, 22}
GUI.fonts["mono24"] = {new_fonts.mono, 24}
GUI.fonts["mono26"] = {new_fonts.mono, 26}
GUI.fonts["mono28"] = {new_fonts.mono, 28}
GUI.fonts["mono32"] = {new_fonts.mono, 32}

-- Need to maintain the default sizes as reference for scaling.
local  DEFAULT_FONT_SIZES = {
    [1] = 32,
    [2] = 20,
    [3] = 16,
    [4] = 16,
    ["monospace"] = 14,
    ["version"] = 10,
    
    ["sans14"] = 14,
    ["sans16"] = 16,
    ["sans18"] = 18,
    ["sans20"] = 20,
    ["sans22"] = 22,
    ["sans24"] = 24,
    ["sans26"] = 26,    
    ["sans28"] = 28,
    ["sans32"] = 32,
    
    ["mono14"] = 14,
    ["mono16"] = 16,
    ["mono18"] = 18,
    ["mono20"] = 20,
    ["mono22"] = 22,
    ["mono24"] = 24,
    ["mono26"] = 26,    
    ["mono28"] = 28,
    ["mono32"] = 32,

}

-- Populated in getUserThemes. Make public for Theme Designer.
DHTK.USER_THEMES = {}

-- For menubox display. 
-- Populated before element creation (in "Window Settings")
-- Make public for Theme Designer.
DHTK.USER_THEME_NAMES = {}

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
        --GUI.Msg("json_string in dh_Toolkit_prefs getWindowSettings is\n " .. json_string  .. "\n")
        
        local saved_settings = json.decode(json_string)
        
        if saved_settings.left then DHTK.window_settings.left = saved_settings.left end
        if saved_settings.top then DHTK.window_settings.top = saved_settings.top end
        --GUI.Msg("> APP_SCALE_FACTORS is: " .. tostring(DHTK.APP_SCALE_FACTORS[1]))
        
        if saved_settings.scale then
            for _, v in ipairs(DHTK.APP_SCALE_FACTORS) do
                if saved_settings.scale == v then
                    DHTK.window_settings.scale = saved_settings.scale
                    DHTK.APP_SCALE = tonumber(v)
                    break
                end
            end
        end
        
        if saved_settings.font_scale then
            for _, v in ipairs(DHTK.FONT_SCALE_FACTORS) do
                if saved_settings.font_scale == v then
                    DHTK.window_settings.font_scale = saved_settings.font_scale
                    break
                end
            end
        end

        if saved_settings.use_outlines then DHTK.window_settings.use_outlines = saved_settings.use_outlines end
       
        if saved_settings.frame_thk then DHTK.window_settings.frame_thk = saved_settings.frame_thk end
        
        --GUI.Msg("\n#  getWindowSettings DHTK.window_settings.use_outlines : " .. tostring(DHTK.window_settings.use_outlines))

        -- If App uses changing window heights get state.
        if saved_settings.is_window_expanded then 
            DHTK.window_settings.is_window_expanded = saved_settings.is_window_expanded 
        end
        
        if saved_settings.theme then DHTK.window_settings.theme = saved_settings.theme end
        if saved_settings.user_theme then DHTK.window_settings.user_theme = saved_settings.user_theme end

    end
end

DHTK.saveWindowSettings = function ()

    local section_name = DHTK.EXT_STATE_NAME

	-- Save window settings --
	local _, cur_x, cur_y = gfx.dock(-1, 0, 0, 0, 0)
	DHTK.window_settings.left = cur_x
	DHTK.window_settings.top = cur_y

    local json_string = json.encode(DHTK.window_settings)
	--GUI.Msg("json_string at exit is\n " .. json_string  .. "\n")
	reaper.SetExtState(section_name, 'window_settings', json_string, true)

    -- No longer need json_string. Maybe unnecessary as it is local.    
	json_string = nil

end 

----------------------------
----      THEMES      ----
----------------------------
--zzthemes  
-- Fetch user themes.
-- Stored in dh_Toolkit ext state so all scripts have access.
-- Called when script is loading.

local function getUserThemes()

    --GUI.Msg("**** in getUserThemes ****")
             
    if reaper.HasExtState("dh_Toolkit", "user-themes") then
    
    --xxx TESTING: Mimic no saved ext state.
    --if reaper.HasExtState("dh_Toolkit", "user-themes-test") then    
    
        --GUI.Msg("     getUserThemes extstate has user-themes****")
    
        --xxx TESTING: Mimic no extstate.
        --goto skip
        
        json_string = reaper.GetExtState("dh_Toolkit", "user-themes")
        
        fetched_themes = json.decode(json_string)
        
        if type(fetched_themes) == "table" and
            DHTK.hash_table_length(fetched_themes) > 0 then
            DHTK.USER_THEMES = fetched_themes
          
            for name, _ in pairs(DHTK.USER_THEMES) do
                table.insert(DHTK.USER_THEME_NAMES, name)
                table.sort(DHTK.USER_THEME_NAMES)
            end
                   
        end
        
        --xxx TESTING: Mimic no extstate.
        --::skip::
    end
    
--zzz

    local user_theme_name = DHTK.window_settings.user_theme     

    --[-[ xxx TESTING: 
    --GUI.Msg("     getUserThemes #DHTK.USER_THEME_NAMES : " .. #DHTK.USER_THEME_NAMES) 
    -- Mimic invalid user theme name.
    --user_theme_name = "Magenta-4xyz"
    -- Mimic no saved user themes.
    --user_theme_name = nil
    -- Mimic.    
    --DHTK.window_settings.theme = "Default"
    --GUI.Msg("     getUserThemes window_settings.user_theme : " .. (user_theme_name or 'nil'))                
    --]=] 
                 
    if DHTK.window_settings.theme == "User" then

        -- If not a valid user theme.
        
        if not DHTK.USER_THEMES[user_theme_name] then
            
            --GUI.Msg(" if not DHTK.USER_THEMES[user_theme_name]") 
            --GUI.Msg("  getUserThemes window_settings.user_theme : " .. (user_theme_name or 'nil'))        
            --GUI.Msg("  getUserThemes  user-theme :\n " .. user_theme_name .. " \ndoes not exist!\nLoading Default theme.")        
                             
            reaper.MB("User theme: " .. (user_theme_name or 'nil') .. " : not found!\nLoading Default theme.", "Whoops!", 0)                             
        
            DHTK.window_settings.theme = "Default"
            DHTK.window_settings.user_theme = nil

            dhth.set_theme(dhth.DH_THEMES["Default"], false)
        else
            --GUI.Msg(" else not DHTK.USER_THEMES[user_theme_name]")         
            -- Should set to USER THEME if exists.
            dhth.set_theme(DHTK.USER_THEMES[user_theme_name], false)
        end
        
    else
        -- Not "User" theme.
        
        -- This should only happen on a script's first run.
        if not dhth.DH_THEMES[DHTK.window_settings.theme] then
            DHTK.window_settings.theme = "Default"
        end
        --GUI.Msg(" else set dh theme")             
        -- DH THEME --
        dhth.set_theme(dhth.DH_THEMES[DHTK.window_settings.theme], false)
    end

end

----------------------------------
------   MISC  FUNCTIONS   ------
----------------------------------

DHTK.main_hwnd = reaper.BR_Win32_GetMainHwnd()

DHTK.return_focus_to_reaper = function ()
  	if DHTK.main_hwnd then 
  	    reaper.BR_Win32_SetFocus(DHTK.main_hwnd) 
  	end
end

-- Get the length of a hash table.
-- @param t: keyed table
-- returns integer: amount of items

DHTK.hash_table_length = function (t) 
  local count = 0
  for key, _ in pairs(t) do
    count = count + 1
  end  
  return count        
end

-- Get index from indexed table using value.
-- @param tbl: indexed table
-- @param val: number - value to search for
-- returns 0 if table length is 0 or value not found.
-- returns index number if val found.
-- else returns 1.

DHTK.table_index_from_value = function (tbl, val)
    if #tbl == 0 then return 0 end
    for i, v in ipairs(tbl) do
        if v == val then return i end
    end
    return 0
end

-- Validate name.
-- Performs certain validation procedures on a string.
-- @param name: string - string to be validated.
-- returns success, validated string

DHTK.validate_name = function (name, show_msg)

    local show_msg = show_msg or true

    -- Must have at least one alphanumeric char --
    
    local test_str = string.match(name, "%w")
    
    if (test_str == nil) or (#name == 0)then
        if show_msg then reaper.ShowMessageBox("Proposed name is invalid!\n", "Error", 0) end  
        return false, ""
    end
    
    -- Strip leading and trailing whitespace --
    
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
    
    -- Clean up and verify snapshot name --
      
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

----------------------------------
------   COLOR  FUNCTIONS   ------
----------------------------------
--zzcolor
--[==[
 * Get hilite colors.
 * @param color: GUI color name or table {r,g,b[,a]}
 * @param enhance: If true increases contrast. 
 * if invalid will use "wnd_bg"
 * Converts r,g,b to hue,sat,lum
 * Calculates new lum value to lighten/darken color.
 * Converts adjusted color back to r,g,b. 
 * returns: adjusted colors, and modifier values.
--]==] 

DHTK.get_hilite_colors = function (color, enhance)
    --GUI.Msg("\n# get_hilite_colors")    
    local r,g,b,a = 1,1,1,1
    
    if type(color) == "string" then
        --GUI.Msg("  input colors : " .. color)    
        if not GUI.colors[color] then
            color = "wnd_bg"
        end
        --GUI.Msg("\n#  color is : " .. color)        
        r,g,b,a = table.unpack(GUI.colors[color])
    elseif type(color) == "table" then
        r,g,b,a = table.unpack(color)
    end
    
    local hue, sat, lum, a = DHTK.rgb2hsl(r, g, b, a)
    
    --GUI.Msg("\n   r is : " .. tostring(r))
    --GUI.Msg("   g is : " .. tostring(g))
    --GUI.Msg("   b is : " .. tostring(b))
    --GUI.Msg("   hue is : " .. tostring(hue))               
    --GUI.Msg("   sat is : " .. tostring(sat))
    --GUI.Msg("   lum is : " .. tostring(lum))        
    
    -- modifiers
    local mll, mhl = 0, 0
    
    local adjmin = 0.15
    local adjmax = 0.30
            
    local min_v, max_v = 0.25, 0.92
    --local min_v, max_v = 0.35, 0.86    
        
    local xtra = enhance and 1.5 or 1

    local mod = (adjmin * (1 - (lum + min_v))) * xtra     

    if lum > max_v then  -- darken darken
             
        --GUI.Msg("\n  -- [ darken darken ] ")

        -- modify using sat or lum.
        mll = lum - (2 * adjmin) - mod
        mhl = lum - (adjmin + mod)
    
    elseif lum <= max_v and lum >= min_v then
    
        --GUI.Msg("\n  -- [ darken lighten ] ")

        -- lum is above min_v but below threshhold
        --   so only darken by 1/2 lum
      
        mll = lum - (adjmin * xtra)
        if mll < (2 * adjmin) then
            mll = lum / 2
        end
        
        -- lum is below min_v but above threshhold
        --   so only lighten by 1/2 (1 - lum)

        mhl = lum + (adjmin * xtra)
                
        -- Some highlights too bright with high lum. Modify.
        
        if mhl > 1 - (2 * (adjmin)) then
            --mhl = lum + ((1 - lum) / 2)
            local datum = adjmin * 2
            local dif = 1 - lum
            --    0.85 +  0.075   *  0.50
            mhl = lum + (dif / 2) * (dif / datum)
        end
        
        
    elseif lum < min_v then  -- lighten lighten
    
        --GUI.Msg("\n  -- [ lighten lighten ] ")

        mll = lum + adjmin + mod
        mhl = lum + (2 * adjmin) + mod
        
    end
    
    -- Just in case ...
    if mll < 0 then mll = 0 end
    if mll > 1 then mll = 1 end
    if mhl < 0 then mhl = 0 end
    if mhl > 1 then mhl = 1 end
    
    -- Adjust colors.

    -- Limit saturation
    if sat > 0.5 then
        sat = 0.5
    end
    
    local r, g, b, a = DHTK.hsl2rgb(hue, sat, mll, a)       
    local ll_color = {r, g, b, a}  
         
    r, g, b, a = DHTK.hsl2rgb(hue, sat, mhl, a)       
    local hl_color = {r, g, b, a}

   
--    GUI.Msg("   lum is : " .. tostring(lum))        
--    GUI.Msg("   mll is : " .. tostring(mll))
--    GUI.Msg("   mhl is : " .. tostring(mhl))

--[==[ Solved satisfactorily with previous hack.
    -- !!! Non-saturated colors yield ambiguous results
    -- as far as hue is concerned.
    -- Need a way to pass in a "theme" color with sat
    -- then pass back in.
                         
    local hl_color, ll_color
    
    if sat < 0.25 then
    
        --GUI.Msg("   sat is less than : ")    
        hl_color = {r * mhl, g * mhl, b * mhl, a}
        ll_color = {r * mll, g * mll, b * mll, a}    
    
    else
    
        --GUI.Msg("   sat is greater than : ")        
        r, g, b, a = DHTK.hsl2rgb(hue, sat, mll, a)       
        ll_color = {r, g, b, a}  
         
        r, g, b, a = DHTK.hsl2rgb(hue, sat, mhl, a)       
        hl_color = {r, g, b, a}      
                     
    end
--]==] 
    
    --GUI.Msg("\n   ll_color r is : " .. tostring(ll_color[1]))
    --GUI.Msg("   ll_color g is : " .. tostring(ll_color[2]))
    --GUI.Msg("   ll_color b is : " .. tostring(ll_color[3]))                       
    
    return ll_color, hl_color, lum, sat, mll, mhl 
 
end  --<get_hilite_colors>


--[==[
 * Converts an RGB[a] color value to HSL[a]. Conversion formula
 *   adapted from http://en.wikipedia.org/wiki/HSL_color_space.
 * Arguments/returns are given as 0-1
 *
 * @param   r : number       The red color value
 * @param   g : number       The green color value
 * @param   b : number       The blue color value
 * @param   a : number       The alpha value
 * @return  h, s, l, and a   The HSL representation
--]==] 

DHTK.rgb2hsl = function (r, g, b, a)

    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local lum = (max + min) / 2
    local chroma = max - min
    
    local hue, sat
    
    -- Dividing by zero is never a good idea
    if chroma == 0 then
        hue = 0
        sat = 0
        return 0, 0, max, (a or 1)
    else

        --??? sat = chroma / 1 − abs(2 * lum −1) 
        --sat = (max ~= 0) and ((max - min) / max) or 0
        sat = (lum > 0.5) and (chroma / (2 - max - min)) or (chroma / (max + min))

        if max == r then
            --hue = ((g - b) / chroma) % 6
            hue = ((g - b) / chroma) + ((g < b) and 6 or 0)
            goto skip
        elseif max == g then
            hue = ((b - r) / chroma) + 2
            goto skip
        elseif max == b then
            hue = ((r - g) / chroma) + 4
            goto skip
        else
            hue = -1
        end
        
        ::skip::
        
        if hue ~= -1 then hue = hue / 6 end
        
    end

    return hue, sat, lum, (a or 1)
    
end


local function hue2rgb(p, q, t) 
    if (t < 0) then t = t + 1 end
    if (t > 1) then t = t - 1 end
    if (t < 1/6) then return p + (q - p) * 6 * t end
    if (t < 1/2) then return q end
    if (t < 2/3) then return p + (q - p) * (2/3 - t) * 6 end
    return p
end

--[==[
 * Converts an HSL[a]color value to RGB[a]. Conversion formula
 * adapted from https://en.wikipedia.org/wiki/HSL_color_space.
 * Arguments/returns are given as 0-1
 * returns r, g, and b in the set [0, 255].
 *
 * @param   h : number       The hue
 * @param   s : number       The saturation
 * @param   l : number       The lightness
 * @param   a : number       The alpha value
 * @return  {Array}           The RGB representation
 */
--]==]

DHTK.hsl2rgb = function (hue, sat, lum, a) 
    local r, g, b, a
    --GUI.Msg("  -> hsl2rgb -> sat is : " .. tostring(sat))
    --GUI.Msg("  -> hsl2rgb -> lum is : " .. tostring(lum))    
    if (s == 0) then
        r, g, b = lum, lum, lum // achromatic
    else
        local t1, t2   
                          
        if ( lum <= 0.5 ) then 
            t2 = lum * (sat + 1);
        else 
            t2 = lum + sat - (lum * sat)
        end
       
        t1 = lum * 2 - t2;
       
        --r = hue2rgb(t1, t2, hue + 2)
        --g = hue2rgb(t1, t2, hue)
        --b = hue2rgb(t1, t2, hue - 2)
        
        r = hue2rgb(t1, t2, hue + 1/3)
        g = hue2rgb(t1, t2, hue)
        b = hue2rgb(t1, t2, hue - 1/3)
        
    end
    
    --GUI.Msg("  -> hsl2rgb -> RED   is : " .. tostring(r))
    --GUI.Msg("  -> hsl2rgb -> GREEN is : " .. tostring(g))    
    --GUI.Msg("  -> hsl2rgb -> BLUE  is : " .. tostring(b))        
    
      return r,g,b,a

end

DHTK.zhsl2rgb = function (hue, sat, lum) 
    local r, g, b;

    if (s == 0) then
        r, g, b = lum, lum, lum // achromatic 
    else 
        local q = (lum < 0.5) and (lum * (1 + s)) or (lum + sat - (lum * sat))
        local p = (2 * lum) - q
        r = hue2rgb(p, q, h + 1/3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1/3)
  end
  
  return r,g,b

end

----------------------------------
------   SCALE  FUNCTIONS   ------
----------------------------------
--zzscale

-- Normalize metric - converts scaled value to 1.00 scale.
-- @param num: number - element metric to be normalized.
-- @param scale: number - current scale of GUI. 
-- returns normalized metric.

local function normalize_metric (num, scale)
  return math.floor((num / prevscale) + 0.5)
end

-- Scale metric
-- @param num: number - element metric to be scaled.
-- @param scale: number - new scale of GUI.
-- returns scaled metric.

DHTK.scale_metric = function (num, scale)
    return math.floor((num * scale) + 0.5)
end

-- Normalize and Scale metric
-- @param num: number  current scaled value of a metric.
-- @param prevscale: number - current scale of GUI.
-- @param newscale: number - new scale of GUI.

local function norm_scale_metric(num, prevscale, newscale)
    -- return to 1.00 scale.
    local m = math.floor((num / prevscale) + 0.5)
    -- calculate new value.
    return math.floor((m * newscale) + 0.5)
end

-- Called when a script is initialized.
-- Called when app is scaled.
-- Called when setting font scale preference.

DHTK.set_scaled_fonts = function()

    --GUI.Msg("\n##  DHTK.set_scaled_fonts  ##")
    --GUI.Msg("    DHTK.window_settings.font_scale : " .. DHTK.window_settings.font_scale)

    local sf = tonumber(DHTK.window_settings.font_scale) * DHTK.APP_SCALE   
     
    for k, v in pairs(DEFAULT_FONT_SIZES) do

        --GUI.Msg("key : " .. tostring(k) .. " : key type is : " .. type(k) .. " : value is : " .. tostring(v))
        GUI.fonts[k][2] = v * sf

    end
    
    -- Need to redraw everything, even hidden layers (tabs).
    if GUI.gfx_open then 
    
        for key, elmslist in pairs(GUI.elms_list) do
            if type(elmslist) == "table" then
                for idx, elmval in ipairs(elmslist) do
                    --GUI.Msg("> GUI.elms.list zkey is: " .. zkey .. " : elmval is: " .. elmval .. "\n")
                    GUI.elms[elmval]:init()
                    GUI.elms[elmval]:redraw() 
                end
            end
        end

    end
    
end

----------------------------------
------   SCALE  ELEMENTS   ------
----------------------------------
--zzscale
-- !!! This needs all scalable properties of all element classes.

DHTK.SCALABLE_METRICS = {
    'x', 'y', 'w', 'h', 'tab_w', 'tab_h', "limit_w",
    'pad', 'pad_x', 'pad_y', 'pad_top_val', 'cap_pad', 'cap_x', 'cap_y', 'cap_pad_x', 'cap_pad_y',
    'border_width', 'radius', 'opt_size', 'scrollbar_width', 'track_thk',      
    'tick_size', 'hard_tick_size', 'pad_ticks', 'pad_values', 

    'ox', 'oy', 'title_height', 'close_size',
    'display_w', 'display_h', 'display_pad_x', 'display_pad_y',
    'track_offset', 'tickmarks_offset', 'line_height_pixels',
    'txt_pad', 'txt_indent', 'round',
}
   
-- Scale elements.
-- Iterates GUI elements and rescales them to new scale.
-- @param prevscale: number - current scale of GUI.
-- @param newscale: number - new scale of GUI.

DHTK.scale_elements = function (prevscale, newscale)

    for elm_name, _ in pairs(GUI.elms) do
    
       -- GUI.Msg("**** scale_elements elm_name : " .. elm_name)
        
        for _, metric in ipairs(DHTK.SCALABLE_METRICS) do
        
                --GUI.Msg("        metric : " .. metric)
            if GUI.elms[elm_name][metric] then
                GUI.elms[elm_name][metric] = norm_scale_metric(GUI.elms[elm_name][metric], prevscale, newscale)
            end
               
        end
    end

end

-- @param: elm; Single element to be scaled.
DHTK.scale_elm = function (elm)

    for _, metric in ipairs(DHTK.SCALABLE_METRICS) do
    
        if elm[metric] then
            elm[metric] = elm[metric] * DHTK.APP_SCALE
        end
    
    end

end

----------------------------------
------     SCALE  APP    ------
----------------------------------
--zzscale  

-- @param requested_scale: string.
--  if supplied will use it to scale app.
--  if not supplied will look for it in menubox.
  
DHTK.scaleApp = function (requested_scale)

    --GUI.Msg("\n** dhtk_scaleApp **")
    --GUI.Msg("    GUI.w : " .. tostring(GUI.w))
    --GUI.Msg("    gfx.w : " .. tostring(gfx.w)) 

    -- # Set APP_SCALE
    
    local prevscale = DHTK.APP_SCALE
    
    local scale
    
    if requested_scale then 
         scale = requested_scale 
    elseif GUI.elms.mbx_Scale then
         local _, mbx_scale = GUI.Val("mbx_Scale")
         scale = mbx_scale
    else
        scale = "1.00"
    end

    DHTK.window_settings.scale = scale
    
    DHTK.APP_SCALE = tonumber(scale)
    
    --GUI.Msg("> scaleApp new APP_SCALE is: " .. tostring(DHTK.APP_SCALE))
    
    -- # Update fonts
    DHTK.set_scaled_fonts()
    
    -- # Set Window METRICS 

    -- Scale window width and height.
     if DHTK.MULTIPLE_HEIGHTS then
        -- Multiple window heights.
        GUI.w = DHTK.scale_metric(DHTK.APP_WIDTH, DHTK.APP_SCALE)
        GUI.h = norm_scale_metric(GUI.h, prevscale, DHTK.APP_SCALE)
        
        -- The main script will need these.
        DHTK.s_APP_MIN_HEIGHT = DHTK.scale_metric(DHTK.APP_MIN_HEIGHT, DHTK.APP_SCALE)
        DHTK.s_APP_EXP_HEIGHT = DHTK.scale_metric(DHTK.APP_EXP_HEIGHT, DHTK.APP_SCALE)
        DHTK.s_PREFS_HEIGHT = DHTK.scale_metric(DHTK.PREFS_HEIGHT, DHTK.APP_SCALE)
    
    else
        -- Non-changing window height.
        GUI.w = DHTK.scale_metric(DHTK.APP_WIDTH, DHTK.APP_SCALE)
        GUI.h = DHTK.scale_metric(DHTK.APP_HEIGHT, DHTK.APP_SCALE)
    end
    
    --GUI.Msg("> scaleApp new GUI.w is: " .. tostring(GUI.w))
    --GUI.Msg("> scaleApp prevscale is: " .. tostring(prevscale))
    --GUI.Msg("> scaleApp APP_SCALE is: " .. tostring(DHTK.APP_SCALE))
        
    -- # Scale elements
    DHTK.scale_elements(prevscale, DHTK.APP_SCALE)
    
   --[===[    
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
             
        dhMain()
            if GUI.resized then
                gfx.qujit()
                gfx.init(GUI.name, GUIO.w, GUI.h, 0, x, y)
                GUI.redraw_z[0] = true
             
    --]===]
   
    
    -- Do this if calling GUI.Init() because
    -- GUI.Init() converts colors back to 0..1 format.
    
    -- # Convert colors to integer (0..255) format.
    -- GUI.Init() requires colors in integer format.
    -- GUI.Init() converts colors back to 0..1 format.

    for name, col in pairs(GUI.colors) do 
        col[1] = math.floor((col[1] * 255) + 0.5)
        col[2] = math.floor((col[2] * 255) + 0.5)
        col[3] = math.floor((col[3] * 255) + 0.5)
        col[4] = math.floor((col[4] * 255) + 0.5)
    end
      
    GUI.Init()
    
    -- This init all elms, but doesn't redraw them.
    -- Therefore next update only redraws visible layers.
    --GUI.update_elms_list(true)     
    
    -- Need to redraw everything, even hidden layers.

    for key, elmslist in pairs(GUI.elms_list) do
        if type(elmslist) == "table" then
            for idx, elmval in ipairs(elmslist) do
                --GUI.Msg("> GUI.elms.list zkey is: " .. zkey .. " : elmval is: " .. elmval .. "\n")
                --GUI.elms[elmval]:init()
                GUI.elms[elmval]:redraw() 
            end
        end
    end
    
    GUI.resized = true
                     
end --<scaleApp>

----------------------------------------
--[[ DEV NOTE: 
     I'm using layers 489-500 for Preferences Window.
     May want to reserve a few more just in case.
     The following two functions are to hide and show them.
     These need to correspond to z-layers of element definitions.
--]]
    
local function hidePrefsWindow()

    --GUI.Msg("**** core hidePrefsWindow ****")         

    for _, lyr in ipairs(DHTK.PREFS_LAYERS) do
        --GUI.Msg("> hide lyr : " .. tostring(lyr))         
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

    -- Restore saved.
    for _, lyr in ipairs(DHTK.layers_to_restore) do
        --GUI.Msg("> show lyr : " .. tostring(lyr))             
        GUI.elms_hide[lyr] = false
        GUI.redraw_z[lyr] = true
    end

end

DHTK.showPrefsWindow = function ()

    --GUI.Msg("** core showPrefsWindow **")
    
    -- Store any visible layers, and then hide them.

    DHTK.layers_to_restore = {}
    
    -- GUI.elms_list holds visible elms sorted by z.
    -- key is layer, val is list of elm names.

    for z, _ in pairs(GUI.elms_list) do
        if not GUI.elms_hide[z] then
            --GUI.Msg("> showPrefsWindow layers_to_restore : " .. tostring(z))          
            table.insert(DHTK.layers_to_restore, z)
            GUI.elms_hide[z] = true
        end
    end   

    -- Show Preferences.

    for _, lyr in ipairs(DHTK.PREFS_LAYERS) do
        GUI.elms_hide[lyr] = false
    end	

    if GUI.elms.mbx_UserThemes.visibility == "hidden" then
        GUI.elms_hide[GUI.elms.mbx_UserThemes.z] = true
    end

end

--======================================
  --------      ELEMENTS      --------
--======================================
--zzelem
--!!! IMPORTANT: Don't use these with GUI Builder. They clash.

--[===[

    Z LAYER ASSIGNMENTS:

    Layers 485 - 487 reserved for external script use for elements to be added to Preferences window.
    # designates elements that visibility gets toggled independently when Prefs window is showing.
    
    Element                 Layer  

    -- Preferences window layers.
    frm_Preferences          500  
    lbl_Preferences          499  
    btn_ClosePrefs           499  

    lbl_ScaleSectionTitle    499
      
    pnl_ScaleSection         499  
    lbl_CurrScaleTitle       498  
    mbx_Scale                497   
    lbl_CurrFontScaleTitle   498
    mbx_FontScale            496
    
    chkl_UseOutlines         495
    chkl_FrameThk            494    

    lbl_ThemesSectionTitle   499 
     
    pnl_ThemesSection        499  
    lbl_CurrDhThemeTitle     498
    mbx_dhThemes             491  
    lbl_CurrUserThemeTitle   498  
    # mbx_UserThemes         490  
    
    -- For external script use.
    lbl_Options              488 
    chkl_Options             488  
    
    -- Elements used in dh_ThemeDesigner.
    pnl_UserThemesSection    487
    lbl_UserThemeTitle       486
    tbx_UserThemeName        485
    btn_RenameUserTheme      484
    btn_DeleteUserTheme      483
    btn_SaveUserTheme        482
    chkl_SaveToConsole       481
    
--]===]

------------------------------------
----   CREATE PREFS WINDOW   ------
------------------------------------

local function createPrefsWindow()

-- !!! Changed indent for elements definitions for ease of maintenance.
--GUI.Msg("**** in createPrefsWindow ****")
------------------------------------
------  Preferences Window  ------
------------------------------------
--zzprefs
GUI.New("frm_Preferences", "dh_Panel", {
    z = 500, 
    x = 0,
    y = 0,
    w = DHTK.APP_WIDTH,
    h = DHTK.PREFS_HEIGHT,
    shadow = false,
    border_width = 2,
    radius = 0,
    col_bg = "wnd_bg",
    col_border = "elm_frame", 
    col_text = "txt",        
    col_backdrop = "wnd_bg",              
})

GUI.New("lbl_Preferences", "dh_Label", {
    z = 499, 
    x = 16, 
    y = 8, 
    text = "Preferences:",
    shadow = false,
    font = "sans24",
})

GUI.New("btn_ClosePrefs", "dh_Button", {
    z = 499, 
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
    z = 499, 
    x = 16, 
    y = 32, 
    text = "App Scale",
    shadow = false,
    font = "sans22",
})

GUI.New("pnl_ScaleSection", "dh_Panel", {
    z = 499, 
    x = 12,
    y = 56,
    w = 170,
    h = 272,  
    shadow = false,
    border_width = 2, 
    radius = 0,
    col_bg = "panel_bg", 
    col_border = "panel_border",	
    col_text = "panel_txt",
    col_backdrop = "wnd_bg",            
})

----------------------------------------

GUI.New("lbl_CurrScaleTitle", "dh_Label", {
    z = 498,
    x = 20, 
	y = 64, 
    text = "Current Scale",
    shadow = false,
    col_bg = "panel_bg",
    col_text = "panel_txt",    
    font = "sans22",
})

GUI.New("mbx_Scale", "dh_Menubox", {
    z = 497, 
    x = 20, 
    y = 92, 
    w = 154, 
    h = 28,  
    text = "",
    noarrow = false,
    optarray = DHTK.APP_SCALE_FACTORS,
    curr_opt = 1,
    align_text = "left",
    font_text = "sans22",  --"sans24",
    col_text = "elm_txt",
    col_backdrop = "panel_bg",
})

GUI.New("lbl_CurrFontScaleTitle", "dh_Label", {
    z = 498, 
    x = 20, 
	y = 140,  
    text = "Current Font Scale",
    shadow = false,
    col_bg = "panel_bg",
    col_text = "panel_txt",    
    font = "sans22",
})

GUI.New("mbx_FontScale", "dh_Menubox", {
    z = 496, 
    x = 20, 
    y = 168,  
    w = 154, 
    h = 28,   
    text = "",
    noarrow = false,
    optarray = DHTK.FONT_SCALE_FACTORS,
    curr_opt = 3,
    align_text = "left",
    font_text = "sans22",  --"sans24",
    col_text = "elm_txt",
    col_backdrop = "panel_bg",
})

GUI.New("chkl_UseOutlines", "dh_Checklist", {
    z = 495,
    x = 16, 	
    y = 264, 
    w = 154, 
    h = 24,
    caption = "", 
    opts = {"Use Outlines"},
	dir = "v", 
	pad = 0,

    border_width = 0, 
    radius = 0,
        
    col_text = "panel_txt",    
    col_border = "panel_border",  
    col_bg = "panel_bg",
    col_backdrop = "panel_bg",         
    font_text = "sans22",
    opt_size = 14,
})

GUI.New("chkl_FrameThk", "dh_Checklist", {
    z = 494,
    x = 16, 	
    y = 292,  
    w = 154, 
    h = 24,
    caption = "", 
    opts = {"Thick Frames"},
	dir = "v", 
	pad = 0,

    border_width = 0, 
    radius = 0,
        
    col_text = "panel_txt",    
    col_border = "panel_border",  
    col_bg = "panel_bg",
    col_backdrop = "panel_bg",         
    font_text = "sans22",
    opt_size = 14,
})

------------------------------------
------   Themes Section   ------ 
------------------------------------
--zztheme   

GUI.New("lbl_ThemesSectionTitle", "dh_Label", { 
    z = 499, 
    x = 194, 
    y = 32,
    text = "Themes",
    shadow = false,
    font = "sans22",
})

GUI.New("pnl_ThemesSection", "dh_Panel", {
    z = 499, 
    x = 190,
    y = 56,
    w = 170,
    h = 272,
    shadow = false,
    border_width = 2, 
    radius = 0,
    col_bg = "panel_bg", 
    col_border = "panel_border",
    col_text = "panel_txt",	
    col_backdrop = "wnd_bg",     
})

----------------------------------------

GUI.New("lbl_CurrDhThemeTitle", "dh_Label", {
    z = 498, 
    x = 198, 
	y = 64,
    text = "Current dh_theme:",
    shadow = false,
    col_bg = "panel_bg",
    col_text = "panel_txt",    
    font = "sans22",
})

GUI.New("mbx_dhThemes", "dh_Menubox", {
    z = 491, 
    x = 198, 
    y = 92, 
    w = 154, 
    h = 28,  
    text = "",
    noarrow = false,
    optarray = dhth.DH_THEME_NAMES,
    curr_opt = 1,
    align_text = "left",
    font_text = "sans22",
    col_text = "elm_txt",
    col_backdrop = "panel_bg",
})

GUI.New("lbl_CurrUserThemeTitle", "dh_Label", {
    z = 498, 
    x = 198, 
	y = 140,
    text = "Current User theme:",
    shadow = false,
    col_bg = "panel_bg",
    col_text = "panel_txt",    
    font = "sans22",
})

GUI.New("mbx_UserThemes", "dh_Menubox", {
    z = 490, 
    x = 198, 
    y = 168,   
    w = 154, 
    h = 28,   
    text = "",
    noarrow = false,
    optarray = DHTK.USER_THEME_NAMES,
    curr_opt = 0, -- Set this in script init.
    align_text = "left",
    font_text = "sans22",  --"sans24",
    col_text = "elm_txt",
    col_backdrop = "panel_bg",
    -- added property for special use    
    visibility = "hidden",
})

------------------------------------
------   Optional Section   ------ 
------------------------------------
--zzoptions
--[[ DEV NOTE: 
     !!! Define optional section in Main Script.
     Can use this as a template. 

GUI.New("lbl_Options", "dh_Label", {
    z = 488,  
    x = 372, 
    y = 32, 
    text = "Options", 
    font = "sans22",
})

GUI.New("chkl_Options",	"dh_Checklist",	{
	z = 488,  
    x = 368, 	
    y = 56,  
    w = 220, 
    h = 236,
	--opts = template_options_names, -- defined in "my data"
	opts= {},
	dir = "v", 

    border_width = 2, 
    radius = 0,
    
	caption = "",
	font_caption = "sans22",
	--shadow = false,    
        
	col_bg = "panel_bg",        
    col_border = "panel_border",
	col_text = "panel_txt",     	
	col_cap_bg = "panel_bg",  -- caption bg color
    col_backdrop = "wnd_bg",

})

--]]
    
-- Indent back to normal indent.

    ------------------------------------
    ------  Prefs Functions  ------
    ------------------------------------
    -- These must before they are called.
    
    function updateOutlines(use_outlines)
 
        -- Iterate all elms and set outlines.
    	for key, elm in pairs(GUI.elms) do
    	    if elm.frame_use_outline ~= nil then
    	        elm.frame_use_outline = use_outlines
                elm:init()
                elm:redraw()
            end
        end 
    
    end    
 
    function updateFrameThk(thk_val)
 
        -- Iterate all elms and set frame_thk.
    	for key, elm in pairs(GUI.elms) do
    	    if elm.frame_thk ~= nil then
    	        elm.frame_thk = thk_val
                elm:init()
                elm:redraw()
            end
        end 
    
    end

    ------------------------------------
    ------  Initialize Elements  ------
    ------------------------------------
    --GUI.Msg("**** createPrefsWindow init ****")

    -- Set preferences options.
    GUI.Val("mbx_Scale", DHTK.table_index_from_value(DHTK.APP_SCALE_FACTORS, DHTK.window_settings.scale))
    GUI.Val("mbx_FontScale", DHTK.table_index_from_value(DHTK.FONT_SCALE_FACTORS, DHTK.window_settings.font_scale))

    GUI.Val("mbx_dhThemes", DHTK.table_index_from_value(dhth.DH_THEME_NAMES, DHTK.window_settings.theme))

--zzz             
    updateOutlines(DHTK.window_settings.use_outlines)
    GUI.Val("chkl_UseOutlines", DHTK.window_settings.use_outlines) 
    
    updateFrameThk(DHTK.window_settings.frame_thk)
    GUI.Val("chkl_FrameThk", (DHTK.window_settings.frame_thk == 2) and true or false) 

    if DHTK.window_settings.theme == "User" then
        if DHTK.window_settings.user_theme then
            GUI.Val("mbx_UserThemes", DHTK.table_index_from_value(DHTK.USER_THEME_NAMES, DHTK.window_settings.user_theme))
            GUI.elms.mbx_UserThemes.visibility = "visible"
        end    
    else
        GUI.elms.mbx_UserThemes.visibility = "hidden"
    end

    hidePrefsWindow()
    
    
    

    ----------------------------------
    ------   Method Overrides  ------
    ----------------------------------
    --zzoverrides
    -- !!! Overrides can not be local. They will be added to GUI.

    function GUI.elms.mbx_Scale:onmouseup()
        
        -- Run the element's normal method
        GUI.dh_Menubox.onmouseup(self)    
    
    	-- Add our code.
	    
	    -- scaleApp will convert it to number.
        local scale = self.optarray[self.curr_opt]
        DHTK.scaleApp()
    
    end  

    function GUI.elms.mbx_FontScale:onmouseup()
        
        -- Run the element's normal method
        GUI.dh_Menubox.onmouseup(self)    
    
    	-- Add our code.
	    
        DHTK.window_settings.font_scale = self.optarray[self.curr_opt]
        -- set_scaled_fonts gets value from settings then converts it to number.
        DHTK.set_scaled_fonts()
    
    end

--zzz  
    function GUI.elms.mbx_dhThemes:onmouseup()
        --GUI.Msg("# GUI.elms.mbx_dhThemes:onmouseup")           
        local prev_opt = self.curr_opt
        
        -- Run the element's normal method
        GUI.dh_Menubox.onmouseup(self)
        
        -- No change. Clicked on current option.
        if prev_opt == self.curr_opt then return end
        
        local dh_theme_name = self.optarray[self.curr_opt]
        
        if dh_theme_name == "User" then

            if #DHTK.USER_THEME_NAMES == 0 then
                reaper.MB("There are no user themes to load!", "Whoops!", 0) 
                self.curr_opt = prev_opt                            
                return
            else
                GUI.elms.mbx_UserThemes.visibility = "visible"
                GUI.elms_hide[GUI.elms.mbx_UserThemes.z] = false  

                -- Set the current user theme option.
                local _, curr_ut = GUI.elms.mbx_UserThemes:val()
                dhth.set_theme(DHTK.USER_THEMES[curr_ut], true)
            end
        else
        
            -- DH THEME selected.
            if GUI.elms.mbx_UserThemes.visibility == "visible" then
                GUI.elms.mbx_UserThemes.visibility = "hidden"
                GUI.elms_hide[GUI.elms.mbx_UserThemes.z] = true 
            end    

            dhth.set_theme(dhth.DH_THEMES[dh_theme_name], true)
        end
        
        DHTK.window_settings.theme = dh_theme_name
     	
        -- Necessary!
        GUI.update_elms_list(true)
    	
    	GUI.redraw_z[0] = true     	     	
     	
    end
    
    -- If mbx_UserThemes visible there must be at least
    --   one user theme.
    function GUI.elms.mbx_UserThemes:onmouseup()
    
        local prev_opt = self.curr_opt
    
        -- Run the element's normal method
        GUI.dh_Menubox.onmouseup(self)
 
        -- No change. Clicked on current option.
        if prev_opt == self.curr_opt then return end

        local user_theme_name = self.optarray[self.curr_opt]
        DHTK.window_settings.user_theme = user_theme_name
        dhth.set_theme(DHTK.USER_THEMES[user_theme_name], true)
     	
        -- Necessary!
        GUI.update_elms_list(true)
    	
    	GUI.redraw_z[0] = true     	
     	
    end    

    function GUI.elms.chkl_UseOutlines:onmouseup()

    	-- Run the element's normal method --
    	GUI.dh_Checklist.onmouseup(self)

        local boolval = self.optsel[1]
        DHTK.window_settings.use_outlines = boolval        
        updateOutlines(boolval)
                 
    end
    
    function GUI.elms.chkl_FrameThk:onmouseup()

    	-- Run the element's normal method --
    	GUI.dh_Checklist.onmouseup(self)

        local thk_val = self.optsel[1] and 2 or 1
        DHTK.window_settings.frame_thk = thk_val        
        updateFrameThk(thk_val)

    end
    
    

--GUI.Msg("**** end createPrefsWindow ****")

end --<createPrefsWindow> 

--======================================
  --------    INIT CODE    --------
--======================================
local function setup_window()
    GUI.x = DHTK.window_settings.left
    GUI.y = DHTK.window_settings.top
    GUI.w = DHTK.scale_metric(DHTK.APP_WIDTH, DHTK.APP_SCALE)    
   
    if DHTK.MULTIPLE_HEIGHTS then
        if DHTK.window_settings.is_window_expanded == false then
            GUI.h = DHTK.APP_MIN_HEIGHT
        else
            GUI.h = DHTK.APP_EXP_HEIGHT
        end
        
        -- The main script will need these.
        DHTK.s_APP_MIN_HEIGHT = DHTK.scale_metric(DHTK.APP_MIN_HEIGHT, DHTK.APP_SCALE)
        DHTK.s_APP_EXP_HEIGHT = DHTK.scale_metric(DHTK.APP_EXP_HEIGHT, DHTK.APP_SCALE)
        DHTK.s_PREFS_HEIGHT = DHTK.scale_metric(DHTK.PREFS_HEIGHT, DHTK.APP_SCALE)
                 
    else
        DHTK.window_settings.is_window_expanded = nil
        GUI.h = DHTK.APP_HEIGHT
    end

    --GUI.Msg("**** setup_window DHTK.APP_SCALE is : " .. tostring(DHTK.APP_SCALE))
    --GUI.Msg("**** setup_window GUI.h is : " .. tostring(GUI.h))
    --GUI.Msg("**** setup_window APP_HEIGHT is : " .. tostring(APP_HEIGHT))
    --GUI.Msg("**** setup_window DHTK.APP_HEIGHT is : " .. tostring(DHTK.APP_HEIGHT))
    
    GUI.h = DHTK.scale_metric(GUI.h, DHTK.APP_SCALE)

end

--zzinit 
-- This needs to be called in Main script after loading classes. 

DHTK.init_DHTK = function () 

    --GUI.Msg("**** in DHTK.init_DHTK ****")
    
    getWindowSettings()

    getUserThemes()
    
    --!!! IMPORTANT! Will not use DHTK Prefs elements if false. 
    -- Skip if implementing your own handling of preferences as in dh_GUI_Builder.
    
    if DHTK.USE_DHTK_PREFS then
    
        -- Layers used for dh_Toolkit Prefs window.  
        DHTK.PREFS_LAYERS = {485,486,487,488,489,490,491,492,493,494,495,496,497,498,499,500}
        
        -- Store any visible layers before hiding them when Preference window is opened.
        DHTK.layers_to_restore = {}
        
        -- Empty user themes will be addressed.
        createPrefsWindow()

    end 

    setup_window()
    
    DHTK.set_scaled_fonts()
    
    --GUI.Msg("**** end DHTK.init_DHTK ****")
end


DHTK.init_scale_elms = function ()

    --GUI.Msg("**** DHTK.init_scale_elms ****")
    
    DHTK.scale_elements(1, DHTK.APP_SCALE)

end


----------------------------------------
return DHTK
----------------------------------------

--zzend