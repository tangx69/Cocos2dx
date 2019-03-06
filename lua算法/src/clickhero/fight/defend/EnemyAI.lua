local EnemyAI = {
}

---
-- 坚守阵地敌人AI
-- @function [parent=#EnemyAI] update
-- @param #EnemyAI self
-- @param #DefendEnemy enemy
-- @param #number dt
function EnemyAI:update(enemy)
    if enemy:getState() == 1 then
        local distance = enemy:getSpeed() * ch.DefendTimer:getDeltaTime()
        enemy:move(-distance)
    end
end

return EnemyAI