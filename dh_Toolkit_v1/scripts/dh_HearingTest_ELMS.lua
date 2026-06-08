-- # GUI Builder Project file v1

GB_Project_Settings = {
    name = "dh_HearingTest",
    w = 640,
    h = 480,
    x = 0,
    y = 0,
    anchor = "mouse",
    corner = "C",
}

GB_Project_Elements_Names = {
    "btn_ProfileRename",
    "btn_Print",
    "tbx_ProfileName",
    "btn_Gain_Dec",
    "btn_CloseProfileEditor",
    "knob_LR_Cents",
    "dh_MainTest",
    "pnl_MainTest",
    "btn_ProfileDelete",
    "mbx_Tracks",
    "mbx_Profiles",
    "lbl_LR_Test",
    "btn_ProfileSave",
    "btn_LR_Stop",
    "btn_Prefs",
    "btn_Start",
    "knob_LR_Gain",
    "graph_Freq",
    "radio_GraphType",
    "radio_Channel",
    "chkl_Locked",
    "mbx_Freqs",
    "lbl_ProfileEditor",
    "btn_Stop",
    "btn_LR_Start",
    "pnl_ProfileEditor",
    "btn_OpenProfileEditor",
    "btn_Gain_Inc",
    "pnl_LR_Test",
    "chkl_Bypass",
}
GUI.New("mbx_Freqs", "dh_Menubox", {
    z = 10,
    x = 16,
    y = 32,
    w = 128,
    h = 28,
    noarrow = false,
    optarray = {"Option 1", "Option 2" , "Option 3", "Option 4"},
    curr_opt = 1,
    font_text = "sans22",
    pad = 4,
    align_text = "left",
    caption = "Frequency",
    font_caption = "sans22",
    cap_pos = "top",
    cap_pad_x = 4,
    cap_pad_y = 4,
    cap_centered = false,
    shadow_caption = false,
    shadow = false,
    col_bg = "elm_bg",
    frame_use_outline = false,
    frame_thk = 2,
    col_frame = "elm_frame",
    col_face = "btn_face",
    col_text = "elm_txt",
    col_cap_text = "txt",
    allow_sel_outline = false,
    col_active = "elm_active",
    col_backdrop = "wnd_bg",
})




GUI.New("mbx_Tracks", "dh_Menubox", {
    z = 11,
    x = 160,
    y = 32,
    w = 172,
    h = 28,
    noarrow = false,
    optarray = {"Option 1", "Option 2" , "Option 3", "Option 4"},
    curr_opt = 1,
    font_text = "sans22",
    pad = 4,
    align_text = "left",
    caption = "Track",
    font_caption = "sans22",
    cap_pos = "top",
    cap_pad_x = 4,
    cap_pad_y = 4,
    cap_centered = false,
    shadow_caption = false,
    shadow = false,
    col_bg = "elm_bg",
    frame_use_outline = false,
    frame_thk = 2,
    col_frame = "elm_frame",
    col_face = "btn_face",
    col_text = "elm_txt",
    col_cap_text = "txt",
    allow_sel_outline = false,
    col_active = "elm_active",
    col_backdrop = "wnd_bg",
})

GUI.New("mbx_Profiles", "dh_Menubox", {
    z = 11,
    x = 352,
    y = 32,
    w = 172,
    h = 28,
    noarrow = false,
    optarray = {"Option 1", "Option 2" , "Option 3", "Option 4"},
    curr_opt = 1,
    font_text = "sans22",
    pad = 4,
    align_text = "left",
    caption = "Profiles",
    font_caption = "sans22",
    cap_pos = "top",
    cap_pad_x = 4,
    cap_pad_y = 4,
    cap_centered = false,
    shadow_caption = false,
    shadow = false,
    col_bg = "elm_bg",
    frame_use_outline = false,
    frame_thk = 2,
    col_frame = "elm_frame",
    col_face = "btn_face",
    col_text = "elm_txt",
    col_cap_text = "txt",
    allow_sel_outline = false,
    col_active = "elm_active",
    col_backdrop = "wnd_bg",
})




