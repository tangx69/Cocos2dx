local doTouchBind = function(widget,config,type,...)
    if type == 1 and string.len(config.bp2) > 0 then
        widget:exeCommond(config.bp2, ...)
    elseif type == 2 and string.len(config.bp3) > 0 then
        widget:exeCommond(config.bp3, ...)
    end
end

return function (widget, config)
    local ctr = widget:getChild(config.bp1)
    local ctrName = ctr:getDescription()
    if ctrName == "TextField" then
        ctr:addEventListener(function(sender,evt)
            if ccui.TextFiledEventType.insert_text == evt or ccui.TextFiledEventType.delete_backward == evt then
                local strLimit = ctr:getString()
                if ctr:getMaxLength() ~= 0 then
                    strLimit = zzy.StringUtils:strMaxLimit(ctr:getString(), ctr:getMaxLength())
                end               
                ctr:setString(strLimit)
                doTouchBind(widget,config,1,strLimit)
            elseif ccui.TextFiledEventType.detach_with_ime == evt then
                doTouchBind(widget,config,2,ctr:getString())
            end
        end)
    elseif ctrName == "EditBox" then
        ctr:addEventListener(function(sender,evt)
            if ccui.TextFiledEventType.insert_text == evt or ccui.TextFiledEventType.delete_backward == evt then
                doTouchBind(widget,config,1,ctr:getString())
            elseif ccui.TextFiledEventType.detach_with_ime == evt then
                doTouchBind(widget,config,2,ctr:getString())
            end
        end)
    elseif ctrName == "Button" or ctrName == "ImageView" or ctrName == "Layout" then
        ctr:addTouchEventListener(function(sender, evt)
            if not ctr:isVisible() then return end
            if ccui.TouchEventType.ended == evt then
                doTouchBind(widget,config,1)
            end
        end)
    elseif ctrName == "CheckBox" then
        ctr:addEventListener(function(sender, evt)
            if ccui.CheckBoxEventType.selected == evt then
                doTouchBind(widget,config,1)
            elseif ccui.CheckBoxEventType.unselected == evt then
                doTouchBind(widget,config,2)
            end
        end)
    elseif ctrName == "PageView" then
        ctr:addEventListener(function(sender, evt)
            if ccui.PageViewEventType.turning == evt then
                doTouchBind(widget,config,1,ctr:getCurPageIndex())
            end
        end)
    end
end