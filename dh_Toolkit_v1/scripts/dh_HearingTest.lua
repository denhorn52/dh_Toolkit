-- dh_HearingTest.lua 

-- version 1.0 
-- Author: Dennis R. Horn
-- Modified Date: 20261009

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
--   Comments starting with --zzx denote code which can possibly be removed.
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

--GUI.name = "dh_HearingTest v1.0"

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
--[==[

radio_Channel; also Test 1 panning?
--??? Shoulg I be using 1 or -1 ?
-- Extremes might have extreme gain falloff?  

Test 1 compares datum_vol to test_ref_vol per channel.
  Should datum be panned for center test? 
  
Test 2 compares panned datum_vol to test_vol with pan.

test_ref_vol was used in Test 2 for calibration of test freq.
  It may get eliminated as unnecessary. 
                
--]=]
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
Tone generator wet mix gain gets set up before tests.
This is the reference signal.
Default is -12dBFS (decibels below full scale). 

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
reference frequency. Let's call this HT.eq_loud_gain.

HT.test_gain_adj is the adjustment to HT.eq_loud_gain to achieve 
equal loudness. It is per frequency. This is the number that 
will be stored in the dataset (for Test1).

HT.datum_gain: track gain of datum frequecy (fixed per test)
HT.eq_loud_gain: gain of test frequency relative to datum_gain
HT.test_gain_adj: gain adj required to bring test frequency 
   to equal loudness with datum frequency.
   
Test 1 can test left, center, and right pan separately.
Results suggest eq adjustments to be applied to mixes to achieve 
perception as compared to someone with normal hearing.
The eq should be the last plugin in the mix.
Of course, this eq needs to be disabled before rendering output.
  
Test 2 uses the test tone with panning to achieve perceived 
equal loudness at center. The results will be two separate 
gain values, left and right which should be applied to two 
separate eqs, one on left track, one on the right track.

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
  
-- 196hz has phon level of 70db above 1Khz ref of 60
-- Subtract 60 to get +10 ref
-- I'm using 1047 which is +0.3 to 0.4db  
--   so in essence I'm using a reference of 60.4
-- phon_ref_level is curve point minus 60.4

-- gain generally refers to values in decibels.
-- volume generally refers to track value:
--   0=-inf, 0.5=-6dB, 1=+0dB, 2=+6dB, 4=+12dB

--]==]

--======================================
  --------      My Data      --------
--======================================
--zzdata 

HT = {}

HT.PROJECT, HT.PROJECT_NAME = reaper.EnumProjects(-1)

GUI.name = "dh_HearingTest v1.0  Project : " .. HT.PROJECT_NAME

HT.r_track = nil          -- reference to selected track
HT.tgen_idx = nil         -- reference to tone generator
HT.tgen_guid = nil        -- GUID of tone generator
HT.eq_idx = nil           -- reference to ReaEQ

-- References to tone generator parameters.

HT.tgen_wm_idx = nil      -- index of wet mix parameter
HT.tgen_note_idx = nil    -- index of note parameter
HT.tgen_octave_idx = nil  -- index of octave parameter
HT.tgen_cents_idx = nil   -- index of cents parameter

-- This contains the default dataset used for tests.
HT.defaults = require "dh_HearingTest_data"

-- The freqs for the tests.
HT.freqs = HT.defaults.frequencies

-- Container for all profiles.
-- Each profile is a container with test freq parameters 
--   and test results. 
-- Initialize with a default profile.
-- (Copy so as to leave defaults intact.)

HT.profiles = {
  ['Working Copy'] = GUI.table_copy(HT.defaults.zones)
}
HT.curr_profile_name = 'Working Copy'

-- Convenience reference, initially defaults.
HT.zones = HT.profiles[HT.curr_profile_name]

-- This will be used by Profiles menubox.
-- May be populated with additional profiles during init.
HT.profile_names = {"Working Copy"}

-- Datum parameters.
HT.datum_freq_id  = '1047'-- lookup value for selected datum frequency (fixed)
HT.datum_freq_idx = 12    -- lookup value for reference frequency

-- Initial test tone default values. 
--zzztg
HT.tg_gain = -12          -- tone generator wet mix gain
HT.datum_gain = -18       -- track gain of datum frequecy in dB (per profile)
HT.datum_vol = 10^(HT.datum_gain / 20)  -- 1 is 0 on slider (test reference). 
HT.datum_pan = 0          -- range -1  0  +1

-- Test parameters.

HT.phon_curve = 80        -- equal loudness dataset 

HT.test_freq_id  = '1047' -- lookup value for selected frequency
HT.test_freq_idx = 12     -- index in HT.freqs
HT.eq_loud_gain = 0       -- gain of test frequency relative to datum gain to achieve eq loud
HT.test_gain_adj = 0      -- adjustment to eq_loud_offset to achieve equal loudness

-- True when a test is running.
HT.is_running = false

-- Holds channel used for Test 1.
HT.channel = 2            -- 1: left, 2: center, 3: right 
  
-- Used for Test 1 results.
HT.gain_lcr = "gain_c"    -- "gain_l", "gain_c", "gain_r"

-- Used for Test 2 calcs and results.
HT.datum_vol_left  = 10^(HT.datum_gain / 20) * 0.70711
HT.datum_vol_right = 10^(HT.datum_gain / 20) * 0.70711
HT.test_pan = 0    -- Test2 pan, used to center test tone
HT.test_vol = 0    -- Test2 total track volume

--??? May not need these next three.
-- Not if I'm using centered data for calcs.
-- These were used when calibrating test_ref freq.
HT.test_ref_vol = 0         -- used for test 2
HT.test_ref_vol_left = 0    -- used for test 2
HT.test_ref_vol_right = 0   -- used for test 2
HT.test_ref_pan = 0         -- used for test 2

--??? No longer using? Was used with buttons.
--HT.gain_adj_step = 1      -- step amount to adjust gain when using buttons

--zzx !!! This should get loaded from file (in elems section).
--HT.profile_layers = {51,52,53,54,55,56,57,58,59,60,}  -- set as built in GUI Builder

-- For graph display. 
HT.phon_points = HT.defaults.phon_80
HT.data_points = {}   -- used for Test1 and Test2
HT.data_points2 = {}  -- secondary set for Test2 graph display.

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

--zzgraph
y_labels_c = {
  {2, "75"}, 
  {4, "50"}, 
  {6, "25"}, 
}

y_labels_f = {
  {2, "16"},
  {4, "12"},
  {6, "8"}, 
  {8, "4"},
  {10, "0"},
  {12, "-4"},
  --{3, "12"},
  --{5, "8"},
  --{7, "4"}, 
  --{9, "0"},
  --{2, "8"},
  --{4, "4"}, 
  --{6, "0"},   
}

--zztimer  --zzztm
-- Timer defaults.

TIMER = {}
TIMER.start_time = 0
TIMER.interval = 1        -- seconds
TIMER.caller = 1          -- 1: Test1, 2: Test2, 3: LR Test
TIMER.state = 1
TIMER.count = 0
TIMER.end_count = 5
-- datum won't change
TIMER.datum_note_idx = 3  --"C"
TIMER.datum_octave = 1
-- test will change based on frequency. Set in test.
TIMER.test_note_idx = 3
TIMER.test_octave = -4

-- used for lr test 
TIMER.cents = 0

--======================================
  ------     My Functions    --------
--======================================
--zzfunc

--zzprefs  
local function savePrefs()

    local prefs = {}
    prefs.channel = HT.channel
    prefs.test_freq_id = HT.test_freq_id
    prefs.current_profile = HT.curr_profile_name 
    prefs.test_type = GUI.Val("radio_SelectTest") 
    
    --GUI.Msg("    savePrefs test_type : " .. prefs.test_type)
    
    json_string = json.encode(prefs)
    
    reaper.SetExtState(DHTK.EXT_STATE_NAME, "prefs", json_string, true)
    
    json_string = nil    

end


local function loadPrefs()

    --GUI.Msg("\n##  loadPrefs ## ")
    
    local json_string = reaper.GetExtState(DHTK.EXT_STATE_NAME, "prefs")
    
    --GUI.Msg("    loadPrefs PREFS json_string :\n " .. json_string)

    local prefs = json.decode(json_string) -- should return Lua table

    if type(prefs) == "table" and DHTK.hash_table_length(prefs) > 0 then
        if prefs.channel then HT.channel = prefs.channel end
        if prefs.test_freq_id then HT.test_freq_id = prefs.test_freq_id end
        if prefs.current_profile then HT.curr_profile_name = prefs.current_profile end
        if prefs.test_type then 
            GUI.Val("radio_SelectTest", prefs.test_type) 
        else
            GUI.Val("radio_SelectTest", 2) -- default
        end
        --GUI.Msg("    loadPrefs test_type : " .. prefs.test_type)
    end

    json_string = nil
    
end  --<loadPrefs>

-- A profile is a set of freqs. with their assoc. data.
-- HT.profiles is a table of all profiles 
--   (which are loaded on script start).
-- There is possibility that a profile lacks certain data.
-- This ensures at least a default value exists for each item.
-- @param profile: string - profile name or reset.

-- ## THIS DOES ALL THE HEAVY LIFTING ##

