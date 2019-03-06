require "src.clickhero.fight.svr.load_module"
require "src.clickhero.fight.svr.mod.baseobj.init"
require "src.clickhero.fight.svr.mod.cardbattle.init"

local Battle = _M["mod/cardbattle/battle"].Battle 
local CombatUnit = _M["mod/cardbattle/combatunit"].CombatUnit
_M["mod/cardbattle/skdata"].card_skill = GameConfig.CardskillConfig:getTable()

local CardFightMap = {
    _layer = nil,
    _fightInfo = nil,
    _curStage = nil,
    _eventId = nil,
    _curRound = nil,
    _attacker = nil,
    _defender = nil,
    _attackerData = nil,
    _defenderData = nil,
    _hasRaisedSkill = nil,
    _renderer = nil,
    _roleRes = nil,
    _familiars = nil,
    _fightType = nil,
    _svnWin = nil,
    _isPaused = nil,
    _timeId = nil,
    _skillStage = nil,
    _isEnding = nil,
    _state = nil,
    _exeTime = nil,
    State = {
        began = 1,
        ended = 2
    },
    RoleType = {
        attacker = 1,
        defender = 2
    },
    cardFightCompletedEvent = "CARD_FIGHT_COMPLETED_EVENT" -- {type =,win =0/1}
}

local battle = nil

local time = nil

function CardFightMap:init(attacker,defender,seed,fightType,svnWin)
    self._attackerData = attacker
    self._defenderData = defender
   
    local attackerZL = ch.PetCardModel:getTeamPower(attacker.sk)
    local defenderZL = ch.PetCardModel:getTeamPower(defender.sk)
    
    DEBUG("attackerZL="..attackerZL)
    DEBUG("defenderZL="..defenderZL)
    
    local ratio = 1.3
    --tgx
    if svnWin ==  1 then
        local adRatio = attackerZL/defenderZL
        local exRatio = 1
        if adRatio < ratio then
            exRatio = ratio / adRatio
        end

        for k,v in pairs(self._attackerData.attr) do
            self._attackerData.attr[k] = v*exRatio
        end
    else
        local daRatio = defenderZL/attackerZL
        local exRatio = 1
        if daRatio < ratio then
            exRatio = ratio / daRatio
        end

        for k,v in pairs(self._defenderData.attr) do
            self._defenderData.attr[k] = v*exRatio
        end
    end
    
    self._fightType = fightType
    self._svnWin = svnWin
    self._isPaused = false
    if self._attackerData.role.userId == ch.PlayerModel:getPlayerID() then
        self._attackerData.role.name = GameConst.CARD_RECODE_SYSTEM[10]
    elseif self._defenderData.role.userId == ch.PlayerModel:getPlayerID() then
        self._defenderData.role.name = GameConst.CARD_RECODE_SYSTEM[10]
    end
    -- 副本
    if self._fightType == 102 then
        local cardId = zzy.StringUtils:split(self._defenderData.role.userId,"_")[2]
        self._defenderData.role.name = GameConfig.CardConfig:getData(tonumber(cardId)).name
    end
    
    self._skillStage = {}
    self._layer = cc.Layer:create()
    self._layer:setPositionY(ch.editorConfig:getSceneGlobalConfig().roleh)
    local backSprite = cc.Sprite:create("res/scene/cardBackground.png")
    backSprite:setAnchorPoint(cc.p(0,0))
    backSprite:setPositionY(-112)
    self._layer:addChild(backSprite)
    ch.UIManager:getAutoFightLayer():addChild(self._layer,20)
    ch.CardFightRole:initSkill()
    self:initBattleData(attacker,defender, 0 or seed) --tgx
    self:initRoles(attacker,defender)
    ch.CardFightView:init(attacker,defender)
    ch.UIManager:getActiveSkillLayer():setVisible(false)
    ch.UIManager:getMainViewLayer():setVisible(false)
    self._layer:addChild(ch.CardFightView:getRenderer())
    self._eventId = zzy.EventManager:listen(zzy.Events.TickEventType, function()
        if self._isEnding or self._isPaused then return end
        if self._exeTime and os_clock() > self._exeTime then
            self._exeTime = nil
            if self._state == self.State.began then
                self:roleStartAttack()
            elseif self._state == self.State.ended then
                self:roleEndAttack()
            end
        end
        if self._attacker then self._attacker:update() end
        if self._defender then self._defender:update() end
    end)
    ch.RoleResManager:loadEffect("tx_kapaishifang")
    ch.RoleResManager:loadEffect("tx_baojishanbi")
    ch.RoleResManager:loadEffect("tx_shifangkapai")
    ch.RoleResManager:loadEffect("tx_xuetiaoxiaoguo")
    
