local chestName ="baoxiangguai"
local chestScale = 0.8

local chestZOrder = 200
local mainRoleZOrder = 300

local layer = {}

local _layer
local _mainRole
local _familiar
local _enemys = {}
local _damageLayer
local dpsCounter = {}
local _mainRoleActionSpeed = 1
local _isPause = false
local enemyRes = nil
local hjjjGold = 0 -- 黄金季节1秒内累积的数量

local function _sortView()
    table.sort(_enemys, function(e1, e2)
        return e1.basey > e2.basey
    end)
    for order, e in ipairs(_enemys) do
        if e:getRoleType() ~= ch.fightRole.roleType.chest then
            e:setLocalZOrder(order)
        end
    end
end

function layer:init()
    if _layer then return end
    _isPause = false
    _layer = cc.Layer:create()
    _layer:setPositionY(ch.editorConfig:getSceneGlobalConfig().roleh)
    ch.UIManager:getAutoFightLayer():addChild(_layer, 3)
    
    _damageLayer = cc.Layer:create()
    _damageLayer:setPosition(30, 40)
    _layer:addChild(_damageLayer,-1)
    zzy.EventManager:listen(zzy.Events.TickEventType, function()
        if _isPause then return end
        if _mainRole and _mainRole:isRoleVisible() then
            for i,enemy in ipairs(_enemys) do
                if not enemy.isdie then
                    enemy:update()  
                end
            end
            if ch.LevelController:getState() == 2 then
                ch.fightBackground:lookTo(_mainRole:getPositionX() + ch.editorConfig:getSceneGlobalConfig().offsetX * _mainRole:getDir())
            end
            _mainRole:update()
        end
    end)
    
    zzy.EventManager:listen(ch.RunicModel.SkillDurationStatusChangedEventType,function(obj,evt)
        if evt.id == ch.RunicModel.skillId.shuangchongdaji and _mainRole then
            if evt.statusType == ch.RunicModel.StatusType.began then
                _mainRole:addSkillEffect()
            else
                _mainRole:removeSkillEffect()
            end
        end
        if evt.id == ch.RunicModel.skillId.qianshouzhili and _mainRole then
            if evt.statusType == ch.RunicModel.StatusType.began then
                _mainRole.chongwu:addSkillEffect()
            else
                _mainRole.chongwu:removeSkillEffect()
            end
        end
        local schedulerId = nil
        if evt.id == ch.RunicModel.skillId.huangjinjijie then
            if evt.statusType == ch.RunicModel.StatusType.began then
                 if schedulerId then
                    hjjjGold = 0
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerId)
                 end
                 schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
                    ch.MoneyModel:addGold(hjjjGold)
                    hjjjGold = 0
                    if ch.RunicModel:getSkillDuration(ch.RunicModel.skillId.huangjinjijie) < 0 then
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerId)
                    end
                 end,1,false)
            end
        end
    end)
end

function layer:clearHJJJGold()
	hjjjGold = 0
end

function layer:setVisible(isVisible)
    _layer:setVisible(isVisible)
end

function layer:updateOffsetX(px)
    _layer:setPositionX(px)
end

function layer:getDps()
    local et = os_clock()
    local st = et - GameConst.LEVEL_FIGHT_COUNTER_TS
    local total = 0
    for key, var in pairs(dpsCounter) do
    	if key < st then
            dpsCounter[key] = nil
    	else
            total = total + dpsCounter[key]
    	end
    end
    return total / GameConst.LEVEL_FIGHT_COUNTER_TS
end

-- 累积黄金季节获得的金币
function layer:addHJJJGold(gold)
	hjjjGold = hjjjGold + gold
end

local roleLastTime = os_clock()
local petLastTime = os_clock()
local roleDamageNum = {}
local petDamageNum = {}

