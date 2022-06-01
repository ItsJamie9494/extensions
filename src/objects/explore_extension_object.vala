/* objects/explore_extension_object.vala
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
    public class ExploreExtensionObject : GLib.Object {
        public string uuid { get; set; }
        public string name { get; set; }
        public string creator { get; set; }
        public string creator_url { get; set; }
        // NOTE: This is the global PK, not the version PK
        public int64 pk { get; set; }
        public string description { get; set; }
        public string link { get; set; }
        public string icon { get; set; }
        public string? screenshot { get; set; }
        public Json.Object shell_version_map { get; set; }

        public ExploreExtensionObject (Json.Object obj) {
            Object ();

            uuid = obj.get_string_member_with_default ("uuid", "unknown@example.com");
            name = obj.get_string_member_with_default ("name", "Unknown Extension");
            creator = obj.get_string_member_with_default ("creator", "Unknown Developer");
            creator_url = obj.get_string_member_with_default ("creator_url", "https://example.com");
            pk = obj.get_int_member_with_default ("pk", 0);
            description = obj.get_string_member_with_default ("description", "No Description Provided");
            link = obj.get_string_member_with_default ("link", "https://example.com");
            // TODO write icon code
            icon = obj.get_string_member_with_default ("icon", "https://example.com");
            if (obj.get_null_member ("screenshot")) {
                screenshot = null;
            } else {
                screenshot = obj.get_string_member_with_default ("screenshot", "null");
            }
            shell_version_map = obj.get_object_member ("shell_version_map");
        }
    }
}
