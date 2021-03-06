# Extensions

Manage and find new GNOME extensions.

## Building

You'll need the following dependencies:

> *Note*: This dependency list is the names searched for by `pkg-config`. Depending on your distribution, you may need to install other packages (for example, `gtk4-devel` on Fedora)

- `meson`
- `valac`
- `gtk4`
- `libadwaita-1`
- `gee-0.8`
- `json-glib-1.0`,
- `libsoup-3.0`,
- `gio-2.0`

Run `meson build` to configure the build environment. Change to the build directory and run `ninja test` to build and run automated tests.

```bash
$ meson build --prefix=/usr
$ cd build
$ ninja test
```

For debug messages, set the `G_MESSAGES_DEBUG` environment variable, e.g. to `all`:

```bash
G_MESSAGES_DEBUG=all ./src/extensions
```

## Installing

To install, use `ninja install`, then execute with `extensions`.

```bash
$ sudo ninja install
$ extensions
```


