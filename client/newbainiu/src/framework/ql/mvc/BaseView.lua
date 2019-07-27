--
-- Author: Carl
-- Date: 2015-04-29 18:09:08
--

local BaseView = class("BaseView", function()
	return display.newNode()
end)

function BaseView:ctor(args)
	-- 设置场景名称
	self.name = self.class.__cname or "<unknown-view>"
	-- 加载csb，默认使用和view同名的csb文件
	local csbname = rawget(self.class, "csb") or self.name .. ".csb"
	if csbname then
		if self._node then
        	self._node:removeSelf()
        	self._node = nil
	    end
	    if cc.FileUtils:getInstance():isFileExist(csbname) then
	    	self._node = cc.uiloader:load(csbname)
	   	 	assert(self._node, string.format("BaseView:onCreate() - load resouce node from file \"%s\" failed", csbname))
	    	self:addChild(self._node)
	    end
	end
	self:setAnchorPoint(cc.p(0.5, 0.5))
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	if self.onCreate then self:onCreate(args) end
end

-- 设置点击监听
function BaseView:setOnClickListener(listener)
	self:setTouchEnabled(true)
	self:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		if event.name == "ended" and cc.rectContainsPoint(self:getBoundingBox(), cc.p(event.x, event.y)) then
			listener({x=event.x, y=event.y})
        end
        return true
	end)
end

-- 设置触摸监听（单点）
function BaseView:setOnTouchListener(listener)
	self:setTouchEnabled(true)
	self:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		listener(event)
        return true
	end)
end

-- 根据名称检索node，不止children
function BaseView:findNodeByName(name, parent)
	return findNodeByName(name, parent or self._node)
end

-- 为View设置效果和监听器
-- @effect "trans", "zoom", "transinner", "none" 默认是"zoom"
function BaseView:setOnViewClickedListener(view, listener, parent, effect, playSound)
	setOnViewClickedListener(view, listener, parent or self._node, effect, playSound)
end

-- 获取到根视图
function BaseView:getRoot()
	return self._node
end

return BaseView