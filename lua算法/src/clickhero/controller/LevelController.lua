local goldCritTimes = 10 -- 金币暴击倍率

local levelController = {
    GO_NEXT_LEVEL = "LEVELC_GO_NEXT_LEVEL",
    GAME_MODE_CHANGE = "GAME_MODE_CHANGE",
    mode = nil,
    GameMode = {
        normal = 1,   -- 正常推关
        warpath = 2, -- 无尽征途 
        defend = 3,   -- 坚守阵地
        goldBoss = 4, -- 黄金大魔王
        AFK = 5, -- 挂机中
        sStoneBoss = 6, -- 魂石大魔王
        cardFight = 7,  -- 卡牌战斗
        guildWar = 8,   -- 公会战
    },
    _wStartTime = nil,
}

local state = 0  -- 0=初始化中 1=入场中 2=正常开打
local levelConfig
local refEnemyCount = 0
local timeId = nil
local addEnemyId =  {}
local goldBossTime = nil
local isInitialized = false

function levelController:getState()
    return state
end

-- 无尽征途活动开始时间
function levelController:wStartTime()
    return self._wStartTime
end

function levelController:debug()
    state = 2
end

function levelController:init(isNormal)
    isInitialized = true
    self.mode = self.GameMode.normal
    ch.fightRoleLayer:init()
    ch.clickLayer:init()
    ch.goldLayer:init()
    ch.fairyLayer:init()
    if isNormal == nil then isNormal = true end
    self:showLevel(false,isNormal)
    zzy.EventManager:listen(ch.fightRole.DEAD_EVENT_TYPE, function(obj, evt)
        if self.mode == self.GameMode.normal then
            self:deathOnNormal(evt)
        elseif self.mode == self.GameMode.warpath then
            self:deathOnWarpath(evt)
        elseif self.mode == self.GameMode.goldBoss then
            self:deathOnGoldBoss(evt)
        elseif self.mode == self.GameMode.sStoneBoss then
            self:deathOnSStoneBoss(evt)
        end
    end,1)
    if ch.AFKModel:getLastTargetLevel() and ch.AFKModel:getLastTargetLevel() > ch.LevelModel:getCurLevel() then
        self:startAFK()
    end
end

function levelController:deathOnWarpath(evt)
    state = 0
    local isCrit = math.random() < ch.fightRoleLayer:getMoneyCritProbability()
    local gold = ch.fightRoleLayer:getWarpathGold(ch.WarpathModel:getCurStage(),ch.WarpathModel:getCurIndex())
    if isCrit then
        gold = gold * goldCritTimes
    end
    ch.NetworkController:killedInWarpath(ch.WarpathModel:getCurIndex(),0,gold)
    self:dropMoneyInWarpath(evt.x,evt.y,gold,isCrit)
    ch.goldLayer:dropMoney(evt.x,evt.y, 3,6)
    local index = ch.WarpathModel:getCurIndex()
    ch.WarpathModel:AttackBoss(evt.harm,ch.LongDouble.zero)
    if ch.WarpathModel:getCurIndex() == GameConst.WARPATH_BOSS_MAX_COUNT and
        ch.WarpathModel:getCurHP() == ch.LongDouble.zero then --本阶段结束
        zzy.EventManager:dispatch({type = ch.fightRole.BOSS_PASS_EVENT_TYPE})
        self:openResultWarpath()
    else
        timeId = zzy.TimerUtils:setTimeOut(0.5,function()
            if self.mode == self.GameMode.warpath then
                state = 1
                ch.fightRoleLayer:addMainRole(ch.UserTitleModel:getAvatar(),ch.UserTitleModel:getWeapon())
                ch.fightRoleLayer:addWarpathRole()
                ch.fightBackground:lookTo(0)
                ch.fightBackground:playVictoryInWarpath(index,function()
                    state = 2
                end)
            end
            timeId = nil
        end)
    end
end

