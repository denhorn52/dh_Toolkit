-- NoIndex: true

-- dh_Slider_V.lua
-- Modified: 20260330

---------------------------------------------------------------------
-- Lokasenna_GUI - Slider class
--   For documentation, see this class's page on the project wiki:
--     https://github.com/jalovatt/Lokasenna_GUI/wiki/Slider
---------------------------------------------------------------------
--[[ Modified by Dennis Horn.

     Added ability to adjust track thickness and thumb sizes.
     2025-05-06 Changed properties font_a and font_b to font_caption and font_text, and bg to col_bg.
     2025-05-21 Changed property col_hnd to col_thumb.
     Note: gfx draws circle, hence roundrect, one pixel larger than design size. 
       A circle with radius of 9 will yield a diameter of 19; a radius of 10 will yield a diameter of 21.
     2026-01-01 Removed multiple handles. If needing multiple use dh_Slider_multi.     
                Renamed handle to thumbs.
     2026-01-06 Added integrated display. Made class 'vertical' only.  
                Renamed col_text to col_values.
     2026-01-16 Added highlighting for track and optional display.
     2026-02-04 Changed how slider is drawn.         
                Added col_backdrop to improve antialiasing for roundrect,
                captions, and for drawing frames.        
                                
--]]
---------------------------------------------------------------------
-- Requires that Lokasenna_GUI v2 be loaded.

if not GUI then
    reaper.ShowMessageBox("Couldn't access GUI functions.\n\nLokasenna_GUI - Core.lua must be loaded prior to any classes.", "Library Error", 0)
    missing_lib = true
    return 0
end
--zznew
---------------------------------------------------------------------
-- Creation parameters:
-- name, z, x, y, w, h, caption, min, max, default[, inc]
---------------------------------------------------------------------
GUI.dh_Slider_V = GUI.Element:new()

function GUI.dh_Slider_V:new(name, z, x, y, w, h, caption, min, max, default, inc)

    local Slider = (not x and type(z) == "table") and z or {}

    Slider.name = name
    Slider.type = "dh_Slider_V"

    Slider.z = Slider.z or z

    Slider.x = Slider.x or x
    Slider.y = Slider.y or y
    
    Slider.w = Slider.w or w or GUI.dh_Slider_V.defaults.w
    Slider.h = Slider.h or h or GUI.dh_Slider_V.defaults.h
  
    Slider.track_thk = Slider.track_thk or GUI.dh_Slider_V.defaults.track_thk
    if Slider.track_thk < 4 then Slider.track_thk = 4 end
    
    Slider.thumb_style = Slider.thumb_style or GUI.dh_Slider_V.defaults.thumb_style  -- ("none", "long", "wide" "square",)
    
    Slider.border_width = Slider.border_width or GUI.dh_Slider_V.defaults.border_width
    Slider.radius = Slider.radius or GUI.dh_Slider_V.defaults.radius 

    Slider.caption = Slider.caption or caption or GUI.dh_Slider_V.defaults.caption
    Slider.font_caption = Slider.font_caption or GUI.dh_Slider_V.defaults.font_caption  
    Slider.cap_pos = Slider.cap_pos or GUI.dh_Slider_V.defaults.cap_pos
    Slider.cap_pad_x = Slider.cap_pad_x or GUI.dh_Slider_V.defaults.cap_pad_x
    Slider.cap_pad_y = Slider.cap_pad_y or GUI.dh_Slider_V.defaults.cap_pad_y  
    Slider.cap_centered = Slider.cap_centered or GUI.dh_Slider_V.defaults.cap_centered

    Slider.show_values = Slider.show_values or false
    Slider.font_values = Slider.font_values or GUI.dh_Slider_V.defaults.font_values
    Slider.pad_values = Slider.pad_values or GUI.dh_Slider_V.defaults.pad_values
  
    Slider.shadow_caption = Slider.shadow_caption or false
    Slider.shadow = Slider.shadow or false

    Slider.frame_use_outline = Slider.frame_use_outline or false
    Slider.frame_thk = Slider.frame_thk or GUI.dh_Slider_V.defaults.frame_thk
    if Slider.allow_sel_outline == nil then
        Slider.allow_sel_outline = GUI.dh_Slider_V.defaults.allow_sel_outline  
    end

----colors-------------------------------------
    Slider.col_bg = Slider.col_bg or GUI.dh_Slider_V.defaults.col_bg
    Slider.col_border = Slider.col_border or GUI.dh_Slider_V.defaults.col_border  
    Slider.col_track = Slider.col_track or GUI.dh_Slider_V.defaults.col_track
    --Slider.col_track_outline = Slider.col_track_outline or "elm_frame" 
    Slider.col_frame = Slider.col_frame or GUI.dh_Slider_V.defaults.col_frame            
    Slider.col_fill = Slider.col_fill or GUI.dh_Slider_V.defaults.col_fill
    Slider.col_thumb = Slider.col_thumb or GUI.dh_Slider_V.defaults.col_thumb
    Slider.col_thumb_outline = Slider.col_thumb_outline or GUI.dh_Slider_V.defaults.col_thumb_outline  

    Slider.col_cap_text = Slider.col_cap_text or GUI.dh_Slider_V.defaults.col_cap_text

    Slider.col_values = Slider.col_values or GUI.dh_Slider_V.defaults.col_values

    Slider.col_display_bg = Slider.col_display_bg or GUI.dh_Slider_V.defaults.col_display_bg
    Slider.col_display_text = Slider.col_display_text or GUI.dh_Slider_V.defaults.col_display_text
    
    Slider.col_active = Slider.col_active or GUI.dh_Slider_V.defaults.col_active
    Slider.col_backdrop = Slider.col_backdrop or GUI.dh_Slider_V.defaults.col_backdrop
