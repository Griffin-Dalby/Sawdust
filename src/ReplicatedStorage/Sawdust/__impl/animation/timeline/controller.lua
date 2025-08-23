--[[

    Timeline Controller

    Griffin Dalby
    2025.08.23

    This module will provide a controller for the timeline.

--]]

local controller = {}
controller.__index = controller

type self = {
    __utility: {
        getTime: () -> number,
        setTime: (time: number) -> nil,

        isPlaying: () -> boolean,
        setPlaying: (playing: boolean) -> nil,
    }

}
export type TimelineController = typeof(setmetatable({} :: self, controller))

function controller.new(timeline)
    local self = setmetatable({} :: self, controller)

    --]] Setup Internal Utility
    self.__utility = {
        getTime = function() : number
            return timeline.time end,
        setTime = function(time: number)
            timeline.time = time end,

        isPlaying = function() : boolean
            return timeline.playing end,
        setPlaying = function(playing: boolean) : boolean
            timeline.playing = playing end
    }

    return self
end

function controller:setTime(time: number)
    self.__utility.setTime(time)
end

function controller:play(atTime: number)
    if atTime then
        assert(type(atTime) == 'number', `atTime was provided, but is a {type(atTime)}! (Expected Type: number)`)

        self.__utility.setTime(atTime)
    end

    self.__utility.setPlaying(true)
end

function controller:pause()
    self.__utility.setPlaying(false)
end

function controller:restart()
    self:pause()
    self:setTime(time)
end

return controller