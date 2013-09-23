if _VERSION ~= "Luaj-jse 2.0.3" then
	require("CoordTracker")
	require("ShapeInfo")
end

DOWN = "down"
UP = "up"
FRONT = "front"

FarmBuilder = {}

function FarmBuilder:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   o.coordTracker = CoordTracker:new(0,0,0, CoordTracker.DIR.Y_PLUS)
   return o
end

function FarmBuilder:listMethods()
   local methods = {}
   for name,originalFunction in pairs(self) do
      methods[name] = originalFunction
   end

   for name,originalFunction in pairs(getmetatable(self)) do
      methods[name] = originalFunction
   end

   --forbidden symbols
   methods["__index"] = nil
   methods["new"] = nil
   methods["listMethods"] = nil

   return methods
end

function FarmBuilder:turnLeft()
   turtle.turnLeft()
   self.coordTracker:turnLeft()
end

function FarmBuilder:turnRight()
   turtle.turnRight()
   self.coordTracker:turnRight()
end

function FarmBuilder:moveForward()
   local res = self:_cycle(function() return turtle.forward() end)
   if res then self.coordTracker:moveForward() end
   return res
end

function FarmBuilder:moveBack()
   local res = self:_cycle(function() return turtle.back() end)
   if res then self.coordTracker:moveBack() end
   return res
end

function FarmBuilder:moveUp()
   local res = self:_cycle(function() return turtle.up() end)
   if res then self.coordTracker:moveUp() end
   return res
end

function FarmBuilder:moveDown()
   local res = self:_cycle(function() return turtle.down() end)
   if res then self.coordTracker:moveDown() end
   return res
end

function FarmBuilder:_cycle(f)
   local count = 10

   repeat
     sleep(1)
     count = count - 1
   until f() or count == 0

   return count > 0 -- if count >0, then we were successful
end

function FarmBuilder:dig(item)
   self:_doWithItem(item, turtle.dig, true)
end

function FarmBuilder:digUp(item)
   self:_doWithItem(item, turtle.digUp, true)
end

function FarmBuilder:digDown(item)
   self:_doWithItem(item, turtle.digDown, true)
end

function FarmBuilder:suck(item)
   self:_doWithItem(item, turtle.suck, true)
end

function FarmBuilder:suckUp(item)
   self:_doWithItem(item, turtle.suckUp, true)
end

function FarmBuilder:suckDown(item)
   self:_doWithItem(item, turtle.suckDown, true)
end

function FarmBuilder:discardDig(digDirection)
   print("DisacrdDig")
   print("Item: ", ITEM)
   print("ITEM.EMPTY: ", s(ITEM.EMPTY.slot))

   local digDirections
   if (type(digDirection) == "string") then
      digDirections = {digDirection}
   else
      digDirections = digDirection
   end

   for _, digDirection in ipairs(digDirections) do
	   self:_chooseSlotByItem(ITEM.EMPTY)
	   turtle.drop()

	   if digDirection == DOWN then
		  turtle.digDown()
		  turtle.dropDown()
	   elseif digDirection == UP then
		  turtle.digUp()
		  turtle.dropUp()
	   elseif digDirection == FRONT then
		  turtle.dig()
		  turtle.drop()
	   else
		  error("Unknown dig direction: "..digDirection)
	   end
   end
end

function FarmBuilder:place(item)
   self:_doWithItem(item, turtle.place)
end

function FarmBuilder:placeUp(item)
   self:_doWithItem(item, turtle.placeUp)
end

function FarmBuilder:placeDown(item)
   self:_doWithItem(item, turtle.placeDown)
end

function FarmBuilder:dropDown(item, doNotFail)
   self:_doWithItem(item, turtle.dropDown, doNotFail)
end

function FarmBuilder:_doWithItem(item, funcToDo, doNotFail)
   self:_chooseSlotByItem(item)

   if not funcToDo() and doNotFail ~= true then
      error("Operation with "..item.name.." failed")
   end
end

function FarmBuilder:_chooseSlotByItem(item)
   assert(item ~= nil, "Item must not be nil")
   turtle.select(item.slot)
