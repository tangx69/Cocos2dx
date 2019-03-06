local DefendRefreshAI = {
    _enemyInfo = nil,
    _startTime = nil,
}

DefendRefreshAI.__index = DefendRefreshAI

function DefendRefreshAI:create()
    local o = {}
    setmetatable(o,DefendRefreshAI)
    return o
end

function DefendRefreshAI:start()
    local cf = GameConfig.DefendConfig:getData(ch.DefendModel:getCurConfigId())
    self._enemyInfo = {}
    self._startTime = ch.DefendTimer:getGameTime()
    for i= 1,10 do
        local n = "gw"..i
        if cf[n] and cf[n]~= "" then
            local tmp = zzy.StringUtils:split(cf[n],",")
            if #tmp ~= 4 then
                error("defend表，level "..ch.DefendModel:getCurConfigId().."里的 n 错误" )
            end
            local info = {curCount = 0}
            info.gid = tonumber(tmp[1])
            info.startTime = tonumber(tmp[2]) 
            info.intervalTime = tonumber(tmp[3])
            info.totalCount = tonumber(tmp[4])
            table.insert(self._enemyInfo,info)
        else
            break
        end
    end
end

function DefendRefreshAI:update()
    if not self._startTime then return end
    local time = ch.DefendTimer:getGameTime() - self._startTime
    if self._enemyInfo then
        for k,info in ipairs(self._enemyInfo) do
            if info.curCount < info.totalCount and 
                time >= info.startTime + info.intervalTime * info.curCount then
                ch.DefendMap:addEnemy(info.gid)
                info.curCount = info.curCount + 1
            end    
        end
    end
end

function DefendRefreshAI:getTotalEnemyCount()
    local count = 0
    if self._enemyInfo then
        for k,info in ipairs(self._enemyInfo) do
            count = count + info.totalCount 
        end
    end
    return count
end

function DefendRefreshAI:isCompleted()
    if not self._enemyInfo then return false end
    for k,enemyInfo in ipairs(self._enemyInfo) do
        if enemyInfo.curCount ~= enemyInfo.totalCount then
            return false
        end
    end
    return true
end


return DefendRefreshAI