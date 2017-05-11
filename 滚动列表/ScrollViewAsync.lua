local ScrollViewAsync = class("ScrollViewAsync")
local WaitingBar = require("sg.component.WaitingBar")

--携程开关,便于调试
ScrollViewAsync.USE_CORO = true

---------------------------
--@return #type description
--
function ScrollViewAsync:ctor(scrollView, unitCreateFunctions, unitUpdateFuntions, colNum, align, funcAfterCoro, unitDatas,use_core)
    self.funcAfterCoro = funcAfterCoro
    --控制是否使用携程
    if use_core ~= nil then
        self.use_core = use_core
    else
        self.use_core = ScrollViewAsync.USE_CORO
    end
    ------("ScrollViewAsync init")
    --容器不能为空
    if (scrollView == nil) then
        cclog("[ERROR]<ScrollViewAsync>:scrollView is nil")
        return nil
    end

    --单元创建方法不能为空
    if (unitCreateFunctions == nil) then
        cclog("[ERROR]<ScrollViewAsync>:unitFuntions is nil, cant't create unit")
        return nil
    end

    --单元显示方法不能为空
    if (unitUpdateFuntions == nil) then
        cclog("[ERROR]<ScrollViewAsync>:unitUpdateFuntions is nil, cant't udpate unit")
        return nil
    end

    --初始化数据
    self.colNum = colNum or 2
    self.unitCreateFunctions = unitCreateFunctions
    self.unitUpdateFunctions = unitUpdateFuntions
	self.unitDatas = unitDatas or {}
    
    self.unitWidth = nil
    self.unitHeight = nil
    for k,unitCreateFunction in pairs(self.unitCreateFunctions) do
        local unitTemp = unitCreateFunction()
        self.unitWidth = unitTemp:getSize().width
        self.unitHeight = unitTemp:getSize().height
        break
    end
    
    if self.unitWidth == nil then
        cclog("[WARNING]<ScrollViewAsync>:size of unitUpdateFuntions is 0")
        return nil
    end

    --初始化容器
    self.scrollView = scrollView
    self.scrollViewWidth = scrollView:getContentSize().width
    self.scrollViewHeight = scrollView:getContentSize().height
    self.scrollViewWidthMin = scrollView:getContentSize().width
    self.scrollViewHeightMin = scrollView:getContentSize().height
    
    --初始化单元间隔
    self.align = {}
    if align ~= nil then
        --横向边距
        self.align.marginX = align.marginX or 0
        --纵向边距
        self.align.marginY = align.marginY or 0
        --单元横向间距
        self.align.spaceX = align.spaceX or 0
        --单元纵向间距
        self.align.spaceY = align.spaceY or 0
    else
        --横向边距
        self.align.marginX = 0
        --纵向边距
        self.align.marginY = 0
        --单元横向间距
        self.align.spaceX = 0
        --单元纵向间距
        self.align.spaceY = 0
    end
    self:initScrollView()
    
    if self.use_core then
        --创建异步,调用创建函数,每一帧创建一个单元
        self.co = coroutine.create(handler(self, self.initUnits))

        local function update()
            --log暂时保留，测试是否有地方没有释放
            --cclog("ScrollViewAsync running!!!!!")
            coroutine.resume(self.co)
        end
        self.timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 1/60, false)
    else
        self:initUnits()
        if  self.funcAfterCoro then
            self.funcAfterCoro()
        end
    end
end

--初始化所有单元
function ScrollViewAsync:initUnits()
    local index = 0
    self.units = {}
    self.key2Index = {}
    self.index2Key = {}

    --创建可视单元
    for key,unitUpdateFunction in pairs(self.unitUpdateFunctions) do
        --创建并显示单元
        index = index + 1
        self.units[key] = self.unitCreateFunctions[key]()
        self.units[key].key = key
        self.units[key].index = index
        self.key2Index[key] = index
        self.index2Key[index] = key
        self.unitUpdateFunctions[key](self.units[key], key, self.unitDatas[key])
        
        --摆放并添加单元
        if self.scrollView then
            self.scrollView:addChild(self.units[key])
        else
            break
        end
        self.units[key]:setPosition(self:getPos(key))
        
        if self.use_core then
            coroutine.yield()
        end
    end
       
    if self.use_core then
    	if  self.funcAfterCoro then
        	self.funcAfterCoro()
    	end
    	
        coroutine.yield()
    end
    
    if self.use_core and self.timer ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
        self.timer = nil
        self.co = nil
    end
end

function ScrollViewAsync:updateFunctions(unitUpdateFunctions)
    self.unitUpdateFunctions = unitUpdateFunctions
