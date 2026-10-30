# Language, Scripting

**Contents**

- Gloo Script Files
- Comments
- Gloo Constants
- Line Continuation

## Gloo Script Files

Gloo scripts are stored in regular text files with the `.gloo` extension. A file is UTF-8, whatever the locale gloo runs in (cron and launchd, for example, give a process a plain ASCII locale). A line with bytes that aren't UTF-8 still loads, with a warning: those bytes read as `�` (U+FFFD), and the file keeps them, so saving it doesn't change them.

Indentation is what puts an object under another: one level deeper is a tab or two spaces. They can be mixed, from line to line or on one line (a tab and two spaces is two levels).

An object is declared as `name [type] : value`. Spaces just inside the brackets don't matter: `[ int ]` and `[int ]` are `[int]`.

Conventions:

- Script files are small and composable.
- Each file contains a single root level object.
    - There is no system requirement that a file contains only a single object. There can be more than one.
    - The single-root-object convention means that object hierarchy can better align with files in folders.
- The root level object has the same name as the file.

```gloo
#
# Example of gloo script file.
#
hello [can] :
  on_load [script] : show 'hello world'
```

## Comments

A line whose first non-blank character is `#` is a comment. Whole-line comments
can appear anywhere — between objects, inside a container, or inside a script
body — and are ignored when the file runs.

```gloo
#
# A whole-line comment.
#
demo [can] :
  # a comment inside the container
  msg [string] : hello
  on_load [script] :
    # a comment inside the script body
    show demo.msg
```

A statement line may also end with an inline `# ...` comment. It is stripped
before the statement runs, so it has no effect on execution:

```gloo
on_load [script] :
  show 3 + 4        # prints 7
  check demo.msg for blank?
  show it           # prints false
```

Two things are *not* treated as inline comments, and are left alone:

- a `#` inside a quoted string — `show 'a # b'`
- a `#` with no space before it — a URL fragment such as
  `http://example.com/page#section`

An inline comment on an object declaration is also left alone — everything after
the `:` is the object's value, so `note [string] : see item # 5` stores the
string `see item # 5`.

---

## Gloo Constants

There is no gloo language construct for constants. They are simply objects. But by convention, constants are named in all caps. They might be in a container or at the root object level.

```gloo
#
# Example of a constant in gloo.
#
constants [can] :

  MSG [string] : Hello World!

  on_load [script] :
    show ^.MSG
```

## Line Continuation

In gloo scripting, a line continuation is done by ending a line with a backslash (`\`). Logical lines can be split across multiple physical lines of text in scripts. A line break is otherwise an indication of a new statement. Inside a `BEGIN` … `END` block a backslash is just a character: the block's lines are its value, exactly as written.

```gloo
#
# Example of a continuation character in gloo scripts.
#

continuation [can] :

  one [string] : Hello
  two [string] : World!

  on_load [script] :
    show continuation.one and \
      ' ' and continuation.two
```
