-- 圣诞活动主界面

local function reqHolidayData(data)
    --f data ~= ch.ChristmasModel:getCurPage() then
        ch.ChristmasModel:setCurPage(tonumber(data))
        if data == 1003 then        --圣诞限购
            ch.NetworkController:getSdxgPanel()
        elseif data == 2036 then        --开服7天排行
            ch.NetworkController:getKfphPanel()
        elseif  data == 1021 then  --荣耀金矿
            ch.NetworkController:sendGloryGold()
        elseif  data == 1001 then  --节日兑换
            ch.NetworkController:getSddhPanel()
        end
    --end
end
zzy.BindManager:addFixedBind("Christmas/W_Christmas", function(widget)
    local pageChangeEvent = {}
    pageChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.ChristmasModel.dataType.curPage
    end
    
    local nextdayChangeEvent = {}
    nextdayChangeEvent[ch.ShopModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ShopModel.dataType.all 
    end
    nextdayChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.stop 
    end
    
    widget:addDataProxy("listIcon",function(evt)
        if ch.ChristmasModel.isEffect then
            ch.ChristmasModel.isEffect = false
            local evt = {type = ch.ChristmasModel.effectDataChangeEventType}
            zzy.EventManager:dispatch(evt)
        end
        local list =  ch.ChristmasModel:getHolidayTypeList()
        reqHolidayData(list[1])
        return list
    end)
    
    local pages = {}
    widget:addDataProxy("openPanel",function(evt)
        local k = ch.ChristmasModel:getCurPage()
        for k,v in pairs(pages) do
            v:setVisible(false)
        end
        if pages[k] then
            pages[k]:setVisible(true)
        else
            pages[k] = widget:create(GameConst.HOLIDAY_ITEM_DATA["hd"..k].panel, widget._pathFormat)
            widget:addChild(pages[k])
        end
    end,pageChangeEvent)
    
    widget:addDataProxy("isClose",function(evt)
        if not ch.ChristmasModel:isOpen() then
            widget:destory()
        end
        return true
    end,nextdayChangeEvent)
    
    local close = widget.destory
    widget.destory = function(widget,cleanView)
        close(widget,cleanView)
        ch.ChristmasModel.openRedBag = false
        cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("res/ui/aaui_png/plist_holiday.plist")
    end
    
--    widget:addDataProxy("listContent",function(evt)
--        local items = {}
--        local tmpData = ch.ChristmasModel:getCSVDataByType(ch.ChristmasModel:getCurPage())
--        local index = 2
--        if ch.ChristmasModel:getCurPage() == 1003 or ch.ChristmasModel:getCurPage() == 1001 then
--            index = 1
--        end
--        if tmpData then
--            for k,v in pairs(tmpData) do
--                table.insert(items,{index = index,value = {type=ch.ChristmasModel:getCurPage(),value=v},isMultiple = true})
--            end
--        end
--        return items
--    end,pageChangeEvent)
    
end)

-- 圣诞活动图标
zzy.BindManager:addCustomDataBind("Christmas/W_Xmas_icon", function(widget,data)
    local pageChangeEvent = {}
    pageChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.curPage
    end
    
    local stateChangeEvent = {}
    stateChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.state
            or evt.dataType == ch.ChristmasModel.dataType.czxl
            or evt.dataType == ch.ChristmasModel.dataType.xhfl
    end
    stateChangeEvent[ch.ChristmasModel.wheelChangeEventType] = false
    stateChangeEvent[ch.ChristmasModel.redbagChangeEventType] = false
    stateChangeEvent[ch.ChristmasModel.redbagOpenEventType] = false
    stateChangeEvent[ch.ChristmasModel.hyggChangeEventType] = false
    
    widget:addDataProxy("icon",function(evt)
        if data == 1001 then
            return GameConst.HOLIDAY_SDDH_MONEY_DATA[ch.ChristmasModel:getCfgidByType(1001)].icon
        else
            return GameConst.HOLIDAY_ITEM_DATA["hd" .. data].icon
        end
    end)
    
    widget:addDataProxy("ifSelect",function(evt)
        return data == ch.ChristmasModel:getCurPage()
    end,pageChangeEvent)
    
    widget:addDataProxy("ifNew",function(evt)
        return ch.ChristmasModel:getCurCan(data)
    end,stateChangeEvent)
    -- 活动 itemicon 点击事件
    widget:addCommond("openPanel",function()
        reqHolidayData(data)
    end)
end)

-- 圣诞活动兑换界面单元
zzy.BindManager:addCustomDataBind("Christmas/W_Xmas_shop", function(widget,data)
    local pageChangeEvent = {}
    pageChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.curPage
    end
    local stateChangeEvent = {}
    stateChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.state
    end
    stateChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.cSock
    end
    local countChangeEvent = {}
    countChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.count
    end
    
    widget:addDataProxy("icon",function(evt)
        return data.value.icon
    end,pageChangeEvent)
    widget:addDataProxy("name",function(evt)
        return string.format(data.value.name,ch.ChristmasModel:getGiftNameById(data.value.giftId))
    end,pageChangeEvent)
    widget:addDataProxy("desc",function(evt)
        return data.value.desc
    end,pageChangeEvent)
    
    widget:addDataProxy("price",function(evt)
        return data.value.price
    end,pageChangeEvent)
    
    widget:addDataProxy("ifCanBuy",function(evt)
        return ch.ChristmasModel:getHolidayState(data.type,data.value.id) == 1 and ch.MoneyModel:getCSock() >= data.value.price
    end,stateChangeEvent)
    widget:addDataProxy("noBuy",function(evt)
        if data.value.max == 0 or ch.ChristmasModel:getDHNum(data.value.id) > 0 then
            ch.ChristmasModel:setHolidayState(data.type,data.value.id,1)
        else
            ch.ChristmasModel:setHolidayState(data.type,data.value.id,2)
        end
        return data.value.max == 0 or ch.ChristmasModel:getDHNum(data.value.id) > 0
    end,countChangeEvent)
    widget:addCommond("buyNew",function()
        ch.NetworkController:getHolidayReward(data.type,data.value.id)
        ch.MoneyModel:addCSock(-data.value.price)
        ch.ChristmasModel:addDHNum(data.value.id,1)
    end)
end)

-- 圣诞活动任务单元
zzy.BindManager:addCustomDataBind("Christmas/W_Xmas_1", function(widget,data)
    local pageChangeEvent = {}
    pageChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.curPage
    end
    local stateChangeEvent = {}
    stateChangeEvent[ch.ChristmasModel.dataChangeEventType] = false
    
    local countChangeEvent = {}
    countChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.curPage
            or evt.dataType == ch.ChristmasModel.dataType.count
    end
    
    widget:addDataProxy("icon",function(evt)
        return data.value.icon
    end,pageChangeEvent)
    widget:addDataProxy("name",function(evt)
        return data.value.name
    end,pageChangeEvent)
    widget:addDataProxy("desc",function(evt)
        if data.type == 1004 or data.type == 1005 or data.type == 1018 then
            return string.format(data.value.desc,data.value.goal)
        elseif (data.type == 1002 or data.type == 2035 or data.type == 2037) and data.value.itemType then
            return string.format(data.value.desc,ch.ChristmasModel:getGiftNameById(data.value.itemId))
        else
            return data.value.desc
        end
    end,pageChangeEvent)

    widget:addDataProxy("ifCanGet",function(evt) --touchEnable
        return ch.ChristmasModel:getHolidayState(data.type,data.value.id) == 1
    end,stateChangeEvent)
    widget:addDataProxy("noGet",function(evt) --visible
        if data.type == 1004 or data.type == 1005 or data.type == 1018 then
            return ch.ChristmasModel:getHolidayState(data.type,data.value.id) ~= 2
        elseif data.type == 1002 or data.type == 2037 or data.type == 2035 then
            return ch.ChristmasModel:getHolidayState(data.type,data.value.id) ~= 2
        else
            return ch.ChristmasModel:getHolidayState(data.type,data.value.id) == 1 or ch.ChristmasModel:getHolidayState(data.type,data.value.id) == 3
        end
    end,stateChangeEvent)
    
    -- 设置当前活动完成状态 0不可领1可领奖2已领奖3不到时间4已过期
    widget:addDataProxy("btnText",function(evt)
        if data.type == 1004 or data.type == 1005 or data.type == 1018 then
            if ch.ChristmasModel:getHolidayState(data.type,data.value.id) == 1 then
                return Language.src_clickhero_view_ChristmasView_18
            else
                return Language.src_clickhero_view_ChristmasView_2
            end
        elseif data.type == 1002 or data.type == 2037 or data.type == 2035 then
            local state = ch.ChristmasModel:getHolidayState(data.type, data.value.id)
            if state ~= 2 then
                if state == 1 then
                    return Language.src_clickhero_view_ChristmasView_18 --领取
                elseif state == 0 then
                    return Language.src_clickhero_view_ChristmasView_2 --未达成
                elseif state == 3 then
                    return Language.src_clickhero_view_ChristmasView_3 --未到期
                elseif state == 4 then
                    return Language.src_clickhero_view_ChristmasView_17 --已结束
                end
            end
        else
            if ch.ChristmasModel:getHolidayState(data.type,data.value.id) == 3 then
                return Language.src_clickhero_view_ChristmasView_3
            else
                return Language.src_clickhero_view_ChristmasView_4
            end
        end
    end,countChangeEvent)
    
    widget:addDataProxy("getImage",function(evt)
        if data.type == 1004 or data.type == 1005 or data.type == 1018 then
            return "aaui_common/state_get1.png"
        else
            if ch.ChristmasModel:getHolidayState(data.type,data.value.id) == 4 then
                return "aaui_common/state_out1.png" --已过期
            else
                return "aaui_common/state_signed1.png" --已签到
            end
        end
    end)
    widget:addCommond("getReward",function()
        ch.NetworkController:getHolidayReward(data.type,data.value.id)
        if (data.type == 1002 or data.type == 2037 or data.type == 2035) then
            ch.ChristmasModel:setHolidayState(data.type,data.value.id,2)
        elseif data.type == 1004 or data.type == 1005 or data.type == 1018 then
            ch.ChristmasModel:addRewardNum(data.type,data.value.id,1)
        end
    end)
end)

-- 圣诞活动限购单元
zzy.BindManager:addCustomDataBind("Christmas/W_Xmas_2", function(widget,data)
    local pageChangeEvent = {}
    pageChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.curPage
    end
    local countChangeEvent = {}
    countChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.count
    end
    
    local stateChangeEvent = {}
    stateChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.state
    end
    stateChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.diamond
    end
    
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.diamond
    end
	

    widget:addDataProxy("icon",function(evt)
        return data.value.icon
    end,pageChangeEvent)
    widget:addDataProxy("name",function(evt)
        if data.value.itemType == 1 then
            local tmp = GameConfig.GiftConfig:getData(data.value.itemId)
            -- 只有卡牌和侍宠
            if tmp.idty1 == 5 or tmp.idty1 == 7 then
                return string.format(data.value.name,ch.ChristmasModel:getGiftNameById(data.value.itemId))
            else
                return data.value.name
            end
        else
            return data.value.name
        end
    end,pageChangeEvent)
    widget:addDataProxy("desc",function(evt)
        return data.value.desc
    end,pageChangeEvent)
    widget:addDataProxy("numDesc",function(evt)
        return ch.ChristmasModel:getSDXGDesc(data.value.id)
    end,pageChangeEvent)
    widget:addDataProxy("num",function(evt)
        if data.value.max > 0 then
            return ch.ChristmasModel:getSDXGNum(data.value.id)
        else
            return ""
        end
    end,countChangeEvent)
    widget:addDataProxy("price",function(evt)
        return data.value.price
    end,moneyChangeEvent)
    widget:addDataProxy("offSell",function(evt)
        return string.format(Language.OFF_SALE, data.value.sale)
    end,moneyChangeEvent)
    widget:addDataProxy("imgBg",function(evt)
        if data.value.type == 1 then
            return "aaui_card/card_bg_ld.png"
        else
            return "aaui_card/card_bg_ld1.png"
        end
    end,pageChangeEvent)
    
    widget:addDataProxy("ifCanBuy",function(evt)
        return ch.ChristmasModel:getHolidayState(data.type,data.value.id) == 1 
            and ch.MoneyModel:getDiamond() >= data.value.price
            and ch.ChristmasModel:getPartnerStateById(data.value.itemType,data.value.itemId)
    end,stateChangeEvent)
    
    widget:addDataProxy("noBuy",function(evt)
        if data.value.max == 0 or ch.ChristmasModel:getSDXGNum(data.value.id) > 0 then
            ch.ChristmasModel:setHolidayState(data.type,data.value.id,1)
        else
            ch.ChristmasModel:setHolidayState(data.type,data.value.id,2)
        end
        return data.value.max == 0 or ch.ChristmasModel:getSDXGNum(data.value.id) > 0
    end,countChangeEvent)
    
    widget:addDataProxy("isHot",function(evt)
        return false
    end)
    widget:addDataProxy("isNew",function(evt)
        return false
    end)
    widget:addCommond("buyNew",function()
        local buy = function()
            ch.NetworkController:getHolidayReward(data.type,data.value.id,data.value.day)
            ch.ChristmasModel:addSDXGNum(data.value.id,1)
        end
        local tmp = {price = data.value.price,buy = buy}
        ch.ShopModel:getCostTips(tmp)
    end)
end)

-- 圣诞活动兑换界面
zzy.BindManager:addFixedBind("Christmas/W_Xmas_txt_DH", function(widget)
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.MoneyModel.dataType.cSock
    end
    
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()
    
    widget:addDataProxy("time",function(evt)
--        local str = os.date(Language.src_clickhero_view_ChristmasView_5,tonumber(ch.ChristmasModel:getOpenTimeByType(1001)))
--        str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getEndTimeByType(1001)))
--        return str
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(1001)) - os_time()
        return ch.NumberHelper:cdTimeToString(time)
    end)
    widget:addDataProxy("num",function(evt)
        return ch.MoneyModel:getCSock()
    end,moneyChangeEvent)
    widget:addDataProxy("list",function(evt)
        local items = {}
        local tmpData = ch.ChristmasModel:getCSVDataByType(1001)
        if tmpData then
            for k,v in pairs(tmpData) do
                table.insert(items,{type=ch.ChristmasModel:getCurPage(),value=v})
            end
        end
        return items
    end)
    
    widget:addDataProxy("isFree",function(evt)
        return true
    end,moneyChangeEvent)
    widget:addDataProxy("noFree",function(evt)
        return true
    end,moneyChangeEvent)
    widget:addDataProxy("canBuy",function(evt)
        return true
    end,moneyChangeEvent)
    widget:addCommond("get",function()
        ch.NetworkController:dhMoneyGet(1)
    end)
    widget:addCommond("buy",function()
        ch.NetworkController:dhMoneyGet(0)
    end)
