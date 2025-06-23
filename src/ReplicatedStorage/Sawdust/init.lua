--[[
	
	Sawdust Module
	
	Griffin E. Dalby
	6/12/25
	
	"Sawdust" is a collection of modules that I use,
	all combined in one, easy to use, streamlined module.
	
	It's all extremley modular and takes advantage of types
	as much as humanly possible for the easiest possible
	programming experience.
	
--]]

--]] Internals
local __internal = script.__internal

local __settings = require(__internal.__settings)
local __service_manager = require(__internal.__service_manager)

--]] Implementations
local __impl = script.__impl
local __is_dev = game:GetService('RunService'):IsStudio()

--> Check Integrity
if __is_dev then
	for _, module: ModuleScript in pairs(__impl:GetChildren()) do
		if not module:IsA('ModuleScript') then continue end

		local ok, res = pcall(require, module)
		assert(ok, `[{script.Name}] Implementation "{module.Name}" is broken!\n{res}`)
	end
end

--> Commit
local networking = require(__impl.networking)
local builder = require(__impl.builder)
local promise = require(__impl.promise)
local signal = require(__impl.signal)
local cache = require(__impl.cache)
local util = require(__impl.util)
local cdn = require(__impl.cdn)

--]] Sawdust
local sawdust = {} :: {
	services: __service_manager.SawdustSVCManager,
	builder: typeof(__impl.builder),

	core: {
		networking: typeof(__impl.networking),
		promise: typeof(__impl.promise),
		signal: typeof(__impl.signal),
		cache: typeof(__impl.cache),
		util: typeof(__impl.util),
		cdn: typeof(__impl.cdn)
	},
}

--[[ SERVICES ]]--
sawdust.services = __service_manager.new() --> Create services
sawdust.builder = builder --> Expose service builder
export type SawdustSVCManager = __service_manager.SawdustSVCManager --> Expose SVCManager type
export type SawdustSVCInjection = builder.SawdustSVCInjection --> Expose SVCInjection type
export type SawdustService = builder.SawdustService --> Expose service type

--[[ CORE ]]--
local core = {}
sawdust.core = core

--]] NETWORKING
core.networking = networking
export type SawdustEvent = networking.SawdustEvent
export type SawdustChannel = networking.SawdustChannel
export type SawdustMiddleware = networking.SawdustMiddleware
export type SawdustPipeline = networking.SawdustPipeline
export type SawdustConnection = networking.SawdustConnection


--]] PROMISES
core.promise = promise
export type SawdustPromise = promise.SawdustPromise


--]] SIGNAL
core.signal = signal
export type SawdustEmitter = signal.SawdustEmitter
export type SawdustSignal = signal.SawdustSignal
export type SawdustSignalConnection = signal.SawdustSignalConnection


--]] CACHE
core.cache = cache
export type SawdustCache = cache.SawdustCache


--]] UTIL
core.util = util
export type SawdustMaid = util.SawdustMaid
export type SawdustTimer = util.SawdustTimer
export type SawdustEnumMap = util.SawdustEnumMap


--]] CDN
core.cdn = cdn
export type SawdustCDNProvider = cdn.SawdustCDNProvider
export type SawdustCDNPreloader = cdn.SawdustCDNPreloader
export type SawdustCDNReturnTemplate = cdn.SawdustCDNReturnTemplate


return sawdust