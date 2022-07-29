# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as chromium with context %}

include:
  - {{ sls_package_install }}


{%- for user in chromium.users %}

Chromium has been run once for user '{{ user.name }}':
  cmd.run:
    - name: |
        "{{ chromium._bin }}"
    - runas: {{ user.name }}
    - bg: true
    - timeout: 20
    - hide_output: true
    - require:
      - sls: {{ sls_package_install }}
    - creates:
      - {{ user._chromium.confdir | path_join("Default") }}

Chromium has generated the default profile for user '{{ user.name }}':
  file.exists:
    - name: {{ user._chromium.confdir | path_join("Default") }}
    - retry:
        attempts: 10
        interval: 1
    - require:
      - Chromium has been run once for user '{{ user.name }}'

Chromium is not running for user '{{ user.name }}':
  process.absent:
    - name: {{ salt["file.basename"](chromium._bin) }}
    - user: {{ user.name }}
    - onchanges:
      - Chromium has been run once for user '{{ user.name }}'
{%- endfor %}
