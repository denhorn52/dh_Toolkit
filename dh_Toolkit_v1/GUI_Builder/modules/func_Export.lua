-- NoIndex: true

--func_Export.lua
-- Modified 20260506
----------------------------------------------
-------- File import / export functions -----
--------    for GUI Builder -----------------
----------------------------------------------
-- Functionality added by Dennis R. Horn to allow saving and reloading the project.

local Export = {}

--local Element = require("func_Elements")

-----------------------------------
---------    EXPORT   ----------
-----------------------------------
-- Click on menu item "Save Project" opens "Save Project" dialog.
-- Click on "Save Project" dialog confirm button calls Export.get_project_file().
-- If canceling save Dialog should remain open.
-- If file exists open "Overwrite" dialog.
-- If OK then save file. 

function Export.get_project_file()

    --GUI.Msg("# Export.get_project_file")
    
    -- First, get file name.
    
    local export_path = ""
    local suffix = ""
    
    if (Dialog.params.save_state == "project") then 
        export_path = GUI.script_path .. "projects" .. "/"        
        suffix = "_PROJ.lua"
    elseif (Dialog.params.save_state == "elements") then
        export_path = GUI.script_path .. Project.proj_settings.scripts_dir        
        suffix = "_ELMS.lua"
    elseif (Dialog.params.save_state == "template") then
        export_path = GUI.script_path .. "projects" .. "/"   
        suffix = "_TMPL.lua"
    end
        
--zzfilename
    local file_name = GUI.Val("GB_dlg_input1") .. suffix
    local file_path = export_path .. file_name
    
    -- Check if file exists. Prompt if so.
    
    Dialog.data = file_path
    
    if reaper.file_exists(file_path) then
        Dialog.stay_open = true
        Dialog.open_overwrite_dlg()
        return
    end
    
    Dialog.stay_open = false
    
    Export.save_file()

end


function Export.save_file()

    -- Build file.
    
    local saving_template = (Dialog.params.save_state == "template")
    
    -- Don't need proj settings for template.
    
    local settings, heading   
    
    if saving_template then
        settings = ""
        heading = "-- # GUI Builder Template file v1\n\n"
    else
        settings = Export.build_project_settings_str()
        heading = "-- # GUI Builder Project file v1\n\n"         
    end

    local elements, elms_names_str = Export.build_elements_str()
    
    -- settings is "" for template. Handled above.
    -- elms_names_str is different for template. Handled in build_elements_str.
    -- elements need to be inside function.
    
    local elements_str = ""
    
    if saving_template then
        elements_str = elements_str .. "GB_TEMPLATE_load_elm = function()\n\n"
    end
    
    -- Note: template will have only one element.
    
    elements_str = elements_str .. table.concat(elements, "\n")
    
    if saving_template then
        elements_str = elements_str .. "end\n"
    end
    
    local layer_sets_str = ""

    
    if not saving_template then
    
        str = 'GB_Project_Layer_Sets = {'
        
        for i, zset in ipairs(GB.LAYER_SETS) do
            --str = str .. '\n        [' .. tostring(i) .. '] = {'
            str = str .. '\n        {'                             
            for _, z in ipairs(zset) do   
                str = str .. tostring(z) .. ','
            end
            str = str .. '},'                             
            
        end
             
        str = str .. '\n    }\n'   
--zzz
        -- Always start with no selected sets.         
        --str = str .. 'GB_Project_Current_Layer_Set = ' .. tostring(GB.CURRENT_LAYER_SET_INDEX)
        str = str .. 'GB_Project_Current_Layer_Set = ' .. tostring(GB.CURRENT_LAYER_SET_INDEX)         

        layer_sets_str = str
    
    end    
    
    local content = heading .. settings .. elms_names_str .. elements_str .. layer_sets_str
    
    --GUI.Msg(content)
    
    local file, err = io.open(Dialog.data, "w")
    
    if not file then
        reaper.MB("Could't open file to write:\n" .. tostring(err), "Oops!", 0)
        return
    end
    
    file:write(content)    
    file:close()

