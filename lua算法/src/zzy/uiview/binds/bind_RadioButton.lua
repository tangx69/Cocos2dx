return function(widget, config)
    local buttons = {}
    local count = tonumber(config.bp3)
    for i = 1,count do
        local button = widget:getChild(string.format("%s:%s%d",config.bp1,config.bp2,i))
        if button then
            button:addTouchEventListener(function(sender,evt)
                if evt == ccui.TouchEventType.ended then
                    for k,v in pairs(buttons) do
                        v:setTouchEnabled(true)
                        v:setBright(true)
                    end
                    button:setTouchEnabled(false)
                    button:setBright(false)
                end
            end)
            table.insert(buttons,button)
        end
    end
end