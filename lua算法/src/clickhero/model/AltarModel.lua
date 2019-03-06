---
-- 祭坛 model层 
--@module AltarModel
local AltarModel = {
    _data = nil,
    _panelData = nil,
    _robPanelData = nil,
    _altarData = nil,
    _myCardList = nil,
    _playerDetail = nil,
    _defaultData = nil,
    _robWinData = nil,
    _robLogData = nil,
    effectTime = 0,
    signImg = {"aaui_card/jt_btn_kj_1.png","aaui_card/jt_btn_lh_1.png","aaui_card/jt_btn_gh_1.png"},
    curAltar = 1,
    dataChangeEventType = "AltarModelDataChange", --{type = ,id=,dataType =}
    _eventId = nil,
    dataType = {
        rob = 1,
        reset = 2,
        all = 3,
        panel = 4,
        limit = 5,
        select = 6,
        myCardList = 7,
        initList = 8,
        exp = 9,
    },
    typeId = {
        1,2,3
    }
}

---
-- @function [parent=#AltarModel] init
-- @param #ArenaModel self
-- @param #table data
function AltarModel:init(data)
    self.curAltar = 1
    self.effectTime = os_time() + 180
    self._data = data.altar
    self._panelData = {}
    self._robPanelData = {}
    self._robLogData = {}
    self._robWinData = {}
    self._altarData = {}
    self._altarData[1]=self._data.money or {level=0,maxNum=GameConfig.Altar_levelConfig:getData(1).capability,cardList={},exnum=0}
    self._altarData[2]=self._data.soul or {level=0,maxNum=GameConfig.Altar_levelConfig:getData(1).capability,cardList={},exnum=0}
    self._altarData[3]=self._data.sun or {level=0,maxNum=GameConfig.Altar_levelConfig:getData(1).capability,cardList={},exnum=0}
    self._myCardList = {}
    self:setMyCardListInit(1)
    self:setMyCardListInit(2)
    self:setMyCardListInit(3)
    local lis = false
    for k,v in pairs(self._altarData) do
        if v.level == 0 then
            lis = true
            break
        end
    end
    if lis then
        self._eventId = zzy.EventManager:listen(ch.StatisticsModel.maxLevelChangeEventType,function()
            for k,v in ipairs(GameConst.ALTAR_OPEN_LEVEL) do
                if self._altarData[k].level == 0 and ch.StatisticsModel:getMaxLevel() > v then
                    self:addLevel(k,0)
                    local count = 0
                    for k,v in pairs(self._altarData) do
                        if v.level > 0 then
                            count = count + 1
                        end
                    end
                    if count == #GameConst.ALTAR_OPEN_LEVEL then
                        zzy.EventManager:unListen(self._eventId)
                        self._eventId = nil
                    end
                end
            end
        end,1)
    end
end

---
-- 清理
-- @function [parent=#AltarModel] clean
-- @param #AltarModel self
function AltarModel:clean()
    self._data = nil
    self._panelData = nil
    self._robPanelData = nil
    self._altarData = nil
    self._myCardList = nil
    self._playerDetail = nil
    self._defaultData = nil
    self._robWinData = nil
    self._robLogData = nil
    self.effectTime = 0
    self.curAltar = 1
    if self._eventId then
        zzy.EventManager:unListen(self._eventId)
        self._eventId = nil
    end
end

function AltarModel:_raiseDataChangeEvent(dataType)
    local evt = {
        type = self.dataChangeEventType,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 切换界面
-- @function [parent=#AltarModel] setCurAltarSelect
-- @param #AltarModel self
-- @param #number type
function AltarModel:setCurAltarSelect(type)
    self.curAltar = type
    self:_raiseDataChangeEvent(self.dataType.select)
end

---
-- 当前界面是哪个祭坛
-- @function [parent=#AltarModel] getCurAltarSelect
-- @param #AltarModel self
-- @return #number type
function AltarModel:getCurAltarSelect()
    return self.curAltar
end

---
-- 界面信息
-- @function [parent=#AltarModel] setPanelData
-- @param #AltarModel self
-- @param #table data
function AltarModel:setPanelData(data)
    self._panelData[data.type] = data
    -- 打开界面时刷新内容
    if not self._panelData[data.type] then
        self:setMyCardListInit(data.type)
        self:changeMyCardList(data.type)
    end
    
    self:_raiseDataChangeEvent(self.dataType.panel)
end

---
-- 界面信息
-- @function [parent=#AltarModel] getPanelData
-- @param #AltarModel self
-- @param #number type
-- @return #table data
function AltarModel:getPanelData(type)
    return self._panelData[type] or {exp = 0,stoneNum=0,cdTimes={}}
end

---
-- 掠夺界面信息
-- @function [parent=#AltarModel] setRobPanelData
-- @param #AltarModel self
-- @param #table data
function AltarModel:setRobPanelData(data)
    self._robPanelData[data.type] = data.player
    for k,v in ipairs(self._robPanelData[data.type]) do
        self:setCardList(v.cardList,data)
    end    
    self:_raiseDataChangeEvent(self.dataType.panel)
end

---
-- 掠夺界面信息
-- @function [parent=#AltarModel] getRobPanelData
-- @param #AltarModel self
-- @param #number type
-- @return #table data
function AltarModel:getRobPanelData(type)
    return self._robPanelData[type]
end

---
-- 掠夺战斗记录
-- @function [parent=#AltarModel] setRobLogData
-- @param #AltarModel self
-- @param #table data
function AltarModel:setRobLogData(data)
    self._robLogData = data
end

---
-- 掠夺战斗记录
-- @function [parent=#AltarModel] getRobLogData
-- @param #AltarModel self
-- @return #table data
function AltarModel:getRobLogData()
    return self._robLogData or {}
end

---
-- 相关祭坛信息(1财富2灵魂3光辉)
-- @function [parent=#AltarModel] getAltarByType
-- @param #AltarModel self
-- @param #number type
function AltarModel:getAltarByType(type)
    return self._altarData[type]
end

---
-- 祭坛是否开放掠夺功能(1财富2灵魂3光辉)
-- @function [parent=#AltarModel] isRobOpen
-- @param #AltarModel self
-- @return #boolean
function AltarModel:isRobOpen()
    for k,v in pairs(self._altarData) do
        if v.level >= GameConst.ALTAR_ROB_LEVEL then
            return true
        end
    end 
    return false
end

---
-- 增加氪金保存上限(1财富2灵魂3光辉)
-- @function [parent=#AltarModel] addStoneLimit
-- @param #AltarModel self
-- @param #number type
-- @param #number num
function AltarModel:addStoneLimit(type,num)
    if num > 0 then
        self._altarData[type].maxNum = self._altarData[type].maxNum + num
        self:_raiseDataChangeEvent(self.dataType.limit)
    end
end

---
-- 增加购买上限次数
-- @function [parent=#AltarModel] addExnum
-- @param #AltarModel self
-- @param #number type
-- @param #number num
function AltarModel:addExnum(type,num)
    self._altarData[type].exnum = self._altarData[type].exnum + num
end

---
-- 增加氪金(1财富2灵魂3光辉)
-- @function [parent=#AltarModel] addStone
-- @param #AltarModel self
-- @param #number type
-- @param #number num
function AltarModel:addStone(type,num)
    num = math.floor(num)
    if num > 0 and self._panelData[type].stoneNum < self._altarData[type].maxNum then
        self._panelData[type].stoneNum = self._panelData[type].stoneNum + num
        self:_raiseDataChangeEvent(self.dataType.limit)
    end
    if self._panelData[type].stoneNum > self._altarData[type].maxNum then
        self._panelData[type].stoneNum = self._altarData[type].maxNum
        self:_raiseDataChangeEvent(self.dataType.limit)
    end
end

---
-- 领取氪金
-- @function [parent=#AltarModel] getExp
-- @param #AltarModel self
-- @param #number type
-- @param #number num
-- @param #boolean isStone
function AltarModel:getExp(type,num,isStone)
    if num ~= 0 then
        if isStone then
            self._panelData[type].stoneNum = self._panelData[type].stoneNum - num
            -- 是否显示光效
            local time = 30
            local ifChangeTime = true
            for i=1,3 do
                if self:getAllOutput(self:getMyCardList(i),true) > 0 and 
                (not self._panelData[i] or self._panelData[i].stoneNum >= self:getAllOutput(self:getMyCardList(i),true)*time) then
                    ifChangeTime = false
                end
            end
            if ifChangeTime then
                self:setEffectTime(time*60)
            end
        end
        if not self._panelData[type] then
            self._panelData[type] = {exp=0}
        end
        self._panelData[type].exp = self._panelData[type].exp + num
        self:_raiseDataChangeEvent(self.dataType.exp)
    end
end

---
-- 升级(1财富2灵魂3光辉)
-- @function [parent=#AltarModel] addLevel
-- @param #AltarModel self
-- @param #number type
-- @param #number num
function AltarModel:addLevel(type,num)    
    if self._altarData[type].level > 0 then
        self._altarData[type].level = self._altarData[type].level + 1
        self._panelData[type].exp = self._panelData[type].exp - num
        if self._altarData[type].maxNum < GameConst.ALTAR_EXP_LIMIT_MAX then
            self._altarData[type].maxNum = GameConfig.Altar_levelConfig:getData(self._altarData[type].level).capability
            self._altarData[type].maxNum = self._altarData[type].maxNum+GameConst.ALTAR_EXP_LIMIT_ADD_BUY * self._altarData[type].exnum
        end
    else
        self._altarData[type].level = 1
    end
    if type == 2 or type == 3 then
        ch.MagicModel:resetDPS()
    end
    self:_raiseDataChangeEvent(self.dataType.exp)
end

---
-- 卡牌产量(1财富2灵魂3光辉)
-- @function [parent=#AltarModel] getOutput
-- @param #AltarModel self
-- @param #number level
function AltarModel:getOutput(level)
    if level and level > 0 then
        return math.floor(GameConfig.CarduplevelConfig:getData(level).add_exp *60/GameConfig.CarduplevelConfig:getData(level).add_tm)
    else
        return 0
    end
end

---
-- 总产量(1财富2灵魂3光辉)
-- @function [parent=#AltarModel] getAllOutput
-- @param #AltarModel self
-- @param #table list
-- @param #boolean ifAltar
function AltarModel:getAllOutput(list,ifAltar)
    ifAltar = ifAltar or false
    local output = 0
    for k,v in pairs(list) do
        if v.vis ~= false then
            if ifAltar then
                local tmpRatio = 1
                if self:getCurAltarSelect() == 1 then
                    tmpRatio = 1+ch.TotemModel:getTotemSkillData(1,15)
                elseif self:getCurAltarSelect() == 2 then
                    tmpRatio = 1+ch.TotemModel:getTotemSkillData(1,14)
                elseif self:getCurAltarSelect() == 3 then
                    tmpRatio = 1+ch.TotemModel:getTotemSkillData(1,13)
                end
                tmpRatio = tmpRatio * (1+ch.FamiliarModel:getAltarAdd(self:getCurAltarSelect()))
                output = output + math.floor(self:getOutput(v.l)*tmpRatio)
            else
                output = output + self:getOutput(v.l)
            end
        end
    end
    return output
end

---
-- 防守阵容列表
-- @function [parent=#AltarModel] getAltarListInit
-- @param #AltarModel self
-- @param #number type
-- @return #table
function AltarModel:getAltarListInit(type)
    return self._altarData[type].cardList
end

---
-- 我的阵容列表(显示)
-- @function [parent=#AltarModel] getMyCardList
-- @param #AltarModel self
-- @param #number type
-- @return #table
function AltarModel:getMyCardList(type)
    return self._myCardList[type]
end

---
-- 当前阵容列表是否不为空
-- @function [parent=#AltarModel] ifMyCardList
-- @param #AltarModel self
-- @param #number type
function AltarModel:ifMyCardList(type)
    if self._myCardList[type] then
        for k,v in pairs(self._myCardList[type]) do
            if v.vis then
                return true
            end
        end
    end
    return false
end

---
-- 该卡牌是否在阵容内(显示)
-- @function [parent=#AltarModel] isInGroup
-- @param #AltarModel self
-- @param #number type 
-- @param #number id
-- @return #boolean
function AltarModel:isInGroup(type,id)
    if self._myCardList[type] then
        for k,v in pairs(self._myCardList[type]) do
            if v.vis and v.id == id then
                return true
            end
        end
    end
    return false
end

---
-- 该卡牌是否在其他阵容内(显示)
-- @function [parent=#AltarModel] isInOtherGroup
-- @param #AltarModel self
-- @param #number type 
-- @param #number id
-- @return #boolean
function AltarModel:isInOtherGroup(type,id)
    for i=1,3 do
        if i~= type and self._myCardList[i] then
            for k,v in pairs(self._myCardList[i]) do
                if v.vis and v.id == id then
                    return true
                end
            end
        end
    end
    return false
end

---
-- 该卡牌是否在现有阵容内(显示)
-- @function [parent=#AltarModel] isInAllGroup
-- @param #AltarModel self
-- @param #number id
-- @return #boolean
function AltarModel:isInAllGroup(id)
    for i=1,3 do
        if self._myCardList[i] then
            for k,v in pairs(self._myCardList[i]) do
                if v.vis and v.id == id then
                    return true
                end
            end
        end
    end
    return false
end

---
-- 该卡牌是否在哪个现有阵容内(显示)
-- @function [parent=#AltarModel] isInGroupType
-- @param #AltarModel self
-- @param #number id
-- @return #string
function AltarModel:isInGroupType(id)
    for i=1,3 do
        if self._myCardList[i] then
            for k,v in pairs(self._myCardList[i]) do
                if v.vis and v.id == id then
                    if i == self:getCurAltarSelect() then
                        return "aaui_common/ui_common_fragment_tag.png"
                    else
                        return self.signImg[i]
                    end
                end
            end
        end
    end
    return "aaui_common/dot1.png"
end

---
-- 修改我的阵容列表(显示)
-- @function [parent=#AltarModel] changeMyCardListById
-- @param #AltarModel self
-- @param #number type
-- @param #number id
function AltarModel:changeMyCardListById(type,id)
    if self._myCardList[type] then
        for k,v in pairs(self._myCardList[type]) do
            if v.id == id and v.vis then
                v.id = 50001
                v.l = 1
                v.talent=1
                v.vis = false
                v.canSelect = false
                self:_raiseDataChangeEvent(self.dataType.myCardList)
                return 
            end
        end
    end
end

---
-- 阵容列表里是否有空位
-- @function [parent=#AltarModel] ifNotFull
-- @param #AltarModel self
-- @param #number type
-- @return #boolean
function AltarModel:ifNotFull(type)
    if self._myCardList[type] then
        for i=1,5 do
            if not self._myCardList[type][i].vis then
                return true
            end
        end
    end
    return false
end

---
-- 修改我的阵容列表(显示)
-- @function [parent=#AltarModel] addMyCardList
-- @param #AltarModel self
-- @param #number type
-- @param #number id
function AltarModel:addMyCardList(type,id)
    if self._myCardList[type] then
        for i=1,5 do
            if not self._myCardList[type][i].vis then
                self._myCardList[type][i].index = i
                self._myCardList[type][i].id = id
                self._myCardList[type][i].l = ch.PetCardModel:getLevel(id)
                self._myCardList[type][i].talent = ch.PetCardModel:getTalent(id)
                self._myCardList[type][i].vis = true
                self._myCardList[type][i].canSelect = true
                self:_raiseDataChangeEvent(self.dataType.myCardList)
                return
            end
        end
    end
end

---
-- 设置阵容列表
-- @function [parent=#AltarModel] setCardList
-- @param #AltarModel self
-- @param #table myData
-- @param #table data
function AltarModel:setCardList(myData,data)
    if not myData then
        myData = {}
    end
    for i=1,5 do
        if myData[i] then
            myData[i].vis = true
        else
            myData[i] = {id=50001,l=1,talent=1,vis=false}
        end
    end
end

---
-- 修改我的阵容列表(显示)
-- @function [parent=#AltarModel] setMyCardList
-- @param #AltarModel self
-- @param #number type
-- @param #number index
-- @param #number id
function AltarModel:setMyCardList(type,index,id)
    if id then
        self._myCardList[type][index].id = id
        self._myCardList[type][index].l = ch.PetCardModel:getLevel(id)
        self._myCardList[type][index].talent = ch.PetCardModel:getTalent(id)
    else
        self._myCardList[type][index] = {index = index,id=50001,l=1,talent=1,vis=false,canSelect = false}
    end
    self:_raiseDataChangeEvent(self.dataType.myCardList)
end

---
-- 我的阵容列表(存储)
-- @function [parent=#AltarModel] setMyCardListInit
-- @param #AltarModel self
-- @param #number type
function AltarModel:setMyCardListInit(type)
    self._myCardList[type] = {}
    if not self._altarData[type].cardList then
        self._altarData[type].cardList = {}
    end
    for i=1,5 do
        if self._altarData[type].cardList[i] then
            self._myCardList[type][i] = {index = i, id=self._altarData[type].cardList[i],l=ch.PetCardModel:getLevel(self._altarData[type].cardList[i]),talent=ch.PetCardModel:getTalent(self._altarData[type].cardList[i]),vis=true,canSelect = true}
        else
            self._myCardList[type][i] = {index = i,id=50001,l=1,talent=1,vis=false,canSelect = false}
        end
    end
end

---
-- 确认修改阵容
-- @function [parent=#AltarModel] changeMyCardList
-- @param #AltarModel self
-- @param #number type
function AltarModel:changeMyCardList(type)
    self._altarData[type].cardList = {}
    for k,v in pairs(self._myCardList[type]) do
        if v.vis then
            table.insert(self._altarData[type].cardList,v.id)
        end
    end
    self:_raiseDataChangeEvent(self.dataType.initList)
end

---
-- 剩余掠夺次数
-- @function [parent=#AltarModel] getRobNum
-- @param #AltarModel self
-- @return #number
function AltarModel:getRobNum()
    return self._data.robNum
end

---
-- 增加掠夺次数
-- @function [parent=#AltarModel] addRobNum
-- @param #AltarModel self
-- @param #number num
function AltarModel:addRobNum(num)
    if num ~= 0 then
        self._data.robNum = self._data.robNum + num
        self:_raiseDataChangeEvent(self.dataType.rob)
    end
end

---
-- 剩余补充次数
-- @function [parent=#AltarModel] getResetNum
-- @param #AltarModel self
-- @return #number
function AltarModel:getResetNum()
    return self._data.reset
end

---
-- 增加补充次数
-- @function [parent=#AltarModel] addResetNum
-- @param #AltarModel self
-- @param #number num
function AltarModel:addResetNum(num)
    if num ~= 0 then
        self._data.reset = self._data.reset + num
        self:_raiseDataChangeEvent(self.dataType.reset)
    end
end

---
-- 卡牌抛石头
-- @function [parent=#AltarModel] getIdProduce
-- @param #AltarModel self
-- @return #table
function AltarModel:getIdProduce()
    local tmp = {}
    for i=1,3 do
        if self._panelData[i] and self._panelData[i].cdTime then
            for k,v in pairs(self._panelData[i].cdTime) do
                if v.t and v.t+60 <= os_time() then
                    table.insert(tmp,v.id)
                    v.t = v.t + 60
                    local output = GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getLevel(v.id)).add_exp
                    output = output*(1+ch.FamiliarModel:getAltarAdd(self:getCurAltarSelect()))
                    -- 图腾影响
                    if i == 1 then
                        output = output*(1+ch.TotemModel:getTotemSkillData(1,15))
                    elseif i == 2 then
                        output = output*(1+ch.TotemModel:getTotemSkillData(1,14))
                    elseif i == 3 then
                        output = output*(1+ch.TotemModel:getTotemSkillData(1,13))
                    end
                    self:addStone(i,output)
                end
            end
        end
    end
    return tmp
end

---
-- 掠夺胜利相关信息
-- @function [parent=#AltarModel] setRobWinData
-- @param #AltarModel self
-- @param #string dataType
-- @param #string data
function AltarModel:setRobWinData(dataType,data)
    self._robWinData[dataType] = data
end

---
-- 掠夺胜利相关信息
-- @function [parent=#AltarModel] getRobWinData
-- @param #AltarModel self
-- @return #table
function AltarModel:getRobWinData()
    return self._robWinData
end

---
-- 播放主界面领取光效相关
-- @function [parent=#AltarModel] getEffectTime
-- @param #AltarModel self
-- @return #number
function AltarModel:getEffectTime()
    if self.effectTime then
        local leftTime = self.effectTime - os_time()
        if leftTime > 0 then return math.floor(leftTime) end
    end
    return -1
end

---
-- 播放主界面领取光效相关(os_time()+time)
-- @function [parent=#AltarModel] setEffectTime
-- @param #AltarModel self
-- @param #number time
function AltarModel:setEffectTime(time)
    self.effectTime = os_time() + time
end

function AltarModel:getAddEffect(alertType)
    local alert = self:getAltarByType(alertType)
    
    --祭坛配置中读出来的是最终比例（1+加成比例），例如加成为0.5倍，那么祭坛config里配置的就是(1+0.5)*10000 = 15000
    local finalEffect = GameConfig.Altar_levelConfig:getData(self:getAltarByType(alertType).level).ratio/10000
    
    local addEffect = finalEffect - 1
    
    if alertType == 1 then --财富
        addEffect = addEffect * (1 + ch.ShentanModel:getSkillData(1))
    end
    
    if alertType == 2 then --灵魂
        addEffect = addEffect * (1 + ch.ShentanModel:getSkillData(2))
    end
    
    if alertType == 3 then --光辉
        addEffect = addEffect * (1 + ch.ShentanModel:getSkillData(3))
    end

    return addEffect
end

function AltarModel:getFinalEffect(alertType)
    local alert = self:getAltarByType(alertType)
    
    --祭坛配置中读出来的是最终比例（1+加成比例），例如加成为0.5倍，那么祭坛config里配置的就是(1+0.5)*10000 = 15000
    local finalEffect = GameConfig.Altar_levelConfig:getData(self:getAltarByType(alertType).level).ratio/10000
    
    local addEffect = finalEffect - 1
    
    if alertType == 1 then --财富
        addEffect = addEffect * (1 + ch.ShentanModel:getSkillData(1))
    end
    
    if alertType == 2 then --灵魂
        addEffect = addEffect * (1 + ch.ShentanModel:getSkillData(2))
    end
    
    if alertType == 3 then --光辉
        addEffect = addEffect * (1 + ch.ShentanModel:getSkillData(3))
    end

    return addEffect + 1
end

---
-- 过天逻辑
-- @function [parent=#AltarModel] onNextDay
-- @param #AltarModel self
function AltarModel:onNextDay()
    self._data["robNum"] = GameConst.ALTAR_ROB_MAX
    self._data["reset"] = GameConst.ALTAR_RESET_ADD

    self:_raiseDataChangeEvent(self.dataType.all)
end

return AltarModel