end)

-- 圣诞活动签到界面
zzy.BindManager:addFixedBind("Christmas/W_Xmas_txt_QD", function(widget)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()
    
    widget:addDataProxy("time",function(evt)
--        local str = os.date(Language.src_clickhero_view_ChristmasView_5,tonumber(ch.ChristmasModel:getOpenTimeByType(1002)))
--        str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getEndTimeByType(1002)))
--        return str
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(1002)) - os_time()
        return ch.NumberHelper:cdTimeToString(time)
    end)

    widget:addDataProxy("list",function(evt)
        local items = {}
        local tmpData = ch.ChristmasModel:getCSVDataByType(1002)
        if tmpData then
            for k,v in pairs(tmpData) do
                table.insert(items,{type=ch.ChristmasModel:getCurPage(),value=v})
            end
        end
        return items
    end)
end)

--连续充值2037
zzy.BindManager:addFixedBind("Christmas/W_Xmas_txt_LXCZ", function(widget)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()
    
    widget:addDataProxy("time",function(evt)
--        local str = os.date(Language.src_clickhero_view_ChristmasView_5,tonumber(ch.ChristmasModel:getOpenTimeByType(1002)))
--        str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getEndTimeByType(1002)))
--        return str
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(2037)) - os_time()
        return ch.NumberHelper:cdTimeToString(time)
    end)

    widget:addDataProxy("desc",function(evt)
        return Language.src_clickhero_view_ChristmasView_desc_lxcz
    end)

    widget:addDataProxy("list",function(evt)
        local items = {}
        local tmpData = ch.ChristmasModel:getCSVDataByType(2037)
        if tmpData then
            for k,v in pairs(tmpData) do
                table.insert(items,{type=ch.ChristmasModel:getCurPage(),value=v})
            end
        end
        return items
    end)
end)

--月末飞升2035
zzy.BindManager:addFixedBind("Christmas/W_Xmas_txt_YMFS", function(widget)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()
    
    widget:addDataProxy("time",function(evt)
--        local str = os.date(Language.src_clickhero_view_ChristmasView_5,tonumber(ch.ChristmasModel:getOpenTimeByType(1002)))
--        str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getEndTimeByType(1002)))
--        return str
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(2035)) - os_time()
        return ch.NumberHelper:cdTimeToString(time)
    end)

    widget:addDataProxy("desc",function(evt)
        return Language.src_clickhero_view_ChristmasView_desc_ymfs
    end)
    
    widget:addDataProxy("img",function(evt)
        return GameConst.HOLIDAY_ITEM_DATA["hd" .. 2035].img
    end)

    widget:addDataProxy("list",function(evt)
        local items = {}
        local tmpData = ch.ChristmasModel:getCSVDataByType(2035)
        if tmpData then
            for k,v in pairs(tmpData) do
                table.insert(items,{type=ch.ChristmasModel:getCurPage(),value=v})
            end
        end
        return items
    end)
end)

-- 圣诞活动限购界面
zzy.BindManager:addFixedBind("Christmas/W_Xmas_txt_XG", function(widget)
    local nextdayChangeEvent = {}
    nextdayChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.nextday
    end
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()
    
    widget:addDataProxy("time",function(evt)
--        local str = os.date(Language.src_clickhero_view_ChristmasView_5,tonumber(ch.ChristmasModel:getOpenTimeByType(1003)))
--        str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getEndTimeByType(1003)))
--        return str
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(1003)) - os_time()
        return ch.NumberHelper:cdTimeToString(time)
    end)
    widget:addDataProxy("desc",function(evt)
        return GameConst.HOLIDAY_GIFT_DESC[ch.ChristmasModel:getCfgidByType(1003)] or ""
    end)

    widget:addDataProxy("tips",function(evt)
        return ""
    end)

   local  Text_tips
    widget:addDataProxy("list",function(evt)
        local items = {}
        local tmpData = ch.ChristmasModel:getCSVDataByType(1003)
        if tmpData then
            for k,v in pairs(tmpData) do
                table.insert(items,{type=ch.ChristmasModel:getCurPage(),value=v})
            end
        end
        return items
    end,nextdayChangeEvent)
end)

-- 圣诞活动坚守阵地界面
zzy.BindManager:addFixedBind("Christmas/W_Xmas_txt_JS", function(widget)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()

    widget:addDataProxy("time",function(evt)
--        local str = os.date(Language.src_clickhero_view_ChristmasView_5,tonumber(ch.ChristmasModel:getOpenTimeByType(1004)))
--        str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getEndTimeByType(1004)))
--        return str
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(1004)) - os_time()
        return ch.NumberHelper:cdTimeToString(time)
    end)

    widget:addDataProxy("list",function(evt)
        local items = {}
        local tmpData = ch.ChristmasModel:getCSVDataByType(1004)
        if tmpData then
            for k,v in pairs(tmpData) do
                table.insert(items,{type=ch.ChristmasModel:getCurPage(),value=v})
            end
        end
        table.sort(items,function(t1,t2)
            return t1.value.index < t2.value.index
        end)
        return items
    end)
end)

-- 圣诞活动魔宠竞技界面
zzy.BindManager:addFixedBind("Christmas/W_Xmas_txt_JJ", function(widget)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()

    widget:addDataProxy("time",function(evt)
--        local str = os.date(Language.src_clickhero_view_ChristmasView_5,tonumber(ch.ChristmasModel:getOpenTimeByType(1005)))
--        str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getEndTimeByType(1005)))
--        return str
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(1005)) - os_time()
        return ch.NumberHelper:cdTimeToString(time)
    end)

    widget:addDataProxy("list",function(evt)
        local items = {}
        local tmpData = ch.ChristmasModel:getCSVDataByType(1005)
        if tmpData then
            for k,v in pairs(tmpData) do
                table.insert(items,{type=ch.ChristmasModel:getCurPage(),value=v})
            end
        end
        table.sort(items,function(t1,t2)
            return t1.value.index < t2.value.index
        end)
        return items
    end)
end)

-- 掠夺次数活动界面
zzy.BindManager:addFixedBind("Christmas/W_Xmas_txt_LD", function(widget)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()

    widget:addDataProxy("time",function(evt)
--        local str = os.date(Language.src_clickhero_view_ChristmasView_5,tonumber(ch.ChristmasModel:getOpenTimeByType(1018)))
--        str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getEndTimeByType(1018)))
--        return str
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(1018)) - os_time()
        return ch.NumberHelper:cdTimeToString(time)
    end)

    widget:addDataProxy("list",function(evt)
        local items = {}
        local tmpData = ch.ChristmasModel:getCSVDataByType(1018)
        if tmpData then
            for k,v in pairs(tmpData) do
                table.insert(items,{type=ch.ChristmasModel:getCurPage(),value=v})
            end
        end
        table.sort(items,function(t1,t2)
            return t1.value.index < t2.value.index
        end)
        return items
    end)
end)

