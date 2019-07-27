--
-- Author: Carl
-- Date: 2015-06-19 14:10:32
--

import(".custom.ToastView")
import(".custom.LoadingView")
require("lfs")



-- 为ImageView设置plist图片
function setPlistTexture(image, textureName)
	if image then
		image:loadTexture(textureName, ccui.TextureResType.plistType)
	end
end

-- 为ImageView设置普通图片
function setLocalTexture(image, textureName)
	if image then
		image:loadTexture(textureName, ccui.TextureResType.localType)
	end
end

-- 为Text设置字符串
function setTextString(text, content, parent)
	if type(text) == "string" then
		text = findNodeByName(text, parent)
	end
	text:setString(content)
end

-- 显示toast消息
function showToast(message)
	toastview:show(message)
end

-- 显示加载动画
function showLoading(parent)
	parent = parent or display.getRunningScene():getController():getView()
	loadingview:show(parent)
end

-- 隐藏加载动画
function dismissLoading()
	loadingview:dismiss()
end

-- 显示对话框
function showDialog(dialogName, args, parent)
	local dialogPackageName = app.packageRoot .. ".views.dialog." .. dialogName
    local dialogClass = require(dialogPackageName)
    local dialog = dialogClass.new(args)
    dialog:show(parent)
    return dialog
end

-- 隐藏对话框
function dismissDialog(dialog)
	if dialog then
		dialog:dismiss()
	end
end

-- 根据房间ID获取房间配置
-- 根据房间ID获取房间配置
function getRoomConfig(roomId)
	for i,v in ipairs(BAINIU_ROOMS) do
		if v.id == roomId then
			return v
		end
	end
	return nil
end


-- 获取支付点
function getPayPoint(name)
	return DDZ_PAY_POINT[name]
end

-- 根据名称检索node，不止children
function findNodeByName(name, parent)
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

--	阻止键盘事件
local isStopKeyEvent = false
function isStopKeyEventHandler(isStop)
	isStopKeyEvent = isStop
end

