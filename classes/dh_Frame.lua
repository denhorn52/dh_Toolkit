-- NoIndex: true

-- dh_Frame.lua
-- Modified: 20250405

--[[ Customized Lokasenna_GUI element (by Dennis Horn) 2025-03-10.
     https://github.com/jalovatt/Lokasenna_GUI/wiki/TextEditor
     
     Draws a frame with optional border, fill, or rounded.
     
--]]

if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end

GUI.dh_Frame = GUI.Element:new()

function GUI.dh_Frame:new(name, z, x, y, w, h, bdr, rad, ...)

	local frame = (not x and type(z) == "table") and z or {}
	frame = (not x and type(z) == "table") and z or {}

	frame.name = name
	frame.type = "dh_Frame"

	frame.z = frame.z or z

	frame.x = frame.x or x
    frame.y = frame.y or y
    frame.w = frame.w or w
    frame.h = frame.h or h

	frame.border_width = frame.border_width or bdr or 0
	frame.radius = frame.radius or rad or 0
	
	frame.fill = frame.fill or false
	
	frame.col_border = frame.col_border or "elm_frame"
	frame.col_fill = frame.col_fill or "elm_fill"

	GUI.redraw_z[frame.z] = true

	setmetatable(frame, self)
	self.__index = self
	return frame

end


function GUI.dh_Frame:init()

    local x, y, w, h = self.x, self.y, self.w, self.h

	self.buff = self.buff or GUI.GetBuffer()

	gfx.dest = self.buff
	gfx.setimgdim(self.buff, -1, -1)
	gfx.setimgdim(self.buff, 2 * w, h)

	--if x or y is 0 then element won't dynamically scale.
	--if x == 0 then x = 1 end
	--if y == 0 then y = 1 end
	
	local rad = self.radius
	local fill = self.fill
	
    if fill == false then fill = 0 end
    if fill == true then fill = 1 end
    
    --dh_log("**** dh_Frame.init ready to draw outer rectangle ****\n")
    --dh_log("> dh_Frame.init elm z is: " .. self.z .. "\n")
    --dh_log("> dh_Frame.init elmname is: " .. self.name .. " : width is: " .. w ..  "\n")
    --dh_log("> dh_Frame.init elm radius is: " .. rad .. "\n")
    	
	-- Draw one design size rectangle --
	
	GUI.color(self.col_border)
	
	if rad > 0 then
        GUI.roundrect(0, 0, w, h, rad, 1, fill)
    else
        gfx.rect(0, 0, w, h, 1)
    end
    
    -- If border draw a second smaller rectangle --
        
    local bw = self.border_width
	if bw > 0 then
	    --dh_log("** dh_Frame.init bw is: " .. tostring(bw) .. "\n")
        --rad = rad - bw
        --if rad < 0 then rad = 0
        --dh_log("** GUI.color(self.col_fill)\n")
	    GUI.color(self.col_fill)
	    
	    if rad > 0 then
	        GUI.roundrect(bw, bw, w - (2 * bw), h - (2 * bw), rad, 1, fill)
	    else
	        gfx.rect(bw, bw, w - (2 * bw), h - (2 * bw), 1)
	    end
	    	    
    end
    
    --[[
	local r, g, b, a = table.unpack(GUI.colors["shadow"])
	gfx.set(r, g, b, 1)
	GUI.roundrect(self.w + 2, 1, self.w, self.h, 4, 1, 1)
	gfx.muladdrect(self.w + 2, 1, self.w + 2, self.h + 2, 1, 1, 1, a, 0, 0, 0, 0 )
    --]]

end

function GUI.dh_Frame:draw()
    --dh_log("== dh_Frame:draw elmname is: " .. self.name .. " : width is: " .. self.w ..  " <568>\n")

	local x, y, w, h = self.x, self.y, self.w, self.h

	gfx.blit(self.buff, 1, 0, 0, 0, w, h, x, y)
	
	--[[
	local state = self.state

	-- Draw the shadow if not pressed
	if state == 0 then
		for i = 1, GUI.shadow_dist do
			gfx.blit(self.buff, 1, 0, w + 2, 0, w + 2, h + 2, x + i - 1, y + i - 1)
		end
	end
    --]]
    
    -- src, scale, rot, srcx, srcy, srcw, srch, destx, desty, destw, desth, rotxoffs, rotyoffs)
	--gfx.blit(self.buff, 1,     0,   0,    0,    w + 2, h + 2, x + 2 * state - 1, y + 2 * state - 1)
	--gfx.blit(self.buff, 1, 0, 0, 0, w + 2, h + 2, x + 2 * state - 1, y + 2 * state - 1)
	--gfx.blit(self.buff, 1, 0, 0, 0, w, h, x + 2 * state - 1, y + 2 * state - 1)
	--gfx.blit(self.buff, 1, 0, 0, 0, w + 2, h + 2, x - 1, y - 1)
	--gfx.blit(self.buff, 1, 0, 0, 0, w, h, x, y)
    --gfx.blit(self.buff, 1, 0, 0, 0, self.w, self.h, self.x, self.y)
    --gfx.blit(self.buff, 1, 0, 0, 0, self.w, self.h, self.x, self.y, self.w, self.h)
end

function GUI.dh_Frame:ondelete()

	GUI.FreeBuffer(self.buff)
	
end

function GUI.dh_Frame:onmouseup()
    -- Code within is for testing purposes.
    --dh_log("** dh_Frame.onmouseup elmname is: " .. self.name .. " : width is: " .. self.w ..  "\n")
    --dh_log("> GUI.elms_hide\n")
    --for i = GUI.z_max, 0, -1 do
    --    if GUI.elms_list[i] and #GUI.elms_list[i] > 0 and GUI.elms_hide[i] then
    --        dh_log("    hidden z layer is: <" .. i .. ">\n")
    --    end
    --end
end

--[[
-- dh_Frame - Execute (extra method)
-- Used for allowing hotkeys to press a dh_Frame
function GUI.dh_Frame:exec(r)

	if r then
		self.r_func(table.unpack(self.r_params))
	else
		self.func(table.unpack(self.params))
	end

end
--]]