function FarmBuilder:_sendCommands(commands)
   -- for start let's assume turtle build from up down - so there is always space below
   self:discardDig(DOWN)
   self:placeDown(ITEM.DISK_DRIVE)
   self:dropDown(ITEM.FLOPPY)

   local d = peripheral.wrap("bottom")
   local file = fs.open(fs.combine("disk", COMMAND_FILE), "w")
   file.write(commands)
   file.close()

   self:suckDown(ITEM.FLOPPY)
   self:digDown(ITEM.DISK_DRIVE)

   self:placeDown(ITEM.CHEST_OUT)
   self:dropDown(ITEM.FLOPPY)
   self:digDown(ITEM.CHEST_OUT)
end

function FarmBuilder:_extractFromSorter(item)
   local sorter = peripheral.wrap("down")
   sorter.extract(0,item.uuid,1,1)
   _chooseSlotByItem(ITEM.EMPTY.slot)
   turtle.transferTo(item.slot)
end

function FarmBuilder:_requestItems(requestTable)
   local command = ""
   for k, v in pairs(requestTable) do
      command = command..itemName(k).."\n"..v.."\n"
   end

   return self:_sendCommands(command)
end

-- resupplies by sending a floppy disk to other turtle
function FarmBuilder:remoteResupply()
	local req = {}
	req[ITEM.STONE_BRICK] = 20
	req[ITEM.FARM_BLOCK] = 30
	self:_requestItems(req)

	self:placeDown(ITEM.CHEST_IN)
	while true do
	   local gotFloppy = self:takeFromChest(ITEM.FLOPPY)
	   if gotFloppy then
		  for item, count in pairs(req) do
			 self:takeFromChest(item,count)
		  end
		  break
	   end
	   sleep(1)
	end
	self:digDown(ITEM.CHEST_IN)
end