--    cclog("进攻方")
--    for k,v in ipairs(attacker.sk) do
--        cclog(v.skid)
--    end
--    cclog("防守方")
--    for k,v in ipairs(defender.sk) do
--        cclog(v.skid)
--    end
--    cclog("随机数 "..seed)
--    cclog("攻击方属性......")
--    cclog(json.encode(attacker))
--    
--    cclog("防守方属性......")
--    cclog(json.encode(defender))
--    
--    cclog("服务器血量........")
--    cclog("攻击方：当前血量  "..string.format("%.2f",battle.uarray[2].hp) .. " 最大血量 "..string.format("%.2f",battle.uarray[2].max_hp))
--    cclog("防守方：当前血量  "..string.format("%.2f",battle.uarray[1].hp) .. " 最大血量 "..string.format("%.2f",battle.uarray[1].max_hp)) 
 
    self:fightReady()
end

function CardFightMap:pause()
	if self._isPaused or not self._layer then return end
    self._isPaused = true
    if self._attacker then
        self._attacker:pause()
    end
    if self._defender then
        self._defender:pause()
    end
end

function CardFightMap:resume()
    if not self._isPaused or not self._layer then return end
    self._isPaused = false
    if self._attacker then
        self._attacker:resume()
    end
    if self._defender then
        self._defender:resume()
    end
end

function CardFightMap:fightReady()
    local callf
    callf = function()
        if self._isEnding then return end
        if self._attacker and self._defender then
            self._attacker:playMove()
            local act = cc.MoveTo:create(0.5,cc.p(210,0))
            local seq = cc.Sequence:create(act,cc.CallFunc:create(function()
                self._attacker:playStand()
                self._defender:playStand()
                self:fightStarted()
            end))
            self._attacker:runAction(seq)
            self._defender:playMove()
            local act2 = cc.MoveTo:create(0.5,cc.p(430,0))
            self._defender:runAction(act2)
            self._timeId = nil
        else
            self._timeId = zzy.TimerUtils:setTimeOut(0,callf)
        end
    end
    ch.CardFightView:startAction(callf)
    ch.CardFightView:showRecord(3,GameConst.CARD_RECODE_SYSTEM[1])
end

function CardFightMap:fightStarted()
    self._curRound = 0
    self._curStage = 0
    ch.CardFightView:showRecord(3,GameConst.CARD_RECODE_SYSTEM[2])
    
    
--    cclog("初始属性////////////////////")
--    self:RecordProperty(self.RoleType.attacker)
--    self:RecordProperty(self.RoleType.defender)
--    cclog("初始属性////////////////////")
    
    
    self._fightInfo = battle:FightRound(1)
    self:RaiseStartSkill()
    self:RecoverStartHP()
    self:roundStarted(self._fightInfo)
end

function CardFightMap:fightEnded(win)
    local winName,lostName,aName
    if win == 1 then
        winName = self._attackerData.role.name
        lostName = self._defenderData.role.name
        aName = "tx_tiaozhanchenggong"
        self._defender:die()
    else
        winName = self._defenderData.role.name
        lostName = self._attackerData.role.name
        aName = "tx_shibai"
        self._attacker:die()
    end
    