GUI.New("chkl_Locked", "dh_Checklist", {
    z = 12,
    x = 16,
    y = 64,
    w = 128,
    h = 32,
    swap = false,
    dir = "v",
    opt_size = 16,
    border_width = 0,
    radius = 2,
    optarray = {
        "Locked",
    },
    caption = "",
    font_caption = "sans22",
    cap_pos = "top",
    cap_pad_x = 4,
    cap_pad_y = 4,
    cap_centered = false,
    shadow_caption = false,
    font_text = "sans22",
    pad_x = 10,
    pad_y = 8,
    shadow_text = false,
    shadow = false,
    col_bg = "wnd_bg",
    col_border = "panel_border",
    col_text = "txt",
    col_cap_text = "txt",
    allow_sel_outline = false,
    col_active = "elm_active",
    col_backdrop = "wnd_bg",
})




GUI.New("chkl_Bypass", "dh_Checklist", {
    z = 13,
    x = 160,
    y = 64,
    w = 128,
    h = 32,
    swap = false,
    dir = "v",
    opt_size = 16,
    border_width = 0,
    radius = 2,
    optarray = {
        "Bypass",
    },
    caption = "",
    font_caption = "sans22",
    cap_pos = "top",
    cap_pad_x = 4,
    cap_pad_y = 4,
    cap_centered = false,
    shadow_caption = false,
    font_text = "sans22",
    pad_x = 10,
    pad_y = 8,
    shadow_text = false,
    shadow = false,
    col_bg = "wnd_bg",
    col_border = "panel_border",
    col_text = "txt",
    col_cap_text = "txt",
    allow_sel_outline = false,
    col_active = "elm_active",
    col_backdrop = "wnd_bg",
})




GUI.New("btn_Prefs", "dh_Button", {
    z = 14,
    x = 552,
    y = 64,
    w = 64,
    h = 28,
    text = "Prefs",
    font = "sans22",
    shadow_text = false,
    col_bg = "btn_face",
    col_outline = "btn_outline",
    col_text = "btn_txt",
    col_active = "elm_active",
    allow_sel_outline = false,
})




GUI.New("btn_Print", "dh_Button", {
    z = 15,
    x = 552,
    y = 16,
    w = 64,
    h = 28,
    text = "Print",
    font = "sans22",
    shadow_text = false,
    col_bg = "btn_face",
    col_outline = "btn_outline",
    col_text = "btn_txt",
    col_active = "elm_active",
    allow_sel_outline = false,
})




GUI.New("btn_OpenProfileEditor", "dh_Button", {
    z = 16,
    x = 392,
    y = 64,
    w = 64,
    h = 28,
    text = "Edit",
    font = "sans24",
    shadow_text = false,
    col_bg = "btn_face",
    col_outline = "btn_outline",
    col_text = "btn_txt",
    col_active = "elm_active",
    allow_sel_outline = false,
})




GUI.New("radio_Channel", "dh_Radio", {
    z = 20,
    x = 16,
    y = 108,
    w = 128,
    h = 208,
    swap = false,
    dir = "v",
    opt_size = 16,
    border_width = 2,
    radius = 4,
    optarray = {
        "Left",
        "Center",
        "Right",
    },
    caption = "Channel",
    font_caption = "sans24",
    cap_pos = "inside",
    cap_pad_x = 24,
    cap_pad_y = 4,
    cap_centered = true,
    shadow_caption = false,
    font_text = "sans22",
    pad_x = 12,
    pad_y = 16,
    shadow_text = false,
    shadow = false,
    col_bg = "panel_bg",
    col_border = "panel_border",
    col_text = "panel_txt",
    col_cap_text = "panel_txt",
    allow_sel_outline = false,
    col_active = "elm_active",
    col_backdrop = "wnd_bg",
})




