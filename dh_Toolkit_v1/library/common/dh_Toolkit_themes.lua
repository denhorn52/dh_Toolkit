-- dh_Toolkit_themes.lua
-- version 1.0
-- Author: Dennis R. Horn
-- Date: 20260330


-----------------------------------
-- DESCRIPTION:

-- Adds themes to scripts using Lokasenna GUI and dh_Toolkit.

-----------------------------------
--CHANGELOG:
-- 2025-04-30 Added/revised themes.
--            Added some utility functions.           
--            Added several color names.
-- 2025-12-29 Added size 14 font.

-----------------------------------
-- Requires that Lokasenna_GUI v2 be loaded.

if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end

-----------------------------------
dh_Toolkit_themes = {}
-----------------------------------

-- Theme names are mainly used to populate a checklist.
-- Usage:   opts = dhtk.DH_THEMES
  
dh_Toolkit_themes.DH_THEME_NAMES = {
  "Default",
  "Aqua",
  "Black",
  "Desert",
  "Gray",
  "Magenta",
  "Mocha",
  "Neon",
  "Pastel",
  "Sepia",
  "Silver",
  "User",
}

-- dh_Toolkit theme definitions.
-- Values are in 0..255 format for compatibility with GUI.
-- Lokasenna GUI defines colors in 0..255 format then
--   converts them them to 0..1 during GUI.Init().

