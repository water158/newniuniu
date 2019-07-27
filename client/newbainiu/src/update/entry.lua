--
-- Author: Carl
-- Date: 2015-08-03 17:59:45



--在Update上------
package.path = package.path .. ";src/"
cc.FileUtils:getInstance():setPopupNotify(false)
require(".app.MyApp").new():run()

--package.path = package.path .. ";src/?.lua;"
--cc.FileUtils:getInstance():setPopupNotify(false)
--collectgarbage("setpause", 100) 
--collectgarbage("setstepmul", 5000)

--require("app.MyApp").new():run()
--[[
local entry = {}

local PLATFORM_OS_WINDOWS = 0
local PLATFORM_OS_ANDROID = 3
local PLATFORM_OS_IPHONE  = 4
local PLATFORM_OS_IPAD    = 5

local DEBUG = 1
local UPDATE_ENABLE = true
-- 升级服务器
local UPDATE_SERVER_URL = "http://static.youxi456.com/static/ddz"
local platform = cc.Application:getInstance():getTargetPlatform()
local USER_CHANNEL = "unknown"
if platform == PLATFORM_OS_ANDROID then
	_, USER_CHANNEL =  LuaJavaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getUserChannel", {}, "()Ljava/lang/String;")
elseif platform == PLATFORM_OS_IPHONE or platform == PLATFORM_OS_IPAD then
	--TODO
else
	UPDATE_ENABLE = false
end

-- 根据名称检索node，不止children
local function findNodeByName(name, parent)
    if not parent then
		return
	end

	if name == parent:getName() then
		return parent
	end

	local findNode
	local children = parent:getChildren()
	local childCount = parent:getChildrenCount()
	if childCount < 1 then
		return
	end
	for i=1, childCount do
		if "table" == type(children) then
			parent = children[i]
		elseif "userdata" == type(children) then
			parent = children:objectAtIndex(i - 1)
		end

		if parent then
			if name == parent:getName() then
				return parent
			end
		end
	end

	for i=1, childCount do
		if "table" == type(children) then
			parent = children[i]
		elseif "userdata" == type(children) then
			parent = children:objectAtIndex(i - 1)
		end

		if parent then
			findNode = findNodeByName(name, parent)
			if findNode then
				return findNode
			end
		end
	end

	return
end

-- 获取请求
local function createHTTPRequest(url, callback)
	return cc.HTTPRequest:createWithUrl(callback, url, cc.kCCHTTPRequestMethodGET)
end

local function trim(input)
	input = string.gsub(input, "^[ \t\n\r]+", "")
    return string.gsub(input, "[ \t\n\r]+$", "")
end

function split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

-- 解析key-value配置文件
local function parseProperties(data)
	local kvs,item = {},{}
	for i,v in ipairs(split(trim(data), '\n')) do
		local kv = split(trim(v), "=")
		if #kv >= 2 and kv[1] and kv[2] then
			kvs[trim(kv[1])] = trim(kv[2])
		end
	end
	return kvs
end

require("lfs")
-- 是否为文件路径，如果路径中带.就认为是文件
local function isfile(path)
	if not path then
		return false
	end
	local mode = lfs.attributes(path, "mode") 
    if mode == "directory" then
    	return false
    elseif mode == "file" then
    	return true
    else
    	local splits = split(path, "/")
    	if #splits > 0 and string.find(splits[#splits], "%.") then
    		return true
    	end
		return false
    end
end

local function rmlastsep(path)
	return string.gsub(path, "[\\\\/]+$", "")
end

-- 移除文件夹
local function rmdir(path)
    if isfile(path) or not cc.FileUtils:getInstance():isDirectoryExist(path) then
        return false
    end
    path = string.gsub(path, "[\\\\/]+$", "")
    local function _rmdir(path)
        for dir in lfs.dir(path) do
        	if dir == nil then break end
            if dir ~= "." and dir ~= ".." then
                local curDir = path.."/"..dir
                local mode = lfs.attributes(curDir, "mode") 
                if mode == "directory" then
                    _rmdir(curDir)
                elseif mode == "file" then
                    os.remove(curDir)
                end
            end
        end
        return lfs.rmdir(path)
    end
    _rmdir(path)
    return true
end

local function writefile(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end

local function readfile(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

local function pathinfo(path)
    local pos = string.len(path)
    local extpos = pos + 1
    while pos > 0 do
        local b = string.byte(path, pos)
        if b == 46 then -- 46 = char "."
            extpos = pos
        elseif b == 47 or b == 92 then -- 47 = char "/" 92 = "\\"
            break
        end
        pos = pos - 1
    end

    local dirname = string.sub(path, 1, pos)
    dirname = string.gsub(dirname, "[\\\\/]+", "/")
    local filename = string.sub(path, pos + 1)
    extpos = extpos - pos
    local basename = string.sub(filename, 1, extpos - 1)
    local extname = string.sub(filename, extpos)
    return {
        dirname = dirname,
        filename = filename,
        basename = basename,
        extname = extname
    }
end

local function mkdirs(path)
	if not path then
		return
	end
	if cc.FileUtils:getInstance():isDirectoryExist(path) then
		return
	end
	if isfile(path) then
		path = pathinfo(path).dirname
	end
	local dirs = split(path, "/")
	local subDir = ""
	for i,v in ipairs(dirs) do
		subDir = subDir .. v .. "/"
		if not cc.FileUtils:getInstance():isDirectoryExist(subDir) then
			lfs.mkdir(subDir)
		end
	end
end

-- 拷贝文件
local function cpfile(srcfile, destdir)
	if not srcfile or not cc.FileUtils:getInstance():isFileExist(srcfile) or not isfile(srcfile) then
		if DEBUG > 0 then
			print("@无法复制文件，源文件不存在或者不是文件夹(%s)", srcfile)
		end
		return false
	end
	if not destdir or isfile(destdir) then
		if DEBUG > 0 then
			print("@无法复制文件，目标文件夹不存在或者不是文件夹(%s)", destdir)
		end
		return false
	end
	if not cc.FileUtils:getInstance():isDirectoryExist(destdir) then
		mkdirs(destdir)
	end
	destdir = rmlastsep(destdir)
	local srcPathInfo = pathinfo(srcfile)
	local destfile = destdir.."/"..srcPathInfo.filename
	local input = io.open(srcfile, "rb")
	local data = input:read("*a")
	local ret = writefile(destfile, data) 
	io.close(input)
    return ret
end

-- 拷贝粘贴文件夹
local function cpdir(srcdir, destdir)
	if not srcdir or not cc.FileUtils:getInstance():isDirectoryExist(srcdir) or isfile(srcdir) then
		if DEBUG > 0 then
			print("@无法复制文件夹，源文件夹不存在或者不是文件夹(%s)", srcdir)
		end
		return false
	end
	if not destdir or isfile(destdir) then
		if DEBUG > 0 then
			print("@无法复制文件夹，目标文件夹不存在或者不是文件夹(%s)", destdir)
		end
		return false
	end
	if not cc.FileUtils:getInstance():isDirectoryExist(destdir) then
		mkdirs(destdir)
	end
	srcdir = rmlastsep(srcdir)
	destdir = rmlastsep(destdir)
	for file in lfs.dir(srcdir) do
		if file == nil then break end
        if file ~= "." and file ~= ".." then
            local curfile = srcdir.."/"..file
            local mode = lfs.attributes(curfile, "mode") 
            if mode == "directory" then
            	if not cpdir(curfile, destdir.."/"..file) then
            		return false
            	end
            elseif mode == "file" then
            	if not cpfile(curfile, destdir) then
            		return false
            	end
            end
        end
	end
	return true
end

]]

--[[
	下载文件
]]
--[[
local function downloadFile(url, destDir, callback)
	local function onDownloadCompleted(event)  
		if event.name == "progress" then
			if event.total > 0 then
		        callback({progress=event.dltotal/event.total})
			end
			return
		end
	    local request = event.request
	 
	    if event.name == "failed" then
	        -- 请求失败，显示错误代码和错误消息
	        if DEBUG > 0 then
	        	print("@下载文件失败, 错误码=", request:getErrorCode(), ", 消息=", request:getErrorMessage())
	        end
	        if callback then callback({error=true}) end
	        return
	    end
	 
	    local code = request:getResponseStatusCode()
	    if code ~= 200 then
	        -- 请求结束，但没有返回 200 响应代码
	        if DEBUG > 0 then
	        	print("@文件服务器响应码不为200(", code, ")!!!")
	        end
	        if callback then callback({error=true}) end
	        return
    	end
	    if event.name == "completed" then
	    	local pathinfo = pathinfo(url)
	    	if not cc.FileUtils:getInstance():isDirectoryExist(destDir) then
    			mkdirs(destDir)
	    	end
	    	local path = destDir..pathinfo.filename 
	    	event.request:saveResponseData(path)
	    	if DEBUG > 0 then
	    		print("@文件下载成功!, 地址=", url, ", 目录=", path)
	    	end
	    	if callback then callback({done=true, path=path}) end
	    end
	end  
	createHTTPRequest(url, onDownloadCompleted):start()
end


--[[
-- 批量下载文件
local function downloadFiles(baseurl, filepaths, from, destDir, callback)
	if from > #filepaths then
		return
	end
	baseurl = string.gsub(baseurl, "[\\\\/]+$", "")
	destDir = string.gsub(destDir, "[\\\\/]+$", "")
	local pathinfo = pathinfo(filepaths[from])
	downloadFile(baseurl..'/'..filepaths[from], destDir.."/"..pathinfo.dirname, function(result)
		if result.done then
			if from == #filepaths then
				callback({progress=1})
				-- 下载完成
				callback({done=true})
				return
			end
			-- 下载下一个
			from = from + 1
			downloadFiles(baseurl, filepaths, from, destDir, callback)
		elseif result.progress then
			callback({progress=((from-1)+result.progress)/#filepaths})
		else
			callback(result)
		end
	end)
end

--]]

--[[
	--请求json文件
local function requestFile(url, callback)
	local function onRequestFinished(event)
		if event.name == "progress" then
			return
		end
	    local request = event.request
	    if event.name == "failed" then
	    	if DEBUG > 0 then
	        	print("@获取JSON文件失败, 错误码=", request:getErrorCode(), " 消息=", request:getErrorMessage())
	        end
	    	if callback then callback() end
	        return
	    end
	 
	    local code = request:getResponseStatusCode()
	    if code ~= 200 then
	    	if DEBUG > 0 then
	        	print("@JSON文件服务器响应码不为200(", code, ")!!!")
	        end
	    	if callback then callback() end
	        return
    	end
 
	    -- 请求成功，显示服务端返回的内容
	    local response = request:getResponseString()
	    if DEBUG > 0 then
	    	print("@请求JSON文件结果="..response)
	    end
	    if callback then
	    	local cjson
			local function safeLoad()
			    cjson = require("cjson")
			end
			if not pcall(safeLoad) then 
			    cjson = nil
			end
			local _, result = pcall(cjson.decode, response)
	    	callback(result) 
	    end
	end
	createHTTPRequest(url, onRequestFinished):start()
end

-- 检查更新
local function checkUpdate(callback)
	if not UPDATE_ENABLE then
		callback({done=true})
		return
	end
	if cc.Network:getInternetConnectionStatus() == 0 then
		callback({done=true})
		return
	end
	local fileutils = cc.FileUtils:getInstance()
	local writableDir = fileutils:getWritablePath()
	local fpFilePath = writableDir..".fp"
	-- 如果不存在指纹文件，则将assets下的.fpz解压到writableDir
	local data
	if not fileutils:isFileExist(fpFilePath) then
		-- 删除res和src文件夹，保障版本一致性
		rmdir(writableDir.."script")
		rmdir(writableDir.."res")
		local zipdata = fileutils:getFileData("version.fpz")
		writefile(writableDir..".fpz", zipdata, "w+b")
		data = cc.FileUtils:getInstance():getFileDataFromZip(writableDir..".fpz", "version.fp")
		writefile(fpFilePath, data, "w+b")
		os.remove(writableDir..".fpz")
	end
	if not data then
		data = readfile(fpFilePath)
	end
	-- 解析.fp文件
	local localFp = parseProperties(data)
	local localVersionCode = localFp["VersionCode"]
	local localVersionName = localFp["VersionName"]
	if localVersionCode and localVersionName then
		if DEBUG > 0 then
			print("@本地版本号为", localVersionCode)
		end

		-- 解析主版本
		local numbers = split(localVersionName, ".")
		local mainVer = 0
		if #numbers > 0 then
			mainVer = numbers[1]
		end
		local url = UPDATE_SERVER_URL.."/v"..mainVer.."/"..USER_CHANNEL
		local tempDir = writableDir.."temp".."/"
		local versionUrl

		local onDownloadFPZ = function(result)
			if result.error then 
				if DEBUG > 0 then
					print("@下载新版指纹文件失败！")
				end
				callback({done=true})
				return
			end
			if result.progress then
				return
			end
			-- 解压fpz文件
			if not fileutils:isFileExist(result.path) then 
				if DEBUG > 0 then
					print("@新版指纹文件不存在！")
				end
				callback({done=true}) 
				return 
			end
			local remoteFp = cc.FileUtils:getInstance():getFileDataFromZip(tempDir.."version.fpz", "version.fp")
			if not remoteFp then 
				if DEBUG > 0 then
					print("@新版指纹文件不合法！")
				end
				callback({done=true}) 
				return 
			end
			writefile(tempDir..".fp", remoteFp, "w+")
			remoteFp = parseProperties(remoteFp)
			-- 比较本地和服务器文件列表
			local diffFiles, md5s = {}, {}
			for k,v in pairs(remoteFp) do
				if k ~= "VersionCode" and k ~= "VersionName" then
					if not localFp[k] or localFp[k] ~= v then -- 本地不存在或者md5值不相同
						table.insert(diffFiles, k)
						table.insert(md5s, {path=k, md5=v})
					end
				end
			end
			if #diffFiles == 0 then 
				if DEBUG > 0 then
					print("@文件列表相同！")
				end
				callback({done=true}) 
				return 
			end

			if entry._message then
				entry._message:setString("下载更新中...")
			end
			-- 下载更新文件
			downloadFiles(versionUrl, diffFiles, 1, tempDir, function(result)
				if result.done then
					-- md5校验
					for i,v in ipairs(md5s) do
						if cc.Crypto:MD5File(tempDir..v.path) ~= v.md5 then
							if DEBUG > 0 then
								print("@MD5校验失败！")
							end
							callback({error=true})
							return
						end
					end
					-- 覆盖原文件
					local cpok = true
					if fileutils:isDirectoryExist(tempDir) then
						cpok = cpok and cpdir(tempDir, writableDir)
					end
					-- 删除temp文件夹
					rmdir(tempDir)
					callback({done=true, restart=false})
				else
					callback(result) -- 进度或发生错误
				end
			end)
		end

		local onDownloadVersionFile = function(data)
			if not data then
				callback({done=true})
				return
			end
			versionUrl = url..data.path
			if data.VersionCode and data.VersionCode ~= localVersionCode and data.path then
				-- 下载新的.fpz文件到temp文件夹
				if fileutils:isDirectoryExist(tempDir) then
					rmdir(tempDir)
				end
				mkdirs(tempDir)
				downloadFile(versionUrl.."/version.fpz", tempDir, onDownloadFPZ)
			else
				if DEBUG > 0 then
					print("@本地与服务器版本一致，无须更新！")
				end
				callback({done=true})
			end
		end

		-- 与服务器版本比较,{"VersionCode": "1", "path": "/v0.0.1", "VersionName": "0.0.1"}
		requestFile(url.."/VERSION", onDownloadVersionFile)
	else
		if DEBUG > 0 then
			print("@指纹文件中尚未包含版本信息！")
		end
		callback({done=true})
	end
end

local function loadScripts()
	if DEBUG > 0 then
		print("@加载脚本")
	end
	if entry._isLoadingScript then
		return
	end
	entry._isLoadingScript = true
	
	-- 计算模块总数
	local data = readfile(cc.FileUtils:getInstance():getWritablePath()..".fp")
	if data then
		entry._scriptMoList = {}
		-- 解析.fp文件
		local localFp = parseProperties(data)
		for k,v in pairs(localFp) do
			local info = pathinfo(k)
			if info.extname == ".mo" and info.basename ~= "update" then
				table.insert(entry._scriptMoList, k)
			end
		end
	else
		entry._scriptMoList = {"framwork.mo", "cocos.mo", "app.mo"}
	end
	-- 加载脚本模块
	entry._currScriptIndex = 1
	entry._updateHandle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
		if entry._currScriptIndex <= #entry._scriptMoList then
			-- 加载脚本
			local scriptFileName = entry._scriptMoList[entry._currScriptIndex]
			local writablePath = cc.FileUtils:getInstance():getWritablePath()
			if cc.FileUtils:getInstance():isFileExist(writablePath..scriptFileName) then
				cc.LuaLoadChunksFromZIP(writablePath..scriptFileName)
			else
				cc.LuaLoadChunksFromZIP(scriptFileName)
			end
		end
		
		if entry._currScriptIndex <= #entry._scriptMoList then
			entry._loadingBar:setPercent(entry._currScriptIndex*100/#entry._scriptMoList)
			entry._currScriptIndex = entry._currScriptIndex + 1
		else
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(entry._updateHandle)
			entry._loadingBar:setPercent(100)

			require("app.MyApp").new():run()
		end
	end, 0.05, false)
end

cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1280, 720, 0)
cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath().."res/")
cc.FileUtils:getInstance():addSearchPath("res/")
local node = cc.CSLoader:getInstance():createNodeWithFlatBuffersFile("LoadingScene.csb")
local scene = cc.Scene:create()
scene:addChild(node)
cc.Director:getInstance():runWithScene(scene)
entry._loadingBar = findNodeByName("loading", node)
entry._loadingBar:setPercent(0)
entry._message = findNodeByName("message", node)
entry._message:setString("检查更新中...")
-- 检查更新
checkUpdate(function(result)
	if result.done then
		if DEBUG > 0 then
			print("@更新成功！")
		end
		-- android or ios平台下加载脚本
		if platform == PLATFORM_OS_ANDROID or platform == PLATFORM_OS_IPHONE or platform == PLATFORM_OS_IPAD then
			loadScripts()
		else
			require("app.MyApp").new():run()
		end
	elseif result.error then
		if DEBUG > 0 then
			print("@更新失败！")
		end
		-- android or ios平台下加载脚本
		if platform == PLATFORM_OS_ANDROID or platform == PLATFORM_OS_IPHONE or platform == PLATFORM_OS_IPAD then
			loadScripts()
		else
			require("app.MyApp").new():run()
		end
	elseif result.progress then
		if DEBUG > 0 then
			print("@更新进度=", result.progress*100)
		end
		entry._loadingBar:setPercent(result.progress*100)
	end
end)

--]]