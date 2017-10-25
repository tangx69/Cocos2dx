local fileUtils = {}

local getFileNameFormLine
local getFilesCmdFunc
if cc.PLATFORM_OS_WINDOWS == cc.Application:getInstance():getTargetPlatform() then
    getFilesCmdFunc = function(p1, p2)
        p1 = string.gsub(p1, "/", "\\")
        p2 = string.gsub(p2, "/", "\\")
        return string.format("dir %s >%s", p1, p2)
    end
    getFileNameFormLine = function(line)
    	if string.len(line) < 2 then return nil end
    	if string.sub(line, 1, 1) == " " then return nil end
        local arr = zzy.StringUtils:split(line, " ")
        return arr[#arr]
    end
else
    getFilesCmdFunc = function(p1, p2)
        return string.format("ls %s >%s", p1, p2)
    end
    getFileNameFormLine = function(line)
        return line
    end
end

function fileUtils:getDirFileNames(path)
    local wp = cc.FileUtils:getInstance():getWritablePath() .. "tempFileList"
    
    os.execute(getFilesCmdFunc(path, wp))
    io.input(wp)
    
	local ret = {}
	
	for line in io.lines() do
	   local fname = getFileNameFormLine(line)
	   if fname then
	       table.insert(ret, fname)
	   end
	end
	
	return ret
end


return fileUtils
