-- NoIndex: true

-- dh_TextEditor.lua
-- Date: 20260330

---------------------------------------------------------------------
-- Lokasenna_GUI - TextEditor class
--   For documentation, see this class's page on the project wiki:
--     https://github.com/jalovatt/Lokasenna_GUI/wiki/TextEditor

---------------------------------------------------------------------
--[[ Modified by Dennis Horn.

     Changed most of the property names for consistency with other dh_Toolkit classes.
     Changed some property default values.
     Added ability to change line_height and scrollbar_width.
     Allows all of the color properties to be overridden, including scrollbar.
     Added ability to change selected text highlight color. 
       The GUI color "sel_txt" is an alpha adjusted color. The property "col_sel_text" specifies the highlight color.     
       That color is ADDED to the list background color to produce the highlight. 
       If "sel_txt" color is specified it will use the "sel_txt" alpha and color. 
       Otherwise it will use the specified color with a default alpha of 0.5.
       
     20260223: Replace element frame with highlighted drawn.
               Added properties for frame modification.

]]--
---------------------------------------------------------------------
-- Requires that Lokasenna_GUI v2 be loaded.

if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end
---------------------------------------------------------------------
-- Creation parameters:
-- name, z, x, y, w, h[, text, caption, pad]
---------------------------------------------------------------------
GUI.dh_TextEditor = GUI.Element:new()
function GUI.dh_TextEditor:new(name, z, x, y, w, h, text, caption, pad)

	local txt = (not x and type(z) == "table") and z or {}

	txt.name = name
	txt.type = "dh_TextEditor"

	txt.z = txt.z or z

	txt.x = txt.x or x
    txt.y = txt.y or y
    txt.w = txt.w or w or GUI.dh_TextEditor.defaults.w
    txt.h = txt.h or h or GUI.dh_TextEditor.defaults.h

	txt.retval = txt.retval or text or {}

	txt.caption = txt.caption or caption or GUI.dh_TextEditor.defaults.caption

	txt.font_caption = txt.font_caption or GUI.dh_TextEditor.defaults.font_caption
	txt.cap_pos = txt.cap_pos or GUI.dh_TextEditor.defaults.cap_pos
	txt.cap_pad_x = txt.cap_pad_x or GUI.dh_TextEditor.defaults.cap_pad_x
	txt.cap_pad_y = txt.cap_pad_y or GUI.dh_TextEditor.defaults.cap_pad_y
	txt.cap_centered = txt.cap_centered or GUI.dh_TextEditor.defaults.cap_centered
	
	-- Forcing a safe monospace font to make our lives easier
	txt.font_text = txt.font_text or GUI.dh_TextEditor.defaults.font_text
	txt.pad = txt.pad or pad or GUI.dh_TextEditor.defaults.pad		
    
    txt.shadow = txt.shadow or GUI.dh_TextEditor.defaults.shadow
    txt.shadow_caption = txt.shadow_caption or GUI.dh_TextEditor.defaults.shadow_caption

    txt.frame_use_outline = txt.frame_use_outline or GUI.dh_TextEditor.defaults.frame_use_outline
    txt.frame_thk = txt.frame_thk or GUI.dh_TextEditor.defaults.frame_thk
        	
    -- Experimental:
    txt.outline_thk = txt.outline_thk or 2
    	
    if txt.allow_sel_outline == nil then 
        txt.allow_sel_outline = GUI.dh_TextEditor.defaults.allow_sel_outline  
    end    

----colors--------------------------- 
    -- Caption
    txt.col_cap_text = txt.col_cap_text or GUI.dh_TextEditor.defaults.col_cap_text
    
    -- Box
    txt.col_bg = txt.col_bg or GUI.dh_TextEditor.defaults.col_bg    
    txt.col_frame = txt.col_frame or GUI.dh_TextEditor.defaults.col_frame 
    txt.col_text = txt.col_text or GUI.dh_TextEditor.defaults.col_text
	txt.col_sel_text = txt.col_sel_text or GUI.dh_TextEditor.defaults.col_sel_text
    
    -- Scrollbar
	txt.col_track = txt.col_track or GUI.dh_TextEditor.defaults.col_track
	--txt.col_thumb = txt.col_thumb or GUI.dh_TextEditor.defaults.
	--txt.col_sb_outline = txt.col_sb_outline or GUI.dh_TextEditor.defaults.

    txt.col_active = txt.col_active or GUI.dh_TextEditor.defaults.col_active	
    txt.col_backdrop = txt.col_backdrop or GUI.dh_TextEditor.defaults.col_backdrop		
-------------------------------------

    -- Use negative value to darken.
    txt.sel_alpha = txt.sel_alpha or GUI.dh_TextEditor.defaults.sel_alpha
    
    txt.line_height = txt.line_height or GUI.dh_TextEditor.defaults.line_height
    txt.scrollbar_width = txt.scrollbar_width or GUI.dh_TextEditor.defaults.scrollbar_width	
    if txt.scrollbar_width < 8 then txt.scrollbar_width = 8 end

	txt.wnd_pos = {x = 0, y = 1}
	txt.caret = {x = 0, y = 1}

	txt.char_h, txt.wnd_h, txt.wnd_w, txt.char_w = nil, nil, nil, nil

	txt.focus = false

	txt.undo_limit = 20
	txt.undo_states = {}
	txt.redo_states = {}

	txt.blink = 0

	GUI.redraw_z[txt.z] = true

	setmetatable(txt, self)
	self.__index = self
	return txt

