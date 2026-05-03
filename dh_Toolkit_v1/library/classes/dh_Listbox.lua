-- NoIndex: true

-- dh_Listbox.lua
-- Date: 20260330

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
     20260223: Replace element frame with highlighted drawn.
               Added properties for frame modification.
     20260330: Changed how val(newval) handles a single number with no multi select.
               Removed property "curr_sel" as it is now redundant.             
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
-- name, z, x, y, w, h[, list, multi, caption, pad, shadow, ...]
---------------------------------------------------------------------
GUI.dh_Listbox = GUI.Element:new()

function GUI.dh_Listbox:new(name, z, x, y, w, h, list, multi, caption, pad, shadow, ...)

	local lst = (not x and type(z) == "table") and z or {}

	lst.name = name
	lst.type = "dh_Listbox"

	lst.z = lst.z or z

	lst.x = lst.x or x
    lst.y = lst.y or y
    lst.w = lst.w or w or GUI.dh_Listbox.defaults.w
    lst.h = lst.h or h or GUI.dh_Listbox.defaults.h

	lst.list = lst.list or list or GUI.dh_Listbox.defaults.list
	
    lst.multi = lst.multi or multi or GUI.dh_Listbox.defaults.multi
    
--zzcap	
	lst.caption = lst.caption or caption or GUI.dh_Listbox.defaults.caption
	lst.font_caption = lst.font_caption or GUI.dh_Listbox.defaults.font_caption
	lst.cap_pos = lst.cap_pos or GUI.dh_Listbox.defaults.cap_pos
    lst.cap_pad_x = lst.cap_pad_x or GUI.dh_Listbox.defaults.cap_pad_x
    lst.cap_pad_y = lst.cap_pad_y or GUI.dh_Listbox.defaults.cap_pad_y
	lst.cap_centered = lst.cap_centered or GUI.dh_Listbox.defaults.cap_centered

	lst.font_text = lst.font_text or GUI.dh_Listbox.defaults.font_text	
	lst.pad = lst.pad or pad or GUI.dh_Listbox.defaults.pad
	
    lst.shadow = lst.shadow or shadow or GUI.dh_Listbox.defaults.shadow
    lst.shadow_caption = lst.shadow_caption or GUI.dh_Listbox.defaults.shadow_caption

    lst.frame_use_outline = lst.frame_use_outline or GUI.dh_Listbox.defaults.frame_use_outline	
    lst.frame_thk = lst.frame_thk or GUI.dh_Listbox.defaults.frame_thk
    if lst.allow_sel_outline == nil then
        lst.allow_sel_outline = GUI.dh_Listbox.defaults.allow_sel_outline
    end
    	
----colors---------------------------
    -- Caption
    lst.col_cap_text = lst.col_cap_text or GUI.dh_Listbox.defaults.col_cap_text 
       
    -- Box
	lst.col_bg = lst.col_bg or GUI.dh_Listbox.defaults.col_bg    
    lst.col_frame = lst.col_frame or GUI.dh_Listbox.defaults.col_frame 
	lst.col_text = lst.col_text or GUI.dh_Listbox.defaults.col_text
	lst.col_sel_text = lst.col_sel_text or GUI.dh_Listbox.defaults.col_sel_text

	-- Scrollbar
	lst.col_track = lst.col_track or GUI.dh_Listbox.defaults.col_track
	--lst.col_thumb = lst.col_thumb or GUI.dh_Listbox.defaults.col_thumb
	
    lst.col_active = lst.col_active or GUI.dh_Listbox.defaults.col_active
    lst.col_backdrop = lst.col_backdrop or GUI.dh_Listbox.defaults.col_backdrop
-------------------------------------

    -- Use negative value to darken.
    lst.sel_alpha = lst.sel_alpha or GUI.dh_Listbox.defaults.sel_alpha

    lst.line_height = lst.line_height or GUI.dh_Listbox.defaults.line_height
    lst.scrollbar_width = lst.scrollbar_width or GUI.dh_Listbox.defaults.scrollbar_width
    if lst.scrollbar_width < 8 then lst.scrollbar_width = 8 end

	lst.retval = lst.retval or {}
		
	lst.wnd_y = 1    -- index of selected item.
	lst.wnd_h, lst.wnd_w, lst.char_w = nil, nil, nil

	GUI.redraw_z[lst.z] = true

	setmetatable(lst, self)
	self.__index = self
	return lst

end

GUI.dh_Listbox.defaults = {
    w = 192,
    h = 96,
    list = {},
    multi = false,
    
	caption = "",
	font_caption = "sans22",
	cap_pos = "top",
    cap_pad_x = 4,
    cap_pad_y = 4,
	cap_centered = false,
	
	font_text = "sans24",	
	pad = 4,
    line_height = 1.20,
    	
	shadow = false,	
	shadow_caption = false,
    frame_use_outline = false,
    frame_thk = 2,
    allow_sel_outline = false,
        	
    sel_alpha = 0.5,

    scrollbar_width = 8,
    
	col_bg = "elm_bg",    
    col_frame = "elm_frame",
    col_track = "btn_face", 
	col_text = "elm_txt",
	col_sel_text = "sel_txt",
	col_cap_text = "txt", 
	--col_thumb = "btn_outline",
    col_active = "elm_active",
    col_backdrop = "wnd_bg",    

}

