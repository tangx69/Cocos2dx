local NetworkController2 = {
}

---
-- 宝物升级
-- @function [parent=#NetworkController2] magicLevelUp
-- @param #NetworkController2 self
-- @param #string id
-- @param #number num 升的级数
function NetworkController2:magicLevelUp(id,num)
    if self._data.magicLevelUpData.id and  self._data.magicLevelUpData.id ~= id then
        self:_sendMagicLUData()
    end
    if self._data.runicLevelUpData.time then
        self:_sendRunicLUData()
    end
    if not self._data.magicLevelUpData.time then
        self._data.magicLevelUpData.curLevel = ch.LevelModel:getCurLevel()
        self._data.magicLevelUpData.totalKilled = ch.LevelModel:getKilledCount()
        self._data.magicLevelUpData.preGold = ch.MoneyModel:getGold() -- 扣费之前
        self._data.magicLevelUpData.preDps = ch.MagicModel:getTotalDPS()
        self._data.magicLevelUpData.preBoxCount = ch.StatisticsModel:getKilledBoxes()
        self._data.magicLevelUpData.firstTime = math.ceil(os_time())
        self._data.magicLevelUpData.prePetDps = ch.RunicModel:getDPS()
    end
    local level = ch.MagicModel:getLevel(id)
    local cost = ch.MagicModel:getLevelUpCost(id,num,level)
    self._data.magicLevelUpData.id = id
    self._data.magicLevelUpData.time = math.ceil(os_time())
    self._data.magicLevelUpData.leftGold = ch.MoneyModel:getGold() - cost
    self._data.magicLevelUpData.cost = (self._data.magicLevelUpData.cost or 0)+cost
    ch.MagicModel:addLevel(id,num)
    ch.MoneyModel:addGold(-cost)
end

---
-- 发送宝物升级数据
-- @function [parent=#NetworkController2] _sendMagicLUData
-- @param #NetworkController2 self
-- @param #bool isForce
function NetworkController2:_sendMagicLUData(isForce)
    local data = self._data.magicLevelUpData
    self:sendLevelData(data.curLevel,data.totalKilled,data.preGold,data.firstTime,data.preDps,nil,isForce,data.preBoxCount,data.prePetDps)
    local id = self._data.magicLevelUpData.id
    local level = ch.MagicModel:getLevel(id)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "item"
    evt.data = {
        f = "up",
        tm = math.ceil(self._data.magicLevelUpData.time),
        id = id,
        level = level,
        tmoney = self._data.magicLevelUpData.leftGold,
        cost = self._data.magicLevelUpData.cost
    }
    zzy.EventManager:dispatch(evt)
    self._data.magicLevelUpData = {}
    
    --立刻同步数据
    self:sendFixedTimeData()
end

---
-- 宝物镀金
-- @function [parent=#NetworkController2] magicStar
-- @param #NetworkController2 self
function NetworkController2:magicStar()
    self:_sendUpData(false)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "dj"
    evt.data = {
        f = "get",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 充值
-- @function [parent=#NetworkController2] charge
-- @param #NetworkController2 self
-- @param #number itemid 物品id
-- @param #number itemName 物品名
-- @param #number itemCount 物品数量
-- @param #number price 物品当前价格
-- @param #number oprice 物品原价格
-- @param #number zs 钻石数
function NetworkController2:charge(itemid,itemName,itemCount,price,oprice,zs,config)
    DEBUG("[charge]itemid="..itemid..",itemName="..itemName..",itemCount="..itemCount..",price="..price..",oprice="..oprice..",zs="..zs)
    local realProductId = config.realItemId or itemid
    
    local customPara = zzy.cUtils.getCustomParam()
    local payType = "charge";
    if zzy.cUtils.getYJPayType and tostring(zzy.cUtils.getYJPayType()) == "2" then
        payType = "pay"
    end
    
    local product_info_t = {}
    product_info_t.id = tostring(itemid)
    product_info_t.name = tostring(itemName)
    product_info_t.price = (price)
    product_info_t.count = (itemCount)
    product_info_t.desc = ""
    product_info_t.userid = tostring(USER_ID)
    product_info_t.ext = customPara.. "#"..USER_ID.."#"..realProductId
    product_info_t.apiType = payType
    
    local targetPlatform = cc.Application:getInstance():getTargetPlatform() 
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) or (cc.PLATFORM_OS_WINDOWS == targetPlatform) then
        product_info_t.id = realProductId
    end
    
    local product_info_s = json.encode(product_info_t)
    DEBUG("product_info_s="..product_info_s)
    
    local isBcSupport = cc.libPlatform.isUseBeeCloud and cc.libPlatform:getInstance():isUseBeeCloud() --sdk是否接入beecloud
    local isBcAllowed = zzy.cUtils.isBcAllowed and zzy.cUtils.isBcAllowed() --远程配置文件是否允许使用beecloud
    
    USE_BEECLOUD = isBcSupport and isBcAllowed
    
    if zzy.Sdk.getFlag() ~= "ANYSDK" and zzy.Sdk.getFlag() ~= "YIJIE" and (not USE_BEECLOUD) then
        if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
            ch.NetworkController:shopBuy(config.id) --windows上可以直接购买，方便测试
            if config.type_item == 10 or config.type_item == 11 then
                ch.BuffModel:addCardBuff(config.reward*3600, config.type_item)
            end
            
            return
        else
            ch.UIManager:showMsgBox(1,true,Language.src_clickhero_controller_NetworkController2_1,function()
                cclog("充值暂未开放")
                end,nil,nil,nil)
            return
        end
    end

    if tostring(zzy.cUtils.getCustomParam()) == "200009" then --百度平台关闭充值
        return
    end
    
    if tostring(zzy.cUtils.getCustomParam()) == "200013" then --HTC平台关闭充值
        --return
    end
    
    local function cbPay(code, msg)
        ch.UIManager:showWaiting(false,true)
        if tonumber(code) == 0 then
            INFO("[payListener]ok!")
            if config.type_item == 10 or config.type_item == 11 then
                ch.BuffModel:addCardBuff(config.reward*3600, config.type_item)
            end
            
            if zzy.cUtils.tdAdTrace_onPaySuccess then
                zzy.cUtils.tdAdTrace_onPaySuccess(tostring(USER_ID), "", tonumber(price), "CNY", "")
            end
        elseif tonumber(code) == 2 then
            ERROR("未安装微信,请安装")
            ch.UIManager:showMsgBox(1,true,"请安装最新版本的微信",function()
            end,nil,nil,nil)
        end
    end
    
    if USE_BEECLOUD then
        local function requestPay(billType)
            local playerId = tostring(PLAYER_ID)
            local channelType = zzy.cUtils.getCustomParam()
            local userId = tostring(USER_ID)
            local productId = realProductId
            local serverId = tostring(SERVER_ID)
            local billNo = playerId.."pay"..os.time()
            
            INFO("PLAYER_ID="..PLAYER_ID)
            INFO("USER_ID="..USER_ID)
            INFO("itemid="..itemid)
            INFO("SERVER_ID="..SERVER_ID)
            INFO("billNo="..billNo)
                
            if luaj then
                --ch.UIManager:showWaiting(true)
                
                local args = {tonumber(billType),tonumber(price),itemName, billNo,cbPay,
                              playerId,channelType,userId, productId,serverId}
                local sigs = "(IILjava/lang/String;Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
                local _ok,_ret  = luaj.callStaticMethod("com/funyou/utils/BeeCloudAdapter", "pay", args, sigs)
                if _ok then
                    ret = _ret
                end
            elseif luaoc then
                --ch.UIManager:showWaiting(true)

                local args = {["billType"]=tonumber(billType), ["totalFee"]=tonumber(price), ["billTitle"]=itemName, ["billNo"]=billNo, ["luaCallBack"]=cbPay,
                              ["playerid"]=playerId, ["channeltype"]=channelType, ["userid"]=userId, ["productid"]=productId, ["serverid"]=serverId}
          
                local _ok,_ret  = luaoc.callStaticMethod("BCAdapter", "pay", args)
                if _ok then
                    ret = _ret
                end
            end
        end
        
        -- show payType ui
        local uiName = "res/ui/Shop/W_shop_billtype.csb"
        if luaj then
            uiName = "res/ui/Shop/W_shop_billtype.csb"
        elseif luaoc then
            uiName = "res/ui/Shop/W_shop_billtype_ios.csb"
        end
        local choseLayer = cc.CSLoader:createNode(uiName)
        local function zfbClick(sender,eventType)
            if  eventType == ccui.TouchEventType.ended then
                choseLayer:removeFromParent()
                requestPay(1)
            end
        end
        local function wxClick(sender,eventType)
            if  eventType == ccui.TouchEventType.ended then
                choseLayer:removeFromParent()
                requestPay(2)
            end
        end
        local function appstoreClick(sender,eventType)
            if  eventType == ccui.TouchEventType.ended then
                choseLayer:removeFromParent()
                cc.libPlatform:getInstance():setPayCallBack(cbPay)
                ch.UIManager:showWaiting(true)
                cc.libPlatform:getInstance():pay(product_info_s)
            end
        end
        local function cancelClick(sender,eventType)
            if  eventType == ccui.TouchEventType.ended then
                choseLayer:removeFromParent()
            end
        end
        
        local B_payType_zfb = zzy.CocosExtra.seekNodeByName(choseLayer,"B_payType_zfb")
        B_payType_zfb:addTouchEventListener(zfbClick)
        local B_payType_wx = zzy.CocosExtra.seekNodeByName(choseLayer,"B_payType_wx")
        B_payType_wx:addTouchEventListener(wxClick)
        local B_payType_appstore = zzy.CocosExtra.seekNodeByName(choseLayer,"B_payType_appstore")
        if B_payType_appstore then
            B_payType_appstore:addTouchEventListener(appstoreClick)
        end
        local B_cancel = zzy.CocosExtra.seekNodeByName(choseLayer,"B_cancel")
        B_cancel:addTouchEventListener(cancelClick)
        
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(choseLayer)
        local framesize = cc.Director:getInstance():getWinSize()
        choseLayer:setPosition(framesize.width/2,framesize.height/2)
    else
        cc.libPlatform:getInstance():setPayCallBack(cbPay)
        --ch.UIManager:showWaiting(true)
        cc.libPlatform:getInstance():pay(product_info_s)
    end
end

---
-- 宝物镀金转移
-- @function [parent=#NetworkController2] magicStarTrans
-- @param #NetworkController2 self
-- @param #string oldId 原宝物id
-- @param #string type 0为钻石1为魂
function NetworkController2:magicStarTrans(oldId,type)
    self._magicStarOldId = oldId
    self:_sendUpData(false)
    local evt = zzy.Events:createC2SEvent()

    evt.cmd = "dj"
    evt.data = {
        f = "trans",
        srcid = oldId,
        type = type,
        tm = math.ceil(os_time())
    }

    --[[ tgx
    evt.cmd = "dj"
    evt.data = {
        f = "transNum",
        srcid = oldId,
        type = type,
        num = 1,
        tm = math.ceil(os_time())
    }
    ]]
    zzy.EventManager:dispatch(evt)
    if tostring(type) == "0" then
        ch.MoneyModel:addDiamond(-GameConst.MGAIC_STAR_PRICE_DIAMOND)
        ch.ShopModel:addDiamondStar(1)
    else
        ch.MoneyModel:addSoul(-GameConst.MGAIC_STAR_PRICE)
        ch.ShopModel:addStarSoulCount(-1)
    end
end

---
-- 符文升级
-- @function [parent=#NetworkController2] runicLevelUp
-- @param #NetworkController2 self
-- @param #number num 升级的级数
function NetworkController2:runicLevelUp(num)
    if self._data.magicLevelUpData.time then
        self:_sendMagicLUData()
    end
    if not self._data.runicLevelUpData.time then
        self._data.runicLevelUpData.curLevel = ch.LevelModel:getCurLevel()
        self._data.runicLevelUpData.totalKilled = ch.LevelModel:getKilledCount()
        self._data.runicLevelUpData.preGold = ch.MoneyModel:getGold() -- 扣费之前
        self._data.runicLevelUpData.firstTime = math.ceil(os_time())
        self._data.runicLevelUpData.preBoxCount = ch.StatisticsModel:getKilledBoxes()
        self._data.runicLevelUpData.preDps = ch.MagicModel:getTotalDPS()
        self._data.runicLevelUpData.prePetDps = ch.RunicModel:getDPS()
        self._data.runicLevelUpData.upseq = {}
    end
    local money = ch.RunicModel:getCostLevelUp(num)
    self._data.runicLevelUpData.time = math.ceil(os_time())
    self._data.runicLevelUpData.leftGold = ch.MoneyModel:getGold() - money
    local startLevel = ch.RunicModel:getLevel()
    ch.RunicModel:addLevel(num)
    ch.MoneyModel:addGold(-money)
    local endLevel = ch.RunicModel:getLevel()
    self._data.runicLevelUpData.upseq = self._data.runicLevelUpData.upseq or {}
    table.insert(self._data.runicLevelUpData.upseq, {startLevel, endLevel})
end

---
-- 发送符文升级数据
-- @function [parent=#NetworkController2] _sendRunicLUData
-- @param #NetworkController2 self
-- @param #bool isForce
function NetworkController2:_sendRunicLUData(isForce)
    local data = self._data.runicLevelUpData
    self:sendLevelData(data.curLevel,data.totalKilled,data.preGold,data.firstTime,data.preDps,nil,isForce,data.preBoxCount,data.prePetDps)
    local level = ch.RunicModel:getLevel()
    local evt = zzy.Events:createC2SEvent()
    local upseqstr = string.gsub(json.encode(data.upseq), ',', '#')
    evt.cmd = "fw"
    evt.data = {
        f = "up", 
        tm = math.ceil(self._data.runicLevelUpData.time),
        level = level,
        tmoney = self._data.runicLevelUpData.leftGold,
        upseq = upseqstr
    }
    DEBUG("宠物升级"..json.encode(evt.data))
    zzy.EventManager:dispatch(evt)
    self._data.runicLevelUpData={}
end

---
-- 图腾刷新
-- @function [parent=#NetworkController2] totemRefresh
-- @param #NetworkController2 self
-- @param #string type 货币类型 0为钻石，1为魂
function NetworkController2:totemRefresh(type)
    self:_sendUpData(false)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "totem"
    evt.data = {
        f = "rf",
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    type = tonumber(type)
    if type == 1 then
        ch.MoneyModel:addSoul(-ch.TotemModel:getRefreshSoulPrice())
    elseif type == 0 then
        ch.MoneyModel:addDiamond(-ch.TotemModel:getRefreshDiamondPrice())
    end
end

---
-- 图腾获得
-- @function [parent=#NetworkController2] totemGet
-- @param #NetworkController2 self
-- @param #string id 图腾id
-- @param #int type 货币类型 0为钻石，1为魂
function NetworkController2:totemGet(id,type)
    self:_sendUpData(false)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "totem"
    evt.data = {
        f = "get",
        id = id,
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    -- 先扣钱，再召唤，注意顺序可能引发的bug
    type = tonumber(type)
    if type == 1 then
        ch.MoneyModel:addSoul(-ch.TotemModel:getCallSoulPrice(1))
        ch.TotemModel:addReturnSoulNum(ch.TotemModel:getCallSoulPrice(1))
    elseif type == 0 then
        ch.MoneyModel:addDiamond(-ch.TotemModel:getCallDiamondPrice(1))
        ch.TotemModel:addReturnDiamondNum(ch.TotemModel:getCallDiamondPrice(1))
    end
    -- 添加新图腾并且刷新
    ch.TotemModel:addTotem(id)
end

---
-- 高级图腾刷新
-- @function [parent=#NetworkController2] totemRefresh_senior
-- @param #NetworkController2 self
-- @param #string type 货币类型 0为钻石，1为魂
function NetworkController2:totemRefresh_senior(type)
    self:_sendUpData(false)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "totem"
    evt.data = {
        f = "rfS",
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    type = tonumber(type)
    if type == 1 then
        ch.MoneyModel:addSoul(-ch.TotemModel:getRefreshSoulPrice(2))
    elseif type == 0 then
        ch.MoneyModel:addDiamond(-ch.TotemModel:getRefreshDiamondPrice(2))
    end
end

---
-- 高级图腾获得
-- @function [parent=#NetworkController2] totemGet_senior
-- @param #NetworkController2 self
-- @param #string id 图腾id
-- @param #int type 货币类型 0为钻石，1为魂
function NetworkController2:totemGet_senior(id,type)
    self:_sendUpData(false)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "totem"
    evt.data = {
        f = "getS",
        id = id,
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    -- 先扣钱，再召唤，注意顺序可能引发的bug
    type = tonumber(type)
    if type == 1 then
        ch.MoneyModel:addSoul(-ch.TotemModel:getCallSoulPrice(2))
        ch.TotemModel:addReturnSoulNum(ch.TotemModel:getCallSoulPrice(2))
    elseif type == 0 then
        ch.MoneyModel:addDiamond(-ch.TotemModel:getCallDiamondPrice(2))
        ch.TotemModel:addReturnDiamondNum(ch.TotemModel:getCallDiamondPrice(2))
    end
    -- 添加新图腾并且刷新
    ch.TotemModel:addTotem(id)
end

---
-- 图腾升级
-- @function [parent=#NetworkController2] totemLevelUp
-- @param #NetworkController2 self
-- @param #string id
-- @param #number type 0为钻石1为魂
function NetworkController2:totemLevelUp(id,type,upNum)
    upNum = upNum or 1
    self:_sendUpData(false)
    local level = ch.TotemModel:getLevel(id) + upNum
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "totem"
    evt.data = {
        f = "up", 
        id = id,
        level = level,
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    type = tonumber(type)
    local soulPrice,diamondPrice = ch.TotemModel:getLevelUpCost(id,upNum)
    if type == 1 then
        -- 魂升级(清除暂时不用)
        ch.MoneyModel:addSoul(-soulPrice) 
        --        ch.TotemModel:addReturnSoulNum(soulPrice) 
    else
        -- 钻石升级
        ch.MoneyModel:addDiamond(-diamondPrice)
        --        ch.TotemModel:addReturnDiamondNum(diamondPrice)
    end
    ch.TotemModel:addLevel(id, upNum)
end

---
-- 神坛升级
-- @function [parent=#NetworkController2] totemLevelUp
-- @param #NetworkController2 self
-- @param #string id
-- @param #number type 0为钻石1为魂
function NetworkController2:shentanLevelUp(id,type,upNum)
    upNum = upNum or 1
    self:_sendUpData(false)
    local level = ch.ShentanModel:getLevel(id) + upNum
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "holyland"
    evt.data = {
        f = "up", 
        id = id,
        level = level,
        --type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    type = tonumber(type)
    local godsPrice,diamondPrice = ch.ShentanModel:getLevelUpCost(id,upNum)
    if type == 1 then
        ch.MoneyModel:addGods(-godsPrice) 
    else
        ch.MoneyModel:addDiamond(-diamondPrice)
    end
    
    ch.ShentanModel:addLevel(id, upNum)
    ch.MagicModel:resetDPS() --清除缓存dps
    local evt = {type = ch.ShentanModel.dataChangeEventType, dataType=ch.ShentanModel.dataType.level}
    zzy.EventManager:dispatch(evt)
end

---
-- 神坛重置
-- @function [parent=#NetworkController2] totemLevelUp
-- @param #NetworkController2 self
-- @param #string id
-- @param #number type 0为钻石1为魂
function NetworkController2:shentanReset(costDiamond)
    self:_sendUpData(false)

    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "holyland"
    evt.data = {
        f = "reset", 
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)

    local costGodsTotal = 0
    for id= 1, 5 do
        local level = ch.ShentanModel:getLevel(id)
        if id == 1 then
            costGodsTotal = costGodsTotal + level*10
        else
            costGodsTotal = costGodsTotal + level*1
        end
        
        ch.ShentanModel:addLevel(id, -level)
    end
    
    ch.MoneyModel:addGods(costGodsTotal)
    ch.MoneyModel:addDiamond(-costDiamond)
    ch.ShentanModel:addResetTimes(1)
    
    ch.MagicModel:resetDPS() --清除缓存dps
    local evt = {type = ch.ShentanModel.dataChangeEventType, dataType=ch.ShentanModel.dataType.level}
    zzy.EventManager:dispatch(evt)
end

---
-- 图腾重置
-- @function [parent=#NetworkController2] totemReset
-- @param #NetworkController2 self
-- @param #string type 类型，0为免费 1为收费
function NetworkController2:totemReset(type)
    self:_sendUpData(false)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "totem"
    evt.data = {
        f = "reset",
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    type = tonumber(type)
    if type == 0 then
        --得到免费返回的魂
        ch.MoneyModel:addSoul(ch.TotemModel:getReturnSoulFree())
        ch.MoneyModel:addDiamond(ch.TotemModel:getReturnDiamondFree())
    elseif type == 1 then
        -- 花费钻石
        ch.MoneyModel:addDiamond(-ch.TotemModel:getCleanDiamondPrice())
        --得到花费钻石返回的魂
        ch.MoneyModel:addSoul(ch.TotemModel:getReturnSoul())
        ch.MoneyModel:addDiamond(ch.TotemModel:getReturnDiamond())
    end
    ch.TotemModel:cleanTotem()
end

---
-- 魂石获得
-- @function [parent=#NetworkController2] sStoneGet
-- @param #NetworkController2 self
-- @param #string level 关卡id
function NetworkController2:sStoneGet(level)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "sprite"
    evt.data = {
        f = "get",
        gkid = level,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 定时发送
-- @function [parent=#NetworkController2] sendFixedTimeData
-- @param #NetworkController2 self
function NetworkController2:sendFixedTimeData()
    if self._waitGold then
        return
    end
    
    if self:isWaitingForMagicLevelUp() then
        return
    end
    
    self:_sendUpData(false)
    local killCount = 0
    local curLevel = ch.LevelModel:getCurLevel()
    local totalCount = ch.LevelModel:getKilledCount()
    local gold = ch.MoneyModel:getGold()
    if not self._data.levelData.curLevel or self._data.levelData.curLevel ~= curLevel then
        self._data.levelData.curLevel = curLevel
        self._data.levelData.killCount = totalCount
        killCount = totalCount
    else
        killCount = totalCount - self._data.levelData.killCount
        self._data.levelData.killCount = totalCount
    end
    local time = math.ceil(os_time())
    local evt = zzy.Events:createC2SEvent()
    if ch.LevelController.mode == ch.LevelController.GameMode.goldBoss or
        ch.LevelController.mode == ch.LevelController.GameMode.sStoneBoss then
        evt.cmd = "gk"
        evt.data = {
            f = "gbkill",
            tm = time,
            isVictory = 0,
            tmoney = gold,
            type = ch.LevelController.mode == ch.LevelController.GameMode.goldBoss and 1 or 2,
            hp = 0,
            useTime = ch.LevelController:getGoldBossTime()
        }
        zzy.EventManager:dispatch(evt)
    elseif ch.LevelController.mode == ch.LevelController.GameMode.warpath then
        evt.cmd = "wp"
        evt.data = {
            f = "money",
            tm = time,
            tmoney = gold
        }
        zzy.EventManager:dispatch(evt)
    end

    evt = zzy.Events:createC2SEvent()
    evt.cmd = "gk"
    evt.data = {
        f = "rf",
        tm = time,
        gkid = curLevel,
        tmoney = gold,
        kill = killCount,
        curDps = ch.MagicModel:getTotalDPS(),
        curPetDps = ch.RunicModel:getDPS(),
        killMonster = ch.StatisticsModel:getKilledMonsters(),
        killBox = ch.StatisticsModel:getKilledBoxes(),
        petCrit = ch.StatisticsModel:getRunicCritTimes(),
        petClick = ch.StatisticsModel:getClickTimes(),
        petSpeed = ch.StatisticsModel:getMaxClickSpeed(),
        maxDPS = ch.StatisticsModel:getMaxDPS()
    }
    local tmpTable = ch.TaskModel:taskTimeData()
    for k,v in pairs(tmpTable) do
        evt.data["task"..k] = v
    end
    zzy.EventManager:dispatch(evt)
end

---
-- 关卡指令
-- @function [parent=#NetworkController2] sendLevelData
-- @param #NetworkController2 self
-- @param #number curLevel
-- @param #number totalCount
-- @param #number gold
-- @param #number time
-- @param #number dps
-- @param #number isEnd
-- @param #bool isForce
-- @param #number boxCount
-- @param #number petDps
function NetworkController2:sendLevelData(curLevel,totalCount,gold,time,dps,isEnd,isForce,boxCount,petDps)
    local killCount = 0
    local curLevel = curLevel or ch.LevelModel:getCurLevel()
    local totalCount = totalCount or ch.LevelModel:getKilledCount()
    dps = dps or ch.MagicModel:getTotalDPS()
    petDps = petDps or ch.RunicModel:getDPS()
    gold = gold or ch.MoneyModel:getGold()
    time = time or math.ceil(os_time())
    if not self._data.levelData.curLevel or self._data.levelData.curLevel ~= curLevel then
        self._data.levelData.curLevel = curLevel
        self._data.levelData.killCount = totalCount
        killCount = totalCount
    else
        killCount = totalCount - self._data.levelData.killCount
        self._data.levelData.killCount = totalCount
    end
    if self._data.isGoldChanged then
        isForce = true
        self._data.isGoldChanged = false
    end
    boxCount = boxCount or ch.StatisticsModel:getKilledBoxes()
    if killCount > 0 or isEnd or isForce then
        local evt = zzy.Events:createC2SEvent()
        if ch.LevelController.mode == ch.LevelController.GameMode.goldBoss 
            or ch.LevelController.mode == ch.LevelController.GameMode.sStoneBoss  then
            evt.cmd = "gk"
            evt.data = {
                f = "gbkill",
                tm = time,
                isVictory = 0,
                tmoney = gold,
                hp = 0,
                type = ch.LevelController.mode == ch.LevelController.GameMode.goldBoss and 1 or 2,
                useTime = ch.LevelController:getGoldBossTime()
            }
        elseif ch.LevelController.mode == ch.LevelController.GameMode.warpath then
            evt.cmd = "wp"
            evt.data = {
                f = "money",
                tm = time,
                tmoney = gold
            }
        else
            evt.cmd = "gk"
            evt.data = {
                f = "rf",
                tm = time,
                gkid = curLevel,
                tmoney = gold,
                kill = killCount,
                killBox = boxCount,
                curDps = dps,
                curPetDps = petDps
            }
            if isEnd == 1 or isEnd == -1 then evt.data.isEnd = isEnd end
        end
        zzy.EventManager:dispatch(evt)
    end
end

---
-- 发送缓存数据
-- @function [parent=#NetworkController2] sendCacheData
-- @param #NetworkController2 self
-- @param #number isEnd 1为过关，-1为后退
function NetworkController2:sendCacheData(isEnd)
    self:_sendUpData(false)
    self:sendLevelData(nil,nil,nil,nil,nil,isEnd,nil,nil,nil)
end

---
-- 发送缓存的宝物和符文升级数据
-- @function [parent=#NetworkController2] _sendUpData
-- @param #NetworkController2 self
-- @param #bool isForce
function NetworkController2:_sendUpData(isForce)
    if self._data.magicLevelUpData.time and not self._data.runicLevelUpData.time  then
        self:_sendMagicLUData(isForce)
    elseif self._data.runicLevelUpData.time and not self._data.magicLevelUpData.time then
        self:_sendRunicLUData(isForce)
    elseif self._data.runicLevelUpData.time and self._data.magicLevelUpData.time then
        if self._data.runicLevelUpData.time >  self._data.magicLevelUpData.time then
            self:_sendMagicLUData(isForce)
            self:_sendRunicLUData(isForce)
        else
            self:_sendRunicLUData(isForce)
            self:_sendMagicLUData(isForce)
        end 
    end
end

---
-- 发送数据
-- @function [parent=#NetworkController2] _sendData
-- @param #NetworkController2 self
function NetworkController2:_sendData()
    local magicTime = self._data.magicLevelUpData.time
    if magicTime and os_time() - magicTime > 1 then
        self:_sendMagicLUData()
    end
    local runicTime = self._data.runicLevelUpData.time
    if runicTime and os_time() - runicTime > 1 then
        self:_sendRunicLUData()
    end
end

---
-- 镀金获得
-- @function [parent=#NetworkController2] magicStarGetData
-- @param #NetworkController2 self
-- @param #table data
function NetworkController2:magicStarGetData(data)
    if data.ret == 0 then
        if data.f == "get" then
            ch.MagicModel:addStar(data.id,1)
            ch.MoneyModel:addStar(-1)
        end
    end
end

---
-- 镀金转移
-- @function [parent=#NetworkController2] magicStarTransData
-- @param #NetworkController2 self
-- @param #table data
function NetworkController2:magicStarTransData(data)
    if data.ret == 0 then
        if data.f == "trans" then
            ch.MagicModel:setRemoveMagicID(data.desid)
            ch.MagicModel:addStar(data.desid,1)
            ch.MagicModel:addStar(self._magicStarOldId,-1)
        end
    end
end

---
-- 清楚关卡指令数据
-- @function [parent=#NetworkController2] clearLevelData
-- @param #NetworkController2 self
function NetworkController2:clearLevelData()
    self._data.levelData.curLevel = nil
    self._data.levelData.killCount = nil
end

---
-- 转生
-- @function [parent=#NetworkController2] samsara
-- @param #NetworkController2 self
function NetworkController2:samsara()
    self:sendFixedTimeData()  -- 为了同步成就完成状态，转生前同步数据
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "reborn"
    evt.data = {
        f = "s",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    ch.ShopModel:addSamsaraCount(-1)
    ch.StatisticsModel:setRTime(os_time()) -- 必须在前面
    ch.StatisticsModel:addRTimes(1)  -- 必须在前面
    ch.MoneyModel:onSamsara() -- 必须在第一位
    ch.MagicModel:onSamsara()
    ch.RunicModel:onSamsara()
    ch.LevelModel:onSamsara()    
    ch.TaskModel:onSamsara()
    ch.StatisticsModel:onSamsara()
    ch.PartnerModel:onSamsara()
    ch.OffLineModel:onSamsara()
    ch.MagicModel:resetDPS() --清除缓存dps
    ch.ModelManager:setOffLineGold(ch.LongDouble.zero)
    ch.flyBox:clearFlyBox()
    ch.LevelController:startNormal()
    zzy.EventManager:dispatchByType(ch.PlayerModel.samsaraCleanOffLineEventType)
end

---
-- 转生
-- @function [parent=#NetworkController2] samsara
-- @param #NetworkController2 self
function NetworkController2:superSamsara()
    self:sendFixedTimeData()  -- 为了同步成就完成状态，转生前同步数据
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "autofight"
    evt.data = {
        f = "superreborn",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    
    ch.ShopModel:addSamsaraCount(-1)
    ch.StatisticsModel:setRTime(os_time()) -- 必须在前面
    ch.StatisticsModel:addRTimes(1)  -- 必须在前面
    
    ch.MoneyModel:onSuperSamsara() -- 必须在第一位
    --ch.MagicModel:onSamsara()
    --ch.RunicModel:onSamsara()
    
    --ch.LevelModel:onSamsara()    
    ch.TaskModel:onSamsara() --清除力量源泉
    ch.StatisticsModel:onSamsara()
    ch.PartnerModel:onSuperSamsara()
    --ch.OffLineModel:onSamsara()
    ch.MagicModel:resetDPS() --清除缓存dps
    --ch.ModelManager:setOffLineGold(ch.LongDouble.zero)
    ch.flyBox:clearFlyBox()
    ch.LevelController:startNormal()
    --zzy.EventManager:dispatchByType(ch.PlayerModel.samsaraCleanOffLineEventType)
end

---
-- 使用技能
-- @function [parent=#NetworkController2] skillUsed
-- @param #NetworkController2 self
-- @param #string skillId
function NetworkController2:skillUsed(skillId)
    self:_sendUpData(false)
    if self._data.runicLevelUpData.time then
        self:_sendRunicLUData()
    end
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "sk"
    evt.data = {
        f = "use",
        skid = skillId,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    ch.RunicModel:useSkill(skillId)
end

---
-- 清除所有技能CD
-- @function [parent=#NetworkController2] clearAllSkillCD
-- @param #NetworkController2 self
function NetworkController2:clearAllSkillCD()
    if ch.MoneyModel:getDiamond() >= GameConst.RUNIC_CLEARCD_COST then
        local evt = zzy.Events:createC2SEvent()
        evt.cmd = "sk"
        evt.data = {
            f = "clear",
            tm = math.ceil(os_time())
        }
        zzy.EventManager:dispatch(evt)
        -- 花费钻石
        ch.MoneyModel:addDiamond(-GameConst.RUNIC_CLEARCD_COST)
        -- 清除所有技能cd
        ch.RunicModel:clearAllSkillCD()
    else
        cclog("清除所有技能CD， 钻石不够！")
    end
end

---
-- 特殊排行榜
-- @function [parent=#NetworkController2] matchRankList
-- @param #NetworkController2 self
-- @param #number typeId
-- @param #string cfgId
function NetworkController2:matchRankList(typeId,cfgId)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "matchrank"
    evt.data = {
        f = "get",
        typeId = typeId,
        cfgId = cfgId,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 排行榜
-- @function [parent=#NetworkController2] rankList
-- @param #NetworkController2 self
function NetworkController2:rankList()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "rk"
    evt.data = {
        f = "get",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end
---
-- 竞技榜
-- @function [parent=#NetworkController2] arenaList
-- @param #NetworkController2 self
function NetworkController2:arenaList()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "rk"
    evt.data = {
        f = "arena",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end
---
-- 公会榜
-- @function [parent=#NetworkController2] rankGuildList
-- @param #NetworkController2 self
function NetworkController2:rankGuildList()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "rk"
    evt.data = {
        f = "guild",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end
---
-- 排行榜玩家信息
-- @function [parent=#NetworkController2] rankListPlayer
-- @param #NetworkController2 self
-- @param #string userid
function NetworkController2:rankListPlayer(userid)
    if userid == "" or userid == nil then
        return
    end
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "rk"
    evt.data = {
        f = "player",
        userid = userid,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 第一周签到
-- @function [parent=#NetworkController2] firstSign
-- @param #NetworkController2 self
-- @param #number type 奖励类型
-- @param #number id 奖励ID
-- @param #number value 领取的金币
function NetworkController2:firstSign(type,id,value)
    self:sendCacheData()
    local sv = id == ch.MoneyModel.dataType.gold and value or 0
    local items = {{t=type,id=id,num=value}}
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "firstSign"
    evt.data = {
        f = "sg",
        tmoney = sv,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    ch.FirstSignModel:sign()
    ch.CommonFunc:addItems(items)
end

---
-- 签到
-- @function [parent=#NetworkController2] sign
-- @param #NetworkController2 self
-- @param #number type 奖励类型
-- @param #number id 奖励ID
-- @param #number value 领取的金币
function NetworkController2:sign(type,id,value)
    self:sendCacheData()
    local sv = id == ch.MoneyModel.dataType.gold and value or 0
    local items = {{t=type,id=id,num=value}}
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "qd"
    evt.data = {
        f = "sg",
        tmoney = sv,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    ch.SignModel:sign()
    ch.CommonFunc:addItems(items)
end

---
-- 小仙女领取
-- @function [parent=#NetworkController2] fairyDropItem
-- @param #NetworkController2 self
-- @param #number id
-- @param #number value
function NetworkController2:fairyDropItem(id,value)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "xn"
    evt.data = {
        f = "get",
        type = id,
        value = value,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    if id == 1 then
        ch.MoneyModel:addGold(value)
        ch.CommonFunc:playGoldSound(value)
    elseif id == 2 then -- 鼓舞
        ch.BuffModel:addInspireBuff(value)
    elseif id == 3 then -- 万金
        ch.BuffModel:addManyGoldBuff(value)
    elseif id == 4 then
        ch.MoneyModel:addDiamond(value)
    end
end

---
-- 小仙女刷新出
-- @function [parent=#NetworkController2] fairyAppear
-- @param #NetworkController2 self
function NetworkController2:fairyAppear()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "xn"
    evt.data = {
        f = "add",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 离线收益
-- @function [parent=#NetworkController2] getOffLineGold
-- @param #NetworkController2 self
-- @param #number gold
function NetworkController2:getOffLineGold(gold)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "olgold"
    evt.data = {
        f = "get",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    ch.MoneyModel:addGold(gold)
    ch.CommonFunc:showGoldRain(gold)
    ch.ModelManager:setOffLineGold(ch.LongDouble.zero)
end

---
-- 离线收益
-- @function [parent=#NetworkController2] getOffRewardGold
-- @param #NetworkController2 self
-- @param #table reward
function NetworkController2:getOffRewardGold(reward)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "olgold"
    evt.data = {
        f = "getReward",
        type = reward.type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    ch.CommonFunc:addItems(reward.items)
end

---
-- 设置改名
-- @function [parent=#NetworkController2] changeName
-- @param #NetworkController2 self
-- @param #string newName
-- @param #number newGender
function NetworkController2:changeName(newName,newGender)
    self:_sendUpData(false)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "cname"
    evt.data = {
        f = "cn",
        name = newName,
        gender = newGender,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 每日限购购买
-- @function [parent=#NetworkController2] buyLimitBuyOne
-- @param #NetworkController2 self
-- @param #number day
-- @param #number index
function NetworkController2:buyLimitBuyOne(day,index)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "buylimit"
    evt.data = {
        f = "buy",
        day = day,
        index = index,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 商店
-- @function [parent=#NetworkController2] shopBuy
-- @param #NetworkController2 self
-- @param #string id
-- @param #number value
function NetworkController2:shopBuy(id,value)
    DEBUG("[shopBuy]id="..id)
    if (id == 22 or id == 68) then
        return
    end
    self:sendCacheData()
    value = value or 0
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "shop"
    evt.data = {
        f = "buy",
        id = id,
        value = value,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 侍宠出战替换
-- @function [parent=#NetworkController2] curFamiliar
-- @param #NetworkController2 self
-- @param #number id
function NetworkController2:curFamiliar(id)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "familiar"
    evt.data = {
        f = "switch",
        id = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 侍宠获得
-- @function [parent=#NetworkController2] getFamiliar
-- @param #NetworkController2 self
-- @param #number id
function NetworkController2:getFamiliar(id)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "familiar"
    evt.data = {
        f = "get",
        id = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 侍宠未查看列表清除
-- @function [parent=#NetworkController2] cleanSeeFamiliar
-- @param #NetworkController2 self
function NetworkController2:cleanSeeFamiliar()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "familiar"
    evt.data = {
        f = "see",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 宠物出战替换
-- @function [parent=#NetworkController2] curPartner
-- @param #NetworkController2 self
-- @param #string id
function NetworkController2:curPartner(id)
    self:_sendUpData(false)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "partner"
    evt.data = {
        f = "swap",
        id = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 宠物奖励领取
-- @function [parent=#NetworkController2] getPartnerReward
-- @param #NetworkController2 self
-- @param #string id
function NetworkController2:getPartnerReward(id)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "partner"
    evt.data = {
        f = "lq",
        tm = math.ceil(os_time()),
        id = id
    }
    zzy.EventManager:dispatch(evt)
    ch.PartnerModel:getReward(id)
end

---
-- 消息，请求数据
-- @function [parent=#NetworkController2] msgPanel
-- @param #NetworkController2 self
-- @param #number type
function NetworkController2:msgPanel(type)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "msg"
    evt.data = {
        f = "panel",
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 消息，一键领取
-- @function [parent=#NetworkController2] getAllAttachments
-- @param #NetworkController2 self
-- @param #number type
function NetworkController2:getAllAttachments(type)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "msg"
    evt.data = {
        f = "y",
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 消息，一键已读
-- @function [parent=#NetworkController2] readAllMsg
-- @param #NetworkController2 self
-- @param #number type
function NetworkController2:readAllMsg(type)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "msg"
    evt.data = {
        f = "read",
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 消息，领取
-- @function [parent=#NetworkController2] getAttachments
-- @param #NetworkController2 self
-- @param #string msgID
function NetworkController2:getAttachments(msgID)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "msg"
    evt.data = {
        f = "s",
        id = msgID,
        lq = "2",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 消息，读取
-- @function [parent=#NetworkController2] readMsg
-- @param #NetworkController2 self
-- @param #string msgID
function NetworkController2:readMsg(msgID)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "msg"
    evt.data = {
        f = "s",
        id = msgID,
        dq = "2",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 从后台切回到游戏，请求下离线收益
-- @function [parent=#NetworkController2] reOffLine
-- @param #NetworkController2 self
function NetworkController2:reOffLine()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "olgold"
    evt.data = {
        f = "re",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 存储引导
-- @function [parent=#NetworkController2] saveGuide
-- @param #NetworkController2 self
-- @param #string id
function NetworkController2:saveGuide(id)
    --向服务器发送数据
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guide"
    evt.data = {
        f = "ac",
        tm = math.ceil(os_time()),
        id = id
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 请求服务器给客户端发送消息
-- @function [parent=#NetworkController2] reGuideMsg
-- @param #NetworkController2 self
-- @param #string gid
-- @param #string mid
function NetworkController2:reGuideMsg(gid, mid)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guide"
    evt.data = {
        f = "msg",
        tm = math.ceil(os_time()),
        gid = gid,
        mid = mid
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 挑战失败
-- @function [parent=#NetworkController2] buyBossTime
-- @param #NetworkController2 self
function NetworkController2:buyBossTime()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "btime"
    evt.data = {
        f = "buy",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    ch.MoneyModel:addDiamond(-GameConst.SHOP_BUY_BOSS_COST[ch.LevelModel:getBuyCount()+1])
    ch.LevelModel:addBuyCount()
end

---
-- 任务
-- @function [parent=#NetworkController2] getTaskReward
-- @param #NetworkController2 self
-- @param #string id
-- @param #number gold
function NetworkController2:getTaskReward(id,gold)
    self:sendFixedTimeData()
    gold = gold or 0
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "task"
    evt.data = {
        f = "get",
        id = id,
        gold = gold,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    -- 领取奖励要放在发送数据之后，因为会改变任务状态，会影响同步数据
    ch.TaskModel:getTaskReward(id)
end

---
-- 任务过天刷新
-- @function [parent=#NetworkController2] taskRefresh
-- @param #NetworkController2 self
function NetworkController2:taskRefresh()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "task"
    evt.data = {
        f = "rf",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end


---
-- 成就领奖
-- @function [parent=#NetworkController2] getAchievementReward
-- @param #NetworkController2 self
-- @param #string data
-- @param #string id
function NetworkController2:getAchievementReward(data,id)
    self:sendFixedTimeData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "achievement"
    evt.data = {
        f = "get",
        id = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)    
    -- 领取奖励要放在发送数据之后，因为会改变任务状态，会影响同步数据
    if ch.AchievementModel:getRewardType(data) == GameConst.ACHIEVEMENT_REWARD_DIAMOND then
        ch.MoneyModel:addDiamond(ch.AchievementModel:getReward(data))
    end
    -- 先加钻石，再获得成就，获得时会改变状态，放在最后
    ch.AchievementModel:getNewAchievement(data)
end

---
-- 成就状态改为可领奖
-- @function [parent=#NetworkController2] changeAchState
-- @param #NetworkController2 self
-- @param #string type
-- @param #string id
function NetworkController2:changeAchState(type,id)
    if type == "1" then
        self:sendFixedTimeData()
        local evt = zzy.Events:createC2SEvent()
        evt.cmd = "achievement"
        evt.data = {
            f = "chg",
            id = id,
            tm = math.ceil(os_time())
        }
        zzy.EventManager:dispatch(evt)
    end
end

---
-- 请求帮会界面信息
-- @function [parent=#NetworkController2] guildPanel
-- @param #NetworkController2 self
function NetworkController2:guildPanel()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "panel",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 请求加入公会界面（刷新）
-- @function [parent=#NetworkController2] refreshGuild
-- @param #NetworkController2 self
function NetworkController2:refreshGuild()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "rf",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 查看公会详情界面(搜索时只有name)type为打开来源1排行榜2聊天等可加入
-- @function [parent=#NetworkController2] guildDetail
-- @param #NetworkController2 self
-- @param #string id
-- @param #string name
-- @param #number type
function NetworkController2:guildDetail(id,name,type)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "detail",
        id = id,
        name = name,
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 加入公会
-- @function [parent=#NetworkController2] joinGuild
-- @param #NetworkController2 self
-- @param #string id
function NetworkController2:joinGuild(id)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "join",
        id = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 退出公会
-- @function [parent=#NetworkController2] quitGuild
-- @param #NetworkController2 self
-- @param #string id
function NetworkController2:quitGuild(id)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "quit",
        id = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 创建公会
-- @function [parent=#NetworkController2] buildGuild
-- @param #NetworkController2 self
-- @param #string name
-- @param #number flag
function NetworkController2:buildGuild(name,flag)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "build",
        name = name,
        flag = flag,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 设置帮会信息(改名)(与改旗帜合为一条)
-- @function [parent=#NetworkController2] guildChangeName
-- @param #NetworkController2 self
-- @param #string id
-- @param #string name
-- @param #number flag
function NetworkController2:guildChangeName(id,name,flag)
    self._guildName = name
    self._guildFlag = flag
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "changeN",
        id = id,
        name = name,
        flag = flag,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 设置帮会信息(改旗帜)
-- @function [parent=#NetworkController2] guildChangeFlag
-- @param #NetworkController2 self
-- @param #string id
-- @param #number flag
function NetworkController2:guildChangeFlag(id,flag)
    self._guildFlag = flag
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "changeF",
        id = id,
        flag = flag,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 帮会拉人
-- @function [parent=#NetworkController2] guildCallWorld
-- @param #NetworkController2 self
-- @param #string id
-- @param #string say
function NetworkController2:guildCallWorld(id,say)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "call",
        id = id,
        say = say,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 解散公会
-- @function [parent=#NetworkController2] deleteGuild
-- @param #NetworkController2 self
-- @param #string id
function NetworkController2:deleteGuild(id)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "del",
        id = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 踢出公会
-- @function [parent=#NetworkController2] kickGuild
-- @param #NetworkController2 self
-- @param #string id
-- @param #stirng userId
function NetworkController2:kickGuild(id,userId)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "kick",
        id = id,
        userid = userId,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 领取首充奖励
-- @function [parent=#NetworkController2] getFirstPayReward
-- @param #NetworkController2 self
function NetworkController2:getFirstPayReward()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "shop"
    evt.data = {
        f = "firstpay",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 领取七日活动奖励
-- @function [parent=#NetworkController2] getFestivityReward
-- @param #NetworkController2 self
-- @param #number id
-- @param #table item
function NetworkController2:getFestivityReward(id,item)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "festivity"
    evt.data = {
        f = "get",
        id = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    ch.FestivityModel:setFestivityState(id,2)
    ch.CommonFunc:addItems(item)
end

---
-- 排行榜玩家信息
-- @function [parent=#NetworkController2] rankListPlayerData
-- @param #NetworkController2 self
-- @param #table data
function NetworkController2:rankListPlayerData(data)
    --服务器返回错误 则return
    if data.ret and data.ret ~= 0 then
        return
    end   
    if data.f == "player" then
        ch.RankListModel:setRankPlayer(data)
    end
    ch.UIManager:showGamePopup("Guild/W_Guildmemberdetail",{type = 2,value = ch.RankListModel:getRankPlayer()})
end

---
-- 任务过天刷新数据
-- @function [parent=#NetworkController2] taskRefreshData
-- @param #NetworkController2 self
-- @param #table data
function NetworkController2:taskRefreshData(data)
    if data.ret == 0 then
        if data.f == "rf" then
            ch.TaskModel:onNextDayData(data.task)
        end
    end
end

---
-- 进入无尽征途
-- @function [parent=#NetworkController2] startWarpath
-- @param #NetworkController2 self
function NetworkController2:startWarpath()
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "wp"
    evt.data = {
        f = "start",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 无尽征途中杀死怪物
-- @function [parent=#NetworkController2] killedInWarpath
-- @param #NetworkController2 self
-- @param #number index
-- @param #number hp
-- @param #number gold
function NetworkController2:killedInWarpath(index,hp,gold)
    self:_sendUpData(false)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "wp"
    evt.data = {
        f = "kill",
        index = index,
        hp = hp,
        tmoney = ch.MoneyModel:getGold()+gold,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    ch.MoneyModel:addGold(gold)
    ch.CommonFunc:playGoldSound(gold)
    if hp == 0 then
        ch.MoneyModel:addHonour(GameConst.WARPATH_HONOUR_NUM)
    end
end

---
-- 无尽征途奖励领取
-- @function [parent=#NetworkController2] RewardInWarpath
-- @param #NetworkController2 self
function NetworkController2:RewardInWarpath() 
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "wp"
    evt.data = {
        f = "reward",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 无尽征途活动信息改变
-- @function [parent=#NetworkController2] _onInfoChanged
-- @param #NetworkController2 self
-- @param #table evt
function NetworkController2:_onInfoChanged(evt)
    if evt.data.ret == 0 then
        ch.WarpathModel:setProgress(evt.data.data)
        if evt.data.data.statue and evt.data.data.statue == 2 and
            ch.LevelController.mode == ch.LevelController.GameMode.warpath then
            ch.fightRoleLayer:pause()
            ch.UIManager:showMsgBox(1,true,
                GameConst.WARPATH_ERROR_TIPS[1],function()
                    ch.LevelController:startNormal()
                end)
        end
    end
end

---
-- 无尽征途活动可以开始
-- @function [parent=#NetworkController2] _onStartWarpath
-- @param #NetworkController2 self
-- @param #table evt
function NetworkController2:_onStartWarpath(evt)
    if not evt.data.error then
        self:sendCacheData()
        ch.WarpathModel:setProgress(evt.data.data)
        ch.WarpathModel:addTimes()
        ch.LevelController:startWarpath()
    else
        ch.fightRoleLayer:pause()
        ch.UIManager:showMsgBox(1,true,
            GameConst.WARPATH_ERROR_TIPS[evt.data.error],function()
                ch.fightRoleLayer:resume()
            end)
    end
end

---
-- 无尽征途活动中击杀boss的下行
-- @function [parent=#NetworkController2] _onKilledWarpath
-- @param #NetworkController2 self
-- @param #table evt
function NetworkController2:_onKilledWarpath(evt)
    if evt.data.error then
        ch.fightRoleLayer:pause()
        ch.UIManager:showMsgBox(1,true,
            GameConst.WARPATH_ERROR_TIPS[evt.data.error],function()
                ch.LevelController:startNormal()
            end)
    end
end

---
-- 黄金boss结算
-- @function [parent=#NetworkController2] killedGoldBoss
-- @param #NetworkController2 self
-- @param #number isVictory
-- @param #number type boss类型
-- @param #number addMoney 
-- @param #number totalTime
-- @param #number hp
function NetworkController2:killedGoldBoss(isVictory,type,addMoney,totalTime,hp)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "gk"
    evt.data = {
        f = "gbkill",
        tm = math.ceil(os_time()),
        type = type,
        isVictory  = isVictory,
        useTime = totalTime,
        hp = hp
    }
    if type == 1 then
        evt.data.tmoney = ch.MoneyModel:getGold() + addMoney
    else
        evt.data.tmoney = ch.MoneyModel:getGold()   
    end
    zzy.EventManager:dispatch(evt)
    if type == 1 then
        ch.MoneyModel:addGold(addMoney)
        ch.CommonFunc:showGoldRain(addMoney)
    end
end

---
-- 无尽征途战报信息
-- @function [parent=#NetworkController2] warpathReport
-- @param #NetworkController2 self
function NetworkController2:warpathReport()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "wp"
    evt.data = {
        f = "report",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 无尽征途战报增加信息
-- @function [parent=#NetworkController2] warpathReportAdd
-- @param #NetworkController2 self
-- @param #number time
function NetworkController2:warpathReportAdd(time)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "wp"
    evt.data = {
        f = "addrep",
        ltime = time,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 无尽征途公会成员排名
-- @function [parent=#NetworkController2] warpathMemberRank
-- @param #NetworkController2 self
function NetworkController2:warpathMemberRank()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "wp"
    evt.data = {
        f = "member",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 无尽征途公会排名
-- @function [parent=#NetworkController2] warpathGuildRank
-- @param #NetworkController2 self
function NetworkController2:warpathGuildRank()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "wp"
    evt.data = {
        f = "rank",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 无尽征途公会详情
-- @function [parent=#NetworkController2] warpathGuildDetail
-- @param #NetworkController2 self
-- @param #string id
function NetworkController2:warpathGuildDetail(id)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "wp"
    evt.data = {
        f = "guild",
        id = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end


---
-- 坚守阵地开始
-- @function [parent=#NetworkController2] startDefend
-- @param #NetworkController2 self
function NetworkController2:startDefend()
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "tf"
    evt.data = {
        f = "start",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 坚守阵地当前波胜利
-- @function [parent=#NetworkController2] defendLevelVictory
-- @param #NetworkController2 self
-- @param #number killed
-- @param #number totalCount
function NetworkController2:defendLevelVictory(killed,totalCount)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "tf"
    evt.data = {
        f = "level",
        tm = math.ceil(os_time()),
        s1 = ch.DefendModel:getCritLevel(),
        s2= ch.DefendModel:getAttackLevel(),
        s3 = ch.DefendModel:getPowerDropLevel(),
        hp = ch.DefendModel:getHP(),
        cry = ch.DefendModel:getCrystals(),
        dps = ch.RunicModel:getDPS(),
        killed = killed,
        total = totalCount,
        gold = ch.DefendModel:getTotalGold(),
        level = ch.DefendModel:getCurLevel()
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 坚守阵地当前波胜利
-- @function [parent=#NetworkController2] _onDefendLevelVictory
-- @param #NetworkController2 self
-- @param #table data
function NetworkController2:_onDefendLevelVictory(data)
    ch.DefendModel:setRewardContent(data)
    ch.UIManager:showGamePopup("Guild/W_JSZDwaveresult")
end

---
-- 坚守阵地当前波胜利的领取
-- @function [parent=#NetworkController2] defendChooseReward
-- @param #NetworkController2 self
-- @param #number index
function NetworkController2:defendChooseReward(index)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "tf"
    evt.data = {
        f = "lr",
        tm = math.ceil(os_time()),
        index = index
    }
    zzy.EventManager:dispatch(evt)
    ch.DefendModel:addReward(index)
    if index == 0 then
        ch.MoneyModel:addDiamond(-GameConst.DEFEND_LEVEL_REWARD_COST)
    end
end

---
-- 坚守阵地奖励领取
-- @function [parent=#NetworkController2] RewardInDefend
-- @param #NetworkController2 self
-- @param #number level
-- @param #number kill
-- @param #number addGold
function NetworkController2:RewardInDefend(level,kill,addGold)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "tf"
    evt.data = {
        f = "reward",
        level = level,
        kill = kill,
        tmoney = ch.MoneyModel:getGold() + addGold,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    ch.MoneyModel:addGold(addGold)
    ch.CommonFunc:showGoldRain(ch.DefendModel:getTotalGold())
end

---
-- 坚守阵地玩家排名
-- @function [parent=#NetworkController2] defendMemberRank
-- @param #NetworkController2 self
function NetworkController2:defendMemberRank()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "tf"
    evt.data = {
        f = "member",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 领取礼包码
-- @function [parent=#NetworkController2] getGift
-- @param #NetworkController2 self
-- @param #string cdk
function NetworkController2:getGift(cdk)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "gift"
    evt.data = {
        f = "act",
        tm = math.ceil(os_time()),
        cdk = cdk.." "
    }
    zzy.EventManager:dispatch(evt)
    ch.TimerController.canSend = false
    ch.fightRoleLayer:pause()
end

---
-- 礼包码返错
-- @function [parent=#NetworkController2] _onGetGift
-- @param #NetworkController2 self
-- @param #table evt
function NetworkController2:_onGetGift(evt)
    ch.fightRoleLayer:resume()
    if evt.data.error and evt.data.error ~= 0 then
        ch.TimerController.canSend = true
        local tipIndex = evt.data.error
        if tipIndex > 1100 then
            tipIndex = tipIndex - 1103
        end
        tipIndex = tipIndex > #GameConst.GIFT_ERROR_TIPS and 1 or tipIndex
        ch.UIManager:showMsgBox(1,true,GameConst.GIFT_ERROR_TIPS[tipIndex])
    end
end

---
-- 获得物品
-- @function [parent=#NetworkController2] _onGetItems
-- @param #NetworkController2 self
-- @param #table evt
function NetworkController2:_onGetItems(evt)
    if evt.data.ret == 0 then
        ch.CommonFunc:addItems(evt.data.items)
        ch.UIManager:showGamePopup("setting/W_SNbonus",evt.data.items)
    end
end

---
-- 获取分享奖励
-- @function [parent=#NetworkController2] getShareReward
-- @param #NetworkController2 self
-- @param #table reward
function NetworkController2:getShareReward(params)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "share"
    evt.data = {
        f = params.f,
        type = params.type,
        id = params.id,
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 等待上行宝物升级
-- @function [parent=#NetworkController] isWaitingForMagicLevelUp
function NetworkController2:isWaitingForMagicLevelUp()
    local isWaiting = false
    
    local cachedId = self._data.magicLevelUpData.id
    if cachedId then
        isWaiting = true
    end 
    
    return isWaiting
end

return NetworkController2