end


function FarmBuilder:takeFromChest(item, count)
    if (count == nil) then
	   count = 64
	end
	local chest = peripheral.wrap("bottom")
	for slotNumber = 0, 26 do
	   local slotContents = chest.getStackInSlot(slotNumber)
	   if slotContents ~= nil and item.uuid == uuid(slotContents.id, slotContents.dmg) then
	      chest.pushIntoSlot("up", slotNumber, count, item.slot-1) -- openperipherals count slots from 0
		  return true
	   end
	end
	return false
end


function FarmBuilder:_resupply()
    self:discardDig(DOWN)
	self:placeDown(ITEM.CHEST_IN)
	for name, item in pairs(ITEM) do
	   --print("Considering "..name)
	   if item.alwaysClearDuringResupply or (item.minAmount ~= nil and turtle.getItemCount(item.slot)<= item.minAmount) then
	      if item.alwaysClearDuringResupply then
	      	self:dropDown(item)
	      end
	      local weHave = turtle.getItemCount(item.slot)
		  local weShouldHave = item.restockAmount
		  while(weHave < weShouldHave) do
		     self:takeFromChest(item,weShouldHave-weHave)
			 weHave = turtle.getItemCount(item.slot)
			 sleep(0.3)
		  end
	   end
	end
	self:digDown(ITEM.CHEST_IN)
	
	-- now we discard any items that require this - be careful with this setting
	for name, item in pairs(ITEM) do
	   if item.discardDuringResupply then
	   		self:dropDown(item, true)
	   end
	end
end

function FarmBuilder:_checkFuel()
   if turtle.getFuelLevel()<400 then
      self:discardDig(DOWN)
	  self:placeDown(ITEM.CHEST_IN)
	  self:takeFromChest(ITEM.CHARCOAL, 10)
	  self:_chooseSlotByItem(ITEM.CHARCOAL)
	  turtle.refuel()
	  self:digDown(ITEM.CHEST_IN)
   end
end

function FarmBuilder:doLeftTurn(bool)
  if bool then
	 self:turnLeft()
  else
	 self:turnRight()
  end
end

function FarmBuilder:_clear3Layers()
   local leftTurn = true
   local linesLeft = 5
   while (linesLeft > 0) do
      linesLeft = linesLeft - 1
      for i = 1,4 do
	     self:discardDig({DOWN, FRONT, UP})
		 self:moveForward()
	  end

	  -- if more lines to do left, then move to next line
	  if (linesLeft > 0) then
	     self:doLeftTurn(leftTurn)
	     self:discardDig({DOWN, FRONT, UP})
	     self:moveForward()
	     self:doLeftTurn(leftTurn)
	     leftTurn = not(leftTurn)
	  else
	     self:discardDig({DOWN, UP})
	  end
	  self:_checkFuel()
   end
end

function FarmBuilder:placeAndConfigure(shapeInfo, moveDir)
   assert(shapeInfo ~= nil, "shapeInfo is nil")
   assert(moveDir ~= nil, "moveDir is nil")
   --print("My current:"..self.coordTracker:getCoords():tostring())
   local coord = self.coordTracker:coordOf(moveDir)
   --print("Target coord:"..coord:tostring())
   local item = shapeInfo:getV(coord)
   if item ~= nil then
      --print("Target item:"..item.name)
	  self[moveDir.place](self, item)
	  if item.tesseractConfig ~= nil then
		 local p = peripheral.wrap(moveDir.wrap)
		 assert(p ~= nil, "Peripheral not found")
		 local result = p.setFrequency(item.tesseractConfig.freq)
		 if (p.setMode ~= nil) then
		 	p.setMode("RECEIVE")
		 end
		 if not(result) then
		 	print("Configuration of "..item.name.." failed")
		 end
	  end
   end
end

function FarmBuilder:placeAndMove(shapeInfo)
   assert(shapeInfo ~= nil, "shapeInfo is nil")
   self:placeAndConfigure(shapeInfo, CoordTracker.MOVE_DIR.UP)
   self:placeAndConfigure(shapeInfo, CoordTracker.MOVE_DIR.DOWN)
   self:moveBack()
   self:placeAndConfigure(shapeInfo, CoordTracker.MOVE_DIR.FORWARD)
