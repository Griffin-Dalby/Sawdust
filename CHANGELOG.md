# Changelog

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
