-- NoIndex: true

-- wnd_Help.lua
-- Modified 20260330

GUI.New("GB_wnd_help", "dh_Window", {
    z = 493,
    x = 16, 
    y = 16, 
    w = DHTK.APP_WIDTH - 32,  --480,  
    h = WORKSPACE_HEIGHT,  --480,
    center = false, 
    caption = "Project Help",
    z_set = {492, 493},
})

GUI.New("GB_wnd_help_lbx", "dh_Listbox", {
    z = 492,
    x = 16, 
    y = 16, 
    w = DHTK.APP_WIDTH - 64,  --480,  
    h = WORKSPACE_HEIGHT - 64,  --480,
    caption = "",
    --font_caption = "sans22",
    font_text = "mono16",
    scrollbar_width = 12,
    col_bg = "panel_bg",
    col_text = "panel_txt",
})

GUI.elms_hide[493] = true
GUI.elms_hide[492] = true

local usage_text = {
"  ",
"Usage:",
" ",
"> Right-click in the workspace (or on a dh_Panel) to ",
"    open a popup list of element types.",
"    Select an element to add it at the ",
"    current mouse coordinates.",
" ",
"> Click (or middle mouse click) on an element to select it",
"    for editing. Once an element is selected additional ",
"    mouse events use native functionality (varies with element).",
" ",
"> Shift-drag (or middle mouse drag) an element to move it.",
" ",
"> Alt-click (or right-click) an element to delete it.",
" ",
"> Right-click an empty area with an element selected to duplicate it.",
" ",
"> Shift-click an empty area to deselect any selected element.",
" ",
"> Top-left of sidebar has a label showing type of selected element. ",
"    Click it to deselect.",   
"  ",
}  -- end usage_text

local defaults_text = {
"  ",
"  ------------------------------------------------------",   
"  dh_Toolkit class default GUI colors (and alternates) ",
"  ------------------------------------------------------",
"  button:        btn_face,  btn_outline, btn_txt",
"  ", 
"  knob:          btn_face,  btn_outline", 
"  ", 
"  label:         wnd_bg,    txt",
"                 panel_bg,  panel_txt",         
"  ",  
"  text elms:     elm_frame, elm_bg, elm_text, sel_txt", 
"  ",
"  menubox face:  btn_face (button with arrow)",
"  ",
"  options:       panel_bg,  panel_border, panel_text",
"                 wnd_bg,    elm_frame,    txt", 
"  ",
"  panel:         panel_bg,  panel_border, panel_text",
"                 wnd_bg,    elm_frame,    txt", 
"  ",
"  slider:        panel_bg,  panel_border, panel_text",          
"                 wnd_bg,    elm_frame,    txt",                    
"  ", 
"  slider track:  track_fill", 
"                 elm_fill",
"  ", 
"  slider thumb:  btn_face,  btn_outline",
"  ",
"  menubar:       btn_face,  btn_txt",
"  ", 
"  tabs:          tab_active, tab_inactive, txt",
"                 btn_face,                 btn_txt",
"                 panel_bg,                 panel_txt",
"  ", 
"  ------------------------------------------------------",
"  GUI fonts ",
"  ------------------------------------------------------",
"  sans14, sans16, sans18, sans20,", 
"  sans22, sans24, sans28, sans32,",
"  mono14, mono16, mono18, mono20,",
"  mono22, mono24, mono28, mono32 ",
"  ",

}  -- end defaults_text

GUI.elms.GB_wnd_proj.noadjust = {
    GB_wnd_proj_OK = true,
}

function GUI.elms.GB_wnd_help:onopen(params)

    self:adjustchildelms(true)

    GUI.Msg("help text param : " .. params[1])
    --GUI.Msg(" type help text param : " .. type(text))    

    local list
    
    if params[1] == "usage_text" then
        list = usage_text
    else
        list = defaults_text
    end
    
    GUI.elms.GB_wnd_help_lbx.list = list
    
    GUI.elms.GB_wnd_help_lbx:redraw()

end

function GUI.elms.GB_wnd_help:onclose(ok)
    if ok then
     
        --GUI.Msg("---- CLOSE : GB_wnd_help:onclose ----")


        GUI.elms.GB_frm_bg:redraw()
    
    end
    
end

