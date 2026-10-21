-- NoIndex: true

-- func_Menu.lua
-- Modified 20261009

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
        {"  Layer Set 1", function() Menu.change_layer_sets(1) end},
        {"  Layer Set 2", function() Menu.change_layer_sets(2) end},        
        {"  Layer Set 3", function() Menu.change_layer_sets(3) end},        
        {"  Layer Set 4", function() Menu.change_layer_sets(4) end},        
        {"  Layer Set 5", function() Menu.change_layer_sets(5) end},        
        {"  Layer Set 6", function() Menu.change_layer_sets(6) end},
        {"  Layer Set 7", function() Menu.change_layer_sets(7) end},
        {"  Layer Set 8", function() Menu.change_layer_sets(8) end},
        {""},
        {"  Hide common layers", function() Menu.change_layer_sets(10) end},  
        {"  Open Editor", function() Editor.open_editor("layer_sets") end}
   
    }},

    {title = "Help", options = {
        --{"Instructions", function() Help.show_help_msg() end}
        {"Usage", function() GUI.elms.GB_wnd_help:open("usage_text") end},
        {"Defaults", function() GUI.elms.GB_wnd_help:open("defaults_text") end},
        {"Show elms by z in console", function() Menu.show_elms_in_console('z') end},
        {"Show elms by name in console", function() Menu.show_elms_in_console('name') end}
    }},    
    
}

-- This gets called when loading file, 
-- on editor close,
-- menu selection.
-- @param: m_idx - LayerSets menu index.

