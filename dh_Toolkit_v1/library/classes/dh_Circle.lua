-- NoIndex: true

-- dh_Circle.lua
-- Date: 20250706

---------------------------------------------------------------------
--[[ Modified by Dennis Horn.

     Class to test drawing boundaries of gfx.circle.
     
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
-- name, z, x, y, w, h, r
---------------------------------------------------------------------
-- dh_Circle - New
GUI.dh_Circle = GUI.Element:new()
function GUI.dh_Circle:new(name, z, x, w, h, y, r)

	local circle = (not x and type(z) == "table") and z or {}

	circle.name = name
	circle.type = "dh_Circle"

	circle.z = circle.z or z
	circle.x = circle.x or x
    circle.y = circle.y or y
	circle.w = circle.w or w
	circle.h = circle.h or h

    circle.r = circle.r or r
	
	if circle.offset == nil then
	    circle.offset = 0
	else
	    circle.offset = circle.offset
	end	
	
	if circle.fill == nil then
	    circle.fill = 0
	else
	    circle.fill = circle.fill
	end
	        

    if circle.aa == nil then
        circle.aa = 0
    else
        circle.aa = circle.aa
    end
    
    if circle.rect == nil then
        circle.rect = false
    else
        circle.rect = circle.rect
    end

----colors---------------------------	
	circle.col_rect =     circle.col_rect  or "red"
	circle.col_circle =   circle.col_circle or "green"
-------------------------------------  

	GUI.redraw_z[circle.z] = true

	setmetatable(circle, self)
    self.__index = self
    return circle

end


function GUI.dh_Circle:init(open)

    local x, y, w, h = self.x, self.y, self.w, self.h
    gfx.x, gfx.y = x, y
    
    self.buff = self.buff or GUI.GetBuffer()
        
    --GUI.Msg("Circle:init self.r for : " .. self.name .. " is " .. tostring(self.r))    

    gfx.dest = self.buff
    gfx.setimgdim(self.buff, -1, -1)
    gfx.setimgdim(self.buff, w + 2, h + 2)

    
    GUI.color("white")
    gfx.rect(0, 0, w, h, 1)
    
    --GUI.color(self.col_rect)
    GUI.color("red")    
    
    if self.rect then
        -- Draw rect.
        gfx.rect(0, 0, w, h, 1)
    else
        -- Draw rect with lines.
        gfx.line(0, 0, w, 0)
        gfx.line(0, 0, 0, h)
        gfx.line(w, 0 , w, h)
        gfx.line(0, h, w, h)
    end
    
    -- Draw circle.
    
    GUI.color(self.col_circle)
    
    local ctr = self.r + self.offset
    gfx.circle(ctr, ctr, 1, self.fill, self.aa)    
    gfx.circle(ctr, ctr, self.r, self.fill, self.aa)

end


function GUI.dh_Circle:ondelete()

	GUI.FreeBuffer(self.buff)

end


function GUI.dh_Circle:draw()
    local x, y, w, h = self.x, self.y, self.w + 2, self.h + 2
    --gfx.x, gfx.y = 0, 0
    gfx.blit(self.buff, 1, 0, 0, 0, w, h, x, y, w, h)

end


function GUI.dh_Circle:val(newval)

	if newval then
		self.caption = newval
		self:init()
		self:redraw()
	else
		return self.caption
	end

end

-- 20250430 Added by dh
function GUI.dh_Circle:onmouseup()
--[[
	--self.state = 0

	-- If the mouse was released on the button, run func
	if GUI.IsInside(self, GUI.mouse.x, GUI.mouse.y) then

		self.func(table.unpack(self.params))

	end
	
	--self:redraw()
--]]
end


