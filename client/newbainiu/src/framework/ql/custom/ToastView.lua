--
-- Author: Carl
-- Date: 2015-06-17 11:34:57
--

local ToastView = class("ToastView")
function ToastView:show(message,parentself)
	if self._instance then
        if self._instance:getParent() then
            self._instance:removeSelf()
        end
        self._instance:release()
        self._instance = nil
	end
	local label = cc.ui.UILabel.new({
        text = message,
        size = 30,
        color = display.COLOR_WHITE,
    })

    local w, h = label:getContentSize().width, label:getContentSize().height
	local bg = cc.ui.UIImage.new("#Common/bg_toast.png", {scale9 = true})
	bg:setAnchorPoint(cc.p(0.5, 0.5))
	bg:setLayoutSize(w + 60, math.max(60, h))
    bg:setPosition(CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
    bg:setLocalZOrder(MAX_ZORDER)
    label:setPosition(30, bg:getContentSize().height/2)
    label:addTo(bg)
    --?!
    bg:addTo(display.getRunningScene():getController():getView())
    --bg:addTo(parentself)
    bg:setOpacity(0)
    bg:runAction(transition.sequence({cca.fadeIn(0.2), cca.delay(1.5), cca.callFunc(function() 
    	transition.fadeOut(bg, {time=0.2, onComplete=function() 
            if bg:getParent() then
                 bg:removeSelf()
            end
            self._instance:release()
    		self._instance = nil
    	end})
    end)}))
    
    self._instance = bg
    self._instance:retain()
end


if not toastview then
	toastview = ToastView.new()
end

return ToastView