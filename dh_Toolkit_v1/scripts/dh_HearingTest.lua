-- dh_HearingTest.lua 
-- version 1.0 
-- Author: Dennis R. Horn
-- Date: 2026-06-06

---------------------------------------------
-- Copyright (c) 2025 Dennis R. Horn
-- License: GNU General Public License version 3

-- Uses Lokasenna_GUI v2 for interactivity:
-- https://github.com/jalovatt/Lokasenna_GUI

-- Uses dhToolkit for widget classes and theming.

-- Uses json.lua for encoding/decoding data to/from ext state:
-- https://github.com/rxi/json.lua

---------------------------------------------
-- DISCLAIMER: This script has been tested on Reaper 6.23 
--   running on Windows 11-x64 with no issues. 
--   Although thoroughly tested the author is not responsible 
--   for any loss of data that may result in the event 
--   that the script crashes Reaper.

---------------------------------------------
-- DESCRIPTION:

-- Script for use with Reaper DAW.
-- Test one's hearing against for perceived equal loudness
--   according to established ISO Standards.

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
-- dh_log (used during development)
---------------------------------------
-- Disable all console messages using dh_log() by setting this to false. 

local dh_log_active = false

function dh_log(msg)
	if dh_log_active then
		reaper.ShowConsoleMsg(msg .. "\n")
	end
end

reaper.ClearConsole()
--======================================
-- Lokasenna's GUI requirements.
--======================================
local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
if not lib_path or lib_path == "" then
    reaper.MB("Couldn't load the Lokasenna_GUI library. Please install 'Lokasenna's GUI library v2 for Lua', available on ReaPack, then run the 'Set Lokasenna_GUI v2 library path.lua' script in your Action List.", "Whoops!", 0)
    return
end
loadfile(lib_path .. "Core.lua")()

-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end

GUI.name = "dh_HearingTest v1.0"

--Hide the version number since I'm using a small window.
--GUI.Draw_Version = function () end

--======================================
-- dh_Toolkit requirements 
--======================================
-- Adds current directory to path.

-- Can use this if script is in dh_Toolkit directory.
local script_folder = debug.getinfo(1).source:match("@?(.*[\\|/])")
--GUI.Msg("script_folder : " .. script_folder)
--reaper.ShowConsoleMsg("script_folder : ")

package.path = package.path .. ";" .. script_folder .. "?.lua"
local dhtk_path = reaper.GetExtState("dh_Toolkit", "lib_path_v1")
if not dhtk_path or dhtk_path == "" then
    reaper.MB("Couldn't load dh_Toolkit. Please install 'dh_Toolkit v1 for Lua', available on ReaPack, then run the 'Set dh_Toolkit v1 library path.lua' script in your Action List.", "Whoops!", 0)
    return
end

package.path = package.path .. ";" .. dhtk_path .. "?.lua"

require "common/GUI_overrides"

----------------------------------------
DHTK = require "common/dh_Toolkit_core"
----------------------------------------

DHTK.USE_DHTK_PREFS = true

-- This is the name to be used as the section name when 
-- saving settings to reaper ext state (usually the name of the script).
DHTK.EXT_STATE_NAME = "dh_HearingTest"

DHTK.APP_WIDTH = 640
DHTK.APP_HEIGHT = 480

----------------------------------------
--[[ DEV NOTE: Custom or modified Lokasenna classes.
     Comment out classes not used. ]]--

-- dh_Toolkit classes 

-- Needed for core.
require "classes/dh_Button"     
require "classes/dh_Label"
require "classes/dh_Menubox"  
require "classes/dh_Options"   
require "classes/dh_Panel"   
  
require "classes/dh_Graph"    
require "classes/dh_Knob"  
--require "classes/dh_Listbox"
--require "classes/dh_Menubar"
--require "classes/dh_Slider_H"
--require "classes/dh_Slider_V"
--require "classes/dh_Tabs"
require "classes/dh_Textbox" 
--require "classes/dh_TextEditor"

----------------------------------------
DHTK.init_DHTK()
----------------------------------------

-- Used for saving/loading to extstate.
local json = require "common/json"

--======================================
  --------      TODO      --------
--======================================
--zztodo

---------------------------------------
  --------      NOTES      --------
---------------------------------------
--zznotes
--[==[
Decibels provide a relative measure of sound intensity. 
The unit is based on powers of 10 to give a manageable range 
of numbers to encompass the wide range of the human hearing 
response, from the standard threshold of hearing at 
1000 Hz to the threshold of pain at some ten trillion times 
that intensity.

Another consideration which prompts the use of powers of 10 
for sound measurement is the rule of thumb for loudness: 
it takes about 10 times the intensity to sound twice as loud. 

The Fletcher-Munson curves for equal loudness are defined as 
60db sound pressure at 1Khz for a 60 phon curve. 

!!! THIS SHOULD NOT BE CHANGED DURING SCRIPT RUN!
HT.datum_gain is the reference track volume for datum frequency.
This is to be set to a value (maybe -18db) to leave plenty of 
headroom for adjustments to equal loudness. 

Using this reference the speakers/headphones volume need 
to be adjusted to achieve 60 SPL (sound pressure loudness) 
at the reference frequency and gain. 

Next, a test frequency is selected. The selected frequency 
will have an equal loudness value based on the Fletcher-Munson 
curve. (Low frequencies can have 40+ db to achieve equal loudness.)
This value will be the curve value minus the curve reference, 
e.g., 196Hz curve value of 70 for a 60 phon curve means that 
frequency requires 10db more pressure to sound as loud as the 
reference frequency. Let's call this HT.eq_loud_offset.

HT.test_gain_adj is the adjustment to HT.eq_loud_offset to achieve 
equal loudness. It is per frequency. This is the number that 
will be stored in the dataset.

HT.datum_gain: track gain of datum frequecy (fixed per test)
HT.eq_loud_offset: gain of test frequency relative to datum_gain
HT.test_gain_adj: gain adj required to bring test frequency 
   to equal loudness with datum frequency.

Track volume should only be changed by the script.
Make sure all tests respect this.

-- Init vol is difference of curve value - reference phon  + deviation from phon level (initially 0).
-- Fletcher-Munson curves use 1Khz as datum.
-- dh_HearingTest uses 1047hz as datum.
-- Difference is 1047 is ~ +0.4db. Compensate.
--   eg., 1Khz: 70 - 60 = 10; 1049: 70 - 60.4 = 9.6
-- Deviations are zone.gain_l. gain_c, and gain_r are 
-- agjustments from phon level required to achieve equal loudness.                
--   eg., 70 - 60.4 + 1.2

--!!! dbl check 784 eq loud at 60 phon. ~60
  
-- 196hz has phon level of 70db above 1Khz ref of 60
-- Subtract 60 to get +10 ref
-- I'm using 1049 which is +0.4db  
--   so in essence I'm using a reference of 60.4
-- test gain is always deviation from datum ref.
-- phon_ref_level is curve point minus 60.4

--]==]

--======================================
  --------      My Data      --------
--======================================
--zzdata  --zzzc --zzzz

HT = {}

HT.r_track = nil          -- reference to selected track
HT.tgen_idx = nil         -- reference to tone generator
HT.tgen_guid = nil        -- GUID of tone generator
HT.eq_idx = nil           -- reference to ReaEQ

-- References to tone generator parameters.
HT.tgen_wm_idx = nil      -- index of wet mix parameter
HT.tgen_note_idx = nil    -- index of note parameter
HT.tgen_octave_idx = nil  -- index of octave parameter
HT.tgen_cents_idx = nil   -- index of cents parameter

-- Test parameters.
HT.datum_freq_id  = '1047'-- lookup value for selected datum frequency (fixed)
HT.datum_freq_idx = 12    -- lookup value for reference frequency
HT.datum_gain = -18       -- track gain of datum frequecy (per profile)
-- 1 is 0 on slider (test reference). Should not change.
HT.track_ref_vol = 10^(HT.datum_gain / 20)  -- initial value

