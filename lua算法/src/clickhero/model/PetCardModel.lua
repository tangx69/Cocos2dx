---
-- 魔宠卡牌 model层     结构 {{l = 1,s = 0}, ... }
--@module PetCardModel
local PetCardModel = {
    _data = nil,
    _cardOrderData = nil,
    _getCardList = nil,
    _newCardList = nil,
    _newChipList = nil,
    _cardState = nil,
    _orderMyCard = nil,
    _detailMyCardOrder = nil,
    _runicSelect = nil,
    _totalPowerCache = nil,
    _powerDPSCache = nil,
    _powerLVCache = nil,
    dataChangeEventType = "PetCardModelDataChange", --{type = ,id=,dataType =}
    dataType = {
        level = 1,  -- 等级变化会引起数量变化
        chip = 2,   -- 数量变化
        clean = 3,  -- 清除缓存数据
        drop = 4,    -- 掉落卡牌
        order = 5,    -- 品质排序
        runicSelect = 6,    -- 选中使用通用符文
        talent = 7
    }
}

---
-- @function [parent=#PetCardModel] init
-- @param #PetCardModel self
-- @param #table data
function PetCardModel:init(data)
    self._data = data.petcard or {}
    self._getCardList = {}
    self._newCardList = {}
    self._newChipList = {}
    -- 获取所有卡牌ID并排序
    self:_orderPetCard()
    self:allMyCardID()
    self:setAllCardState()
    -- 所有卡牌总战力计算
    self:allPower()

    -- 存储到本地的万能符文选中状态
    local str = cc.UserDefault:getInstance():getStringForKey("CardSelectData")
    if str and str ~= "" and str~= "null" then
        self._runicSelect = json.decode(str)
    else
        self._runicSelect = {}
        for k,v in pairs(self._cardOrderData) do
            self._runicSelect[tostring(v)] = 0
        end
        cc.UserDefault:getInstance():setStringForKey("CardSelectData",json.encode(self._runicSelect))
    end
end


---
-- @function [parent=#PetCardModel] clean
-- @param #PetCardModel self
function PetCardModel:clean()
    self._data = nil
    self._cardOrderData = nil
    self._getCardList = nil
    self._newCardList = nil
    self._newChipList = nil
    self._cardState = nil
    self._orderMyCard = nil
    self._detailMyCardOrder = nil
    self._runicSelect = nil
    self._totalPowerCache = nil
    self._powerDPSCache = nil
    self._powerLVCache = nil
end

function PetCardModel:_raiseDataChangeEvent(id,dataType)
    local evt = {
        type = self.dataChangeEventType,
        id = id,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 排序卡牌，按顺序显示 
-- @function [parent=#PetCardModel] _orderPetCard
-- @param #PetCardModel self
function PetCardModel:_orderPetCard()
    local cs = GameConfig.CardConfig:getTable()
    self._cardOrderData = {}
    for k,v in pairs(cs) do
        if v.ty == 1 then
            table.insert(self._cardOrderData,v.id)
        end
    end
end

---
-- 排序卡牌，按顺序显示 
-- @function [parent=#PetCardModel] orderMyCard
-- @param #PetCardModel self
function PetCardModel:orderMyCard()
    table.sort(self._orderMyCard,function(t1,t2)
        local t1Level = self:getLevel(t1)
        local t2Level = self:getLevel(t2)
        if t1Level == t2Level then
            return t1 > t2
        else
            return t1Level > t2Level
        end
    end)
    self:_raiseDataChangeEvent(0,self.dataType.order)
end

---
-- 获取所有卡牌ID
-- @function [parent=#PetCardModel] getAllPetCardID
-- @param #PetCardModel self
-- @return #table
function PetCardModel:getAllPetCardID()
    local allCard = {}
    self._detailMyCardOrder = {}
    for k,v in ipairs(self._cardOrderData) do
        table.insert(allCard,v)
        if self:getLevel(v) > 0 then
            table.insert(self._detailMyCardOrder,v)
        end
    end
    -- 排序，可合成，可进阶，已获得，满级，未获得
    table.sort(allCard,function(t1,t2)
        local t1State = self:getCardState(t1)
        local t2State = self:getCardState(t2)
        if t1State == t2State then
            return t1 > t2
        else
            return t1State > t2State
        end
    end)

    table.sort(self._detailMyCardOrder,function(t1,t2)
        local t1State = self:getCardState(t1)
        local t2State = self:getCardState(t2)
        if t1State == t2State then
            return t1 > t2
        else
            return t1State > t2State
        end
    end)

    return allCard
end

---
-- 拥有的所有的卡
-- @function [parent=#PetCardModel] allMyCardID
-- @param #PetCardModel self
function PetCardModel:allMyCardID()
    self._orderMyCard = {}
    for k,v in ipairs(self._cardOrderData) do
        if self:getLevel(v) > 0 then
            table.insert(self._orderMyCard,v)
        end
    end
    self:orderMyCard()
end

---
-- 获取所有整卡ID(详情界面用)
-- @function [parent=#PetCardModel] getDetailCardID
-- @param #PetCardModel self
-- @return #table
function PetCardModel:getDetailCardID()
    return self._detailMyCardOrder
end

---
-- 获取所有整卡ID
-- @function [parent=#PetCardModel] getCardID
-- @param #PetCardModel self
-- @return #table
function PetCardModel:getCardID()
    return self._orderMyCard
end

---
-- 通过整卡ID获得index
-- @function [parent=#PetCardModel] getIndexByCardID
-- @param #PetCardModel self
-- @param #table cardList
-- @param #number id
-- @return #number
function PetCardModel:getIndexByCardID(cardList,id)
    for k,v in ipairs(cardList) do
        if id == v then
            return tonumber(k)
        end
    end
    return 1
end

---
-- 获取卡片等级
-- @function [parent=#PetCardModel] getLevel
-- @param #PetCardModel self
-- @param #number id
-- @return #number
function PetCardModel:getLevel(id)
    id = tostring(id)
    if self._data[id] then 
        return self._data[id].level
    else
        return 0
    end
end

---
-- 获取卡片当前资质
-- @function [parent=#PetCardModel] getTalent
-- @param #PetCardModel self
-- @param #number id
-- @return #number
function PetCardModel:getTalent(id)
    id = tostring(id)
    if self._data[id] and self._data[id].talent and self._data[id].talent > 0 then 
        return self._data[id].talent
    else
        return GameConfig.CardConfig:getData(tonumber(id)).talent
    end
end

---
-- 卡牌资质提升
-- @function [parent=#PetCardModel] talentUp
-- @param #PetCardModel self
-- @param #number id
-- @return #number
function PetCardModel:talentUp(id)
    id = tostring(id)
    if not self._data[id] then
        self._data[id] = {}
    end
    if not self._data[id].talent or self._data[id].talent < 1 then
        self._data[id].talent = GameConfig.CardConfig:getData(tonumber(id)).talent
    end
    self._data[id].talent = self._data[id].talent + 1
    
    -- 重新计算宝物攻击力
    ch.MagicModel:resetDPS(GameConfig.CardConfig:getData(tonumber(id)).magic)

    -- 升级后，修改阵容界面信息
    ch.ArenaModel:setMyCardListInit()
    for i=1,3 do
        ch.AltarModel:setMyCardListInit(i)
    end
    -- 重新计算总战力
    self:allPower()
    self:_raiseDataChangeEvent(tonumber(id),self.dataType.talent)
end

---
-- 设置所有卡牌状态  5可合成 4可进阶 3已获得 2满级 1未获得
-- @function [parent=#PetCardModel] setAllCardState
-- @param #PetCardModel self
function PetCardModel:setAllCardState()
    self._cardState = {}
    for k,v in ipairs(self._cardOrderData) do
        if self:getChipNum(v) >= self:getChipCost(v) then
            if self:getLevel(v) < 1 then
                self._cardState[v] = 5
            elseif self:getLevel(v) < GameConst.PETCARD_LEVEL_MAX then
                self._cardState[v] = 4
            else
                self._cardState[v] = 2
            end
        else
            if self:getLevel(v) < 1 then
                self._cardState[v] = 1
            else
                self._cardState[v] = 3
            end
        end
    end
end

---
-- 设置卡牌状态 5可合成 4可进阶 3已获得 2满级 1未获得
-- @function [parent=#PetCardModel] setCardState
-- @param #PetCardModel self
-- @param #number id
function PetCardModel:setCardState(id)
    if self:getChipNum(id) >= self:getChipCost(id) then
        if self:getLevel(id) < 1 then
            self._cardState[id] = 5
        elseif self:getLevel(id) < GameConst.PETCARD_LEVEL_MAX then
            self._cardState[id] = 4
        else
            self._cardState[id] = 2
        end
    else
        if self:getLevel(id) < 1 then
            self._cardState[id] = 1
        else
            self._cardState[id] = 3
        end
    end
end

---
-- 获得卡牌状态  5可合成 4可进阶 3已获得 2满级 1未获得
-- @function [parent=#PetCardModel] getCardState
-- @param #PetCardModel self
-- @param #number id
-- @return #number
function PetCardModel:getCardState(id)
    return self._cardState[id] or 1
end

---
-- 是否有可合成或可进阶卡牌 
-- @function [parent=#PetCardModel] ifEnoughPlayEffect
-- @param #PetCardModel self
-- @return #boolean
function PetCardModel:ifEnoughPlayEffect()
    for k,v in pairs(self._cardState) do
        if v == 5 or v == 4 then
            return true
        end
    end
    return false
end

---
-- 卡牌进阶（升级和获得）
-- @function [parent=#PetCardModel] addLevel
-- @param #PetCardModel self
-- @param #number id
-- @return #number
function PetCardModel:addLevel(id)
    id = tostring(id)
    if self._data[id] then
        self._data[id].level = self._data[id].level + 1
    else
        self._data[id]={}
        self._data[id].level = 1
        self._data[id].chip = 0
        self._data[id].talent = GameConfig.CardConfig:getData(tonumber(id)).talent
    end
    -- 重新计算宝物攻击力
    ch.MagicModel:resetDPS(GameConfig.CardConfig:getData(tonumber(id)).magic)
    -- 注意数量也会变化
    self:setCardState(tonumber(id))
    self:allMyCardID()
    -- 升级后，修改阵容界面信息
    ch.ArenaModel:setMyCardListInit()
    for i=1,3 do
        ch.AltarModel:setMyCardListInit(i)
    end
    -- 重新计算总战力
    self:allPower()
    self:_raiseDataChangeEvent(tonumber(id),self.dataType.level)
end

---
-- 卡牌碎片获得
-- @function [parent=#PetCardModel] addChip
-- @param #PetCardModel self
-- @param #number id
-- @param #number num
-- @return #number
function PetCardModel:addChip(id,num)
    id = tostring(id)
    if self._data[id] then
        self._data[id].chip = self._data[id].chip + num
    else
        self._data[id]={}
        self._data[id].level = 0
        self._data[id].chip = num
    end
    -- 判断卡牌可合成进阶状态
    self:setCardState(tonumber(id))
    self:_raiseDataChangeEvent(tonumber(id),self.dataType.chip)
end

---
-- 通过卡牌碎片ID增加卡牌碎片值
-- @function [parent=#PetCardModel] addChipByChipId
-- @param #PetCardModel self
-- @param #number id
-- @param #number num
-- @return #number
function PetCardModel:addChipByChipId(id,num)
    id = tonumber(id)
    local chipNum = num or 0
    local cardID = id
    local listID = id
    if id < 51000 then
        if self:getLevel(id) > 0 then
            chipNum = GameConfig.CardConfig:getData(id).mtnum*num
            listID = GameConfig.CardConfig:getData(id).mtid
        else
            self:addLevel(id)
            self:addCardList(id,1)
            chipNum = 0
            if num > 1 then
                chipNum = GameConfig.CardConfig:getData(id).mtnum*(num-1)
                listID = GameConfig.CardConfig:getData(id).mtid
            end
        end
    else
        cardID = GameConfig.CardConfig:getData(id).enid
    end
    self:addChip(cardID,chipNum)
    self:addCardList(listID,chipNum)
    self:_raiseDataChangeEvent(0,self.dataType.drop)
end

---
-- 获取对应碎片数量
-- @function [parent=#PetCardModel] getChipNum
-- @param #PetCardModel self
-- @param #number id
-- @return #number
function PetCardModel:getChipNum(id)
    id = tostring(id)
    if self._data[id] then 
        return self._data[id].chip
    else
        return 0
    end
end

---
-- 获取升级需要的碎片(默认当前等级)
-- @function [parent=#PetCardModel] getChipCost
-- @param #PetCardModel self
-- @param #number id
-- @param #number level
-- @return #number
function PetCardModel:getChipCost(id,level)
    level = level or self:getLevel(id)
    if level < 1 then
        local chipID = GameConfig.CardConfig:getData(tonumber(id)).mtid
        return GameConfig.CardConfig:getData(chipID).ennum
    elseif level >= GameConst.PETCARD_LEVEL_MAX then
        return 0
    else
        return GameConfig.CarduplevelConfig:getData(level).num
    end
end

---
-- 卡牌对相应宝物的影响
-- @function [parent=#PetCardModel] addMagicRatio
-- @param #PetCardModel self
-- @param #string magicId
-- @return #number
function PetCardModel:addMagicRatio(magicId)
    local tmpTable = GameConfig.CardConfig:getTable()
    for k,v in pairs(tmpTable) do
        if v.ty == 1 and v.magic == magicId then
            return math.pow(GameConst.MGAIC_PET_CARD_RATIO,self:getLevel(v.id))
        end
    end
end

---
-- 获取卡牌品质等级
-- @function [parent=#PetCardModel] getQuality
-- @param #PetCardModel self
-- @param #number id
-- @return #number
function PetCardModel:getQuality(id)
    id = tostring(id)
    if self._data[id] and self._data[id].level > 0 then 
        return self._data[id].level
    else
        return 1
    end
end

---
-- 获取卡牌品质等级
-- @function [parent=#PetCardModel] getStar
-- @param #PetCardModel self
-- @param #number id
-- @return #number
function PetCardModel:getStar(id)
    id = tostring(id)
    if self._data[id] and self._data[id].level > 0 then 
        return GameConfig.CarduplevelConfig:getData(self._data[id].level).star
    else
        return 0
    end
end

---
-- 卡牌获得记录
-- @function [parent=#PetCardModel] addCardList
-- @param #PetCardModel self
-- @param #number id
-- @param #number num
function PetCardModel:addCardList(id,num)
    if self._getCardList[id] then
        self._getCardList[id] = self._getCardList[id]+num
    else
        self._getCardList[id] = num
    end
    if id < 51000 then
        self._newCardList[id] = true
    else
        self._newChipList[GameConfig.CardConfig:getData(id).enid] = true    
    end
end

---
-- 卡牌获得记录
-- @function [parent=#PetCardModel] getCardList
-- @param #PetCardModel self
-- @return #table
function PetCardModel:getCardList()
    return self._getCardList or {}
end

---
-- 清空卡牌获得记录
-- @function [parent=#PetCardModel] cleanCardList
-- @param #PetCardModel self
function PetCardModel:cleanCardList()
    self._getCardList = {}
    self:_raiseDataChangeEvent(0,self.dataType.clean)
end

---
-- 整卡获得记录
-- @function [parent=#PetCardModel] getNewCardList
-- @param #PetCardModel self
-- @param #number id
-- @return #boolean
function PetCardModel:getNewCardList(id) 
    return self._newCardList[id]
end

---
-- 查看过整卡
-- @function [parent=#PetCardModel] setNewCardList
-- @param #PetCardModel self
-- @param #number id
function PetCardModel:setNewCardList(id)
    self._newCardList[id] = false
end

---
-- 清除整卡获得记录
-- @function [parent=#PetCardModel] cleanNewCardList
-- @param #PetCardModel self
function PetCardModel:cleanNewCardList()
    self._newCardList = {}
end

---
-- 碎片获得记录
-- @function [parent=#PetCardModel] getNewChipList
-- @param #PetCardModel self
-- @param #number id
-- @return #boolean
function PetCardModel:getNewChipList(id) 
    return self._newChipList[id]
end

---
-- 查看过碎片
-- @function [parent=#PetCardModel] setNewChipList
-- @param #PetCardModel self
-- @param #number id
function PetCardModel:setNewChipList(id)
    self._newChipList[id] = false
end

---
-- 清除碎片获得记录
-- @function [parent=#PetCardModel] cleanNewChipList
-- @param #PetCardModel self
function PetCardModel:cleanNewChipList()
    self._newChipList = {}
end

---
-- 获取满足最低等级的卡牌数量
-- @function [parent=#PetCardModel] getCardNumByMinLv
-- @param #PetCardModel self
-- @param #number minLv
-- @return #number
function PetCardModel:getCardNumByMinLv(minLv)
    local num = 0
    for k,v in pairs(self._cardOrderData) do
        if self:getLevel(v) >= minLv then
            num = num + 1
        end
    end
    return num
end


---
-- 选择阵容界面的5个坑
-- @function [parent=#PetCardModel] getCardGroup
-- @param #PetCardModel self
-- @return #table
function PetCardModel:getCardGroup()
    return {50001,50002,50003,50004,50005}
end

---
-- 获取对应生命值
-- @function [parent=#PetCardModel] getHP
-- @param #PetCardModel self
-- @param #number id
-- @param #number level
-- @param #number talent
-- @return #number
function PetCardModel:getHP(id,level,talent)
    local cardLevel = level or self:getLevel(id)
    local cardTalent = talent or self:getTalent(id)
    local config = GameConfig.CardConfig:getData(tonumber(id))
    local configUp = GameConfig.CarduplevelConfig:getData(cardLevel)
    local hp = config.max_hp *configUp.max_hp_ratio/100000000
    hp = hp * GameConst.CARD_TALENT_UP_RATIO[cardTalent].max_hp
    
    -- 图腾影响
    hp = hp * (1+ch.TotemModel:getTotemSkillData(7,config.job))
    return hp
end

---
-- 获取对应攻击值
-- @function [parent=#PetCardModel] getAP
-- @param #PetCardModel self
-- @param #number id
-- @param #number level
-- @param #number talent
-- @return #number
function PetCardModel:getAP(id,level,talent)
    local cardLevel = level or self:getLevel(id)
    local cardTalent = talent or self:getTalent(id)
    local config = GameConfig.CardConfig:getData(tonumber(id))
    local configUp = GameConfig.CarduplevelConfig:getData(cardLevel)
    local ap = config.damage *configUp.damage_ratio/100000000
    ap = ap * GameConst.CARD_TALENT_UP_RATIO[cardTalent].damage

    -- 图腾加成
    ap = ap * (1+ch.TotemModel:getTotemSkillData(8,config.job))
    return ap
end

---
-- 获取对应暴击值
-- @function [parent=#PetCardModel] getCR
-- @param #PetCardModel self
-- @param #number id
-- @param #number level
-- @param #number talent
-- @return #number
function PetCardModel:getCR(id,level,talent)
    local cardLevel = level or self:getLevel(id)
    local cardTalent = talent or self:getTalent(id)
    local config = GameConfig.CardConfig:getData(tonumber(id))
    local configUp = GameConfig.CarduplevelConfig:getData(cardLevel)
    return config.cs * configUp.cs_ratio/100000000 * GameConst.CARD_TALENT_UP_RATIO[cardTalent].cs
end

---
-- 获取对应防御值
-- @function [parent=#PetCardModel] getAC
-- @param #PetCardModel self
-- @param #number id
-- @param #number level
-- @param #number talent
-- @return #number
function PetCardModel:getAC(id,level,talent)
    local cardLevel = level or self:getLevel(id)
    local cardTalent = talent or self:getTalent(id)
    local config = GameConfig.CardConfig:getData(tonumber(id))
    local configUp = GameConfig.CarduplevelConfig:getData(cardLevel)
    return config.defence*configUp.defence_ratio/100000000 * GameConst.CARD_TALENT_UP_RATIO[cardTalent].defence
end

---
-- 获取对应闪避值
-- @function [parent=#PetCardModel] getDC
-- @param #PetCardModel self
-- @param #number id
-- @param #number level
-- @param #number talent
-- @return #number
function PetCardModel:getDC(id,level,talent)
    local cardLevel = level or self:getLevel(id)
    local cardTalent = talent or self:getTalent(id)
    local config = GameConfig.CardConfig:getData(tonumber(id))
    local configUp = GameConfig.CarduplevelConfig:getData(cardLevel)
    return config.dodge * configUp.dodge_ratio/100000000 * GameConst.CARD_TALENT_UP_RATIO[cardTalent].dodge
end

---
-- 所有卡牌总战力
-- 战力=72*talent*品质对应系数*生命值成长率/10000
-- @function [parent=#PetCardModel] allPower
-- @param #PetCardModel self
-- @return #number
function PetCardModel:allPower()
    self._totalPowerCache = 0
    self._powerDPSCache = 0
    self._powerLVCache = 1
    for k,v in pairs(self:getCardID()) do
        local Anum = GameConfig.CarduplevelConfig:getData(self:getLevel(v)).max_hp_ratio/10000
        local Bnum = GameConst.CARD_TALENT_RATIO[self:getTalent(v)]
        self._totalPowerCache = self._totalPowerCache+math.floor(72*Anum*Bnum+0.5)
    end
    for k,v in ipairs(GameConst.CARD_POWER_LEVEL_EXP) do
        self._powerLVCache = k
        if self._totalPowerCache < v then
            break
        end 
    end
    self._powerDPSCache = GameConst.CARD_POWER_DPS_RATIO(self._powerLVCache)
    ch.MagicModel:resetTotalDPS()
end

---
-- 获取所有卡牌总战力
-- @function [parent=#PetCardModel] getAllPower
-- @param #PetCardModel self
-- @return #number
function PetCardModel:getAllPower()
    return self._totalPowerCache
end

---
-- 获取所有卡牌总战力提供的DPS
-- @function [parent=#PetCardModel] getAllPowerDPS
-- @param #PetCardModel self
-- @return #number
function PetCardModel:getAllPowerDPS()
    return self._powerDPSCache
end

---
-- 获取所有卡牌总战力等级
-- @function [parent=#PetCardModel] getAllPowerLV
-- @param #PetCardModel self
-- @return #number
function PetCardModel:getAllPowerLV()
    return self._powerLVCache
end


---
-- 阵容综合战力计算
-- 战力=生命上限*攻击力*(1+暴击等级*.001)/(1-防御等级/（防御等级+1000）)/(1-回避等级/（回避等级+1000）)[废弃]
-- 战力=72*talent*品质对应系数*生命值成长率/10000
-- @function [parent=#PetCardModel] getTeamPower
-- @param #PetCardModel self
-- @param #table list
-- @return #number
function PetCardModel:getTeamPower(list)
    local powerNum = 0
--    local num = {0,0,0,0,0}
    for k,v in pairs(list) do
        if v.vis ~= false then
            local Anum = GameConfig.CarduplevelConfig:getData(v.l).max_hp_ratio/10000
            local Bnum = GameConst.CARD_TALENT_RATIO[v.talent]
            powerNum = powerNum+math.floor(72*Anum*Bnum+0.5)
--            num[1] = self:getHP(v.id,v.l)
--            num[2] = self:getAP(v.id,v.l)
--            num[3] = self:getCR(v.id,v.l)
--            num[4] = self:getAC(v.id,v.l)
--            num[5] = self:getDC(v.id,v.l)
--            powerNum = powerNum+math.ceil(num[1]*num[2]*(1+num[3]*0.001)/(1-num[4]/(num[4]+1000))/(1-num[5]/(num[5]+1000))/100)
        end
    end
    return powerNum
end

---
-- 阵容相关内容{power=0,cr=0,hp=0,ac=0,ap=0,dc=0}
-- 战力=生命上限*攻击力*(1+暴击等级*.001)/(1-防御等级/（防御等级+1000）)/(1-回避等级/（回避等级+1000）)
-- @function [parent=#PetCardModel] getTeamData
-- @param #PetCardModel self
-- @param #table list
-- @return #table
function PetCardModel:getTeamData(list)
    local tmpData = {power=0,cr=0,hp=0,ac=0,ap=0,dc=0}
    local num = {0,0,0,0,0}
    for k,v in pairs(list) do
        if v.vis ~= false then
            num[1] = self:getHP(v.id,v.l,v.talent)
            num[2] = self:getAP(v.id,v.l,v.talent)
            num[3] = self:getCR(v.id,v.l,v.talent)
            num[4] = self:getAC(v.id,v.l,v.talent)
            num[5] = self:getDC(v.id,v.l,v.talent)
--            tmpData.power = tmpData.power+math.ceil(num[1]*num[2]*(1+num[3]*0.001)/(1-num[4]/(num[4]+1000))/(1-num[5]/(num[5]+1000))/100)
            tmpData.hp = tmpData.hp + math.floor(num[1])
            tmpData.ap = tmpData.ap + math.floor(num[2])
            tmpData.cr = tmpData.cr + math.floor(num[3])
            tmpData.ac = tmpData.ac + math.floor(num[4])
            tmpData.dc = tmpData.dc + math.floor(num[5])
            local Anum = GameConfig.CarduplevelConfig:getData(v.l).max_hp_ratio/10000
            local Bnum = GameConst.CARD_TALENT_RATIO[v.talent]
            tmpData.power = tmpData.power+math.floor(72*Anum*Bnum+0.5)
        end
    end
    return tmpData
end

---
-- 获得即将变化的星星index 公式（2*i + 3 -total）
-- @function [parent=#PetCardModel] getStarIndex
-- @param #PetCardModel self
-- @param #table level
-- @return #number
function PetCardModel:getStarIndex(level)
    local c = GameConfig.CarduplevelConfig:getData(level)
    local total = c.max_star
    local cur = c.star
    return 2*cur + 3 - total
end

---
-- 获得选中状态
-- @function [parent=#PetCardModel] isRunicSelect
-- @param #PetCardModel self
-- @param #number id
-- @return #boolean
function PetCardModel:isRunicSelect(id)
    return self._runicSelect[tostring(id)] == 1
end

---
-- 设置通用符文使用的选中状态(1选中0取消选中)
-- @function [parent=#PetCardModel] setRunicSelect
-- @param #PetCardModel self
-- @param #number id
-- @param #boolean isSelect
function PetCardModel:setRunicSelect(id,isSelect)
    if isSelect then
        self._runicSelect[tostring(id)] = 1
    else
        self._runicSelect[tostring(id)] = 0
    end
    cc.UserDefault:getInstance():setStringForKey("CardSelectData",json.encode(self._runicSelect))
    self:_raiseDataChangeEvent(id,self.dataType.runicSelect)
end

return PetCardModel