local rotateUnit = function(widget,func)
    local ani = cc.RotateBy:create(0.15,cc.Vertex3F(90,0,0))
    local seq = cc.Sequence:create(ani,cc.CallFunc:create(function()
        local spr = cc.Sprite:createWithSpriteFrameName("aaui_diban/Task_Bg.png")
        spr:setRotation(180)
        widget:addChild(spr)
        spr:setPosition(303,58)
        widget:noticeDataChange("data")
        local ani = cc.RotateBy:create(0.3,cc.Vertex3F(180,0,0))
        local seq = cc.Sequence:create(ani,cc.CallFunc:create(function()
            spr:removeFromParent()
            local ani = cc.RotateBy:create(0.15,cc.Vertex3F(90,0,0))
            if func then
                local seq = cc.Sequence:create(ani,cc.CallFunc:create(function()
                    func()
                end))
                widget:runAction(seq)
            else
                widget:runAction(ani) 
            end
        end))
        widget:runAction(seq)
    end))
    widget:runAction(seq)
end 
local RandomRefreshViewType = "RANDOM_REFRESH_VIEW_TYPE"

local getTime = function(time)
    if time > 0 then
        local second = math.floor(time%60)
        time = time /60
        local minute = math.floor(time%60)
        local hour = math.floor(time/60)
        return string.format("%02d:%02d:%02d",hour,minute,second)
    else
        return "00:00:00"
    end
end


