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
            });
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
