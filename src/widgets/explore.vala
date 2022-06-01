/* widgets/explore.vala
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
    public class Explore : Adw.Bin {
        [GtkChild]
        private unowned Gtk.FlowBox box;

        [GtkCallback]
        public void on_realise () {
            SoupClient.get_default ().get_extensions.begin ((obj, res) => {
                try {
                    Json.Array extensions = SoupClient.get_default ().get_extensions.end (res);
                    extensions.get_elements ().foreach ((node) => {
                        if (node.get_node_type () == Json.NodeType.OBJECT) {
                            ExploreExtensionObject extension_obj = new ExploreExtensionObject (node.get_object ());
                            box.append (new ExploreRow (extension_obj));
                        }
                    });
                } catch (SoupError e) {
                    print ("%s\n", e.message);
                }
            });
        }

        [GtkCallback]
        public void on_click (Gtk.FlowBoxChild fb_child) {
            var ext_child = fb_child.get_child ();
            if (ext_child.get_type () == typeof (ExploreRow)) {
                Application.main_window.open_details (((ExploreRow) ext_child).extension);
            }
        }

        public Explore () {
            Object ();
        }
    }
}
