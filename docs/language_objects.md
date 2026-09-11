# Language, Objects

**Contents**

- Object Naming
- Nested Container Shorthand
- Keywords
- Literals
- Value Conversion

## Object Naming

Object names are single words (no spaces) and conform to the following:

- Spaces in names are not allowed.
- Names should be unique within their context.
    - Note that there is no technical restriction. Multiple objects with the same name in the same context can exist, but there's no way to reference objects past the first one with the given name.
- Names can be capitalized or lower case.
    - But names with different cases are not treated as unique.
- Names can contain numbers and special characters.

```gloo
#
# Example of object naming.
#
# NOTE that the second 'a' and the 'A' objects are not reachable.
# 'naming.a' will always reach the 'First A' string.
#
naming [container] :
  on_load [script] :
    show naming.msg!$%
    show naming.a
    show naming.1
  msg!$% [string] : Naming stuff
  a [string] : First A
  a [string] : Second A is not reachable
  A [string] : Capital A is not reachable
  1 [string] : One
```

See also: Pathname.

## Nested Container Shorthand

A declaration whose name is a dotted path creates a container for each
prefix segment, then declares the real object under the last one. These
two files are equivalent:

```gloo
page [container] :
  core [container] :
    users [container] :
      list [container] :
        title [string] : Users
```

```gloo
page.core.users.list [container] :
  title [string] : Users
```

- Each prefix segment (`page`, `core`, `users`) becomes a container,
  unless a sibling object of that name already exists — in which case
  that object is used as-is.
- The shorthand works at any indent level; the prefix is resolved
  relative to the current parent.
- Several shorthand lines can share a prefix — `page.core.users [...]`
  and `page.core.settings [...]` both reuse the same `page` and
  `page.core` containers.
- Indented lines below a shorthand declaration are children of the last
  segment (`list` above), not of any prefix container.

## Documenting an Object

A contiguous run of whole-line comments immediately above a declaration,
at the same indent and with no blank line in between, is that object's
**doc** — read it back at run time with `tell {obj} to doc` or
`check {obj} for doc` (the cleaned text lands in `it`, like any other
value-returning message):

```gloo
#
# The user's display name. Empty until they set it in preferences.
#
name [string] :
```

```gloo
> check name for doc
> show it
The user's display name. Empty until they set it in preferences.
```

Each line's own leading whitespace and `#` marker (plus one space after
it, if there is one) are stripped; the result is dedented to its
shallowest line and blank leading/trailing lines are dropped. An object
with no leading comment — including anything created at run time rather
than loaded from a file — has a blank doc (`''`).

A comment separated from the declaration by a blank line, or at a
different indent, is not associated with it — it's kept as its own
floating comment in the file instead. When a name is declared in more
than one loaded file, the first non-empty doc wins (same rule as the
first value).

`list` can show every documented object in a listed tree: turn on the
`list_docs` setting (off by default) — see `list` and `settings` in the
in-app help.

## Keywords

Gloo doesn't reserve words the way many languages do. A verb keyword like `put` or an object type name like `string` can also be used as an object name — there's no parser conflict, because verbs are only looked up as the first word of a statement, and object type names are only looked up where a type is expected (inside the `[ ]` on a declaration). Everywhere else, the word is just a pathname segment (see Object Naming, above).

That said, gloo's own vocabulary — words that already mean something built-in — comes from two sources:

- Verb keywords, and their shortcuts (see Verbs) — `put`, `show`, `run`, `tell`, and the rest.
- Object type names, and their shortcuts (see Objects) — `string`, `container`, `integer`, and the rest.

Both lists grow as core libraries and extensions load — `load lib {name}` and `load ext {name}` can add new verbs and object types at runtime, so the full set isn't fixed. Use the in-app help (see Application, Help) for the live list of whatever's currently loaded: enter `help` (or `?`), then `verbs` or `objects`.

See also: Verbs, Objects.

## Literals

Literals are values inline in a script command.

The following rules apply to literal values:

- Strings
    - Can be delimited by single or double quotes. (`"` or `'`)
    - A quote of the other kind inside needs no escaping —
      `'{"x":1}'` is the string `{"x":1}`, which is the usual way to
      write a JSON literal.
    - A quote of the same kind inside is escaped with a backslash —
      `"say \"hi\""` is the string `say "hi"`.
- Numbers
    - Integer and decimal numbers need no delimiters.
    - To refer to a decimal with no fractional value, include `.0` to indicate a decimal value.
- Booleans
    - Can be `TRUE` or `FALSE`
    - Note that the text is case insensitive.

```gloo
#
# Examples of literal values.
#

  literal [can] :

    s [string] :
    i [integer] :
    d [decimal] :
    b [boolean] :

    #
    # Use Literals to assign values
    #
    on_load [script] :

      # String literals
      put 'Hello world.' into ^.s
      show ^.s
      put "You're Awesome!" into ^.s
      show ^.s
      put '{"lang":"gloo"}' into ^.s
      show ^.s

      # Number literals
      put 1 into ^.i
      show ^.i
      put 3.12 into ^.d
      show ^.d

      # Boolean literals
      # Boolean literals are case insensitive
      put TRUE into ^.b
      show ^.b
      put false into ^.b
      show ^.b
```

See also: Put, Show, String, Boolean, Integer, Decimal, Value Conversion.

## Value Conversion

When putting an object or literal value into another object, gloo will attempt to convert the value to the target type.

Here are some of the value conversions that gloo will attempt:

- string to integer
    - additional text is discarded
    - `put '1 one' into x` => 1
- integer to string
    - simple to-string conversion
- string to decimal
    - additional text is discarded
    - `put '3.25 and more…' into x` => 3.25
- decimal to string
    - simple to-string conversion
- decimal to integer
    - drops everything after the decimal point
    - `put 1.23 into x` => 1
- integer to decimal
    - decimal with integer value
    - `put 1 into d` => 1.0
- string to boolean
    - if the string is (trimmed, case-insensitive) 'true' or 't' then the boolean is true; 'false' or 'f' is false; anything else is false
    - `put 'true' into bool` => true
- boolean to string
    - simple to-string conversion: 'true' or 'false'
- integer to boolean
    - 0 => false, otherwise true
    - `put 1 into bool` => true
- boolean to integer
    - true => 1, false => 0
- string to date
    - uses Chronic lib to convert text to date
    - `put '7/11' into dt` => 2024.07.11
- date to string
    - convert date to string in default format
- string to time
    - uses Chronic lib to convert text to time
    - `put 'now' into time` => 01:24:55 pm
- time to string
    - convert time to string in default format
- string to datetime
    - uses Chronic lib to convert text to datetime
    - `put 'now' into dt` => 2024.07.11 01:21:39 pm
- datetime to string
    - convert datetime to string in default format

```gloo
#
# Examples of value conversions.
#

  convert [can] :

    i [integer] : 1
    d [decimal] : 7.75
    s [string] : "hello"
    b [boolean] : true
    date [date] : "2024-07-11"
    time [time] : "13:45:00"
    dt [datetime] : "2024-07-11 13:45:00"

    #
    # Do some value conversions.
    #
    on_load [script] :

      # String to integer
      put '3 third time' into ^.i
      show ^.i

      # String to decimal
      put '3.12 more' into ^.d
      show ^.d

      # String to date
      put 'now' into ^.dt
      show ^.dt
```

See also: Literals.
