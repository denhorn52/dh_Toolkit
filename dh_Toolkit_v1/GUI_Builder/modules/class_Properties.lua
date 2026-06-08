-- NoIndex: true

-- class_Properties.lua
-- Modified 20260506


--[===[

Subclesses for the Property elements which get displayed in the Sidebar.

The selected element is the user added element in the project area which is currently selected.
The selected element's properties are updated with the (validated) value in the sidebar is changed.

Property Textbox: clicking the Enter button click or clicking outside the textbox ->
    lostfocus calls "generic" apply_value which validates then applies value to selected element.
    
Property Checklist (Booleans): onmouseup handler updates selected element.

Property Menubox: onmouseup calls self:apply_value which validates then applies value to selected element.

Property Button: 
--]===]

--------------------------------------
--------  Property classes  --------
--------------------------------------

--local Element = require("func_Elements")
--local json = require("common/json")
--local Editor = require("func_Editor")

local Property = {}

Property.Name         = GUI.table_copy(GUI.dh_Textbox)
Property.String       = GUI.table_copy(GUI.dh_Textbox)
Property.Number       = GUI.table_copy(GUI.dh_Textbox)
Property.Integer      = GUI.table_copy(GUI.dh_Textbox)
Property.Boolean      = GUI.table_copy(GUI.dh_Checklist)

Property.Font         = GUI.table_copy(GUI.dh_Textbox)
Property.Color        = GUI.table_copy(GUI.dh_Textbox)

Property.Coord_Y      = GUI.table_copy(GUI.dh_Textbox)
Property.Coord_Z      = GUI.table_copy(GUI.dh_Textbox)

Property.Menu_Titles  = GUI.table_copy(GUI.dh_Textbox)
Property.Table        = GUI.table_copy(GUI.dh_Textbox)
Property.Min_Max_Vals = GUI.table_copy(GUI.dh_Textbox)
Property.Editor       = GUI.table_copy(GUI.dh_Button)

Property.Align        = GUI.table_copy(GUI.dh_Menubox)
Property.Cap_Pos      = GUI.table_copy(GUI.dh_Menubox)
Property.Direction    = GUI.table_copy(GUI.dh_Menubox)
Property.Line_Height  = GUI.table_copy(GUI.dh_Menubox)
Property.List         = GUI.table_copy(GUI.dh_Menubox)
Property.MonoFont     = GUI.table_copy(GUI.dh_Menubox)

-- ? Propose use for dh_Knob centered.
--Property.Knob_Center = GUI.table_copy(GUI.dh_Textbox)

--------------------------------------
------  Shared methods/params ------
--------------------------------------
--zzapply --zzbool --zzdir --zzcap --zzmono  --zzlh --zzalign --zzlist -- zzset  --zztable

-- Pass the property's new value to its target element.
-- Checklists(boolean) and Menuboxes have their own apply_value.
-- This should only need to handle textboxes.
-- self.prop is property name

local function apply_value(self)

    --GUI.Msg("\n****   APPLY VALUE   ****\n")
    --GUI.Msg("  self.name is : " .. self.name)    
    --GUI.Msg("  self.class is : " .. self.class)    

    -- Get reference to selected elm.
    -- self.elm is selected element name.
    
    local sel_elm = GUI.elms[self.elm]
    --GUI.Msg("  self.elm name is : " .. sel_elm.name)    
    
    -- Make sure the value is valid, otherwise revert.
    local val = self:validate()

    --GUI.Msg("  self.value is : " .. tostring(val))

    if val then
    
        --GUI.Msg("    if val prop  : " .. self.prop)
        --GUI.Msg("    if val value : " .. tostring(val))

        if (self.class == "Number") or (self.class == "Integer") then
            
            --GUI.Msg("    in if self.class == 'Number' class : " .. self.class)
            --GUI.Msg("    if Number : prop  : " .. self.prop)
            --GUI.Msg("    if Number : val  : " .. val)             
            --GUI.Msg("    if Number : type val  : " .. type(val))
