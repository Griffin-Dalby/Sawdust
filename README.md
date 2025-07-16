# 🌲 Sawdust Framework
![Made for Roblox](https://img.shields.io/badge/Made%20for-Roblox-red?logo=roblox)
![Lua](https://img.shields.io/badge/Powered%20by-Lua-yellow)
![GPLv3](https://img.shields.io/badge/License-GPLv3-blue)

Sawdust is a lightweight, modular framework for Roblox developers who want clarity, control, and smart abstractions, without the bloat 😉

> 💖 Built with love by **Griffin Dalby**<br>
> 🛠 Designed for efficient, easy-to-read, and easy-to-use code - made for devs who hate reading docs.

---

## ✨ Features

- 💉 **Service Injection System**  
  Build, inject, and manage services with dependency resolution.

- 🔗 **Smart Networking**
  Networking w/ a custom protocol for secure returns from each side, all with a friendly interface.

- 📦 **CDN System**
  Efficient asset delivery with preload batching and efficient caching.

- 📣 **Signal Emitters**
  Embeddable event behavior for services or general-purpose modules.

- 📜 **Cache API**
  Stackable cache management built for structure, and speed.

- 🧹 **Maid Utility**
  Clean up anything, connections, callbacks, instances, all with tag-based logic.

- ✈ **And much, much more planned**
  I hope to get as much quality of life features as possible.

- 🌳 **Lignin**
  Lignin is a plugin being developed to aid even further with sawdust development.
  You'll be able to gradually create networking channels and events/functions, and many more things
  All of these will create automatic type metadata for a dynamic feeling typechecking experience including assetIds and networking event names.

---

## 🧠 Philosophy

Sawdust is designed to:
- Give **maximum control** to the developer
- Encourage **clean runtime logic**
- Reduce **boilerplate**
- Promote **discoverabiliy** via tooling & naming clarity
- Minimize documentation checks

You get **injection + dependency** management without losing Luau's flexibility.

---

## 🚚 Installation

1. Drop the Sawdust folder into `ReplicatedStorage`
2. Access it on server or client via:
```lua
local sawdust = require(game:GetService('ReplicatedStorage').Sawdust)
```
3. Access the implementations like:
```lua
local sawdust = require(game:GetService('ReplicatedStorage').Sawdust)

local services = sawdust.services
local networking = sawdust.networking
local cache = sawdust.cache
```

---

## 🚀 Quick Start

### Network from server <-> client
```lua
--> In StarterCharacterScripts.Mechanics

local networking = sawdust.core.networking
local mechanics = networking.getChannel('mechanics')

mechanics.skill:useMiddleware('after', 1, function(pipeline)
    --> I'll fill this all out soon I just want to push this for the rodev game jam tmr I love this module
end)

mechanics.skill:with() --> Returns a new call
    :headers('use')
    :data('fireball', mousePosition)
    :timeout(4)
    :invoke() --> Returns a promise
        :finally(function(req)
            local headers, data = req.headers, req.data
            local didUse = (data[1]==true)


        end)
        :catch(function(issue)
            warn('Issue with skill: fireball')
            warn(issue)
        end)

```

```lua
--> In ServerScriptService.Mechanics

local networking = sawdust.core.networking
local mechanics = networking.getChannel('mechanics')

mechanics.skill:handle(function(req, res)
    local headers, data = req.headers, req.data

    res.setHeaders('success')
    res.setData('Whatever you\\\'d need')
    res.send() --> Send the data and headers set
end)
```

### Build a Service
```lua
--> In ServerScriptService.SawdustServices

local builder = sawdust.builder
local services = sawdust.services

services:register(builder.new('OtherService')
    :init(function(self, deps) --> 'init' runtime phase
        self.data = 'Hello!' --> Set OtherService.data to 'Hello!'
    end)
    :method('methodName', function(msg) --> Create a new method (OtherService.methodName(msg))
        print(`Method was called, message: "{msg}"`)
    end)
    :inject('init', function(self, deps) --> Inject function into 'init' runtime phase
        print('Injection into OtherService success!')
    end))

services:register(builder.new('ExampleService')
    :dependsOn('OtherService') --> Depend on the OtherService
    :init(function(self, deps) --> :init() phase
        self.otherService = deps.OtherService
    end)
    :start(function(self) --> :start() phase
        print(`Data from other service: "{self.otherService.data}"`)
        self.otherService.methodName('I called the function from ExampleService!')
    end))

services:resolveAll() --> :init() all services
services:startAll() --> :start() all services

--[[

    This should print this, in order:
    'Injection into OtherService success!'
    'Data from other service: "Hello!"'
    'Method was called, message: "I called the function from ExampleService!"'

--]]

```

## 🧪 Tests
I've built unit tests for sawdust and [all of the implementations]("This may not be ALL implementations at time of reading, I may still be working on some."), you can read more about this

---

## 📖 Documentation
I do hate documentation, and this library is being built to be independent of documentation, however one is being built but not yet published. <br>
Until it's finished, check the [Changelog](CHANGELOG.md) for detailed module additions and improvements.

---

## 📚 Modules

#### Services
| Module | Description |
| ------ | ----------- |
| ```builder``` | Service definition w/ injections & dependencies |
| ```services``` | Service resolver, runner, and state tracker |

#### Core
| Module | Description |
| ------ | ----------- |
| ```networking``` | Middleware & event channels |
| ```promise``` | Promise system modeled after NodeJS |
| ```signal``` | Simple event emitter system |
| ```cache``` | Fast, structured memory management |
| ```cdn``` | Asset delivery w/ preload features |

#### Util
| Module | Description |
| ------ | ----------- |
| ```maid``` | Cleanup utility for tagged objects |
| ```debounce``` | Timed and interactable debounces |
| ```enum_map``` | "Maps" enums to human readable, and back. |
| ```states```| Simple dynamic state management |
| ```timer```| Heartbeat wrapper w/ decay and start/stop control |
| ```uuid``` | Customizable UUID generator |

---

## 📜 License
This library complies with GNU-GPL-3.0-or-later.