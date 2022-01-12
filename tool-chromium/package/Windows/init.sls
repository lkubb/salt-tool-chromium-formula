{%- from 'tool-chromium/map.jinja' import chromium -%}

{%- set mode = 'latest' if chromium.get('update_auto') else 'installed' %}

Chromium is installed:
  chocolatey.{{ mode }}:
    - name: {{ chromium._package }}

Chromium setup is completed:
  test.nop:
    - name: Chromium setup has finished, hooray.
    - require:
      - chocolatey: {{ chromium._package }}
