local aiConfig = {}
aiConfig.bossStartAtkTime = 0


function aiConfig:getSkill(roleName, skills)
    if not skills or #skills == 0 then return end
    
    local canUseSkills = {}
    local totalW = 0
    
    for _, opt in ipairs(skills) do
        local atkConfig = GameConst.MAIN_ROLE_SKILL_CONFIG.nanzhanshi[opt[1]]
        local enemys = ch.fightRoleLayer:getEnemyRoles(atkConfig.te[1])
        if table.maxn(enemys) >= atkConfig.te[2] then
            table.insert(canUseSkills, opt)
            totalW = totalW + opt[2]
        end
    end
    
    if totalW == 0 then return end
    
    local rand = math.random(0, totalW-1)
    for _, opt in ipairs(canUseSkills) do
        rand = rand - opt[2]
        if rand < 0 then
            return opt[1]
        end
    end
end


aiConfig.mainDefault = function(role)
    local state = ch.LevelController:getState()
    --DEBUG("[aiConfig.mainDefault]getState=%d", state)

    if state == 1 then
        return role:moveAd(220+role.config.w, 0)
    end
--    local enemies = ch.fightRoleLayer:getEnemies()
--    if enemies and #enemies > 1 then
--        local enemy = nil
--        local distance = 99999999999999
--        for k,v in ipairs(enemies) do
--            if v:getPositionX()<role:getPositionX() then
--                local dis = math.abs(v:getPositionX()-role:getPositionX())
--                if dis<distance then
--                    distance = dis
--                    enemy = v
--                end
--            end
--        end
--        if enemy then
--           return role:moveAd(enemy:getPositionX(), enemy.config.w)
--        end
--    end
    
    local useSkill = aiConfig:getSkill(role.roleName, GameConst.MAIN_ROLE_SKILL_START_INDEXS.nanzhanshi)
    if useSkill and aiConfig.bossStartAtkTime < os_clock() then
        role:attack(useSkill)
    else
        local enemys = ch.fightRoleLayer:getEnemyRoles(599999)
        local count = #enemys
        if count > 0 then
            local enemy = enemys[1]
            for i = 2,count do
                if enemys[i]:getPositionX() < enemy:getPositionX() then
                    enemy = enemys[i]
                end
            end
            role:moveAd(enemy:getPositionX(), enemy.config.w)
        else
            role:playStand()
        end
    end
end


--aiConfig.nvfashi = function(role)
--    self.mainDefault(role)
--end
--
--aiConfig.nanzhanshi = function(role)
--    self.mainDefault(role)
--end

aiConfig.default = function(role)
    local mainRole = ch.fightRoleLayer:getMainRole()
    if mainRole then
        local minX = mainRole:getPositionX() + mainRole.config.w + role.config.w
        if role:getPositionX() < minX then
            return role:setPositionX(minX)
        end
        role:moveAd(mainRole:getPositionX(), mainRole.config.w) 
    end
end

return aiConfig