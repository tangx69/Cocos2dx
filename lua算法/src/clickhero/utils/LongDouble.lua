local LongDouble = {
    zero = nil
}

LongDouble.__index = LongDouble

local ingoreSize = 10

function LongDouble:new(num)
	local o = {num = 0,exp=0}
    if num then
        o.num,o.exp = self:_splitNumber(num)
    end
    setmetatable(o,LongDouble)
    return o
end

LongDouble.__add = function(a,b)
	a,b = LongDouble:_convertParam(a,b)
	local c = LongDouble:new()
	local e = a.exp - b.exp
    if e > ingoreSize then
        c.num = a.num
        c.exp = a.exp
    elseif e < -ingoreSize then
        c.num = b.num
        c.exp = b.exp
    else
        c.num = a.num + b.num/(10^e)
        c.exp = a.exp
        c:formate()
    end
    return c
end

LongDouble.__sub = function(a,b)
    a,b = LongDouble:_convertParam(a,b)
    local c = LongDouble:new()
    local e = a.exp - b.exp
    if e > ingoreSize then
        c.num = a.num
        c.exp = a.exp
    elseif e < -ingoreSize then
        c.num = -b.num
        c.exp = b.exp
    else
        c.num = a.num - b.num/(10^e)
        c.exp = a.exp
        c:formate()
    end
    return c
end

LongDouble.__mul = function(a,b)
    a,b = LongDouble:_convertParam(a,b)
    local c = LongDouble:new()
    c.num = a.num * b.num
    c.exp = a.exp + b.exp
    c:formate()
    return c
end

LongDouble.__div = function(a,b)
    a,b = LongDouble:_convertParam(a,b)
    local c = LongDouble:new()
    c.num = a.num / b.num
    c.exp = a.exp - b.exp
    c:formate()
    return c
end

LongDouble.__mod = function(a,b) -- 取模

end

LongDouble.__pow = function(a,b)
    error("暂时不支持该类型的pow") 
end

LongDouble.__unm = function(a) -- 相反数
    local c = LongDouble:new()
    c.num = -a.num
    c.exp = a.exp
    return c
end

LongDouble.__eq = function(a,b) 
    a,b = LongDouble:_convertParam(a,b)
    a:formate()
    b:formate()
    if a.exp ~= b.exp then
        return false
    else 
        return math.abs(a.num - b.num) < 0.00000001
    end
end

LongDouble.__lt = function(a,b) -- 小于
    a,b = LongDouble:_convertParam(a,b)
    a:formate()
    b:formate()
    if a.exp == b.exp then
        return a.num < b.num
    elseif a.num > 0 and b.num > 0 then
        return a.exp < b.exp 
    elseif a.num < 0 and b.num < 0 then
        return a.exp > b.exp
    else
        return a.num < b.num
    end
end

LongDouble.__le = function(a,b) -- 小于等于
    a,b = LongDouble:_convertParam(a,b)
    a:formate()
    b:formate()
    if a.exp == b.exp then
        return a.num <= b.num
    elseif a.num > 0 and b.num > 0 then
        return a.exp < b.exp 
    elseif a.num < 0 and b.num < 0 then
        return a.exp > b.exp
    else
        return a.num < b.num
    end
end

local count = 4
LongDouble.__tostring = function(a)
    return string.format("%.8fe%d",a.num,a.exp)
end


function LongDouble:pow(a,b)
    local c = LongDouble:new()
    if b == 0 then
        c.num = 1
        return c
    end
	local num,exp = ch.PowHelper:pow(a,b)
	if num then
	   c.num = num
	   c.exp = exp
	else
        c.num = a
        c:formate()
        while b > 300 do
            c.num = c.num^300
            c.exp = c.exp*300
            c:formate()
            b= b/300
        end
        c.num = c.num^b
        c.exp = c.exp*b
	end
	c:formate()
	return c
end

function LongDouble:formate()
    if self.num == 0 and self.exp == 0 then return end
    local c = self.exp - math.floor(self.exp)
    if c > 0 then
        self.exp = math.floor(self.exp)
        self.num = self.num * 10^c
    end
    if self.num == 0 then
        self.exp = 0
    elseif self.num<=-10 or (self.num >-1 and self.num <1) or self.num >=10 then
        local num,exp = LongDouble:_splitNumber(self.num)
        self.num = num
        self.exp = self.exp + exp
    end
end

function LongDouble:log10(a)
	return a.exp + math.log10(a.num)