-- 元旦活动红包界面
zzy.BindManager:addFixedBind("Christmas/W_redbag", function(widget)
    local openChangeEvent = {}
    openChangeEvent[ch.ChristmasModel.redbagOpenEventType] = false
    
    local redbagChangeEvent = {}
    redbagChangeEvent[ch.ChristmasModel.redbagChangeEventType] = false
    
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()

    widget:addDataProxy("time",function(evt)
--        local str = os.date(Language.src_clickhero_view_ChristmasView_5,tonumber(ch.ChristmasModel:getOpenTimeByType(1007)))
--        str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getEndTimeByType(1007)))
--        return str
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(1007)) - os_time()
        return Language.HOLIDAY_DIAMOND_WHEEL_CDTIME .."\n\n".. ch.NumberHelper:cdTimeToString(time)
    end)

    widget:addDataProxy("rewardIcon",function(evt)
        return "aaui_icon/shop9.png"
    end)
    widget:addDataProxy("rewardNum",function(evt)
        return "X".. ch.ChristmasModel:getRedBagReward()
    end,redbagChangeEvent)
    widget:addDataProxy("getNum",function(evt)
        return ch.ChristmasModel:getRedBagOpenNum()
    end,redbagChangeEvent)
    widget:addDataProxy("getDiamond",function(evt)
        return ch.ChristmasModel:getRedBagGetDiamond()
    end,redbagChangeEvent)
    widget:addDataProxy("canNum",function(evt)
        return ch.ChristmasModel:getRedBagNoOpenNum()
    end,redbagChangeEvent)
    widget:addDataProxy("limitNum",function(evt)
        return ch.ChristmasModel:getRedBagDiamond()
    end,redbagChangeEvent)
    
    widget:addDataProxy("ifGetPanel",function(evt)
        -- 获得显示
        if ch.ChristmasModel:getRedBagReward() > 0 and ch.ChristmasModel.openRedBag then
            widget:playEffect("redbagOpenEff2")
            widget:playEffect("redbagOpenEff",false,function()
                ch.ChristmasModel.openRedBag = false
                    widget:noticeDataChange("ifGetPanel")
                    widget:noticeDataChange("noOpen")
                end)
        end
        return ch.ChristmasModel:getRedBagReward() > 0 and ch.ChristmasModel.openRedBag
    end,openChangeEvent)
    
    -- 红包部分不显示
    widget:addDataProxy("ifName",function(evt)
        return false
    end)
    -- 红包部分显示
    widget:addDataProxy("ifIcon",function(evt)
        return true
    end)
    widget:addDataProxy("noOpen",function(evt)
        return not ch.ChristmasModel.openRedBag
    end)
    
    widget:addDataProxy("canOpen",function(evt)
        -- 可开启红包
        if ch.ChristmasModel:getRedBagNoOpenNum() > 0 then
            widget:playEffect("redbagGetEff",true)
        else
            widget:stopEffect("redbagGetEff")
        end
        return ch.ChristmasModel:getRedBagNoOpenNum() > 0
    end,redbagChangeEvent)
    
    widget:addCommond("openRedbag",function()
        ch.NetworkController:openRedBag()
        ch.ChristmasModel.openRedBag = false
        widget:noticeDataChange("ifGetPanel")
        widget:noticeDataChange("noOpen")
    end)
end)

-- 双倍魔宠试炼界面
zzy.BindManager:addFixedBind("Christmas/W_double_mcsl", function(widget)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()

    widget:addDataProxy("time",function(evt)
--        local str = os.date(Language.src_clickhero_view_ChristmasView_6,tonumber(ch.ChristmasModel:getOpenTimeByType(1008)))
--        str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getEndTimeByType(1008)))
--        return str
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(1008)) - os_time()
        return ch.NumberHelper:cdTimeToString(time)
    end)

    widget:addCommond("openMCSL",function()
        if ch.StatisticsModel:getMaxLevel() > GameConst.CARD_FB_OPEN_LEVEL then
            ch.UIManager:cleanGamePopupLayer(true)
            ch.UIManager:showGamePopup("cardInstance/W_cardins",nil,nil,nil,"cardInstance/W_cardins")
        else
            ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_ChristmasView_8)
        end
    end)
end)

-- 双倍祭坛掠夺界面
zzy.BindManager:addFixedBind("Christmas/W_double_jt", function(widget)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()
    
    widget:addDataProxy("time",function(evt)
--        local str = os.date(Language.src_clickhero_view_ChristmasView_6,tonumber(ch.ChristmasModel:getOpenTimeByType(1009)))
--        str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getEndTimeByType(1009)))
--        return str
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(1009)) - os_time()
        return ch.NumberHelper:cdTimeToString(time)
    end)

    widget:addCommond("openJT",function()
        if ch.StatisticsModel:getMaxLevel() > GameConst.ALTAR_OPEN_LEVEL[1] then
            if ch.AltarModel:isRobOpen() then
                ch.UIManager:cleanGamePopupLayer(true,true)
                ch.NetworkController:altarPanel(ch.AltarModel:getCurAltarSelect())
                ch.UIManager:showGamePopup("card/W_jt_main")
            else
                ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_ChristmasView_9)
            end
        else
            ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_ChristmasView_8)
        end
    end)
end)

-- 双倍体力领取界面
zzy.BindManager:addFixedBind("Christmas/W_double_tl", function(widget)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()

    widget:addDataProxy("time",function(evt)
--        local str = os.date(Language.src_clickhero_view_ChristmasView_6,tonumber(ch.ChristmasModel:getOpenTimeByType(1010)))
--        str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getEndTimeByType(1010)))
--        return str
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(1010)) - os_time()
        return ch.NumberHelper:cdTimeToString(time)
    end)

    widget:addCommond("openTL",function()
        if ch.StatisticsModel:getMaxLevel() > GameConst.CARD_FB_OPEN_LEVEL then
            ch.UIManager:cleanGamePopupLayer(true)
            ch.UIManager:showGamePopup("MainScreen/W_Activity")
        else
            ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_ChristmasView_8)
        end
    end)
end)

-- 矿区翻倍界面
zzy.BindManager:addFixedBind("Christmas/W_double_kqfb", function(widget)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()

    widget:addDataProxy("time",function(evt)
        --        local str = os.date(Language.src_clickhero_view_ChristmasView_6,tonumber(ch.ChristmasModel:getOpenTimeByType(1020)))
        --        str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getEndTimeByType(1020)))
        --        return str
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(1020)) - os_time()
        return ch.NumberHelper:cdTimeToString(time)
    end)

    widget:addCommond("openKQFB",function()
        if ch.StatisticsModel:getMaxLevel() > GameConst.MINE_OPEN_LEVEL then
            ch.UIManager:cleanGamePopupLayer(true)
            
            ch.NetworkController:minePanel()
            ch.NetworkController:minePageData(ch.MineModel:getMyMineZone())
            ch.UIManager:showGamePopup("CardPit/W_pit")
        else
            ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_ChristmasView_8)
        end
    end)
end)


-- 充值返礼界面
zzy.BindManager:addFixedBind("Christmas/W_CZXL", function(widget)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()

    widget:addDataProxy("time",function(evt)
--        local str = os.date(Language.src_clickhero_view_ChristmasView_6,tonumber(ch.ChristmasModel:getOpenTimeByType(1011)))
--        str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getEndTimeByType(1011)))
--        return str
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(1011)) - os_time()
        return ch.NumberHelper:cdTimeToString(time)
    end)

    widget:addDataProxy("list",function(evt)
        local items = {}
        local tmpData = ch.ChristmasModel:getCSVDataByType(1011)
        if tmpData then
            for k,v in pairs(tmpData) do
                table.insert(items,{type=ch.ChristmasModel:getCurPage(),value=v})
            end
        end
        table.sort(items,function(t1,t2)
            return t1.value.index < t2.value.index
        end)
        return items
    end)
end)


-- 充值返礼单元
zzy.BindManager:addCustomDataBind("Christmas/W_CZXL_unit", function(widget,data)
    local pageChangeEvent = {}
    pageChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.curPage
    end
    local stateChangeEvent = {}
    stateChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.curPage 
            or evt.dataType == ch.ChristmasModel.dataType.czxl
    end
    widget:addDataProxy("maxNum",function(evt)
        return ch.CommonFunc:getMoneyByDiamond(data.value.max)
    end,pageChangeEvent)
    widget:addDataProxy("addNum",function(evt)
        local num = data.value.max-ch.ChristmasModel:getHDataByType(1011).diamond
        if num < 0 then
            num = 0
        end
        return ch.CommonFunc:getMoneyByDiamond(num)
    end,stateChangeEvent)
    widget:addDataProxy("icon1",function(evt)
        return data.value.giftIcon1
    end,pageChangeEvent)
    widget:addDataProxy("num1",function(evt)
        return data.value.giftNum1
    end,pageChangeEvent)
    widget:addDataProxy("noGet1",function(evt)
        local state = ch.ChristmasModel:getHDataByType(1011).getReward[tostring(data.value.id)]
        return not state or state == 1
    end,stateChangeEvent)
    widget:addDataProxy("canGet1",function(evt)
        local state = ch.ChristmasModel:getHDataByType(1011).getReward[tostring(data.value.id)]
        return data.value.max<=ch.ChristmasModel:getHDataByType(1011).diamond and (not state or state ~= 1)
    end,stateChangeEvent)
    
    widget:addDataProxy("hasTwo",function(evt)
        if data.value.giftNum2 and data.value.giftNum2 > 0 then
            return true
        else
            return false
        end
    end,pageChangeEvent)
    widget:addDataProxy("icon2",function(evt)
        if data.value.giftNum2 and data.value.giftNum2 > 0 then
            return data.value.giftIcon2
        else
            return data.value.giftIcon1
        end
        return 
    end,pageChangeEvent)
    widget:addDataProxy("num2",function(evt)
        if data.value.giftNum2 and data.value.giftNum2 > 0 then
            return data.value.giftNum2
        else
            return data.value.giftNum1
        end
    end,pageChangeEvent)
    widget:addDataProxy("noGet2",function(evt)
        local state = ch.ChristmasModel:getHDataByType(1011).getReward[tostring(data.value.id)]
        return not state or state == 2
    end,stateChangeEvent)
    widget:addDataProxy("canGet2",function(evt)
        local state = ch.ChristmasModel:getHDataByType(1011).getReward[tostring(data.value.id)]
        return data.value.max<=ch.ChristmasModel:getHDataByType(1011).diamond and (not state or state ~= 2)
    end,stateChangeEvent)

    widget:addCommond("getReward",function(widget,arg)
        local rty = tonumber(arg)
        ch.NetworkController:getCZXLReward(data.value.id,rty)
    end)
end)


-- 累计充值界面
zzy.BindManager:addFixedBind("Christmas/W_CZFH", function(widget)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()

    widget:addDataProxy("time",function(evt)
--        local str = os.date(Language.src_clickhero_view_ChristmasView_6,tonumber(ch.ChristmasModel:getOpenTimeByType(1011)))
--        str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getEndTimeByType(1011)))
--        return str
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(1011)) - os_time()
        return ch.NumberHelper:cdTimeToString(time)
    end)

    widget:addDataProxy("list",function(evt)
        local items = {}
        local tmpData = ch.ChristmasModel:getCSVDataByType(1011)
        if tmpData then
            for k,v in pairs(tmpData) do
                table.insert(items,{type=ch.ChristmasModel:getCurPage(),value=v})
            end
        end
        table.sort(items,function(t1,t2)
            return t1.value.index < t2.value.index
        end)
        return items
    end)
end)