end

GUI.dh_TextEditor.defaults = {
    w = 256,
    h = 192,
    retval = "",
    font_text = "mono16",
    pad = 4,
    line_height = 1.20,    
    undo_limit = 20,
    scrollbar_width = 8,    
    
	caption = "",
	font_caption = "sans22",
	cap_pos = "top",
    cap_pad_x = 4,
    cap_pad_y = 4,
	cap_centered = false,    
	shadow_caption = false,
    shadow = false,
    
    frame_use_outline = false,
    frame_thk = 2,    
    allow_sel_outline = true,
    
    col_bg = "elm_bg",
    col_frame = "elm_frame",
    col_track = "btn_face",     
	col_text = "elm_txt",        	
	col_sel_text = "sel_txt",	
    sel_alpha = 0.5,	    	    
    col_cap_text = "txt",	      
    col_active = "elm_active",
    col_backdrop = "wnd_bg", 

}


function GUI.dh_TextEditor:init()

	-- Process the initial string; split it into a table by line
	if type(self.retval) == "string" then self:val(self.retval) end

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
    
    -- Make sure we calculate this ASAP to avoid errors with
    -- dynamically-generated textboxes
    -- Do it here if window already open. 
    -- Otherwise do it in draw if not already set.
    if gfx.w > 0 then self:wnd_recalc() end

end


function GUI.dh_TextEditor:ondelete()

	GUI.FreeBuffer(self.buff)

end

------------------------------------
-------- Drawing methods -----------
------------------------------------

function GUI.dh_TextEditor:draw()

    local x, y, w, h = self.x, self.y, self.w, self.h
    
    local sd = self.shadow and GUI.shadow_dist or 0

	-- Some values can't be set in :init() because the window isn't
	-- open yet - measurements won't work.
	if not self.wnd_h then self:wnd_recalc() end

	-- Draw the caption.
	if self.caption and self.caption ~= "" then self:drawcaption() end

	-- Blit the background and frame.
	gfx.blit(self.buff, 1, 0, 0, 0, w + sd, h + sd, x, y)

	-- Draw the text.
	self:drawtext()

	-- Focused?
	
	if self.focus then

        -- Selection
        if self.sel_s and self.sel_e then
            self:drawselection()
        end
        
	    -- Caret
	    -- Only needs to be drawn for half of the blink cycle
	    
        if self.show_caret then self:drawcaret() end
        
        if self.allow_sel_outline then
	        GUI.color(self.col_active)
    	    --gfx.rect(x - 1, y - 1, w + 2, h + 2, 0)
    	    gfx.rect(x - 2, y - 2, w + 4, h + 4, 0)
    		-- Thicken highlight.
    		if self.outline_thk > 1 then
    	        gfx.rect(x - 2, y - 2, w + 4, h + 4, 0)
    	    end
        end
        
    end

	-- Scrollbars
	self:drawscrollbars()

end

--zzcap
function GUI.dh_TextEditor:drawcaption()

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

    --GUI.text_bg(str, self.col_backdrop)
    
    GUI.color(self.col_backdrop)        
    gfx.rect(gfx.x, gfx.y, str_w, str_h, 1)

    if self.shadow_caption then
        GUI.shadow(caption, self.col_cap_text, "shadow")
    else
        GUI.color(self.col_cap_text)
        gfx.drawstr(caption)
    end

end


