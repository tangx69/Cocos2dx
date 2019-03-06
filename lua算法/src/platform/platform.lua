zzy.Sdk.Events = {
    initDone="sdk_event_initDone",
    loginDone="sdk_event_loginDone",
    chargeDone="sdk_event_chargeDone",
}

local sdkFlag = cc.libPlatform:getInstance():getFlag()

INFO("[sdkflag=%s]", sdkFlag)

local isUseSdkLogin = false

if "YIJIE" == sdkFlag or "ANYSDK" == sdkFlag then
    if (cc.libPlatform:getInstance():hasUserPugin() == true) then
        isUseSdkLogin = true
    end
end

if isUseSdkLogin then
    zzy.Sdk.PLATFORM_DEFAULT = true
    package.loaded["src.platform.platform_sdk"] = nil --sdk的登录方式,具体是什么sdk,在c++里由宏开关决定
    require "src.platform.platform_sdk"
else
    zzy.Sdk.PLATFORM_DEFAULT = true
    package.loaded["src.platform.platform_default"] = nil --默认游戏自带的登录方式
    require "src.platform.platform_default"
end