function layer:showDamage(posx, posy, type, value)
    local now = os_clock()
    if type == 1 then
        if #roleDamageNum >= 5 and now - roleLastTime < 0.2 then return end
        roleLastTime = now
    else
        if #petDamageNum >= 5 and now - petLastTime < 0.2 then return end
        petLastTime = now
    end
    local fontTmp = "res/ui/aaui_font/font_yellow.fnt"
    if type == 1 then
        fontTmp = "res/ui/aaui_font/font_red.fnt"
    elseif type == 2 then
        fontTmp = "res/ui/aaui_font/font_yellow.fnt"
    elseif type == 3 then
        fontTmp = "res/ui/aaui_font/font_crtical.fnt"
    end
    local text = ccui.TextBMFont:create(ch.NumberHelper:harmToString(value), fontTmp)
    if type == 1 then
        table.insert(roleDamageNum,text)
    else
        table.insert(petDamageNum,text)
    end
    _damageLayer:addChild(text)
    text:setPosition(posx,posy)
    text:setScale(1)
    local time = 0.6
    if type == 1 then
        text:runAction(cc.EaseOut:create(cc.MoveBy:create(time, cc.vertex2F(-50, 200)), time))
        text:runAction(cc.Sequence:create(cc.EaseOut:create(cc.FadeOut:create(time), time), cc.CallFunc:create(function()
            text:removeFromParent()
            for k,v in ipairs(roleDamageNum) do
                if v == text then
                    table.remove(roleDamageNum,k)
                    break
                end
            end
        end)))
        text:setLocalZOrder(1000)
    else
        text:runAction(cc.EaseOut:create(cc.MoveBy:create(time, cc.vertex2F(0, 200)), time))
        text:runAction(cc.MoveBy:create(time, cc.vertex2F(70, 0)))
        text:runAction(cc.Sequence:create(cc.EaseOut:create(cc.FadeOut:create(time), time), cc.CallFunc:create(function()
             if zzy.CocosExtra.isCobjExist(text) then text:removeFromParent() end
            for k,v in ipairs(petDamageNum) do
                if v == text then
                    table.remove(petDamageNum,k)
                    break
                end
            end
        end)))
    end
--    local t = os_clock()
--    dpsCounter[t] = (dpsCounter[t] or 0) + value
end

function layer:addMainRole(roleName,weapon)
    if _mainRole then
        _mainRole:setRoleVisible(true)
        _mainRole:setPosition(-100,0)
        _mainRole:reset()
        if _familiar then
            _familiar:setVisible(true)
        end
    else
        ch.RoleResManager:load(ch.PartnerModel:getCurPartnerAvatar(), function()
            ch.RoleResManager:load(roleName, function(roleName)
                _mainRole = ch.fightRole:create(roleName, nil, GameConst.MAIN_ROLE_SCALE, ch.fightRole.roleType.mainRole, GameConst.MAIN_ROLE_ACTION_SPEED_SCALE)
                _layer:addChild(_mainRole)
                if weapon then
                    cc.Director:getInstance():getTextureCache():addImage(weapon)
                    _mainRole:changeWeapon(weapon)
                end
                _mainRole:setActionSpeed(_mainRoleActionSpeed)
                _mainRole:setLocalZOrder(mainRoleZOrder)
                if ch.FamiliarModel:getCurFamiliar() then
                    self:addFamiliarRole(ch.FamiliarModel:getCurFamiliar())
                end
            end)
        end)
    end
end

function layer:addFamiliarRole(id)
    self:clearFamiliar()
    local name = GameConfig.FamiliarConfig:getData(id).avatar
    ch.RoleResManager:load(name, function()
        _familiar = ch.familiarRole:create(id,ch.familiarRole.Orientation.right)
        _familiar:initTarget(_mainRole)
        _layer:addChild(_familiar)
    end)
end

function layer:clearFamiliar()
    if _familiar then
        local name = _familiar:getAvatarName()
        _familiar:destroy()
        ch.RoleResManager:release(name)
        _familiar = nil
    end
end

function layer:changeMainRole(roleName)
    ch.RoleResManager:load(ch.PartnerModel:getCurPartnerAvatar(), function()
    ch.RoleResManager:load(roleName, function(roleName)
        if _mainRole then
            self:clearMainRole()
        end
            local roleType = ch.fightRole.roleType.mainRole
            _mainRole = ch.fightRole:create(roleName, nil, GameConst.MAIN_ROLE_SCALE, roleType, GameConst.MAIN_ROLE_ACTION_SPEED_SCALE)
            _layer:addChild(_mainRole)
            _mainRole:setActionSpeed(_mainRoleActionSpeed)
            _sortView()
        end)
    end)
end

function layer:getMainRole()
    return _mainRole
end

