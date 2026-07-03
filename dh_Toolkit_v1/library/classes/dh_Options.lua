-- NoIndex: true

-- dh_Options.lua
-- Date: 20260330

---------------------------------------------------------------------
-- Lokasenna_GUI - Options class
--   For documentation, see this class's page on the project wiki:
--     https://github.com/jalovatt/Lokasenna_GUI/wiki/Options
---------------------------------------------------------------------
--[[ Lokasenna_GUI - Options classes

    This file provides two separate element classes:

    dh_Radio       A list of options from which the user can only choose one at a time.
    dh_Checklist   A list of options from which the user can choose any, all or none.

    Both classes take the same parameters on creation, and offer the same parameters
    afterward - their usage only differs when it comes to their respective :val methods.

    For documentation, see the class pages on the project wiki:
    https://github.com/jalovatt/Lokasenna_GUI/wiki/Checklist
    https://github.com/jalovatt/Lokasenna_GUI/wiki/Radio

--]]
---------------------------------------------------------------------
--[[ Modified by Dennis Horn.

     Add extra color properties.
     Provides ability to define border color and width.
       They can now be set separately from the caption text and background colors.
     If "border_width" > 0 then a border will be drawn 
       using "col_border" with the specified "border_width".
     If the "radius" > 0 it will round the corners of the option panel. 
       If using a border the radius will apply to the inner edge of the border. 
     Checklist.onmouseup sets self.optindex to the index of the selected item. 
       Index now available to use in onmouseup override. This may be useful if you
       need to see which item was clicked.
     20251105 Added shadows.
     20251109 Removed property "pad. Replaces with "pad_x" and "pad_y".  
       
--]]
---------------------------------------------------------------------
-- Requires that Lokasenna_GUI v2 be loaded.

if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end

--zzz
---------------------------------------------------------------------
-- DEFAULTS:
-- defaults must be before dh_Option:new because dh_Option:new is local.

local defaults = {
    w = 128,
    h = 128,
    swap = false,
    dir = "v",
    opt_size = 16,
	border_width = 2,
	radius = 0,    
    optarray = {"Option 1"},
        	    
	caption = "",
	font_caption = "sans22",
	cap_pos = "top",
    cap_pad_x = 4,
    cap_pad_y = 4,
	cap_centered = false,
	shadow_caption = false,
	    
	font_text = "sans22",	
	pad_x = 10,	
	pad_y = 8,
	shadow_text = false, 	    
    shadow = false,
    
    allow_sel_outline = false,	

	col_bg = "wnd_bg",
	col_border = "panel_border",
	col_text = "txt",    
    col_cap_text = "txt", 
    col_active = "elm_active",
    col_backdrop = "wnd_bg",
         
}

---------------------------------------------------------------------
-- Creation parameters: 
-- name, z, x, y, w, h, caption, opts, dir[, ...]
---------------------------------------------------------------------
local dh_Option = GUI.Element:new()

function dh_Option:new(name, z, x, y, w, h, caption, opts, dir, ...)

	local option = (not x and type(z) == "table") and z or {}

	option.name = name
	option.type = "dh_Option"

	option.z = option.z or z

	option.x = option.x or x
    option.y = option.y or y
    option.w = option.w or w or defaults.w
    option.h = option.h or h or defaults.h
	
	-- First, check if optarray.
    if not option.optarray then
    
        option.optarray = {}
    
        -- Next, check if opts.
        local opts = option.opts or opts or "Option 1"        

        if type(opts) == "table" then

            option.optarray = opts

        elseif type(opts) == "string" then
            -- Given a comma separated string.
	        -- Parse the string of options into a table
            local tempidx = 1
            for word in string.gmatch(opts, '([^,]*)') do
                option.optarray[tempidx] = word
                tempidx = tempidx + 1
            end
        end
        
    else
        if #option.optarray == 0 then option.optarray = {"Option 1"} end    
    end	
    
	option.dir = option.dir or dir or defaults.dir

	option.caption = option.caption or caption or defaults.caption
	option.font_caption = option.font_caption or defaults.font_caption
	option.cap_pos = option.cap_pos or defaults.cap_pos  -- top, inside
	option.cap_pad_x = option.cap_pad_x or defaults.cap_pad_x
	option.cap_pad_y = option.cap_pad_y or defaults.cap_pad_y
	option.cap_centered = option.cap_centered or defaults.cap_centered
	
	-- Size of the option bubbles
	option.opt_size = option.opt_size or defaults.opt_size	
	option.pad_x = option.pad_x or defaults.pad_x	
	option.pad_y = option.pad_y or defaults.pad_y	
    
	option.font_text = option.font_text or defaults.font_text

	option.swap = option.swap or defaults.swap

	option.border_width = option.border_width or defaults.border_width
	option.radius = option.radius or defaults.radius	    
	
    option.shadow = option.shadow or defaults.shadow
    option.shadow_caption = option.shadow_caption or defaults.shadow_caption
    option.shadow_text = option.shadow_text or defaults.shadow_text    
    
    if option.allow_sel_outline == nil then
        option.allow_sel_outline = defaults.allow_sel_outline
    end
    
