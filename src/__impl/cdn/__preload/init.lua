--[[

    Sawdust CDN Preload Module

    Griffin E. Dalby
    6/16/25

    This module provides preload functions to the CDN module, allowing the
    developer to dynamically preload assets in batches or however you want.

--]]

--]] Services
local contentProvider = game:GetService('ContentProvider')

--]] Settings
local __internal = script.Parent.Parent.Parent.__internal
local __settings = require(__internal.__settings)

--]] Modules
local caching = require(script.Parent.Parent.cache)

--]] Cache table
local cdnCache = caching.findCache('__cdn_cache')

--]] Functions
function scanTable(table: {}, seen: {})
    seen = seen or {}
    if seen[table] then return {} end
    seen[table] = true

    local assetIdList = {}
    
    for _, v in pairs(table) do
        if typeof(v) == 'table' then
            local foundAssetIds = scanTable(v, seen)
            for _, assetId: string in pairs(foundAssetIds) do
                table.insert(assetIdList, assetId)  end
        elseif typeof(v) == 'string' then
            if v:match('^rbxassetid://%d+') or v:match('^%d+$') or v:match('asset%/?%?id=%d+') then
                table.insert(assetIdList, v)
            end
        end
    end

    return assetIdList
end

--]] Preloader
local preload = {}
preload.__index = preload

type self = {
    provider: Folder,
    tags: {
        [string]: { string }
    }
}
export type SawdustCDNPreloader = typeof(setmetatable({} :: self, preload))

--[[ preload.new()
    Constructor function for the preloader instance. ]]
function preload.new(provider: Folder) : SawdustCDNPreloader
    local self = setmetatable({} :: self, preload)

    self.provider = provider
    self.tags = {}

    return self
end

--[[ preload:preload(tag: string)
    Locates all assets that are tagged within the tagTable, and preloads them. ]]
function preload:preload(tag: string)
    local debug = __settings.global.debug and __settings.content.debug.preload

    local tagTable = self.tags[tag]
    if not tagTable then 
        warn(`[{script.Name}:preload()] Attempt to preload w/ tag that doesn't exist! ({tag or '<none provided>'})`)
        return end

    print(`[{script.Name}] Starting preload with {#tagTable} assets.`)

    local _assets = cdnCache:findTable('_assets')
    
    local assetIdPreloads = {}
    for _, assetId: string in pairs(tagTable) do
        local foundAsset = self.provider:FindFirstChild(assetId) :: Instance
        if not foundAsset then
            warn(`[{script.Name}:preload()] Couldn't find asset with ID "{assetId or '<none provided>'}" in provider "{self.provider.Name}"`)
            return end
        
        if foundAsset:IsA('ModuleScript') then
            local data = table.clone(require(foundAsset))
            local assetIds = scanTable(data)
            data.cdnInfo = {
                ['assetId'] = assetId,
            }
            
            for _, assetId: string in pairs(assetIds) do
                table.insert(assetIdPreloads, assetId)
            end
            
            if debug then
                print(`[{script.Name}] Cached & crawled metadata for {self.provider.Name}.{assetId}`)  end
            _assets:setValue(`{self.provider.Name}.{assetId}`, data)
        else
            if debug then
                print(`[{script.Name}] Cached instance for {self.provider.Name}.{assetId}`) end
            _assets:setValue(`{self.provider.Name}.{assetId}`, foundAsset:Clone())
        end
    end

    if #assetIdPreloads > 0 then
        if debug then
            print(`[{script.Name}] FINISHED CACHING!\n`)
            print(`[{script.Name}] Preloading {#assetIdPreloads} AssetIds.`) end

        local count = 0
        contentProvider:PreloadAsync(assetIdPreloads, function()
            if not debug then return end

            count += 1
            if count%5 == 0 or count == #assetIdPreloads then
                print(`[{script.Name}] Preloaded {count} assets.`)

                if count == #assetIdPreloads then
                    print(`[{script.Name}] Finished preloading!`)
                end
            end
        end)
    end
end

--[[ preload:addTag(tag: string, assetIds: ...string)
    Adds all assetIds specified as a tuple after *tag*, to the specified tag.
    This makes it so when you call :preload(tag: string), those assetIds will be included.
    You could also call it like :addTag('tag', '*') to preload everything in a provider. ]]
function preload:addTag(tag: string, ...)
    local tagTable = self.tags[tag]
    if not tagTable then
        self.tags[tag] = {}
        tagTable = self.tags[tag] end
    
    local assetIds = {...} :: {[number]: string}
    if assetIds[1] == '*' then
        assetIds = {}
        for _, v in pairs(self.provider:GetChildren()) do
            table.insert(assetIds, v.Name)
        end
    end

    for _, assetId in pairs(assetIds) do
        if table.find(tagTable, assetId) then continue end
        table.insert(tagTable, assetId)
    end
end

--[[ preload:clearTag(tag: string)
    Clears all assetIds within the specified tag, and deletes the tagTable. ]]
function preload:clearTag(tag: string)
    local tagTable = self.tags[tag]
    if not tagTable then return end

    table.clear(tagTable)
    self.tags[tag] = nil
end

return preload