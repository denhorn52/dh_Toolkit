-- NoIndex: true

-- data_Elements.lua

--[[
    Modified 20260506

    20251001 - added dh_ classes.
    20251001 - changed some property display orders.
    20251109 - Added some extra properties.
    20251219 - Added some extra properties.
    20260115 - Renamed dh_Slider to dh_Slider_multi.
               Added new single thumb dh_Slider.
               Added dh_Slider_H and dh_Slider_V
    20260420 - Revised some properties.
    20260506: All dh_Graph.             
--]]

--[===[

Adds creation and property data to the GUI element classes.
(func_Elements adds GB-specific methods for selecting, deleting, duplicating, dragging, etc.)
GB properties are used to create property display elms in the Sidebar.

project elements are the elements that will be in user script.

property elements get displayed in the Sidebar showing
  project elm property values.
  
classes is a dictionary of {element class name, data}

data is a dictionary of {defaults, creation, props}
  This gets added to element class as elm.GB.dat

defaults - list of values used for creating project elements.
  This corresponds to class creation parameters.
  Elements are created on z = 5, x = mouse.x, y = mouse_y
  Element classes set defaults for other properties,
    but not z, x, y, w or h.
  Therefore defaults supplies these for elm creation.
  defaults are unpacked and added to element creation string.
    GUI.New(name, class, 11, x, y, table.unpack(GUI[class].GB.defaults) )
    
creation - list of additional property names, which do
  have defaults defined in class file, and are to be included 
  as editable properties displayed in sidebar.
  Starts with w, h, and any other defaults which are
    necessary for elm creation.
  After default params include a "" to delineate start of additional 
    properties to include in elm.prop_defaults[]
    
properties - list of properties that gets displayed in Sidebar.
    {prop = "", caption = "", class = "", [options]},

    prop        Project element's property name
    caption     Sidebar property elm caption
    class       Property type
    
    recreate = true
                Will delete and GUI.New(...) the target element after applying a value. 
                Necessary for some classes (Slider) that do a lot of internal
                  work with the created values and can't be easily updated.
    needs_init = true
                Selected project element needs to be re-initialized after applying value.
                Most properties default to true. Set to false those not requiring init.
    no_scale = true
                property doesn't change when scaling app.            
                
props is a convenience list of GB property objects.
    
--]===]
  
--zzsl
------------------------------------------------
local classes = {}

-- Frequently-used properties so I only have to type them out once
local props = {

    name          = {prop = "name",          caption = "Name",            class = "Name"},
    z             = {prop = "z",             caption = "Z",               class = "Coord_Z"},
    x             = {prop = "x",             caption = "X",               class = "Integer"},
    -- Adjustments for menubar height are now done in store_elm_defaults.
    --y             = {prop = "y",           caption = "Y",               class = "Coord_Y"},
    y             = {prop = "y",             caption = "Y",               class = "Integer"},
    w             = {prop = "w",             caption = "W",               class = "Integer",     needs_init = true},
    h             = {prop = "h",             caption = "H",               class = "Integer",     needs_init = true},
    caption       = {prop = "caption",       caption = "Caption",         class = "String",      needs_init = false},
    font          = {prop = "font",          caption = "Font",            class = "Font",        needs_init = true},
    font_a        = {prop = "font_a",        caption = "Cap. Font",       class = "Font",        needs_init = false},
    font_b        = {prop = "font_b",        caption = "Text Font",       class = "Font",        needs_init = true},
    col_txt       = {prop = "col_txt",       caption = "Text Color",      class = "Color",       needs_init = true},
    col_fill      = {prop = "col_fill",      caption = "Fill Color",      class = "Color",       needs_init = false},
    pad           = {prop = "pad",           caption = "Padding",         class = "Integer",     needs_init = true},
    shadow        = {prop = "shadow",        caption = "Shadow",          class = "Boolean",     needs_init = true},
--zzprop
    -- dhtk properties
    
    text            = {prop = "text",            caption = "Text",            class = "String",  needs_init = false},
    font_text       = {prop = "font_text",       caption = "Text Font",       class = "Font",    needs_init = false},
    font_values     = {prop = "font_values",     caption = "Values Font",     class = "Font",    needs_init = false},
    font_caption    = {prop = "font_caption",    caption = "Cap. Font",       class = "Font",    needs_init = false},
    font_display    = {prop = "font_display",    caption = "Display Font",    class = "Font",    needs_init = false},
    cap_pad_x       = {prop = "cap_pad_x",       caption = "Cap. Offset X",   class = "Integer", needs_init = false},
    cap_pad_y       = {prop = "cap_pad_y",       caption = "Cap. Offset Y",   class = "Integer", needs_init = false},
    cap_pos         = {prop = "cap_pos",         caption = "Cap. Position",   class = "Cap_Pos", needs_init = false},
    cap_centered    = {prop = "cap_centered",    caption = "Cap. Centered",   class = "Boolean", needs_init = false},

    col_cap_text    = {prop = "col_cap_text",    caption = "Caption Color",   class = "Color",   needs_init = false},
    col_text        = {prop = "col_text",        caption = "Text Color",      class = "Color",   needs_init = false},
    col_values      = {prop = "col_values",      caption = "Values Color",    class = "Color",   needs_init = false},
    col_bg          = {prop = "col_bg",          caption = "Background Col.", class = "Color",   needs_init = true},
    col_outline     = {prop = "col_outline",     caption = "Outline Color",   class = "Color",   needs_init = true},
    col_border      = {prop = "col_border",      caption = "Border Color",    class = "Color",   needs_init = true},
    col_frame       = {prop = "col_frame",       caption = "Frame Color",     class = "Color",   needs_init = true},
    col_face        = {prop = "col_face",        caption = "Face Color",      class = "Color",   needs_init = false},
    col_active      = {prop = "col_active",      caption = "Active Color",    class = "Color",   needs_init = false},
    col_sel_text    = {prop = "col_sel_text",    caption = "Sel. Text Color", class = "Color",   needs_init = false},
    col_backdrop    = {prop = "col_backdrop",    caption = "Backdrop Color",  class = "List",    needs_init = true},
    use_sel_alpha   = {prop = "use_sel_alpha",   caption = "Use Sel. Alpha",  class = "Boolean", needs_init = false}, 

    sel_alpha       = {prop = "sel_alpha",       caption = "Sel. Text Alpha", class = "Number",  needs_init = false,  noscale = true},
    line_height       = {prop = "line_height",   caption = "Line Height",     class = "Line_Height", needs_init = false},    
    shadow_caption    = {prop = "shadow_caption",      caption = "Cap. Shadow",       class = "Boolean", needs_init = false},
    frame_use_outline = {prop = "frame_use_outline",   caption = "Frame Use Outline", class = "Boolean", needs_init = true},
    frame_thk         = {prop = "frame_thk",           caption = "Frame Thickness",   class = "List",    needs_init = true},
    allow_sel_outline = {prop = "allow_sel_outline", caption = "Allow Sel Outline",   class = "Boolean", needs_init = false},
}

------------------------------------------------
-- GUI.Button:new(name, z, x, y, w, h, caption, func, ...)

classes.Button = {
    defaults = {48, 24, "Button"},
    creation = {"w", "h", "caption", "", "font", "col_txt", "col_fill"},        
    properties = {
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        props.w,
        props.h,
        "",
        props.caption,
        "",
        props.font,
        props.col_txt,
        {prop = "col_fill",      caption = "Fill Color",      class = "Color",       needs_init = true},            
    }
}