HT.test_freq_id  = '1047' -- lookup value for selected frequency
HT.test_freq_idx = 12     -- index in HT.freqs
HT.eq_loud_offset = 0     -- gain of test frequency relative to datum gain
HT.test_gain_adj = 0      -- adjustment to eq_loud_offset to achieve equal loudness
HT.gain_adj_step = 1      -- step amount to adjust gain with buttons

-- This contains default settings.
HT.defaults = require "dh_HearingTest_data"

-- Need freqs in order for displaying data.
HT.freqs = HT.defaults.frequencies

-- Container for test parameters and data. 
-- Copy so as to leave defaults intact.
HT.zones = GUI.table_copy(HT.defaults.zones)

-- Need a default.
HT.profiles = {
  ['Working Copy'] = HT.zones,
}

-- This will be used by menubox.
HT.profile_names = {"Working Copy"}

HT.current_profile = 'Working Copy'

HT.profile_layers = {52,53,54,55,56,57,58,59,60,}  -- set as built in GUI Builder

HT.phon_curve = 60
HT.phon_points = HT.defaults.phon_60

-- True when a test is running.
HT.is_running = false

HT.channel = 2            -- 1: left, 2: center, 3: right   
HT.gain_lcr = "gain_c"    -- "gain_l", "gain_c", "gain_r"
HT.graph_type = 1         -- 1 is curved, 2 is flat

-- For graph display. 
HT.data_points = {}

-- Graph label settings.
x_labels = {
  --{1, "33"}, 
  {2, "49"},
  --{3, "82"},
  {4, "131"},       
  --{5, "196"},
  {6, "262"},
  --{7, "392"},       
  {8, "523"},
  --{9, "659"},
  {10, "784"},       
  --{11, "932"},                     
  {12, "1047"},
  --{13, "1319"},          
  {14, "1568"},
  --{15, "2093"},
  {16, "2637"},
  --{17, "3136"},                            
  {18, "3729"},
  --{19, "4186"},
  {20, "4699"},
  --{21, "5274"},
  {22, "6272"},       
  --{23, "7459"},       
  {24, "8372"},                                         
  --{25, "10548"},
}

y_labels_c = {
  {2, "75"}, 
  {4, "50"}, 
  {6, "25"}, 
}

y_labels_f = {
  {2, "8"},
  {4, "4"}, 
  {6, "0"}, 
}

--zzztimer
-- Timer defaults.
TIMER = {}
TIMER.start_time = 0
TIMER.interval = 1        -- seconds
TIMER.caller = 1          -- 1: Main Test, 2: Test LR
TIMER.state = 1
TIMER.count = 0
TIMER.end_count = 5

-- Used for main test (timer 1)

TIMER.datum_note_idx = 3  --"C"
TIMER.datum_octave = 1
TIMER.test_note_idx = 3
TIMER.test_octave = -4
-- used for test (timer 2 and/or 3)
TIMER.cents = 0

--======================================
  ------     My Functions    --------
--======================================
--zzfunc

--zzext
-- Called on script exit.

local function saveExtState()

    --GUI.Msg("\n## saveExtState ## ")
    
    -- # ZONES / PROFILES    

    local json_string = json.encode(HT.profiles)
    
    if json_string == nil then json_string = "" end
    
    --GUI.Msg("  saveExtState PREFS json_string :\n " .. json_string)                

    reaper.SetExtState(DHTK.EXT_STATE_NAME, "profiles", json_string, true)
    
    -- # PREFS

    local prefs = {}
    prefs.channel = HT.channel
    prefs.graph_type = HT.graph_type
    prefs.test_freq_id = HT.test_freq_id
    prefs.current_profile = HT.current_profile    
    
    json_string = json.encode(prefs)
    
    reaper.SetExtState(DHTK.EXT_STATE_NAME, "prefs", json_string, true)

    json_string = nil    

end  --<saveExtState>

--zzext
local function loadExtState()

    --GUI.Msg("\n##  loadExtState ## ")

    local json_string = reaper.GetExtState(DHTK.EXT_STATE_NAME, "profiles")
    
    local data = json.decode(json_string) -- should return Lua table
    
    if type(data) == "table" and DHTK.hash_table_length(data) > 0 then
        HT.profiles = data
    end

end  --<loadExtState>


local function loadPrefs()

    --GUI.Msg("\n##  loadPrefs ## ")
    
    local json_string = reaper.GetExtState(DHTK.EXT_STATE_NAME, "prefs")
    
    --GUI.Msg("    loadExtState PREFS json_string :\n " .. json_string)

    local prefs = json.decode(json_string) -- should return Lua table
    
    if type(prefs) == "table" and DHTK.hash_table_length(prefs) > 0 then
        if prefs.channel then HT.channel = prefs.channel end
        if prefs.graph_type then HT.graph_type = prefs.graph_type end
        if prefs.test_freq_id then HT.test_freq_id = prefs.test_freq_id end
        if prefs.current_profile then HT.current_profile = prefs.current_profile end
    end
    
    --GUI.Msg("  loadPrefs HT.test_freq_id : " .. HT.test_freq_id)    

    json_string = nil
    
end  --<loadPrefs>

--!!! If I do this in script init for all profiles then
--    I don't need to do it every load profile.
-- profiles exist in HT.profiles which are loaded on script start.
-- There is possibility that profile lacks certain data.
-- This ensures at least a default value exists for each item.

local function load_profile(profile)

    --GUI.Msg("\n## load_profile ## ")
    
    --Profile should exist. Notify if not?
    if not HT.profiles[profile] then return end
    
    --GUI.Msg("    profile : " .. profile)

    local tmp = GUI.table_copy(HT.defaults.zones)

    for _, freq in ipairs(HT.freqs) do
    
        local pdata = HT.profiles[profile][freq]

        if pdata.locked then tmp[freq].locked = pdata.locked end 
        if pdata.bypass then tmp[freq].bypass = pdata.bypass end
        if pdata.gain_l then tmp[freq].gain_l = pdata.gain_l end 
        if pdata.gain_c then tmp[freq].gain_c = pdata.gain_c end 
        if pdata.gain_r then tmp[freq].gain_r = pdata.gain_r end 
        if pdata.lr_gain then tmp[freq].lr_gain = pdata.lr_gain end 
        if pdata.lr_cents then tmp[freq].lr_cents = pdata.lr_cents end 

    end
    
    if not HT.profiles[profile][HT.datum_freq_id].tg_gain then
        tmp[HT.datum_freq_id].tg_gain = -12
    end
    
    if not HT.profiles[profile][HT.datum_freq_id].datum_gain then
        tmp[HT.datum_freq_id].datum_gain = -18
    end
    
    HT.datum_gain = HT.profiles[profile][HT.datum_freq_id].datum_gain
    
    --GUI.Msg("    HT.datum_gain : " .. HT.datum_gain)
    
    HT.profiles[profile] = tmp 
    HT.zones = HT.profiles[profile]
        
end

--zzzprofile
-- Adds/updates profile in HT.profiles, and saves it to extstate.

local function save_profile()  

    --GUI.Msg("\n## save_profile ## ")
    
    local profile_name = GUI.elms.tbx_ProfileName.retval 
    
    -- Make sure profile_name is legit.
    --??? Should do more validating?
    if (not profile_name) or #profile_name < 1 then
        --profile_name = "Working Copy"
        reaper.MB("Enter a name for the profile!", "Whoops!", 0)
        return
    end
    
    -- Disregard if 'Working Copy'.
    if profile_name == 'Working Copy' then 
        reaper.MB("Cannot save to 'Working Copy'!", "Whoops!", 0)    
        return
    end    
    
    -- No need to save if current profile.
    if profile_name == HT.current_profile then 
        reaper.MB("Profile already exists!", "Whoops!", 0)    
        return
    end
    
    HT.current_profile = profile_name
    GUI.Val("lbl_CurrentProfileName", HT.current_profile)   
    
    -- # Add profile to profiles.
    --   HT.zones has the current profile to be saved.
    
    HT.profiles[profile_name] = HT.zones

    table.insert(HT.profile_names, profile_name)    

    -- # Update menubox.
    
    --??? Sort profile names
    
    GUI.elms.mbx_Profiles.curr_opt = #HT.profile_names -- the newly created profile            
    
    -- # Save to extstate.
    local json_str = json.encode(HT.profiles)
    reaper.SetExtState("dh_HearingTest", "profiles", json_string, true)    
            
