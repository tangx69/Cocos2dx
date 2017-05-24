local Utils = {}

--node:一个textlabel
--str：该lable上要显示的文字
--maxWidth：该label文字最大宽度
function Utils.autoBreak(node, str, maxWidth)
    local getFontWidth = function(_str, node)
        node:setString(_str)
        return node:getContentSize().width
    end

    local len = #str
    local curWidth = 0
    local curStr = ""
    local beforeCount = 1
    local curLen = 0
    for i=1, len do
        local curByte = string.byte(str,beforeCount)
        local byteCount = 1
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

        local curChar = string.sub(str, beforeCount, beforeCount + byteCount - 1)
        local fontWidth = getFontWidth(curChar, node)
        curWidth = curWidth + fontWidth
        if curChar=="\n" then
            curWidth = 0
        end

        if curWidth>maxWidth then
            curWidth = fontWidth
            curStr = curStr.."\n"
        end
        curStr = curStr..curChar

        beforeCount = beforeCount + byteCount
        if beforeCount > len then
            break
        end
    end

    return curStr
end

return Utils
