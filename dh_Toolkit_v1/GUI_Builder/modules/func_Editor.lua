-- NoIndex: true

--[===[
func_Editor.lua
Modified 20260330

The Editor consists of several elements housed on layers 494 and 495.
Editor specific elements are created when Editor is "opened".
Then layers 494 and 495 are moved to layers 1 and 2 to be displayed.



]===]

-- Needs to be declared as global (not local)) otherwise it breaks.
Editor = {}

Editor.data = {}

-----------------------------------------------
--      # Basic editor elements
-----------------------------------------------
-- These don't need scaling because they are loaded before GUI.init()

Editor.load_editor_elms = function()

    --GUI.Msg("Editor.load_editor_elms")
    
    GUI.New("GB_editor_pnl", "dh_Panel", {
        z = 495,
        x = 0, 
        y = MENUBAR_HEIGHT, 
        w = WORKSPACE_WIDTH,  --DHTK.APP_WIDTH, 
        h = WORKSPACE_HEIGHT,
        border_width = 4, 
        radius = 0, 
        col_border = "panel_border",	
        col_bg = "wnd_bg",
        col_text = "txt",
        --pad = 8,  -- from inside border?
    })
    
    GUI.New("GB_editor_sidebar_pnl", "dh_Panel", {
        z = 495,
        x = WORKSPACE_WIDTH, 
        y = MENUBAR_HEIGHT, 
        w = SIDEBAR_WIDTH, 
        h = WORKSPACE_HEIGHT,
        border_width = 0, 
        radius = 0, 
        col_border = "panel_border",	
        col_bg = "shadow",
        col_text = "txt",
        --pad = 8,  -- from inside border?
    })
    
    GUI.New("GB_editor_type_lbl", "dh_Label", {
        z = 494,
        x = 16, 
        y = MENUBAR_HEIGHT + 12, 
        text = "Editor",    
        font = "sans28",
        col_bg = "wnd_bg",
        col_text = "txt",    
    })
    
    GUI.New("GB_editor_info_lbl", "dh_Label", {
        z = 494,
        x = 28, 
        y = MENUBAR_HEIGHT + 48, 
        text = "Editor",    
        font = "sans28",
        col_bg = "wnd_bg",
        col_text = "txt",    
    })
    
    GUI.New("GB_editor_close_btn", "dh_Button", {
        z = 494,
        x = WORKSPACE_WIDTH - 48, 
        y = MENUBAR_HEIGHT + 12, 
        w = 36, 
        h = 36, 
        text = "X",
        font = "mono24",
        func = Editor.close_editor,
    })
    
    GUI.New("GB_editor_save_btn", "dh_Button", {
        z = 494,
        x = WORKSPACE_WIDTH - (48 + 80), 
        y = MENUBAR_HEIGHT + 12, 
        w = 64, 
        h = 36, 
        text = "Save",
        font = "sans24",
        func = Editor.save_editor,
    })
    
    
    GUI.elms_hide[494] = true
    GUI.elms_hide[495] = true

end  --<load_editor_elms>

-----------------------------------------------
--      #  Close Editor
-----------------------------------------------

