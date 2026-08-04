@/Users/ecrane/dev/gloo_meta/CLAUDE.md

# Gloo — Core Interpreter

This is the main gloo language implementation, packaged as a Ruby gem.

## Project Structure

```
gloo/
├── lib/gloo/
│   ├── core/        Parser, Obj base class, Dictionary, path names (PN)
│   ├── exec/        Execution engine, dispatcher, runner
│   ├── expr/        Expression evaluator and operators
│   ├── objs/        Object type implementations
│   │   ├── basic/   string, int, bool, container, text, decimal, untyped, alias
│   │   ├── ctrl/    script, function (ƒ), each, repeat
│   │   ├── dt/      date, time, datetime
│   │   ├── str_utils/
│   │   ├── system/  ruby, file_handle, system
│   │   └── web/     http_get, http_post, json, uri, erb
│   ├── verbs/       One file per verb (29 total)
│   ├── persist/     File loading/saving
│   ├── convert/     Type conversion
│   └── plugin/      Plugin system
├── test/            Ruby unit tests (minitest)
└── test.gloo/       Gloo-language integration tests
```

## Documentation

This project is the authoritative source for gloo language documentation — not the `vaults/gloo` Obsidian vault, whose old `doc/` folder was renamed to `doc_deprecated/` and retired.

- **Narrative reference** — `docs/*.md`, ten flat files: `getting_started.md`, `application.md`, `language_objects.md`, `language_syntax.md`, `language_scripting.md`, `operators.md`, `iterators.md`, `objects.md`, `verbs.md`, `plugins.md`. Linked from the root `README.md`. Convention: no markdown link syntax between pages (plain-text pointers instead, e.g. "see Put" not `[Put](put.md)`) since these are read both on GitHub and in a terminal; `---` separates sections that came from different source material.
- **Verb/object reference** — each verb (`lib/gloo/verbs/*.rb`) and object type (`lib/gloo/objs/**/*.rb`) class defines `self.doc_data` (name, shortcut, description, syntax, parameters, result, errors, examples, notes — see `lib/gloo/docs/doc_data.rb`), rendered by the in-app interactive help shell (`help`/`?`, see `lib/gloo/docs/help_shell.rb`). When adding or changing a verb or object type, add/update its `doc_data` too.
- Core-lib gems (`gloo_core_libraries`) follow the same `doc_data` pattern for their own verbs/objects; a narrative `doc/` folder per gem is planned but not yet built.

## Test Suites

### Ruby unit tests — `test/`
Run with: `rake test`

File naming: `test/<area>/<name>_test.rb`
Structure mirrors `lib/gloo/` — a test file per class/verb.

```
test/
├── verbs/           One *_test.rb per verb
├── objs/basic/      One *_test.rb per object type
├── objs/ctrl/
├── objs/dt/
├── core/
├── exec/
├── expr/
└── ...
```

Base classes: inherit from `GlooTest` (defined in `test/base_test.rb`).

### Gloo integration tests — `test.gloo/`
Written in gloo itself. Each file contains `[test]` objects with `on_test` scripts using `assert` and `refute`.

```
test.gloo/
├── basic.test.gloo
├── dt/
├── lang/
├── math/
├── objs/
├── string/
└── verbs/
```

Test object pattern:
```gloo
tests [can] :
  group [can] :
    my_test [test] :
      description [string] : What this verifies
      on_test [script] :
        # ... setup ...
        eval some.value = expected
        assert "description of passing condition"
```

## Adding a Missing Unit Test

1. Find the relevant `test/<area>/*_test.rb` file (or create one mirroring the `lib/` path)
2. Inherit from `GlooTest`
3. Run the full suite with `rake test` to verify nothing is broken
4. Check `test.gloo/` to see if a corresponding gloo-level integration test is also needed
