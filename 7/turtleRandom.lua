---Source: https://raw.github.com/theoriginalbit/CC-Emu-Turtle/master/api

_G.turtle = {}
turtle.native = {}

function turtle.native.craft( quantity )
  return (math.random(1, 10) ~= 9) -- 10% chance of not crafting something
end

function turtle.native.forward()
  return (math.random(1,20) ~= 14) -- 5% chance of not moving
end

function turtle.native.back()
  return (math.random(1,20) ~= 14) -- 5% chance of not moving
end

function turtle.native.down()
  if (math.random(1,20) ~= 14) then return false end -- 5% chance of not moving
  return true
end

function turtle.native.up()
  if (math.random(1,20) ~= 14) then return false end -- 5% chance of not moving
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
  return (math.random(1, 4) == 3) -- 25% chance of attack
end

function turtle.native.attackUp()
  return (math.random(1, 4) == 3) -- 25% chance of attack
end

function turtle.native.attackDown()
  return (math.random(1, 4) == 3) -- 25% chance of attack
end

function turtle.native.dig()
  return (math.random(1, 4) == 3) -- 25% chance of digging
end

function turtle.native.digUp()
  return (math.random(1, 4) == 3) -- 25% chance of digging
end

function turtle.native.digDown()
  return (math.random(1, 4) == 3) -- 25% chance of digging
end

function turtle.native.place( text )
  return (math.random(1, 4) ~= 3) -- 25% chance of not being able to place
end

function turtle.native.placeUp()
  return (math.random(1, 4) ~= 3) -- 25% chance of not being able to place
end

function turtle.native.placeDown()
  return (math.random(1, 4) ~= 3) -- 25% chance of not being able to place
end

function turtle.native.detect()
  return (math.random(1, 4) == 3) -- 25% chance of something being there
end

function turtle.native.detectUp()
  return (math.random(1, 4) == 3) -- 25% chance of something being there
end

function turtle.native.detectDown()
  return (math.random(1, 4) == 3) -- 25% chance of something being there
end

function turtle.native.compare()
  return (math.random(1, 2) == 1) -- 50% chance of being the same
end

function turtle.native.compareUp()
  return (math.random(1, 2) == 1) -- 50% chance of being the same
end

function turtle.native.compareDown()
  return (math.random(1, 2) == 1) -- 50% chance of being the same
end

function turtle.native.compareTo( slot )
  if slot < 0 or slot > 16 then error('Slot out of bounds of inventory: '..slot, 2) end
  return (math.random(1, 10) == 4) -- 10% chance of being the same
end

function turtle.native.drop( amount )
  return true
end

function turtle.native.dropUp( amount )
  return true
end

function turtle.native.dropDown( amount )
  return true
end

function turtle.native.suck()
  return true
end

function turtle.native.suckUp()
  return true
end

function turtle.native.suckDown()
  return true
end

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