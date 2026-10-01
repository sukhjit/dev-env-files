#!/usr/bin/env python3
# Print JSON list of desktop ids (without .desktop) that shouldn't show on this desktop:
# OnlyShowIn/NotShowIn vs XDG_CURRENT_DESKTOP, NoDisplay, Hidden, TryExec. Same rules GTK launchers use.
import json

from gi.repository import Gio

print(json.dumps([a.get_id().removesuffix(".desktop") for a in Gio.AppInfo.get_all() if not a.should_show()]))