-- 充值返礼单元
zzy.BindManager:addCustomDataBind("Christmas/W_CZFH_unit", function(widget,data)
    local pageChangeEvent = {}
    pageChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.curPage
    end
    local stateChangeEvent = {}
    stateChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.curPage 
            or evt.dataType == ch.ChristmasModel.dataType.czxl
    end
    widget:addDataProxy("num",function(evt)
        local num = data.value.max-ch.ChristmasModel:getHDataByType(1011).diamond
        if num < 0 then
            num = 0
        end
--         return string.format(Language.src_clickhero_view_ChristmasView_10,ch.CommonFunc:getMoneyByDiamond(num),ch.CommonFunc:getCoinName())
		return string.format(Language.src_clickhero_view_ChristmasView_10,num,Language.MSG_PAYCOIN)
    end,stateChangeEvent)
    widget:addDataProxy("name",function(evt)
        return data.value.name
    end,pageChangeEvent)
    widget:addDataProxy("desc",function(evt)
--         return string.format(Language.src_clickhero_view_ChristmasView_13,ch.CommonFunc:getMoneyByDiamond(data.value.max),ch.CommonFunc:getCoinName())    
		return string.format(Language.src_clickhero_view_ChristmasView_13,data.value.max,Language.MSG_PAYCOIN)    
    end,pageChangeEvent)
    widget:addDataProxy("icon",function(evt)
        return data.value.giftIcon1
    end,pageChangeEvent)

    widget:addDataProxy("noGet",function(evt)
        local state = ch.ChristmasModel:getHDataByType(1011).getReward[tostring(data.value.id)]
        return not state
    end,stateChangeEvent)
    widget:addDataProxy("canGet",function(evt)
        local state = ch.ChristmasModel:getHDataByType(1011).getReward[tostring(data.value.id)]
        return data.value.max<=ch.ChristmasModel:getHDataByType(1011).diamond and (not state)
    end,stateChangeEvent)

    widget:addCommond("getReward",function()
        ch.NetworkController:getCZXLReward(data.value.id,1)
    end)
end)

-- 消耗返礼界面
zzy.BindManager:addFixedBind("Christmas/W_XHFL", function(widget)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()

    widget:addDataProxy("time",function(evt)
--        local str = os.date(Language.src_clickhero_view_ChristmasView_6,tonumber(ch.ChristmasModel:getOpenTimeByType(1012)))
--        str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getEndTimeByType(1012)))
--        return str
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(1012)) - os_time()
        return ch.NumberHelper:cdTimeToString(time)
    end)

    widget:addDataProxy("list",function(evt)
        local items = {}
        local tmpData = ch.ChristmasModel:getCSVDataByType(1012)
        if tmpData then
            for k,v in pairs(tmpData) do
                table.insert(items,{type=ch.ChristmasModel:getCurPage(),value=v})
            end
        end
        table.sort(items,function(t1,t2)
            return t1.value.index < t2.value.index
        end)
        return items
    end)
end)

-- 消耗返礼单元
zzy.BindManager:addCustomDataBind("Christmas/W_XHFL_unit", function(widget,data)
    local pageChangeEvent = {}
    pageChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.curPage
    end
    local stateChangeEvent = {}
    stateChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.curPage 
            or evt.dataType == ch.ChristmasModel.dataType.xhfl
    end
    widget:addDataProxy("num",function(evt)
        local num = data.value.max-ch.ChristmasModel:getHDataByType(1012).diamond
        if num < 0 then
            num = 0
        end
        return string.format(Language.src_clickhero_view_ChristmasView_11,num)
    end,stateChangeEvent)
    widget:addDataProxy("name",function(evt)
        return string.format(data.value.name,ch.ChristmasModel:getGiftNameById(data.value.giftid1))
    end,pageChangeEvent)
    widget:addDataProxy("desc",function(evt)
        return data.value.desc
    end,pageChangeEvent)
    widget:addDataProxy("icon",function(evt)
        return data.value.giftIcon1
    end,pageChangeEvent)

    widget:addDataProxy("noGet",function(evt)
        local state = ch.ChristmasModel:getHDataByType(1012).getReward[tostring(data.value.id)]
        return not state
    end,stateChangeEvent)
    widget:addDataProxy("canGet",function(evt)
        local state = ch.ChristmasModel:getHDataByType(1012).getReward[tostring(data.value.id)]
        return data.value.max<=ch.ChristmasModel:getHDataByType(1012).diamond and (not state)
    end,stateChangeEvent)

    widget:addCommond("getReward",function()
        ch.NetworkController:getXHFLReward(data.value.id,1)
    end)
end)

-- 魔宠试炼双倍CP界面
zzy.BindManager:addFixedBind("Christmas/W_Love", function(widget)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()

    widget:addDataProxy("time",function(evt)
--        local str = os.date(Language.src_clickhero_view_ChristmasView_6,tonumber(ch.ChristmasModel:getOpenTimeByType(1013)))
--        str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getEndTimeByType(1013)))
--        return str
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(1013)) - os_time()
        return ch.NumberHelper:cdTimeToString(time)
    end)
    
    widget:addDataProxy("desc",function(evt)
        return Language.HOLIDAY_LOVE_DESC[ch.ChristmasModel:getCfgidByType(1013)]
    end)
    
    widget:addCommond("openMCSL",function()
        if ch.StatisticsModel:getMaxLevel() > GameConst.CARD_FB_OPEN_LEVEL then
            ch.UIManager:cleanGamePopupLayer(true)
            ch.UIManager:showGamePopup("cardInstance/W_cardins",nil,nil,nil,"cardInstance/W_cardins")
        else
            ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_ChristmasView_8)
        end
    end)

    widget:addDataProxy("list",function(evt)
        local items = {}
        local tmpData = ch.ChristmasModel:getCSVDataByType(1013)
        if tmpData then
            for k,v in pairs(tmpData) do
                table.insert(items,{type=ch.ChristmasModel:getCurPage(),value=v})
            end
        end
        table.sort(items,function(t1,t2)
            return t1.value.id < t2.value.id
        end)
        return items
    end)
end)

-- 魔宠试炼双倍CP单元
zzy.BindManager:addCustomDataBind("Christmas/W_Love_CP", function(widget,data)
    local pageChangeEvent = {}
    pageChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.curPage
    end
    local stateChangeEvent = {}
    stateChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.curPage 
            or evt.dataType == ch.ChristmasModel.dataType.nextday
    end

    widget:addDataProxy("name",function(evt)
        local group = zzy.StringUtils:split(data.value.group,"|")
        local cardName1 = ""
        local cardName2 = ""
        if group[1] and group[1] ~= "" then
            cardName1 = GameConfig.CardConfig:getData(tonumber(group[1])).name
        end
        if group[2] and group[2] ~= "" then
            cardName2 = GameConfig.CardConfig:getData(tonumber(group[2])).name
        end
        return string.format(data.value.name,cardName1,cardName2)
    end,pageChangeEvent)
    widget:addDataProxy("desc",function(evt)
        return data.value.desc
    end,pageChangeEvent)
    widget:addDataProxy("cardIcon1",function(evt)
        local group = zzy.StringUtils:split(data.value.group,"|")
        if group[1] and group[1] ~= "" then
            return GameConfig.CardConfig:getData(tonumber(group[1])).mini
        else
            return "res/icon/dot1.png"
        end
    end,pageChangeEvent)
    widget:addDataProxy("cardIcon2",function(evt)
        local group = zzy.StringUtils:split(data.value.group,"|")
        if group[2] and group[2] ~= "" then
            return GameConfig.CardConfig:getData(tonumber(group[2])).mini
        else
            return "res/icon/dot1.png"
        end
    end,pageChangeEvent)
    
    widget:addDataProxy("ifHaveTwo",function(evt)
        local group = zzy.StringUtils:split(data.value.group,"|")
        return group[2] and group[2] ~= ""
    end,pageChangeEvent)
    widget:addDataProxy("isToday",function(evt)
        return data.value.id == ch.ChristmasModel:getHDataByType(1013).day
    end,stateChangeEvent)
end)


local getBoneOffset = function(ani,boneName)
    local boneP = ani:getBone(boneName):getWorldInfo():getPosition()
    local newX = boneP.x * ani:getScaleX()
    local newY = boneP.y * ani:getScaleY()
    return cc.p(newX,newY)
end