-- 监听键盘事件抬起
local backKeyListeners = {}
function addBackKeyEventListener(view ,listener)
	view.executeBackKeyListener = listener
	table.insert(backKeyListeners, view)
	
	local key_listener = cc.EventListenerKeyboard:create()
    --抬起
    local function key_up(keyCode, event)
    	if keyCode == 6 then
    		local bkListener = backKeyListeners[#backKeyListeners]
    		if bkListener and bkListener.executeBackKeyListener and not isStopKeyEvent then
				bkListener.executeBackKeyListener()
			end
		end
    end
    key_listener:registerScriptHandler(key_up,cc.Handler.EVENT_KEYBOARD_RELEASED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(key_listener,view)
end

-- 移除事件监听
function removeBackKeyEventListener(view)

	for i = #backKeyListeners ,1 ,-1 do
		local bkListener = backKeyListeners[i]
		if bkListener == view then
			table.remove(backKeyListeners,i)
		end
	end
	cc.Director:getInstance():getEventDispatcher():removeEventListenersForTarget(view)
end

-- 为view设置监听
function setOnViewClickedListener(view, listener, parent, effect, playSound)
	if type(view) == "string" then
		view = findNodeByName(view, parent)
	end
	if not view then
		return
	end
	effect = effect or "zoom"
	if playSound == nil then
		playSound = false
	end
	view:setTouchEnabled(true)
	view.lastClickTime = 0
	view.oriScale = view:getScale()
	
	local viewType = tolua.type(view)
	if string.find(viewType, "ccui%.") then --cocos ui
		view:addTouchEventListener(function(sender, eventType)
			if eventType == 0 then
				if effect == "trans" then
					view:setPositionY(view:getPositionY()-3)
				elseif effect == "zoom" then
					view:setScale(view.oriScale*0.95)
				elseif effect == "transinner" then
					for i,v in ipairs(view:getChildren()) do
						v:setPositionY(v:getPositionY()-3)
					end
				end
			elseif eventType == 2 then
				if effect == "trans" then
					view:setPositionY(view:getPositionY()+3)
				elseif effect == "zoom" then
					view:setScale(view.oriScale)
				elseif effect == "transinner" then
					for i,v in ipairs(view:getChildren()) do
						v:setPositionY(v:getPositionY()+3)
					end
				end
				if playSound then
					audio.playSound("audio/buttondown.wav")
				end
				-- 屏蔽双连击
				if math.abs(os.clock() - view.lastClickTime) > 0.008 then
					view.lastClickTime = os.clock()
					listener(view)
				end
			elseif eventType ~= 1 then
				if effect == "trans" then
					view:setPositionY(view:getPositionY()+3)
				elseif effect == "zoom" then
					view:setScale(view.oriScale)
				elseif effect == "transinner" then
					for i,v in ipairs(view:getChildren()) do
						v:setPositionY(v:getPositionY()+3)
					end
				end
	        end
		end)

	else -- quick ui 以cc.开头
		view:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
		view:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
			if event.name == "began" then
				if effect == "trans" then
					view:setPositionY(view:getPositionY()-3)
				elseif effect == "zoom" then
					view:setScale(view.oriScale*0.95)
				elseif effect == "transinner" then
					for i,v in ipairs(view:getChildren()) do
						v:setPositionY(v:getPositionY()-3)
					end
				end
			elseif event.name == "ended" then
				if effect == "trans" then
					view:setPositionY(view:getPositionY()+3)
				elseif effect == "zoom" then
					view:setScale(view.oriScale)
				elseif effect == "transinner" then
					for i,v in ipairs(view:getChildren()) do
						v:setPositionY(v:getPositionY()+3)
					end
				end
				if playSound then
					audio.playSound("audio/buttondown.wav")
				end
				if math.abs(os.clock() - view.lastClickTime) > 0.008 and cc.rectContainsPoint(view:getCascadeBoundingBox(), cc.p(event.x, event.y)) then
					view.lastClickTime = os.clock()
					listener(view)
				end
			elseif event.name == "cancelled" then
				if effect == "trans" then
					view:setPositionY(view:getPositionY()+3)
				elseif effect == "zoom" then
					view:setScale(view.oriScale)
				elseif effect == "transinner" then
					for i,v in ipairs(view:getChildren()) do
						v:setPositionY(v:getPositionY()+3)
					end
				end
	        end
	    	return true
	    end)
	end
end

-- 解析key-value配置文件
function parseProperties(data)
	local kvs,item = {},{}
	for i,v in ipairs(string.split(string.trim(data), '\n')) do
		local kv = string.split(string.trim(v), "=")
		if #kv >= 2 and kv[1] and kv[2] then
			kvs[string.trim(kv[1])] = string.trim(kv[2])
		end
	end
	return kvs
end

-- 删除最后的路径分隔符
function io.rmlastsep(path)
	path = string.gsub(path, "[\\\\/]+$", "")
	return path
end

-- 是否为文件路径，如果路径中带.就认为是文件
function io.isfile(path)
	if not path then
		return false
	end
	local mode = lfs.attributes(path, "mode") 
    if mode == "directory" then
    	return false
    elseif mode == "file" then
    	return true
    else
    	local splits = string.split(path, device.directorySeparator)
    	if #splits > 0 and string.find(splits[#splits], "%.") then
    		return true
    	end
		return false
    end
end

-- 文件夹或文件是否存在
function io.exists(path)
	if not path then
		return
	end
  	if io.isfile(path) then
  		return cc.FileUtils:getInstance():isFileExist(path)
  	else
  		return cc.FileUtils:getInstance():isDirectoryExist(path)
  	end
end

-- 递归创建目录
function io.mkdirs(path)
	if not path then
		return
	end
	if io.exists(path) then
		return
	end
	if io.isfile(path) then
		path = io.pathinfo(path).dirname
	end
	local dirs = string.split(path, device.directorySeparator)
	local subDir = ""
	for i,v in ipairs(dirs) do
		subDir = subDir .. v .. device.directorySeparator
		if not io.exists(subDir) then
			lfs.mkdir(subDir)
		end
	end
end

-- 删除文件
function io.rmfile(filepath)
	os.remove(filepath)
end

-- 移除文件夹
function io.rmdir(path)
    if not io.exists(path) or io.isfile(path) then
        return false
    end
    path = io.rmlastsep(path)
    local function _rmdir(path)
        for dir in lfs.dir(path) do
        	if dir == nil then break end
            if dir ~= "." and dir ~= ".." then
                local curDir = path..device.directorySeparator..dir
                local mode = lfs.attributes(curDir, "mode") 
                if mode == "directory" then
                    _rmdir(curDir)
                elseif mode == "file" then
                    io.rmfile(curDir)
                end
            end
        end
        return lfs.rmdir(path)
    end
    _rmdir(path)
    return true
end

-- 获取文件内容
function io.filedata(filename)
	return cc.FileUtils:getInstance():getFileData(filename)
end

-- 从zip包中获取文件内容
function io.zipdata(zipfile, filename)
	return cc.FileUtils:getInstance():getFileDataFromZip(zipfile, filename)
end

-- 拷贝文件
function io.cpfile(srcfile, destdir)
	if not srcfile or not io.exists(srcfile) or not io.isfile(srcfile) then
		if DEBUG > 0 then
			printInfo("@无法复制文件，源文件不存在或者不是文件夹(%s)", srcfile)
		end
		return false
	end
	if not destdir or io.isfile(destdir) then
		if DEBUG > 0 then
			printInfo("@无法复制文件，目标文件夹不存在或者不是文件夹(%s)", destdir)
		end
		return false
	end
	if not io.exists(destdir) then
		io.mkdirs(destdir)
	end
	destdir = io.rmlastsep(destdir)
	local srcPathInfo = io.pathinfo(srcfile)
	local destfile = destdir..device.directorySeparator..srcPathInfo.filename
	local input = io.open(srcfile, "rb")
	local data = input:read("*a")
	local ret = io.writefile(destfile, data) 
	io.close(input)
	--[[local input = io.open(srcfile, "rb")
	local output = io.open(destfile, "w+b")
    if input then
    	local line = input:read()
    	while line do
    		output:write(line)
    		line = input:read()
    	end
        io.close(input)
        io.close(output)
    end]]
    return ret
end

-- 拷贝粘贴文件夹
function io.cpdir(srcdir, destdir)
	if not srcdir or not io.exists(srcdir) or io.isfile(srcdir) then
		if DEBUG > 0 then
			printInfo("@无法复制文件夹，源文件夹不存在或者不是文件夹(%s)", srcdir)
		end
		return false
	end
	if not destdir or io.isfile(destdir) then
		if DEBUG > 0 then
			printInfo("@无法复制文件夹，目标文件夹不存在或者不是文件夹(%s)", destdir)
		end
		return false
	end
	if not io.exists(destdir) then
		io.mkdirs(destdir)
	end
	srcdir = io.rmlastsep(srcdir)
	destdir = io.rmlastsep(destdir)
	for file in lfs.dir(srcdir) do
		if file == nil then break end
        if file ~= "." and file ~= ".." then
            local curfile = srcdir..device.directorySeparator..file
            local mode = lfs.attributes(curfile, "mode") 
            if mode == "directory" then
            	if not io.cpdir(curfile, destdir..device.directorySeparator..file) then
            		return false
            	end
            elseif mode == "file" then
            	if not io.cpfile(curfile, destdir) then
            		return false
            	end
            end
        end
	end
	return true
end

-- 返回带圆角矩形DrawNode
-- params borderWidth/fillColor/borderColor/scale/segments
function display.newRoundedRect(rect, roundRadius, params)
	local segments = params.segments or 64
	local coef    = 0.5 * math.pi / segments; -- 1/4圆
	local vertices = {}
	-- 左上角
	local ox, oy = rect.x-(rect.width/2-roundRadius), rect.y+(rect.height/2-roundRadius)
	local x, y, rads
	for i=1, segments+1 do
		rads = (segments+1-i)*coef
		x = ox-roundRadius*math.sin(rads)
		y = oy+roundRadius*math.cos(rads)
		table.insert(vertices, {x, y})
	end
	-- 右上角
	ox, oy = rect.x+(rect.width/2-roundRadius), rect.y+(rect.height/2-roundRadius)
	for i=1, segments+1 do
		rads = (i-1)*coef
		x = ox+roundRadius*math.sin(rads)
		y = oy+roundRadius*math.cos(rads)
		table.insert(vertices, {x, y})
	end
	-- 右下角
	ox, oy = rect.x+(rect.width/2-roundRadius), rect.y-(rect.height/2-roundRadius)
	for i=1, segments+1 do
		rads = (segments+1-i)*coef
		x = ox+roundRadius*math.sin(rads)
		y = oy-roundRadius*math.cos(rads)
		table.insert(vertices, {x, y})
	end
	-- 左下角
	ox, oy = rect.x-(rect.width/2-roundRadius), rect.y-(rect.height/2-roundRadius)
	for i=1, segments+1 do
		rads = (i-1)*coef
		x = ox-roundRadius*math.sin(rads)
		y = oy-roundRadius*math.cos(rads)
		table.insert(vertices, {x, y})
	end
	return display.newPolygon(vertices, params)
end

-- 剪裁图片
-- @imageName 图片路径，如果是plist文件，前面加#
-- @stencilNode 模板节点，以它来裁剪
-- @inverted true 显示剩余部分。false显示被剪掉部分
function display.clippingImage(imageName, stencilNode, imageScale, inverted)
	local clippingNode = cc.ClippingNode:create(stencilNode)
	clippingNode:setInverted(inverted or false) --设置是显示被裁剪的部分，还是显示裁剪。true 显示剩余部分。false显示被剪掉部分
	clippingNode:setAlphaThreshold(0.6)--设置绘制底板的Alpha值为0
	local sprite = display.newSprite(imageName)
	sprite:setScale(imageScale or 1)
	clippingNode:addChild(sprite)
	return clippingNode
end

-- 转化成万
function string.formatTenThousand(number)
	if type(number) ~= "number" then
		number = tonumber(number)
	end
	if number < 10000 then
		return tostring(number)
	end
	return string.format("%.1f", math.floor(number/1000)/10)..localize.get("lb_ten_thonsand")
end

-- 隐藏手机号中间4位
function string.formatMobile(mobile)
	if type(mobile) ~= "string" then
		mobile = tostring(mobile)
	end
	if string.len(mobile) >= 11 then
		return string.sub(mobile, 1, 3).."****"..string.sub(mobile, 8)
	end
	return mobile
end

-- 加逗號
function string.subComma(digital)
	return string.formatnumberthousands(digital)
end

-- 播放时间轴动画
function runTimelineAction(target, actionfile, loop, finishCallback)
	local action = cc.CSLoader:createTimeline(actionfile)
	if finishCallback then
		action:setLastFrameCallFunc(function()
			finishCallback()
		end)
	end
	target:runAction(action)
	action:gotoFrameAndPlay(0, loop or false)
end

-- 播放粒子效果
function runParticleEffect(parent, particlefile, x, y, blendSrc, blendDest)

	local particle = cc.ParticleSystemQuad:create(particlefile)
	particle:setBlendFunc(blendSrc or gl.ONE, blendDest or gl.ONE_MINUS_SRC_ALPHA)
	particle:setPosition(x or parent:getContentSize().width/2, y or parent:getContentSize().height/2)
	parent:addChild(particle)
end

-- 内存加密
function encryptMemData(data)
	return crypto.encryptXXTEA(data, "mem-key-xhat782z")
end

-- 内存解密
function decryptMemData(data)
	return crypto.decryptXXTEA(data, "mem-key-xhat782z")
end