dh_Toolkit_themes.DH_THEMES = {

    Default = {
        wnd_bg = {64, 64, 64, 255},
        txt = {192, 192, 192, 255},
        elm_bg = {48, 48, 48, 255},
        elm_fill = {192, 192, 192, 255},
        elm_frame = {96, 96, 96, 255},
        elm_outline = {32, 32, 32, 255},
        tab_bg = {56, 56, 56, 255},
        
        btn_face = {96, 96, 96, 255},
        btn_outline = {32, 32, 32, 255},
        btn_txt = {192, 192, 192, 255},
        aux_bg = {96, 96, 96, 255},
        aux_txt = {192, 192, 192, 255},
        thumb_body = {96, 96, 96, 255},
        track_fill = {148, 148, 148, 255},

        panel_bg = {64, 64, 64, 255},
        panel_border = {96, 96, 96, 255},
        panel_txt = {192, 192, 192, 255},
        
        elm_txt = {192, 192, 192, 255},        
        sel_txt = {120, 120, 120, 128},
        tab_active = {96, 96, 96, 255},
        tab_inactive = {56, 56, 56, 255},
        
        elm_active = {192, 192, 192, 255},        
        metadata = {0, 0, 0, 255},
        
        --elm_thumb = {96, 96, 96, 255},
        --elm_track = {175, 175, 175, 255},        
    },    
    Aqua = {
        wnd_bg = {132, 220, 228, 255},
        txt = {0, 64, 64, 255},
        elm_bg = {48, 48, 48, 255},
        elm_fill = {108, 151, 201, 255},
        elm_frame = {103, 216, 183, 255},
        elm_outline = {32, 32, 32, 255},
        tab_bg = {132, 220, 228, 255},
        
        btn_face = {85, 224, 207, 255},
        btn_outline = {57, 138, 144, 255},
        btn_txt = {0, 64, 64, 255},
        aux_bg = {85, 224, 207, 255},
        aux_txt = {0, 64, 64, 255},
        thumb_body = {48, 183, 144, 255},
        track_fill = {36, 165, 126, 255},

        panel_bg = {164, 228, 236, 255},
        panel_border = {66, 192, 153, 255},
        panel_txt = {0, 64, 64, 255},
        elm_txt = {216, 216, 216, 255},        
        sel_txt = {51, 175, 147, 128},
        tab_active = {155, 237, 245, 255},
        tab_inactive = {132, 220, 228, 255},
        
        elm_active = {255, 0, 255, 255},        
        metadata = {0, 0, 0, 255},
        
        --elm_thumb = {0, 156, 93, 255},
        --elm_track = {139, 216, 201, 255},        
    },    
    Black = {
        wnd_bg = {32, 32, 32, 255},
        txt = {255, 255, 255, 255},
        elm_bg = {48, 48, 48, 255},
        elm_fill = {255, 255, 255, 255},
        elm_frame = {162, 162, 162, 255},
        elm_outline = {118, 118, 118, 255},
        tab_bg = {108, 108, 108, 255},
        
        btn_face = {180, 180, 180, 255},
        btn_outline = {27, 27, 27, 255},
        btn_txt = {0, 0, 0, 255},
        aux_bg = {180, 180, 180, 255},
        aux_txt = {0, 0, 0, 255},
        thumb_body = {162, 162, 162, 255},
        track_fill = {144, 144, 144, 255},

        panel_bg = {64, 64, 64, 255},
        panel_border = {162, 162, 162, 255},
        panel_txt = {255, 255, 255, 255},
        elm_txt = {255, 255, 255, 255},        
        sel_txt = {128, 128, 128, 128},
        tab_active = {198, 198, 198, 255},
        tab_inactive = {160, 160, 160, 255},
        
        elm_active = {255, 255, 255, 255},        
        metadata = {0, 0, 0, 255},
        
        --elm_thumb = {99, 99, 99, 255},
        --elm_track = {198, 198, 198, 255},        
    },        
    Desert = {
        wnd_bg = {231, 193, 164, 255},
        txt = {96, 24, 0, 255},
        elm_bg = {64, 64, 42, 255},
        elm_fill = {135, 64, 64, 255},
        elm_frame = {216, 192, 164, 255},
        elm_outline = {104, 144, 100, 255},
        tab_bg = {209, 171, 143, 255},

        btn_face = {220, 200, 172, 255},
        --btn_outline = {104, 144, 100, 255},
        btn_outline = {95, 117, 91, 255},        
        btn_txt = {96, 24, 0, 255},
        aux_bg = {220, 200, 172, 255},
        aux_txt = {96, 24, 0, 255},
        thumb_body = {209, 185, 158, 255},
        track_fill = {104, 144, 100, 255},

        panel_bg = {236, 218, 200, 255},
        panel_border = {104, 144, 100, 255},
        panel_txt = {96, 24, 0, 255},
        elm_txt = {225, 225, 225, 255},        
        sel_txt = {105, 153, 96, 128},
        tab_active = {238, 208, 188, 255},
        tab_inactive = {209, 171, 143, 255},
        
        elm_active = {255, 0, 255, 255},        
        metadata = {0, 0, 0, 255},
        
        --elm_thumb = {164, 128, 83, 255},
        --elm_track = {221, 207, 190, 255},        
    },
    Gray = {
        wnd_bg = {81, 90, 90, 255},
        txt = {255, 254, 255, 255},
        elm_bg = {57, 66, 66, 255},
        elm_fill = {255, 255, 255, 255},
        elm_frame = {198, 198, 198, 255},
        elm_outline = {118, 118, 118, 255},
        tab_bg = {108, 108, 108, 255},

        btn_face = {208, 208, 208, 255},
        btn_outline = {63, 63, 63, 255},
        btn_txt = {0, 0, 0, 255},
        aux_bg = {208, 208, 208, 255},
        aux_txt = {0, 0, 0, 255},
        thumb_body = {208, 208, 208, 255},
        track_fill = {144, 144, 144, 255},

        panel_bg = {172, 172, 172, 255},
        panel_border = {188, 188, 188, 255},
        panel_txt = {0, 0, 0, 255},
        elm_txt = {255, 255, 255, 255},        
        sel_txt = {124, 124, 124, 102},
        tab_active = {198, 198, 198, 255},
        tab_inactive = {168, 168, 168, 255},
        
        elm_active = {255, 255, 255, 255},        
        metadata = {0, 0, 0, 255},
        
        --elm_thumb = {99, 99, 99, 255},
        --elm_track = {198, 198, 198, 255},        
    },
    Magenta = {
        wnd_bg = {128, 16, 96, 255},
        txt = {219, 210, 219, 255},
        elm_bg = {66, 39, 66, 255},
        elm_fill = {209, 135, 209, 255},
        elm_frame = {200, 103, 182, 255},
        elm_outline = {209, 130, 209, 255},
        tab_bg = {136, 9, 83, 255},
        
        btn_face = {173, 54, 146, 255},
        --btn_outline = {221, 108, 206, 255},
        btn_outline = {95, 0, 98, 255},
        btn_txt = {219, 210, 219, 255},
        aux_bg = {173, 54, 146, 255},
        aux_txt = {219, 210, 219, 255},
        thumb_body = {173, 54, 146, 255},
        track_fill = {164, 72, 146, 255},

        panel_bg = {120, 30, 102, 255},
        panel_border = {200, 103, 182, 255},
        panel_txt = {226, 226, 226, 255},
        elm_txt = {226, 226, 226, 255},        
        sel_txt = {165, 30, 140, 128},
        tab_active = {180, 45, 162, 255},
        tab_inactive = {136, 9, 83, 255},
        
        elm_active = {237, 129, 200, 255},        
        metadata = {0, 0, 0, 255},
        
        --elm_thumb = {127, 27, 92, 255},
        --elm_track = {185, 100, 158, 255},
    },
    Mocha = {
        wnd_bg = {132, 90, 90, 255},
        txt = {255, 236, 230, 255},
        elm_bg = {70, 66, 66, 255},
        elm_fill = {255, 249, 244, 255},
        elm_frame = {202, 162, 144, 255},
        elm_outline = {118, 100, 100, 255},
        tab_bg = {192, 172, 152, 255},
        
        btn_face = {204, 178, 172, 255},
        btn_outline = {100, 82, 82, 255},
        btn_txt = {64, 36, 0, 255},
        aux_bg = {202, 184, 162, 255},
        aux_txt = {64, 36, 0, 255},
        thumb_body = {201, 170, 144, 255},
        track_fill = {166, 142, 136, 255},
        
        panel_bg = {222, 202, 192, 255},
        panel_border = {202, 162, 144, 255},
        panel_txt = {0, 0, 0, 255},
        elm_txt = {255, 237, 233, 255},
        sel_txt = {121, 94, 67, 128},
        tab_active = {218, 202, 180, 255},
        tab_inactive = {192, 172, 152, 255},
        
        elm_active = {255, 248, 240, 255},
        metadata = {0, 0, 0, 255},
    },    

    Neon = {
        wnd_bg = {36, 36, 36, 255},
        txt = {75, 237, 75, 255},
        elm_bg = {27, 27, 27, 255},
        elm_fill = {180, 54, 189, 255},
        elm_frame = {219, 118, 210, 255},
        elm_outline = {255, 172, 255, 255},
        tab_bg = {38, 38, 38, 255},

        btn_face = {162, 57, 166, 255},
        --btn_outline = {224, 135, 224, 255},
        btn_outline = {64, 0, 64, 255},
        btn_txt = {75, 237, 75, 255},
        aux_bg = {162, 57, 166, 255},
        aux_txt = {75, 255, 75, 255},
        thumb_body = {162, 57, 166, 255},
        track_fill = {156, 70, 156, 255},

        panel_bg = {18, 18, 18, 255},
        panel_border = {216, 148, 216, 255},
        panel_txt = {75, 237, 75, 255},
        elm_txt = {75, 237, 75, 255},        
        sel_txt = {221, 99, 206, 153},
        tab_active = {138, 52, 138, 255},
        tab_inactive = {38, 38, 38, 255},
        
        elm_active = {255, 111, 110, 255},        
        metadata = {0, 0, 0, 0},
        
        --elm_thumb = {138, 52, 138, 255},
        --elm_track = {216, 148, 216, 255},        
    },
    Pastel = {
        wnd_bg = {182, 224, 248, 255},
        txt = {0, 64, 64, 255},
        elm_bg = {48, 48, 48, 255},
        elm_fill = {207, 63, 189, 255},
        elm_frame = {218, 193, 220, 255},
        elm_outline = {95, 50, 86, 255},
        tab_bg = {163, 204, 228, 255},
        
        btn_face = {121, 224, 211, 255},
        btn_outline = {48, 138, 117, 255},
        btn_txt = {0, 64, 64, 255},
        aux_bg = {121, 224, 211, 255},
        aux_txt = {0, 64, 64, 255},
        thumb_body = {65, 168, 146, 255},
        track_fill = {48, 192, 144, 255},

        panel_bg = {228, 211, 246, 255},
        panel_border = {48, 192, 144, 255},
        panel_txt = {0, 64, 64, 255},
        elm_txt = {216, 216, 216, 255},        
        sel_txt = {212, 178, 212, 128},
        tab_active = {182, 224, 248, 255},
        tab_inactive = {132, 220, 228, 255},
        
        elm_active = {255, 54, 216, 255},        
        metadata = {0, 0, 0, 255},
        
        --elm_thumb = {174, 103, 174, 255},
        --elm_track = {218, 193, 220, 255},        
    },    
    Sepia = {
        wnd_bg = {144, 87, 81, 255},
        txt = {245, 225, 221, 255},
        elm_bg = {48, 48, 48, 255},
        elm_fill = {128, 99, 68, 255},
        elm_frame = {225, 181, 167, 255},
        elm_outline = {32, 32, 32, 255},
        tab_bg = {207, 145, 140, 255},
        
        btn_face = {224, 184, 176, 255},
        btn_outline = {96, 59, 51, 255},
        btn_txt = {57, 38, 19, 255},
        aux_bg = {224, 184, 176, 255},
        aux_txt = {57, 38, 19, 255},
        thumb_body = {215, 166, 158, 255},
        track_fill = {196, 128, 116, 255},        

        panel_bg = {234, 207, 204, 255},
        panel_border = {224, 171, 167, 255},
        panel_txt = {85, 48, 20, 255},
        elm_txt = {254, 243, 239, 255},        
        sel_txt = {226, 147, 153, 128},
        tab_active = {234, 198, 180, 255},
        tab_inactive = {208, 162, 148, 255},
        
        elm_active = {201, 72, 39, 255},        
        metadata = {0, 0, 0, 255},
        
        --elm_thumb = {186, 124, 116, 255},
        --elm_track = {234, 207, 204, 255},        
    },    
    Silver = {
        wnd_bg = {168, 180, 180, 255},
        txt = {0, 0, 0, 255},
        elm_bg = {57, 66, 66, 255},
        elm_fill = {255, 255, 255, 255},
        elm_frame = {198, 198, 198, 255},
        elm_outline = {118, 118, 118, 255},
        tab_bg = {108, 108, 108, 255},
        
        btn_face = {208, 208, 208, 255},
        btn_outline = {88, 88, 88, 255},
        btn_txt = {0, 0, 0, 255},
        aux_bg = {208, 208, 208, 255},
        aux_txt = {0, 0, 0, 255},
        thumb_body = {208, 208, 208, 255},
        track_fill = {144, 144, 144, 255},        

        panel_bg = {81, 90, 90, 255},
        panel_border = {197, 197, 197, 255},
        panel_txt = {255, 254, 255, 255},
        elm_txt = {255, 255, 255, 255},        
        sel_txt = {144, 144, 144, 128},
        tab_active = {208, 208, 208, 255},
        tab_inactive = {180, 189, 189, 255},
        elm_active = {255, 255, 255, 255},        
        metadata = {0, 0, 0, 255},
        
        --elm_thumb = {99, 99, 99, 255},
        --elm_track = {198, 198, 198, 255},        
    },            
}

