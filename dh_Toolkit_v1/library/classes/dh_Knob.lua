-- NoIndex: true

-- dh_Knob.lua
-- Date: 20260330

---------------------------------------------------------------------
-- Lokasenna_GUI - Knob class
--   For documentation, see this class's page on the project wiki:
--     https://github.com/jalovatt/Lokasenna_GUI/wiki/Knob
---------------------------------------------------------------------
--[[ Modified by Dennis Horn.

     Draws a knob with optional caption. Caption and knob values use the same background and text colors. 
     Changed some property names. Otherwise same as Lokasenna Knob.
     Added property "centered".
         if centered is false then x and y are to edges of knob.
         if centered is true then x and y are to center ob knob.
     Renamed property 'vals' to 'show_values'.
     20251219 added tick marks.
     20260106 added display box.
     20260204 display box defaults to highlighted frame.
     20260223 added properties for frame modification.
]]--

---------------------------------------------------------------------
if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end
---------------------------------------------------------------------
-- Creation parameters:
-- name, z, x, y, w, caption[, centered, min, max, default, inc, show_values, ...]
---------------------------------------------------------------------

GUI.dh_Knob = GUI.Element:new()
function GUI.dh_Knob:new(name, z, x, y, w, caption, centered, min, max, default, inc, show_values, ...)

	local Knob = (not x and type(z) == "table") and z or {}

	Knob.name = name
	Knob.type = "dh_Knob"

	Knob.z = Knob.z or z
	Knob.x = Knob.x or x
    Knob.y = Knob.y or y
    Knob.w = Knob.w or w or GUI.dh_Knob.defaults.w
    Knob.h = Knob.w
   
    if (Knob.centered == nil) and (centered == nil) then
        Knob.centered = true
    else
        Knob.centered = Knob.centered or centered 
    end        

    --GUI.Msg("\ndh_Knob:new Knob.centered is : " .. tostring(Knob.centered))
    --GUI.Msg("\ndh_Knob:new      centered is : " .. tostring(centered))    
   
    if Knob.centered == true then
        Knob.x = Knob.x - (Knob.w // 2)
        Knob.y = Knob.y - (Knob.w // 2)        
    end
    
    --GUI.Msg("    after adj:  x : " .. tostring(Knob.x) .. "; y : " .. tostring(Knob.y))

	Knob.min = Knob.min or min or GUI.dh_Knob.defaults.min
	Knob.max = Knob.max or max or GUI.dh_Knob.defaults.max
	Knob.default = Knob.default or default or GUI.dh_Knob.defaults.default

	Knob.inc = Knob.inc or inc or GUI.dh_Knob.defaults.inc	
	
    Knob.steps = math.abs(Knob.max - Knob.min) / Knob.inc
    
	function Knob:formatretval(val)
	
	local decimal = tonumber(string.match(val, "%.(.*)") or 0)
	local places = decimal ~= 0 and string.len( decimal) or 0
	return string.format("%." .. places .. "f", val)
	
	end
	
	-- Determine the step angle.
	-- Knob uses 2/3 of 360 deg.
	Knob.stepangle = (3 / 2) / Knob.steps
	
	Knob.curstep = Knob.default
	
	Knob.curval = Knob.curstep / Knob.steps
	
    Knob.retval = Knob:formatretval( ((Knob.max - Knob.min) / Knob.steps) * Knob.curstep + Knob.min )

-----------------------------------------

	Knob.knob_style = Knob.knob_style or GUI.dh_Knob.defaults.knob_style -- pointer, flange, simple

	Knob.caption = Knob.caption or caption or GUI.dh_Knob.defaults.caption
	Knob.cap_pos = Knob.cap_pos or GUI.dh_Knob.defaults.cap_pos  
	Knob.font_caption = Knob.font_caption or GUI.dh_Knob.defaults.font_caption
    Knob.cap_pad = Knob.cap_pad or GUI.dh_Knob.defaults.cap_pad
    
    Knob.show_values = Knob.show_values or show_values or GUI.dh_Knob.defaults.show_values
	Knob.font_values = Knob.font_values or GUI.dh_Knob.defaults.font_values
	-- Padding between knob/ticks and values.
	Knob.pad_values = Knob.pad_values or GUI.dh_Knob.defaults.pad_values
    	
	Knob.shadow_caption = Knob.shadow_caption or GUI.dh_Knob.defaults.shadow_caption
    
    if Knob.shadow == nil then 
        Knob.shadow = GUI.dh_Knob.defaults.shadow	
    end
    	
    Knob.frame_use_outline = Knob.frame_use_outline or GUI.dh_Knob.defaults.frame_use_outline
    
    Knob.frame_thk = Knob.frame_thk or GUI.dh_Knob.defaults.frame_thk
    
    if Knob.allow_sel_outline == nil then
        Knob.allow_sel_outline = GUI.dh_Knob.defaults.allow_sel_outline	
    end
    
----colors-------------------------------
    Knob.col_bg = Knob.col_bg or GUI.dh_Knob.defaults.col_bg
    Knob.col_outline = Knob.col_outline or GUI.dh_Knob.defaults.col_outline		
	Knob.col_body = Knob.col_body or GUI.dh_Knob.defaults.col_body  	
	--Knob.col_indicator = Knob.col_indicator or GUI.dh_Knob.defaults.col_indicator 
    
    Knob.col_cap_text = Knob.col_cap_text or GUI.dh_Knob.defaults.col_cap_text
	Knob.col_values = Knob.col_values or GUI.dh_Knob.defaults.col_values

	Knob.col_display_bg = Knob.col_display_bg or GUI.dh_Knob.defaults.col_display_bg
	Knob.col_display_text = Knob.col_display_text or GUI.dh_Knob.defaults.col_display_text
	Knob.col_frame = Knob.col_frame or GUI.dh_Knob.defaults.col_frame
		
	Knob.col_active = Knob.col_active or GUI.dh_Knob.defaults.col_active	
-----------------------------------------

--zztickmarks  

    Knob.show_tickmarks = Knob.show_tickmarks or GUI.dh_Knob.defaults.show_tickmarks
    
    -- tickmark_steps should have some correspondence to knob.steps.
    -- Say, knob.steps is 100, tickmark_steps can be 10.
    Knob.tickmark_steps = Knob.tickmark_steps or GUI.dh_Knob.defaults.tickmark_steps
    
    Knob.tickangle = (3 / 2) / Knob.tickmark_steps
    
    Knob.tickmark_size = Knob.tickmark_size or GUI.dh_Knob.defaults.tickmark_size
    
    -- gap between values and ticks.	
    Knob.pad_ticks = Knob.pad_ticks or GUI.dh_Knob.defaults.pad_ticks	
    
    -- If show_tickmarks some ticks may be displayed more prominently.
    Knob.hard_ticks = Knob.hard_ticks or GUI.dh_Knob.defaults.hard_ticks
    Knob.hard_tick_size = Knob.hard_tick_size or GUI.dh_Knob.defaults.hard_tick_size
    Knob.hard_tick_thk = Knob.hard_tick_thk or GUI.dh_Knob.defaults.hard_tick_thk
    
--zzmin_max    
    
    Knob.show_min_max = Knob.show_min_max or GUI.dh_Knob.defaults.show_min_max
    Knob.min_max_values = Knob.min_max_values or GUI.dh_Knob.defaults.min_max_values		

--zzdisplay 

    Knob.display_style = Knob.display_style or GUI.dh_Knob.defaults.display_style    -- none, box, plain   
    Knob.display_pos = Knob.display_pos or GUI.dh_Knob.defaults.display_pos         
    Knob.display_w = Knob.display_w or GUI.dh_Knob.defaults.display_w
    Knob.display_h = Knob.display_h or GUI.dh_Knob.defaults.display_h
    Knob.font_display = Knob.font_display or GUI.dh_Knob.defaults.font_display
    Knob.display_pad_x = Knob.display_pad_x or GUI.dh_Knob.defaults.display_pad_x
    Knob.display_pad_y = Knob.display_pad_y or GUI.dh_Knob.defaults.display_pad_y
    Knob.display_align = Knob.display_align or GUI.dh_Knob.defaults.display_align  -- left, center, right
    
	GUI.redraw_z[Knob.z] = true

	setmetatable(Knob, self)
	self.__index = self
	return Knob

end

GUI.dh_Knob.defaults = {
    w = 40,
    centered = true,
    knob_style = "pointer",
	min = 0,
	max = 10,
	default = 5,
	inc = 1,
	
	caption = "",
	font_caption = "sans22",
	cap_pos = "bottom",  
    cap_pad = 4,
    
    show_values = false,
	font_values = "sans18",
	pad_values = 4,

    shadow = true,	
	shadow_caption = false,
    frame_use_outline = false,
    frame_thk = 2,
    allow_sel_outline = false,
    
    show_tickmarks = false,        		    
    tickmark_steps = 10,    
    tickmark_size = 4,
    pad_ticks = 4,	
    hard_ticks = {0, 5, 10},
    hard_tick_size = 6,
    hard_tick_thk = false,
        
    show_min_max = false,
    min_max_values = {{0,"0"}, {5,"5"}, {10,"10"}},		
    
    display_style = "none",    -- none, box, plain   
    display_pos = "top",         
    display_w = 48,
    display_h = 24,
    font_display = "sans24",
    display_pad_x = 0,
    display_pad_y = 8,
    display_align = "center",  -- left, center, right
    
    col_bg = "wnd_bg",
    col_outline = "btn_outline",		
	col_body = "btn_face",  	
	--col_indicator = "txt", 
    col_cap_text = "txt",
	col_values = "txt",
	col_display_bg = "elm_bg",
	col_display_text = "elm_txt",
	col_frame = "elm_frame",
	col_active = "elm_active",    
}

-----------------------------------------
-- ####            INIT            ####
-----------------------------------------

function GUI.dh_Knob:init()

    --GUI.Msg("\n** GUI.dh_Knob:init : " .. self.name)
    --GUI.Msg("     knob style is : " .. self.knob_style)            
    --GUI.Msg("    centered is : " .. tostring(self.centered))
    --GUI.Msg("    centered type is : " .. tostring(type(self.centered)))        
    --GUI.Msg("    x : " .. tostring(self.x) .. "; y : " .. tostring(self.y))

    self.h = self.w
    
    ------------------------
    --##   zzbuffers   ##
    ------------------------
    -- Only need one buffer if no tickmarks or display is not box.
    -- Requires separate buffer space for shadow.    
    -- !!! Had an issue with GUI Builder, so instead of convoluted code
    -- I decided to just assign two buffers.
    
    --[=[
	if self.show_tickmarks or (self.display_style ~= "none") then
	    self.buffs = self.buffs or GUI.GetBuffer(2)
	else    
	    --self.buffs = self.buffs or GUI.GetBuffer(1)
	    if self.buffs then
	        self.buffs = self.buffs
	    else
	        self.buffs = {}
	        self.buffs[1] = GUI.GetBuffer(1)
	    end
	    
    end
    --]=]
    
    self.buffs = self.buffs or GUI.GetBuffer(2)
    
    local rad = self.w / 2
    local curangle = 0
    local bfw, ctr, sbfw, sctr     
 
    local sd = self.shadow and GUI.shadow_dist or 0
    local ll_color, hl_color, lum

    ------------------------------
      -- # DRAW KNOB (STYLE) --
    ------------------------------

    gfx.dest = self.buffs[1]
    gfx.setimgdim(self.buffs[1], -1, -1)
    
        -- # POINTER STYLE --

    if self.knob_style == "pointer" then
    
        --GUI.Msg("    # POINTER STYLE")

        local rp = rad * 1.5
        bfw = (2 * rp) + 4        
        self.buff_w = bfw
        ctr = rp + 1
        
        -- for shadow 1 + rad
        sbfw = self.w + 4        
        sctr = rad + 2
        
        -- Put shadow in right half of buffer.
        
        if self.shadow then
            gfx.setimgdim(self.buffs[1], bfw + sbfw, bfw)    
        else
            gfx.setimgdim(self.buffs[1], bfw, bfw)
        end 
        
        -- Figure out the points of the triangle
        
        local side_angle = (math.acos(0.666667) / GUI.pi) * 0.9
        
        local Ax, Ay = GUI.polar2cart(curangle, rp, ctr, ctr)
        local Bx, By = GUI.polar2cart(curangle + side_angle, rad - 1, ctr, ctr)
        local Cx, Cy = GUI.polar2cart(curangle - side_angle, rad - 1, ctr, ctr)
      
        -- Get the highlight/lowlight body colors.
        
        ll_color, hl_color, lum_body = DHTK.get_hilite_colors(self.col_body, true)
        
        -- Get the background and text luminance.
        -- Text by design should have good contrast with background.
        -- Although I don't necessarily want to use text for pointer,
        -- it can used for choosing hilite/lowlite.
        
        local tmp_color = GUI.colors[self.col_bg]
        local lum_bg = ( math.min(tmp_color[1], tmp_color[2], tmp_color[3]) + 
                         math.max(tmp_color[1], tmp_color[2], tmp_color[3]) ) / 2
        tmp_color = GUI.colors[self.col_values]
        local lum_txt = ( math.min(tmp_color[1], tmp_color[2], tmp_color[3]) + 
                         math.max(tmp_color[1], tmp_color[2], tmp_color[3]) ) / 2
        tmp_color = GUI.colors[self.col_body]                         

        --[=[                 
        if (self.name == "dh_Knob1") or (self.name == "dh_Knob4") then
            GUI.Msg("\n** GUI.dh_Knob:init : " .. self.name)
            GUI.Msg("    lum_body : " .. tostring(lum))
            GUI.Msg("      lum_bg : " .. tostring(lum_bg))
        end         
        --]=]
        
        local pointer_color
        local indicator_color = {}

        if lum_txt >= lum_bg then 
            -- lighten field, darken indicator
            pointer_color = hl_color

            -- darken/lighten by a factor.

            if lum_body < 0.50 then
                for i = 1, 3 do
                    indicator_color[i] = hl_color[i] * 1.15
                end
            else
                for i = 1, 3 do
                    indicator_color[i] = ll_color[i] * 0.90  
                end
                indicator_color[4] = 0.65           
            end   
                                      
        else
            -- darken field, lighten indicator  
            pointer_color = ll_color
            indicator_color = self.col_body  -- GOOD!            
        end 
       
        -- Pointer
         
        GUI.color(pointer_color)
        GUI.triangle(true, Ax, Ay, Bx, By, Cx, Cy)
        
        -- Indicator.
        
        GUI.color(indicator_color)
        gfx.rect(ctr + rad + 1, ctr - 1, rp - (rad + 2), 3, 1)        
        
        -- Pointer Outline
                        
        GUI.color(self.col_outline)
        GUI.triangle(false, Ax, Ay, Bx, By, Cx, Cy)
        GUI.triangle(false, Ax - 1, Ay, Bx - 1, By, Cx - 1, Cy)
                
        -- Body
        
        GUI.color(self.col_body)
        gfx.circle(ctr, ctr, rad - 2, 1, 1)

        -- Body Outline
             
        GUI.color(self.col_outline)
        --gfx.a = 0.25                    
        gfx.circle(ctr, ctr, rad, 0, 1) 
               
        --gfx.a = 1        
        GUI.color(self.col_outline)
        gfx.circle(ctr, ctr, rad - 1, 0, 1)
        
        -- Gradient
        
        -- Get hilites

        local body_color

        if lum_body > 0.5 then 
            -- darken 
            body_color = ll_color
        else
            -- lighten 
            body_color = hl_color
        end  
                
        local grad_size = self.w / 8
        local grad_step = 1 / grad_size        

        GUI.color(body_color)
        gfx.a = 1
        
        for i = 0, grad_size - 1 do
            --GUI.Msg("    gfx.a :  " .. tostring(gfx.a))
            gfx.circle(ctr, ctr, rad - (2 + i), 0, 1) 
            gfx.a = gfx.a - grad_step
            
        end         
        
        gfx.a = 1                

    elseif self.knob_style == "flange" then
    
        -- # FLANGE STYLE -- 

        --GUI.Msg("    # FLANGE STYLE")
--zzz
        bfw = self.w + 4
        self.buff_w = bfw
        ctr = rad + 1
        sctr = rad + 1
        
        -- Put shadow, highlights in right half of buffer.
        -- No shadow for flange?
        --if self.shadow then
        --    gfx.setimgdim(self.buffs[1], bfw + sbfw, bfw)    
        --else
            gfx.setimgdim(self.buffs[1], bfw, bfw)
        --end 
                                                    
        -- Flange
        
        GUI.color({0.2, 0.2, 0.2, 1})
        gfx.circle(ctr, ctr, rad, 1, 1)
        
        -- Highlight so it appears better on dark backgrounds.
        GUI.color({1, 1, 1, 0.50})
        gfx.circle(ctr, ctr, rad, 0, 1)        
        
        GUI.color({1, 1, 1, 0.25})
        gfx.circle(ctr, ctr, rad - 1, 0, 1) 
               
        GUI.color({1, 1, 1, 0.12})
        gfx.circle(ctr, ctr, rad - 2, 0, 1)        
        
        -- Body Outline
        
        GUI.color({0.55, 0.55, 0.55, 0.55})
        gfx.circle(ctr, ctr, rad * 0.60, 1, 1)
        
        GUI.color({0.85, 0.85, 0.85, 0.75})
        gfx.circle(ctr, ctr, rad * 0.60, 0, 1)

        -- Face
        
        GUI.color({0.75, 0.75, 0.75, 1})
        gfx.circle(ctr, ctr, rad * 0.45, 1, 1)
        
        GUI.color({0, 0, 0, 0.75})
        gfx.circle(ctr, ctr, rad * 0.45, 0, 1)
        
        -- Indicator.
        
        GUI.color("white")
        gfx.rect(ctr + rad * 0.7, ctr - 1, rad * 0.3, 3, 1)
        
    else

        -- # SIMPLE STYLE --

        --GUI.Msg("    # SIMPLE STYLE")
        
        bfw = self.w + 4  --2 * (rad + 1)  -- self.w + 2

        self.buff_w = bfw
--zzz
        ctr = rad + 1
        sctr = rad + 1
        
        -- for shadow 1 + rad
        sbfw = self.w + 4  --2 * (rad + 2)  -- self.w + 4
        sctr = rad + 2

        -- Put shadow in right half of buffer.

        if self.shadow then
            gfx.setimgdim(self.buffs[1], bfw + sbfw, bfw + sbfw)  
        else
            gfx.setimgdim(self.buffs[1], bfw, bfw)
        end

        -- Body

        GUI.color(self.col_body)
        gfx.circle(ctr, ctr, rad - 2, 1, 1)
        
        -- Outline
        
        GUI.color(self.col_outline)
        gfx.a = 0.25                    
        gfx.circle(ctr, ctr, rad, 0, 1) 
               
        gfx.a = 1        
        GUI.color(self.col_outline)
        gfx.circle(ctr, ctr, rad - 1, 0, 1)
--zzx
        -- Gradient

        local grad_size = self.w / 8
        local grad_step = 1 / grad_size        

        ll_color, hl_color, lum_body, sat = DHTK.get_hilite_colors(self.col_body, true)
        
        --[=[                 
        if (self.name == "dh_Knob3") or (self.name == "dh_Knob6") then
            GUI.Msg("\n** GUI.dh_Knob:init : " .. self.name)
            GUI.Msg("       lum : " .. tostring(lum))
            GUI.Msg("       sat : " .. tostring(sat))
            --GUI.Msg("       mll : " .. tostring(mll))                
            --GUI.Msg("       mhl : " .. tostring(mhl))
            GUI.Msg("    lum_bg : " .. tostring(lum_bg))
        end         
        --]=]        
            
        local body_color = {}
        
        if lum_body > 0.5 then 
            -- darken 
            body_color = ll_color
        else
            -- lighten 
            body_color = hl_color
        end

        GUI.color(body_color)
        gfx.a = 1
    
        for i = 0, grad_size - 1 do
            --GUI.Msg("    gfx.a :  " .. tostring(gfx.a))
            gfx.circle(ctr, ctr, rad - (2 + i), 0, 1) 
            gfx.a = gfx.a - grad_step
    
        end         

        -- Indicator.
        
        -- darken/lighten by a factor.

        if lum_body < 0.50 then
            for i = 1, 3 do
                body_color[i] = hl_color[i] * 1.15
            end
        else
            for i = 1, 3 do
                body_color[i] = ll_color[i] * 0.85  
            end
        end
        
        gfx.a = 1        

        GUI.color(body_color)        
        gfx.rect(ctr + rad * 0.1, ctr - 1, rad * 0.8, 3, 1)
                        
                
    end  -- <if self.knob_style>		

    ------------------------
    --##    zzshadow    ##
    ------------------------

    --if self.shadow and (self.knob_style == "simple") then
    if self.shadow then 
        GUI.color("shadow")
        gfx.circle(bfw + sctr, sctr, rad + 1 , 1, 1)
    end
     
    -------------------------
    --##   zztickmarks   ##	
    -------------------------
    
    self.tickspace = 0
    --GUI.Msg("    self.name : " .. self.name .. " : self.tickspace is : " .. tostring(self.tickspace))
    
    -- There will be no buffer to draw to anyhow.
    if not self.show_tickmarks and (self.display_style == "none") then 
         --self.tickspace = 0
         return
    end
    
    gfx.dest = self.buffs[2]
    gfx.setimgdim(self.buffs[2], -1, -1)
    
    if self.show_tickmarks then
        self.tickspace = self.w + (2 * self.pad_ticks) + (2 * math.max(self.tickmark_size, self.hard_tick_size))
    end
    
    --GUI.Msg("    self.tickspace : " .. tostring(self.tickspace))	

	local buff_w = self.tickspace + ((self.display_style ~= "none") and self.display_w or 0)
	local buff_h = math.max(self.tickspace, (self.display_style ~= "none") and self.display_h or 0)	
	
    --GUI.Msg("    buff_w : " .. tostring(buff_w))		
    --GUI.Msg("    buff_h : " .. tostring(buff_h))		
    	
    -- | tickspace | display_w |
    --gfx.setimgdim(self.buffs[2], buff_w, self.tickspace)	    
    gfx.setimgdim(self.buffs[2], buff_w, buff_h)	        
    
    --!!! May need to specify buff h.
    --    Using tickmark h below may cause issues on tight layouts.

	if self.show_tickmarks then
	
        --GUI.Msg("  > show_tickmarks : " .. tostring(self.show_tickmarks))
  	
    	-- # Background
    	
    	GUI.color(self.col_bg)
    	gfx.rect(0, 0, buff_w, self.tickspace)
        	
	    local ctr = {x = self.tickspace / 2, y = self.tickspace / 2}	    
	    
        --GUI.Msg("    ctr.x : " .. tostring(ctr.x) .. "; ctr.y : " .. tostring(ctr.y))	    

        rad = rad + self.pad_ticks        
        
        local ts = self.tickmark_size        
        
        -- # Draw normal ticks.
        	    
        --GUI.Msg("    #self.tickmark_steps : " .. tostring(self.tickmark_steps))
        
        GUI.color(self.col_values)
        
        for i = 0, self.tickmark_steps do
        
            local angle = (-5 / 4 ) + (i * self.tickangle)
    
            local cx, cy = GUI.polar2cart(angle, rad, ctr.x, ctr.y)
            local cx2, cy2 = GUI.polar2cart(angle, rad + ts, ctr.x, ctr.y)
            
            --GUI.Msg("    cx : " .. tostring(cx) .. " : cy : " .. tostring(cy))
            
            gfx.line(cx, cy, cx2, cy2, 1) 
        
        end
--zztick        
        -- # Draw Hard ticks.
        
        --GUI.Msg("\n    #hard_ticks : " .. tostring(#self.hard_ticks))
        
        ts = self.hard_tick_size - 1
        
        for _, ht in ipairs(self.hard_ticks) do
              
            --GUI.Msg("    hard_ticks type : " .. type(ht))
            --GUI.Msg("    hard_ticks val  : " .. tostring(ht))
            
            local angle = (-5 / 4 ) + (ht * self.tickangle)
            
            -- This will lengthen lines. OK.
            local cx, cy = GUI.polar2cart(angle, rad, ctr.x, ctr.y)
            local cx2, cy2 = GUI.polar2cart(angle, rad + ts, ctr.x, ctr.y)
            gfx.line(cx, cy, cx2, cy2, 1)
            
            -- Thicken lines. EXPERIMENTAL! Drawing over normal ticks will mess up antialiasing.
            if self.hard_tick_thk then
            
            --START        
            if (angle < -1.20) then cx, cx2 = cx - 1, cx2 - 1 end
            
            if (angle >= -1.20) and (angle < -1.10) then cx, cx2 = cx - 1, cx2 - 1 end 
            --if (angle >= -1.20) and (angle < -1.10) then cx, cx2, cy, cy2 = cx - 1, cx2 - 1, cy - 1, cy2 - 1 end
            
            if (angle >= -1.10) and (angle <= -0.90) then cy, cy2 = cy - 1, cy2 - 1 end
            
            if (angle > -0.90)and (angle < -0.80) then cx, cx2 = cx - 1, cx2 - 1 end         
                    
            if (angle >= -0.80) and (angle <= -0.70) then cx, cx2 = cx - 1, cx2 - 1 end
            
            if (angle > -0.70) and (angle < -0.60) then cx, cx2 = cx + 1, cx2 + 1 end        
            
            -- top
            if (angle >= -0.60) and (angle <= -0.40) then cx, cx2 = cx + 1, cx2 + 1 end 
            
            if (angle > -0.40) and (angle < -0.30) then cx, cx2 = cx + 1, cx2 + 1 end
             
            if (angle >= -0.30) and (angle <= 0.-20) then cx, cx2 = cx - 1, cx2 - 1 end                        
            
            if (angle > -0.20) and (angle < -0.10 ) then cx, cx2 = cx + 1, cx2 + 1 end         
            
            if (angle >= -0.10) and (angle <= 0.10) then cy, cy2 = cy - 1, cy2 - 1 end                
            
            if (angle > 0.10) and (angle <= 0.20) then cx, cx2 = cx + 1, cx2 + 1 end         
              
            if (angle > 0.20) then cx, cx2 = cx + 1, cx2 + 1 end 
            --END                                       
                        
            gfx.line(cx, cy, cx2, cy2, 1)
            
            end
            
            --[=[ 
            -- This gives satisfactory results. May use this.
            
            local ex, ex2, ey, ey2 = cx, cx2, cy, cy2
            
            -- Y
            if (angle < -0.65) or (angle > -0.30) then ey, ey2 = cy - 1, cy2 - 1 end        
            
            --X ranges: -
            if (angle < -1.20) then ex, ex2 = cx - 1, cx2 - 1 end
            
            --top
            if (angle > -0.80) and (angle < -0.40) then ex, ex2 = cx + 1, cx2 + 1 end
            
            if (angle >= -0.40) and (angle < -0.20) then ex, ex2 = cx - 1, cx2 - 1 end                         
            
            if (angle > 0.20) then ex, ex2 = cx + 1, cx2 + 1 end
            
            --GUI.Msg(" angle : " .. tostring(angle))
            --GUI.Msg("    " .. tostring(ht) .. " : ey : " .. tostring(ey))             
            
            gfx.line(ex, ey, ex2, ey2, 1)
            
            --]=]                
    	
        end

    end  -- <if self.show_tickmarks>
    
    -------------------------
    --##   zzdisplay   ##	
    -------------------------

    if self.display_style == "box" then
    
        local frm_thk = tonumber(self.frame_thk)

        -- In case I want to precalculate display position for later blitting.
        -- local x, y = self.x, self.y
        --GUI.Msg("    x : " .. tostring(x) .. "; y : " .. tostring(y))  
        
        if ((GUI.colors["metadata"]) 
            and (GUI.colors["metadata"][4] == 0)) 
            or self.frame_use_outline   
        then  
            --GUI.Msg(" KNOB display box use outline ")
            -- # use OUTLINE and outline color
            -- ??? thk outlines?

            GUI.color(self.col_frame)
            gfx.rect(self.tickspace, 0, self.display_w, self.display_h, 1)  
        
        else    

            ll_color, hl_color = DHTK.get_hilite_colors(self.col_bg)
    
            -- Draw hilite.
            GUI.color(hl_color)
            gfx.rect(self.tickspace, 0, self.display_w, self.display_h, 1)            
        
            -- Draw lowlite.
            GUI.color(ll_color)
            gfx.rect(self.tickspace, 0, self.display_w - frm_thk, self.display_h - frm_thk, 1)            
        
        end

        --GUI.Msg("    DRAW BOX : ")
        
        -- Draw box.
        GUI.color(self.col_display_bg)
        gfx.rect(self.tickspace + frm_thk, frm_thk, self.display_w - (2 * frm_thk), self.display_h - (2 * frm_thk), 1)    
    end 

end


function GUI.dh_Knob:ondelete()

	GUI.FreeBuffer(self.buffs)

end

------------------------------------
-------- Drawing methods -----------
------------------------------------
--zzdraw

function GUI.dh_Knob:draw()

    --GUI.Msg("\n## GUI.dh_Knob:draw : " .. self.name)
    --GUI.Msg("     self.tickspace : " .. tostring(self.tickspace))    

	local x, y, w, h = self.x, self.y, self.w, self.h  -- top-left of elm.
	
    --GUI.Msg("    x : " .. tostring(self.x) .. "; y : " .. tostring(self.y))

    -- Use for drawing values. Not used for blitting?
	local r = self.w / 2
	local o = {x = x + r, y = y + r}
	
	local buff_w, buff_h
	
	--if self.buffs[2] then	
	
	    --buff_w, buff_h = gfx.getimgdim(self.buffs[2])
        --GUI.Msg("    buff_w : " .. tostring(buff_w) .. "; buff_h : " .. tostring(buff_h))	

    --end
	
	-- Blit ticks
	
	if self.show_tickmarks then 
                   
        gfx.blit(   self.buffs[2], 1, 0,
                    0, 0, self.tickspace, self.tickspace,
                    o.x - (self.tickspace / 2), o.y - (self.tickspace / 2) + 1 )                    
	end
                    
--zzdisplay
    -- Draw display

	if self.display_style ~= "none" then self:draw_display(o, buff_w, buff_h) end  
                    
    -- Draw min_max
	if self.show_min_max then self:draw_min_max(o, r) end

	-- Draw value 
	--if self.show_values and not show_tickmarks then self:draw_values(o, r) end
	if self.show_values then self:draw_values(o, r) end
	
    -- Draw caption
    if self.caption and self.caption ~= "" then self:draw_caption(o, r) end
   
    -- Blit shadow
	buff_w, buff_h = gfx.getimgdim(self.buffs[1])
	
    --GUI.Msg(" >> buff_w : " .. tostring(buff_w) .. ";    buff_h : " .. tostring(buff_h))
    --GUI.Msg("  > self.w : " .. tostring(self.w))
    
--zzsh
	if self.shadow then

        --GUI.Msg("  > sbx : " .. tostring(sbx))
	    
	    gfx.blit( self.buffs[1], 1, 0, 
              self.buff_w, 0,
              self.w + 4, self.w + 4,
              x, y)            
	
	end

    -- Blit knob
    
	-- Figure out where the knob is pointing
	local curangle = (-5 / 4) + (self.curstep * self.stepangle)
	
	local blit_offset = (self.knob_style == "pointer") and ((self.buff_w - self.w) / 2 - 2) or 0
	
    gfx.blit( self.buffs[1], 1, curangle * GUI.pi,
              0, 0, 
              self.buff_w - 2, self.buff_w - 2,
              x - 1 - blit_offset, y - 1 - blit_offset)
              
	--GUI.Msg("\n## dh_Knob self.focus : " .. tostring(self.focus))              

    -- Focus            
	if self.focus then

		if self.allow_sel_outline then
		    GUI.Msg("\n## dh_Knob allow_sel_outline ## ")
    		GUI.color(self.col_active)
    	    --gfx.rect(x - 1, y - 1, w + 2, h + 2, 0)
    	    gfx.rect(x - 2, y - 2, w + 4, h + 4, 0)
    		-- Thicken highlight.
    	    --gfx.rect(x - 2, y - 2, w + 4, h + 4, 0)		
		end	
	
	end                

end

--zzdisplay  
function GUI.dh_Knob:draw_display(o, buff_w, buff_h)

    --GUI.Msg("\n## dh_Knob:draw_display ## ")

    local x,y,w,h = self.x, self.y, self.w, self.h
    
    --GUI.Msg("  elm.x : " .. tostring(x) .. "; elm.y : " .. tostring(y))
    --GUI.Msg("    o.x : " .. tostring(x) .. ";   o.y : " .. tostring(y))            

    local display_x, display_y
    
    if self.display_pos == "top" then
        --GUI.Msg("    TOP ")
        display_x = o.x - (self.display_w / 2) + self.display_pad_x
        display_y = y - (self.display_h + self.display_pad_y)
    
    elseif self.display_pos == "bottom" then
        --GUI.Msg("    BOTTOM ")    
        display_x = o.x - (self.display_w / 2) + self.display_pad_x
        display_y = y + h + self.display_pad_y
    
    elseif self.display_pos == "left" then
        --GUI.Msg("    LEFT ")    
        display_x = x - (self.display_w  + self.display_pad_x)
        display_y = o.y - (self.display_h / 2) + self.display_pad_y
    
    elseif self.display_pos == "right" then
        --GUI.Msg("    RIGHT ")    
        display_x = x + w + self.display_pad_x
        display_y = o.y - (self.display_h / 2) + self.display_pad_y
    
    end
    
    --GUI.Msg("    display_x : " .. tostring(display_x) .. " : display_y : " .. tostring(display_y))
    
    -- # Blit the display.
    
    if self.display_style == "box" then

        gfx.blit( self.buffs[2], 1, 0, 
                  self.tickspace, 0, 
                  self.display_w, self.display_h,
                  display_x, display_y)
              
    end
    
    -- # Draw display value  
       
    local output = tostring(self.retval)
    
    GUI.color(self.col_display_text)
    GUI.font(self.font_display)
    
    -- Adjustments: aligns to defined box.
    -- align: 0 = left, 1= center, 2 = right, 4 = center vert
   
    local align = (self.display_align == "left") and (0 + 4)
               or (self.display_align == "center") and (1 + 4)
               or  (2 + 4)  -- right
           
    if self.display_style == "plain" then
        -- 256 is ignore r, b
        align = align + 256
    end
     
    gfx.x = display_x + self.display_pad_x    
    gfx.y = display_y
    
    local r = display_x + self.display_w - self.display_pad_x      
    local b = display_y + self.display_h    
        
    --GUI.text_bg(output, self.col_cap_bg, align)
    
    gfx.drawstr(output, align, r, b)

end

--zzmm	
function GUI.dh_Knob:draw_min_max(o, r)

    GUI.font(self.font_values)
    GUI.color(self.col_values)
    

    -- {{0,"0"}, {6,"6"}, {12,"12"}}
    
    for _, data in ipairs(self.min_max_values) do
    
        local str_w, str_h = gfx.measurestr(data[2])
    
        local angle = (-5 / 4 ) + (data[1] * self.stepangle)        
        
        local ts = ((#self.hard_ticks > 0) and self.hard_tick_size or self.tickmark_size) + self.pad_values
        
        local cx, cy = GUI.polar2cart(angle, r + ts + 2, o.x, o.y)       
        
        -- Shift angle 0 to top for calcs.       		        
        local adj = math.cos((angle + 0.5) * GUI.pi)       		        
        gfx.y = cy - str_h/2 - (str_h * adj)/2 
        
        if angle < -0.51 then
            gfx.x = cx - (str_w + 2)
            
        elseif angle > -0.49 then
            gfx.x = cx + 2
        else
            gfx.x = cx - (str_w / 2)
        end	 

        --GUI.text_bg(str, self.col_bg)
        
        GUI.color(self.col_bg)
        gfx.rect(gfx.x, gfx.y, str_w, str_h, 1)    
 
        GUI.color(self.col_values)
        gfx.drawstr(tostring(data[2]), 256)
    
    end

end

--zzcap
function GUI.dh_Knob:draw_caption(o, r)

    local str = self.caption
    --local x, y, w, h = self.x, self.y, self.w, self.h

	GUI.font(self.font_caption)
	
    local str_w, str_h = gfx.measurestr(str)

	local cap_off = math.max(self.tickspace or 0, self.w)
			
	if self.cap_pos == "top" then
	
        gfx.x = o.x - str_w / 2
        gfx.y = o.y - ((cap_off / 2) + str_h + self.cap_pad)

    elseif self.cap_pos == "bottom" then

        gfx.x = o.x - str_w / 2
        gfx.y = o.y + ((cap_off / 2) + self.cap_pad)
        
    elseif self.cap_pos == "left" then
    
        gfx.x = o.x - ((cap_off / 2) + str_w + self.cap_pad)
        gfx.y = o.y - str_h / 2
    
    elseif self.cap_pos == "right" then
    
        gfx.x = o.x + ((cap_off / 2) + self.cap_pad)
        gfx.y = o.y - str_h / 2

	end
	
	GUI.color(self.col_bg)
	gfx.rect(gfx.x, gfx.y, str_w, str_h, 1)    
	
	--GUI.Msg("        gfx.x : " .. tostring(x))
	--GUI.Msg("        gfx.y : " .. tostring(y))  
	
	if self.shadow_caption then
	    GUI.shadow(str, self.col_cap_text, "shadow")
	else
	    GUI.color(self.col_cap_text)
	    gfx.drawstr(str)
	end

end

--zzval
function GUI.dh_Knob:draw_values(o, r)

    --GUI.Msg("\n** GUI.dh_Knob:draw_values **")
    
    -- Adjust radius
    
    --if self.pad_values then r = r + self.pad_values end
    
    local dist = r + self.pad_values
    --GUI.Msg("    dist is : " .. tostring(dist))
    
    if self.show_tickmarks then
    
        dist = dist + (((#self.hard_ticks > 0) and self.hard_tick_size or self.tickmark_size) + self.pad_ticks)	
        
    end
    --GUI.Msg("    dist is : " .. tostring(dist))    
    

    for i = 0, self.steps do

        local angle = (-5 / 4 ) + (i * self.stepangle)

        -- Highlight the current value
        if i == self.curstep then
            GUI.color(self.col_values)
            GUI.font({GUI.fonts[self.font_values][1], GUI.fonts[self.font_values][2] * 1.2, "b"})
        else
            GUI.color(self.col_values)
            GUI.font(self.font_values)
        end

        --local output = (i * self.inc) + self.min
        local output = self:formatretval( i * self.inc + self.min )

        if self.output then
            local t = type(self.output)
            if t == "string" or t == "number" then
                output = self.output
            elseif t == "table" then
                output = self.output[i + 1]                
            elseif t == "function" then
                output = self.output(output)
            end
        end

        -- Avoid any crashes from weird user data
        output = tostring(output)

        if output ~= "" then

            local str_w, str_h = gfx.measurestr(output)
            local cx, cy = GUI.polar2cart(angle, dist, o.x, o.y)
            gfx.x, gfx.y = cx - str_w / 2, cy - str_h / 2
            
            --GUI.text_bg(output, self.col_bg)
            
            GUI.color(self.col_bg)
            gfx.rect(gfx.x, gfx.y, str_w, str_h, 1)
                
            GUI.font(self.font_values)
            GUI.color(self.col_values)
            gfx.drawstr(output)
        end

    end

end

------------------------------------
-------- Mouse events -----------
------------------------------------

-- Knob - Get/set value
function GUI.dh_Knob:val(newval)

	if newval then

        self:setcurstep(newval)

		self:redraw()

	else
		return self.retval
	end

end

function GUI.dh_Knob:onmousedown()

    self.focus = true
    self:redraw()
end 


-- Knob - Dragging.
function GUI.dh_Knob:ondrag()

	local y = GUI.mouse.y
	local ly = GUI.mouse.ly

	-- Ctrl?
	local ctrl = GUI.mouse.cap&4==4

	-- Multiplier for how fast the knob turns. Higher = slower
	--					Ctrl	Normal
	local adj = ctrl and 1200 or 150

    self:setcurval( GUI.clamp(self.curval + ((ly - y) / adj), 0, 1) )
    
	self:redraw()

end


-- Knob - Doubleclick
function GUI.dh_Knob:ondoubleclick()

    self:setcurstep(self.default)

	self:redraw()

end

-- Knob - Mousewheel
function GUI.dh_Knob:onwheel()

	local ctrl = GUI.mouse.cap&4==4

	-- How many steps per wheel-step
	local fine = 1
	local coarse = math.max( GUI.round(self.steps / 30), 1)

	local adj = ctrl and fine or coarse

    self:setcurval( GUI.clamp( self.curval + (GUI.mouse.inc * adj / self.steps), 0, 1))

	self:redraw()

end

-- Make sure the box highlight goes away
function GUI.dh_Knob:lostfocus()

    if self.allow_sel_outline then
        self:redraw()
    end

end

------------------------------------
-------- Value helpers -------------
------------------------------------

function GUI.dh_Knob:setcurstep(step)

    self.curstep = step
    self.curval = self.curstep / self.steps
    self:setretval()

end


function GUI.dh_Knob:setcurval(val)

    self.curval = val
    self.curstep = GUI.round(val * self.steps)
    self:setretval()

end


function GUI.dh_Knob:setretval()

    self.retval = self:formatretval(self.inc * self.curstep + self.min)

end