function levelController:deathOnNormal(evt)
    if ch.LevelModel:getCurLevel() ~= evt.level then return end
    if evt.roleType == ch.fightRole.roleType.chest then
        ch.StatisticsModel:addKilledBoxes(1)
    elseif evt.roleType == ch.fightRole.roleType.monster then
        ch.StatisticsModel:addKilledMonsters(1)
    elseif evt.roleType == ch.fightRole.roleType.boss then
        ch.StatisticsModel:addKilledBosses(1)
    end
    ch.LevelModel:addKilledCount()
    self:dropMoney(evt.roleType,evt.level,evt.x,evt.y)
    if levelConfig.type ~= 2 then
        local killedCount = ch.LevelModel:getTotalCount(ch.LevelModel:getCurLevel())
        if ch.LevelModel:getCurLevel() == ch.LevelModel:getMaxLevel() then
            if ch.LevelModel:getKilledCount() >= killedCount then
                ch.NetworkController:sendCacheData(1)--发送刚过去的关卡数据
                ch.PartnerModel:nextLevel()--计算宠物的属性加成
                ch.LevelModel:nextLevel()  -- 不要更改这三顺序
                timeId = zzy.TimerUtils:setTimeOut(0.5,function()
                    if self.mode == self.GameMode.normal then
                        self:goNextLevel()
                    end
                    timeId = nil
                end)
            elseif refEnemyCount < killedCount then
                refEnemyCount = refEnemyCount + 1
                ch.fightRoleLayer:addEnemyRole()
            end
        else
            ch.fightRoleLayer:addEnemyRole()
        end
    else
        if evt.roleType == ch.fightRole.roleType.boss then
            zzy.EventManager:dispatch({type = ch.fightRole.BOSS_PASS_EVENT_TYPE})
        end
        state = 0
        ch.NetworkController:sendCacheData(1)--发送刚过去的关卡数据
        ch.PartnerModel:nextLevel() --计算宠物的属性加成
        ch.LevelModel:nextLevel() --不要更改这三顺序
        self:dropSStone(evt.level, evt.x, evt.y)
        self:dropCard(evt.level, evt.x, evt.y)
        self:dropFirecraker(evt.level, evt.x, evt.y)
        self:dropConversionMoney(evt.level,evt.x,evt.y)
        if evt.level % 10 == 0 then
            self:dropStar(evt.level, evt.x, evt.y)
        end
        ch.fightRoleLayer:getMainRole():playVictory(function()
            -- 需引导
            if self.mode == self.GameMode.normal then
                local goldType = ch.flyBox:isAppear(math.ceil(os_clock() - ch.fightRoleAI.bossStartAtkTime))
                if goldType then
                    ch.flyBox:addFlyBox(goldType)
                end
                self:goNextLevel()
            end
        end)
    end
end

function levelController:deathOnGoldBoss(evt)
    ch.fightRoleLayer:clearHJJJGold()
    zzy.EventManager:dispatch({type = ch.fightRole.BOSS_PASS_EVENT_TYPE})
    local hp = ch.fightRoleLayer:getGoldBossLife(evt.level)
    self:openResultGoldBoss(true,evt.level,hp)
end

function levelController:deathOnSStoneBoss(evt)
    ch.fightRoleLayer:clearHJJJGold()
    zzy.EventManager:dispatch({type = ch.fightRole.BOSS_PASS_EVENT_TYPE})
    ch.NetworkController:killedGoldBoss(1,2,0,self:getGoldBossTime(),0)
end

local goldLine = 0
if ch.LongDouble then
    goldLine = ch.LongDouble:new(100)
end
function levelController:dropMoney(roleType,level,x,y)
    local isCrit = math.random() < ch.fightRoleLayer:getMoneyCritProbability()
    local gold = ch.fightRoleLayer:getGold(level,roleType == ch.fightRole.roleType.chest)
    if isCrit then
        gold = gold * goldCritTimes
    end
    local goldBaseNum = gold <= goldLine and 1 or 2
    if isCrit then goldBaseNum = goldBaseNum*2 end
    local goldNum = (roleType ~= ch.fightRole.roleType.monster and 8 or 1) * goldBaseNum
    local type = roleType == ch.fightRole.roleType.chest and 4 or 1
    ch.goldLayer:dropMoney(x, y, goldNum,type)
    ch.MoneyModel:addGold(gold)
    ch.CommonFunc:playGoldSound(gold)
end

function levelController:dropCard(level,x,y)
    local card = ch.LevelModel:getCardDropData(level)
    if card and card.id and card.num>0 then
        ch.PetCardModel:addChipByChipId(card.id,card.num)
        if card.id > 51000 then
            ch.goldLayer:dropMoney(x,y,1,7)
        else
            ch.goldLayer:dropMoney(x,y,1,5)
            ch.CommonFunc:cardDropEffect(card.id)
        end
    end
end

function levelController:dropSStone(level,x,y)
    local num = ch.LevelModel:getSStoneDropData(level)
    if num and num>0 then
        ch.MoneyModel:addsStone(num)
        local sStoneNum = num <= 10 and 1 or num <= 100 and 2 or num <= 1000 and 3 or 5
        ch.goldLayer:dropMoney(x, y, sStoneNum,2)
    end
