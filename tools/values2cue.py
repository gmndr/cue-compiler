#!/usr/bin/env python3
"""Convertit le values.yaml officiel d'un chart Helm en base CUE.

Chaque valeur feuille est émise comme valeur par défaut CUE (`*valeur | _`)
afin qu'un contexte (overrides/<env>) puisse la surcharger par unification.

Usage :
    python3 tools/values2cue.py <values.yaml> <sortie.cue> [package]
"""

import json
import re
import sys

import yaml

IDENT = re.compile(r"^[a-zA-Z_][a-zA-Z0-9_]*$")
CUE_KEYWORDS = {"if", "for", "let", "in", "import", "package", "else"}


def field_key(key) -> str:
    key = str(key)
    if IDENT.match(key) and key not in CUE_KEYWORDS:
        return key
    return json.dumps(key, ensure_ascii=False)


def scalar(v) -> str:
    if v is None:
        return "null"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return repr(v)
    return json.dumps(str(v), ensure_ascii=False)


def literal(v) -> str:
    if isinstance(v, dict):
        if not v:
            return "{}"
        inner = ", ".join(f"{field_key(k)}: {literal(val)}" for k, val in v.items())
        return "{" + inner + "}"
    if isinstance(v, list):
        if not v:
            return "[]"
        return "[" + ", ".join(literal(item) for item in v) + "]"
    return scalar(v)


def emit(node, indent: int, out: list) -> None:
    pad = "\t" * indent
    for k, v in node.items():
        key = field_key(k)
        if isinstance(v, dict):
            if not v:
                out.append(f"{pad}{key}: {{}}")
            else:
                out.append(f"{pad}{key}: {{")
                emit(v, indent + 1, out)
                out.append(f"{pad}}}")
        else:
            out.append(f"{pad}{key}: *{literal(v)} | _")


def main() -> None:
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    src, dst = sys.argv[1], sys.argv[2]
    package = sys.argv[3] if len(sys.argv) > 3 else "base"
    with open(src, encoding="utf-8") as f:
        data = yaml.safe_load(f)
    if not isinstance(data, dict):
        sys.exit(f"{src}: le document racine doit être une map YAML")
    out = [
        f"// Généré depuis {src} par tools/values2cue.py — ne pas éditer à la main.",
        f"package {package}",
        "",
    ]
    emit(data, 0, out)
    with open(dst, "w", encoding="utf-8") as f:
        f.write("\n".join(out) + "\n")


if __name__ == "__main__":
    main()