local function load_profile(profile)

    --GUI.Msg("\n## load_profile ## ")

    local reset = (profile == "reset")
    
    --GUI.Msg("    reset : " .. tostring(reset)) 
    
    if reset then
        profile = HT.curr_profile_name
    end
    
    -- Profile should exist. Notify if not???
    if not HT.profiles[profile] then return end

    --GUI.Msg("    profile : " .. profile)
    
    -- # Start with default.
    local tmp = GUI.table_copy(HT.defaults.zones)

    if not reset then

        for _, freq in ipairs(HT.freqs) do
    
            local pdata = HT.profiles[profile][freq]

            if pdata.locked then tmp[freq].locked = pdata.locked end 
            if pdata.bypass then tmp[freq].bypass = pdata.bypass end
            
            if pdata.gain_l then tmp[freq].gain_l = pdata.gain_l end 
            if pdata.gain_c then tmp[freq].gain_c = pdata.gain_c end 
            if pdata.gain_r then tmp[freq].gain_r = pdata.gain_r end 
            
            if pdata.test_ref_pan then tmp[freq].test_ref_pan = pdata.test_ref_pan end 
            if pdata.test_gain_adj then tmp[freq].test_gain_adj = pdata.test_gain_adj end 
            if pdata.test_pan then tmp[freq].test_pan = pdata.test_pan end 
            if pdata.gain2_l then tmp[freq].gain2_l = pdata.gain2_l end 
            if pdata.gain2_r then tmp[freq].gain2_r = pdata.gain2_r end 
            
            if pdata.lr_gain then tmp[freq].lr_gain = pdata.lr_gain end 
            if pdata.lr_cents then tmp[freq].lr_cents = pdata.lr_cents end 

        end
        
    end
        
    -- # Get calibration parameters stored in datum freq.
    
    local d_zone = tmp[HT.datum_freq_id]
    local p_zone = HT.profiles[profile][HT.datum_freq_id]
    
    if not reset then
        if p_zone.phon_curve then d_zone.phon_curve = p_zone.phon_curve end
        if p_zone.datum_pan then d_zone.datum_pan = p_zone.datum_pan end
        if p_zone.datum_gain then d_zone.datum_gain = p_zone.datum_gain end
        if p_zone.tg_gain then d_zone.tg_gain = p_zone.tg_gain end
    end

    HT.phon_curve = d_zone.phon_curve
    HT.datum_pan  = d_zone.datum_pan
    HT.datum_gain = d_zone.datum_gain
    HT.datum_vol = 10^(HT.datum_gain / 20)
    HT.tg_gain    = d_zone.tg_gain

--zzzp load_profile

    -- # Update profile references.

    HT.profiles[profile] = tmp 
    HT.zones = HT.profiles[profile]
    HT.curr_profile_name = profile
    
    -- # Update GUI elements.

    --!!! Calibration elements are updated when opening profile editor.
    update_graph(GUI.Val("radio_SelectTest"))
    --local test_type = GUI.Val("radio_SelectTest")      
    --update_graph(test_type)
    
    -- # Update GUI elements, whether visible or not.
    --??? Redundant? They will be updated on test start?
    
    local zone = HT.zones[HT.test_freq_id]
    
    GUI.elms.knob_Test1_Gain:val(zone[HT.gain_lcr]) 
    --zzx  
	GUI.elms.knob_Test2_Calibrate:val(zone.test_ref_pan)  
    GUI.elms.knob_Test2_Gain:val(zone.test_gain_adj)   
    GUI.elms.knob_Test2_Pan:val(zone.test_pan) 
    GUI.elms.knob_LR_Gain:val(zone.lr_gain)
    GUI.elms.knob_LR_Cents:val(zone.lr_cents) 
    
    -- # Update reaper.

    if HT.r_track then   
    
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", HT.datum_vol)
        
        -- # Set track pan depending on test.
        local pan
        
        if (GUI.Val("radio_TestType") == 2) then
            pan = HT.datum_pan
        else
            pan = ((HT.channel == 1) and -1.0)
               or ((HT.channel == 2) and 0.0)
               or ((HT.channel == 3) and 1.0)
        end	
        
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", HT.datum_pan)
        
    end
    
    -- # Set tone generator to datum freq params.
    if HT.tgen_idx then
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_note_idx, HT.zones[HT.datum_freq_id].note_idx)
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_octave_idx, HT.zones[HT.datum_freq_id].octave) 
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_cents_idx, 0) 
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_wm_idx, HT.tg_gain)
    end
        
end

--zzprofile
-- Adds/updates profile in HT.profiles, and saves it to extstate.

local function save_profile()  

    --GUI.Msg("\n## save_profile ## ")
    
    local tbx_name = GUI.elms.tbx_ProfileName.retval

    -- # Trim leading and trailing whitespace.
    local profile_name = string.gsub(tbx_name, "^%s*(.-)%s*$", "%1")

    -- Make sure profile_name is legit.
    -- Should do more validating ???
    
    if (not profile_name) or (#profile_name < 1) then
        reaper.MB("Enter a name for the profile!", "Whoops!", 0)
        return
    end
    
    -- Disregard if 'Working Copy'.
    if profile_name == 'Working Copy' then 
        reaper.MB("Cannot save to 'Working Copy'!", "Whoops!", 0)    
        return
    end    
    
    -- # Overwrite (save) existing current profile.
    
    local is_new_profile = true
    
    if profile_name == HT.curr_profile_name then
    
        local msg = "Profile already exists! Overwrite?"

        local retval = reaper.MB(msg, "Warning", 4)
    
	    if retval == 6 then
	        is_new_profile = false
        else	    
	        return 
	    end   
    
    end
        
    -- # Add profile to profiles.
    --  HT.zones has the current profile to be saved.
    --  If new will add new profile.
    --  If existing will overwite existing.

    if is_new_profile then
    
        -- # Update profiles table.
        -- Must copy it, not just assign.
        
        HT.profiles[profile_name] = GUI.table_copy(HT.zones)
        HT.zones = HT.profiles[profile_name]
        HT.curr_profile_name = profile_name
        GUI.Val("lbl_CurrentProfileName", HT.curr_profile_name)   
    
        -- # Update profile names list.
        
        table.insert(HT.profile_names, profile_name)
        table.sort(HT.profile_names)    
        
        -- # Move "Working Copy" to top.
        -- (Sorting moves "Working Copy" near bottom of list.)
        
        local idx = DHTK.table_index_from_value(HT.profile_names, "Working Copy")
        local item = table.remove(HT.profile_names, idx)
        table.insert(HT.profile_names, 1, item)
        
        -- # Update menubox selection.
        
        idx = DHTK.table_index_from_value(HT.profile_names, HT.curr_profile_name)  -- this works
        GUI.elms.mbx_Profiles.curr_opt = idx
        GUI.elms.mbx_Profiles:redraw()
        
    end

    -- # Save to projextstate.
    local json_str = json.encode(HT.profiles)
    reaper.SetProjExtState(0, 'dh_HearingTest', 'profiles', json_string)    
        
end  --<save_profile>


local function rename_profile()

    local tbx_name = GUI.elms.tbx_ProfileName.retval 
        
    -- # Trim leading and trailing whitespace.
    local new_profile_name = string.gsub(tbx_name, "^%s*(.-)%s*$", "%1")

    -- Make sure profile_name is legit.
    -- Should do more validating???
    
    if (not new_profile_name) or #new_profile_name < 1 then
        reaper.MB("Enter a name for the profile!", "Whoops!", 0)
        return
    end
    
    -- No need to save if current profile.
    if new_profile_name == HT.curr_profile_name then 
        reaper.MB("Profile already exists!", "Whoops!", 0)    
        return
    end
        
    -- Disregard if 'Working Copy'.
    if HT.curr_profile_name == 'Working Copy' then 
        reaper.MB("Cannot rename 'Working Copy'!", "Whoops!", 0)    
        return
    end
    
    -- Disregard if renaming to 'Working Copy'.
    if new_profile_name == 'Working Copy' then 
        reaper.MB("Cannot rename to 'Working Copy'!", "Whoops!", 0)    
        return
    end        
--zzzname    
    -- # Update profile table.
        
    HT.profiles[new_profile_name] = HT.profiles[HT.curr_profile_name]
    HT.profiles[HT.curr_profile_name] = nil
    
    -- # Point zones to new profile
    HT.zones = HT.profiles[new_profile_name]

    -- # Update profile names list.

    local idx = DHTK.table_index_from_value(HT.profile_names, HT.curr_profile_name)
    table.remove(HT.profile_names, idx)
    table.insert(HT.profile_names, new_profile_name)
    table.sort(HT.profile_names)    
    
    -- # Move "Working Copy" to top.
    
    idx = DHTK.table_index_from_value(HT.profile_names, "Working Copy")
    local item = table.remove(HT.profile_names, idx)
    table.insert(HT.profile_names, 1, item)

    -- # Update menubox.
    
    HT.curr_profile_name = new_profile_name
    GUI.Val("lbl_CurrentProfileName", HT.curr_profile_name)   
    
    idx = DHTK.table_index_from_value(HT.profile_names, HT.curr_profile_name)  -- this works
    GUI.elms.mbx_Profiles.curr_opt = idx
    GUI.elms.mbx_Profiles:redraw()

    -- # Save to projextstate.
    local json_str = json.encode(HT.profiles)
    reaper.SetProjExtState(0, 'dh_HearingTest', 'profiles', json_string)    

end  --<rename_profile>

--zzgraph
 
--@param: pointtype - name of a freq test value

local function update_data_points(pointtype)

    local pointset = {}

    for i, freq in ipairs(HT.freqs) do 
    
        local zone = HT.zones[freq]
        local val = zone[pointtype]
        
        table.insert(pointset, val)

    end
    
    return pointset
    
end  --<update_data_points>

--zzy  --zzug
-- Use when changing graph yype.
-- Test 1 uses HT.data_points.
-- Test 2 uses HT.data_points and HT.data_points2.
-- Phon curve uses only HT.phon_points.
--!!! If not using phon curve then don't need to set grid params.
--!!! Can't be local (called in an earlier function?)

function update_graph(graph_type)

    local graph_type = graph_type or GUI.Val("radio_SelectTest")
       
    if graph_type == 1 then  -- Test 1 linear
        GUI.elms.graph_Freq.y_min = -8
        GUI.elms.graph_Freq.y_max = 20
        GUI.elms.graph_Freq.y_ref = 0
        GUI.elms.graph_Freq.grid_y_divs = 14  --9                    
        GUI.elms.graph_Freq.y_labels = y_labels_f

        GUI.elms.graph_Freq.ref_points = nil  
        HT.data_points = update_data_points(HT.gain_lcr)
        GUI.elms.graph_Freq.data_points = HT.data_points
        GUI.elms.graph_Freq.data_points2 = nil
        
        --GUI.Msg("\n  UPDATE GRAPH datapoint freq val : " .. HT.data_points[7])
        
    elseif graph_type == 2 then  -- Test 2
        GUI.elms.graph_Freq.y_min = -8
        GUI.elms.graph_Freq.y_max = 20
        GUI.elms.graph_Freq.y_ref = 0
        GUI.elms.graph_Freq.grid_y_divs = 14  --9                    
        GUI.elms.graph_Freq.y_labels = y_labels_f
        
        GUI.elms.graph_Freq.ref_points = nil  
        HT.data_points = update_data_points("gain2_l")
        GUI.elms.graph_Freq.data_points = HT.data_points
        HT.data_points2 = update_data_points("gain2_r")
        GUI.elms.graph_Freq.data_points2 = HT.data_points2
        
    elseif graph_type == 3 then  -- Phon curve
        GUI.elms.graph_Freq.y_min = 0
        GUI.elms.graph_Freq.y_max = 100
        GUI.elms.graph_Freq.y_ref = 50
        GUI.elms.graph_Freq.grid_y_divs = 8                
        GUI.elms.graph_Freq.y_labels = y_labels_c
        
        GUI.elms.graph_Freq.ref_points = HT.phon_points 
        GUI.elms.graph_Freq.data_points = nil
        GUI.elms.graph_Freq.data_points2 = nil
        
    end

    --??? Redundant?
    GUI.elms.graph_Freq.grid_x_divs = 26                    
    GUI.elms.graph_Freq.x_labels = x_labels
--zzt1                
    GUI.elms.graph_Freq:init()
    GUI.elms.graph_Freq:redraw()

end  --<update_graph>


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

--zzztk
-- Called from mbx_Tracks:onmouseup using mbx index.
-- Called during script init using iteration index.
-- @param track_idx: integer - reaper track index (0 based)

local function select_track(track_idx, hide_msg)

    HT.tgen_idx = nil
    HT.tgen_guid = nil    
    
--zzzx
    --[=[
	local track_idx 

    if trk_idx then
        track_idx = trk_idx
    else
        track_idx = GUI.elms.mbx_Tracks.curr_opt - 1
    end
    --]=]

    -- # Get track.
    local r_track = reaper.GetTrack(0, track_idx)
    
    if r_track then
    
        -- # Get track and store reference.
    
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
            if not hide_msg then
                reaper.MB("No tone generator on selected track!", "Whoops!", 0)
            end
            return
        end
        
        -- TONE GENERATOR FOUND --
        
        --GUI.Msg("\n-- TONE GENERATOR FOUND --\n")
--zzztg
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
--zzztg
        -- # Set up tone generator to datum.

        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_note_idx, HT.zones[HT.datum_freq_id].note_idx)
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_octave_idx, HT.zones[HT.datum_freq_id].octave)
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_octave_idx, 0)
        --reaper.TrackFX_SetNamedConfigParm(HT.r_track, HT.tgen_idx, "Wet Mix (dB)", HT.tg_gain)
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_wm_idx, HT.tg_gain)

        -- # Set track volume.  

        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", HT.datum_vol)  

        -- # Set track pan depending on test.
        local pan
        
        if (GUI.Val("radio_TestType") == 2) then
            pan = HT.datum_pan
        else
            pan = ((HT.channel == 1) and -1.0)
               or ((HT.channel == 2) and 0.0)
               or ((HT.channel == 3) and 1.0)
        end	
        
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", pan)

        -- If we're at this point then tg is found.
        return true

    else
        reaper.MB("No track to select!", "Whoops!", 0)
    end

