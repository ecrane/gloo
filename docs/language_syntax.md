# Language, Syntax

**Contents**

- Color
- Computed Arguments
- Errors
- Events
- Function Calls
- Gloo System Objects
- Here
- It
- Operators
- Pathname
- What Counts as True

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

These are the common ones, but any color name from the `colorize` gem works too (e.g. `cyan`, `magenta`, or a `light_` variant of any of the above).

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

## Computed Arguments

Some verbs take literal text rather than an object or an expression: a file name, a path, a name. Each of these can instead be an expression in parentheses. Gloo works out the expression and uses its value as the text:

```
load ( $.gloo_tmp '/scratch.gloo' )
load lib ( lib_name )
save my_obj to ( $.gloo_tmp '/my_obj' )
context ( 'app.' section )
exists? object ( type_name )
```

This works for `load` (a file, `ext` or `lib`), `save … to`, `context` and `exists?`. Anything not in parentheses is still taken literally, so `load common/app/*` still loads those files. A computed file name goes through the same lookup as a literal one, so wildcards, the `.gloo` extension and project-relative names work the same way.

The `+` is optional when joining text, so `( $.gloo_tmp '/scratch.gloo' )` and `( $.gloo_tmp + '/scratch.gloo' )` are the same. A `[file]` or `[string]` object holding a path works too: `load ( my.file_obj )`.

If the expression can't be worked out (for example, an object it names doesn't exist), that's reported as an error and the verb doesn't run.

### Computed Object Paths

Where a verb expects an object path, a parenthesized expression works the same way: gloo works it out, and its value is used as the path, exactly as if it had been typed there.

```gloo
create ( 'quotes.' ^.i ) as string
put ^.file into ( 'quotes.' ^.i )
tell ( target ) to run
move ( src ) to ( dst )
```

This works for `tell` and `check` (the object), `put … into`, `create` (the name), `move` (both the object and the new parent), `list`, `run`, `invoke` (the function) and `save` (the object).

Without parentheses you get the object; with them, the path its value holds. If `target` is a string holding `app.jobs.nightly`, `tell target to run` sends `run` to the string itself, while `tell ( target ) to run` runs `app.jobs.nightly`. Think of `( target )` as an inline alias: for one line, it does what an alias holding `target`'s value would, and nothing is stored.

- The fixed part of a path is text, so quote it: `( 'quotes.' ^.i )`. Without the quotes, `( quotes. ^.i )` would read `quotes.` as an object.
- A built path can be relative, and it's resolved the same way as when typed: `( '^.quotes.' ^.i )` starts from the running script's parent, `( '@.' name )` from the context.
- A value that isn't text is turned into text first, so `( i )` with `i` = 3 means the object named `3`.
- A computed path that names nothing is handled exactly as the same typed path would be: `create` creates it, `put` and `tell` report it isn't there, and the message names the worked-out path (`Object 'quotes.3' was not found.`), not the expression.
- A path that works out to blank is an error, `Object path '( p )' is blank.`, and the verb doesn't run.

Parentheses anywhere else keep their meaning. In `tell ( s ) to starts_with? ( 'he' )` the first group is the object and the second is the message's parameters. A group after `create`'s `:` is the value, not the name. `invoke( f )` with no space is an inline function call (see Function Calls); `invoke ( f )`, with a space, is a computed path. `redirect` doesn't take a computed path: a group after it is its `(hard)` option.

#### Computed Paths and Aliases

An alias is a pointer you keep: declared once, saved with the file, used from many places. A computed path is a one-off, built and used on one line. Before computed paths, building a path at runtime meant pointing an alias at it first:

```gloo
put 'quotes.' ^.i into ^.slot*
create ^.slot* as string
put ^.file into ^.slot
```

That still works; `create ( 'quotes.' ^.i ) as string` and `put ^.file into ( 'quotes.' ^.i )` do the same without the alias.

Putting an alias inside the parentheses is new, and it adds a step. Working out an alias follows it to its target and gives the target's value, and that value is then used as the path. With `ln` pointing at `a.s`, and `a.s` holding the text `other.place`:

| Written | Goes into |
|---|---|
| `put x into ln` | `a.s` — the alias forwards to its target |
| `put x into ( ln )` | `other.place` — the target's value, used as a path: a second hop |
| `put x into ( ln* )` | `a.s` — the alias's own value, the path it holds; the same as `put x into ln` |
| `put x into ln*` | the alias itself, which now points somewhere else |

So `( ln )` is only what you want when the alias's target holds a path. To mean "where the alias points", leave the parentheses off, or use `( ln* )`.

For anything else, `run ~>` works out a whole command and runs it: `run ~> 'load ' $.gloo_tmp '/x.gloo'`. Prefer the parentheses where they're available; a command built this way breaks if a path has spaces in it.

See also: Load, Save, Context, Exists.

## Errors and Warnings

Gloo makes a best guess and keeps going when it can, but it never does so silently: every problem is reported, in one of these ways.

