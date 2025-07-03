--[[

    Sawdust Cache Tests

    Griffin Dalby
    2025.06.24

    Unit tests for the "Cache" implementation.

--]]

--]] Services
local replicatedStorage = game:GetService('ReplicatedStorage')

--]] Modules
local sawdust = require(replicatedStorage.Sawdust)
local __settings = require(replicatedStorage.Sawdust.__internal.__settings)

local cache = sawdust.core.cache

--]] Settings
--]] Tests
local cacheGroup: sawdust.SawdustCache
local cacheTable: sawdust.SawdustCache

return function()
    describe('Basic Access', function()
        it('fetch group', function()
            cacheGroup = cache.findCache('__test_cache__')

            expect(cacheGroup).to.be.ok()
            expect(cacheGroup.contents).to.be.ok()
            expect(cacheGroup.getValue).to.be.ok()
        end)

        it('set/fetch key (abstracted)', function()
            cacheGroup:setValue('key', true)
            expect(cacheGroup:getValue('key')).to.be.equal(true)
        end)

        it(':setValue() saves internally', function()
            cacheGroup:setValue('key2', 'secondKey')

            expect(cacheGroup.contents['key']).to.be.equal(true)
            expect(cacheGroup.contents['key2']).to.be.equal('secondKey')
        end)
    end)

    describe('Nesting', function()
        it('create table', function()
            cacheTable = cacheGroup:createTable('__test_table__')

            expect(cacheTable).to.be.ok()
            expect(cacheTable.contents).to.be.ok()
            expect(cacheTable.getValue).to.be.ok()
        end)

        it('fetch table (abstracted)', function()
            expect(cacheGroup:findTable('__test_table__')).to.be.equal(cacheTable)
        end)

        it('fetch table (internally)', function()
            expect(cacheGroup.contents['__test_table__']).to.be.equal(cacheTable)
        end)

        it('set/fetch key', function()
            cacheTable:setValue('anotherKey', true)
            expect(cacheTable:getValue('anotherKey')).to.be.equal(true)
        end)

    end)
end