end  --<save_profile>


local function rename_profile()

    local new_profile_name = GUI.elms.tbx_ProfileName.retval 
    
    -- # Make sure profile_name is legit.
    --??? Should do more validating?
    
    if (not new_profile_name) or #new_profile_name < 1 then
        --profile_name = "Working Copy"
        reaper.MB("Enter a name for the profile!", "Whoops!", 0)
        return
    end
    
    -- Disregard if 'Working Copy'.
    if new_profile_name == 'Working Copy' then 
        reaper.MB("Cannot rename 'Working Copy'!", "Whoops!", 0)    
        return
    end    
    
    -- No need to save if current profile.
    if new_profile_name == HT.current_profile then 
        reaper.MB("Profile already exists!", "Whoops!", 0)    
        return
    end
    
    -- # Do updates.
        
    HT.profiles[new_profile_name] = HT.profiles[HT.current_profile]
    HT.profiles[HT.current_profile] = nil
    
    -- # Point zones to new profile
    HT.zones = HT.profiles[new_profile_name]    

    HT.current_profile = new_profile_name
    GUI.Val("lbl_CurrentProfileName", HT.current_profile)   
    
    -- # Update menubox.
    
    local mbx = GUI.elms.mbx_Profiles
    local idx, val = mbx:val()
    -- If I change optarray that should be changing HT.profile_names.
    mbx.optarray[idx] = new_profile_name
    mbx:redraw()
    
    -- # Save to extstate.
    local json_str = json.encode(HT.profiles)
    reaper.SetExtState("dh_HearingTest", "profiles", json_string, true)  

end


local function delete_profile()

    local profile_name = GUI.elms.tbx_ProfileName.retval
    
    if profile_name == 'Working Copy' then
        reaper.MB("Cannot delete 'Working Copy'!", "Whoops!", 0)    
        return    
    end

    local msg = "Do you want to delete profile : " .. profile_name .. " ?"

    local retval = reaper.MB(msg, "Warning", 4)
    
	if retval == 6 then
	
        HT.profiles[profile_name] = nil
        
        -- HT.zones needs to point somewhere.
        
        -- # Go back to 'Working Copy'.
        
        HT.zones = HT.profiles['Working Copy']
        HT.current_profile = 'Working Copy'
        GUI.Val("lbl_CurrentProfileName", HT.current_profile)   
        
        -- # Update menubox.
         
        -- It thinks the deleted profile is still there. So the curr_opt is still legit.
        local mbx = GUI.elms.mbx_Profiles
        local idx, val = mbx:val()
        -- If I change HT.profile_names that should be changing optarray.
        table.remove(HT.profile_names, idx)
        mbx.curr_opt = 1
        mbx:redraw()        

	end

end

--zzzdata 
-- data_points are deviations from phon curve.

local function update_data_points()

    HT.data_points = {}

    for i, freq in ipairs(HT.freqs) do 
    
        --GUI.Msg("\n##  update_data_points freq : " .. freq)
        --GUI.Msg("      type of freq : " .. type(freq))
        --GUI.Msg("      size of HT.zones : " .. GUI.table_length(HT.zones))
    
        local zone = HT.zones[freq]
        local val = zone[HT.gain_lcr]
        
        if HT.graph_type == 1 then
            val = val + HT.phon_points[i] or 0
            --GUI.Msg("     update_data_points ref val : " .. val)
        end
        
        --GUI.Msg("     update_data_points ref val : " .. val)
        --GUI.Msg("        type  ref val : " .. type(val) )               

        table.insert(HT.data_points, val)        
        
    end

end  --<update_data_points>


local function update_graph(needs_init)

    --GUI.Msg("\n##  update_graph : ")
    
    update_data_points()
       
    --!!! It seems I have to reassign.
    GUI.elms.graph_Freq.data_points = HT.data_points 
    
    if needs_init then
        GUI.elms.graph_Freq:init()
    end   
    
    GUI.elms.graph_Freq:redraw()

end


local function get_track_names()

    local r_track_count = reaper.CountTracks(0)
    local track_names = {}

    for i = 0, r_track_count - 1 do

    	local r_track = reaper.GetTrack(0, i)

    	local _, rt_name = reaper.GetTrackName(r_track)

        table.insert(track_names, rt_name)
        
        --GUI.Msg("get_track_names : " .. rt_name)

    end
    
    return track_names

end

-- Called from mbx_Tracks:onmouseup and during script init.
--??? Rework to get track/fx on script init?

local function select_track()

    HT.tgen_idx = nil
    HT.tgen_guid = nil    
    
	local track_idx = GUI.elms.mbx_Tracks.curr_opt - 1
    
    -- # Get track.
    local r_track = reaper.GetTrack(0, track_idx)
    
    if r_track then
    
        local _, track_name = reaper.GetTrackName(r_track)
        --GUI.Msg("select_track track_name : " .. track_name)
            
        HT.r_track = r_track
    
        -- # Get index of tone generator.
        
        -- returns index in fx chain of first fx with name.
        -- -1 if not found.
        
        local fx_cnt = reaper.TrackFX_GetCount(r_track)
        
        --GUI.Msg("fx_cnt size : " .. fx_cnt)
        
        for i = 1, fx_cnt do
            local _, fx_name = reaper.TrackFX_GetFXName(r_track, i - 1, "fx_name") --, string buf)
            --GUI.Msg("fx_name : " .. fx_name)
        end
        
        -- retval is fx position in chain if success; -1 if failure..            
        local retval = reaper.TrackFX_AddByName(r_track, "JS: Tone Generator", false, 0)
        
        --GUI.Msg("fx_name retval : " .. retval)

        if retval == -1 then
            reaper.MB("No tone generator on selected track!", "Whoops!", 0)
            return
        end
        
        -- TONE GENERATOR FOUND --
        
        --GUI.Msg("\n-- TONE GENERATOR FOUND --\n")
        
        HT.tgen_idx = retval
        
        --!!! May need this someday.
        HT.tgen_guid = reaper.TrackFX_GetFXGUID(r_track, retval)
        
        -- # Get params indices --
        
        -- Iterate effect params.
        
        local paramcount = reaper.TrackFX_GetNumParams(r_track, HT.tgen_idx)
        
	    for p_idx = 0, paramcount - 1 do 
	               
            -- Get param name. Just the name, please!
            
            local succ, param_name = reaper.TrackFX_GetParamName(r_track, HT.tgen_idx, p_idx) 
        
            if param_name == "Wet Mix (dB)" then
                HT.tgen_wm_idx = p_idx
            elseif param_name == "Note" then
                HT.tgen_note_idx = p_idx                
            elseif param_name == "Octave" then
                HT.tgen_octave_idx = p_idx 
            elseif param_name == "Fine Tune (cents)" then
                HT.tgen_cents_idx = p_idx 
            end            
        
        end

        -- # Set up tone generator.
        
        -- Frequency is selected on script init.

        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_note_idx, HT.zones[HT.test_freq_id].note_idx)
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_octave_idx, HT.zones[HT.test_freq_id].octave)
        
        local wm_gain = HT.zones[HT.datum_freq_id].tg_gain or -12
        --reaper.TrackFX_SetNamedConfigParm(HT.r_track, HT.tgen_idx, "Wet Mix (dB)", wm_gain)
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_wm_idx, wm_gain)

        HT.eq_loud_offset = HT.phon_points[HT.test_freq_idx] - HT.phon_curve - 0.4         

        local adj = HT.zones[HT.test_freq_id][HT.gain_lcr]
        
        --GUI.Msg("          HT.datum_gain : " .. HT.datum_gain)                
        --GUI.Msg("      HT.eq_loud_offset : " .. HT.eq_loud_offset)        
        --GUI.Msg("                    adj : " .. adj)

        -- # Set track volume.  
                 
        local g = 10^((HT.datum_gain + HT.eq_loud_offset + adj) / 20)
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", g)  

    else
        reaper.MB("No track to select!", "Whoops!", 0)
    end