----colors---------------------------
    -- Caption
	option.col_cap_text = option.col_cap_text or defaults.col_cap_text    

    -- Element
    option.col_bg = option.col_bg or defaults.col_bg
	option.col_border = option.col_border or defaults.col_border
	option.col_text = option.col_text or defaults.col_text

    option.col_active = option.col_active or defaults.col_active
	option.col_backdrop = option.col_backdrop or defaults.col_backdrop    
-------------------------------------

	GUI.redraw_z[option.z] = true

	setmetatable(option, self)
    self.__index = self
    return option

end


function dh_Option:init()

    --GUI.Msg("\n## dh_Option:init : " .. self.name)
    
    -- Make sure we're not trying to use the base class.
    
    if self.type == "dh_Option" then
        reaper.ShowMessageBox(  "'"..self.name.."' was initialized as an dh_Option element,"..
                                "but dh_Option doesn't do anything on its own!",
                                "GUI Error", 0)
        
        GUI.quit = true
        return
    end

	self.buffs = self.buffs or GUI.GetBuffer(2)
	
	-- Draw options to buffer so they can be blitted later.
	
	gfx.setimgdim(self.buffs[2], -1, -1)
	gfx.setimgdim(self.buffs[2], 2 * self.opt_size + 4, 2 * self.opt_size + 2)
	gfx.dest = self.buffs[2]
	
    self:initoptions()
    
    -- Draw any borders and fields w/ optional shadows.
    
    local x, y, w, h = self.x, self.y, self.w, self.h
    local bw = self.border_width
    local rad = self.radius  -- radius of bg rectangle.
    local sd = self.shadow and GUI.shadow_dist or 0
    local sa = GUI.colors["shadow"][4]
    -- In case element created before gfx opened.    
    if sa > 1 then sa = sa / 255 end

	gfx.setimgdim(self.buffs[1], -1, -1)
	gfx.setimgdim(self.buffs[1], w + sd, h + sd)
	gfx.dest = self.buffs[1]	
	
	-- Draw backdrop for better antialiasing of roundrect.
	if rad > 0 then
	
	    GUI.color(self.col_backdrop)
    	gfx.rect(0, 0, w + sd, h + sd)
	
	end
	
    -- If no border then no shadow. Draw only bg then return.
   
    if bw == 0 then

        GUI.color(self.col_bg)
	   
        if rad > 0 then
            GUI.roundrect(0, 0, w - 1, h - 1, rad, 1, 1)
        else
            gfx.rect(0, 0, w, h, 1)
        end
       
        return
    end

    --!!! GUI.roundrect yields wierd results when using shadow. 
    -- It seems that gfx.circle sometimes adds 1 to x and y when it shouldn't.
    -- I rewrote this function and put it in dh_Toolkit_shared as a hack.
   
    -- Draw outer shadow.