------------------------
-- GUI.dh_Button:new(name, z, x, y, w, h, text, func, ...)

classes.dh_Button = {
    defaults = {64, 28, "Button"},
    creation = {"w", "h", "text", "", "font", "shadow", "shadow_text",
                "col_bg", "col_text", "col_outline", "col_active", "allow_sel_outline",
    },        
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        props.w,
        props.h,
        {prop = "text",            caption = "Text",           class = "String",   needs_init = true},
        props.font,
        -- shadow always drawn
        --{prop = "shadow",         caption = "Button Shadow",   class = "Boolean",  needs_init = true},        
        {prop = "shadow_text",    caption = "Text Shadow",     class = "Boolean",  needs_init = true},
        "2",
        props.col_bg, 
        props.col_outline,
        {prop = "col_text",        caption = "Text Color",      class = "Color",   needs_init = true},
        props.col_active,        
        props.allow_sel_outline,  
    }
}

------------------------
-- GUI.Checklist:new(name, z, x, y, w, h, caption, opts, dir, pad)

classes.Checklist = {
    defaults = {96, 192, "Checklist", "Option 1,Option 2,Option 3,Option 4"},
    creation = {"w", "h", "caption", "optarray", "", "dir", "pad", 
                "font_a", "font_b", 
                "frame", "shadow", "opt_size", "swap",
                "bg", "col_txt", "col_fill", 
    },
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        props.w,
        props.h,
        "",
        {prop = "optarray",     caption = "Options",        class = "Table",      needs_init = false}, 
        {prop = "dir",          caption = "Direction",      class = "Direction",  needs_init = true},  
        {prop = "opt_size",     caption = "Option Size",    class = "Integer",    needs_init = false},
        props.pad,
        {prop = "swap",         caption = "Swap",           class = "Boolean",    needs_init = false}, 
        "2",
        props.caption,
        "",        
        props.font_a,
        props.font_b,
        props.col_txt,
        {prop = "col_fill",     caption = "Fill Color",     class = "Color",      needs_init = true},        
        {prop = "bg",           caption = "Text BG",        class = "Color",      needs_init = true}, 
        "",
        {prop = "frame",        caption = "Frame",          class = "Boolean",    needs_init = true},
        props.shadow,
    }
}

--zzopt  
------------------------
-- GUI.dh_Checklist:new(name, z, x, y, w, h, caption, opts, dir)

classes.dh_Checklist = {
    defaults = {128, 128, "dh_Checklist", "Option 1,Option 2,Option 3,Option 4"},
    creation = {"w", "h", "caption", "", "optarray", "dir",
                "font_caption", "cap_pos", "cap_pad_x", "cap_pad_y", "cap_centered", 
                "font_text", "pad_x", "pad_y", "border_width", "radius", 
                "col_cap_text", "col_bg", "col_border", "col_text", "col_active", 
                "col_backdrop",  
                "swap", "opt_size",
                "shadow", "shadow_caption", "shadow_text", "allow_sel_outline", 
    },
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        props.w,
        props.h,
        {prop = "swap",         caption = "Swap",           class = "Boolean",    needs_init = false},        
        {prop = "dir",          caption = "Direction",      class = "Direction",  needs_init = true},
        {prop = "opt_size",     caption = "Option Size",    class = "Integer",    needs_init = false}, 
        {prop = "border_width", caption = "Border Width",   class = "Integer",    needs_init = true},
        {prop = "radius",       caption = "Radius",         class = "Integer",    needs_init = true},
        {prop = "optarray",     caption = "Options",        class = "Editor",     needs_init = false,  subclass = "options"},                 
        "2",        
        props.caption,
        props.font_caption,
        props.cap_pos,        
        props.cap_pad_x,
        props.cap_pad_y,
        props.cap_centered,
        props.shadow_caption,
        "",
        props.font_text,
        {prop = "pad_x",        caption = "Option Pad X",   class = "Integer",    needs_init = false},
        {prop = "pad_y",        caption = "Option Pad Y",   class = "Integer",    needs_init = false},
        {prop = "shadow_text",  caption = "Text Shadow",    class = "Boolean",    needs_init = false},
        "",
        props.shadow,                
        "3",        
        props.col_bg,
        props.col_border,
        props.col_text,
        props.col_cap_text,
        props.allow_sel_outline, 
        props.col_active,        
        props.col_backdrop,        
    }
}

------------------------
-- GUI.Frame:new(name, z, x, y, w, h, shadow, fill, color, round)

classes.Frame = {
    defaults = {256, 128},
    creation = {"w", "h", "", "shadow", "fill", "color", "round", 
                "text", "txt_indent", "txt_pad", "pad", "bg", "font", "col_txt"},
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        props.w,
        props.h,
        {prop = "fill",         caption = "Fill",           class = "Boolean",   needs_init = true},
        {prop = "color",        caption = "Frame Color",    class = "Color",     needs_init = true},
        {prop = "bg",           caption = "BG Color",       class = "Color",     needs_init = true},
        {prop = "round",        caption = "Round",          class = "Integer",   needs_init = true},
        props.shadow,
        "2",
        {prop = "text",         caption = "Text",           class = "String",     needs_init = true},
        {prop = "txt_indent",   caption = "Para. Indent",   class = "Integer",    needs_init = true},
        {prop = "txt_pad",      caption = "Wrap Indent",    class = "Integer",    needs_init = true},
        props.pad,
        props.font,
        props.col_txt,
    }
}
--zzlh
------------------------
-- GUI.dh_Panel:new(name, z, x, y, w, h, bw, rad)

classes.dh_Panel = {
    defaults = {256, 128},
    creation = {"w", "h", "", "border_width", "radius", 
        "caption", "font_caption", "cap_pad_x", "cap_pad_y",
        "cap_centered", "shadow_caption", "shadow",
        "text", "font_text", "pad", 
        "line_height", "use_pixels", "line_height_pixels", 
        "col_bg", "col_border", "col_text", "col_cap_text", 
        "col_backdrop",
    },
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        props.w,
        props.h,
        "",
        {prop = "border_width", caption = "Border Width",   class = "Integer",    needs_init = true},
        {prop = "radius",       caption = "Radius",         class = "Integer",    needs_init = true},
        props.shadow,
        "2",
        props.caption,
        props.font_caption,
        props.cap_pad_x,
        props.cap_pad_y,
        props.cap_centered,
        props.shadow_caption,
        "",
        {prop = "text",               caption = "Text",              class = "Table",    needs_init = false},        
        props.font_text,
        props.pad,
        props.line_height,
        {prop = "use_pixels",         caption = "Ln Hgt Use Pixels", class = "Boolean",  needs_init = false}, 
        {prop = "line_height_pixels", caption = "Line Hgt Pixels",   class = "Integer",  needs_init = false}, 
        "3",
        props.col_bg,
        props.col_border,
        props.col_text,
        props.col_cap_text,
        props.col_backdrop,        
    }
}
--zzz
------------------------
-- GUI.dh_Graph:new(name, z, x, y, w, h[, points]) 

