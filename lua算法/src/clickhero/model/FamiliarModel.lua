---
--
-- @module FamiliarModel
local FamiliarModel = {
    _data = nil,
    dataChangeEventType = "FAMILIAR_MODEL_DATA_CHANGE", --{type=,id = }
    _eventId = nil,
    _altarAdd = nil,
    dataType = {
        get = 1,
        fight = 2,
        clean = 3 
    }
}

function FamiliarModel:_raiseDataChangeEvent(fid,dataType)
    local evt = {
        type = self.dataChangeEventType,
        id = fid,
        dataType=dataType
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 初始化
-- @function [parent=#FamiliarModel] init
-- @param #FamiliarModel self
-- @param #table data
function FamiliarModel:init(data)
    self._data = data.familiar or {}
    if not self:hasFamiliar(GameConst.FAMILIAR_FREE_ID) then
        self._eventId = zzy.EventManager:listen(ch.StatisticsModel.maxLevelChangeEventType,function()
            if ch.StatisticsModel:getMaxLevel() > GameConst.FAMILIAR_OPEN_LEVEL then
                self:addFamiliar(GameConst.FAMILIAR_FREE_ID)
                zzy.EventManager:unListen(self._eventId)
                self._eventId = nil
            end
        end,1)
    end
    self:initAltarAdd()
end

---
-- @function [parent=#FamiliarModel] clean
-- @param #FamiliarModel self
function FamiliarModel:clean()
    self._data = nil
    self._altarAdd = nil
    if self._eventId then
        zzy.EventManager:unListen(self._eventId)
        self._eventId = nil
    end
end

---
-- 获取当前侍宠
-- @function [parent=#FamiliarModel] getCurFamiliar
-- @param #FamiliarModel self
-- @return #number
function FamiliarModel:getCurFamiliar()
    return self._data.cur
end

---
-- 获取侍宠对祭坛产量的加成
-- @function [parent=#FamiliarModel] getAltarAdd
-- @param #FamiliarModel self
-- @param #number aType 祭坛类型
-- @return #number
function FamiliarModel:getAltarAdd(aType)
    return self._altarAdd[aType]
end

---
-- 初始化祭坛加成效果
-- @function [parent=#FamiliarModel] initAltarAdd
-- @param #FamiliarModel self
function FamiliarModel:initAltarAdd()
    self._altarAdd = {}
    for k,v in pairs(ch.AltarModel.typeId) do
        self._altarAdd[v] = 0
    end
    if self._data and self._data.own then
        for k,v in pairs(self._data.own) do
            local c = GameConfig.FamiliarConfig:getData(tonumber(k))
            self:addAttachProperty(c.pType,self:getFamiliarRatio(tonumber(k)))
        end
    end
end

---
-- 添加宠物附加属性
-- @function [parent=#FamiliarModel] addAttachProperty
-- @param #FamiliarModel self
-- @param #number pType
-- @param #number num
function FamiliarModel:addAttachProperty(pType,num)
    num = num or 0
    if pType == 1 then
        for k,v in pairs(self._altarAdd) do 
            self._altarAdd[k] = v + num
        end
    end
end

---
-- 添加宠物附加属性
-- @function [parent=#FamiliarModel] getFamiliarRatio
-- @param #FamiliarModel self
-- @param #number id
function FamiliarModel:getFamiliarRatio(id)
    local c = GameConfig.FamiliarConfig:getData(id)
    if self:getFamiliarLevel(id) > 1 then
        return (c.pValue + c.pValue_add*(self:getFamiliarLevel(id)-1))/10000
    end
    return c.pValue/10000
end

---
-- 设置当前侍宠
-- @function [parent=#FamiliarModel] setCurFamiliar
-- @param #FamiliarModel self
-- @param #number id
function FamiliarModel:setCurFamiliar(id)
    if self._data.cur ~= id then
        self._data.cur = id
        self:_raiseDataChangeEvent(id,self.dataType.fight)
        ch.fightRoleLayer:addFamiliarRole(id)
    end
end

---
-- 获取当前所以侍宠
-- @function [parent=#FamiliarModel] getAllFamiliars
-- @param #FamiliarModel self
-- @return #table id
function FamiliarModel:getAllFamiliars()
    return self._data.own
end

---
-- 获取当前未查看的侍宠列表
-- @function [parent=#FamiliarModel] getSeeFamiliars
-- @param #FamiliarModel self
-- @return #table id
function FamiliarModel:getSeeFamiliars()
    return self._data.see
end

---
-- 添加新的未查看侍宠
-- @function [parent=#FamiliarModel] addSeeFamiliar
-- @param #FamiliarModel self
-- @param #number id
function FamiliarModel:addSeeFamiliar(id)
    self._data.see = self._data.see or {}
    for k,v in pairs(self._data.see) do
        if v == id then
            return
        end
    end
    table.insert(self._data.see,id)
end

---
-- 清除未查看侍宠列表
-- @function [parent=#FamiliarModel] cleanSeeFamiliar
-- @param #FamiliarModel self
function FamiliarModel:cleanSeeFamiliar()
    self._data.see = {}
    self:_raiseDataChangeEvent(0,self.dataType.clean)
end

---
-- 添加新的侍宠
-- @function [parent=#FamiliarModel] addFamiliar
-- @param #FamiliarModel self
-- @param #number id
function FamiliarModel:addFamiliar(id)
--    self._data.own = self._data.own or {}
--    if not self:hasFamiliar(id) then
--        table.insert(self._data.own,id)
--        self:addSeeFamiliar(id)
--        local c = GameConfig.FamiliarConfig:getData(id)
--        self:addAttachProperty(c.pType,c.pValue/10000)
--        self:_raiseDataChangeEvent(id,self.dataType.get)
--    end
    self._data.own = self._data.own or {}
    local c = GameConfig.FamiliarConfig:getData(id)
    if not self._data.own[tostring(id)] then
        self._data.own[tostring(id)] = {l=1}
        self:addAttachProperty(c.pType,c.pValue/10000)
    else
        self._data.own[tostring(id)].l = self._data.own[tostring(id)].l + 1
        self:addAttachProperty(c.pType,c.pValue_add/10000)
    end
    self:addSeeFamiliar(id)
    self:_raiseDataChangeEvent(id,self.dataType.get)
end

---
-- 侍宠升级
-- @function [parent=#FamiliarModel] familiarLevelUp
-- @param #FamiliarModel self
-- @param #number id
-- @param #number num
function FamiliarModel:familiarLevelUp(id,num)
    self._data.own = self._data.own or {}
    local c = GameConfig.FamiliarConfig:getData(id)
    if not self._data.own[tostring(id)] then
        self._data.own[tostring(id)] = {l=num}
        self:addAttachProperty(c.pType,c.pValue/10000)
    else
        self._data.own[tostring(id)].l = self._data.own[tostring(id)].l + num
        self:addAttachProperty(c.pType,c.pValue_add/10000)
    end
    self:_raiseDataChangeEvent(id,self.dataType.get)
end

---
-- 是否拥有侍宠
-- @function [parent=#FamiliarModel] hasFamiliar
-- @param #FamiliarModel self
-- @param #number id
-- @return #bool
function FamiliarModel:hasFamiliar(id)
	if self._data.own[tostring(id)] then
        return true
	end
	return false
end

---
-- 获取当前侍宠卡片状态
-- @function [parent=#FamiliarModel] getCurFamiliarCardData
-- @param #FamiliarModel self
-- @return #number
function FamiliarModel:getCurFamiliarCardData()
    if self._data.cur then
        return GameConfig.FamiliarConfig:getData(self._data.cur)
    else
        return GameConst.FAMILIAR_OPEN_DATA
    end
end

---
-- 获取界面侍宠index
-- @function [parent=#FamiliarModel] getCurFamiliarIndex
-- @param #FamiliarModel self
-- @param #string id
-- @return #number
function FamiliarModel:getCurFamiliarIndex(id)
    for k,v in ipairs(GameConst.FAMILIAR_ORDER) do
        if v == id then
            return k-1
        end
    end
    return 0
end

---
-- 获取侍宠的价格
-- @function [parent=#FamiliarModel] getFamiliarPrice
-- @param #FamiliarModel self
-- @param #string id
-- @return #number,number,number
function FamiliarModel:getFamiliarPrice(id)
    if self:hasFamiliar(id) then
        return 1,0,1
    else
        local cs = GameConfig.ShopConfig:getTable()
        for k,v in pairs(cs) do
            if v.reward == tonumber(id) then
                return v.type_cost,v.price,v.id
            end
        end
        return 1,0,1
    end
end

---
-- 获取侍宠的等级
-- @function [parent=#FamiliarModel] getFamiliarLevel
-- @param #FamiliarModel self
-- @param #string id
-- @return #number
function FamiliarModel:getFamiliarLevel(id)
    if self._data.own[tostring(id)] then
        return self._data.own[tostring(id)].l
    end
    return 0

end

---
-- 侍宠获得说明
-- @function [parent=#FamiliarModel] getRewardDesc
-- @param #FamiliarModel self
-- @param #string id
-- @return #string,string
function FamiliarModel:getRewardDesc(id)
    local curDesc = GameConfig.FamiliarConfig:getData(id).desc_get
    local nextDesc = ""
    return curDesc,nextDesc
end


return FamiliarModel