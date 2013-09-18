----- START of function call recorder


local mode = "replay"
local log = {}

function addLog(functionName, func, parameters)
   local logItem = {functionName = functionName, func = func, parameters = parameters}
   log[#log+1] = logItem
end

function wrap(name, f)
  print("Wrapping "..name)
  local _f = f
  local _name = name
  return function(self,a1,a2,a3,a4,a5)
     --print("Call to ".._name.."("..s(a1)..","..s(a2)..","..s(a3)..","..s(a4)..","..s(a5)..")")
     if mode == "record" or mode=="plan" then
        addLog(_name,_f,{a1,a2,a3,a4,a5})
     end

     if mode ~= "plan" then
        _f(self, a1,a2,a3,a4,a5)
     end
  end
end

function wrapAll(t)
   for name,originalFunction in pairs(t:listMethods()) do
      local proxy = wrap(name, originalFunction)
      t[name] = proxy
   end
end

function play(object)
   for i, item in ipairs(log) do
      local a1, a2, a3, a4, a5 = item.parameters[1], item.parameters[2], item.parameters[3], item.parameters[4], item.parameters[5]
      object[item.functionName](object,a1,a2,a3,a4,a5)
   end
end
------------------ END of recorder