end  --<select_track>

--zzzdata
local function show_dataset_in_console()

    local wm_gain = tostring(HT.zones[HT.datum_freq_id].tg_gain)
    local datum_gain = tostring(HT.zones[HT.datum_freq_id].datum_gain)
    
    local msg = "\n---------------------------------------------------------------------\n"

    msg = msg .. "                    -- dh_HearingTest  --\n\n"
    
    msg = msg .. "Profile name: " .. HT.current_profile .. "\n\n"
    
    msg = msg .. "Wet Mix gain : " .. wm_gain .. " ; Datum gain : " .. datum_gain .. "\n\n"
    
    msg = msg .. "    Freq :        Left     Center    Right    LR Gain   LR Cents\n"
    
    msg = msg .. "---------------------------------------------------------------------\n"    
    
    for _, freq in ipairs(HT.freqs) do
    
        local zone = HT.zones[freq]   
    
        if zone.bypass then goto getnext end
    
        local zmsg = ""

        local fstr = string.format("%8d", zone.frequency)
        local zmsg = zmsg .. fstr .. "    "
        
        fstr = string.format("%10.2f", zone.gain_l)
        zmsg = zmsg .. fstr
        
        fstr = string.format("%10.2f", zone.gain_c)
        zmsg = zmsg .. fstr
        
        fstr = string.format("%10.2f", zone.gain_r)
        zmsg = zmsg .. fstr

        fstr = string.format("%10.2f", zone.lr_gain)
        zmsg = zmsg .. fstr
        
        fstr = string.format("%10.2f", zone.lr_cents)
        zmsg = zmsg .. fstr .. "\n\n"
    
        msg = msg .. zmsg
        
        ::getnext::
        
    end
        
    reaper.ShowConsoleMsg(msg .. "\n")

end  --<show_dataset_in_console>


--[===[  This is the Nitty-Gritty here!
   
Alternate between test_freq_id and datum_freq_id.
If I use a second tone gen for datum_freq_id then 

HT.datum_gain (datum_freq gain) is set during calibration. 
  It doesn't get adjusted anytime during test.
  It is considered 0. (Speaker controls set desired volume.)
  
  Say datum is 50db at 1khz.
  196hz is 62db at 50 phon.
  So test gain should be adjusted to +12db
  It should be initialized in Start test set timer.
  
--]===]

--zzzt1  
local function update_timer_1()
     
    -- # PLAYING: Started at state 1: datum_freq, track_ref_vol.
    
    if (TIMER.state == 1) then
    
        -- # SILENCE - Set to state 2: test cycle
        
        --GUI.Msg("\n<<<< TIMER interval 1 end : SILENCE - Set to state 2: set up test cycle")
        
        TIMER.state = 2 
        TIMER.interval = 0.5 
        
        -- # Silence track.
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", 0)
	    
	    -- # Set up next cycle.
	    
        -- # Set to test frequency.
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_note_idx, TIMER.test_note_idx)  
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_octave_idx, TIMER.test_octave)

    elseif (TIMER.state == 2) then  
    
        -- # PLAYS test_freq, test_gain.
 
        --GUI.Msg("\n<<<< TIMER interval 2 end : PLAY test_freq, test_gain")
        --GUI.Msg("        HT.test_gain_adj : " .. HT.test_gain_adj)
        
        TIMER.state = 3
        TIMER.interval = 0.75

        -- # Set to test gain.
        local g = 10^((HT.datum_gain + HT.eq_loud_offset + HT.test_gain_adj) / 20)
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", g)

    elseif (TIMER.state == 3) then  
    
        -- # SILENCE - Set to state 4: set up datum cycle
        
        --GUI.Msg("\n<<<< TIMER interval 3 end : SILENCE - Set to state 4: set up datum cycle")        
        
        TIMER.state = 4
        TIMER.interval = 0.5        
    
        -- # Silence track.
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", 0)
	    
        -- # Set to datum frequency.
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_note_idx, TIMER.datum_note_idx)  
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_octave_idx, TIMER.datum_octave)
          
    elseif (TIMER.state == 4) then  

        -- # PLAYS datum_freq, track_ref_vol.
        
        --GUI.Msg("\n<<<< TIMER interval 4 end : PLAYS datum_freq, track_ref_vol - switch to DATUM")
                
        TIMER.state = 1
        TIMER.interval = 0.75
        
        -- # Un-silence.
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", HT.track_ref_vol)
    
    end
    
    -- # Reset timer for next interval.
    TIMER.start_time = reaper.time_precise()

end  --<update_timer_1>

--zzzt2
local function update_timer_2()

    --GUI.Msg("\n## update_timer_2  ")
 
    -- # PLAYING: Started at state 1: LEFT at 0 cents, test_gain.

    if (TIMER.state == 1) then
    
        -- # SILENCE - Set up for right channel 
             
        --GUI.Msg("\n<<<< TIMER interval 1 end : SILENCE")
        --GUI.Msg("\n<<<< HT.test_freq_id : " .. HT.test_freq_id)        
        
        TIMER.state = 2 
        TIMER.interval = 0.5
        
        -- # Silence track.
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", 0)            
            
        -- # Adjust note fine tune.
        local retval = GUI.elms.knob_LR_Cents.retval
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_cents_idx, retval)
        
        -- # Change pan to right.
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", 1.0)    
        
    elseif (TIMER.state == 2) then
    
        -- # PLAYS right channel.
 
        --GUI.Msg("\n<<<< TIMER interval 2 end : PLAY right channel with adjustments.")      
    
        TIMER.state = 3
        TIMER.interval = 0.75
        
        -- # Set track volume to include knob gain.
        local retval = GUI.elms.knob_LR_Gain.cur_num_val + HT.datum_gain + HT.eq_loud_offset + HT.zones[HT.test_freq_id].gain_l
        local g = 10^(retval / 20)
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", g)         
        
    elseif (TIMER.state == 3) then 
     
        -- # SILENCE - Set to state 4: set to left channel
        
        --GUI.Msg("\n<<<< TIMER interval 3 end : SILENCE - Set to state 4: left channel")        
        
        TIMER.state = 4
        TIMER.interval = 0.5
        
        -- # Silence track.
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", 0)         
    
        -- # Set note to start fine tune.
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_cents_idx, 0)
    
        -- # Change pan to left.
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", -1.0)   
         
    elseif (TIMER.state == 4) then  

        -- # PLAYS left channel.
        
        --GUI.Msg("\n<<<< TIMER interval 4 end : PLAY left channel.")      
                
        TIMER.state = 1
        
        TIMER.interval = 0.75
        
        -- # Set track volume to left.
        local g = 10^((HT.datum_gain + HT.eq_loud_offset + HT.zones[HT.test_freq_id].gain_l) / 20)  
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", g)                 
           
    end
    
    -- Reset timer for next interval.
    TIMER.start_time = reaper.time_precise()

end  --<update_timer_2>


-- This gets called from dh_Main when timer interval reached.

local function update_timer()

    --GUI.Msg("  update_timer caller : " .. TIMER.caller)    

    if TIMER.caller == 1 then
        update_timer_1()
        
    elseif TIMER.caller == 2 then
        update_timer_2()
        
    end

end

--======================================
  ------   Element Functions   ------
--======================================
--zzelemfunc

-- Put your functions here if they are called from a GUI element, e.g., a button click. 
-- esp. if they need to call a function declared earlier.


--======================================
  --------      ELEMENTS      --------
--======================================
--zzelements 

----------------------------------------
------  Import Elements  ------
----------------------------------------
-- # Load the elements contained in an external file. 

loadfile(GUI.script_path .. "dh_HearingTest_ELMS.lua")()

-- # Assign additional data or func to the loaded elements.

GUI.elms.btn_Prefs.func = DHTK.showPrefsWindow

