# Gloo

## About This Project

gloo is a personal passion project — a custom interpreted programming language
built in Ruby that I've been designing and building over several years. It's
under active, ongoing development, so expect the design (especially around
GUI support) to keep evolving.

This is shared publicly for visibility, not as a maintained open-source
project. I'm not actively seeking contributions right now, but feel free to
open an issue if something's broken or you're curious about the design —
just know response times may be slow.


## Installation

The gloo gem is published on [RubyGems](https://rubygems.org/gems/gloo) and
can be installed with:

```
gem install gloo
```

## Usage

Run gloo:

```
gloo
```

See documentation below, or the in-app help for usage.


## Documentation

Read in order for a guided tour of the language, top to bottom, or jump straight to any page — pages toward the bottom are reference material and read fine out of sequence.

1. [Getting Started](docs/getting_started.md) — prerequisites, installation, hello world, history and concepts
2. [Application](docs/application.md) — running gloo, modes, configuration, logging, the in-app help shell
3. [Language, Objects](docs/language_objects.md) — object naming, keywords, literals, value conversion
4. [Language, Syntax](docs/language_syntax.md) — color, errors, events, system objects, here/it, pathnames
5. [Language, Scripting](docs/language_scripting.md) — script files, constants, line continuation
6. [Objects](docs/objects.md) — a tour of built-in object types (string, container, integer)
7. [Verbs](docs/verbs.md) — a tour of verbs (run, tell, put)
8. [Operators](docs/operators.md) — math and comparison operators
9. [Iterators](docs/iterators.md) — each, repeat
10. [Plugins](docs/plugins.md) — core libraries and user extensions
11. [A Trivial Web App](docs/web_app.md) — a two-page "Hello World" built with the `gloo-web` core library


## License

This project is licensed under the [MIT License](LICENSE.txt) — see
`LICENSE.txt` for details.