classes.dh_Graph = {
    defaults = {320, 120},
    creation = {"w", "h", "", 
        "caption", "font_caption", "cap_pad_x", "cap_pad_y",
        "cap_centered", "shadow_caption", "shadow",
        "grid_x_divs", "grid_y_divs", "y_scale",
        --"points", "x_labels", "y_labels", 
        "font_text", "pad", 
        "frame_use_outline", "frame_thk", "allow_sel_outline", 
        --"col_bg", "col_text",
        "col_frame", 
        "col_cap_text", "col_backdrop",
    },
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        props.w,
        props.h,        
        "",
        {prop = "grid_x_divs",  caption = "X divs",       class = "Integer",  needs_init = true},
        {prop = "grid_y_divs",  caption = "Y divs",       class = "Integer",  needs_init = true},        
        {prop = "y_scale",      caption = "Y scale",      class = "Number",   needs_init = true},        
        --{prop = "points",       caption = "Data points",  class = "Table",    needs_init = false},        
        --{prop = "x_labels",     caption = "X labels",     class = "Editor",   needs_init = true},
        --{prop = "y_labels",     caption = "Y labels",     class = "Editor",   needs_init = true},
        
        "2",                
        props.caption,
        props.font_caption,
        props.cap_pad_x,
        props.cap_pad_y,
        props.cap_centered,
        props.shadow_caption,
        props.shadow,
        "",
        props.font_text,
        props.pad,
--zzcolors
        "3",
        --props.col_bg,
        props.frame_use_outline,
        props.frame_thk,
        props.col_frame,
        --props.col_text,
        props.col_cap_text,
        props.allow_sel_outline,
        --props.col_active,
        props.col_backdrop,        
    }

}

------------------------
-- GUI.Knob:new(name, z, x, y, w, caption, min, max, default, inc, vals)

classes.Knob = {
    defaults = {40, "Knob", 0, 10, 5, 1, true},
    creation = {"w", "caption", "min", "max", "default", "inc", "vals", "", 
                "font_a", "font_b", "cap_pad_x", "cap_pad_y",
                "bg", "col_txt", "col_head", "col_body", 
    },
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        props.w,
        "",
        {prop = "min",          caption = "Min.",        class = "Number",   recreate = true,  noscale = true},
        {prop = "max",          caption = "Max.",        class = "Number",   recreate = true,  noscale = true},
        {prop = "default",      caption = "Default",     class = "Number",   recreate = true,  noscale = true},
        {prop = "inc",          caption = "Increment",   class = "Number",   recreate = true,  noscale = true},
        {prop = "vals",         caption = "Show Values", class = "Boolean"},
        "2",
        props.caption,
        "",
        props.font_a,
        props.cap_pad_x,
        props.cap_pad_y,
        "",
        props.font_b,
        props.col_txt,
        "",
        {prop = "col_head",     caption = "Head",           class = "Color",  needs_init = true},
        {prop = "col_body",     caption = "Body",           class = "Color",  needs_init = true},

    }
}
--zzknob 
------------------------
-- GUI.dh_Knob:new(name, z, x, y, w, caption, centered, min, max, default, inc, show_vals, ...)

classes.dh_Knob = {
    defaults = {40, "dh_Knob", true, 0, 10, 5, 1, false},
    creation = {"w", "caption", "centered", "min", "max", "default", "inc", "show_values", "", 
                "knob_style", "pad_values",
                "font_caption", "cap_pos", "font_values", --"output",
                "cap_pad", --"cap_pad_x", "cap_pad_y", 
                "shadow_caption", "shadow",
                "col_bg", "col_values", "col_outline", "col_cap_text", "col_body",  --"col_indicator", 
                "allow_sel_outline", "col_active",
                "show_tickmarks", "tickmark_steps", "tickmark_size", "show_min_max", "min_max_values",
                "hard_ticks", "hard_tick_size", "hard_tick_thk", 
                "display_style", "display_w", "display_h", 
                "display_pos", "display_pad_x", "display_pad_y",
                "display_align", "font_display", "col_display_bg", "col_display_text", 
                "frame_use_outline", "frame_thk", "col_frame", 
    },
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        props.w,
        {prop = "centered",       caption = "Centered",     class = "Boolean",  needs_init = false},
        {prop = "knob_style",     caption = "Knob Style",   class = "List"},
        {prop = "min",            caption = "Min.",         class = "Number",   recreate = true,   noscale = true},
        {prop = "max",            caption = "Max.",         class = "Number",   recreate = true,   noscale = true},
        {prop = "default",        caption = "Default",      class = "Number",   recreate = true,   noscale = true},
        {prop = "inc",            caption = "Increment",    class = "Number",   recreate = true,   noscale = true},
        props.shadow,
--zzcaption        
        "2",
        props.caption,        
        props.font_caption,
        props.cap_pos,        
        --props.cap_pad_x,
        --props.cap_pad_y,
        {prop = "cap_pad",        caption = "Caption Pad",  class = "Integer",  needs_init = false},        
        props.shadow_caption,
        "",
        {prop = "show_values",    caption = "Show Values",  class = "Boolean",  needs_init = false},
        {prop = "font_values",    caption = "Values Font",  class = "Font"},
        {prop = "pad_values",     caption = "Values Pad",   class = "Integer",  needs_init = false},
        "",
        --{prop = "output",         caption = "Output",     class = "Table"},
                                
--zzcolors
        "3",
        --props.col_bg,
        {prop = "col_bg",         caption = "Background Col.",   class = "List"},            
        props.col_outline,
        {prop = "col_body",       caption = "Body Color",        class = "Color"},
        --{prop = "col_indicator",  caption = "Indicator Color", class = "Color"},
        props.col_values,
        props.col_cap_text,
        props.allow_sel_outline,
        props.col_active,
        
--zztickmarks        
        "4",
        -- needs_init if using dh_Knob with ticks in init.
        {prop = "show_tickmarks", caption = "Show Tickmarks",  class = "Boolean",      needs_init = true},
        {prop = "tickmark_steps", caption = "Tickmark Steps",  class = "Integer",      needs_init = true,   noscale = true},
        {prop = "tickmark_size",  caption = "Tickmark Size",   class = "Integer",      needs_init = true},
        {prop = "pad_ticks",      caption = "Tickmark Pad",    class = "Integer",      needs_init = true},        
        "",
        {prop = "hard_ticks",     caption = "Hard Ticks",      class = "Table",        needs_init = true,   numbers_only = true},       
        {prop = "hard_tick_size", caption = "Hard Tick Size",  class = "Integer",      needs_init = true},
        {prop = "hard_tick_thk",  caption = "Hard Tick Thick", class = "Boolean",      needs_init = true},
        "",
        {prop = "show_min_max",   caption = "Show Min-Max",    class = "Boolean",      needs_init = true},
        {prop = "min_max_values", caption = "Min-Max Vals",    class = "Editor",       needs_init = false,  subclass = "min_max_values"},        
    
--zzdisplay  --zzsl2
        "5",
        {prop = "display_style",    caption = "Display Style",    class = "List"},     -- do not recreate
        {prop = "display_w",        caption = "Display Box W",    class = "Integer",   needs_init = true},
        {prop = "display_h",        caption = "Display Box H",    class = "Integer",   needs_init = true},
        {prop = "display_pos",      caption = "Display Position", class = "Cap_Pos",   needs_init = true},
        {prop = "display_pad_x",    caption = "Disp. Box Pad X",  class = "Integer",   needs_init = true},
        {prop = "display_pad_y",    caption = "Disp. Box Pad Y",  class = "Integer",   needs_init = true},
        props.font_display,
        {prop = "display_align",    caption = "Align",            class = "Align",     noscale = true},
        "",
        {prop = "col_display_bg",   caption = "Display BG Col",   class = "Color",     needs_init = true},        
        {prop = "col_display_text", caption = "Display Text Col", class = "Color",     needs_init = true}, 
        props.frame_use_outline,
        props.frame_thk,
        {prop = "col_frame",        caption = "Disp. Frame Col",   class = "Color",    needs_init = true},                       
    }

}