Editor.close_editor = function()

    -- # Update GUI

    --GUI.Msg("    #Editor.elms_to_delete: " .. (tostring(#Editor.elms_to_delete) or "nil")) 
    --GUI.Msg("    type of Editor.elms_to_delete : " .. type(Editor.elms_to_delete) )
    
    for _, elm_name in ipairs(Editor.elms_to_delete) do
        --GUI.Msg("    elms_to_delete : " .. elm_name )
        GUI.elms[elm_name]:delete()
    end
    
    GUI.elms.GB_editor_pnl.z = 495
    GUI.elms.GB_editor_sidebar_pnl.z = 495    
    GUI.elms.GB_editor_type_lbl.z = 494
    GUI.elms.GB_editor_info_lbl.z = 494    
    GUI.elms.GB_editor_save_btn.z = 494
    GUI.elms.GB_editor_close_btn.z = 494
    GUI.elms_hide[495] = true
    GUI.elms_hide[494] = true
    --GUI.redraw_z[2] = true
    --GUI.redraw_z[1] = true
    GUI.redraw_z[0] = true        

end


-----------------------------------------------
--        # Open Editor
-----------------------------------------------
--zzopen

-- Editor operates on a copy of data. GUI is updated on "Save".
-- Ant elements created here need to be adjusted according to app scale.



Editor.open_editor = function(editor_type)

    --GUI.Msg("\n# Editor.open_editor -> editor_type : " .. editor_type)
    --GUI.Msg("     editor_type type : " .. type(editor_type) )   
    
    Editor.type = editor_type
    Editor.elms_to_delete = {}

   -----------------------------
   ---- # Menu Titles  open ---- 
   -----------------------------
    
    if editor_type == "menu_titles" then
    
        --GUI.Msg("\n# Editor.open_editor -> editor_type : " .. editor_type)    
    
        GUI.elms.GB_editor_type_lbl.text = "Menu Titles Editor"
        GUI.elms.GB_editor_type_lbl:init()
        GUI.elms.GB_editor_info_lbl.x = 28 * DHTK.APP_SCALE
        GUI.elms.GB_editor_info_lbl.y = (MENUBAR_HEIGHT + 64) * DHTK.APP_SCALE        
        GUI.elms.GB_editor_info_lbl.text = "Enter names separated by commas."
        GUI.elms.GB_editor_info_lbl:init()        
        
        -- # Get reference to selected element.
        
        local sel_elm = GUI.elms[GUI.elms.GB_frm_sel_elm.elm]
        
        GUI.New("GB_editor_menu_titles_tbx", "dh_Textbox", {
            z = 1,
            x = 24 * DHTK.APP_SCALE, 
            y = (MENUBAR_HEIGHT + 96) * DHTK.APP_SCALE, 
            w = (WORKSPACE_WIDTH - (24 + 24)) * DHTK.APP_SCALE, 
            h = 36 * DHTK.APP_SCALE,
            caption = "",
            cap_pos = "left",
            font_caption = "sans24",                 
            font_text = "mono18",   --textbox needs mono font
            col_text = "elm_txt",
            col_sel_text = "sel_txt",
            col_backdrop = "wnd_bg",        
        })
--zzz open        
        table.insert(Editor.elms_to_delete, "GB_editor_menu_titles_tbx")                
            
        -- Get titles. Convert to string for tbx display.
        
        local titles = {}
        
        for i = 1, #sel_elm.menus do
            titles[i] = sel_elm.menus[i].title
        end
        
        GUI.elms.GB_editor_menu_titles_tbx.retval = table.concat(titles, ",")        
    
    end 

   -------------------------------
   ---- # Min-Max values open ---- 
   -------------------------------

    if editor_type == "min_max_values" then
    
        --GUI.Msg("\n# Editor.min_max_values_editor -> editor_type : " .. editor_type)    
    
        GUI.elms.GB_editor_type_lbl.text = "Min-Max Values Editor"
        GUI.elms.GB_editor_type_lbl:init()
        GUI.elms.GB_editor_info_lbl.x = 28 * DHTK.APP_SCALE
        GUI.elms.GB_editor_info_lbl.y = (MENUBAR_HEIGHT + 140) * DHTK.APP_SCALE        
        GUI.elms.GB_editor_info_lbl.text = "step : step position <integer>\n" ..
                                           "value : alphanumeric <string>\n" ..
                                           "Enter step value separated with comma\n" ..
                                           "Separate step value pairs with semicolons"
        GUI.elms.GB_editor_info_lbl:init()        
        
        -- # Get reference to selected element.
        
        local sel_elm = GUI.elms[GUI.elms.GB_frm_sel_elm.elm]
        
        GUI.New("GB_editor_min_max_tbx", "dh_Textbox", {
            z = 1,
            x = 24 * DHTK.APP_SCALE, 
            y = (MENUBAR_HEIGHT + 88) * DHTK.APP_SCALE,  
            w = (WORKSPACE_WIDTH - (24 + 24))  * DHTK.APP_SCALE, 
            h = 36 * DHTK.APP_SCALE,
            caption = "",
            cap_pos = "left",
            font_caption = "sans24",                 
            font_text = "mono18",   --textbox needs mono font
            col_text = "elm_txt",
            col_sel_text = "sel_txt",
            col_backdrop = "wnd_bg",        
        })
        
        table.insert(Editor.elms_to_delete, "GB_editor_min_max_tbx")                
               
        -- Get min_max values. Convert to string for tbx display.
        
        local valstr = ""
        
        for i, item in ipairs(sel_elm.min_max_values) do
        
            valstr = valstr .. tostring(item[1]) .. "," .. item[2] 
        
            if i < #sel_elm.min_max_values then
            
                valstr = valstr .. ";"
            
            end
        
        
        end
        
        GUI.elms.GB_editor_min_max_tbx.retval = valstr        
    
    end

   -------------------------------
   ---- # Options Editor open ---- 
   -------------------------------
    
    if editor_type == "options" then
    
        --GUI.Msg("\n# Editor.open_editor -> editor_type : " .. editor_type)    
    
        GUI.elms.GB_editor_type_lbl.text = "Options Editor"
        GUI.elms.GB_editor_type_lbl:init()
        GUI.elms.GB_editor_info_lbl.x = 28 * DHTK.APP_SCALE
        GUI.elms.GB_editor_info_lbl.y = (MENUBAR_HEIGHT + 64) * DHTK.APP_SCALE        
        GUI.elms.GB_editor_info_lbl.text = "Enter names separated by commas."
        GUI.elms.GB_editor_info_lbl:init()        
        
        -- # Get reference to selected element.
        
        local sel_elm = GUI.elms[GUI.elms.GB_frm_sel_elm.elm]
        
        GUI.New("GB_editor_options_tbx", "dh_Textbox", {
            z = 1,
            x = 24 * DHTK.APP_SCALE, 
            y = (MENUBAR_HEIGHT + 96) * DHTK.APP_SCALE, 
            w = (WORKSPACE_WIDTH - (24 + 24)) * DHTK.APP_SCALE, 
            h = 36 * DHTK.APP_SCALE,
            caption = "",
            cap_pos = "left",
            font_caption = "sans24",                 
            font_text = "mono18",   --textbox needs mono font
            col_text = "elm_txt",
            col_sel_text = "sel_txt",
            col_backdrop = "wnd_bg",        
        })
        
        table.insert(Editor.elms_to_delete, "GB_editor_options_tbx")                
            
        -- Get options.  Convert to string for tbx display.
        
        GUI.elms.GB_editor_options_tbx.retval = table.concat(sel_elm.optarray, ",")        
    
    end   
     
    -----------------------------
    ---- #  Tab Titles open  ---- 
    -----------------------------
    
    if editor_type == "tab_titles" then
    
        GUI.elms.GB_editor_type_lbl.text = "Tab Titles Editor"
        GUI.elms.GB_editor_type_lbl:init()
        GUI.elms.GB_editor_info_lbl.x = 28 * DHTK.APP_SCALE
        GUI.elms.GB_editor_info_lbl.y = (MENUBAR_HEIGHT + 48) * DHTK.APP_SCALE                       
        GUI.elms.GB_editor_info_lbl.text = ""
        GUI.elms.GB_editor_info_lbl:init()        
        
        -- # Get reference to selected element (will be tabs element).
        
        local sel_elm = GUI.elms[GUI.elms.GB_frm_sel_elm.elm]
        
        -- titles textbox
        GUI.New("GB_editor_titles_tbx", "dh_Textbox", {
            z = 1,
            x = 24, 
            y = (MENUBAR_HEIGHT + 76)  * DHTK.APP_SCALE, 
            w = (WORKSPACE_WIDTH - 48) * DHTK.APP_SCALE, 
            h = 36 * DHTK.APP_SCALE,
            caption = "Tab Title Name",
            font_caption = "sans26",
            font_text = "mono18",                             
        })
        
        table.insert(Editor.elms_to_delete, "GB_editor_titles_tbx") 
                       
        -- add button
        GUI.New("GB_editor_add_btn", "dh_Button", {
            z = 1,
            x = 28 * DHTK.APP_SCALE, 
            y = (MENUBAR_HEIGHT + 124) * DHTK.APP_SCALE, 
            w = 88 * DHTK.APP_SCALE, 
            h = 32 * DHTK.APP_SCALE, 
            text = "Add",
            font = "sans24",
        })
        
        table.insert(Editor.elms_to_delete, "GB_editor_add_btn")                 
        
        -- rename button
        GUI.New("GB_editor_rename_btn", "dh_Button", {
            z = 1,
            x = 132 * DHTK.APP_SCALE, 
            y = (MENUBAR_HEIGHT + 124) * DHTK.APP_SCALE, 
            w = 88 * DHTK.APP_SCALE, 
            h = 32 * DHTK.APP_SCALE, 
            text = "Rename",
            font = "sans24",
        })
        
        table.insert(Editor.elms_to_delete, "GB_editor_rename_btn")         
        
        -- move up button
        GUI.New("GB_editor_moveup_btn", "dh_Button", {
            z = 1,
            x = 236 * DHTK.APP_SCALE, 
            y = (MENUBAR_HEIGHT + 124) * DHTK.APP_SCALE, 
            w = 88 * DHTK.APP_SCALE, 
            h = 32 * DHTK.APP_SCALE, 
            text = "Move Up",
            font = "sans24",
        })
        
        table.insert(Editor.elms_to_delete, "GB_editor_moveup_btn")         
        
        -- delete button
        GUI.New("GB_editor_delete_btn", "dh_Button", {
            z = 1,
            x = (WORKSPACE_WIDTH - (88 + 28)) * DHTK.APP_SCALE,  
            y = (MENUBAR_HEIGHT + 124) * DHTK.APP_SCALE, 
            w = 88 * DHTK.APP_SCALE, 
            h = 32 * DHTK.APP_SCALE, 
            text = "Delete",
            font = "sans24",
        })
        
        table.insert(Editor.elms_to_delete, "GB_editor_delete_btn") 
        
        -- listbox
        GUI.New("GB_editor_titles_lbx", "dh_Listbox", {
            z = 1,
            x = 24 * DHTK.APP_SCALE, 
            y = (MENUBAR_HEIGHT + 192) * DHTK.APP_SCALE, 
            w = (WORKSPACE_WIDTH - 48) * DHTK.APP_SCALE, 
            h = 156 * DHTK.APP_SCALE,
            multi = false,
            caption = "Tab Title List",
            font_caption = "sans26",
            font_text = "sans26",                 
        })
                                             
        table.insert(Editor.elms_to_delete, "GB_editor_titles_lbx")
        
       --------------------------------
         ---- # Initialize data ---- 
       --------------------------------         
            
        -- Make a copy of Listbox.list to edit.

       Editor.data.title_names = {}
       Editor.data.tab_titles = {}
        
       for i, name in ipairs(sel_elm.props_norm.optarray) do               
        
           table.insert(Editor.data.title_names, name)
           local title = {name = name, orig_idx = i}

           table.insert(Editor.data.tab_titles, title)
        
       end 
       
       GUI.elms.GB_editor_titles_lbx.list = Editor.data.title_names
       GUI.elms.GB_editor_titles_lbx:val(1)

       GUI.elms.GB_editor_titles_tbx.retval = Editor.data.title_names[1]
       
       -----------------------------------
         ---- # Add mouse overrides ---- 
       -----------------------------------
       
       -- Copy selected listbox title into textbox. 
       function GUI.elms.GB_editor_titles_lbx:onmouseup()
           -- Run the element's normal method
           GUI.dh_Listbox.onmouseup(self)
           
           _, GUI.elms.GB_editor_titles_tbx.retval = GUI.elms.GB_editor_titles_lbx:val()
       
       end
       
       function GUI.elms.GB_editor_add_btn:onmouseup()
           -- Run the element's normal method
           GUI.dh_Button.onmouseup(self)

           local new_name = GUI.elms.GB_editor_titles_tbx.retval
                     
           -- Add the new title to titles.                     
           --!!! We are still operating on temp data while Editor is open.
           
           local title = {}
           title.name = new_name
           title.orig_idx = -1  -- flag so new tabs will get empty zset.
           
           local insert_idx = GUI.elms.GB_editor_titles_lbx:val() 
           insert_idx = insert_idx + 1
           
           table.insert(Editor.data.tab_titles, insert_idx, title)
           
           -- Add the revised titles to lbx (at end).           
           table.insert(GUI.elms.GB_editor_titles_lbx.list, insert_idx,  new_name) 
           
           GUI.elms.GB_editor_titles_lbx:val(insert_idx)       

       end

       
       function GUI.elms.GB_editor_rename_btn:onmouseup()
       
           -- Run the element's normal method
           GUI.dh_Button.onmouseup(self)
       
           local new_name = GUI.elms.GB_editor_titles_tbx.retval
           
           --GUI.Msg("   NEW NAME : " .. new_name)
       
           -- Get index of selected lbx item.
           local i = GUI.elms.GB_editor_titles_lbx:val()
           
           -- Update database.
           Editor.data.tab_titles[i].name = new_name
           
           --GUI.Msg("\n# GB_editor_rename tab_title.name: " .. (Editor.data.tab_titles[i].name or "WTF"))
                   
           -- Replace list item.
           GUI.elms.GB_editor_titles_lbx.list[i] = new_name
           
           -- Redraw lbx.
           GUI.elms.GB_editor_titles_lbx:redraw()
       
       end
       
       function GUI.elms.GB_editor_moveup_btn:onmouseup()
              
           -- Run the element's normal method
           GUI.dh_Button.onmouseup(self)
           
           -- # Get current index.
           
           local i, _ = GUI.elms.GB_editor_titles_lbx:val()
           
           -- Don't move up if first item.
           if i == 1 then 
               reaper.MB("Can't move first item up!", "Whoops!", 0) 
               return 
           end

           -- Move isn't yielding correct result.
           --table.move(Editor.data.tab_titles, i, i, i - 1, Editor.data.tab_titles)
           --table.move(GUI.elms.GB_editor_titles_lbx.list, i, i, i - 1, GUI.elms.GB_editor_titles_lbx.list)
           
           local temp_val = table.remove(Editor.data.tab_titles, i)
           table.insert(Editor.data.tab_titles, i - 1, temp_val)
           
           temp_val = table.remove(GUI.elms.GB_editor_titles_lbx.list, i)
           table.insert(GUI.elms.GB_editor_titles_lbx.list, i - 1, temp_val)
              
           -- Select moved item.
           GUI.elms.GB_editor_titles_lbx:val(i - 1)
              
       end
       
       function GUI.elms.GB_editor_delete_btn:onmouseup()   
           
           -- # Don't delete if only 1 item.
           if #Editor.data.tab_titles == 1 then
               reaper.MB("Can't delete when only one tab!", "Whoops!", 0) 
               return
           end
       
           -- Run the element's normal method
           GUI.dh_Button.onmouseup(self)

           -- # Get current index.
           
           local i = GUI.elms.GB_editor_titles_lbx:val()
                      
           -- # Remove item from lists
           
           table.remove(Editor.data.tab_titles, i)  
                    
           table.remove(GUI.elms.GB_editor_titles_lbx.list, i)  
           
           if i > #Editor.data.tab_titles then
           
               GUI.elms.GB_editor_titles_lbx:val(#Editor.data.tab_titles)
               GUI.elms.GB_editor_titles_tbx:val(Editor.data.tab_titles[#Editor.data.tab_titles].name)

           end
       
       end
    
    end  --<tab titles> 
    
    ----------------------------   
    ----   #  Z_sets open   ----
    ----------------------------   
        
    if editor_type == "z_sets" then
        
        GUI.elms.GB_editor_type_lbl.text = "Tabs Z_Sets Editor"
        GUI.elms.GB_editor_type_lbl:init()
        GUI.elms.GB_editor_info_lbl.x = 148 * DHTK.APP_SCALE
        GUI.elms.GB_editor_info_lbl.y = (MENUBAR_HEIGHT + 56) * DHTK.APP_SCALE        
        GUI.elms.GB_editor_info_lbl.text = " Enter integers separated by commas."
        GUI.elms.GB_editor_info_lbl:init()        
        
        -- # Get reference to selected element.
        
        local sel_elm = GUI.elms[GUI.elms.GB_frm_sel_elm.elm]
        
            --GUI.Msg("\n# props_norm.z_sets : ")
            --GUI.Msg(GUI.table_list(sel_elm.props_norm.z_sets))        

        -- Iterate to create Property elms. How?

        --GUI.Msg("\n>  #sel_elm.optarray: " .. (#sel_elm.optarray or "nil"))
        --GUI.Msg(">  #sel_elm.z_sets  : " .. (#sel_elm.z_sets or "nil"))
        --GUI.Msg(">  #sel_elm.z_sets[1]  : " .. (#sel_elm.z_sets[1] or "nil") .. "\n")
        --GUI.Msg("    PROPS_NORM.Z_SETS : ")
        --GUI.Msg(GUI.table_list(sel_elm.props_norm.z_sets))
        --GUI.Msg("    ELEMENTS.Z_SETS : ")
        --GUI.Msg(GUI.table_list(sel_elm.z_sets))         
        
        local y_init, y_off = 72, 48                            
    
        for idx = 1, #sel_elm.optarray do

            --GUI.Msg(">    #zset[" ..  idx .. "] : " .. (#zset or "nil"))
            --GUI.Msg(">    type of z_set : " .. type(zset))
            
            local tab_name = sel_elm.optarray[idx]
            local tbx_name = "GB_editor_tbx_" .. tostring(idx)
            
            --GUI.Msg(">    tbx_name : " .. tbx_name)

            GUI.New(tbx_name, "dh_Textbox", {
                z = 1,
                x = 144 * DHTK.APP_SCALE, 
                y = (y_init + (idx * y_off)) * DHTK.APP_SCALE, 
                w = (WORKSPACE_WIDTH - (144 + 24)) * DHTK.APP_SCALE, 
                h = 36 * DHTK.APP_SCALE,
                caption = tab_name,
                cap_pos = "left",
	            font_caption = "sans24",                 
                font_text = "mono18",   --textbox needs mono font
                col_text = "elm_txt",
                col_sel_text = "sel_txt",
                col_backdrop = "wnd_bg",        
            })
            
            table.insert(Editor.elms_to_delete, tbx_name)            

            -- values are design values.
            -- Say, Tabs.z design = 1, now is 11.
            -- zset has 11, but now hides Tabs.
            -- Need to get from props_norm.
        
            --local zset = sel_elm.z_sets[idx]
            local zset = sel_elm.props_norm.z_sets[idx]
                        
            -- Need to convert zset to string then put it in tbx.
            GUI.elms[tbx_name].retval = table.concat(zset, ",")
            
        end  
        
    end
    
    --GUI.Msg("    #Editor.elms_to_delete: " .. (tostring(#Editor.elms_to_delete) or "nil")) 
 
    -- Editor - display common elements.
    GUI.elms.GB_editor_pnl.z = 2
    GUI.elms.GB_editor_sidebar_pnl.z = 2    
    GUI.elms.GB_editor_type_lbl.z = 1
    GUI.elms.GB_editor_info_lbl.z = 1    
    GUI.elms.GB_editor_save_btn.z = 1
    GUI.elms.GB_editor_close_btn.z = 1

    --??? Necessary?
    GUI.elms.GB_editor_pnl:redraw()
    GUI.elms.GB_editor_sidebar_pnl:redraw()    
    GUI.elms.GB_editor_type_lbl:redraw()
    GUI.elms.GB_editor_info_lbl:redraw()        
    GUI.elms.GB_editor_close_btn:redraw()
    
end  

-----------------------------------------------
----     #  Save    
-----------------------------------------------
--zzclose

Editor.save_editor = function()

    --GUI.Msg("\n# Editor.save_editor")
    
    -- Get reference to selected element.
    local sel_elm = GUI.elms[GUI.elms.GB_frm_sel_elm.elm]
    
    --GUI.Msg("    sel_elm : " .. GUI.elms.GB_frm_sel_elm.elm)
--zzz
    --------------------------------
    ---- #  Menu Titles  save   ---- 
    --------------------------------

    if Editor.type == "menu_titles" then
    
        -- Convert retval to table.
        
        local valstr = GUI.elms["GB_editor_menu_titles_tbx"].retval
        
        GUI.Msg("\n# Menu Titles  save valstr : " .. valstr)
        
        local menus = {}       
        
        for v in string.gmatch(valstr, "[^,]*") do
        
            GUI.Msg("    title : " .. v)
            
            table.insert(menus, {title = v, options = {}})
            
        end
        
        --do return end        
        
        --sel_elm.menus = menus 
        sel_elm.props_norm.menus = menus
        
        --GUI.Val("my_menubar", new_menus)
        
        sel_elm:val(menus)
        
        
        sel_elm:redraw()         
    
    end

    -----------------------------------
    ---- #  Min-Max values  save   ---- 
    -----------------------------------

    if Editor.type == "min_max_values" then
    
        -- Convert retval to table.
        
        local valstr = GUI.elms["GB_editor_min_max_tbx"].retval
        
        local new_min_max_values = {}       
        
        for mm_str in string.gmatch(valstr, "[^;]*") do
        
            -- mm_str is string <step,str_value>
            
            local mm_item = {}
            
            for v in string.gmatch(mm_str, "[^,]*") do  
                table.insert(mm_item, v)
            end
            
            -- Convert first value to integer.
            mm_item[1] = math.tointeger(mm_item[1])
            
            
            table.insert(new_min_max_values, mm_item)
            
        end
        
        sel_elm.min_max_values = new_min_max_values 
        sel_elm.props_norm.min_max_values = new_min_max_values
        
        sel_elm:redraw()         
    
    end
     
    ----------------------------
    ---- #  Options  save   ---- 
    ----------------------------

    if Editor.type == "options" then
    
        -- Convert retval to table.
        
        local valstr = GUI.elms["GB_editor_options_tbx"].retval
        local opts = {}       
        
        for v in string.gmatch(valstr, "[^,]*") do
        
            table.insert(opts, v)
            
        end
        
        sel_elm.optarray = opts 
        sel_elm.props_norm.optarray = opts
        
        sel_elm:redraw()         
    
    end

    ------------------------------
    ---- #  Tab Titles  save  ---- 
    ------------------------------
    
    if Editor.type == "tab_titles" then
    
        -- # Update Tabs titles and z_sets.
               
        local new_names = {}
        local new_zsets = {}
        local new_idx
        
        -- # Update z sets.
        
        for i, title in ipairs(Editor.data.tab_titles) do
        
            --GUI.Msg(">    tab_title.name : " .. title.name)
        
            table.insert(new_names, title.name)
        
            -- I want to match zset to tab number.

            -- New tab gets empty set.
            if title.orig_idx == -1 then
                --sel_elm.z_sets[i] = {}
                --sel_elm.props_norm.z_sets[i] = {}
                new_zsets[i] = {}
                sel_elm.props_norm.z_sets[i] = {}                
            else
            
                local zset = {}
                local norm_set = {}
                
                -- z is z in table of z's.
                for i, z in pairs(sel_elm.z_sets[title.orig_idx]) do
                    
                    table.insert(zset, z)
                    table.insert(norm_set, z - 10)
                
                end
                
                new_zsets[i] = zset
                sel_elm.props_norm.z_sets[i] = norm_set
            
            end

        end
        
        sel_elm.z_sets = new_zsets
        
        --??? Should I set selected tab?
        --sel_elm:update_sets()                
        sel_elm.state = 1
        
        sel_elm.optarray = new_names
        sel_elm.props_norm.optarray = new_names         

    end 
        
    --------------------------
    ---- #  Z Sets save   ---- 
    --------------------------
     
    if Editor.type == "z_sets" then

        -- Update selected element. Convert csv string to table.
        -- Textbox will show design z.
        
        local elm_zsets = {}
        local norm_zsets = {}
        
        for idx = 1, #sel_elm.optarray do
        
            --GUI.Msg("    > idx : " .. idx)
        
            local elm_set = {}
            local norm_set = {}
            
            local tbx_val = GUI.elms["GB_editor_tbx_" .. idx].retval
            
            --GUI.Msg("    tbx_val : " .. tbx_val)
            
            -- tbx_val contains csv string of design values.
            -- Add 10 offset for elms.
                    
            for v in string.gmatch(tbx_val, "[^,]*") do
                if math.tointeger(v) then
                    v = math.tointeger(v)
                    --GUI.Msg("        v : " .. v)
                    table.insert(elm_set, v + 10)
                    table.insert(norm_set, v)
                end
            end
        
            elm_zsets[idx] = elm_set 
            norm_zsets[idx] = norm_set 
            
        end
        
        sel_elm.z_sets = elm_zsets 
        sel_elm.props_norm.z_sets = norm_zsets 
        
        --GUI.Msg("\n# PROPS_NORM.Z_SETS : ")
        --GUI.Msg(GUI.table_list(sel_elm.props_norm.z_sets))
        --GUI.Msg("\n# ELEMENTS.Z_SETS : ")
        --GUI.Msg(GUI.table_list(sel_elm.z_sets))
         
    end
    
--zzz    
    -- # Update GUI
    --Editor.close_editor()
    
    --[=[
    for _, elm_name in ipairs(Editor.elms_to_delete) do
        GUI.Msg("    elms_to_delete : " .. elm_name )
        GUI.elms[elm_name]:delete()
    end
    
    GUI.elms.GB_editor_pnl.z = 495
    GUI.elms.GB_editor_sidebar_pnl.z = 495    
    GUI.elms.GB_editor_type_lbl.z = 494
    GUI.elms.GB_editor_info_lbl.z = 494    
    GUI.elms.GB_editor_save_btn.z = 494
    GUI.elms.GB_editor_close_btn.z = 494
    GUI.elms_hide[495] = true
    GUI.elms_hide[494] = true
    --GUI.redraw_z[2] = true
    --GUI.redraw_z[1] = true
    GUI.redraw_z[0] = true        
    --]=]    
end


return Editor