end

function FarmBuilder:moveTo(targetCoord, callbackParam)
	local whereTo = targetCoord - self.coordTracker:getCoords()
	local moveCallback = callbackParam or function() end
	for i = 1,math.abs(whereTo.z) do
		if(whereTo.z<0) then
			self:moveDown()
		end
		if(whereTo.z>0) then
			self:moveUp()
		end
		whereTo = targetCoord - self.coordTracker:getCoords()
	end

	if (whereTo.y ~= 0) then

		local correctDirection
		if (whereTo.y > 0) then
			correctDirection = CoordTracker.DIR.Y_PLUS
		else
			correctDirection = CoordTracker.DIR.Y_MINUS
		end

		for _ = 1,4 do
			if self.coordTracker:getDirection().name ~= correctDirection.name then
				self:turnRight()
			end
		end

		for _ = 1,math.abs(whereTo.y) do
			self:moveForward()
			moveCallback(self)
		end
	end

	if (whereTo.x ~= 0) then

		local correctDirection
		if (whereTo.x > 0) then
			correctDirection = CoordTracker.DIR.X_PLUS
		else
			correctDirection = CoordTracker.DIR.X_MINUS
		end

		for _ = 1,4 do
			if self.coordTracker:getDirection().name ~= correctDirection.name then
				self:turnRight()
			end
		end

		for _ = 1,math.abs(whereTo.x) do
			self:moveForward()
			moveCallback(self)
		end
	end
end


function FarmBuilder:autoBuild(shapeInfo, coordTracker)
	self.coordTracker = coordTracker
	local minV,maxV = shapeInfo:getBorderCubeCoords()
	local maxZ, minZ = maxV.z, minV.z
	local d = vector.new(0,0,1)

	for z = maxZ, minZ, -1 do
		local path = Pathfinder.calculatePath(coordTracker, shapeInfo, z)
		
		if #path > 0 then
			self:moveTo(path[1]-d)
			self:placeAndConfigure(shapeInfo, CoordTracker.MOVE_DIR.UP)
			for i = 2, #path do
				self:moveTo(path[i]-d, function() 
					self:placeAndConfigure(shapeInfo, CoordTracker.MOVE_DIR.UP)
				end)
				self:_resupply()
				self:_checkFuel()
			end
		end
	end
end


