---
--@module PermissionUtils
local PermissionUtils = {}

local readOnlyNewIndexFun = function (t,k,v)
    error("attempt to update a read-only table",2)
end

---
-- 拷贝对象并设置为只读
-- @function [parent=#PermissionUtils] makeTableReadOnly
-- @param self
-- @param #table o
-- @return #table ret
function PermissionUtils:makeTableReadOnly(o)
    local proxy = {}
    local mt = {
        __index = o,
        __newindex = readOnlyNewIndexFun
    }
    setmetatable(proxy,mt)
    for key,var in pairs(o) do
        if type(var) == "table" then
           var = PermissionUtils:makeTableReadOnly(var)
           rawset(o,key,var)
        end
    end
    return proxy
end

return PermissionUtils
