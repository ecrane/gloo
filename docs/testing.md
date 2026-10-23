# Testing

How to write and run tests for gloo code: an app, an extension or a core library. Tests are written in gloo itself, in `*.test.gloo` files, using the `[test]` object and the `assert` and `refute` verbs from the `gloo-test` core library. This page is about those gloo tests. Ruby unit tests for an extension's Ruby code are covered in Plugins, Testing an Extension; for the interpreter's own tests, see Development, Tests.

**Contents**

- Running Tests
- Writing a Test
- Assertions
- Test Order and Setup
- Errors and Warnings
- Tests Meant to Fail
- Files in Tests

## Running Tests

Install the `gloo-test` gem, then run gloo in test mode with the tests to run:

```
gem install gloo-test
gloo --test path/to/tests/
```

`--test` loads the `gloo-test` library itself, so a test file doesn't need `load lib test`. Give any mix of folders and single files. In a folder, every `*.test.gloo` file is run, including those in subfolders. With no path, gloo looks in the current folder.

While the tests run, gloo shows a `.` for each test that passes and an `x` for each one that fails. Then it lists the failures, each with the test's path, its description and the message of the assertion that failed, and ends with a summary:

```
x.....

*** Failures (1) ***

tests.math.wrong_on_purpose -> A failing test, to see the output.
   expected 2 + 2 to be 5

Tests: 6 • Passed: 5 •  Failed: 1
  Assertions: 6 • Files: 2
Tests finished in 0.01 seconds
```

In test mode, errors and warnings go to the log files, not the console, so the output is just the test results (see Application, Logging). The summary says when any were logged; see Errors and Warnings, below.

When the run is over, gloo exits with status 0 if it passed, and 1 if any test failed or the summary reports errors or warnings that no test expected. A missing test file or folder counts too. So a script or CI job can tell a good run from a bad one:

```
gloo --test test/ && echo "all good"
```

## Writing a Test

A test file holds one root container with `[test]` objects inside it. By convention, the root is `tests`, and each file adds its own area under it with nested container shorthand (see Language, Objects), so many test files can share the `tests` root:

```gloo
tests.math [can] :

  total [int] : 0

  adds_up [test] :
    description [string] : Adding two numbers.
    on_test [script] :
      eval 2 + 2
      put it into ^^.total
      eval ^^.total = 4
      assert "expected 2 + 2 to be 4"
```

A `[test]` has two children:

- `description` — what the test checks. It's shown with the test's path when the test fails.
- `on_test` — the script that does the work and makes the assertions.

Inside `on_test`, `^` is the test and `^^` is the container that holds it, so `^^.total` is the `total` object beside the test. Objects a test works with usually sit in the container, next to the tests.

## Assertions

`assert` and `refute` look at `it`. `assert` passes if `it` is true; `refute` passes if `it` is false. Each takes an optional message, which is shown if it fails, so write it as what was expected:

```gloo
check ^^.name for blank?
refute "expected the name to be set"

eval ^^.count > 0
assert "expected at least one item"
```

`expect` is another name for `assert`, and `expect_not` for `refute`.

So a test usually puts the thing it's checking into `it` first: with `eval` for a comparison, `check` for a question (`blank?`, `contains?`, `exists?`), or a message or verb that sets `it` (see Language, Syntax, It). A test can have any number of assertions, and it fails if any one of them fails.

## Test Order and Setup

Tests run in a random order: the files are shuffled, and so are the tests within each file. A test mustn't depend on another test having run first. Each one sets up what it needs and cleans up after itself.

Between files, the heap is emptied: objects a file loads are gone before the next file runs. Within a file, the tests share the file's objects, so a test that uses one should set it at the start rather than rely on its declared value. For example, `put false into ^^.err_fired` before the step that should set it.

Setup that's the same for every test in a file, and that no test changes, can go in an `on_load` script in the file's container. It runs when the file loads, before any of its tests:

