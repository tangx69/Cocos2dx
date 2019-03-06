return function (widget, config)
    local ctrl = widget:getChild(config.bp1)
    if ctrl.addTouchEventListener then
        ctrl:addTouchEventListener(function(obj,evt)
            local point
            if evt == ccui.TouchEventType.began then
                point = ctrl:getTouchBeganPosition()
            elseif evt == ccui.TouchEventType.moved then
                point = ctrl:getTouchMovePosition()
            elseif evt == ccui.TouchEventType.ended then
                point = ctrl:getTouchEndPosition()
            end
            widget:exeCommond(config.bp2, evt, point)
        end)
    else
        error("页面  %s 内的控件  %s 没有 Mouse绑定",config.ui,config.bp1)
    end
end