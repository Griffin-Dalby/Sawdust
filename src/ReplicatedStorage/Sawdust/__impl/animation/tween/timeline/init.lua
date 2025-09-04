--[[

    Sawdust Tween Timeline Wrapper

    Griffin Dalby
    2025.09.04

    This module will wrap the base timeline object, and specialize it for the
    tween animations.

--]]

--]] Services
--]] Modules
local baseTimeline = require(script.Parent.Parent.timeline)

--]] Wrapper
local wrapper = {}
wrapper.__index = wrapper

type self = {}
export type TweenWrappedTimeline = typeof(setmetatable({} :: self, wrapper))

--[[ wrapper.new()
    This will create a new, wrapped instance of the Sawdust Timeline; specialized
    for the Tween animator Implementation. ]]
function wrapper.new() : TweenWrappedTimeline
    local self = setmetatable({} :: self, wrapper)

    self.__timeline = baseTimeline.new()

    return self
end

return wrapper