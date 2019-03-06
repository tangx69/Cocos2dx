return function(widget, config)
    local checkBox = widget:getChild(config.bp1)
    if not checkBox then return end
    if checkBox:getDescription() ~= "CheckBox" then
        error(string.format("%s 控件类型错误，应该是CheckBox", config.bp1))
        return
    end
    local status = checkBox:isSelected()
    local selectWidgets = {}
    local unSelectWidgets = {} 
    if config.bp2 ~= "" and config.bp3 ~= "" and tonumber(config.bp3) > 0 then
        for i = 1,tonumber(config.bp3) do
            local item = widget:getChild(config.bp2..i)
            if item then
                table.insert(selectWidgets,item)
                item:setVisible(status)
            end
        end
    end
    if config.bp4 ~= "" and config.bp5 ~= "" and tonumber(config.bp5) > 0 then
        for i = 1,tonumber(config.bp5) do
            local item = widget:getChild(config.bp4..i)
            if item then
                table.insert(unSelectWidgets,item)
                item:setVisible(not status)
            end
        end
    end
    checkBox:addEventListener(function(sender,evt)
        if ccui.CheckBoxEventType.selected == evt then
            for k,v in pairs(selectWidgets) do
                v:setVisible(true)
            end
            for k,v in pairs(unSelectWidgets) do
                v:setVisible(false)
            end
        elseif ccui.CheckBoxEventType.unselected == evt then
            for k,v in pairs(selectWidgets) do
                v:setVisible(false)
            end
            for k,v in pairs(unSelectWidgets) do
                v:setVisible(true)
            end
        end
    end)
end