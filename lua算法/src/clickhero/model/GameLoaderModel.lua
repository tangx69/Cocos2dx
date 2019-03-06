---
-- GameLoaderModel   loading界面
--@module GameLoaderModel
local GameLoaderModel = {
    progressEventType = "GameLoaderModelProgressEventType" ,--{type = ,dataType =}
    loadingTxtChangeEventType = "GameLoaderModelLoadingTxtChangeEventType" ,
    loadingShowChangeEventType = "GameLoaderModelLoadingShowChangeEventType" ,
    versionChangeEventType = "GameLoaderModelVersionChangeEventType" ,
    btnStartShowChangeEventType = "GameLoaderModelBtnShowChangeEventType" ,--开始游戏按钮显示性事件
    btnLoginShowChangeEventType = "GameLoaderModelBtnLoginShowChangeEventType" ,--登陆按钮显示性事件
    startGameEventType = "GameLoaderModelStartGameEventType",
    switchServerEventType = "GameLoaderModelSwitchServerEventType",--切换服务器
    selServerEventType = "GameLoaderModelSelServerEventType",--选择服务器
    selectedSerShowChangeEventType="selectedSerShowChangeEventType",--当前服是否显示
	loadCompletedEvent = "MAIN_LOAD_COMPLETED_EVENT",
	closeNoticeEventType = "closeNoticeEventType", -- 关闭公告
    loading_txt="",
    isShowNotice = false,
    loadingCom=false,--是否预加载完成
    loadingShow=false,--是否显示loadng
    btnStartShow = false, -- 是否显示按钮
    btnLoginShow = false, -- 是否显示登陆按钮
    selectedSerShow = false, -- 是否显示选择的当前服
    processPer={0.4,0.3,0.3},--每个阶段所占的百分比 目前分为3个阶段
    curProcess=0,--当前的阶段
    curPer=0,--当前下载的百分比
    serverList = {},--服务器列表
    showVersion="0.0.0"--显示版本号
}

