---
-- 聊天model层
--@module ChatModel

local ChatModel = {
    _data = nil,
    _unreadCount = 0,
    _curChanelId = nil,
    _curName = nil,
    _curContent = nil,
    dataChangeEventType = "CHAT_MODEL_DATA_CHANGE", --{type=}
    
}

---
-- @function [parent=#ChatModel] init
-- @param #ChatModel self
-- @param #table data
function ChatModel:init(data)
    self._data = data.cht or {}
end

---
-- 清理
-- @function [parent=#ChatModel] clean
-- @param #ChatModel self
function ChatModel:clean()
    self._data = nil
    self._curChanelId = nil
    self._curName = nil
    self._curContent = nil
    self._unreadCount = 0
end

function ChatModel:_raiseDataChangeEvent()
    local evt = {
        type = self.dataChangeEventType
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 处理缓存数据
-- @function [parent=#ChatModel] getCacheData
-- @param #ChatModel self
-- @return #table
function ChatModel:getCacheData()
    return self._data.cache or {}
end

---
-- 获取未读数量
-- @function [parent=#ChatModel] getUnreadCount
-- @param #ChatModel self
-- @return #number
function ChatModel:getUnreadCount()
	return self._unreadCount
end

---
-- 清除未读数量
-- @function [parent=#ChatModel] clearUnreadCount
-- @param #ChatModel self
function ChatModel:clearUnreadCount()
    self._unreadCount = 0
    self:_raiseDataChangeEvent()
end

---
-- 添加聊天
-- @function [parent=#ChatModel] addChatCount
-- @param #ChatModel self
function ChatModel:addChatCount()
    if self._unreadCount < GameConst.CHAT_MAX_ITEMS_COUNT then
        self._unreadCount = self._unreadCount + 1
    end
end

---
-- 设置聊天内容
-- @function [parent=#ChatModel] setChatContent
-- @param #ChatModel self
-- @param #table chatData
function ChatModel:setChatContent(chatData)
    self._curContent = chatData.c
    self._curName = chatData.i
    self._curChanelId = chatData.t
    self:_raiseDataChangeEvent()
end


---
-- 获得聊天文字
-- @function [parent=#ChatModel] getChatContent
-- @param #ChatModel self
-- @return #string
function ChatModel:getChatContent()
    if self._curChanelId then
        local channelStr = ""
        if self._curChanelId == ch.ChatView.ChanenlList.World then
            channelStr = Language.src_clickhero_model_ChatModel_1
        elseif self._curChanelId == ch.ChatView.ChanenlList.Guild then
            channelStr = Language.src_clickhero_model_ChatModel_2
        end
        return string.format("[%s]%s: %s",channelStr,self._curName,self._curContent)
    end
	return ""
end

return ChatModel