end

function levelController:dropStar(level,x,y)
    if level >= ch.LevelModel:getStarLevel() then
        if ch.LevelModel:getStarLevel() < GameConst.MGAIC_STAR_LEVEL then
            ch.LevelModel:setStarLevel(GameConst.MGAIC_STAR_LEVEL)
        end
        if level == GameConst.MGAIC_STAR_LEVEL then
            ch.MoneyModel:addStar(1)
            ch.goldLayer:dropMoney(x, y, 1,3)
        elseif level - GameConst.MGAIC_STAR_STEP == ch.LevelModel:getStarLevel() then
            ch.MoneyModel:addStar(1)
            ch.LevelModel:setStarLevel(level)
            ch.goldLayer:dropMoney(x, y, 1,3)
        end
    end
end

function levelController:dropFirecraker(level,x,y) -- 掉落爆竹
    local num = ch.LevelModel:getFirecrackerDropData(level)
    if num and num>0 then
        ch.MoneyModel:addFirecracker(num)
        ch.goldLayer:dropMoney(x, y, num,8)
    end
end

function levelController:dropConversionMoney(level,x,y) -- 掉落元宵，红花，粽子
    local num = ch.LevelModel:getConversionMoneyDropData(level)
    if num and num>0 then
        ch.MoneyModel:addCSock(num)
        if ch.ChristmasModel:isOpenByType(1001) then
            local cfgid = ch.ChristmasModel:getCfgidByType(1001)
            local cfgData = GameConst.HOLIDAY_SDDH_MONEY_DATA[cfgid]
            if cfgData.moneyType == 2 then
                ch.goldLayer:dropMoney(x, y, num,9)
            elseif cfgData.moneyType == 4 then
                ch.goldLayer:dropMoney(x, y, num,10)
            elseif cfgData.moneyType == 5 then
                ch.goldLayer:dropMoney(x, y, num,11)
            end
        end
    end
end

local wGoldLine1 = 0
local wGoldLine2 = 0
local wGoldLine3 = 0
if ch.LongDouble then
    wGoldLine1 = ch.LongDouble:new(10)
    wGoldLine2 = ch.LongDouble:new(100)
    wGoldLine3 = ch.LongDouble:new(1000)
end
function levelController:dropMoneyInWarpath(x,y,gold,isCrit)
    local goldBaseNum = gold <= wGoldLine1 and 1 or gold <= wGoldLine2 and 2 or gold <= wGoldLine3 and 3 or 5
    if isCrit then goldBaseNum = goldBaseNum*2 end
    local goldNum = 3 * goldBaseNum
    ch.goldLayer:dropMoney(x, y, goldNum,1)
end

function levelController:mainRoleIn(isAddEnemy,isGuid)
    if isAddEnemy == nil then isAddEnemy = true end
    state = 1
    ch.fightRoleLayer:addMainRole(ch.UserTitleModel:getAvatar(),ch.UserTitleModel:getWeapon())
    if isAddEnemy then
        self:startAddEnemy(isGuid)
    end
end

function levelController:startFightBoss()
    ch.fightBackground:playBossReady(function()
        state = 2
        ch.fightRoleAI.bossStartAtkTime = os_clock()
    end)
end

function levelController:getGoldBossTime()
	if goldBossTime then
        return goldBossTime
	else
	   return os_clock() - ch.fightRoleAI.bossStartAtkTime
	end
	
end

function levelController:startAddEnemy(isGuid)
    if state == 2 then return end
    if levelConfig.type == 2 then
        ch.fightRoleLayer:addEnemyRole()
        if isGuid then
            ch.fightRoleAI.bossStartAtkTime = nil
        else
            ch.fightBackground:playBossReady(function()
                state = 2
                ch.fightRoleAI.bossStartAtkTime = os_clock()
            end)
        end
    else
        local leftCount = 0
        local curCount = ch.LevelModel:getKilledCount()
        if ch.LevelModel:getCurLevel() ~= ch.LevelModel:getMaxLevel() then
            leftCount = 5
        else
            local levelTotalCount = ch.LevelModel:getTotalCount(ch.LevelModel:getCurLevel())
            leftCount = levelTotalCount - curCount
            leftCount = leftCount <= 5 and leftCount or 5
        end    
        local count = 0
        local comp = function()
            count = count + 1
            if count == leftCount then
                state = 2
            end
        end
        ch.fightRoleLayer:addEnemyRole(nil, 600,comp)
        if leftCount>1 then
            for i = 2,leftCount do
                addEnemyId["id"..i] = zzy.TimerUtils:setTimeOut(0.1*(i-1),function()
                    ch.fightRoleLayer:addEnemyRole(nil,nil,comp)
                    addEnemyId["id"..i] = nil
                end)
            end
        end
        refEnemyCount = curCount + leftCount
    end
