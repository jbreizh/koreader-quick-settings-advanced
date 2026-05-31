-- Exit button for KOReader top menu
-- Add hold_callback on Exit button
-- Add exit button in filemanager : Tap->close menu
-- Remove filemanager button in Reader
-- Add exit button in filemanager : Tap->close menu Hold->close filemanager

local UIManager = require("ui/uimanager")

-- Add hold_callback on Exit button

local TouchMenu = require("ui/widget/touchmenu")

local orig_init = TouchMenu.init

function TouchMenu:init(...)
    orig_init(self, ...)

    if not self.bar or not self.bar.icon_widgets then
        return
    end

    for i, tab in ipairs(self.tab_item_table) do
        if tab.id == "exit_patch" and tab.hold_callback then
            local icon_button = self.bar.icon_widgets[i]

            if icon_button then
                icon_button.hold_callback = function(...)
                    tab.hold_callback(...)
                end
            end

            break
        end
    end
end

-- Add exit button in filemanager : Tap->close menu

local FileManagerMenu = require("apps/filemanager/filemanagermenu")

local orig_fm_setUpdateItemTable = FileManagerMenu.setUpdateItemTable

function FileManagerMenu:setUpdateItemTable()
    -- Inject file_exit_tab
    orig_fm_setUpdateItemTable(self)
    local file_exit_tab = {
        id = "exit_patch",
        icon = "exit",
        remember = false,
        callback = function()
            UIManager:close(self.menu_container)
        end,
    }
    table.insert(self.tab_item_table, file_exit_tab)
end

-- Remove filemanager button in Reader
-- Add exit button in filemanager : Tap->close menu Hold->close filemanager

local ReaderMenu = require("apps/reader/modules/readermenu")

local orig_reader_setUpdateItemTable = ReaderMenu.setUpdateItemTable

function ReaderMenu:setUpdateItemTable()
    -- remove filemanager
    orig_reader_setUpdateItemTable(self)
    for i = #self.tab_item_table, 1, -1 do
        if self.tab_item_table[i].id == "filemanager" then
            table.remove(self.tab_item_table, i)
            break
        end
    end
    -- Inject reader_exit_tab
    local reader_exit_tab = {
        id = "exit_patch",
        icon = "exit",
        remember = false,
        callback = function()
            UIManager:close(self.menu_container)
        end,
        hold_callback = function()
            self:onTapCloseMenu()
            local file = self.ui.document.file
            self.ui:onClose()
            self.ui:showFileManager(file)
        end
    }
     table.insert(self.tab_item_table, reader_exit_tab)
end
