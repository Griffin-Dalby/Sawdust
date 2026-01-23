--!strict
--[[

    Networking Rate Limiter

    Griffin Dalby
    2026.01.16

    The Rate Limiter system allows developers to easily establish
    rate limits for events.

--]]

local WARE_ORDER = 5

--]] Services
local RunService = game:GetService("RunService")
local Https = game:GetService("HttpService")

--]] Modules
local net_root = script.Parent.Parent

--> Networking
local types = require(net_root.types)

--]] Module
export type methods_limiter = {
    --=======
    -- Constructor
    __index: methods_limiter,

    --[[
        Creates a new Limiter instance.
        @return RateLimiterComposer
    ]]
    new: () -> RateLimiterComposer,

    --=================--
    -- Compose Methods --
    --=================--

    --[[ Core Parameters ]]--

    --[[
        Sets the maximum bucket capacity
        @param max_capacity Maximum bucket capacity
    ]]
    Capacity: (self: RateLimiterComposer, max_capacity: number) -> RateLimiterComposer,
    --[[
        Sets the amount of tokens that get refilled each tick
        @param refill_rate Amount of tokens
    ]]
    Refill: (self: RateLimiterComposer, refill_rate: number) -> RateLimiterComposer,
    --[[
        Sets the cost of one request
        @param cost Amount of tokens
    ]]
    Cost: (self: RateLimiterComposer, cost: number) -> RateLimiterComposer,
    --[[
        Sets the handling behavior of the packet if it exceeds bucket size.<br>
        
        "allow" simply allows the packet to pass, useful for debugging, will flag with production enabled.<br>
        "drop" correlates to **token bucket** behavior.<br>
        "delay" correlates to **leaky bucket** behavior.
        @param behavior Either "allow", "drop" or "delay".
    ]]
    OnExceed: (self: RateLimiterComposer, behavior: "allow"|"drop"|"delay") -> RateLimiterComposer,

    --[[ Inital Capacity ]]--

    --[[
        Set the inital bucket capacity to a certain amount
        @param capacity Inital bucket capacity
    ]]
    StartAt: (self: RateLimiterComposer, capacity: number) -> RateLimiterComposer,
    --[[
        Set the inital bucket capacity to the maximum capacity
    ]]
    StartFull: (self: RateLimiterComposer) -> RateLimiterComposer,
    --[[
        Set the inital bucket capacity to empty
    ]]
    StartEmpty: (self: RateLimiterComposer) -> RateLimiterComposer,

    --[[ Attach ]]--

    --[[
        Attaches the composed Rate Limiter to a network event's 
        middleware system
        @param event NetworkEvent to attach to
    ]]
    Attach: (self: RateLimiterComposer, event: types.NetworkingEvent) -> nil,

    --===========--
    -- Accessors --
    --===========--
}


local limiter = {} :: methods_limiter
limiter.__index = limiter

--]] Constructor
export type self_limiter = {
    --> Properties
    maximum_capacity: number,
    capacity: number,

    refill_rate: number,
    cost: number,
    exceed_behavior: "allow"|"drop"|"delay",
}
export type RateLimiterComposer = typeof(setmetatable({} :: self_limiter, {} :: methods_limiter))

--[[
    Initalize all properties of the Limiter instance.

    @field maximum_capacity Maximum bucket size
    @field capacity Inital/Current bucket size

    @field refill_rate Tokens to refill per tick
    @field cost Cost of tokens per packet
    @field exceed_behavior "drop" for token bucket, "delay" for leaky bucket.
]]
function limiter.new()
    local self = setmetatable({} :: self_limiter, limiter :: methods_limiter)

    self.maximum_capacity = 100
    self.capacity = self.maximum_capacity

    self.refill_rate = 1
    self.cost = 1
    self.exceed_behavior = "drop"

    return self
end

--]] Compose Methods
function limiter:Capacity(maximum_capacity: number)
    self.maximum_capacity = maximum_capacity
    return self
end
function limiter:Refill(refill_rate: number)
    self.refill_rate = refill_rate 
    return self
end
function limiter:Cost(cost: number)
    self.cost = cost
    return self
end
function limiter:OnExceed(behavior: "allow"|"drop"|"delay")
    self.exceed_behavior = behavior
    return self
end

--> Inital Capacity
function limiter:StartAt(capacity: number)
    self.capacity = capacity 
    return self
end
function limiter:StartFull()
    self:StartAt(self.maximum_capacity) 
    return self 
end
function limiter:StartEmpty()
    self:StartAt(0)
    return self
end

--> Builder
function limiter:Attach(event: types.NetworkingEvent | (types.NetworkingConnection & {__middleware: types.NetworkingMiddleware?}))

    local bucket = {
        maximum_capacity = self.maximum_capacity,
        capacity = self.capacity,

        refill_rate = self.refill_rate,
        cost = self.cost,
        exceed_behavior = self.exceed_behavior,

        queue = {}
    }
    
    local middleware = (event.__middleware or event.middleware) :: types.NetworkingMiddleware

    local TICK_INTERVAL = .1 --> Update every interval seconds
    local tick_counter = 0

    --> Register Middleware
    local reg_id = middleware:Use('before', WARE_ORDER, function(pipeline: types.NetworkingPipeline)
        
        local new_capacity = self.capacity-self.cost
        
        if new_capacity<0 then --> Bucket Empty
            self.capacity = 0

            if bucket.exceed_behavior=="drop" then --> Token Bucket behavior
                pipeline:setHalted(true)
                pipeline:setData{"RateLimited"}

            elseif bucket.exceed_behavior=="delay" then --> Leaky Bucker behavior
                local queue_id = Https:GenerateGUID(false)
                table.insert(bucket.queue, queue_id)

                repeat task.wait(20/60) until table.find(bucket.queue, queue_id)==nil
            end

            return pipeline
        end

        self.capacity = new_capacity
        return pipeline
    end, { internal = true, protected = true })

    --> Create Runtime
    local runtime: RBXScriptConnection?
    runtime = RunService.Heartbeat:Connect(function(dT)
        tick_counter+=dT
        if tick_counter<TICK_INTERVAL then
            tick_counter = 0
            return 
        end

        --> Prevent Memory Leak
        if not(middleware 
           and middleware.__registry 
           and middleware.__registry.__internal.before[reg_id or WARE_ORDER]) then
                    
            if runtime then
                print(`Disconnect: No Middleware in Registry`)
                runtime:Disconnect()
                runtime = nil
            end
            return
        end

        --> Increase capacity
        bucket.capacity = math.max(bucket.capacity+bucket.refill_rate, bucket.maximum_capacity)
    
        --> Check queue
        if bucket.exceed_behavior=="delay" then
            if #bucket.queue>0 and bucket.capacity>=bucket.cost then
                --> Remove first from queue, causing it to quit yielding.
                table.remove(bucket.queue, 1)
                bucket.capacity-=bucket.cost
            end
        end
    end)
    return nil
end

--]] Accessors

return limiter