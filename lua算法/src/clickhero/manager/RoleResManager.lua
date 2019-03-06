local roleRes = {}

--setmetatable(RoleResManager, {__index = ch.RoleResManager2})

function roleRes:load(roleName, callBack)
    if ch.CommonFunc:useSpine(string.format("role_%s", roleName)) then
        self:_loadSpine(roleName,callBack)
        return
    end
   
    if cc.FileUtils:getInstance():isFileExist(string.format("res/role/role_%s.ExportJson", roleName)) then
        self:_loadJson(roleName,callBack)
    else
        self:_loadXml(roleName,callBack)
    end
end

function roleRes:release(roleName)
    if ch.CommonFunc:useSpine(string.format("role_%s", roleName)) then
        self:_releaseSpine(roleName, true)
        return
    end

    if cc.FileUtils:getInstance():isFileExist(string.format("res/role/role_%s.ExportJson", roleName)) then
        self:_releaseJson(roleName,true)
    else
        self:_releaseXml(roleName,true)
    end
end

function roleRes:loadEffect(effect, callBack)
    if cc.FileUtils:getInstance():isFileExist(string.format("res/effect/effect_%s.ExportJson", effect)) then
        self:_loadEffectJson(effect,callBack)
    else
        self:_loadEffectXml(effect,callBack)
    end
end

function roleRes:releaseEffect(effect)
    if cc.FileUtils:getInstance():isFileExist(string.format("res/effect/effect_%s.ExportJson", effect)) then
        self:_releaseJson(effect,false)
    else
        self:_releaseXml(effect,false)
    end
end

function roleRes:_loadXml(roleName, callBack)
    cc.Director:getInstance():getTextureCache():addImage(
        string.format("res/role/role_%s.png", roleName),
        function(tex)
            -- tex:retain()
            cc.SpriteFrameCache:getInstance():addSpriteFrames(string.format("res/role/role_%s.plist", roleName))
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(string.format("res/role/role_%s.xml", roleName))
            if callBack then callBack(roleName) end
        end)
end

function roleRes:_loadJson(roleName, callBack)
    local fileName = string.format("res/role/role_%s.ExportJson", roleName)
    local fileContent = zzy.ExportJsonHelper:getInfo(fileName)
    local count = #fileContent.png
    local index = 0
    for _,v in ipairs(fileContent.png) do
        cc.Director:getInstance():getTextureCache():addImage(
            string.format("res/role/%s",v),function(tex)
                index = index + 1
                if index == count then
                    for _,v in ipairs(fileContent.plist) do
                        local name = string.format("res/role/%s",v)
                        cc.SpriteFrameCache:getInstance():addSpriteFrames(name)
                    end
                    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(fileName)
                    if callBack then callBack(roleName) end
                end
            end)
    end
end

function roleRes:_loadEffectXml(effect, callBack)
    if callBack then
        cc.Director:getInstance():getTextureCache():addImage(
            string.format("res/effect/effect_%s.png", effect),
            function(tex)
              --  tex:retain()
                cc.SpriteFrameCache:getInstance():addSpriteFrames(string.format("res/effect/effect_%s.plist", effect))
                ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(string.format("res/effect/effect_%s.xml", effect))
                callBack(effect)
            end)
    else
        if not cc.Director:getInstance():getTextureCache():getTextureForKey(string.format("res/effect/effect_%s.png", effect)) then
            cc.SpriteFrameCache:getInstance():addSpriteFrames(string.format("res/effect/effect_%s.plist", effect))
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(string.format("res/effect/effect_%s.xml", effect))
        end
    end
end