--    if win ~= self._svnWin then
--        cclog("战斗结果不一致")
--    end
    
    ch.CardFightView:showRecord(4,string.format(GameConst.CARD_RECODE_SYSTEM[8],lostName))
    ch.CardFightView:showRecord(4,string.format(GameConst.CARD_RECODE_SYSTEM[9],winName))
    self._fightInfo  = nil
    self._hasRaisedSkill = nil
    self._curStage = nil
    self._curRound = nil
    self._isEnding = true
    ch.RoleResManager:loadEffect(aName,function()
        local ani = ccs.Armature:create(aName)
        ani:getAnimation():play("play",-1,0)
        ani:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
            if movementType == ccs.MovementEventType.complete then
                ani:removeFromParent()
                ch.RoleResManager:releaseEffect(aName)
                self._isEnding = nil
                self:close()
            end
        end)
        ani:setPosition(320,100)
        self._layer:addChild(ani)
    end)
end

function CardFightMap:skipFight()
    if self._isEnding then return end
    if not self._attacker or not self._defender then return end
    self._attacker:playStand()
    self._defender:playStand()
    self._attacker:setLocalZOrder(0)
    self._defender:setLocalZOrder(0)
    if self._timeId then
        zzy.TimerUtils:cancelTimeOut(self._timeId)
    end
    self:fightEnded(self._svnWin)
end

function CardFightMap:close()
    ch.UIManager:getActiveSkillLayer():setVisible(true)
    ch.UIManager:getMainViewLayer():setVisible(true)
    self:openPage(self._fightType,self._svnWin == 1)
    ch.CardFightMap:destroy()
    ch.LevelController:startNormal()
end


function CardFightMap:roundStarted(fightInfo)
    self._curRound = self._curRound + 1
    self._curStage = 0
    self._fightInfo = fightInfo and fightInfo or battle:FightRound(self._curRound)
    ch.CardFightView:showRecord(3,string.format(GameConst.CARD_RECODE_SYSTEM[3],self._curRound))
    self:attackStart()
end

function CardFightMap:roundEnded()
--    cclog("服务器血量........")
--    cclog("攻击方：当前血量  "..string.format("%.2f",battle.uarray[2].hp) .. " 最大血量 "..string.format("%.2f",battle.uarray[2].max_hp))
--    cclog("防守方：当前血量  "..string.format("%.2f",battle.uarray[1].hp) .. " 最大血量 "..string.format("%.2f",battle.uarray[1].max_hp))
--    cclog("客户端血量.......")
--    cclog("攻击方：当前血量  "..string.format("%.2f",self._attacker._hp) .. " 最大血量 "..string.format("%.2f",self._attacker._maxHp))
--    cclog("防守方：当前血量  "..string.format("%.2f",self._defender._hp) .. " 最大血量 "..string.format("%.2f",self._defender._maxHp))
--    cclog(json.encode(self._fightInfo))
--    self:RecordProperty(self.RoleType.attacker)
--    self:RecordProperty(self.RoleType.defender)
    
    
    if self._fightInfo.win then
        self:fightEnded(self._fightInfo.win)
    else
        self:roundStarted()
    end
end

function CardFightMap:attackStart()
    self._curStage = self._curStage + 1
    local aName = self._curStage == 1 and self._defenderData.role.name or self._attackerData.role.name
    ch.CardFightView:showRecord(3,string.format(GameConst.CARD_RECODE_SYSTEM[4],aName))
    self:onAttackStarted()
    local count = self:getRaiseSkillCount(1)
    local delayTime = count > 0 and 0.5 or 0.2
    self._exeTime = os_clock() + delayTime
    self._state = self.State.began
end

function CardFightMap:roleStartAttack()
    if self._curStage == 1 then
        self._defender:attack(self._attacker)
        self._defender:setLocalZOrder(1)
    else
        self._attacker:attack(self._defender)
        self._attacker:setLocalZOrder(1)
    end
end

function CardFightMap:roleEndAttack()
    local sta = self._curStage + 1
    if self._fightInfo[sta] and
        (self._fightInfo[sta].harm or self._fightInfo[sta].isDodge) then
        self:attackStart()
    else
        self:roundEnded()
    end
    ch.CardBufferManager:RoundEnd()
end

