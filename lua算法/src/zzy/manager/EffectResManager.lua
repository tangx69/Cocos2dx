---
-- 特效资源管理
--@module EffectResManager

local EffectResManager = {
    _resName = {},
    _releaseName = {},
}

---
-- 加载资源
-- @function [parent=#EffectResManager] loadResource
-- @param #EffectResManager self
-- @param #string name
-- @param #function callBack
function EffectResManager:loadResource(name,callBack)
    if not string.find(name,"/") then
        name = string.format("res/effect/%s", name)
    end
    self._resName[name] = self._resName[name] or 0
    if self._resName[name] > 0 then
        self._resName[name] = self._resName[name] + 1
        if callBack then callBack() end
    else
        if cc.FileUtils:getInstance():isFileExist(name..".ExportJson") then
            self:_loadJsonResource(name,callBack)
        else
            self:_loadXmlResource(name,callBack)
        end
    end
end

---
-- 卸载资源
-- @function [parent=#EffectResManager] releaseResource
-- @param #EffectResManager self
-- @param #string name
-- @param #bool isReal
-- @param #number count
function EffectResManager:releaseResource(name,isReal,count)
    if not string.find(name,"/") then
        name = string.format("res/effect/%s", name)
    end
    if not self._resName[name] then return end
    count = count or 1
    if self._resName[name] == 0 then --正经加载资源，确要释放
        self._releaseName[name] = isReal
    end
    self._resName[name] = self._resName[name] - count
    if self._resName[name] <= 0 then
        self._resName[name] = nil
        if isReal == nil then isReal = true end
        if isReal then
            if cc.FileUtils:getInstance():isFileExist(string.format("%s.ExportJson", name)) then
                self:_releaseJsonResource(name)
            else
                self:_releaseXmlResource(name)
            end
        end
    end
end

function EffectResManager:_loadXmlResource(name,callBack)
    if callBack then
        cc.Director:getInstance():getTextureCache():addImage(
            string.format("%s.png", name),
            function(tex)
                cc.SpriteFrameCache:getInstance():addSpriteFrames(string.format("%s.plist", name))
                ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(string.format("%s.xml", name))
                if self._resName[name] then
                    self._resName[name] = self._resName[name] + 1
                    callBack()
                else
                    if self._releaseName[name] then
                        self:_releaseXmlResource(name)
                        self._releaseName[name] = nil
                    end    
                end
            end)
    else
        cc.SpriteFrameCache:getInstance():addSpriteFrames(string.format("%s.plist", name))
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(string.format("%s.xml", name))
        self._resName[name] = self._resName[name] + 1
    end
end

local getBasePath = function(str)
	local basePath = ""
    local path = zzy.StringUtils:split(str,"/")
    for k, v in ipairs(path) do
        if k ~= #path then
            basePath = basePath..v.."/"
        end
    end
    return basePath
end

function EffectResManager:_loadJsonResource(name,callBack)
    local basePath = getBasePath(name)
    local fileName = string.format("%s.ExportJson", name)
    local fileContent = zzy.ExportJsonHelper:getInfo(fileName)
    if callBack then
        local index = 0
        local count = #fileContent.png
        for _,v in ipairs(fileContent.png) do
        cc.Director:getInstance():getTextureCache():addImage(
                basePath..v,function(tex)
                index = index + 1
                if index == count then
                    for _,v in ipairs(fileContent.plist) do
                        local name = basePath..v
                        cc.SpriteFrameCache:getInstance():addSpriteFrames(name)
                    end
                    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(fileName)
                    if self._resName[name] then
                        self._resName[name] = self._resName[name] + 1
                        callBack()
                    else
                        if self._releaseName[name] then
                            self:_releaseJsonResource(name)
                            self._releaseName[name] = nil
                        end    
                    end
                end
            end)
        end
    else
        for k,v in ipairs(fileContent.plist) do
            cc.SpriteFrameCache:getInstance():addSpriteFrames(basePath..v)
        end
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(fileName)
        self._resName[name] = self._resName[name] + 1
    end
end

function EffectResManager:_releaseXmlResource(name)
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(string.format("%s.xml", name))
    cc.Director:getInstance():getTextureCache():removeTextureForKey(string.format("%s.png", name))
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(string.format("%s.plist", name))
end

function EffectResManager:_releaseJsonResource(name)
    local basePath = getBasePath(name)
    local fileName = string.format("%s.ExportJson", name)
    local fileContent = zzy.ExportJsonHelper:getInfo(fileName)
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(fileName)
    for k,v in ipairs(fileContent.plist) do
        cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(basePath..v)
    end
     for k,v in ipairs(fileContent.png) do
        cc.Director:getInstance():getTextureCache():removeTextureForKey(basePath..v)
    end
    
--    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(fileName)
--    local count = 0
--    for k,v in ipairs(fileContent.plist) do
--        cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFileAsync(basePath..v,function()
--            count = count + 1
--            if count == #fileContent.plist then
--                for k,v in ipairs(fileContent.png) do
--                    cc.Director:getInstance():getTextureCache():removeTextureForKey(basePath..v)
--                end 
--            end
--        end)
--    end
end
 
return EffectResManager