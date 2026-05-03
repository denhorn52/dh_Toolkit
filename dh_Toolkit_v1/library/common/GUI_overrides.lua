--[[
    GUI_overrides.lua
    Modified by Dennis R. Horn 20260330
    
    My goal was to build dh_Toolkit without touching the Lokasenna GUI.
    There are several instances where the Lokasenna GUI has "deficiencies".
    This file is to override those "deficiencies".
    Ideally, the Lokasenna files should be updated.    
]]--

-- The Lokasenna text elements do not check if an element's drawing buffer already exist.
-- This caused a problem where dh_ThemeDesigner would crash due to running out of buffers to assign.
-- If you plan on using any of these make sure you load them before calling this or they won't be
-- updated. Currently this is the only way to update them.

if GUI.Listbox then
  function GUI.Listbox:init()

	-- If we were given a CSV, process it into a table
	if type(self.list) == "string" then self.list = self:CSVtotable(self.list) end

	local x, y, w, h = self.x, self.y, self.w, self.h

	--self.buff = GUI.GetBuffer()
	self.buff = self.buff or GUI.GetBuffer()	

	gfx.dest = self.buff
	gfx.setimgdim(self.buff, -1, -1)
	gfx.setimgdim(self.buff, w, h)

	GUI.color(self.bg)
	gfx.rect(0, 0, w, h, 1)

	GUI.color("elm_frame")
	gfx.rect(0, 0, w, h, 0)

  end
end

if GUI.Menubox then
  function GUI.Menubox:init()
    local w, h = self.w, self.h

    --self.buff = GUI.GetBuffer()
	self.buff = self.buff or GUI.GetBuffer()	    

    gfx.dest = self.buff
    gfx.setimgdim(self.buff, -1, -1)
    gfx.setimgdim(self.buff, 2*w + 4, 2*h + 4)

    self:drawframe()

    if not self.noarrow then self:drawarrow() end

  end
end

if GUI.Textbox then
  function GUI.Textbox:init()
	local x, y, w, h = self.x, self.y, self.w, self.h

	--self.buff = GUI.GetBuffer()
	self.buff = self.buff or GUI.GetBuffer()	    	

	gfx.dest = self.buff
	gfx.setimgdim(self.buff, -1, -1)
	gfx.setimgdim(self.buff, 2*w, h)

	GUI.color("elm_bg")
	gfx.rect(0, 0, 2*w, h, 1)

	GUI.color("elm_frame")
	gfx.rect(0, 0, w, h, 0)

	GUI.color("elm_fill")
	gfx.rect(w, 0, w, h, 0)
	gfx.rect(w + 1, 1, w - 2, h - 2, 0)

    -- Make sure we calculate this ASAP to avoid errors with
    -- dynamically-generated textboxes
    if gfx.w > 0 then self:wnd_recalc() end

  end
end

if GUI.TextEditor then
  function GUI.TextEditor:init()
	-- Process the initial string; split it into a table by line
	if type(self.retval) == "string" then self:val(self.retval) end

	local x, y, w, h = self.x, self.y, self.w, self.h

	--self.buff = GUI.GetBuffer()
	self.buff = self.buff or GUI.GetBuffer()	    		

	gfx.dest = self.buff
	gfx.setimgdim(self.buff, -1, -1)
	gfx.setimgdim(self.buff, 2*w, h)
    --GUI.Msg("GUI.TextEditor:init buffer set ")
	GUI.color(self.bg)
	gfx.rect(0, 0, 2*w, h, 1)

	GUI.color("elm_frame")
	gfx.rect(0, 0, w, h, 0)

	GUI.color("elm_fill")
	gfx.rect(w, 0, w, h, 0)
	gfx.rect(w + 1, 1, w - 2, h - 2, 0)

  end
end

-- GUI.GetBuffer first tries to get a buffer from GUI.freed_buffers.
-- If none then will assign a buffer number counting down from 1023 to GUI.z_max + 1.
-- This doesn't make sense to me as the buffer number should have no relationship to GUI.z_max.
-- If a script requires, say, 40 buffers, and has an element with a z-layer of 1000 
-- it will crash due to a lack of buffers.

GUI.GetBuffer = function (num)

    local ret = {}

    for i = 1, (num or 1) do

        --GUI.Msg(" >>> #GUI.freed_buffers : " .. tostring(#GUI.freed_buffers))
        --GUI.Msg("GUI.GetBuffer override")

        if #GUI.freed_buffers > 0 then

            ret[i] = table.remove(GUI.freed_buffers)
            
            --GUI.Msg(" >>> GUI.GetBuffer : get from GUI.freed_buffers ") 

        else
        
            --GUI.Msg(" >>> GUI.GetBuffer : assign new buffers ")

            --for j = 1023, GUI.z_max + 1, -1 do
            for j = 1023, 1, -1 do            

                if not GUI.buffers[j] then
                    ret[i] = j

                    GUI.buffers[j] = true
                    
                    goto skip
                end

            end

            -- Something bad happened, probably my fault
            --GUI.error_message = "Couldn't get a new graphics buffer - buffer would overlap element space. z = " .. GUI.z_max
            GUI.error_message = "Couldn't get a new graphics buffer. Exceeded 1023 buffers."

            ::skip::
        end

        --GUI.Msg(" >>> GUI.GetBuffer new buffer no : " .. tostring(ret[i]))

    end

    return (#ret == 1) and ret[1] or ret

end