function CardFightMap:attackEnd()
    self:onAttackEnded()
    self._attacker:setLocalZOrder(0)
    self._defender:setLocalZOrder(0)
    local count = self:getRaiseSkillCount(1)
    local delayTime = count > 0 and 0.5 or 0.2
    self._exeTime = os_clock() + delayTime
    self._state = self.State.ended
end

function CardFightMap:onAttackStarted()
    self._hasRaisedSkill = false
    self:RaiseSkill(1)
    self:RecoverHp(1)
end

function CardFightMap:onAttacking(role,ratio)  
    if not self._hasRaisedSkill then
        self._hasRaisedSkill = true
        self:RecordHarm(self:isDodge(),self:isCrit())
        self:RaiseSkill(2)
       -- local role = self._curStage == 1 and self._attacker or self._defender
        local x = self._curStage == 1 and -150 or 150
        if self:isCrit() then
            self:showDodgeOrCrit(role:getPositionX()+x,1)
        elseif self:isDodge() then
            self:showDodgeOrCrit(role:getPositionX()+x,2)
        end
        if self:getRaiseSkillCount(2,self.RoleType.attacker) > 0 then
            self._attacker:showSkillEffect()
        end
        if self:getRaiseSkillCount(2,self.RoleType.defender) > 0 then
            self._defender:showSkillEffect()
        end
    end
    self:RecoverHp(2,ratio)
end

function CardFightMap:onAttackEnded()
    self:RaiseSkill(3)
    self:RecoverHp(3)
end

function CardFightMap:RaiseSkill(stage)
    for k,roleType in pairs(self.RoleType) do
        local role = roleType == self.RoleType.attacker and self._attacker or self._defender
        local skill = self:getSkill(roleType)
        if skill and skill[stage] then
            for _,s in ipairs(skill[stage]) do
                ch.CardFightView:raiseSkill(roleType,s.id)
                self:RecordSkill(roleType,stage,s.id)
                local conf =  GameConfig.CardskillConfig:getData(s.id)
                for i = 1,3 do
                    if conf["target"..i] > 0 then
                        if conf["target_attr"..i] == 1 then
                            local maxHp = self:_getSkillValue(roleType,s.id,conf,i)
                            role:addMaxHp(maxHp)
                        end
                    else
                        break
                    end
                end 
                if not self._skillStage[s.id] then
                    self._skillStage[s.id] = stage
                end
            end
        end
    end
end

---
-- 开局技能    
function CardFightMap:RaiseStartSkill()
	for i = 1,2 do
	   self._curStage = i
	   self:RaiseSkill(4)
	end
	self._curStage = 0
end

---
-- 开局回血
function CardFightMap:RecoverStartHP()
    for i = 1,2 do
        self._curStage = i
        self:RecoverHp(4)
    end
    self._curStage = 0
end

function CardFightMap:getRaiseSkillCount(stage,roleType)
    local count = 0
    if roleType ~= self.RoleType.defender then
    	local skillData = self:getSkill(self.RoleType.attacker)
    	if skillData and skillData[stage] then
            count = count + #skillData[stage]
    	end
	end
    if roleType ~= self.RoleType.attacker then
    local skillData = self:getSkill(self.RoleType.defender)
        if skillData and skillData[stage] then
            count = count + #skillData[stage]
        end
    end
    return count
end

function CardFightMap:RecoverHp(stage,ratio)
     for k,roleType in pairs(self.RoleType) do
        local role = roleType == self.RoleType.attacker and self._attacker or self._defender
        local addHp,subHp = self:_getStageHp(roleType,stage)
        if addHp > 0 then
            if ratio then addHp = addHp * ratio end
            role:recoveHP(addHp)
        end
        if subHp < 0 then
            if ratio then subHp = subHp * ratio end
            role:recoveHP(subHp)
        end
     end
end

function CardFightMap:_getStageHp(roleType,stage)
    local addHp,subHp = 0,0
    local hpData = self:getRecoverHP(roleType)
    if hpData then hpData = hpData[1] end
    if not hpData then return addHp,subHp end
    for _,hpv in ipairs(hpData) do
        if self._skillStage[hpv.id] == stage then
            if hpv.hp > 0 then
                addHp = addHp + hpv.hp
            else
                subHp = subHp + hpv.hp   
            end
        end
    end
    return addHp,subHp