---------------------------------------------
  
    Slider.fill_from_default = Slider.fill_from_default or false  
  
    local min = Slider.min or min or GUI.dh_Slider_V.defaults.min
    local max = Slider.max or max or GUI.dh_Slider_V.defaults.max

    --GUI.Msg("  dh_Slider_V new : min : " .. tostring(min)) 
    --GUI.Msg("  dh_Slider_V new : max : " .. tostring(max)) 

    if min > max then
        min, max = max, min
    elseif min == max then
        max = max + 1
    end
    
    --GUI.Msg("2  dh_Slider_V new : min : " .. tostring(min)) 
    --GUI.Msg("2  dh_Slider_V new : max : " .. tostring(max))     

    Slider.min, Slider.max = min, max
    Slider.inc = Slider.inc or inc or GUI.dh_Slider_V.defaults.inc
    
    function Slider:formatretval(val)

       local decimal = tonumber(string.match(val, "%.(.*)") or 0)
          local places = decimal ~= 0 and string.len( decimal) or 0
          return string.format("%." .. places .. "f", val)

    end
    
    Slider.default = Slider.default or default or GUI.dh_Slider_V.defaults.default
    
    Slider.steps = math.abs(Slider.max - Slider.min) / Slider.inc        
        
    -- Make sure the default is valid
    
    Slider.default = math.floor( GUI.clamp(0, tonumber(Slider.default), Slider.steps) )
    
   
    Slider.curstep = Slider.default    -- Used throughout.
    Slider.curval = Slider.default / Slider.steps    -- Used by mouse events.
    -- Used in val.
    Slider.retval = Slider:formatretval( ((Slider.max - Slider.min) / Slider.steps) * Slider.default + Slider.min)
    
--zztickmarks

    -- Although tickmarks can be placed anywhere, 
    -- should endeavor to correspond them with inc.
    Slider.show_tickmarks = Slider.show_tickmarks or false
    Slider.tickmark_steps = Slider.tickmark_steps or GUI.dh_Slider_V.defaults.tickmark_steps
             
    Slider.show_default_tickmarks = Slider.show_default_tickmarks or false
    Slider.default_tickmarks = Slider.default_tickmarks or GUI.dh_Slider_V.defaults.default_tickmarks
    if type(Slider.default_tickmarks) == "number" then Slider.default_tickmarks = {Slider.default_tickmarks} end
    Slider.track_offset = Slider.track_offset or GUI.dh_Slider_V.defaults.track_offset
    Slider.tickmarks_offset = Slider.tickmarks_offset or GUI.dh_Slider_V.defaults.tickmarks_offset
    
--zzmin_max

	Slider.show_min_max = Slider.show_min_max or false
	Slider.min_max_values = Slider.min_max_values or GUI.dh_Slider_V.defaults.min_max_values		
--zzz
--zzdisplay

    Slider.display_style = Slider.display_style or GUI.dh_Slider_V.defaults.display_style  -- none, box, plain   
    Slider.display_pos = Slider.display_pos or GUI.dh_Slider_V.defaults.display_pos  -- top, bottom
    Slider.display_w = Slider.display_w or GUI.dh_Slider_V.defaults.display_w
    Slider.display_h = Slider.display_h or GUI.dh_Slider_V.defaults.display_h
    Slider.font_display = Slider.font_display or GUI.dh_Slider_V.defaults.font_display    
    Slider.display_pad_x = Slider.display_pad_x or GUI.dh_Slider_V.defaults.display_pad_x    
    Slider.display_pad_y = Slider.display_pad_y or GUI.dh_Slider_V.defaults.display_pad_y
    Slider.display_align = Slider.display_align or GUI.dh_Slider_V.defaults.display_align  -- left, center, right

    GUI.redraw_z[Slider.z] = true

    setmetatable(Slider, self)
    self.__index = self
    return Slider

end

GUI.dh_Slider_V.defaults = {
    w = 24,
    h = 128,
    track_thk = 8,
    thumb_style = "long",
    border_width = 0,
    radius = 4,
    
    caption = "",
    font_caption = "sans22", 
    cap_pos = "top",
    cap_pad_x = 4,
    cap_pad_y = 4,  
    cap_centered = false,

    show_values = false,
    font_values = "sans18",
    pad_values = 4,
    
    shadow_caption = false,
    shadow = false,

    frame_use_outline = false,
    frame_thk = 2,
    allow_sel_outline = false,  

    fill_from_default = false,  
    min = 0,
    max = 10,
    inc = 1,
    default = 5,
--zzz                  
    show_tickmarks = false,
    tickmark_steps = 10,
    show_default_tickmarks = false,
    default_tickmarks =  5, -- Integer ok; same as default
    track_offset = 0,
    tickmarks_offset = 0,
    
    show_min_max = false,
    min_max_values = {{0,"0"}, {5,"5"}, {10,"10"}},		
    
    display_style = "none",    -- none, box, plain   
    display_pos = "top",       -- top, right, integrated
    display_w = 48,
    display_h = 26,
    font_display = "sans24",    
    display_pad_x = 8,    
    display_pad_y = 8,    
    display_align = "center",  -- left, center, right

    col_bg = "wnd_bg",
    col_border = "panel_border",  
    col_track = "elm_bg",  
    --col_track_outline = "elm_frame",
    col_frame = "elm_frame",  
    col_fill = "track_fill",  
    col_thumb = "btn_face",
    col_thumb_outline = "btn_outline",  
    
    col_cap_text = "txt",
    
    col_values = "txt",
    
    col_display_bg = "elm_bg",
    col_display_text = "elm_txt",
    
    col_active = "elm_active",
    col_backdrop = "wnd_bg",

}

