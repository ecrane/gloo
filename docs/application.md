# Gloo Application

**Contents**

- The Gloo Home Directory
- Running Gloo
- Modes
- Script Mode and App Mode
- Stopping with Ctrl-C
- Configuration
- Logging
- Help

## The Gloo Home Directory

Gloo keeps its configuration, projects, and logs under a per-user home directory. This is exposed at runtime through a set of gloo system objects (see Language, Syntax) (`gloo.gloo_home`, and friends):

- `gloo.gloo_home` — the gloo home directory
- `gloo.gloo_config` — the configuration directory (see Configuration, below)
- `gloo.gloo_projects` — the projects directory (same as `gloo.app` when an app is running)
- `gloo.gloo_log` — the logging directory (see Logging, below)
- `gloo.gloo_tmp` — a folder for temporary files, such as scratch files a script or test writes and then deletes. It's `tmp` under the gloo home directory unless `tmp_path` in `gloo.yml` says otherwise (see Configuration, below), and it's created if it isn't there. Use it instead of `/tmp`, which doesn't exist on Windows.

```
> show gloo.gloo_home
```

## Running Gloo

```
gloo [global option] [file]
```

Running gloo with a file specified will run that file. Once that file is done, gloo will quit. However, by specifying `--cli`, once the file has finished, gloo will remain open in CLI mode.

Gloo can also be started from another Ruby program; see Development, Running Gloo from Ruby.

If a file named on the command line can't be found (a typo, the wrong folder, a missing `.gloo` extension on a full path), gloo prints `File '{name}' was not found.` to stderr and exits with a non-zero status. Any other load or run error also exits non-zero — including syntax errors in a file that otherwise loaded (gloo keeps loading past them, reporting each with its file and line) — so a shell script calling gloo can tell a failed run from a clean one.

The exit status covers the whole run, not just its last line: gloo exits with status 1 if any error, or any Ruby exception, happened at any point while the files were loading or running, and 0 otherwise. An error still counts when an `on_error` or `on_exception` handler ran for it, because a handler reports the problem, it doesn't undo it. Warnings don't count. This applies when gloo runs files (Script mode); App and CLI modes don't set an exit status, and Test mode has its own (see the `--test` option below). In any mode, a run that Ctrl-C stopped exits with 130 (see Stopping with Ctrl-C).

When specifying a file there are a couple ways to reference the gloo file to open:

- By Path
    - Use an absolute or relative path to the gloo file.
    - Include the `.gloo` or other file extension when specifying by path.
    - For example:
        ```
        gloo ~/folder/file.gloo
        ```
- By Project
    - Use the path within the project folder.
    - The `.gloo` extension can be left off.
    - The location of the project folder is part of the configuration.
    - For example:
        ```
        gloo my_project/file
        ```

## Modes

```
--cli        - Run in CLI mode
             - If no options are specified, this is the default.
--app        - Run in App mode
             - Requires an extra parameter which is the root path of the project.
             - Running in app mode overrides the default project path for gloo.
             - By default gloo will look for a start.gloo file in the
               root level of the project. That start.gloo file should load other files
               and run the app.
             - Any further parameter(s) after the project path are not loaded by
               gloo as files - they're passed through as a single command for the
               app's own command handling (e.g. a [shell] object, from the cli core
               library, runs it once via its execute_once) and gloo exits once that
               command completes, instead of starting an interactive session.
--script     - Run in Script mode
             - Run the script in the file parameter and then quit.
             - If a file is provided as a parameter this option does not need to be specified.
--test       - Run in Test mode
             - Runs the *.test.gloo files in the folders and files given
               (the current folder if none), using the gloo-test library.
             - Exits with status 1 if any test failed, or errors or warnings
               were logged that no test expected; 0 otherwise.
             - See Testing.
--embed      - Run in Embedded mode
             - Start the engine and return, for a Ruby program that drives
               gloo itself.
             - This is the default when gloo is created in code with no file
               or mode. See Development, Running Gloo from Ruby.
--version    - Show application version
--help       - Show the help screen
```

## Script Mode and App Mode

Gloo runs a file in one of two ways, and they're meant for different things.

**Script mode** (`gloo path/to/file.gloo`) is a transaction: gloo loads the file, runs its `on_load`, and quits. Use it for a job that does something and finishes.

