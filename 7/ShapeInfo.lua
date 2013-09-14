local vector = require("vector")

ShapeInfo = {}
function ShapeInfo:new()
   local o = {}
   setmetatable(o, self)
   self.__index = self

   o.data = {}
   o.coordCache = {} -- cache of "x:y:z" = {x=x,y=y,z=z} for simple traversing of own data

   return o
end

function ShapeInfo:put(x,y,z,value)
   local coord = x..":"..y..":"..z
   self.data[coord] = value
   self.coordCache[coord] = {x=x, y=y, z=z}
end

function ShapeInfo:get(x,y,z)
   local coord = x..":"..y..":"..z
   return self.data[coord]
end

-- vector get
function ShapeInfo:getV(vect)
   return self:get(vect.x,vect.y,vect.z)
end

function ShapeInfo:fillZLayer(minX, maxX, minY, maxY, z, value)
   for x = minX, maxX do
      for y = minY, maxY do
	     self:put(x,y,z,value)
	  end
   end
end

--returns 2 vectors - min and max
function ShapeInfo:getBorderCubeCoords(zFrom, zTo)
   local isLimitZ = false
   if zFrom ~= nil and zTo == nil then
		zTo = zFrom
   end

   if zFrom ~= nil then
   		isLimitZ = true
	end

   assert(zFrom == nil or tonumber(zFrom) ~= nil, "Either do not specify zFrom or it must be a number")
   assert(zTo == nil or tonumber(zTo) ~= nil, "Either do not specify zTo or it must be a number")
   assert(not(isLimitZ) or zFrom <= zTo, "From must be greater then To")

   local minX, maxX, minY, maxY, minZ, maxZ = 1000000,-1000000,1000000,-1000000,1000000,-1000000
   for coord, value in pairs(self.data) do
		local c = self.coordCache[coord]
		if value ~= nil and (not(isLimitZ) or (c.z >= zFrom and c.z <= zTo)) then
			minX = math.min(minX, c.x)
			minY = math.min(minY, c.y)
			minZ = math.min(minZ, c.z)
			maxX = math.max(maxX, c.x)
			maxY = math.max(maxY, c.y)
			maxZ = math.max(maxZ, c.z)
		end
   end
   return vector.new(minX,minY,minZ), vector.new(maxX,maxY,maxZ)
end


function ShapeInfo:layoutFarm(farmCoordX, farmCoordY, z, farmSizeX, farmSizeY, radius, value)
	local insideFarmX = function(checkX)
		return checkX>= farmCoordX and checkX<=farmCoordX + farmSizeX - 1
	end

	local insideFarmY = function(checkY)
		return checkY>= farmCoordY and checkY<=farmCoordY + farmSizeY - 1
	end

	local insideFarmXY = function(checkX, checkY)
		return insideFarmX(checkX) and insideFarmY(checkY)
	end

	local topY = farmCoordY + farmSizeY + radius - 1
	--assert(topY == 11, "was "..topY)
	local bottomY = farmCoordY - radius
--	assert(bottomY == -5, "was "..bottomY)

	local leftX = farmCoordX
	--assert(leftX == 1)
	local rightX = farmCoordX + farmSizeX - 1
	--assert(rightX == 5, "was "..rightX)
	local phase = "belowFarm"

	for y = bottomY, topY do
		for x = leftX, rightX do
			if not(insideFarmXY(x,y)) then
				self:put(x, y, z, value)
			end
		end
		if phase == "belowFarm" and insideFarmY(y) then
			phase = "inFarm"
		end


		if phase == "inFarm" and not(insideFarmY(y+1)) then
			phase = "aboveFarm"
		end

		local change = 0
		if phase == "belowFarm" then
			change = change + 1
		end
		if phase == "aboveFarm" then
			change = change - 1
		end
		leftX = leftX - change
		rightX = rightX + change
	end
end

-- goes layer by layer (z) and prints farm
function ShapeInfo:printFarm()
	local minV, maxV = self:getBorderCubeCoords()
	for z = maxV.z, minV.z, -1 do
		local actual = ""
		for y = maxV.y, minV.y, -1 do
			local line = ""
			for x = minV.x, maxV.x do
				local value = self:get(x, y, z)
				if value ~= nil then
					line = line..value
				else
					line = line.." "
				end
			end

			actual = actual..line.."|\n"
		end
		print(actual)
	end
end


function ShapeInfo.unitTest()
   local LuaUnit = require("luaunit")
   local shapeInfo = ShapeInfo:new()
   for z = 1,4 do
      shapeInfo:fillZLayer(1,5,1,5,z,"F")
   end
   assert(shapeInfo:get(1,1,4) == "F")
   shapeInfo:put(1,1,4, "T")
   assert(shapeInfo:get(1,1,4) == "T")

   --global border cube test
   local s = ShapeInfo:new()
   s:put(1,2,3,"A")
   s:put(-1,-2,-3,"B")
   local minV, maxV = s:getBorderCubeCoords()
   assertEquals(minV, vector.new(-1,-2,-3))
   assertEquals(maxV, vector.new(1,2,3))

   --test specific z values
   local s = ShapeInfo:new()
   s:put(9,2,6,"A")
   s:put(5,2,4,"A")

   s:put(1,2,3,"A")
   s:put(-1,-2,3,"A")

   s:put(-5,-6,-3,"B")
   local minV, maxV = s:getBorderCubeCoords(3)
   assertEquals(minV, vector.new(-1,-2,3))
   assertEquals(maxV, vector.new(1,2,3))

   local minV, maxV = s:getBorderCubeCoords(-3, 3)
   assertEquals(minV, vector.new(-5,-6,-3))
   assertEquals(maxV, vector.new(1,2,3))
   print("ShapeInfo unitTest ok")
end

function ShapeInfo.unitTest_layout()
	local LuaUnit = require("luaunit")

	local s = ShapeInfo:new()

	s:fillZLayer(1,5, 1,5, 3, "F")
	s:layoutFarm(1,1, 3, 5,5, 6, "B")

	assert(s:get(-5,-5,3) == nil)

	local actual = [[
	]]
	local actualT = {}
	local lineNumber = 1
	for y = 11, -5, -1 do
		local line = ""
		for x = -5, 11 do
			local value = s:get(x, y, 3)
			assert(value == nil or value == "B" or value == "F")
			if value ~= nil then
				line = line..value
			else
				line = line.." "
			end
		end

		actual = actual..line.."|\n"
		actualT[lineNumber] = line
		lineNumber = lineNumber + 1
	end

	--print(actual)
	local expectedResult = {
	"      BBBBB      ",
	"     BBBBBBB     ",
	"    BBBBBBBBB    ",
	"   BBBBBBBBBBB   ",
	"  BBBBBBBBBBBBB  ",
	" BBBBBBBBBBBBBBB ",
	"BBBBBBFFFFFBBBBBB",
	"BBBBBBFFFFFBBBBBB",
	"BBBBBBFFFFFBBBBBB",
	"BBBBBBFFFFFBBBBBB",
	"BBBBBBFFFFFBBBBBB",
	" BBBBBBBBBBBBBBB ",
	"  BBBBBBBBBBBBB  ",
	"   BBBBBBBBBBB   ",
	"    BBBBBBBBB    ",
	"     BBBBBBB     ",
	"      BBBBB      "}

	for i, expected in ipairs(expectedResult) do
		local ok, result = pcall(function() assertEquals(actualT[i], expected) end)
		if not ok then
			error("Line "..i.." not equals: "..result)
		end
	end

	print("Layout test ok")
end