end  --<select_track>

--zzdata
local function show_dataset_in_console()

    local wm_gain = tostring(HT.zones[HT.datum_freq_id].tg_gain)
    local datum_gain = tostring(HT.zones[HT.datum_freq_id].datum_gain)
    
    local msg = "\n-------------------------------------------------------------------------------------\n"

    msg = msg .. "                    -- dh_HearingTest  --\n\n"
    
    msg = msg .. "Profile name: " .. HT.curr_profile_name .. "\n\n"
    
    msg = msg .. "Wet Mix gain : " .. wm_gain .. " ; Datum gain : " .. datum_gain .. "\n\n"
    
    msg = msg .. "    Freq :        Left     Center    Right    Left 2   Right 2    LR Gain   LR Cents\n"
    
    msg = msg .. "-------------------------------------------------------------------------------------\n"    
    
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
        
        fstr = string.format("%10.2f", zone.gain2_l)
        zmsg = zmsg .. fstr
        
        fstr = string.format("%10.2f", zone.gain2_r)
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


--[===[ 
 
This is the Nitty-Gritty here!
   
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

--zzt1  
local function update_timer_1()
     
    -- # PLAYING: Started at state 1: datum_freq, datum_vol.
    
    if (TIMER.state == 1) then
    
        -- # State 2: SILENCE - prepare for test freq cycle
        
        --GUI.Msg("\n<<<< State 2: SILENCE - set up test freq cycle")
        
        TIMER.state = 2 
        TIMER.interval = 0.5 
        
        -- # Silence track.
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", 0)
	    
	    -- # Set up next cycle.
	    
        -- # Set up test frequency.
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_note_idx, TIMER.test_note_idx)  
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_octave_idx, TIMER.test_octave)

    elseif (TIMER.state == 2) then  
    
        -- # State 3: PLAYS test_freq, test_gain.
 
        --GUI.Msg("\n<<<< State 3: PLAY test_freq, test_gain")
        --GUI.Msg("        HT.datum_gain : " .. HT.datum_gain)        
        --GUI.Msg("        HT.eq_loud_gain : " .. HT.eq_loud_gain)
        --GUI.Msg("        HT.test_gain_adj : " .. HT.test_gain_adj)        
        
        TIMER.state = 3
        TIMER.interval = 0.5

        -- # Set to test gain.
        local g = 10^((HT.datum_gain + HT.eq_loud_gain + HT.test_gain_adj) / 20)
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", g)

    elseif (TIMER.state == 3) then  
    
        -- # SILENCE - State 4: set up datum cycle
        
        --GUI.Msg("\n<<<< State 4: SILENCE - set up datum freq cycle")        
        
        TIMER.state = 4
        TIMER.interval = 0.75        
    
        -- # Silence track.
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", 0)
	    
        -- # Set to datum frequency.
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_note_idx, TIMER.datum_note_idx)  
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_octave_idx, TIMER.datum_octave)
          
    elseif (TIMER.state == 4) then  

        -- # PLAYS datum_freq, datum_vol.
        
        --GUI.Msg("\n<<<< State 1: PLAYS datum_freq, datum_vol.")
                
        TIMER.state = 1
        TIMER.interval = 0.5
        
        -- # Un-silence.
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", HT.datum_vol)
    
    end
    
    -- # Reset timer for next interval.
    TIMER.start_time = reaper.time_precise()

end  --<update_timer_1>


local function update_timer_2()

    --GUI.Msg("\n#### update_timer_2  ")
 
    -- # PLAYING: Started at state 1: datum_freq, datum_pan, datum_vol.

    if (TIMER.state == 1) then
    
        -- # State 2: SILENCE - Set up to play test freq cycle.
             
        --GUI.Msg("\n<<<< State 2: SILENCE - Set up to play test freq cycle.")
        --GUI.Msg("\n<<<< HT.test_freq_id : " .. HT.test_freq_id)        
        
        TIMER.state = 2 
        TIMER.interval = 0.5
        
        -- # Silence track.
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", 0)            

        -- # Set up test frequency for next cycle.
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_note_idx, TIMER.test_note_idx)  
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_octave_idx, TIMER.test_octave)
        
        -- # Set pan. Setting here otherwise it seems to lag.
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", HT.test_pan)    
                
    elseif (TIMER.state == 2) then

        -- # State 3: PLAYS test_freq, test_pan, test_vol.
 
        --GUI.Msg("\n<<<< State 3: PLAYS test_freq, test_pan, test_vol.")      
    
        TIMER.state = 3
        TIMER.interval = 0.5