**App mode** (`gloo --app path/to/folder`) is a process: gloo loads the folder's `start.gloo`, and the app stays up — a shell taking commands, a web server, a connection — until it's told to stop. The folder is the app's root: `gloo.app` is that folder, and words after it on the command line are a command for the app, not files to load.

An app only runs in App mode. If an app's `start.gloo` is run as a script by mistake, starting a shell (gloo-cli) or a web server (gloo-web) is an error that says how to run it, for example `Could not start the shell: an app runs in App mode. Run it with 'gloo --app ~/gloo/app/notes'.`, and gloo exits with status 1.

The two also differ in what the **project folder** is. In App mode it's the app's folder. Otherwise it's where you keep your projects: the `project_path` setting (see Configuration), `~/gloo/projects` unless you change it, and `gloo.gloo_projects`.

### Where a Relative Load Looks

A `load` with a full path, or one starting with `~`, loads that file. A relative name is looked for in a few places, in order, and the first place that has it wins:

| Mode | Looks in, in order |
|---|---|
| App mode | the app folder → next to the loading file → the gloo home |
| Script and Test modes | next to the loading file → the projects folder → the gloo home |
| A command typed at the prompt | the working folder → the projects folder → the gloo home (in App mode: the app folder → the working folder → the gloo home) |

"Next to the loading file" is the folder of the file the running script was declared in — the folder `check {obj} for source_dir` gives for it. A script declared in one file and run from another still looks next to its own file. A script that didn't come from a file (one created while gloo runs) skips this step. A command typed at the prompt has no file, so the working folder stands in for it; a load inside a file never depends on where gloo was started.

A folder load (`load parts/*`) is looked for the same way, and the first place with matching `.gloo` files is used. The gloo home comes last in every mode, so files kept there (such as a `common` folder shared by several apps) can be loaded from anywhere.

For example, a small project:

```
report/
  start.gloo      # on_load: load parts/*
  parts/
    totals.gloo
    format.gloo
```

Run as a script (`gloo report/start.gloo`), `load parts/*` finds `report/parts` next to `start.gloo`, whatever folder gloo was started from. Run as an app (`gloo --app report`), it finds the same folder as part of the app. Inside an app, a name means the same thing in every file: `load parts/format` gets `report/parts/format.gloo` whichever of the app's files says it.

Files named on the command line are found differently: as given (from the working folder), then in the projects folder, then in the gloo home (see Running Gloo, above).

A new file saved with a relative name (`save notes to lists/notes`, or `save notes` for a top-level object that has no file yet) goes in the first place a load would look: the app folder in App mode, otherwise next to the saving script's file, or the working folder for a command typed at the prompt. A script that didn't come from a file saves into the projects folder. So a script that saves `lists/notes` can load it back with `load lists/notes`.

## Stopping with Ctrl-C

Ctrl-C stops whatever is running and gives you a clean prompt. It isn't a way to leave gloo — `quit` is.

