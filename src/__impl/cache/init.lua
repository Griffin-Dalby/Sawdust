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
    assert(cacheName, `.findCache() missing argument 1! (cacheName)`)
    assert(type(cacheName)=='string', `.findCache() argument 1 type mismatch! (expected string, got {type(cacheName)}!)`)

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
function cache:getValue(...) : any...
    assert(self, `:getValue() called without a targeted cache!`)

    local keys = {...} :: {[number]: string}
    local found = {}
    
    for i, key in pairs(keys) do
        local value = self.contents[key]
        assert(value~=nil, `:getValue() couldn't find entry "{key} @ {i}"!`)

        found[i] = value
    end

    return unpack(found)
end

--[[ cache:hasEntry(entry: any)
    Checks if the current cache has an entry for "entry". ]]
function cache:hasEntry(entry: any) : boolean
    assert(self, `:hasEntry() called without a targeted cache!`)
    assert(entry, `:hasEntry() missing argument 1! (entry)`)
    return self.contents[entry] ~= nil
end

--[[ cache:getContents()
    Returns a copy of all values within the current cache. ]]
function cache:getContents() : {[string]: any}
    assert(self, `:getContents() called without a targeted cache!`)
    return table.clone(self.contents)
end

--[[ cache:setValue(key: any, value: any)
    Sets the value of key "key" to "value".
    Setting a value to "nil" is a valid way to delete data. ]]
function cache:setValue(key: any, value: any)
    assert(self, `:setValue() called without a targeted cache!`)
    assert(key, `:setValue() missing argument 1! (key)`)

    self.contents[key] = value
end

--[[ cache:createTable(tableKey: any, create: boolean?)
    Creates a table within the cache, basically having caches in caches.
    
    safe(false) : If true & the table already exists, it will be returned.
    Usually this would result in a conflict error. ]]
function cache:createTable(tableKey: any, safe: boolean?) : SawdustCache
    assert(self, `:createTable() called without a targeted cache!`)
    assert(tableKey, `:createTable() missing argument 1! (tableKey)`)
    if safe then
        if self.contents[tableKey] then return self.contents[tableKey] end
    else
        assert(not self.contents[tableKey], `:createTable() conflict while creating a new table!`)
    end

    local pseudoCache = setmetatable({} :: self, cache)

    pseudoCache.cacheName = tableKey
    pseudoCache.contents = {}

    self.contents[tableKey] = pseudoCache
    return pseudoCache
end

--[[ cache:findTable(tableKey: any)
   Finds a specified table, returning it as if it were another cache. ]]
function cache:findTable(tableKey: any) : SawdustCache
    assert(self, `:findTable() called without a targeted cache!`)
    assert(tableKey, `:findTable() missing argument 1! (tableKey)`)
    assert(self.contents[tableKey], `:findTable() unable to find table w/ name "{tableKey}"!`)
    assert(type(self.contents)=='table', `:findTable() located value is a {type(self.contents)}, not a table!`)

    return self.contents[tableKey] :: SawdustCache
end

--[[ cache:deleteTable(tableKey: any)
    Finds & deletes the specified table. ]]
function cache:deleteTable(tableKey: any)
    assert(self, `:deleteTable() called without a targeted cache!`)
    assert(tableKey, `:deleteTable() missing argument 1! (tableKey)`)
    assert(self.contents[tableKey], `:deleteTable() unable to find table w/ name "{tableKey}"!`)
    assert(type(self.contents)=='table', `:deleteTable() located value is a {type(self.contents)}, not a table!`)

    self.contents[tableKey] = nil
end

return cache