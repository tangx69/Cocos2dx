---
-- MoneyModel     结构 {gold=100,}
--@module MoneyModel
local MoneyModel = {
    _data = nil,
    _dataMixed = {},
    dataChangeEventType = "MoneyModelDataChange", --{type = ,dataType =}
    _eventId = nil,
    dataType = {
        diamond = "90001",
        gold = "90002",
        soul = "90003",
        sStone = "90004",
        star = "90005",
        honour = "90006",
        runic = "90011",
        cSock = "90012",  -- 兑换币，如圣诞袜，元宵，香炉，红花
        firecracker = "90013", -- 爆竹
        defeat = "90015", -- 天梯征服点
        spirit = "90018",  -- 英灵，提升卡牌资质
        quintessence = "90019",  -- 精华，用于增加附魔经验
        gods = "90032", --神灵,用于升级神坛
    }
}

local KEY = 123456

function MoneyModel:encrypt(data)
    local dataEncrypt = {}
    
    dataEncrypt.num = data.num + KEY
    dataEncrypt.exp = data.exp + KEY
    
    return dataEncrypt
end

ENCODE_NUM = ENCODE_NUM or function(num)
    return num
end

DECODE_NUM = DECODE_NUM or function(num)
    return num
end

---
-- @function [parent=#MoneyModel] init
-- @param self #MoneyModel
-- @param #table data
function MoneyModel:init(data)
    data.money[self.dataType.gold] = ch.LongDouble:toLongDouble(tostring(data.money[self.dataType.gold]))
    self._data = data.money
    
    self._dataMixed[self.dataType.gold] = self:encrypt(self._data[self.dataType.gold])
    
    if ch.StatisticsModel:getMaxLevel() <= GameConst.SSTONE_LEVEL then
        self._eventId = zzy.EventManager:listen(ch.StatisticsModel.maxLevelChangeEventType,function()
            if ch.StatisticsModel:getMaxLevel() == GameConst.SSTONE_LEVEL + 1 then
                self:addSoul(1)
                zzy.EventManager:unListen(self._eventId)
                self._eventId = nil
            end
        end,1)
    end
    
    
    self._data[self.dataType.sStone] = ENCODE_NUM(self._data[self.dataType.sStone])
    self._data[self.dataType.gods] = ENCODE_NUM(self._data[self.dataType.gods] or 0)
end

---
-- @function [parent=#MoneyModel] clean
-- @param #MoneyModel self
function MoneyModel:clean()
    self._data = nil
    self._dataMixed = {}
    if self._eventId then
        zzy.EventManager:unListen(self._eventId)
        self._eventId = nil
    end
end

function MoneyModel:_raiseDataChangeEvent(dataType,num)
    local evt = {
        type = self.dataChangeEventType,
        dataType = dataType,
        value = num or 0
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 获取黄金
-- @function [parent=#MoneyModel] getGold
-- @param #MoneyModel self
-- @return #number
function MoneyModel:getGold()
    self._data[self.dataType.gold].num = DECODE_NUM(self._data[self.dataType.gold].num)
    self._data[self.dataType.gold].exp = DECODE_NUM(self._data[self.dataType.gold].exp)

    return self._data[self.dataType.gold]
end

---
-- 设置黄金数量
-- @function [parent=#MoneyModel] setGold
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:setGold(money)
    local old = self:getGold()
    if money ~= old then
        money.num = ENCODE_NUM(money.num)
        money.exp = ENCODE_NUM(money.exp)
        self._data[self.dataType.gold] = money
        self:_raiseDataChangeEvent(self.dataType.gold)
    end
end

--local MAX_GOLD = ch.LongDouble:new(1.0e300)
---
-- 添加黄金
-- @function [parent=#MoneyModel] addGold
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:addGold(money)
    if type(money) == "number" then
        money = ch.LongDouble:new(money)
    end
    if money ~= 0 then
        local gold = self:getGold()
        gold = gold + money
        gold.num = ENCODE_NUM(gold.num)
        gold.exp = ENCODE_NUM(gold.exp)
        
        self._data[self.dataType.gold] = gold
        
        if ch.guide._data["guide9092"] ~= 1 and self:getGold() >= ch.LongDouble:new(1e16) then
            ch.guide._data["guide9092"] = 1
            ch.NetworkController:reGuideMsg("9092", "10")
        end
        if money > ch.LongDouble.zero then
            ch.StatisticsModel:addGotGold(money)
        end
        self:_raiseDataChangeEvent(self.dataType.gold,money)
    end
end

---
-- 获取魂
-- @function [parent=#MoneyModel] getSoul
-- @param #MoneyModel self
-- @return #number
function MoneyModel:getSoul()
    return DECODE_NUM(self._data[self.dataType.soul])
end

---
-- 设置魂数量
-- @function [parent=#MoneyModel] setSoul
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:setSoul(money)
    local old = self:getSoul()
    if money ~= old then
        self._data[self.dataType.soul] = money
        self._data[self.dataType.soul] = ENCODE_NUM(self._data[self.dataType.soul])
        ch.MagicModel:resetDPS()
        self:_raiseDataChangeEvent(self.dataType.soul)
    end
end

---
-- 添加魂
-- @function [parent=#MoneyModel] addSoul
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:addSoul(money)
    if money ~= 0 then
        self._data[self.dataType.soul] = ENCODE_NUM(self:getSoul() + money)
        ch.MagicModel:resetDPS()
        if money > 0 then
            ch.StatisticsModel:addGotSoul(money)
        end
        
        self:_raiseDataChangeEvent(self.dataType.soul,money)
    end
end

---
-- 获取神灵
-- @function [parent=#MoneyModel] getGods
-- @param #MoneyModel self
-- @return #number
function MoneyModel:getGods()
    return DECODE_NUM(self._data[self.dataType.gods])
end

---
-- 设置神灵数量
-- @function [parent=#MoneyModel] setGods
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:setGods(money)
    local old = self:getGods()
    if money ~= old then
        self._data[self.dataType.gods] = money
        self._data[self.dataType.gods] = ENCODE_NUM(self._data[self.dataType.gods])
        self:_raiseDataChangeEvent(self.dataType.gods)
    end
end

---
-- 添加神灵
-- @function [parent=#MoneyModel] addGods
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:addGods(money)
    if money ~= 0 then
        self._data[self.dataType.gods] = ENCODE_NUM(self:getGods() + money)
        
        self:_raiseDataChangeEvent(self.dataType.gods, money)
    end
end

---
-- 获取钻石
-- @function [parent=#MoneyModel] getDiamond
-- @param #MoneyModel self
-- @return #number
function MoneyModel:getDiamond()
    return DECODE_NUM(self._data[self.dataType.diamond])
end

---
-- 设置钻石数量
-- @function [parent=#MoneyModel] setDiamond
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:setDiamond(money)
    local old = self:getDiamond()
    if money ~= old then
        self._data[self.dataType.diamond] = ENCODE_NUM(money)
        self:_raiseDataChangeEvent(self.dataType.diamond)
    end
end

---
-- 添加钻石
-- @function [parent=#MoneyModel] addDiamond
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:addDiamond(money)
    if money ~= 0 then
        self._data[self.dataType.diamond] = ENCODE_NUM(self:getDiamond() + money)
        self:_raiseDataChangeEvent(self.dataType.diamond,money)
    end
end

---
-- 获取魂石
-- @function [parent=#MoneyModel] getsStone
-- @param #MoneyModel self
-- @return #number
function MoneyModel:getsStone()
    return DECODE_NUM(self._data[self.dataType.sStone])
end

---
-- 设置魂石数量
-- @function [parent=#MoneyModel] setsStone
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:setsStone(money)
    local old = self:getsStone()
    if money ~= old then
        self._data[self.dataType.sStone] = ENCODE_NUM(money)
        self:_raiseDataChangeEvent(self.dataType.sStone)
    end
end

---
-- 添加魂石
-- @function [parent=#MoneyModel] addsStone
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:addsStone(money)
    if money ~= 0 then
        self._data[self.dataType.sStone] = ENCODE_NUM(self:getsStone() + money)
        self:_raiseDataChangeEvent(self.dataType.sStone,money)
    end
end


---
-- 获取镀金次数
-- @function [parent=#MoneyModel] getStar
-- @param #MoneyModel self
-- @return #number
function MoneyModel:getStar()
    return self._data[self.dataType.star]
end

---
-- 设置镀金次数
-- @function [parent=#MoneyModel] setStar
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:setStar(money)
    local old = self:getStar()
    if money ~= old then
        self._data[self.dataType.star] = money
        self:_raiseDataChangeEvent(self.dataType.star)
    end
end

---
-- 添加镀金次数
-- @function [parent=#MoneyModel] addStar
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:addStar(money)
    if money ~= 0 then
        self._data[self.dataType.star] = self._data[self.dataType.star] + money
        self:_raiseDataChangeEvent(self.dataType.star,money)
    end
end


---
-- 获取荣誉值
-- @function [parent=#MoneyModel] getHonour
-- @param #MoneyModel self
-- @return #number
function MoneyModel:getHonour()
    return self._data[self.dataType.honour]
end

---
-- 设置荣誉值
-- @function [parent=#MoneyModel] setHonour
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:setHonour(money)
    local old = self:getHonour()
    if money ~= old then
        self._data[self.dataType.honour] = money
        self:_raiseDataChangeEvent(self.dataType.honour)
    end
end

---
-- 添加荣誉值
-- @function [parent=#MoneyModel] addHonour
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:addHonour(money)
    if money ~= 0 then
        local str = self.dataType.honour
        self._data[str] = self._data[str] + money
        self:_raiseDataChangeEvent(self.dataType.honour,money)
    end
end

---
-- 获取万能符文数
-- @function [parent=#MoneyModel] getRunic
-- @param #MoneyModel self
-- @return #number
function MoneyModel:getRunic()
    return self._data[self.dataType.runic]
end

---
-- 设置万能符文数
-- @function [parent=#MoneyModel] setRunic
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:setRunic(money)
    local old = self:getRunic()
    if money ~= old then
        self._data[self.dataType.runic] = money
        self:_raiseDataChangeEvent(self.dataType.runic)
    end
end

---
-- 添加万能符文数
-- @function [parent=#MoneyModel] addRunic
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:addRunic(money)
    if money ~= 0 then
        self._data[self.dataType.runic] = self._data[self.dataType.runic] + money
        self:_raiseDataChangeEvent(self.dataType.runic,money)
    end
end

---
-- 获取圣诞袜
-- @function [parent=#MoneyModel] getCSock
-- @param #MoneyModel self
-- @return #number
function MoneyModel:getCSock()
    return ch.ChristmasModel:getJRDHCount()
end

---
-- 设置圣诞袜
-- @function [parent=#MoneyModel] setCSock
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:setCSock(money)
    local old = self:getCSock()
    if money ~= old then
        ch.ChristmasModel:setJRDHCount(money)
        self:_raiseDataChangeEvent(self.dataType.cSock,money)
    end
end

---
-- 添加圣诞袜
-- @function [parent=#MoneyModel] addCSock
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:addCSock(money)
    if money ~= 0 then
        ch.ChristmasModel:addJRDHCount(money)
        self:_raiseDataChangeEvent(self.dataType.cSock,money)
    end
end


---
-- 获取爆竹
-- @function [parent=#MoneyModel] getFirecracker
-- @param #MoneyModel self
-- @return #number
function MoneyModel:getFirecracker()
    return self._data[self.dataType.firecracker]
end

---
-- 设置爆竹
-- @function [parent=#MoneyModel] setFirecracker
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:setFirecracker(money)
    local old = self:getFirecracker()
    if money ~= old then
        self._data[self.dataType.firecracker] = money
        self:_raiseDataChangeEvent(self.dataType.firecracker)
    end
end

---
-- 添加爆竹
-- @function [parent=#MoneyModel] addFirecracker
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:addFirecracker(money)
    if money ~= 0 then
        self._data[self.dataType.firecracker] = self._data[self.dataType.firecracker] + money
        self:_raiseDataChangeEvent(self.dataType.firecracker,money)
    end
end

---
-- 获得天梯征服点
-- @function [parent=#MoneyModel] getDefeat
-- @param #MoneyModel self
-- @return #number
function MoneyModel:getDefeat()
    return self._data[self.dataType.defeat]
end

---
-- 设置天梯征服点
-- @function [parent=#MoneyModel] setDefeat
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:setDefeat(money)
    local old = self:getDefeat()
    if money ~= old then
        self._data[self.dataType.defeat] = money
        self:_raiseDataChangeEvent(self.dataType.defeat)
    end
end

---
-- 添加天梯征服点
-- @function [parent=#MoneyModel] addDefeat
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:addDefeat(money)
    if money ~= 0 then
        self._data[self.dataType.defeat] = self._data[self.dataType.defeat] + money
        self:_raiseDataChangeEvent(self.dataType.defeat,money)
    end
end

---
-- 获取英灵数量
-- @function [parent=#MoneyModel] getSpirit
-- @param #MoneyModel self
-- @return #number
function MoneyModel:getSpirit()
    return self._data[self.dataType.spirit]
end

---
-- 设置英灵数量
-- @function [parent=#MoneyModel] setSpirit
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:setSpirit(money)
    local old = self:getSpirit()
    if money ~= old then
        self._data[self.dataType.spirit] = money
        self:_raiseDataChangeEvent(self.dataType.spirit)
    end
end

---
-- 添加英灵数量
-- @function [parent=#MoneyModel] addSpirit
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:addSpirit(money)
    if money ~= 0 then
        self._data[self.dataType.spirit] = self._data[self.dataType.spirit] + money
        self:_raiseDataChangeEvent(self.dataType.spirit,money)
    end
end

---
-- 获取精华数量
-- @function [parent=#MoneyModel] getQuintessence
-- @param #MoneyModel self
-- @return #number
function MoneyModel:getQuintessence()
    return self._data[self.dataType.quintessence] or 0
end

---
-- 设置精华数量
-- @function [parent=#MoneyModel] setQuintessence
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:setQuintessence(money)
    local old = self:getQuintessence()
    if money ~= old then
        self._data[self.dataType.quintessence] = money
        self:_raiseDataChangeEvent(self.dataType.quintessence)
    end
end

---
-- 添加精华数量
-- @function [parent=#MoneyModel] addQuintessence
-- @param #MoneyModel self
-- @param #number money
function MoneyModel:addQuintessence(money)
    if not self._data[self.dataType.quintessence] then
        self._data[self.dataType.quintessence] = 0
    end
    if money ~= 0 then
        self._data[self.dataType.quintessence] = self._data[self.dataType.quintessence] + money
        self:_raiseDataChangeEvent(self.dataType.quintessence,money)
    end
end


---
-- 根据类型获取代币
-- @function [parent=#MoneyModel] getMoney
-- @param #MoneyModel self
-- @param #number type
-- @return #number
function MoneyModel:getMoney(type)
    type = tostring(type)
    if type == self.dataType.gold then
        return self:getGold()
    elseif type == self.dataType.diamond then
        return self:getDiamond()
    elseif type == self.dataType.soul then
        return self:getSoul()
    elseif type == self.dataType.sStone then
        return self:getsStone()
    elseif type == self.dataType.star then
        return self:getStar()
    elseif type == self.dataType.honour then
        return self:getHonour()
    elseif type == self.dataType.runic then
        return self:getRunic()
    elseif type == self.dataType.cSock then
        return self:getCSock()
    elseif type == self.dataType.firecracker then
        return self:getFirecracker()
    elseif type == self.dataType.defeat then
        return self:getDefeat()
    elseif type == self.dataType.spirit then
        return self:getSpirit()
    elseif type == self.dataType.quintessence then
        return self:getQuintessence()
    else
        error("不存在该代币类型：%d",type or 0)
    end
end

---
-- 设置代币数量根据类型
-- @function [parent=#MoneyModel] setMoney
-- @param #MoneyModel self
-- @param #number type
-- @param #number money
function MoneyModel:setMoney(type, money)
    type = tostring(type)
    if type == self.dataType.gold then
        self:setGold(money)
    elseif type == self.dataType.diamond then
        self:setDiamond(money)
    elseif type == self.dataType.soul then
        self:setSoul(money)
    elseif type == self.dataType.sStone then
        self:setsStone(money)
    elseif type == self.dataType.star then
        self:setStar(money)
    elseif type == self.dataType.honour then
        self:setHonour(money)
    elseif type == self.dataType.runic then
        self:setRunic(money)
    elseif type == self.dataType.cSock then
        self:setCSock(money)
    elseif type == self.dataType.firecracker then
        self:setFirecracker(money)
    elseif type == self.dataType.defeat then
        self:setDefeat(money)
    elseif type == self.dataType.spirit then
        self:setSpirit(money)
    elseif type == self.dataType.quintessence then
        self:setQuintessence(money)
    else
        error("不存在该代币类型：%d",type or 0)  
    end
end

---
-- 添加代币数量根据类型
-- @function [parent=#MoneyModel] addMoney
-- @param #MoneyModel self
-- @param #number type
-- @param #number money
function MoneyModel:addMoney(type, money)
    type = tostring(type)
    if type == self.dataType.gold then
        self:addGold(money)
    elseif type == self.dataType.diamond then
        self:addDiamond(money)
    elseif type == self.dataType.soul then
        self:addSoul(money)
    elseif type == self.dataType.sStone then
        self:addsStone(money)
    elseif type == self.dataType.star then
        self:addStar(money)
    elseif type == self.dataType.honour then
        self:addHonour(money)
    elseif type == self.dataType.runic then
        self:addRunic(money)
    elseif type == self.dataType.cSock then
        self:addCSock(money)
    elseif type == self.dataType.firecracker then
        self:addFirecracker(money)
    elseif type == self.dataType.defeat then
        self:addDefeat(money)
    elseif type == self.dataType.spirit then
        self:addSpirit(money)
    elseif type == self.dataType.quintessence then
        self:addQuintessence(money)
    else
        error("不存在该代币类型：%d",type or 0)
    end
end

---
-- 关于轮回
-- @function [parent=#MoneyModel] onSamsara
-- @param #MoneyModel self
function MoneyModel:onSamsara()
    if ch.TotemModel:getTotemSkillData(2,1) > GameConst.RUNIC_SAMSARA_GOLD then
        self:setGold(ch.LongDouble:new(ch.TotemModel:getTotemSkillData(2,1)))
    else
        self:setGold(ch.LongDouble:new(GameConst.RUNIC_SAMSARA_GOLD))
    end
--    local money = self:getsStone()*(1+ch.TotemModel:getTotemSkillData(2,2) or 0)
    local money = self:getsStone()
    money = money + math.floor((ch.RunicModel:getLevel()+ch.MagicModel:getTotalLevel())/GameConst.SOUL_LEVEL)
    self:addSoul(money)
    self:setsStone(0)
end

---
-- 关于高级轮回
-- @function [parent=#MoneyModel] onSamsara
-- @param #MoneyModel self
function MoneyModel:onSuperSamsara()
    local money = self:getsStone()
    money = money + math.floor((ch.RunicModel:getLevel()+ch.MagicModel:getTotalLevel())/GameConst.SOUL_LEVEL)
    self:addSoul(money)
    self:setsStone(0)
end

return MoneyModel