- **A script** (`gloo file.gloo`, at a terminal): Ctrl-C stops the run and leaves you at the gloo prompt, with everything that was loaded and done so far still there to look at. `quit` then leaves.
- **At a prompt** — gloo's own, a web app's (the same prompt), a gloo-cli shell's or a menu's: Ctrl-C during a command stops it and gives you that same prompt back. At an empty prompt it says how to leave, for example `Use 'quit' to stop running gloo.`; with something typed, the line is dropped.
- **With no one at a terminal** (gloo run by cron or launchd, or with its input piped in) and in Test mode: Ctrl-C stops the run, runs `on_quit`, and exits.
- **While gloo is quitting** (`on_quit`, or a web app's `on_stop`): Ctrl-C stops the rest of the quitting, and gloo exits at once, with a warning, `Quit cut short by Ctrl-C: {where}.`

Ctrl-C isn't an error: it doesn't run `on_error`, and `it` keeps whatever the last finished line put there. But it's never silent: when it stops something, gloo says where, `Stopped by Ctrl-C: app.sync.do, line 2.`, and logs it as a warning, since the work it stopped may be half done. What already ran stays done.

After Ctrl-C has stopped something, gloo exits with status 130 when it ends (the usual status for a program stopped by Ctrl-C), so a shell script that ran it can tell.

## Configuration

When gloo runs, it looks for a configuration file which it expects to find in `~/gloo/config/`. If there is no `gloo.yml` file in that directory, one will be created and default values added.

```yaml
#
# Gloo configuration
#
gloo:

  #
  # Root directory for projects.
  # Update this with the directory with your gloo projects.
  #
  project_path: /Users/my_user/gloo/projects

  #
  # Folder for temporary files, such as scratch files written by
  # tests. Scripts get it with $.gloo_tmp.
  #
  tmp_path: /Users/my_user/gloo/tmp

  #
  # Run this script when starting up gloo.
  # (Only if a script file is not specified.)
  # A bare filename (no path) is looked up in the config directory
  # above. Either way, the .gloo extension is assumed if left off.
  #
  start_with:

  #
  # Indentation (spaces) when showing an object outline.
  #
  list_indent: 2

  #
  # Show listing the object tree,
  # how many levels of children will be shown?
  # Children at deeper levels will be hidden.
  #
  list_levels: 3

  #
  # When listing the object tree, also show each object's doc (the
  # comment declared immediately above it in its source file), if it
  # has one.
  #
  list_docs: false

  #
  # Show debug statements in the log?
  #
  debug: false

  #
  # Color theme for console output: dark or light.
  # Match this to your terminal's background.
  #
  theme: dark
```

## Color Theme

Gloo colors its console output (prompts, `help settings`, warnings/errors, listings, the help shell) to be readable against a terminal background. There's no auto-detection — set `theme: dark` or `theme: light` in `gloo.yml` to match your terminal, and it applies everywhere at once. Defaults to `dark` if unset or set to anything else.

To see the current theme and preview both palettes side by side (handy for comparing across terminals before you switch), use the `theme` help topic:

```gloo
> help
help> theme
```

## Logging

Gloo writes to the `gloo.log` and `error.log` files as well as to the console.

Debug messages are written to the log only, but other messages are also written to the console unless the application is running in quiet mode.

On the console, errors and warnings go to stderr, while a script's own output (`show`) goes to stdout. So the two can be redirected separately: `gloo my_script.gloo 2>/dev/null` shows just the script's output.

Only error and warning level messages are written to the error log.

In test mode (`--test`), errors and warnings go to the log files only, not the console, so the test output is just the test results. An error a test expects (or one from a test file that deliberately contains a problem) is still in `error.log`. The summary at the end of a test run says how many errors and warnings were logged, and by which tests, leaving out those a test expects (`expect_errors`). See Testing.

The application logs folder is in the gloo folder. When gloo is run, the log files will be created if they do not exist. To trim the logs, just delete those log files.

Example tail command to watch the gloo log:

```shell
tail -f ~/gloo/logs/gloo.log
tail -f ~/gloo/logs/error.log
```

## Help

### Inline Reference

Gloo has a built-in `help` verb (shortcut `?`) that enters an interactive help shell:

```gloo
help
```

From the `help>` prompt, look up verbs, object types, settings, the color theme, extensions, libraries, and narrative doc pages, or get detailed help for a specific verb, object, doc page, loaded library, or loaded extension:

- `verbs` — list all verbs
- `objects` — list all object types
- `settings` — show application settings
- `theme` — show the current color theme, how to change it, and a preview of both palettes
- `extensions` — list loaded extensions (only loaded extensions are shown; use `load ext {name}` first)
- `libraries` — list loaded libraries (only loaded libraries are shown; use `load lib {name}` first)
- `docs` — list all narrative doc pages (this page and its siblings)
- `verb {name}` — detailed help for one verb (tab-completable)
- `object {name}` — detailed help for one object type (tab-completable)
- `doc {name}` — show one narrative doc page (tab-completable)
- `library {name}` — show a loaded library's README, from the root of its gem (tab-completable, loaded libraries only)
- `extension {name}` — show a loaded extension's README, from the root of its extension folder (tab-completable, loaded extensions only)
- `quit` — leave the help shell

```gloo
> help
help> verbs
help> verb put
help> object container
help> theme
help> docs
help> doc getting_started
help> library db
help> quit
```

### Narrative Docs in the Shell

This page and the others in `docs/` (in the interpreter's source) are the same files shown by `help> doc {name}` — there's no separate doc server or web mode. A `gloo --doc` local web server was considered and put off in favor of this: one system, no separate build/serve step.
