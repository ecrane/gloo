# Objects

Everything in gloo is an object. Strings, numbers, containers, scripts, functions, dates — even the folder-like structures that hold your code — are all objects, and they're all accessed and manipulated the same way: by sending them messages.

Gloo ships with a large set of built-in object types, and core libraries and extensions can add more. This page doesn't try to cover them all — it walks through three common ones to get a feel for how objects work. For the complete list of object types, and every message each one supports, use the in-app help: enter `help` (or `?`), then `objects` to list them all, or `object {name}` for detail on one (see Application, Help).

An object's **type declares which messages it can receive** — `up` and `trim` for a `string`, `inc` for an `integer`, `run` for a `script`. An object doesn't have to have a type: with none it is `untyped` (short `any`), declared with a bare colon (`slot :`), with `[any]`, or by `create` with no `as`. An untyped object still takes the messages every object understands (`blank?`, `contains?`, `responds_to?`, `doc`, `reload`, `unload`) — just not the type-specific ones. Untyped is the right choice when you only need to hold, compare, or show a value: a generic result slot, a config value passed straight through, or a field whose kind of value changes over its life.

**Contents**

- String
- Container
- Integer

## String

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

Sending `up` to the string converts it to uppercase, in place. Sending `size` puts the character count into `it`. There are messages for lowercasing, counting words and lines, checking prefixes/suffixes, finding where a substring occurs (`index_of`), encoding, and generating random strings (UUIDs, hex, alphanumeric) — see the in-app help for the full list.

For yes/no messages that inspect state (`blank?`, `starts_with?`, `ends_with?`), the `check` verb reads better than `tell` — `check s.msg for starts_with? ("Hello")` — but it does the same thing (see Verbs, Tell).

## Container

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

### Getting children by position

A container keeps its children in the order they were added, so you can also reach them by position. Positions are 0-based: after `split_list`, index 0 is the child named `1`.

- `child_value_at (index)` — the value of the child at that position.
- `child_path_at (index)` — the child's path from root. This works for any child, including a container.
- `random_child_value` — the value of a randomly chosen child.
- `random_child_path` — the path of a randomly chosen child.

Each puts its result into `it`. The `_value` messages are for simple children; a container child has no value of its own, so asking for one is an error. Use the path instead, and put it into an alias to reach the child's fields:

```gloo
books [can] :
  list [can] :
    a [can] :
      title [string] : Walden
    b [can] :
      title [string] : Emma
  ptr [alias] :
  on_load [script] :
    tell books.list to random_child_path
    put it into books.ptr*
    show books.ptr.title
```

An index that is out of range (including a negative one) or isn't a number, or an empty container for the `random_` messages, is an error, and `it` is `false`.

The `random_` messages pick with replacement, so two calls can give the same child. For distinct picks, pick a random index with an integer's `randomize` message, keep the indexes already used as children of another container, and check it with `child_exists` before using `child_path_at`.

### Building a numbered list

To add children one at a time — say, while walking a folder — create each one through an alias. Point the alias at the next numbered path, then create the object there, and put its value in:

```gloo
names [can] :
  words [string] : red green blue
  list [can] :
  next [int] : 0
  slot [alias] :

  add_each [each] :
    word [string] :
    in [alias] : names.words
    do [script] :
      tell names.list to count
      put it + 1 into names.next
      put 'names.list.' + names.next into names.slot*
      create names.slot* as string
      put ^.word into names.slot

  on_load [script] :
    tell names.add_each to run
    tell names.list to show_key_value_table
```

The children are named `1`, `2`, `3`, the same way `split_list` names them, so `child_value_at ( 0 )` is the child named `1`. The `*` after the alias refers to the alias itself rather than what it points to (see `alias` in the in-app help), so `put … into names.slot*` changes where it points and `create names.slot*` creates the object there.

## Integer

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

These three barely scratch the surface — decimals, booleans, dates, files, functions, and many more object types are all documented in-app. Enter `help` (or `?`), then `objects` to browse them. (This page itself is also viewable in-app: `help> doc objects`.)
