-- 固有绑定
-- 离线收益打开界面
zzy.BindManager:addFixedBind("Common/W_offlinegold", function(widget)
    widget:addDataProxy("offLineGold", function(evt) 
        return ch.NumberHelper:toString(ch.LongDouble:floor(ch.ModelManager:getOffLineGold()))
    end)
   
    widget:addCommond("addOffLineGold",function()
        local gold = ch.ModelManager:getOffLineGold()
        ch.NetworkController:getOffLineGold(gold)
        local evt = {type = ch.PlayerModel.offLineGetEventType}
        zzy.EventManager:dispatch(evt)
        widget:destory()
        ch.SoundManager:play("close")
    end)
end)