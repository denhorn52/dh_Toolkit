-- NoIndex: true

--func_Elements.lua
-- Modified 20260330

--[==[
  --  Introduced elm.props_norm  --  
  This is a hash of a project elements property values created at 1x scale.
  GUI Builder shifts z layers up 10 to allow room for itself.
  Scaling the script window also affects the metrics stored in the element itself.
  props_norm stores the design state of these property values.
    It holds the 1x scale metrics.
    It holds the unshifted z and z_sets value.
  It holds the values that will be displayed in sidebar.
  It will be updated on propery changes.
--]==]

local Element = {}

-- Add all of the element data to the element classes
--Element.classes = GUI.req(GUI.script_path .. "modules/data_Elements.lua")()
Element.classes = require("data_Elements")

--zzselect --zzdrag

-- @param elm : selected element

function Element.select_elm(elm)
    --GUI.Msg("\n** Element.select_elm : " .. elm.name)
    GUI.elms.GB_frm_sel_elm.elm = elm.name
    GUI.elms.GB_frm_sel_elm.z = 10
    GUI.redraw_z[10] = true
    
    --Properties.init_properties(elm)
    Properties.init_properties(elm, GUI.elms[elm.name].curr_menu_page)

end


function Element.deselect_elm()

    GUI.elms.GB_frm_sel_elm.elm = nil
    GUI.elms.GB_frm_sel_elm.z = -2
    GUI.redraw_z[10] = true

    Properties.clear_properties()

end

--zzdup
function Element.duplicate_elm(elm)
    --GUI.Msg("\n** DUPLICATE ELM **")
    
    local new_name = Element.get_new_elm_name(elm.type)

    local x, y, proj_x, proj_y = Element.get_new_elm_coords(GUI.mouse.x, GUI.mouse.y)

    Properties.recreate_elm(elm, new_name, false, x, y, proj_x, proj_y)

end

function Element.delete_elm(elm)

    if GUI.elms.GB_frm_sel_elm.elm == elm.name then Element.deselect_elm() end

    elm:redraw()
    elm:delete()

    -- Giving GUI.Update a new element to perform the subsequent :onmouseup(),
    -- otherwise it will get stuck and not allow any new LMB input.
    --GUI.mouse_down_elm = GUI.elms.GB_frm_bg
    --GUI.forcemouseup()
    
end

--zzdrag
function Element.drag_elm(elm)

    -- Get target x,y
    
    local target_x, target_y
    if GUI.mouse.m_down then
        target_x = GUI.mouse.x - GUI.mouse.m_off_x
        target_y = GUI.mouse.y - GUI.mouse.m_off_y
    else
        target_x = GUI.mouse.x - GUI.mouse.off_x
        target_y = GUI.mouse.y - GUI.mouse.off_y    
    end    
    
    --GUI.Msg("\nnorm mouse : " .. tostring(GUI.mouse.x) .. " : " .. tostring(GUI.mouse.y))   
    --GUI.Msg("\nnorm offset : " .. tostring(GUI.mouse.off_x) .. " : " .. tostring(GUI.mouse.off_y))       
    --GUI.Msg("\nnorm_target : " .. tostring(norm_target_x) .. " : " .. tostring(norm_target_y))
    
    -- !!! Special case for Knob centered.
    -- Need to use center for snap (add radius).
    -- !!! If I change property to knob_centered then only need one check.
    
    if elm.type == "dh_Knob" and elm.centered then
        target_x = target_x + math.floor(((elm.props_norm.w / 2) + 0.5) * DHTK.APP_SCALE)
        target_y = target_y + math.floor(((elm.props_norm.w / 2) + 0.5) * DHTK.APP_SCALE)
    end
    
    -- Snap to grid. 

    local new_x, new_y, proj_x, proj_y = Element.get_new_elm_coords(target_x, target_y)
    
    --GUI.Msg("new from snap : " .. tostring(new_x) .. " : " .. tostring(new_y))
