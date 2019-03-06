local selectId = 1
-- 七日活动界面
zzy.BindManager:addFixedBind("activity/W_7days",function(widget)
    local firstPayChangeEvent = {}
    firstPayChangeEvent[ch.ShopModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ShopModel.dataType.firstPay
    end
    
    local nextDayChangeEvent = {}
    nextDayChangeEvent[ch.FestivityModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.FestivityModel.dataType.nextday
    end
    
    local stateChangeEvent = {}
    stateChangeEvent[ch.FestivityModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.FestivityModel.dataType.state or evt.dataType == ch.FestivityModel.dataType.nextday
    end
    
--    if  string.sub(zzy.Sdk.getFlag(),1,2) == "HD" then
--        widget:getChild("img_money_0"):setVisible(false)
--    end
    
    widget:addDataProxy("detailDesc", function(evt)
        return GameConst.FESTIVITY_DETAIL_DESC
    end)
    widget:addDataProxy("title", function(evt)
        if ch.FestivityModel:getWeek() == 1 then
            return Language.src_clickhero_view_FestivityView_1
        elseif ch.FestivityModel:getWeek() == 2 then
            return Language.src_clickhero_view_FestivityView_2
        elseif ch.FestivityModel:getWeek() == 3 then
            return Language.src_clickhero_view_FestivityView_3
        else
            return Language.src_clickhero_view_FestivityView_4
        end
    end,nextDayChangeEvent)
    widget:addDataProxy("canGet", function(evt)
        return ch.ShopModel:getfirstPay() == 1
    end,firstPayChangeEvent)
    widget:addDataProxy("noGet", function(evt)
        return ch.ShopModel:getfirstPay() == 0
    end,firstPayChangeEvent)
    widget:addCommond("goTo",function(obj,evt)
        ch.UIManager:cleanGamePopupLayer(true)
        ch.UIManager:showBottomPopup("Shop/W_shop")
        local evt = {type = ch.PlayerModel.payOpenShopEventType}
        zzy.EventManager:dispatch(evt)
    end)
    widget:addCommond("openPet",function()
        ch.UIManager:showGamePopup("fuwen/W_FuwenPetChange",{type =1,id = GameConst.SHOP_FIRST_PAY_REWARD.pet})
    end)
    widget:addCommond("getReward",function()
        ch.NetworkController:getFirstPayReward()
    end)
    
    widget:addDataProxy("tab_data1", function(evt)
        local ifShow = ch.FestivityModel:getDay() == 1
        if ifShow then
            selectId = 1
        end
        return ifShow
    end,nextDayChangeEvent)
    widget:addDataProxy("tab_img1", function(evt)
        if ch.FestivityModel:getDay() > 1 then
            return GameConst.FESTIVITY_BUTTON[1].img
        elseif ch.FestivityModel:getDay() == 1 then
            return GameConst.FESTIVITY_BUTTON[2].img
        else
            return GameConst.FESTIVITY_BUTTON[3].img
        end
    end,nextDayChangeEvent)
    widget:addDataProxy("tab_color1", function(evt)
        if ch.FestivityModel:getDay() > 1 then
            return GameConst.FESTIVITY_BUTTON[1].color
        elseif ch.FestivityModel:getDay() == 1 then
            return GameConst.FESTIVITY_BUTTON[2].color
        else
            return GameConst.FESTIVITY_BUTTON[3].color
        end
    end,nextDayChangeEvent)
    widget:addDataProxy("tab_can1", function(evt)
        return ch.FestivityModel:getCurCanNum(1) > 0
    end,stateChangeEvent)
    widget:addCommond("openIn1",function()
        selectId = 1
    end)
    
    widget:addDataProxy("tab_data2", function(evt)
        local ifShow = ch.FestivityModel:getDay() == 2
        if ifShow then
            selectId = 2
        end
        return ifShow
    end,nextDayChangeEvent)
    widget:addDataProxy("tab_img2", function(evt)
        if ch.FestivityModel:getDay() > 2 then
            return GameConst.FESTIVITY_BUTTON[1].img
        elseif ch.FestivityModel:getDay() == 2 then
            return GameConst.FESTIVITY_BUTTON[2].img
        else
            return GameConst.FESTIVITY_BUTTON[3].img
        end
    end,nextDayChangeEvent)
    widget:addDataProxy("tab_color2", function(evt)
        if ch.FestivityModel:getDay() > 2 then
            return GameConst.FESTIVITY_BUTTON[1].color
        elseif ch.FestivityModel:getDay() == 2 then
            return GameConst.FESTIVITY_BUTTON[2].color
        else
            return GameConst.FESTIVITY_BUTTON[3].color
        end
    end,nextDayChangeEvent)
    widget:addDataProxy("tab_can2", function(evt)
        return ch.FestivityModel:getCurCanNum(2) > 0
    end,stateChangeEvent)
    widget:addCommond("openIn2",function()
        selectId = 2
    end)
    
    widget:addDataProxy("tab_data3", function(evt)
        local ifShow = ch.FestivityModel:getDay() == 3
        if ifShow then
            selectId = 3
        end
        return ifShow
    end,nextDayChangeEvent)
    widget:addDataProxy("tab_img3", function(evt)
        if ch.FestivityModel:getDay() > 3 then
            return GameConst.FESTIVITY_BUTTON[1].img
        elseif ch.FestivityModel:getDay() == 3 then
            return GameConst.FESTIVITY_BUTTON[2].img
        else
            return GameConst.FESTIVITY_BUTTON[3].img
        end
    end,nextDayChangeEvent)
    widget:addDataProxy("tab_color3", function(evt)
        if ch.FestivityModel:getDay() > 3 then
            return GameConst.FESTIVITY_BUTTON[1].color
        elseif ch.FestivityModel:getDay() == 3 then
            return GameConst.FESTIVITY_BUTTON[2].color
        else
            return GameConst.FESTIVITY_BUTTON[3].color
        end
    end,nextDayChangeEvent)
    widget:addDataProxy("tab_can3", function(evt)
        return ch.FestivityModel:getCurCanNum(3) > 0
    end,stateChangeEvent)
    widget:addCommond("openIn3",function()
        selectId = 3
    end)
    
    widget:addDataProxy("tab_data4", function(evt)
        local ifShow = ch.FestivityModel:getDay() == 4
        if ifShow then
            selectId = 4
        end
        return ifShow
    end,nextDayChangeEvent)
    widget:addDataProxy("tab_img4", function(evt)
        if ch.FestivityModel:getDay() > 4 then
            return GameConst.FESTIVITY_BUTTON[1].img
        elseif ch.FestivityModel:getDay() == 4 then
            return GameConst.FESTIVITY_BUTTON[2].img
        else
            return GameConst.FESTIVITY_BUTTON[3].img
        end
    end,nextDayChangeEvent)
    widget:addDataProxy("tab_color4", function(evt)
        if ch.FestivityModel:getDay() > 4 then
            return GameConst.FESTIVITY_BUTTON[1].color
        elseif ch.FestivityModel:getDay() == 4 then
            return GameConst.FESTIVITY_BUTTON[2].color
        else
            return GameConst.FESTIVITY_BUTTON[3].color
        end
    end,nextDayChangeEvent)
    widget:addDataProxy("tab_can4", function(evt)
        return ch.FestivityModel:getCurCanNum(4) > 0
    end,stateChangeEvent)
    widget:addCommond("openIn4",function()
        selectId = 4
    end)
    
    widget:addDataProxy("tab_data5", function(evt)
        local ifShow = ch.FestivityModel:getDay() == 5
        if ifShow then
            selectId = 5
        end
        return ifShow
    end,nextDayChangeEvent)
    widget:addDataProxy("tab_img5", function(evt)
        if ch.FestivityModel:getDay() > 5 then
            return GameConst.FESTIVITY_BUTTON[1].img
        elseif ch.FestivityModel:getDay() == 5 then
            return GameConst.FESTIVITY_BUTTON[2].img
        else
            return GameConst.FESTIVITY_BUTTON[3].img
        end
    end,nextDayChangeEvent)
    widget:addDataProxy("tab_color5", function(evt)
        if ch.FestivityModel:getDay() > 5 then
            return GameConst.FESTIVITY_BUTTON[1].color
        elseif ch.FestivityModel:getDay() == 5 then
            return GameConst.FESTIVITY_BUTTON[2].color
        else
            return GameConst.FESTIVITY_BUTTON[3].color
        end
    end,nextDayChangeEvent)
    widget:addDataProxy("tab_can5", function(evt)
        return ch.FestivityModel:getCurCanNum(5) > 0
    end,stateChangeEvent)
    widget:addCommond("openIn5",function()
        selectId = 5
    end)
    
    widget:addDataProxy("tab_data6", function(evt)
        local ifShow = ch.FestivityModel:getDay() == 6
        if ifShow then
            selectId = 6
        end
        return ifShow
    end,nextDayChangeEvent)
    widget:addDataProxy("tab_img6", function(evt)
        if ch.FestivityModel:getDay() > 6 then
            return GameConst.FESTIVITY_BUTTON[1].img
        elseif ch.FestivityModel:getDay() == 6 then
            return GameConst.FESTIVITY_BUTTON[2].img
        else
            return GameConst.FESTIVITY_BUTTON[3].img
        end
    end,nextDayChangeEvent)
    widget:addDataProxy("tab_color6", function(evt)
        if ch.FestivityModel:getDay() > 6 then
            return GameConst.FESTIVITY_BUTTON[1].color
        elseif ch.FestivityModel:getDay() == 6 then
            return GameConst.FESTIVITY_BUTTON[2].color
        else
            return GameConst.FESTIVITY_BUTTON[3].color
        end
    end,nextDayChangeEvent)
    widget:addDataProxy("tab_can6", function(evt)
        return ch.FestivityModel:getCurCanNum(6) > 0
    end,stateChangeEvent)
    widget:addCommond("openIn6",function()
        selectId = 6
    end)
    
    widget:addDataProxy("tab_data7", function(evt)
        local ifShow = ch.FestivityModel:getDay() == 7
        if ifShow then
            selectId = 7
        end
        return ifShow
    end,nextDayChangeEvent)
    widget:addDataProxy("tab_img7", function(evt)
        if ch.FestivityModel:getDay() > 7 then
            return GameConst.FESTIVITY_BUTTON[4].img
        elseif ch.FestivityModel:getDay() == 7 then
            return GameConst.FESTIVITY_BUTTON[5].img
        else
            return GameConst.FESTIVITY_BUTTON[6].img
        end
    end,nextDayChangeEvent)
    widget:addDataProxy("tab_color7", function(evt)
        if ch.FestivityModel:getDay() > 7 then
            return GameConst.FESTIVITY_BUTTON[4].color
        elseif ch.FestivityModel:getDay() == 7 then
            return GameConst.FESTIVITY_BUTTON[5].color
        else
            return GameConst.FESTIVITY_BUTTON[6].color
        end
    end,nextDayChangeEvent)
    widget:addDataProxy("tab_can7", function(evt)
        return ch.FestivityModel:getCurCanNum(7) > 0
    end,stateChangeEvent)
    widget:addCommond("openIn7",function()
        selectId = 7
    end)
end)

zzy.BindManager:addFixedBind("activity/W_7days_in1",function(widget)
    local stateChangeEvent = {}
    stateChangeEvent[ch.FestivityModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.FestivityModel.dataType.state or evt.dataType == ch.FestivityModel.dataType.nextday
    end
    widget:addDataProxy("list", function(evt)
        return ch.FestivityModel:getListByIndex(ch.FestivityModel:getWeek(),1)
    end,stateChangeEvent)
end)

zzy.BindManager:addFixedBind("activity/W_7days_in2",function(widget)
    local stateChangeEvent = {}
    stateChangeEvent[ch.FestivityModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.FestivityModel.dataType.state or evt.dataType == ch.FestivityModel.dataType.nextday
    end
    widget:addDataProxy("list", function(evt)
        return ch.FestivityModel:getListByIndex(ch.FestivityModel:getWeek(),2)
    end,stateChangeEvent)
end)

zzy.BindManager:addFixedBind("activity/W_7days_in3",function(widget)
    local stateChangeEvent = {}
    stateChangeEvent[ch.FestivityModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.FestivityModel.dataType.state or evt.dataType == ch.FestivityModel.dataType.nextday
    end
    widget:addDataProxy("list", function(evt)
        return ch.FestivityModel:getListByIndex(ch.FestivityModel:getWeek(),3)
    end,stateChangeEvent)
end)

zzy.BindManager:addFixedBind("activity/W_7days_in4",function(widget)
    local stateChangeEvent = {}
    stateChangeEvent[ch.FestivityModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.FestivityModel.dataType.state or evt.dataType == ch.FestivityModel.dataType.nextday
    end
    widget:addDataProxy("list", function(evt)
        return ch.FestivityModel:getListByIndex(ch.FestivityModel:getWeek(),4)
    end,stateChangeEvent)
end)

zzy.BindManager:addFixedBind("activity/W_7days_in5",function(widget)
    local stateChangeEvent = {}
    stateChangeEvent[ch.FestivityModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.FestivityModel.dataType.state or evt.dataType == ch.FestivityModel.dataType.nextday
    end
    widget:addDataProxy("list", function(evt)
        return ch.FestivityModel:getListByIndex(ch.FestivityModel:getWeek(),5)
    end,stateChangeEvent)
end)

zzy.BindManager:addFixedBind("activity/W_7days_in6",function(widget)
    local stateChangeEvent = {}
    stateChangeEvent[ch.FestivityModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.FestivityModel.dataType.state or evt.dataType == ch.FestivityModel.dataType.nextday
    end
    widget:addDataProxy("list", function(evt)
        return ch.FestivityModel:getListByIndex(ch.FestivityModel:getWeek(),6)
    end,stateChangeEvent)
end)

zzy.BindManager:addFixedBind("activity/W_7days_in7",function(widget)
    local stateChangeEvent = {}
    stateChangeEvent[ch.FestivityModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.FestivityModel.dataType.state or evt.dataType == ch.FestivityModel.dataType.nextday
    end
    widget:addDataProxy("list", function(evt)
        return ch.FestivityModel:getListByIndex(ch.FestivityModel:getWeek(),7)
    end,stateChangeEvent)
end)

zzy.BindManager:addCustomDataBind("activity/W_7days_unit",function(widget,data)
    local stateChangeEvent = {}
    stateChangeEvent[ch.FestivityModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.FestivityModel.dataType.state and evt.id == data.id
    end
    widget:addDataProxy("name", function(evt)
        return data.desc
    end)
    widget:addDataProxy("icon", function(evt)
        return data.icon
    end)
    widget:addDataProxy("rewardText", function(evt)
--        return ch.FestivityModel:getRewardName(data.id).." "..ch.FestivityModel:getRewardValue(data.id)
        return ch.CommonFunc:getRewardName(data.rewardType,data.rewardId) .. " " .. ch.CommonFunc:getRewardValue(data.rewardType,data.rewardId,data.rewardValue)
    end)
    widget:addDataProxy("rewardIcon", function(evt)
        return ch.CommonFunc:getRewardIcon(data.rewardType,data.rewardId)
--        return ch.FestivityModel:getRewardIcon(data.id)
    end)
    
    widget:addDataProxy("canGet", function(evt)
        return ch.FestivityModel:getFestivityState(data.id) == 1
    end,stateChangeEvent)
    widget:addDataProxy("isGet", function(evt)
        return ch.FestivityModel:getFestivityState(data.id) ~= 2
    end,stateChangeEvent)
    widget:addDataProxy("isGetDB", function(evt)
        return ch.FestivityModel:getFestivityState(data.id) == 1 or ch.FestivityModel:getFestivityState(data.id) == 2
    end,stateChangeEvent)
    widget:addDataProxy("isNew", function(evt)
        local new = ch.FestivityModel:getCSVDataByType():getData(data.id).new
        return ch.FestivityModel:getFestivityState(data.id) == 0 and new and new > 0
    end,stateChangeEvent)
    widget:addDataProxy("btnText", function(evt)
        if ch.FestivityModel:getFestivityState(data.id) == 3 then
            return Language.src_clickhero_view_FestivityView_5
        else
            return Language.src_clickhero_view_FestivityView_6
        end
    end,stateChangeEvent)
    widget:addCommond("getReward",function()
        ch.NetworkController:getFestivityReward(data.id,{{t=data.rewardType,id=data.rewardId,num=data.rewardValue}})
    end)
end)

zzy.BindManager:addCustomDataBind("activity/W_7days_unit2",function(widget,data)
    local firstPayChangeEvent = {}
    firstPayChangeEvent[ch.ShopModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ShopModel.dataType.firstPay
    end
--    if  string.sub(zzy.Sdk.getFlag(),1,2) == "HD" then
--		widget:getChild("img_money_0"):setVisible(false)
--	end
    widget:addDataProxy("canGet", function(evt)
        return ch.ShopModel:getfirstPay() == 1
    end,firstPayChangeEvent)
    widget:addDataProxy("noGet", function(evt)
        return ch.ShopModel:getfirstPay() == 0
    end,firstPayChangeEvent)
    widget:addCommond("goTo",function()
--        ch.UIManager:cleanGamePopupLayer(true)
--        ch.UIManager:showBottomPopup("Shop/W_shop")
        local evt = {type = ch.PlayerModel.payOpenShopEventType}
        zzy.EventManager:dispatch(evt)
    end)
    widget:addCommond("getReward",function()
        ch.NetworkController:getFirstPayReward()
    end)
    widget:addCommond("openPet",function()
        ch.UIManager:showGamePopup("fuwen/W_FuwenPetChange",{type =1,id = GameConst.SHOP_FIRST_PAY_REWARD.pet})
    end)
end)