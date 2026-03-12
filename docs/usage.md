# Command‑Line Usage (auto‑generated)

The following sections are generated automatically from the `--help` output of each executable script in the repository.

{% for entry in help_entries %}
## {{ entry.name }}

```text
{{ entry.output }}
```

{% endfor %}

*To refresh this page, run `python scripts/generate_help.py` and commit the changes.*