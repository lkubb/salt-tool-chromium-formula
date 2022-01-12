{%- from 'tool-chromium/map.jinja' import chromium -%}

{%- if 'ungoogled' == chromium.version %}
include:
  - .repo
{%- endif %}

{%- set mode = 'latest' if chromium.get('update_auto') else 'installed' %}

Chromium is installed:
  pkg.{{ mode }}:
    - name: {{ chromium._package }}
    - refresh: true

Chromium setup is completed:
  test.nop:
    - name: Chromium setup has finished, hooray.
    - require:
      - pkg: {{ chromium._package }}
