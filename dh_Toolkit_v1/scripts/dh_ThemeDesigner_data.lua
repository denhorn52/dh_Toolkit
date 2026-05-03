-- dh_ThemeDesigner_data.lua

-- Date: 20260330

--zztop
-----------------------------------
dh_ThemeDesigner_data = {}
-----------------------------------

----------------------------------
------    COLOR NAMES    -------
----------------------------------
-- COLOR_DISPLAY_NAMES and COLOR_USES need to correspond to
-- dh_Toolkit_themes.COLOR_NAMES

-----------------------------------
------    DISPLAY NAMES   -------
-----------------------------------
--zzdn
-- Display names for GUI color names. 
-- Use to populate Menubox.

dh_ThemeDesigner_data.COLOR_DISPLAY_NAMES = {
    -- Lokasenna defined
    "Window BG ",
    "Text ",
    "Element BG ",
    "Element fill ",
    "Element frame ",
    "Element outline ",
    "Tab BG ",
    
    -- dh_Toolkit defined
    "Button face",
    "Button outline",
    "Button text", 
    "Aux. background",
    "Aux. text",
    "Slider Thumb",    
    "Track fill", 

    "Panel background",
    "Panel border",
    "Panel text",     
    "Element text",
    "Selected text",    
    "Tab active",
    "Tab inactive",
    
    "Element active",
    --"Element thumb",
    --"Element track",            
}

---------------------------------
------    COLOR USES    -------
---------------------------------
--zzcu
-- Color uses show where they are used as defaults.
-- Use to populate listbox.
-- * Lokasenna can't override.
-- (L) Lokasenna only default.
-- (D) dh_Toolkit only default.
-- % Optional.

dh_ThemeDesigner_data.COLOR_USES = {
    wnd_bg = {
        "Window BG",
        "Captions BG",
        "Frame BG (L)",
        "Knob BG",
        "Label BG",
        "Options BG",
        "Slider BG",        
        "Tab - active (L)",
    },
    txt = {
        "Button text (L)",
        "Caption text",
        "Knob values",
        "Knob pointer (L)",
        "Label text",
        "Listbox text (L)",
        "Menubar text (L)",
        "Menubox text (L)",
        "Options text",
        "Options buttons (D)",
        "Slider values",
        "Tabs text",
        "Textbox text (L)",
        "TextEditor text (L)",
    },
    elm_bg = {
        "Listbox box *",
        "Menubox box *",
        "Textbox box *",
        "TextEditor box *",
        "Slider track *",
        "Tabs BG",
    },
    elm_fill = {
        "Knob head fill (L)",
        "Knob hilite value (L)",
        "Listbox Sel. text hilite (L*)",
        "Menubar over hilite",
        "Menubox outline focused (L*)",
        "Menubox Sel. text hilite (L*)",
        "Option bubble fill (L)",
        "Scrollbar thumb (L)",
        "Slider track fill (L)",
        "Textbox outline focused (L*)",
        "Textbox Sel. text hilite (L*)",
        "TextEditor outline focused (L*)",
        "TextEditor Sel. text hilite (L*)",
        --"Text Elms outline focused (L*)",
        --"Text Elms Sel. text hilite (L*)",
    },
    elm_frame = {
        "Button face (L)",
        "Frame border (L)",
        "Frame fill if true (L*)",
        "Knob body (L)",
        "Listbox frame *",
        "Menubar BG (L)",
        "Menubox frame *",
        "Options frame (L)",
        "Option bubble outline (L*)",
        "Scrollbar thumb (D)",
        "Slider thumb face (L)",
        "Textbox frame *",
        "TextEditor frame *",
    },
    elm_outline = {
        "Button outline (L)",
        "Knob outline (L)",
        "Scrollbar outline (L) ",
        "Slider outline (L)",
    },
    tab_bg = {
        "Inactive Tab BG (L)",
        "Scrollbar BG (L)*",
    },
    btn_face = {
        "dh_Button face",
        "dh_Knob face",
        "dh_Menubar BG",
        "dh_Menubox face",
        "dh_Slider thumb",                        
    },
    btn_outline = {
        "dh_Button outline",
        "dh_Knob outline",
        "dh_Slider Thumb ol.",
    },    
    btn_txt = {
        "dh_Button text color",
        "dh_Menubar text color",
    },
    aux_bg = {
        "dh_Button face",
        "dh_Knob face",
        "dh_Menubar BG",
        "dh_Menubox face",
        "dh_Slider thumb",                        
    },
    aux_txt = {
        "dh_Button outline",
        "dh_Knob outline",
        "dh_Slider Thumb ol.",
    },    
    thumb_body = {
        "dh_Slider thumb",
    },
    track_fill = {
        "dh_Slider track fill",
        --"    alternate",
    },   

    panel_bg = {
        "dh_Panel background",
        "    alternate",
    },
    panel_border = {
        "dh_Panel border",
        --"    alternate",
    },
    panel_txt = {
        "dh_Panel text",
        "    alternate",
    },
    elm_txt = {
        "dh_ Text Elements text",
        "-- Pair with elm_bg --",
    },        
    sel_txt = {
        "Selected Text Hilite",
        "  ",
        "Used in:",
        "  dh_Listbox",
        "  dh_Textbox",
        "  dh_TextEditor",
    },
    tab_active = {
        "dh_Tabs active tab",
    },
    tab_inactive = {
        "dh_Tabs inactive Tab",
    },
    elm_active = {
        "dh_ Elements",
        "    focused outline",
    }, 
    --[[
    elm_thumb = {
        "dh_ scrollbar",
        --"    thumb alternate",
    },    
    elm_track = {
        "dh_ scrollbar",
        --"    track alternate",
    },
    --]]
                
}


