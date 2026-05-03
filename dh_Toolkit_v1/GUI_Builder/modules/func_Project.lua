-- NoIndex: true

-- func_Project.lua
-- Modified 20260330

local Project = {}

-- Default project window properties
Project.proj_settings = {
    
    name = "New project",
    w = 640,
    h = 480,
    x = 0,
    y = 0,
    anchor = "mouse",
    corner = "C",
    scripts_dir = "../scripts/",
}

-- This is called when closing Project window.
-- Elm GB_wnd_proj_prop gets appropriate function assigned
--   to its lostfocus method.
-- lostfocus will update Project.proj_settings if valid value.

Project.validate_proj_setting = {

    name = function(val)
        if val ~= "" then return tostring(val) end
    end,

    w = function(val)
        if tonumber(val) and tonumber(val) > 0 then return math.floor(val) end
    end,

    h = function(val)
        if tonumber(val) and tonumber(val) > 0 then return math.floor(val) end
    end,

    x = function(val)
        if tonumber(val) then return math.floor(val) end
    end,

    y = function(val)
        if tonumber(val) then return math.floor(val) end
    end,

    anchor = function(val)
        if val == "screen" or val == "mouse" then return tostring(val) end
    end,

    corner = function(val)
        if string.match("TL,T,TR,R,BR,B,BL,L,C", val.."%,") then return val end        
    end,
    
    scripts_dir = function(val)
        return val       
    end,    
}

-- Called on project load to update Project.proj_settings.

function Project.load_settings(s_from_file)

    --GUI.Msg("# Project.load_settings")
    
    if s_from_file then
            
        for prop_name, val in pairs(Project.proj_settings) do

            local val
            
            -- If sff prop doesn't exist, or has no value condition is skipped,
            --   and Project_proj_settings will remain as is.
            if s_from_file[prop_name] then
                val = Project.validate_proj_setting[prop_name](s_from_file[prop_name])   
                --Project.proj_settings[prop_name] = val
                if val ~= nil then Project.proj_settings[prop_name] = val end
            end
            
            --GUI.Msg("     after validate Project.prop: " .. prop_name .. " : " .. tostring(Project.proj_settings[prop_name]) .. " : " .. type(Project.proj_settings[prop_name]) .. "\n")    
        end
                
    end


end

-- Called when Project window opens to populate GB_wnd_proj_ elms.

function Project.populate_settings() 

    --GUI.Msg("# Project.populate_settings: Project window opened ")

    --for k, v in pairs(Project.proj_settings) do
    --    GUI.Val("GB_wnd_proj_" .. k, v) 
    --end
    
    for prop_name, prop_val in pairs(Project.proj_settings) do
        --GUI.Msg("  > Proj : " .. prop_name .. " : " .. tostring(prop_val) .. " : " .. type(prop_val))
        
        local prop_elm = GUI.elms["GB_wnd_proj_" .. prop_name] 
               
        if prop_elm.type == "dh_Menubox" then
        
            -- Need to get opt number of prop_val.
            local c_opt
            for k, v in ipairs(prop_elm.optarray) do
                if v == prop_val then
                    c_opt = k
                    break
                end
            end
            GUI.Val(prop_elm.name, c_opt)
        
        else
            GUI.Val(prop_elm.name, prop_val)
        end
    
    end
    
end

-- Called when Project window closes.
-- Textboxes lostfocus updates Project.proj_settings directly.
-- Only need to handle other elements (as of 20251229 none).

function Project.save_settings()

    --GUI.Msg("\n# Project.save_settings: ")
    
    for prop_name, _ in pairs(Project.proj_settings) do
    
        local prop_elm = GUI.elms["GB_wnd_proj_" .. prop_name]
    
        if prop_elm.type == "dh_Menubox" then
            --GUI.Msg("      dh_Menubox : " .. prop_elm.name)
            local c_opt, opt_val = GUI.Val(prop_elm.name)
            --GUI.Msg("    curr_opt : " .. tostring(c_opt) .. " : opt_val : " .. tostring(opt_val))
            Project.proj_settings[prop_name] = opt_val
        end
        
        --GUI.Msg("      after if Proj.prop  : " .. prop_name .. " : " .. tostring(Project.proj_settings[prop_name]) .. " : " .. type(GUI.Val(prop_elm.name)))        
    
    end
    
end

-- This is called from main script (Initialization section).

function Project.add_method_overrides(elms)

    --GUI.Msg("##  Project.add_method_overrides  ##")
        
    for name in pairs(elms) do
    
        --GUI.Msg("      elm name : " .. name)
        
        if not string.match(name, "_OK") then
            
            GUI.elms[name].prop = string.match(name, "GB_wnd_proj_(.+)")
                        
            --GUI.Msg("      prop     : " .. GUI.elms[name].prop)
            
            -- Only need to handle Textboxes.
            if GUI.elms[name].type == "dh_Textbox" then  
                                    
                GUI.elms[name].lostfocus = function(self)
    
                    local val = Project.validate_proj_setting[self.prop](self.retval)
                    
                    --GUI.Msg(    name .. " : lostfocus override")
                    
                    if val then
                        --GUI.Msg("      val     : " .. tostring(val))
                        Project.proj_settings[self.prop] = val
                    else
                        self.retval = Project.proj_settings[self.prop]
                    end
                    
                    self:redraw()
    
                end
                
            end
            
        end  --<if not string.match>
        
        --::skipped::
        
    end  --<for name in pairs>    
    