--zzknob
            -- !!! Special cases.
            if sel_elm.type == "dh_Knob" and sel_elm.centered 
                and (self.prop == "x" or self.prop == "y" or self.prop == "w") then

                if self.prop == "x" then  
                    -- Subtract rad.
                    val = (val - (sel_elm.w // 2))

                elseif self.prop == "y" then
                
                    GUI.Msg("    APPLY val dh_Knob y : " .. val)
                    GUI.Msg("    type of dh_Knob y : " .. type(val))                    
                  
                    -- Subtract rad, add menu.h, then scale.
                    --val = (val + MENUBAR_HEIGHT - (sel_elm.w // 2))
                    
                    -- Subtract rad then scale.
                    val = (val - (sel_elm.w // 2))                     

                else --if self.prop == "w" then 
                    -- Force width to even so x,y not fractional. 
                    if val % 2 == 1 then 
                        val = val + 1 
                        self:val(val)
                    end

                    local rad = math.floor((val / 2) + 0.5)
                    
                    -- Store new norm x value.
                    local c = GUI.Val("GB_prop_x") -- center x
                    sel_elm.props_norm.x = math.floor((c - rad) + 0.5)
                    -- Set elm x coord to center for init.
                    sel_elm.x = sel_elm.props_norm.x * DHTK.APP_SCALE
    
                    -- Store new norm y value.
                    c = GUI.Val("GB_prop_y") -- center
                    sel_elm.props_norm.y = math.floor((c - rad) + 0.5)
                    -- Set elm y coord to center for init.
                    sel_elm.y = (sel_elm.props_norm.y + MENUBAR_HEIGHT) * DHTK.APP_SCALE
                end

            end  -- <if knob>
            
            -- Can do these here or in validate integer.
            if self.prop == "track_thk" then
                if val < 4 then val = 4 end
            end
            
            if self.prop == "scrollbar_width" then
                if val < 8 then val = 8 end
            end
            
            -- Store normalized adjusted value.
            sel_elm.props_norm[self.prop] = val
            --GUI.Msg("    sel_elm.props_norm : " .. tostring(sel_elm.props_norm[self.prop]))
            
            if self.prop == "y" then
                val = val + MENUBAR_HEIGHT
            end            

            -- Scale it to current app scale.
            
            if not self.noscale then
                if self.class == "Integer" then
                    val = math.floor(val * DHTK.APP_SCALE + 0.5)
                else
                    val = val * DHTK.APP_SCALE                
                end
            end
                       
            --GUI.Msg("    scaled value is : " .. tostring(val)) 

        else
            -- Store non-number value (Could be table).
            sel_elm.props_norm[self.prop] = val
        
        end  -- if number

        --GUI.Msg("    after if Number : prop  : " .. self.prop)
        --GUI.Msg("    after if Number : val  : " .. val)             
        --GUI.Msg("    after if Number : type val  : " .. type(val))
        --if type(val) == "table" then
        --    GUI.Msg("    after if Number : val[1]  : ") -- .. val[1])
        --end        
        
        sel_elm[self.prop] = val
        
        -- INIT, RECREATE, OR REDRAW?
        -- Will recreate init? Yes
        
        --??? Do I need to pass proj_x, proj_y?
        if self.recreate then 
            Properties.recreate_elm(sel_elm, nil, true) 
        else
            if self.needs_init == false then goto skip_init end
            
            sel_elm:init()
            
            ::skip_init::
        end
        
        sel_elm:redraw()
        
        -- Only really necessary for x,y,w,h ?
        GUI.elms.GB_frm_sel_elm:redraw()

    else
        -- val is nil.
        
        -- Don't want to revert value.
        -- Warn user of illegal value.
        if self.numbers_only then
            reaper.MB("Invalid Table for : " .. self.prop, "Oops!", 0)
            return
        end        
        
        -- Revert to non-changed value from selected elm.

        self:val(sel_elm[self.prop])
        
        --GUI.Msg("self.value else is : " .. tostring(val))    
        
            
    end  -- <if val>

end  --<apply_value>

-- All property textboxes should apply their value when focus is lost.

local function lostfocus(self)

    --GUI.Msg("# generic lost focus -> apply_value?")

    self:apply_value()
    
    --[=[
    -- Need to transfer text editor retval when recreating elm.
    -- Can't seem to transfer  anywhere else.- Maybe because it's not in GB props?
    local retstr
    
    if GUI.elms[self.elm].type == "dh_TextEditor" or  GUI.elms[self.elm].type == "TextEditor" then
        retstr = GUI.elms[self.elm]:val()
    end
    
    if self.recreate then Properties.recreate_elm(GUI.elms[self.elm], nil, true) end
    
    if GUI.elms[self.elm].type == "dh_TextEditor" or  GUI.elms[self.elm].type == "TextEditor" then
        GUI.Val(self.elm, retstr)
    end
    --]=]
    
    GUI[self.type].lostfocus(self)
    --self:redraw()
        
end


local function revert_value(self)

    local sel_elm = GUI.elms[self.elm]

    gfx.x, gfx.y = GUI.mouse.x, GUI.mouse.y
    
    -- Do not handle Lokasenna elements.    
    local can_revert = (not self.recreate) and (string.find(sel_elm.type, "dh_"))
    local retval = gfx.showmenu(can_revert and "Revert to default value" or "#This property cannot be reverted")
    
    if retval and retval > 0 then

        --local new = sel_elm.prop_defaults[self.prop]
        local def_val = GUI[sel_elm.type].defaults[self.prop]
--zzknob        
        if (sel_elm.type == "dh_Knob") and (self.prop == "centered") then
            --GUI.Msg("  revert_value : knob centered")
            --GUI.Msg("  def_val : " .. tostring(def_val)) 
                       
            -- Assuming dh_Knob.centered default is true.
            -- This is right-click so checkbox has not been toggled.    
            -- Need to do several things.
            
            if self.optsel[1] == false then
                --GUI.Msg("is false")
                sel_elm.centered = true
                sel_elm.props_norm.centered = true
                sel_elm.props_norm.x = sel_elm.props_norm.x + sel_elm.props_norm.w // 2
                sel_elm.props_norm.y = sel_elm.props_norm.y + sel_elm.props_norm.w // 2            
                GUI.Val("GB_prop_x", sel_elm.props_norm.x)
                GUI.Val("GB_prop_y", sel_elm.props_norm.y)
            end 

        end
        
        --GUI.Msg("revert_value self.prop : " .. self.prop)
        --GUI.Msg("reverted value : " .. tostring(def_val))                
        sel_elm[self.prop] = def_val
        sel_elm:init()
        sel_elm:redraw()
        
        if self.type == "dh_Menubox" then
            def_val = GUI.table_find(self.optarray, def_val)
        end

        self:val(def_val)
        self:lostfocus()
        self:redraw()
      
    end
    
end

-- Common methods
-- apply_value will use generic apply_value
-- unless a Property overrides it.
-- Same for lostfocus.

for class in pairs(Property) do
    
    Property[class].apply_value = apply_value  
    Property[class].lostfocus = lostfocus
    Property[class].onmouser_up = revert_value
    
end

--------------------------------------
-------- Class-specific ------------
-------- methods and params --------
--------------------------------------

-- Creation params for each type of property
-- (Not including name,type,z,x,y,w,h,caption, since they're determined at runtime.
-- dh. Could not get this to be useful.

Property.Boolean.extra_params = {""}
    
------------------------------------
------  validate functions  ------
------------------------------------
function Property.String:validate()
    return tostring(self:val())
end

function Property.Number:validate()
    if tonumber(self:val()) then
        return tonumber(self:val())
    end
end

function Property.Integer:validate()
    if tonumber(self:val()) then
        return GUI.round(tonumber(self:val()))
    end
end

function Property.Font:validate()
    local val = self:val()
    if GUI.fonts[tonumber(val)] then
        return tonumber(val)
    elseif GUI.fonts[val] then
        return val
    end
end

function Property.Color:validate()
    local val = self:val()
    if GUI.colors[val] then
        return val
    elseif GUI.colors[tonumber(val)] then
        return tonumber(val)
    end
end

------------------------------
----------  NAME  ----------
------------------------------
function Property.Name:lostfocus()
    
    --GUI.Msg("\n# Property.Name:lostfocus : " )
    
    GUI[self.type].lostfocus(self)
    
    -- Make sure the value is valid, otherwise revert
    local val = self:validate()
    
    if val then
        Properties.rename_elm(self, val)
    else
        self:val(GUI.elms[self.elm][self.prop])
    end    
        
end

-- Don't allow duplicate names
function Property.Name:validate()
    local val = self:val()
    if val and val ~= "" and not GUI.elms[val] and not string.match(val, "^GB_") then
        return tostring(self:val())
    end
end

---------------------------------
----------  COORD_Z  ----------
---------------------------------
--zzcz
-- lost focus called validate
-- validate calls val without newval
-- val tries to add to 10
--   if is not number crashes
-- Now do it all here.

function Property.Coord_Z:lostfocus()

    --GUI.Msg("\n## Property.Coord_Z:lostfocus : " )
    
    GUI[self.type].lostfocus(self)
    
    --local val = self:validate()
    local val = tonumber(self.retval)
    
    --GUI.Msg("    lostfocus : type val : " .. type(val))
    --GUI.Msg("    val : " .. tostring(val))
          
    if val then
    
        -- Limit range of z.
        val = GUI.round(tonumber(val))        
        local legal = GUI.clamp(1, val, 460)
        if val ~= legal then val = legal end
        
        -- This is what will be exported.
        GUI.elms[self.elm].props_norm[self.prop] = val                

        -- Offset so 1-10 can be reserved for GB stuff.
        -- This is what is used in workspace.
        val = val + 10
        
        GUI.elms[self.elm][self.prop] = val
        GUI.elms[self.elm]:redraw()

        GUI.elms.GB_frm_sel_elm:redraw()
        
        --GUI.Msg("    elm.z : " .. tostring(GUI.elms[self.elm].z))
        --GUI.Msg("    props_norm.z : " .. tostring(GUI.elms[self.elm].props_norm.z))
        
        -- Need to draw even hidden elms in case using tabs,
    	for key, __ in pairs(GUI.elms) do
            --GUI.elms[key]:init()
            GUI.elms[key]:redraw()
        end                
        
    else
        -- If not a good value restore property display.
        self:val(GUI.elms[self.elm][self.prop])
    end
    
end

-- Offset so 1-10 can be reserved for GB stuff
-- Crashes script if retval is not number.
-- Getting newval from props_norm indirectly through mew property..

function Property.Coord_Z:val(newval)

    --GUI.Msg("#   Property.Coord_Z:val " )
    
    if newval then
        --GUI.Msg("       newval : "  .. newval)        
        self.retval = tonumber(newval) -- 10
        self:redraw()
    else
        --??? Don't think this gets called, or if it does it shouldn't add 10?
        --GUI.Msg("####       self.retval : "  .. self.retval)            
        return self.retval + 10
    end
    
end

-- I find this confusing. Would think should pass a value to validate.
-- Getting its value from val which needs a validated value.
--[=[
function Property.Coord_Z:validate()

    --GUI.Msg("   Property.Coord_Z:validate " )

    return tonumber(self:val())

end
--]=]

---------------------------------
----------  COORD_Y  ----------
---------------------------------
-- Offset for the menu bar.
-- Not currently using as menubar hgt adj made at usage points.
-- Maybe can reimplement if allow for app scaling.

function Property.Coord_Y:val(newval)

    if newval then
        self.retval = tonumber(newval) - MENUBAR_HEIGHT
        self:redraw()		
    else
        return tonumber(self.retval) + MENUBAR_HEIGHT
    end   

end

function Property.Coord_Y:validate()
    return tonumber(self:val())
end

------------------------------------
---------  MENU TITLES  ----------
------------------------------------
--zzmnu
-- Replaced with Editor.

function Property.Menu_Titles:validate()
    local val = self:val()
    return type(val) == "table" and val
end

function Property.Menu_Titles:val(newval)

    --GUI.Msg("   Property.Menu_Titles:val " )
    
    if newval then
        
        local titles = {}
        for i = 1, #GUI.elms[self.elm].menus do
            titles[i] = GUI.elms[self.elm].menus[i].title
        end
        self.retval = table.concat(titles, ",")
        
    else
    
        -- Applying to the menubar
        local menus = {}
        for v in string.gmatch(self.retval, "[^,]*") do
            table.insert(menus, {title = v, options = {}})
        end
                
        return menus
        
    end
    
end

--[=[ 
function Property.Menu_Titles:apply_value()
    
    GUI[self.type].lostfocus(self)
   
    local val = self:validate()
    
    if val then
        -- Make the titles accessible for get_creation_params
        GUI.elms[self.elm].titles = val
    else
        self:val(GUI.elms[self.elm][self.prop])
    end
    
end
--]=]

---------------------------------
--------  MIN_MAX_VALS  --------
---------------------------------
-- Values must be in format: {{0,"0"}, {6,"6"}, {12,"12"}}
-- List of {position: integer, display string}
-- Replaced with Editor.

-- This gets called everytime a knob is selected.

function Property.Min_Max_Vals:init()

    --GUI.Msg("# Property.Min_Max_Vals:init : " )

    -- Convert selected knob min_max_values to string for display in textbox.
    
    local status, result = pcall(function()
        --GUI.Msg("# Property.Min_Max_Vals in pcall : ")
        local json_str = json.encode(GUI.elms[self.elm].min_max_values)
        --GUI.Msg("# Property.Min_Max_Vals:init json_str : " .. json_str)
        return json_str
    end) 
  
    if status then
        --return result
        --GUI.Msg("# Property.Min_Max_Vals:init result : " .. result)        
        self:seteditorstate(tostring(result))
		self:redraw()          
    else
        -- Popup error message.
        reaper.ShowMessageBox("Error occurred loading Min_Max Values.", "Notice!", 0)
    end     
    
    GUI[self.type].init(self)
    
end

function Property.Min_Max_Vals:lostfocus()

    --GUI.Msg("# Property.Min_Max_Vals:lostfocus : " )
    
    GUI[self.type].lostfocus(self)
    
    -- Take textbox retval and convert it to table to pass to selected elm.
    -- I think validate will have to do the heavy liftimg. 
    
    local val = self:validate()
    
    --GUI.Msg("    lostfocus : type val : " .. type(val))
      
    if val then

        -- Should now have a table decoded from json string displayed in textbox.
        
        self:apply_value(val)
        
    else
        -- If not a good value restore property display.
        -- No, I think I'll leave for the app designer to correct.
        --self:val(GUI.elms[self.elm][self.prop])
    end
    
end

-- Need to override generic apply_value.

function Property.Min_Max_Vals:apply_value(val)

    --GUI.Msg("# Property.Min_Max_Vals:apply_value : " )

    GUI.elms[self.elm][self.prop] = val
    GUI.elms[self.elm].props_norm[self.prop] = val
    
    -- ??? Do I need reinit?
    
    GUI.elms[self.elm]:redraw()
    GUI.elms.GB_frm_sel_elm:redraw()

end

--zzminmax   {{0,"0"}, {6,"6"}, {12,"12"}}

-- Try to take textbox retval [string] and convert it to table and pass it to selected elm.
-- If textbox retval can be converted to a json string all should be good.
-- If decode fails pcall should return status false.
-- Return data table to update selected elm min_max_values.

function Property.Min_Max_Vals:validate()

    --GUI.Msg("   Property.Min_Max_Vals:validate " )
    
    local status, result = pcall(function()
        --GUI.Msg("   self.retval :  " .. self.retval)
        return json.decode(self.retval)
    end)
  
    if status then
        return result  
    else
        -- Popup error message.
        reaper.ShowMessageBox("Error occurred processing Min_Max Values.\nBe sure that data is entered correctly.", "Notice!", 0)
        
        return nil
    end  
  
end

-- Don't think I need this. Inaccurate as is, anyway.
-- Doesn't appear this is ever called.
function Property.Min_Max_Vals:val(newval)

    --GUI.Msg("   Property.Min_Max_Vals:val " )
    
    -- I can feed this a json string?
    -- If invalid will crash script. xpcall?
    
    if newval then
    
        local json_str = json.decode(newval)
        self:seteditorstate(tostring(newval))        
        self:redraw()
    else
    
        local json_str = json.encode(self.retval)
    
        return json_str 
    end
    
	if newval then
        self:seteditorstate(tostring(newval))
		self:redraw()
	else
		return self.retval
	end    
    
end

-------------------------------
----------  TABLE  ----------
-------------------------------
--zztable

-- Called from apply_value when property element loses focus.
-- self:val converts cvs string to table to update selected elm.
-- Need to validate only numbers for some tables.


function Property.Table:validate()

    --GUI.Msg("# Property.Table:validate : " )
    
    local val = self:val()
    
    --GUI.Msg("    type of val : " .. type(val))
    
    return self:val()
    
end

-- Called when property is created with value from selected elm,
--   GUI.Val(GB_prop name, sel_elm.props_norm[prop])
--   Converts to csv string for display. Assumes legit table.
-- When property elm loses focus, apply_value is called
--   which calls validate which calls this to get value.
--   value is the csv string which, if numbers_only,
--   needs its items to be converted back to numbers. 

function Property.Table:val(newval)

    if newval then

        if type(newval) == "table" then

            local vals = {}
            for i = 1, #newval do
                vals[i] = newval[i]
            end
            
            self.retval = table.concat(vals, ",")
        
        end

    else
    
        local vals = {}
        for v in string.gmatch(self.retval, "[^,]*") do
        
            --GUI.Msg("    type of val : " .. type(v))
            --GUI.Msg("            val : " .. tostring(v))
        
            if self.numbers_only then
                if tonumber(v) then
                    v = tonumber(v)
                else
                    return nil
                end
            end    
        
            table.insert(vals, v)
            
        end

        return vals
        
    end

end

--------------------------------------
------  Editor  (dh_Button)  ------
--------------------------------------
--zzset
function Property.Editor:init()

    --GUI.Msg("\n## Property.Editor:init ")
    --GUI.Msg("     Editor type : " .. self.subclass)    
    
    if self.subclass == "menu_titles" then
        self.text = "Menu Titles" 
    elseif self.subclass == "min_max_values" then
        self.text = "Min-Max values" 
    elseif self.subclass == "graph_labels" then
        self.text = "Graph Labels"
    elseif self.subclass == "options" then
        self.text = "Options"
    elseif self.subclass == "tab_titles" then
        self.text = "Tab Titles"
    elseif self.subclass == "z_sets" then
        self.text = "Z_sets"
    end
    
    GUI[self.type].init(self)
end

-- Editor used to open editor.

function Property.Editor:onmouseup()
    GUI[self.type].onmouseup(self)
    
    --if self.subclass == "tab_titles" then
    --    Editor.open_editor("z_sets")
    --elseif self.subclass == "z_sets" then
    --    Editor.open_editor("z_sets")
    --end
    
    Editor.open_editor(self.subclass)
    
end

function Property.Editor:apply_value()

end

--------------------------------------
------  Boolean  (checklist)  ------
--------------------------------------
--zzbool  

function Property.Boolean:init()

    --GUI.Msg("> Boolean:init prop name : " .. self.elm)  
    --GUI.Msg("> Boolean:init caption : " .. self.caption)
    --GUI.Msg("> Boolean:init caption type: " .. type(self.caption)) -- string
    --GUI.Msg("> Boolean:init optarray : " .. self.optarray[1]) -- optarray is initially nil.   
    
    -- When scaling self.caption has already been set to "".
    if self.caption ~= "" then    
        self.optarray = {self.caption}
        self.caption = ""    
    end

    --self.pad = 4
    self.pad_x = 2
    self.pad_y = 2
    self.border_width = 0
    self.col_bg = "panel_bg"
    self.col_text = "panel_txt"  
    self.col_opt_outline = "panel_txt"
    self.col_opt_fill = "panel_txt"              
    GUI[self.type].init(self)
    
end

function Property.Boolean:lostfocus()
    --GUI.Msg("\n** Property.Boolean.lostfocus self.name ** : " .. self.name)
    GUI[self.type].lostfocus(self)
end

-- Not all checklist properties need itit().
-- Do any need recreate? fullwidth?
-- Maybe I can add need_init boolean to Property.

function Property.Boolean:onmouseup()

    --GUI.Msg("\n** Boolean.onmouseup self.name ** : " .. self.name)

    -- Checklist mouseup 
    --   sets optsel[1] to true/false.
    --   sets its self.focus to false
    --     preventing its self:lostfocus() from being called?
    --     WHY?
    --   calls redraw.
    -- !!! Shouldn't need to call native handler. Only one option.
    
    --GUI[self.type].onmouseup(self)
	self.optsel[1] = not self.optsel[1]
    self:redraw()
    
    -- Should the rest of this can be rolled into apply_value
    --   if including special case for dh_Knob?
    
    -- ## Reference to selected project elm.
    local sel_elm = GUI.elms[self.elm]
    
    --GUI.Msg("      val : " .. tostring(self.optsel[1]))
    --GUI.Msg("      elm.type : " .. elm.type)
    --GUI.Msg("      self.prop : " .. self.prop)
    
    sel_elm[self.prop] = self.optsel[1]
    sel_elm.props_norm[self.prop] = self.optsel[1]

    -- Special case for dh_Knob. Only affects displayed values.
--zzknob
    if (sel_elm.type == "dh_Knob") and (self.prop == "centered") then
        if self.optsel[1] == false then
            --GUI.Msg("is false")
            sel_elm.centered = false
            sel_elm.props_norm.centered = false
            sel_elm.props_norm.x = sel_elm.props_norm.x - sel_elm.props_norm.w // 2
            sel_elm.props_norm.y = sel_elm.props_norm.y - sel_elm.props_norm.w // 2            
            GUI.Val("GB_prop_x", sel_elm.props_norm.x)
            GUI.Val("GB_prop_y", sel_elm.props_norm.y)
        else
            --GUI.Msg("is true")
            sel_elm.centered = true
            sel_elm.props_norm.centered = true
            sel_elm.props_norm.x = sel_elm.props_norm.x + sel_elm.props_norm.w // 2
            sel_elm.props_norm.y = sel_elm.props_norm.y + sel_elm.props_norm.w // 2             
            GUI.Val("GB_prop_x", sel_elm.props_norm.x)
            GUI.Val("GB_prop_y", sel_elm.props_norm.y)
        end
        
        return
    end
    
    -- Special case for allow highlight.
    
    -- Set elm.focus to true but is false when redraw.
    -- ? Maybe try adding Boolean:lostfocus and moving it there.

    if self.prop == "allow_sel_outline" then
        --GUI.Msg("      allow_sel_outline : " .. tostring(self.optsel[1]))
        sel_elm.focus = true
        --elm:redraw()
        --elm:onmousem_down()
        
        return
    end 

    if self.needs_init == false then goto skipped end
      
    --GUI.Msg("    calling sel_elm:init() with elm.name: " .. self.elm)
    --GUI.Msg("    self.needs_init == false ")
    
    sel_elm:init()
    
    ::skipped::
        
    --GUI.Msg("bool mouseup call elm init")        
    --GUI.Msg("bool mouseup elm : " .. sel_elm.name)
    --GUI.Msg("    prop : " .. self.prop .. " : " .. tostring(self.optsel[1]))
    --GUI.Msg("    prop type : " .. tostring(type(self.optsel[1])))
        
    GUI.redraw_z[sel_elm.z] = true
    
    GUI.elms.GB_frm_sel_elm:redraw()
            
end

-- ??? Necessary? self:val does this?
function Property.Boolean:validate()
    --GUI.Msg("Boolean validate : " .. tostring(not not self:val()))
    return not not self:val()
end

-- Override checklist:val(). Only one option.
function Property.Boolean:val(newval)

    --GUI.Msg("Boolean:val")
    
    if newval ~= nil then
        self.optsel[1] = not not newval
    else
        return self.optsel[1]
    end   

end 

---------------------------------
------  Align (menubox)  ------
---------------------------------
--zzalign --zzz  

function Property.Align:init()

    --GUI.Msg("\n** Property.Align:init : " .. self.name)
    
    -- gfx.drawstring flags for positioning.
    if (self.prop == "display_align") or
       (self.prop == "align_text") then
        --self.optarray = {"0", "1", "2"}
        self.optarray = {"left", "center", "right"}
    else
        self.optarray = {"0", "2", "4", "8"}
    end
    
    -- Get integer value from project elm.
    local av = GUI.elms[self.elm][self.prop]
    
    --GUI.Msg("\n** Property.Align:init av : " .. tostring(av))
        
    self.curr_opt = GUI.table_find(self.optarray, tostring(av))
    
    --GUI.Msg("\n** Property.Align:init self.curr_opt : " .. tostring(self.curr_opt))    
    
    self.cap_pos = "left"
    --self.noarrow = false
    --self.pad = 4
    --self.cap_pad_y = 4
    --self.col_backdrop = "panel_bg"
    
    -- Disable wheel.
    self.onwheel = function() end
    
    --GUI.Msg("    before call to GUI[self.type].init(self) curr_opt is : " .. tostring(self.curr_opt))
    --GUI.Msg("    before call to GUI[self.type].init(self) self.type is : " .. tostring(self.type))        
    
    GUI[self.type].init(self)
    
    --GUI.Msg("    after call to GUI[self.type].init(self) curr_opt is : " .. tostring(self.curr_opt))

end

function Property.Align:onmouseup()
    GUI[self.type].onmouseup(self)
    self:apply_value()
end

function Property.Align:apply_value()

    --GUI.Msg("\n## Property.Align:apply_value : " .. self.name)

    -- Reference to selected project elm.
    local sel_elm = GUI.elms[self.elm]    

    -- Get selected value as string.
    local val = self.optarray[self.curr_opt]
    
    --GUI.Msg("    apply_value: val is: " .. val)
    --GUI.Msg("    apply_value: self.curr_opt is: " .. self.curr_opt)
        
    if val then
    
        --GUI.Msg("    # Inside IF val  ")
        --GUI.Msg("    apply_value: val is: " .. val)
        --GUI.Msg("    apply_value: self.curr_opt is: " .. self.curr_opt)
           
        if (self.prop ~= "display_align") and (self.prop ~= "align_text") then
            --GUI.Msg("    not display_align or align_text  ")
            val = tonumber(val)
        end    
                            
        
        sel_elm[self.prop] = val
        sel_elm.props_norm[self.prop] = val 
        
        -- Should only need to redraw.
        sel_elm:redraw()

    else
        --GUI.Msg("    # Inside if ELSE val  ")
        -- If for some reason val is nil revert.
        self:val(sel_elm[self.prop])
    end  
    
end

-----------------------------------
------  Cap_Pos (menubox)  ------
-----------------------------------
--zzcappos 

function Property.Cap_Pos:init()

    --GUI.Msg("\n** Property.Cap_Pos:init **")
    
    local sel_elm = GUI.elms[self.elm]

    if sel_elm.type == "dh_Checklist" or sel_elm.type == "dh_Radio" then    
        self.optarray = {"top", "inside"}
        
    elseif sel_elm.type == "dh_Label" then   
        self.optarray = {"left", "center", "right"}
    
    elseif sel_elm.type == "dh_Slider_H" and self.prop == "display_pos" then
        self.optarray = {"top", "right", "integrated"}
        
    elseif sel_elm.type == "dh_Slider_V" then   
        self.optarray = {"top", "bottom"}
        
    else
        -- Text elements.
        self.optarray = {"left", "top", "right", "bottom"}
    end
    
    -- Get value from project elm.
    local pos = sel_elm[self.prop]
    self.curr_opt = GUI.table_find(self.optarray, pos)
    --GUI.Msg("    curr_opt is: " .. self.curr_opt)
    self.cap_pos = "left" 
    --self.noarrow = false
    --self.pad = 4
    --self.cap_pad_x = 4
    --self.col_backdrop = "panel_bg"    

    -- Disable wheel.
    self.onwheel = function() end    
    
    GUI[self.type].init(self)
    
end

function Property.Cap_Pos:onmouseup()
    GUI[self.type].onmouseup(self)
    self:apply_value()
end

--!!! Should be able to roll this into apply_value(),
-- but apply_value calls validate'
-- Since no validation is needed would need a dummy validation function.

function Property.Cap_Pos:apply_value()

    --GUI.Msg("\n## Property.Cap_Pos:apply_value ##")

    -- Reference to selected project elm.
    local sel_elm = GUI.elms[self.elm]  
      
    -- Get selected value as string.
    local val = self.optarray[self.curr_opt]
    
    --GUI.Msg("    property is: " .. self.prop)
    --GUI.Msg("    apply_value: val is: " .. val)
    
    if val then
                            
        --GUI.Msg("    # Inside IF val  ")
        
        sel_elm[self.prop] = val
        sel_elm.props_norm[self.prop] = val
        --GUI.Msg("    val is: " .. val)         
        --GUI.Msg("    sel_elm.props_norm.x is: " .. tostring(sel_elm.props_norm.x))
        --GUI.Msg("    sel_elm.x is: " .. tostring(sel_elm.x))
        --GUI.Msg("    sel_elm.w is: " .. tostring(sel_elm.w))                
        -- Should only need redraw except for dh_Label x.
        
        if sel_elm.type == "dh_Label" then
            
            sel_elm.x = (sel_elm.props_norm.x * DHTK.APP_SCALE)
            --sel_elm:init()
            
            GUI.elms.GB_frm_sel_elm:redraw()
        end
        
        --if self.prop == "display_pos" then
        --    sel_elm:init()
        --end 
        
        if self.needs_init then
            sel_elm:init()
        end
        
        sel_elm:redraw()
 
    else 
        -- If for some reason val is nil revert.
        --GUI.Msg("    # Inside if ELSE val  ")
        self:val(sel_elm[self.prop])
    end  
    
end

-------------------------------------
------  Direction (menubox)  ------
-------------------------------------
--zzdir
function Property.Direction:init()

    --GUI.Msg("\n** Property.Direction:init **")
    
    self.optarray = {"h", "v"}
    
    -- Get value from project elm.
    local d = GUI.elms[self.elm].dir
    self.curr_opt = GUI.table_find(self.optarray, d)

    self.cap_pos = "left"
    --self.noarrow = false
    --self.pad = 4
    --self.cap_pad_x = 4
    --self.col_backdrop = "panel_bg"    

    -- Disable wheel.
    self.onwheel = function() end
    
    --GUI.Msg("    before call to GUI[self.type].init(self) curr_opt is : " .. tostring(self.curr_opt))
    --GUI.Msg("    before call to GUI[self.type].init(self) self.type is : " .. tostring(self.type))        
    
    GUI[self.type].init(self)
    
    --GUI.Msg("    after call to GUI[self.type].init(self) curr_opt is : " .. tostring(self.curr_opt))
    
end

function Property.Direction:onmouseup()
    GUI[self.type].onmouseup(self)
    self:apply_value()
end

--zzdir 
-- Can probably roll this into apply_value() as I am not
-- swapping w and heights or element.
-- Would need to fetch value in validate,
-- and add recreate.

function Property.Direction:apply_value()

    --GUI.Msg("\n** Property.Direction:apply_value **")

    -- Reference to selected project elm.
    local sel_elm = GUI.elms[self.elm]    
  
    -- Get selected value as string.
    local val = self.optarray[self.curr_opt]
    
    -- No need to validate as val is "h" or "v"

    --GUI.Msg("    val   is : " .. val)     
    --GUI.Msg("    sel_elm.w is : " .. tostring(sel_elm.w))     
    --GUI.Msg("    sel_elm.h is : " .. tostring(sel_elm.h))         
    
    if val then    
    
        --GUI.Msg("  # Inside IF val  ")

        sel_elm[self.prop] = val
        sel_elm.props_norm[self.prop] = val

        -- Swap w to where it should be for the new direction.
        
        --if sel_elm.type == "Slider" or sel_elm.type == "dh_Slider" or sel_elm.type == "dh_Slider_multi" then
        if sel_elm.type == "Slider" then        
            sel_elm.w = sel_elm.props_norm.w * DHTK.APP_SCALE
            -- Need to use 8 for Lokasenna Slider.
            sel_elm.h = sel_elm.props_norm.h or 8 * DHTK.APP_SCALE        
            Properties.recreate_elm(sel_elm, nil, true)                
        end
       
        --!!! Must recreate! At least for slider.
        --Properties.recreate_elm(sel_elm, nil, true)
                
        GUI.elms.GB_frm_sel_elm:redraw()        

    else
        -- If for some reason val is nil revert.     
        --GUI.Msg("# Inside if ELSE val  ")
        self:val(sel_elm[self.prop])
    end  
    
end

--------------------------------------
------  Line_Height (menubox) ------
--------------------------------------
--zzlh --zzz  

function Property.Line_Height:init()

    --GUI.Msg("\n**  Property.Line_Height:init  **")
    
    self.optarray = {"1.00", "1.10", "1.20", "1.25", "1.30", "1.40", "1.50", "1.60", "1.75", "1.85", "2.00"}
    
    -- Get proj elm.line_height
    -- ht will be number, optarray is string.
    local ht = GUI.elms[self.elm].line_height
    
    if type(ht) == "number" then
        ht = string.format("%.2f", ht)
    end
    
    --GUI.Msg("    line_height tostring is : " .. tostring(ht))
    
    -- Get index. For some reason GUI.table_find doesn't work here. 
    local c_opt
    
    for i, v in ipairs(self.optarray) do
        if string.match(v, ht) then 
            c_opt = i
        end
    end

    self.curr_opt = c_opt
    
    self.cap_pos = "left"
    --self.noarrow = false
    --self.pad = 4
    --self.cap_pad_x = 4
    --self.col_backdrop = "panel_bg"    

    -- Disable wheel.
    self.onwheel = function() end

    GUI[self.type].init(self)
    
end

function Property.Line_Height:onmouseup()
     GUI[self.type].onmouseup(self)
    self:apply_value()
end

-- ??? Should be able to roll this into apply_value()
function Property.Line_Height:apply_value()

    --GUI.Msg("\n** Property.Line_Height:apply_value **")

    -- Reference to selected project elm.
    local sel_elm = GUI.elms[self.elm]   
     
    -- Get selected value as string.
    local val = self.optarray[self.curr_opt]
    
    --GUI.Msg("    apply_value: val is: " .. val)

    if val then
    
        val = tonumber(val)
                            
        --GUI.Msg("    # Inside IF val  ")
        
        sel_elm[self.prop] = val
        sel_elm.props_norm[self.prop] = val 
        
        -- ??? init or recreate?
        sel_elm:init() 
        -- Should only need redraw.
        sel_elm:redraw()

    else
        -- If for some reason val is nil revert.             
        --GUI.Msg("    # Inside if ELSE val  ")
        self:val(sel_elm[self.prop])
    end  
    
end

------------------------------------
------  List (menubox)  ------
------------------------------------
--zzcomp
function Property.List:init()

    local val 

    if self.prop == "display_style" then
        self.optarray = {"none", "box", "plain"}
        val = GUI.elms[self.elm].display_style
    
    elseif self.prop == "knob_style" then
        self.optarray = {"pointer", "flange", "simple"}
        val = GUI.elms[self.elm].knob_style
    
    elseif self.prop == "thumb_style" then 
        self.optarray = {"none", "long", "wide", "square"}
        val = GUI.elms[self.elm].thumb_style
        
    elseif self.prop == "frame_thk" then 
        self.optarray = {"1", "2"}
        val = GUI.elms[self.elm].frame_thk
         
    elseif self.prop == "col_backdrop" then      
        self.optarray = {"wnd_bg", "panel_bg"}
        val = GUI.elms[self.elm].col_backdrop         
        
    else    -- col_bg     
        self.optarray = {"wnd_bg", "panel_bg"}
        val = GUI.elms[self.elm].col_bg        
    end
    
    --GUI.Msg(" Property.List:init   type val : " .. type(val))        
    --GUI.Msg(" Property.List:init   val : " .. tostring(val))    
    
    self.curr_opt = GUI.table_find(self.optarray, val)
        
    --GUI.Msg(" Property.List:init   self.curr_opt : " .. tostring(self.curr_opt))
         
    self.cap_pos = "left"
    --self.noarrow = false
    --self.pad = 4
    --self.cap_pad_x = 4
    --self.col_backdrop = "panel_bg"    

    -- Disable wheel.
    self.onwheel = function() end    

    GUI[self.type].init(self)
    
end


function Property.List:onmouseup()
    GUI[self.type].onmouseup(self)
    self:apply_value()
end


function Property.List:apply_value()

    --GUI.Msg("\n** Property.Thumb_Type:apply_value **")

    -- Reference to selected project elm.
    local sel_elm = GUI.elms[self.elm] 
       
    -- Get selected value as string.
    local val = self.optarray[self.curr_opt]
    
    --GUI.Msg("    apply_value: val is: " .. tostring(val))
    
    if val then
        --GUI.Msg("    # Inside IF val  ")
        
        sel_elm[self.prop] = val
        sel_elm.props_norm[self.prop] = val
            
        -- !!! DO NOT RECREATE!
        --Properties.recreate_elm(sel_elm, nil, true)
        sel_elm:init()
        sel_elm:redraw()

    else  
        -- If for some reason val is nil revert.    
        --GUI.Msg("    # Inside if ELSE val  ")
        self:val(sel_elm[self.prop])
    end  
    
end

------------------------------------
------  MonoFont (menubox)  ------
------------------------------------
--zzmono  

function Property.MonoFont:init()

    -- Get monofont names from GUI.
    
    local mfonts = {}
    
    for k, fnt in pairs(GUI.fonts) do
        if string.match(k, "mono") then
            table.insert(mfonts, k)
        end
    end
    
    table.sort(mfonts)
    
    -- List them.
    --for _, f in ipairs(mfonts) do
    --GUI.Msg("     GUI.fonts mono : " .. tostring(f))        
    --end

    local fnt = GUI.elms[self.elm][self.prop]
    
    self.optarray = mfonts 
    self.curr_opt = GUI.table_find(mfonts, fnt)
    
    self.cap_pos = "left"
    --self.noarrow = false
    --self.pad = 4
    --self.cap_pad_x = 4
    --self.col_backdrop = "panel_bg"    

    -- Disable wheel.
    self.onwheel = function() end    
    
    GUI[self.type].init(self)
    
end

function Property.MonoFont:onmouseup()
    GUI[self.type].onmouseup(self)
    self:apply_value()
end

-- ??? Should be able to roll this into apply_value()
function Property.MonoFont:apply_value()

    --GUI.Msg("\n** Property.MonoFont:apply_value **")

    -- Reference to selected project elm.
    local sel_elm = GUI.elms[self.elm] 
       
    -- Get selected value as string.
    local val = self.optarray[self.curr_opt]
    
    --GUI.Msg("    apply_value: val is: " .. val)
    
    if val then
        --GUI.Msg("    # Inside IF val  ")
        
        sel_elm[self.prop] = val
        sel_elm.props_norm[self.prop] = val
            
        -- Not sure if init needed (may depend on usage) so just do it.
        sel_elm:init()
        sel_elm:redraw()

    else 
        -- If for some reason val is nil revert.                 
        --GUI.Msg("    # Inside if ELSE val  ")
        self:val(sel_elm[self.prop])
    end  
    
end

-- No validate needed as value is from menubox optarray.
-- Keeping here fpr reference.
function Property.MonoFont:validate()
    
    local val = self:val()
    if GUI.fonts[tonumber(val)] then
        val = tonumber(val)
    elseif not GUI.fonts[val] then
        val = nil
    end
    
    -- Check for monospace
    if val then
        GUI.font(val)
        local w1 = gfx.measurechar(string.byte("i"))
        local w2 = gfx.measurechar(string.byte("m"))
        
        if w1 == w2 then return val end
    end
        
end


return Property