# Plugins

**Contents**

- Core Libraries
- User Extensions

## Core Libraries

Core Libraries extend gloo functionality, primarily by adding object types and potentially verbs.

A core library ships as its own gem (`gloo-<name>`). `load lib <name>` requires the gem, installing it first via `gem install` if it isn't already present — so the explicit `gem install` step below is optional, but doing it yourself ahead of time is recommended so the install doesn't happen mid-script. Once loaded, a library's objects and verbs show up in the `help`/`?` shell exactly like built-ins:

```gloo
> gem install gloo-yaml
> load lib yaml
help> object yaml
```

A library's object types must be registered before any file that declares one is parsed. To use a library type in a script file, put the `load lib` at the **top of the file**, before the first object:

```gloo
load lib yaml

settings [can] :
  file [yaml] : ~/.myapp/settings.yml
  ...
```

The loader runs these top-of-file `load lib` / `load ext` lines before it builds the object tree, so declarations below them can use the library's types. Only `load lib` and `load ext` are recognized this way, and only above the first object — a `load lib` in a script still runs when that script runs, as before.

### Available Core Libraries

- **CLI** — Use the `gloo-cli` gem when building CLI applications.
    - Library Objects: Prompt, Colorize, Confirm, Select, Menu, Menu Item, Shell, Command
    ```gloo
    > gem install gloo-cli
    > load lib cli
    help> object prompt
    ```
- **Database** — Use the `gloo-db` gem and one or more of `gloo-sqlite`, `gloo-mysql`, `gloo-pg` connector gems.
    - Library Objects: Query, Table, SQLite, MySQL, Postgres
    ```gloo
    > gem install gloo-db gloo-sqlite
    > load lib db
    > load lib sqlite
    help> object query
    ```
- **Email** — Use the `gloo-email` gem to send and receive email.
    - Library Objects: Email, Email SMTP, Email IMAP
    ```gloo
    > gem install gloo-email
    > load lib email
    help> object email_smtp
    ```
- **Markdown** — Use the `gloo-md` gem to render markdown.
    - Library Objects: Markdown, MD Doc (a markdown file with YAML frontmatter), Markdown Extensions (part of the markdown object)
    ```gloo
    > gem install gloo-md
    > load lib md
    help> object markdown
    ```
- **Test** — Use the `gloo-test` gem to manually include. See Test Runner for notes about the gloo test runner.
    - Library Objects: Test
    - Library Verbs: Assert, Refute
    - See also: Eval, It
    ```gloo
    > gem install gloo-test
    > load lib test
    help> verb assert
    ```
- **Web Server** — Use the `gloo-web` gem when building web applications.
    - Library Objects: Server, Page, Partial, Form, Field, Element
    ```gloo
    > gem install gloo-web
    > load lib web
    help> object page
    ```
- **YAML** — Use the `gloo-yaml` gem for YAML file read/write support.
    - Library Objects: YAML
    ```gloo
    > gem install gloo-yaml
    > load lib yaml
    help> object yaml
    ```

## User Extensions

A User Extension is a mechanism that can be used to add verbs and objects that are not built into gloo.

Extensions are ruby code that live in the `extensions` folder inside the gloo root folder (`~/gloo/extensions` by default — see `ext_path` in Settings).

An extension is structured thus:

```
~/gloo/extensions/
  /ext_name
    /doc/
    /src/
    /test/
    /ext_name_ext.rb
```