end

local playMusic = function(withAni,config)
    local level = ch.LevelModel:getCurLevel()
    local time = config.type == 1 and 2 or 2.5
    local play = function(type)
        if config.type == 1 then
            ch.MusicManager:playCommonBGMusic(true)
    	else
            ch.MusicManager:playBossBGMusic(true)
        end
    end
    if withAni then
        ch.MusicManager:stopMusic()
        zzy.TimerUtils:setTimeOut(time,function()
            play()
        end)
    else
        play()
    end
end

function levelController:goNextLevel(withAni)
    state = 0
    ch.fightRoleLayer:releaseUselessEnemyRes()
    ch.clickLayer:clearBombs()
    local isTitleChange,isShow = ch.UserTitleModel:isNew()
    if isShow then
        ch.UserTitleModel:setShowEffect(true)
    end
    if isTitleChange then
        ch.UIManager:showGamePopup("MainScreen/W_title_getnew")
        ch.fightRoleLayer:changeMainRoleAvatar(ch.UserTitleModel:getAvatar(),ch.UserTitleModel:getWeapon())
    end
    
    local newLevel = ch.LevelModel:getCurLevel()
    local level = newLevel - 1
    --    if nextLevel%5 == 0 and not ch.LevelModel:getSStoneDropData(nextLevel) then
    if newLevel%5 == 0 then
        ch.NetworkController:sStoneGet(newLevel)
    end
    
    -- 首次突破10关，请求新手礼包数据
    local flag= string.sub(zzy.Sdk.getFlag(),1,2)
    if flag=="CY" and ch.StatisticsModel:getMaxLevel() == GameConst.GIFT_BAG_LEVEL + 1 then
        ch.NetworkController:getGiftBagEndTime()
    end
    
    -- 坚守阵地引导
    if ch.StatisticsModel:getMaxLevel() == GameConst.DEFEND_OPEN_LEVEL+1 and ch.guide._data["guide9060"] ~= 1 then
        zzy.TimerUtils:setTimeOut(0, function()
            ch.UIManager:cleanGamePopupLayer(true)
            ch.guide:play_guide(9060)
        end)
    end
    -- 卡牌副本引导
    if ch.StatisticsModel:getMaxLevel() == GameConst.CARD_FB_OPEN_LEVEL+1 and ch.guide._data["guide10320"] ~= 1 then
        zzy.TimerUtils:setTimeOut(0, function()
            ch.UIManager:cleanGamePopupLayer(true)
            ch.guide:play_guide(10320)
        end)
    end
    -- 矿区争夺战引导
    if ch.StatisticsModel:getMaxLevel() == GameConst.MINE_OPEN_LEVEL+1 and ch.guide._data["guide10340"] ~= 1 then
        zzy.TimerUtils:setTimeOut(0, function()
            ch.UIManager:cleanGamePopupLayer(true)
            ch.guide:play_guide(10340)
        end)
    end
    -- 天梯引导
    if ch.StatisticsModel:getMaxLevel() > GameConst.ARENA_OPEN_LEVEL and ch.guide._data["guide10170"] ~= 1 then
        zzy.TimerUtils:setTimeOut(0, function()
            ch.UIManager:cleanGamePopupLayer(true)
            ch.guide:play_guide(10170)
        end)
    end
    -- 祭坛引导
    if ch.StatisticsModel:getMaxLevel() > GameConst.ALTAR_OPEN_LEVEL[1] and (ch.guide._data["guide10250"] ~= 1 or (not ch.guide.obj and table.maxn(ch.AltarModel:getAltarListInit(1)) < 1)) then
        zzy.TimerUtils:setTimeOut(0, function()
            ch.UIManager:cleanGamePopupLayer(true)
            ch.guide:play_guide(10250)
        end)
    end
    
    if _G_ST_BTN and (ch.StatisticsModel:getMaxLevel() > GameConst.SHENTAN_OPEN_LEVEL) then
        _G_ST_BTN:setVisible(true)
    end
	
	  -- 评分
    if ch.StatisticsModel:getMaxLevel() == GameConst.RATE_LEVEL+1 or ch.StatisticsModel:getMaxLevel() == GameConst.RATE_LEVEL1+1 then
       if  string.sub(zzy.Sdk.getFlag(),1,2)=="CY"  then
			local info={
				f="gotorate"
			}
			zzy.Sdk.extendFunc(json.encode(info))
			cclog(json.encode(info))
		end
    end
    
    --第一次进入boss
    local ifGuide = false
    if ch.StatisticsModel:getMaxLevel() == 5 and ch.guide._data["guide9030"] ~= 1 then
        ifGuide = true
        zzy.TimerUtils:setTimeOut(1, function()
            ch.UIManager:cleanGamePopupLayer(true)
            ch.guide:play_guide(9030)
        end)
    end
    --第一次得到魂石
    if level%5 == 0 and ch.LevelModel:getSStoneDropData(tonumber(level)) > 0 and ch.guide._data["guide9037"] ~= 1 then
        ch.guide._data["guide9037"] = 1
        ch.NetworkController:reGuideMsg("9037", "2")
    end
    self:showLevel(withAni,true,ifGuide)
    --第一次挑战boss成功
    if ch.StatisticsModel:getMaxLevel() == 6 and ch.guide._data["guide9035"] ~= 1 then
        ch.guide._data["guide9035"] = 1
        ch.NetworkController:reGuideMsg("9035", "1")
    end
    -- 没转生过，首次突破130关，获得魂石超过一定数量
    if ch.StatisticsModel:getRTimes()<1 and ch.StatisticsModel:getMaxLevel() > GameConst.RUNIC_SAMSARA_LEVEL_MIN and ch.MoneyModel:getsStone() >= GameConst.MSG_CF_SStone and ch.guide._data["guide9038"] ~= 1 then
        ch.guide._data["guide9038"] = 1
        ch.NetworkController:reGuideMsg("9038", "3")
    end
    --改名引导
    if ch.StatisticsModel:getMaxLevel() == 21 and ch.guide._data["guide9039"] ~= 1 then
        ch.guide._data["guide9039"] = 1
        ch.NetworkController:reGuideMsg("9039", "6")
    end
    local lv = ch.RunicModel:getActiveSkillUnlockLv(ch.RunicModel.skillId.wujinzhuansheng)
    if ch.LevelModel:getCurLevel() == lv + 1 then
        ch.fightBackground:playSamsaraEffect()
    end
      
    local evt = {type = self.GO_NEXT_LEVEL}
    zzy.EventManager:dispatch(evt)
