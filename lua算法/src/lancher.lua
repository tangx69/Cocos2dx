local targetPlatform = cc.Application:getInstance():getTargetPlatform()
if (0 == targetPlatform) or (2 == targetPlatform) then
    local breakInfoFun,xpcallFun = require("src.LuaDebugjit")("localhost", 7003)
    cc.Director:getInstance():getScheduler():scheduleScriptFunc(breakInfoFun, 0.5, false)
end

local SceneLauncher = require ("src.SceneLauncher")

local director = cc.Director:getInstance()
director:getOpenGLView():setDesignResolutionSize(640, 1136, cc.ResolutionPolicy.SHOW_ALL)

-- 启动场景
local sceneLancher = SceneLauncher.new()
if cc.Director:getInstance():getRunningScene() then
    cc.Director:getInstance():replaceScene(sceneLancher)
else
    cc.Director:getInstance():runWithScene(sceneLancher)
end