function FarmBuilder:buildFarm()
   -- Building 5x5x4 farm
   -- Turtle starts at south eastern top corner of the farm - just above the farm level.
   -- South-eastern is relative to turtle current facing
   --  Top view			Side view					Top view z=1    Soil layers
   -- +y			|+z                          |  +y            | E
   --5FFFFF			|4FFFFF                      |  5FFFFF        | S
   -- FFFFF			| FFFFF                      |   FFFFF        |  BFFFFFB
   -- FFFFF			| FFFFF                      |   FFGFH        | E FFFFF
   -- FFFFF			| FFXFX <= functional blocks |   FFVFH        | S FFFFF
   --1FFFFF +x		|0  T T <= tesseracts etc    |  1FFHFH +x     |  BFFFFFB
   --01   X<--turtle is on 5,0,5 coord           |  01            |     T T
   --                                                               E
   --                                                               S

   self:_resupply()

   --- @{#ShapeInfo}
   local shapeInfo = ShapeInfo:new()
   for z = 1,4 do
      shapeInfo:fillZLayer(1,5,1,5,z,ITEM.FARM_BLOCK)
   end
   -- functional farm blocks
   shapeInfo:put(5,1,1,ITEM.FARM_HATCH)
   shapeInfo:put(5,2,1,ITEM.FARM_HATCH)
   shapeInfo:put(5,3,1,ITEM.FARM_HATCH)
   shapeInfo:put(3,1,1,ITEM.FARM_HATCH)
   shapeInfo:put(3,2,1,ITEM.FARM_VALVE)
   shapeInfo:put(3,3,1,ITEM.FARM_GEARBOX)
   -- functional non-farm blocks
   shapeInfo:put(5,1,0,ITEM.ITEM_TESSERACT_1)
   shapeInfo:put(5,2,0,ITEM.ITEM_TESSERACT_2)
   shapeInfo:put(5,3,0,ITEM.ITEM_TESSERACT_3)
   shapeInfo:put(3,1,0,ITEM.ENDER_CHEST)
   shapeInfo:put(3,2,0,ITEM.WATER_TESSERACT)
   shapeInfo:put(3,3,0,ITEM.ENERGY_TESSERACT)
   --
   shapeInfo:layoutFarm(1,1, 1, 5,5, 6, ITEM.STONE_BRICK)
   shapeInfo:layoutFarm(1,1, 4, 5,5, 6, ITEM.STONE_BRICK)

   self:autoBuild(shapeInfo, CoordTracker:new(5,0,5, CoordTracker.DIR.Y_PLUS))
end

------------------------- Unit tests
function FarmBuilder.unitTest_automove()
	require("luaunit")
	local vector = require("vector")

	local function v(x,y,z)
		return vector.new(x,y,z)
	end

	-- commands turtle to move to the target point from starting coordinate specified by CoordTracker
	function FarmBuilder._testMoveTo(target, startingCoordTracker)
		if startingCoordTracker == nil then
			startingCoordTracker = CoordTracker:new(0,0,0, CoordTracker.DIR.X_PLUS)
		end

		local f = FarmBuilder:new()
		f.coordTracker = startingCoordTracker

		f:moveTo(target)
		assertEquals(f.coordTracker:getCoords(), target)
	end

	function FarmBuilder.automoveTestMoveDown()
		FarmBuilder._testMoveTo(v(0,0,-3))
	end

	function FarmBuilder.automoveTestMoveUp()
		FarmBuilder._testMoveTo(v(0,0,3))
	end

	function FarmBuilder.automoveTestGoToYWithTurn()
		FarmBuilder._testMoveTo(v(0,3,0))
		FarmBuilder._testMoveTo(v(0,-3,0))
	end

	function FarmBuilder.automoveTestGoToYWithoutTurn()
		FarmBuilder._testMoveTo(v(0,3,0), CoordTracker:new(0,0,0, CoordTracker.DIR.Y_PLUS))
		FarmBuilder._testMoveTo(v(0,-3,0), CoordTracker:new(0,0,0, CoordTracker.DIR.Y_MINUS))
	end

	function FarmBuilder.automoveTestGoToXWithTurn()
		FarmBuilder._testMoveTo(v(0,3,0), CoordTracker:new(0,0,0, CoordTracker.DIR.Y_PLUS))
		FarmBuilder._testMoveTo(v(0,-3,0), CoordTracker:new(0,0,0, CoordTracker.DIR.Y_PLUS))
	end

	function FarmBuilder.automoveTestGoToXWithoutTurn()
		FarmBuilder._testMoveTo(v(3,0,0), CoordTracker:new(0,0,0, CoordTracker.DIR.X_PLUS))
		FarmBuilder._testMoveTo(v(-3,0,0), CoordTracker:new(0,0,0, CoordTracker.DIR.X_MINUS))
	end

	function FarmBuilder.automoveTestGoToAny()
		FarmBuilder._testMoveTo(v(4,3,-5))
	end

	function FarmBuilder.automoveTestMoveWithCallback()
		local f = FarmBuilder:new()
		local callbackCalledTimes = 0

		f.coordTracker = CoordTracker:new(0,0,0, CoordTracker.DIR.X_PLUS)

		f:moveTo(v(0,3,0), function(farmBuilder)
			assert(farmBuilder ~= nil)
			callbackCalledTimes = callbackCalledTimes + 1
		end
		)

		assertEquals(callbackCalledTimes, 3)
	end

	for name, func in pairs(FarmBuilder) do
		if string.starts(name, "automoveTest") then
			print("Running "..name)
			func()
		end
	end

	print("unitTest_automove ok")
end

function FarmBuilder.unitTest_autobuild()
	require("luaunit")
	require("minecraftCompat")
	require("MyAsserts")
	local vector = require("vector")
	local oldResupply = FarmBuilder._resupply
	FarmBuilder._resupply = function() end

	function FarmBuilder.helper_autobuildTest_setup()
		-- setup world emulation
		turtle.world = ShapeInfo:new()
		turtle.coord = CoordTracker:new(5,5,5, CoordTracker.DIR.X_PLUS)
		turtle.slotContents[1] = ItemStack:new("A", 10)

		-- setup our turtle model
		local fb = FarmBuilder:new()

		local request = ShapeInfo:new()
		local currentCoordFb = CoordTracker:new(5,5,5, CoordTracker.DIR.X_PLUS)
		return fb, request, currentCoordFb
	end

	function FarmBuilder.autobuildTest_onePoint()
		local fb, request, currentCoordFb = FarmBuilder.helper_autobuildTest_setup()

		request:put(0,0,0, {slot=1})

		fb:autoBuild(request, currentCoordFb)
		assertEquals(turtle.coord:getCoords(), vector.new(0,0,-1))
		assertEquals(turtle.world:get(0,0,0), "A")
	end


	function FarmBuilder.autobuildTest_twoPoints()
		local fb, request, currentCoordFb = FarmBuilder.helper_autobuildTest_setup()

		request:put(0,0,0, {slot=1})
		request:put(-2,0,0, {slot=1})

		fb:autoBuild(request, currentCoordFb)
		assertEquals(turtle.coord:getCoords(), vector.new(-2,0,-1))
		assertEquals(turtle.world:get(0,0,0), "A")
		assertEquals(turtle.world:get(-1,0,0), nil)
		assertEquals(turtle.world:get(-2,0,0), "A")
	end
	
	function FarmBuilder.autobuildTest_oneLine()
		local fb, request, currentCoordFb = FarmBuilder.helper_autobuildTest_setup()

		request:put(0,0,0, {slot=1})
		request:put(-1,0,0, {slot=1})
		request:put(-2,0,0, {slot=1})

		fb:autoBuild(request, currentCoordFb)
		assertEquals(turtle.coord:getCoords(), vector.new(-2,0,-1))
		assertEquals(turtle.world:get(0,0,0), "A")
		assertEquals(turtle.world:get(-1,0,0), "A")
		assertEquals(turtle.world:get(-2,0,0), "A")
	end

	function FarmBuilder.autobuildTest_square()
		local fb, request, currentCoordFb = FarmBuilder.helper_autobuildTest_setup()

		request:put(0,0,0, {slot=1})
		request:put(-3,0,0, {slot=1})
		request:put(-2,2,0, {slot=1})
		request:put(0,1,0, {slot=1})

		fb:autoBuild(request, currentCoordFb)
		assertEquals(turtle.world:get(0,0,0), "A")
		assertEquals(turtle.world:get(-3,0,0), "A")
		assertEquals(turtle.world:get(-2,2,0), "A")
		assertEquals(turtle.world:get(0,1,0), "A")
	end
	
	function FarmBuilder.autobuildTest_multiZ()
		local fb, request, currentCoordFb = FarmBuilder.helper_autobuildTest_setup()

		request:put(0,0,1, {slot=1, name="A"})
		request:put(-3,0,3, {slot=1, name="A"}) -- by this we test empty layer handling (layer 2)
		request:put(-2,2,0, {slot=1, name="A"})
		request:put(0,1,0, {slot=1, name="A"})

		fb:autoBuild(request, currentCoordFb)		
		assertEquals(turtle.world:get(-3,0,3), "A")
		assertEquals(turtle.world:get(0,0,1), "A")
		assertEquals(turtle.world:get(-2,2,0), "A")
		assertEquals(turtle.world:get(0,1,0), "A")
	end

 	for name, func in pairs(FarmBuilder) do
 		if string.starts(name, "autobuildTest_") then
 			print("Running "..name)
 			func()
 		end
 	end

	FarmBuilder._resupply = oldResupply
	
	print("unitTest_autobuild ok")
end
