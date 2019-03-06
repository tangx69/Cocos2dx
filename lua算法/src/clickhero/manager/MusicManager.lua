---
-- @module MusicManager
local MusicManager = {
    _musicNames = {bg1 = "stage1st.mp3",bg2 = "stage2st.mp3",boss = "boss.mp3"},
}

---
-- 预加载背景音乐
--@function [parent=#MusicManager] preload
--@param #MusicManager self
function MusicManager:preload()
    for k,v in pairs(self._musicNames) do
        cc.SimpleAudioEngine:getInstance():preloadMusic(string.format("res/music/%s",v))
    end
end

---
-- 播放普通关背景音乐
-- @function [parent=#MusicManager] playCommonBGMusic
-- @param #MusicManager self
-- @param #bool isLoop 默认为循环播放
function MusicManager:playCommonBGMusic(isLoop)
    if isLoop == nil then
        isLoop = true
    end
    local b = math.random(1,2)
    local name = b==1 and  self._musicNames.bg1 or self._musicNames.bg2
    cc.SimpleAudioEngine:getInstance():playMusic(string.format("res/music/%s",name),isLoop)
end

---
-- 播放boss关背景音乐
-- @function [parent=#MusicManager] playBossBGMusic
-- @param #MusicManager self
-- @param #bool isLoop 默认为循环播放
function MusicManager:playBossBGMusic(isLoop)
    if isLoop == nil then
        isLoop = true
    end
    cc.SimpleAudioEngine:getInstance():playMusic(string.format("res/music/%s",self._musicNames.boss),isLoop)
end

---
-- 暂停播放背景音乐
-- @function [parent=#MusicManager] pauseMusic
-- @param #MusicManager self
function MusicManager:pauseMusic()
    cc.SimpleAudioEngine:getInstance():pauseMusic()
end

---
-- 恢复播放背景音乐
-- @function [parent=#MusicManager] resumeMusic
-- @param #MusicManager self
function MusicManager:resumeMusic()
    cc.SimpleAudioEngine:getInstance():resumeMusic()
end

---
-- 停止播放背景音乐
--@function [parent=#MusicManager] stopMusic
--@param #MusicManager self
function MusicManager:stopMusic()
    cc.SimpleAudioEngine:getInstance():stopMusic()
end

---
-- 播放背景音乐音量
--@function [parent=#MusicManager] getMusicVolume
--@param #MusicManager self
--@return #number
function MusicManager:getMusicVolume()
    return cc.SimpleAudioEngine:getInstance():getMusicVolume()
end

---
-- 设置背景音乐音量
--@function [parent=#MusicManager] setMusicVolume
--@param #MusicManager self
--@param #number value
function MusicManager:setMusicVolume(value)
    cc.SimpleAudioEngine:getInstance():setMusicVolume(value)
end

return MusicManager