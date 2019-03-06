-- 自定义绑定
-- 断线重连界面
zzy.BindManager:addCustomDataBind("Common/W_reconnect", function(widget,arg)
    widget:addDataProxy("message",function()
        return arg.msg or ""
    end)
    widget:addDataProxy("btnText",function()
        return arg.text or Language.MSG_BUTTON_YESOK
    end)
    widget:addCommond("reConnect",function()
        if arg.isClose then
        ch.UIManager.isTipOpen = false
            widget:destory()
        end
        if arg.func1 then
            arg.func1()
        end
--        else
--        cclog("网络状态"..zzy.cUtils.getNetworkState())
--        if zzy.cUtils.getNetworkState() == 0 then
--            ch.UIManager:cleanGamePopupLayer(true)
--            ch.UIManager:showBottomPopup("Common/W_reconnect")
--        else
--            cclog("重启游戏")
--            __G__ONRESTART__()
--        end
--        end
        
    end)
end)

-- 二次确认界面
zzy.BindManager:addCustomDataBind("Common/W_Poperror", function(widget,arg)
    widget:addDataProxy("message",function()
        return arg.msg or ""
    end)
    widget:addDataProxy("btnText",function()
        return arg.text or Language.MSG_BUTTON_YESOK
    end)
    widget:addDataProxy("short",function()
        return arg.txtType == 1
    end)
    widget:addDataProxy("long",function()
        return arg.txtType ~= 1
    end)
    widget:addCommond("reConnect",function()
        if arg.isClose then
            ch.UIManager.isTipOpen = false
            widget:destory()
        end
        if arg.func1 then
            arg.func1()
        end
    end)
    widget:addCommond("cancel",function()
        ch.UIManager.isTipOpen = false
        widget:destory()
    end)
end)

-- 带标题的界面
zzy.BindManager:addCustomDataBind("Common/W_title_tips", function(widget,arg)
    widget:addDataProxy("title",function()
        return arg.title or ""
    end)
    widget:addDataProxy("tips1",function()
        return arg.tips or ""
    end)
    widget:addDataProxy("isTwo",function()
        return arg.btn == 2
    end)
    widget:addDataProxy("isOne",function()
        return arg.btn == 1
    end)
    widget:addCommond("ok",function()
        if arg.func1 then
            arg.func1()
        end
        if arg.isClose then
            widget:destory()
        end
    end)
    widget:addCommond("cancel",function()
        widget:destory()
    end)
end)