- **Syntax error** — the command couldn't be understood: an unknown verb or object type, a required part missing (`put 3 into`), the wrong number of arguments, an unclosed quote or parenthesis, or an operator missing a value (`show 1 +`).
- **Runtime error** — the command was understood but couldn't be done: an object that doesn't exist used as a value or a target (`show no.such.obj`), division by zero, a file that can't be read or written, a position out of range. This includes failures caused by the input or the outside world: JSON that doesn't parse, a URL that's malformed or can't be reached, a wrong encryption key, a template with a mistake in it, a date object whose value isn't a date. These read `Could not {what}: {why}.` — for example `Could not parse the JSON in j: expected object key, got 'bad' at line 1 column 2`. A command that would have set `it` sets it to `false` (see It).
- **Warning** — the command was done, but probably not the way it was meant: a value that isn't really of its type, used as a best guess (`'x' is not an integer; using 0.`), or indentation that doesn't line up. A warning is only logged; it isn't an error.
- **Just a result** — a question whose answer is "no" is not an error at all: `exists?`, `contains?`, `substring?`, and `index_of` (which gives -1) answer in `it`.

Errors and warnings are logged with where they happened in front of the message: the file and line while a file is loading (`app.gloo:12: Unknown type 'strng'; using untyped.`), even when a script started the load; otherwise the script and its line (`app.on_load, line 3: Object 'app.nme' was not found.`). On the console both go to stderr, apart from a script's own output. "Not found" errors always read the same way: `Object 'x' was not found.`, `File 'x' was not found.`, `Folder 'x' was not found.`, `Verb 'x' was not found.`

What happens after an error:

- The line that failed is abandoned, and the script continues with the next line. A `put` whose value couldn't be worked out leaves its target unchanged (and `it` is `false`).
- One error is different: runaway recursion. A script that runs itself with no end — directly, through other scripts, or a function that invokes itself — runs scripts inside each other until there's no room left. Gloo stops it with `Could not run app.again: scripts ran 730 deep, one inside another (runaway recursion?).`, located at the deepest script. Rather than abandon only the deepest line (and let every level above carry on), it abandons the whole run back to the outermost line — the line you typed, or the line of a script an event ran, such as `on_load` — and reports it once. That script then carries on with its next line, as after any error.
- Loading a file keeps going after a syntax error, so every problem in the file is reported at once. An object with an unknown type is created untyped, so anything nested under it still loads where it should. A declaration with no name (`[int] : 3`) is created under a placeholder name, `unnamed_1`, `unnamed_2` and so on. A type missing its closing bracket (`count [int : 3`) is read as if it were closed after the type word.
- The error runs any `on_error` handler (see Events below).

Gloo has a special `error` variable that's not part of the normal object heap. The error will be empty most of the time, but if a command results in an error, this variable will hold the error message until the next command is executed. The error is a string and can be accessed by simply referring to the path-name `error`.

To see the last error:

```
> show error
```

To run a command that generates an error:

```
> put 3 into
Target (into) missing!
```

Then, showing the error:

```
> show error
Target (into) missing!
```

But, as mentioned, the next command will clear out the last error. If you need to keep track of the result of a command, you should put the error into another object.

```
> create err as string
> put 3 into
> put error into err
```

See also: Pathname.

## Events

Scripts can be written to be triggered by events. The current list is as follows, but it is expected that the list of events will grow.

The following events are application and file-level events:

- `on_load` — run when an object loads
- `on_unload` — run when an object receives an unload message
- `on_quit` — event triggered when gloo is quitting
- `on_save` — when an object is saved, this event is triggered
- `on_reload` — event triggered when an object receives message to reload
- `on_error` — event triggered when gloo reports a syntax or runtime error (see Errors and Warnings). Warnings don't trigger it.
- `on_exception` — event triggered when gloo's safety net catches an unanticipated Ruby exception — a bug in gloo itself, since anticipated failures such as division by zero or a missing file are runtime errors (use the `throw` verb to exercise it)

`on_error` and `on_exception` are independent channels — a gloo error fires `on_error` only, an unhandled Ruby exception fires `on_exception` only, and neither triggers the other. In both cases the line that failed is abandoned and execution continues with the next line; a handler is a place to log or react, not a way to retry. After the handler runs, the error is still there for the rest of the command to see (`error`).

Each handler reads its details from a sibling data container (`error_data` / `exception_data`) that the engine populates before running the script; the handler script and its data container can sit at the root of a file or be nested together inside a container. Each child is optional — the engine fills in the ones that are there:

- `message` — the error message
- `backtrace` — the backtrace, when there is one
- `kind` (`error_data` only) — `syntax` if the command couldn't be understood, `runtime` if it couldn't be done
- `location` (`error_data` only) — where it happened: `file:line` while loading, or `script path, line N`

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
  kind [string] :
  location [string] :


#
# Global Exception Handler.
# Same shape as on_error, with a sibling exception_data container.
# 'throw' deliberately raises a Ruby exception to exercise this.
#
on_exception [script] :
  tell audit_exception.write to run

exception_data [can] :
  message [string] :
  backtrace [string] :
