# Language, Syntax

**Contents**

- Color
- Errors
- Events
- Gloo System Objects
- Here
- It
- Operators
- Pathname

## Color

The following colors can be used by the `show` verb to display colored text:

```gloo
red
blue
green
white
black
yellow
```

The color names are considered as virtual objects but may also be referenced in variables. See the example below.

```gloo
#
# Show multiple messages in color
#
colors [can] :
  var [string] : red
  on_load [script] :
    show "red" (colors.var)
    show "blue" (blue)
    show "green" (green)
```

See also: Show.

---

## Errors

Gloo has a special `error` variable that's not part of the normal object heap. The error will be empty most of the time, but if a command results in an error, this variable will hold the error message until the next command is executed. The error is a string and can be accessed by simply referring to the path-name `error`.

To see the last error:

```
> show error
```

To run a command that generates an error:

```
> put 3 into
'put' must include 'into' target
```

Then, showing the error:

```
> show error
'put' must include 'into' target
```

But, as mentioned, the next command will clear out the last error. If you need to keep track of the result of a command, you should put the error into another object.

```
> create err as string
> put 3 into
> put error into err
```

See also: Pathname.

---

## Events

Scripts can be written to be triggered by events. The current list is as follows, but it is expected that the list of events will grow.

The following events are application and file-level events:

- `on_load` — run when an object loads
- `on_unload` — run when an object receives an unload message
- `on_quit` — event triggered when gloo is quitting
- `on_save` — when an object is saved, this event is triggered
- `on_reload` — event triggered when an object receives message to reload
- `on_error` — event triggered when there is an error in the application

Some objects also have events that are triggered as part of their lifecycle. Here are some examples:

- function — `on_invoke`, `after_invoke`
- server — `on_start`, `on_stop`
- page — `on_prerender`, `on_render`, `after_render`
- partial — `on_render`, `after_render`

```gloo
#
# Show a message when a file is loaded:
#
start [container] :
    on_load [script] : show "Welcome back!" (white)


#
# Show a message when a file unloaded:
#
done [container] :
    on_unload [script] : show "See ya soon!" (white)


#
# Show a message when gloo is quitting:
#
quitting [container] :
    on_quit [script] : show "Gloo is done for now." (white)


#
# Show a message when an object is going to be saved:
#
on_save [script] :
    show 'This object file is going to saved now.' (yellow)


#
# Show a message when an object is giong to be re-loaded:
#
on_reload [script] :
    show "The object is reloading now."

#
# Global Error Handler.
# Include the data container for the error data.
# The data is populated by the application on error event.
#
on_error [script] :
  tell audit_error.write to run

error_data [can] :
  message [string] :
  backtrace [string] :
```

See also: Load, Reload, Unload, Save, Quit.

---

## Gloo System Objects

The gloo system objects are virtual objects. That is, they can be accessed like other objects, but the values are set by the system. The values cannot be updated. The other difference is that the virtual objects do not show up in the object heap.

The gloo objects can be accessed through the `gloo` root level virtual object designation. There is also a shortcut for the virtual object path: `$`. For example, to see the current user:

```
> show gloo.user
```

Or:

```
> show $.user
```

Some objects include an `_` to separate words. As an alternative, a `.` can be used instead. The following commands are treated as identical:

```
> show gloo.working_dir
> show gloo.working.dir
> show $.working_dir
> show $.working.dir
```

```
APP
gloo.app             # Path of the running app. (Same as gloo.gloo_projects)

IDENTITY
gloo.hostname         # Get the system hostname.
gloo.user             # Get the logged in User.

SPECIAL CHARS
gloo.line             # A carriage return (line feed) character.

FILE SYSTEM
gloo.user_home        # Get the user's home directory.
gloo.working_dir      # Get the working directory.
gloo.gloo_home        # Get the gloo home directory
gloo.gloo_config      # Get the gloo configuration directory
gloo.gloo_projects    # Get the gloo projects directory
gloo.gloo_log         # Get the gloo logging directory

SCREEN
gloo.screen_lines     # Get the number of lines on screen.
gloo.screen_cols      # Get the number of columns on screen.

PLATFORM
gloo.platform_cpu       # Get the platform CPU
gloo.platform_os        # Get the platform Operating System
gloo.platform_version   # Get the platform version
gloo.platform_windows?  # Is the platform Windows?
gloo.platform_unix?     # Is the platform Unix?
gloo.platform_linux?    # Is the platform Linux?
gloo.platform_mac?      # Is the platform Mac?
```

See also: Pathname. The file-system subset of these objects is also referenced in Application > The Gloo Home Directory.

---

## Here

Gloo scripts can use relative referencing to access objects without specifying the full path. This relative referencing is referred to as the "here" operator, which is a single caret (`^`) character.

Using two carets together (`^^`) means to go up a level — that is, go to the parent container to find the object. Three carets, `^^^`, says to go up yet another level in the object hierarchy.

In the following script, the here reference is used several times:

```gloo
#
# Use here reference.
#
here [can] :
  s [str] : local string
  on_load [script] : show ^.s
  a [can] :
    s [str] : A string
    b [can] :
      s [str] : B string
      on_load [script] :
        show ^.s
        show ^^.s
```

A single use of `^` means: refer to an object at the same level as the running script. It tells the interpreter to "look here" for the object.

Use of two `^^` here references means to go up a level, and so forth.

See also: Pathname.

---

## It

`it` is a special virtual object. `it` contains the value of the last expression or command run. Not all commands result in a change to the value of `it`.

Get the value of an expression and store it somewhere for later use:

```gloo
#
# Example of usage of 'it'.
#
example [can] :
  result [int] :
  on_load [script] :
    show 3 + 4
    put it into ^.result
    show ^.result
```

Running this script will show `7` twice. The first time will be the result of the addition. The second time will be showing the result object.

See also: Pathname.

---

## Operators

Operators have their own dedicated page — see the Operators page.

---

## Pathname

All gloo object data and scripts are stored in a heap of objects, or just "the heap." The heap is hierarchical, with some objects having children objects. To reference an object, we use a "pathname." The pathname starts with the root level object, then has a period, `.`, then the child object name, and so forth. `a.b.c` refers to the `c` object in the `b` container, which is in the `a` container.

### Root & Context

The word "root" is not needed when referring to objects. In some special cases, "root" can be used to point to the first level of the object heap. One such use would be with the "context" verb.

The pathname will start from the root container. When context has been set, the pathname can start from the context container by use of the `@.` prefix. For example:

```gloo
context [container] :
  sub [container] :
    msg [string] : Hello Gloo World!
    on_load [script] :
        @ context.sub
        show @.msg
        @ root
```

Full pathnames can be used when context has been set.

### Exceptional Cases

The following are also exceptional pathname cases:

- Here
- It
- Errors
- Gloo System Objects

Here is an example of objects and a pathname reference to an object within the hierarchy:

```gloo
#
# Hierarchical containers.
#
a [can] :
  b [can] :
    c [string] : Hello World
on_load [script] : show a.b.c
```

See also: Context, Object Naming.