------------
    -- !!! Special case for Knob centered.
    -- new_x, new_y are scaled center x,y.
    -- elm x,y needs subtract radius then scale?
    -- prop display needs integer center x,y (which is in props_norm.
    
    if elm.type == "dh_Knob" and elm.centered then
    
        local rad = math.floor((elm.props_norm.w / 2) + 0.5)
    
        -- Store (integer) proj x,y in props_norm. 

        elm.props_norm.x = proj_x                                         
        elm.props_norm.y = proj_y         
        
        -- !!! Only if not elm:init()
        new_x = new_x - math.floor((rad * DHTK.APP_SCALE) + 0.5)
        new_y = new_y - math.floor((rad * DHTK.APP_SCALE) + 0.5)
        
        -- Update property display. 
        GUI.Val("GB_prop_x", proj_x)
        GUI.Val("GB_prop_y", proj_y)    
    else
    
        -- Store (integer) proj x,y in props_norm. 
        elm.props_norm.x = proj_x                                           
        elm.props_norm.y = proj_y

        -- Update property display. 
        GUI.Val("GB_prop_x", elm.props_norm.x)
        GUI.Val("GB_prop_y", elm.props_norm.y)    
    end

------------
    GUI.elms.GB_frm_sel_elm.x, GUI.elms.GB_frm_sel_elm.y = elm.x, elm.y
    GUI.elms.GB_frm_sel_elm:redraw()
    
    -- !!! If knob centered and using init will need center.
    elm.x, elm.y = new_x, new_y

    --GUI.Msg(" drag_elm ready to redraw")
    
    -- Need redraw here!
    --elm:redraw()
    GUI.redraw_z[0] = true
    
end


-- CAN STAY HERE
function Element.get_new_elm_name(type)

    local i = 1
    while true do
        if not GUI.elms[type..i] then
            return type..i
        else
            i = i + 1
        end
    end
    
end

------------------------------------
---------  GB Methods  ------------
------------------------------------

-- Used for testing.
function msg_focused_elm()
    for name, elm in pairs(GUI.elms) do
        if not string.find(name, "GB") then
            if elm.focus == true then
                GUI.Msg(">>> GUI FOCUSED elm is : " .. name)
            end
        end
    end
end


function Element.add_GB_methods(elm)

    --GUI.Msg("Element.add_GB_methods")
    
    function elm:onmouseup()
    
        --GUI.Msg("\n# GB elm mouse up")
        --msg_focused_elm()        
        
        -- Just a placeholder to keep elms from doing anything on Shift
        --   and messing up the other methods.
        
        if GUI.mouse.cap & 8 == 8 then
        
            -- Button needs to be redrawn in up state.
            --GUI.Msg("    GB elm mouse up + shift")
            if elm.type == "dh_Button" or elm.type == "Button" then
                elm.state = 0
                elm:redraw()
            end                     
        
        -- Alt+click to delete
        elseif GUI.mouse.cap & 16 == 16 then
            --Element.delete_elm(self)
            
             local params = {}
             params.title = "Delete Element?"
             params.message = self.name
             params.show_inputs = false
             params.func = Element.delete_elm
             params.params = self
             
             -- This will display dialog, but can't return anything useful.
             Dialog.open(params)            
--zzz            
        else
        
            GUI[self.type].onmouseup(self)
            
            --[=[]
            if GUI.elms.GB_frm_sel_elm.elm ~= self.name then
                GUI.Msg("    not self.name") 
                --Element.select_elm(self)  --!!! This seems redundant 
            else
                GUI.Msg("    is self.name")
                GUI.Msg("% GB elm mouseup else run native mouseup")
                --GUI[self.type].onmouseup(self)
            end            
            --]=]
        end
        
        --GUI.Msg("\n#    end GB elm mouse up")
                
    end

    function elm:onmousedown()
    
        --GUI.Msg("\n# GB elm mouse down")
        
        GUI[self.type].onmousedown(self)        
        
        if GUI.elms.GB_frm_sel_elm.elm ~= self.name then
            --GUI.Msg("    not self.name")
            
            if (elm.type == "dh_Checklist") or (elm.type == "Checklist") 
                or (elm.type == "dh_Menubox")or (elm.type == "Menubox")
            then                     
                Element.select_elm(self)
                self.focus = false
            else    
                Element.select_elm(self)
                self.focus = true                
            end

        end
        
        -- TRY this at start. Same result.
        --GUI[self.type].onmousedown(self)

    end

    -- elms retaining focus on middle mouse, except for button. 
    
    function elm:onmousem_up()
        --GUI.Msg("% elm middle mouse up")
        --GUI[self.type].onmouseup(self)
        --self.focus = true
        -- Button needs to be redrawn in up state.
        if elm.type == "dh_Button" or elm.type == "Button" then
            elm.state = 0
            elm:redraw()
        end         

    end    
    
    
    function elm:onmousem_down()
    
        --GUI.Msg("% elm middle mouse down")
        --GUI.Msg("mouse.cap is : " .. tostring(GUI.mouse.cap))            

        if GUI.elms.GB_frm_sel_elm.elm ~= self.name then
        
            local prev_elm_name = GUI.elms.GB_frm_sel_elm.elm
            
            if GUI.elms[prev_elm_name] then
                GUI.elms[prev_elm_name].focus = false
            end
            Element.select_elm(self)  

        end
        
        -- Need this to be able to drag.        
        self.focus = true

    end 
     
