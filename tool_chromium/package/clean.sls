# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chromium with context %}

include:
  - {{ slsdotpath }}.repo.clean

Chromium is removed:
  pkg.removed:
    - name: {{ chromium._pkg.name }}
