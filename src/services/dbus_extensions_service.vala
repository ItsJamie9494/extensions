/* services/dbus_extensions_service.vala
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
    [DBus (name = "org.gnome.Shell.Extensions")]
    public interface ExtensionsService : GLib.Object {
        public abstract GLib.HashTable<string, GLib.HashTable<string, GLib.Variant>> list_extensions () throws GLib.Error;
        public abstract void open_extension_prefs (string uuid, string parent_window, GLib.HashTable<string, GLib.Variant> options) throws GLib.Error;
    }
}
