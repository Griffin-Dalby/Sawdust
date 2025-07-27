--[[

    Sawdust Caching Implementation

    Griffin E. Dalby
    2025.06.16

    Splits data into non-replicated keyed tables, where you can freely
    access and modify the values within. You could also have said keyed
    tables within others.

    This is a very raw module I'd put it, there isn't much error handling
    by design for as much flexibility and ease of use as possible. It reads
    just how you'd expect and works just how it reads.

--]]

--]] Services
--]] Modules
--]] Settings
--]] Constants
--]] Variables
local __cache = {}

--]] Functions
--]] Cache

local cache = {}
cache.__index = cache

type self = {
    cacheName: string,
    contents: {[any]: any}
}
export type SawdustCache = typeof(setmetatable({} :: self, cache))

--[[ cache.findCache(cacheName: string!)
    Finds a cache table w/ "cacheName". ]]
function cache.findCache(cacheName: string): SawdustCache
    if __cache[cacheName] then
        return __cache[cacheName]  end

    local self = setmetatable({} :: self, cache)

    self.cacheName = cacheName
    self.contents = {}

    __cache[cacheName] = self
    return self
end

--[[ cache:getValue(keys: ...string)
    Fetches multiple or singular values from the current cache. ]]
function cache:getValue(...)
    local keys = {...} :: {[number]: string}
    local found = {}
    
    for i, key in pairs(keys) do
        local value = self.contents[key]
        if value then found[i] = value end
    end

    return unpack(found)
end

--[[ cache:hasEntry(entry: any)
    Checks if the current cache has an entry for "entry". ]]
function cache:hasEntry(entry: any) : boolean
    if not entry then error(`[Sawdust.{script.Name}] Trying to check for an entry without a key!`); return false end
    return self.contents[entry] ~= nil
end

--[[ cache:getContents()
    Returns a copy of all values within the current cache. ]]
function cache:getContents()
    return table.clone(self.contents)
end

--[[ cache:setValue(key: any, value: any)
    Sets the value of key "key" to "value".
    Setting a value to "nil" is a valid way to delete data. ]]
function cache:setValue(key: any, value: any)
    if not key then error(`[Sawdust.{script.Name}] Trying to set value without a key!`); return end

    self.contents[key] = value
end

--[[ cache:createTable(tableKey: any)
    Creates a table within the cache, basically having caches in caches. ]]
function cache:createTable(tableKey: any)
    if self.contents[tableKey] then
        error(`[{script.Name}] Conflict while creating new Table!`)
        return end
    
    local pseudoCache = setmetatable({} :: self, cache)

    pseudoCache.cacheName = tableKey
    pseudoCache.contents = {}

    self.contents[tableKey] = pseudoCache
    return pseudoCache
end

--[[ cache:findTable(tableKey: any)
   Finds a specified table, returning it as if it were another cache. ]]
function cache:findTable(tableKey: any) : SawdustCache
    if not tableKey or not self.contents[tableKey] then
        error(`[{script.Name}] Unable to find table w/ name "{tableKey or '<none provided>'}"!`)
        return end
    if typeof(self.contents) ~= 'table' then
        error(`[{script.Name}] Attempted to find table w/ name "{tableKey}", and it was a {typeof(self.contents)}!`)
        return end

    return self.contents[tableKey] :: SawdustCache
end

return cache