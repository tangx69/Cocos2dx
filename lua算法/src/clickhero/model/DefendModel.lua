---
-- 宠物塔防model
-- @module DefendModel
local DefendModel = {
    _data = nil,
    _curLevel= nil,
    _curConfigId = nil,
    _nextConfigId = nil,
    _critLevel = nil,
    _attackLevel = nil,
    _speedLevel = nil,
    _powerDropLevel = nil,
    _attackRatio = nil,
    
    _rewardAddt = nil, -- 1为暴击，2为攻击力，3，能量概率，4水晶掉落概率
    _rewardContent = nil, -- 每波奖励内容
    
    _hp = nil,
    _crystals = nil, -- 水晶数
    _power = nil,    -- 能量数
    _killedCount=nil,
    _totalGold = nil,
    
    _enemyHPCache = nil,        
    
    dataChangeEventType = "DEFEND_MODEL_DATA_CHANGE",
    powChangeEventType = "DEFEND_MODEL_POWER_CHANGE",
    getRewardEventType = "DEFEND_MODEL_GET_REWARD",
    dataType = {
        hp = 1,
        level = 2,
        critLevel = 3,
        attackLevel = 4,
        speedLevel = 5,
        crystals = 6,
        killedCount = 7,
        Times = 8,
        PowerDropLevel = 9
    },
    _rankData = nil,
    _myRankData = nil,
    ifRankData = false,
    panelDataChangeEventType = "DEFEND_PANEL_DATA_CHANGE",
    
    _skillTime = nil,
    _skillPauseTime = nil,
    SkillCDProgressChangedEventType = "DEFEND_SKILL_PROGRESS_CHANGED", --{type =,id =,leftTime=}
    SkillCDStatusChangedEventType = "DEFEND_SKILL_STATUS_CHANGED", --{type =,id =,statusType=,}
    StatusType = {
        began = 1,
        ended = 2,
    },
    skillId = {
        ALZ = 11,
        CHS = 12,
        HHS = 13,
        FSZF = 14,
        YSCJ = 15,
        ZRJD = 16,
    }
}

ENCODE_NUM = ENCODE_NUM or function(num)
    return num
end

DECODE_NUM = DECODE_NUM or function(num)
    return num
end

function DefendModel:_raiseDataChangeEvent(dataType)
    local evt = {
        type = self.dataChangeEventType,
        dataType = dataType,
    }
    zzy.EventManager:dispatch(evt)
end

function DefendModel:_raiseCDStatusChangedEvent(id,status)
    local evt = {type = self.SkillCDStatusChangedEventType}
    evt.id = id
    evt.statusType = status
    zzy.EventManager:dispatch(evt)
end

function DefendModel:_raiseCDProgressChangedEvent(id,leftTime)
    local evt = {type = self.SkillCDProgressChangedEventType}
    evt.id = id
    evt.leftTime = leftTime
    zzy.EventManager:dispatch(evt)
end

function DefendModel:_panelDataChangeEvent()
    local evt = {
        type = self.panelDataChangeEventType
    }
    zzy.EventManager:dispatch(evt)
end

