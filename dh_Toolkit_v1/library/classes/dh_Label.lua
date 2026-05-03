-- NoIndex: true

-- dh_Label.lua
-- Date: 20260330

---------------------------------------------------------------------
-- Lokasenna_GUI - Label class
--   For documentation, see this class's page on the project wiki:
--     https://github.com/jalovatt/Lokasenna_GUI/wiki/Label     

---------------------------------------------------------------------
--[[ Modified by Dennis Horn.

     Same as Lokasenna Label except for changed property names. 
     Note: init and draw functions added then subtracted 2 pixels from gfx.x and gfx.h.
           This caused labels to be displayed at design x minus 2 causing problems with tight layout.
           Changed to eliminate add/subtract. Doesn't seem to be causing any problems.
     20251219 rev a: added properties "text_pos" and "x_override". Although gfx.drawstring() allows for justifying text 
           dh_Label draws text on a background rectangle in a buffer then that buffer get blitted'
           Positioning occurs during the draw cycle. Use "x_override" with position "center" or "right". 
     20260106: x_override not needed. self.x will be repositioned if text_pos is not "left".       
     
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
-- name, z, x, y[, text, shadow_text, font, col_bg, col_text]
---------------------------------------------------------------------
-- dh_Label - New
GUI.dh_Label = GUI.Element:new()
function GUI.dh_Label:new(name, z, x, y, text, shadow_text, font, col_bg, col_text)

	local label = (not x and type(z) == "table") and z or {}

	label.name = name
	label.type = "dh_Label"

	label.z = label.z or z
	label.x = label.x or x
    label.y = label.y or y

	--label.caption = label.caption or caption or "Label"	
	label.text = label.text or text or GUI.dh_Label.defaults.text	
	label.font = label.font or font or GUI.dh_Label.defaults.font
	label.shadow_text = label.shadow_text or shadow_text or GUI.dh_Label.defaults.shadow_text

    label.text_pos = label.text_pos or GUI.dh_Label.defaults.text_pos   -- left,center,right
    --label.x_override = label.x_override or label.x

----colors---------------------------	
	label.col_bg =     label.col_bg     or bg         or GUI.dh_Label.defaults.col_bg
	label.col_text =   label.col_text   or col_text   or GUI.dh_Label.defaults.col_text
-------------------------------------  

    -- Placeholders; we'll get these at runtime
	label.w, label.h = 0, 0	
    
    -- Started to implement using func, but it is easy enough 
    -- to call a function by overriding the mouseup event.
	--label.func = label.func or func or function () end
	--label.params = label.params or {...}

	GUI.redraw_z[label.z] = true

	setmetatable(label, self)
    self.__index = self
    return label

end

GUI.dh_Label.defaults = {
	text = "Label",	
	font = "sans22",
    text_pos = "left",   -- left,center,right
    shadow_text = false,
	col_bg = "wnd_bg",
	col_text = "txt",
}

function GUI.dh_Label:init(open)

    -- We can't do font measurements without an open window
    if gfx.w == 0 then return end

    self.buffs = self.buffs or GUI.GetBuffer(2)

    GUI.font(self.font)
    self.w, self.h = gfx.measurestr(self.text)
    
    --GUI.Msg("Label:init self.h for : " .. self.name .. " is " .. tostring(self.h))    
    
    --??? Is this necessary? Does it really help antialiaing? 
    -- Two pixels is valuable in tight layouts.
    --local w, h = self.w + 4, self.h + 4
    local w, h = self.w, self.h
    
    -- Reposition self.x if not using default "left" alignment.

    --GUI.Msg("\n** Label:init self.x before adjustment : " .. tostring(self.x))
    
    if self.text_pos == "center" then
        self.x = math.floor(self.x - self.w / 2)
    elseif self.text_pos == "right" then
        self.x = self.x - self.w
    end
        
    --GUI.Msg("\n** Label:init self.x after adjustment : " .. tostring(self.x))
    
    -- Because we might be doing this in mid-draw-loop,
    -- make sure we put this back the way we found it
    local dest = gfx.dest

    -- Keeping the background separate from the text to avoid graphical
    -- issues when the text is faded.
    gfx.dest = self.buffs[1]
    gfx.setimgdim(self.buffs[1], -1, -1)
    gfx.setimgdim(self.buffs[1], w, h)

    GUI.color(self.col_bg)
    gfx.rect(0, 0, w, h)

    -- Text + shadow
    gfx.dest = self.buffs[2]
    gfx.setimgdim(self.buffs[2], -1, -1)
    gfx.setimgdim(self.buffs[2], w, h)

    -- Text needs a background or the antialiasing will look like shit
    GUI.color(self.col_bg)
    gfx.rect(0, 0, w, h)
    
    --gfx.x, gfx.y = 2, 2
    gfx.x, gfx.y = 0, 0

    GUI.color(self.col_text)

	if self.shadow_text then
        GUI.shadow(self.text, self.col_text, "shadow")
    else
        gfx.drawstr(self.text)
    end

    gfx.dest = dest

end


function GUI.dh_Label:ondelete()

	GUI.FreeBuffer(self.buffs)

end


function GUI.dh_Label:fade(len, z_new, z_end, curve)

	self.z = z_new
	self.fade_arr = { len, z_end, reaper.time_precise(), curve or 3 }
	self:redraw()

end

--zzdraw
function GUI.dh_Label:draw()

    -- Font stuff doesn't work until we definitely have a gfx window
	if self.w == 0 then self:init() end

    local a = self.fade_arr and self:getalpha() or 1
    if a == 0 then return end
    
    --gfx.x, gfx.y = self.x - 2, self.y - 2
    gfx.x, gfx.y = self.x, self.y
    
    --[[
    if self.text_pos == "center" then
        --gfx.x = self.x_override - self.w / 2
        gfx.x = self.x - self.w / 2
    elseif self.text_pos == "right" then
        --gfx.x = self.x_override - self.w
        gfx.x = self.x - self.w
    else -- left    
        gfx.x = self.x
    end
    
    gfx.y = self.y
    --]]

    -- Background
    gfx.blit(self.buffs[1], 1, 0)

    gfx.a = a

    -- Text
    gfx.blit(self.buffs[2], 1, 0)

    gfx.a = 1

end


function GUI.dh_Label:val(newval)

	if newval then
		self.text = newval
		self:init()
		self:redraw()
	else
		return self.text
	end

end

-- 20250430 Added by dh. Not currently using.
function GUI.dh_Label:onmouseup()
--[[
	--self.state = 0

	-- If the mouse was released on the button, run func
	if GUI.IsInside(self, GUI.mouse.x, GUI.mouse.y) then

		self.func(table.unpack(self.params))

	end
	
	--self:redraw()
--]]
end

function GUI.dh_Label:getalpha()

    local sign = self.fade_arr[4] > 0 and 1 or -1

    local diff = (reaper.time_precise() - self.fade_arr[3]) / self.fade_arr[1]
    diff = math.floor(diff * 100) / 100
    diff = diff^(math.abs(self.fade_arr[4]))

    local a = sign > 0 and (1 - (gfx.a * diff)) or (gfx.a * diff)

    self:redraw()

    -- Terminate the fade loop at some point
    if sign == 1 and a < 0.02 then
        self.z = self.fade_arr[2]
        self.fade_arr = nil
        return 0
    elseif sign == -1 and a > 0.98 then
        self.fade_arr = nil
    end

    return a

end