--zzzls
--zzx
-- GUI Builder doesn't save menubox options as they can get quite complex.
-- Therefore it exports with the default {"Option 1", "Option 2", "Option 3", "Option 4'}
-- The correct menu will get assigned later in script init.

--  # Hide the profile layers.

for _, lyr in ipairs(HT.profile_layers) do
    --GUI.Msg("> hide lyr : " .. tostring(lyr))         
    GUI.elms_hide[lyr] = true
end

-- These layers may contain some unused elements.
GUI.elms_hide[50] = true
GUI.elms_hide[51] = true

--======================================
  ------   Method Overrides  ------
--======================================
--zzoverrides 

function GUI.elms.mbx_Tracks:onmouseup()
	GUI.dh_Menubox.onmouseup(self)
	select_track()
end

--zzzfreq
function GUI.elms.mbx_Freqs:onmouseup()

    -- Ignore if test is running.
    if HT.is_running then return end

	GUI.dh_Menubox.onmouseup(self)

	--GUI.Msg("self.curr_opt: " .. self.curr_opt)
	--GUI.Msg("#self.optarray: " .. #self.optarray)	
	
	HT.test_freq_id = self.optarray[self.curr_opt]
	HT.test_freq_idx = self.curr_opt	
        
    local zone = HT.zones[HT.test_freq_id]
        
    -- # Set locked checkbox.
    GUI.elms.chkl_Locked:val(zone.locked)  
    GUI.elms.chkl_Locked:redraw()
    
    -- # Set bypass checkbox.
    GUI.elms.chkl_Bypass:val(zone.bypass)  
    GUI.elms.chkl_Bypass:redraw()   

    -- # Init LR knobs.
    GUI.elms.knob_LR_Gain:val(zone.lr_gain)  
    GUI.elms.knob_LR_Cents:val(zone.lr_cents)  
    
    --!!! Not really necessary.
    GUI.elms.knob_MainTest_Gain:val(HT.zones[HT.test_freq_id][HT.gain_lcr])

    -- # No tone generator found.
    if not HT.tgen_idx then
        --reaper.MB("No tone generator found!", "Whoops!", 0)
        return
    end

	--GUI.Msg("\n#mbx_Freqs:onmouseup ")
	--GUI.Msg("   note_idx : " .. HT.zones[HT.test_freq_id].note_idx)
	--GUI.Msg("   octave : " .. HT.zones[HT.test_freq_id].octave)	
            
    -- # Set tone generator frequency.
    reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_note_idx, HT.zones[HT.test_freq_id].note_idx)
    reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_octave_idx, HT.zones[HT.test_freq_id].octave)    

    -- # Set test gain and track volume.        

    HT.eq_loud_offset = (HT.phon_points[HT.test_freq_idx] - 0.4) - HT.phon_curve    
    
    HT.test_gain_adj = HT.zones[HT.test_freq_id][HT.gain_lcr]
    
    --??? Should I adjust test_gain quieter to start test?  
    --??? Not really necessary here? Will be set at test start.
    local g = 10^((HT.datum_gain + HT.eq_loud_offset + HT.test_gain_adj) / 20)
    reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", g) 

end  --<mbx_Freqs:onmouseup>

-- Loads a profile from selection box.

function GUI.elms.mbx_Profiles:onmouseup()

	GUI.dh_Menubox.onmouseup(self)
	
	HT.current_profile = self.optarray[self.curr_opt]
	
    --GUI.Msg("\n## mbx_Profiles:onmouseup : " .. HT.current_profile)	
	
	load_profile(HT.current_profile)
	
    --GUI.Msg("\n## mbx_Profiles:onmouseup : " .. HT.current_profile)
    --GUI.Msg("     HT.gain_lcr : " .. HT.gain_lcr)        

    HT.zones = HT.profiles[HT.current_profile]
    
    --GUI.Msg("    HT.zones[HT.test_freq_id].lr_gain : " .. HT.zones[HT.test_freq_id].lr_gain)       
    
    -- # Update graph.
    update_graph(false)
    
--zzzprofile
                
    -- # Init LR knobs.
    GUI.elms.knob_LR_Gain:val(HT.zones[HT.test_freq_id].lr_gain)
    GUI.elms.knob_LR_Cents:val(HT.zones[HT.test_freq_id].lr_cents)  

    --!!! Not really necessary.
    GUI.elms.knob_MainTest_Gain:val(HT.zones[HT.test_freq_id][HT.gain_lcr])
    
    --!!! These are getting set in load_profile. 
    local wm_gain = HT.zones[HT.datum_freq_id].tg_gain or -12     
    HT.datum_gain = HT.zones[HT.datum_freq_id].datum_gain or -18
        
    --GUI.Msg("    HT.datum_gain : " .. HT.datum_gain) 
    
    -- # Update tone generator wet mix gain.
    if HT.r_track and HT.tgen_idx then
        --reaper.TrackFX_SetNamedConfigParm(HT.r_track, HT.tgen_idx, "Wet Mix (dB)", wm_gain)
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_wm_idx, wm_gain)
	end

    -- # track volume
    --??? Not really necessary?
	if HT.r_track then    
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", HT.track_ref_vol)  
	end
	
end  --<mbx_Profiles>


function GUI.elms.chkl_TG_Enable:onmouseup()

	GUI.dh_Checklist.onmouseup(self)

	-- # No tone generator found. Abort!
	if not HT.tgen_idx then
	    reaper.MB("No tone generator found!", "Whoops!", 0)
    	return
	end
	
    reaper.TrackFX_SetEnabled(HT.r_track, HT.tgen_idx, self.optsel[1] )
    	
end


-- HT.test_gain_adj used in timer to set gain. 
-- HT.test_gain_adj = HT.zones[HT.test_freq_id][HT.gain_lcr]
-- Knob self.retval is a formatted string,
--  but it works for changing track gain.
-- Added property cur_num_val to knob.

function GUI.elms.knob_MainTest_Gain:ondrag()
	GUI.dh_Knob.ondrag(self)
    --HT.test_gain_adj = self.retval 
    HT.test_gain_adj = self.cur_num_val 
end

--zzzknob
function GUI.elms.knob_MainTest_Gain:onwheel()
	GUI.dh_Knob.onwheel(self)
    --HT.test_gain_adj = self.retval 
    HT.test_gain_adj = self.cur_num_val 
end


function GUI.elms.knob_TG_Gain:ondrag()

	GUI.dh_Knob.ondrag(self)
	
	-- # Set tone generator wet mix gain.
	if HT.r_track and HT.tgen_idx then
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_wm_idx, self.cur_num_val)
        HT.zones[HT.datum_freq_id].tg_gain = self.cur_num_val
    end
    
end


function GUI.elms.knob_TG_Gain:onwheel()

	GUI.dh_Knob.onwheel(self)
	
	-- # Set tone generator wet mix gain.
	if HT.r_track and HT.tgen_idx then
	    reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_wm_idx, self.cur_num_val)
	    HT.zones[HT.datum_freq_id].tg_gain = self.cur_numval
	    --GUI.Msg("    onwheel self.retval : " .. self.retval)                       
	end

end


function GUI.elms.knob_Datum_Gain:ondrag()

	GUI.dh_Knob.ondrag(self)
	
	-- # Set track volume.
	if HT.r_track then
        HT.datum_gain = self.cur_num_val
        HT.zones[HT.datum_freq_id].datum_gain = self.cur_num_val
        local g = 10^(HT.datum_gain / 20)
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", g)  
    end
    
end


function GUI.elms.knob_Datum_Gain:onwheel()

	GUI.dh_Knob.onwheel(self)
	
	-- # Set track volume.
	if HT.r_track then
        HT.datum_gain = self.cur_num_val
        HT.zones[HT.datum_freq_id].datum_gain = self.cur_num_val
        local g = 10^(HT.datum_gain / 20)
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", g)  
    end
    
end


function GUI.elms.chkl_Locked:onmouseup()

    local prev = self.optsel[1]

	GUI.dh_Checklist.onmouseup(self)
	
	local idx, val = GUI.elms.mbx_Freqs:val()
	
    if idx == HT.datum_freq_idx then
        reaper.MB("Cannot unlock datum frequency!", "Whoops!", 0)
        self:val(prev)
        return
    end

    -- # Update zone.
    HT.zones[HT.test_freq_id].locked = self.optsel[1]

