--version number v1.0.0
--@client side GlobalEffect.lua
--[[
  此文件用来 书写 游戏的公共特效 工具类，方便整个项目调用
]]--
--script writer  Han 
--creation time 2015-04-21


--[[
此函数显示抖动特效
@param  node 特效对象
@return 无
]]

local     GlobalEffect = {}
function  GlobalEffect.shake_effect(node)
    
    local callShow = cc.CallFunc:create(function ()
    
          node:setVisible(true)

    end)
  
    local rotate = cc.RotateBy:create(1,10)
    local scaleTo1=cc.ScaleTo:create(0.4,1.3)
    local scaleTo2=cc.ScaleTo:create(0.2,0.8)
    local scaleTo3=cc.ScaleTo:create(0.4,1.2)
    local scaleTo4=cc.ScaleTo:create(0.2,1.0)
    
    local seq = transition.sequence({callShow,scaleTo1,rotate,scaleTo2,scaleTo3,scaleTo4})
    node:runAction(cc.RepeatForever:create(seq))


end


--[[
此函数显示文字上移效果
@param  node 特效对象
@return 无
]]
function  GlobalEffect.textUp(node)
    
    node:setLocalZOrder(100)
    local moveup = cc.MoveTo:create(1,cc.p(node:getPositionX(),node:getPositionY()+node:getBoundingBox().height*1.5))
    local scale =  cc.ScaleTo:create(0.3,0.8)
    local fadeto = cc.FadeTo:create(1.2,0)
    local seq = transition.sequence({moveup,fadeto})
    node:runAction(seq)

end

function  GlobalEffect.textDown(textNode)
    
    textNode:setString("")
    local movedown = cc.MoveTo:create(0.1,cc.p(textNode:getPositionX(),textNode:getPositionY()-textNode:getBoundingBox().height*1.5))
    local fadeto = cc.FadeTo:create(0.1,255)
    local seq = transition.sequence({movedown,fadeto})
    textNode:runAction(seq)

end


--[[
此函数显示抖动特效
@param  node 特效对象
@return 无
]]
function  GlobalEffect.shake_effectTwo(node)
    
    local scaleTo1=cc.ScaleTo:create(0.45,1.05)
    local scaleTo2=cc.ScaleTo:create(0.4,1)
    local seq = transition.sequence({scaleTo1,scaleTo2})
    node:runAction(cc.RepeatForever:create(seq))

end

--[[
此函数向下移动
@param  node 特效对象
@return 无
]]
function GlobalEffect:moveDown(node,pos)
  
   local movedown  = cc.MoveTo:create(1,pos)
   node:runAction(movedown)    

end

--[[
星星下落的特效
@param  node 特效对象
@return 无
]]
function GlobalEffect.starMoveEffect(node)
   
   local moveup = cc.MoveTo:create(1,cc.p(node:getPositionX(),node:getPositionY()+node:getBoundingBox().height*1.5))
   local movedown  = cc.MoveTo:create(3,cc.p(node:getPositionX(),display.bottom-node:getBoundingBox().height))
   local seq=transition.sequence({moveup,movedown})
   node:runAction(seq) 

end

--[[
旋转动作
@param  无
@return 无
]]
function GlobalEffect.rotateAction(node)
  
  local rotate = cc.RotateBy:create(5,360)
  local repeatRotate = cc.RepeatForever:create(rotate)
  node:runAction(repeatRotate)
    
end

--[[
此函数用来显示翻转特效
@param  node 特效对象
@return 无
]]

function  GlobalEffect.flipY_effect(node)

    local  orbitFront = cc.OrbitCamera:create(0.8,1,0,90,-90,0,0)
    node:runAction(orbitFront)

end


--[[
此函数用来停止动作
@param  node 特效对象
@return 无
]]
function  GlobalEffect.stop_Action(node)
    
    node:stopAllActions()

end

--[[
此函数显示闪烁特效
@param  node 特效对象
@return 无
]]
function  GlobalEffect.blink_effect(node)
    
    local fadein1=cc.FadeIn:create(0.3)
    local fadeout2=cc.FadeOut:create(0.3)
    local seq=transition.sequence({fadein1,fadeout2})
    local scaleAction= cc.RepeatForever:create(seq)
    node:runAction(scaleAction)

end

--[[
此函数显示透明度渐变特效
@param  node 特效对象
@return 无
]]
function  GlobalEffect.fadeTo_effect(node,time,opacity)
    local fadeto1=cc.FadeTo:create(time,opacity)
    node:runAction(fadeto1)
end