end

function CardFightMap:RecordSkill(roleType,stage,id)
    local config = GameConfig.CardskillConfig:getData(id)
    local selfName,enemyName,cardName
    if roleType == self.RoleType.attacker then
        selfName = self._attackerData.role.name
        enemyName = self._defenderData.role.name
        cardName = self:_getCardNameBySkillId(self._attackerData,id)
	else
        selfName = self._defenderData.role.name
        enemyName = self._attackerData.role.name
        cardName = self:_getCardNameBySkillId(self._defenderData,id)
    end
    local text = string.format(GameConst.CARD_RECORD_SKILL,selfName,cardName,config.name)
    for i= 1,3 do
        if config["target"..i] > 0 then
            local name = config["target"..i] == 1 and selfName or enemyName
            local pName = GameConst.CARD_RECODE_PROPERTY[config["target_attr"..i]]
            local eName
            if config["target_attr"..i] == 2 then
                eName = config["target_rate"..i] >0 and GameConst.CARD_RECODE_ENAME[3] or GameConst.CARD_RECODE_ENAME[4]
            else
                eName = config["target_rate"..i] >0 and GameConst.CARD_RECODE_ENAME[1] or GameConst.CARD_RECODE_ENAME[2]
            end
            local vStr = self:_getSkillValue(roleType,id,config,i)
            if config["target_attr"..i] >=7 and config["target_attr"..i] <=10 then
                vStr = vStr * 100
                vStr = string.format("%d%%",math.floor(math.abs(vStr)) + 0.5)
            else
                vStr = math.floor(math.abs(vStr) + 0.5)
            end
            text = text..", "..string.format(GameConst.CARD_RECORD_EFFECT,name,pName,eName,vStr)
	   else
	       break
	   end
	end
	ch.CardFightView:showRecord(roleType,text)
end

function CardFightMap:RecordHarm(isDodge,isCrit)
    local aName,dName
    if self._curStage == 1 then
        aName = self._defenderData.role.name
        dName = self._attackerData.role.name
    else
        aName = self._attackerData.role.name
        dName = self._defenderData.role.name
    end
    local showType = self._curStage == 1 and 2 or 1
    if isDodge then
        local text = string.format(GameConst.CARD_RECODE_SYSTEM[6],aName,dName,dName)
        ch.CardFightView:showRecord(showType,text)
    elseif isCrit then
        local text = string.format(GameConst.CARD_RECODE_SYSTEM[7],aName,dName,self._fightInfo[self._curStage].harm)
        ch.CardFightView:showRecord(showType,text)
    else
        local text = string.format(GameConst.CARD_RECODE_SYSTEM[5],aName,dName,self._fightInfo[self._curStage].harm)
        ch.CardFightView:showRecord(showType,text)
    end
end

function CardFightMap:_getSkillValue(roleType,id,cf,index)
    local value = 0
    local selfRole = roleType == self.RoleType.attacker and battle.uarray[2] or battle.uarray[1]
    local enemyRole = roleType == self.RoleType.attacker and battle.uarray[1] or battle.uarray[2]
--    if cf["target_attr"..index] == 2 then
--        cclog(id)
--        local hpInfo = self:getRecoverHP(roleType)[1]
--        for _,info in ipairs(hpInfo) do
--            if info.id == id then
--                value = info.hp
--                break
--            end
--        end
--    else
        local tarRole = cf["target"..index] == 1 and selfRole or enemyRole
        if cf["target_rule"..index] == 1 then
            value = cf["target_rate"..index]/10000
        else
            local baseValue = self:_getRolePropertyByType(tarRole,cf["target_attr"..index])
            value = baseValue * cf["target_rate"..index]/10000
        end
--    end
    return value
end

