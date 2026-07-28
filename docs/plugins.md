# Plugins

### Core Libraries

Core Libraries extend gloo functionality, primarily by adding object types and potentially verbs.

Be sure to load a core library (or extension) prior to loading a gloo file that includes object types defined in the library.

Use the [Load Verb](load.md) to use an extension.

#### Available Core Libraries

- **CLI** — Use the `gloo-cli` gem when building CLI applications.
    - Library Objects: [Prompt](prompt.md), [Colorize](colorize.md), [Confirm](confirm.md), [Select](select.md), [Menu](menu.md), [Menu Item](menu_item.md)
- **Database** — Use the `gloo-db` gem and one or more of `gloo-sqlite`, `gloo-mysql`, `gloo-pg` connector gems.
    - Library Objects: [Query](query.md), [Table](table.md), [MySQL](mysql.md), [SQLite](sqlite.md)
- **Markdown** — Use the `gloo-md` gem to render markdown.
    - Library Objects: [Markdown](markdown.md), [Markdown Extensions](markdown_ext.md) (part of the markdown object)
- **Test** — Use the `gloo-test` gem to manually include. See [Test Runner](test_runner.md) for notes about the gloo test runner.
    - Library Objects: [Test](test.md)
    - Library Verbs: [Assert](assert.md), [Refute](refute.md)
    - See also: [Eval](eval.md), [It](language_syntax.md#it)
- **Web Server** — Use the `gloo-web` gem when building web applications.

---

### User Extensions

A User Extension is a mechanism that can be used to add verbs and objects that are not built into gloo.

Extensions are ruby code that live in the `extensions` folder inside the gloo root folder.

An extension is structured thus:

```
~/gloo/extensions/
  /ext_name
    /doc/
    /src/
    /test/
    /ext_name.rb
```

Be sure to load an extension (or core library) prior to loading a gloo file that includes object types defined in the extension.

Use the [Load Verb](load.md) to use an extension.