--zzdf
-- Shows default uses of colors in "spreadsheet" format.
-- Display in popup Listbox.

dh_ThemeDesigner_data.data_color_defaults = {

--"[color]; Can't be overridden",
--"%; Optional by overriding",
--" ",
"Class /       Lokasenna       dh_Toolkit     ",
" attribute     default         default       alternate",
" ",
"Button:",
"  bg:         elm_frame       btn_face       aux_bg", 
"  outline:    [elm_outline]   btn_outline    elm_frame",     
"  text:       txt             btn_txt        aux_txt",
" ", 
"Text Elements: ( Listbox, Menubox, Textbox, TextEditor )",
"  bg:         [elm_bg]        elm_bg         ",
"  frame:      [elm_frame]     elm_frame      ",      
"  focused:    [elm_fill]      elm_active     ",
"  text:       txt             elm_txt        ",
"  selected:   [elm_fill]      sel_txt        elm_fill",  
"  scrollbar:",      
"    track:    [tab_bg]        btn_face       elm_fill",       
"    outline:  [elm_outline]   [auto calculated]",
"    thumb:    elm_fill        [auto calculated]",
" ",    
"Frame/Panel:",
"  bg:         wnd_bg          wnd_bg         panel_bg",
"  border:     elm_frame       panel_border   elm_frame",  
"  text:       txt             txt            panel_txt",
" ", 
"Knob:", 
"  bg:         wnd_bg          wnd_bg         ",
"  text:       txt             txt            ",
"  body:",       
"    face:     elm_frame       btn_face       aux_bg",
"    outline:  [elm_outline]   btn_outline    elm_frame",   
"  head (indicator):",       
"    face:     elm_fill        txt            ", 
"    outline:  [elm_outline]   sometimes auto calculated",   
" ", 
"Label (and captions)",               
"  bg:         wnd_bg          wnd_bg         ",
"  text:       txt             txt            ",
" ",
"Menubar:", 
"  bg:         elm_frame       btn_face       ",
"  over:       elm_fill        elm_fill       ",
"  text:       txt             btn_txt        ",
" ",   
"Options:",
"  bg:         wnd_bg          wnd_bg         panel_bg",
"  frame:      [elm_frame]     panel_border   elm_frame",  
"  text:       txt             txt            panel_txt",
"  bubble:",     
"    outline:  [elm_frame]     txt            panel_txt",
"    fill:     elm_fill        txt            panel_txt",
" ",                        
"Slider:",
"  bg:         wnd_bg          wnd_bg         panel_bg",
"  border:     n/a             panel_border   elm_frame",
"  values:     txt             txt            panel_txt",
"  track:",      
"    bg:       [elm_bg]        elm_bg         ",
"    outline:  [elm_outline]   elm_frame      ",   
"    fill:     elm_fill        track_fill     elm_fill",
"  thumb:",      
"    outline:  [elm_outline]   btn_outline    elm_frame",   
"    body:     elm_frame       thumb_body     btn_face",
" ",  
"Tabs:",
"  bg:         elm_bg          elm_bg         ",
"  text:       txt             txt            ",
"  active:     wnd_bg          tab_active     ", 
"  inactive:   tab_bg          tab_inactive   ",
" ",                        
"Caption: as used on various elements",
"  bg:         wnd_bg          wnd_bg         ",
"  text:       txt             txt            ",

}    

