# A Trivial Web App

**Contents**

- Overview
- File and Folder Layout
- start.gloo
- app/app.gloo
- layout/primary.gloo
- shared/nav.gloo
- page/home.gloo
- page/about.gloo
- Running It
- Where To Go From Here

## Overview

This walks through the smallest complete gloo web app: a "Hello World" with two pages (`home` and `about`) sharing a common layout and nav bar. It uses the `gloo-web` core library — see Plugins for how core libraries are installed and loaded in general.

The app runs in App Mode (`gloo --app {path}`, see Application) — gloo looks for a `start.gloo` file at the root of the app folder and runs it. That file loads everything else and starts the web server.

## File and Folder Layout

```
hello/
  start.gloo
  app/
    app.gloo
  layout/
    primary.gloo
  shared/
    nav.gloo
  page/
    home.gloo
    about.gloo
```

- `start.gloo` — the entry point. Loads the `web` core library, then everything under `app/`, `layout/`, `shared/`, and `page/`, then starts the server.
- `app/app.gloo` — the `app` object: the app's URL and its `svr` (web server), including server config and the default routes (layout, home page).
- `layout/primary.gloo` — the page layout shared by every page: the HTML shell, the nav bar, and where a page's own head/body content gets inserted.
- `shared/nav.gloo` — a partial (reusable fragment) for the nav bar, included by the layout.
- `page/home.gloo`, `page/about.gloo` — the two pages. Every `[page]` object loaded under the root `page` container automatically becomes a route: `page.home` answers `/`, `page.about` answers `/about`. Routes are wired up by the router when the server starts — there's no separate routing table to maintain by hand.

## start.gloo

```gloo
#
# Start the hello app.
#
# Run it:
#   gloo --app ~/gloo/projects/apps/hello
#

start [container] :

  on_load [script] :

    # Load the web core library.
    load lib web

    # Load the app's own objects.
    load app/*
    load layout/*
    load shared/*
    load page/*

    # Start the server and open it in a browser.
    tell app.svr to start
    tell app.url to open
```

## app/app.gloo

```gloo
#
# The hello app: web server config and default routes.
#

app [can] :

  # The app's URL.
  url [uri] : http://localhost:8080/

  # The web server for the app.
  svr [svr] :

    config [container] :
      scheme [string] : http
      host [string] : localhost
      port [string] : 8080

    on_start [script] : show 'hello app started'
    on_stop [script] : show 'hello app stopped'

    # Default layout and home page.
    layout [alias] : layout.primary
    home [alias] : page.home
```

`svr` is a `gloo-web` object type (see Plugins — Core Libraries). `layout` and `home` are conventional aliases: `layout` points at the partial used to wrap every page that doesn't specify its own, and `home` points at the page served for `/`. A real app would also set `error [alias] : page.err` to control the page shown on a server error, but it's optional — gloo falls back to a generic message if it's not set.

## layout/primary.gloo

```gloo
#
# The shared page layout: HTML shell + nav bar.
# Every page renders inside this unless it specifies its own layout.
#

layout [can] :
  primary [part] :
    content [can] :

      html_open [text] : BEGIN
<!DOCTYPE html>
<html lang="en">
<head>
  <%= head %>
</head>
<body>
END

      nav [alias] : shared.nav
      body [string] : <%= body %>

      html_close [text] : BEGIN
</body>
</html>
END
```

`primary` is a `[part]` (partial) — see Plugins for the `gloo-web` object list. `<%= head %>` and `<%= body %>` are filled in automatically by the page being rendered: whatever that page defines under its own `head` and `body` children. `nav` is an alias to the shared nav partial below, rendered inline wherever it appears in the layout's content.

## shared/nav.gloo

```gloo
#
# The shared nav bar, included by the layout.
#

shared [can] :
  nav [part] :
    content [text] : BEGIN
<nav>
  <a href="/">Home</a>
  <a href="/about">About</a>
</nav>
END
```

## page/home.gloo

```gloo
#
# The home page ("/").
#

page [can] :
  home [page] :

    params [can] :
      msg [string] : Hello, World!

    head [e] :
      content [can] :
        title [e] : Hello

    body [e] :
      content [can] :
        h1 [e] : <%= msg %>
        p [e] : This is the home page.
```

`page.home` is what `app.svr.home` points to, so it answers requests to `/`. `params` declares values the page's content can reference — here just `msg`, used in the `<h1>` via `<%= msg %>`. `head` and `title` and `body`, `h1`, `p` are `[e]` (element) objects — see Plugins — the building blocks the layout's `<%= head %>`/`<%= body %>` render.

## page/about.gloo

```gloo
#
# The about page ("/about"), reached by name automatically —
# no routing table entry required.
#

page [can] :
  about [page] :

    head [e] :
      content [can] :
        title [e] : About

    body [e] :
      content [can] :
        h1 [e] : About
        p [e] : A trivial two-page gloo web app.
```

Because this page is named `about` and lives directly under the root `page` container, it's automatically routed to `/about` the moment the server starts — see File and Folder Layout above.

## Running It

```shell
 gloo --app ~/gloo/projects/apps/hello
```

This runs `start.gloo`, which starts the server and opens `http://localhost:8080/` in a browser. Visit `/about` to see the second page. Stop the app the same way as any other gloo app (`q` at the prompt, or `Ctrl-C`).

Once the app is running, `gloo-web`'s objects (`page`, `part`, `e`, `svr`, `form`, `field`) are all documented in-app — `help> object page`, etc. — see Plugins.

## Where To Go From Here

This example deliberately leaves out most of what `gloo-web` supports: forms and fields (`form`, `field`), page parameters populated from query strings, sessions, static assets (images/CSS/JS served from an `asset/` folder, with `image_tag`/`css_tag`/`js_tag` layout helpers), a database-backed page (`gloo-db` plus a `sqlite`/`mysql`/`postgres` driver — see Plugins), and a dedicated error page. Each of those follows the same shape shown here: an object type from `gloo-web` (or another core library), loaded the same way, documented the same way in `help`.
