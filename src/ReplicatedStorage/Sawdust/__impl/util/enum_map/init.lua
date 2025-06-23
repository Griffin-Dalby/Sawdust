--[[

    Sawdust EnumMap Utility

    Griffin Dalby
    2025.06.19

    This implementation will help developers map out Enums with ease and
    aid in things such as settings sytems w/ Enum.KeyCode

--]]

--]] EnumMap
local enumMap = {}
enumMap.__index = enumMap

type self = {}
export type SawdustEnumMap = typeof(setmetatable({} :: self, enumMap))

--[[ enumMap.new(Enum: Enum)
    Maps out a Enum table and wraps it. ]]
function enumMap.new(Enum: Enum): SawdustEnumMap
    local self = setmetatable({} :: self, enumMap)
    
    return self
end

return enumMap