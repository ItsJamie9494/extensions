/* application.vala
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
    public class Application : Adw.Application {
        public Application () {
            Object (
                application_id: "dev.itsjamie9494.Extensions",
                flags: ApplicationFlags.FLAGS_NONE
            );
        }
        public static ExtensionsService dbus_extensions;
        
        construct {
            ActionEntry[] action_entries = {
                { "about", this.on_about_action },
                { "quit", this.quit }
            };
            this.add_action_entries (action_entries, this);
            this.set_accels_for_action ("app.quit", {"<primary>q"});
        }

        public override void activate () {
            try {
                dbus_extensions = Bus.get_proxy_sync (SESSION, "org.gnome.Shell.Extensions", "/org/gnome/Shell/Extensions");
                dbus_extensions.list_extensions ().foreach ((extension) => {
                    print (extension + "\n");
                });
            } catch (GLib.IOError e) {
                print ("%s\n", e.message);
                return;
            } catch (GLib.Error e) {
                print ("%s\n", e.message);
                return;
            }
            
            base.activate ();
            var win = this.active_window;
            if (win == null) {
                win = new Extensions.Window (this);
            }
            win.present ();
        }

        private void on_about_action () {
            string[] authors = { "Jamie Murphy" };
            Gtk.show_about_dialog (this.active_window,
                                   "program-name", "Extensions",
                                   "authors", authors,
                                   "version", "0.1.0");
        }
    }
}

int main (string[] args) {
    var app = new Extensions.Application ();
    return app.run (args);
}