end  --<chkl_Locked:onmouseup>


--function GUI.elms.chkl_Bypass:onmouseup()
--	GUI.dh_Checklist.onmouseup(self)
--end


function GUI.elms.radio_Channel:onmouseup()

	GUI.dh_Radio.onmouseup(self)

    -- Set track pan
   
    --GUI.Msg("\n## radio_Channel:onmouseup  ##")
    
    HT.channel= self.retval
    
    --GUI.Msg("      HT.channel : " .. HT.channel)        
    
    HT.gain_lcr = ((self.retval == 1) and "gain_l")
               or ((self.retval == 2) and "gain_c")
               or ((self.retval == 3) and "gain_r")
               
    --GUI.Msg("      HT.gain_lcr : " .. HT.gain_lcr)                       
    
    if HT.r_track then
        local pan = (HT.channel == 1 and -1)
        or (HT.channel == 2 and 0)
        or (HT.channel == 3 and 1)
        
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", pan)    
    
        local tg = HT.zones[HT.test_freq_id][HT.gain_lcr]
        local g = 10^((HT.datum_gain + HT.eq_loud_offset + tg) / 20)
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", g) 
    
    end
    
--zzzknob         
    --!!! Not really necessary.
    GUI.elms.knob_MainTest_Gain:val(HT.zones[HT.test_freq_id][HT.gain_lcr])
    
    -- Changing channels require datapoints to be updated.
    update_graph(false)

end  --<radio_Channel:onmouseup>


function GUI.elms.radio_GraphType:onmouseup()

	GUI.dh_Radio.onmouseup(self)
	
    --GUI.Msg("\n## radio_GraphType:onmouseup  self.retval : " .. self.retval)	
       
    -- # No change.
    if self.retval == HT.graph_type then
        return
    end
    
    -- # Get reference to graph.
    local graph = GUI.elms.graph_Freq  
      
    -- # Set graph params.
    HT.graph_type = self.retval

    if self.retval == 1 then
        --GUI.Msg(">>>  radio_GraphType:onmouseup type : " .. HT.graph_type)
        graph.y_min = 0
        graph.y_max = 100
        graph.y_ref = 50
        graph.ref_points = HT.phon_points
        --graph.grid_x_divs = 23
        graph.grid_y_divs = 8            
        graph.y_labels = y_labels_c

    else
        --GUI.Msg(">>>  radio_GraphType:onmouseup type : " .. HT.graph_type)
        graph.y_min = -6
        graph.y_max = 12
        graph.y_ref = 0
        graph.ref_points = nil -- don't draw phon
        --graph.grid_x_divs = 23
        graph.grid_y_divs = 9                        
        graph.y_labels = y_labels_f
    end

    update_graph(true)

end  --<radio_GraphType:onmouseup>

----------------------------------------
--   Buttons
----------------------------------------

function GUI.elms.btn_Gain_Inc:onmouseup()

	GUI.dh_Button.onmouseup(self)
	
    -- Ignore if test is not running.
    if not HT.is_running then return end
    
    -- Ignore if test freq.
    if HT.test_freq_idx == HT.datum_freq_idx then return end
    
    -- # Increment track volume by factor.
    HT.test_gain_adj = HT.test_gain_adj + HT.gain_adj_step

end

--zzzt1
function GUI.elms.btn_Gain_Dec:onmouseup()

	GUI.dh_Button.onmouseup(self)

    -- Ignore if test is not running.
    if not HT.is_running then return end
    
    -- Ignore if test freq.
    if HT.test_freq_idx == HT.datum_freq_idx then return end
    
    -- # Decrement track volume by factor.
    HT.test_gain_adj = HT.test_gain_adj - HT.gain_adj_step

end
	

function GUI.elms.btn_Start:onmouseup()

	--GUI.Msg("\n## btn_Start:onmouseup  ")
	GUI.dh_Button.onmouseup(self)
	
    -- Ignore if test is running.
    if HT.is_running then return end
    
    -- Ignore if datum freq.
    if HT.test_freq_idx == HT.datum_freq_idx then return end
    
    -- Ignore if test_freq is locked..    
    if HT.zones[HT.test_freq_id].locked then return end

    --GUI.Msg("      HT.test_freq_id : " .. HT.test_freq_id)
    --GUI.Msg("      HT.test_freq_id type : " .. type(HT.test_freq_id))    
    --GUI.Msg("      HT.datum_freq_id : " .. HT.datum_freq_id)    
    --GUI.Msg("      HT.datum_freq_id type : " .. type(HT.datum_freq_id))    
            
    -- # No tone generator found. Abort!
    if not HT.tgen_idx then
        reaper.MB("No tone generator found!", "Whoops!", 0)
        return
    end

    -- # Initialize frequency test. (Tone generator exists.)
    reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_note_idx, TIMER.datum_note_idx)  
    reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_octave_idx, TIMER.datum_octave)    

    --??? Shouldn't need to set pan?

	-- # Set selected channel.
    local pan = ((HT.channel == 1) and -1.0)
             or ((HT.channel == 2) and 0.0)
             or ((HT.channel == 3) and 1.0)	
	
	reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", pan)	
	
	-- # Start at datum track ref volume.
	reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", HT.track_ref_vol) 

    -- # Set initial test freq gain -6db.
    --!!! IMPORTANT: Set it to knob min.
    HT.test_gain_adj = GUI.elms.knob_MainTest_Gain.min

--zzzknob btn_start
    -- # Set knob_MainTest_Gain.
    --   Set it min for test start.
    
    GUI.elms.knob_MainTest_Gain:val(HT.test_gain_adj)
    --GUI.elms.knob_MainTest_Gain:setcurstep(0)
    --GUI.elms.knob_MainTest_Gain:redraw()

    --[=[  TIMER 1	--]=]
    
    -- # Setup timer.
    
    TIMER.caller = 1
    TIMER.interval = 0.75
    TIMER.state = 1
    --TIMER.datum_note_idx   = HT.zones[HT.datum_freq_id].note_idx
    --TIMER.datum_octave = HT.zones[HT.datum_freq_id].octave
    TIMER.test_note_idx = HT.zones[HT.test_freq_id].note_idx
    TIMER.test_octave = HT.zones[HT.test_freq_id].octave
	
	-- # Start test.
	
	-- Set tone generator enabled.	
	reaper.TrackFX_SetEnabled(HT.r_track, HT.tgen_idx, true)
	
	HT.is_running = true
	TIMER.start_time = reaper.time_precise()
	
end  --<btn_Start:onmouseup>


function GUI.elms.btn_Stop:onmouseup()

	--GUI.Msg("\n## btn_Stop:onmouseup  ")
	GUI.dh_Button.onmouseup(self)
	
	-- Ignore if test is not running.
	if not HT.is_running then return end

	-- Ignore if test freq.
    if HT.test_freq_idx == HT.datum_freq_idx then return end

	HT.is_running = false

	-- # Set tone generator to not enabled.
    reaper.TrackFX_SetEnabled(HT.r_track, HT.tgen_idx, false)

--zzzknob btn-stop
	-- # Save gain. 
	--GUI.Msg("\n>>> HT.test_gain_adj : " .. HT.test_gain_adj)
	--GUI.Msg("      type HT.test_gain_adj : " .. type(HT.test_gain_adj)) -- string		
	--GUI.Msg(">   HT.gain_lcr : " .. HT.gain_lcr)

    --!!! Knob retval is a formatted string. Convert it to a number.
	HT.test_gain_adj = tonumber(HT.test_gain_adj)	
	
	HT.zones[HT.test_freq_id][HT.gain_lcr] = HT.test_gain_adj
	
	-- # Make sure tone generator params are returned to test freq.
    reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_note_idx, HT.zones[HT.test_freq_id].note_idx)
    reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_octave_idx, HT.zones[HT.test_freq_id].octave) 

	-- # Update graph.	

	-- data_points has data from selected freq gain/channel.
    -- Only update curr point.