end

function levelController:goPreLevel(withAni,isGiveUp)
    state = 0
    ch.clickLayer:clearBombs()
    ch.LevelModel:preLevel()
    ch.fightRoleLayer:releaseUselessEnemyRes()
    self:showLevel(withAni,true)
    if not isGiveUp and ch.guide._data["guide10040"] ~= 1 then
        ch.guide:play_guide(10040)
    end
    local evt = {type = self.GO_NEXT_LEVEL}
    zzy.EventManager:dispatch(evt)
end

function levelController:setLevel(level)
    state = 0
    ch.NetworkController:clearLevelData()
    ch.LevelModel:setCurLevel(level)
    self:showLevel(false,true)
end

function levelController:showLevel(withAni,isNormal,isGuidBoss)
    state = 0
    if withAni == nil then withAni = true end
    ch.fightRoleLayer:clearRole()
    local level = ch.LevelModel:getCurLevel()
    local configLevel = level % table.maxn(GameConfig.LevelConfig:getTable())
    configLevel = configLevel == 0 and table.maxn(GameConfig.LevelConfig:getTable()) or configLevel
    levelConfig = GameConfig.LevelConfig:getData(configLevel)
    if withAni then
        local oldLevel = (level - 1) % table.maxn(GameConfig.LevelConfig:getTable())
        oldLevel = oldLevel == 0 and table.maxn(GameConfig.LevelConfig:getTable()) or oldLevel
        ch.fightBackground:showScene(levelConfig.scene, GameConfig.LevelConfig:getData(oldLevel).type, level - 1,function()
            self:mainRoleIn(isNormal,isGuidBoss)
        end)
    else
        ch.fightBackground:showScene(levelConfig.scene,nil,nil,function()
            self:mainRoleIn(isNormal,isGuidBoss)
        end)
    end
    playMusic(withAni,levelConfig)
end

--额外魂石计算 参数为等级
function levelController:getPrimalHeroSoulRewards(param1)
     if param1 == GameConst.SSTONE_LEVEL then
        return math.floor(1*(1+ch.TotemModel:getTotemSkillData(1,9)))
     end
     if param1 > GameConst.SSTONE_LEVEL and param1 % 5 == 0 then
        local num = math.floor(math.pow(((param1 - GameConst.SSTONE_LEVEL) / 5 + 4) / 5,GameConst.SSTONE_VALUE_POW))
        return math.floor(num*(1+ch.TotemModel:getTotemSkillData(1,9)))
     end
     return 0