-----------------------------------
----    PROPERTY ASSIGNMENTS    -----
-----------------------------------

-- Used to store Tab2 default and overridden color assignments.
-- Initialized with default.
-- Update with Menubar selections via menubar_function.
-- assign_name = {default, current}
-- Should I combine color_assignments and display_assignments into one list: property_assignments?

dh_ThemeDesigner_data.tab2_property_assignments = {
    menubar_bg = {"elm_frame", "elm_frame"}, 
    menubar_text = {"txt", "txt"},
    menubar_font = {2, 2},
    frame_fill = {false, false},                 
    frame_color = {"elm_frame", "elm_frame"},
    frame_bg = {"wnd_bg", "wnd_bg"},
    frame_text = {"txt", "txt"}, 
    button_face = {"elm_frame", "elm_frame"},   
    button_text = {"txt", "txt"},
    button_font = {3, 3},                 
    element_text = {"txt", "txt"},             
    knob_body = {"elm_frame", "elm_frame"},       
    knob_head = {"elm_fill", "elm_fill"},        
    radio_font = {2, 2},
    option_bubble_fill = {"txt", "txt"},                       
    --scrollbar_track = {"tab_bg", "tab_bg"}, 
    scrollbar_thumb = {"elm_fill", "elm_fill"},
 
    slider_track_fill = {"elm_fill", "elm_fill"},    
    slider_thumb = {"elm_frame", "elm_frame"},   

    tabs_bg = {"elm_bg", "elm_bg"},
    tabs_text = {"txt", "txt"},               
    tab_active = {"wnd_bg", "wnd_bg"},         
    tab_inactive = {"tab_bg", "tab_bg"},       
                       
}

dh_ThemeDesigner_data.tab2_display_assignments = {
    {"menubar_bg",        "Menubar background:      col_bg        -> "},
    {"menubar_text",      "Menubar text:            col_txt       -> "},
    {"menubar_font",      "Menubar font size:       font          -> "},    
    {"frame_fill",        "Frame fill:              fill          -> "},
    {"frame_color",       "Frame color:             color         -> "},
    {"frame_bg",          "Frame bg color:          bg            -> "},
    {"frame_text",        "Frame text:              col_txt       -> "},
    {"button_face",       "Button face:             col_fill      -> "},
    {"button_text",       "Button text:             col_txt       -> "},
    {"button_font",       "Button font size:        font          -> "},    
    {"element_text",      "Element text:            color     *   -> "},
    {"knob_body",         "Knob face:               col_body      -> "},
    {"knob_head",         "Knob pointer:            col_head  **  -> "},
    {"radio_font",        "Radio font size:         font_b        -> "},
    {"option_bubble_fill","Option bubble fill:      col_fill      -> "},    
    --{"scrollbar_track",   "Scrollbar track:         [tab_bg]      -> "},    
    {"scrollbar_thumb",   "Scrollbar thumb:         elm_fill  *** -> "},

    {"slider_track_fill", "Slider track fill:       col_fill      -> "},
    {"slider_thumb",      "Slider thumb:            col_hnd       -> "},
    {"tabs_bg",           "Tab background:          bg            -> "},
    {"tabs_text",         "Tab text:                col_txt       -> "},
    {"tab_active",        "Tab active:              col_tab_a     -> "},
    {"tab_inactive",      "Tab inactive:            col_tab_b     -> "},
    
}

-- Used to store Tab3 default and overridden property assigned values.
-- These are properties that are updated with menu item clicks
-- via updateTab3Elements(), and other applicable methods.
-- Initialized with default.
-- This table gets stored in reaper_extstate.ini
-- assign_name = {default, current}

