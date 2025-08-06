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
local debounce = {}
debounce.__index = debounce
debounce.shared  = nil :: DebounceTracker

type self = {
    __tracked: {[string]: boolean}
}
export type DebounceTracker = typeof(setmetatable({} :: self, debounce))

--]] Setup Shared
if not debounceCache:getValue('shared') then
    local sharedTracker = debounce.newTracker()
    debounce.shared = sharedTracker end

--]] Debounce Functions
function debounce.newTracker() : DebounceTracker
    local self = setmetatable({} :: self, debounce)

    self.__tracked = {}

    return self
end

--[[ debounce:track(debounceId: string, lifetime: number, cleanup: (exists: boolean) -> nil)
    This will add $debounceId to the tracked list for the $lifetime.

    After the lifetime, $cleanup will be called. The "exists" argument
    dictates if the tracked debounce existed after the total lifetime. ]]
function debounce:track(debounceId: string, lifetime: number, cleanup: (exists: boolean) -> nil)
    assert(self, `Attempt to :track() without constructing.`)
    assert(not self.__tracked[debounceId], `Attempt to track "{debounceId}" while it's already being tracked!`) --// TODO: Review & refactor error severity

    self.__tracked[debounceId] = true
    task.delay(lifetime, function()
        if not self.__tracked[debounceId] then cleanup(false); return end

        self.__tracked[debounceId] = nil
        if cleanup then cleanup(true) end
    end)
end

--[[ debounce:cancel(debounceId: string)
    Manually cancel a specific debounce. ]]
function debounce:cancel(debounceId: string)
    assert(self, `Attempt to :cancel() without constructing.`)
    self.__tracked[debounceId] = nil
end

--[[ debounce:check(debounceId: string) : boolean
    Checks for the presence of $debounceId in the tracked debounce
    list, if it exists, true will be returned. ]]
function debounce:check(debounceId: string) : boolean
    assert(self, `Attempt to :check() without constructing.`)

    return (self.__tracked[debounceId]==true)
end

--[[ debounce:discard()
    Properly cleans up all debounces. ]]
function debounce:discard()
    for debounceId: string in pairs(self.__tracked) do
        self:cancel(debounceId) end

    table.clear(self)
end

return debounce