------------------------
-- GUI.Label:new(name, z, x, y, caption, shadow, font, color, bg)

classes.Label = {
    defaults = {"Label"},
    creation = {"caption", "", "shadow", "font", "color", "bg"},        
    properties = {
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        "",
        "",
        props.caption,        
        props.font,
        {prop = "color",    caption = "Text Color",   class = "Color",   needs_init = true},
        {prop = "bg",       caption = "BG Color",     class = "Color",   needs_init = true},  
        props.shadow, 

    }
}

------------------------
-- name, z, x, y[, text, shadow_text, font, col_bg, col_text]

classes.dh_Label = {
    defaults = {"Label"},
    creation = {"text", "", "shadow_text", "font", "col_bg", "col_text",  "text_pos"},        
    properties = {
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        "",
        {prop = "text",            caption = "Text",         class = "String",  needs_init = true},        
        props.font,
        {prop = "text_pos",     caption = "Text Position",   class = "Cap_Pos", needs_init = true},
        --props.col_bg,
        {prop = "col_bg",      caption = "Background Col.",  class = "List",    needs_init = true},            
        {prop = "col_text",        caption = "Text Color",   class = "Color",   needs_init = true},
        {prop = "shadow_text",  caption = "Text Shadow",     class = "Boolean", needs_init = true},
    }
}

------------------------
-- GUI.Listbox:new(name, z, x, y, w, h, list, multi, caption, pad)

classes.Listbox = {
    defaults = {192, 96, "Item 1,Item 2,Item 3,Item 4"},
    creation = {"w", "h", "list", "", "multi", "caption", "pad", 
                "font_a", "font_b", "shadow",
                "cap_bg", "bg", "color", "col_fill",  
    },
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        props.w,
        props.h,
        "",
        props.caption,
        "",
        {prop = "list",         caption = "List Items",     class = "Table",   needs_init = false},
        {prop = "multi",        caption = "Multi-select",   class = "Boolean", needs_init = false},
        "2",
        "",                
        props.font_a,
        {prop = "font_b",       caption = "Text Font",      class = "Font",    needs_init = false}, --recreate = true},
        props.pad,
        "",
        {prop = "color",        caption = "Text Color",     class = "Color",   needs_init = true},
        props.col_fill,
        {prop = "bg",           caption = "List BG",        class = "Color",   needs_init = true},
        {prop = "cap_bg",       caption = "Caption BG",     class = "Color",   needs_init = true},
        props.shadow,
        
    }
}

--zzlbx 
------------------------
-- GUI.dh_Listbox:new(name, z, x, y, w, h, list, multi, caption, pad, shadow, ...)

classes.dh_Listbox = {
    defaults = {192, 96, "Item 1,Item 2,Item 3,Item 4"},
    creation = {"w", "h", "list", "", "multi", "caption", "pad",
                "cap_pos", "cap_pad_x", "cap_pad_y", "cap_centered",                 
                "col_cap_text",  "col_frame", "frame_use_outline", "frame_thk",  
                "col_bg", "col_text", "col_sel_text", 
                "col_track", "col_active", "col_backdrop", --  "col_thumb","col_sb_outline", 
                "use_sel_alpha", "sel_alpha", "font_caption", "font_text",
                "line_height", "scrollbar_width",
                "shadow", "shadow_caption", "allow_sel_outline",
    },
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        props.w,
        props.h,
        "",
        {prop = "list",             caption = "List Items",     class = "Table",      needs_init = false},
        {prop = "multi",            caption = "Multi-select",   class = "Boolean",    needs_init = false},
        {prop = "scrollbar_width",  caption = "SB Width",       class = "Integer",    needs_init = false},
        props.font_text,
        props.pad,
        props.line_height,
        
        "2",                
        props.caption,
        props.font_caption,
        props.cap_pos,        
        props.cap_pad_x,
        props.cap_pad_y,
        props.cap_centered,
        props.shadow_caption,
        props.shadow,
--zzz
        "3",
        props.col_bg,
        props.frame_use_outline,
        props.frame_thk,
        props.col_frame,
        {prop = "col_track",          caption = "Track Color",    class = "Color",    needs_init = false},
        --{prop = "col_thumb",        caption = "Thumb Color",    class = "Color"},
        --{prop = "col_sb_outline",   caption = "SB OL Color",    class = "Color"},
        props.col_text,
        props.col_sel_text,
        props.use_sel_alpha,
        props.sel_alpha,
        props.col_cap_text,
        props.allow_sel_outline,                            
        props.col_active,        
        props.col_backdrop,        
    }
}

------------------------
-- GUI.Menubar:new(name, z, x, y, menus, w, h, pad)

classes.Menubar = {
    defaults = {
                 {
                    {title = "Menu 1", options = {}},
                    {title = "Menu 2", options = {}},
                    {title = "Menu 3", options = {}},
                  },
                },
    creation = {"menus", "", "w", "h", "pad", 
                "fullwidth", "font", "col_txt", "col_bg", "col_over"},
    properties = {
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        props.w,
        props.h,
        {prop = "fullwidth",    caption = "Full Width",     class = "Boolean",      needs_init = true},        
        {prop = "menus",        caption = "Menu Titles",    class = "Menu_Titles",  needs_init = true},
        {prop = "font",         caption = "Text Font",      class = "Font",         needs_init = true},
        props.col_txt,
        {prop = "col_bg",       caption = "BG Color",       class = "Color",        needs_init = true},
        {prop = "col_over",     caption = "Hover Color",    class = "Color",        needs_init = false},
    }
}

------------------------
-- GUI.dh_Menubar:new(name, z, x, y, menus, w, h, fullwidth, pad, ...) 

classes.dh_Menubar = {
    defaults = {
                 {
                    {title = "Menu 1", options = {}},
                    {title = "Menu 2", options = {}},
                    {title = "Menu 3", options = {}},
                 },
    
    },
    creation = {"menus", "w", "h", "", "fullwidth", "pad",
                "limit_w", "font", "pad", "do_pad_top", "pad_top_val",  
                "col_bg", "col_text", "col_over",
                "shadow",
    },
    properties = {
        "1",
        props.name,
        "",
        props.z, 
        props.x,
        props.y,
        props.w,
        props.h,
        {prop = "fullwidth",    caption = "Full Width",     class = "Boolean",      needs_init = true},
        {prop = "limit_w",      caption = "Limit Width",    class = "Integer",      needs_init = true},
        {prop = "menus",        caption = "Menu Titles",    class = "Editor",       needs_init = true, subclass = "menu_titles"},          
        {prop = "font",         caption = "Text Font",      class = "Font",         needs_init = true},
        props.pad,
        props.shadow,        
        "2",
        props.col_bg,       
        props.col_text,
        {prop = "col_over",     caption = "Hover Color",    class = "Color",        needs_init = false},
        "",        
        {prop = "do_pad_top",   caption = "Do Pad Top",     class = "Boolean",      needs_init = false}, 
        {prop = "pad_top_val",  caption = "Pad Top Value",  class = "Integer",      needs_init = false},        
    },
}

