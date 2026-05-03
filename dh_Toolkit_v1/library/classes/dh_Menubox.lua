-- NoIndex: true

-- dh_Menubox.lua
-- Modified: 20260330

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
     20251128: Moved drawframe into init. Re-did how drawn.
     20260223: Replace element frame with highlighted drawn.
               Added properties for frame modification.

     Notes:
      
     When defining a Menubox you use the "opts" property to specify either a comma separated string of options, 
       or a table of strings as options. During element creation "opts" gets parsed into the element's "optarray" property 
       which hold the values that will be displayed in the popup menu. If not specified it will contain a single entry 
       of " " (or else calls to gfx.showmenu would crash not only the script, but may also crash reaper). 
       After element creation "opts" is no longer used. Any access to the popup menu options will be to "optarray".
       
     It is possible that a dynamically assigned optarray will be an empty table. Code has been adjusted to accommodate this case,  
       
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
--Creation parameters:  ??? Needs updating to add colors? 
--  name, z, x, y, w, h[, caption, opts, noarrow]
--------------------------------------------------------------------
GUI.dh_Menubox = GUI.Element:new()
function GUI.dh_Menubox:new(name, z, x, y, w, h, caption, opts, noarrow)

    local menu = (not x and type(z) == "table") and z or {}

    menu.name = name
    menu.type = "dh_Menubox"

    menu.z = menu.z or z

    menu.x = menu.x or x
    menu.y = menu.y or y
    menu.w = menu.w or w or GUI.dh_Menubox.defaults.w
    menu.h = menu.h or h or GUI.dh_Menubox.defaults.h

    menu.caption = menu.caption or caption or GUI.dh_Menubox.defaults.caption

    menu.font_caption = menu.font_caption or GUI.dh_Menubox.defaults.font_caption
	menu.cap_pos = menu.cap_pos or GUI.dh_Menubox.defaults.cap_pos
	menu.cap_pad_x = menu.cap_pad_x or GUI.dh_Menubox.defaults.cap_pad_x
	menu.cap_pad_y = menu.cap_pad_y or GUI.dh_Menubox.defaults.cap_pad_y
	menu.cap_centered = menu.cap_centered or GUI.dh_Menubox.defaults.cap_centered

    menu.font_text = menu.font_text or GUI.dh_Menubox.defaults.font_text     
	menu.pad = menu.pad or pad or GUI.dh_Menubox.defaults.pad
    menu.align_text = menu.align_text or GUI.dh_Menubox.defaults.align_text  -- left, center, right
	
    menu.noarrow = menu.noarrow or noarrow or GUI.dh_Menubox.defaults.noarrow

    menu.shadow = menu.shadow or GUI.dh_Menubox.defaults.shadow
    menu.shadow_caption = menu.shadow_caption or GUI.dh_Menubox.defaults.shadow_caption

    menu.frame_use_outline = menu.frame_use_outline or GUI.dh_Menubox.defaults.frame_use_outline
    menu.frame_thk = menu.frame_thk or GUI.dh_Menubox.defaults.frame_thk    	
    if menu.allow_sel_outline == nil then
        menu.allow_sel_outline = GUI.dh_Menubox.defaults.allow_sel_outline
    end
        
----colors---------------------------
    -- Caption
    menu.col_cap_text = menu.col_cap_text or GUI.dh_Menubox.defaults.col_cap_text
    
    -- Box
    menu.col_bg = menu.col_bg or GUI.dh_Menubox.defaults.col_bg
    menu.col_frame = menu.col_frame or GUI.dh_Menubox.defaults.col_frame
    menu.col_text = menu.col_text or GUI.dh_Menubox.defaults.col_text 
    menu.col_face = menu.col_face or GUI.dh_Menubox.defaults.col_face 
        
    menu.col_active = menu.col_active or GUI.dh_Menubox.defaults.col_active
    menu.col_backdrop = menu.col_backdrop or GUI.dh_Menubox.defaults.col_backdrop
-------------------------------------  

    -- First, check if optarray.
    if not menu.optarray then
    
        menu.optarray = {}
    
        -- Next, check if opts.
        local opts = menu.opts or opts or {}        
    
        if type(opts) == "table" then
            -- Copy table into optarray.
            --for i = 1, #opts do
            --    menu.optarray[i] = opts[i]
            --end
            menu.optarray = opts
        else
            -- Given a comma separated string.
        	-- Parse the string of options into a table.
            local tempidx = 1
            for word in string.gmatch(opts, '([^,]*)') do
                menu.optarray[tempidx] = word
                tempidx = tempidx + 1
            end
        
        end

    end
    
    if #menu.optarray > 0 then
        menu.curr_opt = 1
    else    
        menu.curr_opt = 0
    end     
         