-- 年兽
zzy.BindManager:addFixedBind("Christmas/W_NianShou", function(widget)
    local hpChangeEvent = {}
    hpChangeEvent[ch.ChristmasModel.nianDataChangedEventType] = function (evt)
        return evt.dataType == ch.ChristmasModel.nianDataType.hp
    end
    local killedChangedEvent = {}
    killedChangedEvent[ch.ChristmasModel.nianDataChangedEventType] = function (evt)
    	return evt.dataType == ch.ChristmasModel.nianDataType.killed
    end
    local fcChangedEvent = {}
    fcChangedEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.firecracker
    end
    
    local showTimeChangedEvent = {}
    showTimeChangedEvent[ch.ChristmasModel.nianDataChangedEventType] = function (evt)
        return evt.dataType == ch.ChristmasModel.nianDataType.showTime
    end
    local isPlaying = false
    
    local time= "00:00:00"
    local cdTimeId
    widget:addDataProxy("killedCount",function(evt)
        return string.format(Language.CHRISTMAS_VIEW_NIAN_2,ch.ChristmasModel:getNiankilled())
    end)
    widget:addDataProxy("leftHp",function(evt)
        if ch.ChristmasModel:getNiankilled() == GameConst.CXHD_BASHNIAN_BASH_MAX or
            ch.ChristmasModel:getNianShowTime() > os_time() then
            return 0
        end    
        return ch.ChristmasModel:getNianHp()
    end)
    
    widget:addDataProxy("leftHpProgress",function(evt)
        if ch.ChristmasModel:getNiankilled() == GameConst.CXHD_BASHNIAN_BASH_MAX or
            ch.ChristmasModel:getNianShowTime() > os_time() then
            return 0
        end
        return 100 *ch.ChristmasModel:getNianHp()/GameConst.CXHD_BASHNIAN_BOSS_HP
    end)  
    
    widget:addDataProxy("fcNum",function(evt)
        return ch.MoneyModel:getFirecracker()
    end,fcChangedEvent)
    
    widget:addDataProxy("cdTime",function(evt)
        return time
    end)
    
    widget:addDataProxy("clearCDPrice",function(evt)
        return GameConst.CXHD_BASHNIAN_FLASH_PRICE
    end)
    
    widget:addDataProxy("buyPrice",function(evt)
        return GameConst.CXHD_BASHNIAN_FIRECRACKER_PRICE
    end)
    
    widget:addDataProxy("isCD",function(evt)
        return ch.ChristmasModel:getNiankilled() < GameConst.CXHD_BASHNIAN_BASH_MAX and os_time() < ch.ChristmasModel:getNianShowTime()
    end)
    
    widget:addDataProxy("isKilled",function(evt)
        return ch.ChristmasModel:getNiankilled() == GameConst.CXHD_BASHNIAN_BASH_MAX
    end)
    
    widget:addDataProxy("canBuy",function(evt)
        return ch.ChristmasModel:getNiankilled() < GameConst.CXHD_BASHNIAN_BASH_MAX
    end)
    
    widget:addDataProxy("backGround",function(evt)
        return "res/img/nian_shou_BG.png"
    end)
    
    
    local role = nil
    local fcEffect = nil
    local panel = widget:getChild("Panel_nianshou")
    
    
    local addNian = function()
        ch.RoleResManager:load("nianshou",function()
            if zzy.CocosExtra.isCobjExist(widget) then
                role = ccs.Armature:create("nianshou")
                role:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
                    if movementID == "crush" and movementType == ccs.MovementEventType.complete then
                        role:getAnimation():play("move",-1,1)
                    end
                end)
                role:getAnimation():setSpeedScale(0.8)
                role:getAnimation():play("move",-1,1)
                role:setPositionX(320)
                panel:addChild(role)
            else
                ch.RoleResManager:release("nianshou")
            end
        end)
    end
    
    local addHarmNum = function(text)
        local textWidget = ccui.TextBMFont:create(text, "res/ui/aaui_font/font_red.fnt")
        local p = getBoneOffset(role,"top")
        p = role:convertToWorldSpace(p)
        p = panel:convertToNodeSpace(p)
        textWidget:setPosition(p)
        panel:addChild(textWidget)
        textWidget:runAction(cc.EaseOut:create(cc.MoveBy:create(0.6, cc.vertex2F(-50, 200)), 0.6))
        textWidget:runAction(cc.Sequence:create(cc.EaseOut:create(cc.FadeOut:create(0.6), 0.6), cc.CallFunc:create(function()
            textWidget:removeFromParent()
        end)))
    end
    
    local removeNian = function()
    	if role then
            role:removeFromParent()
            role = nil
            ch.RoleResManager:release("nianshou")
    	end
    end
    
    local startCutDown = function()
        local endTime = ch.ChristmasModel:getNianShowTime()
        cdTimeId = widget:listen(zzy.Events.TickEventType,function(obj,evt)
            local now = os_time();
            local cd = endTime - now
            if cd > 0 then
                local second = math.floor(cd%60)
                cd = cd/60
                local min = math.floor(cd%60)
                cd = cd/60
                local hour = math.floor(cd)
                time = string.format("%02d:%02d:%02d",hour,min,second)
                widget:noticeDataChange("cdTime")
            else
                addNian()
                ch.ChristmasModel:setNianHp(GameConst.CXHD_BASHNIAN_BOSS_HP)
                widget:noticeDataChange("isCD")
                widget:noticeDataChange("leftHp")
                widget:noticeDataChange("leftHpProgress")
                widget:unListen(cdTimeId)
                cdTimeId = nil
            end
        end)
    end

    local stopCutDown = function()
        if cdTimeId then
            widget:unListen(cdTimeId)
            cdTimeId = nil
        end
    end
    
    local speed = 400
    local roleRun = function()
        local id
        local lastTime = os_clock()
        isPlaying = true
        id = widget:listen(zzy.Events.TickEventType,function(obj,evt)
            local now = os_clock()
            if role:getPositionX() <-200 then
                removeNian()
                isPlaying = false
                startCutDown()
                widget:noticeDataChange("isCD")
                widget:unListen(id)
            else
                local x = role:getPositionX() - 400 *(now - lastTime)
                role:setPositionX(x)
            end
            lastTime = now
        end)
    end
    
    local roleDie = function()
        isPlaying = true
        role:runAction(cc.Sequence:create(cc.Blink:create(0.5,10), cc.CallFunc:create(function()
            if zzy.CocosExtra.isCobjExist(role) then
                removeNian()
                isPlaying = false
                widget:noticeDataChange("isKilled")
                widget:noticeDataChange("canBuy")
            end
        end)))
    end
    
    local resCount = {}
    for i=1,#ch.goldLayer.resName do
        resCount[i] = 0
    end
    local dropLayer = cc.Layer:create()
    panel:addChild(dropLayer,1)
    
    local createAni = function(px,py,num,type)
        resCount[type] = resCount[type] +  num
        for i = 1,num do
            local ani = ccs.Armature:create(ch.goldLayer.resName[type])
            local zhuanName = "zhuan"
            local faguangName = "faguang"
            if type == 4 then
                zhuanName = "zhuan_1"
                faguangName = "faguang_1"
            end
            ani:getAnimation():play(zhuanName)
            ani:setPosition(px, py)
            dropLayer:addChild(ani)
            ani.faguangName = faguangName
            ani.vx = math.random(GameConst.GOLD_DROP_FLY_MIN_VX, GameConst.GOLD_DROP_FLY_MAX_VX)
            ani.vy = math.random(GameConst.GOLD_DROP_FLY_MIN_VY, GameConst.GOLD_DROP_FLY_MAX_VY)
            ani:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
                if (movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete)
                    and movementID == faguangName then
                    ani:removeFromParent()
                    resCount[type] = resCount[type] - 1
                    if resCount[type] == 0 then
                        if type~= 1 and type ~= 4 then
                            ch.RoleResManager:releaseEffect(ch.goldLayer.resName[type])
                        end
                    end
                end
            end)
        end
    end
    
    local dropMoney = function(x,y,num,type)
        type = type or 1
        if type == 1 or type == 4 then
            createAni(x,y,num,type)
        elseif ch.goldLayer.resName[type] then
            ch.RoleResManager:loadEffect(ch.goldLayer.resName[type],function()
                createAni(x,y,num,type)
            end)    
        end
    end
    local lastUpdateTime = os_clock()
    widget:listen(zzy.Events.TickEventType, function()
        local curT = os_clock()
        local dt = curT - lastUpdateTime
        local anis = dropLayer:getChildren()
        for _,ani in ipairs(anis) do
            if ani.vx then
                local px,py = ani:getPosition()
                py = py + ani.vy * dt
                px = px + ani.vx * dt
                if py > 0 then
                    ani.vy = ani.vy + GameConst.GOLD_DROP_FLY_G * dt
                else
                    ani.vx = nil
                    py = 0
                    ani:getAnimation():play(ani.faguangName)
                end
                ani:setPosition(px, py)
            end
        end
        lastUpdateTime = curT
    end)
    
        --1为金币，2为魂石，3为圣光,4为大金币,5为整卡,6为荣誉,7为符文,8为鞭炮
    local getResEffectType = function(item)
    	local tp = nil
    	local type = tonumber(item.t)
        local id = tostring(item.id)
        if type == 1 then  -- 代币
            if id == ch.MoneyModel.dataType.gold then
                tp = 1
            elseif id == ch.MoneyModel.dataType.sStone then
                tp = 2
            elseif id == ch.MoneyModel.dataType.star then
                tp = 3
            elseif id == ch.MoneyModel.dataType.honour then
                tp = 6
            elseif id == ch.MoneyModel.dataType.runic then
                tp = 7
            elseif id == ch.MoneyModel.dataType.firecracker then
                tp = 8
            end
        elseif type == 4 then  -- 时长金币
            tp = 1
        elseif type == 5 then -- 卡牌
            tp= 5
        elseif type == 6 then    -- 最高关卡获得魂或魂石
            if id == "40100" then  -- 最高关卡获得魂石
                tp = 2
            end
        elseif type == 9 then  -- 通用符文包
            tp = 7
        end
        return tp
    end
    
    local dropItem = function(items)
        for k,v in ipairs(items) do
            local tp = getResEffectType(v)
            if tp then
                local p = getBoneOffset(role,"top")
                p = role:convertToWorldSpace(p)
                p = panel:convertToNodeSpace(p)
                dropMoney(p.x,p.y,1,tp)
            end
        end
    end
    
    local addFcEffect = function()
        fcEffect = ccs.Armature:create("tx_bianpao")
        local p = getBoneOffset(role,"body")
        p = role:convertToWorldSpace(p)
        p = panel:convertToNodeSpace(p)
        fcEffect:setPosition(p)
        panel:addChild(fcEffect)
        isPlaying = true
        fcEffect:getAnimation():play("huohua",-1,1)
        fcEffect:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
            if movementID == "baozha" and movementType == ccs.MovementEventType.complete then
                fcEffect:removeFromParent()
                fcEffect = nil
                widget:noticeDataChange("leftHp")
                widget:noticeDataChange("leftHpProgress")
                local reward = ch.ChristmasModel:getNianReward()
                ch.ChristmasModel:setNianReward(nil)
                addHarmNum(reward.hp)
                if reward.items then
                    dropItem(reward.items)
                end
                if ch.ChristmasModel:getNianHp() == 0 then
                    widget:noticeDataChange("killedCount")
                    if ch.ChristmasModel:getNiankilled() < GameConst.CXHD_BASHNIAN_BASH_MAX then
                        roleRun()
                    else
                        roleDie()
                    end
                    local tmpData = {}
                    tmpData.title = Language.src_clickhero_controller_NetworkController_4
                    tmpData.desc = Language.src_clickhero_controller_NetworkController_5
                    tmpData.list = reward.items
                    ch.UIManager:showGamePopup("setting/W_SNbonus",tmpData)
                else
                    isPlaying = false
                    if reward.items then
                        for k,v in ipairs(reward.items) do
                            local name = ch.CommonFunc:getRewardName(v.t,v.id)
                            local num = ch.CommonFunc:getRewardValue(v.t,v.id,v.num)
                            widget:setTimeOut((k-1)*0.2,function()
                                ch.UIManager:showUpTips(string.format("%s X%s",name,num))
                            end)
                        end
                    end
                end
            end
        end)
    end
    
    
    widget:listen(ch.ChristmasModel.nianDataChangedEventType,function(obj,evt)
        if evt.dataType == ch.ChristmasModel.nianDataType.reward then
            fcEffect:getAnimation():play("baozha",-1,0)
            ch.SoundManager:play("bianpao")
            role:getAnimation():play("crush",-1,0)
        elseif evt.dataType == ch.ChristmasModel.nianDataType.showTime then
            stopCutDown()
            addNian()
            ch.ChristmasModel:setNianHp(GameConst.CXHD_BASHNIAN_BOSS_HP)
            widget:noticeDataChange("isCD")
            widget:noticeDataChange("leftHp")
            widget:noticeDataChange("leftHpProgress")
        end
    end)
    
    widget:addCommond("buy",function()
        local msg = string.format(Language.CHRISTMAS_VIEW_NIAN_3,GameConst.CXHD_BASHNIAN_FIRECRACKER_PRICE,GameConst.CXHD_BASHNIAN_FIRECRACKER_NUM)
        ch.UIManager:showMsgBox(2,true,msg,function()
            if ch.MoneyModel:getDiamond() >= GameConst.CXHD_BASHNIAN_FIRECRACKER_PRICE then
                ch.NetworkController:buyFirecracker()
            else
                ch.UIManager:showMsgBox(1,true,Language.MSG_UNENOUGH_PAYCOIN)
            end
        end)
    end)

    widget:addCommond("clearCD",function()
        local msg = string.format(Language.CHRISTMAS_VIEW_NIAN_4,GameConst.CXHD_BASHNIAN_FLASH_PRICE)
        ch.UIManager:showMsgBox(2,true,msg,function()
            if ch.MoneyModel:getDiamond() >= GameConst.CXHD_BASHNIAN_FLASH_PRICE then
                ch.NetworkController:clearNianCD()
            else
                ch.UIManager:showMsgBox(1,true,Language.MSG_UNENOUGH_PAYCOIN)
            end
        end)
    end)

    widget:addCommond("use",function()
        if isPlaying or role == nil then return end
        if ch.MoneyModel:getFirecracker() > 0 then
            ch.NetworkController:useFirecracker()
            addFcEffect()
        else
            ch.UIManager:showUpTips(Language.CHRISTMAS_VIEW_NIAN_1)
        end
    end)
        
    ch.RoleResManager:loadEffect("tx_bianpao")
    if ch.ChristmasModel:getNiankilled() < GameConst.CXHD_BASHNIAN_BASH_MAX then
        if os_time() >= ch.ChristmasModel:getNianShowTime() then
            addNian()
        else
            startCutDown()
        end    
    end
    
    local close = widget.destory
    widget.destory = function(widget,cleanView)
        close(widget,cleanView)
        ch.RoleResManager:releaseEffect("tx_bianpao")
        if role then
            ch.RoleResManager:release("nianshou")
        end
        for k,v in ipairs(resCount) do
            if v > 0 and k~=1 and k~= 4 then
                ch.RoleResManager:releaseEffect(ch.goldLayer.resName[k])
            end
        end
    end