-----------------------------------------
-- ####            INIT            ####
-----------------------------------------
    
function GUI.dh_Slider_V:init()

    --GUI.Msg("\n##  dh_Slider_V:init  ##  self.name is : " .. tostring(self.name))

    --GUI.Msg("    self.w: " .. tostring(self.w))
    --GUI.Msg("    self.h: " .. tostring(self.h))

    local w, h, x, y = self.w, self.h, self.x, self.y

    local bw = self.border_width
    local rad = self.radius 
--zzsh
    local sd = self.shadow and GUI.shadow_dist or 0    
    local sa = GUI.colors["shadow"][4]
    -- In case gfx not open?
    if sa > 1 then sa = sa / 255 end
          
    ------------------------
    --##   zzbuffers   ##
    ------------------------
    
    self.buffs = self.buffs or GUI.GetBuffer(2)
          
    gfx.dest = self.buffs[1]
    gfx.setimgdim(self.buffs[1], -1, -1)
    
    local buff_w, buff_h
    
    if self.display_style ~= "none" then
        -- expand buffer to include display.
        -- was adding 1px border aound box, now included in box so the '+ 2' could be removed.
        buff_w = w + sd + self.display_w
        buff_h = math.max(h + sd, self.display_h)
    else
        buff_w = w + sd
        buff_h = h + sd
    end

    gfx.setimgdim(self.buffs[1], buff_w, buff_h)

    -------------------------
    --##    Draw Bezel   ##
    -------------------------
    -- gfx.roundrect adds 1px to x and y. Compensate.
    -- GUI.roundrect yields undesirable results when using alpha (shadow), 
    --   overlapping draws compound alpha.
    -- Radius is to inside of border.
    
    gfx.dest = self.buffs[1]        
    
    if rad > 0 then
    
        -- Draw backdrop for better antialiasing of roundrect.
        GUI.color(self.col_backdrop)
        gfx.rect(0, 0, w + sd, h + sd)
        
    end
    
    -- # If no border then no shadow. Draw only bg.
    
    if bw == 0 then
    
        GUI.color(self.col_bg)
        
        if rad > 0 then
            GUI.roundrect(0, 0, w - 1, h - 1, rad, 1, 1)
        else
            gfx.rect(0, 0, w, h, 1)
        end
        
        goto skipped
        
    end
    
    ---- Has a border ----

    -- # Draw outer shadow.

    if self.shadow then
    
        if rad > 0 then
        
            -- Create a temporary buffer to generate shadow.    
            local sh_buff = GUI.GetBuffer() 

            gfx.setimgdim(sh_buff, -1, -1)
            gfx.setimgdim(sh_buff, w, h) 
        
            gfx.dest = sh_buff            
            
            -- Draw shadow shape opaque.    
            GUI.color("black")
            GUI.roundrect(0, 0, w - 1, h - 1, rad + bw + sd, 1, 1) 
                       
            -- Then lighten whole buffer.
            gfx.muladdrect(0, 0, w, h, 1, 1, 1, sa, 0, 0, 0, 0 )     
            
            --# Blit shadow to main buffer.
            gfx.dest = self.buffs[1]
            gfx.blit(sh_buff, 1, 0, 0, 0, w, h, sd, sd)
                                    
            -- Done with temp buffer.
            GUI.FreeBuffer(sh_buff)                    
    
        else
            
            GUI.color(GUI.colors["shadow"])
            gfx.rect(sd, sd, w, h, 1)
    
        end
    
    end
    
    -- # Draw border
    
    GUI.color(self.col_border)
    
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
    	 
