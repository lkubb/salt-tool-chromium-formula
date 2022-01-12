{%- from 'tool-chromium/map.jinja' import chromium -%}

{%- if chromium.users | selectattr('chromium.flags', 'defined') | list %}
include:
  - .active
{%- endif %}
