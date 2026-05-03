-- NoIndex: true

-- wnd_Dialog.lua
-- Modified 20260330

local Dialog = {}

Dialog.title = "Title"
Dialog.message = "Message"
Dialog.show_inputs = true
Dialog.input_text = " "
Dialog.func = nil
Dialog.params = nil
Dialog.data = nil

function Dialog.open(params)

    Dialog.show_inputs = params.show_inputs
    Dialog.func = params.func
    --Dialog.params = params.params
    Dialog.params = params

    Dialog.stay_open = false  
    
    Dialog.btn_w = 64 
    Dialog.btn_h = 28
    local btn_spacing = (SIDEBAR_WIDTH - (2 * SIDEBAR_BORDER_WIDTH) - (2 * Dialog.btn_w)) // 3  
    Dialog.btn_confirm_x = WORKSPACE_WIDTH + SIDEBAR_BORDER_WIDTH + btn_spacing
    Dialog.btn_cancel_x = Dialog.btn_confirm_x + Dialog.btn_w + btn_spacing
    Dialog.btn_y = 224 

    -- Overlay to prevent interaction with workspace.
    GUI.New({
        name = "GB_dlg_ws_overlay",
        type = "dh_Panel",
        z = 2,
        x = 0,
        y = 0, --MENUBAR_HEIGHT,
        w = WORKSPACE_WIDTH * DHTK.APP_SCALE,
        h = (WORKSPACE_HEIGHT + MENUBAR_HEIGHT) * DHTK.APP_SCALE,
        col_bg = {0, 0, 0, 0.6},
        border_width = 0, 
        radius = 0, 
    })

    GUI.New({
        name = "GB_dlg_panel_form",
        type = "dh_Panel",
        z = 2,
        x = (WORKSPACE_WIDTH + SIDEBAR_BORDER_WIDTH) * DHTK.APP_SCALE,
        y = (MENUBAR_HEIGHT + SIDEBAR_BORDER_WIDTH) * DHTK.APP_SCALE,
        w = (SIDEBAR_WIDTH - 2 * SIDEBAR_BORDER_WIDTH) * DHTK.APP_SCALE,
        h = (WORKSPACE_HEIGHT - 2 * SIDEBAR_BORDER_WIDTH) * DHTK.APP_SCALE,
        col_bg = "panel_bg",
        col_text = "panel_txt",
        border_width = 0, 
        radius = 0, 
    })
    
    GUI.New({
        name = "GB_dlg_title",
        type = "dh_Label",
        z = 1,
        --x = (WORKSPACE_WIDTH + 16) * DHTK.APP_SCALE,
        x = (WORKSPACE_WIDTH + SIDEBAR_WIDTH / 2) * DHTK.APP_SCALE,
        y = (16 + MENUBAR_HEIGHT) * DHTK.APP_SCALE,
        col_bg = "panel_bg",
        col_text = "panel_txt",
        text = params.title or " ",
        font = "sans28",
        text_pos = "center",
    })

    GUI.New({
        name = "GB_dlg_message",
        type = "dh_Label",
        z = 1,
        x = (WORKSPACE_WIDTH + 16) * DHTK.APP_SCALE + 16,
        y = (64 + MENUBAR_HEIGHT) * DHTK.APP_SCALE,
        col_bg = "panel_bg",
        col_text = "panel_txt",
        text = params.message or " ",
        font = "sans24"
    })
    
    if params.show_inputs then
    
        GUI.New({
            name = "GB_dlg_input1",
            type = "dh_Textbox",
            z = 1,
            x = (WORKSPACE_WIDTH + 16) * DHTK.APP_SCALE,
            y = (112 + MENUBAR_HEIGHT) * DHTK.APP_SCALE,
            w = (SIDEBAR_WIDTH - 32) * DHTK.APP_SCALE,  
            h = 28 * DHTK.APP_SCALE, 
            retval = params.input_text or " ",
        })
    
    end
    
    GUI.New({
        name = "GB_dlg_btn_confirm",
        type = "dh_Button",
        z = 1,
        --x = (WORKSPACE_WIDTH + 16) * DHTK.APP_SCALE,
        x = Dialog.btn_confirm_x * DHTK.APP_SCALE,
        y = (Dialog.btn_y + MENUBAR_HEIGHT) * DHTK.APP_SCALE,
        w = Dialog.btn_w * DHTK.APP_SCALE,  
        h = Dialog.btn_h * DHTK.APP_SCALE, 
        text = "OK",
        func = Dialog.confirmDialog,
    })
    
    GUI.New({
        name = "GB_dlg_btn_cancel",
        type = "dh_Button",
        z = 1,
        --x = (WORKSPACE_WIDTH + 96) * DHTK.APP_SCALE,
        x = Dialog.btn_cancel_x * DHTK.APP_SCALE,
        y = (Dialog.btn_y + MENUBAR_HEIGHT) * DHTK.APP_SCALE,
        w = Dialog.btn_w * DHTK.APP_SCALE,  
        h = Dialog.btn_h * DHTK.APP_SCALE, 
        text = "Cancel",
        func = Dialog.cancelDialog,
    })