----------------------------------
------    COLOR NAMES    -------
----------------------------------
--zzcn 
-- GUI.colors 
-- Use to populate Colors Tab.
-- !!! Order is important for dh_ThemeDesigner

dh_Toolkit_themes.COLOR_NAMES = {
    -- Lokasenna defined
    "wnd_bg",
    "txt",
    "elm_bg",
    "elm_fill",
    "elm_frame",
    "elm_outline",
    "tab_bg",  -- inactive
    
    -- dh_Toolkit defined
    "btn_face",
    "btn_outline",
    "btn_txt",
    "aux_bg",
    "aux_txt",
    "thumb_body",
    "track_fill",
    
    "panel_bg",
    "panel_border",
    "panel_txt",        
    "elm_txt",
    "sel_txt",
    "tab_active",
    "tab_inactive",
    
    "elm_active",    
    "metadata",
    --"elm_thumb",    
    --"elm_track",    
}

-----------------------------------
------     FUNCTIONS      ------
-----------------------------------
-- GUI.colors are a table of of colors specified by a color name.
-- If changing a GUI.color the values must be copied, not assigned.
-- i.e., GUI.colors["wnd_bg"] = GUI.colors["new_color"]
--   then subsequenr changed to GUI.colors["new_color"] 
--   will change GUI.colors["wnd_bg"] because they point to the same color.
-- GUI.colors["wnd_bg"] = set_color(GUI.colors["new_color"])
--   copies color values to GUI.colors["wnd_bg"].
--   Subsequent changes to GUI.colors["new_color"] will not affect 
--   GUI.colors["wnd_bg"] as GUI.colors["wnd_bg"] references 
--   the newly created newcolor.