--zz0523m
dh_ThemeDesigner_data.tab3_property_assignments = {
    menubar_bg = {"btn_face", "btn_face"}, 
    menubar_text = {"btn_txt", "btn_txt"},
    menubar_over = {"elm_fill", "elm_fill"},    
    menubar_font = {"sans22", "sans22"},
    
    panel_bg = {"wnd_bg", "wnd_bg"}, 
    panel_border = {"panel_border", "panel_border"},  
    panel_text = {"txt", "txt"},  
    panel_border_width = {2, 2},
    panel_radius = {0, 0},
         
    button_face = {"btn_face", "btn_face"}, 
    button_outline = {"btn_outline", "btn_outline"}, 
    button_text = {"btn_txt", "btn_txt"},
    button_font = {"sans22", "sans22"},     

    knob_style = {"pointer", "pointer"},     
    knob_body = {"btn_face", "btn_face"}, 
    knob_outline = {"btn_outline", "btn_outline"}, 
    --knob_indicator = {"btn_txt", "btn_txt"},
    
    element_bg = {"elm_bg", "elm_bg"},
    element_text = {"elm_txt", "elm_txt"},
    element_sel_text = {"sel_txt", "sel_txt"},
    element_sel_alpha = {0.5, 0.5},    

    scrollbar_track = {"btn_face", "btn_face"}, 
    --scrollbar_thumb = {"btn_txt", "btn_txt"},
    scrollbar_width = {8, 8},
    
    frame_thk = {1, 2},
    sel_alpha = {0.5, 0.5},  

    radio_font = {"sans22", "sans22"},
    --option_bubble_outline = {"txt", "txt"},
    --option_bubble_fill = {"txt", "txt"},

    slider_track_bg = {"elm_bg", "elm_bg"},    
    slider_thumb = {"thumb_body", "thumb_body"},
    slider_thumb_outline = {"btn_outline", "btn_outline"}, 
    slider_track_fill = {"track_fill", "track_fill"},    
    slider_thickness = {8, 8},       

    tabs_bg = {"elm_bg", "elm_bg"},
    tab_active = {"tab_active", "tab_active"},         
    tab_inactive = {"tab_inactive", "tab_inactive"},  
    tabs_text = {"btn_txt", "btn_txt"},  
                       
}

-- Must have a corresponding entry in tab3_property_assignments.

dh_ThemeDesigner_data.tab3_display_assignments = {
    {"menubar_bg",           "Menubar background:    col_bg            -> "},
    {"menubar_text",         "Menubar text:          col_text          -> "},
    {"menubar_over",         "Menubar over:          col_over          -> "},  
    {"menubar_font",         "Menubar font:          font              -> "},          
    
    {"panel_bg",             "Panel background:      col_bg            -> "},    
    {"panel_border",         "Panel border:          col_border        -> "},    
    {"panel_text",           "Panel text:            col_text          -> "},
    {"panel_border_width",   "Panel border width:    border_width      -> "},    
    {"panel_radius",         "Panel radius:          radius            -> "},    

    {"button_face",          "Button face:           col_bg            -> "},
    {"button_outline",       "Button outline:        col_outline       -> "},
    {"button_text",          "Button text:           col_text          -> "},
    {"button_font",          "Button font:           font              -> "},    

    {"knob_style",           "Knob style:            knob_style        -> "},    
    {"knob_body",            "Knob face:             col_body          -> "},
    {"knob_outline",         "Knob outline:          col_outline       -> "},
    --{"knob_indicator",       "Knob indicator:        col_indicator **  -> "},

    {"element_bg",           "Element background:    col_bg            -> "},
    {"element_text",         "Element text:          col_text  *       -> "},
    {"element_sel_text",     "Selected Text Hilite:  col_sel_text      -> "},
    
    {"sel_alpha",            "Text elms sel_alpha:   sel_alpha         -> "},    
            
    {"scrollbar_track",      "Scrollbar track:       col_track         -> "},    
    --{"scrollbar_thumb",      "Scrollbar thumb:       col_thumb ***     -> "},
    {"scrollbar_width",      "Scrollbar width:       scrollbar_width   -> "},  

    {"radio_font",           "Radio font:            font_text         -> "},
    --{"option_bubble_outline","Option bubble outline: col_opt_outline   -> "},    
    --{"option_bubble_fill",   "Option bubble fill:    col_opt_fill      -> "},
        
    {"slider_track_bg",      "Slider background:     col_track         -> "},    
    {"slider_thumb",         "Slider thumb:          col_thumb         -> "},
    {"slider_thumb_outline", "Slider thumb outline:  col_thumb_outline -> "},
    {"slider_track_fill",    "Slider track fill:     col_fill          -> "},
    {"slider_thickness",     "Slider thickness:      track_thk         -> "},
        
    {"tabs_bg",              "Tab background:        col_bg            -> "},
    {"tabs_text",            "Tab text:              col_text          -> "},
    {"tab_active",           "Tab active:            col_tab_active    -> "},
    {"tab_inactive",         "Tab inactive:          col_tab_inactive  -> "},
    
}

-----------------------------------
return dh_ThemeDesigner_data
-----------------------------------
--zzend