function layer:changeMainRoleAvatar(roleName,weapon)
    if roleName == _mainRole.roleName then
        if weapon then
            cc.Director:getInstance():getTextureCache():addImage(weapon,function()
                _mainRole:changeWeapon(weapon)
            end)
        end
    else
        local oldName = _mainRole.roleName
        ch.RoleResManager:load(roleName,function()
            if weapon then
                cc.Director:getInstance():getTextureCache():addImage(weapon,function()
                    _mainRole:changeAvatar(roleName)
                    _mainRole:changeWeapon(weapon)
                end)
            else
                _mainRole:changeAvatar(roleName)    
            end
            ch.RoleResManager:release(oldName)
        end)
    end
end

function layer:setMainRoleActionSpeed(speed)
    _mainRoleActionSpeed = speed
    return _mainRole and _mainRole:setActionSpeed(_mainRoleActionSpeed)
end

function layer:fuwenAttack(pos, damage, iscrict)
    local gold = self:getAttackDropMoney()
    for _,role in pairs(_enemys) do
        if not role.isdie and math.abs(role:getPositionX() - pos) < GameConst.PAT_ATTACK_BOM_SIZE then
            role:fuwenAttack(damage, 1, iscrict)
            if gold> ch.LongDouble.zero then
                role:dropGold(gold)
            end
        end
    end
end

local hpCache = {}
function layer:getLevelMaxHP(level,isUsedAddit)
    if not hpCache[level] then
        local life = 0
        local isBoss = 1
        local notBoss = 1
        local lifeBase = GameConst.LEVEL_ENEMY_HP_BASE
        local lifePower = GameConst.LEVEL_ENEMY_HP_UP_RATIO
        if (math.mod(level,5)==0) then
            isBoss = 10
            notBoss = 1
        else
            isBoss = 1
            notBoss = 1
            if (level > 50) then
                notBoss = math.max(0.5,(1 - 0.01 * (level -50)))
            end
        end
        if level <= 1 then 
            return ch.LongDouble:new(lifeBase)
        end 
        if level < lifePower[2].level then
            life = lifeBase * math.pow(lifePower[1].ratio,level -1) + (level-1)*10
        elseif level < lifePower[3].level then
            life = lifeBase * math.pow(lifePower[1].ratio,lifePower[2].level -1) + (lifePower[2].level-1)*10
            life = life * math.pow(lifePower[2].ratio,level-lifePower[2].level)
        elseif level < lifePower[4].level then
            life = lifeBase * math.pow(lifePower[1].ratio,lifePower[2].level-1) + (lifePower[2].level-1)*10
            life = life * math.pow(lifePower[2].ratio,lifePower[3].level-lifePower[2].level)
            life = life * math.pow(lifePower[3].ratio,level-lifePower[3].level)
        else
            life = lifeBase * math.pow(lifePower[1].ratio,lifePower[2].level-1) + (lifePower[2].level-1)*10
            life = life * math.pow(lifePower[2].ratio,lifePower[3].level-lifePower[2].level)
            life = life * math.pow(lifePower[3].ratio,lifePower[4].level-lifePower[3].level)
            life = life * (ch.LongDouble:pow(lifePower[4].ratio,level-lifePower[4].level))
        end
        life = ch.LongDouble:ceil(isBoss*notBoss*life)
        hpCache[level] = life
    end
    local hp = hpCache[level]
    if math.mod(level,5)==0 and isUsedAddit then
        hp = hp * (1- ch.TotemModel:getTotemSkillData(3,2))
        hp = hp * (1 - ch.PartnerModel:getUpNum(5))  -- 图腾和宠物附加属性
        hp = ch.LongDouble:ceil(hp)
    end
    return hp
end

local getBaseGold = function(hp,level)
    local fix = 1
    local gold = 0
    if (level < 200) then
        fix = 0.3*math.pow(1.005,level)
    else
        fix = 0.3*math.pow(1.005,200)+(level-200)*0.005
    end
    gold = hp * (fix/15)
    local minGold = ch.LongDouble:new(level)
    if (gold < minGold) then
        gold = minGold
    end
    return gold
end

local getAddiTionGold = function(gold)
	gold = gold * (1 + ch.MagicModel:getMToMoneyAddition()) -- 宝物加成
    gold = gold * (1 + ch.TotemModel:getTotemSkillData(1,2)) -- 图腾加成
    gold = gold * (1 + ch.BuffModel:getNGoldAddtion())  -- buff
    if ch.AltarModel:getAltarByType(1).level > 0 then
        gold = gold * ch.AltarModel:getFinalEffect(1) -- 祭坛
    end
    return gold