end)

-- 许愿池
zzy.BindManager:addFixedBind("Christmas/W_XCXY", function(widget)
   local selectChangeEvent = {}
    selectChangeEvent[ch.ChristmasModel.XY_SELECT_EVENT]=false
	
	 local xyStateChangeEvent = {}
    xyStateChangeEvent[ch.ChristmasModel.XY_STATE_CHANGE_EVENT]=false
	
	
	local dayChangeEvent = {}
    dayChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.ChristmasModel.dataType.nextday
    end
	
	local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.diamond
    end
    moneyChangeEvent[ch.ChristmasModel.XY_STATE_CHANGE_EVENT]=false
    
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("txt_xy")
        widget:noticeDataChange("txt_lj")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()

	widget:addDataProxy("txt_xy",function(evt)
--        local str = os.date(Language.src_clickhero_view_ChristmasView_6,tonumber(ch.ChristmasModel:getHDataByType(1014).time1.openTime))
--        str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getHDataByType(1014).time1.endTime))   
--        return str
        local time = tonumber(ch.ChristmasModel:getHDataByType(1014).time1.endTime) - os_time()
        if time > 0 then
            return ch.NumberHelper:cdTimeToString(time)
        else
            return Language.src_clickhero_view_ChristmasView_17
        end
    end)
	
	widget:addDataProxy("txt_lj",function(evt)
--        local str = os.date(Language.src_clickhero_view_ChristmasView_6,tonumber(ch.ChristmasModel:getHDataByType(1014).time2.openTime))
--         str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getHDataByType(1014).time2.endTime))
--        return str
        if tonumber(ch.ChristmasModel:getHDataByType(1014).time2.openTime) > os_time() then
            return Language.src_clickhero_view_ChristmasView_16
        else
            local time = tonumber(ch.ChristmasModel:getHDataByType(1014).time2.endTime) - os_time()
            return ch.NumberHelper:cdTimeToString(time)
        end
    end)
		
	widget:addCommond("xy_free",function()
        if ch.ChristmasModel:getXYSelectID() then
            ch.NetworkController:xycXY(1,ch.ChristmasModel:getXYSelectID())
		else
			ch.UIManager:showUpTips(Language.src_clickhero_view_ChristmasView_12)
        end
    end)
	
	 widget:addCommond("xy_buy",function()
        local buy = function()
            ch.NetworkController:xycXY(2)
        end
        local tmp = {price = GameConst.CXHD_WISH_ALL_PRICE,buy = buy}
        ch.ShopModel:getCostTips(tmp)
    end)

	 widget:addCommond("xy_hunshi",function()
		ch.ChristmasModel:xySelectChange(1)
    end)
	
	 widget:addCommond("btnGet1",function()
        ch.NetworkController:xycLJ(1) 
    end)
	
	 widget:addCommond("btnGet2",function()
        ch.NetworkController:xycLJ(2) 
    end)
	
	 widget:addCommond("btnGet3",function()
        ch.NetworkController:xycLJ(3) 
    end)
	
	 widget:addCommond("btnGet4",function()
        ch.NetworkController:xycLJ(4) 
    end)
	
	 widget:addCommond("xy_shengguang",function()
		ch.ChristmasModel:xySelectChange(2)
    end)
	
	 widget:addCommond("xy_fuwen",function()
		ch.ChristmasModel:xySelectChange(3)
    end)
	
	 widget:addCommond("xy_zhuanyi",function()
		ch.ChristmasModel:xySelectChange(4)
    end)
	
	widget:addDataProxy("icon_hunshi",function(evt)
         return  GameConst.MSG_FJ_BIG_ICON[1]["db90004"]
    end)
	widget:addDataProxy("icon_shenguang",function(evt)
         return  GameConst.MSG_FJ_BIG_ICON[1]["db90005"]
    end)
	widget:addDataProxy("icon_fuwen",function(evt)
        return GameConst.MSG_FJ_BIG_ICON[1]["db90011"]
    end)
	widget:addDataProxy("icon_zhuanyi",function(evt)
         return GameConst.MSG_FJ_BIG_ICON[1]["db90009"]
    end)
	
	
	
	widget:addDataProxy("btnGet1canLJ",function(evt)
          return ch.ChristmasModel:getHDataByType(1014).st["1"]==2 or   ch.ChristmasModel:getHDataByType(1014).st["1"]==3
    end,xyStateChangeEvent)
	
	widget:addDataProxy("btnGet2canLJ",function(evt)
          return ch.ChristmasModel:getHDataByType(1014).st["2"]==2 or   ch.ChristmasModel:getHDataByType(1014).st["2"]==3
    end,xyStateChangeEvent)
	
	widget:addDataProxy("btnGet3canLJ",function(evt)
          return ch.ChristmasModel:getHDataByType(1014).st["3"]==2 or   ch.ChristmasModel:getHDataByType(1014).st["3"]==3
    end,xyStateChangeEvent)
	
	widget:addDataProxy("btnGet4canLJ",function(evt)
          return ch.ChristmasModel:getHDataByType(1014).st["4"]==2 or   ch.ChristmasModel:getHDataByType(1014).st["4"]==3
    end,xyStateChangeEvent)
	
	
	widget:addDataProxy("ifCanBuyFree",function(evt)
          return not( ch.ChristmasModel:getHDataByType(1014).st["1"]~=1 or  ch.ChristmasModel:getHDataByType(1014).st["2"]~=1 
		  or  ch.ChristmasModel:getHDataByType(1014).st["3"]~=1  or  ch.ChristmasModel:getHDataByType(1014).st["4"]~=1)
    end,xyStateChangeEvent)
	
	widget:addDataProxy("xyVis",function(evt)
          return ch.ChristmasModel:isOpenByType(1014) and ch.ChristmasModel:getHDataByType(1014).day <=  GameConst.CXHD_WISH_MW_DAYS/3600/24 
    end,dayChangeEvent)
	
	widget:addDataProxy("ljVis",function(evt)
          return ch.ChristmasModel:isOpenByType(1014) and ch.ChristmasModel:getHDataByType(1014).day >  GameConst.CXHD_WISH_MW_DAYS/3600/24 
    end,dayChangeEvent)
	
	widget:addDataProxy("get1Vis",function(evt)
        return ch.ChristmasModel:getHDataByType(1014).st["1"]==4
    end,xyStateChangeEvent)
	
	widget:addDataProxy("get2Vis",function(evt)
          return ch.ChristmasModel:getHDataByType(1014).st["2"]==4  
    end,xyStateChangeEvent)
	
	widget:addDataProxy("get3Vis",function(evt)
        return ch.ChristmasModel:getHDataByType(1014).st["3"]==4
    end,xyStateChangeEvent)
	
	widget:addDataProxy("get4Vis",function(evt)
          return ch.ChristmasModel:getHDataByType(1014).st["4"]==4
    end,xyStateChangeEvent)
	
	widget:addDataProxy("xuyuan1Vis",function(evt)
          return ch.ChristmasModel:getHDataByType(1014).st["1"]==2  or ch.ChristmasModel:getHDataByType(1014).st["1"]==3
    end,xyStateChangeEvent)
	
	widget:addDataProxy("xuyuan2Vis",function(evt)
        return ch.ChristmasModel:getHDataByType(1014).st["2"]==2  or  ch.ChristmasModel:getHDataByType(1014).st["2"]==3
    end,xyStateChangeEvent)
	
	widget:addDataProxy("xuyuan3Vis",function(evt)
        return ch.ChristmasModel:getHDataByType(1014).st["3"]==2  or  ch.ChristmasModel:getHDataByType(1014).st["3"]==3
    end,xyStateChangeEvent)
	
	
	widget:addDataProxy("xuyuan4Vis",function(evt)
        return ch.ChristmasModel:getHDataByType(1014).st["4"]==2  or   ch.ChristmasModel:getHDataByType(1014).st["4"]==3
    end,xyStateChangeEvent)
	
	widget:addDataProxy("txt_des_vis",function(evt)
         return  ch.ChristmasModel:getXYSelectID()==nil
    end,selectChangeEvent)
	widget:addDataProxy("txt_hunshi_vis",function(evt)
          return ch.ChristmasModel:getXYSelectID()==1
    end,selectChangeEvent)
	widget:addDataProxy("txt_shenguang_vis",function(evt)
          return ch.ChristmasModel:getXYSelectID()==2
    end,selectChangeEvent)
	widget:addDataProxy("txt_fuwen_vis",function(evt)
          return ch.ChristmasModel:getXYSelectID()==3
    end,selectChangeEvent)
	widget:addDataProxy("txt_zhuanyi_vis",function(evt)
          return ch.ChristmasModel:getXYSelectID()==4
    end,selectChangeEvent)
	
	widget:addDataProxy("diamondPrice",function(evt)
          return  GameConst.CXHD_WISH_ALL_PRICE
    end)
	
	widget:addDataProxy("ifCanBuy",function(evt)
          return ch.MoneyModel:getDiamond() >= GameConst.CXHD_WISH_ALL_PRICE and (ch.ChristmasModel:getHDataByType(1014).st["1"]==1 or  ch.ChristmasModel:getHDataByType(1014).st["2"]==1 
		  or  ch.ChristmasModel:getHDataByType(1014).st["3"]==1  or  ch.ChristmasModel:getHDataByType(1014).st["4"]==1)
    end,moneyChangeEvent)

end)