function dh_Toolkit_themes.set_color(color)
    --if not color then return GUI.colors.wnd_bg end
    local newcolor = {}
    table.insert(newcolor, color[1])
    table.insert(newcolor, color[2])
    table.insert(newcolor, color[3])
    table.insert(newcolor, color[4])
    return newcolor
end

function dh_Toolkit_themes.set_color_int2dec(color)
    local newcolor = {}
    table.insert(newcolor, GUI.clamp(color[1] / 255,0,1))
    table.insert(newcolor, GUI.clamp(color[2] / 255,0,1))
    table.insert(newcolor, GUI.clamp(color[3] / 255,0,1))
    table.insert(newcolor, GUI.clamp(color[4] / 255,0,1))
    return newcolor
end

function dh_Toolkit_themes.set_color_dec2int(color)
    local newcolor = {}
    table.insert(newcolor, math.floor((color[1] * 255) + 0.5))
    table.insert(newcolor, math.floor((color[2] * 255) + 0.5))
    table.insert(newcolor, math.floor((color[3] * 255) + 0.5))
    table.insert(newcolor, math.floor((color[4] * 255) + 0.5))
    return newcolor
end

-- IMPORTANT: If GUI has already been initialized then 
--   colors have to be converted from 0..255 to 0..1.
-- @param theme : Reference to a DH_THEME or a USER_THEME.
-- @param isGuiInit : boolean <true if script has been initialized>