end

local _baseGoldCache = {}
function layer:getGold(level,isChest)
    if not _baseGoldCache[level] then
        local life = self:getLevelMaxHP(level,true)
        _baseGoldCache[level] = getBaseGold(life,level)
    end
    local gold = _baseGoldCache[level]    
    gold = getAddiTionGold(gold)
    if isChest then --宝箱
        gold = gold * 10 * (1 + ch.TotemModel:getTotemSkillData(1,3))
    end
    return ch.LongDouble:ceil(gold)
end

function layer:getDefendGold(hp)
    local gold = getBaseGold(hp,ch.LevelModel:getCurLevel())
	gold = getAddiTionGold(gold)
    return ch.LongDouble:ceil(gold)
end

function layer:getWarpathLife(stage,index)
    return ch.LongDouble:new(GameConst.WARPATH_BOSS_HP(0,stage,index))
end

--local _baseWGoldCache = {}
function layer:getWarpathGold(stage,index)
--    if not _baseWGoldCache[stage] then
--        _baseWGoldCache[stage] = {}
--    end
--    if not _baseWGoldCache[stage][index] then
--        local life = self:getWarpathLife(stage,index)
--        _baseWGoldCache[stage][index] = getBaseGold(life,GameConst.GUILD_OPEN_LEVEL)
--    end
--    local gold = _baseWGoldCache[stage][index]
--    gold = getAddiTionGold(gold)
--    return math.ceil(gold)
      local level = math.ceil(ch.LevelModel:getCurLevel()/5) *5
      local life = self:getLevelMaxHP(level,false)
      local gold = getBaseGold(life,level)
      gold = getAddiTionGold(gold)
    return ch.LongDouble:ceil(gold)
end

function layer:getGoldBossLife(level)
    local level = math.floor(ch.LevelModel:getCurLevel()/5)*5
    local hp = self:getLevelMaxHP(level,true) * GameConst.GOLD_BOSS_HP_RATIO
    return ch.LongDouble:ceil(hp)
end

function layer:getGoldBossGold(level,hp)
    local gold = getBaseGold(hp,level)
    gold = getAddiTionGold(gold)
    gold = gold * GameConst.GOLD_BOSS_GOLD_RATIO * (1 + ch.TotemModel:getTotemSkillData(1,3))
    return ch.LongDouble:ceil(gold)
end

-- 废弃
function layer:getGoldBossHJJJGold(level,hp)
    local gold = getBaseGold(hp,level)
    gold = getAddiTionGold(gold)
    return ch.LongDouble:ceil(gold)
end

-- 黄金季节
function layer:getAttackDropMoney()
    if ch.RunicModel:getSkillDuration(ch.RunicModel.skillId.huangjinjijie) > 0 then
        if ch.LevelController.mode == ch.LevelController.GameMode.normal then
            local level = ch.LevelModel:getCurLevel()
            local gold = ch.fightRoleLayer:getGold(level,false)
            gold = gold * (1+ch.RunicModel:getSkillEffect(ch.RunicModel.skillId.huangjinjijie))
            local t = level%5 == 0 and 0.001 or 0.01
            gold = gold *t
            return ch.LongDouble:ceil(gold)
        elseif ch.LevelController.mode == ch.LevelController.GameMode.warpath then
            local gold = self:getWarpathGold(ch.WarpathModel:getCurStage(),ch.WarpathModel:getCurIndex())
            gold = gold * (1+ch.RunicModel:getSkillEffect(ch.RunicModel.skillId.huangjinjijie))
            gold = gold *0.001
            return ch.LongDouble:ceil(gold)
        elseif ch.LevelController.mode == ch.LevelController.GameMode.goldBoss 
            or ch.LevelController.mode == ch.LevelController.GameMode.sStoneBoss then
            local level = ch.LevelModel:getCurLevel()
            local hp = self:getGoldBossLife(level)
            local gold = self:getGoldBossGold(level,hp)
            gold = gold * (1+ch.RunicModel:getSkillEffect(ch.RunicModel.skillId.huangjinjijie))
            gold = gold *0.001
            return ch.LongDouble:ceil(gold)
        end
    end
    return ch.LongDouble.zero