end

function LongDouble:floor(a)
	if type(a) == "number" then
	   return math.floor(a)
    elseif type(a) == "table" then
        local c = self:new()
        if a.exp >= 10 then
            c.exp = a.exp
            c.num = a.num
        else
            c.num = a.num * ch.PowHelper:pow10(a.exp)
            c.num = math.floor(c.num)
            c:formate()
        end
        return c
	end
end

function LongDouble:ceil(a)
    if type(a) == "number" then
        a = math.ceil(a)
        return LongDouble:new(a)
    elseif type(a) == "table" then
        local c = self:new()
        if a.exp >= 10 then
            c.exp = a.exp
            c.num = a.num
        else
            c.num = a.num * ch.PowHelper:pow10(a.exp)
            c.num = math.ceil(c.num)
            c:formate()
        end
        return c
    end
end

function LongDouble:toLongDouble(a)
    local aStr = zzy.StringUtils:trim(a)
    local isf = false
    if string.sub(aStr,1,1) == "-" then
        aStr = string.sub(aStr,2)
        isf = true
        aStr = zzy.StringUtils:trim(aStr)
    end
    while string.len(aStr) > 1 and string.sub(aStr,1,1) == "0" do
        aStr = string.sub(aStr,2)
    end
    if isf then
        aStr = "-" ..aStr
    end
	local eIndex = string.find(aStr,"[eE]")
    local c = LongDouble:new()
	if eIndex then
        c.num = tonumber(string.sub(a,1,eIndex - 1))
        c.exp = tonumber(string.sub(a,eIndex + 1))
	else
        local dIndex = string.find(aStr,"%.")
        if dIndex then
            local n = 1
            local maxLength = 11
            if string.sub(aStr,1,1) == "-" then
                c.exp = dIndex - 3
                n = 2
                maxLength = 12
            else
                c.exp = dIndex - 2
            end
            local numStr = string.sub(aStr,1,n).."."
            if dIndex > n + 1 then
                local length = dIndex-1 > maxLength and maxLength or dIndex-1
                numStr = numStr .. string.sub(aStr,n + 1,length)
            end
            if string.len(numStr) < maxLength then
                local len = maxLength - string.len(numStr)
                numStr = numStr.. string.sub(aStr,dIndex + 1,dIndex +len)
           end
           c.num = tonumber(numStr)
	   else
	        local n = 1
            local maxLength = 10
            local numLen = string.len(aStr)
            if string.sub(aStr,1,1) == "-" then
                n= 2
                maxLength = 11
                numLen = numLen -1
            end
            c.exp = numLen - 1
            local numStr = string.sub(aStr,1,n).."."
            numStr = numStr .. string.sub(aStr,n+1,n+9)
            c.num = tonumber(numStr)
	   end
	end
	c:formate()
	return c
end

function LongDouble:toNumber()
	self:formate()
	if self.exp >305 then
	   return nil
	else
	   return self.num * ch.PowHelper:pow10(self.exp)
    end
end

function LongDouble:_convertParam(a,b)
    if type(a) == "string" then
        a = tonumber(a)
    end
    if type(b) == "string" then
        b = tonumber(b)
    end
    
    if type(a) == "number" then
        local o = {num = 0,exp =0}
        o.num,o.exp = LongDouble:_splitNumber(a)
        a = o
    end
    
    if type(b) == "number" then
        local o = {num = 0,exp =0}
        o.num,o.exp = LongDouble:_splitNumber(b)
        b = o
    end
    
    return a,b
end

function LongDouble:_splitNumber(num)
    if num == 0 then
       return 0,0
    end
    local e = math.floor(math.log10(math.abs(num))+0.000000001)
    local n = num/ch.PowHelper:pow10(e)
    return n,e
end

LongDouble.zero = {}
setmetatable(LongDouble.zero,{__index = function(t,k)
    if k == "num" or k== "exp" then
        return 0
    else
        return LongDouble[k]
    end
end,__newindex = function(t,k,v)
    error("LongDouble的zero只读，无法修改")
end,__add = LongDouble.__add,__sub = LongDouble.__sub,
__mul = LongDouble.__mul,__mul = LongDouble.__div,
__mod = LongDouble.__mod,__pow = LongDouble.__pow,
__unm = LongDouble.__unm,__eq = LongDouble.__eq,
__lt = LongDouble.__lt,__le = LongDouble.__le,
__tostring = LongDouble.__tostring
})

return LongDouble