end

function levelController:stop()
    if isInitialized then
        ch.fightRoleLayer:stop()
        ch.fightRoleLayer:clearAllRes()
        ch.fightBackground:clearRes()
        ch.goldLayer:clear()
        ch.clickLayer:clear()
        self:cancelTimeout()
        ch.UIManager:getAutoFightLayer():removeAllChildren()
    end
end

function levelController:cancelTimeout()
    if timeId then
        zzy.TimerUtils:cancelTimeOut(timeId)
        timeId = nil
    end
    for k,v in pairs(addEnemyId) do
        zzy.TimerUtils:cancelTimeOut(v)
        addEnemyId[k] = nil
    end
end

function levelController:startNormal()
    self:cancelTimeout()
    if self.mode == self.GameMode.defend then -- 从塔防出来加载mainRoleEffect
        ch.RoleResManager:load("mainRoleEffect")
    end
    state = 1
    self.mode = self.GameMode.normal
    self._wStartTime = nil
    ch.fightRoleLayer:clearRole()
    ch.fightRoleLayer:clearEnemyRes()
    ch.fightRoleLayer:clearHJJJGold()
    ch.clickLayer:clearBombs()
    ch.fightBackground:lookTo(0)
    ch.fairyLayer:start()
    ch.fightRoleLayer:resume()
    self:showLevel(false,true,false)
    local evt = {type= self.GAME_MODE_CHANGE}
    evt.mode = self.GameMode.normal
    zzy.EventManager:dispatch(evt)
end

-- 无尽征途
function levelController:startWarpath()
    self:cancelTimeout()
    self.mode = self.GameMode.warpath
    self._wStartTime = nil
    ch.RunicModel:clearAllSkillEffect()
    ch.fightRoleLayer:clearRole()
    ch.fightRoleLayer:clearEnemyRes()
    ch.fightRoleLayer:clearHJJJGold()
    ch.flyBox:clearFlyBox()
    ch.clickLayer:clearBombs()
    ch.fightBackground:lookTo(0)
    state = 1
    ch.fightRoleLayer:resume()
    ch.fightRoleLayer:addMainRole(ch.UserTitleModel:getAvatar(),ch.UserTitleModel:getWeapon())
    ch.fightRoleLayer:addWarpathRole()
    ch.fightBackground:showScene("wujinzhengtu")
    ch.fightBackground:playWarpathReady(function()
        state = 2
        self._wStartTime = os_clock()
    end)
    local evt = {type= self.GAME_MODE_CHANGE}
    evt.mode = self.GameMode.warpath
    zzy.EventManager:dispatch(evt)
end

function levelController:openResultWarpath()
    self:cancelTimeout()
    state = 0
    ch.fightRoleLayer:pause()
    ch.clickLayer:clearBombs()
    ch.fightRoleLayer:clearHJJJGold()
    ch.RoleResManager:releaseEffect("tx_wujinzhengtu")
    ch.NetworkController:RewardInWarpath()
end

function levelController:startDefend(isGuide)
    self:cancelTimeout()
    ch.NetworkController:startDefend()
    state = 0
    self.mode = self.GameMode.defend
    ch.RunicModel:clearAllSkillEffect()
    ch.fightRoleLayer:clearRole(true)
    ch.RoleResManager:release("mainRoleEffect") -- 仅在塔防时卸载主角特效，并在塔防结束时，加载它
    ch.fightRoleLayer:clearEnemyRes()
    ch.fightRoleLayer:clearHJJJGold()
    ch.fightRoleLayer:pause()
    ch.clickLayer:clearBombs()
    ch.flyBox:clearFlyBox()
    
    ch.fightBackground:showScene("jianshouzhendi",nil,nil,function()
        ch.fightBackground:_updateXTo(0)
    end)
    ch.fairyLayer:stop()
    ch.DefendMap:init(isGuide)
    local evt = {type= self.GAME_MODE_CHANGE}
    evt.mode = self.GameMode.defend
    zzy.EventManager:dispatch(evt)
end