function CardFightMap:_getRolePropertyByType(unit,type)
    if type == 1 then
        return unit.base_max_hp
    elseif type == 2 then
        return unit.max_hp
    elseif type == 3 then
        return unit.base_damage
    elseif type == 4 then
        return unit.base_cs
    elseif type == 5 then
        return unit.base_defence
    elseif type == 6 then
        return unit.base_dodge
    elseif type == 7 then
        return unit.base_csm
    elseif type == 8 then 
        return unit.base_defm
    elseif type == 9 then
        return unit.base_dgm
    elseif type == 10 then
        return unit.base_tdg
    elseif type == 11 then
        return unit.base_csd
    else
        return 0
    end
end

function CardFightMap:_getCardNameBySkillId(data,id)
    for k,skill in pairs(data.sk) do
        local config = GameConfig.CardConfig:getData(skill.id)
	   if config.skillid == id then
	       return config.name
	   end
	end
end

function CardFightMap:RecordProperty(roleType)
    local text = roleType == self.RoleType.attacker and self._attackerData.role.name or self._defenderData.role.name
    local unit = roleType == self.RoleType.attacker and battle.uarray[2] or battle.uarray[1]
    cclog(text.."血量 "..string.format("%.2f",unit.hp)..",攻击 "..unit.damage..",暴击 "..unit.cs..",防御 "..unit.defence
        ..",闪避 "..unit.dodge..",暴击率 "..unit.csm..",免伤率 ".. string.format("%.2f",unit.defm)..",闪避率 "..string.format("%.2f",unit.dgm)..",暴击倍率 "..unit.csd)
end

--function CardFightMap:RecordSkill(stage)
--    local attSkill = self:getSkill(self.RoleType.attacker)
--    if attSkill and attSkill[stage] then
--        for _,skill in ipairs(attSkill[stage]) do
--            cclog("A触发了技能  " .. skill.id .. "  名称："..GameConfig.CardskillConfig:getData(skill.id).name)
--        end
--    end
--    local defSkill = self:getSkill(self.RoleType.defender)
--    if defSkill and defSkill[stage] then
--        for _,skill in ipairs(defSkill[stage]) do
--            cclog("B触发了技能  " .. skill.id.."  名称："..GameConfig.CardskillConfig:getData(skill.id).name)
--        end
--    end
--end

function CardFightMap:initRoles(attacker,defender)
    self._roleRes = {}
    self._familiars = {}
    local role1,weapon1 = ch.UserTitleModel:getAvatarByLevel(attacker.role.maxLevel -1,attacker.role.gender)
    self._roleRes[1] = role1
    ch.RoleResManager:load(role1,function()
        self._attacker = self:createRole(attacker.attr.hp,role1,weapon1,1,attacker.attr.max_hp)
        self._attacker:setPositionX(-120)
        self._layer:addChild(self._attacker)
        if attacker.role.fid then
            local name = GameConfig.FamiliarConfig:getData(attacker.role.fid).avatar
            ch.RoleResManager:load(name, function()
                local f = ch.familiarRole:create(attacker.role.fid,ch.familiarRole.Orientation.right)
                f:initTarget(self._attacker)
                self._familiars[self.RoleType.attacker] = f
                self._layer:addChild(f)
            end)
        end
    end)
    local role2,weapon2 = ch.UserTitleModel:getAvatarByLevel(defender.role.maxLevel -1,defender.role.gender)
    self._roleRes[2] = role2
    ch.RoleResManager:load(role2,function()
        self._defender = self:createRole(defender.attr.hp,role2,weapon2,-1,defender.attr.max_hp)
        self._defender:setPositionX(760)
        self._layer:addChild(self._defender)
        if defender.role.fid then
            local name = GameConfig.FamiliarConfig:getData(defender.role.fid).avatar
            ch.RoleResManager:load(name, function()
                local f = ch.familiarRole:create(defender.role.fid,ch.familiarRole.Orientation.left)
                f:initTarget(self._defender)
                self._familiars[self.RoleType.defender] = f
                self._layer:addChild(f)
            end)
        end
    end)
end

function CardFightMap:initBattleData(attacker,defender,seed)
    battle = Battle:New()
    battle:SetRandSeed(seed)
    local att = self:createCombatUnit(attacker)
    att.is_attacker = 1
    battle:AddUnit(att)
    local def = self:createCombatUnit(defender)
    def.is_attacker = 0
    battle:AddUnit(def)
    battle:Init()