--zzt2a update_timer_2                 
        -- # Set track volume to include knob gain.
        HT.test_vol = 10^((HT.datum_gain + HT.eq_loud_gain + HT.test_gain_adj) / 20)
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", HT.test_vol)         

    elseif (TIMER.state == 3) then 
     
        -- # State 4: SILENCE - Set up to play datum freq cycle.
        
        --GUI.Msg("\n<<<< State 4: SILENCE - Set up to play datum freq cycle.")        

        TIMER.state = 4
        TIMER.interval = 0.75
        
        -- # Silence track.
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", 0)         

        -- # Set to datum frequency.
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_note_idx, TIMER.datum_note_idx)  
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_octave_idx, TIMER.datum_octave)
    
        -- # Set pan to test_ref_pan.
        --reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", HT.test_ref_pan)   
        
        -- # Set pan to datum_pan.
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", HT.datum_pan)   
         
    elseif (TIMER.state == 4) then  

        -- # State 1: PLAYS datum_freq, datum_pan, datum_vol.
        
        --GUI.Msg("\n<<<< State 1: PLAYS datum_freq, datum_pan, datum_vol.")      
                
        TIMER.state = 1
        
        TIMER.interval = 0.5
        
        -- # Set track volume to datum gain.
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", HT.datum_vol)                 
           
    end
    
    -- Reset timer for next interval.
    TIMER.start_time = reaper.time_precise()

end  --<update_timer_2>

--zzt3
local function update_timer_3()

    --GUI.Msg("\n## update_timer_3>  ")
 
    -- # PLAYING: Started at state 1: LEFT at 0 cents, test_gain.

    if (TIMER.state == 1) then
    
        -- # SILENCE - Set up for right channel 
             
        --GUI.Msg("\n<<<< State 2: SILENCE - set up to play right channel.")
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
 
        --GUI.Msg("\n<<<< State 3: PLAY right channel with adjustments.")      
    
        TIMER.state = 3
        TIMER.interval = 0.75
        
        -- # Set track volume to include knob gain.
        local retval = GUI.elms.knob_LR_Gain.cur_num_val + HT.datum_gain + HT.eq_loud_gain + HT.zones[HT.test_freq_id].gain_l
        local g = 10^(retval / 20)
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", g)         
        
    elseif (TIMER.state == 3) then 
     
        -- # SILENCE - Set to state 4: set up to play left channel
        
        --GUI.Msg("\n<<<< State 4: SILENCE - Set up to play left channel")        
        
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
        
        --GUI.Msg("\n<<<< State 1: PLAY left channel.")      
                
        TIMER.state = 1
        
        TIMER.interval = 0.75
        
        -- # Set track volume to left.
        local g = 10^((HT.datum_gain + HT.eq_loud_gain + HT.zones[HT.test_freq_id].gain_l) / 20)  
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", g)                 
           
    end
    
    -- Reset timer for next interval.
    TIMER.start_time = reaper.time_precise()

end  --<update_timer_3>


-- This gets called from dh_Main when timer interval reached.

local function update_timer()

    --GUI.Msg("  update_timer caller : " .. TIMER.caller)    

    if TIMER.caller == 1 then
        update_timer_1()
        
    elseif TIMER.caller == 2 then
        update_timer_2()
        
    elseif TIMER.caller == 3 then
        update_timer_3()
        
    end

end

--======================================
  ------   Element Functions   ------
--======================================

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

-- GUI Builder doesn't save menubox options as they can get quite complex.
-- Therefore it exports with the default {"Option 1", "Option 2", "Option 3", "Option 4'}
-- The correct menu will get assigned later in script init.

--zzlyr
-- # Assign layersets to vars.

if GB_Project_Layer_Sets then

    local lyrsets = GB_Project_Layer_Sets

    for idx, lyrset in ipairs(GB_Project_Layer_Sets) do

        if lyrset[1] == "Profile Editor" then

            HT.profile_layers = lyrset[2]   
             
            -- Always hide these on script open.
            for _, z in ipairs(HT.profile_layers) do
                    GUI.elms_hide[z] = true  
            end
        end
        
        if lyrset[1] == "Test 1" then

            HT.test1_layers = lyrset[2]   
                
            -- Hide if not active.
            if GB_Active_Layer_Sets[idx] == false then
                for _, z in ipairs(HT.test1_layers) do
                    GUI.elms_hide[z] = true  
                end
            end
            
            GUI.Val("radio_SelectTest", 1)

        end
        
        if lyrset[1] == "Test 2" then

            HT.test2_layers = lyrset[2]    
               
            -- Hide if not active.
            if GB_Active_Layer_Sets[idx] == false then
                for _, z in ipairs(HT.test2_layers) do
                    GUI.elms_hide[z] = true  
                end
            end
            
            GUI.Val("radio_SelectTest", 2)

        end
        
        if lyrset[1] == "L-R Test" then

            -- Not currently using.
            HT.lr_test_layers = lyrset[2]    
               
            -- Hide if not active.
            if GB_Active_Layer_Sets[idx] == false then
                for _, z in ipairs(HT.lr_test_layers) do
                    GUI.elms_hide[z] = true  
                end
            end

        end

        if lyrset[1] == "Unused Elms" then

            -- Always hide (may be used in future).  
            HT.unused_layers = lyrset[2]       
            if GB_Active_Layer_Sets[idx] == false then
                for _, z in ipairs(HT.unused_layers) do
                    GUI.elms_hide[z] = true  
                end
            end

        end

    end
    
end

--======================================
  ------   Method Overrides  ------
--======================================
--zzoverrides --zzztk

function GUI.elms.mbx_Tracks:onmouseup()
	GUI.dh_Menubox.onmouseup(self)
	-- reaper track index is 0 based.
	select_track(self.curr_opt - 1)
end

--zzfreq
function GUI.elms.mbx_Freqs:onmouseup()

    -- Ignore if test is running.
    if HT.is_running then return end

	GUI.dh_Menubox.onmouseup(self)

	--GUI.Msg("self.curr_opt: " .. self.curr_opt)
	--GUI.Msg("#self.optarray: " .. #self.optarray)	
	
	HT.test_freq_id = self.optarray[self.curr_opt]
	HT.test_freq_idx = self.curr_opt	

    local zone = HT.zones[HT.test_freq_id]
    
    -- # Load any saved test set up parameters.
    -- Can use these for initializing tests.
    
    --zzx Maybe won't be using.
    HT.test_ref_pan = zone.test_ref_pan
    
    HT.test_gain_adj = zone.test_gain_adj
    HT.test_pan = zone.test_pan
        
    -- # Set locked checkbox.
    GUI.elms.chkl_Locked:val(zone.locked)  
    GUI.elms.chkl_Locked:redraw()
    
    -- # Set bypass checkbox.
    GUI.elms.chkl_Bypass:val(zone.bypass)  
    GUI.elms.chkl_Bypass:redraw()  

    -- # Init Test knobs even if not current test.
    GUI.elms.knob_Test1_Gain:val(zone[HT.gain_lcr])
    --zzx
    GUI.elms.knob_Test2_Calibrate:val(zone.test_ref_pan)  
    GUI.elms.knob_Test2_Gain:val(zone.test_gain_adj)  
    GUI.elms.knob_Test2_Pan:val(zone.test_pan)  
    GUI.elms.knob_LR_Gain:val(zone.lr_gain)  
    GUI.elms.knob_LR_Cents:val(zone.lr_cents)  
    
    --!!! Whole purpose of testing.
    HT.eq_loud_gain = (HT.phon_points[HT.test_freq_idx] - HT.phon_curve) - (HT.phon_points[HT.datum_freq_idx] - HT.phon_curve)    
    -- (83 - 80) - (80.3 - 80) = 2.7
    
--zzztg   
 
    if HT.r_track then

        -- # Set track volume to datum.  
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", HT.datum_vol)  
    
        --[=[
        --zzx Not necessary!
        -- # Set track pan depending on test.
        local pan
    
        if (GUI.Val("radio_TestType") == 2) then
            pan = HT.datum_pan
        else
            pan = ((HT.channel == 1) and -1.0)
               or ((HT.channel == 2) and 0.0)
               or ((HT.channel == 3) and 1.0)
        end	
    
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", pan)
        --]=]
    
    end
    
    --[=[
    -- # No tone generator found.
    if not HT.tgen_idx then
        --reaper.MB("No tone generator found!", "Whoops!", 0)
        return
    end

	--GUI.Msg("\n# mbx_Freqs:onmouseup ")
	--GUI.Msg("   note_idx : " .. HT.zones[HT.test_freq_id].note_idx)
	--GUI.Msg("   octave : " .. HT.zones[HT.test_freq_id].octave)	
            
    -- # Set tone generator frequency.
    
    --??? Is this necessary? Test start should set this.
    reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_note_idx, HT.zones[HT.datum_freq_id].note_idx)
    reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_octave_idx, HT.zones[HT.datum_freq_id].octave)    
    reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_cents_idx, 0)    
    --]=]

end  --<mbx_Freqs:onmouseup>

--zzprofiles Loads a profile from selection box.

function GUI.elms.mbx_Profiles:onmouseup()

    if HT.isrunning then return end

	GUI.dh_Menubox.onmouseup(self)
	
	HT.curr_profile_name = self.optarray[self.curr_opt]
	
    --GUI.Msg("\n## mbx_Profiles:onmouseup : " .. HT.curr_profile_name)	

	load_profile(HT.curr_profile_name)
	
    --GUI.Msg("\n## mbx_Profiles:onmouseup : " .. HT.curr_profile_name)
	
end  --<mbx_Profiles>

----------------------------------------
--   Option Elements
----------------------------------------
--zzopts