--[===[                       
    -- # Draw inner shadow.
        
    -- Not using inner shadow with sliders.                   
    -- If reinstituting be sure to move GUI.FreeBuffer(sh_buff) from above to below. 
        
    if self.shadow then
    
        if rad > 0 then
    
            -- Reinitialize shadow buffer.
            gfx.setimgdim(self.sh_buff, -1, -1)
            gfx.setimgdim(self.sh_buff, w, h)        
            gfx.dest = self.sh_buff
        
            -- Draw shadow shape opaque.    
            GUI.color("black")
            GUI.roundrect(0, 0, w - (2 * bw) - 1, h - (2 * bw) - 1, rad, 1, 1) 
                   
            -- Then lighten whole buffer.
            gfx.muladdrect(0, 0, w - (2 * bw), h - (2 * bw), 1, 1, 1, sa, 0, 0, 0, 0 )     
        
            --# Blit shadow to main buffer
            gfx.dest = self.buffs[1]
            gfx.blit(self.sh_buff, 1, 0, 0, 0, w - (2 * bw), h - (2 * bw), bw, bw) 
                   
            -- Draw inner bg rectangle --   
            GUI.color(self.col_bg)
            GUI.roundrect(bw + sd, bw + sd, w - ((2 * bw) + sd) - 1, h - ((2 * bw) + sd) - 1, rad, 1, 1)            
        
            -- Done with temp buffer.
            GUI.FreeBuffer(self.sh_buff)
        
        else
            GUI.color(GUI.colors["shadow"])
            gfx.rect(bw, bw, w - (2 * bw) , h - (2 * bw), 1)
    
            -- Draw inner bg rectangle --
            GUI.color(self.col_bg)
            gfx.rect(bw + sd, bw + sd, w - ((2 * bw) + sd), h - ((2 * bw) + sd), 1)
        end
    
    end
--]===]
    
    ::skipped::
     
    -----------------------------
    --##  Get Track Metrics  ##
    -----------------------------
    
    local thk = self.track_thk

    -- thumb base size, needed also to determine track_start.
    local hbase = thk * 1.5
    
    -- minimum size
    local min_thumb_size = 16 * DHTK.APP_SCALE
    if hbase < min_thumb_size then hbase  = min_thumb_size end
    
    -- Effective track representing track travel. 
    -- These will be used in mouse events.
    
    self.track_start = hbase + self.border_width + (thk // 2)
    self.track_length = h - (2 * self.track_start)
        
    -- Actual visual drawn track metrics.
    local ts = self.track_start
    local tl = self.track_length
    
    -- Track length including end caps.
    th = tl + thk

    --local toff_x = (w - thk) // 2  
    local toff_x = (w - thk) // 2 + self.track_offset 
    local toff_y = self.track_start - (thk // 2)
    
    --GUI.Msg("    track_start  : " .. tostring(self.track_start))    
    --GUI.Msg("    track_length : " .. tostring(self.track_length))
    
    ----------------------
    --##  zztickmarks  ##
    ---------------------- 
    
    if self.show_tickmarks then    
        
        GUI.color(self.col_values)    

        --local t1 = toff_x + thk + 2
        local t1 = toff_x + thk + 2 + self.tickmarks_offset        
        local t2 = math.min(w - (bw + 2), t1 + thk)        

        --GUI.Msg("  ticks t2  : " .. tostring(t2))
        
        for i = 0, self.tickmark_steps do
            -- Position along effective track.
            local pos = ts + (i * (tl / self.tickmark_steps))
            gfx.line(t1, pos, t2, pos)

        end

    end
    
    if self.show_default_tickmarks then
    
        if type(self.default_tickmarks) == "number" then
            self.default_tickmarks = {self.default_tickmarks}
        end    
    
        GUI.color(self.col_values)    
       
        for _, v in ipairs(self.default_tickmarks) do  
        
            -- Position along effective track.
            local pos = ts + (tonumber(v) * (tl / self.steps))

            gfx.line((bw + 1), pos, toff_x - (bw - 2), pos)
            gfx.line(toff_x + thk + 1, pos, w - (bw + 2), pos)
    
        end
    
    end
    
    --------------------
    --##  zztrack  ##
    --------------------

    local ll_color, hl_color
    local use_outline = false 

    if ((GUI.colors["metadata"]) 
       and (GUI.colors["metadata"][4] == 0)) 
       or self.frame_use_outline   
    then  
    
        -- # use OUTLINE and outline color
        use_outline = true
        --GUI.color(self.col_track_outline)
        GUI.color(self.col_frame)        
        gfx.rect(toff_x - 1, toff_y - 1, thk + 2, th + 2, 1)  
       
    else
    
        ll_color, hl_color = DHTK.get_hilite_colors(self.col_bg)
         
        ---- # HIGHLIGHT bottom and right of track ----
        GUI.color(hl_color)
        gfx.rect(toff_x - 1, toff_y - 1, thk + 2, th + 2, 1)
        
        ---- # LOWLIGHT top and left of track ----
        GUI.color(ll_color)
        gfx.rect(toff_x - 1, toff_y - 1, thk + 1, th + 1, 1)
        
    end
    
    ---- # track ----
    GUI.color(self.col_track)
    gfx.rect(toff_x, toff_y, thk, th, 1)   

    ----------------------
    -- ##  zzdisplay  ##
    ----------------------

    -- # Set offsets relative to elm to be used for drawing ops.
    --!!! Need to update for blitting / drawing display values.
    
    if self.display_style ~= "none" then
    
        self.display_x = (w // 2) - (self.display_w // 2)
    
        if self.display_pos == "top" then
            self.display_y = -(self.display_h + self.display_pad_y)
        else
            --GUI.Msg("    bottom: ") 
            self.display_y = h + self.display_pad_y
        end
    end
    
    if self.display_style == "box" then
    
        local frm_thk = tonumber(self.frame_thk)
    
        if use_outline then
        
            --GUI.color(self.col_track_outline)
            GUI.color(self.col_frame)            
            gfx.rect(w + sd, 0, self.display_w, self.display_h, 1)            
        
        else

            ll_color, hl_color = DHTK.get_hilite_colors(self.col_backdrop)
         
            ---- # HIGHLIGHT bottom and right of track ----    
            GUI.color(hl_color)
            gfx.rect(w + sd, 0, self.display_w, self.display_h, 1)            
         
            ---- # LOWLIGHT top and left of track ----    
            GUI.color(ll_color)
            gfx.rect(w + sd, 0, self.display_w - frm_thk, self.display_h - frm_thk, 1)            
            
        end

        -- #Draw box 
        GUI.color(self.col_display_bg)
        gfx.rect(w + sd + frm_thk, frm_thk, self.display_w - (2 * frm_thk), self.display_h - (2 * frm_thk), 1)            

    end
        
    -----------------------------------
    -- #  Draw Thumb  
    -----------------------------------

    if self.thumb_style == "none" then return end    
    
    -- !!! Need some minimums for thumb size,
    -- Wider than track, but narrower than bezel.
    
    if self.thumb_style == "long" then
        hw = hbase
        hh = hbase * 2
    elseif self.thumb_style == "wide" then
        hw = hbase * 1.5
        hh = hbase
    else 
        -- square   
        hw, hh = hbase, hbase
    end

    self.thumb_w, self.thumb_h = hw, hh 
    
    -- Increase shadow.
    sd = sd + 1 

--zzsh      
    -- buffer includes space for thumb and shadow.
    gfx.dest = self.buffs[2]
    gfx.setimgdim(self.buffs[2], -1, -1)
    --gfx.setimgdim(self.buffs[2], (hw + 1) + (hw + 1) +  * (hw + 1), hh + 1)    
    gfx.setimgdim(self.buffs[2], (hw + 1) + (hw + 2 + sd), (hh + 1 + sd))
    

    -- # Thumb shadow
    
    gfx.set(0,0,0,1)
    --GUI.roundrect(hw + 1, 0, hw + 2, hh + 2, 3, 1, 1)
    --GUI.roundrect(hw + 1, 0, hw + sd, hh + sd, sd + 1, 1, 1)        
    --gfx.muladdrect(hw + 1, 0, hw + (2 * sd), hh + sd, 1, 1, 1, 0.15, 0, 0, 0, 0 )
    GUI.roundrect(hw + 1, 0, (hw + 1 + sd), (hh + sd), sd + 1, 1, 1)        
    gfx.muladdrect(hw + 1, 0, (hw + 2 + sd), (hh + 1 + sd), 1, 1, 1, 0.15, 0, 0, 0, 0 )
    
    
    gfx.set(0,0,0,0.2)    
    gfx.rect(hw + 2, 1, hw + 1, hh, 1)    
    gfx.rect(hw + 3, 2, hw - 3, hh, 1)
    gfx.set(0,0,0,0.1)                
    gfx.rect(hw + 1, 3, 2, hh - 5, 1)         

    
    -- # Thumb

    local ll_color, hl_color, lum = DHTK.get_hilite_colors(self.col_thumb, true)   

    -- Face
    
    GUI.color(self.col_thumb)
    GUI.roundrect(0, 0, hw - 1, hh, 2, 1, 1)
    
    --if lum < 0.5 then
    --    GUI.color(hl_color)
    --    gfx.a = 0.5        
    --    gfx.rect(1, 1, hw - 2, hh - 1)
    --end
    
--zzthumb                         
    -- Outline        
    
    GUI.color(self.col_thumb_outline)
    GUI.roundrect(0, 0, hw - 1, hh, 2, 1, 0)


    if self.thumb_style == "long" then
    
        local dh = hh // 8       
    
        -- top end
        
        GUI.color(hl_color)
        gfx.a = 0.5
        
        gfx.line(1, dh - 3, hw - 2, dh - 3)                
        gfx.a = 0.75    
        gfx.line(1, dh - 2, hw - 2, dh - 2)
        gfx.a = 1
        gfx.line(1, dh - 1, hw - 2, dh - 1)
        
        -- top gradient
        
        --GUI.color(ll_color)
        
        local a_max                 

        if lum < 0.5 then    
            GUI.color(hl_color)
            a_max = 0.5 + (0.5 - lum)
        else
            GUI.color(ll_color)
            a_max = lum / 2
        end          
                
        gfx.a = a_max        
        --GUI.Msg("ll_col gfx.a : " .. tostring(gfx.a))                
        
        local gs = dh               -- gradient start
        local ge = (hh / 2) - 3     -- gradient end
        local gl = ge - gs          -- gradient length
        local a_adj = a_max / gl        
        
        for i = 0, gl - 1, 1 do
           --GUI.Msg("ll_col gfx.a : " .. tostring(gfx.a))                
           gfx.line(1, gs + i, hw - 2, gs + i)
           gfx.a = gfx.a - a_adj
        end
                
        -- bottom gradient        
        
        gs = hh / 2 + 2             -- gradient start
        ge = hh - dh      -- gradient end
        gl = ge - gs                -- gradient length
        
        gfx.a = a_adj 
        
        for i = 2, gl, 1 do
           --GUI.Msg("hl_col gfx.a : " .. tostring(gfx.a))        
           gfx.line(1, gs + i, hw - 2, gs + i)
           gfx.a = gfx.a + a_adj
        end
                
        -- bottom end
        
        GUI.color(hl_color)        
        gfx.a = 1
        gfx.line(1, hh - (dh - 1), hw - 2, hh - (dh - 1))
        gfx.a = 0.75    
        gfx.line(1, hh - (dh - 2), hw - 2, hh - (dh - 2))
        gfx.a = 0.5
        gfx.line(1, hh - (dh - 3), hw - 2, hh - (dh - 3))
        
        -- additional hilites        
--[=[                
        GUI.color(ll_color)                                
        gfx.a = 0.75         
        gfx.line(hw - 2, 4, hw - 2, hh - 4)        

        GUI.color(hl_color)                                
        gfx.a = 0.75         
        gfx.line(1, 4, 1, hh - 4)                    
--]=]

        GUI.color(hl_color)
        gfx.a = 0.5                 
        gfx.line(hw - 2, 4, hw - 2, hh - 4)        
        gfx.a = 0.75         
        gfx.line(1, 4, 1, hh - 4)                    



    else  -- wide
    
        --GUI.color(ll_color)
        --gfx.a = 0.25                
        --gfx.line( 1,      2, 1,      hh - 3)
        --gfx.line( hw - 1, 2, hw - 1, hh - 3)
          
        GUI.color(hl_color)                
        gfx.a = 0.8
        gfx.line( 1, 2,      hw - 2, 2)
        gfx.line( 1, hh - 2, hw - 2, hh - 2)

        gfx.a = 0.6        
        gfx.line( 1, 3,      hw - 2, 3)
        gfx.line( 1, hh - 3, hw - 2, hh - 3)
        
        gfx.a = 0.4        
        gfx.line( 1, 4,      hw - 2, 4)
        gfx.line( 1, hh - 4, hw - 2, hh - 4)                 
        
        gfx.a = 0.20        
        gfx.line( 1, 5,      hw - 2, 5)
        gfx.line( 1, hh - 5, hw - 2, hh - 5)

        -- additional hilites        

        GUI.color(ll_color)                                
        gfx.a = 0.5
        
        -- bottom                                                 
        gfx.line(2, hh - 1, hw - 3, hh - 1)
        
        -- right        
        gfx.line(hw - 2, 2, hw - 2, hh - 2)                                

        GUI.color(hl_color)                                
        gfx.a = 0.75
        
        --top                                                                 
        gfx.line(1, 2, 1, hh - 2)

        
    end       

    -- # Centerline
    
    --GUI.color(ll_color)
    GUI.color(self.col_values)        
    gfx.a = 1
    --gfx.line(2, hh / 2, hw - 3, hh / 2)
    gfx.line(2, hh / 2, hw - 3, hh / 2)        

end


function GUI.dh_Slider_V:ondelete()

    GUI.FreeBuffer(self.buffs)

end

------------------------------------
------------ Drawing  -----------
------------------------------------
--zzdraw
function GUI.dh_Slider_V:draw()

    --GUI.Msg("\n##  dh_Slider_V:DRAW  ## self.name is : " .. tostring(self.name))

    local x, y, w, h = self.x, self.y, self.w, self.h
    
    -- As specified in buffer.
    local sd = self.shadow and GUI.shadow_dist or 0
    
    --GUI.Msg("    self.x            : " .. tostring(x))
    --GUI.Msg("    self.y            : " .. tostring(y))
    --GUI.Msg("    self.w            : " .. tostring(w))
    --GUI.Msg("    self.h            : " .. tostring(h))            
     
    -- Blit panel and track.
    gfx.blit(self.buffs[1], 1, 0, 0, 0, w + sd, h + sd, x, y)    
        
    -- x,y,w,h are element metrics.
    -- Actual track has its own metrics.

    local ts = y + self.track_start

    --local tc = x + w / 2    -- track center
    local tc = (x + w / 2) + self.track_offset    -- track center
    
    local thk = self.track_thk
    local inc_px = self.track_length / self.steps

    -- Get thumb position along track, and coords.
    local pos = ts + (inc_px * self.curstep)
    self.thumb_x = tc - (self.thumb_w / 2)
    
    -- Need math.floor so thumb aligns with tickmarks.
    self.thumb_y = math.floor(pos - (self.thumb_h / 2))     
    --GUI.Msg("  thumb pos  : " .. tostring(pos))
    
    self:drawfill(ts, tc, thk, pos, inc_px)
    
    self:drawslider()
    
--zzmin_max    
    if self.show_min_max then self:draw_min_max(ts, inc_px) end
  
    if self.caption and self.caption ~= "" then self:drawcaption() end
    
    if self.display_style ~= "none" then self:drawdisplay() end    
    
	if self.focus then
	
		if self.allow_sel_outline then
    		GUI.color(self.col_active)
    	    gfx.rect(x - 2, y - 2, w + 4, h + 4, 0)
    		-- Thicken highlight.
    	    --gfx.rect(x - 2, y - 2, w + 4, h + 4, 0)		
		end	
	
	end    

end

--zzdisplay
 
function GUI.dh_Slider_V:drawdisplay()

    local x,y,w,h = self.x, self.y, self.w, self.h
    local display_x, display_y = x + self.display_x, y + self.display_y
    
--zzsh
    -- As specified in buffer.
    local sd = self.shadow and GUI.shadow_dist or 0
    
    -- # Blit the display.
             
    if (self.display_style == "box") then 
    
        gfx.blit(self.buffs[1], 1, 0, 
             w + sd, 0, 
             self.display_w, self.display_h, 
             display_x, display_y)
             
    end

    -- # Draw display value  
       
    local output = tostring(self.retval)
    
    GUI.color(self.col_display_text)
    
    -- Adjustments: aligns to defined box.
    -- align: 0 = left, 1= center, 2 = right, 4 = center vert
    
    local align = (self.display_align == "left") and (0 + 4)
               or (self.display_align == "center") and (1 + 4)
               or  (2 + 4)  -- right
               
    if self.display_style == "plain" then
        align = align + 256
    end
    
    gfx.x = display_x + 2  -- arbitrary text padding 
    gfx.y = display_y
        
    local r = display_x + self.display_w - 4
    local b = display_y + self.display_h
        
    -- color depends on where drawn.    
    --GUI.text_bg(output, self.col_backdrop, align)
    gfx.drawstr(output, align, r, b)    

end


function GUI.dh_Slider_V:drawfill(ts, tc, thk, pos, inc)

    local fill_start, fill_default, fill_length

    -- Get the color
    self:setfill()
    
    if self.fill_from_default then
        --GUI.Msg("\n#   fill from default")
        if self.curstep == self.default then return end            

        fill_default = ts + self.track_length - (inc * self.default)
        fill_default = GUI.round(fill_default)
        fill_length = math.abs(pos - fill_default) 
        fill_start = math.min(fill_default, pos)

    else   -- fill from start
        --GUI.Msg("\n#   fill from start")
        fill_start = pos
        fill_length = ts + self.track_length + (thk / 2) - fill_start
        
    end

    -- Set the color
    GUI.color(self.col_fill)    
    
    local offset = tc - (thk / 2) + 1
    
    -- Draw the fill.
    gfx.rect(offset, fill_start, thk - 1, fill_length, 1)   

end


function GUI.dh_Slider_V:setfill()

    -- If the user has given us two colors to make a gradient with
    if self.col_fill_a then

        -- Make a gradient,
        local col_a = GUI.colors[self.col_fill_a]
        local col_b = GUI.colors[self.col_fill_b]
        local grad_step = self.curstep / self.steps

        local r, g, b, a = GUI.gradient(col_a, col_b, grad_step)

        gfx.set(r, g, b, a)

    else
        GUI.color(self.col_fill)
    end

end


function GUI.dh_Slider_V:drawslider()

    --GUI.Msg("\n##  dh_Slider_V:drawslider ##")

    GUI.color(self.col_values)
    GUI.font(self.font_values)

    local thumb_x, thumb_y = GUI.round(self.thumb_x), GUI.round(self.thumb_y)

    local val_offset = self.show_outline and self.h or self.thumb_h + 4

    if self.show_values then
        -- Slider right, Center of thumb. 
        self:drawslidervalue(self.x + self.w, thumb_y + self.thumb_h / 2, i)                                
    end
    
    if self.thumb_style ~= "none" then
        self:drawsliderthumb(thumb_x, thumb_y, self.thumb_w, self.thumb_h)
    end
    
end


function GUI.dh_Slider_V:drawslidervalue(x, y)

    --GUI.Msg("\n##  dh_Slider_V:drawslidervalue ##")

    --??? implement output function?
    local output = self.retval
    --local output = self.max - self.retval
    --GUI.Msg("    self.max : " .. tostring(self.max))          
    --GUI.Msg("    retval   : " .. tostring(self.retval))
    --GUI.Msg("    self.max - self.retval   : " .. tostring(self.max - self.retval))      
      
    -- Align value with thumb center.
    
    -- gfx flag value to align text. 1=center horz; 4=center vert
    local align = 4

    -- As specified in buffer.
    local sd = self.shadow and GUI.shadow_dist or 0
    
    -- text_bg adds 2 px border around text. 
    x = x + self.pad_values + sd  
    
    --GUI.Msg("    gfx.x : " .. tostring(x))
    --GUI.Msg("    gfx.y : " .. tostring(y))    
    
    gfx.x, gfx.y = x, y

    -- font and text color set in calling function.
    GUI.text_bg(output, self.backdrop, align + 256)
    gfx.drawstr(output, 256 + align, gfx.x, gfx.y)

end


function GUI.dh_Slider_V:drawsliderthumb(hx, hy, hw, hh)

    --GUI.Msg("\n** drawsliderthumb **")
    --GUI.Msg("  hx: " .. tostring(hx))
    --GUI.Msg("  hy: " .. tostring(hy))
    --GUI.Msg("  hw: " .. tostring(hw))
    --GUI.Msg("  hh: " .. tostring(hh))    

--zzsh            
    -- Always draw shadow - helps with visual display.
    -- As specified for thumb buffer.
    local sd = (GUI.shadow_dist or 2) + 1    
            
    --[=[
    -- method 1 - blit in loop
    -- shadow as drawn in buffer. 
    for j = 1, GUI.shadow_dist do
        gfx.blit(self.buffs[2], 1, 0, 
                  hw + 1, 0, 
                  hw + 1, hh + 1, 
                  hx + j, hy + j)
    end
    --]=]
--zzthumb 
--zzsh        
    -- method 2 - blit as whole
    
    gfx.blit(self.buffs[2], 1, 0, 
              hw + 1, 0, 
              --hw + sd, hh + 1 + sd,
              hw + sd + 1, hh + 1 + sd,                              
              hx - 1, hy)
              
    -- blit thumb.              
    
    --gfx.blit(source, scale, rotation[, srcx, srcy, srcw, srch, destx, desty, destw, desth, rotxoffs, rotyoffs] )
    gfx.blit(self.buffs[2], 1, 0, 0, 0, hw, hh + 1, hx, hy)

end

--zzmin_max
function GUI.dh_Slider_V:draw_min_max(track_start, inc_px)
    
    GUI.font(self.font_values)
    
    -- gfx flag value to align text. 1=center horz; 4=center vert
    local align = 4 + 256

--zzsh
    -- As specified in buffer.
    local sd = self.shadow and GUI.shadow_dist or 0

    local s_off = self.w + sd + self.pad_values 
    
    -- track_start from self:draw.
    local ts, tl = track_start, self.track_length    
    
    --GUI.Msg("  draw_min_max #min_max_values : " .. tostring(#self.min_max_values))
    
    for _, data in ipairs(self.min_max_values) do
    
        local str = tostring(data[2])
        
        --GUI.Msg("    data[1] : " .. tostring(data[1]) .. " ; data[2] : " .. tostring(data[2]))
    
        local pos

        pos = ts + tl - (data[1] * inc_px)

        --[=[        
        -- # Use GUI.text_bg
        gfx.x = self.x + s_off
        gfx.y = pos

        GUI.text_bg(str, self.col_backdrop, align)
        gfx.drawstr(tostring(data[2]), align)
        --]=]

        -- # - OR - I can make my own text bg. 
        
        local str_w, str_h = gfx.measurestr(str)

        gfx.x = self.x + s_off
        gfx.y = pos - str_h / 2

        GUI.color(self.col_backdrop)
        gfx.rect(gfx.x, gfx.y, str_w, str_h, 1)    
        
        --GUI.Msg("        gfx.x : " .. tostring(x))
        --GUI.Msg("        gfx.y : " .. tostring(y))  
          
        GUI.color(self.col_values)
        gfx.drawstr(str, align)
        
    end
    
end

--zzcap
function GUI.dh_Slider_V:drawcaption()
    
    local str = self.caption
    
    GUI.font(self.font_caption)    

    local str_w, str_h = gfx.measurestr(str)
    
    if self.cap_pos == "left" then
        gfx.x = self.x - str_w - self.cap_pad_x
        if self.cap_centered then
            gfx.y = self.y + self.cap_pad_y + (self.h - str_h) / 2
        else
            gfx.y = self.y + self.cap_pad_y
        end
        
    elseif self.cap_pos == "top" then
        if self.cap_centered then
            gfx.x = self.x + self.cap_pad_x + (self.w - str_w) / 2
        else
            gfx.x = self.x + self.cap_pad_x
        end   
        gfx.y = self.y - str_h - self.cap_pad_y
        
    elseif self.cap_pos == "right" then
        gfx.x = self.x + self.w + self.cap_pad_x
        if self.cap_centered then
            gfx.y = self.y + self.cap_pad_y + (self.h - str_h) / 2
        else
            gfx.y = self.y + self.cap_pad_y
        end
        
    elseif self.cap_pos == "bottom" then
        if self.cap_centered then
            gfx.x = self.x + self.cap_pad_x + (self.w - str_w) / 2
        else
            gfx.x = self.x + self.cap_pad_x 
        end               
        gfx.y = self.y + self.h + self.cap_pad_y
        
    end    

    GUI.color(self.col_backdrop)    
    gfx.rect(gfx.x, gfx.y, str_w, str_h, 1)
    
    if self.shadow_caption then
        GUI.shadow(str, self.col_cap_text, "shadow")
    else
        GUI.color(self.col_cap_text)
        gfx.drawstr(str)
    end
    
end

------------------------------------
----------   Val   -------------
------------------------------------

function GUI.dh_Slider_V:val(newval)      
      
    if newval then
    
        self:setcurstep(newval)
    
        self:redraw()
        
    else
      
        return tonumber(self.retval)
      
    end  
      
end

------------------------------------
-------- Input methods -------------
------------------------------------
--zzmouse  

function GUI.dh_Slider_V:onmousedown()

    -- Snap the slider to the mouse pos.
    local mouse_val = (GUI.mouse.y - (self.y + self.track_start)) / self.track_length      

    self:setcurval(GUI.clamp(mouse_val, 0, 1) )
    
    self:redraw()

end


function GUI.dh_Slider_V:ondrag()

    local mouse_val = (GUI.mouse.y - (self.y + self.track_start) / self.track_length) 
    local n, ln = GUI.mouse.y, GUI.mouse.ly

     -- Ctrl
    local ctrl = GUI.mouse.cap&4==4

    -- A multiplier for how fast the slider should move. Higher values = slower
    --						    Ctrl					Normal
    local adj = ctrl and math.max(1200, (8*self.steps)) or 150
    local adj_scale = self.h / 150
    
    adj = adj * adj_scale

    self:setcurval(GUI.clamp( self.curval + ((n - ln) / adj) , 0, 1 ) )

    self:redraw()

end


function GUI.dh_Slider_V:onwheel()

    local mouse_val = (GUI.mouse.y - (self.y + self.track_start)) / self.track_length      

    local inc = GUI.round(-GUI.mouse.inc)

    local ctrl = GUI.mouse.cap&4==4

    -- How many steps per wheel-step
    local fine = 1
    local coarse = math.max( GUI.round(self.steps / 30), 1)

    local adj = ctrl and fine or coarse

    self:setcurval(GUI.clamp( self.curval + (inc * adj / self.steps) , 0, 1) )
            
    self:redraw()

end


function GUI.dh_Slider_V:ondoubleclick()

    -- Ctrl+click - reset the slider to the default.
    if GUI.mouse.cap & 4 == 4 then

        local mouse_val = (GUI.mouse.x - (self.x + self.track_start)) / self.track_length

        self:setcurstep(self.default)

    end

    self:redraw()

end

function GUI.dh_Slider_V:onmouser_up()

    -- Ctrl + right-click - reset the slider to the default.
    if GUI.mouse.cap & 4 == 4 then

        local mouse_val = (GUI.mouse.x - (self.x + self.track_start)) / self.track_length

        self:setcurstep(self.default)

    end

    self:redraw()

end


-- Make sure the box highlight goes away
function GUI.dh_Slider_V:lostfocus()

    if self.allow_sel_outline then
        self:redraw()
    end

end

------------------------------------
-------- Slider helpers ------------
------------------------------------

function GUI.dh_Slider_V:setcurstep(step)

    self.curstep = step
    self.curval = self.curstep / self.steps
    self:setretval()

end


function GUI.dh_Slider_V:setcurval(val)

    self.curval = val
    self.curstep = GUI.round(val * self.steps)
    self:setretval()

end


function GUI.dh_Slider_V:setretval()

    --local val = self.min - self.inc * self.curstep
    local val = self.max - self.inc * self.curstep    

    self.retval = self:formatretval(val)

end