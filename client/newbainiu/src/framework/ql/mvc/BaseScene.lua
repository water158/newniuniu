--
-- Author: Carl
-- Date: 2015-04-21 17:22:29
--

local BaseScene = class("BaseScene", function()
	return display.newScene("BaseScene")
end)

function BaseScene:ctor(args)
	-- 设置场景名称
	self.name = self.class.__cname or "<unknown-scene>"
	-- 加载csb，默认使用和场景同名的csb文件
	local csbname = rawget(self.class, "csb") or self.name .. ".csb"
	if csbname then
		if self.node then
        	self.node:removeSelf()
        	self.node = nil
	    end
	    self.node = cc.uiloader:load(csbname)
	    assert(self.node, string.format("BaseScene:onCreate() - load resouce node from file \"%s\" failed", csbname))
	    self:addChild(self.node)
	end
	-- onCreate 方法
    if self.onCreate then self:onCreate(args) end
end

-- @override
function BaseScene:onEnter()
	if self.controller then self.controller:onEnter() end
end

-- @override
function BaseScene:onExit()
	if self.controller then self.controller:onExit() end
	event:removeListenerByTarget(self)
end

-- 获取node根节点
function BaseScene:getNode()
	return self.node
end

-- 跳转到其他场景
function BaseScene:enterScene(sceneName, args, transitionType, time, more)
	app:enterScene(sceneName, {args}, transitionType, time, more);
end

-- 绑定控制器
function BaseScene:bindController(controllerName, args)
	if controllerName then
		local class = require(app.packageRoot .. ".controllers." .. controllerName)
		if class then
            self.controller = class.new(self.node, args)
			self:addChild(self.controller)
		else
			printError("controller class is not found, name=%s!", controllerName)
		end
	else
		printError("controller is not found, name is nil!")
	end
end

-- 根据名称检索node，不止children
function BaseScene:findNodeByName(name, parent)
    return findNodeByName(name, parent or self.node)
end

-- 为View设置效果和监听器
-- @effect "trans", "zoom", "transinner", "none" 默认是"zoom"
function BaseScene:setOnViewClickedListener(view, listener, parent, effect, playSound)
	setOnViewClickedListener(view, listener, parent or self._node, effect, playSound)
end

-- 获取控制器
function BaseScene:getController()
	return self.controller
end

-- 增加全局事件监听
function BaseScene:addEventListener(eventId, listener)
	event:addListener(self, eventId, listener)
end

-- 触发全局事件
function BaseScene:dispatchEvent(eventId, args, hook)
	event:dispatch(eventId, args, hook)
end

return BaseScene