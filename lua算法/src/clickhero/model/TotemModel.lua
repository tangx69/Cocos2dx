---
-- 图腾 model层     结构 {clean = 0,own={"1":0}, ... },randTotem={}}
--@module TotemModel
local TotemModel = {
    _data = nil,
    _skillData = nil,
    _totemOrderData = nil,  -- 数组，{"15","12"}保证图腾的显示顺序
    _ownTotems = nil,
    _restTotems = nil,
    _returnSoul = nil,
    _newID = nil,
    isDiamond = false,
    _totemNum = nil,
    _totemSeniorNum = nil,
    _ownNum = nil,
    _ownSeniorNum = nil,
    dataChangeEventType = "TotemModelDataChange", --{type = ,id=,dataType =}
    refreshChangeEventType = "TotemModelRefreshChange", -- {type = , dataType = }
    dataType = {
        level = 1,
        refresh = 2
    },
    showEffect = false,
    showEffectChangeEventType = "TotemModelShowEffect"
}

ENCODE_NUM = ENCODE_NUM or function(num)
    return num
end

DECODE_NUM = DECODE_NUM or function(num)
    return num
end

---
-- @function [parent=#TotemModel] init
-- @param #TotemModel self
-- @param #table data
function TotemModel:init(data)
    self._data = data.totem
    self._data.randS = self._data.randS or {}
    self._ownTotems = {}
    self._restTotems = {}
    self._returnSoul = 0
    self:_cacheAllSkillData()
    self:_orderTotem()
    self:_getRestTotem()
    self:getCurTotem()
end

---
-- @function [parent=#TotemModel] clean
-- @param #TotemModel self
function TotemModel:clean()
    self._data = nil
    self._skillData = nil
    self._totemOrderData = nil
    self._ownTotems = nil
    self._restTotems = nil
    self._returnSoul = nil
    self._newID = nil
end

---
-- 没有图腾时，请求服务器 刷新列表中的数据
-- @function [parent=#TotemModel] requitRefresh
-- @param #TotemModel self
-- @return #table
function TotemModel:requitRefresh()
    local isBlank = true
    local isSenior = true
    for  k,v in pairs(self._data.randTotem) do
        if v ~= "0" then
        	isBlank = false
        	break
        end
    end
    
    for  k,v in pairs(self._data.own) do
        if v ~= "0" then
            isBlank = false
            break
        end
    end
    
    for  k,v in pairs(self._data.randS) do
        if v ~= "0" then
            isSenior = false
            break
        end
    end
    if self:getOwnTotemNum(2) > 0 then
        isSenior = false 
    end
    if isBlank == true then
        cclog("+++++++++++++++++++++请求图腾刷新列表中的数据")
        local evt = zzy.Events:createC2SEvent()
        evt.cmd = "totem"
        evt.data = {
            f = "rf",
            type = -1,
            tm = math.ceil(os_time())
        }
        zzy.EventManager:dispatch(evt)
    end
    if isSenior == true then
        if ch.StatisticsModel:getMaxLevel() > GameConst.TOTEM_SENIOR_OPEN_LEVEL then
            self:setShowEffect(true)
        end
        cclog("请求图腾刷新列表中的数据++++++高级图腾")
        local evt = zzy.Events:createC2SEvent()
        evt.cmd = "totem"
        evt.data = {
            f = "rfS",
            type = -1,
            tm = math.ceil(os_time())
        }
        zzy.EventManager:dispatch(evt)
    end
end

function TotemModel:_raiseDataChangeEvent(id,dataType,num)
    local evt = {
        type = self.dataChangeEventType,
        id = id,
        dataType = dataType,
        value = num or 0
    }
    zzy.EventManager:dispatch(evt)
end

function TotemModel:_refreshChangeEvent(dataType)
    local evt = {
        type = self.refreshChangeEventType,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end

function TotemModel:_showEffectChangeEvent()
    local evt = {
        type = self.showEffectChangeEventType
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 是否显示高级图腾开启提示
-- @function [parent=#TotemModel] getShowEffect
-- @param #TotemModel self
-- @return #boolean
function TotemModel:getShowEffect()
    return self.showEffect
end

---
-- 是否显示高级图腾开启提示
-- @function [parent=#TotemModel] setShowEffect
-- @param #TotemModel self
-- @param #boolean isShow
function TotemModel:setShowEffect(isShow)
    if isShow ~= self.showEffect then
        self.showEffect = isShow
        self:_showEffectChangeEvent()
    end
end

---
-- 获取当前需要显示的图腾
-- @function [parent=#TotemModel] getCurTotem
-- @param #TotemModel self
-- @return #table
function TotemModel:getCurTotem()
    self._ownNum = 0
    self._ownSeniorNum = 0
    if table.maxn(self._ownTotems)<1 then
        for  k,v in pairs(self._data.own) do
            table.insert(self._ownTotems,tostring(k))
        end
    end
    -- 更改未获得的图腾
    self:_getRestTotem()
    local tmp = {}
    for i = 1,table.maxn(self._ownTotems) do
        table.insert(tmp,self._ownTotems[i])
        if GameConfig.TotemConfig:getData(self._ownTotems[i]).type == 1 then
            self._ownNum = self._ownNum + 1
        elseif GameConfig.TotemConfig:getData(self._ownTotems[i]).type == 2 then
            self._ownSeniorNum = self._ownSeniorNum + 1
        end
    end
    
--    table.sort(tmp,function(t1,t2)
--        local maxLv1 = GameConfig.TotemConfig:getData(t1).maxlv
--        local maxLv2 = GameConfig.TotemConfig:getData(t2).maxlv
--        if maxLv1 > 0 and self:getLevel(t1) >= maxLv1 then
--            return false
--        elseif maxLv2 > 0 and self:getLevel(t2) >= maxLv2 then
--            return true
--        else
--            return maxLv1 < maxLv2
--        end
--    end)

    table.sort(tmp,function(t1,t2)
        local data1 = GameConfig.TotemConfig:getData(t1)
        local data2 = GameConfig.TotemConfig:getData(t2)

        local power1 = 0
        if data1.maxlv > 0 and self:getLevel(t1) >= data1.maxlv then
            power1 = power1 + 100000000
        end
        power1 = power1 + data1.id * 10 - data1.type * 10000

        local power2 = 0
        if data2.maxlv > 0 and self:getLevel(t2) >= data2.maxlv then
            power2 = power2 + 100000000
        end
        power2 = power2 + data2.id * 10 - data2.type * 10000

        return power1 < power2
    end)
    return tmp
end

---
-- 清除当前图腾
-- @function [parent=#TotemModel] cleanTotem
-- @param #TotemModel self
function TotemModel:cleanTotem()
    cclog("清除图腾")
    self._data.soul = 0
    self._data.diamond = 0
    self._data.clean = self._data.clean + 1
    self._ownTotems = {}
    self._restTotems = {}
    self._skillData = {}
    self:_getRestTotem()
    --self:_refreshTotem()
    for k,v in pairs(self._data.own) do
        self._data.own[k] = nil
    end
    ch.MagicModel:resetDPS()
    self:_raiseDataChangeEvent("1",self.dataType.level)
end

---
-- 是否拥有
-- @function [parent=#TotemModel] isOwn
-- @param #TotemModel self
-- @param #string id
-- @return #bool 
function TotemModel:isOwn(id)
	for k,v in pairs(self._ownTotems) do
	   if tonumber(id) == tonumber(v) then
	       return true
	   end
	end
	return false
end



---
-- 添加图腾
-- @function [parent=#TotemModel] addTotem
-- @param #TotemModel self
-- @param #string id
function TotemModel:addTotem(id)
    local ifinsert = true
    for i = 1,table.maxn(self._ownTotems) do
    	if self._ownTotems[i] == tostring(id) then
    	   ifinsert = false
    	   break   
    	end
    end
    if ifinsert then
        table.insert(self._ownTotems,tostring(id))
        self._data.own[tostring(id)] = 1
        
        -- 从未获得列表取出
        for i = 1,table.maxn(self._restTotems) do
            if self._restTotems[i] == tostring(id) then
                table.remove(self._restTotems,i)
            end
        end
        cclog(table.maxn(self._restTotems))
    end
    -- 1,6 和 1,7 调函数
    if id == "9" or id == "10" or id == "109" then
        ch.MagicModel:resetDPS()
    end
    if GameConfig.TotemConfig:getData(id).type == 1 then
        self._ownNum = self._ownNum + 1
    elseif GameConfig.TotemConfig:getData(id).type == 2 then
        self._ownSeniorNum = self._ownSeniorNum + 1
    end
    self:_cacheSkillData(id)
    self:setTotemNewID(id)
    self:_raiseDataChangeEvent(id,self.dataType.level,1)
end

---
-- 获取刚获得的图腾id 
-- @function [parent=#TotemModel] getTotemNewID
-- @param #TotemModel self
-- @return #string
function TotemModel:getTotemNewID()
    return self._newID or "0"
end

---
-- 设置刚获得的图腾id 
-- @function [parent=#TotemModel] setTotemNewID
-- @param #TotemModel self
-- @param #string id
function TotemModel:setTotemNewID(id)
    self._newID = id
end

---
-- 获取图腾等级
-- @function [parent=#TotemModel] getLevel
-- @param #TotemModel self
-- @param #string id
-- @return #number
function TotemModel:getLevel(id)
    id = tostring(id)
    if self._data.own[id] then
        return DECODE_NUM(self._data.own[id])
    else
        return 0
    end
end

---
-- 设置图腾等级
-- @function [parent=#TotemModel] setLevel
-- @param #TotemModel self
-- @param #string id
-- @param #number level
function TotemModel:setLevel(id,level)
    id = tostring(id)
    local old = self:getLevel(id)
    if old ~= level then
        if id == "109" then
            ch.MagicModel:resetDPS()
        end

        if not self._data.own[id] then
            self._data.own[id] = 0
        end
        self._data.own[id] = level
        self._data.own[id] = ENCODE_NUM(self._data.own[id])
        self:_cacheSkillData(id)
        self:_raiseDataChangeEvent(id,self.dataType.level)
    end
end

---
-- 添加图腾等级
-- @function [parent=#TotemModel] addLevel
-- @param #TotemModel self
-- @param #string id
-- @param #number level 默认为1
function TotemModel:addLevel(id,level)
    level = level or 1
    id = tostring(id)
    if level ~= 0 then
        if not self._data.own[id] then
            self._data.own[id] = 1
        end
        self._data.own[id] = self:getLevel(id) + level
        self._data.own[id] = ENCODE_NUM(self._data.own[id])
        self:_cacheSkillData(id)
        if id == "9" or id == "10" or id == "109" then
            ch.MagicModel:resetDPS()
        end
        self:_raiseDataChangeEvent(id,self.dataType.level,level)
    end
end

---
-- 获得图腾升级需要的魂
-- @function [parent=#TotemModel] getLevelUpCost
-- @param #TotemModel self
-- @param #string id 图腾id
-- @param #number addLevel 要升的等级数(暂时没加，只是升一级的消耗)
-- @return #number
function TotemModel:getLevelUpCost(id,addLevel)
    local costt = 0
    local costp = 0
    
    id = tostring(id)
    local config = GameConfig.TotemConfig:getData(id)
    
    if config and addLevel > 0 then
        local level = self:getLevel(id)
        
        for i=1,addLevel do
            if config.priceType == 1 then
                local _costt, _costp = GameConst.TOTEM_LEVELUP_COST1(level)
                costt = costt + _costt
                costp = costp + _costp
            elseif config.priceType == 2 then
                local _costt, _costp = GameConst.TOTEM_LEVELUP_COST2(level)
                costt = costt + _costt
                costp = costp + _costp
            elseif config.priceType == 3 then
                local _costt, _costp = GameConst.TOTEM_LEVELUP_COST3(level)
                costt = costt + _costt
                costp = costp + _costp
            elseif config.priceType == 4 then
                local _costt, _costp = GameConst.TOTEM_LEVELUP_COST4(level)
                costt = costt + _costt
                costp = costp + _costp
            else
                local _costt, _costp = GameConst.TOTEM_LEVELUP_COST2(level)
                costt = costt + _costt
                costp = costp + _costp
            end

            level =  level + 1
        end
    else
        error("该图腾在配置表中不存在或者addLevel小于等于0，图腾id:"..id)
    end
    
    return costt, costp
end

---
-- 获得图腾当前消耗的魂(暂时不加钻石升级消耗，要改数值存储计算)(可能删掉了)
-- @function [parent=#TotemModel] getTotemCost
-- @param #TotemModel self
-- @param #string id 图腾id
-- @return #number
function TotemModel:getTotemCost(id)
    id = tostring(id)
    local config = GameConfig.TotemConfig:getData(id)
    if config then
        local level = self:getLevel(id)
        local tmpFunc = nil
        if config.priceType == 1 then
            tmpFunc = function(num)
            	return self:levelUpCost1(num+1,1)
            end
        elseif config.priceType == 2 then
            tmpFunc = function(num)
                return self:levelUpCost2(num+1,1)
            end
        elseif config.priceType == 3 then
            tmpFunc = function(num)
                return self:levelUpCost3(num+1,1)
            end
        elseif config.priceType == 4 then
            tmpFunc = function(num)
                return self:levelUpCost4(num+1,1)
            end
        else
            tmpFunc = function(num)
                return self:levelUpCost2(num+1,1)
            end
        end
        local tmpCost = 0
        for i = 1,level-1 do
            tmpCost = tmpCost + tmpFunc(i)
        end
        return tmpCost
    else
        error("该图腾在配置表中不存在或者addLevel小于等于0，图腾id:"..id)
    end
end


---
-- 获取拥有图腾个数
-- @function [parent=#TotemModel] getOwnTotemNum
-- @param #TotemModel self
-- @param #number type
-- @return #number
function TotemModel:getOwnTotemNum(type)
    type = type or 1
    if type == 1 then
        return self._ownNum
    elseif type == 2 then
        return self._ownSeniorNum
    else
        return 0
    end
end

---
-- 所有图腾个数
-- @function [parent=#TotemModel] getAllTotemNum
-- @param #TotemModel self
-- @param #number type
-- @return #number
function TotemModel:getAllTotemNum(type)
    if type == 1 then
        return self._totemNum
    elseif type == 2 then
        return self._totemSeniorNum
    else
        return table.maxn(self._totemOrderData)
    end
end

---
-- 清除图腾花费钻石数
-- @function [parent=#TotemModel] getCleanDiamondPrice
-- @param #TotemModel self
-- @return #number
function TotemModel:getCleanDiamondPrice()
    if self._data.clean >= GameConst.TOTEM_FREE_COUNT then
        return GameConst.TOTEM_DIAMOND_COST
    else
        return 0
    end
end

---
-- 免费100%清除次数
-- @function [parent=#TotemModel] getFreeCount
-- @param #TotemModel self
-- @return #number
function TotemModel:getFreeCount()
    if self._data.clean >= GameConst.TOTEM_FREE_COUNT then
        return 0
    else
        return GameConst.TOTEM_FREE_COUNT - self._data.clean
    end
end

---
-- 完全返回魂数
-- @function [parent=#TotemModel] getReturnSoul
-- @param #TotemModel self
-- @return #number
function TotemModel:getReturnSoul()
    return self._data.soul
end

---
-- 完全返回钻石数
-- @function [parent=#TotemModel] getReturnSoul
-- @param #TotemModel self
-- @return #number
function TotemModel:getReturnDiamond()
    return self._data.diamond
end

---
-- 免费返回魂数
-- @function [parent=#TotemModel] getReturnSoulFree
-- @param #TotemModel self
-- @return #number
function TotemModel:getReturnSoulFree()
    if self:getCleanDiamondPrice()>0 then
        return math.floor(self:getReturnSoul() * GameConst.TOTEM_RETURN_RATIO)
    else
        return self:getReturnSoul()
    end
end

---
-- 免费返回钻石数
-- @function [parent=#TotemModel] getReturnDiamondFree
-- @param #TotemModel self
-- @return #number
function TotemModel:getReturnDiamondFree()
    if self:getCleanDiamondPrice()>0 then
        return math.floor(self:getReturnDiamond() * GameConst.TOTEM_RETURN_RATIO)
    else
        return self:getReturnDiamond()
    end
end

---
-- 图腾等级上限
-- @function [parent=#TotemModel] getMaxLevel
-- @param #TotemModel self
-- @param #string id
-- @return #string
function TotemModel:getMaxLevel(id)
    if GameConfig.TotemConfig:getData(id).maxlv > 0 then
        return GameConfig.TotemConfig:getData(id).maxlv
    else
        return Language.src_clickhero_model_TotemModel_1
    end
end

---
-- 是否达到图腾等级上限
-- @function [parent=#TotemModel] ifLvMax
-- @param #TotemModel self
-- @param #string id
-- @return #number
function TotemModel:ifLvMax(id)
    if GameConfig.TotemConfig:getData(id).maxlv <= 0 then
        return true
    elseif self:getLevel(id) < GameConfig.TotemConfig:getData(id).maxlv then 
        return true
    else
        return false
    end
end

---
-- 刷新图腾花费钻石数
-- @function [parent=#TotemModel] getRefreshDiamondPrice
-- @param #TotemModel self
-- @param #number type
-- @return #number
function TotemModel:getRefreshDiamondPrice(type)
    type = type or 1
    local ownNum = self:getOwnTotemNum(type)
    if type == 1 and self._totemNum - ownNum > 4 then
        return GameConst.TOTEM_REFRESH_DIAMOND[ownNum+1]
    elseif type == 2 and self._totemSeniorNum - ownNum > 4 then
        return GameConst.TOTEM_SENIOR_REFRESH_DIAMOND[ownNum+1]
    else
        return 0
    end
end

---
-- 刷新图腾花费魂数
-- @function [parent=#TotemModel] getRefreshSoulPrice
-- @param #TotemModel self
-- @param #number type
-- @return #number
function TotemModel:getRefreshSoulPrice(type)
    type = type or 1
    local ownNum = self:getOwnTotemNum(type)
    if type == 1 and self._totemNum - ownNum > 4 then
        return GameConst.TOTEM_REFRESH_SOUL[ownNum+1]
    else
        return 0
    end
end

---
-- 未获得图腾个数
-- @function [parent=#TotemModel] getrestTotemsNum
-- @param #TotemModel self
-- @return #number
function TotemModel:getrestTotemsNum()
    return table.maxn(self._restTotems)
end

---
-- 选择界面的4个图腾ID
-- @function [parent=#TotemModel] _getrandTotems
-- @param #TotemModel self
-- @return #table
function TotemModel:_getrandTotems()
    local tmp = {}
    for i=1,4 do
        tmp[i] = self._data.randTotem[i] or "0"
    end
    return tmp
end

---
-- 高级选择界面的4个图腾ID
-- @function [parent=#TotemModel] getrandTotems_senior
-- @param #TotemModel self
-- @return #table
function TotemModel:getrandTotems_senior()
    local tmp = {}
    for i=1,4 do
        tmp[i] = self._data.randS[i] or "0"
    end
    return tmp
end

---
-- 召唤图腾花费魂数
-- @function [parent=#TotemModel] getCallSoulPrice
-- @param #TotemModel self
-- @param #number type
-- @return #number
function TotemModel:getCallSoulPrice(type)
    type = type or 1
    if type == 1 then
        return GameConst.TOTEM_CALL_SOUL[self:getOwnTotemNum(type)+1]
    else
        return 0
    end
end

---
-- 召唤图腾花费钻石数
-- @function [parent=#TotemModel] getCallDiamondPrice
-- @param #TotemModel self
-- @param #number type
-- @return #number
function TotemModel:getCallDiamondPrice(type)
    type = type or 0
    if type == 1 then
        return GameConst.TOTEM_CALL_DIAMOND[self:getOwnTotemNum(type)+1]
    elseif type == 2 then
        return GameConst.TOTEM_SENIOR_CALL_DIAMOND[self:getOwnTotemNum(type)+1]
    else
        return 0
    end
end

---
-- 记录召唤图腾花费的总钻石数(不用了)
-- @function [parent=#TotemModel] addCallDiamondNum
-- @param #TotemModel self
-- @param #number addNum
function TotemModel:addCallDiamondNum(addNum)
    self._data.diamond = self._data.diamond + addNum
end

---
-- 记录召唤图腾花费的总魂数(不用了)
-- @function [parent=#TotemModel] addCallSoulNum
-- @param #TotemModel self
-- @param #number addNum
function TotemModel:addCallSoulNum(addNum)
    self._data.soul = self._data.soul + addNum
end

---
-- 缓存所有的图腾技能加成
-- @function [parent=#TotemModel] _cacheAllSkillData
-- @param #TotemModel self
function TotemModel:_cacheAllSkillData()
    self._skillData = {}
    if self._data.own then
        for k,v in pairs(self._data.own) do
            self:_cacheSkillData(k)
        end
    end
end

---
-- 缓存图腾在当前等级的技能加成数据
-- @function [parent=#TotemModel] _cacheSkillData
-- @param #TotemModel self
-- @param #string id
function TotemModel:_cacheSkillData(id)
    id = tostring(id)
    local bigType = GameConfig.TotemConfig:getData(id).bigType
    local smallType = GameConfig.TotemConfig:getData(id).smallType
    if self._skillData[bigType] == nil then self._skillData[bigType] = {} end
    self._skillData[bigType][smallType] = 0
    local totemData = GameConfig.TotemConfig:getTable()
    for k,v in pairs(totemData) do
        if v.bigType == bigType and v.smallType == smallType then
            self._skillData[bigType][smallType] = self._skillData[bigType][smallType] + self:getSkillData(v.id,true)
        end
    end
end

---
-- 排序图腾，按顺序显示 
-- @function [parent=#TotemModel] _orderTotem
-- @param #TotemModel self
function TotemModel:_orderTotem()
    self._totemNum = 0
    self._totemSeniorNum = 0
    local cs = GameConfig.TotemConfig:getTable()
    local totems = {}
    for k,v in pairs(cs) do
        table.insert(totems,{id = k})
        if v.type == 1 then
            self._totemNum = self._totemNum + 1
        elseif v.type == 2 then
            self._totemSeniorNum = self._totemSeniorNum + 1
        end
    end
    table.sort(totems,function(t1,t2)
        return t1.id < t2.id
    end)
    self._totemOrderData = {}
    for k,v in ipairs(totems) do
        table.insert(self._totemOrderData,v.id)
    end
end

---
-- 刷新图腾，刷出4个 
-- @function [parent=#TotemModel] _refreshTotem
-- @param #TotemModel self
--function TotemModel:_refreshTotem()
--    math.randomseed(os_clock())
--    local num = table.maxn(self._restTotems)  
--    if num>4 then
--        for i=1,4 do
--            local t = math.random(1,num)
--            self._data.randTotem[i]=self._restTotems[t]
--            self._restTotems[t],self._restTotems[num] = self._restTotems[num],self._restTotems[t]
--            num = num-1
--    end
--    else
--        for i = 1,4 do
--            if i>num then
--                self._data.randTotem[i] = "0"
--            else
--                self._data.randTotem[i] = self._restTotems[i]
--            end
--        end
--    end
--    self:_refreshChangeEvent(self.dataType.refresh)
--end

---
-- 设置图腾id 
-- @function [parent=#TotemModel] _setTotemID
-- @param #TotemModel self
function TotemModel:_setTotemID(totemids)
    if totemids then
        for i = 1,4 do
            self._data.randTotem[i] = totemids[i] or "0"
        end
        self:_refreshChangeEvent(self.dataType.refresh)
    end
end

---
-- 设置图腾id 高级
-- @function [parent=#TotemModel] setTotemID_senior
-- @param #TotemModel self
function TotemModel:setTotemID_senior(totemids)
    if totemids then
        for i = 1,4 do
            self._data.randS[i] = totemids[i] or "0"
        end
        self:_refreshChangeEvent(self.dataType.refresh)
    end
end

---
-- 获得未获得的图腾
-- @function [parent=#TotemModel] _getRestTotem
-- @param #TotemModel self
-- @param #Boolean ifRest
function TotemModel:_getRestTotem()
    if table.maxn(self._restTotems)<1 then
        for k,v in pairs(self._totemOrderData) do
            table.insert(self._restTotems, v)
        end
    end
    -- 从未获得列表取出
    for i = 1,table.maxn(self._restTotems) do
        for k,v in pairs(self._ownTotems) do
            if self._restTotems[i] == v then
                table.remove(self._restTotems,i)
            end
        end
    end
end

---
-- 获取图腾在该等级下的技能加成数据
-- @function [parent=#TotemModel] getTotemSkillData
-- @param #TotemModel self
-- @param #number bigType
-- @param #number smallType
-- @return #number 图腾技能加成数据
function TotemModel:getTotemSkillData(bigType, smallType)
    -- 从表中取数据
    if self._skillData[bigType] == nil then self._skillData[bigType] = {} end
    if self._skillData[bigType][smallType] == nil then
        self._skillData[bigType][smallType] = 0
        local totemData = GameConfig.TotemConfig:getTable()
        for k,v in pairs(totemData) do
            if v.bigType == bigType and v.smallType == smallType then
                self._skillData[bigType][smallType] = self._skillData[bigType][smallType] + self:getSkillData(v.id,true)
            end
        end
    end
    return self._skillData[bigType][smallType]
end

---
-- 图腾加成
-- @function [parent=#TotemModel] getSkillData
-- @param #TotemModel self
-- @param #string id
-- @param #boolean ifTotem 外部计算用
-- @param #number level
-- @return #number
function TotemModel:getSkillData(id,ifTotem,level)
    local num = nil
    level = level or self:getLevel(id)
    local cs = GameConfig.TotemConfig:getData(id)
--    if id == "4" or id == "14" then 
--        if self:getLevel(id) == 0 then
--            -- 特殊处理
--            if ifTotem then
--                num = 0
--            else
--                num = cs.step
--            end
--        else
--            num = cs.step*self:getLevel(id)
--        end
--    else
        if level == 0 then
            -- 万分之一
            if ifTotem then
                num = 0
            else
                if cs.valueType == 1 then
                    num = self:levelUpValue1(1,cs.step/10000)
                elseif cs.valueType == 2 then
                    num = self:levelUpValue2(1)/100
                elseif cs.valueType == 3 then
                    num = self:levelUpValue3(1)
                else
                    num = self:levelUpValue1(1,cs.step/10000)
                end
            end
        else
            if cs.valueType == 1 then
                num = self:levelUpValue1(level,cs.step/10000)
            elseif cs.valueType == 2 then
                num = self:levelUpValue2(level)/100
            elseif cs.valueType == 3 then
                num = self:levelUpValue3(level)
            else
                num = self:levelUpValue1(level,cs.step/10000)
            end
        end
--    end
    return num
end

---
-- 是否达到图腾开启条件
-- @function [parent=#TotemModel] getTotemOpen
-- @param #TotemModel self
-- @return #boolean
function TotemModel:getTotemOpen()
    if ch.StatisticsModel:getMaxLevel() > GameConst.SSTONE_LEVEL and ch.StatisticsModel:getGotSoul()>0 then
        return true
    else
        return false
    end
end

---
-- 图腾返还钻石数计算
-- @function [parent=#TotemModel] addReturnDiamondNum
-- @param #TotemModel self
-- @param #number num
function TotemModel:addReturnDiamondNum(num)
    num = num or 0
    self._data.diamond = self._data.diamond + num
end

---
-- 图腾返还魂数计算
-- @function [parent=#TotemModel] addReturnSoulNum
-- @param #TotemModel self
-- @param #number num
function TotemModel:addReturnSoulNum(num)
    num = num or 0
    self._data.soul = self._data.soul + num
end

-- 有关开服活动用到的方法
---
-- 满级图腾个数
-- @function [parent=#TotemModel] getTotemFullNum
-- @param #TotemModel self
-- @return #number num
function TotemModel:getTotemFullNum()
    local num = 0
    for  k,v in pairs(self._ownTotems) do
        local maxlv = GameConfig.TotemConfig:getData(v).maxlv
        if maxlv > 0 and self:getLevel(v) == maxlv then
            num = num + 1
        end
    end
    return num
end

---
-- 是否有相关图腾组合
-- @function [parent=#TotemModel] isTotemGroupOwn
-- @param #TotemModel self
-- @param #table group
-- @return #boolean
function TotemModel:isTotemGroupOwn(group)
    for k,v in pairs(group) do
        if self:getLevel(v) < 1 then
            return false
        end
    end
    return true
end

---
-- 图腾是否有折扣
-- @function [parent=#TotemModel] isTotemDiamondRatio
-- @param #TotemModel self
-- @param #string id
-- @return #boolean
function TotemModel:isTotemDiamondRatio(id)
    id = tostring(id)
    if ch.ChristmasModel:isOpenByType(1026) then
        local tmpTable = ch.ChristmasModel:getCSVDataByType(1026)
        for k,v in pairs(tmpTable) do
            if v.totem == id then
                return true
            end
        end
    end
    return false
end


---
-- 图腾钻石折扣
-- @function [parent=#TotemModel] getTotemDiamondRatio
-- @param #TotemModel self
-- @param #string id
-- @return #number
function TotemModel:getTotemDiamondRatio(id)
    id = tostring(id)
    if ch.ChristmasModel:isOpenByType(1026) then
        local tmpTable = ch.ChristmasModel:getCSVDataByType(1026)
        for k,v in pairs(tmpTable) do
            if v.totem == id then
                return v.ratio
            end
        end
    end
    return 1
end


-- 以下方法用于组合数据填充关于图腾的相关界面

---
-- 填充图腾描述数据
-- @function [parent=#TotemModel] getDesData
-- @param #TotemModel self
-- @param #string id
-- @param #number level
-- @return #string
function TotemModel:getDesData(id,level)
    level = level or self:getLevel(id)
    local skillData = self:getSkillData(id,false,level)
    -- 增加个数类
    if id == "14" then
        return "+"..ch.NumberHelper:toString(skillData)
    elseif id == "1" or id == "6" or id == "8" or id == "9" or id == "11" or 
        id == "28" or id == "29" or id=="101" or id=="108" or id=="109" then   -- 增加百分数类
        return "+"..skillData*100 .."%"
    elseif id == "2" or id == "5" or id == "7" or id == "10" or id == "27" then -- 可能显示过大
        return "+"..ch.NumberHelper:toString(skillData*100) .."%"
    elseif id == "13" then   -- 减少个数类
        return "-"..ch.NumberHelper:toString(skillData)
    elseif id == "3" or id == "12" or id == "16" or id == "18" or id == "20" or 
        id == "22" or id == "24" or id == "26" or id=="103" then   -- 减少百分数类
        return "-"..skillData*100 .."%"
    elseif id == "15" or id == "17" or id == "19" or id == "21" or id == "23" or id == "25" then   -- 增加秒数类
        return "+"..ch.NumberHelper:toString(skillData)..Language.src_clickhero_model_TotemModel_2
    elseif id == "4" then
        local data = level== 0 and 1 or level
        return "+"..data*10 .."%"
    elseif id == "31" or id=="33" or id=="35" or id=="37" or id=="39" then
        return "+" .. skillData*100 .."%"
    elseif id == "30" or id=="32" or id=="34" or id=="36" or id=="38" then
        return "+" .. skillData*100 .."%"
    elseif id == "40" or id=="41" or id=="42" or id=="43" then
        return "+" .. skillData*100 .."%"
    else  -- 特殊类
        return ch.NumberHelper:toString(skillData)
    end
end

-- 以下方法用于图腾的升级和数值公式
-- 魂价格
---
-- 升级公式1(等级的1.5次幂)(四舍五入)
-- @function [parent=#TotemModel] levelUpCost1
-- @param #TotemModel self
-- @param #number level
-- @param #number type 消耗货币类型：0钻石，1魂
-- @return #number
function TotemModel:levelUpCost1(level,type)
    if type == 0 then
        return math.floor((math.pow(level,0.01)-1)*718.85+0.5)
    else
        return math.floor(math.pow(level,1.5)+0.5)
    end
end

---
-- 升级公式2(等于等级)
-- @function [parent=#TotemModel] levelUpCost2
-- @param #TotemModel self
-- @param #number level
-- @param #number type 消耗货币类型：0钻石，1魂
-- @return #number
function TotemModel:levelUpCost2(level,type)
    if type == 0 then
        return math.floor((math.pow(level*2,0.01)-1)*214.9+0.5)
    else
        return level
    end
end

---
-- 升级公式3(等级的1/3的ceil)
-- @function [parent=#TotemModel] levelUpCost3
-- @param #TotemModel self
-- @param #number level
-- @param #number type 消耗货币类型：0钻石，1魂
-- @return #number
function TotemModel:levelUpCost3(level,type)
    if type == 0 then
        return math.floor((math.pow(level*2,0.01)-1)*214.9 /3+0.5)
    else 
        return math.ceil(level / 3)
    end
end

---
-- 升级公式4(等级的10倍)
-- @function [parent=#TotemModel] levelUpCost4
-- @param #TotemModel self
-- @param #number level
-- @param #number type 消耗货币类型：0钻石，1魂
-- @return #number
function TotemModel:levelUpCost4(level,type)
    if type == 0 then
        return math.floor((math.pow(level*2,0.01)-1)*214.9 * 10+0.5)
    else
        return level * 10
    end
end

---
-- 数值公式1(等级*步长)
-- @function [parent=#TotemModel] levelUpValue1
-- @param #TotemModel self
-- @param #number level
-- @param #number step
-- @return #number
function TotemModel:levelUpValue1(level,step)
    return level * step
end

---
-- 数值公式2(根据等级衰减)(百分比)
-- @function [parent=#TotemModel] levelUpValue2
-- @param #TotemModel self
-- @param #number level
-- @return #number
function TotemModel:levelUpValue2(level)
    if level < 20 then
        return level * 5
    elseif level < 40 then
        return 100+(level-20)*4
    elseif level < 60 then
        return 180+(level-40)*3
    elseif level < 80 then
        return 240+(level-60)*2
    else
        return 280+(level-80)
    end
end

---
-- 数值公式3(数组)
-- @function [parent=#TotemModel] levelUpValue3
-- @param #TotemModel self
-- @param #number level
-- @return #number
function TotemModel:levelUpValue3(level)
    if level > table.maxn(GameConst.TOTEM_VALUE_ARRAY) then
        return GameConst.TOTEM_VALUE_ARRAY[table.maxn(GameConst.TOTEM_VALUE_ARRAY)]
    else
        return GameConst.TOTEM_VALUE_ARRAY[level+1]
    end
end

return TotemModel