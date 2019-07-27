--
-- Author: Carl
-- Date: 2015-04-23 16:03:21
--

local BaseController = class("BaseController", function()
	return display.newNode()
end)

function BaseController:ctor(node, args)
	self._node = node
	if self.onCreate then self:onCreate(args) end
end

function BaseController:onEnter()

end

function BaseController:onExit()
	event:removeListenerByTarget(self)

	--移除键盘事件监听
	removeBackKeyEventListener(self)
end

-- 跳转到其他场景
function BaseController:enterScene(sceneName, args, transitionType, time, more)
	app:enterScene(sceneName, {args}, transitionType, time, more);
end

-- 根据名称检索node，不止children
function BaseController:findNodeByName(name, parent)
    return findNodeByName(name, parent or self._node)
end

-- 为View设置效果和监听器
-- @effect "trans", "zoom", "transinner", "none" 默认是"zoom"
function BaseController:setOnViewClickedListener(view, listener, parent, effect, playSound)
	setOnViewClickedListener(view, listener, parent or self._node, effect, playSound)
end

-- 设置点击监听
function  BaseController:setOnClickListener(view,listener)
	
    if type(view) == "string" then
		view = findNodeByName(view, parent or self._node)
	end
	if not view then
		return
	end

	view:setTouchEnabled(true)
	view:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
	view:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		if event.name == "ended" and cc.rectContainsPoint(view:getBoundingBox(), cc.p(event.x, event.y)) then
			listener({x=event.x, y=event.y})
        end
        return true
	end)
end

-- 弹出对话框
function BaseController:showDialog(dialogName, args)
	return showDialog(dialogName, args, self._node)
end

-- 隐藏对话框
function BaseController:dismissDialog(dialog)
	dismissDialog(dialog)
end

-- 显示toast消息
function BaseController:showToast(message)
	showToast(message)
end

-- 显示加载动画
function BaseController:showLoading()
	showLoading(self._node)
end

-- 隐藏加载动画
function BaseController:dismissLoading()
	dismissLoading()
end

-- 显示全屏网页
function BaseController:openUrl(url)
	self:enterScene("WebScene", {url=url})
end

-- 获取根节点
function BaseController:getView()
	return self._node
end

-- 增加退出按键设置
function BaseController:addBackKeyEventListener(listener)
	addBackKeyEventListener(self,listener)
end

-- 增加全局事件监听
function BaseController:addEventListener(eventId, listener)
	event:addListener(self, eventId, listener)
end

-- 触发全局事件
function BaseController:dispatchEvent(eventId, args, hook)
	event:dispatch(eventId, args, hook)
end

return BaseController