- `ext_name_ext.rb` — the extension's entry point. Loaded and registered when `load ext ext_name` runs.
- `src/` — the verb and/or object classes themselves, one file per class.
- `doc/` — narrative markdown for the extension (a `README.md` at the extension root plus optional per-object/verb `.md` files under `doc/` are the convention used by the built-in extensions — see e.g. `extensions/beep/`).
- `test/` — both Ruby unit tests (`*_test.rb`, minitest, same conventions as this project's own `test/` — see Test Suites in the root `CLAUDE.md`) and/or a gloo-language integration test (`*.test.gloo`).

Be sure to load an extension (or core library) prior to loading a gloo file that includes object types defined in the extension.

Use the Load Verb to use an extension: `load ext ext_name`.

### The extension entry point

`ext_name_ext.rb` defines a class named `<ExtName>Ext` (the extension's folder name, capitalized, plus `Ext`) that derives from `Gloo::Plugin::Base` and implements `register`. `register` is handed a `Gloo::Plugin::Callback` that it uses to register one or more verb and/or object classes:

```ruby
#
# Registers the beep extension.
#
# This extension provides a simple beep command.
#
class BeepExt < Gloo::Plugin::Base

    #
    # Register verbs and objects.
    #
    def register( callback )
      require_relative 'src/beep'

      callback.register_verb( Beep )
    end

end
```

`callback.register_verb` and `callback.register_obj` both take a class, not an instance. Wrap the calls in a `begin`/`rescue` if the extension has external dependencies (a gem, a CLI tool on the `PATH`, etc.) that might not be present, so a missing dependency logs an error instead of crashing the whole extension load — see `extensions/stats/stats_ext.rb` or `extensions/git/git_ext.rb` for the pattern:

```ruby
def register( callback )
  require_relative 'src/git'

  begin
    callback.register_obj( Git )
  rescue => e
    puts "Failed to load Git extension: #{e.message}"
  end
end
```

### Adding a Verb

A verb subclasses `Gloo::Core::Verb` and must implement `self.keyword`, `self.keyword_shortcut`, and `run`. Inside `run`, `@tokens` gives access to the parsed command line and `@engine` is the running engine (use `@engine.err` for user-facing errors, `@engine.heap.it` to set the implicit `it` result).

The simplest possible verb — `beep`, which takes no parameters (`extensions/beep/src/beep.rb`):

```ruby
#
# Play a standard system beep sound.
#
class Beep < Gloo::Core::Verb

  KEYWORD = 'beep'.freeze
  KEYWORD_SHORT = 'b'.freeze

  def self.keyword
    return KEYWORD
  end

  def self.keyword_shortcut
    return KEYWORD_SHORT
  end

  def run
    print 7.chr
  end

  # ---------------------------------------------------------------------
  #    Verb Documentation
  # ---------------------------------------------------------------------

  def self.doc_data
    {
      :name => KEYWORD,
      :shortcut => KEYWORD_SHORT,
      :description => 'Play a standard system beep sound.',
      :syntax => [ 'beep' ],
      :result => 'A system beep (chime) is sounded.',
      :examples => <<~EXAMPLES.strip
        > beep
      EXAMPLES
    }
  end

end
```

A verb that reads a parameter — `alert`, which evaluates an expression and shows it as a system notification (`extensions/alert/src/alert.rb`):

```ruby
class Alert < Gloo::Core::Verb

  KEYWORD = 'alert'.freeze
  KEYWORD_SHORT = '!'.freeze

  MISSING_EXPR_ERR = 'Missing Expression!'.freeze
  NO_RESULT_ERR = 'Expression evaluated with no result!'.freeze

  def run
    unless @tokens.token_count > 1
      @engine.err MISSING_EXPR_ERR
      return
    end

    expr = Gloo::Expr::Expression.new( @engine, @tokens.params )
    result = expr.evaluate

    if result
      @engine.heap.it.set_to result
      post_alert result
    else
      @engine.err NO_RESULT_ERR
    end
  end

  def self.keyword
    return KEYWORD
  end

  def self.keyword_shortcut
    return KEYWORD_SHORT
  end

  private

  def post_alert( msg )
    @engine.log.info msg
    return if @engine.args.quiet?

    post_osx msg
  end

  def post_osx( msg )
    cmd1 = '/usr/bin/osascript -e "display notification \"'
    cmd2 = '\" with title \"Gloo\" "'
    system( cmd1 + msg.to_s + cmd2 )
  end

end
```

Register it from `alert_ext.rb` with `callback.register_verb( Alert )`, and the verb `alert {message}` becomes available anywhere after `load ext alert`.

### Adding an Object

An object subclasses `Gloo::Core::Obj` and must implement `self.typename` and `self.short_typename`. Objects typically:

- expose named children (settings/parameters) that are read with `find_child`
- optionally auto-add default children on creation, via `add_children_on_create?` and `add_default_children`
- respond to messages (`tell obj to some_message`) by overriding `self.messages` to list the message names and defining a `msg_<name>` method for each

`stats`, from `extensions/stats/src/stats.rb`, shows all three. It declares three children (`folder`, `types`, `skip`), adds them automatically on `create`, and implements three messages that delegate to a plain Ruby helper class (`Gloo::Utils::Stats`, in `extensions/stats/src/stats_util.rb`) that does the real work:

```ruby
class Stats < Gloo::Core::Obj

  KEYWORD = 'stats'.freeze
  KEYWORD_SHORT = 'stat'.freeze
  FOLDER = 'folder'.freeze
  TYPES = 'types'.freeze
  SKIP = 'skip'.freeze

  def self.typename
    return KEYWORD
  end

  def self.short_typename
    return KEYWORD_SHORT
  end

  def path_value
    o = find_child FOLDER
    return o ? o.value : nil
  end

  def types_value
    o = find_child TYPES
    return o ? o.value : ''
  end

  def skip_list
    o = find_child SKIP
    val = o ? o.value : ''
    return val.split ' '
  end

  # ---------------------------------------------------------------------
  #    Children
  # ---------------------------------------------------------------------

  def add_children_on_create?
    return true
  end

  def add_default_children
    fac = @engine.factory
    fac.create_file FOLDER, '', self
    fac.create_string TYPES, '', self
    fac.create_can SKIP, self
  end

  # ---------------------------------------------------------------------
  #    Messages
  # ---------------------------------------------------------------------

  def self.messages
    all = %w[show_all]
    more = %w[show_busy_folders show_types]
    return super + all + more
  end

  def msg_show_all
    o = Gloo::Utils::Stats.new(
      @engine, path_value, types_value, skip_list )
    o.show_all
  end

  def msg_show_types
    o = Gloo::Utils::Stats.new(
      @engine, path_value, types_value, skip_list )
    o.file_types
  end

  def msg_show_busy_folders
    o = Gloo::Utils::Stats.new(
      @engine, path_value, types_value, skip_list )
    o.busy_folders
  end

end
```

`self.messages` should call `super` and append to it — the base `Gloo::Core::Obj` already contributes messages every object receives (`reload`, `unload`, `blank?`, `contains?`, `responds_to?`).

Used from gloo, once loaded:

```gloo
main [can] :
  stats [stats] :
    folder [file] : /Users/me/dev/project
    types [string] : rb erb js
    skip [string] : .git tmp
  on_load [script] :
    tell main.stats to show_all
```

Register it from `stats_ext.rb` with `callback.register_obj( Stats )`.

### Custom `each` iterators

An extension's object can also plug into the built-in `each` verb by providing its own iterator. `extensions/git/src/each_repo.rb` shows the shape: a plain Ruby class (not a `Gloo::Core::Obj`) with `self.use_for?( iterator_obj )` — which returns `true` when the `each` loop's iterator object looks like a match (here, when it has a `repo` child) — and a `run` method that walks whatever it's iterating over, setting the loop's child value and calling `@iterator_obj.run_do` for each item. See the git extension for the full pattern; this hook only makes sense for extensions that also register a matching object type (here, `git_repo`).

### Documenting the extension

Add `self.doc_data` to every verb/object class (see the `beep` and `stats` examples above) — this is what powers the in-app `help`/`?` shell once the extension is loaded, exactly as it does for built-in verbs and objects (see `lib/gloo/docs/doc_data.rb`). Also add a top-level `README.md` for the extension (usage, `load ext` line, list of verbs/objects, a pointer to `help> verb <name>` / `help> object <name>` for the full reference) — see `extensions/beep/README.md` or `extensions/git/README.md` for the expected shape and length.

### Testing an extension

Add a Ruby unit test per verb/object class under `test/` (mirrors the conventions in the root `CLAUDE.md`'s Test Suites section — inherit from the project's `GlooTest`/`BaseEngineTest` base), and add a `*.test.gloo` integration test that loads the extension and exercises it end to end, e.g. `extensions/beep/test/beep.test.gloo`:

```gloo
tests [can] :
  beep [can] :

    on_load [script] :
      load ext beep

    assert_verb [test] :
      description [string] : The beep verb exists
      on_test [script] :
        exists? verb beep
        assert "beep verb should exist"
        beep
```
