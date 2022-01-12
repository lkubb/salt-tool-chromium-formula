{%- from 'tool-chromium/map.jinja' import chromium -%}

{%- if chromium.get('_download_extensions') %}
  {%- for extension, settings in chromium._download_extensions.items() %}
    {%- if 'https://clients2.google.com/service/update2/crx' == settings.update_url %}
      {#- if this is the first time Chromium is run on MacOS (as root), there might be problems
          uninstalling it with brew @TODO #}
      {%- set version = salt['cmd.run_stdout']("test -e {} && {} --version | grep -oe '[0-9\.]*' || echo '97.0.4692.71'".format(chromium._bin, chromium._bin), python_shell=True) %}
      {#- since jinja is evaluated first, when Chromium is not installed, set version to something that exists
          to prevent download errors -#}
      {%- set source = salt['cmd.run_stdout']("curl -ILs -o /dev/null -w %{{url_effective}} 'https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&&prodversion={}&x=id%3D{}%26installsource%3Dondemand%26uc'".format(version, settings.id)) %}
    {%- else %}
      {%- set source = salt['cmd.run_stdout']("curl {} | sed -nE \"s/.*codebase='([^']+)'.*/\\1/p\"".format(settings.update_url), python_shell=True) %}
    {%- endif %}

Extension '{{ extension }}' was downloaded from source:
  file.managed:
    - name: {{ chromium._download_extensions_tempdir }}/{{ extension }}.crx
    - source: {{ source }}
    - skip_verify: True # meh
    - makedirs: true
    - mode: '0644'
    - dir_mode: '0755'
    - user: root
    - group: {{ salt['user.primary_group']('root') }}
    # sometimes, the downloads fail and the file size is zero. redownload in that case
    - unless:
      - test -s {{ chromium._download_extensions_tempdir }}/{{ extension }}.crx
  {%- endfor %}
{%- endif %}
