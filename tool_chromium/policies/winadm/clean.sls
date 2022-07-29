# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chromium with context %}


{%- if 'Windows' == grains.kernel %}

{%-   for template in ['google', 'chrome'] %}

{{ template | capitalize }} GPO ADMX file is absent:
  file.absent:
    - name: {{ chrome.lookup.win_gpo.policy_dir | path_join(template ~ '.admx') }}

{{ template | capitalize }} GPO ADML file is absent:
  file.absent:
    - name: {{ chrome.lookup.win_gpo.policy_dir | path_join(chrome.lookup.win_gpo.lang, template ~ '.adml') }}
{%-   endfor %}
{%- endif %}
