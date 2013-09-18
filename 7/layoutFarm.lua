require("turtle")
require("minecraftCompat")
require("FarmBuilder")
require("Pathfinder")
require("MyAsserts")
local luaunit = require("luaunit")

function FarmBuilder:moveTo(targetCoord)
	local whereTo = targetCoord - self.coordTracker:getCoords()
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
		end
	end
end

function FarmBuilder.unitTest_automove()

	local function v(x,y,z)
		return vector.new(x,y,z)
	end

	function FarmBuilder._testMoveTo(target, startingCoordTracker)
		if startingCoordTracker == nil then
			startingCoordTracker = CoordTracker:new(0,0,0, CoordTracker.DIR.X_PLUS)
		end

		local f = FarmBuilder:new()
		f.coordTracker = startingCoordTracker

		f:moveTo(target)
		assertEquals(f.coordTracker:getCoords(), target)
	end

	function FarmBuilder.testMoveDown()
		FarmBuilder._testMoveTo(v(0,0,-3))
	end

	function FarmBuilder.testMoveUp()
		FarmBuilder._testMoveTo(v(0,0,3))
	end

	function FarmBuilder.testGoToYWithTurn()
		FarmBuilder._testMoveTo(v(0,3,0))
		FarmBuilder._testMoveTo(v(0,-3,0))
	end

	function FarmBuilder.testGoToYWithoutTurn()
		FarmBuilder._testMoveTo(v(0,3,0), CoordTracker:new(0,0,0, CoordTracker.DIR.Y_PLUS))
		FarmBuilder._testMoveTo(v(0,-3,0), CoordTracker:new(0,0,0, CoordTracker.DIR.Y_MINUS))
	end

	function FarmBuilder.testGoToXWithTurn()
		FarmBuilder._testMoveTo(v(0,3,0), CoordTracker:new(0,0,0, CoordTracker.DIR.Y_PLUS))
		FarmBuilder._testMoveTo(v(0,-3,0), CoordTracker:new(0,0,0, CoordTracker.DIR.Y_PLUS))
	end

	function FarmBuilder.testGoToXWithoutTurn()
		FarmBuilder._testMoveTo(v(3,0,0), CoordTracker:new(0,0,0, CoordTracker.DIR.X_PLUS))
		FarmBuilder._testMoveTo(v(-3,0,0), CoordTracker:new(0,0,0, CoordTracker.DIR.X_MINUS))
	end

	function FarmBuilder.testGoToAny()
		FarmBuilder._testMoveTo(v(4,3,-5))
	end

	FarmBuilder.testMoveDown()
	FarmBuilder.testMoveUp()
	FarmBuilder.testGoToYWithTurn()
	FarmBuilder.testGoToYWithoutTurn()
	FarmBuilder.testGoToXWithTurn()
	FarmBuilder.testGoToXWithoutTurn()
	FarmBuilder.testGoToAny()
end

FarmBuilder.unitTest_automove()
