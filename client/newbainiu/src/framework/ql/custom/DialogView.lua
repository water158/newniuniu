--
-- Author: Carl
-- Date: 2015-06-30 15:02:50
--

local DialogView = class("DialogView", import("..mvc.BaseView"))

DialogView.DISMISS = -888

local dialogList = {} --管理Dialog数组

--添加dialog
local function addDialogView(dialog)
	if #dialogList > 0 then
		removeBackKeyEventListener(dialogList[#dialogList])
	end

	dialog:retain()
	table.insert(dialogList,dialog)

	addBackKeyEventListener(dialog,function()
		dialog:dismiss()
	end)
end

--检查对象是否被释放
local function checkDialogIsRelease()
	for i = #dialogList, 1, -1 do
		if dialogList[i]:getReferenceCount() <= 1 then
			dialogList[i]:release()
			table.remove(dialogList,i)
		end
	end
end

--删除dialog
local function removeDialogView(dialog)
	checkDialogIsRelease()

	for i = 1,#dialogList do
		if dialogList[i] == dialog then
			removeBackKeyEventListener(dialog)
			table.remove(dialogList,i)
			--dialog:release()	
		end
	end

	if #dialogList > 0 then
		addBackKeyEventListener(dialogList[#dialogList],function()
			dialogList[#dialogList]:dismiss()
		end)
	end
end

function DialogView:ctor(args)
	DialogView.super.ctor(self,args)
	self._shown = false
	local close = self:findNodeByName("close", self:getRoot())
	if close then
		self:setOnViewClickedListener(close, function() 
			self:dismiss()
		end, self:getRoot())
	end

	local overlay = ccui.Layout:create()
	overlay:setContentSize(cc.size(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT))
	overlay:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
	overlay:setBackGroundColor(cc.c3b(0,0,0))
	overlay:setBackGroundColorOpacity(150)
	overlay:setTouchEnabled(true)
	overlay:setSwallowTouches(true)
	overlay:setLocalZOrder(MAX_ZORDER - 1)
	overlay:setAnchorPoint(cc.p(0.5, 0.5))
	overlay:setPosition(CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
	self._overlay = overlay
	self:setOnViewClickedListener(self._overlay, function()
		if self._touchOutsideDismissed == true or self._touchOutsideDismissed == true then
			self:dismiss()
		end
	end, nil, "none", false)
	self:getRoot():setAnchorPoint(cc.p(0.5, 0.5))
	self:setPosition(CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
	self:setLocalZOrder(MAX_ZORDER - 1)
end

function DialogView:setDismissedOnTouchOutside(enable)
	self._touchOutsideDismissed = enable
end

function DialogView:show(parent)
	parent = parent or display.getRunningScene():getController():getView()
	if self:getParent() ~= parent then
		parent:addChild(self._overlay)
		parent:addChild(self)
		self:showEffect()
		self._shown = true
	end
	--添加dialog
	addDialogView(self)
end

function DialogView:showEffect()
	if self._effectType == nil then
		self:getRoot():setScale(0.3)
		transition.scaleTo(self:getRoot(), {scale=1, time=0.16, onComplete=function()
			if self.onShown then
				self:onShown()
			end
		end})
	elseif self._effectType == "translat" then
		self:getRoot():setPosition(CONFIG_SCREEN_WIDTH,0)
		transition.moveTo(self:getRoot(), {time=0.3, x=0, y=0, easing = "backInOut"})
	end
end

function DialogView:setEffectType(effectType)
	self._effectType = effectType
end

function DialogView:dismiss()
	if self._effectType == nil then
		self:dismissComplete()
	elseif self._effectType == "translat" then
		transition.moveTo(self:getRoot(), {time=0.3, x=CONFIG_SCREEN_WIDTH, y=0, easing = "backInOut", onComplete=function()
			self:dismissComplete()
		end})
	end
end

function DialogView:dismissComplete()
	if self:getParent() and self._shown then
		--移除dialog
		removeDialogView(self)

		if self._overlay then
			self._overlay:removeSelf()
		end
		if self.onDismiss then
			self:onDismiss()
		end
		self:doCallback(DialogView.DISMISS)
		self:removeSelf()
		self._shown = false
	end
end

function DialogView:setCallback(eventType, callback)
	if not self._callbacks then
		self._callbacks = {}
	end
	self._callbacks[eventType] = callback
end

function DialogView:getCallback(eventType)
	return self._callbacks[eventType]
end

function DialogView:doCallback(eventType, args)
	if self._callbacks and self._callbacks[eventType] then
		self._callbacks[eventType](args)
	end
end

function DialogView:getCallbacks()
	return self._callbacks or {}
end

-- 跳转到其他场景
function DialogView:enterScene(sceneName, args, transitionType, time, more)
	app:enterScene(sceneName, {args}, transitionType, time, more);
end

return DialogView