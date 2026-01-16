--!strict
--[[

    Debounce Utility

    Griffin Dalby
    2025.06.08

    This utility will provide a debounce system, allowing easy timed
    debounce, paired with easy lookups.

--]]

--]] Modules
local __impl = script.Parent.Parent
local cache = require(__impl.cache)

--]] Cache Group
local debounceCache = cache.findCache('__debounce_cache')

--]] Debounce
type self_methods = {
    __index: self_methods,
    shared: DebounceTracker,

    --[[ CONSTRUCTOR ]]--

    --[[
        This will construct a new DebounceTracker, where you can :Track(), 
        :Cancel(), and :Check() a debounce entry.
        
        @return DebounceTracker
    ]]
    NewTracker: () -> DebounceTracker,

    --[[ METHODS ]]--

    --[[
        This will add new debounce entry to the tracked list with a provided lifetime.

        After the lifetime, the cleanup callback will be called, providing a
        a "exists" paramater, true if the tracked debounce existed past the total lifetime.
        
        @param debounce_id ID of the debounce to track
        @param lifetime Time until debounce ends
        @param cleanup Optional cleanup callback function
    ]]
    Track: (self: DebounceTracker, debounce_id: string, lifetime: number, cleanup: ((exists: boolean) -> nil)?) -> nil,

    --[[
        Manually cancel a specific debounce.
        
        @param debounce_id Debounce to cancel
    ]]
    Cancel: (self: DebounceTracker, debounce_id: string) -> nil,
    
    --[[
        Checks for the presence of debounce with a specific ID in the
        tracked debounce list is active.
        
        @param debounce_id Debounce ID to check

        @return boolean Debounce Active
    ]]
    Check: (self: DebounceTracker, debounce_id: string) -> nil,

    --[[
        Properly cleans up this object.
    ]]
    Discard: (self: DebounceTracker) -> nil
}

local Debounce = {} :: self_methods
Debounce.__index = Debounce

type self = {
    __tracked: {[string]: boolean}
}
export type DebounceTracker = typeof(setmetatable({} :: self, {} :: self_methods))

--[[ CONSTRUCTOR ]]--
function Debounce.NewTracker() : DebounceTracker
    local self = setmetatable({} :: self, Debounce)

    self.__tracked = {}

    return self
end

--> Setup Shared
if not debounceCache:hasEntry('shared') then
    local sharedTracker = Debounce.NewTracker()
    Debounce.shared = sharedTracker end

--[[ METHODS ]]--]]
function Debounce:Track(debounce_id: string, lifetime: number, cleanup: ((exists: boolean) -> nil)?)
    assert(self, `Attempt to :track() without constructing.`)
    assert(not self.__tracked[debounce_id], `Attempt to track "{debounce_id}" while it's already being tracked!`) --// TODO: Review & refactor error severity

    self.__tracked[debounce_id] = true
    task.delay(lifetime, function()
        if not self.__tracked[debounce_id] and cleanup then cleanup(false); return end

        self.__tracked[debounce_id] = nil
        if cleanup then cleanup(true) end
    end)

    return nil
end

function Debounce:Cancel(debounce_id: string)
    assert(self, `Attempt to :cancel() without constructing.`)
    self.__tracked[debounce_id] = nil

    return nil
end

function Debounce:Check(debounce_id: string) : boolean
    assert(self, `Attempt to :check() without constructing.`)

    return (self.__tracked[debounce_id]==true)
end

function Debounce:Discard()
    for debounceId: string in pairs(self.__tracked) do
        self:Cancel(debounceId) end

    table.clear(self)

    return nil
end

return Debounce