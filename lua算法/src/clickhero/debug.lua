zzy.DebugManager:addClientDebugCommond("test", "测试命令", function()
    cclog("test")
end)

zzy.DebugManager:addClientDebugCommond("addGoldBOSS","添加黄金魂石大魔王1为黄金2为魂石,示例 addGoldBOSS|id=1", function(data)
    data = zzy.StringUtils:splitToTable(data)
    ch.flyBox:setDebugType(data.id)
end)

zzy.DebugManager:addClientSyncCommond("money", function(data)
    if type(data.num) == "string" then
        data.num = ch.LongDouble:toLongDouble(data.num)
    end
    ch.MoneyModel:addMoney(data.id,data.num)
end)

zzy.DebugManager:addClientSyncCommond("addcard", function(data)
    ch.PetCardModel:addChipByChipId(tostring(data.id),data.num)
end)

zzy.DebugManager:addClientSyncCommond("addpet", function(data)
    ch.PartnerModel:getOne(tostring(data.id))
end)

zzy.DebugManager:addClientSyncCommond("offGold", function(data)
    cclog("离线金币："..ch.CommonFunc:getOffLineGold(data.time))
end)

zzy.DebugManager:addClientSyncCommond("addbuff", function(data)
    ch.BuffModel:addBuff(data.ty,data.tm)
end)

zzy.DebugManager:addClientSyncCommond("clearpower", function(data)
    local num = ch.PowerModel:getPower()
    ch.PowerModel:addPower(-num)
end)


--- 为了测试离线金币

local getOffLineGold = function(level) -- levelControll有真正金币掉落的计算公式，这里将其略微修改
    local life = ch.fightRoleLayer:getLevelMaxHP(level,true)
    local fix = 1
    local gold = 0
    if (level < 200) then
        fix = 0.3*math.pow(1.005,level)
    else
        fix = 0.3*math.pow(1.005,200)+(level-200)*0.005
    end
    gold = (life/15) * fix
    --    if (gold <level) then
    --        gold = level
    --    end
    gold = gold * (1 + ch.MagicModel:getMToMoneyAddition()) -- 宝物加成
    gold = gold * (1 + ch.TotemModel:getTotemSkillData(1,2)) -- 图腾加成
    if ch.BuffModel:getCardBuffTime()> 0 then
        gold = gold *(1 + GameConst.BUFF_EFFECT_VALUE[1][3])
    end
    return gold
end

local getRealOffLineGold = function(level)
    local gold = getOffLineGold(level)
    local chestChance = ch.fightRoleLayer:getChestProbability()
    local goldCritChance = ch.fightRoleLayer:getMoneyCritProbability()
    gold = gold *(1-chestChance) + 10*gold*chestChance* (1 + ch.TotemModel:getTotemSkillData(1,3))
    gold = gold*(1- goldCritChance) + goldCritChance*gold*10
    return gold
end


zzy.DebugManager:addClientSyncCommond("dpscheck", function(data)
    cclog("客户端：宝物总攻击力：%s",ch.NumberHelper:toString(ch.MagicModel:getTotalDPS()))
    cclog("客户端：宠物总攻击力：%s",ch.NumberHelper:toString(ch.RunicModel:getDPS()))
    cclog("客户端：宠物无buff无技能的攻击力：%s",ch.NumberHelper:toString(ch.RunicModel:getDPSWithoutBuff()))
    cclog("客户端：1秒的离线收益：%s",ch.NumberHelper:toString(ch.CommonFunc:getOffLineGold(1)))
    local level = ch.LevelModel:getCurLevel()
    cclog("客户端：当前关卡的npc血量：%s",ch.NumberHelper:toString(ch.fightRoleLayer:getLevelMaxHP(level,true)))
    cclog("客户端：1个怪物掉的钱：%s",ch.NumberHelper:toString(ch.fightRoleLayer:getGold(level,false)))
    cclog("客户端：魂的总加成(加了1)：%g",(1 + ch.StatisticsModel:getSoulRatio(ch.MoneyModel:getSoul())))
    local ratio = GameConst.MGAIC_STAR_RATIO + ch.TotemModel:getTotemSkillData(1,7)
    if ch.AltarModel:getAltarByType(3).level and ch.AltarModel:getAltarByType(3).level > 1 then
        ratio = ch.AltarModel:getFinalEffect(3)
    end
    cclog("客户端：单个镀金的加成(不加1)：%g",ratio)
    -- 离线详情
    cclog("////////////////离线的详情数据//////////////////////////////")
    local dps = (ch.MagicModel:getTotalDPS() - GameConst.MGAIC_CONFIG_BASE_HARM)/(1+ ch.RunicModel:getSkillEffect(ch.RunicModel.skillId.shuangchongdaji))
    dps = dps/(1 + ch.BuffModel:getMagicAddtion())
    if ch.BuffModel:getCardBuffTime()> 0 then
        dps = dps *(1 + GameConst.BUFF_EFFECT_VALUE[1][1])
    end
    -- 自动攻击的宠物
    local petDps = 0
    local petDps = ch.RunicModel:getBaseDPS(ch.RunicModel:getLevel())
    petDps = petDps + ch.RunicModel:getMDPSRate()* dps
    petDps = petDps + ch.AchievementModel:getRewardData(GameConst.ACHIEVEMENT_REWARD_BASE)
    petDps = petDps*ch.PartnerModel:getCurPartnerClickSpeed()
    dps = dps + petDps
    cclog("离线状态下，应计算的宝物攻击力：%s",ch.NumberHelper:toString(dps))
    
    local level = ch.LevelModel:getCurLevel()
    if level %5 == 0 then
        level = level -1 
    end
    cclog("离线状态下，1个怪物应该掉的钱：%s",ch.NumberHelper:toString(getOffLineGold(level)))
    cclog("离线状态下，修正暴击和宝箱应该掉的钱：%s",ch.NumberHelper:toString(getRealOffLineGold(level)))
end)

zzy.DebugManager:addClientSyncCommond("gkid", function(data)
    ch.LevelController:setLevel(data.id)
end)

