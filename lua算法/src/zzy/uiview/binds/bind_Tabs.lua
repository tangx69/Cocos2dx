return function(widget, config)
    if string.len(config.bp5) == 0 then
        config.bp5 = "1"
    end

    local pages = {}
    local showPageIndex = nil
    
    local showPageAt = function(k)
        if k == showPageIndex then return end
        
        showPageIndex = k
        
        for key, var in pairs(pages) do
        	if key ~= k then
                var:setVisible(false)
        	end
        end
        if pages[k] then
            pages[k]:setVisible(true)
        else
            pages[k] = widget:create(config.bp3..k, widget._pathFormat)
            widget:getChild(config.bp1):addChild(pages[k])
        end
        
        --消息界面 外部链接 父对象visible为false时，它不消失，  它自身visible为false才消失    所以在此加临时补丁，删除后消息界面显示有问题后果自负
        if config.bp3 == "msg/W_MsgIn" and ch.MsgModel.objwebView then
        	if k == 1 then
                ch.MsgModel.objwebView:setVisible(true)
            else
                ch.MsgModel.objwebView:setVisible(false)
        	end
        end
        
        for i = 1,config.bp4 do
            local optionBtn = widget:getChild(config.bp2 .. i)
            optionBtn:setSelected(k==i)
        end
    end
    
    for i = 1,config.bp4 do
    	local optionBtn = widget:getChild(config.bp2 .. i)
    	if optionBtn:getDescription() ~= "CheckBox" then
            error(string.format("%s 控件类型错误，应该是CheckBox", config.bp2..i))
    	end
    	optionBtn:addEventListener(function(sender, evt)
            if ccui.CheckBoxEventType.selected == evt then
                showPageAt(i)
            elseif ccui.CheckBoxEventType.unselected == evt then
                if showPageIndex == i then
                    optionBtn:setSelected(true)
                end
            end
    	end)
    end
    
    if tonumber(config.bp5) then
        showPageAt(tonumber(config.bp5))
    else
        widget:addDataViewer(config.bp5,function(data)
            showPageAt(data)
        end)
    end    
end