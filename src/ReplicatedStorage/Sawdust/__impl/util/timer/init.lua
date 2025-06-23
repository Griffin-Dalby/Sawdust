--[[

    Timer Sawdust Utility

    Griffin Dalby
    2025.06.18

    This implementation provides a "Timer" module, allowing the developer
    to make a new timer object, have a optional decay value, and most
    importantly, dynamic start, pausing, resuming, and canceling.

--]]

--]] Services
local runService = game:GetService('RunService')

--]] Timer
local timer = {}
timer.__index = timer

type self = {
    initalized: boolean,
    paused: boolean,

    elapsed: number,
    decayDate: number?,

    __callback: (self) -> (),
    connection: RBXScriptConnection,
}
export type SawdustTimer = typeof(setmetatable({} :: self, timer))

--[[ timer.new(callback: (self) -> (), decayTime: number?)
    Constructor function for the timer utility.
        
    callback: Function running per-tick,
    ]]
function timer.new(callback: (self) -> (), decayTime: number?): SawdustTimer
    local self = setmetatable({} :: self, timer)

    self.initalized = false
    self.paused = false

    self.elapsed = 0
    self.decayDate = decayTime and (tick() + decayTime) or nil

    self.__callback = callback
    self.__hb_f = function(deltaTime)
        self.elapsed += deltaTime
        if self.decayDate then
            if tick > self.decayDate then
                self:discard()
            end
        end

        if not self.paused then
            self.__callback(self)
        end
    end

    self.connection = runService.Heartbeat:Connect(self.__hb_f)

    return self
end

--[[ timer:init(callback: (self) -> (), override: boolean?)
    Initalizes this timer, providing the developer with direct access
    to the timer's self. ]]
function timer:init(callback: (self) -> (), override: boolean?)
    if self.initalized and not override then
        warn(`[{script.Name}] Timer already initalized! (Set "override" to true to allow this operation.)`)
        return end

    callback(self)
    self.initalized = true
end

--[[ timer:pause(callback: (self) -> (), silent: boolean?)
    Pauses the internal connection, and provides developer with direct
    access to the timer's self. ]]
function timer:pause(callback: (self) -> (), silent: boolean?)
    if self.pause then
        if not silent then warn(`[{script.Name}] Attempt to pause timer while already paused! (Set "silent" to true to silence warning.)`) end
        return end
    
    callback(self)
    self.pause = true
end

--[[ timer:cancel()
    Disconnects the internal connection. ]]
function timer:cancel()
    if self.connection then
        self.connection:Disconect()
        self.connection = nil
    end
end

--[[ timer:resume(callback: (self) -> (), silent: boolean?)
    Resumes the internal connection, and provides developer with direct
    access to the timer's self. ]]
function timer:resume(callback: (self) -> (), silent: boolean?)
    if not self.connection then
        self.connection = runService.Heartbeat:Connect(self.__hb_f)
        callback(self)
        return end
    if not self.pause then
        if not silent then warn(`[{script.Name}] Attempt to resume timer while it's already running! (Set "silent" to true to silence warning.)`) end
        return end

    callback(self)
    self.pause = false
end

--[[ timer:getElapsed()
    Gets time since timer started. ]]
function timer:getElapsed()
   return self.elapsed end

--[[ timer:getRemaining()
    Gets time until timer decays if specified. ]]
function timer:getRemaining()
    return self.decayDate and self.decayDate-self.elapsed or nil; end

return timer