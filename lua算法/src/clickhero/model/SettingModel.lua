---
-- SettingModel     结构 {music = 1,sound = 1}
--@module SettingModel
local SettingModel = {
    _data = nil,
    _musicState = false,
    _soundState = false,
    _bossTimeRemindState = true,
    _noticeRemindState = true,
    dataChangeEventType = "SettingModelDataChange", --{type = ,dataType =}
	fbdataChangeEventType = "SettingModelFBDataChange", --{type = ,dataType =}
    dataType = {
        music = 1,
        sound = 2,
        bossTime = 3,
        notice = 4
    }
}

---
-- @function [parent=#SettingModel] init
-- @param self #SettingModel
-- @param #table data
function SettingModel:init()
    local str = cc.UserDefault:getInstance():getStringForKey("LOCALDATA")
    if str and str ~= "" and str~= "null" then
        self._data = json.decode(str)
    else
        self._data = {music = 0,sound = 0,bossTime = 1}
        cc.UserDefault:getInstance():setStringForKey("LOCALDATA",json.encode(self._data))
    end
    self:_dataState()
end

---
-- @function [parent=#SettingModel] clean
-- @param #SettingModel self
function SettingModel:clean()
    self._data = nil
    self._musicState = nil
    self._soundState = nil
    self._bossTimeRemindState = nil
    self._noticeRemindState = nil
end

function SettingModel:_raiseDataChangeEvent(dataType)
    local evt = {
        type = self.dataChangeEventType,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end

function SettingModel:fbDataChangeEvent()
    local evt = {
        type = self.fbdataChangeEventType,
    }
    zzy.EventManager:dispatch(evt)
end
---
-- 初始化状态
-- @function [parent=#SettingModel] _dataState
-- @param #SettingModel self
-- @return #boolean
function SettingModel:_dataState()
    if self._data["music"] then
        self._musicState = self._data["music"] == 1
        if self._musicState then
            ch.MusicManager:setMusicVolume(0)
        else
            ch.MusicManager:setMusicVolume(1)
        end
    else
        if ch.MusicManager:getMusicVolume() == 0 then
            self._data["music"] = 1
            self._musicState = true
        else
            self._data["music"] = 0
            self._musicState = false
        end
    end
    
    if self._data["sound"] then
        self._soundState = self._data["sound"] == 1
    else
        if self._soundState then
            self._data["sound"] = 1
        else
            self._data["sound"] = 0
        end
    end
    
    if self._data["bossTime"] then
        self._bossTimeRemindState = self._data["bossTime"] == 1
    else
        if self._bossTimeRemindState then
            self._data["bossTime"] = 1
        else
            self._data["bossTime"] = 0
        end
    end
    
    if self._data["notice"] then
        self._noticeRemindState = self._data["notice"] == 1
    else
        if self._noticeRemindState then
            self._data["notice"] = 1
        else
            self._data["notice"] = 0
        end
    end
end


---
-- 背景音乐播放状态
-- @function [parent=#SettingModel] isNoMusicPlaying
-- @param #SettingModel self
-- @return #boolean
function SettingModel:isNoMusicPlaying()
    if ch.MusicManager:getMusicVolume() == 0 then
        self._data["music"] = 1
        self._musicState = true
    else
        self._data["music"] = 0
        self._musicState = false
    end
    return self._musicState
end

---
-- 设置背景音乐播放状态
-- @function [parent=#SettingModel] setMusicState
-- @param #SettingModel self
-- @param #boolean isPlay
function SettingModel:setMusicState(isPlay)
    if isPlay then
        ch.MusicManager:setMusicVolume(1)
        self._data["music"] = 0
        self._musicState = false
    else
        ch.MusicManager:setMusicVolume(0)
        self._data["music"] = 1
        self._musicState = true
    end
    cc.UserDefault:getInstance():setStringForKey("LOCALDATA",json.encode(self._data))
    SettingModel:_raiseDataChangeEvent(self.dataType.music)
end

---
-- 音效播放状态
-- @function [parent=#SettingModel] isNoSoundPlaying
-- @param #SettingModel self
-- @return #boolean
function SettingModel:isNoSoundPlaying()
    return self._soundState
end

---
-- 设置音效播放状态
-- @function [parent=#SettingModel] setSoundState
-- @param #SettingModel self
-- @param #boolean isPlay
function SettingModel:setSoundState(isPlay)
    self._soundState = isPlay
    if isPlay then
        self._data["sound"] = 1
    else
        self._data["sound"] = 0
    end
    cc.UserDefault:getInstance():setStringForKey("LOCALDATA",json.encode(self._data))
    SettingModel:_raiseDataChangeEvent(self.dataType.sound)
end

---
-- 获取绑定的fbid
-- @function [parent=#SettingModel] getfbid
-- @param #SettingModel self
function SettingModel:getfbid()
    if zzy.config.data_sdk_server then
        if zzy.config.data_sdk_server.bind_info then
            for k,v in pairs (zzy.config.data_sdk_server.bind_info) do
				if v.platform=="facebook" then
					return v.open_oid
				end
			end 
		end
	end
	return nil
end

---
-- 设置boss战失败是否继续提示
-- @function [parent=#SettingModel] setBossTimeRemind
-- @param #SettingModel self
-- @param #boolean isRemind
function SettingModel:setBossTimeRemind(isRemind)
    self._bossTimeRemindState = isRemind
    if isRemind then
        self._data["bossTime"] = 1
    else
        self._data["bossTime"] = 0
    end
    cc.UserDefault:getInstance():setStringForKey("LOCALDATA",json.encode(self._data))
    SettingModel:_raiseDataChangeEvent(self.dataType.bossTime)
end

---
-- 获取是否继续提示bossTime
-- @function [parent=#SettingModel] isBossTimeRemind
-- @param #SettingModel self
-- @return #boolean
function SettingModel:isBossTimeRemind()
    return self._bossTimeRemindState
end

---
-- 设置是否继续通知
-- @function [parent=#SettingModel] setNoticeRemind
-- @param #SettingModel self
-- @param #boolean isRemind
function SettingModel:setNoticeRemind(isRemind)
    self._noticeRemindState = isRemind
    if isRemind then
        self._data["notice"] = 1
    else
        self._data["notice"] = 0
    end
    cc.UserDefault:getInstance():setStringForKey("LOCALDATA",json.encode(self._data))
    SettingModel:_raiseDataChangeEvent(self.dataType.notice)
	 local flag= string.sub(zzy.Sdk.getFlag(),1,2)
	if flag=="TJ" then
		 local info={
				f="igaworks",
				data={notice=isRemind}
		  }
		 zzy.Sdk.extendFunc(json.encode(info))
	 end
end

---
-- 获取是否继续通知
-- @function [parent=#SettingModel] isNoticeRemind
-- @param #SettingModel self
-- @return #boolean
function SettingModel:isNoticeRemind()
    return self._noticeRemindState
end


return SettingModel