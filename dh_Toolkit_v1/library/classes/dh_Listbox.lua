-- NoIndex: true

-- dh_Listbox.lua
-- Date: 20250908

---------------------------------------------------------------------
-- Lokasenna_GUI - Listbox class
--   For documentation, see this class's page on the project wiki:
--     https://github.com/jalovatt/Lokasenna_GUI/wiki/Listbox
---------------------------------------------------------------------
--[[ Modified by Dennis Horn.

     Same as Lokasenna Listbox except for:
     Changed some property names and default values.
     Added ability to change line_height and scrollbar_width.
     Added ability to change frame color.
     Added ability to change selected text highlight color.
     Added ability to customize the scrollbar colors.
     Added property "curr_sel" to hold index of last selected item. May be useful when no "multi-select". 
       Modified onmouseup to set "curr_sel".
     Modified GUI.dh_Listbox:val to return "curr_sel" and list item value when no "multi-select". 
     Note: Caption is optional. If used it will use the colors in properties "col_cap_bg" and "col_cap_text". 

--]]
---------------------------------------------------------------------
-- Requires that Lokasenna_GUI v2 be loaded.

if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end
---------------------------------------------------------------------
-- Creation parameters: !!! Needs updating to add colors.
-- name, z, x, y, w, h[, list, caption, pad, shadow]
---------------------------------------------------------------------
GUI.dh_Listbox = GUI.Element:new()

function GUI.dh_Listbox:new(name, z, x, y, w, h, list, multi, caption, pad, shadow)

	local lst = (not x and type(z) == "table") and z or {}

	lst.name = name
	lst.type = "dh_Listbox"

	lst.z = lst.z or z

	lst.x = lst.x or x
    lst.y = lst.y or y
    lst.w = lst.w or w
    lst.h = lst.h or h

	lst.list = lst.list or list or {}
		
    if lst.multi == nil then
        lst.multi = multi or false
    end	
	
	lst.caption = lst.caption or caption or ""
	lst.pad = lst.pad or pad or 4

    if lst.shadow == nil then
        lst.shadow = true
    end	

----colors---------------------------
    -- Caption
    lst.col_cap_bg = lst.col_cap_bg or "wnd_bg"
    lst.col_cap_text = lst.col_cap_text or "txt" 
       
    -- Box
    lst.col_frame = lst.col_frame or "elm_frame" 
	lst.col_bg = lst.col_bg or "elm_bg"
	lst.col_text = lst.col_text or "elm_txt"
    --lst.col_active = lst.col_active or "elm_fill"  -- Thinking of using for outline for when focused by tabbing.	
	lst.col_sel_text = lst.col_sel_text or "sel_txt"  --"elm_fill"

	-- Scrollbar
	lst.col_track = lst.col_track or "elm_track"  --"elm_fill"
	lst.col_thumb = lst.col_thumb or "elm_thumb"  --"elm_frame"
	lst.col_sb_outline = lst.col_sb_outline or "elm_outline"
-------------------------------------
--zzz
    -- If true uses sel_alpha to override sel_txt alpha.
    lst.use_sel_alpha = lst.use_sel_alpha or false
    -- Use negative value to darken.
    lst.sel_alpha = lst.sel_alpha or 0.5
    
	lst.font_caption = lst.font_caption or "sans20"
	lst.font_text = lst.font_text or "sans22"

    lst.line_height = lst.line_height or 1.25
    lst.scrollbar_width = lst.scrollbar_width or 8

	lst.retval = lst.retval or {}
	lst.curr_sel = 0
		
	lst.wnd_y = 1    -- index of selected item.
	lst.wnd_h, lst.wnd_w, lst.char_w = nil, nil, nil

	GUI.redraw_z[lst.z] = true

	setmetatable(lst, self)
	self.__index = self
	return lst

end


function GUI.dh_Listbox:init()
    --GUI.Msg("dh_Listbox:init name : " .. self.name)
	-- If we were given a CSV, process it into a table
	if type(self.list) == "string" then self.list = self:CSVtotable(self.list) end

	local x, y, w, h = self.x, self.y, self.w, self.h

	self.buff = GUI.GetBuffer()

	gfx.dest = self.buff
	gfx.setimgdim(self.buff, -1, -1)
	gfx.setimgdim(self.buff, w, h)

	GUI.color(self.col_bg)
	gfx.rect(0, 0, w, h, 1)

	GUI.color(self.col_frame)
	gfx.rect(0, 0, w, h, 0)

    -- For testing
    --GUI.Msg("dh_Listbox:init w : " .. tostring(self.w))
    --GUI.Msg("dh_Listbox:init h : " .. tostring(self.h))    
    --GUI.Msg("bh_Listbox:init wnd_y : " .. tostring(self.wnd_h))
    
    -- window should be open.
	if self.wnd_h then self:wnd_recalc() end
    
end


function GUI.dh_Listbox:ondelete()

	GUI.FreeBuffer(self.buff)

end

---------------------------------
-------- Drawing methods---------
---------------------------------

