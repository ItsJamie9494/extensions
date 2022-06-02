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
        [GtkChild]
        private unowned Adw.Leaflet leaflet;
        [GtkChild]
        private unowned Adw.WindowTitle details_title;

        [GtkChild]
        private unowned Gtk.SearchBar search_bar;
        [GtkChild]
        private unowned Gtk.SearchEntry entry_search;
        [GtkChild]
        private unowned Gtk.ToggleButton search_button;

        public GLib.HashTable<string, Row> rows = new GLib.HashTable<string, Row> (str_hash, str_equal);
        public signal void set_details_content (ExploreExtensionObject obj);
        public signal void explore_loaded ();

        [GtkCallback]
        public void search_bar_search_mode_enabled_changed_cb (Object source, GLib.ParamSpec pspec) {
            // var child = main_stack.get_visible_child_name ();

            // I want to provide transitions but until I nail the timing, nah
            // if (child != "search_shell") {
            //     search_view.reset ();
                //  main_stack.set_transition_type (Gtk.StackTransitionType.OVER_DOWN);
            //     main_stack.set_visible_child_name ("search_shell");
            // } else {
                //  main_stack.set_transition_type (Gtk.StackTransitionType.UNDER_DOWN);
            //     main_stack.set_visible_child_name ("main_shell");
            // }
        }

        [GtkCallback]
        public bool user_extensions_set (bool state) {
            Application.dbus_extensions.user_extensions_enabled = state;

            rows.foreach ((uuid, row) => {
                row.set_extension_global_state (state);
            });
            return false;
        }

        [GtkCallback]
        public void back_clicked () {
            leaflet.navigate (Adw.NavigationDirection.BACK);
        }

        public void open_details (ExploreExtensionObject obj) {
            leaflet.navigate (Adw.NavigationDirection.FORWARD);
            details_title.set_title (obj.name);
            set_details_content (obj);
        }

        public Window (Adw.Application app) {
            Object (application: app);

            // search things
            var focus_search = new SimpleAction ("focus-search", null);
            focus_search.activate.connect (() => search_button.set_active (!search_button.active));
            add_action (focus_search);
            app.set_accels_for_action ("win.focus-search", {"<Ctrl>f"});
            search_bar.connect_entry ((Gtk.Editable) entry_search);
            var key_press_event = new Gtk.EventControllerKey ();
            key_press_event.key_pressed.connect ((keyval) => {
                if (keyval == Gdk.Key.Escape) {
                    search_button.set_active (!search_button.active);
                    return true;
                }

                return false;
            });
            entry_search.add_controller (key_press_event);

            explore_loaded.connect (() => {
                search_button.set_sensitive (true);
            });

            Application.installed_extensions.foreach ((extension, variant) => {
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
