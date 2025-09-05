--[[

    Sawdust CDN Tests

    Griffin Dalby
    6/22/25

    Unit tests for the "CDN" implementation.

--]]

--]] Services
local replicatedStorage = game:GetService('ReplicatedStorage')

--]] Modules
local sawdust = require(replicatedStorage.Sawdust)
local __settings = require(replicatedStorage.Sawdust.__internal.__settings)

local cdn = sawdust.core.cdn

--]] Settings
--]] Tests
local cdn_folder = __settings.content.fetchFolder

local provider_folder, example_asset, example_meta
local provider

return function()
    describe('Fetching Provider', function()
        it('access folder & build test environment', function()
            expect(cdn_folder).to.be.ok()

            provider_folder = Instance.new('Folder')
            provider_folder.Name = '__test_provider__'
            provider_folder.Parent = cdn_folder

            example_asset = Instance.new('Part')
            example_asset.Name = '_test_asset__'
            example_asset.Parent = provider_folder

            example_meta = Instance.new('ModuleScript')
            example_meta.Source = `return \{\n    table = \{\n        str = "Hello, World!",\n        num = 12345\n    },\n    \n    model = script.Parent._test_asset__\n}`
            example_meta.Name = '_test_meta__'
            example_meta.Parent = provider_folder

            expect(provider_folder).to.be.ok()
            expect(example_asset).to.be.ok()
            expect(example_meta).to.be.ok()
        end)

        it('locate provider', function()
            provider = cdn.getProvider('__test_provider__')

            expect(provider).to.be.ok()
        end)
    end)

    describe('Fetching Assets', function()
        it('verify asset existence', function()
            expect(provider:hasAsset('_test_asset__')).to.be.equal(true)
            expect(provider:hasAsset('_test_meta__')).to.be.equal(true)
        end)

        it('fetch asset', function()
            local asset = provider:getAsset('_test_asset__')

            expect(asset).to.be.ok()
        end)

        it('fetch & read meta', function()
            local meta = provider:getAsset('_test_meta__')

            expect(meta).to.be.ok()
            expect(meta).to.be.a('table')

            expect(meta['table']).to.be.ok()
            expect(meta['table']['str']).to.be.equal('Hello, World!')
            expect(meta['table']['num']).to.be.equal(12345)
            expect(meta['model']).to.be.equal(example_asset)
        end)

        it('fetch all assets', function()
            local assets = provider:getAllAssets()

            local found_asset, found_meta = false, false
            for asset_name, asset in pairs(assets) do
                if asset_name=='_test_asset__' then
                    found_asset = true
                elseif asset_name=='_test_meta__' then
                    found_meta = true end
            end

            expect(found_asset).to.be.equal(true)
            expect(found_meta).to.be.equal(true)
        end)
    end)
end