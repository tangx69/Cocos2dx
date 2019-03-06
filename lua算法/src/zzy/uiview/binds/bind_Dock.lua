local convertPoint = function(node,type)
    local worldPoint = node:convertToWorldSpace(cc.p(0,0)) --该节点左下角的世界坐标
    local origin = cc.Director:getInstance():getVisibleOrigin()
    local winSize = cc.Director:getInstance():getWinSize()
    local nodeSize = node:getContentSize()
    local stepX = 0
    local stepY = 0
    if type == "1" then
        stepX = origin.x - worldPoint.x
        stepY = origin.y + winSize.height -worldPoint.y - nodeSize.height
    elseif type == "2" then
        stepX = 0
        stepY = origin.y + winSize.height -worldPoint.y - nodeSize.height
    elseif type == "3" then
        stepX = origin.x + winSize.width - worldPoint.x - nodeSize.width
        stepY = origin.y + winSize.height -worldPoint.y - nodeSize.height
    elseif type == "4" then
        stepX = origin.x - worldPoint.x
        stepY = 0
    elseif type == "5" then
        stepX = origin.x + winSize.width - worldPoint.x - nodeSize.width
        stepY = 0
    elseif type == "6" then
        stepX = origin.x - worldPoint.x
        stepY = origin.y - worldPoint.y
    elseif type == "7" then
        stepX = 0
        stepY = origin.y - worldPoint.y
    elseif type == "8" then
        stepX = origin.x + winSize.width - worldPoint.x - nodeSize.width
        stepY = origin.y - worldPoint.y
    else
        error("不存在该停靠方式："..type)    
    end
    return cc.p(node:getPositionX() + stepX,node:getPositionY() + stepY)
end

return function (widget, config)
    local node = widget:getChild(config.bp1)
    if not node or config.bp2 == "" then return end
    local point = convertPoint(node,config.bp2)
    node:setPositionX(point.x)
    node:setPositionY(point.y)
end