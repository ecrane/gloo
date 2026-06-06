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
│   ├── verbs/       One file per verb (28 total)
│   ├── persist/     File loading/saving
│   ├── convert/     Type conversion
│   └── plugin/      Plugin system
├── test/            Ruby unit tests (minitest)
└── test.gloo/       Gloo-language integration tests
```

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