---
-- @function [parent=#DefendModel] init
-- @param #DefendModel self
-- @param #table data
function DefendModel:init(data)
    self._data = data.defend or {}
    self._data["times"] = self._data["times"] or 0
    self._data["cdtime"] = self._data["cdtime"] or 0
    self._rankData = {}
    self._myRankData = {}
    self._skillTime = {}
    self._attackRatio = 1
end

---
-- 清理
-- @function [parent=#DefendModel] clean
-- @param #DefendModel self
function DefendModel:clean()
    self._data = nil
    self._curLevel= nil
    self._curConfigId = nil
    self._nextConfigId = nil
    self._critLevel = nil
    self._attackLevel = nil
    self._speedLevel = nil
    self._powerDropLevel = nil
    self._attackRatio = nil
    self._rewardAddt = nil
    self._rewardContent = nil
    self._hp = nil
    self._crystals = nil
    self._power = nil
    self._killedCount = nil
    self._totalGold = nil  
    self._enemyHPCache = nil
    self._rankData = nil
    self._myRankData = nil
    self.ifRankData = false  
    self._skillTime = nil
    self._skillPauseTime = nil
end

local count = #GameConfig.DefendConfig:getTable()

---
-- 获得今天参加的次数
-- @function [parent=#DefendModel] getTimes
-- @param #DefendModel self
-- @return #number
function DefendModel:getTimes()
	return self._data["times"]
end

---
-- 开始游戏
-- @function [parent=#DefendModel] start
-- @param #DefendModel self
function DefendModel:start()
    self._data["times"] = self._data["times"] + 1
    self._data["cdtime"] = os_time() + 7200
    self._curLevel = 1
    self._curConfigId = math.random(1,count)
    self._nextConfigId = self:_getNextId()
    self._critLevel = 0
    self._attackLevel = 0
    self._speedLevel = 0
    self._powerDropLevel = 0
    self._power = GameConst.DEFEND_INIT_POWER_NUM
    self._killedCount = 0
    self._totalGold = 0
    self._crystals = 0
    self._rewardAddt = {0,0,0,0}
    local maxLevel = ch.StatisticsModel:getMaxLevel()
    self._attackRatio = maxLevel/(maxLevel + GameConst.DEFEND_PET_ATTACK_BONUS)*2 +1
    self._hp = GameConst.DEFEND_BASE_HP_NUMBER
    self._enemyHPCache = {}
    self:_raiseDataChangeEvent(self.dataType.Times)
end

---
-- 进入下一波
-- @function [parent=#DefendModel] nextLevel
-- @param #DefendModel self
function DefendModel:nextLevel()
    self._curLevel = ENCODE_NUM(self:getCurLevel() + 1)
    self._curConfigId = self._nextConfigId
    self._nextConfigId = self:_getNextId()
    self:_raiseDataChangeEvent(self.dataType.level)
end

---
-- 获得当前的波次
-- @function [parent=#DefendModel] getCurLevel
-- @param #DefendModel self
-- @return #number
function DefendModel:getCurLevel()
	return DECODE_NUM(self._curLevel)
end

---
-- 获得当前波的表id
-- @function [parent=#DefendModel] getCurConfigId
-- @param #DefendModel self
-- @return #number
function DefendModel:getCurConfigId()
    return self._curConfigId
end

---
-- 获得下一波的表id
-- @function [parent=#DefendModel] getNextConfigId
-- @param #DefendModel self
-- @return #number
function DefendModel:getNextConfigId()
    return self._nextConfigId
end


---
-- 获得当前暴击技能等级
-- @function [parent=#DefendModel] getCritLevel
-- @param #DefendModel self
-- @return #number
function DefendModel:getCritLevel()
    return self._critLevel
end

---
-- 获得当前攻击技能等级
-- @function [parent=#DefendModel] getAttackLevel
-- @param #DefendModel self
-- @return #number
function DefendModel:getAttackLevel()
    return self._attackLevel
end

---
-- 获得当前减速技能等级
-- @function [parent=#DefendModel] getSpeedLevel
-- @param #DefendModel self
-- @return #number
function DefendModel:getSpeedLevel()
    return self._speedLevel
end

---
-- 获得当前能量掉落技能等级
-- @function [parent=#DefendModel] getPowerDropLevel
-- @param #DefendModel self
-- @return #number
function DefendModel:getPowerDropLevel()
    return self._powerDropLevel
end

---
-- 添加当前暴击技能等级
-- @function [parent=#DefendModel] addCritLevel
-- @param #DefendModel self
-- @param #number level
function DefendModel:addCritLevel(level)
    self._critLevel = self._critLevel + level
    self:_raiseDataChangeEvent(self.dataType.critLevel)
end

---
-- 添加当前攻击技能等级
-- @function [parent=#DefendModel] addAttackLevel
-- @param #DefendModel self
-- @param #number level
function DefendModel:addAttackLevel(level)
    self._attackLevel = self._attackLevel + level
    self:_raiseDataChangeEvent(self.dataType.attackLevel)
end

---
-- 添加当前减速技能等级
-- @function [parent=#DefendModel] addSpeedLevel
-- @param #DefendModel self
-- @param #number level
function DefendModel:addSpeedLevel(level)
    self._speedLevel = self._speedLevel + level
    self:_raiseDataChangeEvent(self.dataType.speedLevel)
end

---
-- 添加当前能量掉落技能等级
-- @function [parent=#DefendModel] addPowerDropLevel
-- @param #DefendModel self
-- @param #number level
function DefendModel:addPowerDropLevel(level)
    self._powerDropLevel = self._powerDropLevel + level
    self:_raiseDataChangeEvent(self.dataType.PowerDropLevel)
end

---
-- 获得当前防御点数
-- @function [parent=#DefendModel] getHP
-- @param #DefendModel self
-- @return #number
function DefendModel:getHP()
    return DECODE_NUM(self._hp)
end

---
-- 添加当前防御点数
-- @function [parent=#DefendModel] addHP
-- @param #DefendModel self
-- @param #number hp
function DefendModel:addHP(hp)
    self._hp = ENCODE_NUM(self:getHP() + hp)
    self:_raiseDataChangeEvent(self.dataType.hp)
end

---
-- 获得当前水晶
-- @function [parent=#DefendModel] getCrystals
-- @param #DefendModel self
-- @return #number
function DefendModel:getCrystals()
    return DECODE_NUM(self._crystals)
end

---
-- 获得当前能量
-- @function [parent=#DefendModel] getPower
-- @param #DefendModel self
-- @return #number
function DefendModel:getPower()
    return DECODE_NUM(self._power)
end

---
-- 获得当前水晶的掉落概率
-- @function [parent=#DefendModel] getCrystalsRate
-- @param #DefendModel self
-- @return #number
function DefendModel:getCrystalsRate()
    return GameConst.DEFEND_CRYSTALS_DROP_RATE + self._rewardAddt[4]
end

---
-- 获得当前能量的掉落概率
-- @function [parent=#DefendModel] getPowerRate
-- @param #DefendModel self
-- @return #number
function DefendModel:getPowerRate()
    return GameConst.DEFEND_POWER_DROP_RATE + self:getPowerDropAddt()
end

---
-- 添加当前水晶
-- @function [parent=#DefendModel] addCrystals
-- @param #DefendModel self
-- @param #number num
function DefendModel:addCrystals(num)
    self._crystals = ENCODE_NUM(self:getCrystals() + num)
    self:_raiseDataChangeEvent(self.dataType.crystals)
end

---
-- 添加当前能量
-- @function [parent=#DefendModel] addPower
-- @param #DefendModel self
-- @param #number num
function DefendModel:addPower(num)
    self._power = ENCODE_NUM(self:getPower() + num)
    
    local evt = {
        type = self.powChangeEventType,
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 获得击杀总数量
-- @function [parent=#DefendModel] getkilledCount
-- @param #DefendModel self
-- @return #number
function DefendModel:getkilledCount()
    return DECODE_NUM(self._killedCount)
end

---
-- 添加击杀总数量
-- @function [parent=#DefendModel] addkilledCount
-- @param #DefendModel self
-- @param #number num
function DefendModel:addkilledCount(num)
    if num ~= 0 then
        self._killedCount = ENCODE_NUM(self:getkilledCount() + num)
        self:_raiseDataChangeEvent(self.dataType.killedCount)
    end
end

---
-- 获得应该得到的金钱折合时间
-- @function [parent=#DefendModel] getTotalGoldTime
-- @param #DefendModel self
-- @return #number
function DefendModel:getTotalGoldTime()
    local shentanEffect = ch.ShentanModel:getSkillData(4)
    local ci = GameConst.DEFEND_GOLD_REWARD_INDEX * self:getkilledCount()
    local num = math.pow(GameConst.DEFEND_GOLD_REWARD_BASE,ci)
    num = math.floor(GameConst.DEFEND_GOLD_REWARD_RATIO * num)
    return num
end

---
-- 获得应该得到的金钱总合
-- @function [parent=#DefendModel] getTotalGold
-- @param #DefendModel self
-- @return #number
function DefendModel:getTotalGold()
    local shentanEffect = ch.ShentanModel:getSkillData(4)
    local ci = GameConst.DEFEND_GOLD_REWARD_INDEX * self:getkilledCount()
    local num = math.pow(GameConst.DEFEND_GOLD_REWARD_BASE,ci)
    num = math.floor(GameConst.DEFEND_GOLD_REWARD_RATIO * num)
    return ch.CommonFunc:getOffLineGold(num) * (1 + shentanEffect)
end


-----
---- 添加应该得到的金钱
---- @function [parent=#DefendModel] addTotalGold
---- @param #DefendModel self
---- @param #number num
--function DefendModel:addTotalGold(num)
--    self._totalGold = self._totalGold + num
--end

---
-- 设置每波的奖励内容
-- @function [parent=#DefendModel] setRewardContent
-- @param #DefendModel self
-- @param #table content  {{l=1,t=3},{l=1,t=3},{l=1,t=3}}
function DefendModel:setRewardContent(content)
    self._rewardContent = content
end

---
-- 获得每波奖励内容
-- @function [parent=#DefendModel] getRewardContent
-- @param #DefendModel self
-- @return #table {l=1,t=3}
function DefendModel:getRewardContent(index)
    if self._rewardContent then
        return self._rewardContent[index]
    end
    return {}
end

---
-- 添加用户选择的奖励
-- @function [parent=#DefendModel] addReward
-- @param #DefendModel self
-- @param #number index 用户选择的宝箱id
function DefendModel:addReward(index)
	if index == 0 then
	   for _,c in ipairs(self._rewardContent) do
	       self:_addRewardByType(c.l,c.t)
	   end
	else
        self:_addRewardByType(self._rewardContent[index].l,self._rewardContent[index].t)
	end
    local evt = {
        type = self.getRewardEventType,
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 根据类型添加奖励
-- @function [parent=#DefendModel] _addRewardByType
-- @param #DefendModel self
-- @param #number value
-- @param #number type 1暴击，2攻击,3能量掉落，4水晶，5鼓舞，6水晶掉落率，7法力
function DefendModel:_addRewardByType(value,type)
	if type == 1 then
        self._rewardAddt[1] = self._rewardAddt[1] + value
	elseif type == 2 then
        self._rewardAddt[2] = self._rewardAddt[2] + value
	elseif type == 3 then
        self._rewardAddt[3] = self._rewardAddt[3] + value
	elseif type == 4 then
        self:addCrystals(value)	   
	elseif type == 5 then
        ch.BuffModel:addInspireBuff(value)
	elseif type == 6 then
        self._rewardAddt[4] = self._rewardAddt[4] + value
	elseif type == 7 then
        self:addPower(value)
	end
end

---
-- 获得攻击力
-- @function [parent=#DefendModel] getDPS
-- @param #DefendModel self
-- @return #number
function DefendModel:getDPS()
    return ch.RunicModel:getDPS()*((1 + self:getDPSAddt()) *self._attackRatio)
end

---
-- 获得攻击力技能等级的加成
-- @function [parent=#DefendModel] getDPSSkillAddt
-- @param #DefendModel self
-- @return #number
function DefendModel:getDPSSkillAddt()
    return self._attackLevel * GameConst.DEFEND_SKILL_LEVELUP_STEP[2]
end

---
-- 获得攻击力的总共加成
-- @function [parent=#DefendModel] getDPSAddt
-- @param #DefendModel self
-- @return #number
function DefendModel:getDPSAddt()
    return self._attackLevel * GameConst.DEFEND_SKILL_LEVELUP_STEP[2] + self._rewardAddt[2]
end

---
-- 获得暴击的概率
-- @function [parent=#DefendModel] getCritRate
-- @param #DefendModel self
-- @return #number
function DefendModel:getCritRate()
    return ch.RunicModel:getCritRate() + self:getCritAddt()
end

---
-- 获得暴击的技能等级概率加成
-- @function [parent=#DefendModel] getCritSkillAddt
-- @param #DefendModel self
-- @return #number
function DefendModel:getCritSkillAddt()
    return self._critLevel * GameConst.DEFEND_SKILL_LEVELUP_STEP[1]
end

---
-- 获得暴击的总共概率加成
-- @function [parent=#DefendModel] getCritAddt
-- @param #DefendModel self
-- @return #number
function DefendModel:getCritAddt()
    return self._critLevel * GameConst.DEFEND_SKILL_LEVELUP_STEP[1] + self._rewardAddt[1]
end

---
-- 获得能量掉落的技能等级概率加成
-- @function [parent=#DefendModel] getPowerDropSkillAddt
-- @param #DefendModel self
-- @return #number
function DefendModel:getPowerDropSkillAddt()
    return self._powerDropLevel * GameConst.DEFEND_SKILL_LEVELUP_STEP[3]
end

---
-- 获得能量掉落的总共概率加成
-- @function [parent=#DefendModel] getPowerDropAddt
-- @param #DefendModel self
-- @return #number
function DefendModel:getPowerDropAddt()
    return self._powerDropLevel * GameConst.DEFEND_SKILL_LEVELUP_STEP[3] + self._rewardAddt[3]
end

---
-- 获得总体减速效果
-- @function [parent=#DefendModel] getSpeedAddt
-- @param #DefendModel self
-- @return #number
function DefendModel:getSpeedAddt()
    local addt = 1 - 1/(1+0.15*self._speedLevel) + self._rewardAddt[3]
    addt = addt > 0.9 and 0.9 or addt
    return addt
end

---
-- 获得减速技能等级效果
-- @function [parent=#DefendModel] getSpeedSkillAddt
-- @param #DefendModel self
-- @return #number
function DefendModel:getSpeedSkillAddt()
    return 1 - 1/(1+0.15*self._speedLevel)
end

---
-- 获得敌人血量
-- @function [parent=#DefendModel] getEnemyHP
-- @param #DefendModel self
-- @param #number level
-- @return #number
function DefendModel:getEnemyHP(level)
    level = level or self:getCurLevel()
    if not self._enemyHPCache[level] then
        local hp = ch.RunicModel:getDPSWithoutBuff() * GameConst.DEFEND_ENEMY_HP_RATIO
        hp = hp * math.pow(GameConst.DEFEND_ENEMY_HP_STEP,level -1)
        self._enemyHPCache[level] = hp
    end
    return self._enemyHPCache[level]
end

local levelCount = #GameConfig.CrystalsConfig:getTable()

---
-- 获得水晶的掉落量
-- @function [parent=#DefendModel] getCrystalsDropNum
-- @param #DefendModel self
-- @param #number level
-- @return #number
function DefendModel:getCrystalsDropNum(level)
    level = level or self:getCurLevel()
    level = level > levelCount and levelCount or level
    return GameConfig.CrystalsConfig:getData(level).fall
end

---
-- 获得能量的额外掉落量
-- @function [parent=#DefendModel] getPowerDropNum
-- @param #DefendModel self
-- @param #number level
-- @return #number
function DefendModel:getPowerDropNum(level)
   return GameConst.DEFEND_POWER_DROP_NUM
end

---
-- 获得暴击升级花费
-- @function [parent=#DefendModel] getCritLevelUpCost
-- @param #DefendModel self
-- @param #number from
-- @return #number
function DefendModel:getCritLevelUpCost(from)
    from = from or self._critLevel
    from = from + 1
    from = from > levelCount and levelCount or from
    return GameConfig.CrystalsConfig:getData(from).critCost
end

---
-- 获得攻击升级花费
-- @function [parent=#DefendModel] getAttackLevelUpCost
-- @param #DefendModel self
-- @param #number from
-- @return #number
function DefendModel:getAttackLevelUpCost(from)
    from = from or self._attackLevel
    from = from + 1
    from = from > levelCount and levelCount or from
    return GameConfig.CrystalsConfig:getData(from).attackCost
end

---
-- 获得减速升级花费
-- @function [parent=#DefendModel] getSpeedLevelUpCost
-- @param #DefendModel self
-- @param #number from
-- @return #number
function DefendModel:getSpeedLevelUpCost(from)
    from = from or self._speedLevel
    from = from + 1
    from = from > levelCount and levelCount or from
    return GameConfig.CrystalsConfig:getData(from).speedCost
end

---
-- 获得能量掉落升级花费
-- @function [parent=#DefendModel] getPowerDropLVCost
-- @param #DefendModel self
-- @param #number from
-- @return #number
function DefendModel:getPowerDropLVCost(from)
    from = from or self._powerDropLevel
    from = from + 1
    from = from > levelCount and levelCount or from
    return GameConfig.CrystalsConfig:getData(from).speedCost
end

---
-- 获得波次的敌人总数量
-- @function [parent=#DefendModel] getEnemyCount
-- @param #DefendModel self
-- @param #number id 波id
-- @return #number
function DefendModel:getEnemyCount(id)
    local totalCount = 0
    local config = GameConfig.DefendConfig:getData(id)
    for i= 1,10 do
        local index = "gw"..i
        if config[index] and config[index] ~= "" then
            local tmp = zzy.StringUtils:split(config[index],",")
            if #tmp ~= 4 then
                error("defend表，level "..self._curConfigId.."里的 n 错误" )
            end
            local count = tmp[4]
            totalCount = totalCount + tonumber(count)
        else
            break
        end
    end
    return totalCount
end


---
-- 获得下一波次怪物表id
-- @function [parent=#DefendModel] _getNextId
-- @param #DefendModel self
-- @return #number
function DefendModel:_getNextId()
    if count == 1 then return 1 end
    local id = math.random(1,count)
    while self._curConfigId and id == self._curConfigId  do
        id = math.random(1,count)
    end
    return id
end

---
-- 设置玩家排名信息
-- @function [parent=#DefendModel] setRankData
-- @param #DefendModel self 
-- @param #table data
function DefendModel:setRankData(data)
    self._rankData = data.list
    self._myRankData.rank = data.rank
    self._myRankData.score = data.score
    self.ifRankData = true
    self:_panelDataChangeEvent()
end

---
-- 获得玩家排名信息
-- @function [parent=#DefendModel] getRankData
-- @param #DefendModel self 
-- @param #number index
-- @return #table
function DefendModel:getRankData(index)
    return self._rankData[index] or {}
end

---
-- 获得排名信息
-- @function [parent=#DefendModel] getAllRankData
-- @param #DefendModel self 
-- @return #table
function DefendModel:getAllRankData()
    return self._rankData or {}
end

---
-- 获得自己的排名信息
-- @function [parent=#DefendModel] getMyRankData
-- @param #DefendModel self 
-- @return #table
function DefendModel:getMyRankData()
    return self._myRankData
end

---
-- 获取技能的剩余冷却时间，-1表示技能已冷却完毕
-- @function [parent=#DefendModel] getSkillCD
-- @param #DefendModel self
-- @param #DefendModel id
-- @return #number
function DefendModel:getSkillCD(id)
    local time = os_clock() - self:getUsedTime(id)
    if self._skillPauseTime then
        time = time - os_clock() + self._skillPauseTime
    end
    local totalCd = self:getSkillTotalCD(id)
    if time > totalCd then
        return -1
    else
        return totalCd - time
    end
end

---
-- 获取技能的上次使用时间
-- @function [parent=#DefendModel] getUsedTime
-- @param #DefendModel self
-- @param #number id
-- @return #number
function DefendModel:getUsedTime(id)
    return self._skillTime[id] or 0
end

---
-- 获取技能的总共冷却时间
-- @function [parent=#DefendModel] getSkillTotalCD
-- @param #DefendModel self
-- @param #number id
-- @return #number
function DefendModel:getSkillTotalCD(id)
    return GameConfig.SkillConfig:getData(id).cd
end

---
-- 使用技能
-- @function [parent=#DefendModel] useSkill
-- @param #DefendModel self
-- @param #number id
-- @return #number
function DefendModel:useSkill(id)
    if self:getSkillCD(id) ~= -1 then return end
    self._skillTime[id] = os_clock()
    self:_raiseCDProgressChangedEvent(id,self:getSkillCD(id))
    self:_raiseCDStatusChangedEvent(id,self.StatusType.began)
    local scheduleId = nil
    scheduleId = zzy.EventManager:listen(zzy.Events.TickEventType,function()
        local leftTime = self:getSkillCD(id)
        if leftTime >= 0 then
            self:_raiseCDProgressChangedEvent(id,leftTime)
        else
            self:_raiseCDStatusChangedEvent(id,self.StatusType.ended)
            zzy.EventManager:unListen(scheduleId)
        end
    end) 
end

---
-- 清除所有技能CD(不包括正在释放的技能)
-- @function [parent=#DefendModel] clearAllSkillCD
-- @param #RunicModel self
function DefendModel:clearAllSkillCD()
    self._skillPauseTime = nil
    for _,id in pairs(self.skillId) do
        self:clearSkillCD(id)
    end
end


---
-- 暂停技能
-- @function [parent=#DefendModel] pauseSkill
-- @param #RunicModel self
function DefendModel:pauseSkill()
    if self._skillPauseTime then return end
    self._skillPauseTime = os_clock()
end

---
-- 恢复技能
-- @function [parent=#DefendModel] resumeSkill
-- @param #RunicModel self
function DefendModel:resumeSkill()
    if self._skillPauseTime then
        local time = os_clock() - self._skillPauseTime
        for id,v in pairs(self._skillTime) do
            self._skillTime[id] = self._skillTime[id] + time
        end
        self._skillPauseTime = nil
    end
end

---
-- 清除某个技能CD
-- @function [parent=#DefendModel] clearSkillCD
-- @param #RunicModel self
-- @param #number id
function DefendModel:clearSkillCD(id)
    self._skillTime[id] = nil
end

---
-- 刷新倒计时
-- @function [parent=#DefendModel] getTimeCD
-- @param #DefendModel self
function DefendModel:getTimeCD()
--    local now = os_time()
--    local oneDaySecs = 24 * 60 * 60
--    -- 需要减掉东八区的8个小时
--    local today_0 = now - now % oneDaySecs - 8*60*60
--    local today_12 = today_0 + 12 * 60 * 60
--    local today_18 = today_0 + 18 * 60 * 60
--    local today_24 = today_0 + oneDaySecs
--    local leftTime = 0
--    
--    if now < today_12 then
--        leftTime = today_12 - now
--    elseif now < today_18 then
--        leftTime = today_18 - now
--    elseif now < today_24 then
--        leftTime = today_24 - now
--    else
--        leftTime = today_12 + oneDaySecs - now
--    end
--    if leftTime > 0 then 
--        return math.floor(leftTime) 
--    end
--    return -1

    local now = os_time()
    if now < self._data.cdtime then
        return math.floor(self._data.cdtime-now)
    else
        return -1
    end
end

---
-- 刷新可挑战次数
-- @function [parent=#DefendModel] refreshTimes
-- @param #DefendModel self
function DefendModel:refreshTimes()
    if ch.StatisticsModel:getMaxLevel() > GameConst.DEFEND_OPEN_LEVEL then
        self._data = self._data or {}
        self._data["times"] = 0
        self:_raiseDataChangeEvent(self.dataType.Times)
    end
end

return DefendModel