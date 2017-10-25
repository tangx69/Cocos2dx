---
-- 字符串工具
-- @module StringUtils
local StringUtils = {}

---
-- 分割字符串
-- @function [parent=#StringUtils] split
-- @param self
-- @param #string s 要分割的字符串
-- @param #string p 用来分割的字符串
-- @return #table ret
function StringUtils:split(s, p)
    local rt= {}
    while true do
        local pos,endP = string.find(s, p)
        if not pos then
            rt[#rt + 1] = s
            break
        end
        local sub_str = string.sub(s, 1, pos - 1)
        rt[#rt + 1] = sub_str
        s = string.sub(s, endP + 1)
    end
--    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end


---
-- @function [parent=#StringUtils] urlencode
-- @param self
-- @param #string str
-- @return #string ret
function StringUtils:urlencode(str)
    if (str) then
        str = string.gsub (str, "\r", "")
        str = string.gsub (str, "\n", "")
        str = string.gsub(str, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
        str = string.gsub (str, " ", "%%20")
    end
    return str    
end

---
-- @function [parent=#StringUtils] urldecode
-- @param self
-- @param #string str
-- @return #string ret
function StringUtils:urldecode(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

---
-- @function [parent=#StringUtils] countTextHeight
-- @param self
-- @param #int fontSize
-- @param #int textWidth
-- @param #string stringValue
-- @return #number ret
function StringUtils:countTextHeight(fontSize, textWidth, stringValue)
    local line = 0
    for _,w in ipairs(StringUtils:split(stringValue, "\n")) do
        line = line + 1 + math.floor(string.len(w) / 3 * fontSize / textWidth)
    end
    return line * fontSize * 1.15
end

---
-- 字符串分割成table(格式"a=1,b=2,c=3")
-- @function [parent=#StringUtils] splitToTable
-- @param self
-- @param #string s
-- @return #talbe ret
function StringUtils:splitToTable(s)
	local arr = zzy.StringUtils:split(s,",")
	local ret = {}
	for key, var in ipairs(arr) do
	   local kv = zzy.StringUtils:split(var,"=")
	   if table.maxn(kv) > 1 then
           local pKey = tonumber(kv[1])
           if pKey == nil then pKey = kv[1] end
           local pValue = tonumber(kv[2])
            if pValue == nil or pValue > 1e307 or pValue < -1e307 then pValue = kv[2] end
    	   ret[pKey] = pValue
	   end
	end
	return ret
end

---
-- 把table转成字符串(格式"a=1,b=2,c=3")
-- @function [parent=#StringUtils] tableToString
-- @param self
-- @param #talbe t
-- @return #string ret
function StringUtils:tableToString(t)
    local ret = ""
    for key, var in pairs(t) do
        if string.len(ret) > 0 then ret = ret .. "," end
    	ret = ret .. tostring(key) .. "=" .. tostring(var)
    end
    return ret
end

---
-- 删除字符串前后空格
-- @function [parent=#StringUtils] trim
-- @param self
-- @param #string s
-- @return #string ret
function StringUtils:trim(s)
    return s:match("^%s*(.-)%s*$")
end

---
-- 限制字符长度（中文占2个，英文和数字占1个）
-- @function [parent=#StringUtils] trim
-- @param self
-- @param #string str
-- @return #string len
function StringUtils:strMaxLimit(str, len)
    local lenInByte = #str
    local beforeCount = 1
    local curLen = 0
    local strResult = ""
    for i=1,lenInByte do
        local curByte = string.byte(str, beforeCount)
        local byteCount = 1;
        if curByte>=0 and curByte<=127 then
            byteCount = 1
            curLen = curLen + 1
        elseif curByte>=192 and curByte<223 then
            byteCount = 2
            curLen = curLen + 2
        elseif curByte>=224 and curByte<=239 then
            byteCount = 3
            curLen = curLen + 2
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
            curLen = curLen + 2
        end
        local char = string.sub(str, beforeCount, beforeCount + byteCount - 1)
        --print(char)
        if curLen <= len then
            strResult = strResult .. char
        else
            break
        end
        beforeCount = beforeCount + byteCount
        if beforeCount > lenInByte then
            break
        end
    end
    --cclog(strResult)
    return strResult
end

local specialChar ={{"{","｛"},{"}","｝"},{"%[","【"},{"%]","】"},{",","，"},{"\"","“"},{"|","｜"},{"#","＃"},{":","："},{"=","＝"}}

---
-- 过滤特殊字符
-- @function [parent=#StringUtils] FilterSpecialChar
-- @param self
-- @param #string str
-- @return #string
function StringUtils:FilterSpecialChar(str)
    for _,key in ipairs(specialChar) do
        str = string.gsub(str,key[1],key[2])
	end
	return str
end

---
-- 过滤敏感字符
-- @function [parent=#StringUtils] FilterSensitiveChar
-- @param self
-- @param #string str
-- @return #string
function StringUtils:FilterSensitiveChar(str)
    for _,key in pairs(GameConfig.KeywordConfig:getTable()) do
        local repl = ""
        local count = string.len(key.chat)
        for i=1,count do
            repl = repl.."*"
        end
        str = string.gsub(str,key.chat,repl)
    end
    return str
end

return StringUtils
