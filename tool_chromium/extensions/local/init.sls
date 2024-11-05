# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chromium with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}


{%- if chromium.get("_local_extensions") and chromium.extensions.local.sync %}

Requested local Chromium extensions are synced:
  file.managed:
    - names:
{%-   for extension in chromium._local_extensions %}
      - {{ chromium.extensions.local.source | path_join(extension ~ ".crx") }}:
        - source: {{ files_switch([extension ~ ".crx"],
                              lookup="Requested local Chromium extensions are synced",
                              indent_width=10,
                              override_root=tplroot ~ "/extensions")
                  }}
{%-   endfor %}
    - mode: '0644'
    - user: root
    - group: {{ chromium.lookup.rootgroup }}
    - makedirs: true

Local Chromium extension update file contains current versions:
  file.managed:
    - name: {{ chromium.extensions.local.source | path_join("update") }}
    - source: {{ files_switch(["update"],
                          lookup="Local Chromium extension update file contains current versions")
              }}
    - template: jinja
    - context:
        local_source: {{ chromium.extensions.local.source }}
        extensions: {{ chromium._local_extensions | json }}
    - mode: '0644'
    - user: root
    - group: {{ chromium.lookup.rootgroup }}
    - require:
      - Requested local Chromium extensions are synced
{%- endif %}
