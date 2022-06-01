/* widgets/explore_row.vala
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
    public class ExploreRow : Adw.ActionRow {

        public ExploreExtensionObject extension;

        public ExploreRow (ExploreExtensionObject obj) {
            Object ();

            extension = obj;

            this.set_title (GLib.Markup.escape_text (obj.name));
            this.set_subtitle (GLib.Markup.escape_text (obj.description.split (".\n")[0]));
            var image = new Gtk.Image ();
            image.set_pixel_size (32);
            obj.get_gicon.begin ((object, res) => {
                var icon = obj.get_gicon.end (res);
                image.set_from_pixbuf (icon);
                this.add_prefix (image);
            });
        }
    }
}
