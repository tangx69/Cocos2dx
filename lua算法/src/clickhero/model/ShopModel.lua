---
-- 商店 model层     结构 {goldCount = 3}
--@module ShopModel
local ShopModel = {
    _data = nil,
    isSelect = false,
    isEffect = false, --是否显示新手礼包按钮上的转圈特效
    dataChangeEventType = "SHOP_MODEL_DATA_CHANGE", --{type=,}
    dataChangeEventType_GiftBag = "SHOP_MODEL_DATA_CHANGE_GIFTBAG", --新手礼包事件
    dataType = {
        all = 0,
        gold = 1,
        star = 2,
        chat = 3,
        samsara = 4,
        firstPay = 5,
        diamondStar = 6,
        totalCharge= 7,
        firstID = 8
    }
}

---
-- @function [parent=#ShopModel] init
-- @param #ShopModel self
-- @param #table data
function ShopModel:init(data)
    if data.shop then
        self._data = data.shop
    else
        self._data = {goldCount = 0,starSoulCount = GameConst.MGAIC_STAR_SOUL_COUNT,samsaraCount = GameConst.RUNIC_SAMSARA_COUNT,firstPay = 0,diamondStar = 0,totalCharge = 0}
    end
    --self:_addListenerCharge()
end

---
-- @function [parent=#ShopModel] clean
-- @param #ShopModel self
function ShopModel:clean()
    self._data = nil
    self.isSelect = nil
end


---添加充值的侦听
-- @function [parent=#ShopModel] _addListenerCharge
-- @param #ShopModel self
function ShopModel:_addListenerCharge()
    zzy.EventManager:listen(zzy.Sdk.Events.chargeDone, function(sender, evt)
        --cclog("lua chargeDone")
    end) 
end

function ShopModel:_raiseDataChangeEvent(dataType)
    local evt = {
        type = self.dataChangeEventType,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end

function ShopModel:_raiseDataChangeEvent_GiftBag()
    local evt = {
        type = self.dataChangeEventType_GiftBag
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 获得已经购买金币的次数
-- @function [parent=#ShopModel] getGoldCount
-- @param #ShopModel self
-- @return #number
function ShopModel:getGoldCount()
    return self._data["goldCount"]
end

---
-- 购买金币的价格
-- @function [parent=#ShopModel] getGoldPrice
-- @param #ShopModel self
-- @param #number id
-- @return #number
function ShopModel:getGoldPrice(id)
    return math.floor(0.5+(1 + self._data["goldCount"]*GameConst.SHOP_BUY_GOLD_PRICE_ADD)*GameConfig.ShopConfig:getData(id).price)
end

---
-- 添加已经购买的次数
-- @function [parent=#ShopModel] addGoldCount
-- @param #ShopModel self
-- @param #number count
function ShopModel:addGoldCount(count)
    count = count or 1
    self._data["goldCount"] = self._data["goldCount"] + count
    self:_raiseDataChangeEvent(self.dataType.gold)
end

---
-- 获得已经魂转移镀金的次数
-- @function [parent=#ShopModel] getStarSoulCount
-- @param #ShopModel self
-- @return #number
function ShopModel:getStarSoulCount()
    return self._data["starSoulCount"]
end

---
-- 添加可免费转移镀金的次数
-- @function [parent=#ShopModel] addStarSoulCount
-- @param #ShopModel self
-- @param #number count
function ShopModel:addStarSoulCount(count)
    if count ~= 0 then
        self._data["starSoulCount"] = self._data["starSoulCount"] + count
        self:_raiseDataChangeEvent(self.dataType.star)
    end
end

---
-- 获得世界发言的次数
-- @function [parent=#ShopModel] getChatCount
-- @param #ShopModel self
-- @return #number
function ShopModel:getChatCount()
    return self._data["chatCount"]
end

---
-- 添加世界发言的次数
-- @function [parent=#ShopModel] addChatCount
-- @param #ShopModel self
-- @param #number count
function ShopModel:addChatCount(count)
    count = count or 1
    self._data["chatCount"] = self._data["chatCount"] + count
    self:_raiseDataChangeEvent(self.dataType.chat)
end

---
-- 获得可转生次数
-- @function [parent=#ShopModel] getSamsaraCount
-- @param #ShopModel self
-- @return #number
function ShopModel:getSamsaraCount()
    return self._data["samsaraCount"]
end

---
-- 添加可转生次数
-- @function [parent=#ShopModel] addSamsaraCount
-- @param #ShopModel self
-- @param #number count
function ShopModel:addSamsaraCount(count)
    if count ~= 0 then
        self._data["samsaraCount"] = self._data["samsaraCount"] + count
        self:_raiseDataChangeEvent(self.dataType.samsara)
    end
end

---
-- 获得首充领奖状态
-- @function [parent=#ShopModel] getFirstPay
-- @param #ShopModel self
-- @return #number
function ShopModel:getfirstPay()
    return self._data["firstPay"]
end

---
-- 修改首充领奖状态
-- @function [parent=#ShopModel] setFirstPay
-- @param #ShopModel self
-- @param #number state
function ShopModel:setfirstPay(state)
    self._data["firstPay"] = state
    self:_raiseDataChangeEvent(self.dataType.firstPay)
end

---
-- 获得已经钻石转移圣光的次数
-- @function [parent=#ShopModel] getDiamondStar
-- @param #ShopModel self
-- @return #number
function ShopModel:getDiamondStar()
    return self._data["diamondStar"]
end

---
-- 添加已经钻石转移圣光的次数
-- @function [parent=#ShopModel] addDiamondStar
-- @param #ShopModel self
-- @param #number count
function ShopModel:addDiamondStar(count)
    count = count or 1
    self._data["diamondStar"] = self._data["diamondStar"] + count
    self:_raiseDataChangeEvent(self.dataType.diamondStar)
end

---
-- 获得累计充值数
-- @function [parent=#ShopModel] getTotalCharge
-- @param #ShopModel self
-- @return #number count
function ShopModel:getTotalCharge()
    return self._data.totalCharge
end

---
-- 设置累计充值数
-- @function [parent=#ShopModel] setTotalCharge
-- @param #ShopModel self
-- @param #number count
function ShopModel:setTotalCharge(count)
    if self._data.totalCharge ~= count then
        self._data.totalCharge = count
        self:_raiseDataChangeEvent(self.dataType.totalCharge)
    end
end

---
-- 今天是否出现钻石类购买确认
-- @function [parent=#ShopModel] setSelectState
-- @param #ShopModel self
-- @param #boolean select
function ShopModel:setSelectState(select)
    self.isSelect = select or false
end

---
-- 今天是否出现钻石类购买确认
-- @function [parent=#ShopModel] getSelectState
-- @param #ShopModel self
-- @return #boolean
function ShopModel:getSelectState()
    return self.isSelect
end

---
-- 花费钻石二次确认
-- @function [parent=#ShopModel] getCostTips
-- @param #ShopModel self
-- @param #table tmpTable {price=1,buy=function() end}
function ShopModel:getCostTips(tmpTable)
    if not ch.ShopModel:getSelectState() and string.sub(zzy.Sdk.getFlag(),1,2)=="CY" then
        ch.UIManager:showGamePopup("Shop/W_shop_confirm_diamond",tmpTable)   
    else
        tmpTable.buy()
    end
end

---
-- 是否是充值翻倍
-- @function [parent=#ShopModel] getFirstID
-- @param #ShopModel self
-- @param #number id
-- @return #number
function ShopModel:getFirstID(id)
    id = tostring(id)
    if self._data["firstID"] and self._data["firstID"][id] then
        return self._data["firstID"][id]
    else
        return 0
    end
end

---
-- 是否是充值翻倍
-- @function [parent=#ShopModel] setFirstID
-- @param #ShopModel self
-- @param #number id
function ShopModel:setFirstID(id)
    id = tostring(id)
    if not self._data["firstID"] then
        self._data["firstID"] = {}
    end
    self._data["firstID"][id] = 1
    self:_raiseDataChangeEvent(self.dataType.firstID) 
end

---
-- 过天逻辑
-- @function [parent=#ShopModel] onNextDay
-- @param #ShopModel self
function ShopModel:onNextDay()
    self._data["goldCount"] = 0
    self._data["chatCount"] = 0
    self._data["diamondStar"] = 0
    if self._data["starSoulCount"] < GameConst.MGAIC_STAR_SOUL_COUNT then
        self._data["starSoulCount"] = GameConst.MGAIC_STAR_SOUL_COUNT
    end
    if self._data["samsaraCount"] >= GameConst.RUNIC_SAMSARA_COUNT_MAX then
        self._data["samsaraCount"] = GameConst.RUNIC_SAMSARA_COUNT_MAX
    else
        self._data["samsaraCount"] = self._data["samsaraCount"] + GameConst.RUNIC_SAMSARA_COUNT
    end
    self:_raiseDataChangeEvent(self.dataType.all)
end

---
-- 获取开服多少天
-- @function [parent=#ShopModel] getSvrDays
-- @param #ShopModel self
-- @return #number
function ShopModel:getSvrDays()
    return self._data["svrdays"]
end

---
-- 跨天时更新本地开服时间
-- @function [parent=#ShopModel] updateLocalSvrDays
-- @param #ShopModel self
function ShopModel:updateLocalSvrDays()
    self._data["svrdays"] = self._data["svrdays"] + 1
end



---
-- 设置可购买新手礼包的状态 0未购买1已购买2已过期
-- @function [parent=#ShopModel] setGiftBagState
-- @param #ShopModel self
-- @param #number state
function ShopModel:setGiftBagState(state)
    self._data.giftData = self._data.giftData or {}
    self._data.giftData.state = state
    self:_raiseDataChangeEvent_GiftBag()
end

---
-- 设置可购买新手礼包的截止时间
-- @function [parent=#ShopModel] setGiftBagTime
-- @param #ShopModel self
-- @param #number timestamp
function ShopModel:setGiftBagTime(timestamp)
    self._data.giftData = self._data.giftData or {}
    self._data.giftData.time = timestamp
    self.isEffect = self:isGiftBagCanBuy()
    self:_raiseDataChangeEvent_GiftBag()
end

---
-- 获取可购买新手礼包的截止时间
-- @function [parent=#ShopModel] getGiftBagTime
-- @param #ShopModel self
function ShopModel:getGiftBagTime()
    return self._data.giftData and self._data.giftData.time or 0
end

---
-- 新手礼包是否可购买，即是否在购买时间内
-- @function [parent=#ShopModel] isGiftBagCanBuy
-- @param #ShopModel self
function ShopModel:isGiftBagCanBuy()
    if self._data.giftData then
        return self._data.giftData.state == 0 and self._data.giftData.time > os_time()
    end
    return false
end

---
-- 设置是否显示新手礼包按钮上的转圈特效
-- @function [parent=#ShopModel] showGiftBagEffect
-- @param #ShopModel self
-- @param #boolean isShow
function ShopModel:showGiftBagEffect(isShow)
    self.isEffect = isShow
    self:_raiseDataChangeEvent_GiftBag()
end

---
-- 是否显示新手礼包按钮上的转圈特效
-- @function [parent=#ShopModel] isShowGiftBagEffect
-- @param #ShopModel self
function ShopModel:isShowGiftBagEffect()
    return self.isEffect
end

return ShopModel