function GUI.elms.chkl_TG_Enable:onmouseup()

	GUI.dh_Checklist.onmouseup(self)

	-- # No tone generator found. Abort!
	if not HT.tgen_idx then
	    reaper.MB("No tone generator found!", "Whoops!", 0)
    	return
	end
	
    reaper.TrackFX_SetEnabled(HT.r_track, HT.tgen_idx, self.optsel[1] )
    	
end

--zzx
--!!! Maybe won't use.
function GUI.elms.chkl_Test2_Calibrate:onmouseup()

    -- # No tone generator found. Abort!
    if not HT.tgen_idx then
        reaper.MB("No tone generator found!", "Whoops!", 0)
        return
    end
    
    -- # If any test in progress.
    if HT.is_running then return end
    
    -- # Run native handler.
	GUI.dh_Checklist.onmouseup(self)
	
	if (self.optsel[1] == true) then
	
	    -- # Set up calibration.
	    HT.is_calibrating = true
	    
	    -- # Set track volume.
	    HT.test_ref_vol = 10^((HT.datum_gain + HT.eq_loud_gain) / 20)
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", HT.test_ref_vol)            

	    -- # Set track pan.
	    local pan = HT.test_ref_pan or 0
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", pan)   
        
        -- # Enable tone gen.
        reaper.TrackFX_SetEnabled(HT.r_track, HT.tgen_idx, true)
	
	else
	
	    -- # Process calibration.
	
	    -- # Disable tone gen.
	    reaper.TrackFX_SetEnabled(HT.r_track, HT.tgen_idx, false)
	    
	    HT.is_calibrating = false
	    
	    -- # Calculate tone_ref_vol left and right.
        HT.test_ref_vol_left  = math.cos(math.rad(HT.test_ref_pan) * HT.test_ref_vol)
        HT.test_ref_vol_right = math.sin(math.rad(HT.test_ref_pan) * HT.test_ref_vol)

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


function GUI.elms.chkl_Bypass:onmouseup()
	GUI.dh_Checklist.onmouseup(self)
    HT.zones[HT.test_freq_id].bypass = self.optsel[1]	
end


function GUI.elms.radio_SelectTest:onmouseup()

    if HT.is_running then return end

	GUI.dh_Radio.onmouseup(self)
	
	local hide_t1 = (self.retval == 2) 
	
	--GUI.Msg(">>> hide_t1 : " .. tostring(hide_t1))

	for _, z in ipairs(HT.test1_layers) do
	    GUI.elms_hide[z] = hide_t1
	end
	    
	for _, z in ipairs(HT.test2_layers) do
	    GUI.elms_hide[z] = not hide_t1
	end
	
    update_graph(self.retval)

end


-- radio_Channel selects which channel is to be used for Test1.
-- In that case we need to set track pan.
-- It also selects which channel data to show on graph,
--   but only if graph_type not Test2.

function GUI.elms.radio_Channel:onmouseup()

    if HT.is_running then return end

	GUI.dh_Radio.onmouseup(self)
   
    --GUI.Msg("\n## radio_Channel:onmouseup  ##")
    
    HT.channel = self.retval
    
    --GUI.Msg("      HT.channel : " .. HT.channel)  

    if HT.r_track then
    
        --??? Should I be using pan 1 or -1 ?
        -- Extremes might have extreme gain falloff?                  
    
        local pan = (HT.channel == 1 and -1)
                 or (HT.channel == 2 and 0)
                 or (HT.channel == 3 and 1)
        
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", pan)  
          
--zzx
        --!!! Not really necessary. Test start should set it.
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", HT.datum_vol) 
    
    end
    
--zzt12  radio_Channel

    HT.gain_lcr = ((self.retval == 1) and "gain_l")
               or ((self.retval == 2) and "gain_c")
               or ((self.retval == 3) and "gain_r")
               
    --GUI.Msg("      HT.gain_lcr : " .. HT.gain_lcr)     

    GUI.elms.knob_Test1_Gain:val(HT.zones[HT.test_freq_id][HT.gain_lcr])
    
    -- Changing channels require datapoints to be updated,
    -- Channel selection now only avaiable during Test 1.
    --   so only update datapoints.

    HT.data_points = update_data_points(HT.gain_lcr)
    
    --GUI.Msg("      HT.data_points[7] : " .. HT.data_points[7])         
    -- Its good to here.
    
    -- This isn't good enough.
    --GUI.elms.graph_Freq:redraw()
        
    -- Changing channels but still call with 1.
    update_graph(1)

end  --<radio_Channel:onmouseup>

--zzx
--[=[
-- May utilize this in future to display phon curve.
-- Options Test, Phon
-- What if phon curve is displayed and a test tries to update?
-- Maybe set HT.is_running to true?

function GUI.elms.radio_GraphType:onmouseup()

    if HT.is_running then return end

	GUI.dh_Radio.onmouseup(self)
	
    --GUI.Msg("\n## radio_GraphType:onmouseup  self.retval : " .. self.retval)	

    local graph_type
    
    if self.retval == 1 then
        graph_type = GUI.Val("radio_SelectTest")
        HT.is_running = false
    else
        graph_type = 3  -- phon curve
        HT.is_running = true
    end

    update_graph(graph_type)

end  --<radio_GraphType:onmouseup>
--]=]

--zzpc
function GUI.elms.radio_PhonCurve:onmouseup()

	GUI.dh_Radio.onmouseup(self)

	local pc = self.optarray[self.retval]
	HT.phon_curve = math.tointeger(pc)
	-- Get dataset from defaults.
	HT.phon_points = HT.defaults["phon_" .. pc]
    HT.zones[HT.datum_freq_id].phon_curve = HT.phon_curve    
    
end  --<radio_PhonCurve:onmouseup>

----------------------------------------
--   Knobs
----------------------------------------
--zzknobs  

function GUI.elms.knob_TG_Gain:ondrag()

	GUI.dh_Knob.ondrag(self)
	
	HT.tg_gain = self.cur_num_val
    HT.zones[HT.datum_freq_id].tg_gain = self.cur_num_val
	
	-- # Set tone generator wet mix gain.
	if HT.r_track and HT.tgen_idx then
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_wm_idx, HT.tg_gain)
    end
    
end


function GUI.elms.knob_TG_Gain:onwheel()

	GUI.dh_Knob.onwheel(self)
	
	--GUI.Msg("    onwheel self.retval : " .. self.retval) 
	                      
	HT.tg_gain = self.cur_num_val
	HT.zones[HT.datum_freq_id].tg_gain = self.cur_num_val
	
	-- # Set tone generator wet mix gain.
	if HT.r_track and HT.tgen_idx then
	    reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_wm_idx, HT.tg_gain)
	end

end


function GUI.elms.knob_Datum_Gain:ondrag()

	GUI.dh_Knob.ondrag(self)
	
    HT.datum_gain = self.cur_num_val
    HT.datum_vol = 10^(HT.datum_gain / 20)
    HT.zones[HT.datum_freq_id].datum_gain = self.cur_num_val
	
	-- # Set track volume.
	if HT.r_track then
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", HT.datum_vol)  
    end
    
end


function GUI.elms.knob_Datum_Gain:onwheel()

	GUI.dh_Knob.onwheel(self)
	
    HT.datum_gain = self.cur_num_val
    HT.datum_vol = 10^(HT.datum_gain / 20)
    HT.zones[HT.datum_freq_id].datum_gain = self.cur_num_val
    	
    -- # Set track volume.
    if HT.r_track then
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", HT.datum_vol)  
    end
    
end

--zzzc
function GUI.elms.knob_Datum_Pan:ondrag()

	GUI.dh_Knob.ondrag(self)
	
    HT.datum_pan = self.cur_num_val
    HT.zones[HT.datum_freq_id].datum_pan = self.cur_num_val
	
	-- # Set datum pan.
	if HT.r_track then
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", HT.datum_pan)  
    end
    
end


function GUI.elms.knob_Datum_Pan:onwheel()

	GUI.dh_Knob.onwheel(self)
	
    HT.datum_pan = self.cur_num_val
    HT.zones[HT.datum_freq_id].datum_pan = self.cur_num_val
	
	-- # Set datum pan.
	if HT.r_track then
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", HT.datum_pan)  
    end
    
end

-- HT.test_gain_adj used during tests to set gain. 
-- For Test 1 it will be saved as the gain for
--   channel tested: gain_l, gain_c, gain_r.
--   HT.test_gain_adj = HT.zones[HT.test_freq_id][HT.gain_lcr]
-- For Test 2 it gets saved as as test_gain_adj.
-- Knob self.retval is a formatted string,
--   but it works for changing track gain.
--   Added property cur_num_val to knob which is a number.

function GUI.elms.knob_Test1_Gain:ondrag()
	GUI.dh_Knob.ondrag(self)
    HT.test_gain_adj = self.cur_num_val 
end


function GUI.elms.knob_Test1_Gain:onwheel()
	GUI.dh_Knob.onwheel(self)
    HT.test_gain_adj = self.cur_num_val 
end


function GUI.elms.knob_Test2_Gain:ondrag()
	GUI.dh_Knob.ondrag(self)
    HT.test_gain_adj = self.cur_num_val 
end


function GUI.elms.knob_Test2_Gain:onwheel()
	GUI.dh_Knob.onwheel(self)
    HT.test_gain_adj = self.cur_num_val 
end


function GUI.elms.knob_Test2_Pan:ondrag()
	GUI.dh_Knob.ondrag(self)
    HT.test_pan = self.cur_num_val 