end

function layer:getChestProbability()
    return GameConst.CHEST_MONSTER_BASE_PROBABILITY + ch.TotemModel:getTotemSkillData(1,4)
end

function layer:getMoneyCritProbability()
    return ch.TotemModel:getTotemSkillData(1,1)
end

function layer:addWarpathRole(func)
    local bossId = ch.WarpathModel:getBossId()
    if bossId == nil then return end
	local roleInfo = GameConfig.WarpathConfig:getData(bossId)
	local opt = zzy.StringUtils:split(roleInfo.guai, ",")
	local roleName = opt[1]
	local scale = tonumber(opt[2])
	local hp = ch.WarpathModel:getCurHP()
	local roleType = ch.fightRole.roleType.boss
	local totalHp = self:getWarpathLife(ch.WarpathModel:getCurStage(),ch.WarpathModel:getCurIndex())
	ch.RoleResManager:load(roleName, function(roleName)
        enemyRes[roleName] = true
        if ch.LevelController.mode ~= ch.LevelController.GameMode.warpath then return end
        local enemy = ch.fightRole:create(roleName,hp,scale,roleType,GameConst.GUAI_ACTION_SPEED_SCALE,totalHp)
        _layer:addChild(enemy)
        enemy:setPositionX(640)
        zzy.TimerUtils:setTimeOut(0, function()
            table.insert(_enemys, enemy)
            _sortView()
            if func then func() end
        end)
    end)
end

function layer:addGoldBoss(type,func)
    local roleName = type == ch.flyBox.FlyBoxType.GoldBoss and "qiandaiguai" or "qiandaiguai02"
    local scale = 1
    local level = math.floor(ch.LevelModel:getCurLevel()/5)*5
    local hp = self:getGoldBossLife(level)
    local roleType = ch.fightRole.roleType.boss
    ch.RoleResManager:load(roleName, function(roleName)
        enemyRes[roleName] = true
        if ch.LevelController.mode ~= ch.LevelController.GameMode.goldBoss and
            ch.LevelController.mode ~= ch.LevelController.GameMode.sStoneBoss then return end
        local enemy = ch.fightRole:create(roleName,hp,scale,roleType,GameConst.GUAI_ACTION_SPEED_SCALE)
        enemy.level = level
        _layer:addChild(enemy)
        enemy:setPositionX(640)
        zzy.TimerUtils:setTimeOut(0, function()
            table.insert(_enemys, enemy)
            _sortView()
            if func then func() end
        end)
    end)
end

function layer:addEnemyRole(roleName, posx,func)
    local level = ch.LevelModel:getCurLevel()
    local configLevel = level % table.maxn(GameConfig.LevelConfig:getTable())
    configLevel = configLevel == 0 and table.maxn(GameConfig.LevelConfig:getTable()) or configLevel
    local levelConfig = GameConfig.LevelConfig:getData(configLevel)
    if not levelConfig.guaiT then
        levelConfig.guaiT = {}
        levelConfig.WT = 0
        for _,optStr in ipairs(zzy.StringUtils:split(levelConfig.guai, "|")) do
            local opt = zzy.StringUtils:split(optStr, ",")
            opt[2],opt[3] = tonumber(opt[2]),tonumber(opt[3])
            table.insert(levelConfig.guaiT, opt)
            levelConfig.WT = levelConfig.WT + opt[3]
        end
    end

    local scale = 1
    local roleType = levelConfig.type == 2 and ch.fightRole.roleType.boss or ch.fightRole.roleType.monster
    if not roleName then
        local isChest = math.random()< self:getChestProbability()
        if levelConfig.type == 1 and isChest then
            roleName = chestName
            scale = chestScale
            roleType = ch.fightRole.roleType.chest
        else
            local rand = math.random(1, levelConfig.WT)
            for _, opt in ipairs(levelConfig.guaiT) do
                rand = rand - opt[3]
                if rand <= 0 then
                    roleName = opt[1]
                    scale = opt[2]
                    if level %5 == 0 then
                        --DEBUG("是boss关")
                        --scale = scale
                    else
                        
                    end
                    --DEBUG("缩放="..scale)
                    
                    break
                end
            end
        end
    end
    local hp = self:getLevelMaxHP(level,true)

    ch.RoleResManager:load(roleName, function(roleName)
        enemyRes[roleName] = true
        if ch.LevelController.mode ~= ch.LevelController.GameMode.normal then return end
        local enemy = ch.fightRole:create(roleName, hp, scale, roleType, GameConst.GUAI_ACTION_SPEED_SCALE)
        enemy.level = level
        _layer:addChild(enemy)
        if roleType == ch.fightRole.roleType.chest then
            enemy:setLocalZOrder(chestZOrder)
        end
        if posx then
            enemy:setPositionX(posx)
        elseif roleType == ch.fightRole.roleType.boss then
            enemy:setPositionX(640)
        elseif _mainRole then
            enemy:setPositionX((1 + math.random()) * 640 + _mainRole:getPositionX())
        else
            enemy:setPositionX(math.random(0, 1000))
        end
        table.insert(_enemys, enemy)
        _sortView()
        if func then func() end
    end)