--zzsh
    -- Temporary buffer for drawing shadow.
    local sh_buff

    if self.shadow then

        if rad > 0 then
       
            if self.shadow then
                sh_buff = sh_buff or GUI.GetBuffer()
                gfx.setimgdim(sh_buff, -1, -1)
                gfx.setimgdim(sh_buff, w, h)
            end
       
            gfx.dest = sh_buff   
                
            -- Draw shadow shape opaque.    
            GUI.color("black")
            GUI.roundrect(0, 0, w - 1, h - 1, rad + bw + sd + 1, 1, 1)
            
            -- Then lighten whole buffer.
            gfx.muladdrect(0, 0, w, h, 1, 1, 1, sa, 0, 0, 0, 0 )     
            
            --# Blit shadow to main buffer.
            gfx.dest = self.buffs[1]
            gfx.blit(sh_buff, 1, 0, 0, 0, w, h, sd, sd)        
         
        else
            GUI.color(GUI.colors["shadow"])
            gfx.rect(sd, sd, w, h, 1)
        end
    end

	-- Draw border
	
    GUI.color(self.col_border)
    
    -- rad is to inside of border.
    if rad > 0 then
       GUI.roundrect(0, 0, w - 1, h - 1, rad + bw, 1, 1)
    else
        gfx.rect(0, 0, w, h, 1)
    end
    
    -- # Draw background
    
    GUI.color(self.col_bg)
    
    if rad > 0 then
        GUI.roundrect(bw, bw, w - ((2 * bw)) - 1, h - ((2 * bw)) - 1, rad, 1, 1)
    else
        gfx.rect(bw, bw, w - ((2 * bw)), h - ((2 * bw)), 1)
    end	            

	-- Draw inner shadow.
	
    if self.shadow then
    
        if rad > 0 then
        
            -- Reinitialize shadow buffer.
            gfx.setimgdim(self.sh_buff, -1, -1)
            gfx.setimgdim(self.sh_buff, w, h)        
            gfx.dest = sh_buff
            
            -- Draw shadow shape opaque.    
            GUI.color("black")
            GUI.roundrect(0, 0, w - (2 * bw) - 1, h - (2 * bw) - 1, rad, 1, 1) 
                   
            -- Then lighten whole buffer.
            gfx.muladdrect(0, 0, w - (2 * bw), h - (2 * bw), 1, 1, 1, sa, 0, 0, 0, 0 )     
            
            --# Blit shadow to main buffer
            gfx.dest = self.buffs[1]
            gfx.blit(sh_buff, 1, 0, 0, 0, w - (2 * bw), h - (2 * bw), bw, bw) 
                   
            -- Draw inner bg rectangle --   
            GUI.color(self.col_bg)
            GUI.roundrect(bw + sd, bw + sd, w - ((2 * bw) + sd) - 1, h - ((2 * bw) + sd) - 1, rad, 1, 1)            
            
        else
            GUI.color(GUI.colors["shadow"])
            gfx.rect(bw, bw, w - (2 * bw) , h - (2 * bw), 1)
            
            -- Draw inner bg rectangle --
            GUI.color(self.col_bg)
            gfx.rect(bw + sd, bw + sd, w - ((2 * bw) + sd), h - ((2 * bw) + sd), 1)
            
        end
        
    end
    
    --!!! IMPORTANT !
    if sh_buff then GUI.FreeBuffer(sh_buff) end

end  -- <init>


function dh_Option:ondelete()

	GUI.FreeBuffer(self.buffs)

end

------------------------------------
-------- Drawing methods -----------
------------------------------------

function dh_Option:draw()

    local x, y, w, h = self.x, self.y, self.w, self.h
    local sd = self.shadow and GUI.shadow_dist or 0

--zzdraw

	-- Expand for shadow.
    if self.shadow then
        w = w + sd
        h = h + sd
    end
    
    gfx.blit(self.buffs[1], 1, 0, 0, 0, w, h, x, y)
    
    if self.caption and self.caption ~= "" then 
        self:drawcaption() 
    end

    self:drawoptions()
    
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

--zzcap  --zzopt
function dh_Option:drawcaption()

    --GUI.Msg("\n** dh_Option:drawcaption: self.cap_pad_x is: " .. tostring(self.cap_pad_x))
    --GUI.Msg("** dh_Option:drawcaption: self.cap_pad_y is: " .. tostring(self.cap_pad_y))    
    --GUI.Msg("** dh_Option:drawcaption: self.caption is: " .. self.caption)    

    GUI.font(self.font_caption)
    
    local str_w, str_h = gfx.measurestr(self.caption)
    self.cap_h = str_h -- needed for draw options
            
    local str_y
    local col_cap
    
	if self.cap_pos == "top" then
	    str_y = str_h + self.cap_pad_y
        GUI.color(self.col_backdrop)
	else  -- inside
	    str_y = -(self.border_width + self.cap_pad_y)
        GUI.color(self.col_bg)	    
	end  
	  
	if self.cap_centered then
	    gfx.x = self.x + (self.w - str_w) / 2
	else
        gfx.x = self.x + self.cap_pad_x
    end
    
    gfx.y = self.y - str_y
    
    --GUI.Msg("\n** dh_Option:drawcaption: gfx.x is: " .. tostring(gfx.x))
    --GUI.Msg("** dh_Option:drawcaption: gfx.y is: " .. tostring(gfx.y))     

    --GUI.text_bg(str, self.col_backdrop)
    
    --GUI.color(self.col_backdrop)
    gfx.rect(gfx.x, gfx.y, str_w, str_h, 1)

    if self.shadow_caption then
        GUI.shadow(self.caption, self.col_cap_text, "shadow")
    else
        GUI.color(self.col_cap_text)
        gfx.drawstr(self.caption)
    end

