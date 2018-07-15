/*
* Copyright (c) 2011-2018 alcadica (https://www.alcadica.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: alcadica <github@alcadica.com>
*/
using Gtk;

using Alcadica.Develop.Plugins.Entities.Template;
using Alcadica.Develop.Services.Editor;

namespace Alcadica.Develop.Views { 
	public class ProjectCreator : Paned {
		private signal void template_did_select (string name);
		private List<string> subscribed_templates;
		private Alcadica.Widgets.ActionBar detail_action_bar;
		private ListBox category_list;
		private Box template_detail;
		
		construct {
			var manager = Services.ActionManager.instance;
			var category_stack = new Stack ();
			var template_stack = new Stack ();

			this.category_list = new ListBox ();
			this.detail_action_bar = new Alcadica.Widgets.ActionBar ();
			this.subscribed_templates = new List<string> ();
			this.template_detail = new Box (Orientation.VERTICAL, 0);
			this.template_detail.pack_end (this.detail_action_bar);

			this.category_list.selection_mode = SelectionMode.SINGLE;
			this.orientation = Orientation.HORIZONTAL;

			category_stack.add (this.category_list);
			template_stack.add (this.template_detail);

			this.pack1 (category_stack, true, false);
			this.pack2 (template_stack, true, false);

			manager.get_action (Actions.Window.SHOW_PROJECT_CREATION).activate.connect (() => {
				this.empty_detail ();
				this.empty_list ();
				this.populate_category_list ();
				this.show_all ();
			});
			
			this.category_list.row_selected.connect (row => {
				this.empty_detail ();
				this.template_did_select (this.subscribed_templates.nth_data (row.get_index ()));
			});

			this.template_did_select.connect (this.populate_template_detail);
		}

		private void empty_list () {
			debug ("Emptying templates list");
		}

		private void empty_detail () {
			debug ("Emptying template detail");
		}

		private Widget? get_template_list_item (string item_name) {
			var template = PluginContext.context.template.get_template_by_name (item_name);
			
			if (template == null) {
				debug (@"No instance for template $item_name");
				return null;
			}

			string template_icon_name;

			if (template.template_icon_name == "" || template.template_icon_name == null) {
				template_icon_name = "image-missing";
			} else {
				template_icon_name = template.template_icon_name;
			}
			
			var grid = new Grid ();
			var template_description = new Label (template.template_description);
			var template_icon = new Image.from_icon_name (template_icon_name, IconSize.DIALOG);
			var template_name = new Label (template.template_name);

			template_name.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
			template_name.ellipsize = Pango.EllipsizeMode.END;
			template_name.xalign = 0;
			template_name.valign = Gtk.Align.END;

			grid.column_spacing = 12;
			grid.orientation = Orientation.HORIZONTAL;
			grid.attach (template_icon, 0, 0, 1, 2);
			grid.attach (template_name, 1, 0, 1, 1);
			grid.attach (template_description, 1, 1, 1, 1);

			debug (@"Created template list item $item_name");

			return grid;
		}

		private Widget? get_template_detail(Template template) {
			var detail_grid = new Grid ();
			var template_title = new Label (template.template_name);

			detail_grid.orientation = Orientation.VERTICAL;
			template_title.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
			template_title.justify = Justification.CENTER;

			detail_grid.add (template_title);

			foreach (TemplateToken token in template.tokens) {
				var field = new Alcadica.Widgets.EntryWithLabel (token.token_label);

				field.changed.connect(value => {
					token.validate (value);
				});
				
				debug (@"Adding token field " + token.token_label + " to form");

				detail_grid.add (field);
			}
			
			return detail_grid;
		}

		private void populate_category_list () {
			this.subscribed_templates = PluginContext.context.template.get_subscribed_templates_names ();
			
			foreach (var template_name in subscribed_templates) {
				debug (@"Adding \"$template_name\" to templates list.");
	
				Widget? item = this.get_template_list_item (template_name);
	
				if (item == null) {
					continue;
				}
				
				this.category_list.add (item);
			}
		}

		private void populate_template_detail (string template_name) {
			Template? template = PluginContext.context.template.get_template_by_name (template_name);

			debug (@"Selected $template_name");

			if (template == null) {
				warning (@"Template $template_name is missing, aborting");
				return;
			}

			var detail_form = this.get_template_detail (template);
			var previous_widget = this.template_detail.get_center_widget ();

			if (previous_widget != null) {
				debug ("Removing previous template form");
				previous_widget.dispose ();
			}

			this.template_detail.set_center_widget (detail_form);
			this.show_all ();
		}
	}
}