end


function Dialog.open_overwrite_dlg()

    GUI.font("sans28")
    local str_w, str_h = gfx.measurestr("File already exists!\n    Overwrite? ")
    local label_x = (SIDEBAR_WIDTH - str_w) / 2

    GUI.New({
        name = "GB_dlg_lbl_overwrite",
        type = "dh_Label",
        z = 1,
        --x = (WORKSPACE_WIDTH + 16) * DHTK.APP_SCALE,
        --x = (WORKSPACE_WIDTH + label_x) * DHTK.APP_SCALE,
        x = (WORKSPACE_WIDTH + (SIDEBAR_WIDTH / 2)) * DHTK.APP_SCALE,        
        y = (148 + MENUBAR_HEIGHT) * DHTK.APP_SCALE,
        col_bg = "panel_bg",
        col_text = "panel_txt",
        text_pos = "center",
        text = "File already exists!\n    Overwrite? ",
        font = "sans28",
    })

    GUI.New({
        name = "GB_dlg_btn_overwrite_confirm",
        type = "dh_Button",
        z = 1,
        --x = (WORKSPACE_WIDTH + 16) * DHTK.APP_SCALE,
        x = Dialog.btn_confirm_x * DHTK.APP_SCALE,
        y = (Dialog.btn_y + MENUBAR_HEIGHT) * DHTK.APP_SCALE,
        w = Dialog.btn_w * DHTK.APP_SCALE,  
        h = Dialog.btn_h * DHTK.APP_SCALE, 
        text = "OK",
        func = Dialog.confirmOverwrite,
    })
    
    GUI.New({
        name = "GB_dlg_btn_overwrite_cancel",
        type = "dh_Button",
        z = 1,
        --x = (WORKSPACE_WIDTH + 96) * DHTK.APP_SCALE,
        x = Dialog.btn_cancel_x * DHTK.APP_SCALE,
        y = (Dialog.btn_y + MENUBAR_HEIGHT) * DHTK.APP_SCALE,
        w = Dialog.btn_w * DHTK.APP_SCALE,  
        h = Dialog.btn_h * DHTK.APP_SCALE, 
        text = "Cancel",
        func = Dialog.cancelOverwrite,
    })

    GUI.elms.GB_dlg_btn_confirm.z = -2
    GUI.elms.GB_dlg_btn_cancel.z = -2
    GUI.redraw_z[1] = true

end


function Dialog.confirmOverwrite()

    --GUI.Msg("\n# Dialog.confirmOverwrite")

    Export.save_file()
    Dialog.cancelOverwrite()
    Dialog.cancelDialog()
    
end


function Dialog.cancelOverwrite()

    --GUI.Msg("\n# Dialog.cancelOverwrite")
    
    GUI.elms.GB_dlg_lbl_overwrite:delete()
    GUI.elms.GB_dlg_btn_overwrite_confirm:delete()
    GUI.elms.GB_dlg_btn_overwrite_cancel:delete()
    
    GUI.elms.GB_dlg_btn_confirm.z = 1
    GUI.elms.GB_dlg_btn_cancel.z = 1
    
    GUI.redraw_z[1] = true
    
end


function Dialog.confirmDialog()

    --GUI.Msg("\n# Dialog.confirmDialog")

    if Dialog.func then
        --Dialog.func(Dialog.params)
        Dialog.func(Dialog.params.params)        
    end
    --GUI.Msg("    Dialog.stay_open : " .. tostring(Dialog.stay_open) .. " : " .. type(Dialog.stay_open))
    if not Dialog.stay_open then
        --GUI.Msg("    NOT Dialog.stay_open")
        Dialog.cancelDialog()
    else    
        --GUI.Msg("    Dialog.stay_open")
    end
    
end


function Dialog.cancelDialog()

    --GUI.Msg("\n# Dialog.cancelDialog")

    GUI.elms.GB_dlg_ws_overlay:delete()
    GUI.elms.GB_dlg_panel_form:delete()
    GUI.elms.GB_dlg_title:delete()
    GUI.elms.GB_dlg_message:delete()
    GUI.elms.GB_dlg_btn_confirm:delete()
    GUI.elms.GB_dlg_btn_cancel:delete()
   
    if Dialog.show_inputs then
        GUI.elms.GB_dlg_input1:delete()
   
    end
    
    -- Do I need redraw? All?
    GUI.redraw_z[2] = true

end

return Dialog