------------------------
-- GUI.Menubox:new(name, z, x, y, w, h, caption, opts, pad, noarrow)

classes.Menubox = {
    defaults = {128, 20, "Menubox", "!Option 1,#Option 2,>Folder,Option 3,Option 4,<Option 5,,Option 6"},
    creation = {"w", "h", "caption", "optarray", "", "pad", "noarrow", 
                "col_txt", "col_cap", "bg", "font_a", "font_b", "align", "retval"},
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        props.w,
        props.h,
        "",
        props.caption,
        props.pad,
        "",
        {prop = "optarray",     caption = "Options",        class = "Table",    needs_init = false},
        {prop = "retval",       caption = "Default",        class = "Integer",  needs_init = false,  noscale = true},
        "2",
        "",                
        props.font_a,
        props.font_b,
        {prop = "col_cap",      caption = "Cap. Color",     class = "Color",    needs_init = false},
        {prop = "col_txt",      caption = "Text Color",     class = "Color",    needs_init = false},
        {prop = "bg",           caption = "BG Color",       class = "Color",    needs_init = true},
        "",
        {prop = "noarrow",      caption = "Hide Arrow",     class = "Boolean",  needs_init = true},
        {prop = "align",        caption = "Align",          class = "Integer",  needs_init = false,  noscale = true},
    }
}

--zzmbx 
------------------------
-- GUI.dh_Menubox:new(name, z, x, y, w, h, caption, opts, noarrow)
-- shadow?

classes.dh_Menubox = {
    defaults = {128, 28, "dh_Menubox", "!Option 1,#Option 2,>Folder,Option 3,Option 4,<Option 5,,Option 6"},
    --defaults = {128, 28, "Menubox", "Option 1,Option 2,<Option 3,,Option 4"},
    creation = {"w", "h", "", "caption", "optarray", "noarrow",     
                "font_caption", "font_text", "pad",
                "cap_pos", "cap_pad_x", "cap_pad_y", "cap_centered",                 
                "col_cap_text", "col_bg", "col_backdrop",  
                "frame_use_outline", "frame_thk", "col_frame", "col_face", "col_active", "col_text",
                "align_text", "curr_opt", 
                "shadow", "shadow_caption", "allow_sel_outline",
    },
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        props.w,
        props.h,
        {prop = "noarrow",    caption = "Hide Arrow",   class = "Boolean",  needs_init = true},
        {prop = "optarray",   caption = "Options",      class = "Table",    needs_init = false},
        {prop = "curr_opt",   caption = "Default",      class = "Integer",  needs_init = false,  noscale = true},
        props.font_text, 
        props.pad,
        {prop = "align_text", caption = "Text Align",   class = "Align",    needs_init = false,  noscale = true},

        "2",        
        props.caption,
        props.font_caption,
        props.cap_pos,        
        props.cap_pad_x,
        props.cap_pad_y,
        props.cap_centered,
        props.shadow_caption,
        props.shadow,
        "3",
        props.col_bg,
        props.frame_use_outline,
        props.frame_thk,
        props.col_frame,
        props.col_face,        
        props.col_text,
        props.col_cap_text,
        "",
        props.allow_sel_outline,                                    
        props.col_active,
        props.col_backdrop,        
    }
}

------------------------
-- GUI.Radio:new(name, z, x, y, w, h, caption, opts, dir, pad)

classes.Radio = {
    defaults = {96, 192, "Radio", "Option 1,Option 2,Option 3,Option 4"},
    creation = {"w", "h", "caption", "optarray", "", "dir", "pad", 
                "font_a", "font_b", "col_txt", "col_fill", "bg", "frame", "shadow", "opt_size", "swap"},
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        props.w,
        props.h,
        "",
        {prop = "optarray",     caption = "Options",        class = "Table",      needs_init = false},
        {prop = "dir",          caption = "Direction",      class = "Direction",  needs_init = true},
        {prop = "opt_size",     caption = "Opt. Size",      class = "Integer",    needs_init = false},
        props.pad,
        {prop = "swap",         caption = "Swap",           class = "Boolean",    needs_init = true},
        "2",
        props.caption,
        "",
        props.font_a,
        "",
        props.font_b,
        props.col_txt,
        {prop = "col_fill",     caption = "Fill Color",     class = "Color",      needs_init = true},        
        {prop = "bg",           caption = "Text BG",        class = "Color",      needs_init = true},
        "",
        {prop = "frame",        caption = "Frame",          class = "Boolean",    needs_init = true},
        props.shadow,

    }
}

--zzopt
------------------------
-- GUI.dh_Radio:new(name, z, x, y, w, h, caption, opts, dir)

classes.dh_Radio = {
    defaults = {128, 128, "dh_Radio", "Option 1,Option 2,Option 3,Option 4"},
    creation = {"w", "h", "caption", "optarray", "", "dir",
                "font_caption", "cap_pos", "cap_pad_x", "cap_pad_y", "cap_centered", 
                "font_text", "pad_x", "pad_y", "border_width", "radius", 
                "col_cap_text", "col_bg", "col_border", "col_text", "col_active",  
                "col_backdrop",
                "swap", "opt_size",
                "shadow", "shadow_caption", "shadow_text", "allow_sel_outline", 
    },
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        props.w,
        props.h,
        {prop = "swap",         caption = "Swap",           class = "Boolean",    needs_init = false},        
        {prop = "dir",          caption = "Direction",      class = "Direction",  needs_init = true},
        {prop = "opt_size",     caption = "Option Size",    class = "Integer",    needs_init = false}, 
        {prop = "border_width", caption = "Border Width",   class = "Integer",    needs_init = true},
        {prop = "radius",       caption = "Radius",         class = "Integer",    needs_init = true},
        {prop = "optarray",     caption = "Options",        class = "Editor",     needs_init = false,  subclass = "options"},                 
        "2",        
        props.caption,
        props.font_caption,        
        props.cap_pos,        
        props.cap_pad_x,
        props.cap_pad_y,
        props.cap_centered,
        props.shadow_caption,
        "",
        props.font_text,
        {prop = "pad_x",        caption = "Option Pad X",   class = "Integer",    needs_init = false},
        {prop = "pad_y",        caption = "Option Pad Y",   class = "Integer",    needs_init = false},
        {prop = "shadow_text",  caption = "Text Shadow",    class = "Boolean",    needs_init = false},

        "",
        props.shadow,                
        "3",        
        props.col_bg,
        props.col_border,
        props.col_text,
        props.col_cap_text,
        props.allow_sel_outline,
        props.col_active, 
        props.col_backdrop,        
    }
   
}

------------------------
-- GUI.Slider:new(name, z, x, y, w, caption, min, max, defaults, inc, dir)

