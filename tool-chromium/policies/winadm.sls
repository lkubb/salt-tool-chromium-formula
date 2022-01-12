{%- from 'tool-chromium/map.jinja' import chromium -%}

{%- load_yaml as gpo -%}
lang: {{ chromium.win_gpo_lang | default('en_US') }}
dir: {{ chromium.win_gpo_policy_dir | default('C:/Windows/PolicyDefinitions') }}
owner: {{ chromium.win_gpo_owner | default('Administrators') }}
{%- endload -%}


# https://support.google.com/chrome/a/answer/187202?ref_topic=9023406&hl=en#zippy=%2Clinux%2Cwindows
# https://dl.google.com/dl/edgedl/chrome/policy/policy_templates.zip

{%- if 'Windows' == grains.kernel %}

{%- set temp = salt['temp.dir']() %}
Google Chrome Group Policy definitions are downloaded (no Chromium ones available):
  archive.extracted:
    - name: {{ temp }}/chrome-policy
    - source: {{ chromium.win_gpo_source | default("https://dl.google.com/dl/edgedl/chrome/policy/policy_templates.zip")}}
  {%- if chromium.get("win_gpo_source_hash") %}
    - source_hash: chromium.win_gpo_source_hash
  {%- else %}
    - skip_verify: True # not recommended
  {%- endif %}

{%- for template in ['google', 'chrome'] %}
{{ template | capitalize }} GPO ADMX file is installed (no Chromium one available):
  file.managed:
    - name: {{ gpo.dir }}/{{ template }}.admx
    - source: {{ temp }}/windows/admx/{{ template }}.admx
    - win_owner: {{ gpo.owner }}

{{ template | capitalize }} GPO ADML file is installed (no Chromium one available):
  file.managed:
    - name: {{ gpo.dir }}/{{ gpo.lang }}/{{ template }}.adml
    - source: {{ temp }}/windows/admx/{{ template }}.admx
    - win_owner: {{ gpo.owner }}
  {% endfor %}
{%- endif %}