---
-- 设置loading 的显示
-- @function [parent=#GameLoaderModel] setLoadingShow
-- @param #GameLoaderModel self
-- @param #string show   可见性
function GameLoaderModel:setLoadingShow(show)
    self.loadingShow=show
    local evt = {type = self.loadingShowChangeEventType}
    zzy.EventManager:dispatch(evt)
end
---
-- 获得下载进度
-- @function [parent=#GameLoaderModel] getProgress
-- @param #GameLoaderModel self
-- @return #number
function GameLoaderModel:getProgress()
    return self.curPer
end
---
-- 获取显示版本号
-- @function [parent=#GameLoaderModel] getShowVersion
-- @param #GameLoaderModel self
-- @return #string rect
function GameLoaderModel:getShowVersion()
    return self.showVersion
end
---
-- 设置显示版本号
-- @function [parent=#GameLoaderModel] setShowVersion
-- @param #GameLoaderModel self
-- @param #number version 显示版本号
function GameLoaderModel:setShowVersion(version)
    self.showVersion=version
    local evt = {
        type = self.versionChangeEventType,
    }
    zzy.EventManager:dispatch(evt)

end
---
-- 设置下载进度
-- @function [parent=#GameLoaderModel] setProgress
-- @param #GameLoaderModel self
-- @param #number per 百分比
function GameLoaderModel:setProgress(per)
    self.curPer=per
    if self.curProcess~=0 then
        local basePer=0
        if self.curProcess~=1 then
            for i=2,self.curProcess do
                basePer=basePer+self.processPer[i-1]
            end
        end
        self.curPer=basePer+per*self.processPer[self.curProcess]
    end
    local evt = {
        type = self.progressEventType,
    }
    zzy.EventManager:dispatch(evt)
end


---
-- 获取加载条上的文字显示
-- @function [parent=#GameLoaderModel] getLoadingTxt
-- @param #GameLoaderModel self
-- @return #string
function GameLoaderModel:getLoadingTxt()
    --    return self.loading_txt..(self.curPer*100).."%"
    return self.loading_txt
end

---
-- 设置加载条上的文字显示
-- @function [parent=#GameLoaderModel] setLoadingTxt
-- @param #GameLoaderModel self
-- @param #string txt   文字
function GameLoaderModel:setLoadingTxt(txt)
    self.loading_txt=txt
    local evt = {type = self.loadingTxtChangeEventType}
    zzy.EventManager:dispatch(evt)
end

---
-- 设置开始游戏按钮显示
-- @function [parent=#GameLoaderModel] setBtnStartVis
-- @param #GameLoaderModel self
-- @param #boolean vis
function GameLoaderModel:setBtnStartVis(vis)
    self.btnStartShow = vis
    local evt = {type = self.btnStartShowChangeEventType}
    zzy.EventManager:dispatch(evt)
end


---
-- 设置登陆按钮按钮显示
-- @function [parent=#GameLoaderModel] setBtnLoginVis
-- @param #GameLoaderModel self
-- @param #boolean vis
function GameLoaderModel:setBtnLoginVis(vis)
    self.btnLoginShow = vis
    local evt = {type = self.btnLoginShowChangeEventType}
    zzy.EventManager:dispatch(evt)
end

---
-- 设置当前服的显示
-- @function [parent=#GameLoaderModel] setSelectedSerShow
-- @param #GameLoaderModel self
-- @param #boolean vis
function GameLoaderModel:setSelectedSerShow(vis)
    self.selectedSerShow = vis
    local evt = {type = self.selectedSerShowChangeEventType}
    zzy.EventManager:dispatch(evt)
end

---
-- 获取可用的svrid列表  0=公网正常服务器，2审批服，3=公网测服，4=公网待开新服  5开发服务器  
-- @function [parent=#GameLoaderModel] getSvridList
-- @param #GameLoaderModel self
-- @param #table 
function GameLoaderModel:getSvridList()
    local svrList={}
    for k,v in ipairs(self.serverList) do 
        if zzy.config.check then
            if v.type==2 then
                table.insert(svrList,k) 
            end
        else
            if zzy.config.debugMode==1 then
                --测试环境
                if v.type==3 then
                    table.insert(svrList,k) 
                end
                --正式环境
                if v.type==0 then
                    table.insert(svrList,k) 
                end
                --开发环境
                if v.type==5 then
                    table.insert(svrList,k) 
                end
            else
                --release包  只能看到公网服
                if v.type==0 then
                    table.insert(svrList,k) 
                end
            end
       end
       --是否显示开发的服务器
--        if zzy.config.showDevSer then
--            if v.type==5 then
--                table.insert(svrList,k) 
--            end
--       end
       
       --是否是测试员  测试员可以看到公网待开新服
       if tonumber(ch.PlayerModel.usertype) >0 then
            if v.type==4 then
                table.insert(svrList,k) 
            end
       end
        
    end
    return svrList
end

---
-- 获取最近登录服务器列表
-- @function [parent=#GameLoaderModel] getLastlySvridList
-- @param #GameLoaderModel self
-- @param #table 
function GameLoaderModel:getLastlySvridList()
    local info ={}
    if zzy.config.loginsvr~="" then
        local lastServerInfo=zzy.StringUtils:split(zzy.config.loginsvr,",") 
        for k,v in pairs (lastServerInfo) do
            local ind=self:getServerIndBySvrid(v)
            if ind ~=nil then
			     local server= self:getServerInfoByInd(ind)
				 if server.type~=2 then
					table.insert(info,ind)
				end
            end
        end
    end
    return info
end

---
-- 通过索引获取某个服务器的信息
-- @function [parent=#GameLoaderModel] getServerInfoByInd
-- @param #GameLoaderModel self
-- @param #string ind
function GameLoaderModel:getServerInfoByInd(ind)
    local info ={}
    if ind  then
        if ind~="last1" and ind~="last2" then 
            info = self.serverList[ind]
        else
			if zzy.config.loginsvr~="" then
                local lastServerInfo=zzy.StringUtils:split(zzy.config.loginsvr,",")
				local curServerInd
				if ind=="last1"then 
					curServerInd=ch.GameLoaderModel:getServerIndBySvrid(lastServerInfo[1])
				elseif ind=="last2" then
					curServerInd=ch.GameLoaderModel:getServerIndBySvrid(lastServerInfo[2])
				end
				if curServerInd then
                    info = self.serverList[curServerInd]
                end
			end
            -- info={host="192.168.100.109",svrid="qmsj0001",port=16001,name="开发1区"..aa,index="1区",status=1,type=0}
        end
    end
    return info
end



---
-- 通过svrid获取索引
-- @function [parent=#GameLoaderModel] getServerIndBySvrid
-- @param #GameLoaderModel self
-- @param #string svrid
function GameLoaderModel:getServerIndBySvrid(svrid)
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
        return self:getServerIndBySvrid_windows(svrid)
    end

    local ind=nil
    for k,v in pairs(self.serverList) do
        if v.svrid == svrid then
            ind = k
            break
        end    
    end
    return ind
end

---
-- 通过svrid获取索引
-- @function [parent=#GameLoaderModel] getServerIndBySvrid
-- @param #GameLoaderModel self
-- @param #string svrid
function GameLoaderModel:getServerIndBySvrid_windows(svrid)
    local ind=nil
    for k,v in pairs(self.serverList) do
        if v.svrid == svrid then
            ind = k
            --break
        end    
    end
    return ind
end

---
-- 通过svrid获取server信息
-- @function [parent=#GameLoaderModel] getServerBySvrid
-- @param #GameLoaderModel self
-- @param #string svrid
function GameLoaderModel:getServerBySvrid(svrid)
    
    local ind=nil
    for k,v in pairs(self.serverList) do
        if v.svrid == svrid then
            ind = k
            break
        end    
    end
    if ind then
        return  self:getServerInfoByInd(ind)
    end
    return {}
end

---
-- 开始游戏
-- @function [parent=#GameLoaderModel] startGame
-- @param #GameLoaderModel self
function GameLoaderModel:startGame()
    local evt = {type = self.startGameEventType}
    zzy.EventManager:dispatch(evt)
end

return GameLoaderModel