--uiconfig的策划目录
UIConfigLuaPath = nil

local GameScene = class("GameScene",function()
    return cc.Scene:create()
end)

function GameScene.create()
    local scene = GameScene.new()
    scene:addChild(scene:loadView())
    return scene
end


function GameScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil
end

function GameScene:loadView()

    function splitString(str, patten)
        local strArr = {}
        while true do
            local index = string.find(str,patten)
            if index then
                table.insert(strArr,string.sub(str,1,index - 1))
                str = string.sub(str,index+1)
            else
                table.insert(strArr,str)               
                break
            end
        end
        return strArr
    end
    
    local pathsss = cc.FileUtils:getInstance():getSearchPaths()
    local designPath = "" 
    for key, var in pairs(pathsss) do
        local _designPath = var
        local index = string.find(_designPath,"game/runtime")
        if index then
            local parentPath = string.sub(_designPath,0,index - 2)
            local parentArr = splitString(parentPath, "/")
            for _var=1, #parentArr - 1 do
                designPath = designPath.. parentArr[_var].. "/"
            end
            break
        end
    end
    UIConfigLuaPath = designPath 

    local allpath = zzy.cUtils.getDirFiles(designPath.. "design\\A-resource\\uiProject\\cocosstudio");
    local paths_temp = splitString(allpath, ",")
    local paths = {}
    for _, var in ipairs(paths_temp) do
        if string.find(var,".csd") then
            local news = string.sub(var,1,string.len(var) - 4)
            table.insert(paths, string.sub(var,1,string.len(var) - 4))
        end
    end
    
    
    local layerFarm = cc.Layer:create()
    local node = cc.CSLoader:createNode("res/ui/widgetTool/wt_main.csb")
    node:setScale(2,2)
    layerFarm:addChild(node)
    local btn = node:getChildByName("Button_1")
    
    local selectText = node:getChildByName("Text_1")
    selectText:setString("")
    
    local list = node:getChildByName("ListView_1")
    
  
    for _, csdItem in ipairs(paths) do
        local label = ccui.Text:create()
        csdItem = string.gsub(csdItem,"\\","/")
        label:setString(csdItem)
        label:setTouchEnabled(true)
        list:pushBackCustomItem(label)
    end
    
    list:addEventListener(function(sender, eventType)
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            local sceneName = list:getItem(list:getCurSelectedIndex()):getString()
            if sceneName and string.len(sceneName) > 0 then
                selectText:setString(sceneName)
                btn:setBright(true)
                btn:setTouchEnabled(true)            
            end
        end
    end)
    
    
    btn:setBright(false)
    btn:setTouchEnabled(false)
    btn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local selectString = selectText:getString()
            if self.callBackFun then
                self.callBackFun(selectString)
            end
        end
    end)
    
    return layerFarm
end

function GameScene:setCallBackFun(fun)
    self.callBackFun = fun
end

return GameScene