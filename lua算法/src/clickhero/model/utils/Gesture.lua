---
-- 手势识别
-- @module Gesture
local Gesture = {
    _points = nil,
    _filterConst = 15,  -- 用于过滤原始点，让每两次采样的点的间隔变大
    _angleConst = 6,    -- 每次以该值为步长，循环求得该直线的斜率，值越小精度越大
    _threshold = 200000,    -- 阀值 ，大于该值即判定为不是直线
    _directionConst = 15,    --用于判定上下左右的范围
    type = {
        click = 0,
        up = 1,
        down = 2,
        right = 3,
        left = 4,
        rightUp = 5,
        rightDown = 6,
        leftUp = 7,
        leftDown = 8
    }
}
Gesture.__index = Gesture

---
-- 构造函数
-- @function [parent=#Gesture] new
-- @param self #Gesture
-- @return #Gesture
function Gesture:new()
    local o = {}
    setmetatable(o,self)
    return o
end

---
-- 初始化
-- @function [parent=#Gesture] init
-- @param self #Gesture
function Gesture:init()
    self._points = {}
end

---
-- 添加点
-- @function [parent=#Gesture] addPoint
-- @param self #Gesture
-- @param point #Point_table
function Gesture:addPoint(point)
    table.insert(self._points,point)
end

---
-- 计算
-- @function [parent=#Gesture] calculate
-- @param self #Gesture
-- @return #table #type 
function Gesture:calculate()
    local points = self:_filterPoint()
    local maxNum = table.maxn(points)
    if maxNum < 3 then
        return nil,0
    end
    local centerPoint = self:_getCenterPoint(points)
    local angle,distance = self:_getRakeRatio(points,centerPoint)
    if distance < self._threshold then
        local firstPoint = self:_getCrossPoint(angle,centerPoint,points[1])
        local lastPoint = self:_getCrossPoint(angle,centerPoint,points[maxNum])
        local data = {firstPoint,lastPoint}
        local type = self:_getDirection(angle,firstPoint,lastPoint)
        return data, type
    else
        return nil
    end
end

---
-- 获得中心点
-- @function [parent=#Gesture] _getCenterPoint
-- @param self #Gesture
-- @param points #table
-- @return #table
function Gesture:_getCenterPoint(points)
    local center = {}
    local count, totalX,totalY = 0,0,0
    for k,v in pairs(points) do
        totalX = totalX + v.x
        totalY = totalY + v.y
        count = count + 1 
    end
    center.x = totalX/count
    center.y = totalY/count
    return center
end

---
-- 获得直线倾角
-- @function [parent=#Gesture] _getRakeRatio
-- @param self #Gesture
-- @param points #table
-- @param centerPoint #table
-- @return #number #number 直线倾角和所有点到该直线的距离
function Gesture:_getRakeRatio(points,centerPoint)
    local angle = 0
    local minAngle = nil
    local minDistance = nil
    local count = table.maxn(points)
    while angle < 180 do
        local distance = 0
        for k,v in pairs(points) do
            distance = distance + self:_getDistance(angle,centerPoint,v)
        end
        distance = distance / count
        if minDistance then
            if minDistance > distance then
                minDistance = distance
                minAngle = angle
            end
        else
            minDistance = distance
            minAngle = angle
        end 
        angle = angle + self._angleConst
    end
    return minAngle, minDistance
end

---
-- 获得点到直线的距离的平方
-- @function [parent=#Gesture] _getDistance
-- @param self #Gesture
-- @param angle #number 直线倾角
-- @param point #table 直线的一个点
-- @param point2 #table 点
-- @return #number
function Gesture:_getDistance(angle,point,point2)
    local cross = self:_getCrossPoint(angle,point,point2)
    if cross then
        return math.pow(point2.x - cross.x,2) + math.pow(point2.y - cross.y,2) 
    end
end



---
-- 获得点在直线上的映射点，（即过该点向直线做垂线，两线的交点）
-- @function [parent=#Gesture] _getCrossPoint
-- @param self #Gesture
-- @param angle #number 直线倾角
-- @param point #table 直线的一个点
-- @param point2 #table 点
-- @return #table
function Gesture:_getCrossPoint(angle,point,point2)
    if angle == 0 then
        return {x = point2.x,y = point.y}
    elseif angle == 90 then
        return {x = point.x ,y = point2.y}
    elseif angle > 0 and angle < 180 then
        local k1 = math.tan(angle/180*3.14)
        local k2 = -1/k1
        local x = (point2.y - point.y + k1*point.x - k2*point2.x)/(k1-k2)
        local y = (k1*point2.y - k2*point.y + k1*k2*(point.x - point2.x))/(k1-k2)
        return {x = x,y = y}
    end
end

---
-- 过滤太接近的坐标点
-- @function [parent=#Gesture] _filterPoint
-- @param self #Gesture
-- @return #table
function Gesture:_filterPoint()
    local newPoints = {}
    local prePoint = nil
    for k,v in pairs(self._points) do
        if prePoint == nil then
            prePoint = v
            table.insert(newPoints,v)
        elseif math.abs(v.x - prePoint.x) > self._filterConst or math.abs(v.y - prePoint.y) > self._filterConst then
            prePoint = v
            table.insert(newPoints,v)
        end
    end
    return newPoints
end

---
-- 获得点在直线上的映射点，（即过该点向直线做垂线，两线的交点）
-- @function [parent=#Gesture] _getDirection
-- @param self #Gesture
-- @param angle #number   直线倾角
-- @param beginPoint #table    直线的一个点
-- @param endPoint #table   点
-- @return #table
function Gesture:_getDirection(angle,beginPoint,endPoint)
    if (angle >= 0 and angle < self._directionConst) or (angle >= 180 - self._directionConst and angle < 180) then
        if beginPoint.x < endPoint.x then
            return self.type.right
        else
            return self.type.left
        end
    elseif angle >= self._directionConst and angle < 90 - self._directionConst then
        if beginPoint.y < endPoint.y then
            return self.type.rightUp
        else
            return self.type.leftDown
        end
    elseif angle >= 90 - self._directionConst  and angle < 90 + self._directionConst  then
        if beginPoint.y < endPoint.y then
            return self.type.up
        else
            return self.type.down
        end
    elseif angle >= 90 + self._directionConst and angle < 180 - self._directionConst then
        if beginPoint.y < endPoint.y then
            return self.type.leftUp
        else
            return self.type.rightDown
        end
    end
    return -1
end

return Gesture