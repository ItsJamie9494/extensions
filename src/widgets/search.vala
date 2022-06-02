/* widgets/search.vala
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
    [GtkTemplate (ui = "/dev/itsjamie9494/Extensions/search.ui")]
    public class Search : Adw.Bin {
        [GtkChild]
        public unowned Gtk.ListBox listbox;

        private string? current_search_term { get; set; default = null; }

        public Search () {
            Object ();

            listbox.set_sort_func ((row1, row2) => {
                var p1 = ((ExploreRow) row1.get_first_child ());
                var p2 = ((ExploreRow) row2.get_first_child ());
                int sp1 = search_priority (p1.extension.name, p2.extension.uuid);
                int sp2 = search_priority (p2.extension.name, p2.extension.uuid);
                if (sp1 != sp2) {
                    return sp2 - sp1;
                }

                return p1.extension.name.collate (p2.extension.name);
            });
        }

        construct {
            this.realize.connect (() => {
                Application.main_window.search_reset.connect (() => {
                    reset ();
                });
                Application.main_window.search_query.connect ((query) => {
                    search.begin (query);
                });
            });
        }

        private int search_priority (string name, string uuid) {
            if ((name != null || uuid != null) && current_search_term != null) {
                var name_lower = name.down ();
                var uuid_lower = uuid.down ();
                var query_lower = current_search_term.down ();

                var name_term_position = name_lower.index_of (query_lower);
                var uuid_term_position = uuid_lower.index_of (query_lower);

                if (name_term_position == 0) {
                    return 2;
                } else if (name_term_position != -1 || uuid_term_position != -1) {
                    return 1;
                }
            }

            return 0;
        }

        public async void search (string query) {
            if (current_search_term != null) {
                current_search_term = null;
            }

            current_search_term = query;
            reset ();

            try {
                Json.Array results = yield SoupClient.get_default ().search_extensions (query);
                foreach (var extension in results.get_elements ()) {
                    listbox.append (new ExploreRow (new ExploreExtensionObject (extension.get_object ())));
                }
            } catch (SoupError e) {
                if (e.code == SoupError.NO_RESULTS) {
                    listbox.append (new Adw.ActionRow () {
                        title = "No Results"
                    });
                } else {
                    print ("%s\n", e.message);
                }
            }
        }

        public void reset () {
            // psuedocode
            Gtk.Widget[] widget_list = get_all_widgets_in_listbox ();

            foreach (var widget in widget_list) {
                listbox.remove (widget);
            }
        }

        private Gtk.Widget[] get_all_widgets_in_listbox () {
            Gtk.Widget[] widgets = {};
            var widget = listbox.get_first_child ();
            Gtk.Widget? next = null;
            if (widget != null) {
                widgets += widget;
                while ((next = widget.get_next_sibling ()) != null) {
                    widget = next;
                    widgets += widget;
                }
            }
            return widgets;
        }
    }
}
