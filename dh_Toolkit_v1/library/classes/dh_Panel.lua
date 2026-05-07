-- NoIndex: true

-- dh_Panel.lua
-- Date: 20260506

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
     20251105 Added caption.
     20251219 Changed way text is drawn.
     20260204 Changed way panel is drawn.
--]]
---------------------------------------------------------------------
-- Requires that Lokasenna_GUI v2 be loaded.

if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end

---------------------------------------------------------------------
--  Creation parameters:
--	name, z, x, y, w, h[, bw, rad]
---------------------------------------------------------------------
GUI.dh_Panel = GUI.Element:new()

function GUI.dh_Panel:new(name, z, x, y, w, h, bw, rad)

	local panel = (not x and type(z) == "table") and z or {}

	panel.name = name
	panel.type = "dh_Panel"

	panel.z = panel.z or z

	panel.x = panel.x or x
    panel.y = panel.y or y
    panel.w = panel.w or GUI.dh_Panel.defaults.w
    panel.h = panel.h or GUI.dh_Panel.defaults.h
    
	panel.border_width = panel.border_width or bw or GUI.dh_Panel.defaults.border_width
	panel.radius = panel.radius or rad or GUI.dh_Panel.defaults.radius	

--zzcap	
	panel.caption = panel.caption or GUI.dh_Panel.defaults.caption
	panel.font_caption = panel.font_caption or GUI.dh_Panel.defaults.font_caption
	--panel.cap_pos = panel.cap_pos or GUI.dh_Panel.defaults.cap_pos
	panel.cap_pad_x = panel.cap_pad_x or GUI.dh_Panel.defaults.cap_pad_x
	panel.cap_pad_y = panel.cap_pad_y or GUI.dh_Panel.defaults.cap_pad_y
	panel.cap_centered = panel.cap_centered or GUI.dh_Panel.defaults.cap_centered
	
--zztext	
	-- Forcing a safe monospace font to make our lives easier
	panel.font_text = panel.font_text or GUI.dh_Panel.defaults.font_text
	panel.pad = panel.pad or GUI.dh_Panel.defaults.pad
	
	panel.text = panel.text or GUI.dh_Panel.defaults.text

	panel.line_height = panel.line_height or GUI.dh_Panel.defaults.line_height
	panel.use_pixels = panel.use_pixels or GUI.dh_Panel.defaults.use_pixels
	panel.line_height_pixels = panel.line_height_pixels or GUI.dh_Panel.defaults.line_height_pixels
	
    panel.shadow = panel.shadow or GUI.dh_Panel.defaults.shadow
    panel.shadow_caption = panel.shadow_caption or GUI.dh_Panel.defaults.shadow_caption

----colors------------------------------------------------
    -- Caption
    panel.col_cap_text = panel.col_cap_text or GUI.dh_Panel.defaults.col_cap_text    
    
    -- Panel
	panel.col_bg = panel.col_bg or GUI.dh_Panel.defaults.col_bg    
	panel.col_border = panel.col_border or GUI.dh_Panel.defaults.col_border
	panel.col_text = panel.col_text or GUI.dh_Panel.defaults.col_text
	panel.col_backdrop = panel.col_backdrop or GUI.dh_Panel.defaults.col_backdrop    
---------------------------------------------------------- 
        
	panel.func = panel.func or GUI.dh_Panel.defaults.func
	panel.params = panel.params or GUI.dh_Panel.defaults.params   

	GUI.redraw_z[panel.z] = true

	setmetatable(panel, self)
	self.__index = self
	return panel

end

GUI.dh_Panel.defaults = {
    w = 128,
    h = 128,
    border_width = 2,
    radius = 0,
    shadow = false,	
    
	caption = "",
	font_caption = "sans22",    
	--cap_pos = "top",
    cap_pad_x = 4,
    cap_pad_y = 4,
	cap_centered = false,
	shadow_caption = false,

	text = nil,    
	font_text = "mono16",	
	pad = 4,
	
    line_height = 1.25,	
    use_pixels = false,
    line_height_pixels = 24,
	
    func = function () end,
    params = {...},

    col_bg = "wnd_bg",
    col_border = "panel_border",
    col_text = "txt",
    col_cap_text = "txt", 
	col_backdrop = "wnd_bg",         	        
}


