---
-- @module SoundManager
local SoundManager = {
    _cache = {},
    _soundNames = {
        "bianpao",
        "cleantuteng",
        "click",
        "close",
        "daojian1",
        "daojian2",
        "daojian3",
        "daojian4",
        "daojian5",
        "daojian6",
        "daojian7",
        "death11",
        "death12",
        "death13",
        "death14",
        "death15",
        "death16",
        "death17",
        "death18",
        "death19",
        "death21",
        "death22",
        "death23",
        "death24",
        "death25",
        "death_c1",
        "death_c2",
        "death_c3",
        "death_c4",
        "death_c5",
        "death_c6",
        "death_c7",
        "death_c8",
        "death_c9",
        "death_niao",
        "getachieve",
        "getbaowu",
        "getskill",
        "gettuteng",
        "gold1",
        "gold2",
        "gold3",
        "guoguan",
        "huoqiu",
        "levup",
        "shengli",
        "ttlvup",
        "updown"
    }
}

---
-- 预加载音效
--@function [parent=#MusicManager] preload
--@param #MusicManager self
function SoundManager:preload()
    for k,v in pairs(self._soundNames) do
        soundName = string.format("res/sound/sound_%s.wav",v)
        cc.SimpleAudioEngine:getInstance():preloadEffect(soundName)
    end
end

---
-- @function [parent=#SoundManager] play
-- @param #SoundManager self
-- @param #SoundManager soundName
-- @return #int soundId
function SoundManager:play(soundName)
    if not ch.SettingModel:isNoSoundPlaying() then
        soundName = string.format("res/sound/sound_%s.wav",soundName)
        self._cache[soundName] = os_clock()
        return cc.SimpleAudioEngine:getInstance():playEffect(soundName)
    end
end

---
-- @function [parent=#SoundManager] clean
-- @param #SoundManager self
function SoundManager:clean()
    local now = os_clock()
    for key, var in pairs(self._cache) do
        if now - var > 60 then
            cc.SimpleAudioEngine:getInstance():unloadEffect(key)
            self._cache[key] = nil
        end
    end
end


return SoundManager