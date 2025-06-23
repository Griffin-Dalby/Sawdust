--[[

    Sawdust Networking Tests

    Griffin Dalby
    6/22/25

    Unit tests for the "Networking" implementation.

--]]

--]] Services
local replicatedStorage = game:GetService('ReplicatedStorage')

--]] Modules
local sawdust = require(replicatedStorage.Sawdust)
local __settings = require(replicatedStorage.Sawdust.__internal.__settings)

local networking = sawdust.core.networking

--]] Settings
local unitTestFolderName = '__unit_tests__'

local yieldTimeout = 2

--]] Tests

local channelFolder = __settings.networking.fetchFolder
function cleanEnv()
    local testFolder = channelFolder:FindFirstChild(unitTestFolderName)
    if testFolder then
        testFolder:Destroy() end
end

local channel
local evConn, fnConn
return function()
    describe('Networking Logic', function()
        it('initalize environment', function()
            if channelFolder:FindFirstChild('__unit_tests__') then
                expect(true).to.be.equal(true)
                return true
            end

            --> Create Env
            local testFolder = Instance.new('Folder')
            testFolder.Name = unitTestFolderName
            testFolder.Parent = channelFolder

            local testEvent = Instance.new('RemoteEvent')
            testEvent.Name = 'event'
            testEvent.Parent = testFolder

            local testFunction = Instance.new('RemoteFunction')
            testFunction.Name = 'func'
            testFunction.Parent = testFolder
            
            --> Finish
            expect(testFolder.Parent).never.to.equal(nil)
            expect(testEvent.Parent).to.equal(testFolder)
            expect(testFunction.Parent).to.equal(testFolder)

        end)

        it('fetch channel', function()
            channel = networking.getChannel(unitTestFolderName)

            expect(channel).to.be.ok()
            expect(channel.event).to.be.ok()
            expect(channel.func).to.be.ok()
            
        end)
        
        it('connect event', function()
            evConn = channel.event:connect(function(returnArg)
                
            end)

            expect(evConn).to.be.ok()
            expect(evConn.uuid).to.be.ok()
            
            evConn:disconnect()

            expect(evConn.uuid).never.to.be.ok()
        end)

        it('fire event', function()
            expect(function()
                channel.event:fire('Argument1', 'Argument2')
            end).never.to.throw()
        end)
    end)

    describe('Middleware', function()
        it('test creation & argument modifiers', function()
            local hit = false
            task.delay(yieldTimeout, function()
                if not hit then error('timed out!') end end)

            channel.event.middleware:use('before', 1, function(pipeline)
                local arg1 = pipeline:getArguments()
                expect(arg1).to.be.equal('inital')

                hit = true
                pipeline:setArguments('modified')

                local newArg1 = pipeline:getArguments()
                expect(newArg1).to.be.equal('modified')

                pipeline:setArguments('final modification')
            end)

            local pipeline = channel.event:fire('inital')
            expect({pipeline:getArguments()}).to.be.equal{'final modification'}
        end)

        it('test halt', function()
            local hit = false
            task.delay(yieldTimeout, function()
                if not hit then error('timed out!') end end)

            channel.event.middleware:use('before', 1, function(pipeline)
                pipeline:setHalted(true)
                pipeline:setError('error')
            end)

            local pipeline = channel.event:fire('inital')
            expect(pipeline:isHalted()).to.be.equal(true)
            expect(pipeline:getError()).to.be.equal('error')
        end)

        it('test 10 middlewares', function()
            local hit = false
            task.delay(yieldTimeout+(yieldTimeout*1.5), function()
                if not hit then error('timed out!') end end)
            
            for i=1,10 do
                channel.event.middleware:use('before', i, function(pipeline)
                    expect({pipeline:getArguments()}).to.be.equal{i-1}
                    pipeline:setArguments(i)
                end)
            end

            channel.event:fire(0)
        end)
    end)
end