function GUI.dh_Listbox:init()

    --GUI.Msg("\n## dh_Listbox:init : [ " .. self.name .. " ]")
    
	-- If we were given a CSV, process it into a table
	if type(self.list) == "string" then self.list = self:CSVtotable(self.list) end
	
	--GUI.Msg("dh_Listbox:init w : " .. tostring(self.w))
	--GUI.Msg("dh_Listbox:init h : " .. tostring(self.h))    
	--GUI.Msg("bh_Listbox:init wnd_y : " .. tostring(self.wnd_h))

	local x, y, w, h = self.x, self.y, self.w, self.h
	
    local sd = self.shadow and GUI.shadow_dist or 0

	self.buff = self.buff or GUI.GetBuffer()
	
	gfx.dest = self.buff
	gfx.setimgdim(self.buff, -1, -1)
	gfx.setimgdim(self.buff, w + sd, h + sd)
	  
	-- Draw shadow.
	
    if self.shadow then
        GUI.color(GUI.colors["shadow"])
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
	
	local sd = self.shadow and GUI.shadow_dist or 0

	local pad = self.pad

	-- Some values can't be set in :init() if the window isn't open yet.
	-- Measurements won't work.
	if not self.wnd_h then self:wnd_recalc() end

	-- Draw the caption.
	if self.caption and self.caption ~= "" then self:drawcaption() end

	-- Blit the background and frame.
	gfx.blit(self.buff, 1, 0, 0, 0, w + sd, h + sd, x, y)

	-- Draw the text.
	self:drawtext()

	-- Highlight any selected items.
	self:drawselection()

	-- Vertical scrollbar
	if #self.list > self.wnd_h then self:drawscrollbar() end
	
	-- Focused?
	
    --GUI.Msg("** dh_Listbox:draw: self.focus is: " .. tostring(self.focus))     	
	
	if self.focus and self.allow_sel_outline then
	
	    GUI.color(self.col_active)
	    --gfx.rect(x - 1, y - 1, w + 2, h + 2, 0)
	    gfx.rect(x - 2, y - 2, w + 4, h + 4, 0)
		-- Thicken highlight.
	    --gfx.rect(x - 2, y - 2, w + 4, h + 4, 0)
	
	end

end

--zzcap
function GUI.dh_Listbox:drawcaption()

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


function GUI.dh_Listbox:drawselection()

    --GUI.Msg("\n# dh_Listbox:drawselection NAME :" .. self.name)
    
	local off_x = self.x + self.pad
	local off_y = self.y + self.pad
	local x, y, w, h

	w = self.w - 2 * self.pad
    
    --if sel_txt use its alpha else use sel_alpha
    -- To darken need a negative alpha.
    -- sel_text alpha always positive, sel_alpha can be set negative.
    
    local alpha
    
    if self.col_sel_text == "sel_txt" then
        alpha = GUI.colors.sel_txt[4]
        if self.sel_alpha <= 0 then
            alpha = -alpha
        end
    else
        alpha = self.sel_alpha 
    end
    
    --GUI.Msg("    lbx col_sel_text : " .. self.col_sel_text)
    --GUI.Msg("    self.sel_alpha : " .. tostring(self.sel_alpha))        
    --GUI.Msg("    alpha : " .. tostring(alpha))
    
    if self.sel_alpha < 0 then
        -- Invert color.
        local r,g,b,a = table.unpack(GUI.colors[self.col_sel_text])
        r = 1 - r
        g = 1 - g
        b = 1 - b
    
        gfx.set(r,g,b,alpha)
    
    else
        GUI.color(self.col_sel_text)
    end

--[=[ Used for testing GUI Builder!   
    if self.name == "lbx_Tab3" or self.name == "lbx_PropertyAssignments" then
        GUI.Msg("dh_Listbox:drawselection name : " .. self.name)
        GUI.Msg("dh_Listbox:drawselection sel_txt alpha :" .. tostring(GUI.colors.sel_txt[4]))        
        GUI.Msg("dh_Listbox:drawselection self_alpha :" .. tostring(self.sel_alpha))
        GUI.Msg("dh_Listbox:drawselection gfx.a :" .. tostring(gfx.a))    
    end
--]=]
        
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

   -- GUI.Msg("dh_Listbox:drawscrollbar : " .. self.name)
    
	local x, y, w, h = self.x, self.y, self.w, self.h

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
    
	--GUI.color(self.col_thumb)
	--GUI.roundrect(sx + 2, fy, sw - 4, fh, sr, 1, 1)
    
    local ll_col, hl_col, lum = DHTK.get_hilite_colors(self.col_track, true)
        
    local thumb_color
    
    if lum > 0.5 then 
        -- darken 
        thumb_color = ll_col
    else
        -- lighten 
        thumb_color = hl_col
    end     
    
    GUI.color(thumb_color)
       	
	GUI.roundrect(sx + 2, fy, sw - 4, fh, sr, 1, 1)
	
	-- Draw scrollbar thumb	

	--GUI.color(self.col_sb_outline)
	GUI.roundrect(sx, sy, sw, sh, 4, 1, 0)				

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
        
            --!!! This isn't right. retval shouldn't be a table of items, but only a single item.

            newval = math.floor(newval)
            
            if self.multi then
                for i = 1, #self.list do
                    self.retval[i] = (i == newval)
                end
            else
                self.retval = {[newval] = true}
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
		
		    --!!! Should be only one item.
		    -- So why iterating? To extract key?
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

    --GUI.Msg("\n**  GUI.dh_Listbox:onmouseup **")

	if not self:overscrollbar() then

		local item = self:getitem(GUI.mouse.y)

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
	--else


	end

	self:redraw()

end


function GUI.dh_Listbox:onwheel(inc)

	local dir = inc > 0 and -1 or 1

	-- Scroll up/down one line
	self.wnd_y = GUI.clamp(1, self.wnd_y + dir, math.max(#self.list - self.wnd_h + 1, 1))

	self:redraw()

end

-- Make sure the box highlight goes away
function GUI.dh_Listbox:lostfocus()

    if self.allow_sel_outline then
        self:redraw()
    end

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