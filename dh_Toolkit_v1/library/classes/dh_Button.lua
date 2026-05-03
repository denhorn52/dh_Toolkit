-- NoIndex: true

-- dh_Button.lua
-- Date: 20260330

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
-- name, z, x, y, w, h[, text, func, ...] 
---------------------------------------------------------------------
GUI.dh_Button = GUI.Element:new()
function GUI.dh_Button:new(name, z, x, y, w, h, text, func, ...)

	local Button = (not x and type(z) == "table") and z or {}

	Button.name = name
	Button.type = "dh_Button"

	Button.z = Button.z or z

	Button.x = Button.x or x
    Button.y = Button.y or y
    Button.w = Button.w or w or GUI.dh_Button.defaults.w
    Button.h = Button.h or h or GUI.dh_Button.defaults.h
    
	Button.text = Button.text or GUI.dh_Button.defaults.text

	Button.font = Button.font or GUI.dh_Button.defaults.font
	
	Button.shadow_text = Button.shadow_text or GUI.dh_Button.defaults.shadow_text
	
    --Button.allow_sel_outline = Button.allow_sel_outline	
    if Button.allow_sel_outline == nil then 
        Button.allow_sel_outline = GUI.dh_Button.defaults.allow_sel_outline	
    end
    
----colors---------------------------
	Button.col_bg = Button.col_bg or GUI.dh_Button.defaults.col_bg
	Button.col_outline = Button.col_outline or GUI.dh_Button.defaults.col_outline
	Button.col_text = Button.col_text or GUI.dh_Button.defaults.col_text
	Button.col_active = Button.col_active or GUI.dh_Button.defaults.col_active	
-------------------------------------  	

	Button.func = Button.func or func or GUI.dh_Button.defaults.func
	Button.params = Button.params or GUI.dh_Button.defaults.params	
	
	Button.state = 0

	GUI.redraw_z[Button.z] = true

	setmetatable(Button, self)
	self.__index = self
	return Button

end

GUI.dh_Button.defaults = {
    w = 64,
    h = 28,
    text = "Button",
    font = "sans22",
    shadow_text = false,
    allow_sel_outline = false,
    func = function () end,
    params = {...},
	col_bg = "btn_face",    
	col_outline = "btn_outline",
	col_text = "btn_txt",
	col_active = "elm_active",	
}

function GUI.dh_Button:init()

    --GUI.Msg("dh_Button:init name :" .. self.name)
    
    local sd = GUI.shadow_dist or 2
    
	self.buff = self.buff or GUI.GetBuffer()

	gfx.dest = self.buff
	gfx.setimgdim(self.buff, -1, -1)
	gfx.setimgdim(self.buff, 2 * self.w + sd, self.h + sd)

    -- Draw the button (roundrect adds 1 px to w and h.)
    
	GUI.color(self.col_bg)
	GUI.roundrect(0, 0, self.w - 1, self.h - 1, 4, 1, 1)
	
	-- Draw outline
	
	GUI.color(self.col_outline)
	GUI.roundrect(0, 0, self.w - 1, self.h - 1, 4, 1, 0)

    -- Draw the shadow

	local sa = GUI.colors["shadow"][4]
	
    -- Draw shadow shape opaque.    
    GUI.color("black")
    GUI.roundrect(self.w, 0, self.w + sd - 1, self.h + sd - 1, 4, 1, 1) 
               
    -- Then lighten whole buffer.
    gfx.muladdrect(self.w, 0, self.w + sd, self.h + sd, 1, 1, 1, sa, 0, 0, 0, 0 )  		

	-- Draw the text
	
	GUI.font(self.font)
	
	local str = self.text
	str = str:gsub([[\n]],"\n")
	
	local str_w, str_h = gfx.measurestr(str)

	gfx.x = (self.w - str_w) / 2
	gfx.y = (self.h - str_h) / 2
	
	if self.shadow_text then
	    GUI.shadow(str, self.col_text, "shadow")
	else
	    GUI.color(self.col_text)
	    gfx.drawstr(str)
	end


end


function GUI.dh_Button:ondelete()

	GUI.FreeBuffer(self.buff)

end


function GUI.dh_Button:draw()
    --GUI.Msg("\ndh_Button:draw : self.name :" .. self.name)

	local x, y, w, h = self.x, self.y, self.w, self.h
    local sd = GUI.shadow_dist or 2

	local state = self.state
    
	if state == 0 then  -- not pressed
	    -- Draw the shadow
	    --gfx.blit(self.buff, 1, 0, w, 0, w , h, x + sd, y + sd)
	    gfx.blit(self.buff, 1, 0, w, 0, w + sd , h + sd, x, y)	    
	    
	    -- Draw the button
	    gfx.blit(self.buff, 1, 0, 0, 0, w, h, x, y)
	end
	
	if state == 1 then  -- pressed
	    --GUI.Msg("    button pressed")
	    -- Draw the shadow
	    gfx.blit(self.buff, 1, 0, w, 0, w + sd, h + sd, x, y)
	    -- Draw the button
	    gfx.blit(self.buff, 1, 0, 0, 0, w , h, x + sd, y + sd)
	end
	
	-- Focused?	
    --GUI.Msg("** dh_Button:draw: self.focus is: " .. tostring(self.focus))
    --GUI.Msg("** dh_Button:draw: self.allow_sel_outline is: " .. tostring(self.allow_sel_outline))         	    
    	
	if self.focus then
	    if self.allow_sel_outline then
	        GUI.color(self.col_active)
	        gfx.rect(x - 1, y - 1, w + 2, h + 2, 0)
	        -- Thicken highlight.
	        gfx.rect(x - 2, y - 2, w + 4, h + 4, 0)
	    end
	end	
    
end

-- dh_Button - Mouse down.
function GUI.dh_Button:onmousedown()

	self.state = 1
	self:redraw()

end


-- dh_Button - Mouse up.
function GUI.dh_Button:onmouseup()

    --GUI.Msg("** dh_Button:onmouseup: self.focus is: " .. tostring(self.focus))
    
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

-- Make sure the box highlight goes away
function GUI.dh_Button:lostfocus()
    --GUI.Msg("\n##  button lost focus  ##")
    if self.allow_sel_outline then
        self:redraw()
    end

end

-- dh_Button - Execute (extra method)
-- Used for allowing hotkeys to press a button
function GUI.dh_Button:exec(r)

	if r then
		self.r_func(table.unpack(self.r_params))
	else
		self.func(table.unpack(self.params))
	end

end