--[[

    Sawdust States Tests

    Griffin Dalby
    2025.09.05

    Unit tests for the "States" implementation.

--]]

--]] Services
local replicatedStorage = game:GetService('ReplicatedStorage')

--]] Modules
local sawdust = require(replicatedStorage.Sawdust)
local __settings = require(replicatedStorage.Sawdust.__internal.__settings)

local states = sawdust.core.states

--]] Settings
--]] Tests
local state_machine

local s_primary: sawdust.SawdustState, s_secondary: sawdust.SawdustState,
      s_teritary: sawdust.SawdustState, s_quaternary: sawdust.SawdustState,
      s_bounce: sawdust.SawdustState

return function()
    describe('State Machine', function()
        it('create State Machine', function()
            state_machine = states.create()
            expect(state_machine).to.be.ok()
        end)

        it('create states', function()
            s_primary = state_machine:state('primary')
            s_secondary = state_machine:state('secondary')
                :hook('enter', function(env)
                    env.__test_run__ = false
                end)

            s_teritary = state_machine:state('tertiary')
            s_quaternary = state_machine:state('quaternary')
                :hook('enter', function(env)
                    env.shared.__hook_entered__ = true
                end)
                :hook('exit', function(env)
                    env.shared.__hook_exited__ = true
                end)

                :hook('update', function(env, delta)
                    env.shared.__hook_updated__ = true
                end)

            s_bounce = state_machine:state('bounce')
                :hook('enter', function(env)
                    env.shared.__bounce_test_run__ = false
                end)

            expect(state_machine.states['primary']).to.be.ok()
            expect(state_machine.states['secondary']).to.be.ok()
            expect(state_machine.states['tertiary']).to.be.ok()
            expect(state_machine.states['quaternary']).to.be.ok()
            expect(state_machine.states['bounce']).to.be.ok()

            state_machine:switchState('primary')
        end)

        it('create transitions', function()
            s_primary:transition('secondary')
                :on('pri-sec')
            s_primary:transition('quaternary')
                :when(function(env)
                    return env.shared.__hook_test_run__ == true
                end)

            s_secondary:transition('tertiary')
                :when(function(env)
                    return env.__test_run__ == true
                end)
            s_secondary:transition('bounce')
                :when(function(env)
                    return env.shared.__bounce_test_run__ == true
                end)

            s_teritary:transition('primary')
                :when(function(env)
                    return env.shared.__transition_test_run__ == true
                end)

            s_bounce:transition('secondary')
                :after(.5)
        end)
    end)

    describe('Transitions', function()
        it('transition on event (primary -> secondary)', function()
            state_machine:event('pri-sec')
            task.wait(.1)
            
            expect(state_machine.c_state.name).to.be.equal('secondary')
        end)
        it('transition w/ conditional [scoped env] (secondary -> tertiary)', function()
            state_machine.c_state.environment.__test_run__ = true
            task.wait(.1)

            expect(state_machine.c_state.name).to.be.equal('tertiary')
        end)
        it('transition w/ conditional [shared env] (tertiary -> primary)', function()
            state_machine.environment.__transition_test_run__ = true
            task.wait(.1)

            expect(state_machine.c_state.name).to.be.equal('primary')
        end)
        it('lifecycle hook functionality (primary -> quaternary -> secondary)', function()
            state_machine.environment.__hook_test_run__ = true
            task.wait(.05)

            state_machine:switchState('secondary')
            task.wait(.05)

            expect(state_machine.environment.__hook_entered__).to.be.equal(true)
            expect(state_machine.environment.__hook_exited__).to.be.equal(true)
            expect(state_machine.environment.__hook_updated__).to.be.equal(true)
        end)

        it('transition after set time (secondary -> bounce -> secondary)', function()
            state_machine.environment.__bounce_test_run__ = true
            task.wait(1)
            expect(state_machine.c_state.name).to.be.equal('secondary')
        end)
    end)
end