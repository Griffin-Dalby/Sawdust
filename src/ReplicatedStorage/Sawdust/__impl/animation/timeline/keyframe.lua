--[[

    Timeline Keyframe

    Griffin Dalby
    2025.08.23

    This module will provide a keyframe object to the timeline implementation.

--]]

local keyframe = {}
keyframe.__index = keyframe

type self = {
    __utility: {
        getKeyframes: () -> {[number]: Keyframe}
    },

    time: number,
    callback: () -> nil
}
export type Keyframe = typeof(setmetatable({} :: self, keyframe))

function keyframe.new(timeline, time: number, callback: () -> nil) : Keyframe
    local self = setmetatable({} :: self, keyframe)

    --]] Setup Internal Utility
    self.__utility = {
        getKeyframes = function() : {[number]: Keyframe}
            return timeline.keyframes end,
    }

    --]] Setup Structure
    self.time = time
    self.callback = callback

    return self
end

return keyframe