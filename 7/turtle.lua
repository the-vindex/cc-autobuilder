---Source: https://raw.github.com/theoriginalbit/CC-Emu-Turtle/master/api
require("ShapeInfo")
require("CoordTracker")
local vector = require("vector")

_G.ItemStack = {}

function ItemStack:new(itemType, count)
   local o = {}
   setmetatable(o, self)
   self.__index = self

   o.itemType = itemType
   o.count = count
   return o
end


_G.turtle = {}
turtle.native = {}
turtle.slotContents = {}
	for i = 1,16 do turtle.slotContents[i] = {} end

turtle.world = ShapeInfo:new()
turtle.coord = CoordTracker:new(0,0,0, CoordTracker.DIR.Y_PLUS)
turtle.activeSlot = 1

function turtle.native.craft( quantity )
  return false
end

local function canMoveIntoDirection(dir)
	return turtle.world:getV(turtle.coord:coordOf(dir)) == nil
end


function turtle.native.forward()
  if canMoveIntoDirection(CoordTracker.MOVE_DIR.FORWARD) then
    turtle.coord:moveForward()
    return true
  else
    return false
  end
end

function turtle.native.back()
  if canMoveIntoDirection(CoordTracker.MOVE_DIR.BACK) then
    turtle.coord:moveBack()
    return true
  else
    return false
  end
end

function turtle.native.down()
  if canMoveIntoDirection(CoordTracker.MOVE_DIR.DOWN) then
    turtle.coord:moveDown()
    return true
  else
    return false
  end
end

function turtle.native.up()
  if canMoveIntoDirection(CoordTracker.MOVE_DIR.UP) then
    turtle.coord:moveUp()
    return true
  else
    return false
  end
end

function turtle.native.turnLeft()
  turtle.coord:turnLeft()
  return true
end

function turtle.native.turnRight()
  turtle.coord:turnRight()
  return true
end

function turtle.native.select( slot ) -- I don't think this needs implementing
  if slot < 0 or slot > 16 then error('Slot out of bounds of inventory: '..slot, 2) end
  return true
end

function turtle.native.getItemCount( slot )
  if slot < 0 or slot > 16 then error('Slot out of bounds of inventory: '..slot, 2) end
  return math.random(0, 64)
end

function turtle.native.getItemSpace( slot )
  if slot < 0 or slot > 16 then error('Slot out of bounds of inventory: '..slot, 2) end
  return math.random(0, 64)
end

function turtle.native.attack()
  return true
end

function turtle.native.attackUp()
  return true
end

function turtle.native.attackDown()
  return true
end

function turtle.native.dig()
  return true
end

function turtle.native.digUp()
  return true
end

function turtle.native.digDown()
  return true
end

function turtle.native._placeInner(dir)
  local itemStack = turtle.slotContents[turtle.activeSlot]
  if itemStack.count == nil or itemStack.count == 0 then
	return false
  end

  --check for block
  if not(canMoveIntoDirection(dir)) then
	return false
  end

  turtle.world:putV(turtle.coord:coordOf(dir), itemStack.itemType)
  itemStack.count = itemStack.count - 1
  return true
end

function turtle.native.place( text )
  return turtle._placeInner(CoordTracker.MOVE_DIR.FORWARD)
end

function turtle.native.placeUp()
  return turtle._placeInner(CoordTracker.MOVE_DIR.UP)
end

function turtle.native.placeDown()
  return turtle._placeInner(CoordTracker.MOVE_DIR.DOWN)
end

function turtle.native.detect()
  return false
end

function turtle.native.detectUp()
  return false
end

function turtle.native.detectDown()
  return false
end

--~ function turtle.native.compare()
--~   return (math.random(1, 2) == 1) -- 50% chance of being the same
--~ end

--~ function turtle.native.compareUp()
--~   return (math.random(1, 2) == 1) -- 50% chance of being the same
--~ end

--~ function turtle.native.compareDown()
--~   return (math.random(1, 2) == 1) -- 50% chance of being the same
--~ end

--~ function turtle.native.compareTo( slot )
--~   if slot < 0 or slot > 16 then error('Slot out of bounds of inventory: '..slot, 2) end
--~   return (math.random(1, 10) == 4) -- 10% chance of being the same
--~ end

function turtle.native.drop( amount )
  return true
end

function turtle.native.dropUp( amount )
  return true
end

function turtle.native.dropDown( amount )
  return true
end

--~ function turtle.native.suck()
--~   return true
--~ end

--~ function turtle.native.suckUp()
--~   return true
--~ end

--~ function turtle.native.suckDown()
--~   return true
--~ end

function turtle.native.refuel( amount )
  amount = math.min(amount, turtle.slotContents[turtle.activeSlot])
  turtle.fuelLevel = turtle.fuelLevel + (amount * 80) -- emulate coal
  turtle.slotContents[turtle.activeSlot] = turtle.slotContents[turtle.activeSlot] - amount
  return true
end

function turtle.native.getFuelLevel()
  return math.random(0, 40960)
end

function turtle.native.transferTo( slot, amount )
  if slot < 0 or slot > 16 then error('Slot out of bounds of inventory: '..slot, 2) end
  return true
end

-- make copies
for k,v in pairs(turtle.native) do
  turtle[k] = v
