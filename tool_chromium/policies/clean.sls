# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chromium with context %}

{%- if 'Windows' == grains.kernel %}

include:
  - {{ slsdotpath }}.winadm.clean
{%- endif %}

{%- if 'Windows' == grains.kernel %}

Chromium forced policies are removed from Group Policy:
  lgpo.set:
    - computer_policy: {}
    - adml_language: {{ chromium.lookup.win_gpo.lang }}
    # this might very well not be allowed @FIXME
    - require_in:
      - sls: {{ slsdotpath }}.winadm.clean

Chromium recommended policies are removed from Group Policy:
  lgpo.set:
    - user_policy: {}
    - adml_language: {{ chromium.lookup.win_gpo.lang }}
    # this might very well not be allowed @FIXME
    - require_in:
      - sls: {{ slsdotpath }}.winadm.clean

Group policies are updated (Chromium):
  cmd.run:
    - name: gpupdate /wait:0
    - onchanges:
      - Chromium forced policies are removed from Group Policy
      - Chromium recommended policies are removed from Group Policy

{%- elif 'Darwin' == grains.kernel %}

Chromium forced policy profile cannot be silently removed:
  test.show_notification:
    - text: >
        Salt cannot silently remove an installed system profile.
        You will need to do that manually. See
            System Preferences > Profiles

Chromium recommended policies are removed:
  file.absent:
    - name: /Library/Preferences/org.chromium.Chromium.plist
{%-   if require_local_sync %}
    - require:
      - sls: {{ tplroot }}.local_extensions.clean
{%-   endif %}

MacOS plist cache is updated for chromium:
  cmd.run:
    - name: defaults read /Library/Preferences/org.chromium.Chromium.plist
    - onchanges:
      - Chromium recommended policies are removed

{%- else %}

Chromium enforced policies are removed:
  file.absent:
    - name: /etc/chromium/policies/managed/salt_tool_managed_policies.json

Chromium recommended policies are removed:
  file.absent:
    - name: /etc/chromium/policies/recommended/salt_tool_recommended_policies.json
{%- endif %}
