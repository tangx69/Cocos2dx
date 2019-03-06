---
-- table工具
-- @module TableUtils
local TableUtils = {}

---
-- 遍历
-- @function [parent=#TableUtils] traversal
-- @param self
-- @param #table t
-- @param #int dep
-- @param #function func
function TableUtils:traversal(t, dep, func)
    if type(t) ~= "table" then
        return
    end
    dep = dep - 1
    for key, var in pairs(t) do
        if dep <= 0 then
            func(key, var)
        else
            TableUtils:traversal(var, dep, function(...)
                func(key, ...)
            end)
        end
    end
end

-- 反向索引使用的metatable
local reverseIndexMT = {
    __index = function(t, k)
        return t.__data[k]
    end,
    __newindex = function(t, k, v)
        t.getReverseIndex[t.__data[k]] = nil
        if v ~= nil then
            t.getReverseIndex[v] = k
        end
        t.__data[k] = v
    end
}

---
-- 反向索引
-- @function [parent=#TableUtils] makeReverseIndex
-- @param #TableUtils self
-- @param #table o
-- @return #table ret
function TableUtils:makeReverseIndex(o)
    local reverse = {}
    local proxy = {
        __data = o,
        getReverseIndex = function() return reverse end
    }
    setmetatable(proxy, reverseIndexMT)
    for key, var in pairs(o) do
    	reverse[var] = key
    end
    return proxy
end

---
-- 复制table，并对新table的key做排序
-- @function [parent=#TableUtils] sortTableKeys
-- @param #TableUtils self
-- @param #table o
-- @return #table ret
function TableUtils:sortTableKeys(o)
    local newo = {}
    
    local keys = {}
    for k,v in pairs(o) do
        table.insert(keys, k)
    end
    table.sort(keys)
    
    local i = 0
    for k,v in function()
        i = i + 1
        return keys[i], o[keys[i]]
    end do
        if type(v) == "table" then
            newo[k] = TableUtils:sortTableKeys(v)
        else
            newo[k] = v
        end
    end
    
    return newo
end

---
-- 对table的key做排序,返回key值的table
-- @function [parent=#TableUtils] sortTableByKey
-- @param #TableUtils self
-- @param #table o
-- @return #table ret
function TableUtils:sortTableByKey(o)
   local key_table = {}  
	--取出所有的键  
	for key,_ in pairs(o) do  
		table.insert(key_table,key)  
	end  
	--对所有键进行排序  
	table.sort(key_table)  
	return key_table
end


function TableUtils:copy(obj)
    local ret = {}
    for k, v in pairs(obj) do
        if type(v) == "table" then
            ret[k] = TableUtils:copy(v)
        else
            ret[k] = v
        end
    end
    return ret
end


function TableUtils:clean(obj)
    for k, v in pairs(obj) do
        obj[k] = nil
    end
end

---
-- @function [parent=#TableUtils] plusTable
-- @param self
-- @param #table source
-- @param #table add
-- @return #table ret
function TableUtils:plusTable(source, add)
    for key, var in pairs(add) do
        local addv = tonumber(var, 10)
        if addv or addv ~= 0 then
            local sourcev = tonumber(source[key], 10)
            if sourcev then
                source[key] = sourcev + addv
            else
                source[key] = addv
            end
        end
    end
end

---
-- @function [parent=#TableUtils] ratioTable
-- @param self
-- @param #table source
-- @param #table ratio
-- @return #table ret
function TableUtils:ratioTable(source, ratio)
    local ret = {}
    for key, var in pairs(source) do
        local nv = tonumber(var, 10)
        if nv and nv ~= 0 then
            ret[key] = math.floor(nv * ratio)
        end
    end
    return ret
end


---
-- @function [parent=#TableUtils] compareTable
-- @param self
-- @param #table a
-- @param #table b
-- @param #string dep
-- @param #string retStr
-- @return #bool ret
function TableUtils:compareTable(a, b, dep, retStr)
    dep = dep or ""
    retStr = retStr or ""
    local ret = true
    for k, v in pairs(a) do
        if not b[k] then
            ret = false
            cclog("table B do not has key : %s, A[%s] = %s", dep..":"..k, dep..":"..k, tostring(v))
            retStr = retStr .. "\n" .. string.format("table B do not has key : %s@ A[%s] # %s", dep..":"..k, dep..":"..k, tostring(v))
        elseif type(v) == "table" then
            if type(b[k]) == "table" then
                local t1,t2 = TableUtils:compareTable(v, b[k], dep..":"..k, retStr)
                ret = t1 and ret
                retStr = retStr .. t2
            else
                ret = false
                cclog("table has different value type, key = %s, A : %s, B : %s", dep..":"..k, tostring(v), tostring(b[k]))
                retStr = retStr .. "\n" .. string.format("table has different value type@ key # %s@ A : %s@ B : %s", dep..":"..k, tostring(v), tostring(b[k]))
            end
        elseif v ~= b[k] then
            ret = false
            cclog("table has different value, key = %s, A : %s, B : %s", dep..":"..k, tostring(v), tostring(b[k]))
            retStr = retStr .. "\n" .. string.format("table has different value@ key # %s@ A : %s@ B : %s", dep..":"..k, tostring(v), tostring(b[k]))
        end
    end
    for k, v in pairs(b) do
        if not a[k] then
            ret = false
            cclog("table A do not has key : %s, B[%s] = %s", dep..":"..k, dep..":"..k, tostring(v))
            retStr = retStr .. "\n" .. string.format("table A do not has key : %s@ B[%s] # %s", dep..":"..k, dep..":"..k, tostring(v))
        end
    end
    
    return ret,retStr
end


return TableUtils
