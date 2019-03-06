require "src.cocos.init"

-- cclog
local cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    -- initialize director
    local director = cc.Director:getInstance()

    --turn on display FPS
    director:setDisplayStats(true)

    --set FPS. the default value is 1.0/60 if you don't call this
    director:setAnimationInterval(1.0 / 30)

    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(640, 1136, cc.ResolutionPolicy.FIXED_WIDTH)

    --create scene 
    local gameScene = cc.Scene:create()

    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(gameScene)
    else
        cc.Director:getInstance():runWithScene(gameScene)
    end
    
    local ds = 200
    local pxpt = 6
    local minSwapDis = 100
    local circleSize = 32
    local rightSize = 40
    
    local swapDif = {
        {-math.pi/8, math.pi/8},
        {-math.pi/8*5, -math.pi/8},
        {math.pi/8, math.pi/8*5},
    }
    
    local itemLayer = cc.Layer:create()
    itemLayer:setPosition(320, 800)
    gameScene:addChild(itemLayer)
    
    local drawNode = cc.DrawNode:create()
    drawNode:drawSegment(cc.p(rightSize,-circleSize),cc.p(rightSize,circleSize),1,cc.c4b(1,1,1,1))
    drawNode:drawSegment(cc.p(-rightSize,circleSize),cc.p(-rightSize,-circleSize),1,cc.c4b(1,1,1,1))
    itemLayer:addChild(drawNode)
    
    local perfertCount = 0
    local showScore = function(str)
        if "perfert" == str then
            perfertCount = perfertCount + 1
            if perfertCount > 1 then
                str = string.format("perfert x %d", perfertCount)
            end
        else
            perfertCount = 0
        end
    
        local text = ccui.Text:create()
        text:setString(str)
        text:setFontSize(50)
        text:setPosition(30, 50)
        itemLayer:addChild(text)
        
        text:runAction(cc.Sequence:create(
            cc.MoveBy:create(1, cc.vertex2F(0,200)),
            cc.CallFunc:create(function()
                itemLayer:removeChild(text, true)
            end)
        ))
    end
    
    local itemOffsetX = 320
    local items = {}
    
    local createItem = function(index)
        local dn = cc.DrawNode:create()
        dn:drawDot(cc.p(0,0), circleSize, cc.c4b(1,1,1,1))
        local rand = math.random(1,4)
        if rand == 1 then
            dn:drawSegment(cc.p(0,-circleSize),cc.p(0,circleSize),2,cc.c4b(0,0,0,1))
        elseif rand == 2 then
            dn:drawSegment(cc.p(-circleSize/1.4,circleSize/1.4),cc.p(circleSize/1.4,-circleSize/1.4),2,cc.c4b(0,0,0,1))
        elseif rand == 3 then
            dn:drawSegment(cc.p(circleSize/1.4,circleSize/1.4),cc.p(-circleSize/1.4,-circleSize/1.4),2,cc.c4b(0,0,0,1))
        else
            dn:drawSegment(cc.p(-circleSize,0),cc.p(circleSize,0),2,cc.c4b(0,0,0,1))
        end
        dn:setPositionX(ds * index + itemOffsetX)
        dn.v = rand
        itemLayer:addChild(dn)
        items[index] = dn
    end
    
    local updateItems = function()
        itemOffsetX = itemOffsetX - pxpt
        
        local minDnIndex = -(itemOffsetX + 320) / ds
        for index,dn in pairs(items) do
            if index < minDnIndex then
                itemLayer:removeChild(dn, true)
                items[index] = nil
            else
                dn:setPositionX(ds * index + itemOffsetX)
                
                if dn.v and dn:getPositionX() < -rightSize - circleSize then
                    dn.v = nil
                    showScore("miss")
                end
            end
        end
        
        local bigDnIndex = math.floor((400 - itemOffsetX) / ds)
        while bigDnIndex > 0 and not items[bigDnIndex] do
            createItem(bigDnIndex)
            bigDnIndex = bigDnIndex - 1
        end
    end
    
    
    cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateItems, 0, false)
    
    local touchPannel = ccui.Layout:create()
    touchPannel:setContentSize(cc.size(600,600))
    touchPannel:setTouchEnabled(false)
    touchPannel:setBackGroundColorType(1)
    touchPannel:setBackGroundColor(cc.c3b(255,255,0))
    touchPannel:setBackGroundColorOpacity(100)
    touchPannel:setPosition(20,100)
    local touchLayer = cc.Layer:create()
    gameScene:addChild(touchLayer)
    touchLayer:addChild(touchPannel)
    
    
    local pointsNode = nil
    local prePoint = nil
    local gesture = require("src/test/Gesture.lua"):new()
    
    local onTouchBegin = function(touch,event)
        gesture:init()
        prePoint = nil
        if pointsNode then
            touchPannel:removeChild(pointsNode)
        end
        pointsNode = cc.DrawNode:create()
        touchPannel:addChild(pointsNode)
        local point = touch:getLocation()
        point.x = point.x - 20
        point.y = point.y - 100
        if point.x < 0 or point.x > 600 or point.y < 0 or point.y > 600 then
            return
        end
        prePoint = point
        gesture:addPoint(point)
    end
    
    local onTouchMove = function(touch,event)
        local point = touch:getLocation()
        point.x = point.x - 20
        point.y = point.y - 100
        if point.x < 0 or point.x > 600 or point.y < 0 or point.y > 600 then
            return
        end
        if prePoint then
            pointsNode:drawSegment(prePoint,point,2,cc.c4b(1,0,0,1))        
        end
        prePoint = point
        gesture:addPoint(point)
    end
    
    local onTouchEnded = function(touch,event)
        local point = touch:getLocation()
        point.x = point.x - 20
        point.y = point.y - 100
        if point.x >= 0 and point.x <= 600 and point.y >= 0 and point.y <= 600 then
            if prePoint then
                pointsNode:drawSegment(prePoint,point,2,cc.c4b(1,0,0,1))
            end
            gesture:addPoint(point)
        end
       local points,type = gesture:calculate()
       local prePoint = nil
       if points then
           for k,v in pairs(points) do
               if prePoint then
                   pointsNode:drawSegment(prePoint,v,2,cc.c4b(0,1,0,1)) 
               else
                   prePoint = v
               end
           end
       end
       
       local swapv = 0
       if type then
           if type == 3 or type == 4 then
               swapv = 4
           elseif type == 6 or type == 7 then
               swapv = 2
           elseif type == 5 or type == 8 then
               swapv = 3
           elseif type == 1 or type == 2 then
               swapv = 1
           end
       end
       
        local scoreValue = -itemOffsetX / ds
        local contextIndex = math.floor(scoreValue + 0.5)
        if not items[contextIndex] then
            showScore("miss")
        else
            local diff = math.abs(scoreValue - contextIndex) * ds
            if diff > rightSize + circleSize then
                showScore("miss")
            else
                if items[contextIndex].v ~= swapv then
                    showScore("miss")
                elseif diff <= rightSize - circleSize then
                    showScore("perfert")
                elseif diff <= rightSize then
                    showScore("good")
                elseif diff <= rightSize + circleSize then
                    showScore("cool")
                end
                itemLayer:removeChild(items[contextIndex], true)
                items[contextIndex] = nil
            end
        end
    end
    
    
    
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(touch,event)
        onTouchBegin(touch,event)
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch,event)
        onTouchMove(touch,event)
    end,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function(touch,event)
        onTouchEnded(touch,event)
    end,cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = touchPannel:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, touchPannel)  
    
    
    
