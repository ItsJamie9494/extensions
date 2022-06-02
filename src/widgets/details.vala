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
        [GtkChild]
        private unowned Gtk.Label details_description;
        [GtkChild]
        private unowned Adw.ActionRow project_website_row;
        [GtkChild]
        private unowned Adw.ActionRow dev_row;
        [GtkChild]
        private unowned Adw.Bin screenshot_box;
        [GtkChild]
        private unowned Gtk.Stack screenshot_stack;

        [GtkChild]
        private unowned Gtk.Button action_button;
        [GtkChild]
        private unowned Gtk.Spinner progress_spinner;

        private string uuid;

        private enum Action {
            INSTALL,
            UNINSTALL,
            UPDATE
        }

        private enum StyleClass {
            SUGGESTED,
            DESTRUCTIVE
        }

        private Action button_action;

        [GtkCallback]
        public void action_clicked () {
            action_button.set_sensitive (false);
            progress_spinner.set_visible (true);

            try {
                if (button_action == Action.INSTALL) {
                    var success = Application.dbus_extensions.install_remote_extension (uuid);
                    if (success == "successful") {
                        action_button.set_sensitive (true);
                        progress_spinner.set_visible (false);
                    }
                } else if (button_action == Action.UPDATE) {
                    print ("TODO provide extension updates");
                } else if (button_action == Action.UNINSTALL) {
                    var success = Application.dbus_extensions.uninstall_extension (uuid);
                    if (success == true) {
                        action_button.set_sensitive (true);
                        progress_spinner.set_visible (false);
                    }
                }
            } catch (Error e) {
                print ("%s\n", e.message);
            }
        }

        [GtkCallback]
        public void on_url_clicked (Adw.ActionRow source) {
            Gtk.show_uri_full.begin (null, source.get_name (), Gdk.CURRENT_TIME, null);
            ((Gtk.FlowBox) source.get_parent ().get_parent ().get_parent ()).unselect_all ();
        }

        public Details () {
            Object ();
        }

        construct {
            this.realize.connect (() => {
                Application.main_window.set_details_content.connect ((extension) => {
                    uuid = extension.uuid;
                    progress_spinner.set_visible (false);

                    // TODO make this match the bottom state code
                    if (Application.installed_extensions.contains (uuid)) {
                        handle_action_button (Application.installed_extensions[uuid]);
                    } else {
                        action_button.set_label ("Install");
                        button_action = Action.INSTALL;
                        action_button.set_sensitive (true);
                        set_action_button_style (StyleClass.SUGGESTED);
                    }

                    screenshot_stack.set_visible_child_name ("loading");
                    details_title.set_label (extension.name);
                    extension.get_gicon.begin ((obj, res) => {
                        details_icon.set_from_pixbuf (extension.get_gicon.end (res));
                    });
                    developer_name.set_label (extension.creator);
                    details_description.set_label (extension.description);

                    if (extension.link != "null") {
                        project_website_row.set_name ("https://extensions.gnome.org%s".printf (extension.link));
                        project_website_row.set_subtitle (extension.get_uri_hostname (extension.link));
                        project_website_row.set_visible (true);
                    }

                    if (extension.creator_url != "null") {
                        dev_row.set_name ("https://extensions.gnome.org%s".printf (extension.creator_url));
                        dev_row.set_subtitle (extension.get_uri_hostname (extension.creator_url));
                        dev_row.set_visible (true);
                    }

                    load_screenshot (extension);
                });

                Application.dbus_extensions.extension_state_changed.connect ((input_uuid, state) => {
                    if (input_uuid == uuid) {
                        handle_action_button (state);
                    }
                });
            });
        }

        private void handle_action_button (GLib.HashTable<string, GLib.Variant> state) {
            action_button.set_sensitive (true);
            if (state.lookup ("type").get_double () == 1.0) {
                action_button.set_label ("Uninstall");
                button_action = Action.UNINSTALL;
                set_action_button_style (StyleClass.DESTRUCTIVE);
                action_button.set_sensitive (false);
                action_button.set_tooltip_markup ("This is a system extension");
            }
            if (state.lookup ("state").get_double () == 1.0 ||
                state.lookup ("state").get_double () == 2.0 ||
                state.lookup ("state").get_double () == 6.0) {
                action_button.set_label ("Uninstall");
                button_action = Action.UNINSTALL;
                set_action_button_style (StyleClass.DESTRUCTIVE);
            } else if (state.lookup ("state").get_double () == 4.0) {
                action_button.set_label ("Update");
                button_action = Action.UPDATE;
                set_action_button_style (StyleClass.SUGGESTED);
            } else if (state.lookup ("state").get_double () == 3.0) {
                action_button.set_label ("Error");
                action_button.set_sensitive (false);
                set_action_button_style (StyleClass.DESTRUCTIVE);
            } else if (state.lookup ("state").get_double () == 99.0) {
                action_button.set_label ("Install");
                button_action = Action.INSTALL;
                action_button.set_sensitive (true);
                set_action_button_style (StyleClass.SUGGESTED);
            } else {
                action_button.set_label ("Working...");
                action_button.set_sensitive (false);
            }
        }

        private void set_action_button_style (StyleClass style) {
            action_button.get_style_context ().remove_class ("suggested-action");
            action_button.get_style_context ().remove_class ("destructive-action");

            if (style == StyleClass.SUGGESTED) {
                action_button.get_style_context ().add_class ("suggested-action");
            } else if (style == StyleClass.DESTRUCTIVE) {
                action_button.get_style_context ().add_class ("destructive-action");
            }
        }

        private void load_screenshot (ExploreExtensionObject obj) {
            var cache = new ScreenshotCache ();
            int MAX_WIDTH = 800;

            if (obj.screenshot != null && obj.screenshot != "null") {
                cache.fetch.begin ("https://extensions.gnome.org%s".printf (obj.screenshot), (obj, res) => {
                    try {
                        var path = cache.fetch.end (res);
                        var pixbuf = new Gdk.Pixbuf.from_file_at_scale (path, MAX_WIDTH * scale_factor, 600 * scale_factor, true);
                        var image = new Gtk.Picture.for_pixbuf (pixbuf);
                        image.height_request = 423;
                        image.halign = Gtk.Align.CENTER;
                        image.get_style_context ().add_class ("screenshot-image");
                        image.get_style_context ().add_class ("image1");

                        image.show ();
                        screenshot_box.set_child (image);
                        screenshot_stack.set_visible_child_name ("screenshot");
                    } catch (GLib.Error e) {
                        print ("%s\n", e.message);
                        screenshot_stack.set_visible_child_name ("no-shot");
                    }
                });
            } else {
                screenshot_stack.set_visible_child_name ("no-shot");
            }
        }
    }
}
