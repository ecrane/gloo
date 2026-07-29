# Objects

Everything in gloo is an object. Strings, numbers, containers, scripts, functions, dates — even the folder-like structures that hold your code — are all objects, and they're all accessed and manipulated the same way: by sending them messages.

Gloo ships with a large set of built-in object types, and core libraries and extensions can add more. This page doesn't try to cover them all — it walks through three common ones to get a feel for how objects work. For the complete list of object types, and every message each one supports, use the in-app help: enter `help` (or `?`), then `objects` to list them all, or `object {name}` for detail on one (see Application, Help).

### String

A string holds text. Beyond just storing a value, a string object responds to messages that transform or inspect it:

```gloo
s [can] :
  msg [string] : Hello World!
  on_load [script] :
    show s.msg
    tell s.msg to up
    show s.msg
    tell s.msg to size
    show it
```

Sending `up` to the string converts it to uppercase, in place. Sending `size` puts the character count into `it`. There are messages for lowercasing, counting words and lines, checking prefixes/suffixes, encoding, and generating random strings (UUIDs, hex, alphanumeric) — see the in-app help for the full list.

### Container

A container holds other objects — it's the closest thing gloo has to a folder, a hash, or a struct. Any object nested inside a container is reachable through a dotted pathname:

```gloo
can [can] :
  data [can] :
    1 : one
    2 : two
    3 : three
  on_load [script] :
    tell can.data to count
    show it
```

`can.data` is itself a container holding three children; `count` puts the number of children into `it`. Because containers can nest arbitrarily, this is how gloo builds up everything from simple config blocks to entire applications.

### Integer

An integer holds a numeric value and responds to a handful of convenience messages:

```gloo
#
# Integer object.
#
i [can] :
  x [integer] : 0
  on_load [script] :
    show i.x
    tell i.x to inc
    show i.x
    put i.x * 10 into i.x
    show i.x

    # Show a random number
    tell ^.x to randomize
    show 'Random number (up to 100 by default): ' + ^.x

    tell ^.x to randomize(6)
    tell ^.x to inc
    show '6-sided dice: ' + ^.x
```

`inc`/`dec` step the value by one; `randomize` sets it to a random number in a range (0 by default, or up to a given maximum — handy for things like rolling a die).

---

These three barely scratch the surface — decimals, booleans, dates, files, functions, and many more object types are all documented in-app. Enter `help` (or `?`), then `objects` to browse them.
