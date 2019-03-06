local TapCruch = class("TapCruch", function()
	local obj = cc.Layer:create()
    return obj
end)

function TapCruch:ctor()
    self.mainUI = cc.CSLoader:createNode("res/ui/Shop/xxx.csb")

    self:addChild(self.mainUI)
end

-- 游戏渲染开始
function TapCruch:init(gameScene)
    self:goinGame()
end

---
-- 进入游戏界面
-- @function [parent=#TapCruch] goinGame
-- @param #TapCruch self
function TapCruch:goinGame()
    INFO("[%s]", "TapCruch:goinGame")
    
    ch.GameLoaderModel.loadingCom = true
    zzy.TimerUtils:setTimeOut(0,function()
        if ch.guide.firstIn then
            ch.LevelController:init(false)
        else
            ch.LevelController:init(true)
        end
        --                                ch.UIManager:getActiveSkillLayer():addChild(zzy.uiViewBase:new("MainScreen/W3_Skill"))
        ch.UIManager:addActiveSkillView()
        ch.UIManager:addMainView()
        zzy.EventManager:dispatch({type = ch.GameLoaderModel.loadCompletedEvent})

        zzy.TimerUtils:setTimeOut(0, function()
            cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("res/ui/loading/loadingPlist.plist")
        end)
    end)
end


return TapCruch