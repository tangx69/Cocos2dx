---
--
--@module NumberHelper

local NumberHelper = {
}

local count = 4

---
-- 转换为字符串
-- @function [parent=#NumberHelper] toString
-- @param self #NumberHelper
-- @param #number num
-- @return #string
function NumberHelper:toString(num)
  local flag=string.sub(zzy.Sdk.getFlag(),1,2)
   if flag=="CY" or flag=="WE" then
	    return self:toStringForEng(num)
   else
		if type(num) == "table" then
			return self:LDToString(num)
		end
		if num > 1e300 then    
			return "1.000e301"
		end
		if num < 100000 then
		   return tostring(math.floor(num))
		elseif num >= 100000 and num < 100000000 then
		   num = num / 10000
		   local n = self:_getIntCount(num)
		   num = self:rounding(num,count - n)
		   local formStr = n < count and string.format("%%.0%df"..Language.src_clickhero_utils_NumberHelper_1,count-n) or "%d"..Language.src_clickhero_utils_NumberHelper_1
		   return string.format(formStr,num)
		elseif num >= 100000000 and num < 1000000000000 then
			num = num /100000000
			local n = self:_getIntCount(num)
			num = self:rounding(num,count - n)
			local formStr = n < count and string.format("%%.0%df"..Language.src_clickhero_utils_NumberHelper_2,count-n) or "%d"..Language.src_clickhero_utils_NumberHelper_2
			return string.format(formStr,num)
		elseif num >= 1000000000000 and num < 10000000000000000 then
			num = num /1000000000000
			local n = self:_getIntCount(num)
			num = self:rounding(num,count - n)
			local formStr = n < count and string.format("%%.0%df"..Language.src_clickhero_utils_NumberHelper_3,count-n) or "%d"..Language.src_clickhero_utils_NumberHelper_3
			return string.format(formStr,num)
		else
			local str = string.format("%.3e",num)
			local index = string.find(str,"+")
			if index then
				local eStr = string.sub(str,index+1)
				return string.sub(str,1,index - 1) .. string.match(eStr,"[1-9][0-9]*")
			else
				return str
			end
		end
	end
end

---
-- 转换为字符串
-- @function [parent=#NumberHelper] toStringForEng
-- @param self #NumberHelper
-- @param #number num
-- @return #string
function NumberHelper:toStringForEng(num)
    if type(num) == "table" then
        return self:LDToStringForEng(num)
    end
    if num > 1e300 then    
        return "1.000e301"
    end
    if num < 10000 then
       return tostring(math.floor(num))
    elseif num >= 10000 and num < 10000000 then
       num = num / 1000
       local n = self:_getIntCount(num)
       num = self:rounding(num,count - n)
       local formStr = n < count and string.format("%%.0%dfK",count-n) or "%dK"
       return string.format(formStr,num)
    elseif num >= 10000000 and num < 10000000000 then
        num = num /1000000
        local n = self:_getIntCount(num)
        num = self:rounding(num,count - n)
        local formStr = n < count and string.format("%%.0%dfM",count-n) or "%dM"
        return string.format(formStr,num)
    elseif num >= 10000000000 and num < 10000000000000 then
        num = num /1000000000
        local n = self:_getIntCount(num)
        num = self:rounding(num,count - n)
        local formStr = n < count and string.format("%%.0%dfB",count-n) or "%dB"
        return string.format(formStr,num)
    elseif num >= 10000000000000 and num < 10000000000000000 then
        num = num /1000000000000
        local n = self:_getIntCount(num)
        num = self:rounding(num,count - n)
        local formStr = n < count and string.format("%%.0%dfT",count-n) or "%dT"
        return string.format(formStr,num)
    else
        local str = string.format("%.3e",num)
        local index = string.find(str,"+")
        if index then
            local eStr = string.sub(str,index+1)
            return string.sub(str,1,index - 1) .. string.match(eStr,"[1-9][0-9]*")
        else
            return str
        end
    end
end

---
-- 伤害数字转换为字符串
-- @function [parent=#NumberHelper] harmToString
-- @param self #NumberHelper
-- @param #number num
-- @return #string
function NumberHelper:harmToString(num)
	local flag=string.sub(zzy.Sdk.getFlag(),1,2)
   if flag=="CY" or flag=="WE" then
        return self:harmToStringForEng(num)
    else
		if type(num) == "table" then
			return self:LDToHarmString(num)
		end
		if num < 100000 then
			return tostring(math.floor(num))
		elseif num >= 100000 and num < 100000000 then
			num = num / 10000
			local n = self:_getIntCount(num)
			num = self:rounding(num,count - n)
			local formStr = n < count and string.format("%%.0%df"..Language.src_clickhero_utils_NumberHelper_1,count-n) or "%d"..Language.src_clickhero_utils_NumberHelper_1
			return string.format(formStr,num)
		elseif num >= 100000000 and num < 1000000000000 then
			num = num /100000000
			local n = self:_getIntCount(num)
			num = self:rounding(num,count - n)
			local formStr = n < count and string.format("%%.0%df"..Language.src_clickhero_utils_NumberHelper_2,count-n) or "%d"..Language.src_clickhero_utils_NumberHelper_2
			return string.format(formStr,num)
		elseif num >= 1000000000000 and num < 10000000000000000 then
			num = num /1000000000000
			local n = self:_getIntCount(num)
			num = self:rounding(num,count - n)
			local formStr = n < count and string.format("%%.0%df"..Language.src_clickhero_utils_NumberHelper_3,count-n) or "%d"..Language.src_clickhero_utils_NumberHelper_3
			return string.format(formStr,num)
		else
			local str = string.format("%.1e",num)
			local index = string.find(str,"+")
			if index then
				local eStr = string.sub(str,index+1)
				return string.sub(str,1,index - 1) .. string.match(eStr,"[1-9][0-9]*")
			else
				return str
			end
		end
	end
end

function NumberHelper:LDToString(a)
    a:formate()
    if a.exp < 5 then
        return tostring(math.floor(a.num*math.pow(10,a.exp)))
    elseif a.exp >= 5 and a.exp < 8 then
        local n = a.exp - 4
        local formStr = n + 1 < count and string.format("%%.0%df"..Language.src_clickhero_utils_NumberHelper_1,count-n-1) or "%d"..Language.src_clickhero_utils_NumberHelper_1
        return string.format(formStr,a.num*math.pow(10,n))
    elseif a.exp >= 8 and a.exp < 12 then
        local n = a.exp - 8
        local formStr = n + 1 < count and string.format("%%.0%df"..Language.src_clickhero_utils_NumberHelper_2,count-n-1) or "%d"..Language.src_clickhero_utils_NumberHelper_2
        return string.format(formStr,a.num*math.pow(10,n))
    elseif a.exp >= 12 and a.exp < 16 then
        local n = a.exp - 12
        local formStr = n + 1 < count and string.format("%%.0%df"..Language.src_clickhero_utils_NumberHelper_3,count-n-1) or "%d"..Language.src_clickhero_utils_NumberHelper_3
        return string.format(formStr,a.num*math.pow(10,n))
    else
        return string.format("%.3fe%d",a.num,a.exp)
    end
end

function NumberHelper:LDToStringForEng(a)
    a:formate()
    if a.exp < 4 then
        return tostring(math.floor(a.num*math.pow(10,a.exp)))
    elseif a.exp >= 4 and a.exp < 7 then
        local n = a.exp - 3
        local formStr = n + 1 < count and string.format("%%.0%dfK",count-n-1) or "%dK"
        return string.format(formStr,a.num*math.pow(10,n))
    elseif a.exp >= 7 and a.exp < 10 then
        local n = a.exp - 6
        local formStr = n + 1 < count and string.format("%%.0%dfM",count-n-1) or "%dM"
        return string.format(formStr,a.num*math.pow(10,n))
    elseif a.exp >= 10 and a.exp < 13 then
        local n = a.exp - 9
        local formStr = n + 1 < count and string.format("%%.0%dfB",count-n-1) or "%dB"
        return string.format(formStr,a.num*math.pow(10,n))
    elseif a.exp >= 13 and a.exp < 16 then
        local n = a.exp - 12
        local formStr = n + 1 < count and string.format("%%.0%dfT",count-n-1) or "%dT"
        return string.format(formStr,a.num*math.pow(10,n))
    else
        return string.format("%.3fe%d",a.num,a.exp)
    end
end

function NumberHelper:LDToHarmString(a)
    a:formate()
    if a.exp < 5 then
        return tostring(math.floor(a.num*math.pow(10,a.exp)))
    elseif a.exp >= 5 and a.exp < 8 then
        local n = a.exp - 4
        local formStr = n + 1 < count and string.format("%%.0%df"..Language.src_clickhero_utils_NumberHelper_1,count-n-1) or "%d"..Language.src_clickhero_utils_NumberHelper_1
        return string.format(formStr,a.num*math.pow(10,n))
    elseif a.exp >= 8 and a.exp < 12 then
        local n = a.exp - 8
        local formStr = n + 1 < count and string.format("%%.0%df"..Language.src_clickhero_utils_NumberHelper_2,count-n-1) or "%d"..Language.src_clickhero_utils_NumberHelper_2
        return string.format(formStr,a.num*math.pow(10,n))
    elseif a.exp >= 12 and a.exp < 16 then
        local n = a.exp - 12
        local formStr = n + 1 < count and string.format("%%.0%df"..Language.src_clickhero_utils_NumberHelper_3,count-n-1) or "%d"..Language.src_clickhero_utils_NumberHelper_3
        return string.format(formStr,a.num*math.pow(10,n))
    else
        return string.format("%.1fe%d",a.num,a.exp)
    end
end

function NumberHelper:LDToHarmStringForEng(a)
    a:formate()
    if a.exp < 4 then
        return tostring(math.floor(a.num*math.pow(10,a.exp)))
    elseif a.exp >= 4 and a.exp < 7 then
        local n = a.exp - 3
        local formStr = n + 1 < count and string.format("%%.0%dfK",count-n-1) or "%dK"
        return string.format(formStr,a.num*math.pow(10,n))
    elseif a.exp >= 7 and a.exp < 10 then
        local n = a.exp - 6
        local formStr = n + 1 < count and string.format("%%.0%dfM",count-n-1) or "%dM"
        return string.format(formStr,a.num*math.pow(10,n))
    elseif a.exp >= 10 and a.exp < 13 then
        local n = a.exp - 9
        local formStr = n + 1 < count and string.format("%%.0%dfB",count-n-1) or "%dB"
        return string.format(formStr,a.num*math.pow(10,n))
    elseif a.exp >= 13 and a.exp < 16 then
        local n = a.exp - 12
        local formStr = n + 1 < count and string.format("%%.0%dfT",count-n-1) or "%dT"
        return string.format(formStr,a.num*math.pow(10,n))
    else
        return string.format("%.1fe%d",a.num,a.exp)
    end
end

---
-- 伤害数字转换为字符串
-- @function [parent=#NumberHelper] harmToStringForEng
-- @param self #NumberHelper
-- @param #number num
-- @return #string
function NumberHelper:harmToStringForEng(num)
    if type(num) == "table" then
        return self:LDToHarmStringForEng(num)
    end
    if num < 10000 then
        return tostring(math.floor(num))
    elseif num >= 10000 and num < 10000000 then
        num = num / 1000
        local n = self:_getIntCount(num)
        num = self:rounding(num,count - n)
        local formStr = n < count and string.format("%%.0%dfK",count-n) or "%dK"
        return string.format(formStr,num)
    elseif num >= 10000000 and num < 10000000000 then
        num = num /1000000
        local n = self:_getIntCount(num)
        num = self:rounding(num,count - n)
        local formStr = n < count and string.format("%%.0%dfM",count-n) or "%dM"
        return string.format(formStr,num)
    elseif num >= 10000000000 and num < 10000000000000 then
        num = num /1000000000
        local n = self:_getIntCount(num)
        num = self:rounding(num,count - n)
        local formStr = n < count and string.format("%%.0%dfB",count-n) or "%dB"
        return string.format(formStr,num)
    elseif num >= 10000000000000 and num < 10000000000000000 then
        num = num /1000000000000
        local n = self:_getIntCount(num)
        num = self:rounding(num,count - n)
        local formStr = n < count and string.format("%%.0%dfT",count-n) or "%dT"
        return string.format(formStr,num)
    else
        local str = string.format("%.1e",num)
        local index = string.find(str,"+")
        if index then
            local eStr = string.sub(str,index+1)
            return string.sub(str,1,index - 1) .. string.match(eStr,"[1-9][0-9]*")
        else
            return str
        end
    end
end

---
-- 时间转换为字符串
-- @function [parent=#NumberHelper] dateTimeToString
-- @param self #NumberHelper
-- @param #number time
-- @return #string
function NumberHelper:dateTimeToString(time)
    local second = math.floor(time % 60)
    time = math.floor(time / 60)
    local minute = math.floor(time % 60)
    time = math.floor(time / 60)
    local hour = math.floor(time % 24)
    local day = math.floor(time / 24)
    local str = ""
    if day > 0 then
        str = string.format("%d"..Language.src_clickhero_utils_NumberHelper_4,day)
    end
    if (day > 0 or hour > 0) and (hour ~= 0 or minute~=0 or second~=0) then
        str = string.format("%s%d"..Language.src_clickhero_utils_NumberHelper_5,str,hour)
    end    
    if (day > 0 or hour > 0 or minute > 0) and (minute~=0 or second~=0) then
        str = string.format("%s%d"..Language.src_clickhero_utils_NumberHelper_6,str,minute)
    end    
    if second ~= 0 then
        str = string.format("%s%d"..Language.src_clickhero_utils_NumberHelper_7,str,second)
    end
    return str
end


---
-- 活动时间转换为倒计时
-- @function [parent=#NumberHelper] cdTimeToString
-- @param self #NumberHelper
-- @param #number time
-- @return #string
function NumberHelper:cdTimeToString(time)
    local second = math.floor(time % 60)
    time = math.floor(time / 60)
    local minute = math.floor(time % 60)
    time = math.floor(time / 60)
    local hour = math.floor(time % 24)
    local day = math.floor(time / 24)
    local str = ""
    local flag=string.sub(zzy.Sdk.getFlag(),1,2)
   if flag=="CY" or flag=="WE" then
        str = string.format("%dd:%02dh:%02dm:%02ds",day,hour,minute,second)
    else
        str = string.format(Language.src_clickhero_utils_NumberHelper_9,day,hour,minute,second)
    end
--    if day > 0 then
--        str = string.format("%d"..Language.src_clickhero_utils_NumberHelper_4,day)
--    end
--    if (day > 0 or hour > 0) and (hour ~= 0 or minute~=0 or second~=0) then
--        str = string.format("%s%d"..Language.src_clickhero_utils_NumberHelper_5,str,hour)
--    end    
--    if (day > 0 or hour > 0 or minute > 0) and (minute~=0 or second~=0) then
--        str = string.format("%s%d"..Language.src_clickhero_utils_NumberHelper_6,str,minute)
--    end    
--    if second ~= 0 then
--        str = string.format("%s%d"..Language.src_clickhero_utils_NumberHelper_7,str,second)
--    end
    return str
end

---
-- 保留几位有效数字
-- @function [parent=#NumberHelper] rounding
-- @param self #NumberHelper
-- @param #number num
-- @param #number n 小数点后保留几位
-- @return #number
function NumberHelper:rounding(num,n)
    n= n < 0 and 0 or n
    local times = math.pow(10,n)
    local temp = num * times
    local newNum = math.modf(temp)
    newNum = newNum /times
--    temp = temp * 10
--    local nextBit = math.modf(temp % 10)
--    if nextBit > 4 then
--        newNum = newNum + 1/times
--    end
    return newNum
end

---
-- 获得整数位数
-- @function [parent=#NumberHelper] _getIntCount
-- @param self #NumberHelper
-- @param #number num
-- @return #number
function NumberHelper:_getIntCount(num)
    local n = 0
    while num >= 1 do
        num = num/10
        n = n + 1
    end
    return n
end

---
-- 魂攻击力显示倍数加成
-- @function [parent=#NumberHelper] multiple
-- @param self #NumberHelper
-- @param #number num
-- @param #number above
-- @return #string
function NumberHelper:multiple(num,above)
    above = above < 0 and 0 or above
    if num > above then
        return ch.NumberHelper:toString(num/100) .. Language.src_clickhero_utils_NumberHelper_8
    else
        return string.format("%g%%",num)
    end
end

return NumberHelper