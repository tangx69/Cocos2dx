---
-- 随机商店model层         结构{{num = 0},...}
--@module RandomShopModel
local RandomShopModel = {
    _data = nil,
    _guildData = nil,
    _arenaData = nil,
    _blackData = nil,
    dataGuildChangeEventType = "GuildShopDataChange", 
    dataArenaChangeEventType = "ArenaShopDataChange",
    dataBlackChangeEventType = "BlackShopDataChange", 
    _guildListNum = nil,
    _arenaListNum = nil,
    _blackListNum = nil,
    refreshPlay = nil,
    refreshPlayBlack = nil,
    refreshPlayGuild = nil,
    dataType = {
        num = 1,
        list = 2,
        time = 3,
        count = 4
    }
}


---
-- @function [parent=#RandomShopModel] init
-- @param #RandomShopModel self
-- @param #table data
function RandomShopModel:init(data)
    self._data = data.randomShop
    self._arenaData = self._data.arena or {}
    self._blackData = self._data.black or {}
    self._guildData = self._data.guild or {}
    self._guildListNum = 0
    self._arenaListNum = 0
    self._blackListNum = 0
end

---
-- @function [parent=#RandomShopModel] clean
-- @param #RandomShopModel self
function RandomShopModel:clean()
    self._data = nil
    self._guildData = nil
    self._arenaData = nil
    self._blackData = nil
    self._guildListNum = nil
    self._arenaListNum = nil
    self._blackListNum = nil
    self.refreshPlay = nil
    self.refreshPlayBlack = nil
    self.refreshPlayGuild = nil
end

-- 公会商店
function RandomShopModel:_raiseGuildDataChangeEvent(id,dataType)
    local evt = {
        type = self.dataGuildChangeEventType,
        id = id,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end

-- 天梯商店
function RandomShopModel:_raiseAreanDataChangeEvent(id,dataType)
    local evt = {
        type = self.dataArenaChangeEventType,
        id = id,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end

-- 黑市商店
function RandomShopModel:_raiseBlackDataChangeEvent(id,dataType)
    local evt = {
        type = self.dataBlackChangeEventType,
        id = id,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会商店相关数据
-- @function [parent=#RandomShopModel] getGuildShopData
-- @param #RandomShopModel self
-- @return #number
function RandomShopModel:getGuildShopData()
    return self._guildData
end

---
-- 公会商店下次刷新时间
-- @function [parent=#RandomShopModel] getGuildShopCDTime
-- @param #RandomShopModel self
-- @return #number
function RandomShopModel:getGuildShopCDTime()
    return self._guildData.cdTime or 0
end
---
-- 公会商店下次刷新时间
-- @function [parent=#RandomShopModel] setGuildShopCDTime
-- @param #RandomShopModel self
-- @param #number time
function RandomShopModel:setGuildShopCDTime(time)
    self._guildData.cdTime = time
    self:_raiseGuildDataChangeEvent("0",self.dataType.time)
end
---
-- 公会商店手动刷新次数
-- @function [parent=#RandomShopModel] getGuildShopCount
-- @param #RandomShopModel self
-- @return #number
function RandomShopModel:getGuildShopCount()
    return self._guildData.count or 0
end
---
-- 公会商店手动刷新次数
-- @function [parent=#RandomShopModel] setGuildShopCount
-- @param #RandomShopModel self
-- @param #number count
function RandomShopModel:setGuildShopCount(count)
    self._guildData.count = count
    self:_raiseGuildDataChangeEvent("0",self.dataType.count)
end
---
-- 公会商店手动刷新次数
-- @function [parent=#RandomShopModel] addGuildShopCount
-- @param #RandomShopModel self
-- @param #number count
function RandomShopModel:addGuildShopCount(count)
    self._guildData.count = self._guildData.count+count
    self:_raiseGuildDataChangeEvent("0",self.dataType.count)
end
---
-- 公会商店列表
-- @function [parent=#RandomShopModel] getGuildShopList
-- @param #RandomShopModel self
-- @return #number
function RandomShopModel:getGuildShopList()
    return self._guildData.list or {}
end
---
-- 公会商店列表
-- @function [parent=#RandomShopModel] setGuildShopList
-- @param #RandomShopModel self
-- @param #table list
function RandomShopModel:setGuildShopList(list)
    self._guildData.list = list
    self.refreshPlayGuild = true
    self:_raiseGuildDataChangeEvent("0",self.dataType.list)
end
---
-- 公会商店列表数量
-- @function [parent=#RandomShopModel] getGuildShopListNum
-- @param #RandomShopModel self
-- @return #number
function RandomShopModel:getGuildShopListNum()
    local num = 0 
    for k,v in pairs(self._guildData.list) do
        num = num + 1
    end
    return num
end

---
-- 公会商店手动刷新价格
-- @function [parent=#RandomShopModel] getGuildShopPrice
-- @param #RandomShopModel self
-- @return #number 
function RandomShopModel:getGuildShopPrice()
    if GameConst.RANDOM_SHOP_GUILD_PRICE[self:getGuildShopCount()+1] then
        return GameConst.RANDOM_SHOP_GUILD_PRICE[self:getGuildShopCount()+1]
    else
        return GameConst.RANDOM_SHOP_GUILD_PRICE[table.maxn(GameConst.RANDOM_SHOP_GUILD_PRICE)]
    end
end

---
-- 天梯商店相关数据
-- @function [parent=#RandomShopModel] getArenaShopData
-- @param #RandomShopModel self
-- @return #number
function RandomShopModel:getArenaShopData()
    return self._arenaData
end

---
-- 天梯商店下次刷新时间
-- @function [parent=#RandomShopModel] getArenaShopCDTime
-- @param #RandomShopModel self
-- @return #number
function RandomShopModel:getArenaShopCDTime()
    return self._arenaData.cdTime or 0
end
---
-- 天梯商店下次刷新时间
-- @function [parent=#RandomShopModel] setArenaShopCDTime
-- @param #RandomShopModel self
-- @param #number time
function RandomShopModel:setArenaShopCDTime(time)
    self._arenaData.cdTime = time
    self:_raiseAreanDataChangeEvent("0",self.dataType.time)
end
---
-- 天梯商店手动刷新次数
-- @function [parent=#RandomShopModel] getArenaShopCount
-- @param #RandomShopModel self
-- @return #number
function RandomShopModel:getArenaShopCount()
    return self._arenaData.count or 0
end
---
-- 天梯商店手动刷新次数
-- @function [parent=#RandomShopModel] setArenaShopCount
-- @param #RandomShopModel self
-- @param #number count
function RandomShopModel:setArenaShopCount(count)
    self._arenaData.count = count
    self:_raiseAreanDataChangeEvent("0",self.dataType.count)
end
---
-- 天梯商店手动刷新次数
-- @function [parent=#RandomShopModel] addArenaShopCount
-- @param #RandomShopModel self
-- @param #number count
function RandomShopModel:addArenaShopCount(count)
    self._arenaData.count = self._arenaData.count+count
    self:_raiseAreanDataChangeEvent("0",self.dataType.count)
end
---
-- 天梯商店列表
-- @function [parent=#RandomShopModel] getArenaShopList
-- @param #RandomShopModel self
-- @return #number
function RandomShopModel:getArenaShopList()
    return self._arenaData.list or {}
end
---
-- 天梯商店列表
-- @function [parent=#RandomShopModel] setArenaShopList
-- @param #RandomShopModel self
-- @param #table list
function RandomShopModel:setArenaShopList(list)
    self._arenaData.list = list
    self.refreshPlay = true
    self:_raiseAreanDataChangeEvent("0",self.dataType.list)
end
---
-- 天梯商店列表数量
-- @function [parent=#RandomShopModel] getArenaShopListNum
-- @param #RandomShopModel self
-- @return #number
function RandomShopModel:getArenaShopListNum()
    local num = 0 
    for k,v in pairs(self._arenaData.list) do
        num = num + 1
    end
    return num
end

---
-- 天梯商店手动刷新价格
-- @function [parent=#RandomShopModel] getArenaShopPrice
-- @param #RandomShopModel self
-- @return #number 
function RandomShopModel:getArenaShopPrice()
    if GameConst.RANDOM_SHOP_ARENA_PRICE[self:getArenaShopCount()+1] then
        return GameConst.RANDOM_SHOP_ARENA_PRICE[self:getArenaShopCount()+1]
    else
        return GameConst.RANDOM_SHOP_ARENA_PRICE[table.maxn(GameConst.RANDOM_SHOP_ARENA_PRICE)]
    end
end

---
-- ID对应的购买次数
-- @function [parent=#RandomShopModel] getNumById
-- @param #RandomShopModel self
-- @param #number shopType
-- @param #number index
-- @return #number
function RandomShopModel:getNumById(shopType,index)
    if shopType == 1 then
        if self._guildData and self._guildData.list and self._guildData.list[index] then
            return self._guildData.list[index].num
        end
    elseif shopType == 2 then
        if self._arenaData and self._arenaData.list and self._arenaData.list[index] then
            return self._arenaData.list[index].num
        end
    elseif shopType == 3 then
        if self._blackData and self._blackData.list and self._blackData.list[index] then
            return self._blackData.list[index].num
        end
    end
    return 0
end

---
-- ID对应的购买次数
-- @function [parent=#RandomShopModel] addNumById
-- @param #RandomShopModel self
-- @param #number shopType
-- @param #number index
-- @param #number num
function RandomShopModel:addNumById(shopType,index,num)
    if shopType == 1 then
        if self._guildData and self._guildData.list and self._guildData.list[index] then
            self._guildData.list[index].num = self._guildData.list[index].num + num
            self:_raiseGuildDataChangeEvent(index,self.dataType.num)
        end
    elseif shopType == 2 then
        if self._arenaData and self._arenaData.list and self._arenaData.list[index] then
            self._arenaData.list[index].num = self._arenaData.list[index].num + num
            self:_raiseAreanDataChangeEvent(index,self.dataType.num)
        end
    elseif shopType == 3 then
        if self._blackData and self._blackData.list and self._blackData.list[index] then
            self._blackData.list[index].num = self._blackData.list[index].num + num
            self:_raiseBlackDataChangeEvent(index,self.dataType.num)
        end
    end
end

---
-- 黑市商店相关数据
-- @function [parent=#RandomShopModel] getBlackShopData
-- @param #RandomShopModel self
-- @return #number
function RandomShopModel:getBlackShopData()
    return self._data.black
end

---
-- 黑市商店下次刷新时间
-- @function [parent=#RandomShopModel] getBlackShopCDTime
-- @param #RandomShopModel self
-- @return #number
function RandomShopModel:getBlackShopCDTime()
    return self._blackData.cdTime or 0
end
---
-- 黑市商店下次刷新时间
-- @function [parent=#RandomShopModel] setBlackShopCDTime
-- @param #RandomShopModel self
-- @param #number time
function RandomShopModel:setBlackShopCDTime(time)
    self._blackData.cdTime = time
    self:_raiseBlackDataChangeEvent("0",self.dataType.time)
end
---
-- 黑市商店手动刷新次数
-- @function [parent=#RandomShopModel] getBlackShopCount
-- @param #RandomShopModel self
-- @return #number
function RandomShopModel:getBlackShopCount()
    return self._blackData.count or 0
end
---
-- 黑市商店手动刷新次数
-- @function [parent=#RandomShopModel] setBlackShopCount
-- @param #RandomShopModel self
-- @param #number count
function RandomShopModel:setBlackShopCount(count)
    self._blackData.count = count
    self:_raiseBlackDataChangeEvent("0",self.dataType.count)
end
---
-- 黑市商店手动刷新次数
-- @function [parent=#RandomShopModel] addBlackShopCount
-- @param #RandomShopModel self
-- @param #number count
function RandomShopModel:addBlackShopCount(count)
    self._blackData.count = self._blackData.count+count
    self:_raiseBlackDataChangeEvent("0",self.dataType.count)
end

---
-- 黑市商店列表
-- @function [parent=#RandomShopModel] getBlackShopList
-- @param #RandomShopModel self
-- @return #number
function RandomShopModel:getBlackShopList()
    return self._blackData.list or {}
end
---
-- 天梯商店列表
-- @function [parent=#RandomShopModel] setBlackShopList
-- @param #RandomShopModel self
-- @param #table list
function RandomShopModel:setBlackShopList(list)
    self._blackData.list = list
    self.refreshPlayBlack = true 
    self:_raiseBlackDataChangeEvent("0",self.dataType.list)
end
---
-- 黑市商店列表数量
-- @function [parent=#RandomShopModel] getBlackShopListNum
-- @param #RandomShopModel self
-- @return #number
function RandomShopModel:getBlackShopListNum()
    local num = 0 
    for k,v in pairs(self._blackData.list) do
        num = num + 1
    end
    return num
end

---
-- 黑市商店是否还有未购买的
-- @function [parent=#RandomShopModel] ifCanBuyBlack
-- @param #RandomShopModel self
-- @return #number
function RandomShopModel:ifCanBuyBlack()
    if self._blackData.list then
        for k,v in pairs(self._blackData.list) do
            if v.num < GameConfig.Shop_rndConfig:getData(tonumber(v.id)).limit then
                return true
            end
        end
    end
    return false
end

---
-- 黑市商店是否刷新
-- @function [parent=#RandomShopModel] ifBlackRefresh
-- @param #RandomShopModel self
-- @return #number
function RandomShopModel:ifBlackRefresh()
    if ch.RandomShopModel:getBlackShopCDTime()>0 and ch.RandomShopModel:getBlackShopCDTime() <= os_time() then
        return true
    end
    return false
end

---
-- 黑市商店手动刷新价格
-- @function [parent=#RandomShopModel] getBlackShopPrice
-- @param #RandomShopModel self
-- @return #number 
function RandomShopModel:getBlackShopPrice()
    if GameConst.RANDOM_SHOP_BLACK_PRICE[self:getBlackShopCount()+1] then
        return GameConst.RANDOM_SHOP_BLACK_PRICE[self:getBlackShopCount()+1]
    else
        return GameConst.RANDOM_SHOP_BLACK_PRICE[table.maxn(GameConst.RANDOM_SHOP_BLACK_PRICE)]
    end
end



---
-- 过天刷新
-- @function [parent=#RandomShopModel] onNextDay
-- @param #RandomShopModel self
function RandomShopModel:onNextDay()
    self:setArenaShopCount(0)
    self:setBlackShopCount(0)
    self:setGuildShopCount(0)
end

return RandomShopModel