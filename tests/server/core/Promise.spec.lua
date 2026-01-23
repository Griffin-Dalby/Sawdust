--[[

    Sawdust Promise Tests

    Griffin Dalby
    6/22/25

    Unit tests for the "Promise" implementation.

--]]

--]] Services
local replicatedStorage = game:GetService('ReplicatedStorage')

--]] Modules
local sawdust = require(replicatedStorage.Sawdust)

local promise = sawdust.core.promise

--]] Settings
--]] Tests

return function()
    describe('Promise Logic', function()
        it('resolve promises', function()
            promise.resolve('resolved')
                :andThen(function(value)
                    expect(value).to.equal('resolved')
                end)
        end)

        it('reject promises', function()
            promise.reject('rejected')
                :catch(function(err)
                    expect(err).to.equal('rejected')
                end)
        end)

        it('call finally despite outcome', function()
            local flag = false

            promise.reject('rejected'):finally(function(value)
                flag = true
            end):catch(function(err)
                expect(err).to.equal('rejected')
            end)
        end)

        it('chain :andThen()', function()
            promise.resolve(10)
                :andThen(function(value)
                    return value + 10
                end)
                :andThen(function(value)
                    expect(value).to.equal(20)
                end)
        end)
    end)

    describe('Promise Grouping', function()
        it('promise.race should resolve w/ first resolved value', function()
            local p1, p2 = 
                promise.new(function(resolve)
                    task.delay(.1, function()
                        resolve('fast')
                    end)
                end),
                promise.new(function(resolve)
                    task.delay(.2, function()
                        resolve('slow')
                    end)
                end)

            promise.race{p1, p2}
                :andThen(function(result)
                    expect(result).to.equal('fast')
                end)
        end)

        it('promise.settleAll should return status for all', function()
            local p1, p2 = 
                promise.resolve('resolved')
                promise.reject('rejected')

            promise.settleAll{p1, p2}
                :andThen(function(results)
                    expect(results[1].status).to.equal('fulfilled')

                    expect(results[2].status).to.equal('rejected')
                    expect(results[2].reason).to.equal('rejected')
                end)
        end)
    end)
end