end

function ScrollViewAsync:updateUnits()
	if self.units then
		for key,unitUpdateFunction in pairs(self.unitUpdateFunctions) do
			--携程走到一半（例如70/100）,就调用这里刷新包裹，这个函数会比携程跑的还快，出现units[71]为nil的情况
			if self.units[key] and self.unitUpdateFunctions[key] then
				self.unitUpdateFunctions[key](self.units[key], key)
			end
		end
	end
end

--计算位置
function ScrollViewAsync:getPos(key)
    local index = self.key2Index[key]
    local row, col = math.floor((index + self.colNum - 1)/self.colNum), (index - 1)%(self.colNum) + 1
    local posX = self.align.marginX + (col - 1)*(self.align.spaceX + self.unitWidth)
    local posY = (self.scrollViewHeight - self.unitHeight) -self.align.spaceY - (row - 1)*(self.align.spaceY + self.unitHeight) - self.align.marginY
    return posX, posY
end

function ScrollViewAsync:initScrollView()
    --行数
    local totalFunctionsNum = 0 
    for k,v in pairs(self.unitUpdateFunctions) do
        totalFunctionsNum = totalFunctionsNum+1
    end
    self.rowNum = math.floor((totalFunctionsNum + self.colNum - 1)/self.colNum)

    --设置容器大小
    local scrollViewWidth  = 2*self.align.marginX + self.unitWidth*self.colNum + self.align.marginY*(self.colNum-1)
    local scrollViewHeight = 2*self.align.marginY + self.unitHeight*self.rowNum + self.align.spaceY*(self.rowNum-1)+10

    if  scrollViewWidth >= self.scrollViewWidthMin then
        self.scrollViewWidth = scrollViewWidth
    end

    if  scrollViewHeight >= self.scrollViewHeightMin then
        self.scrollViewHeight = scrollViewHeight
    end

    if  self.bool then
    else
        self.scrollView:setInnerContainerSize(cc.size(self.scrollViewWidth, self.scrollViewHeight))
    end
    --self.scrollView:setContentSize(self.scrollViewWidth, self.scrollViewHeight)
end

--更新一个单元(使用key定位单元,并更新)
function ScrollViewAsync:updateUnitByKey(key, updateFunction)
    self.unitUpdateFunctions[key] = updateFunction
    self.unitUpdateFunctions[key](self.units[key], key)
end

--更新一个单元(使用index定位单元,并更新)
function ScrollViewAsync:updateUnitByIndex(index, updateFunction)
    local key = self.index2Key[index]
    self:updateUnitByKey(key, updateFunction)
end

--插入一个单元
function ScrollViewAsync:insertUnitByKey(key, unitCreateFunction, unitUpdateFunction)
    
    self.unitCreateFunctions[key] = unitCreateFunction
    self.unitUpdateFunctions[key] = unitUpdateFunction
    
    local unit = unitCreateFunction()
    unitUpdateFunction(unit, key)
    self.scrollView:addChild(unit)
    
    self.units[key] = unit
    self:refreshView()
end

--插入一个单元
function ScrollViewAsync:insertUnitByIndex(index, unitCreateFunction, unitUpdateFunction, key)
    if key == nil then
        key = index
    end
    
    self.unitCreateFunctions[key] = unitCreateFunction
    self.unitUpdateFunctions[key] = unitUpdateFunction

    local unit = unitCreateFunction()
    unitUpdateFunction(unit, key)
    self.scrollView:addChild(unit)
end

--删除一个单元,根据key
function ScrollViewAsync:deleteUnitByKey(key)
    local unit = self.units[key]
    unit:removeFromParent()
    
    self.unitUpdateFunctions[key] = nil
    self.unitUpdateFunctions[key] = nil
    self.units[key] = nil
    
    local index = self.key2Index[key]
    self.key2Index[key] = nil
    self.index2Key[index] = nil
    
    self:refreshView()
end

--删除一个单元,根据index
function ScrollViewAsync:deleteUnitByIndex(index)
    local key = self.index2Key[index]
    self:deleteUnitByKey(key)
end

--删除和添加单元之后,刷新所有单元位置
function ScrollViewAsync:refreshView(index)
    local index = 0
    for key,unit in pairs(self.units) do
        index = index + 1
        unit.key = key
        unit.index = index
        self.key2Index[key] = index
        self.index2Key[index] = key
        
        unit:setPosition(self:getPos(key))
    end
end

function ScrollViewAsync:dtor()
    if self.use_core and self.timer ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
        self.timer = nil
        self.co = nil
    end
    
    self = nil
end

return ScrollViewAsync