function GUI.dh_Panel:init()

    -- gfx.roundrect adds 1px to x and y. Compensate.
    -- GUI.roundrect yields undesirable results when using alpha (shadow), 
    --   overlapping draws compound alpha.
    -- Radius is to inside of border.

    local x, y, w, h = self.x, self.y, self.w, self.h
    local bw = self.border_width
    local rad = self.radius  -- radius of bg rectangle.
    local sd = self.shadow and GUI.shadow_dist or 0
    local sa = GUI.colors["shadow"][4]
    -- In case element created before gfx opened.    
    if sa > 1 then sa = sa / 255 end
    
	self.buff = self.buff or GUI.GetBuffer()
	gfx.setimgdim(self.buff, -1, -1)
    gfx.setimgdim(self.buff, w + sd, h + sd)
    gfx.dest = self.buff
    
    -- Draw backdrop for better antialiasing of roundrect.
    if rad > 0 then

        GUI.color(self.col_backdrop)
        gfx.rect(0, 0, w + sd, h + sd)
           
    end

    -- # If no border then no shadow. Draw only bg then return.
    
    if bw == 0 then

        GUI.color(self.col_bg)
        
        if rad > 0 then
            GUI.roundrect(0, 0, w - 1, h - 1, rad, 1, 1)
        else
            gfx.rect(0, 0, w, h, 1)
        end
        
        return
    end
    
    ---- Has a border ----
    
    -- # Draw outer shadow.
--zzsh
    -- Temporary buffer for drawing shadow.
    local sh_buff

    if self.shadow then

        if rad > 0 then
        
            if self.shadow then
                sh_buff = sh_buff or GUI.GetBuffer()
                gfx.setimgdim(sh_buff, -1, -1)
                gfx.setimgdim(sh_buff, w, h)
            end

            gfx.dest = sh_buff
            
            -- Draw shadow shape opaque.    
            GUI.color("black")
            GUI.roundrect(0, 0, w - 1, h - 1, rad + bw + sd + 1, 1, 1)
                                    
            -- Then lighten whole buffer.
            gfx.muladdrect(0, 0, w, h, 1, 1, 1, sa, 0, 0, 0, 0 )     
            
            --# Blit shadow to main buffer.
            gfx.dest = self.buff
            gfx.blit(sh_buff, 1, 0, 0, 0, w, h, sd, sd)        

        else
            
            GUI.color(GUI.colors["shadow"])
            gfx.rect(sd, sd, w, h, 1)

        end

    end
    
    -- # Draw border

    GUI.color(self.col_border)
    
    -- rad is to inside of border.
    if rad > 0 then
        GUI.roundrect(0, 0, w - 1, h - 1, rad + bw, 1, 1)
    else
        gfx.rect(0, 0, w, h, 1)
    end
    
    -- # Draw background
    
    GUI.color(self.col_bg)

    if rad > 0 then
        GUI.roundrect(bw, bw, w - ((2 * bw)) - 1, h - ((2 * bw)) - 1, rad, 1, 1)
    else
        gfx.rect(bw, bw, w - ((2 * bw)), h - ((2 * bw)), 1)
    end	            

    -- # Draw inner shadow.    

    if self.shadow then
    
        if rad > 0 then
    
            -- Reinitialize shadow buffer.
            gfx.setimgdim(sh_buff, -1, -1)
            gfx.setimgdim(sh_buff, w, h)        
            gfx.dest = sh_buff
        
            -- Draw shadow shape opaque.    
            GUI.color("black")
            GUI.roundrect(0, 0, w - (2 * bw) - 1, h - (2 * bw) - 1, rad, 1, 1) 
                   
            -- Then lighten whole buffer.
            gfx.muladdrect(0, 0, w - (2 * bw), h - (2 * bw), 1, 1, 1, sa, 0, 0, 0, 0 )     
        
            --# Blit shadow to main buffer
            gfx.dest = self.buff
            gfx.blit(sh_buff, 1, 0, 0, 0, w - (2 * bw), h - (2 * bw), bw, bw) 
                   
            -- Draw inner bg rectangle --   
            GUI.color(self.col_bg)
            GUI.roundrect(bw + sd, bw + sd, w - ((2 * bw) + sd) - 1, h - ((2 * bw) + sd) - 1, rad, 1, 1)            
        
        else
            GUI.color(GUI.colors["shadow"])
            gfx.rect(bw, bw, w - (2 * bw) , h - (2 * bw), 1)

            -- Draw inner bg rectangle --
            GUI.color(self.col_bg)
            gfx.rect(bw + sd, bw + sd, w - ((2 * bw) + sd), h - ((2 * bw) + sd), 1)
        
        end

    end
    
    --!!! IMPORTANT !
    if sh_buff then GUI.FreeBuffer(sh_buff) end

end