-- 元宵活动兑换界面
zzy.BindManager:addFixedBind("Christmas/W_SQYX", function(widget)
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.cSock
            or evt.dataType == ch.MoneyModel.dataType.diamond
    end
    
    local hddhChangeEvent = {}
    hddhChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.hddh
    end
    
    local cfgid = ch.ChristmasModel:getCfgidByType(1001)
    local cfgData = GameConst.HOLIDAY_SDDH_MONEY_DATA[cfgid]
    
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()

    widget:addDataProxy("time",function(evt)
--        local str = os.date(Language.src_clickhero_view_ChristmasView_6,tonumber(ch.ChristmasModel:getOpenTimeByType(1001)))
--        str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getEndTimeByType(1001)))
--        return str
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(1001)) - os_time()
        return ch.NumberHelper:cdTimeToString(time)
    end)
    widget:addDataProxy("moneyText",function(evt)
        return string.format(Language.SDDH_MONEY_NAME_DESC,Language.SDDH_MONEY_NAME[cfgData.moneyType])
    end)
    widget:addDataProxy("moneyIcon",function(evt)
        return GameConst.SDDH_MONEY_ICON[cfgData.moneyType]
    end)
    widget:addDataProxy("moneyNum",function(evt)
        return ch.MoneyModel:getCSock()
    end,moneyChangeEvent)
    widget:addDataProxy("rule",function(evt)
        return string.format(Language.HOLIDAY_SDDH_RULE,Language.SDDH_MONEY_NAME[cfgData.moneyType])
    end)
    widget:addDataProxy("tips",function(evt)
        DEBUG("cfgData.moneyTyp="..cfgData.moneyType)
        local moneyName = Language.SDDH_MONEY_NAME[cfgData.moneyType]
        return string.format(Language.HOLIDAY_SDDH_DESC[1],moneyName,moneyName,moneyName)
    end)
    widget:addDataProxy("getText",function(evt)
        return string.format(Language.SDDH_MONEY_FREE_BUTTON_TEXT,Language.SDDH_MONEY_NAME[cfgData.moneyType],cfgData.freeNum)
    end)
    widget:addDataProxy("buyText",function(evt)
        return string.format(Language.SDDH_MONEY_BUY_BUTTON_TEXT,Language.SDDH_MONEY_NAME[cfgData.moneyType],cfgData.addNum)
    end)
    widget:addDataProxy("costNum",function(evt)
        return cfgData.addCost
    end)
    widget:addDataProxy("ifFree",function(evt)
        return cfgData.freeNum>0 and ch.ChristmasModel:getHDataByType(1001).lq == 0
    end,hddhChangeEvent)
    widget:addDataProxy("noFree",function(evt)
        return cfgData.addNum>0 and ch.ChristmasModel:getHDataByType(1001).lq > 0
    end,hddhChangeEvent)
    widget:addDataProxy("canBuy",function(evt)
        return ch.MoneyModel:getDiamond() >= cfgData.addCost
    end,moneyChangeEvent)
    
    widget:addDataProxy("list",function(evt)
        local items = {}
        local tmpData = ch.ChristmasModel:getCSVDataByType(1001)
        if tmpData then
            for k,v in pairs(tmpData) do
                table.insert(items,{type=ch.ChristmasModel:getCurPage(),value=v})
            end
        end
        return items
    end)

    widget:addCommond("getFree",function()
        ch.NetworkController:dhMoneyGet(1)
    end)
    widget:addCommond("buy",function()
        ch.NetworkController:dhMoneyGet(0, cfgData.addCost)
    end)
end)


-- 元宵活动兑换界面单元
zzy.BindManager:addCustomDataBind("Christmas/W_SQYX_unit", function(widget,data)
    local stateChangeEvent = {}
    stateChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.state
    end
    stateChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.cSock
    end
    local countChangeEvent = {}
    countChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.count
    end
    
    local cfgid = ch.ChristmasModel:getCfgidByType(1001)
    local cfgData = GameConst.HOLIDAY_SDDH_MONEY_DATA[cfgid]
    
    widget:addDataProxy("icon",function(evt)
        return data.value.icon
    end)
    widget:addDataProxy("iconFrame",function(evt)
        local idty = GameConfig.GiftConfig:getData(data.value.giftId).idty1
        -- 宠物或侍宠
        if idty == 2 then
            return "aaui_diban/db_petframe.png"
        elseif idty == 7 then
            return "aaui_diban/db_petframe1.png"
        else
            return "aaui_diban/db_shopicon.png"  
        end
    end)
    widget:addDataProxy("name",function(evt)
        local name = ch.ChristmasModel:getRunicNumById(data.value.giftId,data.value.giftNum,data.value.name)
        return string.format(name,ch.ChristmasModel:getGiftNameById(data.value.giftId))
    end)
    widget:addDataProxy("desc",function(evt)
        return data.value.desc
    end)

    widget:addDataProxy("costNum",function(evt)
        return data.value.price
    end)
    widget:addDataProxy("countTimes",function(evt)
        if data.value.max == 0 then
            return Language.SDDH_BUTTON_GET_MAX_TEXT
        else
            local num = ch.ChristmasModel:getDHNum(data.value.id)
            return string.format(Language.SDDH_BUTTON_GET_COUNT_TEXT,num)
        end
    end,countChangeEvent)
    widget:addDataProxy("costIcon",function(evt)
        return GameConst.SDDH_MONEY_ICON[cfgData.moneyType]
    end)
    widget:addDataProxy("noGet",function(evt)
        if data.value.max == 0 or ch.ChristmasModel:getDHNum(data.value.id) > 0 then
            ch.ChristmasModel:setHolidayState(data.type,data.value.id,1)
        else
            ch.ChristmasModel:setHolidayState(data.type,data.value.id,2)
        end
        return data.value.max == 0 or ch.ChristmasModel:getDHNum(data.value.id) > 0
    end,countChangeEvent)
    widget:addDataProxy("canGet",function(evt)
        return ch.ChristmasModel:getHolidayState(data.type,data.value.id) == 1 and ch.MoneyModel:getCSock() >= data.value.price
    end,stateChangeEvent)
    widget:addCommond("getReward",function()
        ch.NetworkController:getHolidayReward(data.type, data.value.id)
        ch.MoneyModel:addCSock(-data.value.price)
        ch.ChristmasModel:addDHNum(data.value.id,1)
    end)
end)

-- 萌宠送福单元
zzy.BindManager:addCustomDataBind("Christmas/W_Xmas_com", function(widget,data)
    local pageChangeEvent = {}
    pageChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.curPage
    end
    local stateChangeEvent = {}
    stateChangeEvent[ch.ChristmasModel.dataChangeEventType] = false

    widget:addDataProxy("icon",function(evt)
        return data.value.icon
    end,pageChangeEvent)
    widget:addDataProxy("name",function(evt)
        return data.value.name
    end,pageChangeEvent)
    widget:addDataProxy("desc",function(evt)
        return data.value.desc
    end,pageChangeEvent)

    widget:addDataProxy("ifCanGet",function(evt)
        return ch.ChristmasModel:getHolidayState(data.type,data.value.id) == 1
    end,stateChangeEvent)
    widget:addDataProxy("noGet",function(evt)
        return ch.ChristmasModel:getHolidayState(data.type,data.value.id) == 1 
            or ch.ChristmasModel:getHolidayState(data.type,data.value.id) == 3
            or ch.ChristmasModel:getHolidayState(data.type,data.value.id) == 0
    end,stateChangeEvent)

    widget:addDataProxy("btnText",function(evt)
        if ch.ChristmasModel:getHolidayState(data.type,data.value.id) == 3 then
            return Language.src_clickhero_view_FestivityView_5
        elseif ch.ChristmasModel:getHolidayState(data.type,data.value.id) == 0 then
            return Language.HOLIDAY_MCSF_BTN_TEXT
        else
            return Language.src_clickhero_view_FestivityView_6
        end
    end,stateChangeEvent)

    widget:addDataProxy("getImage",function(evt)
        if ch.ChristmasModel:getHolidayState(data.type,data.value.id) == 2 then
            return "aaui_common/state_get1.png"
        else
            return "aaui_common/state_out1.png"
        end
    end,stateChangeEvent)
    widget:addCommond("getReward",function()
        ch.NetworkController:getMCSFReward(data.value.id)
    end)
end)

-- 萌宠送福
zzy.BindManager:addFixedBind("Christmas/W_MCSF", function(widget)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()

    widget:addDataProxy("time",function(evt)
--        local str = os.date(Language.src_clickhero_view_ChristmasView_6,tonumber(ch.ChristmasModel:getOpenTimeByType(1017)))
--        str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getEndTimeByType(1017)))
--        return str
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(1017)) - os_time()
        return ch.NumberHelper:cdTimeToString(time)
    end)

    widget:addDataProxy("list",function(evt)
        local items = {}
        local tmpData = ch.ChristmasModel:getCSVDataByType(1017)
        if tmpData then
            for k,v in pairs(tmpData) do
                table.insert(items,{type=ch.ChristmasModel:getCurPage(),value=v})
            end
        end
        return items
    end)
end)

--荣耀金矿
zzy.BindManager:addFixedBind("Christmas/W_RYJK_1", function(widget)

    local l_expectedReward,l_gloryGoldlist=ch.ChristmasModel:getGloryGoldData()
    widget:addDataProxy("leftTime",function(evt)
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(1021)) - os_time()
        return ch.NumberHelper:cdTimeToString(time)

    end)

    widget:addDataProxy("expectedReward",function(evt)
        if l_expectedReward then
             return l_expectedReward
        else
             return 0
        end
    end)
    --你不在公会中
    widget:addDataProxy("isGuild",function(evt)
          
            
        return not ch.WarpathModel:isShow()
    end)
    --当前公会没有奖励
    widget:addDataProxy("isReward",function(evt)
        --有工会并且 有奖励列表的时候不显示提示
        if(ch.WarpathModel:isShow() and l_gloryGoldlist and #l_gloryGoldlist>0 ) then
            cclog("isreward fasle")
            return false 
         end
        --没有工会的时候不显示提示
        if(not ch.WarpathModel:isShow()) then
            return false
        end
        return true
    end)
    
    --[[widget:addDataProxy("isExpect",function(evt)
         local ret=(l_expectedReward==nil and false) or true
         cclog("isexpect=="..ret)
         return ret
    end)--]]
    
    widget:addCommond("descShow",function()
            cclog("descshow")
            ch.UIManager:showGamePopup("Christmas/W_RYJK_2")
    end)

    widget:addDataProxy("rewardlist",function(evt)
        local items = {}
        local _,listData = ch.ChristmasModel:getGloryGoldData()
        if listData and #listData then
            for i=1,#listData do
                    cclog("listdata.time=="..listData[i].time)
                    table.insert(items,{type=ch.ChristmasModel:getCurPage(),value=listData[i]})
            end
        end
        return items
    end)
    
    widget:listen(ch.ChristmasModel.GAMEEventType_GloryGoldChange,function(obj,evt)
        l_expectedReward,l_gloryGoldlist=ch.ChristmasModel:getGloryGoldData()
       
        widget:noticeDataChange("isGuild")
        widget:noticeDataChange("isReward")
        --widget:noticeDataChange("isExpect")
        widget:noticeDataChange("leftTime")
        widget:noticeDataChange("expectedReward")
        widget:noticeDataChange("rewardlist")
    end)
end)

--荣耀金矿规则说明
zzy.BindManager:addFixedBind("Christmas/W_RYJK_2", function(widget)
    cclog("W_RYJK_2")
    widget:addCommond("close",function()
        widget:destory()
    end)
end)

zzy.BindManager:addCustomDataBind("Christmas/W_RYJK_unit", function(widget,data)
    
    widget:addDataProxy("rank",function(evt)
            return data.value.index
    end)

    widget:addDataProxy("name",function(evt)
            return data.value.name
    end)

    widget:addDataProxy("occupyDesc",function(evt)
            return string.format(Language.HOLIDAY_GLORYGOLD_OCCPYTIME,data.value.level,ch.NumberHelper:dateTimeToString(data.value.time))
    end)

    widget:addDataProxy("reward",function(evt)
            return data.value.reward
    end)
end)

--节日兑换活动W_JRDH：2001
-- 从 圣诞活动兑换界面W_Xmas_txt_DH 改过来
zzy.BindManager:addFixedBind("Christmas/W_JRDH", function(widget)
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.MoneyModel.dataType.cSock
    end
    
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()
    
    widget:addDataProxy("time",function(evt)
--        local str = os.date(Language.src_clickhero_view_ChristmasView_5,tonumber(ch.ChristmasModel:getOpenTimeByType(1001)))
--        str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getEndTimeByType(1001)))
--        return str
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(2001)) - os_time()
        return ch.NumberHelper:cdTimeToString(time)
    end)
    widget:addDataProxy("num",function(evt)
        return ch.MoneyModel:getCSock()
    end,moneyChangeEvent)
    widget:addDataProxy("list",function(evt)
        local items = {}
        local tmpData = ch.ChristmasModel:getCSVDataByType(1001)
        if tmpData then
            for k,v in pairs(tmpData) do
                table.insert(items,{type=ch.ChristmasModel:getCurPage(),value=v})
            end
        end
        return items
    end)
    
    widget:addDataProxy("isFree",function(evt)
        return true
    end,moneyChangeEvent)
    widget:addDataProxy("noFree",function(evt)
        return true
    end,moneyChangeEvent)
    widget:addDataProxy("canBuy",function(evt)
        return true
    end,moneyChangeEvent)
    widget:addCommond("get",function()
        ch.NetworkController:dhMoneyGet(1)
    end)
    widget:addCommond("buy",function()
        ch.NetworkController:dhMoneyGet(0)
    end)
