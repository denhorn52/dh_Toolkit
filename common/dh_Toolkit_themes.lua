-- dh_Toolkit_themes.lua
-- version 1.0
-- Author: Dennis R. Horn
-- Date: 2025-04-05

-- Adds themes to Lokasenna GUI used in dh_Toolkit scripts.

-----------------------------------
if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end
-----------------------------------
dh_Toolkit_themes = {}
-----------------------------------


-- These will be displayed in radio options element.
-- Used when scaling app.
-- 20250405 Moved APP_SCALE_FACTORS to dh_Toolkit_prefs.
--[[
dh_Toolkit_themes.APP_SCALE_FACTORS = {
  "0.75", 
  "1.00",
  "1.25",     
  "1.50", 
  "2.00"
}
--]]

-- Theme names are mainly used to populate a checklist.
-- Usage:   opts = dhtk.DH_THEMES
  
dh_Toolkit_themes.DH_THEME_NAMES = {
  "Default",
  "Magenta",
  "Desert",
  "Aqua",
  "Neon",
  "User"
}

-- dh_Toolkit theme definitions.
-- Values are in 0..255 format for compatibility with GUI.
-- Lokasenna GUI defines colors in 0..255 format then
--   converts them them to 0..1 during GUI.Init().

dh_Toolkit_themes.DH_THEMES = {
  Default = {
    wnd_bg = {64, 64, 64, 255},		 
    tab_bg = {56, 56, 56, 255},		    
    elm_bg = {48, 48, 48, 255},		
    elm_frame = {96, 96, 96, 255},
    elm_fill = {64, 64, 64, 255},	      
    elm_outline = {32, 32, 32, 255},
    txt = {216, 216, 216, 255},
    
    dlg_bg = {0, 0, 0, 168},  
    btn_face = {96, 96, 96, 255}, 
    knob_face = {96, 96, 96, 255},
    elm_border = {98, 98, 98, 255},
    opt_frame = {192, 192, 192, 255},
    opt_fill = {255, 255, 255, 255},
    tab_act = {96, 96, 96, 255},
    txt2 = {216, 216, 216, 255}
  },
  Magenta = {
    wnd_bg = {144, 0, 144, 255},		 
    tab_bg = {128, 0, 128, 255},		    
    elm_bg = {48, 48, 48, 255},		
    elm_frame = {183, 64, 183, 255},
    elm_fill = {144, 0, 144, 255},	      
    elm_outline = {216, 128, 216, 255},
    txt = {216, 216, 216, 255},
    
    dlg_bg = {0, 0, 0, 168},  
    btn_face = {192, 72, 192, 255}, 
    knob_face = {192, 72, 192, 255},
    elm_border = {216, 128, 216, 255},
    opt_frame = {255, 168, 255, 255},
    opt_fill = {255, 224, 255, 255},
    tab_act = {183, 64, 183, 255},
    txt2 = {224, 224, 224, 255}
  },
  Desert = {
    wnd_bg = {230, 192, 162, 255},		 
    tab_bg = {220, 182, 154, 255},		    
    elm_bg = {48, 48, 48, 255},		
    elm_frame = {230, 218, 192, 255},
    elm_fill = {230, 192, 162, 255},	      
    elm_outline = {32, 32, 32, 255},
    txt = {96, 24, 0, 255},
    
    dlg_bg = {0, 0, 0, 168},  
    btn_face = {230, 218, 192, 255}, 
    knob_face = {230, 218, 192, 255},
    elm_border = {108, 166, 112, 255},
    opt_frame = {82, 128, 96, 255},
    opt_fill = {16, 64, 64, 255},
    tab_act = {230, 218, 192, 255},
    txt2 = {224, 224, 224, 255}
  },
  Aqua = {
    wnd_bg = {144, 205, 205, 255},		 
    tab_bg = {112, 192, 192, 255},		    
    elm_bg = {48, 48, 48, 255},		
    elm_frame = {144, 205, 205, 255},
    elm_fill = {144, 205, 205, 255},	      
    elm_outline = {32, 32, 32, 255},
    txt = {0, 64, 64, 255},
    
    dlg_bg = {0, 0, 0, 168},  
    btn_face = {112, 225, 192, 255}, 
    knob_face = {112, 225, 192, 255},
    elm_border = {48, 192, 144, 255},
    opt_frame = {0, 128, 64, 255},
    opt_fill = {0, 64, 64, 255},
    tab_act = {166, 218, 218, 255},
    txt2 = {216, 216, 216, 255}
  },
  Neon = {
    wnd_bg = {0, 0, 0, 255},		 
    tab_bg = {56, 56, 56, 255},		    
    elm_bg = {32, 32, 32, 255},		
    elm_frame = {255, 172, 255, 255},
    elm_fill = {0, 0, 0, 255},	      
    elm_outline = {255, 172, 255, 255},
    txt = {75, 255, 75, 255},
    
    dlg_bg = {0, 0, 0, 168},  
    btn_face = {32, 32, 32, 255}, 
    knob_face = {92, 64, 92, 255},
    elm_border = {216, 148, 216, 255},
    opt_frame = {255, 172, 255, 255},
    opt_fill = {255, 205, 255, 255},
    tab_act = {128, 85, 128, 255},
    txt2 = {75, 255, 75, 255}
  
  }
}