function dh_Toolkit_themes.set_theme(theme, isGuiInit)
    
    -- In case the theme lacks a color in COLOR_NAMES.
    
    for _, col_name in ipairs(dh_Toolkit_themes.COLOR_NAMES) do
    
        --GUI.Msg("set theme col_name : " .. col_name)
    
        if not GUI.colors[col_name] then
        
            --GUI.Msg("if not GUI.colors[col_name] : " .. col_name)
                 
            if isGuiInit then
                GUI.colors[col_name] = {0.5,0.5,0.5,1}
            else
                GUI.colors[col_name] = {128,128,128,255}
            end
        end
    end

    -- !!! Don't want to convert theme colors.
    -- Just assign them to GUI.colors.     

    -- name:  wnd_bg
    -- col:   {64, 64, 64, 255}
    for col_name, col in pairs(theme) do
    
        local newcolor = {}
        
        if isGuiInit then
            --col[1], col[2], col[3], col[4] = col[1] / 255, col[2] / 255, col[3] / 255, col[4] / 255 
            table.insert(newcolor, GUI.clamp(col[1] / 255,0,1))
            table.insert(newcolor, GUI.clamp(col[2] / 255,0,1))
            table.insert(newcolor, GUI.clamp(col[3] / 255,0,1))
            table.insert(newcolor, GUI.clamp(col[4] / 255,0,1))
        else
            table.insert(newcolor, GUI.clamp(col[1],0,255))
            table.insert(newcolor, GUI.clamp(col[2],0,255))
            table.insert(newcolor, GUI.clamp(col[3],0,255))
            table.insert(newcolor, GUI.clamp(col[4],0,255))            
        end
        
        --GUI.Msg("dhth.set_theme: newcolor name is: " .. name .. "\n")
        --if col_name == "metadata" then GUI.Msg("metadata[4] : " .. tostring(col[4])) end
        
        GUI.colors[col_name] = newcolor
    end