end)

-- 开服排行榜
zzy.BindManager:addFixedBind("Christmas/W_Xmas_txt_PHB", function(widget)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()
    
    widget:addDataProxy("time",function(evt)
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(2036)) - os_time()
        return ch.NumberHelper:cdTimeToString(time)
    end)

     widget:addDataProxy("desc",function(evt)
        return Language.src_clickhero_view_ChristmasView_desc_kfph
    end)
    
    widget:addDataProxy("img",function(evt)
        return GameConst.HOLIDAY_ITEM_DATA["hd" .. 2036].img
    end)

    widget:addDataProxy("list",function(evt)
        local items = {}
        for i = 1,10 do
            if i<4 then
                table.insert(items,{index = 1,value = {rank=i,type=4},isMultiple = true})
            else
                table.insert(items,{index = 2,value = {rank=i,type=4},isMultiple = true})
            end
        end
        return items
    end)
end)

---
-- 排行榜列表内容
zzy.BindManager:addCustomDataBind("Christmas/N_TopUnit",function(widget,data)
    local rankListEvent = {}
    rankListEvent[ch.RankListModel.dataChangeEventType] = function (evt)
        return evt.dataType == ch.RankListModel.dataType.kfph
    end
    widget:addDataProxy("rank",function(evt)
        return GameConst.RANKLIST_ICON[tonumber(data.rank)]
    end)
    widget:addDataProxy("name",function(evt)
        if data.n then
            return data.n
        else
            return ch.RankListModel:getNameByRank(data.rank,data.type)
        end
    end,rankListEvent)
    widget:addDataProxy("maxLevel",function(evt)
        if data.num then
            if type(data.num) == "string" then
                return data.num
            else
                return ch.NumberHelper:toString(data.num)
            end
        else
            return ch.RankListModel:getNumByRank(data.rank,data.type)
        end
    end,rankListEvent)
    widget:addDataProxy("harmText",function(evt)
        if data.type then
            if data.type == 2 then
                return Language.src_clickhero_view_RankListView_4
            elseif data.type == 3 then
                return Language.src_clickhero_view_RankListView_6
            else
                return ""
            end
        else
            return data.harmText..": "
        end
    end)
    widget:addDataProxy("notRank",function(evt)
        if data.type and data.type == 4 then
            return false
        else
            return true
        end
    end)
    widget:addDataProxy("isRank",function(evt)
        if data.type and data.type == 4 then
            return true
        else
            return false
        end
    end)   
    
    widget:addDataProxy("dbImage",function(evt)
        if ((data.type == 1 or data.type == 2 or data.type == 4) and ch.RankListModel:getUserIdByRank(data.rank,data.type) == ch.PlayerModel:getPlayerID() ) 
            or (data.type == 3 and ch.RankListModel:getUserIdByRank(data.rank,data.type) == ch.RankListModel:getMyGuildID()) then
            return "aaui_diban/db_itemrank_my.png"
        else
            return "aaui_diban/db_itemrank.png"
        end
    end,rankListEvent) 
    
    -- 称号图标
    widget:addDataProxy("titleIcon",function(evt)
        if data.l then
            return ch.UserTitleModel:getTitle(data.l-1,data.id).icon
        else
            if data.type == 3 then
                return GameConst.GUILD_FLAG[tonumber(data.tmpData.flag)]
            else
                return ch.UserTitleModel:getTitle(ch.RankListModel:getMaxLevelByRank(data.rank,data.type)-1,ch.RankListModel:getUserIdByRank(data.rank,data.type)).icon
            end
        end
    end,rankListEvent)
    -- 公会图标
    widget:addDataProxy("guildIcon",function(evt)
        if data.l then
            return ch.UserTitleModel:getTitle(data.l-1,data.id).icon
        else
            if data.type == 3 then
                return GameConst.GUILD_FLAG[tonumber(data.tmpData.flag)]
            else
                return ch.UserTitleModel:getTitle(ch.RankListModel:getMaxLevelByRank(data.rank,data.type)-1,ch.RankListModel:getUserIdByRank(data.rank,data.type)).icon
            end
        end
    end,rankListEvent)
    -- 是否有称号,显示公会图标还是显示称号
    widget:addDataProxy("ifGuild",function(evt)
            return false
    end,rankListEvent)
    widget:addDataProxy("noGuild",function(evt)
            return true
    end,rankListEvent)
    
    widget:addDataProxy("rewardImage",function(evt)
        return GameConfig.KfphConfig:getData(data.rank).icon
    end,rankListEvent)
    
    widget:addDataProxy("rewardNum",function(evt)
        return GameConfig.KfphConfig:getData(data.rank).name
    end,rankListEvent)  
    
    widget:addCommond("openDetail",function()
        if data.type then
            if data.type == 4 then
                ch.NetworkController:rankListPlayer(ch.RankListModel:getUserIdByRank(data.rank,data.type))
            elseif data.type == 2 then
                ch.NetworkController:arenaPlayer(ch.RankListModel:getUserIdByRank(data.rank,data.type),data.rank,1)
            elseif data.type == 3 then
                ch.NetworkController:guildDetail(data.tmpData.id,nil,1)
            end
        elseif not data.l then
            ch.NetworkController:guildDetail(data.id,nil,1)
        else
            ch.NetworkController:rankListPlayer(data.id)
        end
    end)
end)

---
-- 排行榜列表内容
zzy.BindManager:addCustomDataBind("Christmas/N_TopUnit2",function(widget,data)
    local rankListEvent = {}
    rankListEvent[ch.RankListModel.dataChangeEventType] = function (evt)
        return evt.dataType == ch.RankListModel.dataType.kfph
    end

    widget:addDataProxy("rank",function(evt)
        return tostring(data.rank)
    end)
    widget:addDataProxy("name",function(evt)
        if data.n then
            return data.n
        else    
            return ch.RankListModel:getNameByRank(data.rank,data.type)
        end
    end,rankListEvent)
    widget:addDataProxy("maxLevel",function(evt)
        if data.num then
            if type(data.num) == "string" then
                return data.num
            else
                return ch.NumberHelper:toString(data.num)
            end
        else
            return ch.RankListModel:getNumByRank(data.rank,data.type)
        end
        
    end,rankListEvent)
    widget:addDataProxy("harmText",function(evt)
        if data.type then
            if data.type == 2 then
                return Language.src_clickhero_view_RankListView_4
            elseif data.type == 3 then
                return Language.src_clickhero_view_RankListView_6
            else
                return ""
            end
        else
            return data.harmText..": "
        end
    end)
    widget:addDataProxy("notRank",function(evt)
        if data.type and data.type == 4 then
            return false
        else
            return true
        end
    end)
    widget:addDataProxy("isRank",function(evt)
        if data.type and data.type == 4 then
            return true
        else
            return false
        end
    end)   
    
    widget:addDataProxy("dbImage",function(evt)
        if ((data.type == 4 or data.type == 2) and ch.RankListModel:getUserIdByRank(data.rank,data.type) == ch.PlayerModel:getPlayerID() ) 
            or (data.type == 3 and ch.RankListModel:getUserIdByRank(data.rank,data.type) == ch.RankListModel:getMyGuildID()) then
            return "aaui_diban/db_itemrank_my.png"
        else
            return "aaui_diban/db_itemrank.png"
        end
    end,rankListEvent)
    
    -- 称号图标
    widget:addDataProxy("titleIcon",function(evt)
        if data.l then
            return ch.UserTitleModel:getTitle(data.l-1,data.id).icon
        else
            if data.type == 3 then
                return GameConst.GUILD_FLAG[tonumber(data.tmpData.flag)]
            else
                return ch.UserTitleModel:getTitle(ch.RankListModel:getMaxLevelByRank(data.rank,data.type)-1,ch.RankListModel:getUserIdByRank(data.rank,data.type)).icon
            end
        end
    end,rankListEvent)
    -- 公会图标
    widget:addDataProxy("guildIcon",function(evt)
        if data.l then
            return ch.UserTitleModel:getTitle(data.l-1,data.id).icon
        else
            if data.type == 3 then
                return GameConst.GUILD_FLAG[tonumber(data.tmpData.flag)]
            else
                return ch.UserTitleModel:getTitle(ch.RankListModel:getMaxLevelByRank(data.rank,data.type)-1,ch.RankListModel:getUserIdByRank(data.rank,data.type)).icon
            end
        end
    end,rankListEvent)
    -- 是否有称号,显示公会图标还是显示称号
    widget:addDataProxy("ifGuild",function(evt)
        if data.type and data.type == 3 then
            return true
        else
            return false
        end
    end,rankListEvent)
    widget:addDataProxy("noGuild",function(evt)
        if (data.type and data.type ~= 3) or data.l then
            return true
        else
            return false
        end
    end,rankListEvent)
    
    widget:addCommond("openDetail",function()
        if data.type then
            if data.type == 4 then
                ch.NetworkController:rankListPlayer(ch.RankListModel:getUserIdByRank(data.rank,data.type))
            elseif data.type == 2 then
                ch.NetworkController:arenaPlayer(ch.RankListModel:getUserIdByRank(data.rank,data.type),data.rank,1)
            elseif data.type == 3 then
                ch.NetworkController:guildDetail(data.tmpData.id,nil,1)
            end
        elseif not data.l then
            ch.NetworkController:guildDetail(data.id,nil,1)
        else
            ch.NetworkController:rankListPlayer(data.id)
        end
    end)
    
    widget:addDataProxy("rewardImage",function(evt)
        return GameConfig.KfphConfig:getData(data.rank).icon
    end,rankListEvent)
    
    widget:addDataProxy("rewardNum",function(evt)
        return GameConfig.KfphConfig:getData(data.rank).name
    end,rankListEvent)  
end)


-- 消耗返礼界面
zzy.BindManager:addFixedBind("Christmas/W_WXPJ", function(widget)
    if _G_URL_PACKAGE and _G_URL_PACKAGE ~= "" then

    else
        local Button_PJ = zzy.CocosExtra.seekNodeByName(widget, "Button_PJ")
        Button_PJ:setVisible(false)
        Button_PJ:setVisible(false)
    end

    widget:addDataProxy("imageWxpj",function(evt)
        return "res/img/WXPJ.png"
    end)

    widget:addDataProxy("textTitle",function(evt)
            return Language.WXPJ_TITLE
    end)

    widget:addDataProxy("textRule",function(evt)
            return Language.WXPJ_RULE
    end)

    widget:addCommond("goAppstroe",function()
        if _G_URL_PACKAGE then
            cc.Application:getInstance():openURL(_G_URL_PACKAGE)
        end
    end)

    widget:addCommond("sendImage",function()
        zzy.cUtils.sendImage()
    end)
end)