function GUI.dh_Listbox:draw()


	local x, y, w, h = self.x, self.y, self.w, self.h

	local caption = self.caption
	local pad = self.pad

	-- Some values can't be set in :init() if the window isn't open yet.
	-- Measurements won't work.
	if not self.wnd_h then self:wnd_recalc() end

	-- Draw the caption
	if caption and caption ~= "" then self:drawcaption() end

	-- Draw the background and frame
	gfx.blit(self.buff, 1, 0, 0, 0, w, h, x, y)

	-- Draw the text
	self:drawtext()

	-- Highlight any selected items
	self:drawselection()

	-- Vertical scrollbar
	if #self.list > self.wnd_h then self:drawscrollbar() end

end


function GUI.dh_Listbox:drawcaption()

	local str = self.caption

	GUI.font(self.font_caption)
	local str_w, str_h = gfx.measurestr(str)
	gfx.x = self.x - str_w - self.pad
	gfx.y = self.y + self.pad
	GUI.text_bg(str, self.col_cap_bg)

	if self.shadow then
		GUI.shadow(str, self.col_cap_text, "shadow")
	else
		GUI.color(self.col_cap_text)
		gfx.drawstr(str)
	end

end

--zztext 
function GUI.dh_Listbox:drawtext()

	GUI.color(self.col_text)
	GUI.font(self.font_text)

	-- wnd_h is how many lines can fit vertically.
	-- wnd_y is index of top item.
	-- wnd_ bottom is index of bottom item.
	
    local str_w, str_h = gfx.measurestr("M")
   	str_h = str_h * self.line_height
   	local str_x = self.x + self.pad
   	local str_y = self.y + self.pad
    local r = self.w - self.pad
    local b = self.h - self.pad

	for i = self.wnd_y, math.min(self:wnd_bottom() - 1, #self.list) do
       	gfx.x = str_x
	    gfx.y = str_y
	    --gfx.drawstr(str, 0, r, b)
	    gfx.drawstr(self.list[i])
	    str_y = str_y + str_h
	end

end

--zzz
function GUI.dh_Listbox:drawselection()
    --GUI.Msg("-------------------------------------------")
    --GUI.Msg("dh_Listbox:drawselection NAME :" .. self.name)
	local off_x = self.x + self.pad
	local off_y = self.y + self.pad
	local x, y, w, h

	w = self.w - 2 * self.pad
	
    -- If color is "sel_txt" will use sel_txt alpha or override.
    -- If color not "sel_txt" will use sel_alpha.

    GUI.color(self.col_sel_text)

--[[  --]]  
    if self.col_sel_text == "sel_txt" and self.use_sel_alpha == false then
        --GUI.Msg("self.use_sel_txt alpha")
        gfx.a = GUI.colors.sel_txt[4]
    else
        -- Probably don't want to use color other than sel_txt, but just in case.
        --GUI.Msg("self.use_sel_alpha")
        gfx.a = self.sel_alpha -- default 0.5 
    end

--[[    
    if self.name == "lbx_Tab3" or self.name == "lbx_PropertyAssignments" then
        GUI.Msg("dh_Listbox:drawselection name : " .. self.name)
        GUI.Msg("dh_Listbox:drawselection sel_txt alpha :" .. tostring(GUI.colors.sel_txt[4]))        
        GUI.Msg("dh_Listbox:drawselection self_alpha :" .. tostring(self.sel_alpha))
        GUI.Msg("dh_Listbox:drawselection gfx.a :" .. tostring(gfx.a))    
    end
--]]
        
    gfx.mode = 1  -- additive
    	
	for i = 1, #self.list do

		if self.retval[i] and i >= self.wnd_y and i < self:wnd_bottom() then

			y = off_y + (i - self.wnd_y) * self.char_h
			gfx.rect(off_x, y, w, self.char_h, true)

		end

	end

	gfx.mode = 0
	gfx.a = 1

end


function GUI.dh_Listbox:drawscrollbar()
    --GUI.Msg("dh_Listbox:drawscrollbar : " .. self.name)
    
	local x, y, w, h = self.x, self.y, self.w, self.h
	
	--local sx, sy, sw, sh = x + w - 8 - 4, y + 4, 8, h - 12
	local sx = x + w - self.scrollbar_width - 4
    local sy = y + 4
    local sw = self.scrollbar_width
    local sh = h - 8

	-- Draw a gradient to fade out the last ~16px of text
	GUI.color(self.col_bg)
	for i = 0, 15 do
		gfx.a = i/15
		gfx.line(sx + i - 15, y + 2, sx + i - 15, y + h - 4)
	end

	gfx.rect(sx, y + 2, sw + 2, h - 4, true)

	-- Draw scrollbar track
	GUI.color(self.col_track)
	GUI.roundrect(sx, sy, sw, sh, 4, 1, 1)

	GUI.color(self.col_sb_outline)
	GUI.roundrect(sx, sy, sw, sh, 4, 1, 0)

	-- Draw scrollbar thumb
	local fh = (self.wnd_h / #self.list) * sh - 4
	if fh < 4 then fh = 4 end
	local fy = sy + ((self.wnd_y - 1) / #self.list) * sh + 2
	
	-- ? Can't I do math in creation and store the metrics?
	--  8 * .25 = 2 -> 2
	-- 12 * .25 = 3 -> 3
	-- 16 * .25 = 4 -> 4
	
	local s_edge = math.floor(sw * 0.375)  
    --if s_edge < 1 then s_edge = 1 end
    --if s_edge > 4 then s_edge = 4 end
    local sr = (sw - 4) / 2
	GUI.color(self.col_thumb)

	GUI.roundrect(sx + 2, fy, sw - 4, fh, sr, 1, 1)		

end


function GUI.dh_Listbox:val(newval)

-- self.list has names displayed in listbox.
-- self.retval has index of selected item; table if multi.    

	if newval then

        if type(newval) == "table" then

            for i = 1, #self.list do
                self.retval[i] = newval[i] or nil
            end

        elseif type(newval) == "number" then

            newval = math.floor(newval)
            for i = 1, #self.list do
                self.retval[i] = (i == newval)
            end

        end

		self:redraw()

	else

		if self.multi then
			return self.retval
		else
			-- self.retval = {[item] = true}
			-- item is last selected item
			-- self.list is list of displayed names
		
			for k, v in pairs(self.retval) do
				--return k
			    return k, self.list[k]
			end

		end

	end

end

---------------------------------
------ Input methods ------------
---------------------------------

function GUI.dh_Listbox:onmouseup()

	if not self:overscrollbar() then

		local item = self:getitem(GUI.mouse.y)
		
		self.curr_sel = item

		if self.multi then
			-- Ctrl
			if GUI.mouse.cap & 4 == 4 then
				self.retval[item] = not self.retval[item]
			-- Shift
			elseif GUI.mouse.cap & 8 == 8 then
				self:selectrange(item)
			else
				self.retval = {[item] = true}
			end
		else
			self.retval = {[item] = true}
		end
	end

	self:redraw()

end


function GUI.dh_Listbox:onmousedown(scroll)

	-- If over the scrollbar, or we came from :ondrag with an origin point
	-- that was over the scrollbar...
	if scroll or self:overscrollbar() then

        local wnd_c = GUI.round( ((GUI.mouse.y - self.y) / self.h) * #self.list  )
		self.wnd_y = math.floor( GUI.clamp(1, wnd_c - (self.wnd_h / 2), #self.list - self.wnd_h + 1) )

		self:redraw()

	end

end


function GUI.dh_Listbox:ondrag()

	if self:overscrollbar(GUI.mouse.ox) then

		self:onmousedown(true)

	-- Drag selection?
	else


	end

	self:redraw()

end


function GUI.dh_Listbox:onwheel(inc)

	local dir = inc > 0 and -1 or 1

	-- Scroll up/down one line
	self.wnd_y = GUI.clamp(1, self.wnd_y + dir, math.max(#self.list - self.wnd_h + 1, 1))

	self:redraw()

end



---------------------------------
-------- Helpers ----------------
---------------------------------
--zzrecalc 
-- wnd_h is how many lines can fit vertically.
-- wnd_w is how many chars can fit horizontally.

-- Updates internal values for the window size
-- wnd_h is count of lines; how many lines fit in window.
function GUI.dh_Listbox:wnd_recalc()

	GUI.font(self.font_text)

	self.char_w, self.char_h = gfx.measurestr("M")
	self.char_h = self.char_h * self.line_height    
    self.wnd_h = math.floor((self.h - 2 * self.pad) / self.char_h)
    self.wnd_w = math.floor(self.w / self.char_w)
    
end


-- Get the bottom edge of the window (in rows)
function GUI.dh_Listbox:wnd_bottom()

	return self.wnd_y + self.wnd_h

end


-- Determine which item the user clicked
function GUI.dh_Listbox:getitem(y)

	--local item = math.floor( ( (y - self.y) / self.h ) * self.wnd_h) + self.wnd_y

	GUI.font(self.font_text)

	local item = math.floor(	(y - (self.y + self.pad))
								/	self.char_h)
				+ self.wnd_y

	item = GUI.clamp(1, item, #self.list)

	return item

end


-- Split a CSV into a table
function GUI.dh_Listbox:CSVtotable(str)

	local tmp = {}
	for line in string.gmatch(str, "([^,]+)") do
		table.insert(tmp, line)
	end

	return tmp

end


-- Is the mouse over the scrollbar (true) or the text area (false)?
function GUI.dh_Listbox:overscrollbar(x)

	--return (#self.list > self.wnd_h and (x or GUI.mouse.x) >= (self.x + self.w - 12))
	return (#self.list > self.wnd_h and (x or GUI.mouse.x) >= ((self.x + self.w) - self.scrollbar_width))	

end


-- Selects from the first selected item to the current mouse position
function GUI.dh_Listbox:selectrange(mouse)

	-- Find the first selected item
	local first
	for k, v in pairs(self.retval) do
		first = first and math.min(k, first) or k
	end

	if not first then first = 1 end

	self.retval = {}

	-- Select everything between the first selected item and the mouse
	for i = mouse, first, (first > mouse and 1 or -1) do
		self.retval[i] = true
	end

end