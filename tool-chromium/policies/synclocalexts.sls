{%- from 'tool-chromium/map.jinja' import chromium -%}

{%- if chromium.get('_local_extensions') and chromium.get('ext_local_source_sync', True) %}
Requested local Chromium extensions are synced:
  file.managed:
    - names:
  {%- for extension in chromium._local_extensions.keys() %}
      - {{ chromium.ext_local_source}}/{{ extension }}.crx:
        - source: salt://tool-chromium/files/extensions/{{ extension }}.crx
  {%- endfor %}
    - mode: '0644'
    - dir_mode: '0755'
    - user: root
    - group: {{ salt['user.primary_group']('root') }}
    - makedirs: true

Local Chromium extension update file contains current versions:
  file.managed:
    - name: {{ chromium.ext_local_source}}/update
    - source: salt://tool-chromium/policies/files/update
    - template: jinja
    - context:
        local_source: {{ chromium.ext_local_source }}
        extensions: {{ chromium._local_extensions | json }}
    - user: root
    - group: {{ salt['user.primary_group']('root') }}
    - mode: '0644'
{%- endif %}
