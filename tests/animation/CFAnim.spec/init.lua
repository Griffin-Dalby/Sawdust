--[[

    Sawdust CFAnim Tests

    Griffin Dalby
    2025.06.24

    Unit tests for the "CFAnim" animation implementation.

--]]

--]] Services
local replicatedStorage = game:GetService('ReplicatedStorage')

--]] Modules
local sawdust = require(replicatedStorage.Sawdust)
local __settings = require(replicatedStorage.Sawdust.__internal.__settings)

local cfanim = sawdust.animation.cfanim

--]] Settings
--]] Tests
local model: Model
local builder: cfanim.CFAnimBuilder
local animation: cfanim.CFAnimator

return function()
    describe('Creation', function()
        it('setup env', function()
            warn('For animations, you must have a template R6 model in ReplicatedStorage named "Model"!')
            
            model = replicatedStorage:FindFirstChild('Model')
            expect(model).to.be.ok()

            model = model:Clone()
            expect(model).to.be.ok()
        end)

        it('create CFAnim builder & environment', function()
            builder = cfanim.newBuilder()
                :rig('rig1', model)
            
            expect(builder).to.be.ok()
            expect(builder._timelines).to.be.ok()
            expect(builder._environment['rig1']).to.be.ok()
        end)

        it('create timeline & keyframes', function()
            builder:timeline('rig1', function(timeline: cfanim.CFAnimTimeline)
                timeline:keyframe(0, {
                    ['Torso.Right Shoulder'] = CFrame.Angles(math.rad(10), 0, 0),
                    ['Torso.Neck'] = CFrame.Angles(0, math.rad(15), 0),
                    ['Torso.Right Hip'] = CFrame.Angles(math.rad(0), math.rad(0), math.rad(-25))
                })
                timeline:keyframe(1, {
                    ['Torso'] = {
                        ['Right Shoulder'] = CFrame.Angles(math.rad(20), 0, 0),
                        ['Neck'] = CFrame.Angles(0, math.rad(30), 0)
                    },
                })
                timeline:keyframe(2, {
                    ['Torso.Right Shoulder'] = CFrame.Angles(math.rad(30), 0, 0),
                    ['Torso'] = {
                        ['Neck'] = CFrame.Angles(0, math.rad(20), 0),
                        ['Right Hip'] = CFrame.Angles(math.rad(0), math.rad(5), math.rad(80))
                    }
                })
            end)

            expect(builder._timelines['rig1']).to.be.ok()
        end)

        it('build animation', function()
            animation = builder:build()

            expect(animation).to.be.ok()
            expect(animation._environment).to.be.ok()
            expect(animation._timelines).to.be.ok()

            expect(animation.playing).to.be.equal(false)
        end)
    end)

    describe('Playback', function()
        it('prepare model & point camera', function()
            model.Parent = workspace.Terrain
            model:PivotTo(CFrame.new())

            expect(model.Parent).to.be.equal(workspace.Terrain)

            workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
            workspace.CurrentCamera.CFrame = CFrame.lookAt(Vector3.new(0, 0, -10), model.PrimaryPart.Position)
            workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed
        end)

        it('play animation', function()
            task.wait(.25)
            animation:play()

            expect(animation.playing).to.be.equal(true)
        end)

        it('pause animation', function()
            task.wait(.5)
            animation:pause()

            expect(animation.playing).to.be.equal(false)
        end)

        it('resume animation', function()
            task.wait(.5)
            animation:play()

            expect(animation.playing).to.be.equal(true)
        end)
    end)
end