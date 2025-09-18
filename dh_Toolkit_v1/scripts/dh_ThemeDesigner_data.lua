-- dh_ThemeDesigner_data.lua

-- Date: 2025-09-08

--zztop
-----------------------------------
dh_ThemeDesigner_data = {}
-----------------------------------

----------------------------------
------    COLOR NAMES    -------
----------------------------------
-- Display names and Color uses need to correspond to
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
    "Element active",
    "Element text",
    "Element thumb",
    "Element track",
    "Panel background",
    "Panel border",
    "Panel text",    
    "Selected text",
    "Tab active",
    "Tab inactive",
    "Track fill",    
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
        "Frame/Panel BG",
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
        "Frame/Panel border",
        "Frame fill if true (L*)",
        "Knob body (L)",
        "Listbox frame *",
        "Menubar BG (L)",
        "Menubox frame *",
        "Options frame *",
        "Option bubble outline (L*)",
        "Scrollbar thumb (D)",
        "Slider thumb face (L)",
        "Textbox frame *",
        "TextEditor frame *",
    },
    elm_outline = {
        "Button outline (L)",
        "Knob outline (L)",
        "Scrollbar outline ",
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
        "dh_Slider outline",
    },    
    btn_txt = {
        "dh_Button text color",
        "dh_Menubar text color",
    },
    elm_active = {
        "dh_ Text Elements",
        "    focused outline",
    },    
    elm_txt = {
        "dh_ Text Elements text",
        "-- Pair with elm_bg --",
    },
    elm_thumb = {
        "dh_ scrollbar",
        "    thumb alternate",
    },    
    elm_track = {
        "dh_ scrollbar",
        "    track alternate",
    },
    panel_bg = {
        "dh_Panel background",
        "    alternate",
    },
    panel_border = {
        "dh_Panel border",
        "    alternate",
    },
    panel_txt = {
        "dh_Panel text",
        "    alternate",
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
    track_fill = {
        "dh_Slider track fill",
        "    alternate",
    },    
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
"  outline:    [elm_outline]   btn_outline",     
"  bg:         elm_frame       btn_face",
"  text:       txt             btn_txt",
" ", 
"Elements: ( Listbox, Menubox, Textbox, TextEditor )",
"  bg:         [elm_bg]        elm_bg",
"  frame:      [elm_frame]     elm_frame",      
"  focused:    [elm_fill]      elm_active",
"  text:       txt             elm_txt",
"  selected:   [elm_fill]      sel_txt        elm_fill",  
"  scrollbar:",      
"    track:    [tab_bg]        elm_track      elm_fill",       
"    outline:  [elm_outline]   btn_outline    elm_outline",   
"    thumb:    elm_fill        elm_thumb      elm_frame",
" ",    
"Frame/Panel:",
"  border:     elm_frame       elm_frame      panel_border",  
"  bg:         wnd_bg          wnd_bg         panel_bg",
"  text:       txt             txt            panel_txt",
" ", 
"Knob:", 
"  bg:         wnd_bg          wnd_bg",
"  text:       txt             txt",
"  body:",       
"    face:     elm_frame       btn_face",
"    outline:  [elm_outline]   btn_outline",   
"  head:",       
"    face:     elm_fill        txt", 
"    outline:  [elm_outline]   btn_outline",   
" ", 
"Label (and captions)",               
"  bg:         wnd_bg          wnd_bg",
"  text:       txt             txt",
" ",
"Menubar:", 
"  bg:         elm_frame       btn_face",
"  over:       elm_fill        elm_fill",
"  text:       txt             btn_txt",
" ",   
"Options:",
"  frame:      [elm_frame]     elm_frame      panel_border",  
"  bg:         wnd_bg          wnd_bg",
"  text:       txt             txt            panel_txt",
"  field:      n/a             wnd_bg         panel_bg",      
"  bubble:",     
"    outline:  [elm_frame]    txt             ",
"    fill:     elm_fill        txt            ",
" ",                        
"Slider:",
"  bg:         wnd_bg          wnd_bg",
"  text:       txt             txt",
"  track:",      
"    bg:       [elm_bg]        elm_bg",
"    outline:  [elm_outline]   btn_outline",   
"    fill:     elm_fill        track_fill       elm_fill",
"  thumb:",      
"    outline:  [elm_outline]   btn_outline",   
"    face:     elm_frame       btn_face",
" ",  
"Tabs:",
"  bg:         elm_bg          elm_bg",
"  text:       txt             txt",
"  active:     wnd_bg          tab_active", 
"  inactive:   tab_bg          tab_inactive",
" ",                        
"Caption: as used on various elements",
"  bg:         wnd_bg          wnd_bg",
"  text:       txt             txt",

}    

