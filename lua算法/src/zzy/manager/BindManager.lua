local bindManager = {}

local bindFunctions = {}
local loadBindFiles = {}

local bindDataFunctions = {}
local bindFixedFunctions = {}

local commonCmd = {}

local configParamFunc = {}

setmetatable(bindFunctions,{__index = function(t, k)
    local file = string.format("src/zzy/uiview/binds/bind_%s", k)
    local func = require(file)
    bindFunctions[k] = func
    table.insert(loadBindFiles, file)
    return func
end})

function bindManager:doConfigBind(widget, config)
    bindFunctions[config.bind](widget, config)
end

function bindManager:doDataBind(csb, widget, data)
	--INFO("[bindManager:doDataBind]csb=%s", csb)
	
    return data and bindDataFunctions[csb] and bindDataFunctions[csb](widget, data)
end

function bindManager:doFixedBind(csb, widget)
    return bindFixedFunctions[csb] and bindFixedFunctions[csb](widget)
end

function bindManager:clean()
    for _, file in pairs(loadBindFiles) do
        package.loaded[file] = nil
    end
    bindFunctions = {}
    loadBindFiles = {}
    bindDataFunctions = {}
    bindFixedFunctions = {}
    commonCmd = {}
    configParamFunc = {}
end

function bindManager:addCustomConfigBind(key, func)
    bindFunctions[key] = func
end

function bindManager:addCustomDataBind(key, func)
    bindDataFunctions[key] = func
end

function bindManager:addCommonCmd(key, func)
    commonCmd[key] = func
end

function bindManager:getCommondCmd(key)
    return commonCmd[key]
end

function bindManager:addFixedBind(key, func)
    bindFixedFunctions[key] = func
end

function bindManager:addConfigParamTransFunc(key, func)
    configParamFunc[key] = func
end

function bindManager:applyConfigParamTrans(widget, config)
    local config = zzy.TableUtils:copy(config)
    local bpIndex = 1
    repeat
        local bpStr = config["bp"..bpIndex]
        local psPos = string.find(bpStr, "%(")
        if psPos then
            local TransName = string.sub(bpStr, 1, psPos - 1)
            if configParamFunc[TransName] then
                local pArr = zzy.StringUtils:split(string.sub(bpStr, psPos + 1, -2), ",")
                config["bp"..bpIndex] = configParamFunc[TransName](widget, bpStr, unpack(pArr))
            end
        end
        bpIndex = bpIndex + 1
    until not config["bp"..bpIndex]
    
    return config
end


-- 全项目通用cmd
bindManager:addCommonCmd("close", function(widget)
    widget:destory()
end)

-- 字符串拼接数据形成新数据  FORMATSTR(%s/%s,num1,num2)
bindManager:addConfigParamTransFunc("FORMATSTR", function(widget, bpStr, format, ...)
    if widget:getDataProxy(bpStr) then return bpStr end
    
    local formatParam = {}
    for index,dataFlag in ipairs({...}) do
        widget:addDataViewer(dataFlag, function(data)
            formatParam[index] = tostring(data)
            widget:noticeDataChange(bpStr)
        end)
    end
    
    widget:addDataProxy(bpStr, function()
        return string.format(format, unpack(formatParam))
    end)
    
    return bpStr
end)



return bindManager
