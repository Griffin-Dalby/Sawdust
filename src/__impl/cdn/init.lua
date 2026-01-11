--[[

    Sawdust CDN Implementation

    Griffin E. Dalby
    6/16/25

    Dynamic content provider that allows you to easily locate & include
    assets utilizing AssetID's. You can use this module to return
    metadata, or straight instances.

--]]

--]] Settings
local __internal = script.Parent.Parent.__internal
local __settings = require(__internal.__settings)
local __preload = require(script.__preload)

--]] Modules
local caching = require(script.Parent.cache)

--]] Cache table
local cdnCache = caching.findCache('__cdn_cache')

--]] Provider
type self_methods = {
    __index: self_methods,
    getProvider: (provider_name: string) -> SawdustCDNProvider,

    getAsset: (self: SawdustCDNProvider, fetch_id: string) -> SawdustCDNReturnTemplate | Instance,
    getAllAssets: (self: SawdustCDNProvider) -> {[string]: SawdustCDNReturnTemplate | Instance},

    hasAsset: (self: SawdustCDNProvider, asset_id: string) -> boolean
}

local provider = {} :: self_methods
provider.__index = provider

export type SawdustCDNReturnTemplate = {
    cdnInfo: {
        assetId: string
    }
}

type self = {
    provider: Folder,
    preload: __preload.SawdustCDNPreloader,
}
export type SawdustCDNProvider = typeof(setmetatable({} :: self, {} :: self_methods))
export type SawdustCDNPreloader = __preload.SawdustCDNPreloader

--[[
    Locates a CDN provider (in-memory or fresh lookup), and provides an
    interface to retrieve assets.

    On the first access of any provider, all meta will attempt to be preloaded.

    @param provider_name Name of provider
    
    @return SawdustCDNProvider
]]
function provider.getProvider(provider_name: string) : SawdustCDNProvider
    local _providers = cdnCache:hasEntry('_providers') 
        and cdnCache:findTable('_providers')
        or cdnCache:createTable('_providers')

    if _providers:hasEntry(provider_name) then
        return _providers:getValue(provider_name) end

    local self = setmetatable({} :: self, provider)
    
    self.provider = __settings.content.fetchFolder:FindFirstChild(provider_name)
    if not self.provider then
        error(`[{script.Name}] Provider '{provider_name}' not found in content folder.`) 
        return end 
    
    self.preload = __preload.new(self.provider)

    _providers:setValue(provider_name, self)
    return self
end

--[[
    Retrieves an asset from the CDN by its AssetID.
    Returns a table with metadata or an Instance if found. 
    
    @param fetch_id ID of asset to fetch

    @return SawdustCDNReturn | Instance
]]
function provider:getAsset(fetch_id: string) : SawdustCDNReturnTemplate | Instance
    local _assets = cdnCache:hasEntry('_assets') 
        and cdnCache:findTable('_assets')
        or cdnCache:createTable('_assets')

    local asset_id = `{self.provider.Name}.{fetch_id}`
    if _assets:hasEntry(asset_id) then
        local _cached_asset = _assets:getValue(asset_id)

        if __settings.global.debug and __settings.content.debug.cdn then
            print(`[{script.Name}] Fetched cached asset for "{self.provider.Name}.{fetch_id}"`) end
        return _cached_asset end

    local foundAsset = self.provider:FindFirstChild(fetch_id) :: Instance
    if not foundAsset then
        error(`[{script.Name}] Failed to locate asset "{fetch_id or '<no ID provided>'}" in provider "{self.provider.Name}"!`)
        return end

    local isMetadata = foundAsset:IsA('ModuleScript')
    local assetData
    if isMetadata then
        assetData = table.clone(require(foundAsset)) :: SawdustCDNReturnTemplate
        assetData.cdnInfo = {
            ['assetId'] = fetch_id
        }
    else
        assetData = foundAsset:Clone()
    end

    _assets:setValue(`{self.provider.Name}.{fetch_id}`, isMetadata and assetData or foundAsset)
    if __settings.global.debug and __settings.content.debug.cdn then
        print(`[{script.Name}] Fetched & saved asset "{self.provider.Name}.{fetch_id}" to cache.`) end

    return assetData
end

--[[
    Retrives all assets in the current provider.
    
    @return Table with all values [ID] = asset
]]
function provider:getAllAssets() : {}
    local assets = {}
    for _, child in pairs(self.provider:GetChildren()) do
        if child.Name:sub(1,2)=='__' then continue end

        assets[child.Name] = self:getAsset(child.Name)
    end

    return assets
end

--[[
    Returns the state of existence of an asset w/ a specific id. 
    
    @param asset_id Asset to search for
    
    @return boolean
]]
function provider:hasAsset(asset_id: string) : boolean
    return self.provider:FindFirstChild(asset_id) ~= nil
end

return provider