classes.Slider = {
    defaults = {96, "Slider", 0, 10, {5}},
    creation = {"w", "caption", "min", "max", "defaults", "inc", "dir", "", 
                "font_a", "font_b", "show_handles", "show_values", "cap_pad_x", "cap_pad_y",
                "bg", "col_txt", "col_fill", 
    },
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        props.w,
        {prop = "show_handles", caption = "Show Handles",  class = "Boolean",   needs_init = false},
        {prop = "show_values",  caption = "Show Values",   class = "Boolean",   needs_init = false},
        {prop = "min",          caption = "Min.",          class = "Number",    recreate = true, noscale = true},
        {prop = "max",          caption = "Max.",          class = "Number",    recreate = true, noscale = true},
        {prop = "defaults",     caption = "Defaults",      class = "Table",     recreate = true, numbers_only = true},
        {prop = "inc",          caption = "Increment",     class = "Number",    recreate = true, noscale = true},
        {prop = "dir",          caption = "Direction",     class = "Direction", recreate = true},
        "2",
        "",                        
        props.caption,
        {prop = "cap_pad_x",    caption = "Cap. Offset X", class = "Integer",    needs_init = false},
        {prop = "cap_pad_y",    caption = "Cap. Offset Y", class = "Integer",    needs_init = false},        
        props.font_a,
        "",                        
        {prop = "font_b",       caption = "Val. Font",     class = "Font"},
        props.col_txt,
        props.col_fill,
        {prop = "bg",           caption = "BG Color",      class = "Color"},

    }
}

--zzslider  --zzknob 
------------------------
-- GUI.dh_Slider_H:new(name, z, x, y, w, h, caption, min, max, default, inc)

classes.dh_Slider_H = {
    defaults = {256, 64, "dh_Slider_H", 0, 10, 5},
    creation = {"w", "h", "caption", "min", "max", "default", "inc", "", 
                "track_thk", "thumb_style", "fill_from_default",
                "font_caption", "cap_pos", "cap_pad_x", "cap_pad_y", "cap_centered", 
                "shadow_caption", "shadow", 
                "font_values", "font_display", -- "output",  
                "border_width", "radius",
                "col_bg", "col_border", "col_values", "col_cap_text", "col_backdrop",   
                "col_track", "col_frame", --"col_track_outline", 
                "col_thumb", "col_thumb_outline", "col_fill", 
                "frame_use_outline", "frame_thk", "allow_sel_outline", "col_active",
                "show_tickmarks", "tickmark_steps", "show_default_tickmarks", "default_tickmarks", 
                "show_min_max", "min_max_values", "show_values", "pad_values", 
                "track_offset", "tickmarks_offset", 
                "display_style", "display_w", "display_h", "display_pos", "display_pad_x", "display_pad_y",
                "display_align", "col_display_bg", "col_display_text",                   
    },
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        props.w,
        props.h,  
        --!!! Must not recreate!      
        {prop = "track_thk",         caption = "Thickness",         class = "Integer", needs_init = true},
        {prop = "thumb_style",       caption = "Thumb Style",       class = "List",    needs_init = true}, -- do not recreate
        {prop = "fill_from_default", caption = "Fill from Default", class = "Boolean", needs_init = false},
        {prop = "min",               caption = "Min.",              class = "Number",  recreate = true, noscale = true},
        {prop = "max",               caption = "Max.",              class = "Number",  recreate = true, noscale = true},
        {prop = "default",           caption = "Default",           class = "Integer", recreate = true, noscale = true},
        {prop = "inc",               caption = "Increment",         class = "Number",  recreate = true, noscale = true},

--zzcaption        
        "2",
        props.caption,
        props.font_caption,        
        props.cap_pos,        
        props.cap_pad_x,
        props.cap_pad_y,
        props.cap_centered,         
        props.shadow_caption, 
        "",                       
        {prop = "border_width",      caption = "Border Width",      class = "Integer",  needs_init = true},
        {prop = "radius",            caption = "Rad. Corners",      class = "Integer",  needs_init = true},
        props.shadow,
--zzcolors 
        "3",
        props.col_bg,
        props.col_border,
        props.col_values,        
        props.col_cap_text,
        {prop = "col_track",              caption = "Track Color",      class = "Color",  needs_init = true},
        --{prop = "col_track_outline",      caption = "Track OL Color",   class = "Color"},
        props.col_frame,               
        {prop = "col_thumb",              caption = "Thumb Color",      class = "Color",  needs_init = true},
        {prop = "col_thumb_outline",      caption = "Thumb OL Color",   class = "Color",  needs_init = true},
        {prop = "col_fill",               caption = "Fill Color",       class = "Color",  needs_init = false},
        props.frame_use_outline,
        props.frame_thk,                
        props.allow_sel_outline,
        props.col_active,
        props.col_backdrop,        

--zztickmarks         
        "4",
        {prop = "show_tickmarks",         caption = "Show Tickmarks",   class = "Boolean",     needs_init = true},
        {prop = "tickmark_steps",         caption = "Tickmark Steps",   class = "Integer",     needs_init = true,   noscale = true},
        {prop = "show_default_tickmarks", caption = "Show Def Ticks",   class = "Boolean",     needs_init = true},
        {prop = "default_tickmarks",      caption = "Default Ticks",    class = "Table",       needs_init = true,   numbers_only = true},
        "",
        {prop = "show_min_max",           caption = "Show Min-Max",     class = "Boolean",     needs_init = false},
        {prop = "min_max_values",         caption = "Min-Max Vals",     class = "Editor",      needs_init = false,  subclass = "min_max_values"},
        "",
        {prop = "show_values",            caption = "Show Values",      class = "Boolean",     needs_init = false},
        props.font_values,       
        --{prop = "output",                 caption = "Output",            class = "Table"},
        {prop = "pad_values",             caption = "Values Padding",   class = "Integer",     needs_init = false}, 
        {prop = "track_offset",           caption = "Track Offset",     class = "Integer",     needs_init = true},
        {prop = "tickmarks_offset",       caption = "Tickmarks Offset", class = "Integer",     needs_init = true},
                
--zzdisplay
        "5",
        {prop = "display_style",          caption = "Display Style",    class = "List",        needs_init = true},  -- do not recreate
        {prop = "display_w",              caption = "Display Box W",    class = "Integer",     needs_init = true},
        {prop = "display_h",              caption = "Display Box H",    class = "Integer",     needs_init = true},
        {prop = "display_pos",            caption = "Display Position", class = "Cap_Pos",     needs_init = true},
        {prop = "display_pad_x",          caption = "Disp. Box Pad X",  class = "Integer",     needs_init = true},
        {prop = "display_pad_y",          caption = "Disp. Box Pad Y",  class = "Integer",     needs_init = true},
        props.font_display,
        {prop = "display_align",          caption = "Align",            class = "Align",       needs_init = false, noscale = true},
        "",
        {prop = "col_display_bg",         caption = "Display BG Col",   class = "Color",     needs_init = true},
        {prop = "col_display_text",       caption = "Display Text Col", class = "Color",     needs_init = false},

    },
}

------------------------
-- GUI.dh_Slider_V:new(name, z, x, y, w, h, caption, min, max, default, inc)