end

return dh_Toolkit_themes

-----------------------------------
----  ONLY INFO BEYOND HERE  ----
-----------------------------------
-----------------------------------
----   GUI COLORS INFO     ----
-----------------------------------
--[==[
    IMPORTANT: If GUI has already been initialized then colors have to be converted to from 0..255 to 0..1.
	Prior to calling GUI.Init, the color presets are stored as 0-255 values. 
	GUI.Init converts them to 0-1, since that's what REAPER's gfx functions use. 
	Be aware of this if you need to work with any color values directly after the script has started.
	-- In GUI.Init()
    -- Convert color presets from 0..255 to 0..1
    for i, col in pairs(GUI.colors) do
        col[1], col[2], col[3], col[4] = col[1] / 255, col[2] / 255, col[3] / 255, col[4] / 255
    end
--]==]

--[==[
Element colors defined in Core.lua 

    -- Element colors
    wnd_bg = {64, 64, 64, 255},	      -- Window BG 
    tab_bg = {56, 56, 56, 255},	      -- Tabs BG 
    elm_bg = {48, 48, 48, 255},		  -- Element BG 
    elm_frame = {96, 96, 96, 255},    -- Element Frame 
    elm_fill = {64, 192, 64, 255},	  -- Element Fill 
    elm_outline = {32, 32, 32, 255},  -- Element Outline 
    txt = {192, 192, 192, 255},		  -- Text

    shadow = {0, 0, 0, 48},			  -- Element Shadows
    faded = {0, 0, 0, 64},

    -- Standard 16 colors
    black = {0, 0, 0, 255},
    white = {255, 255, 255, 255},
    red = {255, 0, 0, 255},
    lime = {0, 255, 0, 255},
    blue =  {0, 0, 255, 255},
    yellow = {255, 255, 0, 255},
    cyan = {0, 255, 255, 255},
    magenta = {255, 0, 255, 255},
    silver = {192, 192, 192, 255},
    gray = {128, 128, 128, 255},
    maroon = {128, 0, 0, 255},
    olive = {128, 128, 0, 255},
    green = {0, 128, 0, 255},
    purple = {128, 0, 128, 255},
    teal = {0, 128, 128, 255},
    navy = {0, 0, 128, 255},

    none = {0, 0, 0, 0},


Additional colors defined in dh_Toolkit_themes.

    btn_face     -- Face color for Button, Knob, Slider thumb
    btn_outline  -- Outline for Button, Knob, Slider thumb
    btn_txt      -- Button text
    aux_bg       -- Alternate BG/Face color for Button, Knob, Slider thumb, etc.
    aux_txt      -- Alternate Text color for Button, Knob, Slider thumb, etc.
    thumb_body   -- Slider Thumb     
    elm_active   -- Outline for focused Menubox, Textbox, and TextEditor   
    elm_txt      -- Text Elements text
    --elm_track    -- scrollbar track color
    --elm_thumb    -- scrollbar thumb color
    panel_border -- Panel border color
    panel_bg     -- Panel fill color
    panel_txt    -- Optional text color for Panel    
    sel_txt      -- Optional highlight color for Elements selected text
    tab_active   -- Active tab color
    tab_inactive -- Inactive tab color
    track_fill   -- Slider track fill color
--]==]

-----------------------------------
------    GUI FONTS INFO   ------
-----------------------------------
--[==[
-- Declaration in core.lua.
-- Presets can be overridden or added to at any point:
-- GUI.fonts[2] = {fonts.sans, 28}
-- GUI.fonts["meme"] = {"Impact", 20, "b"}
-- Set using the accompanying functions GUI.font
-- GUI.font(2) applies the Header preset

local fonts = GUI.get_OS_fonts()
GUI.fonts = {
                -- Font, size, bold/italics/underline
                -- 				^ One string: "b", "iu", etc.
                {fonts.sans, 32},	-- 1. Title
                {fonts.sans, 20},	-- 2. Header
                {fonts.sans, 16},	-- 3. Label
                {fonts.sans, 16},	-- 4. Value
    monospace = {fonts.mono, 14},
    version = 	{fonts.sans, 12, "i"},
}
--]==]