-----------------------------------
----    COLOR ASSIGNMENTS    -----
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
    -- lbx_PropertyAssignments
    show_pnl_bg = {"panel_bg", "panel_bg"},    
    show_pnl_sel_txt = {"sel_txt", "sel_txt"},    
    sel_alpha = {0.5, 0.5},  
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
    {"show_pnl_bg",       "'Show' panel sel_alpha:  col_bg        -> "},
    {"show_pnl_sel_txt",  "'Show' panel sel_alpha:  col_sel_text  -> "},    
    {"sel_alpha",         "'Show' panel sel_alpha:  sel_alpha     -> "},        
    {"slider_track_fill", "Slider track fill:       col_fill      -> "},
    {"slider_thumb",      "Slider thumb:            col_hnd       -> "},
    {"tabs_bg",           "Tab background:          bg            -> "},
    {"tabs_text",         "Tab text:                col_txt       -> "},
    {"tab_active",        "Tab active:              col_tab_a     -> "},
    {"tab_inactive",      "Tab inactive:            col_tab_b     -> "},
    
}

-- Used to store Tab3 default and overridden color assignments.
-- Initialized with default.
-- Update with Menubar selections via menubar_function.
-- assign_name = {default, current}

--zz0523m
dh_ThemeDesigner_data.tab3_property_assignments = {
    menubar_bg = {"btn_face", "btn_face"}, 
    menubar_text = {"btn_txt", "btn_txt"},
    menubar_over = {"sel_txt", "sel_txt"},    
    menubar_font = {"sans22", "sans22"},
    panel_border_width = {2, 2},  
    panel_border = {"elm_frame", "elm_frame"},  
    panel_bg = {"wnd_bg", "wnd_bg"}, 
    panel_radius = {0, 0},
    panel_text = {"txt", "txt"},       
    button_face = {"btn_face", "btn_face"}, 
    button_outline = {"btn_outline", "btn_outline"}, 
    button_text = {"btn_txt", "btn_txt"},
    button_font = {"sans22", "sans22"},     

    element_text = {"elm_txt", "elm_txt"}, 
     
    knob_body = {"btn_face", "btn_face"},       
    knob_head = {"txt", "txt"},
       
    radio_font = {"sans20", "sans20"},
    option_bubble_outline = {"txt", "txt"},
    option_bubble_fill = {"txt", "txt"},
                           
    scrollbar_track = {"elm_fill", "elm_fill"}, 
    scrollbar_thumb = {"elm_frame", "elm_frame"},
    scrollbar_width = {8, 8},
    
    --sel_alpha = {0.5, 0.5},  -- tab 3 text elements
    
    slider_track_bg = {"elm_bg", "elm_bg"},    
    slider_track_fill = {"elm_fill", "elm_fill"},    
    slider_thumb = {"btn_face", "btn_face"},
    slider_thickness = {8, 8},       

    tabs_bg = {"elm_bg", "elm_bg"},
    tabs_text = {"btn_txt", "btn_txt"},               
    tab_active = {"tab_active", "tab_active"},         
    tab_inactive = {"tab_inactive", "tab_inactive"},       
                       
}

dh_ThemeDesigner_data.tab3_display_assignments = {
    {"menubar_bg",           "Menubar background:    col_bg           -> "},
    {"menubar_text",         "Menubar text:          col_text         -> "},
    {"menubar_font",         "Menubar font:          font             -> "},
    {"menubar_over",         "Menubar over:          col_over         -> "},        
    {"panel_border_width",   "Panel border width:    border_width     -> "},
    {"panel_border",         "Panel border:          col_border       -> "},
    {"panel_bg",             "Panel background:      col_bg           -> "},
    {"panel_radius",         "Panel radius:          radius           -> "},
    {"panel_text",           "Panel text:            col_text         -> "},
    {"button_face",          "Button face:           col_bg           -> "},
    {"button_outline",       "Button outline:        col_outline      -> "},
    {"button_text",          "Button text:           col_text         -> "},
    {"button_font",          "Button font:           font             -> "},    

    {"element_text",         "Element text:          col_text  *      -> "},
    
    {"knob_body",            "Knob face:             col_body         -> "},
    {"knob_head",            "Knob pointer:          col_head  **     -> "},
    
    {"radio_font",           "Radio font:            font_text        -> "},
    {"option_bubble_outline","Option bubble outline: col_opt_outline  -> "},    
    {"option_bubble_fill",   "Option bubble fill:    col_opt_fill     -> "},
        
    {"scrollbar_track",      "Scrollbar track:       col_track        -> "},    
    {"scrollbar_thumb",      "Scrollbar thumb:       col_thumb ***    -> "},
    {"scrollbar_width",      "Scrollbar width:       scrollbar_width  -> "},    
    
    --{"sel_alpha",            "Text elms sel_alpha:   sel_alpha        -> "},    
    
    {"slider_track_bg",      "Slider background:     col_track        -> "},    
    {"slider_track_fill",    "Slider track fill:     col_fill         -> "},
    {"slider_thumb",         "Slider thumb:          col_thumb        -> "},
    {"slider_thickness",     "Slider thickness:      thk              -> "},
        
    {"tabs_bg",              "Tab background:        col_bg           -> "},
    {"tabs_text",            "Tab text:              col_text         -> "},
    {"tab_active",           "Tab active:            col_tab_active   -> "},
    {"tab_inactive",         "Tab inactive:          col_tab_inactive -> "},
    
}

-----------------------------------
return dh_ThemeDesigner_data
-----------------------------------
--zzend