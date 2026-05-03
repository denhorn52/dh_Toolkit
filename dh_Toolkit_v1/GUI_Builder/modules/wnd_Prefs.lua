-- NoIndex: true

-- wnd_Prefs.lua
-- Modified 20260330


local Prefs = GUI.req(GUI.script_path .. "modules/func_Prefs.lua")()

-- Global preferencse
GUI.New("GB_wnd_prefs", "dh_Window", {
    z = 497,
    x = 0, 
    y = 0, 
    w = 360, 
    h = 270, 
    caption = "Preferences",
    --z_set = {495, 496, 497},
    z_set = {496, 497},    
})

GUI.New("GB_wnd_prefs_grid_snap", "dh_Checklist", {
    z = 496,
    x = 16, 
    y = 12, --16, 
    w = 192, 
    h = 28, 

    opts = "Snap to grid",
    shadow = false,      -- default is true
    border_width = 0,    -- default is 1
})

GUI.New("GB_wnd_prefs_grid_show", "dh_Checklist", {
    z = 496,
    x = 16, 
    y = 40, --44, 
    w = 192, 
    h = 28, 

    opts = "Show grid",
    shadow = false,      -- default is true
    border_width = 0,    -- default is 1
})

GUI.New("GB_wnd_prefs_grid_size", "dh_Textbox", {
    z = 496,
    x = 128, 
    y = 72, --88, 
    w = 64, 
    h = 24, 
    caption = "Grid size:",
    cap_pos = "left",
    cap_centered = true,
    font_caption = "sans22",
    --font_text = "mono16",    
})

GUI.New("GB_wnd_prefs_grid_color", "dh_Menubox", {
    z = 496,
    x = 128, 
    y = 104, --120, 
    w = 96, 
    h = 24, 
    caption = "Grid color:",
    cap_pos = "left",
    cap_centered = true,
    font_caption = "sans22",
    optarray = {
        "black", 
        "dark_gray",
        "gray", 
        "light_gray",
        "white",
    }
    --font_text = "mono16",    
})

GUI.New("GB_wnd_prefs_grid_font", "dh_Menubox", {
    z = 496,
    x = 128, 
    y = 136, --152, 
    w = 96, 
    h = 24, 
    caption = "Grid font:",
    cap_pos = "left",
    cap_centered = true,
    font_caption = "sans22",
    optarray = {
        "sans16", 
        "sans18",
        "sans20", 
        "sans22",
        "sans24", 
        "sans28",
    }
    --font_text = "mono16",    
})

GUI.New("GB_wnd_prefs_font_scale", "dh_Menubox", {
    z = 496,
    x = 128, 
    y = 168, 
    w = 96, 
    h = 24, 
    caption = "Font scale:",
    cap_pos = "left",
    cap_centered = true,
    font_caption = "sans22",
    --[[
    optarray = {
        "0.80", 
        "0.90",
        "1.00", 
        "1.10",
        "1.20", 
    },
    --]]
    optarray = DHTK.FONT_SCALE_FACTORS,
    curr_opt = 3,
    --font_text = "mono16",    
})


GUI.New("GB_wnd_prefs_OK", "dh_Button", {
    z = 496, 
    x = 0, 
    y = 0, 
    w = 64, 
    h = 24, 
    text = "OK",
    func = GUI.elms.GB_wnd_prefs.close,
    params = {GUI.elms.GB_wnd_prefs, true},
    
})

GUI.elms.GB_wnd_prefs.noadjust = {GB_wnd_prefs_OK = true}

GUI.elms_hide[496] = true
GUI.elms_hide[497] = true

GUI.elms.GB_wnd_prefs_grid_show.frame = false
GUI.elms.GB_wnd_prefs_grid_snap.frame = false


function GUI.elms.GB_wnd_prefs:onopen()
    --GUI.Msg("\n>>>   on OPEN")
    -- First open after script load needs to adjusts child elms.
    -- Subsequent loads only need to if project is resized.
    -- Doesn't hurt to force it on every open.    
    self:adjustchildelms(true)

    GUI.elms.GB_wnd_prefs_OK.x = GUI.center(GUI.elms.GB_wnd_prefs_OK, self)
    GUI.elms.GB_wnd_prefs_OK.y = self.y + self.h - 40 * DHTK.APP_SCALE
    
    --GUI.Msg("    DHTK.window_settings.font_scale : " .. DHTK.window_settings.font_scale)

    GUI.Val("GB_wnd_prefs_font_scale", GUI.table_find(DHTK.FONT_SCALE_FACTORS, DHTK.window_settings.font_scale))

    Prefs.populate_settings()

end

function GUI.elms.GB_wnd_prefs:onclose(ok)
    
    if ok then 
        --GUI.Msg("\n>>>   on CLOSE")
        Prefs.save_settings()
        
        if GUI.elms.GB_wnd_prefs_font_scale ~= DHTK.window_settings.font_scale then
            _, DHTK.window_settings.font_scale = GUI.elms.GB_wnd_prefs_font_scale:val()
            DHTK.set_scaled_fonts()
        end
        
        --GUI.Msg("    ready to update grid")
        GUI.elms.GB_frm_bg:init()
        GUI.elms.GB_frm_bg:redraw()
        
    end

end


return Prefs