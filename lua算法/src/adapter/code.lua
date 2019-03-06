
local num2char = 
{
    ["0"] = "C",
    ["1"] = "K",
    ["2"] = "M",
    ["3"] = "L",
    ["4"] = "P",
    ["5"] = "F",
    ["6"] = "A",
    ["7"] = "T",
    ["8"] = "O",
    ["9"] = "V",
    ["."] = "D"
}

local char2num = 
{
    C = 0,
    K = 1,
    M = 2,
    L = 3,
    P = 4,
    F = 5,
    A = 6,
    T = 7,
    O = 8,
    V = 9,
    D = ".",
}

function ENCODE_NUM(oriData)
    local ret = ""

    local oriNum = tonumber(oriData)
    local oriStr = tostring(oriNum)
    
    local dataLen = string.len(oriStr)
    for i=1,dataLen do
        local oneNum = string.sub(oriStr,i,i)
        local oneChar = num2char[oneNum]
        if oneChar then
            ret = ret..oneChar
        else
            ret = ret..oneNum
        end
    end
    
    --print("[DEBUG][ENCODE_NUM]num="..oriData)
    --print("[DEBUG][ENCODE_NUM]code="..ret)
    return ret
end

function DECODE_NUM(encodeData)
    local ret = ""
    
    if (tonumber(encodeData) ~= nil) then
        ret = tonumber(encodeData)
    else
        local encodeString = tostring(encodeData)
        local dataLen = string.len(encodeString)
        for i=1,dataLen do
            local oneChar = string.sub(encodeString,i,i)
            local oneNum = char2num[oneChar]
            
            if oneNum then
                ret = ret..oneNum
            else
                ret = ret..oneChar
            end 
        end
        
        ret = tonumber(ret)
    end
    
    --print("[DEBUG][DECODE_NUM]code="..encodeData)
    --print("[DEBUG][DECODE_NUM]num="..ret)
    
    return ret
end

local testNum = 1234567
local eNum = ENCODE_NUM(testNum)
local dNum = DECODE_NUM(eNum)
--print("testNum="..testNum)
--print("eNum="..eNum)
--print("dNum="..dNum)
if (testNum ~= dNum) then
    print("[ERROR]解码出来的数字跟原数字不一样！！！")
end

--print(os.time())