--zzzdp    
	HT.data_points[HT.test_freq_idx] = HT.test_gain_adj
	
	--GUI.Msg(">>   HT.data_points[HT.test_freq_idx] : " .. HT.data_points[HT.test_freq_idx])	
	
	GUI.elms.graph_Freq:redraw()
	
	--??? Reset gain to test gain of selected freq.
	
	
end  --<btn_Stop:onmouseup>


function GUI.elms.btn_LR_Start:onmouseup()

	GUI.dh_Button.onmouseup(self)
	
	--GUI.Msg("\n## btn_LR_Start:onmouseup  ")
	
	-- # No tone generator found. Abort!
	if not HT.tgen_idx then
	    reaper.MB("No tone generator found!", "Whoops!", 0)
	    return
	end

--zzzt2  --zzztest  	
 	-- # Initialize test.
    -- Start in left channel at current test gain as reference.
 	
 	-- # Set pan to left.
 	reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", -1.0)
 	
	--GUI.Msg("      HT.datum_gain : " .. HT.datum_gain) 
	--GUI.Msg("      HT.eq_loud_offset : " .. HT.eq_loud_offset) 	
	--GUI.Msg("      HT.zones[HT.test_freq_id].gain_l : " .. HT.zones[HT.test_freq_id].gain_l) 
	--GUI.Msg("      HT.test_freq_id : " .. HT.test_freq_id) 	

 	-- # Set track volume to test left channel.
 	local g = 10^((HT.datum_gain + HT.eq_loud_offset + HT.zones[HT.test_freq_id].gain_l) / 20)
 	reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", g)
 	
 	-- # Init knobs.
 	local val = HT.zones[HT.test_freq_id].lr_gain or 0 
 	
	--GUI.Msg("    START  val gain : " .. val)  	
 	
 	GUI.elms.knob_LR_Gain:val(val)
 	
 	val = HT.zones[HT.test_freq_id].lr_cents or 0 
 	
	--GUI.Msg("    START  val cents : " .. val)  	
 	
 	GUI.elms.knob_LR_Cents:val(val)
 	
    --[=[  TIMER 2  --]=]
    
    -- # Setup timer.
    
    TIMER.caller = 2
    TIMER.interval = 0.75
    TIMER.state = 1
    --TIMER.cents = 0  -- can get this directly from knob during test

	--GUI.Msg("      TIMER.caller : " .. TIMER.caller)	
	
	-- # START TEST --
	
    -- Set tone generator enabled.	
    reaper.TrackFX_SetEnabled(HT.r_track, HT.tgen_idx, true)
    
    HT.is_running = true
    
    TIMER.start_time = reaper.time_precise()

end  --<btn_LR_Start:onmouseup>

--zzzdata
function GUI.elms.btn_LR_Stop:onmouseup()

	--GUI.Msg("\n## btn_LR_Stop:onmouseup  ")
	GUI.dh_Button.onmouseup(self)
	
	-- Ignore if test is not running.
	if not HT.is_running then return end

    HT.is_running = false	

	-- # Set tone generator to not enabled.
    reaper.TrackFX_SetEnabled(HT.r_track, HT.tgen_idx, false)
	
	-- # Reset fine tune.	
    reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_cents_idx, 0)
	
	-- # Restore original pan. 
	local pan = ((HT.channel == 1) and -1.0)
	         or ((HT.channel == 2) and 0.0)
	         or ((HT.channel == 3) and 1.0)
	
	reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", pan)   
	
	-- # Unmute track (it may have been muted during test).
	reaper.SetMediaTrackInfo_Value(HT.r_track, "B_MUTE", 0)    
	
	-- # Reset gain to test gain of selected freq.
    local g = 10^((HT.datum_gain + HT.eq_loud_offset + HT.test_gain_adj) / 20)	
	reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", g)

--zzzlr		
	--# Store data.
	
    --!!! Knob retval is a formatted string. Convert it to a number.
    local retval = tonumber(GUI.elms.knob_LR_Gain:val())
    
	--GUI.Msg("    STOP  retval gain : " .. retval) 	     	 
	HT.zones[HT.test_freq_id].lr_gain = retval
	
    retval = tonumber(GUI.elms.knob_LR_Cents:val())
	--GUI.Msg("    STOP  retval cents : " .. retval) 	     	      
	HT.zones[HT.test_freq_id].lr_cents = retval

end  --<btn_LR_Stop:onmouseup>


function GUI.elms.btn_Print:onmouseup()

	GUI.dh_Button.onmouseup(self)

    show_dataset_in_console()

end
	
--zzzmbx
function GUI.elms.btn_OpenProfileEditor:onmouseup()

	--GUI.Msg("\n>> btn_OpenProfileEditor:onmouseup : " .. HT.current_profile)
	
	GUI.dh_Button.onmouseup(self)
	
    GUI.Val("lbl_CurrentProfileName", HT.current_profile)   
	
	GUI.elms.tbx_ProfileName:val(HT.current_profile)
	
    -- # Store any visible layers, and then hide them.
    HT.layers_to_restore = {}	
    
    for z, _ in pairs(GUI.elms_list) do
        if not GUI.elms_hide[z] then
            --GUI.Msg("> showPrefsWindow layers_to_restore : " .. tostring(z))          
            table.insert(HT.layers_to_restore, z)
            GUI.elms_hide[z] = true
        end
    end 
    
    -- # Show Profile layers.
    for _, lyr in ipairs(HT.profile_layers) do
        GUI.elms_hide[lyr] = false
    end
    
    GUI.elms.chkl_TG_Enable:val(false)
    
--zzzlr    
    -- # Set knob to tone generator wet mix gain. 
    local wm_gain = HT.zones[HT.datum_freq_id].tg_gain
    GUI.Val("knob_TG_Gain", wm_gain)
    
    -- # Set knob to datum gain.  
    GUI.Val("knob_Datum_Gain", HT.datum_gain)
    
--zzzc  
    -- # Set track volume to datum gain.
    if HT.r_track then   
        local g = 10^(HT.datum_gain / 20)
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", g)
    end

    -- # Set tone generator to datum freq params.
    if HT.tgen_idx then
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_note_idx, HT.zones[HT.datum_freq_id].note_idx)
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_octave_idx, HT.zones[HT.datum_freq_id].octave) 
    end

end

function GUI.elms.btn_CloseProfileEditor:onmouseup()

	--GUI.Msg("\n## btn_CloseProfileEditor:onmouseup  ")
	
	GUI.dh_Button.onmouseup(self)
	
	-- # Hide the profile layers.
    for _, lyr in ipairs(HT.profile_layers) do
        --GUI.Msg("> hide lyr : " .. tostring(lyr))         
        GUI.elms_hide[lyr] = true
    end	
	
    -- # Restore saved layers.
    for _, lyr in ipairs(HT.layers_to_restore) do
        --GUI.Msg("> show lyr : " .. tostring(lyr))             
        GUI.elms_hide[lyr] = false
        GUI.redraw_z[lyr] = true
    end

--zzzlr
    --??? Not really necessary? In case any changes?
    GUI.elms.knob_MainTest_Gain:val(HT.zones[HT.test_freq_id][HT.gain_lcr])
    GUI.elms.knob_LR_Gain:val(HT.zones[HT.test_freq_id].lr_gain) 
    GUI.elms.knob_LR_Cents:val(HT.zones[HT.test_freq_id].lr_cents) 

--zzzc         
    -- # Set tone generator params back to test freq params.    
    if HT.tgen_idx then
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_note_idx, HT.zones[HT.test_freq_id].note_idx)
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_octave_idx, HT.zones[HT.test_freq_id].octave) 
    end
    
    -- # Set track volume to back to test freq gain.
    if HT.r_track then   
        local g = 10^((HT.datum_gain + HT.eq_loud_offset + HT.test_gain_adj) / 20)	
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", g)
    end
    
end

--zzzprofile
function GUI.elms.btn_ProfileSave:onmouseup()

	--GUI.Msg("\n## btn_ProfileSave:onmouseup  ")
	GUI.dh_Button.onmouseup(self)
	
    save_profile()	

end

