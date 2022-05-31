sources = [
  'application.vala',
  'window.vala',
  'widgets/row.vala',
  'services/dbus_extensions_service.vala',
]

deps = [
  dependency('libadwaita-1', version: '>= 1.0'),
  dependency('gio-2.0'),
]

gnome = import('gnome')

executable(
    'extensions',
    sources,
    asresources,
    vala_args: '--target-glib=2.50',
    dependencies: deps,
    install: true,
)
