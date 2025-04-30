-- NoIndex: true

-- dh_Options.lua
-- Modified: 20250405 - add dh_ to subtypes

--[[ Modified Lokasenna_GUI - Option class 

     Originally modified by Dennis R. Horn 2025-02-14:
     
     to add extra colors for theming.
      
	 2025-02-14 Added fields "opt_frame" and "opt_fill".
	   Checklist.onmouseup calls Option:getmouseopt() which
         now returns both boolean value AND index of clicked item.
         (Index now avaiable to use in onmouseup override.)
     2025-02-16 Changed to add self.optindex = mouseopt
       to Checklist.onmouseup to accomplish same.
--]]

--[[	Lokasenna_GUI - Options classes

    This file provides two separate element classes:

    dh_Radio       A list of options from which the user can only choose one at a time.
    dh_Checklist   A list of options from which the user can choose any, all or none.

    Both classes take the same parameters on creation, and offer the same parameters
    afterward - their usage only differs when it comes to their respective :val methods.

    For documentation, see the class pages on the project wiki:
    https://github.com/jalovatt/Lokasenna_GUI/wiki/Checklist
    https://github.com/jalovatt/Lokasenna_GUI/wiki/Radio

    Creation parameters:
	name, z, x, y, w, h, caption, opts[, dir, pad]

--]]

if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end

local dh_Option = GUI.Element:new()

function dh_Option:new(name, z, x, y, w, h, caption, opts, dir, pad)

	local option = (not x and type(z) == "table") and z or {}

	option.name = name
	option.type = "dh_Option"

	option.z = option.z or z

	option.x = option.x or x
    option.y = option.y or y
    option.w = option.w or w
    option.h = option.h or h

	option.caption = option.caption or caption

    if option.frame == nil then
        option.frame = true
    end

	option.bg = option.bg or "wnd_bg"

	option.dir = option.dir or dir or "v"
	option.pad = option.pad or pad or 4

	option.col_txt = option.col_txt or "txt"
	option.col_fill = option.col_fill or "elm_fill"
	
	--!!! Added by Dennis Horn.
	option.opt_frame = option.opt_frame or "elm_frame"
	option.opt_fill = option.opt_fill or "elm_fill"

	option.font_a = option.font_a or 2
	option.font_b = option.font_b or 3

    if option.shadow == nil then
        option.shadow = true
    end

    if option.shadow == nil then
        option.swap = false
    end

	-- Size of the option bubbles
	option.opt_size = option.opt_size or 20

	-- Parse the string of options into a table
    if not option.optarray then
        option.optarray = {}
    
        local opts = option.opts or opts

        if type(opts) == "table" then

            for i = 1, #opts do
                option.optarray[i] = opts[i]
            end

        else

            local tempidx = 1
            for word in string.gmatch(opts, '([^,]*)') do
                option.optarray[tempidx] = word
                tempidx = tempidx + 1
            end

        end
    end

	GUI.redraw_z[option.z] = true

	setmetatable(option, self)
    self.__index = self
    return option

end


function dh_Option:init()

    -- Make sure we're not trying to use the base class.
    if self.type == "dh_Option" then
        reaper.ShowMessageBox(  "'"..self.name.."' was initialized as an dh_Option element,"..
                                "but dh_Option doesn't do anything on its own!",
                                "GUI Error", 0)

        GUI.quit = true
        return

    end

	self.buff = self.buff or GUI.GetBuffer()

	gfx.dest = self.buff
	gfx.setimgdim(self.buff, -1, -1)
	gfx.setimgdim(self.buff, 2*self.opt_size + 4, 2*self.opt_size + 2)


    self:initoptions()


	if self.caption and self.caption ~= "" then
		GUI.font(self.font_a)
		local str_w, str_h = gfx.measurestr(self.caption)
		self.cap_h = 0.5*str_h
		self.cap_x = self.x + (self.w - str_w) / 2
	else
		self.cap_h = 0
		self.cap_x = 0
	end

end


function dh_Option:ondelete()

	GUI.FreeBuffer(self.buff)

end

--zzcolor
function dh_Option:draw()

	if self.frame then
		--!!! Changed by Dennis Horn 2022-02-22.
		--GUI.color("elm_frame")
		GUI.color(self.opt_frame)
		gfx.rect(self.x, self.y, self.w, self.h, 0)
	end

    if self.caption and self.caption ~= "" then self:drawcaption() end

    self:drawoptions()

end

--[[ Testing!!!
function dh_Option:testfunc()
	--dh_log("\ndh_Option:testfunc()\n")
end
]]--