function roleRes:_loadEffectJson(effect,callBack)
    local fileName = string.format("res/effect/effect_%s.ExportJson", effect)
    local fileContent = zzy.ExportJsonHelper:getInfo(fileName)
    if callBack then
        local count = #fileContent.png
        local index = 0
        for _,v in ipairs(fileContent.png) do
            cc.Director:getInstance():getTextureCache():addImage(
                string.format("res/effect/%s",v),function(tex)
                    index = index + 1
                    if index == count then
                        for _,v in ipairs(fileContent.plist) do
                            local name = string.format("res/effect/%s",v)
                            cc.SpriteFrameCache:getInstance():addSpriteFrames(name)
                        end
                        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(fileName)
                        callBack(effect)
                    end
                end)
        end
    else
        for k,v in ipairs(fileContent.plist) do
            cc.SpriteFrameCache:getInstance():addSpriteFrames(string.format("res/effect/%s",v))
        end
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(fileName)
    end
end

function roleRes:_releaseXml(roleName,isRole)
    local basePath = isRole and "res/role/role" or "res/effect/effect"
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(string.format("%s_%s.xml", basePath, roleName))
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(string.format("%s_%s.plist", basePath, roleName))
    cc.Director:getInstance():getTextureCache():removeTextureForKey(string.format("%s_%s.png", basePath, roleName))
end

function roleRes:_releaseJson(roleName,isRole)
    local basePath = isRole and "res/role/role" or "res/effect/effect"
    local fileName = string.format("%s_%s.ExportJson",basePath, roleName)
    local fileContent = zzy.ExportJsonHelper:getInfo(fileName)
    basePath = isRole and "res/role" or "res/effect"
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(fileName)
    for k,v in ipairs(fileContent.plist) do
        cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(string.format("%s/%s",basePath,v))
    end
    for k,v in ipairs(fileContent.png) do
        cc.Director:getInstance():getTextureCache():removeTextureForKey(string.format("%s/%s",basePath,v))
    end
end

function roleRes:_loadSpine(roleName, callBack)
    local roleAtlas = string.format( "res/spine/role_%s.atlas", roleName)
    local atlasFileStr = cc.FileUtils:getInstance():getStringFromFile(roleAtlas)
    local pngName = string.match(atlasFileStr, "[^%c]+png")
    --DEBUG("[roleRes:_loadSpine]"..pngName)
    cc.Director:getInstance():getTextureCache():addImage(
        string.format("res/spine/%s", pngName),
        function(tex)
            --DEBUG("[roleRes:callback]"..pngName)
            if callBack then callBack(roleName) end
        end)
end

function roleRes:_releaseSpine(roleName,isRole)
    --DEBUG("[roleRes:_releaseSpine]"..roleName)
    local basePath = "res/spine/"
    local roleAtlas = isRole and string.format("%srole_%s.atlas",basePath, roleName) or string.format("%seffect_%s.atlas",basePath, roleName)
    local atlasFileStr = cc.FileUtils:getInstance():getStringFromFile(roleAtlas)
    local pngName = string.match(atlasFileStr, "[^%c]+png")
    local pngPathName = string.format("%s%s",basePath, pngName)
    DEBUG("[roleRes:_releasePng]"..pngPathName)
    cc.Director:getInstance():getTextureCache():removeTextureForKey(pngPathName)
end

function roleRes:_loadEffectSpine(effect,callBack)
    local fileName = string.format("res/spine/effect_%s.ExportJson", effect)
    local fileContent = zzy.ExportJsonHelper:getInfo(fileName)
    if callBack then
        local count = #fileContent.png
        local index = 0
        for _,v in ipairs(fileContent.png) do
            cc.Director:getInstance():getTextureCache():addImage(
                string.format("res/spine/%s",v),function(tex)
                    index = index + 1
                    if index == count then
                        for _,v in ipairs(fileContent.plist) do
                            local name = string.format("res/effect/%s",v)
                            cc.SpriteFrameCache:getInstance():addSpriteFrames(name)
                        end
                        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(fileName)
                        callBack(effect) 
                    end
                end)
        end
    else
        for k,v in ipairs(fileContent.plist) do
            cc.SpriteFrameCache:getInstance():addSpriteFrames(string.format("res/effect/%s",v))
        end
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(fileName)
    end
end

return roleRes