end

--zzpad
function dh_Option:drawoptions()
    --GUI.Msg("\n** dh_Option:drawoptions: self.name is: " .. self.name)
    --GUI.Msg("\n** dh_Option:drawoptions: self.cap_h is: " .. tostring(self.cap_h))        
    local x, y, w, h = self.x, self.y, self.w, self.h

    local horz = self.dir == "h" 
    local bw = self.border_width

    -- Bump everything up/down for the caption.
    -- Assuming cap_h = 24; cap_pad_y  = 4
    -- above: 28; middle: 12; below: -(bw + 4)
    
    if self.cap_pos == "inside" then    
        y = y + bw + self.cap_pad_y + self.cap_h + self.pad_y
    else  -- if top or no caption
        y = y + bw + self.pad_y
    end
    
	local opt_size = self.opt_size
    local str, opt_x, opt_y

	for i = 1, #self.optarray do

		str = self.optarray[i]
		if str ~= "_" then
            
            -- !!! opt_y needs to be adjusted for caption!            
            
            if self.dir == "h" then  -- Do horz stuff
                
                if self.swap then
                    opt_x = x + (i - 1) * (opt_size + self.pad_x) 
                    opt_y = y
                else
                    opt_x = x + (i - 1) * (opt_size + self.pad_x) 
                    opt_y = y + opt_size + bw + self.pad_y                
                
                end    
            
            else -- Do vert stuff
            
                if self.swap then
                    opt_x = x + w - (opt_size + self.pad_x)
                    opt_y = y + (i - 1) * (opt_size + self.pad_y)
                else  -- no swap
                    opt_x = x + self.pad_x
                    opt_y = y + (i - 1) * (opt_size + self.pad_y)
                end
            
            end
            
            --GUI.Msg("** dh_Option:drawoptions: opt_x is: " .. tostring(opt_x)) 

			-- Draw the option bubble
            self:drawoption(opt_x, opt_y, opt_size, self:isoptselected(i))

            self:drawvalue(opt_x,opt_y, opt_size, str)

		end

	end

end


function dh_Option:drawoption(opt_x, opt_y, size, selected)

    gfx.blit(   self.buffs[2], 1,  0,
                selected and (size + 3) or 1, 1,
                size + 1, size + 1,
                opt_x, opt_y)

end

function dh_Option:drawvalue(opt_x, opt_y, opt_size, str)

    if not str or str == "" then return end

	GUI.font(self.font_text)

    local str_w, str_h = gfx.measurestr(str)

    if self.dir == "h" then
        gfx.x = opt_x + (opt_size - str_w) / 2
        --gfx.y = opt_y + (self.swap and (opt_size + 4) or -opt_size)  -- swap is good
        gfx.y = opt_y + (self.swap and (opt_size + 4) or -(opt_size + 8)) 
    else
        gfx.x = opt_x + (self.swap and -(str_w + 8) or 1.5 * opt_size)
        gfx.y = opt_y + (opt_size - str_h) / 2
    end

    GUI.text_bg(str, self.col_bg)    

    if self.shadow_text then    
        GUI.shadow(str, self.col_text, "shadow")
    else
        GUI.color(self.col_text)
        gfx.drawstr(str)
    end

end


------------------------------------
-------- Input helpers -------------
------------------------------------

