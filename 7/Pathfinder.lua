vector = require("vector")
require("ShapeInfo")
require("CoordTracker")
require("MyAsserts")

Pathfinder = {}

function Pathfinder.calculatePath(coord, shape, z)
	local v = Pathfinder.v
	local minV, maxV = shape:getBorderCubeCoords(z)
	local path = {}
	function addPath(point)
		path[#path+1] = point
	end

	--expects vectors
	local function addUniquePoint(array, newValue)
		for _, value in ipairs(array) do
			if vectorEquals(value, newValue) then
				return
			end
		end
		array[#array + 1] = newValue
	end

	local function findClosestPoint(myPoint, pointArray)
		local minIndex, minDist = nil, 10000000

		for i, point in ipairs(pointArray) do
			if (point ~= nil ) then
				local currentDist = (myPoint - point):length()
				if  currentDist < minDist then
					minIndex, minDist = i, currentDist
				end
			end
		end
		return minIndex, pointArray[minIndex]
	end

	function math.sign(value)
		if value == 0 then
			return 0
		else
			return value/math.abs(value)
		end
	end

	local function arrayContainsVector(array, vect)
		for _, value in ipairs(array) do
			if vectorEquals(vect,value) then
				return true
			end
		end
		return false
	end
	--v(maxV.x,minV.y,maxV.z), v(maxV.y,minV.x,maxV.z), v(minV.x,minV.y,maxV.z)

	local function calculateOpositeCornerIndex(index)
		return ((index - 1 + 2) % 4) + 1 -- its modulo 4, but we start at 1... so it's more complex
	end

	local topCorners = {}

	--  2FFFF3
	--  FFFFFF
	--  FFFFFF
	--  1FFFF4
	topCorners[1]=v(minV.x,minV.y,maxV.z)
	topCorners[2]=v(minV.x,maxV.y,maxV.z)
	topCorners[3]=v(maxV.x,maxV.y,maxV.z)
	topCorners[4]=v(maxV.x,minV.y,maxV.z)

	local rangeX = math.abs(maxV.x - minV.x)
	local rangeY = math.abs(maxV.y - minV.y)

	local startingPointIndex, startingPoint = findClosestPoint(coord:getCoords(), topCorners)
	addPath(startingPoint)

	local targetPointIndex = calculateOpositeCornerIndex(startingPointIndex)
	local targetPoint = topCorners[targetPointIndex]
	local direction = targetPoint - startingPoint
	local stepX = v(1,0,0) * math.sign(direction.x)
	local stepY = v(0,1,0) * math.sign(direction.y)

	local stepOuter, stepInner, rangeOuter

	if rangeX>rangeY then
		stepOuter, stepInner, rangeOuter = stepY, stepX * rangeX, rangeY
	else
		stepOuter, stepInner, rangeOuter = stepX, stepY * rangeY, rangeX
	end

	local current = startingPoint

	local innerReverse = 1

	if (rangeOuter % 2 == 1) then
		local nextPointIndex, _ = findClosestPoint(current + stepInner * innerReverse, topCorners)
		targetPoint = topCorners[calculateOpositeCornerIndex(nextPointIndex)]
	end

	while not(vectorEquals(current,targetPoint)) do
		current = current + stepInner * innerReverse
		addUniquePoint(path,current)

		if not(vectorEquals(current,targetPoint)) then
			current = current + stepOuter
			addUniquePoint(path,current)
		end
		innerReverse = innerReverse * -1
	end

	return path
end

function Pathfinder.v(x,y,z)
   return vector.new(x,y,z)
end

function Pathfinder.unitTests()
	local luaunit = require("luaunit")
	local v = Pathfinder.v
	local calculatePath = Pathfinder.calculatePath

	local function testGoToCoordinate()
		local c = CoordTracker:new(2,2,2, CoordTracker.DIR.Y_PLUS)
		local s = ShapeInfo:new()
		s:put(0,0,0,"T")

		local path = calculatePath(c, s, 0)

		local expected = {v(0,0,0)}

		assertEquals(path, expected)
	end

	local function testDoOneLine()
		local s = ShapeInfo:new()
		s:put(0,0,0,"T")
		s:put(5,0,0,"T")

		local path = calculatePath(CoordTracker:new(2,2,2, CoordTracker.DIR.Y_PLUS), s, 0)
		local expected = {v(0,0,0), v(5,0,0)}
		assertEquals(path, expected)

		local path = calculatePath(CoordTracker:new(4,4,2, CoordTracker.DIR.Y_PLUS), s, 0)
		local expected = {v(5,0,0),v(0,0,0)}
		assertEquals(path, expected)
	end

	local function testSmallSquare()
		local s = ShapeInfo:new()
		s:fillZLayer(0,1,0,1,0,"F")
		s:printFarm()

		-- if no direction is better, we prefer to move along Y axis
		local path = calculatePath(CoordTracker:new(-1,-1,0, CoordTracker.DIR.Y_PLUS), s, 0)
		local expected = {v(0,0,0), v(0,1,0), v(1,1,0), v(1,0,0)}
		assertEquals(path, expected)
	end

	local function testSmallRectangle()
		local s = ShapeInfo:new()
		s:fillZLayer(0,5,0,1,0,"F")
		s:printFarm()

		-- if no direction is better, we prefer to move along Y axis
		local path = calculatePath(CoordTracker:new(-1,-1,0, CoordTracker.DIR.Y_PLUS), s, 0)
		local expected = {v(0,0,0), v(5,0,0), v(5,1,0), v(0,1,0)}
		assertEquals(path, expected)
	end


	local function testRectangle()
		local s = ShapeInfo:new()
		s:fillZLayer(0,5,0,2,0,"F")
		s:printFarm()

		-- if no direction is better, we prefer to move along Y axis
		local path = calculatePath(CoordTracker:new(-1,-1,0, CoordTracker.DIR.Y_PLUS), s, 0)
		local expected = {v(0,0,0), v(5,0,0), v(5,1,0), v(0,1,0), v(0,2,0), v(5,2,0)}
		assertEquals(path, expected)
	end

	testGoToCoordinate()
	testDoOneLine()
	testSmallSquare()
	testSmallRectangle()
	testRectangle()
end

return Pathfinder
