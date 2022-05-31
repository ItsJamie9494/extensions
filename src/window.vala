/* window.vala
 *
 * Copyright 2022 Jamie Murphy
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Extensions {
    [GtkTemplate (ui = "/dev/itsjamie9494/Extensions/window.ui")]
    public class Window : Adw.ApplicationWindow {
        [GtkChild]
        private unowned Gtk.ListBox user_box;
        [GtkChild]
        private unowned Gtk.ListBox system_box;
        [GtkChild]
        private unowned Gtk.Switch enabledSwitch;

        public GLib.HashTable<string, Row> rows = new GLib.HashTable<string, Row> (str_hash, str_equal);

        [GtkCallback]
        public bool user_extensions_set (bool state) {
            Application.dbus_extensions.user_extensions_enabled = state;

            rows.foreach ((uuid, row) => {
                row.set_extension_global_state (state);
            });
            return false;
        }

        public Window (Adw.Application app) {
            Object (application: app);

            try {
                Application.dbus_extensions.list_extensions ().foreach ((extension, variant) => {
                    if (variant.lookup ("type").get_double () == 1.0) {
                        var row = new Row (extension, variant);
                        row.remove_extension_rows.connect ((uuid) => {
                            var ext = rows.lookup (uuid);
                            rows.remove (uuid);
                            if (ext.is_system_extension ()) {
                                system_box.remove (ext);
                                ext.unparent ();
                                ext.destroy ();
                            } else {
                                user_box.remove (ext);
                                ext.unparent ();
                                ext.destroy ();
                            }
                        });
                        rows.insert (extension, row);
                        system_box.append (rows.lookup (extension));
                    } else {
                        var row = new Row (extension, variant);
                        row.remove_extension_rows.connect ((uuid) => {
                            var ext = rows.lookup (uuid);
                            rows.remove (uuid);
                            if (ext.is_system_extension ()) {
                                system_box.remove (ext);
                                ext.unparent ();
                                ext.destroy ();
                            } else {
                                user_box.remove (ext);
                                ext.unparent ();
                                ext.destroy ();
                            }
                        });
                        rows.insert (extension, row);
                        user_box.append (rows.lookup (extension));
                    }
                });
            } catch (GLib.Error e) {
                print ("%s\n", e.message);
            }

            Application.dbus_extensions.extension_state_changed.connect ((uuid) => {
               if (!rows.contains (uuid)) {
                    try {
                        var variant = Application.dbus_extensions.get_extension_info (uuid);
                        if (variant.size () == 0) {
                            return;
                        } else if (variant.lookup ("type").get_double () == 1.0) {
                            var row = new Row (uuid, variant);
                            row.remove_extension_rows.connect ((uuid) => {
                                var ext = rows.lookup (uuid);
                                rows.remove (uuid);
                                if (ext.is_system_extension ()) {
                                    system_box.remove (ext);
                                    ext.unparent ();
                                    ext.destroy ();
                                } else {
                                    user_box.remove (ext);
                                    ext.unparent ();
                                    ext.destroy ();
                                }
                            });
                            rows.insert (uuid, row);
                            system_box.append (rows.lookup (uuid));
                        } else {
                            var row = new Row (uuid, variant);
                            row.remove_extension_rows.connect ((uuid) => {
                                var ext = rows.lookup (uuid);
                                rows.remove (uuid);
                                if (ext.is_system_extension ()) {
                                    system_box.remove (ext);
                                    ext.unparent ();
                                    ext.destroy ();
                                } else {
                                    user_box.remove (ext);
                                    ext.unparent ();
                                    ext.destroy ();
                                }
                            });
                            rows.insert (uuid, row);
                            user_box.append (rows.lookup (uuid));
                        }
                    } catch (GLib.Error e) {
                        print ("%s\n", e.message);
                    }
               }
            });

            enabledSwitch.set_active (Application.dbus_extensions.user_extensions_enabled);
        }
    }
}