-------------------------------------    

    GUI.redraw_z[menu.z] = true

    setmetatable(menu, self)
    self.__index = self
    return menu

end

GUI.dh_Menubox.defaults = {
    w = 128,
    h = 28,
    noarrow = false,
    optarray = {},    	
    curr_opt = 0,
	font_text = "sans22",	
	pad = 4,
	align_text = "left",        
    
	caption = "",
	font_caption = "sans22",
	cap_pos = "top",
    cap_pad_x = 4,
    cap_pad_y = 4,
	cap_centered = false,
	
	shadow = false,	
	shadow_caption = false,
    frame_use_outline = false,
    frame_thk = 2,
    allow_sel_outline = false,
 
    col_bg = "elm_bg",
    col_frame = "elm_frame",
    col_face = "btn_face",
    col_text = "elm_txt", 
    col_cap_text = "txt", 
    col_active = "elm_active",
    col_backdrop = "wnd_bg",    
}


function GUI.dh_Menubox:init()

    --GUI.Msg("\n**** dh_Menubox:init : [ " .. self.name .. " ]")
    --GUI.Msg("\n**** dh_Menubox:init self.frame_thk:  " .. tostring(self.frame_thk))    

    local w, h = self.w, self.h
    
    local sd = self.shadow and GUI.shadow_dist or 0
	
    self.buff = self.buff or GUI.GetBuffer()

    gfx.dest = self.buff
    gfx.setimgdim(self.buff, -1, -1)
    --gfx.setimgdim(self.buff, 2 * w + sd, 2 * h + sd)
    gfx.setimgdim(self.buff, w + sd, h + sd)    
    
    -- Draw shadow.

    if self.shadow then
        GUI.color("shadow")
        gfx.rect(1, 1, w + sd - 1, h + sd - 1, 1)        
    end

    -- Draw frame.
    
    local frm_thk = tonumber(self.frame_thk)
     
    if ((GUI.colors["metadata"]) 
       and (GUI.colors["metadata"][4] == 0)) 
       or self.frame_use_outline   
    then  
    
        -- # use OUTLINE and outline color.
        
        GUI.color(self.col_frame)
        gfx.rect(0, 0, w, h, 1)          
       
    else    
       
        local ll_color, hl_color = DHTK.get_hilite_colors(self.col_backdrop)
    
        ---- # HIGHLIGHT bottom and right of track ----
        GUI.color(hl_color)
        gfx.rect(0, 0, w, h, 1)
    
        ---- # LOWLIGHT top and left of track ----
        GUI.color(ll_color)
        gfx.rect(0, 0, w - frm_thk, h - frm_thk, 1)
        
    end
    
    -- Draw box.
    
    GUI.color(self.col_bg)
    gfx.rect(frm_thk, frm_thk, w - (2 * frm_thk), h - (2 * frm_thk), 1)   

    -- Arrow background and arrow --
 
    if not self.noarrow then
        GUI.color(self.col_face)
        gfx.rect(w - h, frm_thk, h - frm_thk, h - (2 * frm_thk), 1)  
        GUI.color(self.col_frame)
        gfx.rect(w - h, frm_thk, h - frm_thk, h - (2 * frm_thk), 0)  
        self:drawarrow()
    end

end


function GUI.dh_Menubox:ondelete()

	GUI.FreeBuffer(self.buff)

end

------------------------------------
-------- Drawing methods -----------
------------------------------------

function GUI.dh_Menubox:draw()

    --GUI.Msg("\n**** dh_Menubox:draw : [ " .. self.name .. " ]")
    
    local x, y, w, h = self.x, self.y, self.w, self.h
	local sd = self.shadow and GUI.shadow_dist or 0
    
    -- Draw the caption
    if self.caption and self.caption ~= "" then self:drawcaption() end

    gfx.blit(self.buff, 1, 0, 0, 0, w + sd, h + sd, x, y)
    
    --GUI.Msg("** dh_Menubox:draw: self.focus is: " .. tostring(self.focus))
    
    -- Draw the text
    self:drawtext()         
    
	-- Focused?

	if self.focus then

		if self.allow_sel_outline then
    		GUI.color(self.col_active)
    	    --gfx.rect(x - 1, y - 1, w + 2, h + 2, 0)
    	    gfx.rect(x - 2, y - 2, w + 4, h + 4, 0)
    		-- Thicken highlight.
    	    --gfx.rect(x - 2, y - 2, w + 4, h + 4, 0)		
		end
		    
    end

