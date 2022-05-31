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
                        rows.insert (extension, new Row (extension, variant));
                        system_box.append (rows.lookup (extension));
                    } else {
                        rows.insert (extension, new Row (extension, variant));
                        user_box.append (rows.lookup (extension));
                    }
                });
            } catch (GLib.Error e) {
                print ("%s\n", e.message);
            }

            enabledSwitch.set_active (Application.dbus_extensions.user_extensions_enabled);
        }
    }
}