------------------------------------
-------- Input helpers -------------
------------------------------------

function dh_Option:getmouseopt()

   local len = #self.optarray

	-- See which option it's on
	local mouseopt = self.dir == "h"
                    and (GUI.mouse.x - (self.x + self.pad))
					or	(GUI.mouse.y - (self.y + self.cap_h + 1.5*self.pad) )

	mouseopt = mouseopt / ((self.opt_size + self.pad) * len)
	mouseopt = GUI.clamp( math.floor(mouseopt * len) + 1 , 1, len )
--zzopt
	--[[
	   Added mouse option return value 2022-03-14 by Dennis Horn.
	   This way returns expression result AND index. 
	   (They may be the same.)
	--]]
	
	-- Returns last operand where expression is true, or default.
	-- A and B or false. Must evaluate "and" in A and B.
	-- A and B is true returns B ; in this case mouseopt.
	-- Cannot do (A and B) or false. 
	-- If (A and B) were true would return true.
	-- If (A and B) were false would return default <false>.
	-- Evaluates first operand (self.optarray[mouseopt] ~= "_") 
	-- If true evaluates (and mouseopt). 
	-- If true doesn't evaluate (or false).
	--   because previous combination resulted in true.
	-- Therefore returns last operand that resulted in true
	--   which is mouseopt.
	-- If first operand results in false will return default <or false>. 
	
    --dh_log("option getmouseopt mouseopt value is: " .. tostring(mouseopt) .. "\n")
    --dh_log("option getmouseopt self.optarray[mouseopt] value is: " .. tostring(self.optarray[mouseopt]) .. "\n")
    	
    return self.optarray[mouseopt] ~= "_" and mouseopt or false
    --return self.optarray[mouseopt] ~= "_" and mouseopt or false, mouseopt

end

------------------------------------
-------- Drawing methods -----------
------------------------------------

function dh_Option:drawcaption()

    GUI.font(self.font_a)

    gfx.x = self.cap_x
    gfx.y = self.y - self.cap_h

    GUI.text_bg(self.caption, self.bg)

    GUI.shadow(self.caption, self.col_txt, "shadow")

end


function dh_Option:drawoptions()

    local x, y, w, h = self.x, self.y, self.w, self.h

    local horz = self.dir == "h"
	local pad = self.pad

    -- Bump everything down for the caption
    y = y + ((self.caption and self.caption ~= "") and self.cap_h or 0) + 1.5 * pad

    -- Bump the options down more for horizontal options
    -- with the text on top
	if horz and self.caption ~= "" and not self.swap then
        y = y + self.cap_h + 2*pad
    end

	local opt_size = self.opt_size

    local adj = opt_size + pad

    local str, opt_x, opt_y

	for i = 1, #self.optarray do

		str = self.optarray[i]
		if str ~= "_" then

            opt_x = x + (horz   and (i - 1) * adj + pad
                                or  (self.swap  and (w - adj - 1)
                                                or   pad))

            opt_y = y + (i - 1) * (horz and 0 or adj)

			-- Draw the option bubble
            self:drawoption(opt_x, opt_y, opt_size, self:isoptselected(i))

            self:drawvalue(opt_x,opt_y, opt_size, str)

		end

	end

end


function dh_Option:drawoption(opt_x, opt_y, size, selected)

    gfx.blit(   self.buff, 1,  0,
                selected and (size + 3) or 1, 1,
                size + 1, size + 1,
                opt_x, opt_y)

end

function dh_Option:drawvalue(opt_x, opt_y, size, str)

    if not str or str == "" then return end

	GUI.font(self.font_b)

    local str_w, str_h = gfx.measurestr(str)

    if self.dir == "h" then

        gfx.x = opt_x + (size - str_w) / 2
        gfx.y = opt_y + (self.swap and (size + 4) or -size)

    else

        gfx.x = opt_x + (self.swap and -(str_w + 8) or 1.5*size)
        gfx.y = opt_y + (size - str_h) / 2

    end

    GUI.text_bg(str, self.bg)
    if #self.optarray == 1 or self.shadow then
        GUI.shadow(str, self.col_txt, "shadow")
    else
        GUI.color(self.col_txt)
        gfx.drawstr(str)
    end

end

------------------------------------
-------- Radio methods -------------
------------------------------------

GUI.dh_Radio = {}
setmetatable(GUI.dh_Radio, {__index = dh_Option})

