local tLoginView = require "src.tinygame.tLoginView"

zzy.Sdk.PLATFORM_DEFAULT = true
package.loaded["src.platform.platform_sdk"] = nil --sdk的登录方式,具体是什么sdk,在c++里由宏开关决定
package.loaded["src.platform.platform_default"] = nil --默认游戏自带的登录方式

ch.LoginView = tLoginView.new()

--[[
function zzy.cUtils.getNetString(url,func)
    INFO("[getNetString][SEND]%s", url)
    
    local msg = ""

    if url == "http://gjlogin.hzfunyou.com:27199/ucenter/serverlist" then
        msg = "{\"servers\":\[\{"host":\"115.159.108.177\",\"index\":\"王者5区\",\"name\":\"王者5区\",\"port\":\"27205\",\"status\":1,\"svrid\":3005,\"type\":0}"
    end 

    func(0, msg)
end
]]--
