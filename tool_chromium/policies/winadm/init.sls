# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as chromium with context %}

include:
  - {{ sls_package_install }}


# This will always attempt to reinstall templates. @FIXME

# https://support.google.com/chrome/a/answer/187202?ref_topic=9023406&hl=en#zippy=%2Clinux%2Cwindows
# https://dl.google.com/dl/edgedl/chrome/policy/policy_templates.zip

{%- if 'Windows' == grains.kernel %}

{%-   set temp = salt['temp.dir']() %}

Google Chrome Group Policy definitions are downloaded:
  archive.extracted:
    - name: {{ temp }}
    - source: {{ chrome.lookup.win_gpo.source }}
{%-   if chrome.lookup.win_gpo.get('hash') %}
    - source_hash: {{ chrome.lookup.win_gpo.hash }}
{%-   else %}
    - skip_verify: true # not recommended
{%-   endif %}
    - require:
      - {{ sls_package_install }}

{%-   for template in ['google', 'chrome'] %}

{{ template | capitalize }} GPO ADMX file is installed:
  file.managed:
    - name: {{ chrome.lookup.win_gpo.policy_dir | path_join(template ~ '.admx') }}
    - source: {{ temp | path_join('windows', 'admx', template ~ '.admx') }}
    - win_owner: {{ chrome.lookup.win_gpo.owner }}
    - require:
      - Google Chrome Group Policy definitions are downloaded

{{ template | capitalize }} GPO ADML file is installed:
  file.managed:
    - name: {{ chrome.lookup.win_gpo.policy_dir | path_join(chrome.lookup.win_gpo.lang, template ~ '.adml') }}
    - source: {{ temp | path_join('windows', 'admx', chrome.lookup.win_gpo.lang, template ~ '.adml') }}
    - win_owner: {{ chrome.lookup.win_gpo.owner }}
    - require:
      - {{ template | capitalize }} GPO ADMX file is installed
{%-   endfor %}
{%- endif %}
