local ToolWidgetScene = class("ToolWidgetScene",function()
    return cc.Scene:create()
end)

function ToolWidgetScene.create()
    local scene = ToolWidgetScene.new()
    scene:loadBackGround("wt_tool")
    return scene
end

local rootWidget = ccui.Widget:create()
local selectedData = {}
local loadedWidget = ccui.Widget:create()
local nodeSelectedPathText = ccui.TextField:create()
local nodeSelectedParentText = ccui.TextField:create()
local dataList = ccui.ListView:create()


local fillDataList = nil

--ui key
local csbKey = nil
--ui table
local csbNodeTable = nil
--ui node
local csbNodeSelected = nil
--uiconfig
local uiConfigLuaTable = nil
--Layer容器
local layerContainer = nil
 

local addProBtn = ccui.Button:create()
local proList = ccui.ListView:create()


local saveDataTable = {
    csbKey = "",        -- csb文件名
    nodeList = {}       -- 节点列表
}

--function
local tranverChildren = nil
local checkIsUniqueKey = nil
local addProUnit = nil
local saveData = nil --保存数据到lua
local checkTouchHandler = nil --检测可用的触摸方法


local childrenTable = {}

local paramDataList1 = {
    "Data",
    "Touch"
}
local paramDataList2 = {
    Data={"Visible","Opacity","TouchEnable","Image","Text","FontColor","Select","Progress","Items","Direction","Csb"}
}

function ToolWidgetScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil
end

local function getRoot(node, path)
    if node then
        local parent = node:getParent()
        if parent then
            if parent == loadedWidget then
                return path        
            else
                path = parent:getName().. "/".. path 
                return getRoot(parent, path)        
            end
        else
           return path 
        end        
    else
        return path
    end    
end

local function hightLightSelected(node)
    proList:removeAllItems()
    local oldNode = selectedData.node
    if oldNode then
        oldNode:stopAllActions()
        oldNode:setPosition(selectedData.x, selectedData.y)
    end 
    selectedData.node = node
    if node then
        selectedData.x = node:getPositionX()
        selectedData.y = node:getPositionY()
        node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.5,cc.vertex2F(selectedData.x,selectedData.y+10)),cc.MoveTo:create(0.5,cc.vertex2F(selectedData.x,selectedData.y-10)))))
        nodeSelectedPathText:setString(node:getName().. " (类型：".. node:getDescription().. ")")
        
        local nodeName = node:getName()
        local nodeKey = nodeName
        while checkIsUniqueKey(nodeName) > 1 do
            node = node:getParent()
            if node ~= loadedWidget then
                nodeName = node:getName()
                nodeKey = nodeKey.. ":".. nodeName            
            else
                break
            end
        end
        csbNodeSelected = nodeKey
        nodeSelectedPathText:setString(nodeKey.. " (类型：".. node:getDescription().. ")")
        nodeSelectedParentText:setString(getRoot(node,""))
        addProBtn:setBright(true)
        addProBtn:setTouchEnabled(true)
        
        local _proDatas = saveDataTable.nodeList
        if _proDatas and #_proDatas then
            for i=1,#_proDatas do
                local _unit = _proDatas[i]
                if _unit.bp1 and _unit.bp1 == nodeKey then
                    addProUnit(_unit)
                end
            end
        end
    else
        csbNodeSelected = nil
        nodeSelectedPathText:setString("当前未选中")
        nodeSelectedParentText:setString("")
        addProBtn:setBright(false)
        addProBtn:setTouchEnabled(false)
    end
end

local function transNode(cmd)
    local node = selectedData.node
    if not node then
        return
    end
    local parent = node:getParent()
    local children = nil
    local newNode = nil
    if cmd == "Button_left" then
        if parent then
            children = parent:getChildren()
        end
        if children and #children then
            for key, var in pairs(children) do
                if var == node then
                    break
                end
                newNode = var
            end
        end
    elseif cmd == "Button_right" then
        if parent then
            children = parent:getChildren()
        end
        local find = nil
        if children and #children then
            for key, var in pairs(children) do
                if find then
                    newNode = var
                    break
                end
                if var == node then
                    find = true
                end
            end
        end
    elseif cmd == "Button_up" then
        if parent then
            newNode = parent
        end
    elseif cmd == "Button_down" then
        children = node:getChildren()
        if children and #children then
            for key, var in pairs(children) do
                newNode = var
                break
            end
        end
    end
    hightLightSelected(newNode)
