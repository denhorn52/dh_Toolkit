-- NoIndex: true

-- dh_Panel.lua
-- Date: 20250908

---------------------------------------------------------------------
-- Lokasenna_GUI - Frame class
--   For documentation, see this class's page on the project wiki:
--     https://github.com/jalovatt/Lokasenna_GUI/wiki/Frame
---------------------------------------------------------------------
--[[ Modified by Dennis Horn.

     Draws a panel with optional border and optional rounded corners.
     Fills background with col_bg.
     If "border_width is greater than 0 (default = 2) it will draw a border. 
     Can display text with adjustable line-height.
     No scrolling. If need scrolling use dh_Listbox.
     line-height may be different on different operating systems which can present a problem
       when trying to align text with adjacent elements. So I added a property "use_pixels"
       to try to overcome that. If "use_pixels" is set it will override "line_height".
       (As of 7-12-2025 text only accepts a table of string values.)
--]]
---------------------------------------------------------------------
-- Requires that Lokasenna_GUI v2 be loaded.

if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end

-- Requires dh_Toolkit_shared for modified roundrect function.
-- At least until I implement it in a different way.
local dhtks = require "common/dh_Toolkit_shared"

---------------------------------------------------------------------
--  Creation parameters:
--	name, z, x, y, w, h[, border_width, radius]
---------------------------------------------------------------------
GUI.dh_Panel = GUI.Element:new()

function GUI.dh_Panel:new(name, z, x, y, w, h, bw, rad)

	local panel = (not x and type(z) == "table") and z or {}
	panel = (not x and type(z) == "table") and z or {}

	panel.name = name
	panel.type = "dh_Panel"

	panel.z = panel.z or z

	panel.x = panel.x or x
    panel.y = panel.y or y
    panel.w = panel.w or w
    panel.h = panel.h or h
	
	-- panel.frame is redundant as border_width == 0 is no border,
	-- but I will leave it as it seems intuitive to specify.
	
	--if panel.frame == nil then
    --    panel.frame = true
    --end
    
    -- Same with panel.fill as it will automatically be filled,
    -- either with specified color or wnd_bg.
	
	--if panel.fill == nil then
    --    panel.fill = false
    --end
    
    if panel.shadow == nil then
        panel.shadow = false
    end

	panel.border_width = panel.border_width or bw or 2
	panel.radius = panel.radius or rad or 0  -- radius of bg rectangle.	
	
----colors------------------------------------------------
	panel.col_border = panel.col_border or "elm_frame"
	panel.col_bg = panel.col_bg or "wnd_bg"
	panel.col_text = panel.col_text or "txt"
----------------------------------------------------------  

    panel.font = panel.font or "mono16"
    panel.pad = panel.pad or 4
    panel.line_height = panel.line_height or 1.25
    panel.use_pixels = panel.use_pixels or 0
    
    panel.text = panel.text or nil
    
	panel.func = panel.func or function () end
	panel.params = panel.params or {}  --{...}    

	GUI.redraw_z[panel.z] = true

	setmetatable(panel, self)
	self.__index = self
	return panel

end


