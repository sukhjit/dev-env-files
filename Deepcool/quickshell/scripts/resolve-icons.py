#!/usr/bin/env python3
# Resolve icon names to files via GTK4, so launcher icons match GTK apps (walker).
# Usage: resolve-icons.py <size> <icon-name>...  -> JSON {name: path} on stdout
import json
import os
import sys

import gi

gi.require_version("Gtk", "4.0")
from gi.repository import Gdk, Gtk  # noqa: E402

size = int(sys.argv[1])
names = sys.argv[2:]

Gtk.init()
theme = Gtk.IconTheme.get_for_display(Gdk.Display.get_default())

out = {}
for name in names:
    if os.path.isabs(name):
        out[name] = name
        continue
    if not theme.has_icon(name):
        continue
    f = theme.lookup_icon(name, None, size, 1, Gtk.TextDirection.NONE, 0).get_file()
    if f and f.get_path():
        out[name] = f.get_path()

print(json.dumps(out))