--    touchPannel:addTouchEventListener(function(obj, evt)
--        if evt == ccui.TouchEventType.ended then
--            local tbp = touchPannel:getTouchBeganPosition()
--            local tep = touchPannel:getTouchEndPosition()
--            
--            if math.abs(tbp.x - tep.x) + math.abs(tbp.y - tep.y) < minSwapDis then return end
--            
--            local radvalue = tbp.y>tep.y and math.atan2(tbp.y-tep.y, tbp.x-tep.x) or math.atan2(tep.y-tbp.y, tep.x-tbp.x)
--            local ratio = radvalue / math.pi
--            local swapv
--            if ratio < 1/8 then
--                swapv = 4
--            elseif ratio < 3/8 then
--                swapv = 3
--            elseif ratio < 5/8 then
--                swapv = 1
--            elseif ratio < 7/8 then
--                swapv = 2
--            else
--                swapv = 4
--            end
--            
--            local scoreValue = -itemOffsetX / ds
--            local contextIndex = math.floor(scoreValue + 0.5)
--            if not items[contextIndex] then
--                showScore("miss")
--            else
--                local diff = math.abs(scoreValue - contextIndex) * ds
--                if diff > rightSize + circleSize then
--                    showScore("miss")
--                else
--                    if items[contextIndex].v ~= swapv then
--                        showScore("miss")
--                    elseif diff <= rightSize - circleSize then
--                        showScore("perfert")
--                    elseif diff <= rightSize then
--                        showScore("good")
--                    elseif diff <= rightSize + circleSize then
--                        showScore("cool")
--                    end
--                    
--                    itemLayer:removeChild(items[contextIndex], true)
--                    items[contextIndex] = nil
--                end
--            end
--        end
--    end)
end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
