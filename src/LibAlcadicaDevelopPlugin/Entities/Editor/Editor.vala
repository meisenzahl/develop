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
namespace Alcadica.Develop.Plugins.Entities.Editor {
	public class Editor : Object {
		public uint current_column { get; set; }
		public uint current_row { get; set; }
		public File file { get; set; }
		public string filename { get; set; }
		public signal void did_become_current ();
		public signal void did_close ();
		public signal void did_open ();
		public signal void will_close ();
		public signal void will_open ();
	}
}