function GUI.dh_Radio:new(name, z, x, y, w, h, caption, opts, dir, pad)

    local radio = dh_Option:new(name, z, x, y, w, h, caption, opts, dir, pad)

    radio.type = "dh_Radio"

    radio.retval, radio.state = 1, 1

    setmetatable(radio, self)
    self.__index = self
    return radio

end

function GUI.dh_Radio:initoptions()

	--!!! Changed by Dennis Horn 2025-02-02.
	-- gfx.rect draws a rect at (x,y,w,h [,filled by default]).
	-- gfx.rect draws a 1 pixel wide outline. 
	-- To get a "filled" with different color option bubble would have to
	-- draw a filled rect inside of outline rect.

	local r = self.opt_size / 2

	-- Option bubble
	GUI.color(self.bg)
	--GUI.color(self.opt_frame)
	gfx.circle(r + 1, r + 1, r + 2, 1, 0)
	gfx.circle(3*r + 3, r + 1, r + 2, 1, 0)
	
	--!!! Changed by Dennis Horn 2025-02-02.
	--GUI.color("elm_frame")
	GUI.color(self.opt_frame)	
	
	gfx.circle(r + 1, r + 1, r, 0)
	gfx.circle(3*r + 3, r + 1, r, 0)
	--GUI.color(self.col_fill)
	GUI.color(self.opt_fill)
	--gfx.circle(3*r + 3, r + 1, 0.5*r, 1)
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

	-- Set the new option, or revert to the original if the cursor
    -- isn't inside the list anymore
	if GUI.IsInside(self, GUI.mouse.x, GUI.mouse.y) then
		self.retval = self.state
	else
		self.state = self.retval
	end

    self.focus = false
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

------------------------------------
-------- Checklist methods ---------
------------------------------------

GUI.dh_Checklist = {}
setmetatable(GUI.dh_Checklist, {__index = dh_Option})

function GUI.dh_Checklist:new(name, z, x, y, w, h, caption, opts, dir, pad)

    local checklist = dh_Option:new(name, z, x, y, w, h, caption, opts, dir, pad)

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
	
	-- draw outline
	--GUI.color("elm_frame")
	GUI.color(self.opt_frame)	
    
	gfx.rect(1, 1, size, size, 0)        -- this draws outline around selected items.
   gfx.rect(size + 3, 1, size, size, 0) -- this draws outline around non-selected items.

   -- draw fill
	GUI.color(self.opt_fill)
	--GUI.color("white")
	--gfx.rect(size + 3 + 0.25*size, 1 + 0.25*size, 0.5*size, 0.5*size, 1)
	--gfx.rect(size + 3 + 0.2*size, 1 + 0.2*size, 0.65*size, 0.65*size, 1)
	gfx.rect(size + 3 + 0.2*size, 1 + 0.2*size, size-0.4*size, size-0.4*size, 1)

end


function GUI.dh_Checklist:val(newval)
	--reaper.ShowConsoleMsg("** setting options **\n")
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
            return self.optsel[1]
        else
            local tmp = {}
            for i = 1, #self.optarray do
                tmp[i] = not not self.optsel[i]
            end
            return tmp
        end
        
		--return #self.optarray > 1 and self.optsel or self.optsel[1]
	end

end

function GUI.dh_Checklist:onmouseup()
    
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
    
 --zzopt 
    local mouseopt = self:getmouseopt()
    --local mouseopt, optindex = self:getmouseopt()
    
    --dh_log("ckl mouseup mouseopt value is: " .. tostring(mouseopt) .. "\n")
    --dh_log("ckl mouseup mouseopt type is: " .. type(mouseopt) .. "\n")
	--dh_log("ckl mouseup optindex is: " .. tostring(optindex) .. "\n")    
    --dh_log("ckl mouseup optindex type is: " .. type(optindex) .. "\n") 
	    
    
    if not mouseopt then return end

	self.optsel[mouseopt] = not self.optsel[mouseopt]

    self.focus = false
	self:redraw()

	--!!! Added by Dennis Horn 2025-02-03 so index can be used in override.
	--self.optindex = optindex
	self.optindex = mouseopt
	    
    --dh_log("dho self.optsel[mouseopt] value is: " .. tostring(self.optsel[mouseopt]) .. "\n")
    --dh_log("dho self.optsel[mouseopt] type is: " .. type(self.optsel[mouseopt]) .. "\n")
    --dh_log("dho optindex type is: " .. type(optindex) .. "\n") 
	--dh_log("dho optindex is: " .. tostring(optindex) .. "\n")	

end


function GUI.dh_Checklist:isoptselected(opt)

   return self.optsel[opt]

end