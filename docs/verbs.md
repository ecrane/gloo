# Verbs

Verbs are the commands that make up a gloo script — `put`, `show`, `run`, `tell`, and 24 others. Every statement in gloo starts with a verb.

Verbs aren't just for scripts, though. They're also the interactive language of the gloo application itself: run `gloo` in CLI mode (see Application, Running Gloo) and you can type these same verbs directly at the prompt, one at a time, in a REPL.

This page walks through three of the most commonly used verbs to get a feel for how they work together. For the complete list of verbs, their full syntax, and every error they can raise, use the in-app help: enter `help` (or `?`), then `verbs` to list them all, or `verb {name}` for detail on one (see Application, Help).

### Run

`run` runs a script or other runnable object — the same as sending it a `run` message.

```gloo
run {path.to.object}
```

```gloo
> run my.script

> create s as script : "show 3 + 4"
> run s
```

### Tell

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

### Put

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

---

`run`, `tell`, and `put` cover a lot of ground on their own, but there are 25 more verbs — `show`, `if`, `create`, `each`, `check`, and so on — all documented in-app. Enter `help` (or `?`), then `verbs` to browse them. (This page itself is also viewable in-app: `help> doc verbs`.)
