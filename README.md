# [DevDocs](https://devdocs.io) — API Documentation Browser [![Build Status](https://travis-ci.org/freeCodeCamp/devdocs.svg?branch=master)](https://travis-ci.org/freeCodeCamp/devdocs)

DevDocs combines multiple developer documentations in a clean and organized web UI with instant search, offline support, mobile version, dark theme, keyboard shortcuts, and more.

DevDocs was created by [Thibaut Courouble](https://thibaut.me) and is operated by [freeCodeCamp](https://www.freecodecamp.org).

## We are currently searching for maintainers

Please reach out to the community on [Gitter](https://gitter.im/FreeCodeCamp/DevDocs) if you would like to join the team!

Keep track of development news:

* Join the contributor chat room on [Gitter](https://gitter.im/FreeCodeCamp/DevDocs)
* Watch the repository on [GitHub](https://github.com/freeCodeCamp/devdocs/subscription)
* Follow [@DevDocs](https://twitter.com/DevDocs) on Twitter

**Table of Contents:** [Quick Start](#quick-start) · [Vision](#vision) · [App](#app) · [Scraper](#scraper) · [Commands](#available-commands) · [Contributing](#contributing) · [Documentation](#documentation) · [Related Projects](#related-projects) · [License](#copyright--license) · [Questions?](#questions)

## Quick Start

Unless you wish to contribute to the project, we recommend using the hosted version at [devdocs.io](https://devdocs.io). It's up-to-date and works offline out-of-the-box.

DevDocs is made of two pieces: a Ruby scraper that generates the documentation and metadata, and a JavaScript app powered by a small Sinatra app.

DevDocs requires Ruby 2.6.x, libcurl, and a JavaScript runtime supported by [ExecJS](https://github.com/rails/execjs#readme) (included in OS X and Windows; [Node.js](https://nodejs.org/en/) on Linux). Once you have these installed, run the following commands:

```
git clone https://github.com/freeCodeCamp/devdocs.git && cd devdocs
gem install bundler
bundle install
bundle exec thor docs:download --default
bundle exec rackup
```

Finally, point your browser at [localhost:9292](http://localhost:9292) (the first request will take a few seconds to compile the assets). You're all set.

The `thor docs:download` command is used to download pre-generated documentations from DevDocs's servers (e.g. `thor docs:download html css`). You can see the list of available documentations and versions by running `thor docs:list`. To update all downloaded documentations, run `thor docs:download --installed`.

**Note:** there is currently no update mechanism other than `git pull origin master` to update the code and `thor docs:download --installed` to download the latest version of the docs. To stay informed about new releases, be sure to [watch](https://github.com/freeCodeCamp/devdocs/subscription) this repository.

Alternatively, DevDocs may be started as a Docker container:

```
# First, build the image
git clone https://github.com/freeCodeCamp/devdocs.git && cd devdocs
docker build -t thibaut/devdocs .

# Finally, start a DevDocs container (access http://localhost:9292)
docker run --name devdocs -d -p 9292:9292 thibaut/devdocs
```

## Vision

DevDocs aims to make reading and searching reference documentation fast, easy and enjoyable.

The app's main goals are to: keep load times as short as possible; improve the quality, speed, and order of search results; maximize the use of caching and other performance optimizations; maintain a clean and readable user interface; be fully functional offline; support full keyboard navigation; reduce “context switch” by using a consistent typography and design across all documentations; reduce clutter by focusing on a specific category of content (API/reference) and indexing only the minimum useful to most developers.

**Note:** DevDocs is neither a programming guide nor a search engine. All our content is pulled from third-party sources and the project doesn't intend to compete with full-text search engines. Its backbone is metadata; each piece of content is identified by a unique, "obvious" and short string. Tutorials, guides and other content that don't meet this requirement are outside the scope of the project.

## App

The web app is all client-side JavaScript, written in [CoffeeScript](http://coffeescript.org), and powered by a small [Sinatra](http://www.sinatrarb.com)/[Sprockets](https://github.com/rails/sprockets) application. It relies on files generated by the [scraper](#scraper).

Many of the code's design decisions were driven by the fact that the app uses XHR to load content directly into the main frame. This includes stripping the original documents of most of their HTML markup (e.g. scripts and stylesheets) to avoid polluting the main frame, and prefixing all CSS class names with an underscore to prevent conflicts.

Another driving factor is performance and the fact that everything happens in the browser. A service worker (which comes with its own set of constraints) and `localStorage` are used to speed up the boot time, while memory consumption is kept in check by allowing the user to pick his/her own set of documentations. The search algorithm is kept simple because it needs to be fast even searching through 100,000 strings.

DevDocs being a developer tool, the browser requirements are high:

* Recent versions of Firefox, Chrome, or Opera
* Safari 11.1+
* Edge 17+
* iOS 11.3+

This allows the code to take advantage of the latest DOM and HTML5 APIs and make developing DevDocs a lot more fun!

## Scraper

The scraper is responsible for generating the documentation and index files (metadata) used by the [app](#app). It's written in Ruby under the `Docs` module.

There are currently two kinds of scrapers: `UrlScraper` which downloads files via HTTP and `FileScraper` which reads them from the local filesystem. They both make copies of HTML documents, recursively following links that match a set of rules and applying all sorts of modifications along the way, in addition to building an index of the files and their metadata. Documents are parsed using [Nokogiri](http://nokogiri.org).

Modifications made to each document include:

* removing content such as the document structure (`<html>`, `<head>`, etc.), comments, empty nodes, etc.
* fixing links (e.g. to remove duplicates)
* replacing all external (not scraped) URLs with their fully qualified counterpart
* replacing all internal (scraped) URLs with their unqualified and relative counterpart
* adding content, such as a title and link to the original document
* ensuring correct syntax highlighting using [Prism](http://prismjs.com/)

These modifications are applied via a set of filters using the [HTML::Pipeline](https://github.com/jch/html-pipeline) library. Each scraper includes filters specific to itself, one of which is tasked with figuring out the pages' metadata.

The end result is a set of normalized HTML partials and two JSON files (index + offline data). Because the index files are loaded separately by the [app](#app) following the user's preferences, the scraper also creates a JSON manifest file containing information about the documentations currently available on the system (such as their name, version, update date, etc.).

More information about [scrapers](./docs/scraper-reference.md) and [filters](./docs/filter-reference.md) is available in the `docs` folder.

The [JSON Schema](https://json-schema.org/) for a documentation and its metadata is provided in https://github.com/freeCodeCamp/devdocs/tree/master/public/schema.

## Available Commands

The command-line interface uses [Thor](http://whatisthor.com). To see all commands and options, run `thor list` from the project's root.

```
# Server
rackup              # Start the server (ctrl+c to stop)
rackup --help       # List server options

# Docs
thor docs:list      # List available documentations
thor docs:download  # Download one or more documentations
thor docs:manifest  # Create the manifest file used by the app
thor docs:generate  # Generate/scrape a documentation
thor docs:page      # Generate/scrape a documentation page
thor docs:package   # Package a documentation for use with docs:download
thor docs:clean     # Delete documentation packages

# Console
thor console        # Start a REPL
thor console:docs   # Start a REPL in the "Docs" module
Note: tests can be run quickly from within the console using the "test" command. Run "help test"
for usage instructions.

# Tests
thor test:all       # Run all tests
thor test:docs      # Run "Docs" tests
thor test:app       # Run "App" tests

# Assets
thor assets:compile # Compile assets (not required in development mode)
thor assets:clean   # Clean old assets
```

If multiple versions of Ruby are installed on your system, commands must be run through `bundle exec`.

## Contributing

Contributions are welcome. Please read the [contributing guidelines](./.github/CONTRIBUTING.md).

## Documentation

* [Adding documentations to DevDocs](./docs/adding-docs.md)
* [Scraper Reference](./docs/scraper-reference.md)
* [Filter Reference](./docs/filter-reference.md)
* [Maintainers’ Guide](./docs/maintainers.md)

## Related Projects

Made something cool? Feel free to open a PR to add a new row to this table!

| Project                                                                                                 | Description                                                            | Last commit                                                                                                                                                                |
|---------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [Chrome web app](https://chrome.google.com/webstore/detail/devdocs/mnfehgbmkapmjnhcnbodoamcioleeooe)    | Chrome Web App which adds a shortcut to DevDocs apps page.             | N/A                                                                                                                                                                        |
| [Ubuntu Touch app](https://uappexplorer.com/app/devdocsunofficial.berkes)                               | Application for devices running Ubuntu Touch.                          | N/A                                                                                                                                                                        |
| [Sublime Text plugin](https://sublime.wbond.net/packages/DevDocs)                                       | Sublime Text plugin to search DevDocs by selection or by input.        | [![Latest GitHub commit](https://img.shields.io/github/last-commit/vitorbritto/sublime-devdocs?logo=github&label)](https://github.com/vitorbritto/sublime-devdocs)         |
| [Atom plugin](https://atom.io/packages/devdocs)                                                         | Atom plugin adding the `doc` command to search DevDocs.                | [![Latest GitHub commit](https://img.shields.io/github/last-commit/masnun/atom-devdocs?logo=github&label)](https://github.com/masnun/atom-devdocs)                         |
| [gruehle/dev-docs-viewer](https://github.com/gruehle/dev-docs-viewer)                                   | Brackets extension for searching and viewing DevDocs content.          | [![Latest GitHub commit](https://img.shields.io/github/last-commit/gruehle/dev-docs-viewer?logo=github&label)](https://github.com/gruehle/dev-docs-viewer)                 |
| [naquad/devdocs-shell](https://github.com/naquad/devdocs-shell)                                         | GTK shell with Vim integration.                                        | [![Latest GitHub commit](https://img.shields.io/github/last-commit/naquad/devdocs-shell?logo=github&label)](https://github.com/naquad/devdocs-shell)                       |
| [skeeto/devdocs-lookup](https://github.com/skeeto/devdocs-lookup)                                       | Quick Emacs API lookup on DevDocs.                                     | [![Latest GitHub commit](https://img.shields.io/github/last-commit/skeeto/devdocs-lookup?logo=github&label)](https://github.com/skeeto/devdocs-lookup)                     |
| [yannickglt/alfred-devdocs](https://github.com/yannickglt/alfred-devdocs)                               | Alfred workflow for DevDocs.                                           | [![Latest GitHub commit](https://img.shields.io/github/last-commit/yannickglt/alfred-devdocs?logo=github&label)](https://github.com/yannickglt/alfred-devdocs)             |
| [waiting-for-dev/vim-www](https://github.com/waiting-for-dev/vim-www)                                   | Vim search plugin with DevDocs in its defaults.                        | [![Latest GitHub commit](https://img.shields.io/github/last-commit/waiting-for-dev/vim-www?logo=github&label)](https://github.com/waiting-for-dev/vim-www)                 |
| [vscode-devdocs for VS Code](https://marketplace.visualstudio.com/items?itemName=akfish.vscode-devdocs) | VS Code plugin to open and search DevDocs inside VS Code.              | [![Latest GitHub commit](https://img.shields.io/github/last-commit/akfish/vscode-devdocs?logo=github&label)](https://github.com/akfish/vscode-devdocs)                     |
| [devdocs for VS Code](https://marketplace.visualstudio.com/items?itemName=deibit.devdocs)               | VS Code plugin to open the browser to search selected text on DevDocs. | [![Latest GitHub commit](https://img.shields.io/github/last-commit/deibit/vscode-devdocs?logo=github&label)](https://github.com/deibit/vscode-devdocs)                     |
| [egoist/devdocs-desktop](https://github.com/egoist/devdocs-desktop)                                     | Cross-platform desktop application for DevDocs.                        | [![Latest GitHub commit](https://img.shields.io/github/last-commit/egoist/devdocs-desktop?logo=github&label)](https://github.com/egoist/devdocs-desktop)                   |
| [qwfy/doc-browser](https://github.com/qwfy/doc-browser)                                                 | Native Linux app that supports DevDocs docsets.                        | [![Latest GitHub commit](https://img.shields.io/github/last-commit/qwfy/doc-browser?logo=github&label)](https://github.com/qwfy/doc-browser)                               |
| [hardpixel/devdocs-desktop](https://github.com/hardpixel/devdocs-desktop)                               | GTK3 application for DevDocs with search integrated in the headerbar.  | [![Latest GitHub commit](https://img.shields.io/github/last-commit/hardpixel/devdocs-desktop?logo=github&label)](https://github.com/hardpixel/devdocs-desktop)             |
| [dteoh/devdocs-macos](https://github.com/dteoh/devdocs-macos)                                           | Native macOS application for DevDocs.                                  | [![Latest GitHub commit](https://img.shields.io/github/last-commit/dteoh/devdocs-macos?logo=github&label)](https://github.com/dteoh/devdocs-macos)                         |
| [Merith-TK/devdocs_webapp_kotlin](https://github.com/Merith-TK/devdocs_webapp_kotlin)                   | Android application which shows DevDocs in a webview.                  | [![Latest GitHub commit](https://img.shields.io/github/last-commit/Merith-TK/devdocs_webapp_kotlin?logo=github&label)](https://github.com/Merith-TK/devdocs_webapp_kotlin) |

## Copyright / License

Copyright 2013-2020 Thibaut Courouble and [other contributors](https://github.com/freeCodeCamp/devdocs/graphs/contributors)

This software is licensed under the terms of the Mozilla Public License v2.0. See the [COPYRIGHT](./COPYRIGHT) and [LICENSE](./LICENSE) files.

Please do not use the name DevDocs to endorse or promote products derived from this software without the maintainers' permission, except as may be necessary to comply with the notice/attribution requirements.

We also wish that any documentation file generated using this software be attributed to DevDocs. Let's be fair to all contributors by giving credit where credit's due. Thanks!

## Questions?

If you have any questions, please feel free to ask them on the contributor chat room on [Gitter](https://gitter.im/FreeCodeCamp/DevDocs).