--------------------------------------------------
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
    local newcolor = {}
    table.insert(newcolor, color[1])
    table.insert(newcolor, color[2])
    table.insert(newcolor, color[3])
    table.insert(newcolor, color[4])
    return newcolor
end

-- IMPORTANT: If GUI has already been initialized then 
--   colors have to be converted from 0..255 to 0..1.
-- @param theme : Reference to a DH_THEME or a USER_THEME.
-- @param isGuiInit : boolean <true if script has been initialized>

function dh_Toolkit_themes.set_theme(theme, isGuiInit)

    -- !!! Don't want to convert theme colors.
    -- Just assign them to GUI.colors.     

    -- name:  wnd_bg
    -- col:   {64, 64, 64, 255}
    for name, col in pairs(theme) do
        local newcolor = {}
        if isGuiInit then
            --col[1], col[2], col[3], col[4] = col[1] / 255, col[2] / 255, col[3] / 255, col[4] / 255 
            table.insert(newcolor, col[1] / 255)
            table.insert(newcolor, col[2] / 255)
            table.insert(newcolor, col[3] / 255)
            table.insert(newcolor, col[4] / 255)
        else
            table.insert(newcolor, col[1])
            table.insert(newcolor, col[2])
            table.insert(newcolor, col[3])
            table.insert(newcolor, col[4])            
        end
        
        --dh_log("dhth.set_theme: newcolor name is: " .. name .. "\n")
        GUI.colors[name] = newcolor
    end

end

--------------------------------------------------
--zzcoluses

-- GUI color names, both Lokasenna defined and dh_Toolkit defined.

dh_Toolkit_themes.COLOR_NAMES = {
    "wnd_bg",
    "tab_bg",
    "elm_bg",
    "elm_frame",
    "elm_fill",
    "elm_outline",
    "txt",
    "dlg_bg",
    "btn_face",
    "elm_border",
    "knob_face",
    "opt_frame",
    "opt_fill",
    "tab_act",
    "txt2"
}

-- Color uses are used by dh_ThemeDesigner
-- to display typical element fields where GUI colors are used.

dh_Toolkit_themes.COLOR_USES = {
    wnd_bg = {
        "Window BG *",
        "Text BG *",
        "Caption BG *",
        "Label BG *"
    },
    tab_bg = {
        "Active Tab BG"
    },
    elm_bg = {
        "Listbox *",
        "Menubox",
        "Textbox",
        "TextEditor box *",
        "Slider track *"
    },
    elm_frame = {
        "Frame color *",
        "Knob head *",
        "Listbox outline",
        "Menubox outline",
        "Option outline",
        "Slider handle head *",
        "Textbox outline"
    },
    elm_fill = {
        "Knob arrow face *",
        "Option button fill *",
        "Slider track fill *"
    },
    elm_outline = {
        "Button outline",
        "Knob outline",
        "Slider outline",
        "Textbox outline"
    },
    txt = {
        "Text *",
        "Label text *",
        "Caption text *"
    },
    dlg_bg = {
        "Dialog BG %"
    },
    btn_face = {
        "Button face %"
    },
    elm_border = {
        "dh_Frame outer rectangle %"
    },
    knob_face = {
        "Knob and Slider heads %"
    },
    opt_frame = {
        "Option frame %"
    },
    opt_fill = {
        "Option button fill %"
    },
    tab_act = {
        "Active Tab %"
    },
    txt2 = {
        "Alt. text color %"
    }
}

--------------------------------------------------
--zzfonts

-- dh_Toolkit defined font sets for various scaled sizes of windows.

