--[[

    Model Planner

    Griffin Dalby
    2025.06.25

    This module will "plan" out models, providing inital configurations,
    and a structure that the developer and trackPlanner expects.

--]]

--]] Motor
local motor = {}
motor.__index = motor

type self_motor = {
    motor: Motor6D,
    initalC0: CFrame,
    initalC1: CFrame
}
export type MotorWrapper = typeof(setmetatable({} :: self_motor, motor))

function motor.wrap(motor: Motor6D): MotorWrapper
    local self = setmetatable({} :: self_motor, motor)

    self.motor = motor

    self.initalC0 = motor.C0
    self.initalC1 = motor.C1

    return self
end

--]] Planner
local planner = {}
planner.__index = planner

type self_planner = {
    _structure: {}
}
export type ModelPlanner = typeof(setmetatable({} :: self_planner, planner))

--[[ planner.plan(model: Model)
    "Plans" the model. ]]
function planner.plan(model: Model): ModelPlanner
    local self = setmetatable({} :: self_planner, planner)

    local function scan(instance: Instance)
        local returnData = {}
        local hasMotors = false

        for _, child: Instance in pairs(instance:GetChildren()) do
            if child:IsA('Motor6D') then
                hasMotors = true
                returnData[child.Name] = {
                    motor = child,
                    initalC0 = child.C0,
                    initalC1 = child.C1,
                }
            end

            local childScan, scanHasMotors = scan(child)
            if scanHasMotors then
                returnData[child.Name] = childScan
            end
        end

        return returnData, hasMotors
    end
    self._structure = scan(model)

    return self
end

--[[ planner:shorthand(path: string)
    Allows you to get a motor using shorthand (i.e. 'Torso.Neck', 'Torso.Right Shoulder') ]]
function planner:shorthand(path: string)
end

return planner