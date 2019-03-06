---
-- 矿场 model层 
--@module MineModel
local MineModel = {
    _data = nil,
    curPage = nil,
    _pageData = nil,
    _curMineId = nil,
    _isWin = nil,
    _winId = nil,
    _addBerylNum = nil,
    _attLogData = nil,
    isOpen = false,
    dataChangeEventType = "MineModelDataChange", --{type = ,id=,dataType =}
    dataType = {
        curPage = 1,
        beryl = 2,
        attack = 3,
        occupy = 4,
        state = 5,
        nextday = 6,
        panel = 7,
        page = 8
    }
}


---
-- @function [parent=#MineModel] init
-- @param #MineModel self
-- @param #table data
function MineModel:init(data)
    self._data = data.mine
    if not self._data.occAdd then
        self._data = {
            occAdd=GameConst.MINE_OCCUPATION_RESET,
            attNum=GameConst.MINE_ATTACK_MAX,
            occNum=GameConst.MINE_OCCUPATION_MAX,
            myMineId = 0}
    end
    self._pageData = {}
    self.curPage = 1
end

---
-- @function [parent=#MineModel] clean
-- @param #MineModel self
function MineModel:clean()
    self._data = nil
    self.curPage = nil
    self._pageData = nil
    self._curMineId = nil
    self._isWin = nil
    self._winId = nil
    self._addBerylNum = nil
    self._attLogData = nil
    self.isOpen = false
end

function MineModel:_raiseDataChangeEvent(id,dataType)
    local evt = {
        id = id,
        type = self.dataChangeEventType,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end


---
-- 获取当前打开页签
-- @function [parent=#MineModel] getCurPage
-- @param #MineModel self
-- @return #number
function MineModel:getCurPage()
    return self.curPage
end

---
-- 修改当前打开页签
-- @function [parent=#MineModel] setCurPage
-- @param #MineModel self
-- @param #number page
function MineModel:setCurPage(page)
    self.curPage = page
    self:_raiseDataChangeEvent("0",self.dataType.curPage)
end

---
-- 我的矿区界面信息
-- @function [parent=#MineModel] setMinePanel
-- @param #MineModel self
-- @param #table data
function MineModel:setMinePanel(data)
    self._data.myMineId = data.myMineId
    self._data.beryl = data.beryl
    self._data.stime = data.stime
    self._data.ptime = data.ptime
    self:_raiseDataChangeEvent("0",self.dataType.panel) 
end

---
-- 攻打矿井成功或失败的信息
-- @function [parent=#MineModel] setAttackWin
-- @param #MineModel self
-- @param #number win
-- @param #number id
function MineModel:setAttackWin(win,id)
    self._isWin = win == 1
    self._winId = id
end

---
-- 攻打矿井成功或失败的信息
-- @function [parent=#MineModel] getAttackWinId
-- @param #MineModel self
-- @return #number
function MineModel:getAttackWinId()
    return self._winId or 0
end



---
-- 绿宝石数量
-- @function [parent=#MineModel] getBerylNum
-- @param #MineModel self
-- @return #number
function MineModel:getBerylNum()
    return self._data.beryl or 0
end

---
-- 绿宝石数量
-- @function [parent=#MineModel] setBerylNum
-- @param #MineModel self
-- @param #number num
function MineModel:setBerylNum(num)
    self._data.beryl = num
    self:_raiseDataChangeEvent("0",self.dataType.beryl)
end

---
-- 绿宝石数量
-- @function [parent=#MineModel] addBerylNum
-- @param #MineModel self
-- @param #number num
function MineModel:addBerylNum(num)
    if num ~= 0 then
        self._data.beryl = self._data.beryl + num
        self:_raiseDataChangeEvent("0",self.dataType.beryl)
    end
end

---
-- 剩余攻打次数
-- @function [parent=#MineModel] getAttNum
-- @param #MineModel self
-- @return #number
function MineModel:getAttNum()
    return self._data.attNum or 0
end

---
-- 剩余攻打次数
-- @function [parent=#MineModel] setAttNum
-- @param #MineModel self
-- @param #number num
function MineModel:setAttNum(num)
    self._data.attNum = num
    self:_raiseDataChangeEvent("0",self.dataType.attack)
end

---
-- 剩余攻打次数
-- @function [parent=#MineModel] addAttNum
-- @param #MineModel self
-- @param #number num
function MineModel:addAttNum(num)
    if num ~= 0 then
        if not self._data.attNum then
            self._data.attNum = 0
        end
        self._data.attNum = self._data.attNum + num
        self:_raiseDataChangeEvent("0",self.dataType.attack)
    end
end

---
-- 剩余占领次数
-- @function [parent=#MineModel] getOccNum
-- @param #MineModel self
-- @return #number
function MineModel:getOccNum()
    return self._data.occNum or 0
end

---
-- 剩余占领次数
-- @function [parent=#MineModel] setOccNum
-- @param #MineModel self
-- @param #number num
function MineModel:setOccNum(num)
    self._data.occNum = num
    self:_raiseDataChangeEvent("0",self.dataType.occupy)
end

---
-- 剩余占领次数
-- @function [parent=#MineModel] addOccNum
-- @param #MineModel self
-- @param #number num
function MineModel:addOccNum(num)
    if num ~= 0 then
        if not self._data.occNum then
            self._data.occNum = 0
        end
        self._data.occNum = self._data.occNum + num
        self:_raiseDataChangeEvent("0",self.dataType.occupy)
    end
end

---
-- 剩余补充占领次数
-- @function [parent=#MineModel] getResetOccNum
-- @param #MineModel self
-- @return #number
function MineModel:getResetOccNum()
    return self._data.occAdd or 0
end

---
-- 剩余补充占领次数
-- @function [parent=#MineModel] setResetOccNum
-- @param #MineModel self
-- @param #number num
function MineModel:setResetOccNum(num)
    self._data.occAdd = num
    self:_raiseDataChangeEvent("0",self.dataType.occupy)
end

---
-- 剩余补充占领次数
-- @function [parent=#MineModel] addResetOccNum
-- @param #MineModel self
-- @param #number num
function MineModel:addResetOccNum(num)
    if num ~= 0 then
        if not self._data.occAdd then
            self._data.occAdd = 0
        end
        self._data.occAdd = self._data.occAdd + num
        self:_raiseDataChangeEvent("0",self.dataType.occupy)
    end
end

---
-- 通过矿山ID得到矿山等级信息
-- @function [parent=#MineModel] getLvDataByID
-- @param #MineModel self
-- @param #number id
-- @return #table 
function MineModel:getLvDataByID(id)
    if id and id > 0 then
        local level = GameConfig.Mine_zoneConfig:getData(id).level
        return GameConfig.Mine_defConfig:getData(level)
    else
        return GameConst.MINE_OPEN_DATA
    end
end

---
-- 自己矿山状态变化
-- @function [parent=#MineModel] setMyMineState
-- @param #MineModel self
-- @param #number state
function MineModel:setMyMineState(state)
    if state == 1 or state == 4 then
        self:setMyMineId(0)
        self:setDefTimeCD(0)
        self:setOccTimeCD(0)
    end
    self:_raiseDataChangeEvent("0",self.dataType.state)
end


---
-- 自己拥有的矿山所在矿区
-- @function [parent=#MineModel] getMyMineZone
-- @param #MineModel self
-- @return #number 
function MineModel:getMyMineZone()
    if self._data.myMineId and self._data.myMineId > 0 then
        return GameConfig.Mine_zoneConfig:getData(self._data.myMineId).zone
    else
        return 1
    end
end

---
-- 自己拥有的矿山ID
-- @function [parent=#MineModel] getMyMineId
-- @param #MineModel self
-- @return #number 
function MineModel:getMyMineId()
    return self._data.myMineId or 0
end

---
-- 自己拥有的矿山ID
-- @function [parent=#MineModel] setMyMineId
-- @param #MineModel self
-- @param #number id
function MineModel:setMyMineId(id)
    self._data.myMineId = id
end

---
-- 结算绿宝石
-- @function [parent=#MineModel] getAddBerylNum
-- @param #MineModel self
-- @return #number 
function MineModel:getAddBerylNum()
    return self._addBerylNum or 0
end

---
-- 结算绿宝石
-- @function [parent=#MineModel] setAddBerylNum
-- @param #MineModel self
-- @param #number num
function MineModel:setAddBerylNum(num)
    self._addBerylNum = num
end

---
-- 当前页面矿山信息
-- @function [parent=#MineModel] getPageDataByPos
-- @param #MineModel self
-- @param #number pos
-- @return #table
function MineModel:getPageDataByPos(pos)
    return self._pageData[pos] or {}
end

---
-- 设置当前页面矿山信息
-- @function [parent=#MineModel] setPageData
-- @param #MineModel self
-- @param #table data
function MineModel:setPageData(data)
    self._pageData = data
    self:_raiseDataChangeEvent("0",self.dataType.page)
end


---
-- 当前选中矿山ID
-- @function [parent=#MineModel] getCurMineId
-- @param #MineModel self
-- @return #number
function MineModel:getCurMineId()
    return self._curMineId
end

---
-- 设置当前页面矿山信息
-- @function [parent=#MineModel] setCurMineId
-- @param #MineModel self
-- @param #number id
function MineModel:setCurMineId(id)
    self._curMineId = id
end

---
-- 占领cd时间
-- @function [parent=#MineModel] setOccTimeCD
-- @param #MineModel self
-- @param #number time
function MineModel:setOccTimeCD(time)
    self._data.stime = time
end

---
-- 占领cd时间
-- @function [parent=#MineModel] getOccTimeCD
-- @param #MineModel self
-- @return #number
function MineModel:getOccTimeCD()
    if self._data and self._data.stime then
        local leftTime = self._data.stime - os_time()
        if leftTime > 0 then return math.floor(leftTime) end
    end
    return -1
end

---
-- 保护cd时间
-- @function [parent=#MineModel] setDefTimeCD
-- @param #MineModel self
-- @param #number time
function MineModel:setDefTimeCD(time)
    self._data.ptime = time
end

---
-- 保护cd时间
-- @function [parent=#MineModel] getDefTimeCD
-- @param #MineModel self
-- @return #number
function MineModel:getDefTimeCD()
    if self._data and self._data.ptime then
        local leftTime = self._data.ptime - os_time()
        if leftTime > 0 then return math.floor(leftTime) end
    end
    return -1
end

---
-- 矿区战斗记录
-- @function [parent=#MineModel] getAttLogData
-- @param #MineModel self
-- @return #table 
function MineModel:getAttLogData()
    return self._attLogData or {}
end

---
-- 矿区战斗记录
-- @function [parent=#MineModel] setAttLogData
-- @param #MineModel self
-- @param #table data
function MineModel:setAttLogData(data)
    self._attLogData = data
end

---
-- 过天逻辑
-- @function [parent=#MineModel] onNextDay
-- @param #MineModel self
function MineModel:onNextDay()
    self._data.attNum = GameConst.MINE_ATTACK_MAX
    self._data.occNum = GameConst.MINE_OCCUPATION_MAX
    self._data.occAdd = GameConst.MINE_OCCUPATION_RESET

    self:_raiseDataChangeEvent(self.dataType.nextday)
end

return MineModel