--zzdrag      
    function elm:ondrag()
        --GUI.Msg("elm on drag")
        -- Shift+click to move elm
        if GUI.mouse.cap & 8 == 8 then
            Element.drag_elm(self)
        else
            GUI[self.type].ondrag(self)
        end

    end
    
    function elm:onm_drag()
        --GUI.Msg("elm middle mouse drag")
        Element.drag_elm(self)
    
    end 
 
    -- Since a Panel can take up most or all of the window space 
    -- it is necessary to be able to allow new element context menu to be called by right-clicking it.
        
    if elm.type == "dh_Panel" then
        
        function elm:onmouser_up()
            Element.new_elm_menu()
        end
        
    else
         
         function elm:onmouser_up()
         
             -- Allow, say, 'slider right-click to set default' through.         
             if GUI.mouse.cap & 4 == 4 then
                 GUI[self.type].onmouser_up(self)
                 return
             end 
         
             if GUI.elms.GB_frm_sel_elm.elm ~= self.name then return end
             
             --[[
             local outstr = "Do you want to delete clicked elementt?\n" .. self.name

             ret = reaper.ShowMessageBox(outstr, "Confirm delete!", 1)
             
             -- OK = 1, Cancel = 2
             if ret == 1 then
                 Element.delete_elm(self)
             elseif ret == 2 then
                 return nil
             end
             --]]
             
             local params = {}
             params.title = "Delete Element?"
             params.message = self.name
             params.show_inputs = false
             params.func = Element.delete_elm
             params.params = self
             
             -- This will display dialog, but can't return anything useful.
             Dialog.open(params)

        end
        
    end

end

-- This is called when a new element is created, even when importing.
-- New elm is created at 1x scale then resized to scale.
-- Duplicated elm may be created at other than 1x scale.
-- prop_defaults: table with default values. Use to revert to original values.
-- props_norm: table of all editable properties at 1x scale.
--    Also holds unshifted z values.
--    Use for property display, and duplicating elm.

--zzdefaults

function Element.store_elm_defaults(elm, proj_x, proj_y)

    --GUI.Msg("\n**** store_elm_defaults ****") 

    local defaults = {}
    local props_norm = {}
    local gb_props = elm.GB.properties
    
    
--[=[
    -- !!! 20260330: May not need prop_defaults anymore. Using GUI[elm.type].defaults. 
    -- Can reimplement this for the Lokasenna elements.    
    -- Gets extra editable properties.
    
    -- list of all other editable property names
    local creation = elm.GB.creation 
    local extra = GUI.table_find(creation, "^$") + 1
    
    -- list of all prop names beyond what GB needs for creating an element.
    
    local extra_props = {table.unpack(creation, extra)}

    -- This gets property name.
    for i = 1, #extra_props do
        defaults[extra_props[i]] = elm[extra_props[i]]
        --GUI.Msg(tostring(extra_props[i]) .. " : " .. tostring(extra_props[i]))
    end
    
    elm.prop_defaults = defaults
--]=] 
   
    --GUI.Msg("\n**** store props_norm ****") 
    
    for i = 1, #gb_props do
    
        -- "1"
        -- {prop = "y", caption = "Y", class = "Integer"},
        local prop_table = gb_props[i]  -- get property table or ""

        -- Elm is created at 1x scale (norm).
        -- Table means it is a property.
        
        -- Iterate properties and copy them to props_norm.
        
        if type(prop_table) == "table" then
        
            local p_name = prop_table.prop
            props_norm[p_name] = elm[p_name]  

            -- Shift new element z.
            
            if p_name == "z" then
                
                elm.z = elm.z + 10
                
                --props_norm[p_name] = elm.z - 10

                --GUI.Msg("     elm.z : " .. tostring(elm.z))
                --GUI.Msg("   value   : " .. tostring(props_norm[p_name]))
            end
             
            if p_name == "z_sets" then
            
                --GUI.Msg("\n# z_set defaults")            

                -- Tabs zsets need to be shifted.
                -- props_norm.z_sets will hold unshifted values. 
                -- elm.zsets holds shifted values.
            
                local adj_zsets = {}
            
                for i, orig_set in ipairs(props_norm.z_sets) do

                    local adj_set = {}

                    for z, v in ipairs(orig_set) do 
                        table.insert(adj_set, v + 10)            
                    end
                    
                    adj_zsets[i] = adj_set

                end 
                
                elm.z_sets = adj_zsets

                --GUI.Msg("\n# PROPS_NORM.Z_SETS : ")
                --GUI.Msg(GUI.table_list(props_norm.z_sets))
                --GUI.Msg("\n# ELEMENTS.Z_SETS : ")
                --GUI.Msg(GUI.table_list(elm.z_sets))                

            end
             
        end  --< if table>
        
    end  --< if gb_props>
    
    --GUI.Msg("\n# after build props_norm :")
    --GUI.Msg("    elm  z : " .. tostring(elm.z))
    --GUI.Msg("    props_norm z : " .. tostring(props_norm.z))    
     
