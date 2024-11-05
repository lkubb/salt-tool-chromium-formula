# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chromium with context %}


{%- if chromium.get("_local_extensions") and chromium.extensions.local.sync %}

Synced local Chromium extensions are absent:
  file.absent:
    - names:
{%-   for extension in chromium._local_extensions %}
      - {{ chromium.extensions.local.source | path_join(extension ~ ".crx") }}
{%-   endfor %}
      - {{ chromium.extensions.local.source | path_join("update") }}
{%- endif %}
