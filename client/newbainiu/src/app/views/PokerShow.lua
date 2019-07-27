--
-- Author:Han 
-- Date: 2015-08-19 14:23:35
--
local PokerShow = class("PokerShow",ql.mvc.BaseView)
--Card res 表
local Card = import("..common.GlobalDefine")

function PokerShow:ctor(args)

  self:initPoker()
  self.pokerPos = args.pokerPos

end

function PokerShow:initPoker()

  self.card52 = {}
  
  for i=1,2 do
     
    for j=1,2 do
   
      for m=1,13 do
   
        local smallDesign = "l_"..i.."_"..j
        local bigDesign = "b_"..i.."_"..j 
        local dot = ""
        if j ==1 then
          dot = "Black_"..m
        else
          dot = "Red_"..m
        end
        local writeCard = display.newSprite("#card/card_front.png")
        writeCard:setPosition(cc.p(0,0))
        writeCard:setVisible(false)
        self:addChild(writeCard)
--点
        local  temp_dot = display.newSprite("#"..Card.res[dot])
        temp_dot:setPosition(cc.p(writeCard:getBoundingBox().width*0.2,writeCard:getBoundingBox().height*0.8))
        writeCard:addChild(temp_dot)
  
--小
        local temp_smallDesign = display.newSprite("#"..Card.res[smallDesign])
        temp_smallDesign:setPosition(cc.p(writeCard:getBoundingBox().width*0.2,temp_dot:getPositionY()-temp_dot:getBoundingBox().height))
        writeCard:addChild(temp_smallDesign)


--大
        local  temp_bigDesign = display.newSprite("#"..Card.res[bigDesign])
        temp_bigDesign:setPosition(cc.p(writeCard:getBoundingBox().width*0.6,writeCard:getBoundingBox().height*0.35))
        writeCard:addChild(temp_bigDesign);
        table.insert(self.card52,writeCard)              

      end
    
    end
   
  end

end



function PokerShow:initServicerNormalCards(cardList)

  self.showCard = {}
  local servicerCradList = cardList
  for i=1,25 do
    self.card52[checkint(servicerCradList[i])+1]:setLocalZOrder(i)
    self.card52[checkint(servicerCradList[i])+1]:setPosition(self.pokerPos[i])
    table.insert(self.showCard,self.card52[checkint(servicerCradList[i])+1])
  end 
  
end


return  PokerShow