GUI.New("radio_GraphType", "dh_Radio", {
    z = 21,
    x = 16,
    y = 356,
    w = 36,
    h = 72,
    swap = true,
    dir = "v",
    opt_size = 16,
    border_width = 0,
    radius = 0,
    optarray = {
        "C",
        "F",
    },
    caption = "",
    font_caption = "sans24",
    cap_pos = "top",
    cap_pad_x = 12,
    cap_pad_y = 4,
    cap_centered = true,
    shadow_caption = false,
    font_text = "sans22",
    pad_x = 0,
    pad_y = 16,
    shadow_text = false,
    shadow = false,
    col_bg = "wnd_bg",
    col_border = "panel_border",
    col_text = "txt",
    col_cap_text = "txt",
    allow_sel_outline = false,
    col_active = "elm_active",
    col_backdrop = "wnd_bg",
})




GUI.New("graph_Freq", "dh_Graph", {
    z = 22,
    x = 64,
    y = 332,
    w = 560,
    h = 132,
    grid_x_divs = 24,
    grid_y_divs = 8,
    y_min = -12,
    y_max = 12,
    y_ref = 0,
    caption = "",
    font_caption = "sans22",
    cap_pad_x = 4,
    cap_pad_y = 4,
    cap_centered = false,
    shadow_caption = false,
    shadow = false,
    graph_labels = nil,
    font_text = "sans20",
    pad = 4,
    frame_use_outline = false,
    frame_thk = 2,
    col_frame = "elm_frame",
    col_cap_text = "txt",
    allow_sel_outline = false,
    col_backdrop = "wnd_bg",
})




GUI.New("btn_Stop", "dh_Button", {
    z = 25,
    x = 280,
    y = 240,
    w = 64,
    h = 28,
    text = "STOP",
    font = "sans22",
    shadow_text = false,
    col_bg = "btn_face",
    col_outline = "btn_outline",
    col_text = "btn_txt",
    col_active = "elm_active",
    allow_sel_outline = false,
})




GUI.New("btn_Start", "dh_Button", {
    z = 26,
    x = 280,
    y = 168,
    w = 64,
    h = 28,
    text = "START",
    font = "sans22",
    shadow_text = false,
    col_bg = "btn_face",
    col_outline = "btn_outline",
    col_text = "btn_txt",
    col_active = "elm_active",
    allow_sel_outline = false,
})




GUI.New("btn_Gain_Dec", "dh_Button", {
    z = 27,
    x = 184,
    y = 240,
    w = 64,
    h = 28,
    text = "Dec Vol",
    font = "sans22",
    shadow_text = false,
    col_bg = "btn_face",
    col_outline = "btn_outline",
    col_text = "btn_txt",
    col_active = "elm_active",
    allow_sel_outline = false,
})




GUI.New("btn_Gain_Inc", "dh_Button", {
    z = 28,
    x = 184,
    y = 168,
    w = 64,
    h = 28,
    text = "Inc Vol",
    font = "sans22",
    shadow_text = false,
    col_bg = "btn_face",
    col_outline = "btn_outline",
    col_text = "btn_txt",
    col_active = "elm_active",
    allow_sel_outline = false,
})




GUI.New("dh_MainTest", "dh_Label", {
    z = 29,
    x = 224,
    y = 116,
    text = "Main Test",
    font = "sans24",
    text_pos = "left",
    col_bg = "panel_bg",
    col_text = "panel_txt",
    shadow_text = false,
})




GUI.New("pnl_MainTest", "dh_Panel", {
    z = 30,
    x = 160,
    y = 108,
    w = 208,
    h = 208,
    border_width = 2,
    radius = 4,
    shadow = false,
    caption = "",
    font_caption = "sans22",
    cap_pad_x = 4,
    cap_pad_y = 4,
    cap_centered = false,
    shadow_caption = false,
    text = {
        "",
    },
    font_text = "mono16",
    pad = 4,
    line_height = 1.25,
    use_pixels = false,
    line_height_pixels = 24,
    col_bg = "panel_bg",
    col_border = "panel_border",
    col_text = "panel_txt",
    col_cap_text = "panel_txt",
    col_backdrop = "wnd_bg",
})




