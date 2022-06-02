/* widgets/row.vala
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
    [GtkTemplate (ui = "/dev/itsjamie9494/Extensions/row.ui")]
    public class Row : Gtk.ListBoxRow {
        [GtkChild]
        private unowned Gtk.Label nameLabel;
        [GtkChild]
        private unowned Gtk.Label versionLabel;
        [GtkChild]
        private unowned Gtk.Label descriptionLabel;
        [GtkChild]
        private unowned Gtk.Switch enabledSwitch;
        [GtkChild]
        private unowned Gtk.Image updatesIcon;
        [GtkChild]
        private unowned Gtk.Image errorIcon;
        [GtkChild]
        private unowned Gtk.Label errorLabel;
        [GtkChild]
        private unowned Gtk.Button prefsButton;
        [GtkChild]
        private unowned Gtk.Button removeButton;
        
        private string url;
        private string uuid;
        private double global_state;
        private bool system;
        
        private bool should_set_state = true;

        public signal void remove_extension_rows (string uuid);

        [GtkCallback]
        public void open_more_info () {
            var dialog = new Extensions.MoreInfoDialog (uuid);
            dialog.set_transient_for (Application.main_window);
            dialog.present ();
        }

        [GtkCallback]
        public void open_website () {
            Gtk.show_uri_full.begin (null, url, Gdk.CURRENT_TIME, null);
        }
        
        [GtkCallback]
        public void open_preferences () {
            try {
                HashTable<string, GLib.Variant> options_tbl = new HashTable<string, GLib.Variant> (str_hash, str_equal);
                options_tbl.insert ("modal", true);
                Application.dbus_extensions.open_extension_prefs (uuid, "dev.itsjamie9494.Extensions", options_tbl);
            } catch (GLib.Error e) {
                print ("%s\n", e.message);
            }
        }
        
        [GtkCallback]
        public bool set_extension_state (bool state) {
            if (should_set_state) {
                try {
                    if (state == true) {
                        Application.dbus_extensions.enable_extension (uuid);
                    } else {
                        Application.dbus_extensions.disable_extension (uuid);
                    }
                } catch (GLib.Error e) {
                    print ("%s\n", e.message);
                }
            }
            
            return false;
        }
        
        [GtkCallback]
        public void remove_extension () {
            try {
                bool success = Application.dbus_extensions.uninstall_extension (uuid);
                if (success) {
                    remove_extension_rows (uuid);
                }
            } catch (GLib.Error e) {
                print ("%s\n", e.message);
            }
        }

        public Row (string in_uuid, GLib.HashTable<string, GLib.Variant> variant) {
            Object ();
            uuid = in_uuid;
            url = variant.lookup ("url").get_string ();
            global_state = variant.lookup ("state").get_double ();
            

            if (Application.dbus_extensions.user_extensions_enabled == false) {
                enabledSwitch.set_sensitive (false);
            } if (Application.dbus_extensions.user_extensions_enabled == true) {
                enabledSwitch.set_sensitive (true);
            }
            
            nameLabel.set_label (variant.lookup ("name").get_string ());
            if (variant.lookup ("version") != null) {
                versionLabel.set_label (variant.lookup ("version").get_double ().to_string ());
                versionLabel.set_visible (true);
            }
            descriptionLabel.set_label (variant.lookup ("description").get_string ());
            if (variant.lookup ("state").get_double () == 1.0) {
                enabledSwitch.set_active (true);
                enabledSwitch.set_sensitive (true);
            }
            if (variant.lookup ("state").get_double () == 3.0) {
                errorIcon.set_visible (true);
                errorLabel.set_label (variant.lookup ("error").get_string ());
                errorLabel.set_visible (true);
                enabledSwitch.set_sensitive (false);
            }
            if (variant.lookup ("hasUpdate").get_boolean () == true || variant.lookup ("state").get_double () == 4.0) {
                updatesIcon.set_visible (true);
            }
            if (variant.lookup ("hasPrefs").get_boolean () == true) {
                prefsButton.set_sensitive (true);
            }
            if (variant.lookup ("type").get_double () == 1.0) {
                system = true;
                removeButton.set_sensitive (false);
            } else if (variant.lookup ("type").get_double () == 2.0) {
                removeButton.set_sensitive (true);
                system = false;
            }

            Application.dbus_extensions.extension_state_changed.connect ((uuid, state) => {
                if (uuid == in_uuid) {
                    global_state = state.lookup ("state").get_double ();
                    if (global_state == 1.0) {
                        enabledSwitch.set_active (true);
                        enabledSwitch.set_sensitive (true);
                    } else {
                        enabledSwitch.set_active (false);
                    }
                }
            });
        }

        public void set_extension_global_state (bool state) {
            if (state == false) {
                enabledSwitch.set_sensitive (false);
                should_set_state = false;
                enabledSwitch.set_active (false);
            } else if (state == true) {
                enabledSwitch.set_sensitive (true);
                if (global_state == 1.0) {
                    enabledSwitch.set_active (true);
                }
                should_set_state = true;
            }
        }

        public bool is_system_extension () {
            return system;
        }
    }
}
