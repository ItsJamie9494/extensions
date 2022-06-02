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
        [GtkChild]
        private unowned Gtk.Stack stack;

        [GtkChild]
        private unowned Adw.StatusPage loader;

        // I always love my easter eggs
        string[] loading_messages = {
            "Hang tight...",
            "Generating witty text...",
            "Swapping time and space...",
            "Flowing the bits...",
            "Reticulating splines...",
            "Spinning the wheel of fortune...",
            "Computing chances of success...",
            "Adjusting the flux capacitor...",
            "Keeping all the 1's and removing all the 0's...",
            "Creating time-loop inversion field...",
            "Cleaning off the cobwebs...",
            "Connecting Neurotoxin Storage Tank...",
            "Convincing AI not to turn evil...",
            "Dividing by zero...",
            "Twiddling thumbs...",
            "Downloading more RAM...",
            "Mining some bitcoins...",
        };

        [GtkCallback]
        public void on_realise () {
            loader.set_description (loading_messages[GLib.Random.int_range (0, loading_messages.length)]);

            SoupClient.get_default ().get_extensions.begin ((obj, res) => {
                try {
                    Json.Array extensions = SoupClient.get_default ().get_extensions.end (res);
                    ThreadService.run_in_thread.begin<void> (() => {
                        extensions.get_elements ().foreach ((node) => {
                            if (node.get_node_type () == Json.NodeType.OBJECT) {
                                ExploreExtensionObject extension_obj = new ExploreExtensionObject (node.get_object ());
                                box.append (new ExploreRow (extension_obj));
                            }
                        });
                        stack.set_visible_child_name ("content");
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
