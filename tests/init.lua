--[[

    Sawdust Unit Tests

    Griffin Dalby
    2025.06.22

    This script will simply use testEZ to run unit tests for each
    implementation.

--]]

local testEZ = require(game:GetService('ReplicatedStorage').Packages.testez)

return function ()
    for _, descendant in ipairs(script:GetDescendants()) do
        if descendant:IsA("ModuleScript") then
            print("Checking Integrity:", descendant:GetFullName())
            local ok, result = pcall(require, descendant)
            if not ok then
                warn("FAILED TO REQUIRE:", descendant:GetFullName())
                warn(result)
            end
        end
    end

    print('Running tests...\n')
    testEZ.TestBootstrap:run({script.core})
end