--[[
此函数显示上下漂浮特效
@param  node 特效对象 moveHeight 上下移动距离
@return 无
]]
function  GlobalEffect.flotage_effect(node,height)
    --执行上下动作
    local moveToUp=cc.MoveBy:create(1.0,cc.p(0,height))
    local moveToDown=moveToUp:reverse()
    local seq=transition.sequence({moveToUp,moveToDown})
    local scaleAction= cc.RepeatForever:create(seq)
    node:runAction(scaleAction)
end

--[[
此函数显示弹出特效
@param  node 特效对象
@return 无
]]
function  GlobalEffect.popup_effect(node,callBackEvent)
    node:setScale(0)
    --执行弹出动作
    local scaleto1=cc.ScaleTo:create(0.5,1.7)
    local scaleto2=cc.ScaleTo:create(0.8,1.0)

    if callBackEvent~=nil then
        local callBack=cc.CallFunc:create(callBackEvent)
        local seq=transition.sequence({scaleto1,scaleto2,callBack})
        node:runAction(seq)
    else
        local seq=transition.sequence({scaleto1,scaleto2})
        node:runAction(seq)
    end

end


--[[
此函数显示隐藏弹出特效
@param  node 特效对象 callBackEvent 回调函数
@return 无
]]
function  GlobalEffect.popback_effect(node,callBackEvent)
    --执行隐藏弹出动作,将对象移除掉
    local scaleto1=cc.ScaleTo:create(0.2,1.2)
    local scaleto2=cc.ScaleTo:create(0.1,0.0)
    --local removeself=cc.RemoveSelf:create()
    
    if callBackEvent~=nil then
       
        local callBack=cc.CallFunc:create(callBackEvent)
        local seq=transition.sequence({scaleto1,scaleto2,callBack})
        node:runAction(seq)
    else

        local seq=transition.sequence({scaleto1,scaleto2,removeself})
        node:runAction(seq)
    end
    
    
end

--[[
此函数显示获取物品向上弹出特效
@param  node 特效对象 moveHeight 向上移动距离  callBackEvent 回调函数
@return 无
]]
function  GlobalEffect.receive_effect(node,moveHeight,callBackEvent)
    
    --执行弹出显示动作
    local scaleto1=cc.ScaleTo:create(0.1,1.2)
    local scaleto2=cc.ScaleTo:create(0.2,1.0)
    local moveby1=cc.MoveBy:create(0.2,cc.p(0,moveHeight))
    local fadeout2=cc.FadeOut:create(0.2)
    local removeself=cc.RemoveSelf:create()

    if callBackEvent~=nil then
        local callBack=cc.CallFunc:create(callBackEvent)
        local seq=transition.sequence({scaleto1,scaleto2,moveby1,fadeout2,removeself,callBack})
        node:runAction(seq)
    else 
        local seq=transition.sequence({scaleto1,scaleto2,moveby1,fadeout2,removeself})
        node:runAction(seq)
    end
end


--[[
此函数显示闪白光出现
@param  node 特效对象 
@return 无
]]
function  GlobalEffect.whitelight_effect(node,callBackEvent)
    
    local scaleto1=cc.ScaleTo:create(0.3,0.0)
    local removeself=cc.RemoveSelf:create()

    if callBackEvent~=nil then
        local callBack=cc.CallFunc:create(callBackEvent)
        local seq=transition.sequence({scaleto1,removeself,callBack})
        node:runAction(seq)
    else 
        local seq=transition.sequence({scaleto1,removeself})
        node:runAction(seq)
    end   
    
end

--[[
此函数显示菜单弹出特效
@param  node 特效对象 
@return 无
]]
function GlobalEffect.easeBounceOut(node,movetime,pos)

    local function callBackEvent()
        node:setEnabled(true)
    end
    local callBack=cc.CallFunc:create(callBackEvent)
    local moveby1=cc.MoveTo:create(movetime,pos)
    local easeout=cc.EaseBounceOut:create(moveby1)
    local fadein1=cc.FadeIn:create(movetime*0.5)
    local spw=cc.Spawn:create({fadein1,moveby1})
    
    local seq=transition.sequence({spw,callBack})
    
    node:runAction(spw)

end

--[[
此函数显示菜单缩回特效
@param  node 特效对象 
@return 无
]]
function GlobalEffect.easeBounceIn(node,movetime,pos)
    local function callBackEvent()
        node:setEnabled(false)
    end

    local moveto1=cc.MoveTo:create(movetime,pos)
    local callBack=cc.CallFunc:create(callBackEvent)
    local easeout=cc.EaseBounceIn:create(moveto1)
    local fadeout=cc.FadeOut:create(movetime*0.5)
    local spw=cc.Spawn:create({fadeout,moveto1})
    local seq=transition.sequence({spw,callBack})
    node:runAction(seq)