function levelController:startGoldBoss(type)
    self:cancelTimeout()
    ch.NetworkController:sendCacheData()
    self.mode = type == ch.flyBox.FlyBoxType.GoldBoss and self.GameMode.goldBoss or self.GameMode.sStoneBoss
    ch.fightRoleLayer:clearRole()
    ch.fightRoleLayer:clearHJJJGold()
    ch.clickLayer:clearBombs()
    ch.flyBox:clearFlyBox()
    ch.fightBackground:lookTo(0)
    state = 1
    ch.fightRoleLayer:resume()
    ch.fightRoleLayer:addMainRole(ch.UserTitleModel:getAvatar(),ch.UserTitleModel:getWeapon())
    ch.fightRoleLayer:addGoldBoss(type)
    goldBossTime = 0
    ch.fightBackground:playGoldBossReady(type,function()
        state = 2
        goldBossTime = nil
        ch.fightRoleAI.bossStartAtkTime = os_clock()
    end)
    local evt = {type= self.GAME_MODE_CHANGE}
    evt.mode = self.mode
    zzy.EventManager:dispatch(evt)
end

function levelController:openResultGoldBoss(isVictory,level,hp)
    self:cancelTimeout()
    state = 0
    ch.clickLayer:clearBombs()
    ch.fightRoleLayer:clearHJJJGold()
    local gold = ch.fightRoleLayer:getGoldBossGold(level,hp)
    if isVictory then
        gold = gold * GameConst.GOLD_BOSS_VICTORY_GOLD_RATIO
    end
    goldBossTime = os_clock()- ch.fightRoleAI.bossStartAtkTime
	local data = {victory = isVictory and 1 or 0,
	              gold = gold,
	              hp = hp,
                  totalTime = goldBossTime}
	ch.UIManager:showGamePopup("MainScreen/W_TBossresult",data) -- 界面写在ActiveSkillView
end

function levelController:startAFK()
    self:cancelTimeout()
    self.mode = self.GameMode.AFK
    ch.fairyLayer:stop()
    ch.fightRoleLayer:clearRole()
    ch.fightRoleLayer:clearHJJJGold()
    ch.clickLayer:clearBombs()
    ch.fightBackground:lookTo(0)
    state = 1
    ch.fightRoleLayer:resume()
    ch.fightRoleLayer:addMainRole()
    ch.AFKModel:setAFKing(true)
    local evt = {type= self.GAME_MODE_CHANGE}
    evt.mode = self.GameMode.AFK
    zzy.EventManager:dispatch(evt)
    ch.UIManager:cleanGamePopupLayer(true)
    ch.UIManager:showGamePopup("autofight/W_autofight_2")
end

function levelController:startCardFight(attacker,defender,seed,type,win)
    self:cancelTimeout()
    self.mode = self.GameMode.cardFight
    ch.UIManager:cleanGamePopupLayer(true)
    ch.fightRoleLayer:clearRole()
    ch.fightRoleLayer:clearHJJJGold()
    ch.fightRoleLayer:clearEnemyRes()
    ch.clickLayer:clearBombs()
    ch.fightBackground:lookTo(0)
    ch.fightRoleLayer:pause()
    ch.fairyLayer:stop()
    ch.CardFightMap:init(attacker,defender,seed,type,win)
    local evt = {type= self.GAME_MODE_CHANGE}
    evt.mode = self.GameMode.cardFight
    zzy.EventManager:dispatch(evt)
end

function levelController:startGuildWar()
    self:cancelTimeout()
    self.mode = self.GameMode.guildWar
    ch.UIManager:cleanGamePopupLayer(true)
    ch.fightRoleLayer:clearRole(true)
    ch.fightRoleLayer:clearHJJJGold()
    ch.fightRoleLayer:clearEnemyRes()
    ch.clickLayer:clearBombs()
    ch.fightBackground:lookTo(0)
    ch.fightRoleLayer:pause()
    ch.fairyLayer:stop()
    
    local view = zzy.uiViewBase:new("Guild/W_NewGuild_guildwar_mainbroad",nil,nil,nil,"Guild/W_NewGuild_guildwar_mainbroad")
--    ch.UIManager:getSysPopupLayer():addChild(view)
    ch.UIManager:getGamePopupLayer():addChild(view)
    ch.UIManager:getActiveSkillLayer():setVisible(false)
    ch.UIManager:getMainViewLayer():setVisible(false)
    ch.UIManager:getAutoFightLayer():setVisible(false)
    local evt = {type= self.GAME_MODE_CHANGE}
    evt.mode = self.GameMode.guildWar
    zzy.EventManager:dispatch(evt)
    ch.GuildWarController:refreshMapData()
end