classes.dh_Slider_V = {
    defaults = {24, 128, "dh_Slider_V", 0, 10, 5},
    creation = {"w", "h", "caption", "min", "max", "default", "inc", "", 
                "track_thk", "thumb_style", "fill_from_default",
                "font_caption", "cap_pos", "cap_pad_x", "cap_pad_y", "cap_centered", 
                "shadow_caption", "shadow", 
                "font_values", "font_display", -- "output", 
                "border_width", "radius",
                "col_bg", "col_border", "col_values", "col_cap_text", "col_backdrop",    
                "col_track", "col_frame", "col_fill", --"col_track_outline", 
                "col_thumb", "col_thumb_outline", 
                "frame_use_outline", "frame_thk", "allow_sel_outline", "col_active",
                "show_tickmarks", "tickmark_steps", "show_default_tickmarks", "default_tickmarks", 
                "show_min_max", "min_max_values", "show_values", "pad_values", 
                "track_offset", "tickmarks_offset",   
                "display_style", "display_w", "display_h", "display_pos", "display_pad_x", "display_pad_y",
                "display_align", "col_display_bg", "col_display_text", 
                
    },
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        props.w,
        props.h,  
        --!!! Must not recreate!      
        {prop = "track_thk",         caption = "Thickness",    class = "Integer",      needs_init = true},
        {prop = "thumb_style",       caption = "Thumb Style",  class = "List",         needs_init = true},        -- recreate?                
        {prop = "fill_from_default", caption = "Fill from Default", class = "Boolean", needs_init = false},
        {prop = "min",               caption = "Min.",         class = "Number",       recreate = true, noscale = true},
        {prop = "max",               caption = "Max.",         class = "Number",       recreate = true, noscale = true},
        {prop = "default",           caption = "Default",      class = "Integer",      recreate = true, noscale = true},
        {prop = "inc",               caption = "Increment",    class = "Number",       recreate = true, noscale = true},
        
--zzcaption        
        "2",
        props.caption,
        props.font_caption,        
        props.cap_pos,        
        props.cap_pad_x,
        props.cap_pad_y,
        props.cap_centered,         
        props.shadow_caption,
        "",
        {prop = "border_width",           caption = "Border Width",      class = "Integer",     needs_init = true},
        {prop = "radius",                 caption = "Rad. Corners",      class = "Integer",     needs_init = true},
        props.shadow,
--zzcolors  
        "3",
        props.col_bg,
        props.col_border,          
        props.col_values,        
        props.col_cap_text,
        {prop = "col_track",              caption = "Track Color",     class = "Color",       needs_init = true},
        --{prop = "col_track_outline",      caption = "Track OL Color",  class = "Color"},
        props.col_frame,               
        {prop = "col_thumb",              caption = "Thumb Color",     class = "Color",       needs_init = true},
        {prop = "col_thumb_outline",      caption = "Thumb OL Color",  class = "Color",       needs_init = true},
        {prop = "col_fill",               caption = "Fill Color",      class = "Color",       needs_init = false},
        props.frame_use_outline,
        props.frame_thk,
        props.allow_sel_outline,
        props.col_active,                        
        props.col_backdrop,        
        
--zztickmarks        
        "4",
        {prop = "show_tickmarks",         caption = "Show Tickmarks",   class = "Boolean",     needs_init = true},
        {prop = "tickmark_steps",         caption = "Tickmark Steps",   class = "Integer",     needs_init = true,   noscale = true},
        {prop = "show_default_tickmarks", caption = "Show Def Ticks",   class = "Boolean",     needs_init = true},
        {prop = "default_tickmarks",      caption = "Default Ticks",    class = "Table",       needs_init = true,   numbers_only = true},
        "",
        {prop = "show_min_max",           caption = "Show Min-Max",     class = "Boolean",     needs_init = false},
        {prop = "min_max_values",         caption = "Min-Max Vals",     class = "Editor",      needs_init = false,  subclass = "min_max_values"},
        "",
        {prop = "show_values",            caption = "Show Values",      class = "Boolean",     needs_init = false},
        props.font_values,       
        --{prop = "output",                 caption = "Output",           class = "Table"},
        {prop = "pad_values",             caption = "Values Padding",   class = "Integer",     needs_init = false}, 
        {prop = "track_offset",           caption = "Track Offset",     class = "Integer",     needs_init = true},
        {prop = "tickmarks_offset",       caption = "Tickmarks Offset", class = "Integer",     needs_init = true},

--zzdisplay  --zzsl2
        "5",
        {prop = "display_style",          caption = "Display Style",    class = "List",        needs_init = true}, -- do not recreate
        {prop = "display_w",              caption = "Display Box W",    class = "Integer",     needs_init = true},
        {prop = "display_h",              caption = "Display Box H",    class = "Integer",     needs_init = true},
        {prop = "display_pos",            caption = "Display Position", class = "Cap_Pos",     needs_init = true},
        {prop = "display_pad_x",          caption = "Disp. Box Pad X",  class = "Integer",     needs_init = true},
        {prop = "display_pad_y",          caption = "Disp. Box Pad Y",  class = "Integer",     needs_init = true},
        props.font_display,
        {prop = "display_align",          caption = "Align",            class = "Align",       needs_init = false, noscale = true},
        "",
        {prop = "col_display_bg",         caption = "Display BG Col", class = "Color",         needs_init = true},
        {prop = "col_display_text",       caption = "Display Text Col", class = "Color",       needs_init = false},

    },
}

------------------------
-- GUI.Tabs:new(name, z, x, y, tab_w, tab_h, opts, pad)

classes.Tabs = {
    defaults = {48, 20, "Tab 1,Tab 2,Tab 3"},
    creation = {"tab_w", "tab_h", "optarray", "", "pad", 
                "w", "bg", "col_txt", "col_tab_a", "col_tab_b", "font_a", "font_b"},
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        {prop = "w",            caption = "W",              class = "Integer",    recreate = true},
        {prop = "fullwidth",    caption = "Full Width",     class = "Boolean",    needs_init = true},
        {prop = "optarray",     caption = "Options",        class = "Table",      needs_init = false},          
        {prop = "tab_w",        caption = "Tab Width",      class = "Integer",    needs_init = true},
        {prop = "tab_h",        caption = "Tab Height",     class = "Integer",    recreate = true},
        --{prop = "tab_h",        caption = "Tab Height",     class = "Integer",  needs_init = true},        
        {prop = "pad",          caption = "Tab Pad",        class = "Integer",    needs_init = false},
        "2",
        "",        
        {prop = "font_a",       caption = "Active Font",    class = "Font",       needs_init = false},
        {prop = "font_b",       caption = "Inact. Font",    class = "Font",       needs_init = false},
        "",        
        props.col_txt,
        {prop = "col_tab_a",    caption = "Active Color",   class = "Color",      needs_init = false},
        {prop = "col_tab_b",    caption = "Inact. Color",   class = "Color",      needs_init = false},
        {prop = "bg",           caption = "BG Color",       class = "Color",      needs_init = false},
    }
}

--zztabs
------------------------
-- GUI.dh_Tabs:new(name, z, x, y, tab_w, tab_h, opts, pad)

classes.dh_Tabs = {
    defaults = {48, 20, "Tab 1,Tab 2,Tab 3"},
    creation = {"tab_w", "tab_h", "optarray", "", "pad", 
                " fullwidth", "limit_w", "font_tab_active", "font_tab_inactive", 
                "col_bg", "col_text", "col_tab_acive", "col_tab_inactive",
                "z_sets",
    },
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        --{prop = "w",               caption = "W",              class = "Integer",    recreate = true},
        {prop = "tab_w",             caption = "Tab Width",      class = "Integer",    needs_init = true},
        {prop = "tab_h",             caption = "Tab Height",     class = "Integer",    recreate = true},
        {prop = "pad",               caption = "Tab Pad",        class = "Integer",    needs_init = false},

        {prop = "fullwidth",         caption = "Full Width",     class = "Boolean",    needs_init = true},
        {prop = "limit_w",           caption = "Limit Width",    class = "Integer",    needs_init = true},
        {prop = "optarray",          caption = "Options",        class = "Editor",     needs_init = false,  subclass = "tab_titles"},                 
        {prop = "z_sets",            caption = "z_sets",         class = "Editor",     needs_init = false,  subclass = "z_sets"},
        "2",
        {prop = "font_tab_active",   caption = "Active Font",    class = "Font",       needs_init = false},
        {prop = "font_tab_inactive", caption = "Inact. Font",    class = "Font",       needs_init = false},
        "",
        props.col_bg,
        props.col_text,
        {prop = "col_tab_active",    caption = "Active Tab Color",  class = "Color",   needs_init = false},
        {prop = "col_tab_inactive",  caption = "Inact. Tab Color",  class = "Color",   needs_init = false},

    }
}

