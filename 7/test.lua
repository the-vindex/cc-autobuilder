vector = require("vector")
require("ShapeInfo")
require("CoordTracker")

vector.new()

ShapeInfo.unitTest()
ShapeInfo.unitTest_layout()
CoordTracker.unitTest()

local function tablePrint(tt, indent, done)
	done = done or {}
	indent = indent or 0
	if type(tt) == "table" then
		local sb = {}
		for key, value in pairs(tt) do
			table.insert(sb, string.rep(" ", indent)) -- indent it
			if type(value) == "table" and not done[value] then
				done[value] = true
				table.insert(sb, "[\""..key.."\"] = {\n");
				table.insert(sb, tablePrint(value, indent + 2, done))
				table.insert(sb, string.rep(" ", indent)) -- indent it
				table.insert(sb, "}\n");
			elseif "number" == type(key) then
				table.insert(sb, string.format("\"%s\"\n", tostring(value)))
			else
				table.insert(sb, string.format(
				"%s = \"%s\"\n", tostring(key), tostring(value)))
			end
		end
			return table.concat(sb)
		else
			return tt .. "\n"
	end
end

	--expects vectors
	function addUniquePoint(array, newValue)
		for _, value in ipairs(array) do
			if (value - newValue):length() == 0 then
				return
			end
		end
		array[#array + 1] = newValue
	end

	local topCorners = {}
	addUniquePoint(topCorners,vector.new(0,1,2))
	addUniquePoint(topCorners,vector.new(2,3,4))

	print(tablePrint(topCorners))

	local closestIndex, closestPoint = 1, nil --= findClosestPoint(coord:getCoords(), topCorners)
	--addPath(closestPoint)
	topCorners[closestIndex] = nil



print(tablePrint(topCorners))