end


function Export.build_project_settings_str()

    --GUI.Msg("# Export.build_project_settings_str")

    local ps = Project.proj_settings
    local ps_name = ps.name

    --!!! Modify the project name appendage.
    --!!! Can eliminate if no longer using any of these.
    --??? Shouldn't append to project settings name
    
    local str = "GB_Project_Settings = {\n"

    str = str .. '    name = "' .. ps_name .. '",\n'
    str = str .. '    w = ' .. ps.w .. ',\n'
    str = str .. '    h = ' .. ps.h .. ',\n'
    str = str .. '    x = ' .. ps.x .. ',\n'
    str = str .. '    y = ' .. ps.y .. ',\n'
    str = str .. '    anchor = "' .. ps.anchor .. '",\n'
    str = str .. '    corner = "' .. ps.corner .. '",\n'
    str = str .. "}\n\n"
    
    return str

end

-- Get a list of user elements and generate 'GUI.New(...' strings for them.
-- Can't use Element.get_elm_params because I need to
--   use values from elm.props_norm and format differently.
-- This is very much same as code in tab_Properties recreate_elm(),
--   and func_Elements get_elm_params() and format_property_to_code().

function Export.build_elements_str()

    local elms_strs = {}
    local params, strs
    
    local elms_names_str
    
    if (Dialog.params.save_state == "template") then
        elms_names_str = 'GB_TEMPLATE_element_name = '
    else
        elms_names_str = 'GB_Project_Elements_Names = {\n'
    end    


    ----  SELECTED ELEMENT ONLY  ----  
    
    --GUI.Msg("## EXPORT: Dialog.params.save_state : " .. (Dialog.params.save_state or "nil"))

    if ((Dialog.params.save_state == "template") or 
        (Dialog.params.save_state == "selected") or 
        (Dialog.params.save_state == "sel_skip_defaults")) then
    
        -- Get selected elm. func_Menu should have checked if an element is selected.
        -- Menus set params.input_text = GUI.elms.GB_frm_sel_elm.elm
        -- Here I'm only concerned with the textbox value.
    
        local elm = GUI.elms[GUI.elms.GB_frm_sel_elm.elm]
        --GUI.Msg(" sel_elm : " .. (elm and elm_name or "none"))
        
        -- Will correspond to file name.
        elms_names_str = elms_names_str .. '"' .. GUI.Val("GB_dlg_input1") .. '"\n\n'        
        
        local str = Export.build_elm_str(elm)
        
        --GUI.Msg("\n  build_elements_str : \n" .. str)
        
        --!!! NOT NECESSARY for selected only.

        -- Store strings separately by z so we can sort them.
        
        if not elms_strs[elm.z] then elms_strs[elm.z] = {} end
        table.insert(elms_strs[elm.z], str)        
                   
        goto finish_up
        
    end
    
    ----  ALL ELEMENTS  ----

    for elm_name, elm in pairs(GUI.elms) do
    
        -- Skip GB elms.
        if string.match(elm_name, "GB_") then goto skip_GB end
        
        --GUI.Msg(" loop : " .. elm_name)            

        --table.insert(elms_names, elm_name)
        
        elms_names_str = elms_names_str .. '    "' .. elm_name .. '",\n'

        -- Get elm params and build element string.

        local str = Export.build_elm_str(elm)

        -- Store strings separately by z so we can sort them.
        
        if not elms_strs[elm.z] then elms_strs[elm.z] = {} end
        table.insert(elms_strs[elm.z], str)
 
        ::skip_GB::

    end
    
    
    
    
    ::finish_up::
    
    if (Dialog.params.save_state ~= "template") then
        elms_names_str = elms_names_str .. '}\n\n'
    end     
    
   return Export.sort_elm_strs(elms_strs), elms_names_str