function dh_Toolkit_themes.set_scaled_fonts(scale)
    dh_log("dh_Toolkit_themes.set_scaled_fonts scale is: " .. scale .. "\n")
    local new_fonts = GUI.get_OS_fonts()

    if scale == "0.75" then
    
        GUI.fonts["sans16"] = {new_fonts.sans, 12}
        GUI.fonts["sans18"] = {new_fonts.sans, 14}
        GUI.fonts["sans20"] = {new_fonts.sans, 15}
        GUI.fonts["sans22"] = {new_fonts.sans, 16}
        GUI.fonts["sans24"] = {new_fonts.sans, 18}
        GUI.fonts["sans28"] = {new_fonts.sans, 20}
        GUI.fonts["sans32"] = {new_fonts.sans, 24}
        
        GUI.fonts["mono16"] = {new_fonts.mono, 12}
        GUI.fonts["mono18"] = {new_fonts.mono, 14}
        GUI.fonts["mono20"] = {new_fonts.mono, 15}
        GUI.fonts["mono22"] = {new_fonts.mono, 16}
        GUI.fonts["mono24"] = {new_fonts.mono, 18}
        GUI.fonts["mono28"] = {new_fonts.mono, 20}
        GUI.fonts["mono32"] = {new_fonts.mono, 24}

    elseif scale == "1.00" then
    
        GUI.fonts["sans16"] = {new_fonts.sans, 16}
        GUI.fonts["sans18"] = {new_fonts.sans, 18}
        GUI.fonts["sans20"] = {new_fonts.sans, 20}
        GUI.fonts["sans22"] = {new_fonts.sans, 22}
        GUI.fonts["sans24"] = {new_fonts.sans, 24}
        GUI.fonts["sans28"] = {new_fonts.sans, 28}
        GUI.fonts["sans32"] = {new_fonts.sans, 32}
        
        GUI.fonts["mono16"] = {new_fonts.mono, 16}
        GUI.fonts["mono18"] = {new_fonts.mono, 18}
        GUI.fonts["mono20"] = {new_fonts.mono, 20}
        GUI.fonts["mono22"] = {new_fonts.mono, 22}
        GUI.fonts["mono24"] = {new_fonts.mono, 24}
        GUI.fonts["mono28"] = {new_fonts.mono, 28}
        GUI.fonts["mono32"] = {new_fonts.mono, 32}
        
    elseif scale == "1.25" then   
        GUI.fonts["sans16"] = {new_fonts.sans, 20}
        GUI.fonts["sans18"] = {new_fonts.sans, 22}
        GUI.fonts["sans20"] = {new_fonts.sans, 24}
        GUI.fonts["sans22"] = {new_fonts.sans, 27}
        GUI.fonts["sans24"] = {new_fonts.sans, 30}
        GUI.fonts["sans28"] = {new_fonts.sans, 36}
        GUI.fonts["sans32"] = {new_fonts.sans, 40}
        
        GUI.fonts["mono16"] = {new_fonts.mono, 20}
        GUI.fonts["mono18"] = {new_fonts.mono, 22}
        GUI.fonts["mono20"] = {new_fonts.mono, 24}
        GUI.fonts["mono22"] = {new_fonts.mono, 27}
        GUI.fonts["mono24"] = {new_fonts.mono, 30}
        GUI.fonts["mono28"] = {new_fonts.mono, 36}
        GUI.fonts["mono32"] = {new_fonts.mono, 40}
        
    elseif scale == "1.50" then   
        GUI.fonts["sans16"] = {new_fonts.sans, 24}
        GUI.fonts["sans18"] = {new_fonts.sans, 27}
        GUI.fonts["sans20"] = {new_fonts.sans, 30}
        GUI.fonts["sans22"] = {new_fonts.sans, 33}
        GUI.fonts["sans24"] = {new_fonts.sans, 36}
        GUI.fonts["sans28"] = {new_fonts.sans, 42}
        GUI.fonts["sans32"] = {new_fonts.sans, 48}
        
        GUI.fonts["mono16"] = {new_fonts.mono, 24}
        GUI.fonts["mono18"] = {new_fonts.mono, 27}
        GUI.fonts["mono20"] = {new_fonts.mono, 30}
        GUI.fonts["mono22"] = {new_fonts.mono, 33}
        GUI.fonts["mono24"] = {new_fonts.mono, 36}
        GUI.fonts["mono28"] = {new_fonts.mono, 42}
        GUI.fonts["mono32"] = {new_fonts.mono, 48}

    elseif scale == "2.00" then

        GUI.fonts["sans16"] = {new_fonts.sans, 32}
        GUI.fonts["sans18"] = {new_fonts.sans, 36}
        GUI.fonts["sans20"] = {new_fonts.sans, 40}
        GUI.fonts["sans22"] = {new_fonts.sans, 44}
        GUI.fonts["sans24"] = {new_fonts.sans, 48}
        GUI.fonts["sans28"] = {new_fonts.sans, 56}
        GUI.fonts["sans32"] = {new_fonts.sans, 64}
        
        GUI.fonts["mono16"] = {new_fonts.mono, 32}
        GUI.fonts["mono18"] = {new_fonts.mono, 36}
        GUI.fonts["mono20"] = {new_fonts.mono, 40}
        GUI.fonts["mono22"] = {new_fonts.mono, 44}
        GUI.fonts["mono24"] = {new_fonts.mono, 48}
        GUI.fonts["mono28"] = {new_fonts.mono, 56}
        GUI.fonts["mono32"] = {new_fonts.mono, 64}
        
    else
        return
    end

end

return dh_Toolkit_themes

---------------------------------
-- ONLY INFO BEYOND HERE --
---------------------------------
---------------------------------
------  GUI COLORS INFO  ------
---------------------------------
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

    dlg_bg       -- Dialog background blackout color
    btn_face     -- Button face
    knob_face    -- Knob face, Slider handle
    elm_border   -- dh_Frame outer rectangle
    opt_frame    -- Options outline and bubble outline
    opt_fill     -- Options bubble fill color
    tab_active   -- Active tab face
    txt2         -- Can be used as alternate to txt

--]==]

--------------------------------
------   GUI FONTS INFO  ------
--------------------------------
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