end

function CardFightMap:createCombatUnit(data)
    local unit = CombatUnit:New()
    unit.hp = data.attr.hp
    unit.max_hp = data.attr.max_hp
    unit.damage = data.attr.damage
    unit.cs = data.attr.cs
    unit.defence = data.attr.defence
    unit.dodge = data.attr.dodge
    for i= 1,5 do
        if data.sk[i] then
            unit:AddSkillID(GameConfig.CardConfig:getData(data.sk[i].id).skillid)
        end
    end
    unit:Init()
    return unit
end

function CardFightMap:showRoleHP(role,isCrit,hp)
    local roleType = self._attacker == role and self.RoleType.attacker or self.RoleType.defender
    ch.CardFightView:showHP(roleType,role:getHPRatio())
    if hp>0 then
        self:showRecoverHP(role:getPositionX(),hp)
    else
        self:showDamage(role:getPositionX(),isCrit,-hp)
    end    
end

function CardFightMap:createRole(hp,role,weapon,scaleX,maxHp)
    local role = ch.CardFightRole:create(hp,role,weapon,scaleX,maxHp)
    role:setAttackingCallBack(function(role,ratio)
        self:onAttacking(role,ratio)
    end)
    role:setAttackCompletedCallBack(function()
        self:attackEnd()
    end)
    return role
end

function CardFightMap:destroy()
	ch.CardFightView:close()
	ch.CardBufferManager:Close()
	if self._timeId then
        zzy.TimerUtils:cancelTimeOut(self._timeId)
	end
	self._attacker:destroy()
	self._defender:destroy()
	self._renderer = nil
	self._attacker = nil
	self._defender = nil
    self._skillStage = nil
    self._fightType = nil
    self._svnWin = nil
    self._isEnding = nil
    self._exeTime = nil
    self._isPaused = nil
    for l,f in pairs(self._familiars) do
        local name = f:getAvatarName()
        f:destroy()
        ch.RoleResManager:release(name)
    end
    self._familiars = nil
    self._layer:removeFromParent()
    self._layer = nil
    zzy.EventManager:unListen(self._eventId)
    ch.RoleResManager:releaseEffect("tx_baojishanbi")
    ch.RoleResManager:releaseEffect("tx_kapaishifang")
    ch.RoleResManager:releaseEffect("tx_shifangkapai")
    ch.RoleResManager:releaseEffect("tx_xuetiaoxiaoguo")
    for _,v in ipairs(self._roleRes) do
        if v ~= ch.UserTitleModel:getAvatar() then
            ch.RoleResManager:release(v)
        end
    end
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

function CardFightMap:getHarm()
    if self._fightInfo[self._curStage] then
        return self._fightInfo[self._curStage].harm or 0
    end
    return 0
end

function CardFightMap:isCrit()
    if self._fightInfo[self._curStage] then
        return self._fightInfo[self._curStage].isCrit
    end
    return false
end

function CardFightMap:isDodge()
    if self._fightInfo[self._curStage] then
        return self._fightInfo[self._curStage].isDodge
    end
    return false
end

function CardFightMap:getSkill(roleType)
    if not self._fightInfo[self._curStage] or 
        not self._fightInfo[self._curStage].skill then return end
    return self._fightInfo[self._curStage].skill[roleType]
end

function CardFightMap:getRecoverHP(roleType)
    if not self._fightInfo[self._curStage] or 
        not self._fightInfo[self._curStage].recover then return end
    return self._fightInfo[self._curStage].recover[roleType]
end

