-- NoIndex: true

-- dh_Graph.lua
-- Date: 20260506

---------------------------------------------------------------------
--[[ Draws a simple graph. ]] --
---------------------------------------------------------------------
-- Requires that Lokasenna_GUI v2 be loaded.

if not GUI then
	reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
	missing_lib = true
	return 0
end

---------------------------------------------------------------------
--  Creation parameters:
--	name, z, x, y, w, h[, data_points]
---------------------------------------------------------------------
GUI.dh_Graph = GUI.Element:new()

function GUI.dh_Graph:new(name, z, x, y, w, h, bw, rad)

	local graph = (not x and type(z) == "table") and z or {}

	graph.name = name
	graph.type = "dh_Graph"

	graph.z = graph.z or z

	graph.x = graph.x or x
    graph.y = graph.y or y
    graph.w = graph.w or GUI.dh_Graph.defaults.w
    graph.h = graph.h or GUI.dh_Graph.defaults.h
    
    graph.data_points = graph.data_points or GUI.dh_Graph.defaults.data_points
    graph.ref_points = graph.ref_points or GUI.dh_Graph.defaults.ref_points

    graph.grid_x_divs = graph.grid_x_divs or GUI.dh_Graph.defaults.grid_x_divs
    graph.grid_y_divs = graph.grid_y_divs or GUI.dh_Graph.defaults.grid_y_divs
    --graph.y_scale = graph.y_scale or GUI.dh_Graph.defaults.y_scale
    graph.y_min = graph.y_min or GUI.dh_Graph.defaults.y_min
    graph.y_max = graph.y_max or GUI.dh_Graph.defaults.y_max
    graph.y_ref = graph.y_ref or GUI.dh_Graph.defaults.y_ref

    graph.x_labels = graph.x_labels or GUI.dh_Graph.defaults.x_labels
    graph.y_labels = graph.y_labels or GUI.dh_Graph.defaults.y_labels

--zzcap	
	graph.caption = graph.caption or GUI.dh_Graph.defaults.caption
	graph.font_caption = graph.font_caption or GUI.dh_Graph.defaults.font_caption
	--graph.cap_pos = graph.cap_pos or GUI.dh_Graph.defaults.cap_pos
	graph.cap_pad_x = graph.cap_pad_x or GUI.dh_Graph.defaults.cap_pad_x
	graph.cap_pad_y = graph.cap_pad_y or GUI.dh_Graph.defaults.cap_pad_y
	graph.cap_centered = graph.cap_centered or GUI.dh_Graph.defaults.cap_centered
	
	graph.font_text = graph.font_text or GUI.dh_Graph.defaults.font_text
	graph.pad = graph.pad or GUI.dh_Graph.defaults.pad
	
    graph.shadow = graph.shadow or GUI.dh_Graph.defaults.shadow
    graph.shadow_caption = graph.shadow_caption or GUI.dh_Graph.defaults.shadow_caption

    graph.frame_use_outline = graph.frame_use_outline or GUI.dh_Graph.defaults.frame_use_outline	
    graph.frame_thk = graph.frame_thk or GUI.dh_Graph.defaults.frame_thk
    if graph.allow_sel_outline == nil then
        graph.allow_sel_outline = GUI.dh_Graph.defaults.allow_sel_outline
    end

----colors------------------------------------------------
    -- Caption
    graph.col_cap_text = graph.col_cap_text or GUI.dh_Graph.defaults.col_cap_text    
    
    -- Panel
	graph.col_bg = graph.col_bg or GUI.dh_Graph.defaults.col_bg   
	graph.col_frame = graph.frame or GUI.dh_Graph.defaults.col_frame   
	graph.col_text = graph.col_text or GUI.dh_Graph.defaults.col_text
	graph.col_backdrop = graph.col_backdrop or GUI.dh_Graph.defaults.col_backdrop    
---------------------------------------------------------- 

	GUI.redraw_z[graph.z] = true

	setmetatable(graph, self)
	self.__index = self
	return graph

end