end

--[[
此函数显示对象从左至右平移闪现
@param  node 特效对象 
@return 无
]]
function GlobalEffect.FlashOut(node,movetime,pos)
	
    local function callBackEvent()
        node:setEnabled(true)
    end
    local move = cc.MoveTo:create(movetime,pos)
    --cc.EaseElasticInOut 让目标赋予弹性
    local easeout=cc.EaseBounceOut:create(move)
    --local easeout=cc.EaseElasticInOut:create(move,0.6)
    local seq=transition.sequence({move,easeout})
    node:runAction(seq)
    --直接移动
    --node:runAction(move)
	
	
end

--[[
此函数显示对象从右至左平移闪退
@param  node 特效对象 
@return 无
]]
function GlobalEffect.FlashIn(node,movetime,pos)

    local function callBackEvent()
        node:setEnabled(true)
    end
    local moveback = cc.MoveTo:create(movetime,pos)
    node:runAction(moveback)

end

--[[
此函数用来显示移动特效   ---红包
@param  node 特效对象 
@return 无
]]
function GlobalEffect.PacketShowOut(node,delaytime,movepos,parentself)
  
    local Callfalse = cc.CallFunc:create(function ()
  
    node:setVisible(false)

    end)
    local delayfalse = cc.DelayTime:create(1)
    local scaleTo = cc.ScaleTo:create(0.001,0.7)
    local moveto = cc.MoveTo:create(0.001,movepos)
    local Callture = cc.CallFunc:create(function ()
 
    node:setVisible(true)

    end)
    local delayture = cc.DelayTime:create(delaytime)
    local removeself=cc.RemoveSelf:create()
    local seq=transition.sequence({Callfalse,delayfalse,scaleTo,moveto,Callture,delayture,removeself})
    node:runAction(seq)   
    parentself:addChild(node)

end



--[[
此函数显示对象旋转
@param  node 特效对象 
@return 无
]]
function GlobalEffect.RotateOut(node,movetime,angle)

    local function callBackEvent()
        node:setEnabled(true)
    end
   local rotate = cc.RotateBy:create(movetime,angle)
   node:runAction(rotate)

end

--[[
此函数显示对象旋转
@param  node 特效对象 
@return 无
]]
function GlobalEffect.RotateIn(node,movetime,angle)

    local function callBackEvent()
        node:setEnabled(true)
    end
    local rotate = cc.RotateBy:create(movetime,angle)
    node:runAction(rotate) 

end

--[[
此函数显示闪烁特效
@param  node 特效对象 
@return 无
]]
function  GlobalEffect.blink2_effect(node)

    --执行上下动作
    local blank=cc.Blink:create(1.0,1.5)
    local blankAction= cc.RepeatForever:create(blank)
    node:runAction(blankAction)

end

--[[
此函数显示慢慢消失特效
@param  node 特效对象 time 消失时间  callBackEvent 回调函数
@return 无
]]
function  GlobalEffect.fadeOut_effect(node,time,callBackEvent)
    
    --执行弹出显示动作
    local fadeout1=cc.FadeOut:create(time)
    local removeself=cc.RemoveSelf:create()
    if callBackEvent~=nil then
        local callBack=cc.CallFunc:create(callBackEvent)
        local seq=transition.sequence({fadeout1,removeself,callBack})
        node:runAction(seq)
    else 
        local seq=transition.sequence({fadeout1,removeself})
        node:runAction(seq)
    end
end

--[[
此函数显示移动特效
@param  node 特效对象 time 消失时间  callBackEvent 回调函数
@return 无
]]
function  GlobalEffect.moveTo_effect(node,pos,time,callBackEvent)
    
    --执行弹出显示动作
    local moveto1=cc.MoveTo:create(time,pos)
    local removeself=cc.RemoveSelf:create()

    if callBackEvent~=nil then
        local callBack=cc.CallFunc:create(callBackEvent)
        local seq=transition.sequence({moveto1,removeself,callBack})
        node:runAction(seq)
    else 
        local seq=transition.sequence({moveto1,removeself})
        node:runAction(seq)
    end
end

--[[
此函数显示弹出特效
@param  node 特效对象
@return 无
]]
function  GlobalEffect.scaleTo_effect(node,scale,callBackEvent)

    --执行弹出动作
    local scaleto1=cc.ScaleTo:create(0.05,scale*1.5)
    local scaleto2=cc.ScaleTo:create(0.01,scale)

    if callBackEvent~=nil then
        local callBack=cc.CallFunc:create(callBackEvent)
        local seq=transition.sequence({scaleto1,scaleto2,callBack})
        node:runAction(seq)
    else
        local seq=transition.sequence({scaleto1,scaleto2})
        node:runAction(seq)
    end