end

function layer:preLoadResource(process,completed)
    local allRoleRes = {"","mainRoleEffect"}
    allRoleRes[1] = ch.UserTitleModel:getAvatar()
    enemyRes = {}
    local petName = GameConfig.PartnerConfig:getData(ch.PartnerModel:getCurPartner()).apath
    table.insert(allRoleRes,petName)
    local cg = ch.LevelModel:getLevelConfig(ch.LevelModel:getCurLevel())
    for k,str in ipairs(zzy.StringUtils:split(cg.guai,"|")) do
       local newStr = zzy.StringUtils:split(str,",")
        table.insert(allRoleRes,newStr[1])
       enemyRes[newStr[1]] = true
    end
    local load
    load = function(index,total)
        if index <= total - 1 then
            DEBUG("[PRELOAD]"..index..":"..allRoleRes[index])
            ch.RoleResManager:load(allRoleRes[index],function()
                if process then process(index/total) end
                load(index+1,total)
            end)
        else
            local name = string.format("res/scene/%s.png", ch.LevelModel:getLevelConfig(ch.LevelModel:getCurLevel()).scene)
            cc.Director:getInstance():getTextureCache():addImage(name, function(tex)
                if process then process(1) end
                if completed then completed(tex) end
            end)
        end
    end
    load(1,#allRoleRes + 1)
end

function layer:releaseUselessEnemyRes()
    local nextLevel = ch.LevelModel:getCurLevel()
	local nameStr =  ch.LevelModel:getLevelConfig(nextLevel).guai
	local names = {}
    for k,str in ipairs(zzy.StringUtils:split(nameStr,"|")) do
       local newStr = zzy.StringUtils:split(str,",")
       names[newStr[1]] =true
    end
    local needReleaseNames ={}
    for k,v in pairs(enemyRes) do
        if not names[k] then
            table.insert(needReleaseNames,k)
        end
    end
    for k,v in ipairs(needReleaseNames) do
        ch.RoleResManager:release(v)
        enemyRes[v] = nil
    end
end

function layer:clearEnemyRes()
    if enemyRes then
    	for k,v in pairs(enemyRes) do
    	   ch.RoleResManager:release(k)
    	end
    	enemyRes = {}
	end
end

function layer:clearAllRes()
    local roleRes = {"","mainRoleEffect","xiaoxiannv","baoxiang_NPC"}
    roleRes[1] = ch.UserTitleModel:getAvatar()
    local petName = GameConfig.PartnerConfig:getData(ch.PartnerModel:getCurPartner()).apath
    table.insert(roleRes,petName)
    for k,v in pairs(roleRes) do
        ch.RoleResManager:release(v)
    end
    self:clearEnemyRes()
end

function layer:stop()
    if _damageLayer then
	   _damageLayer:removeAllChildren()
	end
    for _,role in pairs(_enemys) do
        role:destory()
    end
    _enemys = nil
    if _mainRole then
        _mainRole:destory()
        _mainRole = nil
    end
    self:clearFamiliar()
end

function layer:removeEnemy(enemy)
	for k,v in ipairs(_enemys) do
	   if enemy == v then
            table.remove(_enemys,k)
            break
	   end
	end
end

function layer:clearRole(isRemovedMainRole)
    for _,role in pairs(_enemys) do
        role:destory()
    end
    if _mainRole then
        if isRemovedMainRole then
            self:clearMainRole()
        else
            _mainRole:setRoleVisible(false)
            _mainRole:setPosition(-100,0)
            _mainRole:reset()
            if _familiar then
                _familiar:setVisible(false)
            end
        end
    end
    _enemys = {}
end

function layer:clearMainRole()
	local oldName = _mainRole.roleName
    local oldPetName = _mainRole.chongwu.petName
    _mainRole:destory()
    ch.RoleResManager:release(oldName)
    ch.RoleResManager:release(oldPetName)
    self:clearFamiliar()
    _mainRole = nil
end

function layer:doEffect(atker, defer, type, ...)
    local args = {...}
    if type == 1 then
        local harm = 0
        if ch.LevelController.mode == ch.LevelController.GameMode.warpath then
            harm = ch.MagicModel:getWarpathTotalDPS()
        else
            harm = ch.MagicModel:getTotalDPS()
        end
        defer:underAttack(ch.LongDouble:floor(args[1] * harm * GameConst.MGAIC_HARM_RATIO))
    else
        if type == 2 then
            local apos = atker:getPositionX()
            local dpos = defer:getPositionX()
            local dir = dpos > apos and 1 or (apos > dpos and -1 or atker:getDir())
            defer:kickMove(args[1], args[2] * dir)
        elseif type == 3 then
            defer:kickFly(args[1], args[2])
        elseif type == 4 then
            --ch.fightBackground:shock() --去掉震屏
        end
    end
end

function layer:getEnemy(index)
    return _enemys[index]
end

function layer:getNewestAliveEnemy()
    local count = #_enemys
    while count > 0 do
    	if not _enemys[count].isdie then
    	   return _enemys[count]
    	end
    	count = count - 1
    end
    return nil
end

function layer:getNearestEnemy(index)
    local enemy = nil
    local minX = 0
    if _enemys and #_enemys>0 then
        for i=1,#_enemys do
            if not _enemys[i].isdie then
                local x = _enemys[i]:getPositionX()
                if not enemy or x < minX then
                    enemy = _enemys[i]
                    minX = x
                end
            end
        end
    end
    return enemy
end

function layer:getEnemies()
    return _enemys
end

function layer:getEnemyRoles(selecter)
    local posx = _mainRole:getPositionX()
    local dir = _mainRole:getDir()
    local distanceBase = selecter % 100000
    local type = math.floor(selecter / 100000)
    if type == 1 then
        return {_mainRole}
    else
        local enemys = {}
        local minDistance = 100000
        for _,enemy in ipairs(_enemys) do
            if not enemy.isdie then
                local enemypos = enemy:getPositionX()
                local distance = distanceBase + enemy.config.w
                local ok = false
                if type == 2 then
                    local dis = (enemypos - posx) * dir
                    if dis > 0 and dis <= distance then
                        ok = table.maxn(enemys) == 0
                        if ok then
                            minDistance = dis
                        else
                            ok = dis > 0 and dis < minDistance
                            if ok then
                                minDistance = dis
                                enemys = {}
                            end
                        end
                    end
                elseif type == 3 then
                    local temp = (enemypos - posx) * dir
                    ok = temp > 0 and temp <= distance
                elseif type == 4 then
                    ok = math.abs(enemypos - posx) <= distance
                elseif type == 5 then
                    local dis = math.abs(enemypos - posx)
                    if dis <= distance then
                        ok = table.maxn(enemys) == 0
                        if ok then
                            minDistance = dis
                        else
                            ok = dis > 0 and dis < minDistance
                            if ok then
                                minDistance = dis
                                enemys = {}
                            end
                        end
                    end
                end
                if ok then
                    table.insert(enemys, enemy)
                end
            end
        end
        return enemys
    end
end

function layer:isPause()
    return _isPause
end

function layer:pause()
    if _isPause then return end
    _isPause = true
    if _mainRole then
        _mainRole:pauseAnimation()
    end
    for i,enemy in ipairs(_enemys) do
        enemy:pauseAnimation()
    end
end

function layer:resume()
    if not _isPause then return end
    _isPause = false
    if _mainRole then
        _mainRole:resumeAnimation()
    end
    for i,enemy in ipairs(_enemys) do
        enemy:resumeAnimation()
    end
end

function layer:addRole(role)
    _layer:addChild(role)
end

function layer:getLayer()
    return _layer
end

return layer