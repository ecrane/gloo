# Language, Objects

### Object Naming

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

---

### Keywords

_TBD — not yet written._

---

### Literals

Literals are values inline in a script command.

The following rules apply to literal values:

- Strings
    - Can be delimited by single or double quotes. (`"` or `'`)
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

---

### Value Conversion

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
    - if the string is ~ 'true' then the boolean is true, otherwise false
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