end

---
-- 填充属性数据
local function fillProUnitData(unit, index, value)
    local _input = unit:getChildByName("TextField_".. index)
    _input:setString(value or "")
end

---
-- 添加新属性
addProUnit = function (unitData)
    csbNodeTable[csbNodeSelected] = csbNodeTable[csbNodeSelected] or {}
    
    local _unit = cc.CSLoader:createNode("res/ui/widgetTool/proLayer.csb")
    proList:pushBackCustomItem(_unit)
    fillProUnitData(_unit, 1, unitData and unitData.bind or "")
    fillProUnitData(_unit, 2, unitData and unitData.bp2 or "")
    fillProUnitData(_unit, 3, unitData and unitData.bp3 or "")
    fillProUnitData(_unit, 4, unitData and unitData.bp4 or "")
    fillProUnitData(_unit, 5, unitData and unitData.bp5 or "")
    
    local unitTable = unitData
    if not unitData then
        unitTable = {bp1=csbNodeSelected}
        table.insert(saveDataTable.nodeList, unitTable)
    end
    
    local function dataTouch(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local clickUnit = nil
            local clickIndex = nil
            for i=1,5 do
                if sender == _unit:getChildByName("TextField_".. i) then
                    clickUnit = sender
                    clickIndex = i
                    break
                end
            end
            if clickUnit then
                if clickIndex == 1 then
                    fillDataList(clickUnit, paramDataList1)
                elseif clickIndex == 2 then
                    -- 根据上个内容，判断当前的关联数据
                    local _parentShow = _unit:getChildByName("TextField_1"):getString()
                    local _curShow = paramDataList2[_parentShow]
                    if _curShow then
                        fillDataList(clickUnit, _curShow)                    
                    else
                        if _parentShow == "Touch" then
                            
                            local existTable, newFun = checkTouchHandler(csbNodeSelected)
                            table.insert(existTable, newFun)
                            fillDataList(clickUnit, existTable)
                            
                        end
                    end
                end
            end
        end
    end
    
    local function textChange(editbox, eventType)
        -- ccui.TextFiledEventType.detach_with_ime 输入结束
        -- ccui.TextFiledEventType.insert_text 插入文字
        -- ccui.TextFiledEventType.delete_backward 删除文字
        if eventType == ccui.TextFiledEventType.attach_with_ime then
            -- 开始输入
            print("开始输入")
        elseif eventType == ccui.TextFiledEventType.detach_with_ime or eventType == ccui.TextFiledEventType.insert_text or eventType == ccui.TextFiledEventType.delete_backward then
            -- 输入结束
            local textname = editbox:getName()
            local textindex = tonumber(string.sub(textname,string.len(textname),string.len(textname))) or 0
            if textindex == 1 then
                unitTable.bind = editbox:getString()
            elseif textindex > 1 then
                unitTable["bp".. textindex] = editbox:getString()
                print(textindex, unitTable["bp".. textindex])
            end
            print("输入结束", editbox:getString())
        end        
    end
    
    for index=1,5 do
        local _input = _unit:getChildByName("TextField_".. index)
        _input:addTouchEventListener(dataTouch)
        _input:addEventListener(textChange)
    end
    
    
    
    local function closeTouch(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            for key,var in pairs(unitData) do
                unitData[key] = nil            
            end
            
            hightLightSelected(selectedData.node)                
        end
    end
    local _close = _unit:getChildByName("Button_cancel")
    _close:addTouchEventListener(closeTouch)
    
end

---
-- 判断当前的触摸事件
checkTouchHandler = function(itemKey)
    itemKey = string.gsub(itemKey,":","_")

    local oneCsdTable = uiConfigLuaTable._data[saveDataTable.csbKey]
    
    local _existTouchTable = {}
    if oneCsdTable then
        for _, var in ipairs(oneCsdTable) do
            if type(var) == "table" and var["bind"] == "Touch" then
                table.insert(_existTouchTable, var["bp1"])
            end
        end
    end
    
    local index = 1
    local _touchHandler = itemKey.. "_touch".. index
    while true do
        _touchHandler = itemKey.. "_touch".. index
        local _singlFlag = true
        for _, var in ipairs(_existTouchTable) do
            if string.find(var,_touchHandler) then
                index = index + 1
                _singlFlag = nil
                break
            end
        end
        if _singlFlag then
            break
        end
    end
    
    return _existTouchTable, _touchHandler.. "()" 
end

---
-- 填充Input列表数据
fillDataList = function(target, data)
    dataList:removeAllItems()
    dataList:setVisible(true)
    local wp = target:convertToWorldSpace(cc.p(0,0))
    local lp = rootWidget:convertToNodeSpace(wp)
    
    dataList:setPosition(cc.vertex2F(lp.x, lp.y + 25))
    for i=1,#data do
        local label = ccui.Text:create()
        label:setFontSize(30)
        label:setString(data[i])
        label:setTouchEnabled(true)
        dataList:pushBackCustomItem(label)
            
        dataList:addEventListener(function(sender, eventType)
            if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
                local dataName = dataList:getItem(dataList:getCurSelectedIndex()):getString()
                if dataName and string.len(dataName) > 0 then
                    target:setString(dataName)
--                    csbNodeTable[csbKey][csbNodeSelected] = csbNodeTable[csbKey][csbNodeSelected] or {}
--                    csbNodeTable[csbKey][csbNodeSelected]["bind"] = dataName
                    dataList:setVisible(false)
                end
            end
        end)
    end
end

---
-- 保存数据到Lua
saveData = function ()
    local nodelist = saveDataTable.nodeList
    for key, var in pairs(nodelist) do
        nodelist.ui = saveDataTable.csbKey
    end
    if not uiConfigLuaTable then
        uiConfigLuaTable = require("res.config.UiConfig")
    end
    uiConfigLuaTable._data[saveDataTable.csbKey] = zzy.TableUtils:copy(nodelist)
    local luatool = require("src.widgetTool.CreateLuaString").create()
    local _luaTableToString, _luaStringTable, _luaStringHead, _luaStringTail = luatool:getLuaString(uiConfigLuaTable._data)

    local ret = ""
    if _luaStringTable then
        ret = ret.. _luaStringHead
        for key, var in ipairs(_luaStringTable) do
        	--print(key, var)
        	ret = ret.. var
        end
        ret = ret.. _luaStringTail
    else
        ret = _luaTableToString
    end
    
--    print(_luaTableToString)
--    zzy.cUtils.writeFileWithString(ret,"D:/ClickHero/design/A-resource/res/widgetToolConfig1.txt")
    --zzy.cUtils.writeFileWithString(ret,"res/widgetToolConfig1.txt")
    --uiconfig的策划目录
    zzy.cUtils.writeFileWithString(ret, UIConfigLuaPath.. "\\design\\A-resource\\res\\config\\UiConfig2.lua")
    --local config = cc.FileUtils:getInstance():getStringFromFile("D:/ClickHero/design/A-resource/res/widgetToolConfig.txt")
end

function ToolWidgetScene:loadBackGround(csbName)
    local layerFarm = cc.Layer:create()
    local node = cc.CSLoader:createNode("res/ui/widgetTool/".. csbName.. ".csb")
    rootWidget = node
    layerFarm:addChild(node)
    
    node:setPosition(node:getContentSize().width,0)
    self:addChild(layerFarm)
    
    dataList = node:getChildByName("ListView_1")
    dataList:setVisible(false)
    proList = node:getChildByName("ListView_2")
    
    local bg = node:getChildByName("Image_1")
    local btn = node:getChildByName("Button_2")
    local btn1 = node:getChildByName("Button_left")
    local btn2 = node:getChildByName("Button_right")
    local btn3 = node:getChildByName("Button_up")
    local btn4 = node:getChildByName("Button_down")
    addProBtn = node:getChildByName("Button_add")
    local saveBtn = node:getChildByName("Button_save")
    local function btnTouch(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn then
                if self.callBackFun then
                    layerContainer:removeAllChildren()
                    if selectedData then
                        selectedData.node = nil                    
                    end
                    self.callBackFun()
                end
            elseif sender == btn1 or sender == btn2 or sender == btn3 or sender == btn4 then
                transNode(sender:getName())
            elseif sender == addProBtn then
                addProUnit()
            elseif sender == saveBtn then
                saveData()
            end
        end    	
    end
    btn:addTouchEventListener(btnTouch)
    btn1:addTouchEventListener(btnTouch)
    btn2:addTouchEventListener(btnTouch)
    btn3:addTouchEventListener(btnTouch)
    btn4:addTouchEventListener(btnTouch)
    addProBtn:addTouchEventListener(btnTouch)
    saveBtn:addTouchEventListener(btnTouch)

    bg:addTouchEventListener(function()
        dataList:setVisible(false)        
    end)
    
    nodeSelectedPathText = node:getChildByName("Text_2")
    nodeSelectedPathText:setString("当前未选择控件")
    nodeSelectedParentText = node:getChildByName("Text_1")
    nodeSelectedParentText:setString("")
    
    return layerFarm
end

function ToolWidgetScene:setCallBackFun(fun)
    self.callBackFun = fun
end

local TypeTable = {
    "TextField",
    "EditBox",
    "Button",
    "ImageView",
    "Layout",
    "CheckBox"
}

---
-- @function [parent=#ToolWidgetScene] tranverChildren
-- 递归遍历节点的子对象
-- @param node #Node 需遍历节点
tranverChildren = function(node, path)
    local children = node:getChildren()
    if children and #children > 0 then
        for key, var in pairs(children) do
            local desName = var:getDescription()
            if var.addTouchEventListener then
                var:setTouchEnabled(true)
                var:addTouchEventListener(function(sender, eventType)
                    if eventType == ccui.TouchEventType.ended then
                          hightLightSelected(sender)
                    end
                end)
            end
            local _fullPath = nil
            if string.len(path) > 0 then
                _fullPath = path.. ":".. var:getName()
            else
                _fullPath = var:getName()
            end
            table.insert(childrenTable, _fullPath)
            tranverChildren(var, _fullPath)
        end
    end
end

---
-- @function [parent=#ToolWidgetScene] checkIsUniqueKey
-- 判断当前名字是否位移，如果不唯一返回建议Key
-- @param checkKey #string 需遍历节点key
checkIsUniqueKey = function(checkKey)
    local count = 0
    for i=1,#childrenTable do
        local _name = childrenTable[i]
        if _name == checkKey then
            count = count + 1
        else
            local tailName = string.sub(_name,string.len(_name) - string.len(checkKey), string.len(_name))
            if tailName == (":".. checkKey) then
                count = count + 1
            end
        end
    end
    return count
end

function ToolWidgetScene:loadView(csbName)

    csbKey = csbName
    csbNodeTable = {}
    
    saveDataTable = {}
    saveDataTable.csbKey = csbName
    saveDataTable.nodeList = {}
    
    print("***loadView***")

    if not uiConfigLuaTable then
        print("uiConfigLuaTable is null")
        uiConfigLuaTable = require("res.config.UiConfig")
    end
    local index = 1
    while true do
        local _line = uiConfigLuaTable:getData(csbName, index)
        if _line then
            table.insert(saveDataTable.nodeList, zzy.TableUtils:copy(_line))
            if checkIsUniqueKey(_line.bp1) > 1 then
                print(csbName.. " ".. index.. "行的".. _line.bp1.. "不唯一")
            end
        else        
            break
        end
        index = index + 1
    end
    
    

    layerContainer = cc.Layer:create()
    local node = cc.CSLoader:createNode("res/ui/".. csbName.. ".csb", "res/ui/")
    loadedWidget = node
    layerContainer:addChild(node)
    self:addChild(layerContainer)
    
    -- 遍历所有子节点
    childrenTable = {}
    tranverChildren(node, "")
    
    addProBtn:setBright(false)
    addProBtn:setTouchEnabled(false)
    proList:removeAllItems()
    
    
    return layerContainer
end

return ToolWidgetScene