end

-- ====================================== TESTING

function turtle.testAll()
	require("minecraftCompat")
	require("MyAsserts")
	local luaunit = require("luaunit")
	local vector = require("vector")
	local function v(x,y,z)
		return vector.new(x,y,z)
	end


	function turtle.helper_unitTest_move(params)
		local startingDir = params.startingDir or CoordTracker.DIR.X_PLUS
		local obstacle = params.obstacle
		local expectedCoord = params.expectedCoord
		local callThis = params.callThis
		local testOnlyPositive = params.testOnlyPositive
		local testOnlyNegative = params.testOnlyNegative

		if not(testOnlyNegative) then
			--test successful move
			turtle.coord = CoordTracker:new(0,0,0, startingDir)
			turtle.world = ShapeInfo:new()

			assertEquals(callThis(), true)
			assertEquals(turtle.coord:getCoords(), expectedCoord)
		end

		if not(testOnlyPositive) then
			--test blocked move
			turtle.coord = CoordTracker:new(0,0,0, startingDir)
			turtle.world = ShapeInfo:new()

			if obstacle ~= nil then
				turtle.world:putV(obstacle.coord, obstacle.value)
			end

			assertEquals(callThis(), false)
			assertEquals(turtle.coord:getCoords(), v(0,0,0))
		end
	end


	function turtle.unitTest_moveForward()

		turtle.helper_unitTest_move({
			callThis = turtle.forward,
			expectedCoord = v(1,0,0),
			obstacle = {coord = v(1,0,0), value = "A"}
		})
	end

	function turtle.unitTest_moveBack()

		turtle.helper_unitTest_move({
			callThis = turtle.back,
			expectedCoord = v(-1,0,0),
			obstacle = {coord = v(-1,0,0), value = "A"}
		})
	end

	function turtle.unitTest_moveUp()

		turtle.helper_unitTest_move({
			callThis = turtle.up,
			expectedCoord = v(0,0,1),
			obstacle = {coord = v(0,0,1), value = "A"}
		})
	end

	function turtle.unitTest_moveDown()

		turtle.helper_unitTest_move({
			callThis = turtle.down,
			expectedCoord = v(0,0,-1),
			obstacle = {coord = v(0,0,-1), value = "A"}
		})
	end

	function turtle.unitTest_turnRight()

		turtle.helper_unitTest_move({
			callThis = turtle.turnRight,
			expectedCoord = v(0,0,0),
			testOnlyPositive = true
		})

		assertEquals(turtle.coord:getDirection().name, CoordTracker.DIR.Y_MINUS.name)
	end

	function turtle.unitTest_turnLeft()

		turtle.helper_unitTest_move({
			callThis = turtle.turnLeft,
			expectedCoord = v(0,0,0),
			testOnlyPositive = true
		})

		assertEquals(turtle.coord:getDirection().name, CoordTracker.DIR.Y_PLUS.name)
	end

	function turtle.helper_unitTest_place_ok(callThis, targetCoord)

		turtle.activeSlot = 1
		turtle.slotContents[1] = ItemStack:new("X", 10)

		turtle.helper_unitTest_move({
			callThis = callThis,
			expectedCoord = v(0,0,0),
			testOnlyPositive = true
		})

		assertEquals(turtle.world:getV(targetCoord), "X")
		assertEquals(turtle.slotContents[1].count, 9)
	end

	function turtle.helper_unitTest_place_failsIfSlotEmpty(callThis,targetCoord)

		turtle.activeSlot = 1
		turtle.slotContents[1] = {}

		turtle.helper_unitTest_move({
			callThis = callThis,
			expectedCoord = v(0,0,0),
			testOnlyNegative = true
		})

		assertEquals(turtle.world:getV(targetCoord), nil)
		assertEquals(turtle.slotContents[1].count, nil)
	end

	function turtle.helper_unitTest_place_failsSpaceOccupied(callThis,targetCoord)

		turtle.activeSlot = 1
		turtle.slotContents[1] = ItemStack:new("X", 10)

		turtle.helper_unitTest_move({
			callThis = callThis,
			expectedCoord = v(0,0,0),
			obstacle = {coord = targetCoord, value = "A"},
			testOnlyNegative = true
		})

		assertEquals(turtle.world:getV(targetCoord), "A")
		assertEquals(turtle.slotContents[1].count, 10)
	end

	function turtle.helper_unitTest_place(func,targetCoord)
		turtle.helper_unitTest_place_ok(func,targetCoord)
		turtle.helper_unitTest_place_failsIfSlotEmpty(func,targetCoord)
		turtle.helper_unitTest_place_failsSpaceOccupied(func,targetCoord)
	end

	function turtle.unitTest_place_forward()
		turtle.helper_unitTest_place(turtle.place, v(1,0,0))
	end

	function turtle.unitTest_place_down()
		turtle.helper_unitTest_place(turtle.placeDown, v(0,0,-1))
	end

	function turtle.unitTest_place_up()
		turtle.helper_unitTest_place(turtle.placeUp, v(0,0,1))
	end

	for name, func in pairs(turtle) do
		if string.starts(name, "unitTest_") then
			print("Running "..name)
			func()
		end
	end
end
