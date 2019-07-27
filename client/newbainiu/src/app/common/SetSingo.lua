--version number v1.0.0
--@client side 
--[[
 此函数为全局控件
]]--
--script writer Han 
--creation time 2015-08-29

local  SetSingo  = class("SetSingo", ql.mvc.BaseView)
function  SetSingo:changeSecondToTime(second)


    local H = second/3600
    local h = second%3600
    local M = h/60
    local m = h%60
    local S = m

    if H >= 10  then

        tempHourstr = string.format("%d",H)

    else  

        tempHourstr = string.format("%d",H)

    end

    if M >=10  then

        tempMinutestr = string.format("%d",M)

    else

        tempMinutestr = string.format("%d",M)

    end

    if  S >= 10 then

        tempSecond = string.format("%d",S)

    else

        tempSecond = string.format("%d",S)

    end

    if tempHourstr == "0" and tempMinutestr ~= "0" then 

        temptime = tempMinutestr.."m"..tempSecond.."s"

    elseif   tempHourstr == "0" and tempMinutestr == "0" then

        temptime =  tempSecond.."s"

    else 

        temptime =  tempHourstr.."h"..tempMinutestr.."m"..tempSecond.."s"

    end


    print("+++++"..temptime)

    
    return  temptime
end

--转换为等级
function SetSingo:changeForGrade(Grade)
 

 local  tempStr = tostring(Grade) 
 return "g"..tempStr

end

--转换为数字
function SetSingo:changeForNum(Num)

    local  tempStr = tostring(Num) 
    return  tempStr

end

--转换为赢
function SetSingo:changeForWin(winCoins)
   
    local  tempStr = tostring(winCoins) 
    return "+"..tempStr 

end

--转换为输
function SetSingo:changeForLose(loseCoins)
  
  local  tempStr = tostring(loseCoins) 
  return "-"..tempStr   

end


function SetSingo:ctor()
end

--设置时间
function SetSingo:setTime(second,FontType,FontSize)
    
    local  time = self:changeSecondToTime(second)
    local  TimeFontType = FontType
    local  TimeFontSize = FontSize 
    self:initView(time,TimeFontType,TimeFontSize)

end

--设置等级
function SetSingo:setGrade(Grade,FontType,FontSize)
  
    local Getgrade = self:changeForGrade(Grade)
    local GradeFontType = FontType
    local GradeFontSize = FontSize
    self:initView(Getgrade,GradeFontType,GradeFontSize)

end

--设置数字
function SetSingo:setNum(Num,FontType,FontSize)

    local GetNum = self:changeForNum(Num)
    local NumFontType = FontType 
    local NumFontSize = FontSize 
    self:initView(GetNum,NumFontType,NumFontSize)

end

--设置为宁
function SetSingo:setWin(Num,FontType,FontSize)

    local GetNum = self:changeForWin(Num)
    local NumFontType = FontType 
    local NumFontSize = FontSize 
    self:initView(GetNum,NumFontType,NumFontSize)

end

--设置为输

function SetSingo:setLose(Num,FontType,FontSize)

    local GetNum = self:changeForLose(Num)
    local NumFontType = FontType 
    local NumFontSize = FontSize 
    self:initView(GetNum,NumFontType,NumFontSize)

end



--初始化界面
function SetSingo:initView(figure,FontType,FontSize)


    local length = string.len(figure)
    local temp = {}
    for i = 1, length  do

        table.insert(temp,i,string.sub(figure,i,i))

    end 

    local timeSpriteTable = {}

    for i=1, #temp do


        table.insert(timeSpriteTable,i,cc.Sprite:create(FontType..temp[i]..".png"))


    end
  

    for i=1, #timeSpriteTable  do


        if i == 1 then

           
            local posHeight  =  timeSpriteTable[i]:getBoundingBox().height
            timeSpriteTable[i]:setScale(FontSize/posHeight)
            timeSpriteTable[i]:setPosition(cc.p(0,0))
            self:addChild(timeSpriteTable[i])
        else  
            
            local posHeight  =  timeSpriteTable[i]:getContentSize().height
            timeSpriteTable[i]:setScale(FontSize/posHeight)
            local posWidth = timeSpriteTable[i-1]:getBoundingBox().width
            timeSpriteTable[i]:setPosition((cc.p(timeSpriteTable[i-1]:getPositionX()+posWidth/2+timeSpriteTable[i]:getBoundingBox().width/2,timeSpriteTable[i-1]:getPositionY())))
            self:addChild(timeSpriteTable[i])


        end

    end



end

return SetSingo