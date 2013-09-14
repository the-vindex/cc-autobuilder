vector = require("vector")
require("ShapeInfo")
require("CoordTracker")
local luaunit = require("luaunit")

--local s = ShapeInfo:new()

--~ s:fillZLayer(1,5, 1,5, 5, "F")
--~ s:fillZLayer(2,4, 2,4, 4, "F")
--~ s:fillZLayer(2,4, 2,4, 3, "F")
--~ s:fillZLayer(1,5, 1,5, 2, "F")
--~ s:layoutFarm(1,1,3, 5,5, 5, "B")

--~ s:printFarm()

function calculatePath(coord, shape)
	local minV, maxV = shape:getBorderCubeCoords()
	local path = {}
	function addPath(point)
		path[#path+1] = point
	end

	function vectorEquals(a, b)
		assert(a ~= nil and b ~= nil, "Nil values not allowed")
		return (a-b):length() == 0
	end

	--expects vectors
	function addUniquePoint(array, newValue)
		for _, value in ipairs(array) do
			if vectorEquals(value, newValue) then
				return
			end
		end
		array[#array + 1] = newValue
	end

	function findClosestPoint(myPoint, pointArray)
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

	function arrayContainsVector(array, vect)
		for _, value in ipairs(array) do
			if vectorEquals(vect,value) then
				return true
			end
		end
		return false
	end
	--v(maxV.x,minV.y,maxV.z), v(maxV.y,minV.x,maxV.z), v(minV.x,minV.y,maxV.z)

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

	local targetPointIndex = ((startingPointIndex - 1 + 2) % 4) + 1 -- its modulo 4, but we start at 1... so it's more complex
	local targetPoint = topCorners[targetPointIndex]
	local direction = targetPoint - startingPoint
	local stepX = v(1,0,0) * math.sign(direction.x)
	local stepY = v(0,1,0) * math.sign(direction.y)

	local stepOuter, stepInner

	if rangeX>rangeY then
		stepOuter, stepInner = stepY, stepX * rangeX
	else
		stepOuter, stepInner = stepX, stepY * rangeY
	end

	local current = startingPoint
	local visitedCorners = {}

	local innerReverse = 1
	while #visitedCorners < 4 do
		current = current + stepInner * innerReverse
		addUniquePoint(path,current)

		if arrayContainsVector(topCorners,current) and not(arrayContainsVector(visitedCorners,current)) then
			visitedCorners[#visitedCorners + 1] = current
		end

		if #visitedCorners < 4 then
			current = current + stepOuter
			addUniquePoint(path,current)
		end
		innerReverse = innerReverse * -1
	end

	return path
end

function v(x,y,z)
   return vector.new(x,y,z)
end

function testGoToCoordinate()
	local c = CoordTracker:new(2,2,2, CoordTracker.DIR.Y_PLUS)
	local s = ShapeInfo:new()
	s:put(0,0,0,"T")

	local path = calculatePath(c, s)

	local expected = {v(0,0,0)}

	assertEquals(path, expected)
end

function testDoOneLine()
	local s = ShapeInfo:new()
	s:put(0,0,0,"T")
	s:put(5,0,0,"T")

	local path = calculatePath(CoordTracker:new(2,2,2, CoordTracker.DIR.Y_PLUS), s)
	local expected = {v(0,0,0), v(5,0,0)}
	assertEquals(path, expected)

	local path = calculatePath(CoordTracker:new(4,4,2, CoordTracker.DIR.Y_PLUS), s)
	local expected = {v(5,0,0),v(0,0,0)}
	assertEquals(path, expected)
end

function testSmallSquare()
	local s = ShapeInfo:new()
	s:fillZLayer(0,1,0,1,0,"F")
	s:printFarm()

	-- if no direction is better, we prefer to move along Y axis
	local path = calculatePath(CoordTracker:new(-1,-1,0, CoordTracker.DIR.Y_PLUS), s)
	local expected = {v(0,0,0), v(0,1,0), v(1,1,0), v(1,0,0)}
	assertEquals(path, expected)
end

function testSmallRectangle()
	local s = ShapeInfo:new()
	s:fillZLayer(0,5,0,1,0,"F")
	s:printFarm()

	-- if no direction is better, we prefer to move along Y axis
	local path = calculatePath(CoordTracker:new(-1,-1,0, CoordTracker.DIR.Y_PLUS), s)
	local expected = {v(0,0,0), v(5,0,0), v(5,1,0), v(0,1,0)}
	assertEquals(path, expected)
end


function testRectangle()
	local s = ShapeInfo:new()
	s:fillZLayer(0,5,0,2,0,"F")
	s:printFarm()

	-- if no direction is better, we prefer to move along Y axis
	local path = calculatePath(CoordTracker:new(-1,-1,0, CoordTracker.DIR.Y_PLUS), s)
	local expected = {v(0,0,0), v(5,0,0), v(5,1,0), v(0,1,0), v(0,2,0), v(5,2,0)}
	assertEquals(path, expected)
end

testGoToCoordinate()
testDoOneLine()
testSmallSquare()
testSmallRectangle()
testRectangle()
