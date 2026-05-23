-- Exit button for KOReader top menu
-- Remove filemanager button in Book Reader views
-- Add Exit button in both File Manager and Book Reader views.

local UIManager = require("ui/uimanager")
local FileManagerMenu = require("apps/filemanager/filemanagermenu")
local ReaderMenu = require("apps/reader/modules/readermenu")

local orig_fm_setUpdateItemTable = FileManagerMenu.setUpdateItemTable

function FileManagerMenu:setUpdateItemTable()
    -- Inject file_exit_tab
    orig_fm_setUpdateItemTable(self)
    local file_exit_tab = {
    icon = "exit",
    remember = false,
    callback = function() UIManager:close(self.menu_container) end
    }
    table.insert(self.tab_item_table, file_exit_tab)
end

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
        icon = "exit",
        remember = false,
        callback = function()
            -- UIManager:close(self.menu_container)
            self:onTapCloseMenu()
            local file = self.ui.document.file
            self.ui:onClose()
            self.ui:showFileManager(file)
        end
    }
     table.insert(self.tab_item_table, reader_exit_tab)
end
