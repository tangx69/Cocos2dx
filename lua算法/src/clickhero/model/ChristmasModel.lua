---
-- 圣诞活动model层
--@module ChristmasModel
local ChristmasModel = {
    _data = nil,
    curPage = nil,
    _holidayData = nil,
    _limitCount = nil,
    _typeEventId = nil,
    _holidayListData = nil,
    _holidayTypeList = nil,
    _wheelReward = nil,
    _wheelCost = nil,
    _wheelTimes = nil,
    _wheelId = nil,
    _diamondWheelReward = nil,
    _diamondWheelId = nil,
    _hyggReward = nil,
    _hyggId = nil,
    _redbag = nil,
    _redbagReward = nil,
    openRedBag = false,
    _nianReward = nil,
	_xyID=nil,
    _gloryGoldList=nil,
	isEffect = false,
	XY_SELECT_EVENT = "XY_CHANGE_SELECT",
	XY_STATE_CHANGE_EVENT = "XY_STATE_CHANGE_EVENT",
    dataChangeEventType = "CHRISTMAS_MODEL_DATA_CHANGE", --{type=,}
    wheelChangeEventType = "WHEEL_MODEL_DATA_CHANGE",
    diamondWheelChangeEventType = "DIAMOND_WHEEL_MODEL_DATA_CHANGE",
    hyggChangeEventType = "HYGG_MODEL_DATA_CHANGE",
    redbagChangeEventType = "REDBAG_MODEL_DATA_CHANGE",
    redbagOpenEventType = "REDBAG_OPEN_MODEL_DATA_CHANGE",
    nianDataChangedEventType = "NIAN_MODEL_DATA_CHANGE",
    effectDataChangeEventType = "EFFECT_CHRISTMAS_MODEL_DATA_CHANGE",
    GAMEEventType_GloryGoldChange = "GAME_EVENTTYPE_GLORYGOLD_CHANGE",
    dataType = {
        count = 0,
        nextday = 1,
        curPage = 3,
        proNum = 4,
        state = 5,
        open = 6,
        stop = 7,
        czxl = 8,
        xhfl = 9,
        hddh = 10,
        effect = 11,
        zszp = 12
    },
    nianDataType = {
        hp=0,
        killed = 1,
        showTime = 2,
        reward=3,
    }
}