end

-- Can get most property values directly from the element.
-- Number values are retrieved from props_norm because some element values nay be scaled.
-- z must be retrieved from props_norm.

function Export.build_elm_str(elm)

    local params = elm.GB.properties

    local strs = {}

    local started
    local valstr
    
    for i = 1, #params do
        if params[i].prop == "z" then
            started = true
        end
        
        if started and params[i].prop then
        
            -- Do not skip if Lokasenna element.
            --if ((Dialog.params.save_state == "skip_defaults") or (Dialog.params.save_state == "sel_skip_defaults")) 
            if string.match(Dialog.params.save_state,"skip_defaults" )
                and string.find(elm.type, "dh_")
                and (elm.props_norm[params[i].prop] == GUI[elm.type].defaults[params[i].prop])                
                
            then
                --GUI.Msg(" skipped default ")                
                --GUI.Msg(" > " .. params[i].prop)
                --GUI.Msg("    props.norm     : " .. tostring(elm.props_norm[params[i].prop]))
                --GUI.Msg("    prop. defaults : " .. tostring(elm.prop_defaults[params[i].prop]))
                goto skipped_default
            end
                   
            local pname = params[i].prop
            local ptype = type(elm[params[i].prop])

            --GUI.Msg("  elm name : " .. elm.name)
            --GUI.Msg("  elm z : " .. elm.z)
            --GUI.Msg("  param name : " .. pname)
            --GUI.Msg("  param type : " .. ptype)
            --GUI.Msg("  props_val  : " .. tostring(elm[pname]))                                
            --GUI.Msg("  props_norm : " .. tostring(elm.props_norm[pname]))
                
            if pname == "z" then
                --GUI.Msg("  elm name : " .. elm.name)
                --GUI.Msg("  elm z : " .. elm.z)
                --GUI.Msg("  props_norm : " .. elm.props_norm[pname])
                valstr = tostring(elm.props_norm[pname])            
            
            elseif pname == "z_sets" then
                valstr = Export.table2str(elm.props_norm[pname], elm.type, pname)                

            elseif ptype == "string" then
                --valstr = '"' .. elm.props_norm[pname] .. '"'
                valstr = '"' .. elm[pname] .. '"'
                
            elseif ptype == "table" then
                valstr = Export.table2str(elm[pname], elm.type, pname)
                
            elseif ptype == "function" then
                goto next_param
                
            elseif ptype == "boolean" then
                valstr = tostring(elm[pname])
                
            else  -- numbers 
                valstr = tostring(elm.props_norm[pname])
                
            end
            
            strs[#strs+1] = "    " .. pname .. " = " .. valstr .. ","
            
        end
        
        ::skipped_default::
        ::next_param::
    end
    
    -- Add extra params.
    -- These are not part of Property.properties.
    
    if (elm.type == "dh_Textbox") then
        valstr = elm.retval or ""
        strs[#strs+1] = '    retval = "' .. valstr .. '",'
    end
    
    if (elm.type == "dh_TextEditor") then
        valstr = Export.table2str(elm.retval, elm.type)
        strs[#strs+1] = '    retval = ' .. valstr .. ','
    end
    
    local str
    
    if (Dialog.params.save_state == "template") then
        str = 'GUI.New(GB_TEMPLATE_element_name' .. ', "' .. elm.type .. '", {\n'    
    else
        str = 'GUI.New("' .. elm.name .. '", "' .. elm.type .. '", {\n'
    end

    str = str .. table.concat(strs, '\n') .. '\n})\n'

    return str

end


-- Most tables are one dimensional lists.
-- Menubar menus are mixed tables which are several levels deep
-- Menubox optarray may have multi-dimensional tables.
-- For now just export top level.

function Export.table2str(tbl, elm_type, prop_name)

    local str = "{"     
    
    if elm_type == "dh_Menubar" or elm_type == "Menubar" then
        -- {title = "Menu 1", options = {}},
        str = str .. '\n'
        for _, item in ipairs(tbl) do
            str = str .. '        {title = "' .. item.title .. '", options = {}},\n'
        end
        str = str .. '    }'
    
    elseif elm_type == "dh_Menubox" or elm_type == "Menubox" then
        --for _, item in ipairs(tbl) do
        --    str = str .. '        {title = "' .. item.title .. '", options = {}}\n'
        --end
        --!!! temp
        str = '{"Option 1", "Option 2" , "Option 3", "Option 4"}'
        
    elseif prop_name == "min_max_values" then
        str = str .. '\n'    
        for _, item in ipairs(tbl) do
            str = str .. '        {' .. tostring(item[1]) .. ',"' .. tostring(item[2]) .. '"},\n'        
        end 
        str = str .. '    }'
         
    elseif prop_name == "hard_ticks" 
        or prop_name == "default_tickmarks"
        or prop_name == "default"
        or prop_name == "defaults"        
    then
        for _, item in ipairs(tbl) do
                str = str .. item .. ', '            
        end    
        str = str .. '}'
        
    elseif prop_name == "z_sets" then
        str = '{'
        for i, zset in ipairs(tbl) do
            --str = str .. '\n        [' .. tostring(i) .. '] = {'
            str = str .. '\n        {'                             
            for _, z in ipairs(zset) do   
                str = str .. tostring(z) .. ','
            end
            str = str .. '},'                             
            
        end     
        str = str .. '\n    }'
                             
    else
        str = str .. '\n'        
        for _, item in ipairs(tbl) do
            str = str .. '        "' .. item .. '",\n'            
        end
        str = str .. '    }' 
    end
    
    return str
    
end

-- Maybe future use.
function Export.export_elements()

    local header = "-- GUI_Builder exported GUI elements : " .. Project.proj_settings.name .. "\n\n"
    local elms, _ = Export.build_elms_str()
    
    --reaper.ClearConsole()
    --GUI.Msg("size of elms : " .. tostring(#elms))
    local content = header .. table.concat(elms, "\n")
    
    --GUI.Msg(content)
    Export.save_file(content, "_ELMS", "lua")

end

-----------------------------------
---------    IMPORT   ----------
-----------------------------------
--zzsave
-- Called from main menu.

function Export.load_project_file(load_type)

    --GUI.Msg("# Export.load_project_file load type : " .. load_type .. "\n")
    
    Export.load_type = load_type

    local use_script_dir

    if load_type == "project" then
        use_script_dir = false
    elseif load_type == "elements" then
        use_script_dir = true
    elseif load_type == "template" then
        use_script_dir = false
    end

    --GUI.Msg("GUI.script_path: " .. GUI.script_path .. "\n")

    local menu_str = ""
    local i = 0 
    local filelist = {}

    local dir_path
        
    if use_script_dir then
        --dir_path = GUI.script_path .. ".." .. package.config:sub(1,1) .. "scripts" .. package.config:sub(1,1)
        --dir_path = GUI.script_path .. "../" .. "scripts/" 
        dir_path = GUI.script_path .. Project.proj_settings.scripts_dir                
    else
        dir_path = GUI.script_path .. "projects/"        
    end
    
    reaper.EnumerateFiles(dir_path,-1) -- Rescan 
     
    while reaper.EnumerateFiles(dir_path,i) do 
        local filename = reaper.EnumerateFiles(dir_path,i) 
        
        if (load_type == "project") and not string.match(filename, "_PROJ") then
            goto next 
        
        elseif (Export.load_type == "elements") and not string.match(filename, "_ELMS") then
            goto next 
        
        elseif (Export.load_type == "template") and not string.match(filename, "_TMPL") then
            goto next 
        end
        
        table.insert(filelist,filename)

        ::next::
         
        i = i + 1 
    end 
    
    -- Build list for gfx.showmenu --
    
    if #filelist > 0 then
        for i, filename in ipairs(filelist) do
        
            menu_str = menu_str .. filename
            if i < #filelist then 
                menu_str = menu_str .. "|"
            end

        end
    else
        reaper.MB("No Project files found!", "Oops!", 0)
        return
    end
    
    gfx.x, gfx.y = 4, MENUBAR_HEIGHT + 4
    
    local file_num = gfx.showmenu(menu_str)
    
    local filename = filelist[file_num]

    local file_path
    
    if filename then
        file_path = dir_path .. filename
    else
        return
    end

    local file, err = io.open(file_path, "r")
    if not file then
        reaper.MB("Could't open file to read:\n" .. tostring(err), "Oops!", 0)
        return
    end
    
    local content = file:read("*a")
    file:close()
    
    Export.load_project(content)
    
end  --< Export.load_project_file >

-----------------------------------
--------  LOAD PROJECT  --------
-----------------------------------

function Export.load_project(content)

  xpcall(function()
  
    --GUI.Msg("\n## Export.load_project")
    --GUI.Msg("< loaded content: > \n" .. content .. "\n")
    
    Element.deselect_elm()
    
    -- Loading template. Check for unique name. 
  
    if Export.load_type == "template" then
        
        --GUI.Msg(">>> Export.load_type : " .. Export.load_type)  
        
        load(content)()
        
        if GB_TEMPLATE_element_name ~= nil then
        
            --GUI.Msg("    GB_TEMPLATE_element_name : " .. (GB_TEMPLATE_element_name or "nil"))
            
            -- Check if elm name exists
            local i = 1
            local new_name = GB_TEMPLATE_element_name
            
            while GUI.elms[new_name] do
                new_name = GB_TEMPLATE_element_name .. "_" .. tostring(i)
                i = i + 1
            end
            
            GB_TEMPLATE_element_name = new_name
            
            --GUI.Msg("    GB_TEMPLATE_element_name new_name : " .. (GB_TEMPLATE_element_name or "nil"))            
        else
            reaper.MB("Could't import template!\n", "Oops!", 0)           
            return 
        end

        GB_TEMPLATE_load_elm()
        
    else

        -- Delete previous project elements.

        -- This clears property elms, but 
        -- GUI.elms_list doesn't get updated until next GUI.Update,

        --!!! Don't delete GB elements.

        for elm_name, elm in pairs(GUI.elms) do
            if not string.match(elm_name, "GB_") then
                elm:delete()
            end
        end
        
        -- Load all elms and init them.

        load(content)()    
    
    end
    
    -- Imported elms have normalized (1x) values.
    
    local element_names = GB_Project_Elements_Names or {GB_TEMPLATE_element_name} or {}
    
    if element_names then    

        for _, elm_name in ipairs(element_names) do        
        
            --GUI.Msg("        imported elm name : " .. elm_name)        
    
            local elm = GUI.elms[elm_name]
          
            local proj_x, proj_y = elm.x, elm.y
            
            elm.y = elm.y + MENUBAR_HEIGHT
            
            -- !!! Special case for dh_Knob centered.
            -- Creating elm puts elm.x, elm.y to top left.
            -- Readjust them to center for later calcs.

            if elm.type == "dh_Knob" and elm.centered then
                -- Add radius.
                proj_x = proj_x + math.floor((elm.w + 0.5) / 2)
                proj_y = proj_y + math.floor((elm.w + 0.5) / 2)

                --GUI.Msg("        elm x : " .. elm.x)            
                --GUI.Msg("        elm y : " .. elm.y)
                --GUI.Msg("        proj_x : " .. proj_x)            
                --GUI.Msg("        proj_y : " .. proj_y)    

            end
            
            -- Imported elements need to be on layer 1.
            if Export.load_type == "template" then
                elm.z = 1
            end
                                             
            --if elm.type == "dh_Tabs" then
            --    GUI.Msg("    loading  -> calling store_elm_defaults")
            --end
                        
            Element.store_elm_defaults(elm, proj_x, proj_y)
    
            if DHTK.APP_SCALE ~= 1.00 then 
                DHTK.scale_elm(elm)
                GUI.elms[elm_name]: init()
            end
            
            Element.add_GB_methods(elm)
    
        end
        
        -- Need to draw even hidden elms in case using tabs or layer sets.
    	for key, __ in pairs(GUI.elms) do
            --GUI.elms[key]:init()
            GUI.elms[key]:redraw()
        end        
    
    end

    -- Select element if imported template.
    if Export.load_type == "template" then
        Element.select_elm(GUI.elms[GB_TEMPLATE_element_name])
    end

    
    -- # Get the layer sets.
    
    if GB_Project_Layer_Sets then

        GB.LAYER_SETS = GB_Project_Layer_Sets
        
        --GUI.Msg("    GB.LAYER_SETS = GB_Project_Layer_Sets ")
        --GUI.Msg("    #GB.LAYER_SETS : " ..  #GB.LAYER_SETS)
        
        -- Hide all layer set layers.
        -- Remember to shift z's.
        
        --GUI.Msg("    ITERATE GB.LAYER_SETS ")
    
        for i, zset in ipairs(GB.LAYER_SETS) do
        
            --GUI.Msg("    INDEX of zset : " .. i)
            --GUI.Msg("    SIZE of zset  : " .. #zset) 
        
            if #zset > 0 then
            
                --GUI.Msg("     zset value : " .. )
            
                for j, z in ipairs(zset) do
                
                    --GUI.Msg("      zset value : " .. z)                
                
                    GUI.elms_hide[z + 10] = true
                    
                end
            end
        end
        
    else
        --GUI.Msg("    GB.LAYER_SETS = empty ")        
        GB.LAYER_SETS = {{},{},{},{},{},{},{},}
    end
    
    -- # Get current layer set index,
--zzz
    --[=[    
    if GB_Project_Current_Layer_Set then
    
        -- Always start with default: no selected sets.
        GB.CURRENT_LAYER_SET_INDEX = GB_Project_Current_Layer_Set
        
        --GUI.Msg("    GB.CURRENT_LAYER_SET_INDEX : " ..  GB.CURRENT_LAYER_SET_INDEX)
    end
    --]=]
    
    -- # Then update if necessary.
    
    if GB.CURRENT_LAYER_SET_INDEX > 0 then        
        Menu.change_layer_sets(GB.CURRENT_LAYER_SET_INDEX)
    end
        
    -- No longer need these.
    GB_Project_Elements_Names = nil
    GB_Project_Layer_Sets = nil
    GB_Project_Current_Layer_Set = nil
    GB_TEMPLATE_element_name = nil
    GB_TEMPLATE_load_elm = nil
    
    if GB_Project_Settings then
        Project.populate_settings(GB_Project_Settings)
        Project.load_settings(GB_Project_Settings)        
        GB_Project_Settings = nil
    end
    
    Project.update_wnd_size("import")
    

  end, Export.import_error_handler)
  
end  --< Export.load_project >


function Export.import_error_handler()
  reaper.ShowMessageBox("Error occurred importing project!\nProject file may be corrupted.", "Notice!", 0)
end

-- Sort the list of elements by z
function Export.sort_elm_strs(elm_strs)

    local z_max = 0
    for k in pairs(elm_strs) do
        if k > z_max then z_max = k end
    end

    local sorted = {}
    for i = 1, z_max do

        if elm_strs[i] then

            for j = 1, #elm_strs[i] do

                sorted[#sorted + 1] = elm_strs[i][j]

            end

            sorted[#sorted + 1] = "\n\n"

        end

    end

    return sorted

end

return Export