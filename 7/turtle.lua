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

