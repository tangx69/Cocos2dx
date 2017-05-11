local ScrollViewSmart = class("ScrollViewSmart")

local WaitingBar = require("sg.component.WaitingBar")

--初始化总行数 =  计算出的容器内可视的行数 + ScrollViewSmart.EXTRA_UNIT_NUM
ScrollViewSmart.EXTRA_UNIT_NUM = 2

---------------------------
--@return #type description
--
function ScrollViewSmart:ctor(scrollView, unitCreateFunctions, unitUpdateFuntions, colNum, align, flag)
    ------("ScrollViewSmart init ScrollViewSmart")
    --容器不能为空
    if (scrollView == nil) then
        cclog("[ERROR]<ScrollViewSmart>:scrollView is nil")
        return nil
    end
    
    --单元创建方法不能为空
    if (unitCreateFunctions == nil) then
        cclog("[ERROR]<ScrollViewSmart>:unitFuntions is nil, cant't create unit")
        return nil
    end
	
	--单元显示方法不能为空
    if (unitUpdateFuntions == nil) then
        cclog("[ERROR]<ScrollViewSmart>:unitUpdateFuntions is nil, cant't udpate unit")
        return nil
    end
    
    self.flag = flag
	
	self.moves = {}
	
	self.unitCreateFunctions = unitCreateFunctions
	self.unitUpdateFunctions = unitUpdateFuntions
	
    --计算单元大小
    self.unitTemp = self.unitCreateFunctions[1]()
    self.unitWidth = self.unitTemp:getSize().width
    self.unitHeight = self.unitTemp:getSize().height
    scrollView:addChild(self.unitTemp)
    self.unitTemp:setVisible(false)
    
    --容器
    self.scrollView = scrollView
    self.scrollViewWidth = scrollView:getContentSize().width
    self.scrollViewHeight = scrollView:getContentSize().height
    self.scrollViewWidthMin = scrollView:getContentSize().width
    self.scrollViewHeightMin = scrollView:getContentSize().height
    --列数
    self.colNum = colNum or 2
	--偏移量,向上滚动一行+1
	self.offset = 0
	
	self.align = {}
	if align ~= nil then
		--横向边距
		self.align.marginX = align.marginX
		--纵向边距
		self.align.marginY = align.marginY
		--单元横向间距
		self.align.spaceX = align.spaceX
		--单元纵向间距
		self.align.spaceY = align.spaceY
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
    self:initScrollView(scrollView)
    --self:initUnits()
    
    local function onScroll()
        self:onScroll()
        self:move()
    end
    
	--监听滚动事件
    self.scrollView:addEventListenerScrollView(onScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    --self.ticker = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onScroll, 0, false)
    
    self.displayTimer = nil
    local function onTimerEnd(sender, eventType)
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.displayTimer)
        self.displayTimer = nil
        self:initUnits()
        self:updateUnits()
        WaitingBar:CloseWaiting()
    end
    self.displayTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, onTimerEnd), 0.1, false)
    
    WaitingBar:create()
end

--容器滚动时,移动一排units
function ScrollViewSmart:onScroll()
    ------("--onScroll--")
    local curPosY = self.unitTemp:getWorldPosition().y
    if self.unitTempPosY == nil then
        self.unitTempPosY = curPosY +  self.unitHeight - 1
    end
    
    if (curPosY - self.unitTempPosY) >= self.unitHeight then
        self:calcMoves(curPosY, self.unitTempPosY)
    elseif (self.unitTempPosY - curPosY) >= self.unitHeight then
        self:calcMoves(curPosY, self.unitTempPosY)
	end
end

--根据当前位移计算需要上/下移动几次
function ScrollViewSmart:calcMoves(curPosY, prePosY)
    if (curPosY - prePosY) >= self.unitHeight then
        local moveTimes = math.floor((curPosY - prePosY)/self.unitHeight)
        for i=1,moveTimes do
            ------("need top2down")
            table.insert(self.moves, "top2down")
        end
        
        self.unitTempPosY = prePosY + self.unitHeight*moveTimes
    elseif (prePosY - curPosY) >= self.unitHeight then
        local moveTimes = math.floor((prePosY - curPosY)/self.unitHeight)
        for i=1,moveTimes do
            ------("need down2top")
            table.insert(self.moves, "down2top")
        end
        
        self.unitTempPosY = prePosY - self.unitHeight*moveTimes
    end
end

function ScrollViewSmart:move()
    for k,move in pairs(self.moves) do
        if move== "top2down" then
            self:moveTop2Down()
            self.moves[k] = nil
            ------("do top2down")
        elseif move== "down2top" then
            self:moveDown2Top()
            self.moves[k] = nil
            ------("do down2top")
        end
    end
end

function ScrollViewSmart:moveTop2Down()
    --重新定位顶层
    local headRow = self.head.oriRow + 1
    if headRow > self.rowNumVisible then
        headRow = 1
    end
    local temp = self.units[headRow]
	
    --移动顶层到底，并重新绘制
    self.head.viewRow = self.head.viewRow + self.rowNumVisible
    self:drawRow(self.head)
    
    --改变头尾指向
	self.tail = self.head
    self.head = temp
	
	self.offset = self.offset + 1
    ------("****self.offset = %d***", self.offset)
