-- NoIndex: true

-- dh_Menubox.lua
-- Modified: 20250908

---------------------------------------------------------------------
-- Lokasenna_GUI - Menubox class
--   For documentation, see this class's page on the project wiki:
--     https://github.com/jalovatt/Lokasenna_GUI/wiki/Menubox
---------------------------------------------------------------------
--[[ Modified by Dennis Horn.

     Same as Lokasenna Menubox except for: 
     Changed some property names.
     Added ability to customize box colors.
     Added property "col_active". This is the outline color when the Menubox is in focus.
     Changed how the Menubox "frame" is displayed when dropdown menu is displayed.
     Changed position where menu pops up.
     Added property "curr_opt" to replace "retval". (It does the same thing, I just find it to be more descriptive).
     
     
     Notes:
      
     When defining a Menubox you use the "opts" property to specify either a comma separated string of options, 
       or a table of strings as options. During element creation "opts" gets parsed into the element's "optarray" property 
       which hold the values that will be displayed in the popup menu. If not specified it will contain a single entry 
       of " " (or else calls to gfx.showmenu would crash not only the script, but may also crash reaper). 
       After element creation "opts" is no longer used. Any access to the popup menu options will be to "optarray".
       
     The font size in the popup menus cannot be changed. They use the fonts defined by the operating system.  
        

--]]
---------------------------------------------------------------------
-- Requires that Lokasenna_GUI v2 be loaded.

if not GUI then
  reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
  missing_lib = true
  return 0
end
---------------------------------------------------------------------
--Creation parameters:  !!! Needs updating to add colors? optarray?
--  name, z, x, y, w, h, caption, pad, noarrow
--------------------------------------------------------------------
GUI.dh_Menubox = GUI.Element:new()
function GUI.dh_Menubox:new(name, z, x, y, w, h, caption, pad, noarrow)

    local menu = (not x and type(z) == "table") and z or {}

    menu.name = name
    menu.type = "dh_Menubox"

    menu.z = menu.z or z

    menu.x = menu.x or x
    menu.y = menu.y or y
    menu.w = menu.w or w
    menu.h = menu.h or h

    menu.caption = menu.caption or caption or ""
    menu.pad = menu.pad or pad or 4
  
    if menu.noarrow == nil then
        menu.noarrow = noarrow or false
    end  
  
    menu.font_caption = menu.font_caption or "sans20"
    menu.font_text = menu.font_text or "sans22" 
    
----colors---------------------------
    -- Caption
    menu.col_cap_bg = menu.col_cap_bg or "wnd_bg"
    menu.col_cap_text = menu.col_cap_text or "txt"
    
    -- Box
    menu.col_bg = menu.col_bg or "elm_bg"
    menu.col_frame = menu.col_frame or "elm_frame" 
    menu.col_face = menu.col_face or "btn_face"     
    menu.col_active = menu.col_active or "elm_active"
    menu.col_text = menu.col_text or "elm_txt"