end


-- This is called if proj w or h was changed.
-- If app is scaled then all metrics are already scaled,
--   and just need to resize workspace.

function Project.update_wnd_size(status)

    --GUI.Msg("**** Project.update_wnd_size  ****")
    --GUI.Msg("Project.proj_settings.w : " .. tostring(Project.proj_settings.w))
    --GUI.Msg("Project.proj_settings.h : " .. tostring(Project.proj_settings.h))    
    
    WORKSPACE_WIDTH = math.max(Project.proj_settings.w, WORKSPACE_MIN_W)
    WORKSPACE_HEIGHT = math.max(Project.proj_settings.h, WORKSPACE_MIN_H)
    
    --GUI.Msg("WORKSPACE_WIDTH : " .. tostring(WORKSPACE_WIDTH))
    --GUI.Msg("WORKSPACE_HEIGHT : " .. tostring(WORKSPACE_HEIGHT))
    
    -- Resize script window.
    DHTK.APP_WIDTH = WORKSPACE_WIDTH + SIDEBAR_WIDTH
    DHTK.APP_HEIGHT = WORKSPACE_HEIGHT + MENUBAR_HEIGHT
    
    --GUI.Msg("DHTK.APP_WIDTH : " .. tostring(DHTK.APP_WIDTH))
    --GUI.Msg("DHTK.APP_HEIGHT : " .. tostring(DHTK.APP_HEIGHT))      
    
    GUI.w = DHTK.APP_WIDTH * DHTK.APP_SCALE
    GUI.h = DHTK.APP_HEIGHT * DHTK.APP_SCALE
    
    -- Resize and reposition sidebar.
    GUI.elms.GB_side_bg.x = WORKSPACE_WIDTH * DHTK.APP_SCALE
    GUI.elms.GB_side_bg.h = WORKSPACE_HEIGHT * DHTK.APP_SCALE
    
    -- Reposition GB_side_elm_type.
    GUI.elms.GB_side_elm_type.x = (WORKSPACE_WIDTH + 24) * DHTK.APP_SCALE
    
    -- Reposition pages menubox.
    if GUI.elms.GB_mnu_pages then
        GUI.elms.GB_mnu_pages.x = (WORKSPACE_WIDTH + (SIDEBAR_WIDTH - GUI.elms.GB_mnu_pages.w) / 2) * DHTK.APP_SCALE
    end
    
    --!!! Need to reposition properties x.
    
    if status ~= "import" then
        for _, elm_name in pairs(GUI.elms_list[5]) do
            if string.match(elm_name, "GB_prop")  then
                --GUI.Msg("test_elm elm_name  : " .. elm_name)
                GUI.elms[elm_name].x = (WORKSPACE_WIDTH + 132) * DHTK.APP_SCALE
                GUI.elms[elm_name]:init()
            end      
        end 
    end
    
    -- Init workspace if project smaller than workspace.
    -- ??? What about when scaled? when scaled.
    if Project.proj_settings.w < WORKSPACE_WIDTH or
       Project.proj_settings.h < WORKSPACE_HEIGHT then
       GUI.elms.GB_frm_ws:init()
    end

    GUI.elms.GB_frm_bg:init()
    GUI.elms.GB_side_bg:init()
    
    GUI.resized = true
    
end


function Project.draw_ws_grid(self)

    -- Set metrics. Assume grid size of 16
    local rect_sz = Prefs.preferences.grid_size or 16
    local x_offset = 0
    local rows = WORKSPACE_HEIGHT / rect_sz
    local columns = WORKSPACE_WIDTH / rect_sz * 2
    local sf = DHTK.APP_SCALE
    
    --GUI.Msg("drawing ws grid")
    --GUI.Msg("  no of rows    : " .. tostring(rows))
    --GUI.Msg("  no of columns : " .. tostring(columns))
    
    GUI.color("gray")
    gfx.rect(0, 0, self.w, self.h, true)
        
    --GUI.color("panel_bg")
    GUI.color("white")
    gfx.a = 0.5
    
    rect_sz = rect_sz * sf

    for r = 0, rows - 1, 1 do
        
        --GUI.Msg("> ROW r : " .. tostring(r))    
        --GUI.Msg("   ROW y : " .. tostring(math.floor(r * rect_sz)))
        
        local y = r * rect_sz

        -- Reset x_offset
        if r % 2 == 0 then x_offset = 0 else x_offset = rect_sz end

        --GUI.Msg("#  x_offset : " .. tostring(x_offset))

        for c = 0, columns - 1, 2 do
        
            local x = x_offset + (c * rect_sz)
            
            gfx.rect(x, y, rect_sz, rect_sz, true)
            
        end
        
    end
    
    -- Reset alpha
    gfx.a = 1
end


return Project