local CBaseObj = require "src.clickhero.utils.baseobj"

CRandom = CBaseObj:Class()
CRandom.MBIG = 0x7fffffff; -- //0111 1111 1111 1111 1111 1111 1111 1111
CRandom.MSEED = 0x9a4ec86; -- //0000 1001 1010 0100 1110 1100 1000 0110
CRandom.MZ = 0;

function CRandom:OnNew(p_nSeed)
    self.m_aSeedArray = {}
    local num2 = 0x9a4ec86 - math.abs(p_nSeed);
    self.m_aSeedArray[0x37] = num2;
    local num3 = 1;

    for i = 1, 0x37-1 do

        local index = (0x15 * i) % 0x37;
        self.m_aSeedArray[index] = num3;
        num3 = num2 - num3;
        if (num3 < 0) then

            num3 = num3 + 0x7fffffff;
        end
        num2 = self.m_aSeedArray[index];
    end

    for  j = 1, 5-1 do

        for  k = 1,0x38-1 do

            self.m_aSeedArray[k] = self.m_aSeedArray[k] - self.m_aSeedArray[1 + ((k + 30) % 0x37)];
            if (self.m_aSeedArray[k] < 0) then

                self.m_aSeedArray[k] = self.m_aSeedArray[k] + 0x7fffffff;
            end
        end
    end -- //传入相同的Seed，将得到同样的SeedArray

    self.m_nInext = 0;
    self.m_nInextp = 0x15;
    --p_nSeed = 1;
end




function CRandom:_internalSample()

    local index = self.m_nInext;
    local inextp = self.m_nInextp;
    index = index +1;
    if (index >= 0x38) then

        index = 1;
    end
    inextp = inextp +1;
    if (inextp >= 0x38) then

        inextp = 1;
    end

    local num = self.m_aSeedArray[index] - self.m_aSeedArray[inextp];
    if (num < 0) then

        num = num + 0x7fffffff;
    end
    self.m_aSeedArray[index] = num;
    self.m_nInext = index;
    self.m_nInextp = inextp;
    return num;
end



function CRandom:nextInt()

    return self:_internalSample();
end