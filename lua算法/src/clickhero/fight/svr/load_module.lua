_M = {}

local function load_m(module_tb,module_name)
    local module_file = "src/clickhero/fight/svr/".. module_name..".lua"
	local _g = {}
	setmetatable(_g, {__index = _G})
    setfenv(0, _g)
    require(module_file)
    setfenv(0, _G)
    package.loaded[module_file] = nil
	
	rawset(_M,module_name,_g)
	return _g
end

setmetatable(_M, {__index = function(tb,k) --print(k) 
	return load_m(tb,k)
end})

function load(module_name)
	return _M[module_name]
end

return _M