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
local provider = {}
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
export type SawdustCDNProvider = typeof(setmetatable({} :: self, provider))
export type SawdustCDNPreloader = __preload.SawdustCDNPreloader

--[[ provider.new()
    Constructor function for the CDN provider. ]]
function provider.getProvider(providerName: string) : SawdustCDNProvider
    local _providers = cdnCache:hasEntry('_providers') 
        and cdnCache:findTable('_providers')
        or cdnCache:createTable('_providers')

    local _cached_provider = _providers:getValue(providerName)
    if _cached_provider then
        return _cached_provider  end

    local self = setmetatable({} :: self, provider)
    
    self.provider = __settings.content.fetchFolder:FindFirstChild(providerName)
    if not self.provider then
        error(`[{script.Name}] Provider '{providerName}' not found in content folder.`) 
        return end 
    
    self.preload = __preload.new(self.provider)

    _providers:setValue(providerName, self)
    return self
end

--[[ provider:getAsset(assetId: string) : table |  Instance
    Retrieves an asset from the CDN by its AssetID.
    Returns a table with metadata or an Instance if found. ]]
function provider:getAsset(assetId: string) : SawdustCDNReturnTemplate | Instance
    local _assets = cdnCache:hasEntry('_assets') 
        and cdnCache:findTable('_assets')
        or cdnCache:createTable('_assets')

    local _cached_asset = _assets:getValue(`{self.provider.Name}.{assetId}`)
    if _cached_asset then
        if __settings.global.debug and __settings.content.debug.cdn then
            print(`[{script.Name}] Fetched cached asset for "{self.provider.Name}.{assetId}"`) end
        return _cached_asset end

    local foundAsset = self.provider:FindFirstChild(assetId) :: Instance
    if not foundAsset then
        error(`[{script.Name}] Failed to locate asset "{assetId or '<no ID provided>'}" in provider "{self.provider.Name}"!`)
        return end

    local isMetadata = foundAsset:IsA('ModuleScript')
    local assetData
    if isMetadata then
        assetData = table.clone(require(foundAsset)) :: SawdustCDNReturnTemplate
        assetData.cdnInfo = {
            ['assetId'] = assetId
        }
    else
        assetData = foundAsset:Clone()
    end

    _assets:setValue(`{self.provider.Name}.{assetId}`, isMetadata and assetData or foundAsset)
    if __settings.global.debug and __settings.content.debug.cdn then
        print(`[{script.Name}] Fetched & saved asset "{self.provider.Name}.{assetId}" to cache.`) end

    return assetData
end

return provider