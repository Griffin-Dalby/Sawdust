---
sidebar_position: 1
---

# Sawdust Quick Start

Hello! Thank you so much for checking out Sawdust, I really hope it can provide you with a refreshing development experience as much as it has for me!

## Getting Started

Get started by **including Sawdust in your project**!
You can do this one of two ways, depending on your scenario:

1. [Wally](https://wally.run/) + [Rojo](https://rojo.space/)
2. Straight to roblox

### Wally Dependency

*Note: Sawdust adheres to [Semantic Versioning](https://semver.org/)*

If you're using wally, simply add this to your `wally.toml`:

```toml
sawdust = "griffin-dalby/sawdust@1.3.0"
```

Than you can easily access sawdust through **ReplicatedStorage.Sawdust**.

### GitHub Release

*Note: This could be slightly outdated, however I will do my best to ensure it is up to date.*

Alternatively, you can download the `.rbxm` from the [GitHub release page](https://github.com/Griffin-Dalby/Sawdust/releases), and import it into your project's `ReplicatedStorage`.

### Compile w/ Rojo | **!! Potentially Unstable !!**

*Note: You must have the Rojo Studio Plugin!*

If you'd want the most current features for Sawdust, you can clone the Github repo, and serve Sawdust, like so:

```bash
git clone https://github.com/Griffin-Dalby/Sawdust.git
cd Sawdust
rojo serve
```

Then connect in studio, and sawdust will appear in your `ReplicatedStorage`.

## What is Sawdust?

**Sawdust** is a collection of implementations (modules) I've built into an ecosystem, with many impressive, efficient, and smart abstractions, you can give LuaU the expressive syntax developers deserve.

A lot of the implementations I've wrote are reminiscent of Node.JS, with my custom networking layer resembling Express, or promise chaining directly inspired by async Node functions.

In the side bar, you'll find `Implementation Tutorials`, and `Documentation`. If you want a guided experience walking through Sawdust, look through the Tutorials; but if you want to dive straight into the technical aspects opt for Documentation.
