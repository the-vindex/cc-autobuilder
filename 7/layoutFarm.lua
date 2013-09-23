local turtle = require("turtle")
require("FarmBuilder")
require("Pathfinder")
local ShapeInfo = require("ShapeInfo")
local CoordTracker = require("CoordTracker")

ShapeInfo.unitTest()
-- ====================================== TESTING END
--turtle.testAll()
--FarmBuilder.unitTest_automove()

FarmBuilder.unitTest_autobuild()

print(_VERSION)
ShapeInfo.unitTest()