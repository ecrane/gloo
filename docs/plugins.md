# Plugins

## Core Libraries

Core Libraries extend gloo functionality, primarily by adding object types and potentially verbs.

Be sure to load a core library (or extension) prior to loading a gloo file that includes object types defined in the library.

Use the Load Verb to use an extension.

### Available Core Libraries

- **CLI** — Use the `gloo-cli` gem when building CLI applications.
    - Library Objects: Prompt, Colorize, Confirm, Select, Menu, Menu Item
- **Database** — Use the `gloo-db` gem and one or more of `gloo-sqlite`, `gloo-mysql`, `gloo-pg` connector gems.
    - Library Objects: Query, Table, MySQL, SQLite
- **Markdown** — Use the `gloo-md` gem to render markdown.
    - Library Objects: Markdown, Markdown Extensions (part of the markdown object)
- **Test** — Use the `gloo-test` gem to manually include. See Test Runner for notes about the gloo test runner.
    - Library Objects: Test
    - Library Verbs: Assert, Refute
    - See also: Eval, It
- **Web Server** — Use the `gloo-web` gem when building web applications.

---

## User Extensions

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

Use the Load Verb to use an extension.
