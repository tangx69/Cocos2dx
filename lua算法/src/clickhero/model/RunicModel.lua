---
-- 符文 model层     结构 {l = 0}
--@module RunicModel
local RunicModel = {
    _data = nil,
    _orderData = nil,
    _autoSkillAddtionData = nil, -- 满25级加成的
    _skillEffectData = nil,
    _skillForbidden = nil,       -- 清除当前的技能效果
    _samsaraData = nil,
    dataChangeEventType = "RUNIC_MODEL_DATA_CHANGE", --{type =,}
    SkillCDProgressChangedEventType = "SKILL_COOL_DOWN_CHANGED", --{type =,id =,leftTime=}
    SkillCDStatusChangedEventType = "SKILL_COOL_DOWN_STATUS_CHANGED", --{type =,id =,statusType=,}
    SkillDurationProgressChangedEventType = "SKILL_DURATION_PROGRESS_CHANGED", --{type =,id =,lefTime=}
    SkillDurationStatusChangedEventType = "SKILL_DURATION_STATUS_CHANGED" , --{type =,id =,statusType=}
    StatusType = {
        began = 1,
        ended = 2,
    },
    skillId = {
        zhudongchuji = 1,
        shuangchongdaji = 2,
        xingyunzhiguang = 3,
        huangjinjijie =4,
        qianshouzhili = 5,
        kuaidaxuanfeng = 6,
        wujinzhuansheng = 7
    }
}

ENCODE_NUM = ENCODE_NUM or function(num)
    return num
end

DECODE_NUM = DECODE_NUM or function(num)
    return num
end

function RunicModel:_raiseDurtionStatusChangedEvent(id,status)
    local evt = {type = self.SkillDurationStatusChangedEventType}
    evt.id = id
    evt.statusType = status
    if tonumber(id) == ch.RunicModel.skillId.shuangchongdaji then   --宝物技能，重置缓存
        ch.MagicModel:resetTotalDPS()
    end
    zzy.EventManager:dispatch(evt)
end

function RunicModel:_raiseDurtionProgressChangedEvent(id,leftTime)
    local evt = {type = self.SkillDurationProgressChangedEventType}
    evt.id = id
    evt.leftTime = leftTime
    zzy.EventManager:dispatch(evt)
end

function RunicModel:_raiseCDStatusChangedEvent(id,status)
    local evt = {type = self.SkillCDStatusChangedEventType}
    evt.id = id
    evt.statusType = status
    zzy.EventManager:dispatch(evt)
end

function RunicModel:_raiseCDProgressChangedEvent(id,leftTime)
    local evt = {type = self.SkillCDProgressChangedEventType}
    evt.id = id
    evt.leftTime = leftTime
    zzy.EventManager:dispatch(evt)
end

