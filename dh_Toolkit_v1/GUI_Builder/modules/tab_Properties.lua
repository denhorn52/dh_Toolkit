-- NoIndex: true

-- tab_Properties.lua
-- Modified 20260330

local Property = GUI.req(GUI.script_path .. "modules/class_Properties.lua")()
--local Element = require("func_Elements")
--local Property = require("class_Properties")

local Properties = {}
--zzref
local ref_properties = {x = 148, y = 60, w = 144, h = 24, off = 28}

function Properties.adjust_elms(x, w)
    
    Properties.ref_x, Properties.ref_w = x, w
    -- Make sure we move all of the property elements
    for k in pairs(GUI.elms) do

        if string.match(k, "GB_prop_") then
           GUI.elms[k].x = x + ref_properties.x
        end

    end
    
end

------------------------------------
-------- Getting elements ----------
------------------------------------

-- Global --> Properties.lua
-- Make a copy of the target element with a new name,
-- and delete the old one

function Properties.rename_elm(self, new_name)

    --GUI.Msg("\n** RENAME ELM to ** " .. new_name)

    Properties.recreate_elm(GUI.elms[self.elm], new_name, true, nil, nil, GUI.elms[self.elm].props_norm.x, GUI.elms[self.elm].props_norm.y)

end

-- Global --> Properties.lua
-- Delete an element and make it again; for changing properties that need
--   more than just a call to :init
-- Specify 'name' to rename the element, since it requires recreating the
--   element anyway.
-- dup_x, dup_y are actual gfx coords (at current scale) for duplicating. 
-- proj_x, proj_y are normalized coords (less menubar height) to put in props_norm. 

function Properties.recreate_elm(elm, new_name, selected, dup_x, dup_y, proj_x, proj_y)

    --GUI.Msg("\n** RECREATE ELM **\n")
    
    --GUI.Msg("    dup_x :  " .. tostring(dup_x))
    --GUI.Msg("    dup_y :  " .. tostring(dup_y))    
    --GUI.Msg("    proj_x :  " .. tostring(proj_x))
    --GUI.Msg("    proj_y :  " .. tostring(proj_y))    

    local orig_name = elm.name

    -- If changing the name, change the orig_name elm's name so the exported param strings use it...
    if new_name then
        elm.name = new_name
    end
    
-----------------------------------------------
    -- Store props_norm then restore it after recreate.
    local tmp_props_norm = elm.props_norm
    local tmp_props_defaults = elm.props_defaults
    
-----------------------------------------------
    -- Text editor retval not in Properties.
    -- Store it temporarily then restore it after recreate.
    local retstr

    if elm.type == "dh_TextEditor" or elm.type == "TextEditor" 
       or elm.type == "dh_Textbox" or elm.type == "Textbox" 
    then
        retstr = elm:val()
    end
    
-----------------------------------------------

    -- Adjust knob x, y if knob.centered.  
    -- !!! Needed this at some point, but now messes with display. 

    if elm.type == "dh_Knob" and elm.centered == true and not dup_x then
        elm.x = elm.x + elm.w // 2
        elm.y = elm.y + elm.w // 2
    end

-----------------------------------------------
    -- Build table of property values as formatted strings.
    -- Use values from source elm (scaled) to build creation string.
    -- This table can still be updated by prop name.
    -- Non-scaled props_norm will be added later.

    local gb_props = elm.GB.properties    -- list of {prop, caption, class}
    
    local f_params = {}  -- formatted values
    
    -- 'type' isn't part of the editable properties, so we need to add it here.
    f_params.type = '"' .. elm.type .. '"'

    for _, data in ipairs(gb_props) do
    
        local prop = data.prop
  
        if prop then

            --props[prop] = Element.format_property_to_code( elm[prop] )    
            local val = elm[prop]
            local fval 
    
            if type(val) == "string" then
                fval = '"' .. val .. '"'
            elseif type(val) == "boolean" then   
                fval = tostring(val)
            elseif type(val) == "table" then   
                fval = Export.table2str(val, elm.type, prop)
            else
                fval = tostring(val)  -- number
            end
            
            f_params[prop] = fval
            
        end
        
    end
    --GUI.Msg("    f_params.name :  " .. f_params.name)
    --GUI.Msg("    f_params.x :  " .. tostring(f_params.x))    
