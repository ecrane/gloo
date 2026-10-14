# Development

How the interpreter's source is laid out, how to run its tests, and the conventions to follow when changing it. This page is for working on gloo itself; for using gloo, start with Getting Started.

**Contents**

- Source Layout
- Tests
- Documentation
- Reporting Errors

## Source Layout

```
lib/gloo/
├── app/         Engine, application modes, logging
├── core/        Parser, Obj base class, Dictionary, path names (PN)
├── exec/        Execution engine, dispatcher, runner
├── expr/        Expression evaluator and operators
├── objs/        Object type implementations
│   ├── basic/   string, int, bool, container, text, decimal, untyped, alias
│   ├── ctrl/    script, function (ƒ), each, repeat
│   ├── dt/      date, time, datetime
│   ├── str_utils/ cipher, csrf_token, outline, password
│   ├── system/  ruby, file_handle, system
│   └── web/     http_get, http_post, json, uri, erb
├── verbs/       One file per verb
├── docs/        doc_data and the in-app help shell
├── shell/       Interactive shell support
├── persist/     File loading and saving
├── convert/     Type conversion
└── plugin/      Plugin system
test/            Ruby unit tests (minitest)
test.gloo/       Gloo-language integration tests
```

## Tests

There are two automated suites. Run both when making a change, and add to both: a change to the interpreter gets a unit test and a gloo test.

### Unit tests — `test/`

Standard Ruby minitest tests. The layout mirrors `lib/gloo/`, one test file per class or verb: `test/<area>/<name>_test.rb`, for example `test/verbs/show_test.rb` for `lib/gloo/verbs/show.rb`. Test classes inherit from `GlooTest` (in `test/base_test.rb`).

```
rake test
```

### Gloo tests — `test.gloo/`

Integration tests written in gloo itself, using the `[test]` object from the `gloo-test` core library. The suite also loads the `gloo-yaml` and `gloo-md` core libraries, so install all three first:

```
gem install gloo-test gloo-yaml gloo-md
```

Each `*.test.gloo` file holds `[test]` objects whose `on_test` script uses `assert` and `refute`:

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

Run them with the interpreter in this repo, passing any mix of folders and single test files:

```
ruby lib/run.rb --test --quiet test.gloo/
```

Use plain `ruby`, not `bundle exec`. The Gemfile doesn't include `gloo-test` or the other core libraries, so under bundler the `[test]` type and any `load lib` in a test file can't be found. Plain `ruby` uses the installed gems. If one of the core libraries is missing, gloo runs `gem install` for it in the middle of the test run, which fails without a network connection.

The same command runs the gloo tests of core libraries and extensions; add their `test/` folders to the list of paths.

## Documentation

The narrative documentation is the set of flat pages in `docs/`, linked from the README. Two conventions keep them readable both on GitHub and in a terminal:

- No markdown links between pages. Refer to another page or section in plain text instead, for example "see Put" or "see Application, Help".
- A `---` line separates sections that came from different source material.

Reference documentation for each verb and object type lives in the code. Every verb (`lib/gloo/verbs/*.rb`) and object type (`lib/gloo/objs/**/*.rb`) defines `self.doc_data`, a hash of name, shortcut, description, syntax, parameters, result, errors, examples and notes (see `lib/gloo/docs/doc_data.rb`). It's rendered by the in-app help shell (`help` or `?`). When adding or changing a verb or object type, add or update its `doc_data` too.

Core libraries follow the same `doc_data` pattern for their own verbs and objects.

## Reporting Errors

Gloo reports every problem in a way scripts can see (see Language, Syntax, Errors and Warnings). In the interpreter that means:

- `@engine.syntax_err` — the command couldn't be understood.
- `@engine.err` — the command was understood but couldn't be done.
- `@engine.warn` — the command was done, but probably not the way it was meant.
- A question whose answer is "no" is just a result, not an error.

Don't use `@engine.log.error` or `@engine.log.warn` for these; they only write to the log, and scripts can't see them. Build "not found" messages with `Gloo::Core::NotFound` (for example `NotFound.object( name )`) so they always read the same way.
