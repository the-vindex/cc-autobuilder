---Source: https://raw.github.com/theoriginalbit/CC-Emu-Turtle/master/api
require("ShapeInfo")
require("CoordTracker")
local vector = require("vector")

_G.turtle = {}
turtle.native = {}
turtle.slotContents = {}
turtle.world = ShapeInfo:new()
turtle.coord = CoordTracker:new(0,0,0, CoordTracker.DIR.Y_PLUS)
turtle.currentSlot = 1

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

function turtle.native.place( text )
  return true
end

function turtle.native.placeUp()
  return true
end

function turtle.native.placeDown()
  return true
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

		--test successful move
		turtle.coord = CoordTracker:new(0,0,0, startingDir)
		turtle.world = ShapeInfo:new()

		assertEquals(callThis(), true)
		assertEquals(turtle.coord:getCoords(), expectedCoord)

		if not(testOnlyPositive) then
			--test blocked move
			turtle.coord = CoordTracker:new(0,0,0, startingDir)
			turtle.world = ShapeInfo:new()

			turtle.world:putV(obstacle.coord, obstacle.value)

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


	for name, func in pairs(turtle) do
		if string.starts(name, "unitTest_") then
			print("Running "..name)
			func()
		end
	end
end

-- ====================================== TESTING END

-- make copies
for k,v in pairs(turtle.native) do
  turtle[k] = v
end