GUI.dh_Graph.defaults = {
    w = 320,
    h = 120,
    
--zzz
    --data_points = {0,0,0,0,0,0,0,0,0,0,0},
    data_points = {},    
    ref_points = nil,
    
    grid_x_divs = 10,
    grid_y_divs = 8, 
    
    y_min = -12,
    y_max = 12,
    y_ref = 0,
    
    x_labels = {},
    y_labels = {},
    
    --y_scale = 8,
    
    shadow = false,	
	caption = "",
	font_caption = "sans22",    
	--cap_pos = "top",
    cap_pad_x = 4,
    cap_pad_y = 4,
	cap_centered = false,
	shadow_caption = false,

	font_text = "sans16",	
	pad = 4,
	
	frame_use_outline = false,
	frame_thk = 2,
	allow_sel_outline = false,

    col_bg = "black",
    col_frame = "elm_frame",
    col_text = "silver",
    col_cap_text = "txt", 
	col_backdrop = "wnd_bg",         	        
}

function GUI.dh_Graph:ondelete()
	GUI.FreeBuffer(self.buff)
end


function GUI.dh_Graph:init()

    local x, y, w, h = self.x, self.y, self.w, self.h

    local sd = self.shadow and GUI.shadow_dist or 0  -- shadow distance
    local sa = GUI.colors["shadow"][4]               -- shadow alpha
    
    -- In case element created before gfx opened.    
    if sa > 1 then sa = sa / 255 end
    
	self.buff = self.buff or GUI.GetBuffer()
	gfx.setimgdim(self.buff, -1, -1)
    gfx.setimgdim(self.buff, w + sd, h + sd)
    gfx.dest = self.buff
    
    -- # Draw shadow.
    
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
        gfx.rect(0, 0, w, h, 1)
       
    else    
       
        local ll_color, hl_color = DHTK.get_hilite_colors(self.col_backdrop)
    
        ---- # HIGHLIGHT bottom and right of track ----
        GUI.color(hl_color)
        gfx.rect(0, 0, w, h, 1)
    
        ---- # LOWLIGHT top and left of track ----
        GUI.color(ll_color)
        gfx.rect(0, 0, w - frm_thk, h - frm_thk, 1)
        
    end
    
    -- # Draw grid.
    
    local grid_x = frm_thk
    local grid_y = frm_thk
    local grid_w = w - (2 * frm_thk)
    local grid_h = h - (2 * frm_thk) 
    
    local y_ref = frm_thk + ((self.y_max - (self.y_ref or 0)) / (self.y_max - self.y_min)) * grid_h 
    
    local x_step = grid_w / self.grid_x_divs
    local y_step = grid_h / self.grid_y_divs
    
