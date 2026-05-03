-- NoIndex: true

-- dh_Textbox.lua
-- Date: 20260330

---------------------------------------------------------------------
-- Lokasenna_GUI - Textbox class
--   For documentation, see this class's page on the project wiki:
--     https://github.com/jalovatt/Lokasenna_GUI/wiki/Textbox

---------------------------------------------------------------------
--[[ Modified by Dennis Horn.

     Same as Lokasenna Textbox except changed most of the property names for consistency with other dh_Toolkit classes.
     Changed some property names and default values.
     Allows all of the color properties to be overridden.
     Added property allow_sel_outline.
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
-- name, z, x, y, w, h[, caption, pad]
---------------------------------------------------------------------
GUI.dh_Textbox = GUI.Element:new()
function GUI.dh_Textbox:new(name, z, x, y, w, h, caption, pad)

	local txt = (not x and type(z) == "table") and z or {}

	txt.name = name
	txt.type = "dh_Textbox"

	txt.z = txt.z or z

	txt.x = txt.x or x
    txt.y = txt.y or y
    txt.w = txt.w or w or GUI.dh_Textbox.defaults.w
    txt.h = txt.h or h or GUI.dh_Textbox.defaults.h

    txt.retval = txt.retval or ""

	txt.caption = txt.caption or caption or GUI.dh_Textbox.defaults.caption
	txt.font_caption = txt.font_caption or GUI.dh_Textbox.defaults.font_caption
	txt.cap_pos = txt.cap_pos or GUI.dh_Textbox.defaults.cap_pos
	txt.cap_pad_x = txt.cap_pad_x or GUI.dh_Textbox.defaults.cap_pad_x
	txt.cap_pad_y = txt.cap_pad_y or GUI.dh_Textbox.defaults.cap_pad_y
	txt.cap_centered = txt.cap_centered or GUI.dh_Textbox.defaults.cap_centered

	-- Forcing a safe monospace font to make our lives easier
	txt.font_text = txt.font_text or GUI.dh_Textbox.defaults.font_text
	txt.pad = txt.pad or pad or GUI.dh_Textbox.defaults.pad
    txt.align_text = txt.align_text or GUI.dh_Textbox.defaults.align_text  -- left, center, right
    
    txt.shadow = txt.shadow or GUI.dh_Textbox.defaults.shadow
    txt.shadow_caption = txt.shadow_caption or GUI.dh_Textbox.defaults.shadow_caption
    
    txt.frame_use_outline = txt.frame_use_outline or GUI.dh_Textbox.defaults.frame_use_outline	
    txt.frame_thk = txt.frame_thk or GUI.dh_Textbox.defaults.frame_thk

    if txt.allow_sel_outline == nil then 
        txt.allow_sel_outline = GUI.dh_Textbox.defaults.allow_sel_outline 
    end    
    
----colors----------------------------------
    -- Caption   
    txt.col_cap_text = txt.col_cap_text or GUI.dh_Textbox.defaults.col_cap_text
    
    -- Box
    txt.col_bg = txt.col_bg or GUI.dh_Textbox.defaults.col_bg    
    txt.col_frame = txt.col_frame or GUI.dh_Textbox.defaults.col_frame 

	-- Box Text
	txt.col_text = txt.col_text or GUI.dh_Textbox.defaults.col_text
	txt.col_sel_text = txt.col_sel_text or GUI.dh_Textbox.defaults.col_sel_text

    txt.col_active = txt.col_active or GUI.dh_Textbox.defaults.col_active	
    txt.col_backdrop = txt.col_backdrop or GUI.dh_Textbox.defaults.col_backdrop	
---------------------------------------------

	-- Use negative value to darken.
	txt.sel_alpha = txt.sel_alpha or GUI.dh_Textbox.defaults.sel_alpha
	    	
    txt.undo_limit = txt.undo_limit or GUI.dh_Textbox.defaults.undo_limit

    txt.undo_states = {}
    txt.redo_states = {}

    txt.wnd_pos = 0
	txt.caret = 0
	txt.sel_s, txt.sel_e = nil, nil

    txt.char_h, txt.wnd_h, txt.wnd_w, txt.char_w = nil, nil, nil, nil

	txt.focus = false

	txt.blink = 0

	GUI.redraw_z[txt.z] = true

	setmetatable(txt, self)
	self.__index = self
	return txt

end

GUI.dh_Textbox.defaults = {
    w = 96,
    h = 28,
    retval = "",
    font_text = "mono16",
    pad = 4,
    align_text = "left",
    undo_limit = 20,
    
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
    col_cap_text = "txt",
	col_text = "elm_txt",        	
	col_sel_text = "sel_txt",	
    sel_alpha = 0.5,	    	    
    col_active = "elm_active",
    col_backdrop = "wnd_bg", 

}


function GUI.dh_Textbox:init()

    --GUI.Msg("dh_Textbox:init")
    
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
        gfx.rect(0, 0, w, h, 1) -- draw 1 px wide frame          
       
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


function GUI.dh_Textbox:ondelete()

	GUI.FreeBuffer(self.buff)

end

------------------------------------
-------- Drawing methods -----------
------------------------------------

function GUI.dh_Textbox:draw()

    local x, y, w, h = self.x, self.y, self.w, self.h
    
    local sd = self.shadow and GUI.shadow_dist or 0
	
	-- Some values can't be set in :init() because the window isn't
	-- open yet - measurements won't work.
	if not self.wnd_w then self:wnd_recalc() end

	-- Draw the caption
	if self.caption and self.caption ~= "" then self:drawcaption() end

	-- Blit the textbox frame, and make it brighter if focused.
    --        src, scale, rot, srcx,                     srcy, srcw,   srch,  destx,  desty,  destw, desth, rotxoffs, rotyoffs)	
	--gfx.blit(self.buff, 1, 0, (self.focus and self.w or 0), 0, self.w, self.h, self.x, self.y)
	
	-- Blit the background and frame.
	gfx.blit(self.buff, 1, 0, 0, 0, w + sd, h + sd, x, y)
	
    if self.retval ~= "" then self:drawtext() end
    
	-- Focused?    
	
	if self.focus then
        
        --GUI.Msg("dh_Textbox:draw if self.focus")        
        
		if self.sel_s then self:drawselection() end
		if self.show_caret then self:drawcaret() end
		
		if self.allow_sel_outline then
    		GUI.color(self.col_active)
    	    --gfx.rect(x - 1, y - 1, w + 2, h + 2, 0)
    	    gfx.rect(x - 2, y - 2, w + 4, h + 4, 0)
    		-- Thicken highlight.
    	    --gfx.rect(x - 2, y - 2, w + 4, h + 4, 0)		
		end

	end	

    self:drawgradient()

end

--zzcap
function GUI.dh_Textbox:drawcaption()

    --GUI.Msg("dh_Textbox:drawcaption self.cap_pad_x : " .. tostring(self.cap_pad_x))
    
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


function GUI.dh_Textbox:drawtext()

	GUI.color(self.col_text)
	GUI.font(self.font_text)
	
    local text = string.sub(self.retval, self.wnd_pos + 1)
	
    --local str_w, str_h = gfx.measurestr(text)

    -- Draws a string at gfx_x, gfx_y; clipped to (gfx_x, gfx_y, right, bottom) 
    -- Adjustments: aligns to defined box.
    -- align: 0 = left, 1= center, 2 = right, 4 = center vert
    
    local align = (self.align_text == "left") and (0 + 4)
               or (self.align_text == "center") and (1 + 4)
               or  (2 + 4)  -- right
    
	gfx.x = self.x + self.pad  
	gfx.y = self.y + (self.h - gfx.texth) / 2
	
    local r = self.x + self.w - self.pad 
    --local b = gfx.y + gfx.texth
    local b = self.y + self.h - 4
    
	gfx.drawstr(text, align, r, b)

end


function GUI.dh_Textbox:drawcaret()

    local caret_wnd = self:adjusttowindow(self.caret)

    if caret_wnd then

        GUI.color(self.col_text)

        local caret_h = self.char_h - 2

        gfx.rect(   self.x + (caret_wnd * self.char_w) + 4,
                    self.y + (self.h - caret_h) / 2,
                    self.insert_caret and self.char_w or 2,
                    caret_h)

    end

end


function GUI.dh_Textbox:drawselection()

    local x, w

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

    local s, e = self.sel_s, self.sel_e

    if e < s then s, e = e, s end

    local x = GUI.clamp(self.wnd_pos, s, self:wnd_right())
    local w = GUI.clamp(x, e, self:wnd_right()) - x

    if self:selectionvisible(x, w) then

        -- Convert from char-based coords to actual pixels
        x = self.x + (x - self.wnd_pos) * self.char_w + 4

        h = self.char_h - 2

        y = self.y + (self.h - h) / 2

        w = w * self.char_w
        w = math.min(w, self.x + self.w - x - self.pad)

        gfx.rect(x, y, w, h, true)

    end

    gfx.mode = 0

	-- Later calls to GUI.color should handle this, but for
	-- some reason they aren't always.
    gfx.a = 1

end


function GUI.dh_Textbox:drawgradient()

    local left, right = self.wnd_pos > 0, self.wnd_pos < (string.len(self.retval) - self.wnd_w + 2)
    if not (left or right) then return end

    local x, y, w, h = self.x, self.y, self.w, self.h
    local fade_w = 8

    GUI.color(self.col_bg)
    for i = 0, fade_w do

        gfx.a = i/fade_w

        -- Left
        if left then
            local x = x + 2 + fade_w - i
            gfx.line(x, y + 2, x, y + h - 4)
        end

        -- Right
        if right then
            local x = x + w - 3 - fade_w + i
            gfx.line(x, y + 2, x, y + h - 4)
        end

    end

end

------------------------------------
-------- Input methods -------------
------------------------------------

function GUI.dh_Textbox:val(newval)

	if newval then
        self:seteditorstate(tostring(newval))
		self:redraw()
	else
		return self.retval
	end

end


-- Just for making the caret blink
function GUI.dh_Textbox:onupdate()

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

-- Make sure the box highlight goes away
function GUI.dh_Textbox:lostfocus()

    self:redraw()
    --if self.allow_sel_outline then
        self:redraw()
    --end    

end


function GUI.dh_Textbox:onmousedown()

    self.caret = self:getcaret(GUI.mouse.x)

    -- Reset the caret so the visual change isn't laggy
    self.blink = 0

    -- Shift+click to select text
    if GUI.mouse.cap & 8 == 8 and self.caret then

        self.sel_s, self.sel_e = self.caret, self.caret

    else

        self.sel_s, self.sel_e = nil, nil

    end

    self:redraw()

end


function GUI.dh_Textbox:ondoubleclick()

	self:selectword()

end


function GUI.dh_Textbox:ondrag()

	self.sel_s = self:getcaret(GUI.mouse.ox, GUI.mouse.oy)
    self.sel_e = self:getcaret(GUI.mouse.x, GUI.mouse.y)

	self:redraw()

end


function GUI.dh_Textbox:ontype()

	local char = GUI.char

    -- Navigation keys, Return, clipboard stuff, etc
    if self.keys[char] then

        local shift = GUI.mouse.cap & 8 == 8

        if shift and not self.sel_s then
            self.sel_s = self.caret
        end

        -- Flag for some keys (clipboard shortcuts) to skip
        -- the next section
        local bypass = self.keys[char](self)

        if shift and char ~= GUI.chars.BACKSPACE then

            self.sel_e = self.caret

        elseif not bypass then

            self.sel_s, self.sel_e = nil, nil

        end

    -- Typeable chars
    elseif GUI.clamp(32, char, 254) == char then

        if self.sel_s then self:deleteselection() end

        self:insertchar(char)

    end
    self:windowtocaret()

    -- Make sure no functions crash because they got a type==number
    self.retval = tostring(self.retval)

    -- Reset the caret so the visual change isn't laggy
    self.blink = 0

end


function GUI.dh_Textbox:onwheel(inc)

   local len = string.len(self.retval)

   if len <= self.wnd_w then return end

   -- Scroll right/left
   local dir = inc > 0 and 3 or -3
   self.wnd_pos = GUI.clamp(0, self.wnd_pos + dir, len + 2 - self.wnd_w)

   self:redraw()

end

------------------------------------
-------- Selection methods ---------
------------------------------------


-- Make sure at least part of the selection is visible
function GUI.dh_Textbox:selectionvisible(x, w)

	return 		w > 0                   -- Selection has width,
			and x + w > self.wnd_pos    -- doesn't end to the left
            and x < self:wnd_right()    -- and doesn't start to the right

end


function GUI.dh_Textbox:selectall()

    self.sel_s = 0
    self.caret = 0
    self.sel_e = string.len(self.retval)

end


function GUI.dh_Textbox:selectword()

    local str = self.retval

    if not str or str == "" then return 0 end

    self.sel_s = string.find( str:sub(1, self.caret), "%s[%S]+$") or 0
    self.sel_e = (      string.find( str, "%s", self.sel_s + 1)
                    or  string.len(str) + 1)
                - (self.wnd_pos > 0 and 2 or 1) -- Kludge, fixes length issues

end


function GUI.dh_Textbox:deleteselection()

    if not (self.sel_s and self.sel_e) then return 0 end

    self:storeundostate()

    local s, e = self.sel_s, self.sel_e

    if s > e then
        s, e = e, s
    end

    self.retval =   string.sub(self.retval or "", 1, s)..
                    string.sub(self.retval or "", e + 1)

    self.caret = s

    self.sel_s, self.sel_e = nil, nil
    self:windowtocaret()


end


function GUI.dh_Textbox:getselectedtext()

    local s, e= self.sel_s, self.sel_e

    if s > e then s, e = e, s end

    return string.sub(self.retval, s + 1, e)

end


function GUI.dh_Textbox:toclipboard(cut)

    if self.sel_s and self:SWS_clipboard() then

        local str = self:getselectedtext()
        reaper.CF_SetClipboard(str)
        if cut then self:deleteselection() end

    end

end


function GUI.dh_Textbox:fromclipboard()

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
-------- Window/pos helpers --------
------------------------------------


function GUI.dh_Textbox:wnd_recalc()

    GUI.font(self.font_text)

    --[[
    self.char_h = gfx.texth
    self.char_w = gfx.measurestr("_")
    ]]--
    
    self.char_w, self.char_h = gfx.measurestr("i")
    self.wnd_w = math.floor(self.w / self.char_w)

end


function GUI.dh_Textbox:wnd_right()

   return self.wnd_pos + self.wnd_w

end


-- See if a given position is in the visible window
-- If so, adjust it from absolute to window-relative
-- If not, returns nil
function GUI.dh_Textbox:adjusttowindow(x)

    return ( GUI.clamp(self.wnd_pos, x, self:wnd_right() - 1) == x )
        and x - self.wnd_pos
        or nil

end


function GUI.dh_Textbox:windowtocaret()

    if self.caret < self.wnd_pos + 1 then
        self.wnd_pos = math.max(0, self.caret - 1)
    elseif self.caret > (self:wnd_right() - 2) then
        self.wnd_pos = self.caret + 2 - self.wnd_w
    end

end


function GUI.dh_Textbox:getcaret(x)

    x = math.floor(  ((x - self.x) / self.w) * self.wnd_w) + self.wnd_pos
    return GUI.clamp(0, x, string.len(self.retval or ""))

end

------------------------------------
-------- Char/string helpers -------
------------------------------------

function GUI.dh_Textbox:insertstring(str, move_caret)

    self:storeundostate()

    str = self:sanitizetext(str)

    if self.sel_s then self:deleteselection() end

    local s = self.caret

    local pre, post =   string.sub(self.retval or "", 1, s),
                        string.sub(self.retval or "", s + 1)

    self.retval = pre .. tostring(str) .. post

    if move_caret then self.caret = self.caret + string.len(str) end

end


function GUI.dh_Textbox:insertchar(char)

    self:storeundostate()

    local a, b = string.sub(self.retval, 1, self.caret),
                 string.sub(self.retval, self.caret + (self.insert_caret and 2 or 1))

    self.retval = a..string.char(char)..b
    self.caret = self.caret + 1

end


function GUI.dh_Textbox:carettoend()

   return string.len(self.retval or "")

end


-- Replace any characters that we're unable to reproduce properly
function GUI.dh_Textbox:sanitizetext(str)

    str = tostring(str)
    str = str:gsub("\t", "    ")
    str = str:gsub("[\n\r]", " ")
    return str

end


function GUI.dh_Textbox:ctrlchar(func, ...)

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
GUI.dh_Textbox.keys = {

    [GUI.chars.LEFT] = function(self)

        self.caret = math.max( 0, self.caret - 1)

    end,

    [GUI.chars.RIGHT] = function(self)

        self.caret = math.min( string.len(self.retval), self.caret + 1 )

    end,

    [GUI.chars.UP] = function(self)

        self.caret = 0

    end,

    [GUI.chars.DOWN] = function(self)

        self.caret = string.len(self.retval)

    end,

    [GUI.chars.BACKSPACE] = function(self)

        self:storeundostate()

        if self.sel_s then

            self:deleteselection()

        else

        if self.caret <= 0 then return end

            local str = self.retval
            self.retval =   string.sub(str, 1, self.caret - 1)..
                            string.sub(str, self.caret + 1, -1)
            self.caret = math.max(0, self.caret - 1)

        end

    end,

    [GUI.chars.INSERT] = function(self)

        self.insert_caret = not self.insert_caret

    end,

    [GUI.chars.DELETE] = function(self)

        self:storeundostate()

        if self.sel_s then

            self:deleteselection()

        else

            local str = self.retval
            self.retval =   string.sub(str, 1, self.caret) ..
                            string.sub(str, self.caret + 2)

        end

    end,

    [GUI.chars.RETURN] = function(self)

        self.focus = false
        self:lostfocus()
        self:redraw()

    end,

    [GUI.chars.HOME] = function(self)

        self.caret = 0

    end,

    [GUI.chars.END] = function(self)

        self.caret = string.len(self.retval)

    end,

    [GUI.chars.TAB] = function(self)

        GUI.tab_to_next(self)

    end,

	-- A -- Select All
	[1] = function(self)

		return self:ctrlchar(self.selectall)

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
-------- Misc. helpers -------------
------------------------------------

function GUI.dh_Textbox:undo()

	if #self.undo_states == 0 then return end
	table.insert(self.redo_states, self:geteditorstate() )
	local state = table.remove(self.undo_states)

    self.retval = state.retval
	self.caret = state.caret

	self:windowtocaret()

end


function GUI.dh_Textbox:redo()

	if #self.redo_states == 0 then return end
	table.insert(self.undo_states, self:geteditorstate() )
	local state = table.remove(self.redo_states)

	self.retval = state.retval
	self.caret = state.caret

	self:windowtocaret()

end


function GUI.dh_Textbox:storeundostate()

table.insert(self.undo_states, self:geteditorstate() )
	if #self.undo_states > self.undo_limit then table.remove(self.undo_states, 1) end
	self.redo_states = {}

end


function GUI.dh_Textbox:geteditorstate()

	return { retval = self.retval, caret = self.caret }

end


function GUI.dh_Textbox:seteditorstate(retval, caret, wnd_pos, sel_s, sel_e)

    self.retval = retval or ""
    self.caret = math.min(caret and caret or self.caret, string.len(self.retval))
    self.wnd_pos = wnd_pos or 0
    self.sel_s, self.sel_e = sel_s or nil, sel_e or nil

end

-- See if we have a new-enough version of SWS for the clipboard functions
-- (v2.9.7 or greater)
function GUI.dh_Textbox:SWS_clipboard()

	if GUI.SWS_exists then
		return true
	else

		reaper.ShowMessageBox(	"Clipboard functions require the SWS extension, v2.9.7 or newer."..
									"\n\nDownload the latest version at http://www.sws-extension.org/index.php",
									"Sorry!", 0)
		return false

	end

end