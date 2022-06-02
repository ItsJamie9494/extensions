/* screenshot_cache.vala
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
    public errordomain FetchError {
        NO_SCREENSHOT
    }

    public class ScreenshotCache : GLib.Object {
        private const int HTTP_HEAD_TIMEOUT = 3000;
        private const int HTTP_DOWNLOAD_TIMEOUT = 5000;

        private const int MAX_CACHE_SIZE = 100000000;

        private GLib.File screenshot_folder;

        construct {
            var screenshot_path = Path.build_filename (
                Environment.get_user_cache_dir (),
                "extensions",
                "screenshots"
            );

            screenshot_folder = GLib.File.new_for_path (screenshot_path);

            if (!screenshot_folder.query_exists ()) {
                try {
                    if (!screenshot_folder.make_directory_with_parents ()) {
                        return;
                    }
                } catch (Error e) {
                    warning ("Error creating screenshot cache folder: %s", e.message);
                    return;
                }
            }

            maintain.begin ();
        }

        private async void maintain () {
            uint64 screenshot_usage = 0, dirs = 0, files = 0;
            try {
                if (!yield screenshot_folder.measure_disk_usage_async (
                    FileMeasureFlags.NONE,
                    GLib.Priority.DEFAULT,
                    null,
                    null,
                    out screenshot_usage,
                    out dirs,
                    out files
                )) {
                    return;
                }
            } catch (Error e) {
                warning ("Error measuring size of screenshot cache: %s", e.message);
            }

            debug ("Screenshot folder size is %s", GLib.format_size (screenshot_usage));

            if (screenshot_usage > MAX_CACHE_SIZE) {
                yield delete_oldest_files (screenshot_usage);
            }
        }

        private async void delete_oldest_files (uint64 screenshot_usage) {
            var file_list = new Gee.ArrayList<GLib.FileInfo> ();

            FileEnumerator enumerator;
            try {
                enumerator = yield screenshot_folder.enumerate_children_async (
                    GLib.FileAttribute.STANDARD_NAME + "," +
                    GLib.FileAttribute.STANDARD_TYPE + "," +
                    GLib.FileAttribute.STANDARD_SIZE + "," +
                    GLib.FileAttribute.TIME_CHANGED,
                    FileQueryInfoFlags.NONE
                );
            } catch (Error e) {
                warning ("Unable to create enumerator to delete cached screenshots: %s", e.message);
                return;
            }

            FileInfo? info;

            try {
                while ((info = enumerator.next_file (null)) != null) {
                    if (info.get_file_type () == FileType.REGULAR) {
                        file_list.add (info);
                    }
                }
            } catch (Error e) {
                warning ("Error while enumerating screenshot cache dir: %s", e.message);
            }

            file_list.sort ((a, b) => {
                uint64 a_time = a.get_attribute_uint64 (GLib.FileAttribute.TIME_CHANGED);
                uint64 b_time = b.get_attribute_uint64 (GLib.FileAttribute.TIME_CHANGED);

                if (a_time < b_time) {
                    return -1;
                } else if (a_time == b_time) {
                    return 0;
                } else {
                    return 1;
                }
            });

            uint64 current_usage = screenshot_usage;
            foreach (var file_info in file_list) {
                if (current_usage > MAX_CACHE_SIZE) {
                    var file = screenshot_folder.resolve_relative_path (file_info.get_name ());
                    if (file == null) {
                        continue;
                    }

                    debug ("deleting screenshot at %s to free cache", file.get_path ());
                    try {
                        yield file.delete_async (GLib.Priority.DEFAULT);
                        current_usage -= file_info.get_size ();
                    } catch (Error e) {
                        warning ("Unable to delete cached screenshot file '%s': %s", file.get_path (), e.message);
                    }
                } else {
                    break;
                }
            }
        }

        private string generate_screenshot_path (string url) {
            int ext_pos = url.last_index_of (".");
            string extension = url.slice ((long) ext_pos, (long) url.length);
            if (extension.contains ("/")) {
                extension = "";
            }

            return Path.build_filename (
                screenshot_folder.get_path (),
                "%02x".printf (url.hash ()) + extension
            );
        }

        public async string fetch (string url) throws FetchError {
            string path = generate_screenshot_path (url);

            var remote_file = File.new_for_uri (url);
            var local_file = File.new_for_path (path);

            GLib.DateTime? remote_mtime = null;
            try {
                var cancellable = new GLib.Cancellable ();
                uint cancel_source = 0;
                cancel_source = Timeout.add (HTTP_HEAD_TIMEOUT, () => {
                    cancel_source = 0;
                    cancellable.cancel ();
                    return GLib.Source.REMOVE;
                });

                var file_info = yield remote_file.query_info_async (
                    GLib.FileAttribute.TIME_MODIFIED,
                    FileQueryInfoFlags.NONE,
                    GLib.Priority.DEFAULT,
                    cancellable
                );

                if (cancel_source != 0) {
                    GLib.Source.remove (cancel_source);
                }

                remote_mtime = get_modification_time (file_info);
            } catch (Error e) {
                warning ("Error getting modification time of remote screenshot file: %s", e.message);
            }

            if (local_file.query_exists ()) {
                GLib.DateTime? file_time = null;
                try {
                    var file_info = yield local_file.query_info_async (GLib.FileAttribute.TIME_MODIFIED, FileQueryInfoFlags.NONE);
                    file_time = get_modification_time (file_info);
                } catch (Error e) {
                    warning ("Error getting modification time of cached screenshot file: %s", e.message);
                }

                // Local file is up to date
                if (file_time != null && remote_mtime != null && file_time.equal (remote_mtime)) {
                    return path;
                }
            }

            try {
                var cancellable = new GLib.Cancellable ();
                uint cancel_source = 0;
                cancel_source = Timeout.add (HTTP_DOWNLOAD_TIMEOUT, () => {
                    cancel_source = 0;
                    cancellable.cancel ();
                    return GLib.Source.REMOVE;
                });

                yield remote_file.copy_async (
                    local_file,
                    FileCopyFlags.OVERWRITE | FileCopyFlags.TARGET_DEFAULT_PERMS,
                    GLib.Priority.DEFAULT,
                    cancellable
                );

                if (cancel_source != 0) {
                    GLib.Source.remove (cancel_source);
                }
            } catch (Error e) {
                warning ("Unable to download screenshot from %s: %s", url, e.message);
                throw new FetchError.NO_SCREENSHOT ("Unable to download screenshot");
            }

            return path;
        }

        private static GLib.DateTime? get_modification_time (GLib.FileInfo info) {
            GLib.DateTime? datetime = null;

            datetime = info.get_modification_date_time ();

            return datetime;
        }
    }
}
