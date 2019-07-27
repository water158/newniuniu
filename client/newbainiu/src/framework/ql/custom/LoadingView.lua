--
-- Author: Carl
-- Date: 2015-06-17 14:12:39
--

local LoadingView = class("LoadingView")

function LoadingView:ctor()
	self._dismissing = true
end

function LoadingView:show(parent)
	if not self._instance then
		self._dismissing = false
		parent:runAction(transition.sequence({cca.delay(0.1), cca.callFunc(function() 
			if not self._dismissing then
				local node = cc.uiloader:load("LoadingView.csb")
				local running = node:getChildren()[2]
				local action = cc.CSLoader:createTimeline("Running.csb")
				running:runAction(action)
				action:gotoFrameAndPlay(0, true)
				parent:addChild(node, MAX_ZORDER)
				self._instance = node
			end
		end)}))
	end
end

function LoadingView:dismiss()
	self._dismissing = true
	if self._instance then
		self._instance:removeSelf()
		self._instance = nil
	end
end

if not loadingview then
	loadingview = LoadingView.new()
end

return LoadingView