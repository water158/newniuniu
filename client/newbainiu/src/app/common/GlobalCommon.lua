--
-- Author: Han 
-- Date: 2015-08-17 17:16:19

--[[
此函数用来计算坐标中最小值
@param  无
@return 无
]]
local GlobalCommon = {}

function GlobalCommon.MIN(x,y)
    return (((x) > (y)) and (y) or (x))
end

--[[
此函数用来计算坐标中最大值
@param  无
@return 无
]]
function GlobalCommon.MAX(x,y)
    return (((x) < (y)) and (y) or (x))
end

--用来处理字符串
--[[
此函数是用来获取字符串的真实长度 utf8
@param  str 
@return 无
--]]
function GlobalCommon.stringStrlen(str)

    local len = #str;
    local left = len;
    local cnt = 0;
    local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc};
    while left ~= 0 do
        local tmp=string.byte(str,-left);
        local i=#arr;
        while arr[i] do
            if tmp>=arr[i] then left=left-i;break;end
            i=i-1;
        end
        cnt=cnt+1;
    end
    return cnt;
end


--[[
此函数是用来截取字符串
--@brief 切割字符串，并用“...”替换尾部
--@param sName:要切割的字符串，nMaxCount，字符串上限,中文字为2的倍数，nShowCount：显示英文字个数，中文字为2的倍数,可为空
--@return
--]]
function GlobalCommon.GetShortName(sName,nMaxCount,nShowCount)
    if sName == nil or nMaxCount == nil then
        return
    end
    local sStr = sName
    local tCode = {}
    local tName = {}
    local nLenInByte = #sStr
    local nWidth = 0
    if nShowCount == nil then
        nShowCount = nMaxCount - 3
    end
    for i=1,nLenInByte do
        local curByte = string.byte(sStr, i)
        local byteCount = 0;
        if curByte>0 and curByte<=127 then
            byteCount = 1
        elseif curByte>=192 and curByte<223 then
            byteCount = 2
        elseif curByte>=224 and curByte<239 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        end
        local char = nil
        if byteCount > 0 then
            char = string.sub(sStr, i, i+byteCount-1)
            i = i + byteCount -1
        end
        if byteCount == 1 then
            nWidth = nWidth + 1
            table.insert(tName,char)
            table.insert(tCode,1)

        elseif byteCount > 1 then
            nWidth = nWidth + 2
            table.insert(tName,char)
            table.insert(tCode,2)
        end
    end

    if nWidth > nMaxCount then
        local _sN = ""
        local _len = 0
        for i=1,#tName do
            _sN = _sN .. tName[i]
            _len = _len + tCode[i]
            if _len >= nShowCount then
                break
            end
        end
        sName = _sN 
    end
    print("字符串"..sName)
    return sName
end


--[[
用来转换为万
@param  无
@return 无
]]
function GlobalCommon.changeDigits(digitsData)
     
    local nums 
    if digitsData then
     nums = digitsData
    else
     nums = 0    
     return  nums 
    end
--转换为万
    if tonumber(nums) >= 100000000  then
    
        local  myriad = string.format("%.2f",nums/10000) 
        nums = myriad.."万"

    end
       return nums 

end


--[[
用来转换为万
@param  无
@return 无
]]
function GlobalCommon.changeDigitsForCoins(digitsData)
    
    if not digitsData then
     digitsData = 0 
    end
    
    local dataLen =  GlobalCommon.stringStrlen(tostring(digitsData))
    local nums = tonumber(digitsData)
    if (dataLen>=0) and (dataLen <= 9) then
--转换为万

        if nums >= 10000000   then  --千万进万
    
         local  myriad = string.format("%.2f",nums/10000) 
         nums = myriad.."万"
  

        end
        
   elseif dataLen  >  9  then
--转换为亿
         if nums >= 1000000000 then  --十亿进亿
         
           local  myriad = string.format("%.2f",nums/100000000) 
           nums = myriad.."亿"

         end  

   end

    return nums 