end

--[[
此函数显示飞入特效
@param  node 特效对象
@return 无
]]
function  GlobalEffect.flyin_effect(node,direction,time,callBackEvent)

    --执行弹出动作
    local moveToLeft1,moveToLeft2,moveToRight1,moveToRight2
    local delaytime = cc.DelayTime:create(1.0)
    local callBack=cc.CallFunc:create(callBackEvent)

    if direction == 1  then --从左边飞向右边
        node:setPositionX(0-node:getBoundingBox().width)
        moveToLeft1 =cc.MoveTo:create(time,cc.p(display.width*0.6,node:getPositionY()))
        moveToLeft2 =cc.MoveTo:create(0.2,cc.p(display.width*0.5,node:getPositionY()))
        local seq=transition.sequence({delaytime,moveToLeft1,moveToLeft2,callBack})
        node:runAction(seq)

    elseif direction == 2  then --从右边飞向左边
        node:setPositionX(display.width+node:getBoundingBox().width)
        moveToRight1 =cc.MoveTo:create(time,cc.p(display.width*0.4,node:getPositionY()))
        moveToRight2 =cc.MoveTo:create(0.2,cc.p(display.width*0.5,node:getPositionY()))
        local seq=transition.sequence({delaytime,moveToRight1,moveToRight2,callBack})
        node:runAction(seq)
    end

end

--[[
此函数显示延迟移入特效
@param  node 特效对象
@return 无
]]
function  GlobalEffect.DelayMoveTo_effect(node,pos,time,movetime)
    
    local moveTo =cc.MoveTo:create(movetime,pos)
    local delaytime = cc.DelayTime:create(time)

    local seq=transition.sequence({delaytime,moveTo})
    node:runAction(seq)   
end

--[[
此函数显示延迟移入特效
@param  node 特效对象
@return 无
]]
function  GlobalEffect.animation_effect(node,data,isforever,delay)

    local animation = cc.Animation:create()
    local number, name
    for i = 1, #(data) do
        animation:addSpriteFrameWithFile(data[i])
    end
    -- should last 2.8 seconds. And there are 14 frames.
    animation:setDelayPerUnit(delay)
    animation:setRestoreOriginalFrame(false)
    local action = cc.Animate:create(animation)
    if isforever ==true then 
        local repeatAction= cc.RepeatForever:create(action)
        node:runAction(repeatAction)
    else
        node:runAction(action)
    end

end

--[[
飞行
@param  node 特效对象
@return 无
]]
function  GlobalEffect.fly_effect(node)

    local function randompos(sender)
        sender:setPositionX(0-node:getBoundingBox().width*0.5)
        --math.randomseed(os.time())
        --local randomY= math.round(display.height*0.3,display.height*0.7)
        local randomY= math.random(display.height*0.3,display.height)
        --print("随机坐标:"..randomY)
        sender:setPositionY(randomY)
    end
    local callBack=cc.CallFunc:create(randompos)
    local moveto2=cc.MoveBy:create(5,cc.p(display.width+node:getBoundingBox().width*0.5,0))

    local seq=transition.sequence({callBack,moveto1,moveto2})
    local repeatAction= cc.RepeatForever:create(seq)
    
    node:runAction(repeatAction)

end

--[[
飞行
@param  node 特效对象
@return 无
]]
function  GlobalEffect.light_effect(node)

    local function randompos(sender)
        sender:setScale(0.0)
        sender:setRotation(0)
        sender:setOpacity(255)
    end

        local callBack=cc.CallFunc:create(randompos)

        local scaleto1=cc.ScaleTo:create(0.4,1.2)

        local delaytime = cc.DelayTime:create(0.3)

        local delaytime2 = cc.DelayTime:create(1.0)

        local delaytime3 = cc.DelayTime:create(0.2)

        local ration= cc.RotateTo:create(0.3,90)

        local fadeto=cc.FadeOut:create(0.3)

        local seq2=transition.sequence({delaytime3,fadeto})

        local spw1=cc.Spawn:create({ration,seq2})

        local seq1=transition.sequence({delaytime,spw1})

        local spw=cc.Spawn:create({scaleto1,seq1})

        local seq=transition.sequence({callBack,spw,delaytime2})

        local repeatAction= cc.RepeatForever:create(seq)
        node:runAction(repeatAction)
    
end

return GlobalEffect