-----------------------------------------------
    -- ... and then change the name back so the elm can be deleted.
    
    if new_name then
        elm.name = orig_name

        -- If the element's caption is still the default, change it too
        if elm.caption == orig_name then
            --params.caption = Element.format_property_to_code(new_name)
            f_params.caption = '"' .. new_name .. '"'
        end
    end

-----------------------------------------------
    -- If duplicating, update the elm's x and y before creating it
    if dup_x then
    
        --GUI.Msg("   is duplicating : dup_x :  " .. tostring(dup_x))
                
        f_params.x = tostring(math.floor(dup_x + 0.5))
        f_params.y = tostring(math.floor(dup_y + 0.5))
        
    -- If not duplicating, delete the old one
    else
        --GUI.Msg("  -- NOT duplicating --")
        elm:delete() 
    end
    
-----------------------------------------------
--        Build the new elm.
-----------------------------------------------

    --GUI.Msg("--  # Build the new elm with f_params : --")

    -- Concat the table since Lua won't do it with keys
    -- get_elm_params should probably do this itself somehow?
    local str = "GUI.New({\n\t"
    local param_strs = {}
    for k, v in pairs(f_params) do
        param_strs[#param_strs + 1] = k .. " = " .. v
        
        --GUI.Msg("param_strs key is : " .. k)
        --GUI.Msg("param_strs   v is : " .. v)
        
    end
    
    --GUI.Msg("\n    #param_strs is : " .. tostring(#param_strs))    
    
    str = str .. table.concat(param_strs, ",\n\t") .. "\n})"
    
    --GUI.Msg("\n # creating element with string:\n" .. tostring(str) )
    
    -- # Create the new element.
    load(str)()
    
    -- Reference to newly created elm.
    local created_elm = GUI.elms[new_name or orig_name]
    
-----------------------------------------------
    
    --GUI.Msg("  -- Okay, elm is recreated. --")
 
    --[=[    
    if created_elm.track_thk then
        
        GUI.Msg("  elm is : " .. new_name)
        GUI.Msg("  w   is : " .. tostring(created_elm.w))
        GUI.Msg("  thk is : " .. tostring(created_elm.track_thk))
    
    end

    GUI.Msg("\nduplicate elm") 
    GUI.Msg("dup elm name is : " .. created_elm.name)
    GUI.Msg("dup elm x    is : " .. tostring(created_elm.x))
    GUI.Msg("dup elm y    is : " .. tostring(created_elm.y))
    GUI.Msg("dup elm centered is : " .. tostring(created_elm.centered))
    GUI.Msg("dup elm centered type is : " .. tostring(type(created_elm.centered)))    
    --]=]
    
-----------------------------------------------
    -- Add extra data and methods to recreated element.
    
    -- dup knob when centered false
    -- dup_x, dup_y shows 256, 284 (correct mouse click)
    -- drawing with center 256, 256 (wrong, 256, 256 should be top left.)
    -- prop showing 276, 276
    
    if dup_x then
    
        -- Get props_norm from source elm.
        -- Alternately can copy from tmp_props_norm, they are same.
        local props_norm = GUI.table_copy(elm.props_norm)
        
        props_norm.name = new_name
--[=[
        -- # Special case for dh_Knob.
        -- !!! Needed this at some point, but now messes with display.         
        if created_elm.type == "dh_Knob" and created_elm.centered then
            -- Subtract radius.
            props_norm.x = proj_x - math.floor((props_norm.w / 2) + 0.5) 
            props_norm.y = proj_y - math.floor((props_norm.w / 2) + 0.5) 
        else
            props_norm.x = proj_x 
            props_norm.y = proj_y  
        end
--]=]
        props_norm.x = proj_x 
        props_norm.y = proj_y 
        
        created_elm.props_norm = props_norm
        --created_elm.prop_defaults = GUI.table_copy(elm.prop_defaults)
    
    else
        -- Add additional data back in.
        -- Must use tmp because elm has been deleted.
        -- ??? Or should I just use store_elm_defaults?
        -- ??? Do I need to compensate for knob centered?
        created_elm.props_norm = tmp_props_norm
        --created_elm.prop_defaults = tmp_props_defaults
        
        --Element.store_elm_defaults(GUI.elms[new_name or orig_name], proj_x, proj_y)
          
    end
    
    created_elm.props_norm.name = created_elm.name
    
    -- Restore text editor retval.
    if created_elm.type == "dh_TextEditor" or  created_elm.type == "TextEditor" 
       or created_elm.type == "dh_Textbox" or  created_elm.type == "Textbox" 
    then
        GUI.Val(created_elm.name, retstr)
    end

    Element.add_GB_methods(created_elm)

    if selected then
        
        --local page = GUI.elms.GB_mnu_pages and GUI.elms.GB_mnu_pages.retval
        local page = GUI.elms.GB_mnu_pages and GUI.elms.GB_mnu_pages.curr_opt        
        Properties.init_properties(created_elm, page)
        
        GUI.elms.GB_frm_sel_elm.elm = created_elm.name

    end

end


-- DEPENDS: GUI STATE
-- Clear all property elements
function Properties.clear_properties()

    GUI.Val("GB_side_elm_type", "No element selected")    

    for k in pairs(GUI.elms) do

        if string.match(k, "GB_prop_") or string.match(k, "GB_mnu_pages") then 
            GUI.elms[k]:delete() 
        end
        
    end
    
    GUI.redraw_z[5] = true
    
end

--zznew  
-- DEPENDS: CLASS_PROPERTIES, GUI STATE
function Properties.new_property(property, elm, pos)

    local prop = property.prop
    local name = "GB_prop_" .. prop
    local class = property.class
    
    --GUI.Msg("\n# Properties.new_property name : " .. name)
    --GUI.Msg("          new_property class : " .. class)
    --GUI.Msg("          new_property prop : " .. prop)      
    --GUI.Msg("          new_property caption : " .. property.caption) 

    -- w  = {prop = "w", caption = "W", class = "Number"}
    -- # Number should have all of the properties of Textbox.
    
    -- Shift some metrics if name.
    -- ref_properties = {x = 148, y = 60, w = 144, h = 24, off = 28}
    local ref_x = (prop == "name") and 16 or ref_properties.x 
    local ref_y = (prop == "name") and (ref_properties.y + 16) 
                    or ref_properties.y
    local ref_w = (prop == "name") and (SIDEBAR_WIDTH - 32) 
                    or ref_properties.w

    -- !!! Since gfx is open this also calls the elms init().
    
    GUI.New({
        name = name,
        type = Property[class],
        z = 5,
        
        --x = (ref_properties.x + WORKSPACE_WIDTH),
        x = ref_x + WORKSPACE_WIDTH,
        --y = (ref_properties.y + ref_properties.off * pos),
        y = (ref_y + ref_properties.off * pos),
        --w = ref_properties.w,
        w = ref_w,
        
        h = ref_properties.h,
        caption = property.caption,
        class = property.class,
        prop = property.prop,
        col_cap_bg = "panel_bg",
        col_cap_text = "panel_txt",
        col_backdrop = "panel_bg",
        font_caption = "sans22",
        --cap_pos = "left",
        cap_pos = (prop == "name") and "top" or "left",
        elm = elm.name,
        subclass = property.subclass,
        recreate = property.recreate, 
        needs_init = property.needs_init, 
    })
    
    --GUI.Msg("    Properties.new_property after GUI.New : self.curr_opt : " .. tostring(self.curr_opt) or "no curr_opt")
    
    -- This is a reference to Property elm.
    local self = GUI.elms[name]

    if DHTK.APP_SCALE ~= 1 then
        --GUI.Msg("> Boolean:init optarray : " .. self.optarray[1])
        --GUI.Msg("> new property scaling ")
        DHTK.scale_elm(self)
        self:init()
    end

    -- # Get value for display. 
    -- Skip if done in init override (in class_Properties).
    -- Need to get scalable properties from props_norm.
    
    -- # elm is selected elm.
    -- Setting value with GUI.Val() redraws elm.
--zzknob    
    if elm.props_norm[prop] then

        if class == "Align" 
            or class == "Cap_Pos"
            or class == "Comp_Style"
            or class == "Direction"
            or class == "Line_Height"
            or class == "List"
            or class == "Min_Max_Vals"
            or class == "MonoFont"
            or class == "Z_Sets"
        then
            -- Got value in self:init()
            goto cont

        -- All others.    
        else
            GUI.Val(name, elm.props_norm[prop])
            --GUI.Msg("    new prop val : " .. prop .. "  :  " .. tostring(GUI.Val(name)))
            --GUI.Msg("    new prop from props_norm val : " .. prop .. "  :  " .. tostring(elm.props_norm[prop]))
        end
        
        --GUI.Msg("    new prop from norm")
        
        ::cont::          
        
    else
        -- Should never arrive here.
        GUI.Val(name, elm[prop])

    end 
     
    --GUI.Msg("# end Properties.new_property : self.curr_opt :   " .. tostring(self.curr_opt))
    
end


-- DEPENDS: CLASS_PROPERTIES, GUI STATE
function Properties.init_mnu_pages(page, numpages)
    
    local pages = {}
    for i = 1, numpages do
        pages[i] = i .. " of " .. numpages
    end
    --pages = table.concat(pages,",")           
    
    local mnu_offset = (ref_properties.w - 92) / 2

    GUI.New({
        name = "GB_mnu_pages",
        type = "dh_Menubox",
        z = 5,
        x = (WORKSPACE_WIDTH + ref_properties.x + mnu_offset) * DHTK.APP_SCALE,
        y = (MENUBAR_HEIGHT + 20) * DHTK.APP_SCALE,
        w = 92 * DHTK.APP_SCALE,
        h = 28 * DHTK.APP_SCALE,
        optarray = pages,
        caption = "",
        col_backdrop = "panel_bg",
        font_text = "sans24",
    })
        
    --GUI.Msg("\n** Properties.init_mnu_pages > page : " ..  tostring(page))
    
    --GUI.elms.GB_mnu_pages.font_text = "sans24"        
    GUI.elms.GB_mnu_pages.align = 1
    GUI.elms.GB_mnu_pages.col_txt = "elm_txt"
    
    -- Append the menubox's onmouseup(?) and onwheel methods
    function GUI.elms.GB_mnu_pages:onmouseup()
       
        GUI.dh_Menubox.onmouseup(self)
        
        --Properties.init_properties(GUI.elms[GUI.elms.GB_frm_sel_elm.elm], self.retval)
        --GUI.elms[GUI.elms.GB_frm_sel_elm.elm].curr_menu_page = self.retval
        Properties.init_properties(GUI.elms[GUI.elms.GB_frm_sel_elm.elm], self.curr_opt)
        GUI.elms[GUI.elms.GB_frm_sel_elm.elm].curr_menu_page = self.curr_opt        
        
    end
    
    function GUI.elms.GB_mnu_pages:onwheel()
        
        GUI.dh_Menubox.onwheel(self)
        
        --Properties.init_properties(GUI.elms[GUI.elms.GB_frm_sel_elm.elm], self.retval)
        Properties.init_properties(GUI.elms[GUI.elms.GB_frm_sel_elm.elm], self.curr_opt)        
        
    end

    GUI.Val("GB_mnu_pages", page)

end


-- Create property elements for the current element.

function Properties.init_properties(elm, curpage)

    --GUI.Msg("\n** Properties.init_properties **\n")
    Properties.clear_properties()
--zznew    
    --GUI.elms.GB_side_elm_type.z = -2
    GUI.Val("GB_side_elm_type", elm.type)
    --GUI.Val("GB_lbl_cur_elm", "Current element:")
    
    -- Create the new property elements and load them from the elm
    -- Why are these being stored on the elm again? Remembering defaults?
    local properties = GUI[elm.type].GB.properties
    
    -- For tag entries
    local skip = 0
    local numpages, page = 0
    local done_elms
    
    for i = 1, #properties do
    
        -- Spacer entries; do nothing
        if properties[i] == "" then
            --GUI.Msg("  if properties = empty string")
        -- Page numbers
        elseif type(properties[i]) == "string" then
            --GUI.Msg("  if properties = string: " .. properties[i])
            numpages = numpages + 1
            
            -- End of current page
            if page and not done_elms then
                --GUI.Msg("  End of current page")
                done_elms = true
                
            -- Haven't seen a page header yet, requested page is this one, or not given
            else

                if not page
                and (not curpage or numpages == math.floor(curpage)) then
                
                    page = numpages
                    skip = i
                
                end
                
            end
            
        -- Only create elements if they're on the active page, or p1 if not given            
        elseif not done_elms and (page or (not page and not curpage)) then
        
            --GUI.Msg("  call new_property : " .. properties[i].prop)
            
            Properties.new_property(properties[i], elm, i - skip)
        end

    end
    --GUI.Msg("  page: " .. tostring(page) .. "")
    --GUI.Msg("  numpages: " .. tostring(numpages) .. "")
    --GUI.Msg("\n** Properties.init_properties > page : " ..  tostring(page))
    --GUI.Msg("\n** Properties.init_properties > curpage : " ..  tostring(curpage))    

    if page then
        
        --Properties.init_mnu_pages(page, numpages)
        Properties.init_mnu_pages(curpage or page, numpages)

    end

end


return Properties