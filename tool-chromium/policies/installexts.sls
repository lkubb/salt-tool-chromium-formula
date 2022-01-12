{%- from 'tool-chromium/map.jinja' import chromium -%}

include:
  - .downloadexts
  - .synclocalexts
{%- if 'ungoogled' != chromium.version %}
  - {{ slsdotpath }}.allowlocal
{%- endif %}

{#- Currently, extensions can only be defined globally.
   Therefore, install all of them for all users' default profiles.
   Not sure if this works for users that are not logged in. #}
{%- if chromium.get('_download_extensions') or chromium.get('_local_extensions') %}
# Installs requested local extensions one by one. Waits for 60 seconds for the user
# to accept the installation, otherwise will exit with error.
  {%- for user in chromium.users %}
    {%- for name, vars in (salt['defaults.merge'](chromium._download_extensions, chromium._local_extensions, in_place=False)).items() %}
      {%- set ext_path = chromium._download_extensions_tempdir if name in chromium._download_extensions else chromium.ext_local_source %}
      {#- set ext_path = "{}/downloaded/{}.crx".format(chromium.ext_local_source, name) if name in chromium._download_extensions
                       else "{}/{}.crx".format(chromium.ext_local_source, name) #}
Chromium has installed extension {{ name }} for user {{ user.name }}:
  cmd.run:
    - name: |
      {%- if 'Darwin' == grains.kernel %}
        xattr -cr {{ chromium._path }}
      {%- endif %}
        # sometimes the downloads fail and the file is zero bytes
        test -s "{{ ext_path }}/{{ name }}.crx" || exit 1
        "{{ chromium._bin }}" {% if 'ungoogled' == chromium.version  %}--extension-mime-request-handling=always-prompt-for-install {% endif %}file://{{ ext_path }}/{{ name }}.crx &
        start=$(date +%s)
        while [ ! -d '{{ user._chromium.confdir }}/Default/Extensions/{{ vars.id }}' ]; do
          sleep 1;
          if [  $(($(date +%s) - $start)) -ge 60 ]; then
            exit 1;
          fi
        done
        # will not continue if Chromium is running in background
        # since this is not needed on Linux, just use uppercase
        killall Chromium
    - runas: {{ user.name }}
    - creates:
      - {{ user._chromium.confdir }}/Default/Extensions/{{ vars.id }}
{%- if 'ungoogled' != chromium.version %}
    - require:
      - sls: {{ slsdotpath }}.allowlocal
      {%- if name in chromium._download_extensions %}
      - Extension '{{ name }}' was downloaded from source
{#      {%- else %}
      - Requested local Chromium extensions are synced #}
      {%- endif %}
{%- endif %}
    {%- endfor %}
  {%- endfor %}
{%- endif %}
