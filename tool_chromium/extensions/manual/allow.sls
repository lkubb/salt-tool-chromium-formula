# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_winadm_install = tplroot ~ '.policies.winadm' %}
{%- from tplroot ~ "/map.jinja" import mapdata as chromium with context %}


{%- if chromium | traverse('_policies:forced:ExtensionInstallSources') %}
{%-   if 'Windows' == grains.kernel %}

include:
  - {{ sls_winadm_install }}

Local Extension source is allowed to install:
  lgpo.set:
    - computer_policy: {{ {'ExtensionInstallSources': chromium._policies.forced.ExtensionInstallSources} | json }}
    - adml_language: {{ chromium.lookup.win_gpo.lang }}
    - require:
      - sls: {{ sls_winadm_install }}

Group policies are updated to allow local installation: # suffix to make ID distinct from tool_chrome
  cmd.run:
    - name: gpupdate /wait:0
    - onchanges:
      - Local Extension source is allowed to install

{%-   elif 'Darwin' == grains.kernel %}
{%-     set necessary = 'yes' if
                chromium._policies.forced.ExtensionInstallSources !=
                salt['macprofile.item_keys']('salt.tool.org.chromium.Chromium') |
                traverse('ProfileItems:PayloadContent:ExtensionInstallSources')
              else ''
%}

Local Extension source is allowed to install:
  macprofile.installed:
    - name: salt.tool.org.chromium.Chromium
    - description: Chromium default configuration managed by Salt state tool-chromium.policies
    - organization: salt.tool
    - removaldisallowed: false
    - ptype: org.chromium.Chromium
    - content:
      - {{ {'ExtensionInstallSources': chromium._policies.forced.ExtensionInstallSources} | json }}
    # hackityhack for requisites
    - onlyif:
      - test -n '{{ necessary }}'
{%-   endif %}
{%- endif %}