end


function GUI.elms.knob_Test2_Pan:onwheel()
	GUI.dh_Knob.onwheel(self)
    HT.test_pan = self.cur_num_val 
end

--zzx
--!!! Maybe won't use.
function GUI.elms.knob_Test2_Calibrate:ondrag()

    if not HT.is_calibrating then return end

	GUI.dh_Knob.ondrag(self)
	
	-- # Set track pan.
	if HT.r_track then
        HT.test_ref_pan = self.cur_num_val
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", HT.test_ref_pan)  
    end
    
end


function GUI.elms.knob_Test2_Calibrate:onwheel()

    if not HT.is_calibrating then return end

	GUI.dh_Knob.onwheel(self)
	
	-- # Set track pan.
	if HT.r_track then
        HT.test_ref_pan = self.cur_num_val
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", HT.test_ref_pan)  
    end
    
end

----------------------------------------
--   Buttons
----------------------------------------
--zzbtn

--[=[
--!!! Not using buttons. Using knob instead.
function GUI.elms.btn_Gain_Inc:onmouseup()

	GUI.dh_Button.onmouseup(self)
	
    -- Ignore if test is not running.
    if not HT.is_running then return end
    
    -- Ignore if test freq.
    if HT.test_freq_idx == HT.datum_freq_idx then return end
    
    -- # Increment track volume by factor.
    --HT.test_gain_adj = HT.test_gain_adj + HT.gain_adj_step

end


function GUI.elms.btn_Gain_Dec:onmouseup()

	GUI.dh_Button.onmouseup(self)

    -- Ignore if test is not running.
    if not HT.is_running then return end
    
    -- Ignore if test freq.
    if HT.test_freq_idx == HT.datum_freq_idx then return end
    
    -- # Decrement track volume by factor.
    --HT.test_gain_adj = HT.test_gain_adj - HT.gain_adj_step

end
--]=]	

--zzt1  
function GUI.elms.btn_Test1_Start:onmouseup()

	--GUI.Msg("\n## btn_Test1_Start:onmouseup  ")
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

    -- # Initialize to datum frequency. (Tone generator exists.)
    reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_note_idx, TIMER.datum_note_idx)  
    reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_octave_idx, TIMER.datum_octave)    

	-- # Set selected channel.
    local pan = ((HT.channel == 1) and -1.0)
             or ((HT.channel == 2) and 0.0)
             or ((HT.channel == 3) and 1.0)	
	
	reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", pan)	
	
	-- # Start at datum track ref volume.
	reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", HT.datum_vol) 

    -- # Set initial test freq gain -6db.

    --HT.test_gain_adj = GUI.elms.knob_Test1_Gain.min
    HT.test_gain_adj = -6

    -- # Set knob_Test1_Gain.
    
    GUI.elms.knob_Test1_Gain:val(HT.test_gain_adj)
    
--zzztm        
    --[=[  TIMER 1	--]=]

    -- # Setup timer.
    
    TIMER.caller = 1
    TIMER.interval = 0.5
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


function GUI.elms.btn_Test1_Stop:onmouseup()

	GUI.Msg("\n## btn_Test1_Stop:onmouseup  ")
	GUI.dh_Button.onmouseup(self)
	
	-- Ignore if test is not running.
	if not HT.is_running then return end

	-- Ignore if test freq.
    if HT.test_freq_idx == HT.datum_freq_idx then return end

	HT.is_running = false

	-- # Set tone generator to not enabled.
    reaper.TrackFX_SetEnabled(HT.r_track, HT.tgen_idx, false)
	
	HT.zones[HT.test_freq_id][HT.gain_lcr] = HT.test_gain_adj
	
	-- # Make sure tone generator params are returned to test freq.
    reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_note_idx, HT.zones[HT.test_freq_id].note_idx)
    reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_octave_idx, HT.zones[HT.test_freq_id].octave) 

	-- # Update graph.
	
	GUI.Msg("\n SHOULD be updating graph.\n    Following should be test_gain_adj")
	
--zzt12  test 1 stop
	-- data_points has data from selected freq gain/channel.
    -- Only update curr point.
    --HT.data_points[HT.test_freq_idx] = left_gain
    
	HT.data_points[HT.test_freq_idx] = HT.test_gain_adj
	
	GUI.Msg(">>   HT.data_points[HT.test_freq_idx] : " .. HT.data_points[HT.test_freq_idx])	
	
	GUI.elms.graph_Freq:redraw()
	
	--??? Reset gain to test gain of selected freq.
	
	
end  --<btn_Stop:onmouseup>


function GUI.elms.btn_Test2_Start:onmouseup()

	GUI.dh_Button.onmouseup(self)
	
	--GUI.Msg("\n## btn_Test2_Start:onmouseup  ")
	
    -- Ignore if test is running.
    if HT.is_running then return end	
	
	-- # No tone generator found. Abort!
	if not HT.tgen_idx then
	    reaper.MB("No tone generator found!", "Whoops!", 0)
	    return
	end

    -- # Initialize to datum frequency. (Tone generator exists.)
 	reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_note_idx, TIMER.datum_note_idx)  
 	reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_octave_idx, TIMER.datum_octave)   
    reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_cents_idx, 0) 	 
		 	
    -- # Set pan to datum_pan.
    reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", HT.datum_pan)

 	-- # Set track volume to datum_vol.
 	reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", HT.datum_vol) 
 	
	--GUI.Msg("      HT.datum_gain : " .. HT.datum_gain) 
	--GUI.Msg("      HT.eq_loud_gain : " .. HT.eq_loud_gain) 	
	--GUI.Msg("      HT.zones[HT.test_freq_id].gain_l : " .. HT.zones[HT.test_freq_id].gain_l) 
	--GUI.Msg("      HT.test_freq_id : " .. HT.test_freq_id) 	

 	-- # Init Test2 knobs to values from profile.

 	HT.test_pan = HT.zones[HT.test_freq_id].test_pan or 0 
 	GUI.elms.knob_Test2_Pan:val(HT.test_pan)
 	 	
 	--GUI.Msg("    START  test_pan : " .. HT.test_pan)  	

 	HT.test_gain_adj = HT.zones[HT.test_freq_id].test_gain_adj or 0 
 	GUI.elms.knob_Test2_Gain:val(HT.test_gain_adj) 	
 	
	--GUI.Msg("    START HT.test_gain_adj : " .. HT.test_gain_adj)  

--zzt2a --zzztm  btn_start
  	     	 	
    --[=[  TIMER 2  --]=]

    -- # Setup timer.
    
    TIMER.caller = 2
    TIMER.interval = 0.5
    TIMER.state = 1
    TIMER.test_note_idx = HT.zones[HT.test_freq_id].note_idx
    TIMER.test_octave = HT.zones[HT.test_freq_id].octave
    
	--GUI.Msg("      TIMER.caller : " .. TIMER.caller)	
	
	-- # Start test --
	
    -- Set tone generator enabled.	
    reaper.TrackFX_SetEnabled(HT.r_track, HT.tgen_idx, true)
    
    HT.is_running = true
    
    TIMER.start_time = reaper.time_precise()

end  --<btn_Test2_Start:onmouseup>


function GUI.elms.btn_Test2_Stop:onmouseup()

	GUI.Msg("\n## btn_Test2_Stop:onmouseup  ")
	GUI.dh_Button.onmouseup(self)
	
	-- Ignore if test is not running.
	if not HT.is_running then return end

    HT.is_running = false	

	-- # Set tone generator to not enabled.
    reaper.TrackFX_SetEnabled(HT.r_track, HT.tgen_idx, false)

	-- # Reset params to datum.	
    reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_note_idx, TIMER.datum_note_idx)  
    reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_octave_idx, TIMER.datum_octave)   
	
	-- # Reset track pan to datum_pan.
	reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", HT.datum_pan)   
	
	-- # Reset track vol to datum_vol.
	reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", HT.datum_vol)
	
	-- # Unmute track (it may have been muted during test).
	reaper.SetMediaTrackInfo_Value(HT.r_track, "B_MUTE", 0)    

	--[=[  STORE DATA --]=]
	
	-- # Store knob gain and pans for easy test setup.

	HT.zones[HT.test_freq_id].test_ref_pan = HT.test_ref_pan
	HT.zones[HT.test_freq_id].test_gain_adj = HT.test_gain_adj
	HT.zones[HT.test_freq_id].test_pan = HT.test_pan
	
	--GUI.Msg("    STOP  HT.test_gain_adj : " .. HT.test_gain_adj) 	 
	
    -- # Calculate left and right dB diffs between datum and test.
    -- These are the db adjustments that will be applied to eqs.
    -- Store them in profile.
    
--zzt2a	btn_stop

    -- ####  CALCULATE TEST RESULTS  ####

    -- Convert knob range (-1 to +1) to range (0 to 90) for calcs.
    --[=[
    GUI.Msg("\n    datum_vol : " .. HT.datum_vol)
    GUI.Msg("    datum_pan : " .. HT.datum_pan) 

    GUI.Msg("\n    datum_gain : " .. HT.datum_gain)           
    GUI.Msg("    eq_loud_gain : " .. HT.eq_loud_gain)
    GUI.Msg("    test_gain_adj : " .. HT.test_gain_adj)                         
    
    GUI.Msg("\n>>> test_vol : " .. HT.test_vol)        
    GUI.Msg("    test_pan deg : " .. ((HT.test_pan + 1) * 45)) 
    --]=]
       
    local test_pan = math.rad((HT.test_pan + 1) * 45)
    --[=[
    GUI.Msg("    test_pan rad : " .. test_pan)
    GUI.Msg("    cos : " .. math.cos(test_pan))    
    GUI.Msg("    sin : " .. math.sin(test_pan))
    --]=] 
    local test_vol_left  = math.cos(test_pan) * HT.test_vol
    local test_vol_right = math.sin(test_pan) * HT.test_vol

    --GUI.Msg("\n    test_vol_left : " .. test_vol_left)
    --GUI.Msg("    test_vol_right : " .. test_vol_right)    
