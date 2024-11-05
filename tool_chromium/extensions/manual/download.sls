# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chromium with context %}


{%- if chromium.get("_download_extensions") %}

{#- This needs to know the Chromium version. If this is the first time Chromium is run, at least on MacOS, there
    might be problems with uninstallation when run as root. Therefore, run as current console user.
#}

{%-   set runas = salt["cmd.run_stdout"]("id -n -u $(stat -f "%u" /dev/console)", python_shell=true) %}
{%-   for extension, settings in chromium._download_extensions.items() %}
{%-     if "https://clients2.google.com/service/update2/crx" == settings.update_url %}

{#-       Find Chromium version. Since Jinja is evaluated first, when Chromium is not installed,
          set version to something that exists to prevent download errors
#}

{%-       set version = salt["cmd.run_stdout"](
            "test -e {} && {} --version | grep -oe '[0-9\.]*' || echo '97.0.4692.71'".format(chromium._bin, chromium._bin),
            runas=runas or None, python_shell=true) | trim
%}
{%-       set source = salt["cmd.run_stdout"](
            "curl -ILs -o /dev/null -w %{url_effective} " ~
              "'https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&" ~
              "prodversion={}&x=id%3D{}%26installsource%3Dondemand%26uc'".format(version, settings.id)
          ) | trim
%}
{%-     else %}
{%-       set source = salt["cmd.run_stdout"]("curl {} | sed -nE \"s/.*codebase='([^']+)'.*/\\1/p\"".format(settings.update_url), python_shell=true) | trim %}
{%-     endif %}

Check if source was found for extension '{{ extension }}':
  cmd.run:
    - name: test -n '{{ source }}'

Extension '{{ extension }}' was downloaded from source:
  file.managed:
    - name: {{ chromium._download_extensions_tempdir | path_join(extension ~ ".crx") }}
    - source: {{ source }}
    - skip_verify: true  # meh
    - makedirs: true
    - mode: '0644'
    - dir_mode: '0755'
    - user: root
    - group: {{ chromium.lookup.rootgroup }}
    # sometimes, the downloads fail and the file size is zero. redownload in that case
    - unless:
      - test -s '{{ chromium._download_extensions_tempdir | path_join(extension ~ ".crx") }}'
    - require:
      - Check if source was found for extension '{{ extension }}'
{%-   endfor %}
{%- endif %}
