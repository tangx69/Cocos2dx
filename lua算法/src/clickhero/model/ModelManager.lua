---
-- model的整合管理
-- @module ModelManager
local ModelManager = {
    _data = nil,
    _offLineGoldTime = 0,
}
ModelManager.__index = ModelManager

---
-- 初始化
-- @function [parent=#ModelManager] init
-- @param #ModelManager self
-- @param #string data
function ModelManager:init(data)
    if data then
        if type(data) == "string" then
            if data ~= "" then
                self._data = json.decode(data)
            else
                self._data = self.basedata
            end
        else
            self._data = data
        end
    else
        self._data = self.basedata
    end
    ch.StatisticsModel:init(self._data)
    ch.PartnerModel:init(self._data)
    ch.MsgModel:init(self._data)
    ch.GuideModel:init(self._data)
    ch.PlayerModel:init(self._data)
    ch.MoneyModel:init(self._data)
    ch.MagicModel:init(self._data)
    ch.PetCardModel:init(self._data)
    ch.TotemModel:init(self._data)
    ch.ShentanModel:init(self._data) -- 神坛
    ch.RunicModel:init(self._data)  -- 符文初始化时需用到图腾的信息
    
    ch.LevelModel:init(self._data)
    -- 第一周签到和后续签到
    ch.FirstSignModel:init(self._data)
    ch.SignModel:init(self._data)
    ch.BuffModel:init(self._data)
    ch.SettingModel:init()
    -- 排行榜必须在聊天缓存之前，要不会有称号显示错误
    ch.RankListModel:init(self._data)
    ch.GuildModel:init(self._data)
    -- 任务需要在宠物之后，需要主动技的事件监听
    ch.TaskModel:init(self._data)
    -- 成就需要在统计之后,需要在任务之后,以便发送同步数据
    ch.AltarModel:init(self._data) --tgx
    ch.AchievementModel:init(self._data)
    ch.FairyModel:init(self._data)
    ch.ShopModel:init(self._data)
    ch.WarpathModel:init(self._data)
    ch.DefendModel:init(self._data)
    ch.UserTitleModel:init()
    ch.PowerModel:init(self._data)
    ch.FestivityModel:init(self._data)
    ch.BuyLimitModel:init(self._data)
    ch.AFKModel:init(self._data)
    ch.ChatModel:init(self._data)
    ch.ArenaModel:init(self._data)
    --ch.AltarModel:init(self._data) --tgx 放成就前面,不然会报错!!
    ch.MineModel:init(self._data)
    ch.OffLineModel:init(self._data)
    ch.MatchRankModel:init(self._data)
    ch.FamiliarModel:init(self._data)
    ch.CardFBModel:init(self._data)
    ch.ShareModel:init(self._data)
    ch.ChristmasModel:init(self._data)
    ch.RandomShopModel:init(self._data)
    ch.GuildWarModel:init(self._data) 
    self._data.offLineGold.num = self._data.offLineGold.num
    self:setOffLineGold(self._data.offLineGold.num)
    ch.TimerController:start()
    
    
--    if self._data.offLineGold and self._data.offLineGold.num then
--        self:setOffLineGold(self._data.offLineGold.num)
--    else
--        local lastTime = cc.UserDefault:getInstance():getIntegerForKey("SAVETIME")
--        if lastTime ~= 0 then
--            local time = os_time() - lastTime
--            self:setOffLineGold(ch.CommonFunc:getOffLineGold(time) * (1+ch.BuffModel:getOGoldAddtion()))
--        end
--    end
end

function ModelManager:clean()
	ch.AchievementModel:clean()
	ch.AFKModel:clean()
	ch.AltarModel:clean()
	ch.ArenaModel:clean()
	ch.BuffModel:clean()
	ch.BuyLimitModel:clean()
	ch.CardFBModel:clean()
	ch.ChatModel:clean()
	ch.ChristmasModel:clean()
	ch.DefendModel:clean()
	ch.FairyModel:clean()
	ch.FamiliarModel:clean()
	ch.FestivityModel:clean()
	ch.FirstSignModel:clean()
	ch.GuideModel:clean()
	ch.GuildModel:clean()
	ch.GuildWarModel:clean()
	ch.LevelModel:clean()
	ch.MagicModel:clean()
	ch.MatchRankModel:clean()
	ch.MineModel:clean()
	ch.MoneyModel:clean()
	ch.MsgModel:clean()
	ch.OffLineModel:clean()
	ch.PartnerModel:clean()
	ch.PetCardModel:clean()
	ch.PlayerModel:clean()
	ch.PowerModel:clean()
	ch.RandomShopModel:clean()
	ch.RankListModel:clean()
	ch.RunicModel:clean()
	ch.SettingModel:clean()
	ch.ShareModel:clean()
	ch.ShopModel:clean()
	ch.SignModel:clean()
	ch.StatisticsModel:clean()
	ch.TaskModel:clean()
	ch.TotemModel:clean()
	ch.UserTitleModel:clean()
	ch.WarpathModel:clean()
end

---
-- 离线收益
-- @function [parent=#ModelManager] getOffLineGold
-- @param #ModelManager self
-- @return #number
function ModelManager:getOffLineGold()
    return self._offLineGold or ch.LongDouble.zero
end

---
-- 转生后清除离线收益
-- @function [parent=#ModelManager] setOffLineGold
-- @param #ModelManager self
-- @param #number gold
function ModelManager:setOffLineGold(gold)
    self._offLineGold = gold or ch.LongDouble.zero
end

---
-- 保存数据
-- @function [parent=#ModelManager] saveData
-- @param #ModelManager self
function  ModelManager:saveData()
    local dataStr = json.encode(self._data)
    cc.UserDefault:getInstance():setStringForKey("PLAYERDATA",dataStr)
    cc.UserDefault:getInstance():setIntegerForKey("SAVETIME",math.floor(os_clock()))
end

---
-- 获取保存的数据
-- @function [parent=#ModelManager] getData
-- @param #ModelManager self
-- @return #string
function  ModelManager:getData()
    local saveStr = cc.UserDefault:getInstance():getStringForKey("PLAYERDATA")
    if saveStr == "null" then saveStr = nil end
    return saveStr
    --return zzy.LocalStorageUtils:get("PLAYERDATA")
end

---
-- 清除数据
-- @function [parent=#ModelManager] clearData
-- @param #ModelManager self
function  ModelManager:clearData()
    self._data = self.basedata
    local tmpData = {}
    local fairydata = {count = 0,diamond = 0,time = math.floor(os_time())}
    cc.UserDefault:getInstance():setStringForKey("fairyCount",json.encode(fairydata))
    --self:saveData()
end

---
-- 清除用户账号
-- @function [parent=#ModelManager] clearUserID
-- @param #ModelManager self
function  ModelManager:clearUserID()
    local tmpData = {}
    cc.UserDefault:getInstance():setStringForKey("userId",json.encode(tmpData))
    --self:saveData()
end

---
-- 跨天时刷新数据
-- @function [parent=#ModelManager] onNextDay
-- @param #ModelManager self
function ModelManager:onNextDay()
    ch.FirstSignModel:onNextDay()
    ch.SignModel:onNextDay()
    ch.TaskModel:onNextDay()
    ch.fairyLayer:onNextDay()
    ch.ShopModel:onNextDay()
    ch.GuildModel:onNextDay()
    ch.FestivityModel:onNextDay()
    ch.BuyLimitModel:onNextDay()
    ch.CardFBModel:onNextDay()
    ch.ArenaModel:onNextDay()
    ch.ShareModel:onNextDay()
    ch.ChristmasModel:onNextDay()
    ch.RandomShopModel:onNextDay()
    ch.AltarModel:onNextDay()
    ch.MineModel:onNextDay()
    ch.GuildWarModel:onNextDay()
end


ModelManager.basedata = {magic = {},runic = {l = 1,s = {}},
                        totem = {soul = 0,diamond = 0,clean = 0,own={},randTotem={}},achievement = {},
                        statistics = {gotSoul = 0,gotGold = 0,playTime = 0,rTime = 0,rTimes = 0,runicTimes = 0,runicCritTimes = 0, maxSeriesTimes = 0,
                                    killedMonsters = 0,killedBosses = 0,killedBoxes = 0,maxLevel = 0,clickTimes=0, maxClickSpeed=0,},
                        level = {curLevel = 1,maxLevel = 1,starLevel = 1,boss = {1,2,3,4,5}},
                        money = {},
                        sign = {days=0,status = 0},
                        player = {name = Language.INIT_PLAYER_NAME,changeNum = 0},
                        task = {power = 0, showTask = {}}, -- 
                        buff = {card = 0,sStone = 0,inspire = 0,manyGold = 0},
                        offLineGold = {num=0},
                        fairy = {count = 0},
                        shop = {goldCount = 0},
                        msg = {num = 0},
                        partner = {cz = "20001",hs = {"20001"},yld={},jl={},ylq = {}},
                        power = {num = 0},
                        festivity = {days = 1,getReward={1,2,3},canReward={4,5,6}},
                        autofight = {},
                        familiar = {},
                        
                        } -- 前期测试用
ModelManager.basedata.money["90001"] =  1000
ModelManager.basedata.money["90002"] = 0
ModelManager.basedata.money["90003"] = 0
ModelManager.basedata.money["90004"] = 0
ModelManager.basedata.money["90005"] = 0 
ModelManager.basedata.money["90006"] = 0 
ModelManager.basedata.money["90011"] = 0 
ModelManager.basedata.magic["1"] = {l = 1,s = 0}

return ModelManager
