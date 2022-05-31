/* widgets/more_info.vala
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
    [GtkTemplate (ui = "/dev/itsjamie9494/Extensions/more-info.ui")]
    public class MoreInfoDialog : Gtk.Window {
        [GtkChild]
        private unowned Gtk.Label header;
        [GtkChild]
        private unowned Gtk.Label uuidLabel;
        [GtkChild]
        private unowned Gtk.Label pathLabel;
        [GtkChild]
        private unowned Gtk.Label urlLabel;
        [GtkChild]
        private unowned Gtk.Label versionLabel;
        [GtkChild]
        private unowned Gtk.Label stateLabel;
        [GtkChild]
        private unowned Gtk.Label descLabel;

        [GtkCallback]
        public void on_close () {
            this.close ();
        }

        public string get_human_readable_state (double state) {
            switch ((int) state) {
                case 1:
                  return "ENABLED";
                case 2:
                  return "DISABLED";
                case 3:
                  return "ERROR";
                case 4:
                  return "OUT OF DATE";
                case 5:
                  return "DOWNLOADING";
                case 6:
                  return "INITIALIZED";
                case 99:
                  return "UNINSTALLED";
                default:
                  return "UNKNOWN";
            }
        }

        public MoreInfoDialog (string uuid) {
            Object ();

            // TODO do shit with the header and all that
            try {
                var variant = Application.dbus_extensions.get_extension_info (uuid);
                header.set_label (variant.lookup ("name").get_string ());
                uuidLabel.set_label (uuid);
                pathLabel.set_label (variant.lookup ("path").get_string ());
                urlLabel.set_label (variant.lookup ("url").get_string ());
                if (variant.lookup ("version") != null) {
                    versionLabel.set_label (variant.lookup ("version").get_double ().to_string ());
                }
                stateLabel.set_label (get_human_readable_state (variant.lookup ("state").get_double ()));
                descLabel.set_label ("TODO make this not overflow lol");
            } catch (GLib.Error e) {
                print ("%s\n", e.message);
            }
        }
    }
}
