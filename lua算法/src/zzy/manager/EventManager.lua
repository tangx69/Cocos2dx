---
-- @module EventManager
local EventManager = {
    _listeners = {},
    _typeListenerIds = {}
}

---
-- 添加监听
-- @function [parent=#EventManager] listen
-- @param self
-- @param #string eventType 监听的事件类型
-- @param #function handler 触发事件时执行的方法（return -1表示拦截事件）
-- @param #number priority 事件优先级（有效值1-6），默认为5，越小优先级越高(12错误信息,3、为检测功能开启 4pve剧情处理，5普通弹框)
-- @param #table obj 监听事件的对象
-- @param #bool once 是否只监听一次，默认false
-- @return #string 监听id6
function EventManager:listen(eventType, handler, priority, obj, once)
    local id = zzy.GuidUtils:getGuid()
    priority = priority or 5
    self._typeListenerIds[eventType] = self._typeListenerIds[eventType] or {}
    self._typeListenerIds[eventType][priority] = self._typeListenerIds[eventType][priority] or {}
    self._typeListenerIds[eventType][priority][id] = id

    self._listeners[id] = {
        eventType = eventType,
        handler = handler,
        priority = priority,
        obj = obj,
        once = once
    }
    return id
end

---
-- 移除监听
-- @function [parent=#EventManager] unListen
-- @param self
-- @param #string id 监听id
function EventManager:unListen(id)
    if self._listeners[id] then
        local eventType = self._listeners[id].eventType
        local priority = self._listeners[id].priority
        self._typeListenerIds[eventType][priority][id] = nil
        self._listeners[id] = nil   
    end
end

---
-- @function [parent=#EventManager] dispatchByType
-- @param self
-- @param #string eventType
function EventManager:dispatchByType(eventType)
    self:dispatch({type = eventType})
end

---
-- 触发事件
-- @function [parent=#EventManager] dispatch
-- @param self
-- @param #event event
function EventManager:dispatch(event)
    local ids = self._typeListenerIds[event.type] or {}
    ids = zzy.TableUtils:copy(ids)
    local brk = false
    for i = 1, 6 do
        if ids[i] then
            for id,_ in pairs(ids[i]) do
                local listener = self._listeners[id]
                if listener then
                    brk = listener.handler(listener.obj, event) == -1 or brk
                    if listener.once then  self:unListen(id) end
                end
            end
        end
        if brk then break end
    end
end

---
-- 清除
-- @function [parent=#EventManager] clean
-- @param self
function EventManager:clean()
    self._typeListenerIds = {}
    self._listeners = {}
end

return EventManager
