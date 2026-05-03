-- NoIndex: true

-- func_Prefs.lua
-- Modified 20260330

local Prefs = {}

Prefs.preferences = {
    
    grid_snap = true,
    grid_show = true,
    grid_size = 16,
    grid_color = "gray",
    grid_font = "sans16",
    --font_scale = "1.00",
}

Prefs.validate_preference = {
    
    grid_snap = function(val) 
        if type(val) == "boolean" then return val end
    end,
    grid_show = function(val)
        if type(val) == "boolean" then return val end
    end,
    grid_size = function(val)
        if tonumber(val) and tonumber(val) > 0 then return math.floor(val) end
    end,
    grid_color = function(val)
        for k, v in pairs(GUI.elms.GB_wnd_prefs_grid_color.optarray) do
            if v == val then return val end
        end
    end,
    grid_font = function(val)
        for k, v in pairs(GUI.elms.GB_wnd_prefs_grid_font.optarray) do
            if v == val then return val end
        end
    end
    --font_scale = function(val)
    --    if tonumber(val) and then return val end
    --end,
}

-- Called on project load to update Prefs.preferences.

function Prefs.load_settings(s_from_file)

    --GUI.Msg("# Prefs.load_settings")

    if s_from_file then

        for prop_name, _ in pairs(Prefs.preferences) do
        
            local val
        
            --GUI.Msg(">  from extstate prop_name    : " .. prop_name .. " : " .. tostring(s_from_file[prop_name]) .. " : " .. type(s_from_file[prop_name]))
                        
            -- If sff prop doesn't exist, or has no value condition is skipped,
            --   and Preferences will remain as is.
            if s_from_file[prop_name] ~= nil then
                val = Prefs.validate_preference[prop_name](s_from_file[prop_name])   
                if val ~= nil then Prefs.preferences[prop_name] = val end
            end
            
            --GUI.Msg("     after validate Prefs.prop: " .. prop_name .. " : " .. tostring(Prefs.preferences[prop_name]) .. " : " .. type(Prefs.preferences[prop_name]) .. "\n")               
        end
        
    end
    
end

-- Called when Prefs window opens to populate GB_wnd_prefs_ elms.

function Prefs.populate_settings()

    --GUI.Msg("# Prefs.populate_settings")

    for pref_name, pref_val in pairs(Prefs.preferences) do
        --GUI.Msg("  > Pref : " .. pref_name .. " : " .. tostring(pref_val) .. " : " .. type(pref_val))
        
        local pref_elm = GUI.elms["GB_wnd_prefs_" .. pref_name] 
        
        if pref_elm.type == "dh_Menubox" then
        
            -- Need to get opt number of Prefs val.
            local c_opt
            for k, v in ipairs(pref_elm.optarray) do
                if v == pref_val then
                    c_opt = k
                    break
                end
            end
            GUI.Val(pref_elm.name, c_opt)
        
        else
            GUI.Val(pref_elm.name, pref_val)
        end

    end

end

-- This is called when Prefs window closes.
-- Don't need to save Textbox because it is 
--   already validated and saved in lostfocus.

function Prefs.save_settings()

    --GUI.Msg("\n# Prefs.save_settings: ")
      
    for prop_name, _ in pairs(Prefs.preferences) do
    
        local pref_elm = GUI.elms["GB_wnd_prefs_" .. prop_name]
         
        --GUI.Msg("  > pref_elm.name : " .. pref_elm.name)
        --GUI.Msg("      before if Pref.prop : " .. prop_name .. " : " .. tostring(Prefs.preferences[prop_name]))               
        
        if pref_elm.type == "dh_Menubox" then
            --GUI.Msg("      dh_Menubox : " .. pref_elm.name)
            local c_opt, opt_val = GUI.Val(pref_elm.name)
            --GUI.Msg("    curr_opt : " .. tostring(c_opt) .. " : opt_val : " .. tostring(opt_val))
            Prefs.preferences[prop_name] = opt_val
        
        elseif pref_elm.type == "dh_Checklist" then
            
            --GUI.Msg("    > " .. pref_elm.type .. " : " .. pref_elm.name .. " : GUI.Val : " .. tostring(GUI.Val(pref_elm.name)) .. " : type : " .. type(GUI.Val(pref_elm.name)))
            Prefs.preferences[prop_name] = GUI.Val(pref_elm.name)
        end
        
        --GUI.Msg("      after if Pref.prop  : " .. prop_name .. " : " .. tostring(Prefs.preferences[prop_name]) .. " : " .. type(GUI.Val(pref_elm.name)))        
        
    end
    
end

-- This is called from main script (Initialization section).
-- Only need to handle Textbox. (As of 20251227 only grid_size)

function Prefs.add_method_overrides(elms)
        
    for name in pairs(elms) do
        
        if not string.match(name, "_OK") then
            
            GUI.elms[name].prop = string.match(name, "GB_wnd_prefs_(.+)")
            
            if GUI.elms[name].type ~= "dh_Textbox" then return end
            
            GUI.elms[name].lostfocus = function(self)
                
                local val = Prefs.validate_preference[ self.prop ](self.retval)
                
                if val then
                    Prefs.preferences[self.prop] = val
                else
                    self.retval = Prefs.preferences[self.prop]
                end
                
                self:redraw()                

            end
            
        end
        
    end    
    
end


--!!! Need to be able to scale grid.
-- This is called during GB_frm_bg.init.

function Prefs.draw_grid(self)

    --GUI.Msg("\n# Prefs.draw_grid:")
    --GUI.Msg("    grid_snap  : " .. tostring(Prefs.preferences.grid_snap) .. " : type : " .. type(Prefs.preferences.grid_snap))   
    --GUI.Msg("    grid_show  : " .. tostring(Prefs.preferences.grid_show) .. " : type : " .. type(Prefs.preferences.grid_show))   
    --GUI.Msg("    grid_size  : " .. tostring(Prefs.preferences.grid_size) .. " : type : " .. type(Prefs.preferences.grid_size))    
    --GUI.Msg("    grid_color : " .. Prefs.preferences.grid_color)            
    --GUI.Msg("    grid_font  : " .. Prefs.preferences.grid_font)    

    --GUI.color("gray")
    GUI.color(Prefs.preferences.grid_color)
    
    --!!! Should have scaled font.
    GUI.font(Prefs.preferences.grid_font)
 
    --!!! Should be able to use scaled grid size.
    -- Iterants design grid size and design workspace size,
    -- or scaled. Will provide same iteration,
    -- but grid spacing has to reflect scaled grid.
    
    local grid = Prefs.preferences.grid_size

    local pw = Project.proj_settings.w
    local ph = Project.proj_settings.h
    
    --!!! Need to get current scale.
    local sf = DHTK.APP_SCALE
    
    --local num_y = 4 * sf
    
    -- Iterate using 1.00x scale integer grid_size.
    -- 16, 32, 48, 64 ...

    for i = grid, math.max(pw, ph), grid do
        
        -- Set alpha
        local a = (i == 0) or (i % (grid * 4) == 0)
        gfx.a = a and 1 or 0.3
        
        -- Need to adjust for scale.
        -- 20, 40, 60, 80, ...
        local s = i * sf
        
        -- Draw lines
        gfx.line(s, 0, s, self.h) -- horizontal
        gfx.line(0, s, self.w, s) -- vertical
        
        -- Draw numbers
        if a then
            gfx.x, gfx.y = s + 4, 2
            gfx.drawstr( math.floor(i) )
            gfx.x, gfx.y = 4, s + 4
            gfx.drawstr( math.floor(i) )
        end	
    	
    end
    
    gfx.a = 1
    
end
    

return Prefs