GUI.New("knob_LR_Cents", "dh_Knob", {
    z = 36,
    x = 560,
    y = 248,
    w = 40,
    centered = true,
    knob_style = "simple",
    min = -100,
    max = 100,
    default = 10,
    inc = 10,
    shadow = true,
    caption = "Fine Tune",
    font_caption = "sans22",
    cap_pos = "bottom",
    cap_pad = 8,
    shadow_caption = false,
    show_values = false,
    font_values = "sans22",
    pad_values = 2,
    col_bg = "panel_bg",
    col_outline = "btn_outline",
    col_body = "btn_face",
    col_values = "panel_txt",
    col_cap_text = "panel_txt",
    allow_sel_outline = false,
    col_active = "elm_active",
    show_tickmarks = true,
    tickmark_steps = 10,
    tickmark_size = 4,
    pad_ticks = 4,
    hard_ticks = {0, 5, 10, },
    hard_tick_size = 8,
    hard_tick_thk = true,
    show_min_max = true,
    min_max_values = {
        {0,"-1"},
        {10,"0"},
        {20,"+1"},
    },
    display_style = "none",
    display_w = 48,
    display_h = 24,
    display_pos = "top",
    display_pad_x = 0,
    display_pad_y = 8,
    font_display = "sans24",
    display_align = "center",
    col_display_bg = "elm_bg",
    col_display_text = "elm_txt",
    frame_use_outline = false,
    frame_thk = 2,
    col_frame = "elm_frame",
})




GUI.New("knob_LR_Gain", "dh_Knob", {
    z = 37,
    x = 448,
    y = 248,
    w = 40,
    centered = true,
    knob_style = "simple",
    min = -9,
    max = 9,
    default = 9,
    inc = 1,
    shadow = true,
    caption = "Gain",
    font_caption = "sans22",
    cap_pos = "bottom",
    cap_pad = 8,
    shadow_caption = false,
    show_values = false,
    font_values = "sans22",
    pad_values = 2,
    col_bg = "panel_bg",
    col_outline = "btn_outline",
    col_body = "btn_face",
    col_values = "panel_txt",
    col_cap_text = "panel_txt",
    allow_sel_outline = false,
    col_active = "elm_active",
    show_tickmarks = true,
    tickmark_steps = 16,
    tickmark_size = 4,
    pad_ticks = 4,
    hard_ticks = {0, 8, 16, },
    hard_tick_size = 8,
    hard_tick_thk = true,
    show_min_max = true,
    min_max_values = {
        {0,"-9"},
        {9,"0"},
        {18,"+9"},
    },
    display_style = "none",
    display_w = 48,
    display_h = 24,
    display_pos = "top",
    display_pad_x = 0,
    display_pad_y = 8,
    font_display = "sans24",
    display_align = "center",
    col_display_bg = "elm_bg",
    col_display_text = "elm_txt",
    frame_use_outline = false,
    frame_thk = 2,
    col_frame = "elm_frame",
})




GUI.New("btn_LR_Stop", "dh_Button", {
    z = 38,
    x = 416,
    y = 160,
    w = 64,
    h = 28,
    text = "STOP",
    font = "sans22",
    shadow_text = false,
    col_bg = "btn_face",
    col_outline = "btn_outline",
    col_text = "btn_txt",
    col_active = "elm_active",
    allow_sel_outline = false,
})




GUI.New("lbl_LR_Test", "dh_Label", {
    z = 39,
    x = 472,
    y = 116,
    text = "L-R Test",
    font = "sans24",
    text_pos = "left",
    col_bg = "panel_bg",
    col_text = "panel_txt",
    shadow_text = false,
})

GUI.New("btn_LR_Start", "dh_Button", {
    z = 39,
    x = 528,
    y = 160,
    w = 64,
    h = 28,
    text = "START",
    font = "sans22",
    shadow_text = false,
    col_bg = "btn_face",
    col_outline = "btn_outline",
    col_text = "btn_txt",
    col_active = "elm_active",
    allow_sel_outline = false,
})