--zzzp
    --!!! These can be local. I don't envision using them anywhere else.
    HT.datum_vol_left = HT.datum_vol * math.cos(math.rad((HT.datum_pan + 1) * 45))
    HT.datum_vol_left = HT.datum_vol * math.sin(math.rad((HT.datum_pan + 1) * 45))
    
    --GUI.Msg("\n    datum_vol_left : " .. HT.datum_vol_left)
    --GUI.Msg("    datum_vol_right : " .. HT.datum_vol_right)         
    
    local left_ratio  = test_vol_left / HT.datum_vol_left
    local right_ratio = test_vol_right / HT.datum_vol_right
    
    --GUI.Msg("\n    left_ratio : " .. left_ratio)
    --GUI.Msg("    right_ratio : " .. right_ratio)
    
--[==[
        
--]==]         
    
    -- # Convert ratio to dB.
    
    -- If gain very small (probably not noticable loudness) 
    --   set to 0. 
    -- Truncate to 2 decimal places.
    -- 2.1234 * 100 == 212.34 -> 212 -> 2.12
    
    local left_gain  = math.log(left_ratio, 10) * 20 
    --GUI.Msg("\n    left_gain : " .. left_gain)
    if math.abs(left_gain) < 0.1 then left_gain = 0 end
    
    left_gain = math.floor(left_gain * 100) / 100
    --GUI.Msg("    left_gain : " .. left_gain)
    
    local right_gain  = math.log(right_ratio, 10) * 20
    --GUI.Msg("\n    right_gain : " .. right_gain)     
    if math.abs(right_gain) < 0.1 then right_gain = 0 end
    
    right_gain = math.floor(right_gain * 100) / 100
    --GUI.Msg("    right_gain : " .. right_gain)
    
    HT.zones[HT.test_freq_id].gain2_l = left_gain 
    HT.zones[HT.test_freq_id].gain2_r = right_gain 
    
    
    --local fstr = string.format("%10.2f", left_gain)
    --GUI.Msg("\n    STOP  left_gain fmt : " .. fstr)
    --fstr = string.format("%10.2f", right_gain)
    --GUI.Msg("    STOP  right_gain fmt : " .. fstr)
    
    -- update data points then redraw graph if graph_type Test2.
    -- graph_type 2 auto selected during test 2.
    
--zzt12 test 2 stop

    HT.data_points[HT.test_freq_idx] = left_gain
    HT.data_points2[HT.test_freq_idx] = right_gain
    GUI.elms.graph_Freq:redraw()

end  --<btn_Test2_Stop:onmouseup>

--[===[
--zzx Not currently using L-R test. May eliminate?
function GUI.elms.btn_LR_Start:onmouseup()

	GUI.dh_Button.onmouseup(self)
	
	--GUI.Msg("\n## btn_LR_Start:onmouseup  ")
	
	-- # No tone generator found. Abort!
	if not HT.tgen_idx then
	    reaper.MB("No tone generator found!", "Whoops!", 0)
	    return
	end

--zzt3    	
 	-- # Initialize test.
    -- Start in left channel at current test gain as reference.
 	
 	-- # Set pan to left.
 	reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", -1.0)
 	
	--GUI.Msg("      HT.datum_gain : " .. HT.datum_gain) 
	--GUI.Msg("      HT.eq_loud_gain : " .. HT.eq_loud_gain) 	
	--GUI.Msg("      HT.zones[HT.test_freq_id].gain_l : " .. HT.zones[HT.test_freq_id].gain_l) 
	--GUI.Msg("      HT.test_freq_id : " .. HT.test_freq_id) 	

 	-- # Set track volume to test left channel.
 	local g = 10^((HT.datum_gain + HT.eq_loud_gain + HT.zones[HT.test_freq_id].gain_l) / 20)
 	reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", g)
 	
 	-- # Init knobs.
 	local val = HT.zones[HT.test_freq_id].lr_gain or 0 
 	
	--GUI.Msg("    START  val gain : " .. val)  	
 	
 	GUI.elms.knob_LR_Gain:val(val)
 	
 	val = HT.zones[HT.test_freq_id].lr_cents or 0 
 	
	--GUI.Msg("    START  val cents : " .. val)  	
 	
 	GUI.elms.knob_LR_Cents:val(val)
 	
    --[=[  TIMER 3  --]=]
    
    -- # Setup timer.
    
    TIMER.caller = 3
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
    local g = 10^((HT.datum_gain + HT.eq_loud_gain + HT.test_gain_adj) / 20)	
	reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", g)

	--# Store data.
	
    --!!! Knob retval is a formatted string. Convert it to a number.
    local retval = tonumber(GUI.elms.knob_LR_Gain:val())
    
	--GUI.Msg("    STOP  retval gain : " .. retval) 	     	 
	HT.zones[HT.test_freq_id].lr_gain = retval
	
    retval = tonumber(GUI.elms.knob_LR_Cents:val())
	--GUI.Msg("    STOP  retval cents : " .. retval) 	     	      
	HT.zones[HT.test_freq_id].lr_cents = retval

end  --<btn_LR_Stop:onmouseup>
--]===]

function GUI.elms.btn_Print:onmouseup()

	GUI.dh_Button.onmouseup(self)

    show_dataset_in_console()

end
	
--zzprofiles
function GUI.elms.btn_OpenProfileEditor:onmouseup()

	--GUI.Msg("\n## btn_OpenProfileEditor:onmouseup : " .. HT.curr_profile_name)
	
	GUI.dh_Button.onmouseup(self)
		
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

    -- # Initialize editor elements.
    GUI.Val("lbl_CurrentProfileName", HT.curr_profile_name)   
    GUI.Val("tbx_ProfileName", HT.curr_profile_name)
    GUI.Val("chkl_TG_Enable", false)
    
--zzzo open editor   
    --!!! If updated in load_profile then ths is redundant.
    -- Seems safer to do it here.    
              
    -- # Set radio to phon curve. 
    local pcidx = (HT.phon_curve == 40 and 1) or
                  (HT.phon_curve == 60 and 2) or
                  (HT.phon_curve == 80 and 3)
                  
	--GUI.Msg(">    btn_OpenProfileEditor.mouseup HT.phon_curve : " .. HT.phon_curve)	                   

    GUI.Val("radio_PhonCurve", pcidx)

    -- # Set knobs.  
    GUI.Val("knob_Datum_Pan", HT.datum_pan)
    GUI.Val("knob_Datum_Gain", HT.datum_gain)
    GUI.Val("knob_TG_Gain", HT.tg_gain)

    -- # Set track volume and pan to datum.
    if HT.r_track then   
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_VOL", HT.datum_vol)
        reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", HT.datum_pan)
    end

    -- # Set tone generator to datum freq params.
    if HT.tgen_idx then
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_note_idx, HT.zones[HT.datum_freq_id].note_idx)
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_octave_idx, HT.zones[HT.datum_freq_id].octave) 
        reaper.TrackFX_SetParam(HT.r_track, HT.tgen_idx, HT.tgen_cents_idx, 0) 
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
    
--zzzc close editor --zzknob  

    -- # Make sure tone gen is disabled.
    reaper.TrackFX_SetEnabled(HT.r_track, HT.tgen_idx, false)
    
    -- # Set track pan depending on test.
    local pan
             
    if (GUI.Val("radio_TestType") == 2) then
        pan = HT.datum_pan
    else
        pan = ((HT.channel == 1) and -1.0)
           or ((HT.channel == 2) and 0.0)
           or ((HT.channel == 3) and 1.0)
    end	
             
    reaper.SetMediaTrackInfo_Value(HT.r_track, "D_PAN", pan)
    
end


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

--zzzd
-- Deletes the current profile and loads "Working Copy".
-- Can only delete the current profile.

function GUI.elms.btn_ProfileDelete:onmouseup()

	--GUI.Msg("\n## btn_Profiledelete:onmouseup  ")
	GUI.dh_Button.onmouseup(self)
	
	local profile_name = HT.curr_profile_name
		
	if profile_name == 'Working Copy' then
	    reaper.MB("Cannot delete 'Working Copy'!", "Whoops!", 0)    
	    return    
	end
	
	local msg = "Do you want to delete profile : " .. profile_name .. " ?"
	
	local retval = reaper.MB(msg, "Warning", 4)
	
	if retval == 6 then
	
	    HT.profiles[profile_name] = nil

	    load_profile("Working Copy")
	    
	    -- # Since I'm inside of editor...
	    -- Because these don't get updated in load_profile.
	    --   (HT.curr_profile_name does.)
	    
	    GUI.Val("lbl_CurrentProfileName", HT.curr_profile_name)   
        GUI.Val("tbx_ProfileName", HT.curr_profile_name)
	    
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

--zzzr   
--zzreset 
-- Resets the current profile with script defaults.

