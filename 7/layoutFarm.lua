require("turtle")
require("FarmBuilder")

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

-- ====================================== TESTING END
turtle.testAll()