function Menu.change_layer_sets(m_idx)

    if m_idx == 10 then
        --GUI.Msg("\n    before update GB.HIDE_COMMON_LAYERS : " .. tostring(GB.HIDE_COMMON_LAYERS))         
        GB.HIDE_COMMON_LAYERS = not GB.HIDE_COMMON_LAYERS
        --GUI.Msg("\n    after update GB.HIDE_COMMON_LAYERS : " .. tostring(GB.HIDE_COMMON_LAYERS))     
        local txt = (GB.HIDE_COMMON_LAYERS and "$ Hide common layers")
                  or "  Hide common layers"
                  
        GB.LAYER_SETS_MENU[m_idx][1] = txt
    
    end

    if m_idx and (m_idx < 9) then
        --GUI.Msg("\n    if m_idx and (m_idx < 9) : " .. tostring(m_idx))
        -- Toggle. 
        GB.ACTIVE_LAYER_SETS[m_idx] = not GB.ACTIVE_LAYER_SETS[m_idx]

        -- Transistion to show. (was false, now true)
        if GB.ACTIVE_LAYER_SETS[m_idx] == true then
            --GUI.Msg("\n    if GB.ACTIVE_LAYER_SETS[m_idx] == true : ")
            -- Show layers in selected layerset.
            for i, norm_z in ipairs(GB.LAYER_SETS[m_idx][2]) do
                GUI.elms_hide[norm_z + 10] = false
            end
            
            GB.LAYER_SETS_MENU[m_idx][1] = "$ " .. GB.LAYER_SETS[m_idx][1]
            return
        else    
            GB.LAYER_SETS_MENU[m_idx][1] = "  " .. GB.LAYER_SETS[m_idx][1]
        end
        
    end
    
    if not m_idx then
        
        -- # Update menu.
    
        for idx, active in ipairs(GB.ACTIVE_LAYER_SETS) do  
    
            local lyrset_name = (active and '$ ') or '  ' 
            lyrset_name = lyrset_name .. GB.LAYER_SETS[idx][1]
    
            GB.LAYER_SETS_MENU[idx][1] = lyrset_name
            --GUI.Msg("\n    Menu.change_layer_sets Update menu. : " .. lyrset_name) 
        end
    
    end
    
    -- # Hide/show all non GB common elements.
    --GUI.Msg("\n    Menu.change_layer_sets GB.HIDE_COMMON_LAYERS : " .. tostring(GB.HIDE_COMMON_LAYERS))     
    local hide = GB.HIDE_COMMON_LAYERS
    
    for elm_name, elm in pairs(GUI.elms) do
        if not string.match(elm_name, "GB_") then
            GUI.elms_hide[elm.z] = hide
        end
    end        
    
    -- Should have at least default GB.LAYER_SETS
    -- GB.LAYER_SETS holds design (non-shifted) z values
    -- layerset is { name, {...} }
    -- Remember to shift z's.

    -- Must first hide inactive layerset layers, 
    -- then show active layerset layers.
    
    -- # Hide inactive layerset layers.        
    for idx, active in ipairs(GB.ACTIVE_LAYER_SETS) do

        if not active then
            local zset = GB.LAYER_SETS[idx][2]
            --GUI.Msg("\n    if not active name: " .. GB.LAYER_SETS[idx][1])
            --GUI.Msg("\n    if not active #zset: " .. tostring(#zset))                     
            for _, norm_z in ipairs(zset) do
                GUI.elms_hide[norm_z + 10] = true
            end
        end
    
    end
    
    -- # Show active layerset layers.        
    for idx, active in ipairs(GB.ACTIVE_LAYER_SETS) do  
    
        if active then
            local zset = GB.LAYER_SETS[idx][2]
            for _, norm_z in ipairs(zset) do
                GUI.elms_hide[norm_z + 10] = false
            end
        end
        
    end

end

--zzz
-- GUI.elms_list is a table of existing layers.
-- Each table is a list of elms (not sorted?) in that layer.

function Menu.show_elms_in_console(sort_type)

    local str = "\n####  PROJECT ELEMENTS  ####\n"
    local z_elms = {}
   
    if sort_type == "z" then

        --GUI.Msg("\n\n>>> GUI.z_max : " .. GUI.z_max)
  
        for z = 1, GUI.z_max do
        
            z_elms = {}        
        
            if GUI.elms_list[z] and #GUI.elms_list[z] > 0 then
                --GUI.Msg("     z layer : " .. (z - 10)) 
                -- # Extract any project elms.
                for _, elm_name in pairs(GUI.elms_list[z]) do    
        
                    if not string.match(elm_name, "GB_") then  
                         table.insert(z_elms, elm_name)
                         --GUI.Msg("       elm_name : " .. elm_name)
                    end
                
                end

                if #z_elms > 0 then
                
                    -- z's get shifted down by 10.
                    str = str .. "\n# Layer: " .. tostring(z - 10) .. "\n"
                    table.sort(z_elms)
                
                    for _, name in ipairs(z_elms) do
                        str = str .. "   " .. name .. "\n"
                    end
                
                end
    
            end

        end  -- <for z = 1>
        
    elseif sort_type == "name" then

        for elm_name, elm in pairs(GUI.elms) do
        
            if not string.match(elm_name, "GB_") then  
                 local estr = elm_name .. "  [" .. elm.z - 10 .. "]"
            
                 table.insert(z_elms, estr)
            end

        end
        
        table.sort(z_elms)
        
        str = str .. "\n" .. table.concat(z_elms, "\n")

    end  -- <if sort_tpe>
    
    GUI.Msg(str)

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
--zzz    
    -- # Delete all project elms.
    
    for elm_name, elm in pairs(GUI.elms) do
        if not string.match(elm_name, "GB_") then
            --GUI.Msg("> " .. elm_name)
            elm:delete()
        end
    end
    
    -- # Set layer sets to default.
    
    GB.LAYER_SETS = {
      {"Layer Set 1", {} },
      {"Layer Set 2", {} },
      {"Layer Set 3", {} },
      {"Layer Set 4", {} },
      {"Layer Set 5", {} },
      {"Layer Set 6", {} },
      {"Layer Set 7", {} },
      {"Layer Set 8", {} },      
    }

    GB.ACTIVE_LAYER_SETS = {false,false,false,false,false,false}
    GB.HIDE_COMMON_LAYERS = false
    
    --[=[
    -- # Update menu.
         May need this in future if implementing
         menu to toggle layers.
    
    -- # Get reference to layer sets menu.
    local mls
    
    for i, mnu in ipairs(Menu.menu) do
        if Menu.menu.title == "LayerSets" then
            mls = mnu.options
            break
        end
    end    
    
    for idx, layer in ipairs(GB.LAYER_SETS) do
        mls[idx][1] = layer[1]        
    end
    --]=]      
    
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