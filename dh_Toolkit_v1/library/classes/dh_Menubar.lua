-- NoIndex: true

-- dh_Menubar.lua
-- Date: 20260330

---------------------------------------------------------------------
-- Lokasenna_GUI - Menubar class
--   For documentation, see this class's page on the project wiki:
--     https://github.com/jalovatt/Lokasenna_GUI/wiki/Menubar

---------------------------------------------------------------------
--[[ Modified by Dennis Horn.

     Changed property name "col_txt" to "col_text". 
     Added properties do_pad_top and pad_top_val to allow for top padding of titles.
     This was my first attempt to vertically align titles. 
     Later changed code to vertically center titles if "do_pad_top" (default) is false.
     20251103 Added property Tab.limit_w. 

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
-- name, z, x, y[, menus, fullwidth, w, h, pad] 
---------------------------------------------------------------------
GUI.dh_Menubar = GUI.Element:new()
--function GUI.dh_Menubar:new(name, z, x, y, menus, fullwidth, w, h, pad)
function GUI.dh_Menubar:new(name, z, x, y, menus, w, h, pad) 

	local mnu = (not x and type(z) == "table") and z or {}

	mnu.name = name
	mnu.type = "dh_Menubar"

	mnu.z = mnu.z or z
	mnu.x = mnu.x or x
    mnu.y = mnu.y or y
    mnu.w = mnu.w or w
    mnu.h = mnu.h or h or GUI.dh_Menubar.defaults.h
    
    -- Optional parameters should be given default values to avoid errors/crashes:
    
    mnu.menus = mnu.menus or menus or GUI.dh_Menubar.defaults.menus
        
    if (mnu.fullwidth == nil) and (fullwidth == nil) then
        mnu.fullwidth = true
    else
        mnu.fullwidth = mnu.fullwidth or fullwidth 
    end

    -- This will be maximum element width if not fullwidth.
    -- This is necessary to dynamically change width (as in GUI Builder).
    mnu.limit_w = mnu.limit_w or GUI.dh_Menubar.defaults.limit_w

    mnu.pad = mnu.pad or pad or GUI.dh_Menubar.defaults.pad
    
    mnu.do_pad_top = mnu.do_pad_top or GUI.dh_Menubar.defaults.do_pad_top

    mnu.pad_top_val = mnu.pad_top_val or GUI.dh_Menubar.defaults.pad_top_val    

    mnu.font = mnu.font or GUI.dh_Menubar.defaults.font

----colors----------------------------------------------------
    mnu.col_bg = mnu.col_bg or GUI.dh_Menubar.defaults.col_bg   
    mnu.col_text = mnu.col_text or GUI.dh_Menubar.defaults.col_text
    mnu.col_over = mnu.col_over or GUI.dh_Menubar.defaults.col_over
--------------------------------------------------------------

    --mnu.shadow = mnu.shadow or false
    if mnu.shadow == nil then mnu.shadow = true end

	GUI.redraw_z[mnu.z] = true

	setmetatable(mnu, self)
	self.__index = self
	return mnu

end

GUI.dh_Menubar.defaults = {

    h = 28,
    fullwidth = true,
    limit_w = 0,
    menus = {},
    font = "sans22",
    pad = 0,
    
    shadow = true,
    do_pad_top = false,
    pad_top_val = 0,
 
    col_bg = "btn_face",    
    col_text = "btn_txt",
    col_over = "elm_fill",    
}

function GUI.dh_Menubar:init()

    --GUI.Msg("\ndh_Menubar:init name : " .. self.name)
    
    if gfx.w == 0 then return end

    self.buff = self.buff or GUI.GetBuffer()

    -- We'll have to reset this manually since we're not running :init()
    -- until after the window is open
    local dest = gfx.dest

    gfx.dest = self.buff
    gfx.setimgdim(self.buff, -1, -1)

    -- Store some text measurements
    GUI.font(self.font)

    self.tab = gfx.measurestr(" ") * 4

    for i = 1, #self.menus do

        self.menus[i].width = gfx.measurestr(self.menus[i].title)

    end
    
    --GUI.Msg("    limit_w : " .. tostring(self.limit_w))    
        
    -- Determine width.
    self.w = self.fullwidth and (GUI.cur_w - self.x) or math.max(self.limit_w or 0, self:measuretitles(nil, true))
    self.h = self.h or gfx.texth
    
    self.w = math.floor(self.w + 0.5)
    self.h = math.floor(self.h + 0.5)    
  
    --GUI.Msg("dh_Menubar:init gfx.texth : " .. tostring(gfx.texth))
    --GUI.Msg("dh_Menubar:init gfx.w : " .. tostring(gfx.w))    
    --GUI.Msg("dh_Menubar:init GUI.cur_w : " .. tostring(GUI.cur_w))
    --GUI.Msg("dh_Menubar:init GUI.cur_w - self.x : " .. tostring(GUI.cur_w - self.x))
    --GUI.Msg("dh_Menubar:init self.w : " .. tostring(self.w))        

    -- Draw the background + shadow
    gfx.setimgdim(self.buff, self.w, self.h * 2)

    GUI.color(self.col_bg)

    gfx.rect(0, 0, self.w, self.h, true)

    GUI.color("shadow")
    local r, g, b, a = table.unpack(GUI.colors["shadow"])
	gfx.set(r, g, b, 1)
    gfx.rect(0, self.h + 1, self.w, self.h, true)
    gfx.muladdrect(0, self.h + 1, self.w, self.h, 1, 1, 1, a, 0, 0, 0, 0 )

    self.did_init = true

    gfx.dest = dest

end


function GUI.dh_Menubar:ondelete()

	GUI.FreeBuffer(self.buff)

end



function GUI.dh_Menubar:draw()

    if not self.did_init then self:init() end

    local x, y = self.x, self.y
    local w, h = self.w, self.h

    -- Blit the menu background + shadow
    if self.shadow then

        for i = 1, GUI.shadow_dist do

            gfx.blit(self.buff, 1, 0, 0, h, w, h, x, y + i, w, h)

        end

    end

    gfx.blit(self.buff, 1, 0, 0, 0, w, h, x, y, w, h)

    -- Draw menu titles
    self:drawtitles()

    -- Draw highlight
    if self.mousemnu then self:drawhighlight() end

end


function GUI.dh_Menubar:val(newval)

    if newval and type(newval) == "table" then

        self.menus = newval
        self.w, self.h = nil, nil
        self:init()
        self:redraw()

    else

        return self.menus

    end

end


function GUI.dh_Menubar:onresize()

    if self.fullwidth then
        self:init()
        self:redraw()
    end

end


------------------------------------
-------- Drawing methods -----------
------------------------------------


function GUI.dh_Menubar:drawtitles()

    local x = self.x

    GUI.font(self.font)
    GUI.color(self.col_text)

    for i = 1, #self.menus do

        local str = self.menus[i].title
        --local str_w, _ = gfx.measurestr(str)
        local str_w, str_h = gfx.measurestr(str)
        
        --GUI.Msg("-----------------------------------")
        --GUI.Msg("dh_Menubar:drawtitles self.y : " .. tostring(self.y))
        --GUI.Msg("dh_Menubar:drawtitles self.h : " .. tostring(self.h))
        --GUI.Msg("dh_Menubar:drawtitles str_h : " .. tostring(str_h))
        
        gfx.x = x + (self.tab + self.pad) / 2
        
        --gfx.y = self.y

        --GUI.Msg("dh_Menubar:drawtitles do_pad_top : " .. tostring(gfx.y))        
        if self.do_pad_top then
            --GUI.Msg("do_pad_top is true")
            gfx.y = self.y + self.pad_top_val
        else
            --GUI.Msg("do_pad_top is false")
            gfx.y = self.y + (self.h - str_h) / 2
        end
        
        --GUI.Msg("dh_Menubar:drawtitles gfx.y : " .. tostring(gfx.y))
        
        gfx.drawstr(str)

        x = x + str_w + self.tab + self.pad

    end

end


function GUI.dh_Menubar:drawhighlight()

    if self.menus[self.mousemnu].title == "" then return end

    GUI.color(self.col_over)
    gfx.mode = 1
    --                                Hover  Click
    gfx.a = GUI.mouse.cap & 1 ~= 1 and 0.3 or 0.5

    gfx.rect(self.x + self.mousemnu_x, self.y, self.menus[self.mousemnu].width + self.tab + self.pad, self.h, true)

    gfx.a = 1
    gfx.mode = 0

end




------------------------------------
-------- Input methods -------------
------------------------------------


-- Make sure to disable the highlight if the mouse leaves
function GUI.dh_Menubar:onupdate()

    if self.mousemnu and not GUI.IsInside(self, GUI.mouse.x, GUI.mouse.y) then
        self.mousemnu = nil
        self.mousemnu_x = nil
        self:redraw()

        -- Skip the rest of the update loop for this elm
        return true
    end

end



function GUI.dh_Menubar:onmouseup()
    --GUI.Msg("GUI.dh_Menubar:onmouseup")
    if not self.mousemnu then return end

    gfx.x, gfx.y = self.x + self:measuretitles(self.mousemnu - 1, true), self.y + self.h
    local menu_str, sep_arr = self:prepmenu()
    local opt = gfx.showmenu(menu_str)

	if #sep_arr > 0 then opt = self:stripseps(opt, sep_arr) end

    if opt > 0 then
       --GUI.Msg("dh_Menubar:onmouseup type options[opt][2] : " .. type(self.menus[self.mousemnu].options[opt][2]))
       
       self.menus[self.mousemnu].options[opt][2]()
       
       --GUI.Msg("dh_Menubar:onmouseup after run func?")
    end

	self:redraw()

end


function GUI.dh_Menubar:onmousedown()

    self:redraw()

end


function GUI.dh_Menubar:onmouseover()

    local opt = self.mousemnu

    local x = GUI.mouse.x - self.x

    if  self.mousemnu_x and x > self:measuretitles(nil, true) then

        self.mousemnu = nil
        self.mousemnu_x = nil
        self:redraw()

        return

    end


    -- Iterate through the titles by overall width until we
    -- find which one the mouse is in.
    for i = 1, #self.menus do

        if x <= self:measuretitles(i, true) then

            self.mousemnu = i
            self.mousemnu_x = self:measuretitles(i - 1, true)

            if self.mousemnu ~= opt then self:redraw() end

            return
        end

    end

end


function GUI.dh_Menubar:ondrag()

    self:onmouseover()

end


------------------------------------
-------- Menu methods --------------
------------------------------------


-- Return a table of the menu titles
function GUI.dh_Menubar:gettitles()

   local tmp = {}
   for i = 1, #self.menus do
       tmp[i] = self.menus.title
   end

   return tmp

end


-- Returns the length of the specified number of menu titles, or
-- all of them if 'num' isn't given
-- Will include tabs + padding if tabs = true
function GUI.dh_Menubar:measuretitles(num, tabs)

    local len = 0

    for i = 1, num or #self.menus do

        len = len + self.menus[i].width

    end

    return not tabs and len
                    or (len + (self.tab + self.pad) * (num or #self.menus))

end


-- Parse the current menu into a string for gfx.showmenu
-- Returns the string and a table of separators for offsetting the
-- value returned when the user clicks something.
function GUI.dh_Menubar:prepmenu()

    --GUI.Msg("prepmenu self.menus[self.mousemnu].title : " .. self.menus[self.mousemnu].title)

    local arr = self.menus[self.mousemnu].options  -- list of records{"title", func}

    local sep_arr = {}
	local str_arr = {}
    local menu_str = ""
    
    --GUI.Msg("**** prepmenu #arr : " .. tostring(#arr))
    
    -- Either of next lines crashes script.
    --GUI.Msg("prepmenu arr[1] : " .. arr[1])
    --GUI.Msg("prepmenu type arr[1] : " .. type(arr[1]))
    
    --GUI.Msg("prepmenu ????")
    
	for i = 1, #arr do

        table.insert(str_arr, arr[i][1])
        --GUI.Msg("prepmenu #str_arr : " .. tostring(#str_arr))
		if str_arr[#str_arr] == ""
		or string.sub(str_arr[#str_arr], 1, 1) == ">" then
			table.insert(sep_arr, i)
		end

		table.insert( str_arr, "|" )

	end

	menu_str = table.concat( str_arr )

	return string.sub(menu_str, 1, string.len(menu_str) - 1), sep_arr

end


-- Adjust the returned value to account for any separators,
-- since gfx.showmenu doesn't count them
function GUI.dh_Menubar:stripseps(opt, sep_arr)

    for i = 1, #sep_arr do
        if opt >= sep_arr[i] then
            opt = opt + 1
        else
            break
        end
    end

    return opt

end