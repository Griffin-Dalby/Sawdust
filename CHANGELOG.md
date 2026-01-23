# Changelog

## [1.6.0](https://github.com/Griffin-Dalby/Sawdust/compare/v1.5.1...v1.6.0) (2026-01-23)


### Features

* **networking:** Networking V2. ([f0becfe](https://github.com/Griffin-Dalby/Sawdust/commit/f0becfe27895dbe805af1ac33e584aaa8a98e276))
* **promise:** Documented methods in type, and added an "Await" method, that returns a new promising, resolving or rejecting once a table of promises all complete. ([93bff7c](https://github.com/Griffin-Dalby/Sawdust/commit/93bff7cbc852e527c1970a22d22a42d05fdcfa72))
* **tests:** Tests are not located in a seperate folder, outside of src/ ([0923259](https://github.com/Griffin-Dalby/Sawdust/commit/09232590684032cd0c032dfe2af68452849af217))


### Bug Fixes

* **builder:** Fixed issues with new typesolver, split methods and properties. ([76627cb](https://github.com/Griffin-Dalby/Sawdust/commit/76627cbefa934e1ed50e24b187d1d5b6c5b6025b))
* **cdn:** Fixed issues with new typesolver, split methods and properties. ([1fb770e](https://github.com/Griffin-Dalby/Sawdust/commit/1fb770eee88f6f646ef1b262de36d6106a3fd251))
* **cdn:** Method Types did not include self argument. ([07832f6](https://github.com/Griffin-Dalby/Sawdust/commit/07832f60290c1ba7a17010e287ae3f844eb3ce4f))
* **maid:** Fixed tags being nil, after :clean() iterates over a previously cleaned element. ([cd38d7f](https://github.com/Griffin-Dalby/Sawdust/commit/cd38d7fef43d08baf6e450957eab0f84bafb2088))
* **networking:** Fixed composition type solve issues for data and callbacks ([f302bf5](https://github.com/Griffin-Dalby/Sawdust/commit/f302bf531df632425ea1fd059153ee0030f347da))
* **networking:** Fixed rest of types under strict typechecking, preparing for limiter. ([b7ced2c](https://github.com/Griffin-Dalby/Sawdust/commit/b7ced2ca984cf3c23ea6db3769187eecae89e1e0))
* **networking:** Fixed types under strict typechecking to iron any edge cases ([3664fab](https://github.com/Griffin-Dalby/Sawdust/commit/3664fabf1636d70bc2f65737ca95896933c7b2dc))
* **networking:** Fully transitioned metatables to modern type syntax ([5d82b50](https://github.com/Griffin-Dalby/Sawdust/commit/5d82b50a61cfe720b5ba6ce32795ff500778e03b))
* **promise:** Fixed issues with new typesolver, split methods and properties. ([c961e72](https://github.com/Griffin-Dalby/Sawdust/commit/c961e72f09e44786a3c2074ca9c7bed09152d186))
* **promise:** Fully migrated & fixed promise methods ([474c91d](https://github.com/Griffin-Dalby/Sawdust/commit/474c91da27b8650c66acf8b12c6703608b3e7da1))
* **sawdust:** Fixed dev-util gitignore overlapping with util modules ([2d93947](https://github.com/Griffin-Dalby/Sawdust/commit/2d93947b259129293327fa4c70b7e0c73373389a))
* **signal:** Event Generics now support a varadic any argument, rather than a strict singular any argument. ([934385d](https://github.com/Griffin-Dalby/Sawdust/commit/934385d03acc8777af4893861635d7c176f2b0b2))

## [1.5.1](https://github.com/Griffin-Dalby/Sawdust/compare/v1.5.0...v1.5.1) (2026-01-02)


### Bug Fixes

* **networking:** Ensured pipeline & router adhere to new NetworkingCall schemantics. ([833f243](https://github.com/Griffin-Dalby/Sawdust/commit/833f24362747dc9b9140e4efbba0bd24108cd19d))

## [1.5.0](https://github.com/Griffin-Dalby/Sawdust/compare/v1.4.2...v1.5.0) (2026-01-02)


### Features

* **builder:** Added an option to load meta into the service. ([dc58361](https://github.com/Griffin-Dalby/Sawdust/commit/dc58361c5b43a393b5e79166a1d71dfeb4f0e560))
* **builder:** Generics ([7126036](https://github.com/Griffin-Dalby/Sawdust/commit/71260360f6758daa32a007f4b9744ef16e70aead))
* **core.cache:** createTable() now has a new argument "safe" ([769a691](https://github.com/Griffin-Dalby/Sawdust/commit/769a69174b648d43e96bef50e180bf1a8a46be63))
* **core.states:** Working on generics ([d2bd8b9](https://github.com/Griffin-Dalby/Sawdust/commit/d2bd8b9f595ded3854a283a753a559e773f75343))
* **maid:** Smarter rawset cleanup ([54f3063](https://github.com/Griffin-Dalby/Sawdust/commit/54f30637e64a5c18683b22d4cd8fb9f3a422c79a))
* **middleware:** Optional phase lock ([0fe6d6c](https://github.com/Griffin-Dalby/Sawdust/commit/0fe6d6c8e3f19110187fb1ce847e1d8a83aeef4b))
* **networking:** allowed support for UnreliableRemoteEvent ([0e0cd45](https://github.com/Griffin-Dalby/Sawdust/commit/0e0cd45f127ab247a7a41f1f7489c75c75b3b269))
* **networking:** Assertion status return + type addition ([4b4191f](https://github.com/Griffin-Dalby/Sawdust/commit/4b4191f0d4dfb5e5efe0b1bb0fbfbe6507e9476e))
* **networking:** Improved types module, fixed a couple issues, and improved networking forward-exports. ([2c2b0d5](https://github.com/Griffin-Dalby/Sawdust/commit/2c2b0d50842842952ce46ab207bd205f683427e8))
* **networking:** res.assert() ([e32effd](https://github.com/Griffin-Dalby/Sawdust/commit/e32effd75fb4a102e79e3f7d5a2fe75adcdd9525))
* **sawdust:** Generics in Sawdust ([b757a0a](https://github.com/Griffin-Dalby/Sawdust/commit/b757a0a06aedd438289d7d8f13e8b7fef125fcac))
* **sawdust:** Meta ([f95429f](https://github.com/Griffin-Dalby/Sawdust/commit/f95429fa333ac28aff33e8a7fbbb5ce40ed575b9))
* **services:** Promised _resolve & _start ([998db01](https://github.com/Griffin-Dalby/Sawdust/commit/998db01c5a96599dabc5292a488d309a38742963))
* **signal:** Generics ([31c18e6](https://github.com/Griffin-Dalby/Sawdust/commit/31c18e6cf951ddd354bf0cb9645999deb4c8099b))
* **timer:** Cleanup callback option ([3f33600](https://github.com/Griffin-Dalby/Sawdust/commit/3f336002554c909028f5f683e05da4a28e855037))
* **timer:** Discard, structure, and safety. ([90ea2db](https://github.com/Griffin-Dalby/Sawdust/commit/90ea2dbc8aaaa6d7a21eef142dc1fd63851e0e15))
* **timer:** Timer options w/ server-sync, improved documentation, and refactors to clean up structure. ([999ca76](https://github.com/Griffin-Dalby/Sawdust/commit/999ca76a721a2d69f89494f0b82a3e2735a63a90))
* **util.maid:** :add() returns the instance, allowing for more expressive syntax. ([d15c67a](https://github.com/Griffin-Dalby/Sawdust/commit/d15c67a16f66886813566fa45e3bfbf463eb4266))
* **util.maid:** Root table of custom object is now held, and upon :clean() deeply cleaned. Very destructive but there's a flag so... ([03742fd](https://github.com/Griffin-Dalby/Sawdust/commit/03742fd2849b7eeb3b7c90d42a2db5d20200f76e))


### Bug Fixes

* **core.states:** Fixed minor typecheck issue wth state:hook() not accounting for id value. ([ccfc427](https://github.com/Griffin-Dalby/Sawdust/commit/ccfc4276e9fb1d3455b71492c2602a5404ae2df0))
* **core.states:** Messing with generics trying to make them work ([6cd5242](https://github.com/Griffin-Dalby/Sawdust/commit/6cd52424161d0e45bddb37a6635718cf9a07bd60))
* **git-workflow:** Updated to fix Release Please ([556c455](https://github.com/Griffin-Dalby/Sawdust/commit/556c455c33c86b669ecb3288b7ed7b536dab018b))
* **maid:** Improved cleanup logic ([68258c2](https://github.com/Griffin-Dalby/Sawdust/commit/68258c2121e48a85f4dda98fadd5ab1c221f0052))
* **networking:** Proper typecheck ([6822c39](https://github.com/Griffin-Dalby/Sawdust/commit/6822c3990079fef3f3d5dfdd9eb6eb13b553aaa8))
* **services:** Fixed dependencies being returned as promise object, not awaited value. ([ed5cd58](https://github.com/Griffin-Dalby/Sawdust/commit/ed5cd5882399e876442706d7161d9f9ff80dfc00))
* **states:** Fixed generic mismatches in type module ([a50ad36](https://github.com/Griffin-Dalby/Sawdust/commit/a50ad360748ee1dd27ccbbc6501b4bbf0c284654))
* **timer:** Improper use of tick function ([8c4ae5e](https://github.com/Griffin-Dalby/Sawdust/commit/8c4ae5e727f70219048f65ac52a274be08359736))
* **util.maid:** small typo w/ new object decimation cleanup ([e8ed77a](https://github.com/Griffin-Dalby/Sawdust/commit/e8ed77a6ea7a30037cde836d985aa90162451a49))

## Changelog

All notable changes to **Sawdust** will be documented in this file.
This project adheres to [Semantic Versioning](https://semver.org/).

---

> ## [1.1.0] - 2025-07-16
> Most notably, an all new networking system, also a whole truckload of new utilities, 3D animation tools, and promises.
> Both the Networking Rewrite and Promises follow a Node.JS style, with networking resembling Express.
>
> ### Additions
>
>> #### **Networking Protocol** `src\ReplicatedStorage\Sawdust\__impl\networking`
>> - Instead of remote functions, I've created a new protocol specifically for this networking module
>> - This protocol allows simple server-client communication using req and res like express.
>> - It has been designed with efficency in mind, minimizing overhead as much as possible while allowing the same, flexible, secure behavior.
>> - Final note, the invocation actually utilizes the in-house sawdust promises released in this update as well, resolving and rejecting depending on what the other side returns. The server can also invoke multiple clients and get responses from each.
>
>> #### **Networking Middleware & Pipeline** `src\ReplicatedStorage\Sawdust\__impl\networking\middleware`
>> - The middleware & pipeline behavior is very similar to the old, it works the exact same, except it will be tailored towards the new protocol and the data being presented in that format.
>
>> #### **Promises** `src\ReplicatedStorage\Sawdust\__impl\promise`
>> - Simply a promise system modeled after NodeJS.
>> - You can chain together andThen(), catch with catch(), and of course final()
>
>> #### **Animation** `src\ReplicatedStorage\Sawdust\__impl\animation`
>> - I've included the start of CFAnim, a module allowing you to dynamically "plan" rigs and then animate them using CFrames to make procedual animations, however this may become its own module as it doesn't quite fit my vision.
>> - I also plan to create a "scene" module that can create simple environment animations or act as a full-fledged animation suite with full control over scenes all with programming.
>
>> #### **Utilities** `src\ReplicatedStorage\Sawdust\__impl\util\*`
>> - **"Debounce"** allows easy creation of debounces with specified times.
>> - **"EnumMap"** allows the developer to "map" out Enums, converting them into human-readable strings, and back.
>> - **"States"** provides a dynamic interface where you can give objects states, with smart handling.
>> - **"Timer"** can run functions in a wrapped heartbeat where you can start, stop, and resume the internal connection.
>> - **"UUID"** simply provides a more intuitive UUID generator with much more customization.
>
> ### Changes
>
> - `Sawdust.lua` Made exports more human readable 😢
> - `Sawdust.lua` Okay nvm I just redid the layout
>
> ### Fixes
>
> - `__impl\builder` Fixed issues w/ init/injection & pipeline
> - `__internal\__service_manager` Fixed issues w/ runtime
>

---

> ## [1.0.2] - 2025-06-17
> Dependency-injected service implementation with support for runtime injections & dependencies.
>
> ### Additions
>
>> #### **SVCBuilder** `src\ReplicatedStorage\Sawdust\__impl\builder`
>> - Wrapper to build a **SawdustService**
>> - "**Injection**" allows developers to "Inject" code into a phase of service runtime *(e.g. 'init' & 'start')*
>> - "**Dependency**" allows developers to "Depend" their service on another, allowing services to load only after others load.
>> - When a service depends on another, the services the first one depends on will be passed in *init*, and any code injected into *init*.
>
>> #### **SVCManager** `src\ReplicatedStorage\Sawdust\__internal\__service_manager`
>> - Must be called through **Sawdust** main module. `Sawdust.services`
>> - In a setup script, you need to use `services:register(SawdustService)`, getting **SawdustService** from **SVCBuilder**
>> - After, you do `services:resolveAll()` to **initalize** each service.
>> - To **start** the services, follow that with `services:startAll()`.
>
> ### Changes
> 
> `__impl\networking` Added a "once" flag for a connection, disconnecting connection as soon as a event is caught.
> `__impl\networking` Also added a "wait" method, yielding the script until an event is caught.
> `Sawdust.lua` Changed the way implementations get passed through Sawdust main module.
> `README.md` 



> ## [1.0.1] - 2025-06-17
> New content delivery implementation with support for preloading assets, and efficent memory & caching practices.
>
> #### Additions
>
>> ##### **CDN** `src\ReplicatedStorage\Sawdust\__impl\cdn`
>> - Created a dynamic and quite efficient CDN system, utilizing the caching module internally.
>> - Allows you to get "**Providers**" whose main job is to provide assets utilizing AssetIDs.
>> - Provides a "**Preload**" feature, allowing you to preload assets in batches, or singulars
>> - I want to flex how efficent I made it actually, I love how it turned out so much 🙏
>
> #### Changes
> - `__impl\cache` Allowed finding caches within caches, basically allowing you to have objects much like tables.



> ## [1.0.0] - 2025-06-16
> Inital release of Sawdust library with a couple core implementations. 
>
> #### Additions
>
>> ##### **Networking** `src\ReplicatedStorage\Sawdust\__impl\networking`
>> - "**Middleware**" allowing developers to attach events to different points of an event's lifecycle
>> - Very easy to understand interface, splitting events into "channels" that you can easily access and connect.
>> - Event behavior is wrapped smartly, functions and events work the same, but their special behavior is kept in-tact.
>
>> ##### **Signaling** `src\ReplicatedStorage\Sawdust\__impl\signal`
>> - Provides the developer with "Emitters", that you can add events to for very simple, embedded event behavior.
>> - Smart memory handling and cleanup
>
>> ##### **Caching** `src\ReplicatedStorage\Sawdust\__impl\cache`
>> - Splits data into "Caches", from there you can simply get and set data.
>
>> ##### **Maid** `src\ReplicatedStorage\Sawdust\__impl\util\maid`
>> - Apart of the "Util" implementation, the Maid module lets the devloper create a new Maid instance.
>> - Said maid instance can take track of instances, connections, and callback functions.
>> - The developer can "tag" these tracked objects with names, and take action based off of the tags alone.
>> - You can call `:clean(tag: string|nil)` to cleanup all tracked data, or only tagged data.
