-- NoIndex: true

-- wnd_Project.lua
-- Modified 20260330

local Project = GUI.req(GUI.script_path .. "modules/func_Project.lua")()

-- Project settings
GUI.New("GB_wnd_proj", "dh_Window", {
    z = 499,
    x = 0, 
    y = 0, 
    w = 400,    
    h = 400, 
    caption = "Project Settings",
    z_set = {498, 499},
})

local ref_wnd_proj = {x = 88, y = 32, x_off = 144, y_off = 28, tbx_w = 64, tbx_h = 28}

GUI.New("GB_wnd_proj_name", "dh_Textbox", {
    z = 498,
    x = ref_wnd_proj.x, 
    y = ref_wnd_proj.y, 
    w = 192, 
    h = ref_wnd_proj.tbx_h, 
    caption = "Name:",
    font_caption = "sans22",
    --font_text = "mono16",
})

GUI.New("GB_wnd_proj_x", "dh_Textbox", {
    z = 498,
    x = ref_wnd_proj.x, 
    y = ref_wnd_proj.y + 2 * ref_wnd_proj.y_off, 
    w = ref_wnd_proj.tbx_w, 
    h = ref_wnd_proj.tbx_h, 
    caption = "X:",
    font_caption = "sans22",
    --font_text = "mono16",    
})

GUI.New("GB_wnd_proj_y", "dh_Textbox", {
    z = 498,
    x = ref_wnd_proj.x + ref_wnd_proj.x_off, 
    y = ref_wnd_proj.y + 2 * ref_wnd_proj.y_off, 
    w = ref_wnd_proj.tbx_w, 
    h = ref_wnd_proj.tbx_h, 
    caption = "Y:",
    font_caption = "sans22",
    --font_text = "mono16",    
})

GUI.New("GB_wnd_proj_w", "dh_Textbox", {
    z = 498,
    x = ref_wnd_proj.x, 
    y = ref_wnd_proj.y + 4 * ref_wnd_proj.y_off, 
    w = ref_wnd_proj.tbx_w, 
    h = ref_wnd_proj.tbx_h, 
    caption = "Width:",
    font_caption = "sans22",
    --font_text = "mono16",    
})

GUI.New("GB_wnd_proj_h", "dh_Textbox", {
    z = 498,
    x = ref_wnd_proj.x + ref_wnd_proj.x_off, 
    y = ref_wnd_proj.y + 4 * ref_wnd_proj.y_off, 
    w = ref_wnd_proj.tbx_w, 
    h = ref_wnd_proj.tbx_h, 
    caption = "Height:",
    font_caption = "sans22",
    --font_text = "mono16",    
})

--[=[
GUI.New("GB_wnd_proj_anchor", "dh_Textbox", {
    z = 498,
    x = ref_wnd_proj.x, 
    y = ref_wnd_proj.y + 6 * ref_wnd_proj.y_off, 
    w = ref_wnd_proj.tbx_w, 
    h = ref_wnd_proj.tbx_h, 
    caption = "Anchor:",
    font_caption = "sans22",
    --font_text = "mono16",    
})
--]=]

GUI.New("GB_wnd_proj_anchor", "dh_Menubox", {
    z = 498,
    x = ref_wnd_proj.x, 
    y = ref_wnd_proj.y + 6 * ref_wnd_proj.y_off, 
    w = ref_wnd_proj.tbx_w * 1.5, 
    h = ref_wnd_proj.tbx_h, 
    caption = "Anchor:",
    cap_pos = "top",
    cap_centered = false,
    font_caption = "sans22",
    optarray = {
        "screen", 
        "mouse",
    }
    --font_text = "mono16",    
})

--[=[
GUI.New("GB_wnd_proj_corner", "dh_Textbox", {
    z = 498,
    x = ref_wnd_proj.x + ref_wnd_proj.x_off, 
    y = ref_wnd_proj.y + 6 * ref_wnd_proj.y_off, 
    w = ref_wnd_proj.tbx_w, 
    h = ref_wnd_proj.tbx_h, 
    caption = "Corner:",
    font_caption = "sans22",
    --font_text = "mono16",    
})
--]=]
GUI.New("GB_wnd_proj_corner", "dh_Menubox", {
    z = 498,
    x = ref_wnd_proj.x + ref_wnd_proj.x_off, 
    y = ref_wnd_proj.y + 6 * ref_wnd_proj.y_off, 
    w = ref_wnd_proj.tbx_w * 1.5, 
    h = ref_wnd_proj.tbx_h, 
    caption = "Corner:",
    cap_pos = "top",
    cap_centered = false,
    font_caption = "sans22",
    optarray = {
        "TL", 
        "T",
        "TR", 
        "R",
        "BR",
        "B",
        "BL", 
        "L",
        "C",
    }
    --font_text = "mono16",    
})

GUI.New("GB_wnd_proj_scripts_dir", "dh_Textbox", {
    z = 498,
    x = ref_wnd_proj.x, 
    y = ref_wnd_proj.y + (8 * ref_wnd_proj.y_off) + 16, 
    w = 242, 
    h = ref_wnd_proj.tbx_h, 
    caption = "Scripts Directory:",
    font_caption = "sans22",
    --font_text = "mono16",
    retval = "../scripts/",
})

GUI.New("GB_wnd_proj_OK", "dh_Button", {
    z = 498, 
    x = 0, 
    y = 0, 
    w = 64, 
    h = 24, 
    text = "OK",
    --font = "sans22",
    --col_bg = "btn_face",
    --col_border = "btn_outline",
    --col_text = "btn_txt",
    func = GUI.elms.GB_wnd_proj.close,
    params = {GUI.elms.GB_wnd_proj, true},
    
})

GUI.elms.GB_wnd_proj.noadjust = {
    GB_wnd_proj_OK = true,
}

GUI.elms_hide[498] = true
GUI.elms_hide[499] = true


function GUI.elms.GB_wnd_proj:onopen()

    --GUI.Msg("---- OPEN : GB_wnd_proj:onopen - adjust child elms ----")
    
    -- First open after script load needs to adjusts child elms.
    -- Subsequent loads only need to if project is resized.
    -- Doesn't hurt to force it on every open.
    self:adjustchildelms(true)

    GUI.elms.GB_wnd_proj_OK.x = GUI.center(GUI.elms.GB_wnd_proj_OK, self)
    --GUI.elms.GB_wnd_proj_OK.y = self.y + self.h - 40
    GUI.elms.GB_wnd_proj_OK.y = self.y + self.h - 40 * DHTK.APP_SCALE
    --GUI.elms.GB_wnd_proj_OK.y = self.y + (self.h * 0.8)
    
    -- Need these when window closes to determine if project w, h changed.
    self.project_w = Project.proj_settings.w
    self.project_h = Project.proj_settings.h

    Project.populate_settings()

    --??? Is this used anywhere.? I think it may be a remnant.
    Project.resize_window = nil
end

-- This is called when close button or OK button is clicked.
function GUI.elms.GB_wnd_proj:onclose(ok)
    if ok then
     
        --GUI.Msg("---- CLOSE : GB_wnd_proj:onclose ----")
        
        -- Only need to do this if using other than Textboxes (as of 20251229 none).
        Project.save_settings()
        
        -- Resize window if w or h changed.
        if (Project.proj_settings.w ~= GUI.elms.GB_wnd_proj.project_w) or
           (Project.proj_settings.h ~= GUI.elms.GB_wnd_proj.project_h) then
        
            Project.update_wnd_size()
        
        end

        GUI.elms.GB_frm_bg:redraw()
    
    end
    
end


return Project