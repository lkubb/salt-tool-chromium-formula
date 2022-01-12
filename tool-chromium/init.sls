{%- from 'tool-chromium/map.jinja' import chromium -%}

include:
  - .package
{%- if chromium.users | selectattr('chromium.flags', 'defined') | list %}
  - .flags
{%- endif %}
{%- if chromium.get('_policies') %}
  - .policies
{%- endif %}
