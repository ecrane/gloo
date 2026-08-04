# Getting Started with Gloo

**Contents**

- Prerequisites
- Installation
- Configuration
- Running Gloo
- Hello World
- History
- Concepts
- Source Code

## Prerequisites

- Ruby

Gloo requires Ruby to run. Nothing else is required for the core interpreter.

If you don't have Ruby installed, you can download it from here: http://www.ruby-lang.org/en/downloads/

MySQL and Postgres are only needed if you plan to use the `gloo-mysql` or `gloo-pg` core library gems to connect to those databases from a gloo script — see Plugins. Install them only if and when you load one of those libraries.

## Installation

Gloo is distributed as a Ruby gem (https://rubygems.org/gems/gloo). Once you have Ruby installed, you can install Gloo by running the following command:

```shell
> gem install gloo
```

## Configuration

See Application Configuration for details on how to configure Gloo.

## Running Gloo

To start Gloo, run the following command:

```shell
> gloo
```

This will start the Gloo application. This is just enough to get going — for the full set of global options and the two ways to point gloo at a file (by path or by project), see Application, Running Gloo.

## Hello World

Once Gloo is running you can interact with the gloo interpreter. Type the following command to see the "Hello World" message:

```gloo
> show "Hello World"
```

---

## History

### CLI, On Ruby

Gloo is a scripting language and a CLI runtime engine. It was built primarily to run on the Mac and has hooks into several Mac technologies. It runs, at least nominally, on Windows and Linux as well.

Gloo was built in Ruby as a gem. More than that, it has hooks into ruby, can run ruby code, and shares a lot the way ruby works.

### The Name "Gloo" and a Bit of History

Like glue, it is meant to hold things together.

Gloo follows in a series of languages created by it's author. The first was called 'EDT' which stood for Eric's Data Tools. That first set of tools was followed shortly by 'Sqlman' built in the late 90s. Sqlman evolved into a more generalized tool called "AppBuilder". Those three applications were built in Prograph CPX and ran on pre-OS X Macs.

ObjectWise came along as a cross-platform version of AppBuilder. ObjectWise was built in Java on a Sun workstation, and targeted Solaris, Mac OS X, and Windows. It was built around the turn of the millenium. But with job changes, the project went cold for a while and was revived under the name 'Obliner' around 2010. Obliner never gained much traction and never had any substantial use.

Then in late 2018, the project with many names took on a new form as a ruby gem. It was intially called 'object-script' but that was soon changed to 'gloo'. Gloo remains under active development. It has one fanatical user, it's author, but that user makes daily use of it in his work, for personal use, and for fun.

### Why Another Language?

Why another scripting language? Why not just use ruby? Everything in gloo could be done in ruby or any number of other programming or scripting languages. Well, why not? Why should a developer NOT build a programming language as a way to learn and tinker? Why not have a bespoke tool that does just what one wants and that one can change as one pleases? Building a language is an act of invention and creativity. It is an act of rebellion against the machine of best practice and uniformity that corporate jobs often end up being. It is entirely consistent with being a software developer. And why not build a language for the sheer joy of inventing?

### Ideas Behind It

The following technologies influenced the thinking behind gloo and its predecessors:

- HyperCard
- Userland Frontier
- Prograph
- Newton OS
- Ruby and Rails

But each of those could be an essay in and of themselves. Maybe some day they will be.

---

## Concepts

### Outline Based Language

One of the key ideas of gloo is that code and data is organized in an outline. All data and code is intermixed in the same hierarchy. And data in this case represents what in other languages are variables as well as in memory data structures and data storage. Data and code all in the same space. It is all accessed the same way, with a path through the outline. And variables and data can be inspected just like code. This can be done at time of coding as well as at runtime.

### Composition

Another key idea is that code is composed of smaller pieces. The best way to think of gloo is a collection of parts that are assembled together to make something useful.

### Convention

Like Rails, gloo prefers convention over configuration. That is to say that it attempts to make configuration unnecessary unless the user wishes to diverge from the convention. It does not require the programmer to tell it what it can figure out on its own.

### Objects & Messages

In gloo, everything is an object. The object types are built into the language. (There is a plan to add support for user defined object types.)

Objects can have simple values and can also contain other objects.

Interaction with objects is done by sending messages to them.

---

## Source Code

Gloo source code is in GitHub (https://github.com/ecrane/gloo), although the repository is currently private. It might be made public in the future if there is interest or need.