function GUI.dh_Panel:init()

    local x, y, w, h = self.x, self.y, self.w, self.h
    local bw = self.border_width
    local rad = self.radius  -- radius of bg rectangle.
    local sh_d = self.shadow and 2 or 0

	self.buff = self.buff or GUI.GetBuffer()

	gfx.dest = self.buff
	gfx.setimgdim(self.buff, -1, -1)
	--gfx.setimgdim(self.buff, 2 * w, h)
	-- Add 2 for shadow.
	gfx.setimgdim(self.buff, w + 2, h + 2)

    --GUI.Msg("**** dh_Panel.init ready to draw outer rectangle ****")
    --GUI.Msg("> dh_Panel.init elm z is: " .. self.z)
    --GUI.Msg("> dh_Panel.init elmname is: " .. self.name .. " : width is: " .. w)
    --GUI.Msg("> dh_Panel.init elm radius is: " .. rad)
    
    -- If no border then no shadow. Draw only bg then return.
    if bw == 0 then
        --GUI.Msg("> dh_Panel.init elmname is: " .. self.name)
	    GUI.color(self.col_bg)
        if rad > 0 then
            --GUI.roundrect(0, 0, w, h, rad, 1, 1)
            dhtks.roundrect(0, 0, w, h, rad, 1, 1)
        else
            gfx.rect(0, 0, w, h, 1)
        end
        return
    end
    
    --!!! GUI.roundrect yields wierd results when using shadow. 
    -- It seems that gfx.circle sometimes adds 1 to x and y when it shouldn't.
    -- I rewrote this function and put it in dh_Toolkit_shared as a hack.
    
    -- Draw outer shadow.

    if self.shadow then
        GUI.color(GUI.colors["shadow"])
        if rad > 0 then
            --GUI.roundrect(2, 2, w, h, rad + bw + sh_d, 1, 1)
            --GUI.roundrect(0, 0, w + 2, h + 2, rad + bw + sh_d, 1, 1)
            dhtks.roundrect(0, 0, w + 2, h + 2, rad + bw + sh_d, 1, 1)
            
                        
        else
            gfx.rect(2, 2, w, h, 1)
        end
    end
    
	-- Draw border rectangle.
	
    GUI.color(self.col_border)
    if rad > 0 then
        -- This is adding 1 to w and h.
        --GUI.roundrect(0, 0, w, h, rad + bw, 1, 1)
        dhtks.roundrect(0, 0, w, h, rad + bw, 1, 1)
    else
        gfx.rect(0, 0, w, h, 1)
    end
	
	-- Draw inner shadow.
	
    if self.shadow and bw > 0 then
        GUI.color(GUI.colors["shadow"])
        if rad > 0 then
            --GUI.roundrect(bw, bw, w - (2 * bw) , h - (2 * bw), rad + bw, 1, 1)
            dhtks.roundrect(bw, bw, w - (2 * bw) , h - (2 * bw), rad + bw, 1, 1)
        else
            gfx.rect(bw, bw, w - (2 * bw) , h - (2 * bw), 1)
        end
    end
    
    -- Draw inner bg rectangle --
 
    --GUI.Msg("** dh_Panel.init bw is: " .. tostring(bw))
    GUI.color(self.col_bg)
    
    if rad > 0 then
        --GUI.roundrect(bw + sh_d, bw + sh_d, w - ((2 * bw) + sh_d), h - ((2 * bw) + sh_d), rad, 1, 1)
        dhtks.roundrect(bw + sh_d, bw + sh_d, w - ((2 * bw) + sh_d), h - ((2 * bw) + sh_d), rad, 1, 1)
    else
        gfx.rect(bw + sh_d, bw + sh_d, w - ((2 * bw) + sh_d), h - ((2 * bw) + sh_d), 1)
    end	    

end


function GUI.dh_Panel:draw()
    --GUI.Msg("== dh_Panel:draw elmname is: " .. self.name .. " : width is: " .. self.w)

	local x, y, w, h = self.x, self.y, self.w, self.h
	
	if self.shadow then
	    w = w + 2
	    h = h + 2
	end

	gfx.blit(self.buff, 1, 0, 0, 0, w, h, x, y)
	
	-- Draw the text
	if self.text then
	    self:drawtext()
	end
	
end

function GUI.dh_Panel:drawtext()

    --if self.text then
            
        GUI.color(self.col_text)
	    GUI.font(self.font)    
        
        if type(self.text) == "table" then
        
            local str_w, str_h = gfx.measurestr("M")
                        
            if self.use_pixels > 0 then
                str_h = self.use_pixels
            else    
                str_h = str_h * self.line_height
            end

            local str_x = self.x + self.pad + self.border_width
            local str_y = self.y + self.pad + self.border_width

            
            for _, str in ipairs(self.text) do
            
                gfx.x = str_x
                gfx.y = str_y
                gfx.drawstr(str)
                str_y = str_y + str_h
            end
        
        end
        
    --end

end


function GUI.dh_Panel:ondelete()

	GUI.FreeBuffer(self.buff)
	
end

-- dh_Panel - Mouse up.
function GUI.dh_Panel:onmouseup()

	-- If the mouse was released on the button, run func
	if GUI.IsInside(self, GUI.mouse.x, GUI.mouse.y) then

		self.func(table.unpack(self.params))

	end
	self:redraw()

end

-- dh_Panel - Right mouse up
function GUI.dh_Panel:onmouser_up()

	if GUI.IsInside(self, GUI.mouse.x, GUI.mouse.y) and self.r_func then

		self.r_func(table.unpack(self.r_params))

	end
end

-- dh_Panel - Execute (extra method)
-- Used for allowing hotkeys to press a dh_Panel
function GUI.dh_Panel:exec(r)

	if r then
		self.r_func(table.unpack(self.r_params))
	else
		self.func(table.unpack(self.params))
	end

end