-- NoIndex: true

-- dh_Button.lua
-- Date: 20250908

---------------------------------------------------------------------
-- Lokasenna_GUI - Button class
--   For documentation, see this class's page on the project wiki:
--     https://github.com/jalovatt/Lokasenna_GUI/wiki/Button
---------------------------------------------------------------------
--[[ Modified by Dennis Horn.

     Same as Lokasenna Button but with some renamed properties and default colors. 
     
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
-- name, z, x, y, w, h, txt, func[, ...]
---------------------------------------------------------------------
GUI.dh_Button = GUI.Element:new()
function GUI.dh_Button:new(name, z, x, y, w, h, txt, func, ...)

	local Button = (not x and type(z) == "table") and z or {}

	Button.name = name
	Button.type = "dh_Button"

	Button.z = Button.z or z

	Button.x = Button.x or x
    Button.y = Button.y or y
    Button.w = Button.w or w
    Button.h = Button.h or h

	Button.text = Button.text or txt or "Button"

	Button.func = Button.func or func or function () end
	Button.params = Button.params or {...}	

	Button.font = Button.font or "sans22"

----colors---------------------------
	Button.col_outline = Button.col_outline or "btn_outline"
	Button.col_bg = Button.col_bg or "elm_face" or "btn_face"
	Button.col_text = Button.col_text or "btn_txt"
-------------------------------------  	

	Button.state = 0

	GUI.redraw_z[Button.z] = true

	setmetatable(Button, self)
	self.__index = self
	return Button

end


function GUI.dh_Button:init()
    --GUI.Msg("dh_Button:init name :" .. self.name)
	self.buff = self.buff or GUI.GetBuffer()

	gfx.dest = self.buff
	gfx.setimgdim(self.buff, -1, -1)
	gfx.setimgdim(self.buff, 2 * self.w + 4, self.h + 2)

	GUI.color(self.col_bg)

	GUI.roundrect(1, 1, self.w, self.h, 4, 1, 1)
	GUI.color(self.col_outline)
	GUI.roundrect(1, 1, self.w, self.h, 4, 1, 0)


	local r, g, b, a = table.unpack(GUI.colors["shadow"])
	gfx.set(r, g, b, 1)
	GUI.roundrect(self.w + 2, 1, self.w, self.h, 4, 1, 1)
	gfx.muladdrect(self.w + 2, 1, self.w + 2, self.h + 2, 1, 1, 1, a, 0, 0, 0, 0 )


end


function GUI.dh_Button:ondelete()

	GUI.FreeBuffer(self.buff)

end


function GUI.dh_Button:draw()
    --GUI.Msg("dh_Button:draw name :" .. self.name)
    
	local x, y, w, h = self.x, self.y, self.w, self.h
	local state = self.state

	-- Draw the shadow if not pressed
	if state == 0 then

		for i = 1, GUI.shadow_dist do

			gfx.blit(self.buff, 1, 0, w + 2, 0, w + 2, h + 2, x + i - 1, y + i - 1)

		end

	end

	gfx.blit(self.buff, 1, 0, 0, 0, w + 2, h + 2, x + 2 * state - 1, y + 2 * state - 1)

	-- Draw the text
	GUI.color(self.col_text)
	GUI.font(self.font)

    local str = self.text
    str = str:gsub([[\n]],"\n")

	local str_w, str_h = gfx.measurestr(str)
	gfx.x = x + 2 * state + ((w - str_w) / 2)
	gfx.y = y + 2 * state + ((h - str_h) / 2)
	gfx.drawstr(str)

end

-- dh_Button - Mouse down.
function GUI.dh_Button:onmousedown()

	self.state = 1
	self:redraw()

end


-- dh_Button - Mouse up.
function GUI.dh_Button:onmouseup()

	self.state = 0

	-- If the mouse was released on the button, run func
	if GUI.IsInside(self, GUI.mouse.x, GUI.mouse.y) then

		self.func(table.unpack(self.params))

	end
	self:redraw()

end

-- dh_Button - Double click
function GUI.dh_Button:ondoubleclick()

	self.state = 0

	end


-- dh_Button - Right mouse up
function GUI.dh_Button:onmouser_up()

	if GUI.IsInside(self, GUI.mouse.x, GUI.mouse.y) and self.r_func then

		self.r_func(table.unpack(self.r_params))

	end
end
--[[ !!! Proposed change by Dennis Horn 20220220. Would eliminate need to declare r_params in element definition.
-- dh_Button - Right mouse up
function GUI.dh_Button:onmouser_up()

	if GUI.IsInside(self, GUI.mouse.x, GUI.mouse.y) and self.r_func then
		if self.r_params then
			self.r_func(table.unpack(self.r_params))
		else
			self.r_func()
		end
	end
end
--]]

-- dh_Button - Execute (extra method)
-- Used for allowing hotkeys to press a button
function GUI.dh_Button:exec(r)

	if r then
		self.r_func(table.unpack(self.r_params))
	else
		self.func(table.unpack(self.params))
	end

end