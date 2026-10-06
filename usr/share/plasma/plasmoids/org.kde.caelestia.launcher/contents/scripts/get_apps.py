#!/usr/bin/env python3
import os
import glob
import json
import re

dirs = [
    '/usr/share/applications',
    '/usr/local/share/applications',
    os.path.expanduser('~/.local/share/applications'),
    '/var/lib/flatpak/exports/share/applications',
    '/var/lib/snapd/desktop/applications'
]

apps = []
seen_execs = set()

for d in dirs:
    if not os.path.exists(d):
        continue
    for f in glob.glob(os.path.join(d, '**/*.desktop'), recursive=True):
        try:
            with open(f, 'r', encoding='utf-8', errors='ignore') as fp:
                name, comment, icon, exec_cmd = '', '', '', ''
                nodisplay, type_app = False, False
                is_in_desktop_entry = False

                for line in fp:
                    line = line.strip()
                    if line == '[Desktop Entry]':
                        is_in_desktop_entry = True
                        continue
                    elif line.startswith('[') and line.endswith(']'):
                        is_in_desktop_entry = False
                        continue

                    if not is_in_desktop_entry:
                        continue

                    if line.startswith('Type=Application'):
                        type_app = True
                    elif line.startswith('Name=') and not name:
                        name = line.split('=', 1)[1]
                    elif (line.startswith('GenericName=') or line.startswith('Comment=')) and not comment:
                        comment = line.split('=', 1)[1]
                    elif line.startswith('Icon=') and not icon:
                        icon = line.split('=', 1)[1]
                    elif line.startswith('Exec=') and not exec_cmd:
                        exec_cmd = line.split('=', 1)[1]
                    elif line.startswith('NoDisplay=true') or line.startswith('Hidden=true'):
                        nodisplay = True

                if name and exec_cmd and type_app and not nodisplay:
                    # Clean Exec arguments like %u, %F, %f, %U
                    clean_exec = re.sub(r'%[a-zA-Z]', '', exec_cmd).strip()
                    if clean_exec and clean_exec not in seen_execs:
                        seen_execs.add(clean_exec)
                        apps.append({
                            'name': name,
                            'comment': comment or name,
                            'icon': icon or 'application-x-executable',
                            'exec': clean_exec
                        })
        except Exception:
            pass

# Sort alphabetically by name
apps.sort(key=lambda x: x['name'].lower())
print(json.dumps(apps))
