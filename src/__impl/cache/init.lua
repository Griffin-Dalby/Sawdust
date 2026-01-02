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

--[[
    Finds a cache table w/ a specified name, searching the i-cache (internal cache) first.
    
    If it's located in the i-cache then it will be returned from there,
    elsewise it'll be located & saved in the i-cache.

    @param cache_name
]]
function cache.findCache(cache_name: string): SawdustCache
    assert(cache_name, `.findCache() missing argument 1! (cacheName)`)
    assert(type(cache_name)=='string', `.findCache() argument 1 type mismatch! (expected string, got {type(cache_name)}!)`)

    if __cache[cache_name] then
        return __cache[cache_name]  end

    local self = setmetatable({} :: self, cache)

    self.cacheName = cache_name
    self.contents = {}

    __cache[cache_name] = self
    return self
end

--================--
-- STORAGE SYSTEM --
--================--

--[[
    Fetches multiple or singular values from the current cache.
    
    @param tuple<any> Cache ID's to search for

    @return tuple<any> Elements located inside of cache.
]]
function cache:getValue(...) : (...any)
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

--[[
    Checks if the current cache has an entry for "entry".
    
    @param entry ID to search for.

    @return boolean Existence of entry
]]
function cache:hasEntry(entry: any) : boolean
    assert(self, `:hasEntry() called without a targeted cache!`)
    assert(entry, `:hasEntry() missing argument 1! (entry)`)
    return self.contents[entry] ~= nil
end

--[[
    Returns a copy of all values within the current cache.
    
    @return Table of all contents
]]
function cache:getContents() : {[any]: any}
    assert(self, `:getContents() called without a targeted cache!`)
    return table.clone(self.contents)
end

--[[
    Sets the value of key "key" to "value".
    Setting a value to "nil" is a valid way to delete data.
    
    @param key Cache entry to set
    @param value Value to set it to
]]
function cache:setValue(key: any, value: any)
    assert(self, `:setValue() called without a targeted cache!`)
    assert(key, `:setValue() missing argument 1! (key)`)

    self.contents[key] = value
end

--==============--
-- TABLE SYSTEM --
--================

--[[
    Creates a table within the cache, basically having caches in caches.
    
    @param table_key Identification key for this table
    @param safe If true & the table already exists, it will be returned.
    Usually this would result in a conflict error. 
]]
function cache:createTable(table_key: any, safe: boolean?) : SawdustCache
    assert(self, `:createTable() called without a targeted cache!`)
    assert(table_key, `:createTable() missing argument 1! (table_key)`)
    if safe then
        if self.contents[table_key] then return self.contents[table_key] end
    else
        assert(not self.contents[table_key], `:createTable() conflict while creating a new table!`)
    end

    local pseudoCache = setmetatable({} :: self, cache)

    pseudoCache.cacheName = table_key
    pseudoCache.contents = {}

    self.contents[table_key] = pseudoCache
    return pseudoCache
end

--[[
   Finds a specified table, returning it as if it were another cache.
   
   @param table_key Identifier to look up for table
   
   @return SawdustCache
]]
function cache:findTable(table_key: any) : SawdustCache
    assert(self, `:findTable() called without a targeted cache!`)
    assert(table_key, `:findTable() missing argument 1! (table_key)`)
    assert(self.contents[table_key], `:findTable() unable to find table w/ name "{table_key}"!`)
    assert(type(self.contents)=='table', `:findTable() located value is a {type(self.contents)}, not a table!`)

    return self.contents[table_key] :: SawdustCache
end

--[[
    Finds & deletes the specified table.
    
    @param table_key Identifier to look up & delete
]]
function cache:deleteTable(table_key: any)
    assert(self, `:deleteTable() called without a targeted cache!`)
    assert(table_key, `:deleteTable() missing argument 1! (table_key)`)
    assert(self.contents[table_key], `:deleteTable() unable to find table w/ name "{table_key}"!`)
    assert(type(self.contents)=='table', `:deleteTable() located value is a {type(self.contents)}, not a table!`)

    self.contents[table_key] = nil
end

return cache