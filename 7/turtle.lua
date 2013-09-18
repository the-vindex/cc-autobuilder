---Source: https://raw.github.com/theoriginalbit/CC-Emu-Turtle/master/api

_G.turtle = {}
turtle.native = {}

function turtle.native.craft( quantity )
  return true
end

function turtle.native.forward()
  return true
end

function turtle.native.back()
  return true
end

function turtle.native.down()
  return true
end

function turtle.native.up()
  return true
end

function turtle.native.turnLeft()
  return true
end

function turtle.native.turnRight()
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

-- make copies
for k,v in pairs(turtle.native) do
  turtle[k] = v
end
