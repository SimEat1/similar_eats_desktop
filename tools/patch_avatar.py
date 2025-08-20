import os, sys, re, shutil

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
dart_path = os.path.join(ROOT, "lib", "main.dart")
bak_path = dart_path + ".bak"

if not os.path.exists(dart_path):
    print(f"[X] lib/main.dart not found. Run from {ROOT}")
    sys.exit(1)

# Backup once
if not os.path.exists(bak_path):
    shutil.copy2(dart_path, bak_path)
    print("[OK] Backup created:", bak_path)

content = open(dart_path, encoding="utf-8").read()
changed = False

# ---- Insert avatar helpers (color + builder)
if "_avatarColorFrom" not in content:
    helper = """
// ---- Avatar helpers ----
Color _avatarColorFrom(String text) {
  final h = text.runes.fold<int>(0, (a, b) => a + b);
  const palette = <MaterialColor>[
    Colors.orange, Colors.teal, Colors.indigo, Colors.pink, Colors.green, Colors.brown
  ];
  return palette[h % palette.length].shade200;
}

Widget buildAvatar(String label, {String? emoji}) {
  return CircleAvatar(
    backgroundColor: _avatarColorFrom(label),
    child: Text(
      emoji ?? label.characters.first,
      style: const TextStyle(fontWeight: FontWeight.w700),
    ),
  );
}
// ---- /Avatar helpers ----
"""
    content = content.replace(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';" + helper
    )
    changed = True

# ---- Insert emoji helper
if "_emojiFor" not in content:
    emoji_helper = """
// ---- Emoji helper for restaurants ----
String? _emojiFor(String name) {
  const m = <String, String>{
    'El Fuego Taqueria': '🌮',
    'Cheese & Crust': '🍕',
    'Umami House Ramen': '🍜',
    'Sweet Spoon': '🍨',
  };
  return m[name];
}
// ---- /Emoji helper ----
"""
    # place it right after avatar helpers if present, otherwise after imports
    anchor = "// ---- /Avatar helpers ----"
    if anchor in content:
        content = content.replace(anchor, anchor + emoji_helper)
    else:
        content = content.replace(
            "import 'package:flutter/material.dart';",
            "import 'package:flutter/material.dart';" + emoji_helper
        )
    changed = True

# ---- Replace restaurant avatar to use emoji
new_content = re.sub(
    r"const\s+CircleAvatar\s*\(\s*child:\s*Icon\(Icons\.restaurant\)\s*\)",
    r"buildAvatar(r.name, emoji: _emojiFor(r.name))",
    content
)
if new_content != content:
    content = new_content
    changed = True

# ---- Replace Similar Users avatar to colored initial (keep as is if already done)
new_content = re.sub(
    r"CircleAvatar\s*\([^)]*Text\(u\.name\.characters\.first\)[^)]*\)",
    r"buildAvatar(u.name)",
    content
)
if new_content != content:
    content = new_content
    changed = True

if changed:
    open(dart_path, "w", encoding="utf-8").write(content)
    print("[OK] Avatar + emoji changes applied.")
else:
    print("[OK] No changes needed (already patched).")

