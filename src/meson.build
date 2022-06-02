sources = [
  'application.vala',
  'window.vala',
  'widgets/row.vala',
  'widgets/more_info.vala',
  'widgets/explore.vala',
  'widgets/explore_row.vala',
  'widgets/details.vala',
  'services/dbus_extensions_service.vala',
  'services/soup_client_service.vala',
  'services/thread_service.vala',
  'objects/explore_extension_object.vala'
]

deps = [
  dependency('libadwaita-1', version: '>= 1.0'),
  dependency('gio-2.0'),
  dependency('json-glib-1.0'),
  dependency('libsoup-3.0')
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