-------------------------------------  

  -- To go back to original comment out this line and uncomment following block.     
  --menu.optarray = menu.optarray or {}

    local opts = menu.opts or opts

    if not opts then
    
        menu.optarray = menu.optarray or {" "}

    elseif type(opts) == "string" then

        if opts == "" then opts = " " end

        -- Parse the string of options into a table
        menu.optarray = {}

        for word in string.gmatch(opts, '([^,]*)') do
            menu.optarray[#menu.optarray+1] = word
        end
    elseif type(opts) == "table" then
        menu.optarray = opts
        if #menu.optarray == 0 then menu.optarray = {" "} end
    end

-------------------------------------    
  
    menu.align = menu.align or 0

    menu.retval = menu.retval or 1
  
    menu.curr_opt = menu.curr_opt or 0

    GUI.redraw_z[menu.z] = true

    setmetatable(menu, self)
    self.__index = self
    return menu

end


function GUI.dh_Menubox:init()

    local w, h = self.w, self.h

    self.buff = GUI.GetBuffer()

    gfx.dest = self.buff
    gfx.setimgdim(self.buff, -1, -1)
    gfx.setimgdim(self.buff, 2*w + 4, 2*h + 4)

    self:drawframe()

    if not self.noarrow then self:drawarrow() end

end


function GUI.dh_Menubox:ondelete()

	GUI.FreeBuffer(self.buff)

end

------------------------------------
-------- Drawing methods -----------
------------------------------------

function GUI.dh_Menubox:draw()

    local x, y, w, h = self.x, self.y, self.w, self.h

    local caption = self.caption
    local focus = self.focus


    -- Draw the caption
    if caption and caption ~= "" then self:drawcaption() end


    -- Blit the shadow + frame
    for i = 1, GUI.shadow_dist do
        gfx.blit(self.buff, 1, 0, w + 2, 0, w + 2, h + 2, x + i - 1, y + i - 1)
    end

    gfx.blit(self.buff, 1, 0, 0, (focus and (h + 2) or 0) , w + 2, h + 2, x - 1, y - 1)

    -- Draw the text
    self:drawtext()

end


function GUI.dh_Menubox:drawcaption()

    GUI.font(self.font_caption)
    local str_w, str_h = gfx.measurestr(self.caption)

    gfx.x = self.x - str_w - self.pad
    gfx.y = self.y + (self.h - str_h) / 2

    GUI.text_bg(self.caption, self.col_cap_bg)
    GUI.shadow(self.caption, self.col_cap_text, "shadow")

end

function GUI.dh_Menubox:drawframe()

    local x, y, w, h = self.x, self.y, self.w, self.h
    local r, g, b, a = table.unpack(GUI.colors["shadow"])
    gfx.set(r, g, b, 1)
    gfx.rect(w + 3, 1, w, h, 1)
    gfx.muladdrect(w + 3, 1, w + 2, h + 2, 1, 1, 1, a, 0, 0, 0, 0 )

    GUI.color(self.col_bg)
    gfx.rect(1, 1, w, h)
    gfx.rect(1, w + 3, w, h)

    GUI.color(self.col_frame)
    
    gfx.rect(1, 1, w, h, 0)
    GUI.color(self.col_face)
    if not self.noarrow then gfx.rect(1 + w - h, 1, h, h, 1) end

    --GUI.color("elm_fill")
    --GUI.color({0.5,0.5,0.5,0.75})
    GUI.color(self.col_active)
    gfx.rect(1, h + 3, w, h, 0)
    gfx.rect(2, h + 4, w - 2, h - 2, 0)

end


function GUI.dh_Menubox:drawarrow()

    --GUI.color(self.col_frame)
    GUI.color(self.col_face)        
    local x, y, w, h = self.x, self.y, self.w, self.h
    --gfx.rect(1 + w - h, h + 3, h, h, 1)
    gfx.rect(1 + w - h, h + 5, h - 2, h - 4, 1)

    GUI.color(self.col_bg)

    -- Triangle size
    --local r = 5
    --local rh = 2 * r / 5
    
    local r = math.floor(h / 5)
    local rh = math.floor(2 * r / 5)    

    local ox = (1 + w - h) + h / 2
    local oy = 1 + h / 2 - (r / 2)

    local Ax, Ay = GUI.polar2cart(1/2, r, ox, oy)
    local Bx, By = GUI.polar2cart(0, r, ox, oy)
    local Cx, Cy = GUI.polar2cart(1, r, ox, oy)

    GUI.triangle(true, Ax, Ay, Bx, By, Cx, Cy)

    oy = oy + h + 2

    Ax, Ay = GUI.polar2cart(1/2, r, ox, oy)
    Bx, By = GUI.polar2cart(0, r, ox, oy)
    Cx, Cy = GUI.polar2cart(1, r, ox, oy)

    GUI.triangle(true, Ax, Ay, Bx, By, Cx, Cy)

end


--zzdraw
function GUI.dh_Menubox:drawtext()

    --GUI.Msg("**** GUI.dh_Menubox.drawtext ****\n")

------------------------------------------------------------
--[[ ORIGINAL CODE: # Uncomment for original.

    -- Make sure retval hasn't been accidentally set to something illegal
    self.retval = self:validateoption(tonumber(self.retval) or 1)

    -- Strip gfx.showmenu's special characters from the displayed value
    local text = string.match(self.optarray[self.retval], "^[<!#]?(.+)")

    -- Draw the text
    GUI.font(self.font_b)
    GUI.color(self.col_text)

    --if self.output then text = self.output(text) end

    if self.output then
        local t = type(self.output)

        if t == "string" or t == "number" then
            text = self.output
        elseif t == "table" then
            text = self.output[text]
        elseif t == "function" then
            text = self.output(text)
        end
    end

--]]
------------------------------------------------------------   
-- MY CODE: # Comment for original. (Use this or above block.)
--[[ --]]    
    -- Not using special chars for gray out, spacers, or submenus
    -- so shouldn't need to validate.
    
    -- Make sure retval hasn't been accidentally set to something illegal
    --self.curr_opt = self:validateoption(tonumber(self.curr_opt) or 1)
    
    --dh_log("> self.curr_opt is: <" .. tostring(self.curr_opt) .. ">\n")

    -- Still need to draw even if 0 so that existing text is blank.   
    -- Get current option --
    
    local text = ""
    
    if self.curr_opt == 0 then
        text = ""
    else
        text = self.optarray[self.curr_opt]
        --dh_log(" dh_Menubox.drawtext: text is: <" .. text .. ">\n")
    end
        
    --GUI.Msg(" dh_Menubox.drawtext: gfx.drawstr is: <" .. text .. ">\n")
    
    -- Draw the text
    GUI.font(self.font_text)
    GUI.color(self.col_text)
    
------------------------------------------------------------   
    -- Avoid any crashes from weird user data
    text = tostring(text)

    str_w, str_h = gfx.measurestr(text)
    gfx.x = self.x + 4
    gfx.y = self.y + (self.h - str_h) / 2

    local r = gfx.x + self.w - 8 - (self.noarrow and 0 or self.h)
    local b = gfx.y + str_h
    gfx.drawstr(text, self.align, r, b)

end

function GUI.dh_Menubox:val(newval)
  --dh_log("**** in GUI.dh_Menubox:val ****\n")

  if newval then
    -- Sets the curr_opt.
    --dh_log("** if newval\n")
    --self.retval = newval
    self.curr_opt = newval
    --dh_log("> self.curr_opt is: " .. tostring(self.curr_opt) .. "\n")
    self:redraw()
    
  else
    -- Returns the curr_opt 
    --dh_log("** else newval\n")
    --return math.floor(self.retval), self.optarray[self.retval]
    return math.floor(self.curr_opt), self.optarray[self.curr_opt]
  end

end

--zzdraw
------------------------------------
-------- Input methods -------------
------------------------------------
-- Since I am only using an array of strings I can streamline process.
-- !!! gfx.showmenu requires at least " " or Reaper will crash. I now check for this in onmouseup().

function GUI.dh_Menubox:onmouseup()

    -- Bypass option for GUI Builder
    if not self.focus then
        self:redraw()
        return
    end

------------------------------------------------------------ 
-- MY CODE: Can probably leave in.   
    
    if #self.optarray == 0 or self.optarray[1] == " " then
        --dh_log("> dh_Menubox:onmouseup optarray == 0\n")
        return
    end
    
------------------------------------------------------------ 
-- ORIGINAL CODE:  
    -- The menu doesn't count separators in the returned number,
    -- so we'll do it here
    -- # Uncomment for original.
    local menu_str, sep_arr = self:prepmenu() 
    
------------------------------------------------------------ 
-- MY CODE: My replacement for prepmenu.Block comment out to use original.
--Use either this or above.

    -- # Comment for original.
--[[        
    local menu_str = ""
    
    -- Prepare string to be used for menu --
    -- for loop replaces call to self:prepmenu <which was removed>

    for i, v in ipairs(self.optarray) do
        menu_str = menu_str .. v
        if i < #self.optarray then 
            menu_str = menu_str .. "|"
        end
    end
--]]
------------------------------------------------------------
    --orig gfx.x, gfx.y = GUI.mouse.x, GUI.mouse.y
    
    --gfx.x = GUI.mouse.x
    gfx.x = self.x + 4
    gfx.y = self.y + self.h + 4
            
    local new_opt = gfx.showmenu(menu_str)
------------------------------------------------------------
    -- # Uncomment for original.
    if #sep_arr > 0 then curopt = self:stripseps(curopt, sep_arr) end
------------------------------------------------------------        
    -- If nothing selected.
    if new_opt ~= 0 then self.curr_opt = new_opt end
    
    self.focus = false
    self:redraw()

end

-- This is only so that the box will light up
function GUI.dh_Menubox:onmousedown()
  self:redraw()
end

function GUI.dh_Menubox:onwheel()

  -- Avert a crash if there aren't at least two items in the menu
  --if not self.optarray[2] then return end

  -- Check for illegal values, separators, and submenus
    --self.retval = self:validateoption(  GUI.round(self.retval - GUI.mouse.inc),
    --                                    GUI.round((GUI.mouse.inc > 0) and 1 or -1) )
                                        
    self.curr_opt = self:validateoption(  GUI.round(self.curr_opt - GUI.mouse.inc),
                                        GUI.round((GUI.mouse.inc > 0) and 1 or -1) )
                                        

  self:redraw()

end


------------------------------------
-------- Input helpers -------------
------------------------------------
--zzprep
-- prepmenu and strip seps not used in dh_Menubox.

-- Put together a string for gfx.showmenu from the values in optarray
function GUI.dh_Menubox:prepmenu()

  local str_arr = {}
  local sep_arr = {}
  local menu_str = ""

  for i = 1, #self.optarray do

    -- Check off the currently-selected option
    if i == self.retval then menu_str = menu_str .. "!" end

        table.insert(str_arr, tostring( type(self.optarray[i]) == "table"
                                            and self.optarray[i][1]
                                            or  self.optarray[i]
                                      )
                    )

    if str_arr[#str_arr] == ""
    or string.sub(str_arr[#str_arr], 1, 1) == ">" then
      table.insert(sep_arr, i)
    end

    table.insert( str_arr, "|" )

  end

  menu_str = table.concat( str_arr )

  return string.sub(menu_str, 1, string.len(menu_str) - 1), sep_arr

end


-- Adjust the menu's returned value to ignore any separators ( --------- )
function GUI.dh_Menubox:stripseps(curopt, sep_arr)

    for i = 1, #sep_arr do
        if curopt >= sep_arr[i] then
            curopt = curopt + 1
        else
            break
        end
    end

    return curopt

end


function GUI.dh_Menubox:validateoption(val, dir)

    dir = dir or 1

    while true do

        -- Past the first option, look upward instead
        if val < 1 then
            val = 1
            dir = 1

        -- Past the last option, look downward instead
        elseif val > #self.optarray then
            val = #self.optarray
            dir = -1

        end
--zzdraw
        -- Don't stop on separators, folders, or grayed-out options
        local opt = string.sub(self.optarray[val], 1, 1)
        if opt == "" or opt == ">" or opt == "#" then
            val = val - dir

        -- This option is good
        else
            break
        end

    end

    return val

end