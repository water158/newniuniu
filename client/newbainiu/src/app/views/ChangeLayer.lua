local ChangeLayer  = class("ChangeLayer",ql.mvc.BaseView)
local this 

function ChangeLayer:onCreate(args)

  this = self  

end

function ChangeLayer:LoadrecordMsg(recordList)

  self.recordMsgList = recordList
  self.cellNum = table.getn(self.recordMsgList)
  self:initTableView()


end


--[[
创建pageview容器
@param  无
@return 无
]]
function ChangeLayer:initTableView()

  self.tableView = cc.TableView:create(cc.size(800,285))
  self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
  self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
  self.tableView:setPosition(cc.p(246,150))
  self.tableView:setDelegate()
  self:getRoot():addChild(self.tableView)
  self.tableView:registerScriptHandler(ChangeLayer.numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
  self.tableView:registerScriptHandler(ChangeLayer.scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
  self.tableView:registerScriptHandler(ChangeLayer.scrollViewDidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)
  self.tableView:registerScriptHandler(ChangeLayer.tableCellTouched,cc.TABLECELL_TOUCHED)
  self.tableView:registerScriptHandler(ChangeLayer.cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX) 
  self.tableView:registerScriptHandler(ChangeLayer.tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
  self.tableView:reloadData()
   
end


function ChangeLayer.scrollViewDidScroll(view)
    print("scrollViewDidScroll")
end

function ChangeLayer.scrollViewDidZoom(view)
    print("scrollViewDidZoom")
end

function ChangeLayer.tableCellTouched(table,cell)

    print("cell touched at index: " .. cell:getIdx())
   
end

function ChangeLayer.cellSizeForTable(table,idx)
   
  local cellwidth = 800
  local cellheight = 30
  print("表格宽为:"..cellwidth..",高为:"..cellheight)
  return cellheight,cellwidth

end

function ChangeLayer.tableCellAtIndex(table, idx)

  local strValue = string.format("%d",idx)
  local cell = table:dequeueCell()
  cell = cc.TableViewCell:new()
  this:Load_SeedItem(cell,idx)
  return cell

end

function ChangeLayer:Load_SeedItem(cell,idx)
  
  local content = display.newNode()
  local date = self.recordMsgList[idx+1].date
  local operate = self.recordMsgList[idx+1].operate
  local coins = self.recordMsgList[idx+1].coins
  --日期
  local dateText = ccui.Text:create(date,"Arial",25)
  dateText:setAnchorPoint(cc.p(0,0.5)) 
  dateText:setPosition(cc.p(40,0))
  dateText:setColor(cc.c3b(253, 210, 137))
  content:addChild(dateText)
  --操作
  local operateText = ccui.Text:create(operate,"Arial",25)
  operateText:setAnchorPoint(cc.p(0,0.5)) 
  operateText:setPosition(cc.p(300,0))
  operateText:setColor(cc.c3b(253, 210, 137))
  content:addChild(operateText)
  --金币
  local coinsText = ccui.Text:create(string.subComma(coins),"Arial",25)
  coinsText:setAnchorPoint(cc.p(0,0.5)) 
  coinsText:setPosition(cc.p(650,0))
  coinsText:setColor(cc.c3b(253, 210, 137))
  content:addChild(coinsText)
  cell:addChild(content)

end

function ChangeLayer.numberOfCellsInTableView(table)
   
  return  this.cellNum

end


return ChangeLayer