--zzz 
    -- These will be used for drawing graph.
    
    self.grid = {
      x = x + grid_x,
      y = y + grid_y,
      w = grid_w,
      h = grid_h,
      y_ref = y + y_ref,
      x_step = x_step,  
      y_step = y_step,  -- only needed for gridlines
    }
    
    -- # Draw box.
    
    --GUI.color(self.col_bg)
    GUI.color({0,0,0,1})    
    gfx.rect(grid_x, grid_y, grid_w, grid_h, 1)    

    GUI.color({0.4,0.4,0.4,1})

    -- # Vertical lines.
       
    for i = 1, self.grid_x_divs - 1 do
        local new_x = grid_x + (i * x_step)
        gfx.line(new_x, grid_y, new_x, grid_h + 1 )
    end
    
    -- # Horizontal lines.
        
    for i = 1, self.grid_y_divs -1 do
        local new_y = grid_y + (i * y_step)
        gfx.line(grid_x, new_y, grid_w + 1, new_y)
    end
    
    -- # Draw ref line.
    
    if self.y_ref then
        GUI.color({0.75,0.75,0.75,1})
        gfx.line(grid_x, y_ref, grid_w + 1, y_ref)
    end
    
    -- # Draw labels.
    
    --[[
    x_labels = {
      {1, "33"}, 
      {5, "196"}, 
      {8, "523"}, 
      {11, "1K"}, 
      {14, "2093"}, 
      {18, "5274"}, 
      {22, "10548"},
    }
    --]]
    
    if self.x_labels and (#self.x_labels > 0) then
    
        GUI.font(self.font_text)
        gfx.y = grid_h - gfx.texth --+ self.pad
    
        for _, label in ipairs(self.x_labels) do
        
            local str_w, str_h = gfx.measurestr(label[2])
 
            gfx.x = (grid_x + (label[1] * x_step)) - (str_w / 2)
            
            GUI.color(self.col_bg)
            gfx.rect(gfx.x, gfx.y, str_w, str_h, 1)
            
            GUI.color(self.col_text)
            gfx.drawstr(label[2])
                
        end
    
    end
    
    if self.y_labels and (#self.y_labels > 0) then
    
        GUI.font(self.font_text)
    
        for _, label in ipairs(self.y_labels) do

            local str_w, str_h = gfx.measurestr(label[2])
            
            gfx.x = grid_x + self.pad            
            gfx.y = (grid_y + (label[1] * y_step)) - (str_h / 2)
            
            GUI.color(self.col_bg)
            gfx.rect(gfx.x, gfx.y, str_w, str_h, 1)
                
            GUI.color(self.col_text)
            gfx.drawstr(label[2])
                
        end
    
    end

    -- # Draw reference graph.
    
    if self.ref_points then
        GUI.color({1,0.2,0.2,1})
        self:draw_graph(self.ref_points, grid_x, grid_y, y_ref, false)
    end
    
end


function GUI.dh_Graph:draw()
    --GUI.Msg("== dh_Graph:draw elmname is: " .. self.name .. " : width is: " .. self.w)

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
	    self:draw_caption() 
	end
	
	--GUI.Msg("\n== dh_Graph:draw : call draw_graph with blue ")
	
	GUI.color({0,1,1,1})
	self:draw_graph(self.data_points, self.grid.x, self.grid.y, self.grid.y_ref, true)
	
end


function GUI.dh_Graph:draw_graph(dataset, grid_x, grid_y, y_ref, draw_nodes)

    -- Starting point of graph line.
    gfx.x = grid_x    
    
    gfx.y = y_ref
    
    -- !!! Ensure no division by zero!    
    local range = (self.y_max - self.y_min)
    if range < 1 then range = 1 end        

    for i, val in ipairs(dataset) do
    
        -- Just to be safe.
        val = tonumber(val)
    
        --GUI.Msg("# draw_graph i : " .. i)    
        --GUI.Msg("   val : " .. val)
        --GUI.Msg("   type  val : " .. type(val))
                    
        local x_off = gfx.x + self.grid.x_step    
            
        -- Ensure val is in box. data_points are knob gain settings.
        --val = GUI.clamp(val, self.y_min, self.y_max)
        
        if val < self.y_min then val = self.y_min end
        if val > self.y_max then val = self.y_max end         
                                    
        local y_off = grid_y + ((self.y_max - val) / range) * self.grid.h 
        
        -- Draw a line to new position.
        gfx.lineto(x_off, y_off, 1)
        
        --GUI.Msg("data point : " .. tostring(i))             
        --GUI.Msg("gfx.x : " .. tostring(gfx.x))            
        --GUI.Msg("gfx.y : " .. tostring(gfx.y))     
        
        -- Draw a circle at node.
        
        if draw_nodes then
            gfx.circle(x_off, y_off, 3, 1, 1)
        end
        
    end
    
    -- gfx.x and gfx.y is at last data point position.
    -- Draw a line to right / ref.
    gfx.lineto(gfx.x + self.grid.x_step, y_ref, 1)

end


--zzcap
function GUI.dh_Graph:draw_caption()

    --GUI.Msg("dh_Panel:draw_caption self.cap_pad_x : " .. tostring(self.cap_pad_x))
    
    local caption = self.caption

    GUI.font(self.font_caption)

    local str_w, str_h = gfx.measurestr(caption)
    
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
 
--!!! This needs to be rewritten to display labels. 
 
function GUI.dh_Graph:draw_labels()

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


-- dh_Graph - Mouse up.
function GUI.dh_Graph:onmouseup()

    --self:redraw()

end