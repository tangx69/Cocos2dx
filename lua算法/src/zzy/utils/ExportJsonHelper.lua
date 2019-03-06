---
-- 骨骼动画
-- @module ExportJsonHelper

local ExportJsonHelper = {
    cacheData = {}
}

local preLoadList = {
}

---
-- 加载进来所有ExportJson
-- @function [parent=#ExportJsonHelper] init
-- @param #ExportJsonHelper self
function ExportJsonHelper:init()
    for k,v in ipairs(preLoadList) do
        self:_loadJson(v)
    end
end

---
-- 获得缓存的json信息
-- @function [parent=#ExportJsonHelper] getInfo
-- @param #ExportJsonHelper self
-- @param #string file 
-- @return #table
function ExportJsonHelper:getInfo(file)
    if not self.cacheData[file] then
        local fileName = zzy.StringUtils:split(file,"/")[3]
        fileName = zzy.StringUtils:split(fileName,"%.")[1]
        if EJJson[fileName] then
           self.cacheData[file] = EJJson[fileName]
        elseif not self:_loadJson(file) then 
           error(string.format("没有该文件:%s",file)) 
        end
	end
    return self.cacheData[file]
end

---
-- 加载文件的json
-- @function [parent=#ExportJsonHelper] _loadJson
-- @param #ExportJsonHelper self
-- @param #string fileName
-- @return #bool
function ExportJsonHelper:_loadJson(fileName)
    local str = cc.FileUtils:getInstance():getStringFromFile(fileName)
    if str and str ~= "" then
        local fc = json.decode(str)
        self.cacheData[fileName] = {plist = fc.config_file_path,png = fc.config_png_path}
        return true
    end
    return false
end



return ExportJsonHelper