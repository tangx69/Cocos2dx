---
-- 宝物 model层     结构 {{l = 1,s = 0}, ... }
--@module MagicModel
local MagicModel = {
    _data = nil,
    _skillCache = nil,
    _skillGlobalCache = nil, -- 技能的全局加成
    _dpsCache = nil,
    _totalDpsCache = nil,
    _totalDpsWithoutBuffCache = nil, -- 没有buff和技能等时效性的加成
    _margicOrderData = nil,  -- 数组，{"15","12"}保证宝物的显示顺序
    _starRemoveId = nil,
    _skillIcon1 = nil,
    _skillIcon2 = nil,
    _starID = nil,
    _playGetList = nil,
    dataChangeEventType = "MagicModelDataChange", --{type = ,id=,dataType =}
    dataType = {
        level = 1,
        star = 2,
        playGet = 3
    }
}

ENCODE_NUM = ENCODE_NUM or function(num)
    return num
end

DECODE_NUM = DECODE_NUM or function(num)
    return num
end

---
-- @function [parent=#MagicModel] init
-- @param #MagicModel self
-- @param #table data
function MagicModel:init(data)
    self._data = data.magic
    self:_cacheAllSkillData()
    self._dpsCache = {}
    self:_cacheGlobalAddition()
    self:_orderMagic()
end

---
-- @function [parent=#MagicModel] clean
-- @param #MagicModel self
function MagicModel:clean()
    self._data = nil
    self._skillCache = nil
    self._skillGlobalCache = nil
    self._dpsCache = nil
    self._totalDpsCache = nil
    self._totalDpsWithoutBuffCache = nil
    self._margicOrderData = nil
    self._starRemoveId = nil
    self._skillIcon1 = nil
    self._skillIcon2 = nil
    self._starID = nil
    self._playGetList = nil
end

function MagicModel:_raiseDataChangeEvent(id,dataType,num)
	local evt = {
	   type = self.dataChangeEventType,
	   id = id,
	   dataType = dataType,
	   value = num or 0
	}
	zzy.EventManager:dispatch(evt)
end

---
-- 获取当前需要显示的宝物
-- @function [parent=#MagicModel] getCurMagics
-- @param #MagicModel self
-- @return #table
function MagicModel:getCurMagics()
    local maxKey = nil
    for k,v in ipairs(self._margicOrderData) do
        if self:getLevel(v) == 0 then
            maxKey = k
            break
        end
    end
    if maxKey == nil then
        maxKey = table.maxn(self._margicOrderData)
    end
    local margics = {}
    for i = 1,maxKey do
        table.insert(margics,self._margicOrderData[i])
    end
    return margics
end

---
-- 获取所有宝物ID
-- @function [parent=#MagicModel] getAllMagicsID
-- @param #MagicModel self
-- @return #table
function MagicModel:getAllMagicsID()
    local allMagic = {}
    for k,v in ipairs(self._margicOrderData) do
        table.insert(allMagic,v)
    end
    return allMagic
end

---
-- 获取所有宝物星级总数
-- @function [parent=#MagicModel] getTotalStar
-- @param #MagicModel self
-- @return #number
function MagicModel:getTotalStar()
    local num = 0
    for k,v in pairs(self._data) do
        num = num + self._data[k].s
    end
    return num
end

---
-- 获取宝物星级
-- @function [parent=#MagicModel] getStar
-- @param #MagicModel self
-- @param #string id
-- @return #number
function MagicModel:getStar(id)
    id = tostring(id)
    if self._data[id] then 
	   return self._data[id].s
	else
	   return 0
	end
end

---
-- 设置宝物星级
-- @function [parent=#MagicModel] setStar
-- @param #MagicModel self
-- @param #string id
-- @param #number star
function MagicModel:setStar(id,star)
    id = tostring(id)
    local old = self:getStar(id)
    if star ~= old then
        if not self._data[id] then
            self._data[id] = {l = 0, s = 0}
        end
        self._data[id].s = star
        self:resetDPS(id)
        self:_raiseDataChangeEvent(id,self.dataType.star)
    end
end

---
-- 添加宝物星级
-- @function [parent=#MagicModel] addStar
-- @param #MagicModel self
-- @param #string id
-- @param #number star 默认为1
function MagicModel:addStar(id,star)
    star = star or 1
    id = tostring(id)
    if star ~= 0 then
        if not self._data[id] then
            self._data[id] = {l = 0, s = 0}
        end
        self._data[id].s = self._data[id].s + star
        self:resetDPS(id)
        self._starID = id
        self:_raiseDataChangeEvent(id,self.dataType.star,star)
    end
end

---
-- 获取宝物等级
-- @function [parent=#MagicModel] getLevel
-- @param #MagicModel self
-- @param #string id
-- @return #number
function MagicModel:getLevel(id)
    id = tostring(id)
    if self._data[id] then
        return DECODE_NUM(self._data[id].l)
    else
        return 0
    end
end

---
-- 设置宝物等级
-- @function [parent=#MagicModel] setLevel
-- @param #MagicModel self
-- @param #string id
-- @param #number level
function MagicModel:setLevel(id,level)
    id = tostring(id)
    local old = self:getLevel(id)
    if old ~= level then
        if not self._data[id] then
            self._data[id] = {l = 0, s = 0}
        end
        self._data[id].l = ENCODE_NUM(level)
        self:_cacheSkillData(id,level)
        self:_onMagicLevelUp(id,old,level)
        self:resetTotalDPS()
        self:_raiseDataChangeEvent(id,self.dataType.level)
    end
end

---
-- 添加宝物等级
-- @function [parent=#MagicModel] addLevel
-- @param #MagicModel self
-- @param #string id
-- @param #number level 默认为1
function MagicModel:addLevel(id,level)
    level = level or 1
    id = tostring(id)
    if level ~= 0 then
        if not self._data[id] then
            self._data[id] = {l = 0, s = 0}
        end
        local old = self:getLevel(id)
        local new = old + level
        self._data[id].l = ENCODE_NUM(new)
        
        self:_cacheSkillData(id, new)
        self:_onMagicLevelUp(id, old, new)
        ch.MagicModel:resetTotalDPS()
        ch.StatisticsModel:addMagicGotLevel(level)
        self:_raiseDataChangeEvent(id,self.dataType.level,level)
    end
end

---
-- 获得宝物在该级别的dps
-- @function [parent=#MagicModel] getDPS
-- @param #MagicModel self
-- @param #string id 宝物的id
-- @param #number level 宝物的等级
-- @return #number
function MagicModel:getDPS(id,level)
    if level and level <= 0 then return 0 end
    id = tostring(id)
    level = level or self:getLevel(id)
    if not self._dpsCache[id] then self._dpsCache[id] = {} end
    if self._dpsCache[id][level] then
        return self._dpsCache[id][level]
    end
    for k,v in pairs(self._dpsCache[id]) do
        if k < self:getLevel(id) then
            self._dpsCache[id][k] = nil
        end
    end
    local config = GameConfig.MagicConfig:getData(id)
    if config then
        local dps = ch.LongDouble:new(config.dps)*level -- 基础值
        dps = dps * self:_getSkillData(id,level)[1] --技能自身加成（包括自带的和满200乘4的
        -- 镀金加成
        if ch.AltarModel:getAltarByType(3).level > 0 then
            local ratio = GameConst.MGAIC_STAR_RATIO + ch.TotemModel:getTotemSkillData(1,7)
            ratio = ratio * ch.AltarModel:getFinalEffect(3)
            dps = dps *(1 + ratio *self:getStar(id))
        else
            dps = dps * (1 + (GameConst.MGAIC_STAR_RATIO + ch.TotemModel:getTotemSkillData(1,7))*self:getStar(id))
        end
        dps = dps *self:getGlobalDPSAddition() -- 宝物全局dps加成
        -- 英雄之魂效果
        dps = dps *(1 + ch.StatisticsModel:getSoulRatio(ch.MoneyModel:getSoul()))
        -- 成就效果
        dps = dps * ch.AchievementModel:getRewardData(GameConst.ACHIEVEMENT_REWARD_ATTACK)
        -- 力量源泉
        dps = dps * ch.TaskModel:getCurPowerRatio()
        -- 宠物添加
        dps = dps * (1 + ch.PartnerModel:getGjjc())
        -- 宠物附加属性
        dps = dps * (1 + ch.PartnerModel:getUpNum(1))
        -- 卡牌效果
        dps = dps * ch.PetCardModel:addMagicRatio(id)
        self._dpsCache[id][level] = dps
        if tostring(id) == "1" and tostring(level) == "1" then
            --DEBUG("[id]"..id.."[level]"..level.."[dps]"..ch.NumberHelper:toString(dps))
            --DEBUG("ch.TotemModel:getTotemSkillData(1,7)="..ch.TotemModel:getTotemSkillData(1,7))
            --DEBUG("ch.AltarModel:getAltarByType(3).level="..ch.AltarModel:getAltarByType(3).level)
            --DEBUG("self:getStar(id)"..self:getStar(id))
            
            --DEBUG("self:getGlobalDPSAddition()="..self:getGlobalDPSAddition())
            --DEBUG("1 + ch.StatisticsModel:getSoulRatio(ch.MoneyModel:getSoul())="..1 + ch.StatisticsModel:getSoulRatio(ch.MoneyModel:getSoul()))
            --DEBUG("ch.AchievementModel:getRewardData(GameConst.ACHIEVEMENT_REWARD_ATTACK)="..ch.AchievementModel:getRewardData(GameConst.ACHIEVEMENT_REWARD_ATTACK))
            --DEBUG("ch.TaskModel:getCurPowerRatio()="..ch.TaskModel:getCurPowerRatio())
            --DEBUG("ch.PartnerModel:getGjjc()="..ch.PartnerModel:getGjjc())
            --DEBUG("ch.PartnerModel:getUpNum(1)="..ch.PartnerModel:getUpNum(1))
            --DEBUG("ch.PetCardModel:addMagicRatio(id)="..ch.PetCardModel:addMagicRatio(id))
        end
        return dps
    else
        error("该宝物在配置表中不存在，宝物id:"..id)
    end
end

---
-- 获得全部宝物的dps之和
-- @function [parent=#MagicModel] getTotalDPS
-- @param #MagicModel self
-- @return #number
function MagicModel:getTotalDPS()
    if not self._totalDpsCache then
        --DEBUG("--------------------")
        local dps = self:getTotalDPSWithoutBuff()
        --DEBUG("dps="..ch.NumberHelper:toString(dps))
        dps = dps * ch.PetCardModel:getAllPowerDPS() -- 卡牌总战力加成
        ----DEBUG("ch.PetCardModel:getAllPowerDPS()="..ch.PetCardModel:getAllPowerDPS())
        dps = dps * ch.GuildModel:getEnchantmentDPS() -- 公会附魔加成
        ----DEBUG("ch.GuildModel:getEnchantmentDPS()="..ch.GuildModel:getEnchantmentDPS())
        ch.StatisticsModel:setMaxDPS(dps)
        dps = dps *(1+ ch.RunicModel:getSkillEffect(ch.RunicModel.skillId.shuangchongdaji))
        ----DEBUG("ch.RunicModel:getSkillEffect(ch.RunicModel.skillId.shuangchongdaji)="..ch.RunicModel:getSkillEffect(ch.RunicModel.skillId.shuangchongdaji))
        dps = dps *(1 + ch.BuffModel:getMagicAddtion())-- buff
        ----DEBUG("ch.BuffModel:getMagicAddtion()="..ch.BuffModel:getMagicAddtion())
        dps = dps + GameConst.MGAIC_CONFIG_BASE_HARM
        --DEBUG("dps="..ch.NumberHelper:toString(dps))
        self._totalDpsCache = ch.LongDouble:floor(dps)
        --DEBUG("--------------------")
    end
    return self._totalDpsCache
end

---
-- 获得全部宝物的在无尽征途的dps
-- @function [parent=#MagicModel] getWarpathTotalDPS
-- @param #MagicModel self
-- @return #number
function MagicModel:getWarpathTotalDPS()
    local harm = ch.LongDouble:log10(self:getTotalDPSWithoutBuff()) 
    harm = math.pow(harm*30,0.5)* GameConst.WARPATH_ATTACK_HARM_RATIO
    return ch.LongDouble:new(math.floor(harm))
end

---
-- 获得全部宝物的dps之和(无BUFF)
-- @function [parent=#MagicModel] getTotalDPSWithoutBuff
-- @param #MagicModel self
-- @return #number
function MagicModel:getTotalDPSWithoutBuff()
    if not self._totalDpsWithoutBuffCache then
        local dps = 0
        for k,v in pairs(self._data) do
            dps = dps + self:getDPS(k,self:getLevel(k))
        end
        self._totalDpsWithoutBuffCache = ch.LongDouble:floor(dps)
    end
    return self._totalDpsWithoutBuffCache
end

---
-- 获得全部宝物的等级之和
-- @function [parent=#MagicModel] getTotalLevel
-- @param #MagicModel self
-- @return #number
function MagicModel:getTotalLevel()
    local level = 0
    for k,v in pairs(self._data) do
       level = level + self:getLevel(k)
    end
    return level
end

---
-- 获得最新的宝物
-- @function [parent=#MagicModel] getNewMagicId
-- @param #MagicModel self
-- @return #string
function MagicModel:getNewMagicId()
    for k,v in ipairs(self._margicOrderData) do
        if self:getLevel(v) == 0 then
            return v
        end
    end
    return nil
end

---
-- 获得宝物的技能描述
-- @function [parent=#MagicModel] getSkillDesc
-- @param #MagicModel self
-- @param #string id 宝物id
-- @param #number index 第几个技能
-- @param #number descType 短描述为1，长描述为2
-- @return #string
function MagicModel:getSkillDesc(id,index,descType)
    descType = descType or 1
    id = tostring(id)
    local config = GameConfig.MagicConfig:getData(id)
    if index ~= GameConst.MGAIC_AUTO_ADD_SKILL_INDEX1 and index ~= GameConst.MGAIC_AUTO_ADD_SKILL_INDEX2 and config then
        local type = config[string.format("sk%dtype",index)]-- or GameConst.MGAIC_CONFIG_SKILL_DEFAULT_TYPE
        local value = config[string.format("sk%dvalue",index)]/100 or 0  -- 万分之
        if type == 5 then
            return string.format(GameConst.SKILL_DESC[type][descType],value/100)
        else
            return string.format(GameConst.SKILL_DESC[type][descType],value)
        end
    elseif index == GameConst.MGAIC_AUTO_ADD_SKILL_INDEX1 then
        local step = GameConst.MGAIC_AUTO_ADD_SKILL[1].step
        local value = GameConst.MGAIC_AUTO_ADD_SKILL[1].skValue/100+1
        return string.format(GameConst.MGAIC_AUTO_ADD_SKILL_DESC,step,value)
    elseif index == GameConst.MGAIC_AUTO_ADD_SKILL_INDEX2 then
        local step = GameConst.MGAIC_AUTO_ADD_SKILL[2].step
        local value = GameConst.MGAIC_AUTO_ADD_SKILL[2].skValue/100+1
        return string.format(GameConst.MGAIC_AUTO_ADD_SKILL_DESC,step,value)
--        for k,v in ipairs(GameConst.MGAIC_AUTO_ADD_SKILL) do
--            if level >= v.level then
--                value = v.skValue
--                break
--            end
--        end
    else
        error("该宝物在配置表中不存在或者addLevel小于等于0，宝物id:"..id)
    end
end


local levelBaseRatio = 1 + GameConst.MGAIC_UPLEVEL_COST_MONEY_RATIO
---
-- 获得宝物升级需要的金钱
-- @function [parent=#MagicModel] getLevelUpCost
-- @param #MagicModel self
-- @param #string id 宝物id
-- @param #number addLevel 要升的等级数
-- @param #number level 开始升级的等级，缺省为当前等级
-- @return #number
function MagicModel:getLevelUpCost(id,addLevel,level)
    level = level or self:getLevel(id)
    id = tostring(id)
    local config = GameConfig.MagicConfig:getData(id)
    if config and addLevel > 0 then
        local a1 = config.price* ch.LongDouble:pow(levelBaseRatio,level)
        local cost = a1*(1-  ch.LongDouble:pow(levelBaseRatio,addLevel))/(-GameConst.MGAIC_UPLEVEL_COST_MONEY_RATIO) --(1-levelBaseRatio)  
        cost = cost *(1-ch.TotemModel:getTotemSkillData(3,1))
        cost = cost *(1-ch.PartnerModel:getUpNum(2)) -- 图腾 和宠物附加属性
        return ch.LongDouble:ceil(cost)
    else
        error("该宝物在配置表中不存在或者addLevel小于等于0，宝物id:"..id)
    end
end

---
-- 获取所有宝物的全局dps加成
-- @function [parent=#MagicModel] getGlobalDPSAddition
-- @param #MagicModel self
-- @return #number
function MagicModel:getGlobalDPSAddition()
    local dps = self._skillGlobalCache[3]
    return dps
end

---
-- 获取宝物全体技能中的宝物dps转化为符文攻击力的转化率（仅仅是宝物的）
-- @function [parent=#MagicModel] getMToRRate
-- @param #MagicModel self
-- @return #number
function MagicModel:getMToRRate()
    local rate = self._skillGlobalCache[2]
    return rate
end

---
-- 获取宝物技能增加的符文暴击率
-- @function [parent=#MagicModel] getMToRCritsRate
-- @param #MagicModel self
-- @return #number
function MagicModel:getMToRCritsRate()
    return self._skillGlobalCache[4]
end

---
-- 获取宝物技能增加的符文暴击伤害倍数
-- @function [parent=#MagicModel] getMToRCHarmTimes
-- @param #MagicModel self
-- @return #number
function MagicModel:getMToRCHarmTimes()
    return self._skillGlobalCache[5]
end

---
-- 获取宝物技能增加金币掉落
-- @function [parent=#MagicModel] getMToMoneyAddition
-- @param #MagicModel self
-- @return #number
function MagicModel:getMToMoneyAddition()
    return self._skillGlobalCache[6]
end

---
-- 获取宝物技能的全局加成
-- @function [parent=#MagicModel] getSkillAddtion
-- @param #MagicModel self
-- @param #number type
-- @return #number
function MagicModel:getSkillAddtion(type)
    local data = type == 3 and 1 or 0
    for k,v in pairs(self._data)do 
        if type ~= 3 then
            data = data + self:_getSkillData(k,self:getLevel(k))[type]
        else
            data = data * self:_getSkillData(k,self:getLevel(k))[type]
        end
    end
    return data
end

---
-- 获取宝物技能的所有全局加成
-- @function [parent=#MagicModel] _cacheGlobalAddition
-- @param #MagicModel self
-- @param #number type
-- @return #number
function MagicModel:_cacheGlobalAddition()
    local data = {1} 
    for i= 2,6 do
        data[i] = self:getSkillAddtion(i) or 0
    end
    if data[3] == 0 then
        data[3] = 1
    end
    self._skillGlobalCache = data
end

---
-- 当宝物等级变化时，重新计算 宝物技能的全局加成
-- @function [parent=#MagicModel] _onMagicLevelUp
-- @param #MagicModel self
-- @param #string id
-- @param #number oldLevel
-- @param #number newLevel
function MagicModel:_onMagicLevelUp(id,oldLevel,newLevel)
    local index = self:getGroupIndex(id)
    local unlockLevel = GameConst.MGAIC_CONFIG_SKILL_LEVELS[index]
    if oldLevel < unlockLevel and newLevel >= unlockLevel then
        local config = GameConfig.MagicConfig:getData(id)
        local tmpType = config["sk".. index .."type"]
        local tmpValue = config["sk".. index .."value"]
        if tmpType == 3 then  -- 全局dps加成
            self._skillGlobalCache[tmpType] = self._skillGlobalCache[tmpType]*(1 + tmpValue/10000) 
            self:resetDPS()
            self:_raiseDataChangeEvent(0,ch.MagicModel.dataType.level)
        else
            self._skillGlobalCache[tmpType] = self._skillGlobalCache[tmpType] + tmpValue/10000 
        end
    end
end

---
-- 得到宝物团体技能的位置
-- @function [parent=#MagicModel] getGroupIndex
-- @param #MagicModel self
-- @param #string id
-- @return #number
function MagicModel:getGroupIndex(id)
    local count = table.maxn(GameConst.MGAIC_CONFIG_SKILL_LEVELS)
    local config = GameConfig.MagicConfig:getData(id)
    for i = 1,count do
        local str1 = string.format("sk%dtype",i)
        local type =  config[str1] or GameConst.MGAIC_CONFIG_SKILL_DEFAULT_TYPE
        if type ~= 1 then
            return i
        end
    end
    return 1
end

---
-- 重置全部宝物的dps之和缓存数据
-- @function [parent=#MagicModel] resetTotalDPS
-- @param #MagicModel self
function MagicModel:resetTotalDPS()
    self._totalDpsCache = nil
    self._totalDpsWithoutBuffCache = nil
end

---
-- 重置宝物的dps缓存数据,如果id为空则全部重置
-- @function [parent=#MagicModel] resetDPS
-- @param #MagicModel self
-- @param #string id
function MagicModel:resetDPS(id)
    if id then
        self._dpsCache[id] = nil
    else
        self._dpsCache = {}
    end
    self._totalDpsCache = nil
    self._totalDpsWithoutBuffCache = nil
end

---
-- 计算宝物的技能加成效果
-- @function [parent=#MagicModel] _calculateSkillEffect
-- @param #MagicModel self
-- @param #string id 宝物id
-- @param #number level 宝物等级
-- @return #table {1=,2=,3=,4=,5=,6=} 
function MagicModel:_calculateSkillEffect(id,level)
    id = tostring(id)
    local skill = {1,0,1,0,0,0}
    local count = table.maxn(GameConst.MGAIC_CONFIG_SKILL_LEVELS)
    local config = GameConfig.MagicConfig:getData(id)
    for i = 1,count do
        if level >= GameConst.MGAIC_CONFIG_SKILL_LEVELS[i] then
            local str1 = string.format("sk%dtype",i)
            local str2 = string.format("sk%dvalue",i)
            local type =  config[str1] or GameConst.MGAIC_CONFIG_SKILL_DEFAULT_TYPE
            local value = config[str2] or 0
            if type == 1 or type == 3 then
                skill[type] = skill[type] * (1 + value/10000)
            else
                skill[type] = skill[type] + value/10000
            end
        end
    end
    local preCount = nil
    for k,v in ipairs(GameConst.MGAIC_AUTO_ADD_SKILL) do
        if level >= v.level then
            local n = math.floor((level - v.level)/ v.step) + 1
            local repeatCount = 0
            if preCount then
                for i = 1,preCount do
                    local num = GameConst.MGAIC_AUTO_ADD_SKILL[k-1].level + (i-1)*GameConst.MGAIC_AUTO_ADD_SKILL[k-1].step
                    if (num - v.level)%v.step == 0 then
                        repeatCount = repeatCount + 1
                    end
                end
            end
            preCount = n
            skill[1] = skill[1] * (ch.LongDouble:pow(1+v.skValue/100,n - repeatCount))
        end
    end
    return skill
end

---
-- 获取宝物在该等级下的技能加成数据
-- @function [parent=#MagicModel] _getSkillData
-- @param #MagicModel self
-- @param #string id
-- @param #number level
-- @return #table 宝物技能加成数据{0,0,0,0,0,0}
function MagicModel:_getSkillData(id,level)
    id = tostring(id)
    if self._skillCache[id] == nil then self._skillCache[id] = {} end
    if self._skillCache[id][level] == nil then
        self._skillCache[id][level] = self:_calculateSkillEffect(id,level)
    end
    return self._skillCache[id][level]
end

---
-- 缓存所有的宝物技能加成
-- @function [parent=#MagicModel] _cacheAllSkillData
-- @param #MagicModel self
function MagicModel:_cacheAllSkillData()
    self._skillCache = {}
    if self._data then
        for k,v in pairs(self._data) do
            self:_cacheSkillData(k,self:getLevel(k))
        end
    end
end

---
-- 缓存宝物在当前等级，一级+1和+100的技能加成数据
-- @function [parent=#MagicModel] _cacheSkillData
-- @param #MagicModel self
-- @param #string id
-- @param #number level
function MagicModel:_cacheSkillData(id,level)
    id = tostring(id)
    if self._skillCache[id] == nil then 
        self._skillCache[id] = {} 
    else
        for k,v in pairs(self._skillCache[id]) do
            if k < level then
                self._skillCache[id][k] = nil
            end
        end
    end
    if self._skillCache[id][level] == nil then
        self._skillCache[id][level] = self:_calculateSkillEffect(id,level)
    end
    local newLevel = level + 1
    if self._skillCache[id][newLevel] == nil then
        self._skillCache[id][newLevel] = self:_calculateSkillEffect(id,newLevel)
    end
    newLevel = level + 10
    if self._skillCache[id][newLevel] == nil then        
        self._skillCache[id][newLevel] = self:_calculateSkillEffect(id,newLevel)
    end
end

---
-- 排序宝物，按顺序显示 
-- @function [parent=#MagicModel] _orderMagic
-- @param #MagicModel self
function MagicModel:_orderMagic()
    local cs = GameConfig.MagicConfig:getTable()
    local magics = {}
    for k,v in pairs(cs) do
        table.insert(magics,{id = k,price = v.price})
    end
    table.sort(magics,function(t1,t2)
        if tonumber(t1.price) < tonumber(t2.price) then
            return true
        elseif tonumber(t1.price) == tonumber(t2.price) and t1.id < t2.id then
            return true
        end
    end)
    self._margicOrderData = {}
    for k,v in ipairs(magics) do
        table.insert(self._margicOrderData,v.id)
    end
end

---
-- 获取宝物在该等级下应该显示的技能1
-- @function [parent=#MagicModel] _getCurSkill
-- @param #MagicModel self
-- @param #string id
-- @return #index 第几个技能
function MagicModel:_getCurSkill(id)
    id = tostring(id)
    for k = 1,table.maxn(GameConst.MGAIC_CONFIG_SKILL_LEVELS) do
        if GameConst.MGAIC_CONFIG_SKILL_LEVELS[k] > self:getLevel(id) then 
            return k
        end
    end
    local tmpLevel = GameConst.MGAIC_AUTO_ADD_SKILL[1].level
    local tmpStep = GameConst.MGAIC_AUTO_ADD_SKILL[1].step
    if (self:getAutoSkillUnlockLevel(id)-tmpLevel)%tmpStep == 0 then 
        return GameConst.MGAIC_AUTO_ADD_SKILL_INDEX1
    else
        return GameConst.MGAIC_AUTO_ADD_SKILL_INDEX2
    end
end

---
-- 宝物技能解锁等级
-- @function [parent=#MagicModel] getAutoSkillUnlockLevel
-- @param #MagicModel self
-- @return #number
function MagicModel:getAutoSkillUnlockLevel(id)
    local unLocklevel = nil
    for k,v in ipairs(GameConst.MGAIC_AUTO_ADD_SKILL) do
        local level = self:getLevel(id)
        if level >= v.level then
            local count = math.floor((level - v.level)/v.step)
            local l = v.level + v.step * (count + 1)
            if unLocklevel then
                if unLocklevel > l then
                    unLocklevel = l
                end
            else
                unLocklevel = l
            end
        end
    end
    if unLocklevel then
        return unLocklevel
    else
        local max = table.maxn(GameConst.MGAIC_AUTO_ADD_SKILL)
        return GameConst.MGAIC_AUTO_ADD_SKILL[max].level
    end
end
---
-- 宝物技能2解锁等级
-- @function [parent=#MagicModel] getUnlockLevel
-- @param #MagicModel self
-- @return #number
function MagicModel:getUnlockLevel(id)
    if self:_getCurSkill(id)~=GameConst.MGAIC_AUTO_ADD_SKILL_INDEX1 and self:_getCurSkill(id)~=GameConst.MGAIC_AUTO_ADD_SKILL_INDEX2 then
        return GameConst.MGAIC_CONFIG_SKILL_LEVELS[self:_getCurSkill(id)]
    else
        return self:getAutoSkillUnlockLevel(id)
    end
end

---
-- 宝物技能1解锁图标
-- @function [parent=#MagicModel] getSkillIcon1
-- @param #MagicModel self
-- @return #number
function MagicModel:getSkillIcon1(id)
    local config = GameConfig.MagicConfig:getData(id)
    local level1 = GameConst.MGAIC_AUTO_ADD_SKILL[1].level
    local level2 = GameConst.MGAIC_AUTO_ADD_SKILL[2].level
    local step1 = GameConst.MGAIC_AUTO_ADD_SKILL[1].step
    local step2 = GameConst.MGAIC_AUTO_ADD_SKILL[2].step  
    local index = self:_getCurSkill(id)-1
    if index == 0 then
        index = 1
    elseif index == -2 then
        if self:getLevel(id) < level2 then
            index = table.maxn(GameConst.MGAIC_CONFIG_SKILL_LEVELS)
        elseif (self:getUnlockLevel(id)-level1)%step1 == step2 then
            index = -2
        else
            index = -1
        end
    elseif index == -3 then
        index = -1
    end
    local skillType = 1
    local value = 0
    if index == -1 then
        skillType = table.maxn(GameConst.SKILL_ICON)-1
    elseif index == -2 then
        skillType = table.maxn(GameConst.SKILL_ICON)
    else
        skillType = config["sk".. index .."type"]
        value = config["sk".. index .."value"]/100
    end
    return self:getSkillIconByType(skillType,value)
end

---
-- 宝物技能2解锁图标
-- @function [parent=#MagicModel] getUnlockIcon
-- @param #MagicModel self
-- @return #number
function MagicModel:getUnlockIcon(id)
    local config = GameConfig.MagicConfig:getData(id)
    local index = ch.MagicModel:_getCurSkill(id)
    local skillType = 1
    local value = 0
    if index == GameConst.MGAIC_AUTO_ADD_SKILL_INDEX2 then
        skillType = table.maxn(GameConst.SKILL_ICON)-1
    elseif index == GameConst.MGAIC_AUTO_ADD_SKILL_INDEX1 then
        skillType = table.maxn(GameConst.SKILL_ICON)
    else
        skillType = config["sk".. index .."type"]
        value = config["sk".. index .."value"]/100
    end
    return self:getSkillIconByType(skillType,value)
end

---
-- 宝物技能1图标
-- @function [parent=#MagicModel] getSkillIconByType
-- @param #MagicModel self
-- @param #number skillType
-- @param #number value
-- @return #number
function MagicModel:getSkillIconByType(skillType,value)
    if skillType == 1 then
        return "aaui_card/baowuskill_1"..value..".png"
    else
        return GameConst.SKILL_ICON[skillType]
    end
end

---
-- 获取镀金转移到的宝物
-- @function [parent=#MagicModel] getRemoveMagic
-- @param #MagicModel self
-- @param #string id
function MagicModel:getRemoveMagic(id)
    math.randomseed(os_clock())
    id = tostring(id)
    local newId = id
    while newId == id do
    	local randNum = math.random(1,table.maxn(self._margicOrderData))
        newId = self._margicOrderData[randNum]
    end
    self._starRemoveId = newId
end

---
-- 获取随机镀金宝物ID(可能以后不用了)
-- @function [parent=#MagicModel] getRandMagicID
-- @param #MagicModel self
-- @return #string id
--function MagicModel:getRandMagicID()
--    math.randomseed(os_clock())
--    local randNum = math.random(1,table.maxn(self._margicOrderData))
--    local newId = self._margicOrderData[randNum]
--    return newId
--end

---
-- 获取随机镀金宝物ID
-- @function [parent=#MagicModel] getRandMagicID
-- @param #MagicModel self
-- @return #string id
function MagicModel:getRandMagicID()
    return self._starID or "0"
end

---
-- 设置镀金转移到的宝物ID
-- @function [parent=#MagicModel] setRemoveMagicID
-- @param #MagicModel self
-- @param #string id
function MagicModel:setRemoveMagicID(id)
    self._starRemoveId = id
end

---
-- 获取镀金转移到的宝物ID
-- @function [parent=#MagicModel] getRemoveMagicID
-- @param #MagicModel self
-- @return #string id
function MagicModel:getRemoveMagicID()
    return self._starRemoveId or "0"
end

---
-- 设置镀金的宝物ID列表
-- @function [parent=#MagicModel] setPlayGetList
-- @param #MagicModel self
-- @param #table list
function MagicModel:setPlayGetList(list)
    self._playGetList = {}
    for k,v in pairs(list) do
        table.insert(self._playGetList,v)
    end
    self:_raiseDataChangeEvent("0",self.dataType.playGet)
end

---
-- 获取镀金转移到的宝物ID
-- @function [parent=#MagicModel] getPlayGetList
-- @param #MagicModel self
-- @return #table
function MagicModel:getPlayGetList()
    return self._playGetList or {}
end

---
--  轮回
-- @function [parent=#MagicModel] onSamsara
-- @param #MagicModel self
function MagicModel:onSamsara()
    for k,v in pairs(self._data) do
        self._data[k].l = 0
    end
    self._dpsCache = {}
    self:_cacheAllSkillData()
    self:_cacheGlobalAddition()
    self._totalDpsCache = nil
    self._totalDpsWithoutBuffCache = nil
    self._data["1"].l = 1
end

return MagicModel