---
--初始化
-- @function [parent=#ChristmasModel] init
-- @param #ChristmasModel self
-- @param #table data
function ChristmasModel:init(data)
    self._data = data.holiday
    self._holidayData = {}
    self._holidayListData = {}
    self._holidayTypeList = {}
    self._limitCount = {}
    self._typeEventId = {}
    self.curPage = 1001
    self.openRedBag = false
    self.isEffect = false

    --五星评价
    local wxhpTable = 
    {
        hdata = {},
        cfgid = "9999",
        type = 9999,
        openTime = 1505404800,
        endTIme = 9505404800
    }

    
    --if _G_URL_PACKAGE and _G_URL_PACKAGE ~= "" and (not IS_IN_REVIEW) then
    if (not IS_IN_REVIEW) then
        table.insert(data.holiday.list, wxhpTable)
    end
    --五星评价

    if data.holiday and data.holiday.list then
        for k,v in pairs(self._data.list) do
            if v.type then
                if not self._holidayListData[v.type] then
                    table.insert(self._holidayTypeList,v.type)
                end
                self._holidayListData[v.type] = v
                if v.hdata and type(v.hdata) == "table" and v.hdata.canData then
                    v.canReward = v.hdata.canData
                     v.getReward = v.hdata.getData
                end

                if (v.type == 1004 or v.type == 1005 or v.type == 1018) then
                    v.proNum = v.hdata.times
                    --self._holidayListData[v.type].rewardNum = v.hdata.rewardNum
                end
                
                self:setHolidayData(v.type,v.getReward,v.canReward)
                if v.type == 1007 then
                    self._redbag = v.hdata
                    --self._redbag.diamond = 1234 or v.hdata.num
                    --self._redbag.getDiamond = 100000 or v.hdata.diamond
                    self._redbag.costNum = v.hdata.costNum or 100
                elseif v.type == 1017 then
                    self:setHolidayData(v.type,v.hdata.getReward,v.hdata.canReward)  
                end
            end
        end
    end

    --注册时间7天之内的玩家，5星好评放在活动的第一个。否则放在最后
    local isNewPlayer =  (ch.PlayerModel:getLastLoginTime()- ch.PlayerModel:getRegTime()) < 7*24*3600
    if not isNewPlayer then
        GameConst.HOLIDAY_ITEM_DATA["hd9999"].index = 1
    end
    table.sort(self._holidayTypeList,function(t1,t2)
        return GameConst.HOLIDAY_ITEM_DATA["hd"..t1].index > GameConst.HOLIDAY_ITEM_DATA["hd"..t2].index
    end)
    self.curPage = self._holidayTypeList[1] 
end

---
-- 清理
-- @function [parent=#ChristmasModel] clean
-- @param #ChristmasModel self
function ChristmasModel:clean()
    self._data = nil
    self.curPage = nil
    self._holidayData = nil
    self._limitCount = nil
    for k,v in pairs(self._typeEventId) do
        zzy.EventManager:unListen(v)
    end
    self._typeEventId = nil
    self._holidayListData = nil
    self._holidayTypeList = nil
    self._wheelReward = nil
    self._wheelCost = nil
    self._wheelTimes = nil
    self._wheelId = nil
    self._diamondWheelReward = nil
    self._diamondWheelId = nil
    self._hyggReward = nil
    self._hyggId = nil
    self._redbag = nil
    self._redbagReward = nil
    self.openRedBag = false
    self._nianReward = nil
    self._xyID = nil
    self._gloryGoldList=nil
    self.isEffect = false
end

function ChristmasModel:_raiseDataChangeEvent(id,dataType)
    local evt = {
        type = self.dataChangeEventType,
        id = id,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 选中某个愿望许愿
-- @function [parent=#NetworkController] xySelectChange
-- @param #ChristmasModel self
-- @param #number id
function ChristmasModel:xySelectChange(id)
	self._xyID=id
    local evt = {
        type = self.XY_SELECT_EVENT
    }
    zzy.EventManager:dispatch(evt)
end

function ChristmasModel:_raiseNianDataChangeEvent(dataType)
    local evt = {
        type = self.nianDataChangedEventType,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end
---
-- 获取许愿池愿望id
-- @function [parent=#NetworkController] getXYSelectID
-- @param #ChristmasModel self
-- @return #number id
function ChristmasModel:getXYSelectID()
	return self._xyID
end

---
-- 许愿池许愿
-- @function [parent=#NetworkController] setXYData
-- @param #ChristmasModel self
-- @param #number type
-- @param #number id
function ChristmasModel:setXYData(type,id)
	if type==1 then
		ch.ChristmasModel:getHDataByType(1014).st[tostring(id)]=2
	else
		ch.ChristmasModel:getHDataByType(1014).st["1"]=2
		ch.ChristmasModel:getHDataByType(1014).st["2"]=2
		ch.ChristmasModel:getHDataByType(1014).st["3"]=2
		ch.ChristmasModel:getHDataByType(1014).st["4"]=2
		ch.MoneyModel:addDiamond(-GameConst.CXHD_WISH_ALL_PRICE)
	end
	 local evt = {
        type = self.XY_STATE_CHANGE_EVENT
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 许愿池领奖
-- @function [parent=#NetworkController] setXYLJData
-- @param #ChristmasModel self
-- @param #number type
-- @param #number id
function ChristmasModel:setXYLJData(id)	
	ch.ChristmasModel:getHDataByType(1014).st[tostring(id)]=4
	 local evt = {
        type = self.XY_STATE_CHANGE_EVENT
    }
    zzy.EventManager:dispatch(evt)
end
---
-- 活动开启初始化
-- @function [parent=#ChristmasModel] openInit
-- @param #ChristmasModel self
-- @param #table data
function ChristmasModel:openInit(data)
    self._data = data
    if data and data.list then
        for k,v in pairs(data.list) do
            if v.type then
                if not self._holidayListData[v.type] then
                    table.insert(self._holidayTypeList,v.type)
                end
                self._holidayListData[v.type] = v
                self:setHolidayData(v.type,v.getReward,v.canReward)
                if v.type == 1007 then
                    self._redbag = v.hdata
                elseif v.type == 1015 then
                    ch.MoneyModel:addFirecracker(GameConst.CXHD_BASHNIAN_FREE_FIRECRACKER) 
                elseif v.type == 1017 then
                    self:setHolidayData(v.type,v.hdata.getReward,v.hdata.canReward)  
                end
            end
        end
    end
    table.sort(self._holidayTypeList,function(t1,t2)
        return GameConst.HOLIDAY_ITEM_DATA["hd"..t1].index > GameConst.HOLIDAY_ITEM_DATA["hd"..t2].index
    end)
    self.curPage = self._holidayTypeList[1]
    self:_raiseDataChangeEvent("0",self.dataType.open)
end

---
-- 活动停止处理
-- @function [parent=#ChristmasModel] stopHoliday
-- @param #ChristmasModel self
-- @param #table data
function ChristmasModel:stopHoliday(data)
    for m,type in pairs(data) do
        local tmpData = {}
        if self._data and self._data.list then
            for k,v in pairs(self._data.list) do
                if v.type == type then
                    v.endTime = 0
                else
                    table.insert(tmpData,v)
                end
            end
        end
        self._data.list = tmpData
        if self._holidayListData[type] then
            self._holidayListData[type] = nil
        end
    
        local tmp = {}
        for k,v in pairs(self._holidayTypeList) do
            if v ~= type then
                table.insert(tmp,v)
            end
        end
        self._holidayTypeList = tmp
    end
    
    table.sort(self._holidayTypeList,function(t1,t2)
        return GameConst.HOLIDAY_ITEM_DATA["hd"..t1].index > GameConst.HOLIDAY_ITEM_DATA["hd"..t2].index
    end)
    self.curPage = self._holidayTypeList[1]
    ch.UIManager:closeGamePopupLayer("Christmas/W_Christmas")
    self:_raiseDataChangeEvent("0",self.dataType.stop)
end


function ChristmasModel:test2()
    local tmp2 = {f="open",type=2,list={{cfgid="shddh01",type=1001,endTime=1501550358,openTime=1451291157,proNum=1,getReward={},canReward={},dhNum={}},{cfgid="mcslcp01",type=1013,endTime=1501550358,openTime=1451291157,hdata={day=2}}}}
    self:openInit(tmp2)
end

function ChristmasModel:test1()
    local tmp2 = {f="open",type=2,list={{cfgid="bandit01",type=1019,endTime=1501550358,openTime=1451291157,hdata=0}}}
    self:openInit(tmp2)
end

function ChristmasModel:test3()
    local tmp1 = {f="stop",type={1013}}
    self:stopHoliday(tmp1.type)
end

---
-- 活动是否开启
-- @function [parent=#ChristmasModel] isOpen
-- @param #ChristmasModel self
-- @return #boolean
function ChristmasModel:isOpen()
    if self._data and self._data.list and self._data.list[1] and self._data.list[1].endTime and self._data.list[1].endTime > os_time() then
        return true
    else
        return false
    end
end

---
-- 获取活动列表
-- @function [parent=#ChristmasModel] getHolidayTypeList
-- @param #ChristmasModel self
-- @return #table
function ChristmasModel:getHolidayTypeList()
    return self._holidayTypeList
end

---
-- 玩家可开启礼包次数（1004，1005,1018）
-- @function [parent=#ChristmasModel] addRewardNum
-- @param #ChristmasModel self
-- @param #number type
-- @param #number id
-- @param #number num
function ChristmasModel:addRewardNum(type,id,num)
    if true then self:setHolidayState(type,id,2) return end
    
    if num ~= 0 then
        if self._holidayListData[type].rewardNum[tostring(id)] then
            self._holidayListData[type].rewardNum[tostring(id)] = self._holidayListData[type].rewardNum[tostring(id)] + num
        else
            self._holidayListData[type].rewardNum[tostring(id)] = num
        end
        self:_raiseDataChangeEvent(id,self.dataType.count)
        -- 更改状态
        if self:getHolidayState(type,id) == 1 and self:getRewardNum(type,id) <= 0 then
            self:setHolidayState(type,id,2)
        end
    end
end

---
-- 玩家可开启礼包次数（1004，1005,1018）
-- @function [parent=#ChristmasModel] getRewardNum
-- @param #ChristmasModel self
-- @param #number type
-- @param #number id
-- @return #number
function ChristmasModel:getRewardNum(type,id)
    local num  = (self:getHolidayState(type,id) == 1) and 1 or 0
    return num
--[[   
    local tmp = self._holidayListData[type].rewardNum[tostring(id)] or 0
    local cfgid = self._holidayListData[type].cfgid or self._data.cfgid
    local num = 0
    if type == 1004 then
        num = GameConfig.ChristmasConfig:getData(cfgid,1,id).boxNum
    elseif type == 1005 then
        num = GameConfig.ChristmasConfig:getData(cfgid,2,id).boxNum
    elseif type == 1018 then
        num = GameConfig.ChristmasConfig:getData(cfgid,3,id).boxNum
    end
    return num - tmp
]]
end

---
-- 获取活动完成状态
-- @function [parent=#ChristmasModel] getHolidayState
-- @param #ChristmasModel self
-- @param #number type
-- @param #number id
-- @return #number
function ChristmasModel:getHolidayState(type,id)
    if self._holidayData[type] then
        return self._holidayData[type][id]
    else
        return 0
    end
end

---
-- 更改可领取状态
-- @function [parent=#ChristmasModel] setHolidayState
-- @param #ChristmasModel self
-- @param #number type
-- @param #number id
-- @param #number state
function ChristmasModel:setHolidayState(type,id,state)
    if state == 1 and self:getHolidayState(type,id) == 2 then
        return
    end
    self._holidayData[type][id] = state
    if self._holidayListData[type].canReward and state == 1 then
        table.insert(self._holidayListData[type].canReward,id)
    elseif self._holidayListData[type].getReward and state == 2 then
        table.insert(self._holidayListData[type].getReward,id)
    end
    self:_raiseDataChangeEvent(id,self.dataType.state)
end

---
-- 是否可领奖type(1002,1004,1005,1018)
-- @function [parent=#ChristmasModel] getCurCan
-- @param #ChristmasModel self
-- @param #number type
-- @return #boolean
function ChristmasModel:getCurCan(type)
    if type == 1002 or type == 2035 or type == 2037 or type == 1004 or type == 1005 or type == 1018 then
        if self._holidayData[type] then
            for k,v in pairs(self._holidayData[type]) do
                if v == 1 then
                    return true
                end
            end
        end
        return false
    elseif type == 1006 then
        if self:isWheelOpen() and self:getWheelCount() < GameConst.HOLIDAY_WHEEL_FREE_COUNT then
            return true
        end
    elseif type == 1007 then
        if self:isRedBagOpen() and self:getRedBagNoOpenNum() > 0 then
            return true
        end
    elseif type == 1011 then
        if ch.ChristmasModel:getHDataByType(1011) then
            for k,v in pairs(ch.ChristmasModel:getCSVDataByType(1011)) do
                local state = ch.ChristmasModel:getHDataByType(1011).getReward[tostring(v.id)]
                if v.max <=ch.ChristmasModel:getHDataByType(1011).diamond and (not state) then
                    return true
                end
            end
        end
    elseif type == 1012 then
        if ch.ChristmasModel:getHDataByType(1012) then
            for k,v in pairs(ch.ChristmasModel:getCSVDataByType(1012)) do
                local state = ch.ChristmasModel:getHDataByType(1012).getReward[tostring(v.id)]
                if v.max <=ch.ChristmasModel:getHDataByType(1012).diamond and (not state) then
                    return true
                end
            end
        end
    elseif type == 1017 then
        self:ifChangeMCSFState()
        if self._holidayData[type] then
            for k,v in pairs(self._holidayData[type]) do
                if v == 1 then
                    return true
                end
            end
        end
        return false
    elseif type == 1019 then
        if self:isOpenByType(1019) and self:getHDataByType(1019) < GameConst.HOLIDAY_HYGG_FREE_COUNT then
            return true
        end
    end
    return false
end

---
-- 是否可领奖(1002,1004,1005,1018)
-- @function [parent=#ChristmasModel] getAllCan
-- @param #ChristmasModel self
-- @return #boolean
function ChristmasModel:getAllCan()
    if self._holidayTypeList and table.maxn(self._holidayTypeList) > 0 then
        for k,v in pairs(self._holidayTypeList) do
            if self:getCurCan(v) then
                return true
            end
        end
    end
    return false
end

---
-- 获取当前打开页签
-- @function [parent=#ChristmasModel] getCurPage
-- @param #ChristmasModel self
-- @return #number
function ChristmasModel:getCurPage()
    return self.curPage
end

---
-- 修改当前打开页签
-- @function [parent=#ChristmasModel] setCurPage
-- @param #ChristmasModel self
-- @param #number type
function ChristmasModel:setCurPage(type)
    self.curPage = type
    self:_raiseDataChangeEvent("0",self.dataType.curPage)
end

---
-- 限购面板次数
-- @function [parent=#ChristmasModel] setSDXG
-- @param #ChristmasModel self
-- @param #table list
function ChristmasModel:setSDXG(list)
    --[[
    for k,v in pairs(list) do
        self._limitCount[tostring(k)] = v
    end
    ]]
    self._limitCount = list
    self:_raiseDataChangeEvent("0",self.dataType.count)
end

---
-- 连续充值用户数据更新
-- @function [parent=#ChristmasModel] setLXCZ
-- @param #ChristmasModel self
-- @param #table hdata
function ChristmasModel:setLXCZ(hdata)
    hdata.canReward = hdata.canData
    hdata.getReward = hdata.getData

    self:setHolidayData(2037, hdata.getReward, hdata.canReward)
end

---
-- 连续充值用户数据更新
-- @function [parent=#ChristmasModel] setLXCZ
-- @param #ChristmasModel self
-- @param #table hdata
function ChristmasModel:setSDDH(hdata)
    if hdata.count then
        ch.MoneyModel:setCSock(hdata.count)
    end
end

---
-- 月末飞升用户数据更新
-- @function [parent=#ChristmasModel] setLXCZ
-- @param #ChristmasModel self
-- @param #table hdata
function ChristmasModel:setYMFS(hdata)
    hdata.canReward = hdata.canData
    hdata.getReward = hdata.getData

    self:setHolidayData(2035, hdata.getReward, hdata.canReward)
end

---
-- 限购面板次数
-- @function [parent=#ChristmasModel] addSDXGNum
-- @param #ChristmasModel self
-- @param #number id
-- @param #number num
function ChristmasModel:addSDXGNum(id,num)
    if num ~= 0 then
        if self._limitCount[tostring(id)] then
            self._limitCount[tostring(id)] = self._limitCount[tostring(id)] + num
        else
            self._limitCount[tostring(id)] = num
        end
        self:_raiseDataChangeEvent(id,self.dataType.count)
    end
end

---
-- 限购面板次数
-- @function [parent=#ChristmasModel] getSDXGNum
-- @param #ChristmasModel self
-- @param #number id
-- @return #number
function ChristmasModel:getSDXGNum(id)
    local tmp = self._limitCount[tostring(id)] or 0
    local cfgid = self._holidayListData[1003].cfgid or self._data.cfgid
    local config = GameConfig.SdxgConfig:getData(cfgid,self:getProNumByType(1003),id)
    local max = config.max
    if max == nil then
        DEBUG("cfgid="..cfgid)
        DEBUG("id="..id)
    end
    if max == 0 then
        return -1
    else
        return max - tmp
    end
end

---
-- 限购面板次数描述
-- @function [parent=#ChristmasModel] getSDXGDesc
-- @param #ChristmasModel self
-- @param #number id
-- @return #number
function ChristmasModel:getSDXGDesc(id)
    local cfgid = self._holidayListData[1003].cfgid or self._data.cfgid
    local tmpData = GameConfig.SdxgConfig:getData(cfgid,self:getProNumByType(1003),id)
    if tmpData.max == 0 then
        return Language.src_clickhero_model_ChristmasModel_1
    elseif tmpData.type == 1 then
        return Language.src_clickhero_model_ChristmasModel_2
    else
        return Language.src_clickhero_model_ChristmasModel_3
    end
end

---
-- 兑换面板次数
-- @function [parent=#ChristmasModel] addDHNum
-- @param #ChristmasModel self
-- @param #number id
-- @param #number num
function ChristmasModel:addDHNum(id,num)
    if num ~= 0 then
        local dhNum = self._holidayListData[1001].hdata.dhNum
        if dhNum[id] then
            dhNum[id] = dhNum[id] + num
        else
            dhNum[id] = num
        end
        self:_raiseDataChangeEvent(id,self.dataType.count)
    end
end

---
-- 兑换面板次数
-- @function [parent=#ChristmasModel] getDHNum
-- @param #ChristmasModel self
-- @param #number id
-- @return #number
function ChristmasModel:getDHNum(id)
    local dhNum = self._holidayListData[1001].hdata.dhNum
    local tmp = dhNum[id] or 0
    local cfgid = self._holidayListData[1001].cfgid or self._data.cfgid
    local max = GameConfig.SddhConfig:getData(cfgid,id).max
    if max == 0 then
        return -1
    else
        return max - tmp
    end
end

---
-- 限购金额
-- @function [parent=#ChristmasModel] getSDXGPrice
-- @param #ChristmasModel self
-- @param #number id
-- @return #number
function ChristmasModel:getSDXGPrice(id)
    local cfgid = self._holidayListData[1003].cfgid or self._data.cfgid
    return GameConfig.SdxgConfig:getData(cfgid,self:getProNumByType(1003),id).price
end

local tmpNum = {}
---
-- 活动进度当前(进度)
-- 1.坚守阵地 2.魔宠竞技3.掠夺次数
-- @function [parent=#ChristmasModel] _getCurNum
-- @param #ChristmasModel self
-- @param #number type
-- @param #number id
function ChristmasModel:_getCurNum(type,id)
    if self:getHolidayState(type,id) == 3 or self:getHolidayState(type,id) == 2 then
        return 
    end
    local evtType = nil
    local func = nil

    if type == 1004 then   -- 坚守阵地
        if not tmpNum[type] then
            tmpNum[type] = ch.DefendModel:getTimes()
        end
        evtType = ch.DefendModel.dataChangeEventType
        func = function(obj,evt)           
            if evt.dataType == ch.DefendModel.dataType.Times then
                if tmpNum[type] < ch.DefendModel:getTimes() then
                    self:addProNumByType(type,1)
                    self:changeState(type)
                end
                tmpNum[type] = ch.DefendModel:getTimes()
            end
        end
    elseif type == 1005 then  -- 魔宠竞技
        if not tmpNum[type] then
            tmpNum[type] = ch.ArenaModel:getChallengeNum()
        end
        evtType = ch.ArenaModel.dataChangeEventType
        func = function(obj,evt)
            if evt.dataType == ch.ArenaModel.dataType.challenge then
                if tmpNum[type] > ch.ArenaModel:getChallengeNum() then
                    self:addProNumByType(type,1)
                    self:changeState(type)
                end
                tmpNum[type] = ch.ArenaModel:getChallengeNum()
            end
        end
    elseif type == 1018 then  -- 掠夺次数
        if not tmpNum[type] then
            tmpNum[type] = ch.AltarModel:getRobNum()
    end
    evtType = ch.AltarModel.dataChangeEventType
    func = function(obj,evt)
        if evt.dataType == ch.AltarModel.dataType.rob then
            if tmpNum[type] > ch.AltarModel:getRobNum() then
                self:addProNumByType(type,1)
                self:changeState(type)
            end
            tmpNum[type] = ch.AltarModel:getRobNum()
        end
    end
    else
        return 
    end
    if not self._typeEventId[type] then
        self._typeEventId[type] = zzy.EventManager:listen(evtType,func)
    end
end

---
-- 设置当前活动完成状态 0不可领1可领奖2已领奖3不到时间4已过期
-- @function [parent=#ChristmasModel] setHolidayData
-- @param #ChristmasModel self
-- @param #number type
-- @param #table getData
-- @param #table canData
function ChristmasModel:setHolidayData(type,getData,canData)

    if type == 1005 then
        DEBUG("SETHOLIDAY 1005")
    end

    self._holidayData[type] = {}
    if canData and table.maxn(canData) > 0 then
        for k,v in pairs(canData) do
            self._holidayData[type][tonumber(v)] = 1
        end
    end
    if getData and table.maxn(getData) > 0 then
        for k,v in pairs(getData) do
            self._holidayData[type][tonumber(v)] = 2
        end
    end
    local holidayData = self:getCSVDataByType(type)
    if holidayData then
        for k,v in pairs(holidayData) do
            if type == 1001 then
                if v.max == 0 or self:getDHNum(v.id) > 0 then
                    if ch.MoneyModel:getCSock() >= v.price then
                        self._holidayData[type][tonumber(v.id)] = 1
                    else
                        self._holidayData[type][tonumber(v.id)] = 0
                    end
                else
                    self._holidayData[type][tonumber(v.id)] = 2
                end
            elseif type == 1002 then
                if v.id > self:getProNumByType(type) then
                    self._holidayData[type][tonumber(v.id)] = 3
                elseif not self._holidayData[type][tonumber(v.id)] then
                    self._holidayData[type][tonumber(v.id)] = 4
                end
            elseif type == 2035 then
                -- 设置当前活动完成状态 0未充值1可领奖2已领奖
                if not self._holidayData[type][tonumber(v.id)] then
                    self._holidayData[type][tonumber(v.id)] = 0
                end
            elseif type == 2037 then
                -- 设置当前活动完成状态 0未充值1可领奖2已领奖3不到时间4已过期
                if v.id > self:getProNumByType(type) then
                    self._holidayData[type][tonumber(v.id)] = 3
                elseif not self._holidayData[type][tonumber(v.id)] then
                    self._holidayData[type][tonumber(v.id)] = 0
                end
            elseif type == 1003 then
                self._holidayData[type][tonumber(v.id)] = 1
            elseif type == 1017 then
                if v.id > self:getHDataByType(1017).day then
                    self._holidayData[type][tonumber(v.id)] = 3
                elseif not self._holidayData[type][tonumber(v.id)] then
                    if v.id == self:getHDataByType(1017).day then
                        self._holidayData[type][tonumber(v.id)] = 0
                    else
                        self._holidayData[type][tonumber(v.id)] = 4
                    end
                end
            elseif type >= 1006 and type ~= 1018 then
            
            elseif not self._holidayData[type][tonumber(v.id)] then
                self._holidayData[type][tonumber(v.id)] = 0
                self:_getCurNum(type,tonumber(v.id))
            end
        end
    end
    self:changeState(type)
end

---
-- 获得活动内容数量
-- @function [parent=#ChristmasModel] getProNumByType
-- @param #ChristmasModel self
-- @param #number type
-- @return #number
function ChristmasModel:getProNumByType(type)
    if type == 1003 then
        return 1
    end

    return self._holidayListData[type].proNum or 0
end

---
-- 增加活动内容数量
-- @function [parent=#ChristmasModel] addProNumByType
-- @param #ChristmasModel self
-- @param #number type
-- @param #number num
function ChristmasModel:addProNumByType(type,num)
    if num ~= 0 then
        self._holidayListData[type].proNum = self._holidayListData[type].proNum + num
        self:_raiseDataChangeEvent(type,self.dataType.proNum)
    end
end

---
-- 获得活动开始时间
-- @function [parent=#ChristmasModel] getOpenTimeByType
-- @param #ChristmasModel self
-- @param #number type
-- @return #number
function ChristmasModel:getOpenTimeByType(type)
    if self._holidayListData and self._holidayListData[type] and self._holidayListData[type].openTime then
        return self._holidayListData[type].openTime
    end
    return 0
end

---
-- 获得活动结束时间
-- @function [parent=#ChristmasModel] getEndTimeByType
-- @param #ChristmasModel self
-- @param #number type
-- @return #number
function ChristmasModel:getEndTimeByType(type)
    if self._holidayListData and self._holidayListData[type] and self._holidayListData[type].endTime then
        return self._holidayListData[type].endTime
    end
    return 0
end

---
-- 任务进度当前(进度)(1004,1005,1018)
-- 1.坚守阵地 2.宠物竞技3.掠夺次数
-- @function [parent=#ChristmasModel] changeState
-- @param #ChristmasModel self
-- @param #number type
function ChristmasModel:changeState(type)
    if type == 1004 or type == 1005 or type == 1018 then
        local tmpData = self:getCSVDataByType(type)
        if tmpData then
            for k,v in pairs(tmpData) do
                if self:getHolidayState(type,v.id) < 1 and self:getProNumByType(type) >= v.goal then
                    self:setHolidayState(type,v.id,1)
                end
            end
        end
    end
end

---
-- 方案ID
-- @function [parent=#ChristmasModel] getCfgidByType
-- @param #ChristmasModel self
-- @param #number type
-- @return #string
function ChristmasModel:getCfgidByType(type)
    return self._holidayListData[type].cfgid or self._data.cfgid
end

---
-- 读表类型
-- @function [parent=#ChristmasModel] getCSVDataByType
-- @param #ChristmasModel self
-- @param #number type
-- @return #table
function ChristmasModel:getCSVDataByType(type)
    local cfgid = self._holidayListData[type].cfgid or self._data.cfgid
    if type == 1001 then
        return GameConfig.SddhConfig:getTable1("shddh01" or cfgid) --兑换活动只读01
    elseif type == 1002 then
        return GameConfig.SdSignConfig:getTable1(cfgid)
    elseif type == 2035 then
        return GameConfig.YmfsConfig:getTable1(cfgid)
    elseif type == 2037 then
        return GameConfig.LxczConfig:getTable1(cfgid)
    elseif type == 1003 then
        local datas = GameConfig.SdxgConfig:getTable2(cfgid,self:getProNumByType(type))
        return datas
    elseif type == 1004 then
        return GameConfig.ChristmasConfig:getTable2(cfgid,1)
    elseif type == 1005 then
        return GameConfig.ChristmasConfig:getTable2(cfgid,2)
    elseif type == 1006 then
        return GameConfig.WheelConfig:getTable1(cfgid)
    elseif type == 1011 then
        return GameConfig.RcczhkConfig:getTable1(cfgid)
    elseif type == 1012 then
        return GameConfig.RcxfhkConfig:getTable1(cfgid)
    elseif type == 1013 then
        return GameConfig.McslcpConfig:getTable1(cfgid)
    elseif type == 1016 then
        return GameConfig.Diamond_wheelConfig:getTable1(cfgid)
    elseif type == 1017 then
        return GameConfig.SlsfConfig:getTable1(cfgid)
    elseif type == 1018 then
        return GameConfig.ChristmasConfig:getTable2(cfgid,3)
    elseif type == 1019 then
        return GameConfig.BanditConfig:getTable1(cfgid)
    else
        return GameConfig.ChristmasConfig:getTable()
    end
end

---
-- 礼包内容若为符文显示数量（只限礼包内第一个物品）
-- @function [parent=#ChristmasModel] getRunicNumById
-- @param #ChristmasModel self
-- @param #number id
-- @param #number num
-- @param #string name
-- @return #string 
function ChristmasModel:getRunicNumById(id,num,name)
    local tmp = GameConfig.GiftConfig:getData(id)
    if tmp.idty1 == 9 and tmp.id1 == 40200 then
        name = ch.CommonFunc:getRewardName(tmp.idty1,tmp.id1)
        name = name .."X"..ch.CommonFunc:getRewardValue(tmp.idty1,tmp.id1,tmp.num1*num)
    end
    return name
end

---
-- 礼包内容若为宠物判断是否拥有（只限礼包内第一个物品）
-- @function [parent=#ChristmasModel] getPartnerStateById
-- @param #ChristmasModel self
-- @param #number type
-- @param #number id
-- @return #boolean
function ChristmasModel:getPartnerStateById(type,id)
    if type == 2 then
        return true
    end
    local tmp = GameConfig.GiftConfig:getData(id)
    if tmp.idty1 == 2 then
        return not ch.PartnerModel:ifHavePartner(tostring(tmp.id1))
    end
    return true
end

---
-- 转盘活动是否可用
-- @function [parent=#ChristmasModel] isWheelOpen
-- @param #ChristmasModel self
-- @return #bool
function ChristmasModel:isWheelOpen()
	if self._holidayListData[1006] then
	   local now = os_time()
	   if self._holidayListData[1006].openTime <= now and self._holidayListData[1006].endTime > now then
	       return true
	   end
	end
	return false
end

---
-- 转盘活动今天已用次数
-- @function [parent=#ChristmasModel] getWheelCount
-- @param #ChristmasModel self
-- @return #number
function ChristmasModel:getWheelCount()
    return self._holidayListData[1006].hdata
end

---
-- 添加转盘活动今天已用次数
-- @function [parent=#ChristmasModel] addWheelCount
-- @param #ChristmasModel self
-- @param #number count
function ChristmasModel:addWheelCount(count)
    if count ~= 0 then
        self._holidayListData[1006].hdata = self._holidayListData[1006].hdata + count
        local evt = {type = self.wheelChangeEventType}
        zzy.EventManager:dispatch(evt)
    end
end

---
-- 设置转盘奖励
-- @function [parent=#ChristmasModel] setWheelReward
-- @param #ChristmasModel self
-- @param #table reward
function ChristmasModel:setWheelReward(reward)
    self._wheelReward = reward
end

---
-- 获取转盘奖励
-- @function [parent=#ChristmasModel] getWheelReward
-- @param #ChristmasModel self
-- @return #table reward  {t=,id=,num=}
function ChristmasModel:getWheelReward()
    return self._wheelReward
end

---
-- 设置转盘本次花费
-- @function [parent=#ChristmasModel] setWheelCost
-- @param #ChristmasModel self
-- @param #number cost
-- @param #number times
function ChristmasModel:setWheelCost(cost,times)
    self._wheelCost = cost
    self._wheelTimes = times
end

---
-- 获取转盘花费
-- @function [parent=#ChristmasModel] getWheelCost
-- @param #ChristmasModel self
-- @return #number
function ChristmasModel:getWheelCost()
    return self._wheelCost,self._wheelTimes
end

---
-- 获取转盘奖励的id
-- @function [parent=#ChristmasModel] getWheelId
-- @param #ChristmasModel self
-- @return #table 
function ChristmasModel:getWheelId()
    return self._wheelId
end

---
-- 设置转盘奖励的id
-- @function [parent=#ChristmasModel] setWheelId
-- @param #ChristmasModel self
-- @param #number id
function ChristmasModel:setWheelId(id)
    self._wheelId = id
end

---
-- 对应活动是否可用
-- @function [parent=#ChristmasModel] isOpenByType
-- @param #ChristmasModel self
-- @param #number type 
-- @return #bool
function ChristmasModel:isOpenByType(type)
    if self._holidayListData[type] then
        local now = os_time()
        if self._holidayListData[type].openTime <= now and self._holidayListData[type].endTime > now then
            return true
        end
    end
    return false
end

---
-- 1001兑换活动的免费领取代币状态
-- @function [parent=#ChristmasModel] setDHGetFreeState
-- @param #ChristmasModel self
-- @param #number state
function ChristmasModel:setDHGetFreeState(state)
    self._holidayListData[1001].hdata.lq = state
    self:_raiseDataChangeEvent("0",self.dataType.hddh)
end


---
-- 获得对应活动的hdata(不包含1002-1005,1018,2037)
-- @function [parent=#ChristmasModel] getHDataByType
-- @param #ChristmasModel self
-- @param #number type
-- @return #number
function ChristmasModel:getHDataByType(type)
    return self._holidayListData[type].hdata
end

---
-- 红包活动是否可用
-- @function [parent=#ChristmasModel] isRedBagOpen
-- @param #ChristmasModel self
-- @return #bool
function ChristmasModel:isRedBagOpen()
    if self._holidayListData[1007] then
        local now = os_time()
        if self._holidayListData[1007].openTime <= now and self._holidayListData[1007].endTime > now then
            return true
        end
    end
    return false
end

---
-- 获取红包未拆数量
-- @function [parent=#ChristmasModel] getRedBagNoOpenNum
-- @param #ChristmasModel self
-- @return #number 
function ChristmasModel:getRedBagNoOpenNum()
    return self._redbag.canNum
end

---
-- 设置红包未拆数量
-- @function [parent=#ChristmasModel] setRedBagNoOpenNum
-- @param #ChristmasModel self
-- @param #number num
function ChristmasModel:setRedBagNoOpenNum(num)
    self._redbag.canNum = num
    local evt = {type = self.redbagChangeEventType}
    zzy.EventManager:dispatch(evt)
end

---
-- 设置红包未拆数量
-- @function [parent=#ChristmasModel] addRedBagNoOpenNum
-- @param #ChristmasModel self
-- @param #number num
function ChristmasModel:addRedBagNoOpenNum(num)
    if num ~= 0 then
        if self._redbag.canNum then
            self._redbag.canNum = self._redbag.canNum+num
        else
            self._redbag.canNum = num
        end
        local evt = {type = self.redbagChangeEventType}
        zzy.EventManager:dispatch(evt)
    end
end

---
-- 获取红包已拆数量
-- @function [parent=#ChristmasModel] getRedBagOpenNum
-- @param #ChristmasModel self
-- @return #number 
function ChristmasModel:getRedBagOpenNum()
    return self._redbag.getNum
end

---
-- 设置红包已拆数量
-- @function [parent=#ChristmasModel] setRedBagOpenNum
-- @param #ChristmasModel self
-- @param #number num
function ChristmasModel:setRedBagOpenNum(num)
    self._redbag.getNum = num
    local evt = {type = self.redbagChangeEventType}
    zzy.EventManager:dispatch(evt)
end

---
-- 设置红包已拆数量
-- @function [parent=#ChristmasModel] addRedBagOpenNum
-- @param #ChristmasModel self
-- @param #number num
function ChristmasModel:addRedBagOpenNum(num)
    if num ~= 0 then
        if self._redbag.getNum then
            self._redbag.getNum = self._redbag.getNum+num
        else
            self._redbag.getNum = num
        end
        local evt = {type = self.redbagChangeEventType}
        zzy.EventManager:dispatch(evt)
    end
end

---
-- 获取活动期间消耗钻石数
-- @function [parent=#ChristmasModel] getRedBagDiamond
-- @param #ChristmasModel self
-- @return #number 
function ChristmasModel:getRedBagDiamond()
    return self._redbag.costNum - math.floor(self._redbag.diamond%self._redbag.costNum)
end

---
-- 设置活动期间消耗钻石数
-- @function [parent=#ChristmasModel] setRedBagDiamond
-- @param #ChristmasModel self
-- @param #number num
function ChristmasModel:setRedBagDiamond(num)
    self._redbag.diamond = num
    local evt = {type = self.redbagChangeEventType}
    zzy.EventManager:dispatch(evt)
end

---
-- 设置活动期间消耗钻石数
-- @function [parent=#ChristmasModel] addRedBagDiamond
-- @param #ChristmasModel self
-- @param #number num
function ChristmasModel:addRedBagDiamond(num)
    local redbagNum = 0
    if num ~= 0 then
        if self._redbag.diamond then
            redbagNum = math.floor((math.floor(self._redbag.diamond%self._redbag.costNum) + num)/self._redbag.costNum)
            self._redbag.diamond = self._redbag.diamond+num
        else
            redbagNum = math.floor(num/self._redbag.costNum)
            self._redbag.diamond = num
        end
        self:addRedBagNoOpenNum(redbagNum)
        local evt = {type = self.redbagChangeEventType}
        zzy.EventManager:dispatch(evt)
    end
end

---
-- 获取活动或得钻石数
-- @function [parent=#ChristmasModel] getRedBagGetDiamond
-- @param #ChristmasModel self
-- @return #table 
function ChristmasModel:getRedBagGetDiamond()
    return self._redbag.getDiamond
end

---
-- 设置活动或得钻石数
-- @function [parent=#ChristmasModel] setRedBagGetDiamond
-- @param #ChristmasModel self
-- @param #number num
function ChristmasModel:setRedBagGetDiamond(num)
    self._redbag.getDiamond = num
    local evt = {type = self.redbagChangeEventType}
    zzy.EventManager:dispatch(evt)
end

---
-- 设置活动或得钻石数
-- @function [parent=#ChristmasModel] addRedBagGetDiamond
-- @param #ChristmasModel self
-- @param #number num
function ChristmasModel:addRedBagGetDiamond(num)
    if num ~= 0 then
        if self._redbag.getDiamond then
            self._redbag.getDiamond = self._redbag.getDiamond+num
        else
            self._redbag.getDiamond = num
        end
        local evt = {type = self.redbagChangeEventType}
        zzy.EventManager:dispatch(evt)
    end
end

---
-- 设置本次红包奖励
-- @function [parent=#ChristmasModel] setRedBagReward
-- @param #ChristmasModel self
-- @param #number reward
function ChristmasModel:setRedBagReward(reward)
    self._redbagReward = reward
    self.openRedBag = true
    local evt = {type = self.redbagOpenEventType}
    zzy.EventManager:dispatch(evt)
    self:addRedBagGetDiamond(self._redbagReward)
end

---
-- 获取本次红包奖励
-- @function [parent=#ChristmasModel] getRedBagReward
-- @param #ChristmasModel self
-- @return #number
function ChristmasModel:getRedBagReward()
    return self._redbagReward or 0
end

---
-- 设置活动期间充值累计钻石数
-- @function [parent=#ChristmasModel] setCZXLDiamond
-- @param #ChristmasModel self
-- @param #number num
function ChristmasModel:setCZXLDiamond(num)
    self._holidayListData[1011].hdata.diamond = num
    self:_raiseDataChangeEvent("0",self.dataType.czxl)
end

---
-- 设置活动期间充值累计钻石数
-- @function [parent=#ChristmasModel] setZSZPDiamond
-- @param #ChristmasModel self
-- @param #number num
function ChristmasModel:setZSZPDiamond(num)
    self._holidayListData[1016].values = num
    self:_raiseDataChangeEvent("0",self.dataType.zszp)
end

---
-- 更改充值选礼领奖状态
-- @function [parent=#ChristmasModel] setCZXLState
-- @param #ChristmasModel self
-- @param #number id
-- @param #number state
function ChristmasModel:setCZXLState(id,state)
    self._holidayListData[1011].hdata.getReward[tostring(id)] = state
    self:_raiseDataChangeEvent("0",self.dataType.czxl)
end

---
-- 设置活动期间消耗累计钻石数
-- @function [parent=#ChristmasModel] setXHFLDiamond
-- @param #ChristmasModel self
-- @param #number num
function ChristmasModel:setXHFLDiamond(num)
    self._holidayListData[1012].hdata.diamond = num
    self:_raiseDataChangeEvent("0",self.dataType.xhfl)
end

---
-- 设置活动期间消耗累计钻石数
-- @function [parent=#ChristmasModel] addXHFLDiamond
-- @param #ChristmasModel self
-- @param #number num
function ChristmasModel:addXHFLDiamond(num)
    if num ~= 0 then
        if not self._holidayListData[1012].hdata.diamond then
            self._holidayListData[1012].hdata.diamond = 0
        end
        self._holidayListData[1012].hdata.diamond = self._holidayListData[1012].hdata.diamond + num
        self:_raiseDataChangeEvent("0",self.dataType.xhfl)
    end
end

---
-- 更改消耗返礼领奖状态
-- @function [parent=#ChristmasModel] setXHFLState
-- @param #ChristmasModel self
-- @param #number id
-- @param #number state
function ChristmasModel:setXHFLState(id,state)
    self._holidayListData[1012].hdata.getReward[tostring(id)] = state
    self:_raiseDataChangeEvent("0",self.dataType.xhfl)
end

---
-- 是否为双倍活动卡牌ID
-- @function [parent=#ChristmasModel] isDoubleCard
-- @param #ChristmasModel self
-- @param #number id
-- @return #table
function ChristmasModel:isDoubleCard(id)
    if ch.ChristmasModel:isOpenByType(1013) then
        local cfgid = self._holidayListData[1013].cfgid or self._data.cfgid
        local card = GameConfig.McslcpConfig:getData(cfgid,self:getHDataByType(1013).day)
        local group = zzy.StringUtils:split(card.group,"|")
        for k,v in pairs(group) do
            if tonumber(v) == tonumber(id) then
                return {isDouble=true,ratio=card.ratio}
            end
        end
    end
    return {isDouble=false,ratio=1}
end

---
-- 获得年兽的hp
-- @function [parent=#ChristmasModel] getNianHp
-- @param #ChristmasModel self
-- @return #number
function ChristmasModel:getNianHp()
    if self._holidayListData[1015] and self._holidayListData[1015].hdata then
        return self._holidayListData[1015].hdata.hp
    end
    return 0
end

---
-- 设置年兽的hp
-- @function [parent=#ChristmasModel] setNianHp
-- @param #ChristmasModel self
-- @return #number
function ChristmasModel:setNianHp(hp)
    if self._holidayListData[1015] and self._holidayListData[1015].hdata then
        if hp ~= self._holidayListData[1015].hdata.hp then
            self._holidayListData[1015].hdata.hp = hp
            self:_raiseNianDataChangeEvent(self.nianDataType.hp)
        end
    end
end

---
-- 添加年兽的hp
-- @function [parent=#ChristmasModel] addNianHp
-- @param #ChristmasModel self
-- @param #number hp
function ChristmasModel:addNianHp(hp)
    if self._holidayListData[1015] and self._holidayListData[1015].hdata then
        if hp ~= 0 then
            self._holidayListData[1015].hdata.hp = self._holidayListData[1015].hdata.hp + hp
            self:_raiseNianDataChangeEvent(self.nianDataType.hp)
        end
    end
end

---
-- 获得年兽的击杀次数
-- @function [parent=#ChristmasModel] getNiankilled
-- @param #ChristmasModel self
-- @return #number
function ChristmasModel:getNiankilled()
    if self._holidayListData[1015] and self._holidayListData[1015].hdata then
        return self._holidayListData[1015].hdata.killed
    end
    return 0
end

---
-- 添加年兽的击杀次数
-- @function [parent=#ChristmasModel] addNiankilled
-- @param #ChristmasModel self
-- @param #number count
function ChristmasModel:addNiankilled(count)
    if self._holidayListData[1015] and self._holidayListData[1015].hdata then
        if count ~= 0 then
            self._holidayListData[1015].hdata.killed = self._holidayListData[1015].hdata.killed +count
            self._holidayListData[1015].hdata.showTime = os_time() + GameConst.CXHD_BASHNIAN_BASH_CD
            self:_raiseNianDataChangeEvent(self.nianDataType.killed)
        end
    end
    return 0
end

---
-- 获得年兽的出现时间
-- @function [parent=#ChristmasModel] getNianShowTime
-- @param #ChristmasModel self
-- @return #number
function ChristmasModel:getNianShowTime()
    if self._holidayListData[1015] and self._holidayListData[1015].hdata then
        return self._holidayListData[1015].hdata.showTime or 0
    end
    return 0
end

---
-- 重置年兽的出现时间
-- @function [parent=#ChristmasModel] resetNianShowTime
-- @param #ChristmasModel self
-- @param #number time
function ChristmasModel:resetNianShowTime(time)
    if self._holidayListData[1015] and self._holidayListData[1015].hdata then
        self._holidayListData[1015].hdata.showTime = time
        self:_raiseNianDataChangeEvent(self.nianDataType.showTime)
    end
    return 0
end

---
-- 设置年兽的奖励
-- @function [parent=#ChristmasModel] setNianReward
-- @param #ChristmasModel self
-- @param #table data {hp=-2,items ={{id=1,type=2,num=30},...}}
function ChristmasModel:setNianReward(data)
    self._nianReward = data
    if data ~= nil then
        self:_raiseNianDataChangeEvent(self.nianDataType.reward)
    end
end

---
-- 获得年兽的奖励
-- @function [parent=#ChristmasModel] getNianReward
-- @param #ChristmasModel self
-- @return #table {hp=-2,items ={{id=1,t=2,num=30},...}}
function ChristmasModel:getNianReward()
    return self._nianReward
end

---
-- 获取钻石转盘当前奖励项
-- @function [parent=#ChristmasModel] getDiamondWheelNum
-- @param #ChristmasModel self
-- @param #table cfg
-- @return #number
function ChristmasModel:getDiamondWheelNum(cfg)
    local num = self:getHDataByType(1016) + 1
    if num > GameConst.HOLIDAY_DIAMOND_WHEEL_MAX then
        num = GameConst.HOLIDAY_DIAMOND_WHEEL_MAX
    end
    return cfg["bonus"..num]
end

---
-- 添加钻石转盘活动已用次数
-- @function [parent=#ChristmasModel] addDiamondWheelCount
-- @param #ChristmasModel self
-- @param #number count
function ChristmasModel:addDiamondWheelCount(count)
    if count ~= 0 then
        self._holidayListData[1016].hdata = self._holidayListData[1016].hdata + count
        local evt = {type = self.diamondWheelChangeEventType}
        zzy.EventManager:dispatch(evt)
    end
end

---
-- 设置钻石转盘奖励
-- @function [parent=#ChristmasModel] setDiamondWheelReward
-- @param #ChristmasModel self
-- @param #table reward
function ChristmasModel:setDiamondWheelReward(reward)
    self._diamondWheelReward = reward
end

---
-- 获取钻石转盘奖励
-- @function [parent=#ChristmasModel] getDiamondWheelReward
-- @param #ChristmasModel self
-- @return #table reward  {t=,id=,num=}
function ChristmasModel:getDiamondWheelReward()
    return self._diamondWheelReward
end

---
-- 获取钻石转盘奖励的id
-- @function [parent=#ChristmasModel] getDiamondWheelId
-- @param #ChristmasModel self
-- @return #table 
function ChristmasModel:getDiamondWheelId()
    return self._diamondWheelId
end

---
-- 设置钻石转盘奖励的id
-- @function [parent=#ChristmasModel] setDiamondWheelId
-- @param #ChristmasModel self
-- @param #number id
function ChristmasModel:setDiamondWheelId(id)
    self._diamondWheelId = id
end

---
-- 获取钻石转盘奖励的花费
-- @function [parent=#ChristmasModel] getDiamondWheelCost
-- @param #ChristmasModel self
-- @return #number
function ChristmasModel:getDiamondWheelCost()
    local num = self:getHDataByType(1016) + 1
    if num > GameConst.HOLIDAY_DIAMOND_WHEEL_MAX then
        num = GameConst.HOLIDAY_DIAMOND_WHEEL_MAX
    end
    return self:getCSVDataByType(1016)[1]["cost"..num]
end


function ChristmasModel:getDiamondWheelCharge()
    local charge = self._holidayListData[1016].values or 0
    return charge
end

function ChristmasModel:getDiamondWheelNeed()
    local num = self:getHDataByType(1016) + 1
    if num > GameConst.HOLIDAY_DIAMOND_WHEEL_MAX then
        num = GameConst.HOLIDAY_DIAMOND_WHEEL_MAX
    end
    
    local need = self:getCSVDataByType(1016)[1]["limit"..num]
    return need
end


---
-- 添加好运滚滚(老虎机)已用次数
-- @function [parent=#ChristmasModel] addHYGGCount
-- @param #ChristmasModel self
-- @param #number count
function ChristmasModel:addHYGGCount(count)
    if count ~= 0 then
        self._holidayListData[1019].hdata = self._holidayListData[1019].hdata + count
        local evt = {type = self.hyggChangeEventType}
        zzy.EventManager:dispatch(evt)
    end
end

---
-- 设置好运滚滚(老虎机)奖励
-- @function [parent=#ChristmasModel] setHYGGReward
-- @param #ChristmasModel self
-- @param #table reward
function ChristmasModel:setHYGGReward(reward)
    self._hyggReward = reward
end

---
-- 获取好运滚滚(老虎机)奖励
-- @function [parent=#ChristmasModel] getHYGGReward
-- @param #ChristmasModel self
-- @return #table reward  {t=,id=,num=}
function ChristmasModel:getHYGGReward()
    return self._hyggReward
end

---
-- 获取好运滚滚(老虎机)奖励的id
-- @function [parent=#ChristmasModel] getHYGGId
-- @param #ChristmasModel self
-- @return #table 
function ChristmasModel:getHYGGId()
    return self._hyggId
end

---
-- 设置好运滚滚(老虎机)奖励的id
-- @function [parent=#ChristmasModel] setHYGGId
-- @param #ChristmasModel self
-- @param #number id
function ChristmasModel:setHYGGId(id)
    self._hyggId = id
end

---
-- 获取好运滚滚(老虎机)的花费
-- @function [parent=#ChristmasModel] getHYGGCost
-- @param #ChristmasModel self
-- @return #number
function ChristmasModel:getHYGGCost()
    local num = self:getHDataByType(1019) + 1
    if num > GameConst.HOLIDAY_HYGG_FREE_COUNT then
        local cfg = self:getCSVDataByType(1019)
        local funcName = "HOLIDAY_HYGG_PRICING_"..cfg[1].formula
        return GameConst[funcName](num-GameConst.HOLIDAY_HYGG_FREE_COUNT)
    else
        return 0
    end
end

---
-- 是否达成活动内要求拥有宠物
-- @function [parent=#ChristmasModel] isOwnPartner
-- @param #ChristmasModel self
-- @param #number id
-- @return #boolean
function ChristmasModel:isOwnPartner(id)
    if ch.ChristmasModel:isOpenByType(1017) then
        local cfgid = self._holidayListData[1017].cfgid or self._data.cfgid
        local card = GameConfig.SlsfConfig:getData(cfgid,self:getHDataByType(1017).day)
        local group = zzy.StringUtils:split(card.group,"|")
        for k,v in pairs(group) do
            if not ch.PartnerModel:ifHavePartner(tostring(v)) then
                return false
            end
        end
        return true
    end
    return false
end

---
-- 判断是否萌宠送福可领奖
-- @function [parent=#ChristmasModel] ifChangeMCSFState
-- @param #ChristmasModel self
function ChristmasModel:ifChangeMCSFState()
    if ch.ChristmasModel:getHolidayState(1017,ch.ChristmasModel:getHDataByType(1017).day) == 0 then
        if ch.ChristmasModel:isOwnPartner(ch.ChristmasModel:getHDataByType(1017).day) then
            ch.ChristmasModel:setHolidayState(1017,ch.ChristmasModel:getHDataByType(1017).day,1)
        end
    end
end

---
-- 是否要显示光效
-- @function [parent=#ChristmasModel] setShowEffect
-- @param #ChristmasModel self
-- @param #ChristmasModel isShow
function ChristmasModel:setShowEffect(isShow)
    self.isEffect = isShow
    self:_raiseDataChangeEvent("0",self.dataType.effect)
end

---
-- 是否要显示光效
-- @function [parent=#ChristmasModel] getShowEffect
-- @param #ChristmasModel self
-- @return #boolean
function ChristmasModel:getShowEffect()
    return self.isEffect
end


---
-- 礼包内容名字（只限礼包内第一个物品）
-- @function [parent=#ChristmasModel] getGiftNameById
-- @param #ChristmasModel self
-- @param #number id
-- @return #string 
function ChristmasModel:getGiftNameById(id)
    local tmp = GameConfig.GiftConfig:getData(id)
    local name = ch.CommonFunc:getRewardName(tmp.idty1,tmp.id1)
    return name
end

---
-- 过天刷新
-- @function [parent=#ChristmasModel] onNextDay
-- @param #ChristmasModel self
function ChristmasModel:onNextDay()
    if self._holidayListData[1002] and self._holidayListData[1002].endTime and self._holidayListData[1002].endTime > os_time() then
        self:addProNumByType(1002,1)
        self:setHolidayState(1002,self:getProNumByType(1002),1)
        if self:getHolidayState(1002,self:getProNumByType(1002)-1) == 1 then
            self:setHolidayState(1002,self:getProNumByType(1002)-1,4)
        end
    end
    
    if self._holidayListData[2037] and self._holidayListData[2037].endTime and self._holidayListData[2037].endTime > os_time() then
        self:addProNumByType(2037,1)
    end
    
    if self._holidayListData[1003] and self._holidayListData[1003].endTime and self._holidayListData[1003].endTime > os_time() then
    --[[ 限购活动永远只使用第一天的数据
        self:addProNumByType(1003,1)
        self._holidayData[1003] = {}
        self._holidayListData[1003].canReward = {}
        self._holidayListData[1003].getReward = {}
        ch.NetworkController:getSdxgPanel()
    ]]
    end
    if self._holidayListData[1006] then
        local now = os_time()
        if self._holidayListData[1006].openTime <= now and self._holidayListData[1006].endTime > now then
            self:addWheelCount(-self._holidayListData[1006].hdata)         
        end
    end
    if ch.ChristmasModel:isOpenByType(1013) then
        self:getHDataByType(1013).day = self:getHDataByType(1013).day + 1
    end 
    if ch.ChristmasModel:isOpenByType(1001) then
        ch.ChristmasModel:setDHGetFreeState(0)
    end 
    if ch.ChristmasModel:isOpenByType(1014) then
        self:getHDataByType(1014).day = self:getHDataByType(1014).day + 1
    end
    if self._holidayListData[1015] then
        local now = os_time()
        if self._holidayListData[1015].openTime <= now and self._holidayListData[1015].endTime > now then
            ch.MoneyModel:addFirecracker(GameConst.CXHD_BASHNIAN_FREE_FIRECRACKER)     
        end
    end
    if self._holidayListData[1017] and self._holidayListData[1017].endTime and self._holidayListData[1017].endTime > os_time() then
        self:getHDataByType(1017).day = self:getHDataByType(1017).day + 1
        self:setHolidayState(1017,self:getHDataByType(1017).day,0)
        if self:getHolidayState(1017,self:getHDataByType(1017).day-1) == 1 then
            self:setHolidayState(1017,self:getHDataByType(1017).day-1,4)
        end
        self:ifChangeMCSFState()
    end
    if self._holidayListData[1019] then
        local now = os_time()
        if self._holidayListData[1019].openTime <= now and self._holidayListData[1019].endTime > now then
            self:addHYGGCount(-self._holidayListData[1019].hdata)         
        end
    end
    self:_raiseDataChangeEvent("0",self.dataType.nextday)
end

---
-- 获得荣耀金矿的相关数据
-- @function [parent=#ChristmasModel] getGloryGoldData
-- @param #ChristmasModel self

function ChristmasModel:getGloryGoldData()
    return self._gloryExpectedReward,self._gloryGoldList
end
---
-- 设置荣耀金矿的相关数据
-- @function [parent=#ChristmasModel] setGloryGoldData
-- @param #ChristmasModel self
function ChristmasModel:setGloryGoldData(data)
    if (data.expectedReward)then
        self._gloryExpectedReward=data.expectedReward
    else
        self._gloryExpectedReward=nil
    end
    self._gloryGoldList=self._gloryGoldList or {};
    
    for index=1,#self._gloryGoldList do
    --for index in ipairs(self._gloryGoldList) do
    	self._gloryGoldList[index]=nil
    end
    if(data.list) then
        for index,value  in ipairs(data.list) do
            cclog("setGloryGoldData.data.time===="..value.time)
            self._gloryGoldList[index]=self._gloryGoldList[index] or {}
            self._gloryGoldList[index].index=index
            self._gloryGoldList[index].id=value.id
            self._gloryGoldList[index].time=value.time
            self._gloryGoldList[index].name=value.name
            self._gloryGoldList[index].level=value.level
            self._gloryGoldList[index].reward=value.reward
        end
    end
    local event = {type = self.GAMEEventType_GloryGoldChange}
    zzy.EventManager:dispatch(event)
end

---
-- 获取活动兑换币的数量
function ChristmasModel:getJRDHCount()
    return self._holidayListData[1001].hdata.count
end

function ChristmasModel:setJRDHCount(num)
    self._holidayListData[1001].hdata.count = num
end

function ChristmasModel:addJRDHCount(num)
    self._holidayListData[1001].hdata.count = self._holidayListData[1001].hdata.count or 0
    self._holidayListData[1001].hdata.count = self._holidayListData[1001].hdata.count + num
end

return ChristmasModel