---
-- @function [parent=#RunicModel] init
-- @param #RunicModel self
-- @param #table data
function RunicModel:init(data)
    self._data = data.runic
    self:_orderRunic()
    self._autoSkillAddtionData = {}
    self._skillEffectData = {0,0,0,0,0,0}
    self._skillForbidden = {}
    self:_initSkillEffect()
    self._samsaraData = {}
    
    self._data.l = ENCODE_NUM(self._data.l)
end

---
-- @function [parent=#RunicModel] clean
-- @param #RunicModel self
function RunicModel:clean()
    self._data = nil
    self._orderData = nil
    self._autoSkillAddtionData = nil
    self._skillEffectData = nil
    self._skillForbidden = nil
    self._samsaraData = nil
end

function RunicModel:_raiseDataChangeEvent(num)
    local evt = {
        type = self.dataChangeEventType,
        value = num or 0
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 获取符文等级
-- @function [parent=#RunicModel] getLevel
-- @param #RunicModel self
-- @return #number
function RunicModel:getLevel()
	return DECODE_NUM(self._data.l) or 0
end

---
-- 设置符文等级
-- @function [parent=#RunicModel] setLevel
-- @param #RunicModel self
-- @param #RunicModel level
function RunicModel:setLevel(level)
    local old = self:getLevel()
    if old ~= level then
        self._data.l = level
        self._data.l = ENCODE_NUM(self._data.l)
        
        self:_raiseDataChangeEvent()
    end
end

---
-- 添加符文等级，默认为1
-- @function [parent=#RunicModel] addLevel
-- @param #RunicModel self
-- @param #RunicModel level
function RunicModel:addLevel(level)
    level = level or 1
    if level ~= 0 then
        self._data.l = self:getLevel() + level
        self._data.l = ENCODE_NUM(self._data.l)
        self:_raiseDataChangeEvent(level)
    end
end

---
-- 获取符文的基础dps
-- @function [parent=#RunicModel] getBaseDPS
-- @param #RunicModel self
-- @param #number level 在某一级别的dps
-- @return #number
function RunicModel:getBaseDPS(level)
    level = level or self:getLevel()
    -- 基本伤害
    local harm = level * GameConst.RUNIC_STEP_HARM_DATA
    -- 自动技能加成
    harm = harm *self:_getAutoSkillAddtion(level) -- 自动加成是个longdouble
    local ratio = 1
    -- 英雄之魂
    ratio = ratio *(1 + ch.StatisticsModel:getSoulRatio(ch.MoneyModel:getSoul()))
    -- 宝物技能的全局加成
    ratio = ratio *ch.MagicModel:getGlobalDPSAddition()
    --成就之积
    ratio = ratio*ch.AchievementModel:getRewardData(GameConst.ACHIEVEMENT_REWARD_ATTACK)
    --力量源泉未加
    ratio = ratio*ch.TaskModel:getCurPowerRatio()
    -- 不良小魔王
    ratio = ratio * (1 + ch.PartnerModel:getUpNum(1))
    -- 宠物转生
    ratio = ratio * (1 + ch.PartnerModel:getGjjc())
    harm = harm *ratio
    harm = GameConst.RUNIC_BASE_HARM_DATA + harm
    return harm
end

---
-- 获取符文的实际dps
-- @function [parent=#RunicModel] getDPS
-- @param #RunicModel self
-- @param #number level 在某一级别的dps
-- @return #number
function RunicModel:getDPS(level)
    level = level or self:getLevel()
    local harm = self:getBaseDPS(level)
    --成就之和
    harm = harm + ch.AchievementModel:getRewardData(GameConst.ACHIEVEMENT_REWARD_BASE)
    -- buff
    harm = harm * (1 + ch.BuffModel:getRunicAddtion())
    -- 宝物攻击力转化 
    harm = harm + self:getMDPSRate()* ch.MagicModel:getTotalDPS()
    -- 主动技能加成
    harm = harm * (1 + self:getSkillEffect(self.skillId.qianshouzhili))
    -- 卡牌总战力加成(先不加)
--    harm = harm * ch.PetCardModel:getAllPowerDPS()
    return  ch.LongDouble:floor(harm)
end

---
-- 获取符文在无尽征途的dps
-- @function [parent=#RunicModel] getWarpathDPS
-- @param #RunicModel self
-- @return #number
function RunicModel:getWarpathDPS()
    local harm = ch.MagicModel:getWarpathTotalDPS() * (0.03 + ch.TotemModel:getTotemSkillData(1,8))
    return ch.LongDouble:floor(harm)
end

---
-- 获取不含buff和主动技能的符文的dps
-- @function [parent=#RunicModel] getDPSWithoutBuff
-- @param #RunicModel self
-- @param #number level 在某一级别的dps
-- @return #number
function RunicModel:getDPSWithoutBuff(level)
    level = level or self:getLevel()
    local harm = self:getBaseDPS(level)
    -- 宝物攻击力转化 
    harm = harm + self:getMDPSRate()* ch.MagicModel:getTotalDPS()
    --成就之和
    harm = harm + ch.AchievementModel:getRewardData(GameConst.ACHIEVEMENT_REWARD_BASE)
    -- 卡牌总战力加成
--    harm = harm * ch.PetCardModel:getAllPowerDPS()
    return ch.LongDouble:floor(harm)
end

---
-- 获取主动技能的效果
-- @function [parent=#RunicModel] getSkillEffect
-- @param #RunicModel self
-- @param #number id
-- @return #number
function RunicModel:getSkillEffect(id)
	return self._skillEffectData[id]
end

---
-- 使用技能
-- @function [parent=#RunicModel] useSkill
-- @param #RunicModel self
-- @param #number id
-- @return #number
function RunicModel:useSkill(id)
    id = tonumber(id)
    if self:getSkillCD(id) ~= -1 then return end
    self._skillForbidden[id] = nil
    self:setSkillUsedTime(id,os_time())
    self:_raiseSkillEffect(id)
end

---
-- 获取技能的上次使用时间
-- @function [parent=#RunicModel] getUsedTime
-- @param #RunicModel self
-- @param #number id
-- @return #number
function RunicModel:getUsedTime(id)
    return self._data.s[id] or 0
end

---
-- 设置技能的上次使用时间
-- @function [parent=#RunicModel] setSkillUsedTime
-- @param #RunicModel self
-- @param #number id
-- @param #number time
function RunicModel:setSkillUsedTime(id,time)
    self._data.s[id] = time
end

---
-- 获取技能的总共冷却时间
-- @function [parent=#RunicModel] getSkillTotalCD
-- @param #RunicModel self
-- @param #number id
-- @return #number
function RunicModel:getSkillTotalCD(id)
    id = tonumber(id)
    local config = GameConfig.SkillConfig:getData(id)
    local cd = config.cd
    local totemAdd = ch.TotemModel:getTotemSkillData(5,id) or 0 --图腾
    cd = cd*(1-totemAdd) * (1-ch.PartnerModel:getUpNum(3))  -- 宠物附加属性
    return math.floor(cd)
end

---
-- 获取技能的剩余冷却时间，-1表示技能已冷却完毕
-- @function [parent=#RunicModel] getSkillCD
-- @param #RunicModel self
-- @param #number id
-- @return #number
function RunicModel:getSkillCD(id)
    local time = os_time() - self:getUsedTime(id)
    local totalCd = self:getSkillTotalCD(id)
    if time > totalCd then
        return -1
    else
        return totalCd - time
    end
end

---
-- 技能是否处于CD中
-- @function [parent=#RunicModel] ifSkillCD
-- @param #RunicModel self
-- @param #number id
-- @return #boolean
function RunicModel:ifSkillCD(id)
    local ifSkillCD = false
    local time = os_time() - self:getUsedTime(id)
    local totalCd = self:getSkillTotalCD(id)
    if time > totalCd then --冷却时间结束
        ifSkillCD = false
    elseif self:getSkillDuration(id) ~= -1 then --在持续释放技能中
        ifSkillCD = false
    else
        ifSkillCD = true --在冷却中
    end
    return ifSkillCD
end

---
-- 是否有技能处于CD中
-- @function [parent=#RunicModel] haveSkillCD
-- @param #RunicModel self
-- @return #boolean
function RunicModel:haveSkillCD()
    local haveSkillCD = false
    local ids = GameConfig.SkillConfig:getTable()
    for k,v in pairs(ids) do
        if self:ifSkillCD(k) then
            haveSkillCD = true
            cclog("技能id："..k.."    ".. tostring(haveSkillCD))
            break
        end
    end
    return haveSkillCD
end

---
-- 清除所有技能CD(不包括正在释放的技能)
-- @function [parent=#RunicModel] clearAllSkillCD
-- @param #RunicModel self
function RunicModel:clearAllSkillCD()
    for _,id in pairs(self.skillId) do
        if self:ifSkillCD(id) then
            self:clearSkillCD(id)
        end
    end
end

---
-- 清除某个技能CD
-- @function [parent=#RunicModel] clearSkillCD
-- @param #RunicModel self
-- @param #number id
function RunicModel:clearSkillCD(id)
    if self:ifSkillCD(id) then
        self:setSkillUsedTime(id,os_time() - self:getSkillTotalCD(id))
        self:_raiseSkillEffect(id)
    end
end

---
-- 清除技能效果
-- @function [parent=#RunicModel] clearSkillEffect
-- @param #RunicModel self
-- @param #number id
function RunicModel:clearSkillEffect(id)
    if self:getSkillDuration(id) < 0 then return end
    self._skillForbidden[id] = true
end

---
-- 清除所有技能效果
-- @function [parent=#RunicModel] clearAllSkillEffect
-- @param #RunicModel self
function RunicModel:clearAllSkillEffect()
    for _,id in pairs(self.skillId) do
        self:clearSkillEffect(id)
    end
end

---
-- 获取技能的总共持续时间
-- @function [parent=#RunicModel] getSkillTotalDuration
-- @param #RunicModel self
-- @param #number id
-- @return #number
function RunicModel:getSkillTotalDuration(id)
    id = tonumber(id)
    local config = GameConfig.SkillConfig:getData(id)
    local duration = config.duration
    local totemAdd = ch.TotemModel:getTotemSkillData(4,id) or 0
    duration = duration + totemAdd
    return math.floor(duration)
end

---
-- 获取技能的剩余持续时间，-1表示技能已使用完毕
-- @function [parent=#RunicModel] getSkillDuration
-- @param #RunicModel self
-- @param #number id
-- @return #number
function RunicModel:getSkillDuration(id)
    if self._skillForbidden[id] then return -1 end
    local time = os_time() - self:getUsedTime(id)
    local totalDuration = self:getSkillTotalDuration(id)
    if time > totalDuration then
        return -1
    else
        return totalDuration - time
    end
end

---
-- 初始化技能效果
-- @function [parent=#RunicModel] _initSkillEffect
-- @param #RunicModel self
function RunicModel:_initSkillEffect()
    for k,v in pairs(GameConfig.SkillConfig:getTable()) do
        if v.id ~= 7 then
            if self:getSkillCD(v.id) ~= -1 then
                self:_raiseSkillEffect(v.id)
            end
        end
    end
end

---
-- 使用技能后的效果处理
-- @function [parent=#RunicModel] _raiseSkillEffect
-- @param #RunicModel self
function RunicModel:_raiseSkillEffect(id)
    self:_raiseCDProgressChangedEvent(id,self:getSkillCD(id))
    self:_raiseCDStatusChangedEvent(id,self.StatusType.began)
    local isDurationEnded = self:getSkillDuration(id) == -1
    if not isDurationEnded then
        local value = GameConfig.SkillConfig:getData(id).value/10000
        local totemEffect = ch.TotemModel:getTotemSkillData(6,id) or 0
        value = value + totemEffect
        self._skillEffectData[id] = value
        self:_raiseDurtionProgressChangedEvent(id,self:getSkillDuration(id))
        self:_raiseDurtionStatusChangedEvent(id,self.StatusType.began)
    end    
    local scheduleId = nil
    scheduleId = zzy.EventManager:listen(zzy.Events.TickEventType,function()
        if not isDurationEnded then
            local leftTime = self:getSkillDuration(id)
            if leftTime >= 0 then
                self:_raiseDurtionProgressChangedEvent(id,leftTime)
            else
                isDurationEnded = true
                self._skillEffectData[id] = 0
                self:_raiseDurtionStatusChangedEvent(id,self.StatusType.ended)
            end
        end
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
-- 获取宝物dps转化为符文的实际转化率(包含图腾)
-- @function [parent=#RunicModel] getMDPSRate
-- @param #RunicModel self
-- @return #number
function RunicModel:getMDPSRate()
    local rate = ch.MagicModel:getMToRRate()
    rate = rate + ch.TotemModel:getTotemSkillData(1,8)
    return rate
end

---
-- 获取符文的暴击率
-- @function [parent=#RunicModel] getCritRate
-- @param #RunicModel self
-- @return #number
function RunicModel:getCritRate()
    local rate = ch.MagicModel:getMToRCritsRate()     -- 宝物产生的加成
    rate = rate + ch.TotemModel:getTotemSkillData(1,10) -- 图腾加成
    rate = rate + self:getSkillEffect(self.skillId.xingyunzhiguang) -- 主动技能加成
    return rate
end

---
-- 获取符文的暴击倍数
-- @function [parent=#RunicModel] getCritTimes
-- @param #RunicModel self
-- @return #number
function RunicModel:getCritTimes()
    local times = GameConst.RUNIC_CRIT_TIMES
    times = times + ch.MagicModel:getMToRCHarmTimes()
    times = times + ch.TotemModel:getTotemSkillData(1,11)
    return times
end

---
-- 获取宠物在该等级下应该显示的技能
-- @function [parent=#RunicModel] _getCurSkill
-- @param #RunicModel self
-- @return #index 第几个技能
function RunicModel:_getCurSkill()
    for k = 1,table.maxn(GameConst.RUNIC_CONFIG_SKILL_LEVELS) do
        if GameConst.RUNIC_CONFIG_SKILL_LEVELS[k] > self:getLevel() then 
            return k
        end
    end
    local tmpLevel = GameConst.RUNIC_AUTO_ADD_SKILL[1].level
    local tmpStep = GameConst.RUNIC_AUTO_ADD_SKILL[1].step
    if (self:getAutoSkillUnlockLevel()-tmpLevel)%tmpStep == 0 then 
        return GameConst.RUNIC_AUTO_ADD_SKILL_INDEX1
    else
        return GameConst.RUNIC_AUTO_ADD_SKILL_INDEX2
    end
end

---
-- 宠物技能解锁等级
-- @function [parent=#RunicModel] getUnlockLevel
-- @param #RunicModel self
-- @return #number
function RunicModel:getUnlockLevel()
    if self:_getCurSkill()~=GameConst.MGAIC_AUTO_ADD_SKILL_INDEX1 and self:_getCurSkill()~=GameConst.MGAIC_AUTO_ADD_SKILL_INDEX2 then
        return GameConst.RUNIC_CONFIG_SKILL_LEVELS[self:_getCurSkill()]
    else
        return self:getAutoSkillUnlockLevel()
    end
end

---
-- 宠物技能解锁图标
-- @function [parent=#RunicModel] getUnlockIcon
-- @param #RunicModel self
-- @return #number
function RunicModel:getUnlockIcon()
    local index = ch.RunicModel:_getCurSkill()
    if index == GameConst.RUNIC_AUTO_ADD_SKILL_INDEX2 then
        return GameConst.RUNIC_SKILL_ICON[table.maxn(GameConst.RUNIC_SKILL_ICON)-1]
    elseif index == GameConst.RUNIC_AUTO_ADD_SKILL_INDEX1 then
        return GameConst.RUNIC_SKILL_ICON[table.maxn(GameConst.RUNIC_SKILL_ICON)]
    else
        --后来修改
        local skillType = GameConst.RUNIC_CONFIG_SKILL_RATIO[index]
        return GameConst.RUNIC_SKILL_ICON[skillType]
    end
end


---
-- 宠物技能1解锁图标
-- @function [parent=#RunicModel] getSkillIcon1
-- @param #RunicModel self
-- @return #number
function RunicModel:getSkillIcon1()
    local level1 = GameConst.RUNIC_AUTO_ADD_SKILL[1].level--1000
    local level2 = GameConst.RUNIC_AUTO_ADD_SKILL[2].level--200
    local step1 = GameConst.RUNIC_AUTO_ADD_SKILL[1].step--1000
    local step2 = GameConst.RUNIC_AUTO_ADD_SKILL[2].step--25
    local index = self:_getCurSkill()-1
    if index == 0 then
        index = 1
    elseif index == -2 then
        if self:getLevel() < level2 then
            index = table.maxn(GameConst.RUNIC_CONFIG_SKILL_LEVELS)
        elseif (self:getUnlockLevel()-level1)%step1 == step2 then
            index = -2
        else
            index = -1
        end
    end
    local skillType = 1
    if index == -1 then
        skillType = table.maxn(GameConst.RUNIC_SKILL_ICON)-1
    elseif index == -2 then
        skillType = table.maxn(GameConst.RUNIC_SKILL_ICON)
    else
        skillType = GameConst.RUNIC_CONFIG_SKILL_RATIO[index]
    end
    return GameConst.RUNIC_SKILL_ICON[skillType]
end

---
-- 获取自动技能的加成数据
-- @function [parent=#RunicModel] _getAutoSkillAddtion
-- @param #RunicModel self
-- @param #number level 
-- @return #number
function RunicModel:_getAutoSkillAddtion(level)
    if not self._autoSkillAddtionData[level] then
        local times = 1
        -- 200级之前的加成
        local count = table.maxn(GameConst.RUNIC_CONFIG_SKILL_LEVELS)
        for i = 1,count do
            if level >= GameConst.RUNIC_CONFIG_SKILL_LEVELS[i] then
                -- 后来更改
                local tmp = GameConst.RUNIC_CONFIG_SKILL_RATIO[i]
                local value = GameConst.RUNIC_CONFIG_SKILL_TYPE[tmp]
                times = times * (1 + value)
            end
        end
        local preCount = nil
        for k,v in ipairs(GameConst.RUNIC_AUTO_ADD_SKILL) do
            if level >= v.level then
                local n =  math.floor((level - v.level)/ v.step) + 1
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
                times = times * (ch.LongDouble:pow(1 + v.skValue/100,n - repeatCount))
            end
        end
        self._autoSkillAddtionData[level] = times
    end
    return self._autoSkillAddtionData[level]
end

---
-- 获取符文的自动技能解锁等级
-- @function [parent=#RunicModel] getAutoSkillUnlockLevel
-- @param #RunicModel self
-- @return #number
function RunicModel:getAutoSkillUnlockLevel()
    local unLocklevel = nil
    for k,v in ipairs(GameConst.RUNIC_AUTO_ADD_SKILL) do
	   local level = self:getLevel()
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
        local max = table.maxn(GameConst.RUNIC_AUTO_ADD_SKILL)
        return GameConst.RUNIC_AUTO_ADD_SKILL[max].level
    end
end

---
-- 获取升级符文需要的金钱
-- @function [parent=#RunicModel] getCostLevelUp
-- @param #RunicModel self
-- @param #number addLevel 要升的等级数
-- @return #number
function RunicModel:getCostLevelUp(addLevel)
    addLevel = addLevel or 1
    local level = self:getLevel()
    local levelEnd = level + addLevel
    local gold,totalGold = 0,0
    local ratio = 1 + GameConst.MGAIC_UPLEVEL_COST_MONEY_RATIO    
    if level < 15 then
        local eLevel = levelEnd < 15 and levelEnd or 15
        while level < eLevel do
            gold = level + 5
            gold = gold * ch.LongDouble:pow(ratio,level) 
            totalGold = totalGold + ch.LongDouble:floor(gold)
            level = level +1  
        end
    end
    if levelEnd >= 15 then
        local a1 = 20*ch.LongDouble:pow(ratio,level) 
        local s = a1*(1-ch.LongDouble:pow(ratio,levelEnd - level))/(1- ratio)
        totalGold = totalGold + ch.LongDouble:floor(s)
    end
    
    totalGold = totalGold *(1-ch.TotemModel:getTotemSkillData(3,1))
    return ch.LongDouble:ceil(totalGold)
end

---
-- 获得排好序的符文列表 
-- @function [parent=#RunicModel] _orderRunic
-- @param #RunicModel self
-- @return #table 
function RunicModel:getOrderRunics()
    return self._orderData
end

---
-- 排序符文，按顺序显示 
-- @function [parent=#RunicModel] _orderRunic
-- @param #RunicModel self
function RunicModel:_orderRunic()
    local cs = GameConfig.SkillConfig:getTable()
    local runics = {}
    for k,v in pairs(cs) do
        table.insert(runics,{id = k,unlocklv = v.unlocklv})
    end
    table.sort(runics,function(t1,t2)
        if t1.unlocklv < t2.unlocklv then
            return true
        elseif t1.unlocklv == t2.unlocklv and t1.id < t2.id then
            return true
        end
    end)
    self._orderData = {}
    for k,v in ipairs(runics) do
        table.insert(self._orderData,v.id)
    end
end

---
-- 获得主动技的解锁等级 
-- @function [parent=#RunicModel] getActiveSkillUnlockLv
-- @param #RunicModel self
-- @param #number id
-- @return #number 
function RunicModel:getActiveSkillUnlockLv(id)
    if id == 7 then
--        return GameConfig.SkillConfig:getData(id).unlocklv+ch.StatisticsModel:getRTimes()*GameConst.RUNIC_SAMSARA_STEPLV
        local level = GameConst.RUNIC_SAMSARA_LEVEL_MIN+ch.StatisticsModel:getRTimes()*GameConst.RUNIC_SAMSARA_STEPLV
        if level > GameConst.RUNIC_SAMSARA_LEVEL_MAX then
            level = GameConst.RUNIC_SAMSARA_LEVEL_MAX
        end
        return level
    else
        return GameConfig.SkillConfig:getData(id).unlocklv
    end
end

---
-- 转生相关数据
-- @function [parent=#RunicModel] setSamsaraData
-- @param #RunicModel self
-- @param #table data
function RunicModel:setSamsaraData(data)
    self._samsaraData = data
end

---
-- 转生相关数据
-- @function [parent=#RunicModel] getSamsaraData
-- @param #RunicModel self
-- @return #table
function RunicModel:getSamsaraData()
    return self._samsaraData or {}
end

---
-- 关于轮回
-- @function [parent=#RunicModel] onSamsara
-- @param #RunicModel self
function RunicModel:onSamsara()
    self._data.l = 1
    self._data.s = {}
    self._autoSkillAddtionData = {}
    self._skillEffectData = {0,0,0,0,0,0}
    self:_raiseDataChangeEvent()
end

return RunicModel