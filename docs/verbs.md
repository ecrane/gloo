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

`save` writes loaded objects back to their files. With no argument it saves every open file; with an object it saves the file (or files) that object's tree came from; with `to {path}` it saves to a new file and remembers the mapping.

```gloo
> save                        # every open file
> save config                 # just config's file
> save config to backups/config
```

A save is a **rewrite, not a regeneration**: comments, blank lines, and the original spacing are kept, and only the values you actually changed are re-written. A declaration you never touched comes back byte-for-byte.

Several files can contribute to one container — declare `app [container] :` in each and add different children. They merge in the heap, and each file's save only rewrites its own declarations. If two files declare the *same* object with different values, the first one loaded wins and `load` logs a warning.

An object can also save itself: `tell config to save`.

---

`run`, `tell`, `put`, and `load` / `save` cover a lot of ground, but there are more than two dozen other verbs — `show`, `if`, `create`, `each`, `check`, `reload`, `unload`, and so on — all documented in-app. Enter `help` (or `?`), then `verbs` to browse them. (This page itself is also viewable in-app: `help> doc verbs`.)
