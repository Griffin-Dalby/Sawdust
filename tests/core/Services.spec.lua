--[[

    Sawdust Networking Tests

    Griffin Dalby
    6/22/25

    Unit tests for "Services" & the "builder" implementation.

--]]

--]] Services
local replicatedStorage = game:GetService('ReplicatedStorage')

--]] Modules
local sawdust = require(replicatedStorage.Sawdust)
local __settings = require(replicatedStorage.Sawdust.__internal.__settings)

local services = sawdust.services
local builder = sawdust.builder

--]] Settings
--]] Tests

type timings = {
    inject: number?,
    start: number?
}

local data = {
    svc1_timings = {},
    svc2_timings = {},

    tests = {}
} :: {
    svc1_timings: timings,
    svc2_timings: timings,

    tests: {
        method: boolean?,

        startDeps: boolean,
        startDepsReturn: boolean,

        injectDeps: boolean,
        injectDepsReturn: boolean,
        injectDepsValue: boolean,
    }
}

local svc1: sawdust.SawdustService, svc2: sawdust.SawdustService
return function()
    describe('Builder', function()
        it('build svc1 (& basic checks)', function()
            svc1 = builder.new('__test_svc_1')
                :init(function(self)
                    self.data = true
                end)
                :start(function(self)
                    data.svc1_timings.start = tick()
                end)
                :method('aMethod', function(self, number)
                    return number * 10
                end)
                :method('injectMethod', function(self)
                    data.tests.injectDeps = true
                    return true
                end)
                :method('startMethod', function(self)
                    data.tests.startDeps = true
                    return true
                end)
                :inject('init', function(self, deps)
                    data.svc1_timings.inject = tick()
                end)

            --> init/start
            expect(svc1).to.be.ok()
            -- expect(svc1._initfn).to.be.ok()
            -- expect(svc1._startfn).to.be.ok()
            
            --> ID & Injections
            expect(svc1.id).to.be.equal('__test_svc_1')
            expect(svc1.injections).to.be.a('table')
            expect(#svc1.injections.init).to.be.equal(1)

            --> Methods
            expect(svc1.method).to.be.ok()
            expect(svc1.injectMethod).to.be.ok()
            expect(svc1.startMethod).to.be.ok()
        end)

        it('build svc2 (& dependency checks)', function()
            svc2 = builder.new('__test_svc_2')
                :dependsOn('__test_svc_1')
                :init(function(self, deps)
                    self.svc1 = deps.__test_svc_1
                end)
                :start(function(self)
                    data.svc2_timings.start = tick()
                    data.tests.startDepsReturn = self.svc1.startMethod()
                    data.tests.startDepsValue = self.svc1.data

                    local base = 10
                    local expected = base * 10

                    local returned = self.svc1.aMethod(base)
                    data.tests.method = (returned == expected)
                end)
                :inject('init', function(self)
                    data.svc2_timings.inject = tick()
                    
                    data.tests.injectDepsReturn = self.svc1.injectMethod()
                    data.tests.injectDepsValue = self.svc1.data
                end)
            
            expect(svc2).to.be.ok()

            --> init/start
            expect(svc2).to.be.ok()
            expect(svc2._initfn).to.be.ok()
            expect(svc2._startfn).to.be.ok()
            
            --> ID & Injections
            expect(svc2.id).to.be.equal('__test_svc_2')
            expect(svc2.injections).to.be.a('table')
            expect(#svc2.injections.init).to.be.equal(1)

            --> Dependencies
            expect(#svc2.dependencies).to.be.equal(1)
            expect(svc2.dependencies[1]).to.be.equal('__test_svc_1')
        end)
    end)

    describe('Registration & Resolve', function()
        it('register & resolve services', function()
            services:register(svc1)
            services:register(svc2)

            expect(services._registry[svc1.id]).to.be.equal(svc1)
            expect(services._registry[svc2.id]).to.be.equal(svc2)

            services:resolveAll()
        end)

        it('svc timings', function()
            expect(data.svc1_timings.inject).to.be.ok()
            expect(data.svc2_timings.inject).to.be.ok()

            expect(data.svc1_timings.inject < data.svc2_timings.inject).to.be.equal(true)
        end)

        it('self & dependency access', function()
            expect(data.tests.injectDeps).to.be.equal(true)
            expect(data.tests.injectDepsReturn).to.be.equal(true)
            expect(data.tests.injectDepsValue).to.be.equal(true)
        end)
    end)

    describe('Starting Services', function()
        it('start services', function()
            services:startAll()
            
            expect(data.svc1_timings.start).to.be.ok()
            expect(data.svc2_timings.start).to.be.ok()
        end)

        it('dependency & method access', function()
            expect(data.tests.method).to.be.equal(true)

            expect(data.tests.startDeps).to.be.equal(true)
            expect(data.tests.startDepsReturn).to.be.equal(true)
            expect(data.tests.startDepsValue).to.be.equal(true)
        end)
    end)
end