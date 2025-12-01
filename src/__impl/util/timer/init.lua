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

--]] Type Definitions
type self = {
    initalized: boolean,
    paused: boolean,

    elapsed: number,
    decay_date: number?,

    __callback: (self) -> (),
    connection: RBXScriptConnection,
}
export type SawdustTimer = typeof(setmetatable({} :: self, timer))
export type SawdustTimerOptions = {
    decay_time: number?,
    server_sync: boolean?,
    cleanup: (() -> nil)?,
}

--]] Utilities
local function ValidateOptions(options: SawdustTimerOptions)
    if not options then options = {} end

    options.decay_time = options.decay_time or nil
    options.server_sync = options.server_sync or false
    options.cleanup = options.cleanup or function() end

    return options
end

--]] Constructor

--[[ 
    Constructor function for the timer utility.
        
    @param callback Function running per-tick,
    @param options Options for the Timer Instance.

    @param options.decay_time Time until timer decays & cleans itself up.
    @param options.server_sync? Use workspace:GetServerTime() rather than tick()
    @param options.cleanup? Function called when this timer gets cleaned up.
]]
function timer.new(callback: (self) -> (), options: SawdustTimerOptions): SawdustTimer
    local self = setmetatable({} :: self, timer)

    --> Gather Options
    ValidateOptions(options) --> Fill in defaults if needed

    local decay_time = options.decay_time
    local server_sync = options.server_sync
    local f_cleanup = options.cleanup

    --> Utilities
    local function GetTick()
        return if server_sync then workspace:GetServerTimeNow() else tick()
    end

    --> Construct Timer
    self.initalized = false
    self.paused = false

    self.elapsed = 0
    self.decay_date = if decay_time then (GetTick() + decay_time) else nil

    --> Create Logic
    self.__callback = callback
    self.__hb_f = function(deltaTime)
        --> Elapse
        self.elapsed += deltaTime

        --> Check Decay
        if self.decay_date then
            if GetTick() > self.decay_date then
                self:discard()
                f_cleanup()
            end
        end

        --> Check Pause
        if not self.paused then
            self.__callback(self)
        end
    end

    self.connection = runService.Heartbeat:Connect(self.__hb_f)

    return self
end

--[[ 
    Initalizes this timer, providing the developer with a callback
    which runs post-initalize, which includes the timer.

    @param init_callback Function to call post-op w/ timer object.
    @param override Allow a secondary initalization during a timer's runtime.
]]
function timer:init(init_callback: (self) -> (), override: boolean?)
    if self.initalized and not override then
        warn(`[{script.Name}] Timer already initalized! (Set "override" to true to allow this operation.)`)
        return end

    init_callback(self)
    self.initalized = true
end

--[[
    Pauses the internal connection, providing the developer with a callback
    which runs post-initalize, which includes the timer.
    
    @param pause_callback Function to call post-op w/ timer object.
    @param silent If you :pause() an already paused timer, it will warn. Use this to silence that.
]]
function timer:pause(pause_callback: (self) -> (), silent: boolean?)
    if self.pause then
        if not silent then warn(`[{script.Name}] Attempt to pause timer while already paused! (Set "silent" to true to silence warning.)`) end
        return end
    
    pause_callback(self)
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

--[[
    Resumes the internal connection, providing the developer with a callback
    which runs post-initalize, which includes the timer.
    
    @param pause_callback Function to call post-op w/ timer object.
    @param silent If you :resume() an already running timer, it will warn. Use this to silence that.
]]
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

--[[
    Gets time since timer started. 
]]
function timer:getElapsed()
   return self.elapsed end

--[[
    Gets time until timer decays if specified. 
]]
function timer:getRemaining()
    return self.decayDate and self.decayDate-self.elapsed or nil; end

return timer