end

--zzcap
function GUI.dh_Menubox:drawcaption()

    local caption = self.caption

    GUI.font(self.font_caption)

    local str_w, str_h = gfx.measurestr(caption)

    if self.cap_pos == "left" then
    
        gfx.x = self.x - str_w - self.cap_pad_x
        if self.cap_centered then
            gfx.y = self.y + (self.h - str_h) / 2
        else
            gfx.y = self.y + self.cap_pad_y
        end
        
    elseif self.cap_pos == "top" then
    
        if self.cap_centered then
            gfx.x = self.x + (self.w - str_w) / 2
        else
            gfx.x = self.x + self.cap_pad_x  
        end      
        gfx.y = self.y - str_h - self.cap_pad_y
        
    elseif self.cap_pos == "right" then
    
        gfx.x = self.x + self.w + self.cap_pad_x
        if self.cap_centered then
            gfx.y = self.y + (self.h - str_h) / 2
        else
            gfx.y = self.y + self.cap_pad_y
        end
        
    elseif self.cap_pos == "bottom" then
    
        if self.cap_centered then
            gfx.x = self.x + (self.w - str_w) / 2
        else
            gfx.x = self.x + self.cap_pad_x 
        end               
        gfx.y = self.y + self.h + self.cap_pad_y
        
    end

    --GUI.text_bg(caption, self.col_backdrop)
    
    GUI.color(self.col_backdrop)    
    gfx.rect(gfx.x, gfx.y, str_w, str_h, 1)    

    if self.shadow_caption then
        GUI.shadow(caption, self.col_cap_text, "shadow")
    else
        GUI.color(self.col_cap_text)
        gfx.drawstr(caption)
    end


end


function GUI.dh_Menubox:drawarrow()

    --GUI.color(self.col_face)        
    local x, y, w, h = self.x, self.y, self.w, self.h

    --GUI.color(self.col_bg)
    GUI.color("btn_txt")

    -- Triangle size

    local r = math.floor(h / 5)
    local rh = math.floor(2 * r / 5)    

    local ox = (w - h) + (h / 2) - 1
    local oy = (h / 2) - (r / 2)    

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


