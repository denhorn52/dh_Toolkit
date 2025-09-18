--Set dh_Toolkit_v1 library path.lua

-- This is how Lokasenna does it.
-- Find this script in Reaper's action list and run it.
-- dh_Toolkit script path will be saved to Reaper ext state.
-- Then a script placed anywhere should be able to find it
-- by calling it thus:
-- local dhtk_path = reaper.GetExtState("dh_Toolkit", "lib_path_v1")

local info = debug.getinfo(1,'S')
local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
reaper.SetExtState("dh_Toolkit", "lib_path_v1", script_path, true)

reaper.ShowConsoleMsg("dh_Toolkit script path : \n" .. script_path .. " :\n added to reaper ext state.\n")