```

See also: Load, Reload, Unload, Save, Quit, and the `throw` verb reference.

## Function Calls

The `invoke` verb (shortcut `~>`) calls a function object (`[ƒ]`) as a standalone command, space-separated params:

```gloo
invoke functions.add 3 4
show it
```

`invoke( ... )` and `~>( ... )` are the inline forms of the same thing — usable anywhere an expression is evaluated (`show`, `put ... into`, `if`, `unless`, `eval`, and more), not just as a standalone command:

```gloo
show invoke( functions.add 3 4 )
put ~>( functions.add 3 4 ) into total
show "Total: " + invoke( functions.add 3 4 )
if invoke( checks.is_ready ) then show 'ready'
```

`invoke(...)` and `~>(...)` are exactly equivalent — just the full keyword and its shortcut, same as the standalone verb. Params stay space-separated inside the parens; each one is evaluated as a single token (a literal or object reference), same as the standalone verb — not a multi-token sub-expression, so `invoke( f 3+4 )` won't parse `3+4` as one param.

The parens must immediately follow the keyword with no space (`invoke(`, not `invoke (`) — that's what tells gloo it's a function call rather than `show`'s unrelated trailing `(color)` syntax, which always has a space before the paren.

See also: Color.

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
gloo.gloo_tmp         # Get the gloo tmp directory, for temporary files

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
gloo.platform_wsl?      # Is the platform WSL (Windows Subsystem for Linux)?
```

See also: Pathname. The file-system subset of these objects is also referenced in Application > The Gloo Home Directory.

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

## It

`it` is a special virtual object. `it` contains the value of the last expression or command run. Which commands change it follows a simple rule:

- **A question** (`check x for exists?`, `contains?`, `starts_with?`, …) puts its answer in `it`.
- **A command or message that works out a value** puts that value in `it` (`eval`, `put`, `show 3 + 4`) — even if it also stores it somewhere, in the object's own value (`trim`, `sub`, `format_for_html`) or in a child (`run` on an `erb`, `http_get` or `system` object also sets its `result`).
- **A message that puts its result into a destination you name** puts its status in `it`: `true` when it worked, `false` when it didn't. With no destination, the result itself goes in `it`. So `tell f to read ( text )` puts the file's contents in `text` and `true` in `it`, while `tell f to read` puts the contents in `it`. The same goes for json `parse ( dst )` and string `split_list ( delim dst )`.
- **A pure action** — `list`, a bare `show`, deleting, opening a file — leaves `it` alone, so a value in `it` survives it. Running a script or a loop doesn't set `it` either, though the commands inside it do.
- **When something goes wrong** in a question or a command that would set `it`, the problem is reported and `it` is `false`. The same goes for a message that never gets to run — the object doesn't exist, or doesn't take that message — including `run` itself: `it` is `false`, so no stale value from an earlier line is left behind.

Each object's messages say what `it` will have (see Objects, or `help` in the app).

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

`it` is read-only. It is a result value, not an object: it has no type, and the next command that produces a result replaces it. You can read it anywhere a value is allowed (`eval it = 7`, `put it into x`, `if it then …`), but nothing can target it. Sending it a message (`check it for …`, `tell it to …`), putting a value into it, or using it with `run`, `move`, `list`, `create`, `save` or `redirect` is an error, and `it` keeps its value.

To send a message to the value in `it`, put it into an object first. Putting it into an object of a given type also says what kind of value it is:

```gloo
example [can] :
  path [string] :
  list [can] :
    a : one
    b : two
  on_load [script] :
    tell ^.list to random_child_path
    put it into ^.path
    check ^.path for starts_with? ( 'example.list.' )
    show it
```

See also: Pathname, What Counts as True.

## Operators

Operators have their own dedicated page — see the Operators page.

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

## What Counts as True

A condition — the value after `if` or `unless`, or the result of an `until` loop's `done` script — is true or false by one rule, the same one a `[bool]` uses when a value is put into it:

| Value | Counts as |
|---|---|
| `true` | true |
| `false` | false |
| a number other than `0` (`5`, `-1`, `2.5`) | true |
| `0` | false |
| the text `true` or `t` (any case) | true |
| the text `false` or `f` (any case) | false |
| blank, or no value | false |
| any other text | false, with a warning |

Any other text is almost always a mistake — a value used as if it were a question — so it's false, and gloo warns: `'abc' is not true or false; using false.` To ask whether something has a value, ask it: `check name for blank?`, then `unless it then …`.

`unless` is the exact opposite of `if`: `unless x do …` runs exactly when `if x then …` wouldn't. A condition that can't be worked out (it names an object that doesn't exist, say) is an error, and the line is abandoned: neither the command nor `else` runs.

```gloo
truth [can] :
  name [string] :
  on_load [script] :
    if ^.name then show 'has a name' else show 'no name'
    put 'Ann' into ^.name
    check ^.name for blank?
    unless it then show 'has a name now'
```

This shows `no name`, then `has a name now`.

See also: It, If, Unless, Until, Boolean.