function GUI.dh_Menubox:drawtext()

    --GUI.Msg("\n**** dh_Menubox:drawtext : [ " .. self.name .. " ]")
        
    --GUI.Msg("    before validate    curr_opt   is: " .. tostring(self.curr_opt))
    --GUI.Msg("    before validate optarray 1 is: " .. self.optarray[1])
    --GUI.Msg("    before validate optarray 2 is: " .. self.optarray[2])
    --GUI.Msg("                      self:val is: " .. tostring(self:val()))

    -- Not using special chars for gray out, spacers, or submenus
    -- so shouldn't need to validate.
    -- Make sure curr_opt hasn't been accidentally set to something illegal
    self.curr_opt = self:validateoption(tonumber(self.curr_opt) or 1)
    
    --GUI.Msg("    after validate     curr_opt   is: " .. tostring(self.curr_opt))
    
    -- Still need to draw even if 0 so that existing text is blank.
       
    -- Get current option --
    
    local text    
    
    if (self.curr_opt == 0) or (#self.optarray == 0) then
        text = " "
    else
        text = self.optarray[self.curr_opt]
        --GUI.Msg("     drawtext: text is: < " .. text .. " >\n")
    end
    
    -- Avoid any crashes from weird user data
    text = tostring(text)
        
    --GUI.Msg(" dh_Menubox.drawtext: gfx.drawstr is: <" .. text .. ">\n")

    GUI.font(self.font_text)
    GUI.color(self.col_text)

    --local str_w, str_h = gfx.measurestr(text)
    
    -- Draws a string at gfx_x, gfx_y; clipped to (gfx_x, gfx_y, right, bottom) 
    -- Adjustments: aligns to defined box.
    -- align: 0 = left, 1= center, 2 = right, 4 = center vert
    
    local align = (self.align_text == "left") and (0 + 4)
               or (self.align_text == "center") and (1 + 4)
               or  (2 + 4)  -- right

    gfx.x = self.x + self.pad
	gfx.y = self.y + (self.h - gfx.texth) / 2

    local r = self.x + self.w - self.pad - (self.noarrow and 0 or self.h)
    local b = self.y + self.h - 4

    gfx.drawstr(text, align, r, b)

end

function GUI.dh_Menubox:val(newval)

    --GUI.Msg("\n**** dh_Menubox:val : [ " .. self.name .. " ]")
    --GUI.Msg("      self.curr_opt is : " .. tostring(self.curr_opt))

   if newval then
      --GUI.Msg("          newval is : " .. tostring(newval))
      -- Sets the curr_opt.
      self.curr_opt = newval
      self:redraw()
    
   else
      --GUI.Msg("  dh_Menubox:val return curr_opt is : " .. tostring(self.curr_opt))  
      -- Returns the curr_opt 
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

    --GUI.Msg("\n# dh_Menubox:onmouseup : size of optarray : " .. tostring(#self.optarray))
    --GUI.Msg("                     : curr_opt : " .. tostring(self.curr_opt))    
    
------------------------------------------------------------ 
-- MY CODE: Can probably leave in.   
    
    --if #self.optarray == 0 or self.optarray[1] == " " then
    if #self.optarray == 0 or self.curr_opt == 0 then    
        --GUI.Msg("> dh_Menubox:onmouseup optarray == 0\n")
        return
    end
    
------------------------------------------------------------ 

    -- The menu doesn't count separators in the returned number,
    -- so we'll do it here

    local menu_str, sep_arr = self:prepmenu() 

    gfx.x = self.x + 4
    gfx.y = self.y + self.h + 4   
            
    local new_opt = gfx.showmenu(menu_str)

    if #sep_arr > 0 then new_opt = self:stripseps(new_opt, sep_arr) end

    -- If nothing selected.
    if new_opt ~= 0 then self.curr_opt = new_opt end
    
    --GUI.Msg(">     new_opt : " .. (new_opt or "nil"))        
    --GUI.Msg(">     self.curr_opt : " .. (self.curr_opt or "nil"))    

    -- ??? Why is this being set to false?
    -- Shouldn't it be in mouse down set to true.
    --self.focus = false

    self:redraw()

end

-- This is only so that the box will light up ???
function GUI.dh_Menubox:onmousedown()
    --self.focus = true
    --self:redraw()
end

function GUI.dh_Menubox:onwheel()

    -- Avert a crash if there aren't at least two items in the menu
    --if not self.optarray[2] then return end

    -- Check for illegal values, separators, and submenus
    self.curr_opt = self:validateoption(  GUI.round(self.curr_opt - GUI.mouse.inc),
                                        GUI.round((GUI.mouse.inc > 0) and 1 or -1) )
                                        
    self:redraw()

end

-- Make sure the box highlight goes away
function GUI.dh_Menubox:lostfocus()

    if self.allow_sel_outline then
        self:redraw()
    end

end


------------------------------------
-------- Input helpers -------------
------------------------------------
--zzprep

-- Put together a string for gfx.showmenu from the values in optarray

function GUI.dh_Menubox:prepmenu()

    local str_arr = {}
    local sep_arr = {}
    local menu_str = ""

    for i = 1, #self.optarray do

        -- Check off the currently-selected option
        if i == self.curr_opt then menu_str = menu_str .. "!" end

        table.insert(str_arr, tostring( type(self.optarray[i]) == "table"
                                            and self.optarray[i][1]
                                            or  self.optarray[i]
                                      )
                    )

        if str_arr[#str_arr] == "" or string.sub(str_arr[#str_arr], 1, 1) == ">" then
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

    --GUI.Msg("\n**** dh_Menubox:validateoption val : " .. tostring(val))
    --GUI.Msg("   [ " .. self.name .. " ]") 
    --GUI.Msg("    size of optarray : " .. tostring(#self.optarray))
    --GUI.Msg("    curr_opt         : " .. tostring(self.curr_opt))    
    
    -- In case a dynamically allocated optarray may be an empty table.
    if (self.curr_opt == 0) or (#self.optarray == 0) then return 0 end                
    
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