------------------------
--GUI.Textbox:new(name, z, x, y, w, h, caption, pad)

classes.Textbox = {
    defaults = {96, 20, "Textbox"},
    creation = {"w", "h", "caption", "","pad", 
                "font_a", "font_b", "cap_pos", "color", "bg", "shadow", "undo_limit"},
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        props.w,
        props.h,
        "",
        props.caption,
        props.pad,
        props.cap_pos,        
        "2",
        "",        
        props.font_a,
        {prop = "font_b",       caption = "Text Font",      class = "MonoFont", needs_init = false},
        {prop = "color",        caption = "Text Color",     class = "Color",    needs_init = false},
        {prop = "bg",           caption = "Cap. BG",        class = "Color",    needs_init = false},
        props.shadow,        
        "",
        {prop = "undo_limit",   caption = "Undo States",    class = "Integer",  needs_init = false, noscale = true},

    }
}

--zztbx 
------------------------
-- GUI.dh_Textbox:new(name, z, x, y, w, h, caption, pad)

classes.dh_Textbox = {
    defaults = {96, 28, "dh_Textbox"},
    creation = {"w", "h", "caption", "",
                "font_caption", "cap_pos", "cap_pad_x", "cap_pad_y", 
                "cap_centered", "shadow_caption",
                "font_text", "pad", "align_text", "shadow",
                "col_cap_text", "col_frame", "frame_use_outline", "frame_thk",  
                "col_bg", "col_active", "col_text", "col_sel_text", "col_backdrop", 
                "use_sel_alpha", "sel_alpha", "undo_limit", "allow_sel_outline",
    },
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        props.w,
        props.h,
        "",
        {prop = "font_text",    caption = "Text Font",   class = "MonoFont", needs_init = false},
        props.pad,        
        {prop = "align_text",   caption = "Text Align",  class = "Align",    needs_init = false, noscale = true},
        {prop = "undo_limit",   caption = "Undo States", class = "Integer",  needs_init = false, noscale = true},
        "2",
        props.caption,
        props.font_caption,
        props.cap_pos,        
        props.cap_pad_x,
        props.cap_pad_y,
        props.cap_centered,
        props.shadow_caption,
        props.shadow,
        "3",
        props.col_bg,  
        props.frame_use_outline,
        props.frame_thk,
        props.col_frame,
        props.col_text,
        props.col_sel_text,
        props.use_sel_alpha,
        props.sel_alpha,                
        "",
        props.col_cap_text,
        "",
        props.allow_sel_outline, 
        props.col_active,        
        props.col_backdrop,        
    }
}

------------------------
-- GUI.TextEditor:new(name, z, x, y, w, h, text, caption, pad)

classes.TextEditor = {
    defaults = {256, 192},
    creation = {"w", "h", "caption", "pad", "", "bg", "shadow", "color", "col_fill", "font_a", "font_b", "undo_limit"},
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        {prop = "w",            caption = "W",            class = "Integer",   needs_init = true},
        {prop = "h",            caption = "H",            class = "Integer",   needs_init = true},
          
        "",
        props.caption, 
        props.pad, 
        "2",
        "",        
        props.font_a,
        {prop = "font_b",       caption = "Text Font",    class = "MonoFont",   needs_init = fasle},
        {prop = "color",        caption = "Text Color",   class = "Color",      needs_init = true},
        props.col_fill,
        {prop = "cap_bg",       caption = "Cap. BG",      class = "Color",      needs_init = false},
        {prop = "bg",           caption = "Background",   class = "Color",      needs_init = true},
        "",
        props.shadow,        
        "",
        {prop = "undo_limit",   caption = "Undo States",  class = "Integer", needs_init = false,  noscale = true},
    }
}

--zztxe  --zzact
------------------------
-- GUI.dh_TextEditor:new(name, z, x, y, w, h, text, caption, pad)

-- Although dh_TextEditor is created with some default text, there is not a Property to edit it.
-- It can be edited directly in the element. It will then be styored in the elements 'retval' property.
-- When a dh_TextEditor is recreated due to other changes there is a mechanism in place to transfer the 'retval' 
-- to the recreated element.

classes.dh_TextEditor = {
    defaults = {256, 192, "This is some text.\nThis is more text.\nThis is some text.\nThis is more text."},
    creation = {"w", "h", "", "caption", "pad", 
                "font_caption", "cap_pos", "cap_pad_x", "cap_pad_y", 
                "cap_centered", "shadow_caption",
                "font_text", "line_height", "scrollbar_width", "undo_limit",
                "col_cap_text", "col_frame", "frame_use_outline", "frame_thk",  
                "col_bg", "col_text", "col_active", "col_sel_text", "col_backdrop", 
                "col_track", --"col_thumb", --"col_sb_outline", 
                "use_sel_alpha", "sel_alpha", 
                "shadow", "allow_sel_outline", 
    },
    properties = {
        "1",
        props.name,
        "",
        props.z,
        props.x,
        props.y,
        {prop = "w",            caption = "W",            class = "Integer",   needs_init = true},  --recreate = true
        {prop = "h",            caption = "H",            class = "Integer",   needs_init = true},  --recreate = true
        
         "",
        {prop = "font_text",       caption = "Text Font",    class = "MonoFont",  needs_init = false},         
        props.pad,
        props.line_height,
        {prop = "undo_limit",      caption = "Undo States",  class = "Integer",   needs_init = false, noscale = true},
        {prop = "scrollbar_width", caption = "SB Width",     class = "Integer",   needs_init = false},

        "2",
        props.caption,
        props.font_caption,
        props.cap_pos,        
        props.cap_pad_x,
        props.cap_pad_y,
        props.cap_centered,
        props.shadow_caption,                
        props.shadow,       
        "3",
        props.col_bg,
        props.frame_use_outline,
        props.frame_thk,        
        props.col_frame,
        {prop = "col_track",       caption = "Track Color",    class = "Color",   needs_init = false},       
        props.col_text,
        props.col_sel_text,
        props.use_sel_alpha,
        props.sel_alpha,
                        
        props.col_cap_text,

        --{prop = "col_thumb",       caption = "Thumb Color",    class = "Color"},
        --{prop = "col_sb_outline",  caption = "SB OL Color",    class = "Color"},

        props.allow_sel_outline,                                    
        props.col_active,        
        props.col_backdrop,        
    }

}

------------------------
-- Store the element data with the element classes, keep a list of classes we can return
local ret_classes = {}

for class, data in pairs(classes) do

    --GUI.Msg("    data in pairs : " .. class )

    GUI[class].GB = data
    ret_classes[class] = true  -- ???

end

return classes