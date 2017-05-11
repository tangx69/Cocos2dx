local ScrollViewEx = class("ScrollViewEx")

---------------------------
--@return #type description
--
function ScrollViewEx:ctor(container, units, colNum, marginX, marginY, spaceX, spaceY,bool)
    --容器判断
    if (container == nil) then
        cclog("[ERROR]<ScrollViewEx>:container is nil")
        return nil
    end
    
    --单元判断
    if (units == nil) then
        cclog("[WARNING]<ScrollViewEx>:units is nil")
        return nil
    end
	
    self.bool = bool
	--容器
	self.container = container
    self.containerWidth = container:getContentSize().width
    self.containerHeight = container:getContentSize().height
    self.containerWidthMin = container:getContentSize().width
    self.containerHeightMin = container:getContentSize().height
    --列数
    self.colNum = colNum or 2
    --横向边距
    self.marginX = marginX or 0
    --纵向边距
    self.marginY = marginY or 0
    --单元横向间距
    self.spaceX = spaceX or 0
    --单元纵向间距
    self.spaceY = spaceY or 0
    
    self.units = units
    self:initUnits()
    self:initContainer(container)
    
	--添加单元到容器
	for idx,unit in pairs(self.units) do
        self.container:addChild(unit)
    end
	
	self:Draw()
end

function ScrollViewEx:initUnits()	
	local unit = nil
    for k,v in pairs(self.units) do
    	unit = v
    	break
    end

    if unit then
        self.unitWidth = unit:getContentSize().width
        self.unittHeight = unit:getContentSize().height
    else
        self.unitWidth = 100
        self.unittHeight = 100
        cclog("ScrollViewEx:初始化列表为空,无法得知单元格大小")
    end
end

function ScrollViewEx:initContainer()
    --行数
    self.rowNum = math.floor((#self.units + self.colNum - 1)/self.colNum)
    
	--设置容器大小
    local containerWidth  = 2*self.marginX + self.unitWidth*self.colNum + self.spaceX*(self.colNum-1)
    local containerHeight = 2*self.marginY + self.unittHeight*self.rowNum + self.spaceY*(self.rowNum-1)
    
    if  containerWidth >= self.containerWidthMin then
        self.containerWidth = containerWidth
    end
    
    if  containerHeight >= self.containerHeightMin then
        self.containerHeight = containerHeight
    end
    if  self.bool then

    else
        self.container:setInnerContainerSize(cc.size(self.containerWidth, self.containerHeight))
    end
	
	--self.container:setContentSize(self.containerWidth, self.containerHeight)
end

function ScrollViewEx:getPos(index)
    local col, row = (index - 1)%(self.colNum) + 1, math.floor((index + self.colNum - 1)/self.colNum)
    local posX = self.marginX + (col - 1)*(self.spaceX + self.unitWidth)
    local posY = (self.containerHeight - self.unittHeight) -self.spaceY - (row - 1)*(self.spaceY + self.unittHeight) - self.marginY
    return posX, posY
end

function ScrollViewEx:delUnits(indexs)
    for k,v in pairs(indexs) do
		self.units[v]:removeFromParent()
		self.units[v] = nil
	end

	self:Draw()
end

function ScrollViewEx:delUnit(id)
	for k,v in pairs(self.units) do
		if v.id == id then
			self.units[k]:removeFromParent()
			--self.units[k] = nil
			table.remove(self.units, k)
			
		end
	end

    self:Draw()
end

function ScrollViewEx:addUnit(unit)
    --初始sv的时候units为空,则在add时候计算
    self.unitWidth = unit:getSize().width
    self.unittHeight = unit:getSize().height
    
	table.insert(self.units, unit)
	self.container:addChild(unit)
	self:Draw()
end

function ScrollViewEx:Draw()
	--初始化容器
    --self:initContainer()
	
	--计算单元在容器中的位置
	local index = 1
    for k,v in pairs(self.units) do
        v:setPosition(self:getPos(index))
        index = index + 1
    end
end

function ScrollViewEx:setVisible(isVisible)
	--滚动层
	self.container:setVisible(isVisible)
--[[
    --单元
    if (self.units and #self.units > 0) then
		for idx,unit in pairs(self.units) do
			unit:setVisible(isVisible)
		end
	end
	]]--
end

---------------------------
--@return #type description
--@para isPosive:是否正排序
function ScrollViewEx:Sort(isPosive)
	--排序的算法
	local function comp(a, b)
        if a~=nil and b~=nil then
    		if (isPosive == nil) or (isPosive == true) then
    			return a.op < b.op
    		else
    			return a.op > b.op
    		end
        end
	end

	--排序,units必须是从1开始连续的index,不然会出错
	table.sort(self.units, comp)
	
    self:Draw()
end

return ScrollViewEx
