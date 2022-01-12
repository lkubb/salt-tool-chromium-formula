{%- from 'tool-chromium/map.jinja' import chromium -%}

include:
  - .synclocalexts
  - .allowlocal

{#- Currently, extensions can only be defined globally.
   Therefore, install all of them for all users' default profiles.
   Not sure if this works for users that are not logged in. #}
{%- if chromium.get('_local_extensions') %}
# Installs requested local extensions one by one. Waits for 60 seconds for the user
# to accept the installation, otherwise will exit with error.
  {%- for user in chromium.users %}
    {%- for name, vars in chromium._local_extensions.items() %}

Chromium has installed local extension {{ name }} for user {{ user.name }}:
  cmd.run:
    - name: |
      {%- if 'Darwin' == grains.kernel %}
        xattr -cr {{ chromium._path }}
      {%- endif %}
        test -e {{ chromium.ext_local_source }}/{{ name }}.crx || exit 1
        {{ chromium._bin }} file://{{ chromium.ext_local_source }}/{{ name }}.crx &
        start=$(date +%s)
        while [ ! -d '{{ user._chromium.confdir }}/Default/Extensions/{{ vars.id }}' ]; do
          sleep 1;
          if [  $(($(date +%s) - $start)) -ge 60 ]; then
            exit 1;
          fi
        done
    - runas: {{ user.name }}
    - creates:
      - {{ user._chromium.confdir }}/Default/Extensions/{{ vars.id }}
    {%- endfor %}
  {%- endfor %}
{%- endif %}