function dh_Option:getmouseopt()

    local offset

    if self.cap_pos == "top" then
        offset = self.border_width + self.cap_pad_y

    elseif self.cap_pos == "inside" then
        offset = self.cap_h + self.border_width + self.cap_pad_y
        
    else
        -- GUI Builder can set it to left.        
        offset = 0
    end
   
   local len = #self.optarray

	-- See which option it's on

	local mouseopt = self.dir == "h"
            and (GUI.mouse.x - (self.x + self.pad_x))
					or	(GUI.mouse.y - (self.y + offset) )
					
    -- mouseopt now has mouse.y relative to table.
 
	mouseopt = mouseopt / ( (self.opt_size + (self.dir == "h" and self.pad_x or self.pad_y))  * len)

    -- Make sure num is between min and max

	mouseopt = GUI.clamp( math.floor(mouseopt * len) + 1 , 1, len )

    return self.optarray[mouseopt] ~= "_" and mouseopt or false
    
end


------------------------------------
-------- Radio methods -------------
------------------------------------

GUI.dh_Radio = {}
setmetatable(GUI.dh_Radio, {__index = dh_Option})
--zzz
-- So that GUI Builder can defaults.
GUI.dh_Radio.defaults = defaults

function GUI.dh_Radio:new(name, z, x, y, w, h, caption, opts, dir)

    local radio = dh_Option:new(name, z, x, y, w, h, caption, opts, dir)

    radio.type = "dh_Radio"

    radio.retval, radio.state = 1, 1

    setmetatable(radio, self)
    self.__index = self
    return radio

end

function GUI.dh_Radio:initoptions()
	--GUI.Msg("dh_Radio:initoptions name : " .. self.name)
	--!!! Changed by Dennis Horn 2025-02-02.
	-- gfx.rect draws a rect at (x,y,w,h [,filled by default]).
	-- gfx.rect draws (unfilled) a 1 pixel wide outline. 
	-- To get a "filled" with different color option bubble would have to
	-- draw a filled rect inside of outline rect.

	local r = self.opt_size / 2

	-- Option bubble
	
	-- Draw outline
    GUI.color(self.col_bg)	
	gfx.circle(r + 1, r + 1, r + 2, 1, 0)
	gfx.circle(3*r + 3, r + 1, r + 2, 1, 0)
	
	GUI.color(self.col_text)	
	
	gfx.circle(r + 1, r + 1, r, 0)
	gfx.circle(3*r + 3, r + 1, r, 0)

	gfx.circle(3*r + 3, r + 1, 0.6*r, 1)

end

function GUI.dh_Radio:val(newval)

	if newval ~= nil then
		self.retval = newval
		self.state = newval
		self:redraw()
	else
		return self.retval
	end

end


function GUI.dh_Radio:onmousedown()

	self.state = self:getmouseopt() or self.state

	self:redraw()

end


function GUI.dh_Radio:onmouseup()
    
    -- Bypass option for GUI Builder
    if not self.focus then
        self:redraw()
        return
    end
    
    --GUI.Msg("chkl_Tab3:radio onmouseup in normal method")
	-- Set the new option, or revert to the original if the cursor
    -- isn't inside the list anymore
	if GUI.IsInside(self, GUI.mouse.x, GUI.mouse.y) then
		self.retval = self.state
	else
		self.state = self.retval
	end
	
	-- ??? Why was this being set to false?
    --self.focus = false
    
	self:redraw()

end


function GUI.dh_Radio:ondrag()

	self:onmousedown()

	self:redraw()

end


function GUI.dh_Radio:onwheel()
--[[
	state = GUI.round(self.state +     (self.dir == "h" and 1 or -1)
                                    *   GUI.mouse.inc)
]]--

    self.state = self:getnextoption(    GUI.xor( GUI.mouse.inc > 0, self.dir == "h" )
                                        and -1
                                        or 1 )

	--if self.state < 1 then self.state = 1 end
	--if self.state > #self.optarray then self.state = #self.optarray end

	self.retval = self.state

	self:redraw()

end


function GUI.dh_Radio:isoptselected(opt)

   return opt == self.state

end


function GUI.dh_Radio:getnextoption(dir)

    local j = dir > 0 and #self.optarray or 1

    for i = self.state + dir, j, dir do

        if self.optarray[i] ~= "_" then
            return i
        end

    end

    return self.state

end

-- Make sure the box highlight goes away
function GUI.dh_Radio:lostfocus()
    --GUI.Msg("\n##  radio lost focus  ##")
    if self.allow_sel_outline then
        self:redraw()
    end
end

------------------------------------
-------- Checklist methods ---------
------------------------------------

GUI.dh_Checklist = {}
setmetatable(GUI.dh_Checklist, {__index = dh_Option})
--zzz
-- So that GUI Builder can defaults.
GUI.dh_Checklist.defaults = defaults

