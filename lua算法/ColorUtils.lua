local colorUtils = {}

function colorUtils:getSilderColor(c1, c2, ratio)
    local newC = {}
    for _, vn in ipairs({"r","g","b","a"}) do
    	if c1[vn] then
            newC[vn] = c1[vn] + (c2[vn] - c1[vn]) * ratio
    	end
    end
    return newC
end


return colorUtils