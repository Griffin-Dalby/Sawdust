--[[

    Sawdust Timeline

    Griffin Dalby
    2025.08.23

    This implementation will create a flexible timeline to create
    timed events.

--]]

--]] Services
--]] Modules
local controller = require(script.controller)
local keyframe   = require(script.keyframe)

--]] Settings
--]] Constants
unp = unpack

--]] Variables
--]] Functions
--]] Implementation

local timeline = {}
timeline.__index = timeline

type self = {
    time: number,
    playing: boolean,

    keyframes: {},

    __controller: controller.TimelineController
}
export type Timeline = typeof(setmetatable({} :: self, timeline))

--[[ timeline.new()
    Creates a new timeline. ]]
function timeline.new() : Timeline
    local self = setmetatable({} :: self, timeline)

    --]] Structure
    self.time = 0
    self.playing = false

    self.keyframes = {}

    --]] Internals
    self.__controller = controller.new(self)

    return self
end

--[[ KEYFRAMING ]]--
function timeline:keyframe(time: number, callback: () -> nil) : keyframe.Keyframe
    assert(self.keyframes[time]==nil, `There is already a keyframe defined at {time}!`)

    local new_keyframe   = keyframe.new(time, callback)
    self.keyframes[time] = new_keyframe

    return new_keyframe
end

--[[ CONTROLLER ]]--

--[[ timeline:setTime(time: number)
    Sets the playback location of the current timeline. ]]
function timeline:setTime(...)
    self.__controller:setTime(unp{...}) end

--[[ timeline:play(atTime: number?)
    Plays this timeline.

    If *atTime is passed, it'll start at that time. ]]
function timeline:play(...)
    self.__controller:play(unp{...}) end

--[[ timeline:pause()
    Pauses this timeline. ]]
function timeline:pause(...)
    self.__controller:pause(unp{...}) end

--[[ timeline:restart()
    Sets the time to zero, and pauses the timeline. ]]
function timeline:restart(...)
    self.__controller:restart(unp{...}) end

return timeline