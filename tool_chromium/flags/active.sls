# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chromium with context %}

include:
  - {{ tplroot }}.default_profile


{%- for user in chromium.users | selectattr("chromium.flags", "defined") %}

Chromium flags are active for user {{ user.name }}:
  file.serialize:
    - name: {{ user._chromium.confdir | path_join("Local State") }}
    - serializer: json
    - merge_if_exists: true
    - dataset: {{ {"browser": {"enabled_labs_experiments": user.chromium.flags } } |  json }}
    - makedirs: true
    - mode: '0600'
    - dir_mode: '0700'
    - user: {{ user.name }}
    - group: {{ user.group }}
    - require:
      # Flags will not be accepted if the profile was not generated by Chromium first
      - Chromium has generated the default profile for user '{{ user.name }}'
{%- endfor %}