function GUI.dh_Panel:draw()
    --GUI.Msg("== dh_Panel:draw elmname is: " .. self.name .. " : width is: " .. self.w)

	local x, y, w, h = self.x, self.y, self.w, self.h
    local sd = self.shadow and GUI.shadow_dist or 0
	
	-- Expand for shadow.
	if self.shadow then
	    w = w + sd
	    h = h + sd
	end

	gfx.blit(self.buff, 1, 0, 0, 0, w, h, x, y)
	
	-- Draw the caption.
	if self.caption and self.caption ~= "" then 
	    self:drawcaption() 
	end
	
	-- Draw the text.
	--if self.text and self.text ~= "" then
	if self.text and (#self.text > 0) then	
	    self:drawtext()
	end
	
end

--zzcap
function GUI.dh_Panel:drawcaption()

    --GUI.Msg("dh_Panel:drawcaption self.cap_pad_x : " .. tostring(self.cap_pad_x))
    
    local caption = self.caption

    GUI.font(self.font_caption)

    local str_w, str_h = gfx.measurestr(caption)
    
--[=[ # Currently only using top position.
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
--]=]

    gfx.y = self.y - str_h - self.cap_pad_y

    if self.cap_centered then
        gfx.x = (self.x + (self.w - str_w) / 2) + self.cap_pad_x
    else
        gfx.x = self.x + self.cap_pad_x  
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

 --zztext
function GUI.dh_Panel:drawtext()

    --local str_arr = {}
     
    local str_arr = self.text
     
    --GUI.Msg("\n# text type : " .. type(str_arr))
    --GUI.Msg("  text size : " .. tostring(#str_arr))    
     
    if (type(str_arr) == "table") and (#str_arr > 0) then
    
        GUI.color(self.col_text)
        GUI.font(self.font_text)              
        
        local str_w, str_h = gfx.measurestr("M")
   	    local str_x = self.x + self.pad + self.border_width
   	    local str_y = self.y + self.pad        

        if self.use_pixels then
            str_h = self.line_height_pixels
        else    
            str_h = str_h * self.line_height
        end
        
        -- How many lines can fit vertically.        
        local disp_h = (self.h - 2 * (self.border_width + self.pad)) // str_h
        
        -- How many chars can fit left to right.
        --local line_w = (self.w - 2 * (self.border_width + self.pad)) // str_w
        
        -- Alt: use right, bottom.  
        local r = self.x + self.w - (self.border_width + self.pad)
        local b = str_y + str_h
        
        local ath = self.h - 2 * (self.border_width + self.pad)
        --GUI.Msg("available text height : " .. tostring(ath))
        --GUI.Msg("str_h : " .. tostring(str_h))
        --GUI.Msg("b     : " .. tostring(b))                             
          
        for i = 1, math.min(disp_h, #str_arr) do
         
    	   --local str = string.sub(str_arr[i], 1, line_w - 1)         
         
           gfx.x = str_x
           gfx.y = str_y
         
    	   --gfx.drawstr(str)
    	   gfx.drawstr(str_arr[i], 0, r, b)    	   
   	    
    	   str_y = str_y + str_h
    	   b = b + str_h
    	             
        end 
         
    end
             
--[==[

         local start_pos = 1
         local end_pos = 1
         local temp_str = ""
          
         local c_idx = 1
        
        while start_pos < #self.text do 
         
            end_pos = start_pos + line_w -1
            if end_pos > #text then end end_pos = #text
         
            temp_str = string.sub(text, start_pos, end_pos)
             
            table.insert(str_arr, temp_str)
          
            start_pos = end_pos + 1
        end        
        
    	for i = self.wnd_pos.y, math.min(self:wnd_bottom() - 1, #str_arr) do
    			
            gfx.x = str_x
    	    gfx.y = str_y
    	    
    	    local str = string.sub(str_arr[i], self.wnd_pos.x + 1, self:wnd_right() - 1)
    
    	    gfx.drawstr(str)
   	    
    	    str_y = str_y + str_h    	    
        	    
        end    
--]==]        

     
--[==[     
     if type(text) == "table" then
     
         str_arr = text
     
     -- 20260315: not implemented due to a conflict in GUI Builder.
     elseif type(text) == "string" then
     
         -- Comma separated string.
         -- Parse the string of options into a table
         local tempidx = 1
         for word in string.gmatch(self.text, '([^,]*)') do
             str_arr[tempidx] = word
             tempidx = tempidx + 1
         end

         --[=[
         -- How many chars can fit left to right.
         local line_w = (self.w - 2 * (self.border_width + self.pad)) / strw 
         
         local start_pos = 1
         local end_pos = 1
         local temp_str = ""
          
         local c_idx = 1
        
         while start_pos < #self.text do 
         
             end_pos = start_pos + line_w -1
             if end_pos > #text then end end_pos = #text
         
             temp_str = string.sub(text, start_pos, end_pos)
             
             table.insert(str_arr, temp_str)
          
             start_pos = end_pos + 1
         end
         --]=]
     else 
         return
     end
--]==]
         

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