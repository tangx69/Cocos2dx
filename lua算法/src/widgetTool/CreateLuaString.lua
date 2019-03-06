
local CreateLuaString = class("CreateLuaString",function()
    return cc.Scene:create()
end)


local luaHead = [[
---
-- ui配置表
-- @module UiConfig
local UiConfig = {}
UiConfig._data = {}
UiConfig.serverkey = {"ui","index"}

---
-- 获取数据
-- @function [parent=#UiConfig] getData
-- @param self
-- @param #string ui
-- @param #int index
-- @return #UiConfigStruct ret
function UiConfig:getData(ui, index)
if self._data[ui] then
return self._data[ui][index]
end
return nil
end

---
-- 获取数据表
-- @function [parent=#UiConfig] getTable
-- @param self
-- @return #table ret
function UiConfig:getTable()
return self._data
end

---
-- 获取数据表
-- @function [parent=#UiConfig] getTable1
-- @param self
-- @param #string ui
-- @return #table ret
function UiConfig:getTable1(ui)
return self._data[ui]
end


---
-- @module UiConfigStruct

---
-- @field [parent=#UiConfigStruct] #string ui

---
-- @field [parent=#UiConfigStruct] #int index

---
-- @field [parent=#UiConfigStruct] #string bind

---
-- @field [parent=#UiConfigStruct] #string bp1

---
-- @field [parent=#UiConfigStruct] #string bp2

---
-- @field [parent=#UiConfigStruct] #string bp3

---
-- @field [parent=#UiConfigStruct] #string bp4

---
-- @field [parent=#UiConfigStruct] #string bp5

---
-- @field [parent=#UiConfigStruct] #string bp6

---
-- @field [parent=#UiConfigStruct] #string bp7

---
-- @field [parent=#UiConfigStruct] #string bp8

---
-- @field [parent=#UiConfigStruct] #string bp9

---
-- @field [parent=#UiConfigStruct] #string bp10

local entry

]]

local luaTail = [[


UiConfig.md5="d51daddcf1c35acb1e4eedc2b27e5198"

return UiConfig
]]

local luaBody = {}


----
local createLuaStrUnit = nil


function CreateLuaString.create()
    local scene = CreateLuaString.new()
    
    return scene
end

function CreateLuaString:ctor()
    self.schedulerID = nil
end

---
-- 根据UiConfig的table表，生成字符串
function CreateLuaString:getLuaString(luaTable)
    local retTable = {}
    local retCount = 1
    local ret = ""
    for key, var in pairs(luaTable) do
        --print("getLuaString", key, var)
        for _key, _var in pairs(var) do
            --print(_key, _var)
            if type(_var) == "table" then
                ret = ret.. createLuaStrUnit(_var)
                if retCount % 20 == 0 then
                    --print("********************************", retCount % 20)
                    table.insert(retTable,ret)
                    ret = ""
                end
                retCount = retCount + 1
            end
        end
    end
    return ret, retTable, luaHead, luaTail
    --return luaHead.. ret.. luaTail
end

---
-- 解析一个组件对应的字符串
createLuaStrUnit = function (data)
    local tempData = data or {}
    local pros = {ui="",index=1,bind="",bp1="",bp2="",bp3="",bp4="",bp5="",bp6="",bp7="",bp8="",bp9="",bp10=""}
    for key,var in pairs(pros) do
        tempData[key] = data[key] or var
    end
    return 
        'entry={ui="'.. tempData.ui .. '",index='..
        tempData.index .. ',bind="'.. tempData.bind .. '",bp1="'.. 
        tempData.bp1 .. '",bp2="'.. tempData.bp2.. '",bp3="'.. tempData.bp3 .. '",bp4="'.. 
        tempData.bp4 .. '",bp5="'.. tempData.bp5 .. '",bp6="'.. tempData.bp6 .. '",bp7="'.. 
        tempData.bp7 .. '",bp8="'.. tempData.bp8 .. '",bp9="'.. tempData.bp9 .. '",bp10="'.. tempData.bp10 ..
        [["}
UiConfig._data[entry.ui]=UiConfig._data[entry.ui] or {}
UiConfig._data[entry.ui][entry.index] = entry
]]

end


return CreateLuaString