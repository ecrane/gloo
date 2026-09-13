# Verbs

Verbs are the commands that make up a gloo script — `put`, `show`, `run`, `tell`, and 25 others. Every statement in gloo starts with a verb.

Verbs aren't just for scripts, though. They're also the interactive language of the gloo application itself: run `gloo` in CLI mode (see Application, Running Gloo) and you can type these same verbs directly at the prompt, one at a time, in a REPL.

**Contents**

- Run
- Tell
- Put
- Load & Save

This page walks through the most commonly used verbs to get a feel for how they work together. For the complete list of verbs, their full syntax, and every error they can raise, use the in-app help: enter `help` (or `?`), then `verbs` to list them all, or `verb {name}` for detail on one (see Application, Help).

## Run

`run` runs a script or other runnable object — the same as sending it a `run` message.

```gloo
run {path.to.object}
```

```gloo
> run my.script

> create s as script : "show 3 + 4"
> run s
```

## Tell

`tell` sends a message to an object, asking it to do something. Where `run` executes a runnable object, `tell` is the general-purpose way to invoke any message an object supports (`up`, `count`, `inc`, `randomize` — see Objects).

```gloo
tell {path.to.object} to {message}
```

```gloo
> tell an.obj to unload
> tell the.script to run
> tell my.str to up
> tell the.container to count
```

`check` is the same verb under another name — it sends a message exactly the way `tell` does. The two spellings exist so code reads like natural communication: use `tell` to trigger an action (`up`, `run`, `unload`), and `check` to investigate state with a yes/no question (`blank?`, `contains?`, `starts_with?`). The answer to a `check` lands in `it`, so it pairs naturally with `if` / `unless`.

```gloo
> tell my.str to up
> check my.str for starts_with? ("HELLO")
> if it then show 'it does'
```

`doc` is one such message every object responds to: it returns the comment block declared immediately above it in its source file, cleaned up (see Language, Objects — Documenting an Object).

```gloo
> tell my.obj to doc
> show it
```

## Put

`put` evaluates an expression and stores the result in an object.

```gloo
put {expression} into {dst.path}
```

```gloo
> put 'one' into str
> put 123 into x
> put 3 + 5 into x
> put TRUE into flag
```

`it` also picks up the result of the evaluation, same as with other verbs — see It.

## Load & Save

`load` reads a `.gloo` file into the heap and runs its `on_load` script. Give a path relative to the project folder (no extension needed) or a full path (extension required); `*` in place of a file name loads every `.gloo` file in a folder.

```gloo
> load my/project/config
> load my/app/*
> load ~/.my_app/settings.gloo
```

If the name can't be resolved to a file, `load` reports `File not found: {name}` — it fires `on_error` and, when the file was named on the `gloo` command line, prints the message to stderr and exits non-zero. A bad or missing file never fails silently.

`save` writes loaded objects back to their files. With no argument it saves every open file; with an object it saves the file (or files) that object's tree came from; with `to {path}` it **extracts** — moves the object (and its descendants) out of whichever file currently owns them, into a new file, under their full dotted path.

```gloo
> save                        # every open file
> save config                 # just config's file
> save app.core.settings to config/settings
```

A save is a **rewrite, not a regeneration**: comments, blank lines, and the original spacing are kept, and only the values you actually changed are re-written. A declaration you never touched comes back byte-for-byte.

`save {obj} to {path}` doesn't just write a copy — `obj` stops being declared in its old file, wherever that was. Given `app.core.settings` declared inside `app.gloo`, `save app.core.settings to config/settings` leaves `app.gloo` without a `settings` subtree and writes `config/settings.gloo` with `app.core.settings [can] : ...` at the top level (the `app`/`core` prefix is implied via nested-container shorthand, not repeated as nested declarations) plus everything `settings` owns underneath, comments included. An object with no file of its own yet (brand new, or nested under an object that's never been saved) is simply written fresh — nothing to move.

If `obj`'s own subtree already has declarations spread across more than one file (the namespace-merge pattern below, applied *inside* the subtree being extracted, not just above it), extraction refuses rather than guessing which file's slice is authoritative — save each contributing file on its own first.

Several files can contribute to one container — declare `app [container] :` in each and add different children. They merge in the heap, and each file's save only rewrites its own declarations. If two files declare the *same* object with different values, the first one loaded wins and `load` logs a warning.

An object can also save itself: `tell config to save`.

---

`run`, `tell`, `put`, and `load` / `save` cover a lot of ground, but there are more than two dozen other verbs — `show`, `if`, `create`, `each`, `check`, `reload`, `unload`, and so on — all documented in-app. Enter `help` (or `?`), then `verbs` to browse them. (This page itself is also viewable in-app: `help> doc verbs`.)
