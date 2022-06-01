/* services/soup_client_service.vala
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
    public errordomain SoupError {
        JSON_ERROR,
        UNKNOWN
    }

    public class SoupClient {
        private static SoupClient _client;
        public static unowned SoupClient get_default () {
            if (_client == null) {
                _client = new SoupClient ();
            }
            return _client;
        }

        Soup.Session session = new Soup.Session ();

        public async Json.Array get_extensions () throws SoupError {
            try {
                // TODO add more error handling lol
                Soup.Message message = new Soup.Message (
                    "GET",
                    "https://extensions.gnome.org/extension-query/?n_per_page=21&shell_version=42"
                );
                var res = yield session.send_async (message, 1, null);
                Json.Parser parser = new Json.Parser ();
                parser.load_from_stream (res);
                Json.Node root = parser.get_root ();
                Json.Node extensions = root.get_object ().get_member ("extensions");
                if (extensions.get_node_type () != Json.NodeType.ARRAY) {
                    throw new SoupError.JSON_ERROR ("Invalid JSON type");
                } else {
                    return extensions.get_array ();
                }
            } catch (GLib.Error e) {
                print ("%s\n", e.message);
                throw new SoupError.UNKNOWN ("Unknown Error");
            }
        }
    }
}
