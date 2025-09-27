--[[

    Sawdust Promises

    Griffin Dalby
    2025.06.19

    This implementation will provide "Promises", an object representing
    the eventual completion (or failure) of an async function.
    My goal is having it to act much like NodeJS' promises system

    Example usage:

    local promises = Sawdust.promise

    promises.new()

--]]

--]] Promises
local promise = {}
promise.__index = promise

type anyFunction = (...any) -> ...any

type self = {
    _state: "pending"|"fulfilled"|"rejected",
    _value: {any},
    _queue: {}
}
export type SawdustPromise = typeof(setmetatable({} :: self, promise))

function promise:_settle(state, res)
    if self._state ~= 'pending' then return end

    self._state = state
    self._value = res

    for _, queued in ipairs(self._queue) do
        if state == 'fulfilled' then task.defer(queued.success, unpack(res))
        else task.defer(queued.fail, unpack(res)) end
    end

    self._queue = {}
end

--[[ promise.new(callback: (resolve: anyFunction, reject: anyFunction))
    Creates a new async function, and lets developers call resolve() or
    reject() to return data through two different paths. ]]
function promise.new(callback: (resolve: anyFunction, reject: anyFunction) -> nil): SawdustPromise
    local self = setmetatable({
        _state = 'pending',
        _value = {},
        _queue = {},
    } :: self, promise)

    --> Resolve promise
    local function resolve(...)
        self:_settle('fulfilled', {...}) end
    local function reject(...)
        self:_settle('rejected', {...}) end

    callback(resolve, reject)

    return self
end

--[[ promise.resolve(...)
    Returns an instantly fulfilled promise. ]]
function promise.resolve(...): SawdustPromise
    local args = {...}
    return promise.new(function(resolve)
        resolve(unpack(args)) end) end

--[[ promise.reject(...)
    Returns an instantly rejected promise. ]]
function promise.reject(...): SawdustPromise
    local args = {...}
    return promise.new(function(_, reject)
        reject(unpack(args)) end) end

--[[ promise.race(promises: {SawdustPromise})
    "Races" a selection of promises, resolving or rejecting
    with the first one that settles. ]]
function promise.race(promises: {SawdustPromise})
    return promise.new(function(resolve, reject)
        local settled = false
        
        local function checkSettle(status: 'fulfilled'|'rejected', ...)
            if not settled then
                settled = true
                if status=='fulfilled' then resolve(...) else reject(...) end
            end
        end

        for _, p in pairs(promises) do
            p:andThen(function(...)
                checkSettle('fulfilled', ...)
            end):catch(function(...)
                checkSettle('rejected', ...)
            end)
        end
    end)
end

--[[ promise.settleAll(promises: {SawdustPromise})
    Resolves or rejects when all promises settle, returning
    array with the results of each. ]]
function promise.settleAll(promises: {SawdustPromise})
    return promise.new(function(resolve, reject)
        local results = table.create(#promises)
        local completed = 0

        local function save(status: 'fulfilled'|'rejected', i, p, ...)
            results[i] = {
                status = status,
                value = ...
            }
            
            completed += 1
            if completed == #promises then
                resolve(results) end
        end
        
        for i, p in ipairs(promises) do
            p:andThen(function(...)
                save('fulfilled', i, p, ...)
            end):catch(function(...)
                save('rejected', i, p, ...)
            end)
        end
    end)
end




--[[ promise:andThen(callback: (...any) -> ...any)
    Chains a 'then' operation, taking the results of the last chained
    action, and setting _value to the result of this action. ]]
function promise:andThen(callback: anyFunction): SawdustPromise
    local nextPromise = promise.new(function(resolve, reject)
        local function handleSuccess(...)
            local ok, res = pcall(callback, ...)
            if ok then resolve(res) else reject(res) end end
        local function handleFailure(...)
            reject(...) end

        if self._state == 'fulfilled' then
            task.defer(handleSuccess, unpack(self._value))
        elseif self._state == 'rejected' then
            task.defer(handleFailure, unpack(self._value))
        else
            table.insert(self._queue, {
                success = handleSuccess,
                fail = handleFailure,
                resolve = resolve,
            })
        end
    end)

    return nextPromise
end

--[[ promise:catch(callback(...any))
    Catches any error that comes from the last chained action, or the
    inital promise. ]]
function promise:catch(callback: (...any) -> nil): SawdustPromise
    return promise.new(function(resolve, reject)
        local function handleFailure(...)
            local ok, res = pcall(callback, ...)
            if ok then resolve(res) else reject(res) end
        end

        if self._state == 'rejected' then
            task.defer(handleFailure, unpack(self._value))
        else
            table.insert(self._queue, {
                success = resolve,
                fail = handleFailure
            })
        end
    end)
end

--[[ promise:finally(callback: () -> ())
    Always runs regardless of fulfillment or rejection, and also passes
    nothing. ]]
function promise:finally(callback: () -> ()): SawdustPromise
    return self:andThen(function(...)
        callback()
        return ...
    end):catch(function(...)
        callback()
        error(...)
    end)
end

--[[ promise:wait(timeout: number?) : any...
    Yields the current thread until this promise resolves/rejects
    You can modify the timeout time to avoid an infinite yield.

    This will return a success status boolean, as well as an unpacked
    tuple array of the promise return data. ]]
function promise:wait(timeout_time: number?)
    timeout_time = timeout_time or 5

    local did_timeout = false
    task.delay(timeout_time, function()
        did_timeout = true; end)

    repeat task.wait(0) until (self._state=='fulfilled' or self._state=='rejected') or did_timeout

    assert(not did_timeout, `promise:wait() timed out after {timeout_time} seconds!`)
    return (self._state=='fulfilled'), unpack(self._value)
end

return promise