
att_name={
[1]="max_hp", --1最大血量
[2]="hp", --2当前血量
[3]="damage", -- 3攻击
[4]="cs",--4暴击
[5]="defence",--5防御
[6]="dodge",--6闪避
[7]="csm",--7暴击率
[8]="defm",--8免伤率
[9]="dgm",--9闪避率
[10]="tdg",--10潜在伤害
[11]="csd",--11暴击倍率
[12]="hprate",--12血量比例
}

-- 卡牌技能数据
card_skill = {
-- id=[...]
} 

function init()
  card_skill = loadcsv("cardskill")
end
