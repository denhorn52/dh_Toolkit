GB_Project_Settings = {
    name = "dh_Template",
    w = 640,
    h = 420,
    x = 0,
    y = 0,
    anchor = "mouse",
    corner = "C",
}

GB_Project_Elements_Names = {
    "dh_Button1",
    "dh_Tabs1",
    "dh_Button3",
    "dh_Button2",
    "dh_Checklist1",
}

GUI.New("dh_Tabs1", "dh_Tabs", {
    z = 1,
    x = 0,
    y = 0,
    tab_w = 64,
    tab_h = 28,
    fullwidth = false,
    limit_w = 640,
    optarray = {
        "Tab 1",
        "Tab 2",
        "Tab 3",
        "Prefs",
    },
    z_sets = {
        {2,},
        {4,},
        {7,},
        {2,},
    },
})




GUI.New("dh_Checklist1", "dh_Checklist", {
    z = 2,
    x = 64,
    y = 176,
    optarray = {
        "Option 1",
        "Option 2",
        "Option 3",
        "Option 4",
    },
    caption = "dh_Checklist1",
})




GUI.New("dh_Button2", "dh_Button", {
    z = 4,
    x = 256,
    y = 64,
})




GUI.New("dh_Button3", "dh_Button", {
    z = 7,
    x = 448,
    y = 64,
})




GUI.New("dh_Button1", "dh_Button", {
    z = 12,
    x = 64,
    y = 64,
})