function GUI.elms.btn_Reset:onmouseup()

	GUI.dh_Button.onmouseup(self)
	
    local msg = "Do you want to reset the current profile to defaults? /n    " .. HT.curr_profile_name
        
    local retval = reaper.MB(msg, "Warning", 4)
    
	if retval == 6 then
	
	    load_profile("reset")
	    
	    -- # Update the calibration elms.
	    
        -- # Set radio to phon curve. 
        local pcidx = (HT.phon_curve == 40 and 1) or
                      (HT.phon_curve == 60 and 2) or
                      (HT.phon_curve == 80 and 3)
                      
    	--GUI.Msg(">    btn_OpenProfileEditor.mouseup HT.phon_curve : " .. HT.phon_curve)	                   
    
        GUI.Val("radio_PhonCurve", pcidx)
    
        -- # Set knobs.  
        GUI.Val("knob_Datum_Pan", HT.datum_pan)
        GUI.Val("knob_Datum_Gain", HT.datum_gain)
        GUI.Val("knob_TG_Gain", HT.tg_gain)	    

    end

end


function GUI.elms.btn_UnlockAll:onmouseup()

	--GUI.Msg("\n## btn_Profiledelete:onmouseup  ")
	GUI.dh_Button.onmouseup(self)
	
	for _, data in pairs(HT.profiles[HT.curr_profile_name]) do
	
	    data.locked = false
	    
	    GUI.elms.chkl_Locked:val(false)
	    
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

-- Get any saved profiles.
-- If there is not yet a saved extstate then be uses defaults.
-- Default profile was defined earlier.
-- Only need to this on script load.

local function loadProjExtState()

    --GUI.Msg("\n## loadProjExtState ## ")

    local retval, ret_string = reaper.GetProjExtState(0, 'dh_HearingTest', 'profiles')

    if (retval == 1) then
    
        if ret_string and ret_string ~= "" then
            temp_profiles_table = json.decode(ret_string)  -- should return Lua table
        end
        
        -- profiles should have at least "Working Copy".
        
        if not temp_profiles_table["Working Copy"] then 
            --GUI.Msg("    no imported Working Copy")
            goto skipped 
        end
    
        if (type(temp_profiles_table) == "table") 
            and (DHTK.hash_table_length(temp_profiles_table) > 0) 
        then
        
            --GUI.Msg("    import profiles")
            
            HT.profiles = temp_profiles_table    
            
            if HT.profiles[HT.curr_profile_name] then  
                load_profile(HT.curr_profile_name)                   
            end
            
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
            
            -- # Update menubox.
            
            GUI.elms.mbx_Profiles.optarray = HT.profile_names
            idx = DHTK.table_index_from_value(HT.profile_names, HT.curr_profile_name)  -- this works
            GUI.elms.mbx_Profiles.curr_opt = idx
    
        end
        
        ::skipped::
        
    end

end

loadProjExtState()

--GUI.Msg("  SCRIPT INIT  HT.zones[HT.test_freq_id].tg_gain : " .. HT.zones[HT.test_freq_id].tg_gain ) 
--GUI.Msg("  SCRIPT INIT  HT.zones[HT.test_freq_id].datum_gain : " .. HT.zones[HT.test_freq_id].datum_gain ) 

----------------------------------------
--  GUI Elements Initialization
----------------------------------------
--zzinit

--GUI.Msg("HT.freqs is : " .. HT.freqs[1])
--GUI.Msg("HT.zones.frequency is : " .. HT.zones[HT.freqs[1]].frequency)

GUI.elms.mbx_Freqs.optarray = HT.freqs
HT.test_freq_idx = GUI.table_find(HT.freqs, HT.test_freq_id)
GUI.elms.mbx_Freqs.curr_opt = HT.test_freq_idx

GUI.elms.chkl_Locked:val(HT.zones[HT.test_freq_id].locked)
GUI.elms.chkl_Bypass:val(HT.zones[HT.test_freq_id].bypass)

GUI.elms.mbx_Tracks.optarray = get_track_names()

--!!! Hopefully the text will be blank upon init.
--GUI.elms.mbx_Tracks.curr_opt = 0

-- # If a tone gen is found during iteration then select_track does initialization. 
   
for idx, _ in ipairs(GUI.elms.mbx_Tracks.optarray) do
    -- reaper track index is 0 based.
    if select_track(idx - 1, true) then 
        GUI.elms.mbx_Tracks:val(idx)
        break
    else
        GUI.elms.mbx_Tracks:val(0)
    end
end

GUI.elms.mbx_Profiles.optarray = HT.profile_names
GUI.elms.mbx_Profiles.curr_opt = DHTK.table_index_from_value(HT.profile_names, HT.curr_profile_name)

HT.phon_curve = HT.zones[HT.datum_freq_id].phon_curve

--GUI.Msg("    HT.phon_curve : " .. HT.phon_curve)

GUI.elms.radio_PhonCurve.retval = (HT.phon_curve == 40 and 1) or
    (HT.phon_curve == 60 and 2) or
    (HT.phon_curve == 80 and 3)

--zzx !!! Currently not using.
--GUI.elms.radio_GraphType:val(HT.graph_type)

-- # Update following even if not current test.
--GUI.Msg("\n## SCRIPT INIT HT.channel : " .. HT.channel)
GUI.elms.radio_Channel:val(HT.channel)

HT.gain_lcr = ((HT.channel == 1) and "gain_l")
                 or ((HT.channel == 2) and "gain_c")
                 or ((HT.channel == 3) and "gain_r")

--!!! This has to be after setting HT.gain_lcr.
-- # Updates with current profile and test type as 1, 2, or 3.
--zzt12
update_graph(GUI.Val("radio_SelectTest"))

-- # Select which test is showing.

local hide_t1 = ( GUI.Val("radio_SelectTest") == 2 ) 
	
	--GUI.Msg(">>> script init hide_t1 : " .. tostring(hide_t1))

	for _, z in ipairs(HT.test1_layers) do
	    GUI.elms_hide[z] = hide_t1
	end
	    
	for _, z in ipairs(HT.test2_layers) do
	    GUI.elms_hide[z] = not hide_t1
	end
	
hide_t1 = nil	                 

GUI.elms.knob_Test1_Gain:val( HT.zones[HT.test_freq_id][HT.gain_lcr])
--zzx
GUI.elms.knob_Test2_Calibrate:val(HT.zones[HT.test_freq_id].test_ref_pan) 
GUI.elms.knob_Test2_Gain:val(HT.zones[HT.test_freq_id].test_gain_adj) 
GUI.elms.knob_Test2_Pan:val(HT.zones[HT.test_freq_id].test_pan) 
GUI.elms.knob_LR_Gain:val(HT.zones[HT.test_freq_id].lr_gain) 
GUI.elms.knob_LR_Cents:val(HT.zones[HT.test_freq_id].lr_cents) 

--??? Should I upadte Profile editor elms here
--    or when opening editor?

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

    --saveExtState()
    savePrefs()
    
    local proj, _ = reaper.EnumProjects(-1)
    
    if proj ~= HT.PROJECT then
    
        local msg = "Closing dh_HearingTest while the 'Hearing Test' project\n "
        msg = msg .. "  is not the active project.\n"
        msg = msg .. "Attempting to save data to the 'Hearing Test' project.\n"
        msg = msg .. "If that project is no longer open I can't help you!"
        
        reaper.MB(msg, "Whoops!", 0) 
    
    end
    
    -- # Save profiles to projextstate.
    local json_str = json.encode(HT.profiles)
    --reaper.SetProjExtState(0, 'dh_HearingTest', 'profiles', json_str)
    reaper.SetProjExtState(HT.PROJECT, 'dh_HearingTest', 'profiles', json_str)
    
end 

-- Calls Exit function when script is ending.
reaper.atexit(Exit)

--======================================
  ------   MAIN LOOP <dhMain>   ------
--======================================
--zzmain  --zztest

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

--[===[

-----------------------------------------------
Use this for Test 2:

    cos 0.707 sin 0.707
    0.089   0.126   0.089   datum_vol at center
    
    1.259   1.259   1.259   2dB eq_loud_gain
    0.112   0.159   0.112   test_ref_vol rel to datum at center
    
    0.218   0.251   0.126   test_vol at -30
    
    1.946   1.579   1.125   test_result / test_ref
    5.78    4.00    1.02    dB
    
    If I'm not calibrating test_ref
      test_ref_vol = 10^((datum_gain + eq_loud_gain) / 20)
    to run the test.
    
      test_vol = 10^((datum_gain + eq_loud_gain + test_gain_adj) / 20)

-----------------------------------------------
    cos 0.760 sin 0.649
    0.096   0.126   0.082   datum_vol at -10
    
    1.259   1.259   1.259   2dB eq_loud_gain
    0.121   0.159   0.103   test_ref_vol rel to datum at -10
    
    0.218   0.251   0.126   test_vol at -30
    
    1.802   1.579   1.223   test_result / test_ref
    5.11    4.00    1.74    dB gain above test ref
    
    
    So if I want to boost input signal with eq
    
    Since I'm already biasing datum signal
      datum left is already boosted 
        slightly above "normal".
      
    Therefore that boost should be added back to left gain.
    
    0.112   0.159   0.112   test_ref_vol rel to datum at center    
    0.121   0.159   0.103   test_ref_vol rel to datum at -10
    
    1.080   1.000   0.920   biased / centered
    +0.67   0       -0.72 
    
-----------------------------------------------

--]===]