-- 公会商店界面
zzy.BindManager:addCustomDataBind("Guild/W_GuildShop", function(widget,data)
    --版号
    DEBUG("data = "..data)  
    HS_LEFT_REFRESH_TIMES = HS_LEFT_REFRESH_TIMES or 20
    
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.honour
            or evt.dataType == ch.MoneyModel.dataType.diamond
            or evt.dataType == ch.MoneyModel.dataType.defeat
    end

    local dataChangeEvent = {}
    dataChangeEvent[ch.RandomShopModel.dataArenaChangeEventType] = false
    dataChangeEvent[ch.RandomShopModel.dataBlackChangeEventType] = false
    dataChangeEvent[ch.RandomShopModel.dataGuildChangeEventType] = false
    
    local dataMoneyChangeEvent = {}
    dataMoneyChangeEvent[ch.RandomShopModel.dataArenaChangeEventType] = false
    dataMoneyChangeEvent[ch.RandomShopModel.dataBlackChangeEventType] = false
    dataMoneyChangeEvent[ch.RandomShopModel.dataGuildChangeEventType] = false
    dataMoneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.honour
            or evt.dataType == ch.MoneyModel.dataType.diamond
            or evt.dataType == ch.MoneyModel.dataType.defeat
    end
    dataMoneyChangeEvent[RandomRefreshViewType] = false

    local title = ""
    local costIcon = ""
    
    if data == 1 then
        title = Language.src_clickhero_view_ShopView_2
        costIcon = GameConst.MSG_FJ_ICON[1]["db90006"]
    elseif data == 2 then
        title = Language.src_clickhero_view_ShopView_6
        costIcon = GameConst.MSG_FJ_ICON[1]["db90015"]
    elseif data == 3 then
        title = Language.src_clickhero_view_ShopView_7
        costIcon = GameConst.MSG_FJ_ICON[1]["db90001"]
    end
    local isRefreshing = false
    
    widget:addDataProxy("items", function(evt)
        local items = {}
--        if data == 1 then
        -- 公会商店
--            for k,v in pairs(ch.RandomShopModel:getGuildShopList()) do
--                local tmpValue = GameConfig.Shop_rndConfig:getData(tonumber(v.id))
--                table.insert(items,{index = 6, value = {index=k,value=tmpValue},isMultiple = true})
--            end
--        elseif data == 2 then
--        -- 天梯商店
--            for k,v in pairs(ch.RandomShopModel:getArenaShopList()) do
--                local tmpValue = GameConfig.Shop_rndConfig:getData(tonumber(v.id))
--                table.insert(items,{index = 6, value = {index=k,value=tmpValue},isMultiple = true})
--            end
--        elseif data == 3 then
--        -- 黑市商店
--            for k,v in pairs(ch.RandomShopModel:getBlackShopList()) do
--                local tmpValue = GameConfig.Shop_rndConfig:getData(tonumber(v.id))
--                table.insert(items,{index = 6, value = {index=k,value=tmpValue},isMultiple = true})
--            end
--        end
        for i = 1,4 do
            table.insert(items,{index = 6, value = {index=i,type=data},isMultiple = true})
        end
        return items
    end)
    
    widget:addDataProxy("shopTitle",function(evt)
        return title
    end)
    widget:addDataProxy("desc",function(evt)
        return Language.RANDOM_SHOP_DESC[data]
    end)
    widget:addCommond("openEL",function()
        ch.UIManager:showGamePopup("Guild/W_El")
    end)
    
    widget:addDataProxy("honour-num", function(evt)
        if data == 1 then
            return ch.MoneyModel:getHonour()
        elseif data == 2 then
            return ch.MoneyModel:getDefeat()
        elseif data == 3 then
            return ch.MoneyModel:getDiamond()
        end
    end,moneyChangeEvent)
    widget:addScrollData("honour-num", "allNum", 1, function(v)
        return tostring(math.floor(v))
    end,"N_Gglory:num_ry")
    
    widget:addDataProxy("costIcon", function(evt)
        return costIcon
    end)
    
    widget:addDataProxy("isGuildShop", function(evt)
        return data == 1
    end)
    
    widget:addDataProxy("isArenaShop", function(evt)
        return data == 2
    end)
    
    widget:addDataProxy("isBlackShop", function(evt)
        return data == 3
    end)
    
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("cd_gh")
        widget:noticeDataChange("cd_tt")
        widget:noticeDataChange("cd_hs")
        widget:setTimeOut(1,cutDown)
    end
    cutDown() 
    
    widget:addDataProxy("time_gh", function(evt)
        return os.date("%H:%M",tonumber(ch.RandomShopModel:getGuildShopCDTime()))
    end,dataChangeEvent)
    widget:addDataProxy("cd_gh", function(evt)
        if data == 1 then
            local leftTime = ch.RandomShopModel:getGuildShopCDTime() - os_time()
            if leftTime > 0 then return getTime(math.floor(leftTime)) end
            if ch.RandomShopModel:getGuildShopCDTime()>0 and ch.RandomShopModel:getGuildShopCDTime() <= os_time() then
                ch.NetworkController:guildShopRefresh(1)
            end
        end
        return "00:00:00"
    end)
    widget:addDataProxy("time_tt", function(evt)
        return os.date("%H:%M",tonumber(ch.RandomShopModel:getArenaShopCDTime()))
    end,dataChangeEvent)
    widget:addDataProxy("cd_tt", function(evt)
        if data == 2 then
            local leftTime = ch.RandomShopModel:getArenaShopCDTime() - os_time()
            if leftTime > 0 then return getTime(math.floor(leftTime)) end
            if ch.RandomShopModel:getArenaShopCDTime()>0 and ch.RandomShopModel:getArenaShopCDTime() <= os_time() then
                ch.NetworkController:arenaShopRefresh(1)
            end
        end
        return "00:00:00"
    end)
    widget:addDataProxy("time_hs", function(evt)
        return os.date("%H:%M",tonumber(ch.RandomShopModel:getBlackShopCDTime()))
    end,dataChangeEvent)
    widget:addDataProxy("cd_hs", function(evt)
        if data == 3 then
            local leftTime = ch.RandomShopModel:getBlackShopCDTime() - os_time()
            if leftTime > 0 then return getTime(math.floor(leftTime)) end
            if ch.RandomShopModel:getBlackShopCDTime()>0 and ch.RandomShopModel:getBlackShopCDTime() <= os_time() then
                ch.NetworkController:blackShopRefresh(1)
            end
        end
        return "00:00:00"
    end)
    
    -- 花费类型控制按钮和图标
    widget:addDataProxy("btnNormal_gh",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[3][1]
    end)
    widget:addDataProxy("btnPressed_gh",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[3][2]
    end)

    widget:addDataProxy("ifCanRefrash_gh", function(evt)
        return not isRefreshing and data == 1 and ch.MoneyModel:getHonour() >= ch.RandomShopModel:getGuildShopPrice()
    end,dataMoneyChangeEvent)
    widget:addDataProxy("ghPrice", function(evt)
        return string.format("-%d",ch.RandomShopModel:getGuildShopPrice())
    end,dataChangeEvent)
    widget:addDataProxy("ghIcon", function(evt)
        return costIcon
    end)
    
    widget:addCommond("openArena",function()
        ch.UIManager:cleanGamePopupLayer(true)
        ch.NetworkController:arenaPanel()
    end)
    -- 花费类型控制按钮和图标
    widget:addDataProxy("btnNormal_tt",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[1][1]
    end)
    widget:addDataProxy("btnPressed_tt",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[1][2]
    end)
    
    widget:addDataProxy("ifCanRefrash_tt", function(evt)
        return not isRefreshing and data == 2 and ch.MoneyModel:getDefeat() >= ch.RandomShopModel:getArenaShopPrice()
    end,dataMoneyChangeEvent)
    widget:addDataProxy("ttPrice", function(evt)
        return string.format("-%d",ch.RandomShopModel:getArenaShopPrice())
    end,dataChangeEvent)
    widget:addDataProxy("ttIcon", function(evt)
        return costIcon
    end)
    
    -- 花费类型控制按钮和图标
    widget:addDataProxy("btnNormal_hs",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[2][1]
    end)
    widget:addDataProxy("btnPressed_hs",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[2][2]
    end)
    widget:addDataProxy("ifCanRefrash_hs", function(evt)
        return not isRefreshing and data == 3 and ch.MoneyModel:getDiamond() >= ch.RandomShopModel:getBlackShopPrice() and HS_LEFT_REFRESH_TIMES > 0
    end,dataMoneyChangeEvent)
    widget:addDataProxy("hsPrice", function(evt)
        return string.format("-%d",ch.RandomShopModel:getBlackShopPrice())
    end,dataChangeEvent)
    widget:addDataProxy("hsIcon", function(evt)
        return costIcon
    end)
    
    --版号
    local lableCountDown = nil
    local lableLeftTimes = nil
    if data == 3 then
        lableCountDown = zzy.CocosExtra.seekNodeByName(widget, "Text_Countdown_2")
    end
    if IS_BANHAO and lableCountDown then
        lableLeftTimes= cc.Label:createWithTTF("", "aaui_font/ch.ttf", 22)
        lableLeftTimes:setColor(cc.c3b(200,0,0))
        lableCountDown:getParent():addChild(lableLeftTimes)
        lableLeftTimes:setPosition(lableCountDown:getPositionX()+12, lableCountDown:getPositionY() - 30)
        lableLeftTimes:setString("今日剩余刷新次数："..HS_LEFT_REFRESH_TIMES)
    end
    
    widget:addCommond("refreshGH",function()
        ch.NetworkController:guildShopRefresh(0)
        isRefreshing = true
        local evt = {type = RandomRefreshViewType}
        evt.isRefreshing = true
        zzy.EventManager:dispatch(evt)
    end)
    widget:addCommond("refreshTT",function()           
        ch.NetworkController:arenaShopRefresh(0)
        isRefreshing = true
        local evt = {type = RandomRefreshViewType}
        evt.isRefreshing = true
        zzy.EventManager:dispatch(evt)
    end)
    widget:addCommond("refreshHS",function()
        local buy = function()
            --版号
            if IS_BANHAO then
                HS_LEFT_REFRESH_TIMES = HS_LEFT_REFRESH_TIMES - 1
            end
            if lableLeftTimes then
                lableLeftTimes:setString("今日剩余刷新次数："..HS_LEFT_REFRESH_TIMES)
            end
            
            ch.NetworkController:blackShopRefresh(0)
            isRefreshing = true
            local evt = {type = RandomRefreshViewType}
            evt.isRefreshing = true
            zzy.EventManager:dispatch(evt)
        end
        local tmp = {price = ch.RandomShopModel:getBlackShopPrice(),buy = buy}
        ch.ShopModel:getCostTips(tmp)
    end)
    
    widget:listen(ch.RandomShopModel.dataGuildChangeEventType,function(obj,evt)
        if data == 1 and evt.dataType == ch.RandomShopModel.dataType.list then
            if not ch.RandomShopModel.refreshPlayGuild then
                return
            end
            zzy.TimerUtils:setTimeOut(0,function()
                ch.RandomShopModel.refreshPlayGuild = false
                if ch.RandomShopModel:getGuildShopListNum() > 0 then
                    local listView = widget:getChild("ListView_1")
                    for i=1,ch.RandomShopModel:getGuildShopListNum() do
                        local delay = i * 0.15
                        if delay > 0 then
                            if i == ch.RandomShopModel:getGuildShopListNum() then
                                widget:setTimeOut(delay,function()
                                    local unit = listView:getItem(i-1)
                                    rotateUnit(unit,function()
                                        isRefreshing = false
                                        local evt = {type = RandomRefreshViewType}
                                        evt.isRefreshing = false
                                        zzy.EventManager:dispatch(evt)
                                    end)
                                end)
                            else
                                widget:setTimeOut(delay,function()
                                    local unit = listView:getItem(i-1)
                                    rotateUnit(unit)
                                end)
                            end
                        else
                            local unit = listView:getItem(i-1)
                            rotateUnit(unit)
                        end
                    end
                end
            end)
        end
    end)
    
    widget:listen(ch.RandomShopModel.dataArenaChangeEventType,function(obj,evt)
        if data == 2 and evt.dataType == ch.RandomShopModel.dataType.list then
            if not ch.RandomShopModel.refreshPlay then
                return
            end
            zzy.TimerUtils:setTimeOut(0,function()
                ch.RandomShopModel.refreshPlay = false
                if ch.RandomShopModel:getArenaShopListNum() > 0 then
                    local listView = widget:getChild("ListView_1")
                    for i=1,ch.RandomShopModel:getArenaShopListNum() do
                        local delay = i * 0.15
                        if delay > 0 then
                            if i == ch.RandomShopModel:getArenaShopListNum() then
                                widget:setTimeOut(delay,function()
                                    local unit = listView:getItem(i-1)
                                    rotateUnit(unit,function()
                                        isRefreshing = false
                                        local evt = {type = RandomRefreshViewType}
                                        evt.isRefreshing = false
                                        zzy.EventManager:dispatch(evt)
                                    end)
                                end)
                            else
                                widget:setTimeOut(delay,function()
                                    local unit = listView:getItem(i-1)
                                    rotateUnit(unit)
                                end)
                            end
                        else
                            local unit = listView:getItem(i-1)
                            rotateUnit(unit)
                        end
                    end
                end
            end)
        end
    end)
    
    widget:listen(ch.RandomShopModel.dataBlackChangeEventType,function(obj,evt)
        if data == 3 and evt.dataType == ch.RandomShopModel.dataType.list then
            if not ch.RandomShopModel.refreshPlayBlack then
                return
            end
            zzy.TimerUtils:setTimeOut(0,function()
                ch.RandomShopModel.refreshPlayBlack = false
                if ch.RandomShopModel:getBlackShopListNum() > 0 then
                    local listView = widget:getChild("ListView_1")
                    for i=1,ch.RandomShopModel:getBlackShopListNum() do
                        local delay = (i-1) * 0.15
                        if delay > 0 then
                            if i == ch.RandomShopModel:getBlackShopListNum() then
                                widget:setTimeOut(delay,function()
                                    local unit = listView:getItem(i-1)
                                    rotateUnit(unit,function()
                                        isRefreshing = false
                                        local evt = {type = RandomRefreshViewType}
                                        evt.isRefreshing = false
                                        zzy.EventManager:dispatch(evt)
                                    end)
                                end)
                            else
                                widget:setTimeOut(delay,function()
                                    local unit = listView:getItem(i-1)
                                    isRefreshing = false
                                    rotateUnit(unit)
                                end)
                            end
                        else
                            local unit = listView:getItem(i-1)
                            rotateUnit(unit)
                        end
                    end
                end
            end)
        end
    end)
end)

