# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as chromium with context %}

include:
  - {{ sls_package_install }}


{%- for user in chromium.users %}

Chromium has generated the default profile for user '{{ user.name }}':
  cmd.run:
    - name: |
        "{{ chromium._bin }}" &
        while [ ! -d '{{ user._chromium.confdir | path_join('Default') }}' ]; do
          sleep 1;
        done
        sleep 1
        killall "$(basename '{{ chromium._bin }}')"
    - runas: {{ user.name }}
    - require:
      - sls: {{ sls_package_install }}
    - unless:
      - test -d '{{ user._chromium.confdir | path_join('Default') }}'
{%- endfor %}
