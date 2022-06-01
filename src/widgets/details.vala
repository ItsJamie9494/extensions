/* widgets/details.vala
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
    [GtkTemplate (ui = "/dev/itsjamie9494/Extensions/explore.ui")]
    public class Details : Adw.Bin {
        [GtkChild]
        private unowned Gtk.Image details_icon;
        [GtkChild]
        private unowned Gtk.Label details_title;
        [GtkChild]
        private unowned Gtk.Label developer_name;

        public Details () {
            Object ();
        }

        construct {
            this.realize.connect (() => {
                Application.main_window.set_details_content.connect ((extension) => {
                    details_title.set_label (extension.name);
                    extension.get_gicon.begin ((obj, res) => {
                        details_icon.set_from_pixbuf (extension.get_gicon.end (res));
                    });
                    developer_name.set_label (extension.creator);
                });
            });
        }
    }
}
