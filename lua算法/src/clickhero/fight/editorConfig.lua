local editorConfig = {}
local configData
local savePath

-- mac、win32可保存
if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
    savePath = "d:/editor.json"
elseif cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_MAC then
    savePath = "/Users/Shared/editor.json"
end
-- 优先读取编辑器保存的
local readData
if savePath then
    local f = io.open(savePath)
    if f then
        io.input(f)
        readData = io.read()
        if readData and string.len(readData) > 0 then
            configData = json.decode(readData)
        end
    end
end
-- 读取res里的配置
if not configData then
    local readData = cc.FileUtils:getInstance():getStringFromFile("res/editor.json")
    if readData and string.len(readData) > 0 then
        configData = json.decode(readData)
    else
        configData = {}
    end
end

local function doSave()
    if savePath then
        local saveStr = json.encode(configData)
        io.output(savePath)
        io.write(saveStr)
    end
end


function editorConfig:getSceneConfig(sceneName)
    return configData.scene and configData.scene[sceneName] or {
        sky = {h = 300,s = 0.2,o = 300},
        mon = {h = 300,s = 0.5,o = 150},
        frt = {h = 200,s = 1,o = 0}
    }
end

function editorConfig:getSceneGlobalConfig()
    return configData.scene and configData.scene.global or {
        baseh = 400,
        roleh = 500,
        maxOffsetX = 260,
        baseFllowSpeed = 10,
        fllowSpeedA = 1000,
        offsetX = 100
    }
end

function editorConfig:getRoleConfig(roleName)
    return configData.role and configData.role[roleName] or {w=30, s=10, d="", c=1}
end

function editorConfig:saveRoleConfig(roleName, w, s, d, c)
    configData.role = configData.role or {}
    configData.role[roleName] = {w = tonumber(w) or 30, s = tonumber(s) or 10, d = d or "", c = tonumber(c) or 1}
    doSave()
end

function editorConfig:saveSceneConfig(sceneName, sky, mon, frt)
    configData.scene = configData.scene or {}
    configData.scene[sceneName] = {
        img = sceneName,
        sky = {h = tonumber(sky[1]) or 0, s = tonumber(sky[2]) or 0,o = tonumber(sky[3]) or 0},
        frt = {h = tonumber(frt[1]) or 0, s = tonumber(frt[2]) or 0,o = tonumber(frt[3]) or 0},
        mon = {h = tonumber(mon[1]) or 0, s = tonumber(mon[2]) or 0,o = tonumber(mon[3]) or 0}
    }
    doSave()
end

function editorConfig:saveSceneGlobalConfig(data)
    configData.scene = configData.scene or {}
    configData.scene.global = configData.scene.global or {}
    configData.scene.global.baseh = tonumber(data.baseh) or 400
    configData.scene.global.roleh = tonumber(data.roleh) or 500
    configData.scene.global.maxOffsetX = tonumber(data.maxOffsetX) or 260
    configData.scene.global.offsetX = tonumber(data.offsetX) or 100
    configData.scene.global.baseFllowSpeed = tonumber(data.baseFllowSpeed) or 10
    configData.scene.global.fllowSpeedA = tonumber(data.fllowSpeedA) or 1000
    doSave()
end



return editorConfig