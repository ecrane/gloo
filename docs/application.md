# Gloo Application

**Contents**

- The Gloo Home Directory
- Running Gloo
- Modes
- Configuration
- Logging
- Help

## The Gloo Home Directory

Gloo keeps its configuration, projects, and logs under a per-user home directory. This is exposed at runtime through a set of gloo system objects (see Language, Syntax) (`gloo.gloo_home`, and friends):

- `gloo.gloo_home` — the gloo home directory
- `gloo.gloo_config` — the configuration directory (see Configuration, below)
- `gloo.gloo_projects` — the projects directory (same as `gloo.app` when an app is running)
- `gloo.gloo_log` — the logging directory (see Logging, below)

```
> show gloo.gloo_home
```

## Running Gloo

```
gloo [global option] [file]
```

Running gloo with a file specified will run that file. Once that file is done, gloo will quit. However, by specifying `--cli`, once the file has finished, gloo will remain open in CLI mode.

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
    - Do not include the `.gloo` or other file extension.
    - The location of the project folder is part of the configuration.
    - For example:
        ```
        gloo my_project/file.gloo
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
--script     - Run in Script mode
             - Run the script in the file parameter and then quit.
             - If a file is provided as a parameter this option does not need to be specified.
--test       - Run in Test mode
--version    - Show application version
--help       - Show the help screen
```

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
  # Run this script when starting up gloo.
  # (Only if a script file is not specified.)
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
  # Show debug statements in the log?
  #
  debug: false
```

## Logging

Gloo writes to the `gloo.log` and `error.log` files as well as to the console.

Debug messages are written to the log only, but other messages are also written to the console unless the application is running in quiet mode.

Only error and warning level messages are written to the error log.

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

From the `help>` prompt, look up verbs, object types, settings, extensions, libraries, and narrative doc pages, or get detailed help for a specific verb, object, doc page, loaded library, or loaded extension:

- `verbs` — list all verbs
- `objects` — list all object types
- `settings` — show application settings
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
help> docs
help> doc getting_started
help> library db
help> quit
```

### Narrative Docs in the Shell

This page and its ten siblings (`docs/*.md` in the interpreter's source) are the same files shown by `help> doc {name}` — there's no separate doc server or web mode. A `gloo --doc` local web server was considered and put off in favor of this: one system, no separate build/serve step.
