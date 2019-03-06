---
-- @module Events
local Events = {}

-- 自动创建各种Event的构造函数
Events.__index = function(table, key)
    local createFunc = function(self, o)
        o = o or {}
        local typeStr = string.sub(key, 7) .. "Type"
        o.type = self[typeStr]
        return o
    end
    return createFunc
end
setmetatable(Events, Events)

-- 向IDE说明各种Event的构造函数

---
-- 帧频事件，每帧渲染触发一次
-- @function [parent=#Events] createBackgroundEvent
-- @param self
-- @param #table o
-- @return #BackgroundEvent ret
Events.BackgroundEventType = "GLOBAL_EVENT_BACKGROUND"
---
-- app切换到后台或前台时触发
-- @module BackgroundEvent

---
-- 事件类型
-- @field [parent=#BackgroundEvent] #string type

---
-- 是否是切换到后台
-- @field [parent=#BackgroundEvent] #bool isback

---
-- 帧频事件，每帧渲染触发一次
-- @function [parent=#Events] createTickEvent
-- @param self
-- @param #table o
-- @return #TickEvent ret
Events.TickEventType = "GLOBAL_EVENT_TICK"
---
-- 帧频事件，每帧渲染触发一次
-- @module TickEvent

---
-- 事件类型
-- @field [parent=#TickEvent] #string type

---
-- 已渲染的帧数
-- @field [parent=#TickEvent] #int frameCount

---
-- C2S事件，网络层会接收此事件，并发消息给server
-- @function [parent=#Events] createC2SEvent
-- @param self
-- @param #table o
-- @return #C2SEvent ret
Events.C2SEventType = "GLOBAL_EVENT_C2S"


---
-- S2C事件 服务器下行事件
-- @function [parent=#Events] createS2CEvent
-- @param self
-- @param #table o
-- @return #S2CEvent ret
Events.S2CEventType = "GLOBAL_EVENT_S2C"

---
-- 帧频事件，每帧渲染触发一次
-- @module C2SEvent

---
-- 事件类型
-- @field [parent=#C2SEvent] #string type

---
-- 指令
-- @field [parent=#C2SEvent] #string cmd

---
-- 指令数据
-- @field [parent=#C2SEvent] #table data

---
-- 命令是否需要压缩
-- @field [parent=#C2SEvent] #bool doCompress

---
-- 命令是否为json格式（默认false，使用字符串格式）
-- @field [parent=#C2SEvent] #bool isjson

---
-- 命令是否需要立即发送
-- @field [parent=#C2SEvent] #bool sendImmediately

return Events
