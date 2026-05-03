-- NoIndex: true

-- func_Menu.lua
-- Modified 20260330

------------------------------------
-------- Menu bar ------------------
------------------------------------

--local Export = require("func_Export")

local dhth = require "common/dh_Toolkit_themes"

local Menu = {}

-- The menu bar, just so this is easily accessible
-- Replaced by global MENUBAR_HEIGHT
Menu.h = 28

local scale_options = {}

for _, val in ipairs(DHTK.APP_SCALE_FACTORS) do
          
    table.insert(scale_options, {val, function() Menu.scale_GUI(val) end})      

end

local theme_options = {}

for _, val in ipairs(dhth.DH_THEME_NAMES) do
          
    table.insert(theme_options, {val, function() Menu.set_theme(val) end})      

end


--#### TEST ####
-- Used during development to test certain features, or gather data.
local function test()

    --[[
    local test_elm = GUI.table_copy(GUI.Textbox)

    for k,_ in pairs(test_elm) do
        if k == "keys" then
        GUI.Msg("test_elm prop : " .. k)
    end
    --]]
    --[[
    --GUI.Msg("test_elm GB_frm_bg.x  : " .. tostring(GUI.elms.GB_frm_bg.x))
    
    if GUI.elms.dh_Panel1 then
        GUI.elms.dh_Panel1.text = "Text 1,Text 2,Text 3,Text 4"
        GUI.elms.dh_Panel1: redraw()
    end
    --]]
    --[[
    if GUI.elms.dh_Tabs1 then
        --GUI.Msg(">>> dh_Tabs1 z : " .. GUI.elms.dh_Tabs1.z)
        --GUI.Msg(">>> dh_Tabs1 props_norm.z : " .. GUI.elms.dh_Tabs1.props_norm.z)
        --GUI.Msg(">>> dh_Button1 z : " .. GUI.elms.dh_Button1.z)
        --GUI.Msg(">>> dh_Button1 props_norm.z : " .. GUI.elms.dh_Button1.props_norm.z)
        GUI.elms.dh_Tabs1:update_sets()        
    end
    
    if Editor then
        GUI.Msg("    #Editor.elms_to_delete: " .. (tostring(#Editor.elms_to_delete) or "nil")) 
    end 
    --]]
    --[[   
    if GUI.elms.dh_Knob1 then
        --GUI.Msg("\ntest")
        GUI.elms.dh_Knob1.output = {"Okay", "1", "2", "Good", "4", "5", "6", "Better", "8", "9", "Awesome"}
        --GUI.Msg("    dh_Knob:drawvals : size of output is : " .. tostring(#GUI.elms.dh_Knob1.output))
    end 
    --]]
    --[[   
    for elm_name, _ in pairs(GUI.elms) do
        if string.match(elm_name, "GB_") then
            GUI.Msg("> " .. elm_name)
        end
    end
    --]]
    --[[  
    for elm_name, _ in pairs(GUI.elms) do
        if not string.match(elm_name, "GB_") then
            GUI.Msg("> " .. elm_name)
        end
    end  
    --]] 
    --[[    
    GUI.Msg("func_Menu z-layers : ")
    for k, elm in pairs(GUI.elms) do
        GUI.Msg("  z:  " .. tostring(elm.z) .. " : " .. k)
    end
    --]]
    
    --GUI.Msg(GUI.table_list({{0,"0"}, {6,"6"}, {12,"12"}}, 3))
    --[[
    GUI.elms.dh_TextEditor1.retval = {
        "This is a dh_TextEditor.",
        "This is some text.",
        "This is more text.",
        "This is even more text.",
        "This is a dh_TextEditor.",
        "This is some text.",
        "This is more text.",
        "This is even more text.",
        "This is a dh_TextEditor.",
        "This is some text.",
        "This is more text.",
        "This is even more text.",
        }
    --]]
    --[[    
    GUI.elms.dh_Panel1.text = {
        "This is some text.",
        "This is some text.",
        "This is some text.",
        "This is some text.",
        "This is some text.",
        "This is some text.",
        "This is some text.",
        "This is some text.",
        "This is some text.",
        "This is some text.",
        "This is some text."
    }
    --]]
    
end    


Menu.menu = {

    {title = "File", options = {
        {"New Project", function() Menu.new_project() end},
        {""},
           
        {"Save Project", function() Menu.save_project("project") end},    
        --{"Save Project - no defaults", function() Menu.save_project("skip_defaults") end},
        
        {"Save Elements", function() Menu.save_project("elements") end},
        --{"Save Elements - no defaults", function() Menu.save_project("elements_skip_defaults") end},        

        {"Save Template", function() Menu.save_project("template") end},
        {""}, 
                  
        --{"Load Project", function() Menu.load_project("project") end},
        --{"Load Elements", function() Menu.load_project("elements") end},        
        --{"Import Template", function() Menu.load_project("template") end},
        
        {"Load Project", function() Export.load_project_file("project") end},
        {"Load Elements", function() Export.load_project_file("elements") end},        
        {"Import Template", function() Export.load_project_file("template") end},
        
        --{"Test", test}  -- This works because function 'test' is declared earlier.
    }},

    {title = "Settings", options = {
        {"Project Settings", function() GUI.elms.GB_wnd_proj:open() end},
        {"Preferences", function() GUI.elms.GB_wnd_prefs:open() end},
    }},

    {title = "GUI_Scale", options = scale_options},
    
    {title = "Set_Theme", options = theme_options},
    
    {title = "Grid", options = {
        {"Toggle Grid Show", function() Menu.toggle_grid() end},
    }},
    
    {title = "Help", options = {
        --{"Instructions", function() Help.show_help_msg() end}
        {"Usage", function() GUI.elms.GB_wnd_help:open("usage_text") end},
        {"Defaults", function() GUI.elms.GB_wnd_help:open("defaults_text") end},
    }},    
    
}

--!!! Move to Export.load_project_file(load_type)
function Menu.load_project(load_type)

    if load_type == "import" then
    
        Export.load_type = "template"
        Export.load_project_file(false)
        
    elseif load_type == "project" then
        
        Export.load_type = "project"
        Export.load_project_file(false)
        
    elseif load_type == "elements" then
        
        Export.load_type = "elements"
        Export.load_project_file(true)
        
    end
    
end

-- Dialog params need to be set here before Dialog.open()
-- because Dialog may be used elsewhere.

function Menu.save_project(state)

    local params = {}
    params.title = "Save Project?"
   -- params.message = "  ../GUI Builder/projects/"
    params.show_inputs = true
    
    if (state == "project") then
        params.title = "Save Project?"
        params.message = "  .../projects/<name>_PROJ.lua"  
        params.input_text = Project.proj_settings.name
        
    --??? Should I get rid of this? Was useful for testing.
    --    But saves should include all properties in case defaults change.       
    elseif (state == "skip_defaults") then
        params.title = "Save Project?"
        params.message = "  .../projects/<name>_PROJ.lua"  
        params.input_text = Project.proj_settings.name .. "_PROJ_ND"
        
    elseif (state == "elements") then
        params.title = "Save Elements?"
        params.message = "  .../scripts/<name>_ELMS.lua"  
        params.input_text = Project.proj_settings.name
        
    --??? Should I get rid of this? Was useful for testing.
    --    But saves should include all properties in case defaults change.       
    elseif (state == "elements_skip_defaults") then
        params.title = "Save Elements?"
        params.message = "  .../projects/<name>_ELMS.lua"  
        params.input_text = Project.proj_settings.name .. "_ELMS_ND"
        
    elseif (state == "template") then
        
        -- Only save template if something is selected.
        if GUI.elms.GB_frm_sel_elm.elm then
            params.title = "Save Template?"
            --params.message = "  ../GUI Builder/projects/"  
            params.message = "  .../projects/<name>_TMPL.lua"  
            params.input_text = GUI.elms.GB_frm_sel_elm.elm
        else
            reaper.MB("No Element is Selected.!", "Whoops!", 0)
            return
        end

    end 
    
    params.func = Export.get_project_file
    params.params = nil
    params.save_state = state
        
    --GUI.Msg(" Menu.save_project; params.save_state : " .. state) 
    
    -- This will display dialog, but can't return anything useful.
    Dialog.open(params)

end

function Menu.toggle_grid()

    --GUI.Msg(" Menu.toggle_grid : ")
    Prefs.preferences.grid_show = not Prefs.preferences.grid_show
    GUI.elms.GB_frm_bg:init()
	GUI.redraw_z[0] = true

end

function Menu.new_project()

    ret = reaper.ShowMessageBox("Do you want to create a new project?\nCurrent project will not be saved.  ", "Warning!", 1)
    
    -- OK = 1, Cancel = 2
    if ret == 1 then
        goto cont
    elseif ret == 2 then
        return nil
    end
    
    ::cont::
    
    for elm_name, elm in pairs(GUI.elms) do
        if not string.match(elm_name, "GB_") then
            --GUI.Msg("> " .. elm_name)
            elm:delete()
        end
    end
    
    Project.proj_settings.name = "New project"
    
    Element.deselect_elm()   
    
end


function Menu.set_theme(theme_name)

    -- Cannot use DHTK.setTheme() unless I change for key, __ in pairs in it.
    -- Otherwise it basically does the following:
    
    -- This sets the theme GUI colors. 
    dhth.set_theme(dhth.DH_THEMES[theme_name], true)
    DHTK.window_settings.theme = theme_name
    
    -- This inits all the elms to use new theme colors. 
	for key, __ in pairs(GUI.elms) do
	
        -- Skip GUI Builder elements.
        --if not string.match(key, "GB_") then goto next end
        	
        GUI.elms[key]:init()
        GUI.elms[key]:redraw()
        
        ::next::        
    end   
     
    -- Done in for loop.
    --GUI.update_elms_list(true)
    --GUI.redraw_z[0] = true


end


function Menu.scale_GUI(scale_factor)
    
    -- This should scale everything except workspace size.
    -- That is overridden in main script.
    DHTK.scaleApp(scale_factor)
    
    -- Need to redraw the sidebar.
    
    if GUI.elms.GB_mnu_pages then GUI.elms.GB_mnu_pages:onmouseup() end

end


-- Moved to main script.
--GUI.New("GB_mnu_bar", "Menubar", 2, 0, 0, Menu.menu, nil, Menu.h)


return Menu