```gloo
tests.files [can] :

  scratch [file] :

  # Runs when this file loads, before any test.
  on_load [script] :
    put $.gloo_tmp '/my_scratch.gloo' into ^.scratch
```

## Errors and Warnings

The run keeps track of the errors and warnings logged by each test. If any were logged, the summary gets an extra line naming the tests that logged them:

```
Tests: 4 • Passed: 4 •  Failed: 0
  Assertions: 4 • Files: 1
  1 error logged during the run; see ~/gloo/logs/error.log
    tests.files.missing_file_is_an_error (1 error)
Tests finished in 0.0 seconds
```

Problems logged while a test file loads, outside any test, are counted too, as `(outside tests: …)`. A clean run has no such line. Treat one as a problem even when every test passed: something went wrong that no assertion caught.

A test that triggers an error or a warning on purpose (to check an `on_error` handler, or that bad input is reported) sets `expect_errors` to true. What it logs is then left out of the summary:

```gloo
tests.files [can] :

  err_fired [bool] : false

  on_error [script] :
    put true into ^.err_fired

  missing_file_is_an_error [test] :
    description [string] : Loading a file that isn't there fires on_error.
    expect_errors [bool] : true
    on_test [script] :
      put false into ^^.err_fired
      load no_such_file_xyz
      eval ^^.err_fired = true
      assert "expected on_error to fire"
```

## Tests Meant to Fail

A test that's meant to fail, such as one that shows an assertion really does fail when it should, sets `expect_fail` to true. It then passes if at least one of its assertions fails, and fails if none does:

```gloo
  false_fails_an_assert [test] :
    description [string] : assert fails when it is false.
    expect_fail [bool] : true
    on_test [script] :
      eval 1 = 2
      assert "this one is meant to fail"
```

`expect_fail` can't tell which assertion failed, or why, so a test can fail for the wrong reason and still pass. Keep a test like this to the one thing it checks. That's good practice for every test, but it matters most here.

## Files in Tests

**Scratch files.** A test that needs a file it writes and then deletes should put it in the gloo tmp folder, `$.gloo_tmp`, rather than `/tmp`, which doesn't exist on Windows (see Application, The Gloo Home Directory). Set the path once in `on_load`, as in Test Order and Setup, above. To load the file, put the path in parentheses so it's worked out rather than taken literally (see Language, Syntax, Computed Arguments). Unload what was loaded and delete the file at the end of the test:

```gloo
      tell ^^.scratch to write ( ^^.source )
      load ( ^^.scratch )
      # ... assertions ...
      tell demo to unload
      tell ^^.scratch to delete
```

**Fixtures.** A file the tests read but never change can be kept next to the test file, for example in a `fixtures` folder. Name it something other than `*.test.gloo`, so it isn't run as a test. `check ^^ for source_dir` gives the folder of the test file (see Language, Objects, Where an Object Came From):

```gloo
tests.files [can] :

  where [string] :
  fixture [string] : /fixtures/sample.gloo

  loads_its_fixture [test] :
    description [string] : A fixture next to this file can be loaded.
    on_test [script] :
      check ^^ for source_dir
      put it into ^^.where
      load ( ^^.where ^^.fixture )
      eval sample.name = 'from the fixture'
      assert "expected the fixture to load"
      tell sample to unload
```

**Broken source on purpose.** To test how gloo handles a mistake in a file, such as a missing `]` or a declaration with no name, don't put the mistake in the test file itself. It would be reported while the file loads, outside any test. Instead, keep the broken source in a `[text]` object, write it to a scratch file inside the test, and load it there. The problem then belongs to that test, which sets `expect_errors`:

```gloo
  broken_src [text] : BEGIN
broken_demo [can] :
  count [int : 3
END

  broken_source_still_loads [test] :
    description [string] : A type missing its ] is still read as that type.
    expect_errors [bool] : true
    on_test [script] :
      tell ^^.scratch to write ( ^^.broken_src )
      load ( ^^.scratch )
      eval broken_demo.count = 3
      assert "expected the value 3"
      tell broken_demo to unload
      tell ^^.scratch to delete
```