local time = 0.6
function CardFightMap:showDamage(posx, isCrit, value)
    value = math.ceil(value)
    local fontTmp = isCrit and "res/ui/aaui_font/font_crtical.fnt" or "res/ui/aaui_font/font_red.fnt"
    local text = ccui.TextBMFont:create("-"..value, fontTmp)
    self._layer:addChild(text)
    text:setPosition(posx,251)
    if isCrit then
        text:runAction(cc.EaseOut:create(cc.MoveBy:create(time, cc.vertex2F(0, 200)), time))
        text:runAction(cc.Sequence:create(cc.EaseOut:create(cc.FadeOut:create(time), time), cc.CallFunc:create(function()
            text:removeFromParent()
        end)))
        text:setLocalZOrder(1000)
    else
        text:runAction(cc.EaseOut:create(cc.MoveBy:create(time, cc.vertex2F(0, 200)), time))
        text:runAction(cc.Sequence:create(cc.EaseOut:create(cc.FadeOut:create(time), time), cc.CallFunc:create(function()
            if zzy.CocosExtra.isCobjExist(text) then text:removeFromParent() end
        end)))
    end
end

---
-- 显示闪避或者暴击
-- @function [parent=#CardFightMap] showDodgeOrCrit
-- @param #number posx
-- @param #number type 1为暴击，2为闪避
function CardFightMap:showDodgeOrCrit(posx, type)
    local ani = ccs.Armature:create("tx_baojishanbi")
    ani:setPosition(posx,100)
    ani:setScale(0.6)
    self._layer:addChild(ani)
    local name = type == 1 and "baoji" or "shanbi"
    ani:getAnimation():play(name,-1,0)
	ani:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
	   if movementType == ccs.MovementEventType.complete then
	       ani:removeFromParent()
	   end
	end)
end

function CardFightMap:openPage(fightType,isWin)
    if fightType == 101 or fightType == 201 then -- 天梯
        ch.ArenaModel:setWin(isWin)
        ch.NetworkController:arenaPanel()
    elseif fightType == 202 or fightType == 103 then -- 祭坛掠夺
        ch.UIManager:showGamePopup("card/W_jt_main")
        if isWin then
            ch.UIManager:showGamePopup("card/W_card_rob_result")
        end
    elseif fightType == 102 then -- 副本
        ch.UIManager:showGamePopup("cardInstance/W_cardins",nil,nil,nil,"cardInstance/W_cardins")
        -- 定位
        local evt = {type = ch.CardFBModel.cardPopOpenEventType}
        zzy.EventManager:dispatch(evt)
        if isWin then
            ch.UIManager:showGamePopup("cardInstance/W_Result")
        end 
    elseif fightType == 204 then -- 抢矿
        ch.UIManager:showGamePopup("CardPit/W_pit") 
        ch.NetworkController:minePageData(ch.MineModel:getCurPage())
        if isWin then
            ch.UIManager:showGamePopup("CardPit/W_pit_occ",ch.MineModel:getAttackWinId())
        end
    elseif fightType == 10202 or fightType == 10103 then -- 祭坛战斗记录
        ch.UIManager:showGamePopup("card/W_jt_main")
        ch.UIManager:showGamePopup("card/W_jt_zhandoujilu")
    elseif fightType == 10101 or fightType == 10201 then -- 天梯战斗记录
        ch.UIManager:showGamePopup("card/W_tt")
        ch.UIManager:showGamePopup("card/W_tt_zhandoujilu")
    elseif fightType == 10204 then -- 抢矿战斗记录
        ch.UIManager:showGamePopup("CardPit/W_pit")
        ch.UIManager:showGamePopup("CardPit/W_pit_jilu")
    end
end

function CardFightMap:showRecoverHP(posx,value)
    value = math.ceil(value)
	local fontTmp = "res/ui/aaui_font/font_flow.fnt"
	zzy.TimerUtils:setTimeOut(0.2,function()
	    if not zzy.CocosExtra.isCobjExist(self._layer) then return end
	    local text = ccui.TextBMFont:create("+"..value, fontTmp)
        text:setScale(2)
        self._layer:addChild(text)
        text:setPosition(posx,251)
        text:runAction(cc.EaseOut:create(cc.MoveBy:create(time, cc.vertex2F(0, 200)), time))
        text:runAction(cc.Sequence:create(cc.EaseOut:create(cc.FadeOut:create(time), time), cc.CallFunc:create(function()
            text:removeFromParent()
        end)))
        text:setLocalZOrder(1000)
	end)
end

return CardFightMap