function levelController:reStartGame()
    if  ch.GameLoaderModel.loadingCom==false then
		__G__ONRESTART__()
		return
	end
	local  func_getServerInfo
	func_getServerInfo=function() 
		ch.CommonFunc:getNetString(_G_URL_SERVER_INFO, function(err, str)
			if err ~= 0 or str == nil then
				ch.UIManager:showMsgBox(1,true,GameConst.NET_ERROR[1].."("..GameConst.NET_ERROR[5]..err..")",function()
					self:reStartGame()
				end,nil,Language.MSG_BUTTON_RETRY)
				return
			end
			local serverInfo = json.decode(str)
			if  serverInfo then
				--if serverInfo.version.pacVer~=ch.UpdateManager._versionData.pacVer 
				--or serverInfo.version.resVer~=ch.UpdateManager._versionData.resVer 
				--or serverInfo.version.forceVer~=ch.UpdateManager._versionData.forceVer 
                if false -- tgx
				then
					ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_LoginView_18,function()
						__G__ONRESTART__()
					end,nil,nil,nil)
				else
					ch.GameLoaderModel.serverList=serverInfo.servers
					local ind=ch.GameLoaderModel:getServerIndBySvrid(zzy.config.svrid)
					if ind then
						local info = ch.GameLoaderModel:getServerInfoByInd(ind)
						if info.status==0  and tonumber(ch.PlayerModel.usertype)==0 then
							--维护中
							ch.UIManager:showMsgBox(1,true,GameConst.NET_ERROR[3],function()
                            self:reStartGame()
						end,nil,Language.MSG_BUTTON_OK)
							return
						end
						if info.type==4  and tonumber(ch.PlayerModel.usertype)==0 then
							--待开新服
                            ch.UIManager:showMsgBox(1,true,GameConst.NET_ERROR[3],function()
							self:reStartGame()
							end,nil,Language.MSG_BUTTON_OK)
							return
						end
					end
					self:startReconnnect()  
				end
			else
				ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_LoginView_19,function()
					func_getServerInfo()
				end,nil,Language.MSG_BUTTON_RETRY)
			end
		end)	
	end
	cc.Director:getInstance():resume()
    if self.mode == self.GameMode.defend then
        ch.DefendMap:pause()
    elseif self.mode == self.GameMode.cardFight then
        ch.CardFightMap:pause()
    else
        ch.fightRoleLayer:pause()    
    end
	func_getServerInfo()
end
function levelController:startReconnnect()
	ch.LoginView:_checkOrder()
    local loginStr = ch.LoginView:renderLgnStr()
	zzy.NetManager:destoryInstance()
    zzy.GuidUtils:cleanOrderIndex()
    zzy.NetManager:getInstance().loginStr = loginStr
    zzy.NetManager:getInstance():init(zzy.config.host,zzy.config.port)
    ch.UIManager:showWaiting(true)
    ch.UIManager:closeMsgBox()
    local lgnId
    lgnId = zzy.EventManager:listen("S2C_ls_lgn",function(sender, evt) 
        zzy.EventManager:unListen(lgnId)
        if evt.data.ret == 0 then
            local gdId
            gdId = zzy.EventManager:listen("S2C_sys_gd",function(sender, evt)
                zzy.EventManager:unListen(gdId)
                ch.UIManager:showWaiting(false,true)
                self:onReLogin(evt)
            end)
            local evt = zzy.Events:createC2SEvent()
            evt.cmd = "sys"
            evt.data = {
                f = "gd",
            }
            zzy.EventManager:dispatch(evt)
        else
            cclog("登录失败")    
        end
    end)
end
function levelController:onReLogin(evt)
    ch.UIManager:cleanGamePopupLayer(true)
    _SERVER_TIME_DIS = evt.data.d.statistics.time - os_clock()
    --ch.ModelManager:clean() -- tgx
    ch.NetworkController:clean()
    ch.ModelManager:init(evt.data.d)
    ch.UIManager:getMainView():noticeAllDataChange()
    ch.UIManager:getActiveSkillView():noticeAllDataChange()
    ch.fairyLayer:removeAllFairy()
    ch.flyBox:clearFlyBox()
    if self.mode == self.GameMode.defend then
        ch.DefendMap:destory()
    elseif self.mode == self.GameMode.cardFight then
        ch.UIManager:getActiveSkillLayer():setVisible(true)
        ch.UIManager:getMainViewLayer():setVisible(true)
        ch.CardFightMap:destroy()
    end
    
    if ch.AFKModel:getLastTargetLevel() and ch.AFKModel:getLastTargetLevel() > ch.LevelModel:getCurLevel() then
        self:startAFK()
    else
        self:startNormal()
    end
end

return levelController