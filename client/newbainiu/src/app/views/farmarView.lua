--
-- Author: Your Name
-- Date: 2015-09-12 13:50:07
--
local farmarView  = class("farmarView", ql.mvc.BaseView)
--全局定义
local globalDefine = import("..common.GlobalDefine")

function farmarView:onCreate(args)
	
	self._roomId = gamedata:getRoomId()
	self.roomConfig = getRoomConfig(self._roomId)
	self:getRoomType(self._roomId)
	if self.roomType then
	--初始化砝码
		self:initfarmar(self.roomType)
	--储存砝码
		self:loadFarmar(self.roomType)
	--显示砝码
		self:showFarmar(self.roomType)
 
    end

end

function farmarView:getRoomType(roomId)
 
	if tostring(roomId) == "101" then
     self.roomType = 1
	elseif tostring(roomId) == "102" then
     self.roomType = 2
	elseif tostring(roomId) == "103"  then
     self.roomType = 3
    elseif tostring(roomId)  == "-1"   then
     self:quickStart()
    end

end

function farmarView:quickStart()
	
	if gamedata:getPlayerCoins() >=0 and gamedata:getPlayerCoins() <  100000 then
       self.roomType = 1
    elseif gamedata:getPlayerCoins() >=100000 and gamedata:getPlayerCoins() <= 1000000  then 
       self.roomType = 2
    elseif gamedata:getPlayerCoins() >=1000000  then 
       self.roomType = 3
    end

end


function farmarView:initfarmar(roomType)
    
    local roomgenre = roomType
    print("房间类型"..roomgenre)
    local coinsNum = tonumber(gamedata:getPlayerCoins())/8
    local famarView = globalDefine.Room_FarmarImage[roomgenre]
    local roomCoinsData = globalDefine.Room_Data[roomgenre]
    local sortNumTable = {}
    for i=1,#roomCoinsData do
    
    	if  coinsNum >= tonumber(roomCoinsData[i]) then
            
            table.insert(sortNumTable,i,i)
        else

            table.insert(sortNumTable,1,1)

    	end	
    

    end 

    local lightIndex =  sortNumTable[#sortNumTable]
    self:findNodeByName("light_"..lightIndex):setVisible(true)
    self.farmarCoins = roomCoinsData[lightIndex]
 	self.farmarImage = famarView[lightIndex]

end


function farmarView:loadFarmar()

	self.farmarTable = {}
	for i=1,5 do
		table.insert(self.farmarTable,i,self:findNodeByName("farmar_"..i))
	end	

end

function farmarView:changeLight(roomType,coinsNum)
	
 local coinsNumTable = globalDefine.Room_Data[roomType]
 for k,v in pairs(coinsNumTable)  do

 	if v == coinsNum  then
    
    	local lightChange = k
    	for i=1,5 do
   
        	if lightChange == i then

        		self:findNodeByName("light_"..i):setVisible(true)
        	
        	else 

                self:findNodeByName("light_"..i):setVisible(false)

        	end
        
        end

 	end

 end

end


function farmarView:showFarmar(roomType)
	    
        local roomgenre = roomType
        local famarView = globalDefine.Room_FarmarImage[roomgenre]
        
  		for i=1,5 do
			

			self.farmarTable[i]:loadTexture(famarView[i],ccui.TextureResType.plistType)
			self:setOnViewClickedListener("farmar_"..i,function ()
			local lightIndex = i
			for j=1,5 do

 				if j==lightIndex then

 					self:findNodeByName("light_"..j):setVisible(true)
 					self.farmarImage = famarView[j]
 					self:loadFarmarData(j)

 				else
 				self:findNodeByName("light_"..j):setVisible(false)	

 				end

			end

		                                                end,nil,"none")

	    end
	



end


function farmarView:loadFarmarData(farmarIndex)
    
    local roomgenre = self.roomType 
    local roomCoinsData  = globalDefine.Room_Data[roomgenre]
	local farmarData = nil

	for i=1,5 do

		if i==farmarIndex then

			farmarData = roomCoinsData[i]

		end

	end


	if farmarData~= nil then

		self.farmarCoins = farmarData

	else	

		self.farmarCoins = 0

	end

end

function farmarView:getFarmarData()
	return self.farmarCoins
end


function farmarView:getFarmarTexture()

	if self.farmarImage ~= nil then

		return self.farmarImage

	else

        return 

	end

end

function farmarView:getFarmarImage(coinImage)
 
	local FarmarImage = "farmar/chip-"..coinImage.."-1.png" 
	return  FarmarImage

end

return farmarView