end

function ScrollViewSmart:moveDown2Top()
    --移动完成之后,重新定位顶层
    local tailRow = self.tail.oriRow - 1
    if tailRow == 0 then
        tailRow = self.rowNumVisible
    end
    local temp = self.units[tailRow]
    
    --移动底层到顶，并重新绘制
    self.tail.viewRow = self.tail.viewRow - self.rowNumVisible
    self:drawRow(self.tail)
	
    --改变头尾指向
    self.head = self.tail
    self.tail = temp

    self.offset = self.offset - 1
    ------("****self.offset = %d***", self.offset)
end

--计算当前scrollview 可以看见几行
function ScrollViewSmart:getVisibleMaxRowNum()
    local unit = self.unitCreateFunctions[1]()
    local unitSize = unit:getSize()
    
	self.rowNumVisible = 1
	
	for i=1, 100 do
        if self.align.marginY + i*(unitSize.height+self.align.spaceY) >= self.scrollView:getContentSize().height then
            self.rowNumVisible = i + ScrollViewSmart.EXTRA_UNIT_NUM
			break
		end
	end
	
	return self.rowNumVisible
end

--创建可视单元
function ScrollViewSmart:initUnits()
	self.units = {}
	--创建可视单元
	local rowNumVisible = self:getVisibleMaxRowNum()
	for i=1,rowNumVisible do
		self.units[i] = {}
		self.units[i].oriRow = i
		self.units[i].viewRow = i
		for j=1,self.colNum do
            local index = self:getIndexByRowCol(i,j)
            --创建并显示单元
            self.units[i][j] = self.unitCreateFunctions[index]()
            --self.unitUpdateFunctions[index](self.units[i][j], index)
            --摆放并添加单元
            ------("initUnits i=%d, j=%d", i, j)
            self.units[i][j]:setPosition(self:getPosByRowCol(i, j))
            self.scrollView:addChild(self.units[i][j])
		end
	end
	
	--初始化头尾
	self.head = self.units[1]
	self.tail = self.units[self.rowNumVisible]
	self.mid  = self.units[math.floor((1+self.rowNumVisible)/2)]
end


function ScrollViewSmart:updateUnits()
    --更新可视单元
    local rowNumVisible = self:getVisibleMaxRowNum()
    for i=1,rowNumVisible do
        for j=1,self.colNum do
            local index = self:getIndexByRowCol(i,j)
            self.unitUpdateFunctions[index](self.units[i][j], index, self.flag)
        end
    end
end

function ScrollViewSmart:initScrollView()
    --行数
    self.rowNum = math.floor((#self.unitUpdateFunctions + self.colNum - 1)/self.colNum)
    
    --设置容器大小
    local scrollViewWidth  = 2*self.align.marginX + self.unitWidth*self.colNum + self.align.marginY*(self.colNum-1)
    local scrollViewHeight = 2*self.align.marginY + self.unitHeight*self.rowNum + self.align.spaceY*(self.rowNum-1)
    
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

function ScrollViewSmart:getRowColByIndex(index)
    return math.floor((index + self.colNum - 1)/self.colNum), (index - 1)%(self.colNum) + 1
end

function ScrollViewSmart:getIndexByRowCol(row, col)
    return (row-1)*self.colNum+col
end

function ScrollViewSmart:getPosByRowCol(row, col)
    
    local posX = self.align.marginX + (col - 1)*(self.align.spaceX + self.unitWidth)
    local posY = (self.scrollViewHeight - self.unitHeight) -self.align.spaceY - (row - 1)*(self.align.spaceY + self.unitHeight) - self.align.marginY
    return posX, posY
end
--[[
function ScrollViewSmart:getPosByIndex(index)
    local col, row = self:getRowColByIndex(index)
    local posX = self.align.marginX + (col - 1)*(self.align.spaceX + self.unitWidth)
    local posY = (self.scrollViewHeight - self.unitHeight) -self.align.spaceY - (row - 1)*(self.align.spaceY + self.unitHeight) - self.align.marginY
    return posX, posY
end
]]--

--绘制一排
function ScrollViewSmart:drawRow(row)
    for k,unit in pairs(row) do
        if type(k) == "number" then
            ------("***drawRow i=%d, j=%d***", row.viewRow, k)
            local index = self:getIndexByRowCol(row.viewRow, k)
            unit:setPosition(self:getPosByRowCol(row.viewRow, k))
            
            if index <= #self.unitUpdateFunctions then
                unit:setVisible(true)
                self.unitUpdateFunctions[index](unit, index)
            else
                unit:setVisible(false)
            end
        end
	end
end

function ScrollViewSmart:updateUnit(index, updateFunction)
    self.unitUpdateFunctions[index] = updateFunction
    local row,col = self:getRowColByIndex(index)
    
    --更新的单元当前已经显示出来了
    if row >= self.head.viewRow and row <= self.tail.viewRow then
        self.unitUpdateFunctions[index](self.units[(row-1)%self.rowNumVisible+1][col], index)
    end
end

function ScrollViewSmart:dtor()
    --释放定时器
    if self.ticker ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.ticker)
        self.ticker = nil
    end
    self = nil
end

return ScrollViewSmart