function GUI.dh_Checklist:new(name, z, x, y, w, h, caption, opts, dir)

    local checklist = dh_Option:new(name, z, x, y, w, h, caption, opts, dir)

    checklist.type = "dh_Checklist"

    checklist.optsel = {}

    setmetatable(checklist, self)
    self.__index = self
    return checklist

end

--zzcolor
function GUI.dh_Checklist:initoptions()

	local size = self.opt_size

	-- Option bubble
	
	--!!! Changed by Dennis Horn 2025-02-02.
	-- gfx.rect draws a rect at (x,y,w,h [,filled by default]).
	-- gfx.rect draws a 1 pixel wide outline. 
	-- To get a "filled" with different color option bubble would have to
	-- draw a filled rect inside of outline rect. 

	-- Draw outline
	GUI.color(self.col_text)	

	gfx.rect(1, 1, size, size, 0)        -- this draws outline around selected items?
    gfx.rect(size + 3, 1, size, size, 0) -- this draws outline around non-selected items?

    -- draw fill
	GUI.color(self.col_text)
	local p = size // 4
	gfx.rect(size + 3 + p, 1 + p, size - 2 * p, size - 2 * p, 1)	

end

--zzval
function GUI.dh_Checklist:val(newval)

	if newval ~= nil then
		if type(newval) == "table" then
			for k, v in pairs(newval) do
				self.optsel[tonumber(k)] = v
			end
			self:redraw()
			
        elseif type(newval) == "boolean" and #self.optarray == 1 then

            self.optsel[1] = newval
            self:redraw()
		end
	else
        if #self.optarray == 1 then
        
            --GUI.Msg("#self.optarray == 1 : " .. tostring(self.optsel[1]))
        
            return self.optsel[1]
        else
            local tmp = {}
            for i = 1, #self.optarray do
                tmp[i] = not not self.optsel[i]
            end
            return tmp
        end
        
	end

end


function GUI.dh_Checklist:onmouseup()
	--[[ --]]
	
	--GUI.Msg("\n# dh_Checklist:onmouseup self.focus is: " .. tostring(self.focus))
	   
    -- Bypass option for GUI Builder
    if not self.focus then
        self:redraw()
        return
    end
        
	--!!! Added by Dennis Horn 2022-03-14.
	--[[
       self:getmouseopt() now makes available to onmouseup.
         self.optarray[mouseopt] which is the boolean value at index mouseopt.
         Added mouseopt <option index> to return value.
       Now return should be boolean, index 
       These are both available for use in override.
    --]]
 
    local mouseopt = self:getmouseopt()
    
    --GUI.Msg("ckl mouseup mouseopt value is: " .. tostring(mouseopt) .. "\n")
    --GUI.Msg("ckl mouseup mouseopt type is: " .. type(mouseopt) .. "\n")
	--GUI.Msg("ckl mouseup optindex is: " .. tostring(optindex) .. "\n")    
    --GUI.Msg("ckl mouseup optindex type is: " .. type(optindex) .. "\n") 
	    
    
    if not mouseopt then return end

	self.optsel[mouseopt] = not self.optsel[mouseopt]

	--!!! Added by Dennis Horn 2025-02-03 so index can be used in override.
	--self.optindex = optindex
	self.optindex = mouseopt
	    
    --GUI.Msg("dho self.optsel[mouseopt] value is: " .. tostring(self.optsel[mouseopt]) .. "\n")
    --GUI.Msg("dho self.optsel[mouseopt] type is: " .. type(self.optsel[mouseopt]) .. "\n")
    --GUI.Msg("dho optindex type is: " .. type(optindex) .. "\n") 
	--GUI.Msg("dho optindex is: " .. tostring(optindex) .. "\n")
    --GUI.Msg("dho self.optsel[1] value is: " .. tostring(self.optsel[1]) .. "\n")		

    -- Why was this being set to false?
    --self.focus = false
    
	self:redraw()

end

--[[
function GUI.dh_Checklist:onmousedown()
    --self.focus = true
	--self:redraw()
end
--]]

function GUI.dh_Checklist:isoptselected(opt)

   return self.optsel[opt]

end

-- Make sure the box highlight goes away
function GUI.dh_Checklist:lostfocus()
    --GUI.Msg("\n##  checklist lost focus  ##")
    if self.allow_sel_outline then
        self:redraw()
    end

end