function GUI.elms.btn_ProfileRename:onmouseup()

	--GUI.Msg("\n## btn_ProfileRename:onmouseup  ")
	GUI.dh_Button.onmouseup(self)
	
    rename_profile()	

end

function GUI.elms.btn_ProfileDelete:onmouseup()

	--GUI.Msg("\n## btn_Profiledelete:onmouseup  ")
	GUI.dh_Button.onmouseup(self)
	
	delete_profile()

end

--zzzreset
function GUI.elms.btn_Reset:onmouseup()

	GUI.dh_Button.onmouseup(self)
	
    local msg = "Do you want to reset the current profile to defaults? /n    " .. HT.current_profile
        
    local retval = reaper.MB(msg, "Warning", 4)
    
--zzzprofile 

	if retval == 6 then
    
        HT.profiles[HT.current_profile] = GUI.table_copy(HT.defaults.zones)

        HT.zones = HT.profiles[HT.current_profile]

        -- # Update graph.
        update_graph(false)
        
        local wm_gain = HT.zones[HT.datum_freq_id].tg_gain or -12     
        HT.datum_gain = HT.zones[HT.datum_freq_id].datum_gain or -18
    
        --GUI.Msg("    HT.datum_gain : " .. HT.datum_gain)           
--zzzknob
        -- # Reset LR knobs.
    
        GUI.elms.knob_LR_Gain:val(wm_gain)
        GUI.elms.knob_LR_Cents:val(HT.datum_gain)  

        -- # Update tone generator wet mix gain.
        if HT.r_track and HT.tgen_idx then
            --reaper.TrackFX_SetNamedConfigParm(HT.r_track, HT.tgen_idx, "Wet Mix (dB)", wm_gain)
            reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_wm_idx, wm_gain)
    	end
--zzzz
        -- # track volume
    	if HT.r_track then    
            reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", HT.track_ref_vol)  
    	end

    end

end

--======================================
  ------  Script Initialize  ------
--======================================
--zzinit

----------------------------------------
--   Non GUI Initialization
----------------------------------------
--zzext

-- Load Prefs first; gets current profile which is needed later.

if reaper.HasExtState(DHTK.EXT_STATE_NAME, "prefs") then
    loadPrefs()
end

-- Get's any saved profiles.
-- If I don't have extstate then be sure to have defaults.
-- They were set earlier. Let's keep them there.

if reaper.HasExtState(DHTK.EXT_STATE_NAME, "profiles") then

    -- Get saved profiles.
    loadExtState()
    
    --GUI.Msg("\n## SCRIPT INIT ext state loaded  ")
    
--zzzprofile   
     
    -- # Update HT.zones. It already has default.

    --!!! This would be where to update profiles.
    
    if HT.profiles[HT.current_profile] then 
    
        -- This will ensure at least default data.
        load_profile(HT.current_profile)
        
        -- This should be good.
        HT.zones = HT.profiles[HT.current_profile]
        
        --!!! Can't do tone gen gain.
        -- Set it in select_track.

        -- # Get track_gain.
        HT.datum_gain = HT.zones[HT.test_freq_id].datum_gain or -18     
              
    end  --<if HT.profiles>

    --  # Build profile names for menubox.

    local profile_names = {}
    
    for k, v in pairs(HT.profiles) do
        table.insert(profile_names, k)
    end

    table.sort(profile_names)
 
    -- # Move 'Working Copy' to top.

    local idx = DHTK.table_index_from_value(profile_names, "Working Copy")
    
    if idx > 1 then 
        local val = table.remove(profile_names, idx)
        
        --!!! Cannot directly insert the removed value.
        local p = val         
        table.insert(profile_names, 1, p)                
    end
     
    HT.profile_names = profile_names
    
    --GUI.Msg("      #profile_names : " .. #profile_names)
    --GUI.Msg("      #HT.profile_names : " .. #HT.profile_names)                                                    
    
    -- # Update menubox.
    
    GUI.elms.mbx_Profiles.optarray = HT.profile_names
    
    idx = DHTK.table_index_from_value(HT.profile_names, HT.current_profile)  -- this works
        
    GUI.elms.mbx_Profiles.curr_opt = idx
        
end  --<HasExtState>

--GUI.Msg("  SCRIPT INIT  HT.zones[HT.test_freq_id].tg_gain : " .. HT.zones[HT.test_freq_id].tg_gain ) 
--GUI.Msg("  SCRIPT INIT  HT.zones[HT.test_freq_id].datum_gain : " .. HT.zones[HT.test_freq_id].datum_gain ) 

HT.test_gain_adj = HT.zones[HT.test_freq_id][HT.gain_lcr]


----------------------------------------
--  GUI Elements Initialization
----------------------------------------

--zzzinit

--GUI.Msg("\n## SCRIPT INIT HT.channel : " .. HT.channel)

GUI.elms.radio_Channel:val(HT.channel)

HT.gain_lcr = ((HT.channel == 1) and "gain_l")
                 or ((HT.channel == 2) and "gain_c")
                 or ((HT.channel == 3) and "gain_r")

-- # Get graph type.

--GUI.Msg("\n## SCRIPT INIT HT.graph_type : " .. HT.graph_type)

if HT.graph_type == 1 then
    GUI.elms.graph_Freq.y_min = 0
    GUI.elms.graph_Freq.y_max = 100
    GUI.elms.graph_Freq.y_ref = 50
    GUI.elms.graph_Freq.grid_y_divs = 8                
    GUI.elms.graph_Freq.y_labels = y_labels_c
    GUI.elms.graph_Freq.ref_points = HT.phon_points        
    GUI.elms.radio_GraphType:val(1)
else
    GUI.elms.graph_Freq.y_min = -6
    GUI.elms.graph_Freq.y_max = 12
    GUI.elms.graph_Freq.y_ref = 0
    GUI.elms.graph_Freq.grid_y_divs = 9                    
    GUI.elms.graph_Freq.y_labels = y_labels_f
    GUI.elms.graph_Freq.ref_points = nil    
    GUI.elms.radio_GraphType:val(2)
end

GUI.elms.graph_Freq.grid_x_divs = 26                    
GUI.elms.graph_Freq.x_labels = x_labels

--zzdata
-- This will update HT.data_points.
update_data_points()
GUI.elms.graph_Freq.data_points = HT.data_points

--GUI.Msg("HT.freqs is : " .. HT.freqs[1])
--GUI.Msg("HT.zones.frequency is : " .. HT.zones[1].frequency)

GUI.elms.mbx_Freqs.optarray = HT.freqs
HT.test_freq_idx = GUI.table_find(HT.freqs, HT.test_freq_id)
GUI.elms.mbx_Freqs.curr_opt = HT.test_freq_idx

GUI.elms.mbx_Tracks.optarray = get_track_names()

--!!! Hopefully the text will be blank upon init.
GUI.elms.mbx_Tracks.curr_opt = 0

GUI.elms.chkl_Locked:val(HT.zones[HT.test_freq_id].locked)

GUI.elms.chkl_Bypass:val(HT.zones[HT.test_freq_id].bypass)

--zzzknob
--??? Not really necessary.
GUI.elms.knob_MainTest_Gain:val( HT.zones[HT.test_freq_id][HT.gain_lcr])
GUI.elms.knob_LR_Gain:val(HT.zones[HT.test_freq_id].lr_gain) 
GUI.elms.knob_LR_Cents:val(HT.zones[HT.test_freq_id].lr_cents) 

----------------------------------------
--!!! DO NOT REMOVE.
DHTK.init_scale_elms()

--======================================
  --------      EXIT      --------
--======================================
--zzexit
-- Code to execute before window closes, such as saving project states.

local function Exit()
    --!!! Necessary
    DHTK.saveWindowSettings()

    saveExtState()
    
end 

-- Calls Exit function when script is ending.
reaper.atexit(Exit)

--======================================
  ------   MAIN LOOP <dhMain>   ------
--======================================
--zzmain  --zzzt1

local function dhMain()

    if HT.is_running then
        if reaper.time_precise() > TIMER.start_time + TIMER.interval then 
            update_timer()
        end
    end

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