end


--[[
此函数用来随机出精灵坐标
@param  无
@return 无
]]
function GlobalCommon.Rectborder(node)
   
 --进行了微调 
    local posLeft = node:getPositionX() - node:getBoundingBox().width/2+20
 --进行了微调
    local posRight = node:getPositionX() + node:getBoundingBox().width/2-20
 --进行了微调
    local posTop = node:getPositionY() + node:getBoundingBox().height/2-45
 --进行了微调
    local posDown = node:getPositionY() - node:getBoundingBox().height/2+45
 
    local posX = math.random(posLeft,posRight)
    local posY = math.random(posDown,posTop)
 
    return posX, posY  
 
end


--[[
此函数用来随机出金币坐标
@param  无
@return 无
]]
function GlobalCommon.RandomCoins(node)
   
 --进行了微调 
    local posLeft = node:getPositionX() - node:getBoundingBox().width/2+20
 --进行了微调
    local posRight = node:getPositionX() + node:getBoundingBox().width/2-20
 --进行了微调
    local posTop = node:getPositionY() + node:getBoundingBox().height/2-45
 --进行了微调
    local posDown = node:getPositionY() - node:getBoundingBox().height/2+45
 
    local posX = math.random(posLeft,posRight)
    local posY = math.random(posDown,posTop)
 
    return posX, posY  
 
end


--[[
此函数用来进行微调
@param  无
@return 无
]]
function GlobalCommon.Adjust(node,posX,posY)
   
 --进行了微调 
    local posLeft = node:getPositionX() - node:getBoundingBox().width/2+20
    if posX <= posLeft then
       posX = posLeft     
    end
 --进行了微调
    local posRight = node:getPositionX() + node:getBoundingBox().width/2-20
    if posX >= posRight then
       posX = posRight
    end
 --进行了微调
    local posTop = node:getPositionY() + node:getBoundingBox().height/2-30
    if posY >= posTop then
        posY = posTop 
    end
 --进行了微调
    local posDown = node:getPositionY() - node:getBoundingBox().height/2+30 
    if posY <= posDown then
       posY = posDown 
    end
    local adjustX = math.random(1,10)
    local adjustY = math.random(3,12)
    if posX and posY then
 
        return posX+adjustX, posY+adjustY  

    end
 
end


--[[
此函数用来设置枚举类型
@param  无
@return 无
]]
function GlobalCommon.enum(t)
    local enumtable = {}
    local enumindex = 0
    local tmp,key,val
    for _,v in ipairs(t) do
        key,val = string.gmatch(v,"([%w_]+)[%s%c]*=[%s%c]*([%w%p%s]+)%c*")()
        if key then
            tmp = "return " .. string.gsub(val,"([%w_]+)",function (x) return enumtable[x] and enumtable[x] or x end)
            enumindex = loadstring(tmp)()
        else
            key = string.gsub(v,"([%w_]+)","%1");
        end
        enumtable[key] = enumindex
        enumindex = enumindex + 1
    end
    return enumtable
end


--[[
此函数当前的系统时间
@param  无
@return 无
]]
function GlobalCommon.getLocalSystemTime()

    local curtime = os.time()
    return curtime

end


--[[
判断点触摸到菱形里面
@param  rect菱形的rect point 触摸的点
@return 无
]]
function GlobalCommon.diamondContainsPoint(rect,point)

    local startX = rect.x;
    local startY = rect.y;

    local centerX= rect.x+rect.width*0.5
    local centerY= rect.y+rect.height*0.5

    local width = rect.width;
    local height = rect.height;

    local absoluteX = point.x - centerX
    local absoluteY = point.y - centerY

    local k=height/width


    if  (absoluteY-k*absoluteX >-height/2 and absoluteY-k*absoluteX <height/2 ) and
        (absoluteY+k*absoluteX >-height/2 and absoluteY+k*absoluteX <height/2 ) then 
        return true
    else 
        return false
    end

end

return  GlobalCommon