--[=[
    -- Need to replace x, y 
    
    -- !!! Special case for dh_Knob centered.
    -- Creating elm put elm.x, elm.y to top left,
    -- proj_x, proj_y should be correct.
    if elm.type == "dh_Knob" and elm.centered then
        -- Subtract radius.
        props_norm.x = proj_x - math.floor((props_norm.w + 0.5) / 2)
        props_norm.y = proj_y - math.floor((props_norm.w + 0.5) / 2)
    else
        props_norm.x, props_norm.y  = proj_x, proj_y
    end 
--]=]

    props_norm.x, props_norm.y  = proj_x, proj_y
    
    elm.props_norm = props_norm
   
    --GUI.Msg("    store_elm_defaults : props_norm.x : " .. tostring(elm.props_norm.x) .. " ; props_norm.y " .. tostring(elm.props_norm.y))
    
  
--zzz
    -- Update Tabs z_sets.
    
    -- Tabs:init() calls update_sets() with design z's.
    -- This causes menubar on layer 2 to be hidden if layer 2 is in z_sets.
    -- Need to ensure gb layers aren't hidden.
    -- elm.z_sets now have the shifted z's.
    -- So call update_sets() with shifted values.        
    
    --if (elm.type == "dh_Tabs") and elm.z_sets[1] and (#elm.z_sets[1] > 0) then
    if (elm.type == "dh_Tabs") then

        --GUI.Msg("# store elm defaults tab.state : " .. elm.state)
        --GUI.Msg(GUI.table_list(elm.z_sets))   
              
        elm:update_sets()
        
        -- Let's try layer 2, then 1 - 10.
        
        GUI.elms_hide[1] = false         
        GUI.elms_hide[2] = false  
        GUI.elms_hide[3] = false          
        GUI.elms_hide[4] = false
        GUI.elms_hide[5] = false         
        GUI.elms_hide[6] = false  
        GUI.elms_hide[7] = false          
        GUI.elms_hide[8] = false        
        GUI.elms_hide[9] = false                           
        
        -- This doesn't redraw hidden layers.
        GUI.redraw_z[0] = true
                
    end    

end


function Element.get_new_elm_coords(x, y)

    --GUI.Msg("\n** Element.get_new_elm_coords **")

    -- Normalize mouse coords and convert to project coords.
    local proj_x = math.floor((x / DHTK.APP_SCALE) + 0.5)
    local proj_y = math.floor((y / DHTK.APP_SCALE) + 0.5) - MENUBAR_HEIGHT
    
    --GUI.Msg("  x :  " .. tostring(x))
    --GUI.Msg("  y :  " .. tostring(y))    
    --GUI.Msg("  proj_x :  " .. tostring(proj_x))
    --GUI.Msg("  proj_y :  " .. tostring(proj_y))    

    -- Snap to grid.
    if Prefs.preferences.grid_snap then
        proj_x = math.floor(GUI.nearestmultiple(proj_x, Prefs.preferences.grid_size) + 0.5)
        proj_y = math.floor(GUI.nearestmultiple(proj_y, Prefs.preferences.grid_size) + 0.5)
    end
    
    -- Rescale adjusted mouse coords in case snapped.
    x = math.floor((proj_x * DHTK.APP_SCALE) + 0.5)
    y = math.floor(((proj_y + MENUBAR_HEIGHT) * DHTK.APP_SCALE) + 0.5)

    --GUI.Msg("** after snap **")
    --GUI.Msg("  x :  " .. tostring(x))
    --GUI.Msg("  y :  " .. tostring(y))    
    --GUI.Msg("  proj_x :  " .. tostring(proj_x))
    --GUI.Msg("  proj_y :  " .. tostring(proj_y))    

    return x, y, proj_x, proj_y
    
end

--zzcreate

function Element.create_new_elm(class)

    --GUI.Msg("\n**  Element.create_new_elm **")
    
    if not class then return end

    local name = Element.get_new_elm_name(class)
    
    local x, y, proj_x, proj_y = Element.get_new_elm_coords(GUI.mouse.x, GUI.mouse.y)
    
    --GUI.Msg("    elm  x : " .. tostring(x) .. " ; elm y  : " .. tostring(y))
    --GUI.Msg("    proj_x : " .. tostring(proj_x) .. " ; proj_y : " .. tostring(proj_y))    
    
    -- This calls elm init function.
    --GUI.New(name, class, 11, x, y, table.unpack(GUI[class].GB.defaults) )
    GUI.New(name, class, 1, x, y, table.unpack(GUI[class].GB.defaults) )    

    --GUI.Msg("\n  > new  elm  created -> store_elm_defaults")
    --GUI.Msg("    elm  x : " .. tostring(GUI.elms[name].x) .. " ; elm y  : " .. tostring(GUI.elms[name].y))
    --GUI.Msg("    proj_x : " .. tostring(proj_x) .. " ; proj_y : " .. tostring(proj_y))    

    GUI.elms[name].caption = name
    
    --??? Do I need to init here?
    --GUI.elms[name]:init()

    Element.add_GB_methods(GUI.elms[name])

    Element.store_elm_defaults(GUI.elms[name], proj_x, proj_y)
    
    -- If app scaled need to scale new elm and reinit.
    -- Can use elm's own properties as they are at 1x scale.
    if DHTK.APP_SCALE ~= 1 then
    
        DHTK.scale_elm(GUI.elms[name])
        
        -- except for x and y
        -- x, y should be scaled mouse.x, mouse.y  
--zzknob        
        -- Need special case for dh_Knob?
                
        if GUI.elms[name].type == "dh_Knob" then
            GUI.Msg("\n  > new  elm  scaled : ")
            GUI.elms[name].x = x - GUI.elms[name].w // 2
            GUI.elms[name].y = y - GUI.elms[name].w // 2        
        else
            GUI.elms[name].x = x
            GUI.elms[name].y = y
        end
        
        GUI.elms[name]:init()
        
    end
    
    -- Show and select new elm.    
    Element.select_elm(GUI.elms[name])
    
    -- Need to draw even hidden elms in case using tabs,
	for key, __ in pairs(GUI.elms) do
        --GUI.elms[key]:init()
        GUI.elms[key]:redraw()
    end        

end

----------------------------------
-- This where to build menu.
-- Add Lokasenna submenu to elm_menu strs[1].
-- Add DHTK submenu to elm_menu strs[2].

function Element.get_new_elm_menu()
    
    local strs = {}
    local opts = {}
    local strs_lk = {}
    local strs_dh = {}
    
    --for class in GUI.kpairs(Element.classes) do
    for class, _ in pairs(Element.classes) do    

        if not GUI[class].GB.hidden then
        
            if string.match(class, "dh_") then
                table.insert(strs_dh, class)
            else
                table.insert(strs_lk, class)
            end
        end
        
    end

    table.sort(strs_dh)
    table.sort(strs_lk)
    
    table.insert(strs, ">Insert DHTK Element")
    
    for i, c in ipairs(strs_dh) do
        table.insert(opts, c)
        if i == #strs_dh then c = "<" .. c end
        table.insert(strs, c)
    end
    
    table.insert(strs, ">Insert Lokasenna Element")

    for i, c in ipairs(strs_lk) do
        table.insert(opts, c)
        if i == #strs_lk then c = "<" .. c end
        table.insert(strs, c)
    end
    

    table.insert(strs, "Duplicate")
    table.insert(opts, "Duplicate")

    --strs[idx], opts[idx] = "", ""
    --strs[idx + 1], opts[idx + 1] = right_click_menu.strs[3], right_click_menu.opts[3]

    return strs, opts

end

-- gfx.showmenu returns number of field clicked.
-- Need strs table to get elm name.

function Element.new_elm_menu()

    gfx.x, gfx.y = GUI.mouse.x, GUI.mouse.y

    local strs, opts = Element.get_new_elm_menu()

    local ret = gfx.showmenu(table.concat(strs, "|"))
    if ret == 0 then return end
    
    local sel = opts[ret]        

    if sel == "Duplicate" then
        if GUI.elms.GB_frm_sel_elm.elm then
            Element.duplicate_elm(GUI.elms[GUI.elms.GB_frm_sel_elm.elm])
        end
    else
        if string.match(sel, "<") then
            string.gsub(sel, "<", "")
        end
        
        Element.create_new_elm(sel)
        
    end

end


return Element