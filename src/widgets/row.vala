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
        
        private string url;
        private string uuid;
        
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
        
        public Row (string in_uuid, GLib.HashTable<string, GLib.Variant> variant) {
            Object ();
            uuid = in_uuid;
            
            url = variant.lookup ("url").get_string ();
            
            foreach (var extension in variant.get_keys ()) {
                print (extension.to_string () + "\n");
            }
            
            nameLabel.set_label (variant.lookup ("name").get_string ());
            if (variant.lookup ("version") != null) {
                versionLabel.set_label (variant.lookup ("version").get_double ().to_string ());
                versionLabel.set_visible (true);
            }
            descriptionLabel.set_label (variant.lookup ("description").get_string ());
            if (variant.lookup ("state").get_double () == 1.0) {
                enabledSwitch.set_active (true);
            }
            if (variant.lookup ("state").get_double () == 3.0) {
                errorIcon.set_visible (true);
                errorLabel.set_label (variant.lookup ("error").get_string ());
            }
            if (variant.lookup ("hasUpdate").get_boolean () == true) {
                updatesIcon.set_visible (true);
            }
            if (variant.lookup ("hasPrefs").get_boolean () == true) {
                prefsButton.set_sensitive (true);
            }
        }
    }
}
