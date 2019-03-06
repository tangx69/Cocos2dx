---
-- 消息 model层     结构  "msg":[{"id":"2", icon = "1", t:"1为活动消息，2为系统消息，3为社交消息","title":"公告1", "text":"内容", "dq":"是否已读（1为未读，2为已读）", "tz":"跳转类型（0为没有跳转，1为跳转到好友）", "fj":[{"id":"物品id", "num":"数量", "t":"类型（1为代币,2为宠物，3为buff）"}, {}, ...]}, {}, ...]
--@module MsgModel
local MsgModel = {
    _data = nil,
    _newNum = nil,
    objwebView = nil,
    _dataState = nil,
    dataChangeEventType = "MsgModelDataChange",
	dataType = {
        read = 1,
        get = 2,
        add = 3,
        open = 4,
        panel = 5
    }
}

---
-- @function [parent=#MsgModel] init
-- @param #MsgModel self
-- @param #table data
function MsgModel:init(data)
    self._data = {}
    self._data.content = {}
    self._dataState = {false,true,true}
    if data.msg.num then
        self._newNum = data.msg.num
    else
        self._newNum = {0,0,0}
    end

--    if data and data.msg and data.msg then
--        self._data = data.msg
--    else
--        self._data = {{id="2", t="1", icon = "1", title="公告1", text="内容", dq="是否已读（1为未读，2为已读）", tz="跳转类型（0为没有跳转，1为跳转到好友）", fj={{id="物品id", num="数量", t="类型（1为代币,2为宠物，3为buff）"}}}}   
--    end
--    self._data = {{id="2", t="1", icon = "1", title="公告1", text="内容", dq="是否已读（1为未读，2为已读）", tz="跳转类型（0为没有跳转，1为跳转到好友）", fj={{id="物品id", num="数量", t="类型（1为代币,2为宠物，3为buff）"}}}}
--    self:initData()
end

---
-- @function [parent=#MsgModel] clean
-- @param #MsgModel self
function MsgModel:clean()
    self._data = nil
    self._newNum = nil
    self.objwebView = nil
    self._dataState = nil
end

---
-- @function [parent=#MsgModel] initData
-- @param #MsgModel self
function MsgModel:initData()
    for k,v in ipairs(self._data) do
        if not v.open then
            v.open = "false"
            --v.fjs = 1
        end
    end
end

---
-- 添加新消息
-- @function [parent=#MsgModel] addMsg
-- @param #MsgModel self
-- @param #string msgData
function MsgModel:addMsg(msgData)
    local type = tonumber(msgData.t)
    if not self._data.content[type] then
        self._data.content[type] = {}
    end
    table.insert(self._data.content[type],1,msgData)
    if table.maxn(self._data.content[type]) > 30 then
        table.remove(self._data.content[type])
    end
    self._newNum[type] = self._newNum[type]+1
    if self._newNum[type] > 30 then
        self._newNum[type] = 30
    end
    self:setNumNew(type)
    self:dataChangeEvt(self.dataType.add, msgData)
end

---
-- 初始化消息数据
-- @function [parent=#MsgModel] addMsgByType
-- @param #MsgModel self
-- @param #table data
-- @param #number type
function MsgModel:addMsgByType(data,type)
    self._data.content[type] = data
    self._dataState[type] = false
    self:setNumNew(type)
    self:dataChangeEvt(self.dataType.panel,"all")
end

---
-- 是否保存过消息数据
-- @function [parent=#MsgModel] getDataState
-- @param #MsgModel self
-- @param #number type
function MsgModel:getDataState(type)
    return self._dataState[type]
end

---
-- 是否显示tab页（指定类型）
-- @function [parent=#MsgModel] ifShowType
-- @param #MsgModel self
-- @param #string msgType
-- @return #boolean
function MsgModel:ifShowType(msgType)
--    local if_show = false
--    for k,v in ipairs(self._data) do
--        if tostring(msgType) == tostring(v.t) and tostring(v.dq) == "1" then
--            if_show = true
--            break
--        end
--    end
--    if msgType == "1" and if_show == false then
--    	if not self:ifHaveNew() then
--    		if_show = true
--    	end
--    end
--    return if_show
    if tonumber(msgType) == 1 then
        if self:numNewType(2) == 0 and self:numNewType(3) == 0 then
            return true
        else
            return false
        end
    elseif tonumber(msgType) == 2 then
        return self:numNewType(msgType) ~= 0
    elseif tonumber(msgType) == 3 then
        return self:numNewType(2) == 0 and self:numNewType(msgType) ~= 0
    else
        return false
    end
end

---
-- 是否有附件
-- @function [parent=#MsgModel] ifAttachments
-- @param #MsgModel self
-- @param #number type
-- @return #boolean
function MsgModel:ifAttachments(type)
    local if_attachments = false
    if self._data.content[tonumber(type)] then
        for k,v in ipairs(self._data.content[tonumber(type)]) do
            if tostring(v.fjs) == "2" then
                if_attachments = true
                break
            end
        end
    end
    return if_attachments
end

---
-- 是否有新消息（指定类型）
-- @function [parent=#MsgModel] ifHaveNewType
-- @param #string msgType
-- @param #MsgModel self
-- @return #boolean
function MsgModel:ifHaveNewType(msgType)
--    local if_have_new = false
--    for k,v in ipairs(self._data) do
--        if tostring(msgType) == tostring(v.t) and tostring(v.dq) == "1" then
--    		if_have_new = true
--    		break
--    	end
--    end
--    return if_have_new
    return self:numNewType(msgType) ~= 0
end

---
-- 新消息总数量
-- @function [parent=#MsgModel] numNew
-- @param #MsgModel self
-- @return #number
function MsgModel:numNew()
--    local num_new = 0
--    for k,v in ipairs(self._data) do
--        if tostring(v.dq) == "1" then
--            num_new = num_new + 1
--        end
--    end
--    return num_new
    return self:numNewType(1)+self:numNewType(2)+self:numNewType(3)
end

---
-- 新消息数量（指定类型）
-- @function [parent=#MsgModel] numNewType
-- @param #MsgModel self
-- @param #string msgType
-- @return #number
function MsgModel:numNewType(msgType)
--    local num_new = 0
--    if self._data.content[msgType] then
--        for k,v in ipairs(self._data.content[msgType]) do
--            if tostring(v.dq) == "1" then
--                num_new = num_new + 1
--            end
--        end
--        self._newNum[tonumber(msgType)] = num_new
--    end
----    return num_new
--    if self._newNum[tonumber(msgType)] < 0 then
--        self._newNum[tonumber(msgType)] = 0
--    end
    return self._newNum[tonumber(msgType)]
end

---
-- 新消息数量（指定类型）
-- @function [parent=#MsgModel] setNumNew
-- @param #MsgModel self
-- @param #string msgType
-- @return #number
function MsgModel:setNumNew(msgType)
    local num_new = 0
    if self._data.content[msgType] then
        for k,v in ipairs(self._data.content[msgType]) do
            if tostring(v.dq) == "1" then
                num_new = num_new + 1
            end
        end
        self._newNum[tonumber(msgType)] = num_new
    end
    if self._newNum[tonumber(msgType)] < 0 then
        self._newNum[tonumber(msgType)] = 0
    end
end


---
-- 是否有新消息
-- @function [parent=#MsgModel] ifHaveNew
-- @param #MsgModel self
-- @return #boolean
function MsgModel:ifHaveNew()
    local if_have_new = false
    for k,v in ipairs(self._data) do
        if tostring(v.dq) == "1" then
            if_have_new = true
            break
        end
    end
    return if_have_new
end

---
-- 获取消息列表（指定类型）
-- @function [parent=#MsgModel] listType
-- @param #string msgType
-- @param #MsgModel self
-- @return #table
function MsgModel:listType(msgType)
--    local list = {}
--    for k,v in ipairs(self._data) do
--        if tostring(msgType) == tostring(v.t)then
--            table.insert(list, v.id)
--        end
--    end
--    return list
    local list = {}
    if self._data.content[tonumber(msgType)] then
        for k,v in ipairs(self._data.content[tonumber(msgType)]) do
            table.insert(list, v.id)
        end
    end
    return list
end

---
-- 一键领取附件
-- @function [parent=#MsgModel] getAllAttachments
-- @param #MsgModel self
-- @param #number type
function MsgModel:getAllAttachments(type)
    type = tonumber(type)
    ch.NetworkController:getAllAttachments(type)
    for k,v in ipairs(self._data.content[type]) do
        if v.fjs == 2 and v.fj and table.maxn(v.fj) > 0 then
            ch.CommonFunc:addItems(v.fj)
            --v.fj = {}
            v.fjs = 3
            v.dq = "2"
        end
    end
    self:setNumNew(type)
    self:dataChangeEvt(self.dataType.get,"all")
end

---
-- 一键读取邮件
-- @function [parent=#MsgModel] allMsgRead
-- @param #MsgModel self
-- @param #number type
function MsgModel:allMsgRead(type)
    type = tonumber(type)
    ch.NetworkController:readAllMsg(type)
    for k,v in ipairs(self._data.content[type]) do
        v.dq = "2"
    end
    self:setNumNew(type)
    self:dataChangeEvt(self.dataType.get,"all")
end

---
-- 获取消息信息
-- @function [parent=#MsgModel] msgData
-- @param #MsgModel self
-- @param #number type
-- @param #string msgID
-- @return #table
function MsgModel:msgData(type,msgID)
    type = tonumber(type)
    local msg_data = {}
    if self._data.content[type] then
        for k,v in ipairs(self._data.content[type]) do
            if tostring(msgID) == tostring(v.id) then
                msg_data = v
                break
            end
        end
    end
    return msg_data
end

---
-- 消息是否展开
-- @function [parent=#MsgModel] openCard
-- @param #MsgModel self
-- @param #number type
-- @param #string msgID
-- @param #boolean state
function MsgModel:openCard(type,msgID, state)
    type = tonumber(type)
    for k,v in ipairs(self._data.content[type]) do
        if tostring(msgID) == tostring(v.id) then
            if state then
                if v.open == "false" then
                	v.open = "true"
                end
--                if tostring(v.dq) == "1" then
                    v.dq = "2"
                    ch.NetworkController:readMsg(v.id)
                    self._newNum[type] = self._newNum[type]-1
                    self:dataChangeEvt(self.dataType.read, v)
--                end
            else
                if v.open == "true" then
                    v.open = "false"
                end
            end
        else
            v.open = "false"
        end
    end
    self:dataChangeEvt(self.dataType.open, state)
    
end

---
-- 领取附件
-- @function [parent=#MsgModel] getAttachments
-- @param #MsgModel self
-- @param #number type
-- @param #string msgID
function MsgModel:getAttachments(type,msgID)
    type = tonumber(type)
    ch.NetworkController:getAttachments(msgID)
    for k,v in ipairs(self._data.content[type]) do
        if v.fjs == 2 and tostring(msgID) == tostring(v.id) and v.fj and table.maxn(v.fj) > 0 then
            ch.CommonFunc:addItems(v.fj)
            --v.fj = {}
            v.fjs = 3
            break
        end
    end
    self:dataChangeEvt(self.dataType.get,msgID)
end

---
-- 消息数据改变发送事件（客户端监听）
-- @function [parent=#MsgModel] dataChangeEvt
-- @param #MsgModel self
-- @param #string dataType
-- @param #table data
function MsgModel:dataChangeEvt(dataType,data)
    local evt = {
        type = self.dataChangeEventType,
        dataType = dataType,
        value = data
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 获得奖励图标
-- @function [parent=#MsgModel] getRewardIcon
-- @param #MsgModel self
-- @param #number type
-- @param #number id
-- @return #string
function MsgModel:getRewardIcon(type,id)
    local index =""
    if type == 1 then
        index = "db"..id
    elseif type == 2 then
        index = "cw"..id
    elseif type == 3 then
        index = "bf"..id
    elseif type == 4 then
        return GameConst.MSG_FJ_ICON[1]["db90002"]
    elseif type == 5 then
        if id >51000 then
            return GameConst.CARD_GET_ICON.chips
        else
            return GameConst.CARD_GET_ICON.card
        end
    elseif type == 6 then
        if id == 40100 then
            return GameConst.MSG_FJ_ICON[1]["db90004"]
        elseif id == 40101 then
            return GameConst.MSG_FJ_ICON[1]["db90003"]
        end
    elseif type == 7 then
        return "res/icon/icon_boss.png"
    end
    return GameConst.MSG_FJ_ICON[type][index]
end

---
-- 获得奖励数量
-- @function [parent=#MsgModel] getRewardValue
-- @param #MsgModel self
-- @param #number type
-- @param #number id
-- @param #number num
-- @return #string
function MsgModel:getRewardValue(type,id,num)
    if type == 3 then
        return string.format(Language.MSG_G_HOUR,num/3600)
    elseif type == 4 then
        local tmpNum = ch.CommonFunc:getOffLineGold(num)
        return ch.NumberHelper:toString(tmpNum)
    elseif type == 6 then
        local level = math.floor(ch.StatisticsModel:getMaxLevel()/5)*5
        local tmpNum = math.floor(ch.LevelController:getPrimalHeroSoulRewards(level)*num)
        if tmpNum < 1 then
            tmpNum = 1
        end
        return tmpNum
    else
        return ch.NumberHelper:toString(num)
    end
end

---
-- 获取附件icon Unit
-- @function [parent=#MsgModel] getIconUnit
-- @param #MsgModel self
-- @param #string iconType
-- @param #string num
function MsgModel:getIconUnit(iconType,num)
    local layer = ccui.ImageView:create()
    local imageIcon = ccui.ImageView:create()
    if cc.SpriteFrameCache:getInstance():getSpriteFrame(iconType) then
        imageIcon:loadTexture(iconType,ccui.TextureResType.plistType)
    else
        imageIcon:loadTexture(iconType,ccui.TextureResType.localType)
    end
    local textField = ccui.Text:create("", "res/ui/aaui_font/ch.ttf", 22)
    textField:ignoreContentAdaptWithSize(true)
    textField:setContentSize(cc.size(500,50))
    textField:setString(num)
    textField:setPosition(30,4)
    textField:setAnchorPoint(0,0)
    imageIcon:setAnchorPoint(0,0)
    layer:addChild(imageIcon)
    layer:addChild(textField)
    --return layer,textField:getContentSize().width+textField:getPositionX() + 20
    return layer,40
end

---
-- 获取邮件图标
-- @function [parent=#MsgModel] getMsgIcon
-- @param #MsgModel self
-- @param #string type
-- @param #string msgID
-- @return #string
function MsgModel:getMsgIcon(type,msgID)
    if type == "3" then -- 社交消息
        return GameConst.MSG_ICON[4]
    elseif self:msgData(type,msgID).fj and table.maxn(self:msgData(type,msgID).fj)>0 then
    -- 带附件的
        return GameConst.MSG_ICON[1]
    else
    -- 普通邮件
        return GameConst.MSG_ICON[2]
    end
end

return MsgModel