GUI.New("pnl_LR_Test", "dh_Panel", {
    z = 40,
    x = 384,
    y = 108,
    w = 240,
    h = 208,
    border_width = 2,
    radius = 4,
    shadow = false,
    caption = "",
    font_caption = "sans22",
    cap_pad_x = 4,
    cap_pad_y = 4,
    cap_centered = false,
    shadow_caption = false,
    text = {
        "",
    },
    font_text = "mono16",
    pad = 4,
    line_height = 1.25,
    use_pixels = false,
    line_height_pixels = 24,
    col_bg = "panel_bg",
    col_border = "panel_border",
    col_text = "panel_txt",
    col_cap_text = "panel_txt",
    col_backdrop = "wnd_bg",
})




GUI.New("btn_ProfileSave", "dh_Button", {
    z = 55,
    x = 184,
    y = 176,
    w = 78,
    h = 32,
    text = "Save",
    font = "sans24",
    shadow_text = false,
    col_bg = "btn_face",
    col_outline = "btn_outline",
    col_text = "btn_txt",
    col_active = "elm_active",
    allow_sel_outline = false,
})




GUI.New("btn_ProfileRename", "dh_Button", {
    z = 56,
    x = 304,
    y = 176,
    w = 78,
    h = 32,
    text = "Rename",
    font = "sans24",
    shadow_text = false,
    col_bg = "btn_face",
    col_outline = "btn_outline",
    col_text = "btn_txt",
    col_active = "elm_active",
    allow_sel_outline = false,
})

GUI.New("btn_ProfileDelete", "dh_Button", {
    z = 56,
    x = 424,
    y = 176,
    w = 78,
    h = 32,
    text = "Delete",
    font = "sans24",
    shadow_text = false,
    col_bg = "btn_face",
    col_outline = "btn_outline",
    col_text = "btn_txt",
    col_active = "elm_active",
    allow_sel_outline = false,
})




GUI.New("tbx_ProfileName", "dh_Textbox", {
    z = 57,
    x = 184,
    y = 112,
    w = 324,
    h = 32,
    font_text = "mono20",
    pad = 4,
    align_text = "left",
    undo_limit = 20,
    caption = "Profile Name",
    font_caption = "sans24",
    cap_pos = "left",
    cap_pad_x = 12,
    cap_pad_y = 0,
    cap_centered = false,
    shadow_caption = false,
    shadow = false,
    col_bg = "elm_bg",
    frame_use_outline = false,
    frame_thk = 2,
    col_frame = "elm_frame",
    col_text = "elm_txt",
    col_sel_text = "sel_txt",
    use_sel_alpha = nil,
    sel_alpha = 0.5,
    col_cap_text = "txt",
    allow_sel_outline = true,
    col_active = "elm_active",
    col_backdrop = "wnd_bg",
    retval = "Hello",
})




GUI.New("btn_CloseProfileEditor", "dh_Button", {
    z = 59,
    x = 552,
    y = 24,
    w = 72,
    h = 32,
    text = "Close",
    font = "sans24",
    shadow_text = false,
    col_bg = "btn_face",
    col_outline = "btn_outline",
    col_text = "btn_txt",
    col_active = "elm_active",
    allow_sel_outline = false,
})

GUI.New("lbl_ProfileEditor", "dh_Label", {
    z = 59,
    x = 24,
    y = 24,
    text = "Profile Editor:",
    font = "sans28",
    text_pos = "left",
    col_bg = "wnd_bg",
    col_text = "txt",
    shadow_text = false,
})




GUI.New("pnl_ProfileEditor", "dh_Panel", {
    z = 60,
    x = 0,
    y = 0,
    w = 640,
    h = 480,
    border_width = 2,
    radius = 0,
    shadow = false,
    caption = "pnl_ProfileEditor",
    font_caption = "sans22",
    cap_pad_x = 4,
    cap_pad_y = 4,
    cap_centered = false,
    shadow_caption = false,
    text = nil,
    font_text = "mono16",
    pad = 4,
    line_height = 1.25,
    use_pixels = false,
    line_height_pixels = 24,
    col_bg = "wnd_bg",
    col_border = "panel_border",
    col_text = "txt",
    col_cap_text = "txt",
    col_backdrop = "wnd_bg",
})



GB_Project_Layer_Sets = {
        {55,56,57,58,59,60,},
        {},
        {},
        {},
        {},
        {},
    }
GB_Project_Current_Layer_Set = 0