zzy.BindManager:addCustomDataBind("Shop/W_shop_buy_unit",function(widget,data)
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.MoneyModel.dataType.diamond 
            or evt.dataType == ch.MoneyModel.dataType.honour
            or evt.dataType == ch.MoneyModel.dataType.defeat
        return ret
    end

    local dataChangeEvent = {}
    dataChangeEvent[ch.RandomShopModel.dataArenaChangeEventType] = function(evt)
        return evt.dataType == ch.RandomShopModel.dataType.num 
    end
    dataChangeEvent[ch.RandomShopModel.dataBlackChangeEventType] = function(evt)
        return evt.dataType == ch.RandomShopModel.dataType.num 
    end
    dataChangeEvent[ch.RandomShopModel.dataGuildChangeEventType] = function(evt)
        return evt.dataType == ch.RandomShopModel.dataType.num 
    end
    
    widget:addDataProxy("data",function(evt)
        if data.type == 1 then
            local tmpValue = ch.RandomShopModel:getGuildShopList()[data.index].id
            data.value = GameConfig.Shop_rndConfig:getData(tonumber(tmpValue))
        elseif data.type == 2 then
            local tmpValue = ch.RandomShopModel:getArenaShopList()[data.index].id
            data.value = GameConfig.Shop_rndConfig:getData(tonumber(tmpValue))
        else
            local tmpValue = ch.RandomShopModel:getBlackShopList()[data.index].id
            data.value = GameConfig.Shop_rndConfig:getData(tonumber(tmpValue))
        end
        local ret = {}
        ret.icon = data.value.icon
        ret.name = string.format(data.value.name,ch.CommonFunc:getRewardName(data.value.itemType,data.value.itemId))
        ret.isHot = data.value.tag == 1
        ret.isNew = data.value.tag == 2
        ret.isNoMax = ch.RandomShopModel:getNumById(data.value.shopType,data.index) < data.value.limit
        ret.reward = string.format("+%s",ch.CommonFunc:getRewardValue(data.value.itemType,data.value.itemId,data.value.itemNum))
        ret.price = string.format("-%d",data.value.price)
        if data.value.priceId == 90015 then
            ret.btnNormal = GameConst.SHOP_COST_BTN_IMAGE[1][1]
            ret.btnPressed = GameConst.SHOP_COST_BTN_IMAGE[1][2]
        elseif data.value.priceId == 90001 then
            ret.btnNormal = GameConst.SHOP_COST_BTN_IMAGE[2][1]
            ret.btnPressed = GameConst.SHOP_COST_BTN_IMAGE[2][2]
        elseif data.value.priceId == 90006 then
            ret.btnNormal = GameConst.SHOP_COST_BTN_IMAGE[3][1]
            ret.btnPressed = GameConst.SHOP_COST_BTN_IMAGE[3][2]
        end
        ret.costIcon = ch.CommonFunc:getRewardIcon(data.value.priceType,data.value.priceId)
        ret.getIcon = ch.CommonFunc:getRewardIcon(data.value.itemType,data.value.itemId)
        if data.value.shopType == 1 then
            ret.ifCanBuy = ch.MoneyModel:getHonour() >= data.value.price
        elseif data.value.shopType == 2 then
            ret.ifCanBuy = ch.MoneyModel:getDefeat() >= data.value.price
        elseif data.value.shopType == 3 then
            ret.ifCanBuy = ch.MoneyModel:getDiamond() >= data.value.price
        else 
            ret.ifCanBuy = false
        end
        return ret   
    end,dataChangeEvent)
    widget:addDataProxy("icon", function(evt)
        return data.value.icon
    end)
    widget:addDataProxy("name", function(evt)
        return string.format(data.value.name,ch.CommonFunc:getRewardName(data.value.itemType,data.value.itemId))
    end)
    widget:addDataProxy("isHot",function(evt)
        return data.value.tag == 1
    end)
    widget:addDataProxy("isNew",function(evt)
        return data.value.tag == 2
    end)
    -- 花费类型控制按钮和图标
    widget:addDataProxy("btnNormal",function(evt)
        if data.value.priceId == 90015 then
            return GameConst.SHOP_COST_BTN_IMAGE[1][1]
        elseif data.value.priceId == 90001 then
            return GameConst.SHOP_COST_BTN_IMAGE[2][1]
        elseif data.value.priceId == 90006 then
            return GameConst.SHOP_COST_BTN_IMAGE[3][1]
        end
    end)
    widget:addDataProxy("btnPressed",function(evt)
        if data.value.priceId == 90015 then
            return GameConst.SHOP_COST_BTN_IMAGE[1][2]
        elseif data.value.priceId == 90001 then
            return GameConst.SHOP_COST_BTN_IMAGE[2][2]
        elseif data.value.priceId == 90006 then
            return GameConst.SHOP_COST_BTN_IMAGE[3][2]
        end
    end)
    widget:addDataProxy("costIcon",function(evt)
        return ch.CommonFunc:getRewardIcon(data.value.priceType,data.value.priceId)
    end)
    widget:addDataProxy("getIcon",function(evt)
        return ch.CommonFunc:getRewardIcon(data.value.itemType,data.value.itemId)
    end)
    widget:addDataProxy("reward", function(evt)
        return string.format("+%s",ch.CommonFunc:getRewardValue(data.value.itemType,data.value.itemId,data.value.itemNum))
    end)
    widget:addDataProxy("price", function(evt)
        return string.format("-%d",data.value.price)
    end)
    widget:addDataProxy("ifCanBuy",function(evt)
        if data.value.shopType == 1 then
            return ch.MoneyModel:getHonour() >= data.value.price
        elseif data.value.shopType == 2 then
            return ch.MoneyModel:getDefeat() >= data.value.price
        elseif data.value.shopType == 3 then
            return ch.MoneyModel:getDiamond() >= data.value.price
        end
        return false
    end,moneyChangeEvent)
    widget:addDataProxy("isNoMax",function(evt)
        return ch.RandomShopModel:getNumById(data.value.shopType,data.index) < data.value.limit
    end,dataChangeEvent)

    widget:addCommond("buy",function()
        if data.value.shopType == 1 then
            ch.NetworkController:guildShopBuy(data.index)
            ch.CommonFunc:addItems({{t=data.value.itemType,id=data.value.itemId,num=data.value.itemNum}})
        elseif data.value.shopType == 2 then
            ch.NetworkController:arenaShopBuy(data.index)
            ch.CommonFunc:addItems({{t=data.value.itemType,id=data.value.itemId,num=data.value.itemNum}})
        elseif data.value.shopType == 3 then
            local buy = function()
                ch.NetworkController:blackShopBuy(data.index)
                ch.CommonFunc:addItems({{t=data.value.itemType,id=data.value.itemId,num=data.value.itemNum}})
            end
            local tmp = {price = data.value.price,buy = buy}
            ch.ShopModel:getCostTips(tmp)
        end
    end)
end)
