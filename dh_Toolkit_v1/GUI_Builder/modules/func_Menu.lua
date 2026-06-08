-- NoIndex: true

-- func_Menu.lua
-- Modified 20260506

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


-- ##  TEST  ## --
-- Used during development to test certain features, or gather data.
local function test()

    --[[     
    for elm_name, elm in pairs(GUI.elms) do
    
        if not string.match(elm_name, "GB_") then
            GUI.Msg("> " .. elm_name .. " : z : " .. elm.z)
        end
        
        --if string.match(elm_name, "GB_") then
        --    GUI.Msg("> " .. elm_name .. " : z : " .. elm.z)
        --end
        
    end
    
    for z, v in pairs(GUI.elms_hide) do
      if z < 75 then
          GUI.Msg("  GUI.elms_hide[ " .. z .. " ] : " .. tostring(v))
      end
    end
    
    for z, v in pairs(GB.HIDDEN_LAYERS) do
      if z < 75 then
          --if not GUI.elms_hide[v] then
          --    GUI.Msg("  if not GUI.elms_hide[ " .. z .. " ] : " .. tostring(v))
          --end
          GUI.Msg("  GB.HIDDEN_LAYERS[ " .. z .. " ] : " .. tostring(v))
      end
    end        
    --]]    
    

    
end    


Menu.menu = {

    {title = "File", options = {
        {"New Project", function() Menu.new_project() end},
        {""},
        {"Load Project", function() Export.load_project_file("project") end},
        {"Save Project", function() Menu.save_project("project") end},    
        --{"Save Project - no defaults", function() Menu.save_project("skip_defaults") end},        

        {""},           
        {"Load Elements", function() Export.load_project_file("elements") end},        
        {"Save Elements", function() Menu.save_project("elements") end},
        --{"Save Elements - no defaults", function() Menu.save_project("elements_skip_defaults") end},        
        {""},           
        {"Import Template", function() Export.load_project_file("template") end},        
        {"Save Template", function() Menu.save_project("template") end},

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
    
    {title = "LayerSets", options = {
        {"Layer Set 1", function() Menu.change_layer_sets(1) end},
        {"Layer Set 2", function() Menu.change_layer_sets(2) end},        
        {"Layer Set 3", function() Menu.change_layer_sets(3) end},        
        {"Layer Set 4", function() Menu.change_layer_sets(4) end},        
        {"Layer Set 5", function() Menu.change_layer_sets(5) end},        
        {"Layer Set 6", function() Menu.change_layer_sets(6) end},
        {"Open Editor", function() Menu.change_layer_sets(7) end},                
        {"Restore layers", function() Menu.change_layer_sets(8) end},                        
    }},
        
    {title = "Help", options = {
        --{"Instructions", function() Help.show_help_msg() end}
        {"Usage", function() GUI.elms.GB_wnd_help:open("usage_text") end},
        {"Defaults", function() GUI.elms.GB_wnd_help:open("defaults_text") end},
    }},    
    
}

function Menu.change_layer_sets(idx)

    --GUI.Msg(" #GB.LAYER_SETS : " .. #GB.LAYER_SETS)    
    GUI.Msg(" Menu.change_layer_sets; idx : " .. idx)
    --GUI.Msg(" #GB.LAYER_SETS[idx] : " .. #GB.LAYER_SETS[idx])
     
    -- Same item clicked - go no further.
    if idx == GB.CURRENT_LAYER_SET_INDEX then return end
    
    -- Deselect elm if onow on hidden layer.
    
    Element.deselect_elm()
    
          
 
    ---------------------    
    -- # Open editor .--
    ---------------------    
    if idx == 7 then
        Editor.open_editor("layer_sets")
        return    
    end

    ------------------------
    -- # Restore layers. --
    ------------------------
    if idx == 8 then
    
        -- # Already in restored state. Go no further.
        
        if GB.CURRENT_LAYER_SET_INDEX == 0 then
            return
        end
        
        --GUI.Msg("\n## RESTORE layers." .. "\n")

        -- # Set the layer visibility back to where it was.
        
        -- GB.LAYER_SETS has normal (design) z layers.
        -- GB.HIDDEN_LAYERS has z's that have been shifted up by 10.
        
        for i = 1, GUI.z_max do
            GUI.elms_hide[i] = GB.HIDDEN_LAYERS[i]
        end
                
        -- # Hide current layer set.
                   
        for _, z in ipairs(GB.LAYER_SETS[GB.CURRENT_LAYER_SET_INDEX]) do
            --GUI.Msg("  Restore layer z : " .. z)                
            GUI.elms_hide[z + 10] = true                       
        end
        
        GB.CURRENT_LAYER_SET_INDEX = 0
                         
        return
        
    end
    
    -------------------------
    -- # Apply layer set. --   
    -------------------------  
    
     --GUI.Msg("\n## APPLY layer set." .. "\n")          
       
    -- # Do nothing if empty layer_set.
    
    --GUI.Msg("\n## APPLY  size of set : " .. #GB.LAYER_SETS[idx] .."\n")    
    
    if (not GB.LAYER_SETS[idx]) or (#GB.LAYER_SETS[idx] == 0) then
        --GUI.Msg("    DO NOTHING.") 
        return 
    end
        
    -- GUI.elms_list is hash of elm_name = elm
    -- GUI.elms_hide is a hash of z = {elm_name, elm_name, ...}
    --   only used by GUI to signal if an elm 
    --   should be updated: GUI.elms_hide[i] == true.
    
    -- # Store the actual hidden layers whether they're GB or not.
    --   This will remain hidden on restore.
    --   Don't really need to set it to true, 
    --     but now I can access it by z.
 
    -- NOTE: At this point will have selected a new layer set.    
    -- Don't want to update GB.HIDDEN_LAYERS if coming from a different selection set.
    
    local hidden_layers    
    
    if GB.CURRENT_LAYER_SET_INDEX == 0 then
            
        hidden_layers = {}
        
        -- # Store layer visibility state.

        for i = 1, GUI.z_max do        
            if GUI.elms_hide[i] then
              
                hidden_layers[i] = true
                --table.insert(hidden_layers, i)
                --GUI.Msg("  hidden_layers z : " .. i)
                 
            end        
        end
        
        -- # Then hide all non GB elements.
        
        for elm_name, elm in pairs(GUI.elms) do
            if not string.match(elm_name, "GB_") then
                GUI.elms_hide[elm.z] = true
            end
        end        
        
    else
        -- #  Will save current state.
        hidden_layers = GB.HIDDEN_LAYERS
        
        -- # Hide current layer set layers. Need to shift the z's.
        
        for _, z in ipairs(GB.LAYER_SETS[GB.CURRENT_LAYER_SET_INDEX]) do
    
            GUI.elms_hide[z + 10] = true
            hidden_layers[z + 10] = true
    
        end
            
    end
    
    -- # Finally, show selected layer_set.
    -- GB.LAYER_SETS has normal (design) z layers.
    -- So shift up by 10.
    
    for _, z in ipairs(GB.LAYER_SETS[idx]) do

        --GUI.Msg("\n  Apply GB.LAYER_SETS[idx] z : " .. z)        
        GUI.elms_hide[z + 10] = false  
                  
    end     
    
    GB.HIDDEN_LAYERS = hidden_layers
    GB.LAYERS_TO_RESTORE = layers_to_restore
    GB.CURRENT_LAYER_SET_INDEX = idx
    
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