function GUI.dh_TextEditor:drawtext()

    --GUI.Msg("\n## GUI.dh_TextEditor:drawtext: ")

	GUI.color(self.col_text)
	--GUI.color("white")	
	GUI.font(self.font_text)

	-- self.wnd_h is how many lines can fit vertically.
	-- self.wnd_pos.y is index of top item.
	-- self.wnd_bottom is index of bottom item.
	
    local str_w, str_h = gfx.measurestr("M")
   	str_h = str_h * self.line_height
   	local str_x = self.x + self.pad
   	local str_y = self.y + self.pad
    local r = self.w - self.pad
    local b = self.h - self.pad

    --GUI.Msg("   self.wnd_pos.y : " .. tostring(self.wnd_pos.y) )    
    --GUI.Msg("   #self.retval : " .. tostring(#self.retval) )
    --GUI.Msg("   self:wnd_bottom : " .. tostring(self:wnd_bottom()) )    

	for i = self.wnd_pos.y, math.min(self:wnd_bottom() - 1, #self.retval) do		
       	gfx.x = str_x
	    gfx.y = str_y

	    --GUI.Msg("   type of self.retval[i] : " .. type(self.retval[i]))
	    --GUI.Msg("   self.retval[i] : " .. self.retval[i])	    
	    --GUI.Msg("   str_x : " .. tostring(str_x))    	    
	    --GUI.Msg("   str_y : " .. tostring(str_y))

	    local str = string.sub(self.retval[i], self.wnd_pos.x + 1, self:wnd_right() - 1)

	    gfx.drawstr(str)
	    --gfx.drawstr(self.retval[i], 0, r, b)
	    --gfx.drawstr(self.retval[i], 0, r)	    	    
	    str_y = str_y + str_h
	end

end

--zzcaret
function GUI.dh_TextEditor:drawcaret()

	local caret_wnd = self:adjusttowindow(self.caret)

	if caret_wnd.x and caret_wnd.y then

        --GUI.Msg("        in if\n")

        GUI.color(self.col_text)

		gfx.rect(	self.x + self.pad + (caret_wnd.x * self.char_w),
					self.y + self.pad + (caret_wnd.y * self.char_h),
					self.insert_caret and self.char_w or 2,
					self.char_h - 2)

	end

end


function GUI.dh_TextEditor:drawselection()

	local off_x, off_y = self.x + self.pad, self.y + self.pad
	local x, y, w, h

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
	
	gfx.mode = 1 -- additive

	-- Get all the selection boxes that need to be drawn
	local coords = self:getselection()

	for i = 1, #coords do

		-- Make sure at least part of this line is visible
		if self:selectionvisible(coords[i]) then

			-- Convert from char/row coords to actual pixels
			x, y =	off_x + (coords[i].x - self.wnd_pos.x) * self.char_w,
					off_y + (coords[i].y - self.wnd_pos.y) * self.char_h

									-- Really kludgy, but it fixes a weird issue
									-- where wnd_pos.x > 0 was drawing all the widths
									-- one character too short
			w =		(coords[i].w + (self.wnd_pos.x > 0 and 1 or 0)) * self.char_w

			-- Keep the selection from spilling out past the scrollbar
            -- ??? recheck this, the self.x doesn't make sense to me, but it seems to work ???
			w = math.min(w, self.x + self.w - x - self.pad)

			h =	self.char_h

			gfx.rect(x, y, w, h, true)

		end

	end

	gfx.mode = 0

	-- Later calls to GUI.color should handle this, but for
	-- some reason they aren't always.
	gfx.a = 1

end


function GUI.dh_TextEditor:drawscrollbars()

	-- Do we need to be here?
	local max_w, txt_h = self:getmaxlength(), self:getwndlength()
	local vert, horz = 	txt_h > self.wnd_h,
						max_w > self.wnd_w


	local x, y, w, h = self.x, self.y, self.w, self.h
	--local vx, vy, vw, vh = x + w - 8 - 4, y + 4, 8, h - 16
	--local hx, hy, hw, hh = x + 4, y + h - 8 - 4, w - 16, 8
	local fade_w = 12
	local _
	
	local vx = x + w - self.scrollbar_width - 4
    local vy = y + 4
    local vw = self.scrollbar_width
    local vh = h - 16  --8
    
	local hx = x + 4
    local hy = y + h - self.scrollbar_width - 4
    local hw = w - 16
    local hh = self.scrollbar_width    	

    -- Only draw the empty tracks if we don't need scroll bars
	if not (vert or horz) then goto tracks end

	-- Draw a gradient to fade out the last ~16px of text
	--GUI.color("elm_bg")
	GUI.color(self.col_bg)	
	for i = 0, fade_w do

		gfx.a = i/fade_w

		if vert then

			gfx.line(vx + i - fade_w, y + 2, vx + i - fade_w, y + h - 4)

			-- Fade out the top if we're not at wnd_pos.y = 1
			_ = self.wnd_pos.y > 1 and
				gfx.line(x + 2, y + 2 + fade_w - i, x + w - 4, y + 2 + fade_w - i)

		end

		if horz then

			gfx.line(x + 2, hy + i - fade_w, x + w - 4, hy + i - fade_w)

			-- Fade out the left if we're not at wnd_pos.x = 0
			_ = self.wnd_pos.x > 0 and
				gfx.line(x + 2 + fade_w - i, y + 2, x + 2 + fade_w - i, y + h - 4)

		end

	end

	_ = vert and gfx.rect(vx, y + 2, vw + 2, h - 4, true)
	_ = horz and gfx.rect(x + 2, hy, w - 4, hh + 2, true)

    ::tracks::

	-- Draw scrollbar track
	
	GUI.color(self.col_track)

	GUI.roundrect(vx, vy, vw, vh, 4, 1, 1)
	GUI.roundrect(hx, hy, hw, hh, 4, 1, 1)

	-- Draw scrollbar thumb

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

    local sr = (vw - 4) / 2
    
	if vert then
		local fh = (self.wnd_h / txt_h) * vh - 4
		if fh < 4 then fh = 4 end
		local fy = vy + ((self.wnd_pos.y - 1) / txt_h) * vh + 2
		
        --GUI.roundrect(vx + 2, fy, vw - 4, fh, 2, 1, 1)
		GUI.roundrect(vx + 2, fy, vw - 4, fh, sr, 1, 1)
	end

	if horz then
		local fw = (self.wnd_w / (max_w + 4)) * hw - 4
		if fw < 4 then fw = 4 end
		local fx = hx + (self.wnd_pos.x / (max_w + 4)) * hw + 2
		
		--GUI.roundrect(fx, hy + 2, fw, hh - 4, 2, 1, 1)
		GUI.roundrect(fx, hy + 2, fw, hh - 4, sr, 1, 1)
	end
	
	-- Draw scrollbar outline
	
	--GUI.color(self.col_sb_outline)
		
	GUI.roundrect(vx, vy, vw, vh, 4, 1, 0)
	GUI.roundrect(hx, hy, hw, hh, 4, 1, 0)	

end

--zzval
function GUI.dh_TextEditor:val(newval)

    --GUI.Msg("\n# GUI.dh_TextEditor:val newval type is : " .. type(newval))
    --GUI.Msg("# GUI.dh_TextEditor:val newval size is : " .. tostring(#newval))    

	if newval then
		self:seteditorstate(
            type(newval) == "table" and newval
                                    or self:stringtotable(newval))
                                    
        --GUI.Msg("\n# GUI.dh_TextEditor:val :ready to redraw")
        --GUI.Msg("   GUI.dh_TextEditor:val retval type is : " .. type(self.retval))
        --GUI.Msg("   GUI.dh_TextEditor:val retval size is : " .. tostring(#self.retval))
        
		self:redraw()
	else
		return table.concat(self.retval, "\n")
	end

end


function GUI.dh_TextEditor:onupdate()

	if self.focus then

		if self.blink == 0 then
			self.show_caret = true
			self:redraw()
		elseif self.blink == math.floor(GUI.txt_blink_rate / 2) then
			self.show_caret = false
			self:redraw()
		end
		self.blink = (self.blink + 1) % GUI.txt_blink_rate

	end

end


function GUI.dh_TextEditor:lostfocus()

	self:redraw()
    --if self.allow_sel_outline then
    --    self:redraw()
    --end	

end


-----------------------------------
-------- Input methods ------------
-----------------------------------

function GUI.dh_TextEditor:onmousedown()

	-- If over the scrollbar, or we came from :ondrag with an origin point
	-- that was over the scrollbar...
	local scroll = self:overscrollbar()
	if scroll then

        self:setscrollbar(scroll)

    else
    
        --GUI.Msg("\n# GUI.dh_TextEditor:onmousedown : go get caret")

        -- Place the caret
        self.caret = self:getcaret(GUI.mouse.x, GUI.mouse.y)

        -- Reset the caret so the visual change isn't laggy
        self.blink = 0

        -- Shift+click to select text
        if GUI.mouse.cap & 8 == 8 and self.caret then

                self.sel_s = {x = self.caret.x, y = self.caret.y}
                self.sel_e = {x = self.caret.x, y = self.caret.y}

        else

            self:clearselection()

        end

    end

    self:redraw()

end


function GUI.dh_TextEditor:ondoubleclick()

	self:selectword()

end


function GUI.dh_TextEditor:ondrag()

	local scroll = self:overscrollbar(GUI.mouse.ox, GUI.mouse.oy)
	if scroll then

        self:setscrollbar(scroll)

	-- Select from where the mouse is now to where it started
	else

		self.sel_s = self:getcaret(GUI.mouse.ox, GUI.mouse.oy)
		self.sel_e = self:getcaret(GUI.mouse.x, GUI.mouse.y)

	end

	self:redraw()

end


function GUI.dh_TextEditor:ontype(char, mod)

    local char = char or GUI.char
    local mod = mod or GUI.mouse.cap

	-- Non-typeable / navigation chars
	if self.keys[char] then

		local shift = mod & 8 == 8

		if shift and not self.sel_s then
			self.sel_s = {x = self.caret.x, y = self.caret.y}
		end

		-- Flag for some keys (clipboard shortcuts) to skip
		-- the next section
        local bypass = self.keys[char](self)

		if shift and char ~= GUI.chars.BACKSPACE and char ~= GUI.chars.TAB then

			self.sel_e = {x = self.caret.x, y = self.caret.y}

		elseif not bypass then

			self:clearselection()

		end

	-- Typeable chars
	elseif GUI.clamp(32, char, 254) == char then

		if self.sel_s then self:deleteselection() end

		self:insertchar(char)
        -- Why are we doing this when the selection was just deleted?
		--self:clearselection()


	end
	self:windowtocaret()

	-- Reset the caret so the visual change isn't laggy
	self.blink = 0

end


function GUI.dh_TextEditor:onwheel(inc)

	-- Ctrl -- maybe zoom?
	if GUI.mouse.cap & 4 == 4 then

		--[[ Buggy, disabled for now
		local font = self.font_text
		font = 	(type(font) == "string" and GUI.fonts[font])
			or	(type(font) == "table" and font)

		if not font then return end

		local dir = inc > 0 and 4 or -4

		font[2] = GUI.clamp(8, font[2] + dir, 30)

		self.font_text = font

		self:wnd_recalc()
		]]--

	-- Shift -- Horizontal scroll
	elseif GUI.mouse.cap & 8 == 8 then

		local len = self:getmaxlength()

		if len <= self.wnd_w then return end

		-- Scroll right/left
		local dir = inc > 0 and 3 or -3
		self.wnd_pos.x = GUI.clamp(0, self.wnd_pos.x + dir, len - self.wnd_w + 4)

	-- Vertical scroll
	else

		local len = self:getwndlength()

		if len <= self.wnd_h then return end

		-- Scroll up/down
		local dir = inc > 0 and -3 or 3
		self.wnd_pos.y = GUI.clamp(1, self.wnd_pos.y + dir, len - self.wnd_h + 1)

	end

	self:redraw()

end


------------------------------------
-------- Selection methods ---------
------------------------------------

function GUI.dh_TextEditor:getselectioncoords()

	local sx, sy = self.sel_s.x, self.sel_s.y
	local ex, ey = self.sel_e.x, self.sel_e.y

	-- Make sure the Start is before the End
	if sy > ey then
		sx, sy, ex, ey = ex, ey, sx, sy
	elseif sy == ey and sx > ex then
		sx, ex = ex, sx
	end

    return sx, sy, ex, ey

end


-- Figure out what portions of the text are selected
function GUI.dh_TextEditor:getselection()

    local sx, sy, ex, ey = self:getselectioncoords()

	local x, w
	local sel_coords = {}

	local function insert_coords(x, y, w)
		table.insert(sel_coords, {x = x, y = y, w = w})
	end

	-- Eliminate the easiest case - start and end are the same line
	if sy == ey then

		x = GUI.clamp(self.wnd_pos.x, sx, self:wnd_right())
		w = GUI.clamp(x, ex, self:wnd_right()) - x

		insert_coords(x, sy, w)

	-- ...fine, we'll do it the hard way
	else

		-- Start
		x = GUI.clamp(self.wnd_pos.x, sx, self:wnd_right())
		w = math.min(self:wnd_right(), #(self.retval[sy] or "")) - x

		insert_coords(x, sy, w)


		-- Any intermediate lines are clearly full
		for i = self.wnd_pos.y, self:wnd_bottom() - 1 do

			x, w = nil, nil

			-- Is this line within the selection?
			if i > sy and i < ey then

				w = math.min(self:wnd_right(), #(self.retval[i] or "")) - self.wnd_pos.x
				insert_coords(self.wnd_pos.x, i, w)

			-- We're past the selection
			elseif i >= ey then

				break

			end

		end

		-- End
		x = self.wnd_pos.x
		w = math.min(self:wnd_right(), ex) - self.wnd_pos.x
		insert_coords(x, ey, w)


	end
	
	--GUI.Msg("> getselection ey : " .. tostring(ey))

	return sel_coords

end


-- Make sure at least part of this selection block is within the window
function GUI.dh_TextEditor:selectionvisible(coords)

	return 		coords.w > 0                            -- Selection has width,
			and coords.x + coords.w > self.wnd_pos.x    -- doesn't end to the left
            and coords.x < self:wnd_right()             -- doesn't start to the right
			and coords.y >= self.wnd_pos.y              -- and is on a visible line
			and coords.y < self:wnd_bottom()

end


function GUI.dh_TextEditor:selectall()

	self.sel_s = {x = 0, y = 1}
	self.caret = {x = 0, y = 1}
	self.sel_e = {	x = string.len(self.retval[#self.retval]),
					y = #self.retval}

end


function GUI.dh_TextEditor:selectword()

	local str = self.retval[self.caret.y] or ""

	if not str or str == "" then return 0 end

	local sx = string.find( str:sub(1, self.caret.x), "%s[%S]+$") or 0

	local ex =	(	string.find( str, "%s", sx + 1)
			or		string.len(str) + 1 )
				- (self.wnd_pos.x > 0 and 2 or 1)	-- Kludge, fixes length issues

	self.sel_s = {x = sx, y = self.caret.y}
	self.sel_e = {x = ex, y = self.caret.y}

end


function GUI.dh_TextEditor:clearselection()

	self.sel_s, self.sel_e = nil, nil

end


function GUI.dh_TextEditor:deleteselection()

	if not (self.sel_s and self.sel_e) then return 0 end

	self:storeundostate()

    local sx, sy, ex, ey = self:getselectioncoords()

	-- Easiest case; single line
	if sy == ey then

		self.retval[sy] =   string.sub(self.retval[sy] or "", 1, sx)..
                            string.sub(self.retval[sy] or "", ex + 1)

	else

		self.retval[sy] =   string.sub(self.retval[sy] or "", 1, sx)..
                            string.sub(self.retval[ey] or "", ex + 1)
		for i = sy + 1, ey do
			table.remove(self.retval, sy + 1)
		end

	end

	self.caret.x, self.caret.y = sx, sy

	self:clearselection()
	self:windowtocaret()

end


function GUI.dh_TextEditor:getselectedtext()

    local sx, sy, ex, ey = self:getselectioncoords()

	local tmp = {}

	for i = 0, ey - sy do

		tmp[i + 1] = self.retval[sy + i]

	end

	tmp[1] = string.sub(tmp[1], sx + 1)
	tmp[#tmp] = string.sub(tmp[#tmp], 1, ex - (sy == ey and sx or 0))

	return table.concat(tmp, "\n")

end


function GUI.dh_TextEditor:toclipboard(cut)

    if self.sel_s and self:SWS_clipboard() then

        local str = self:getselectedtext()
        reaper.CF_SetClipboard(str)
        if cut then self:deleteselection() end

    end

end


function GUI.dh_TextEditor:fromclipboard()

    if self:SWS_clipboard() then

        -- reaper.SNM_CreateFastString( str )
        -- reaper.CF_GetClipboardBig( output )
        local fast_str = reaper.SNM_CreateFastString("")
        local str = reaper.CF_GetClipboardBig(fast_str)
        reaper.SNM_DeleteFastString(fast_str)

        self:insertstring(str, true)

    end

end

------------------------------------
-------- Window/Pos Helpers --------
------------------------------------

-- Updates internal values for the window size
function GUI.dh_TextEditor:wnd_recalc()

	GUI.font(self.font_text)
	self.char_w, self.char_h = gfx.measurestr("i")
	self.char_h = self.char_h * self.line_height
	self.wnd_h = math.floor((self.h - 2 * self.pad) / self.char_h)
	self.wnd_w = math.floor(self.w / self.char_w)

end


-- Get the right edge of the window (in chars)
function GUI.dh_TextEditor:wnd_right()

	return self.wnd_pos.x + self.wnd_w

end


-- Get the bottom edge of the window (in rows)
function GUI.dh_TextEditor:wnd_bottom()

	return self.wnd_pos.y + self.wnd_h

end


-- Get the length of the longest line
function GUI.dh_TextEditor:getmaxlength()

	local w = 0

	-- Slightly faster because we don't care about order
	for k, v in pairs(self.retval) do
		w = math.max(w, string.len(v))
	end

	-- Pad the window out a little
	return w + 2

end


-- Add 2 to the table length so the horizontal scrollbar isn't in the way
function GUI.dh_TextEditor:getwndlength()

	return #self.retval + 2

end

-- See if a given pair of coords is in the visible window
-- If so, adjust them from absolute to window-relative
-- If not, returns nil
function GUI.dh_TextEditor:adjusttowindow(coords)

    --GUI.Msg("> dh_TextEditor:adjusttowindow\n")

	local x, y = coords.x, coords.y
	x = (GUI.clamp(self.wnd_pos.x, x, self:wnd_right() - 3) == x)
						and x - self.wnd_pos.x
						or nil

	-- Fixes an issue with the position being one space to the left of where it should be
	-- when the window isn't at x = 0. Not sure why.
	--x = x and (x + (self.wnd_pos.x == 0 and 0 or 1))

	y = (GUI.clamp(self.wnd_pos.y, y, self:wnd_bottom() - 1) == y)
						and y - self.wnd_pos.y
						or nil
						
	--y = (GUI.clamp(self.wnd_pos.y, y, self:wnd_bottom()) == y)
	--					and y - self.wnd_pos.y
	--					or nil
						
	return {x = x, y = y}

end


-- Adjust the window if the caret has been moved off-screen
function GUI.dh_TextEditor:windowtocaret()

	-- Horizontal
	if self.caret.x < self.wnd_pos.x + 4 then
		self.wnd_pos.x = math.max(0, self.caret.x - 4)
	elseif self.caret.x > (self:wnd_right() - 4) then
		self.wnd_pos.x = self.caret.x + 4 - self.wnd_w
	end

	-- Vertical
	local bot = self:wnd_bottom()
	local adj = (	(self.caret.y < self.wnd_pos.y) and -1	)
			or	(	(self.caret.y >= bot) and 1	)
			or	(	(bot > self:getwndlength() and -(bot - self:getwndlength() - 1) ) )

	if adj then self.wnd_pos.y = GUI.clamp(1, self.wnd_pos.y + adj, self.caret.y) end

end

--zzcaret  
-- TextEditor - Get the closest character position to the given coords.
-- x, y is mouse.x, mouse.y

function GUI.dh_TextEditor:getcaret(x, y)

	local tmp = {}
	    
    --GUI.Msg("\n# GUI.dh_TextEditor:getcaret")
    
	tmp.x = math.floor(		((x - self.x) / self.w ) * self.wnd_w)
                            + self.wnd_pos.x
	--tmp.y = math.floor(		(y - (self.y + self.pad))
	--					/	self.char_h)
	--		+ self.wnd_pos.y
	
	--tmp.y = math.floor(	( y - (self.y + self.pad)) / (self.char_h * self.line_height) + self.wnd_pos.y)
	tmp.y = math.floor(	(( y - (self.y + self.pad)) / self.char_h) + self.wnd_pos.y)	
	
	tmp.y = GUI.clamp(1, tmp.y, #self.retval)
	tmp.x = GUI.clamp(0, tmp.x, #(self.retval[tmp.y] or ""))
	
	--GUI.Msg("   caret y is : " .. tostring(tmp.y))

	return tmp

end


-- Is the mouse over either of the scrollbars?
-- Returns "h", "v", or false
function GUI.dh_TextEditor:overscrollbar(x, y)

	if	self:getwndlength() > self.wnd_h
	and (x or GUI.mouse.x) >= (self.x + self.w - 12) then

		return "v"

	elseif 	self:getmaxlength() > self.wnd_w
	and		(y or GUI.mouse.y) >= (self.y + self.h - 12) then

		return "h"

	end

end


function GUI.dh_TextEditor:setscrollbar(scroll)

    -- Vertical scroll
    if scroll == "v" then

        local len = self:getwndlength()
        local wnd_c = GUI.round( ((GUI.mouse.y - self.y) / self.h) * len  )
        self.wnd_pos.y = GUI.round(
                            GUI.clamp(	1,
                                        wnd_c - (self.wnd_h / 2),
                                        len - self.wnd_h + 1
                                    )
                                    )

    -- Horizontal scroll
    else
    --self.caret.x + 4 - self.wnd_w

        local len = self:getmaxlength()
        local wnd_c = GUI.round( ((GUI.mouse.x - self.x) / self.w) * len   )
        self.wnd_pos.x = GUI.round(
                            GUI.clamp(	0,
                                        wnd_c - (self.wnd_w / 2),
                                        len + 4 - self.wnd_w
                                    )
                                    )

    end


end


------------------------------------
-------- Char/String Helpers -------
------------------------------------
--zzval
-- Split a string by line into a table
function GUI.dh_TextEditor:stringtotable(str)

    --GUI.Msg("  --  stringtotable  --")

    str = self:sanitizetext(str)
	local pattern = "([^\r\n]*)\r?\n?"
	local tmp = {}
	for line in string.gmatch(str, pattern) do
		table.insert(tmp, line )
	end

	return tmp

end


-- Insert a string at the caret, deleting any existing selection
-- i.e. Paste
function GUI.dh_TextEditor:insertstring(str, move_caret)

	self:storeundostate()

    str = self:sanitizetext(str)

	if self.sel_s then self:deleteselection() end

    local sx, sy = self.caret.x, self.caret.y

	local tmp = self:stringtotable(str)

	local pre, post =	string.sub(self.retval[sy] or "", 1, sx),
						string.sub(self.retval[sy] or "", sx + 1)

	if #tmp == 1 then

		self.retval[sy] = pre..tmp[1]..post
		if move_caret then self.caret.x = self.caret.x + #tmp[1] end

	else

		self.retval[sy] = tostring(pre)..tmp[1]
		table.insert(self.retval, sy + 1, tmp[#tmp]..tostring(post))

		-- Insert our paste lines backwards so sy+1 is always correct
		for i = #tmp - 1, 2, -1 do
			table.insert(self.retval, sy + 1, tmp[i])
		end

		if move_caret then
			self.caret = {	x =	string.len(tmp[#tmp]),
							y =	self.caret.y + #tmp - 1}
		end

	end

end


-- Insert typeable characters
function GUI.dh_TextEditor:insertchar(char)

	self:storeundostate()

	local str = self.retval[self.caret.y] or ""

	local a, b = str:sub(1, self.caret.x),
                 str:sub(self.caret.x + (self.insert_caret and 2 or 1))
	self.retval[self.caret.y] = a..string.char(char)..b
	self.caret.x = self.caret.x + 1

end


-- Place the caret at the end of the current line
function GUI.dh_TextEditor:carettoend()
	--[[
	return #(self.retval[self.caret.y] or "") > 0
		and #self.retval[self.caret.y]
		or 0
	]]--

    return string.len(self.retval[self.caret.y] or "")

end


-- Replace any characters that we're unable to reproduce properly
function GUI.dh_TextEditor:sanitizetext(str)

    if type(str) == "string" then

        return str:gsub("\t", "    ")

    elseif type(str) == "table" then

        local tmp = {}
        for i = 1, #str do

            tmp[i] = str[i]:gsub("\t", "    ")

            return tmp

        end

    end

end


-- Backspace by up to four " " characters, if present.
function GUI.dh_TextEditor:backtab()

    local str = self.retval[self.caret.y]
    local pre, post = string.sub(str, 1, self.caret.x), string.sub(str, self.caret.x + 1)

    local space
    pre, space = string.match(pre, "(.-)(%s*)$")

    pre = pre .. (space and string.sub(space, 1, -5) or "")

    self.caret.x = string.len(pre)
    self.retval[self.caret.y] = pre..post

end


function GUI.dh_TextEditor:ctrlchar(func, ...)

    if GUI.mouse.cap & 4 == 4 then
        func(self, ... and table.unpack({...}))

        -- Flag to bypass the "clear selection" logic in :ontype()
        return true

    else
        self:insertchar(GUI.char)
    end

end


-- Non-typing key commands
-- A table of functions is more efficient to access than using really
-- long if/then/else structures.
GUI.dh_TextEditor.keys = {

	[GUI.chars.LEFT] = function(self)

		if self.caret.x < 1 and self.caret.y > 1 then
			self.caret.y = self.caret.y - 1
			self.caret.x = self:carettoend()
		else
			self.caret.x = math.max(self.caret.x - 1, 0)
		end

	end,

	[GUI.chars.RIGHT] = function(self)

		if self.caret.x == self:carettoend() and self.caret.y < self:getwndlength() then
			self.caret.y = self.caret.y + 1
			self.caret.x = 0
		else
			self.caret.x = math.min(self.caret.x + 1, self:carettoend() )
		end

	end,

	[GUI.chars.UP] = function(self)

		if self.caret.y == 1 then
			self.caret.x = 0
		else
			self.caret.y = math.max(1, self.caret.y - 1)
			self.caret.x = math.min(self.caret.x, self:carettoend() )
		end

	end,

	[GUI.chars.DOWN] = function(self)

		if self.caret.y == self:getwndlength() then
			self.caret.x = string.len(self.retval[#self.retval])
		else
			self.caret.y = math.min(self.caret.y + 1, #self.retval)
			self.caret.x = math.min(self.caret.x, self:carettoend() )
		end

	end,

	[GUI.chars.HOME] = function(self)

		self.caret.x = 0

	end,

	[GUI.chars.END] = function(self)

		self.caret.x = self:carettoend()

	end,

	[GUI.chars.PGUP] = function(self)

		local caret_off = self.caret and (self.caret.y - self.wnd_pos.y)

		self.wnd_pos.y = math.max(1, self.wnd_pos.y - self.wnd_h)

		if caret_off then
			self.caret.y = self.wnd_pos.y + caret_off
			self.caret.x = math.min(self.caret.x, string.len(self.retval[self.caret.y]))
		end

	end,

	[GUI.chars.PGDN] = function(self)

		local caret_off = self.caret and (self.caret.y - self.wnd_pos.y)

		self.wnd_pos.y = GUI.clamp(1, self:getwndlength() - self.wnd_h + 1, self.wnd_pos.y + self.wnd_h)

		if caret_off then
			self.caret.y = self.wnd_pos.y + caret_off
			self.caret.x = math.min(self.caret.x, string.len(self.retval[self.caret.y]))
		end

	end,

	[GUI.chars.BACKSPACE] = function(self)

		self:storeundostate()

		-- Is there a selection?
		if self.sel_s and self.sel_e then

			self:deleteselection()

		-- If we have something to backspace, delete it
		elseif self.caret.x > 0 then

			local str = self.retval[self.caret.y]
			self.retval[self.caret.y] = str:sub(1, self.caret.x - 1)..
                                        str:sub(self.caret.x + 1, -1)
			self.caret.x = self.caret.x - 1

		-- Beginning of the line; backspace the contents to the prev. line
		elseif self.caret.x == 0 and self.caret.y > 1 then

			self.caret.x = #self.retval[self.caret.y - 1]
			self.retval[self.caret.y - 1] = self.retval[self.caret.y - 1] .. (self.retval[self.caret.y] or "")
			table.remove(self.retval, self.caret.y)
			self.caret.y = self.caret.y - 1

		end

	end,

	[GUI.chars.TAB] = function(self)

        -- Disabled until Reaper supports this properly
		--self:insertchar(9)

        if GUI.mouse.cap & 8 == 8 then
            self:backtab()
        else
            self:insertstring("    ", true)
		end

	end,

	[GUI.chars.INSERT] = function(self)

		self.insert_caret = not self.insert_caret

	end,

	[GUI.chars.DELETE] = function(self)

		self:storeundostate()

		-- Is there a selection?
		if self.sel_s then

			self:deleteselection()

		-- Deleting on the current line
		elseif self.caret.x < self:carettoend() then

			local str = self.retval[self.caret.y] or ""
			self.retval[self.caret.y] = str:sub(1, self.caret.x) ..
                                        str:sub(self.caret.x + 2)

		elseif self.caret.y < self:getwndlength() then

			self.retval[self.caret.y] = self.retval[self.caret.y] ..
                                        (self.retval[self.caret.y + 1] or "")
			table.remove(self.retval, self.caret.y + 1)

		end

	end,

	[GUI.chars.RETURN] = function(self)

		self:storeundostate()

		if sel_s then self:deleteselection() end

		local str = self.retval[self.caret.y] or ""
		self.retval[self.caret.y] = str:sub(1, self.caret.x)
		table.insert(self.retval, self.caret.y + 1, str:sub(self.caret.x + 1) )
		self.caret.y = self.caret.y + 1
		self.caret.x = 0

	end,

	-- A -- Select All
	[1] = function(self)

        return self:ctrlchar(self.selectall)
--[[
		if GUI.mouse.cap & 4 == 4 then

			self:selectall()

			-- Flag to bypass the "clear selection" logic in :ontype()
			return true

		else
			self:insertchar(GUI.char)
		end
]]--
	end,

	-- C -- Copy
	[3] = function(self)

		return self:ctrlchar(self.toclipboard)

	end,

	-- V -- Paste
	[22] = function(self)

		return self:ctrlchar(self.fromclipboard)

	end,

	-- X -- Cut
	[24] = function(self)

		return self:ctrlchar(self.toclipboard, true)

	end,

	-- Y -- Redo
	[25] = function (self)

		return self:ctrlchar(self.redo)

	end,

	-- Z -- Undo
	[26] = function (self)

		return self:ctrlchar(self.undo)

	end
}


------------------------------------
-------- Misc. Functions -----------
------------------------------------


function GUI.dh_TextEditor:undo()

	if #self.undo_states == 0 then return end
	table.insert(self.redo_states, self:geteditorstate() )
	local state = table.remove(self.undo_states)

	self.retval = state.retval
	self.caret = state.caret

	self:windowtocaret()

end


function GUI.dh_TextEditor:redo()

	if #self.redo_states == 0 then return end
	table.insert(self.undo_states, self:geteditorstate() )
	local state = table.remove(self.redo_states)
	self.retval = state.retval
	self.caret = state.caret

	self:windowtocaret()

end


function GUI.dh_TextEditor:storeundostate()

	table.insert(self.undo_states, self:geteditorstate() )
	if #self.undo_states > self.undo_limit then table.remove(self.undo_states, 1) end
	self.redo_states = {}

end


function GUI.dh_TextEditor:geteditorstate()

	local state = { retval = {} }
	for k,v in pairs(self.retval) do
		state.retval[k] = v
	end
	state.caret = {x = self.caret.x, y = self.caret.y}

	return state

end

--zzval
function GUI.dh_TextEditor:seteditorstate(retval, caret, wnd_pos, sel_s, sel_e)

    --GUI.Msg("\n# GUI.dh_TextEditor:seteditorstate retval type is : " .. type(retval))
    --GUI.Msg("# GUI.dh_TextEditor:seteditorstate retval size is : " .. tostring(#retval)) 
    
    self.retval = retval or {""}
    self.wnd_pos = wnd_pos or {x = 0, y = 1}
	self.caret = caret or {x = 0, y = 1}
    self.sel_s = sel_s or nil
    self.sel_e = sel_e or nil

end


-- See if we have a new-enough version of SWS for the clipboard functions
-- (v2.9.7 or greater)
function GUI.dh_TextEditor:SWS_clipboard()

	if GUI.SWS_exists then
		return true
	else

		reaper.ShowMessageBox(	"Clipboard functions require the SWS extension, v2.9.7 or newer."..
									"\n\nDownload the latest version at http://www.sws-extension.org/index.php",
									"Sorry!", 0)
		return false

	end

end