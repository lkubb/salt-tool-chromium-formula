{%- from 'tool-chromium/map.jinja' import chromium -%}

include:
  - .installexts
{%- if 'Windows' == grains.kernel %}
  - .winadm

Chromium forced policies are applied as Group Policy:
  lgpo.set:
    - computer_policy: {{ chromium._policies.forced | json }}
    - adml_language: {{ chromium.win_gpo_lang | default('en_US') }}
    - require:
      - sls: {{ slsdotpath }}.winadm
      - sls: {{ slsdotpath }}.synclocaladdons

Chromium recommended policies are applied as Group Policy:
  lgpo.set:
    - user_policy: {{ chromium._policies.recommended | json }}
    - adml_language: {{ chromium.win_gpo_lang | default('en_US') }}
    - require:
      - sls: {{ slsdotpath }}.winadm
      - sls: {{ slsdotpath }}.synclocaladdons

Group policies are updated (Chromium): # suffix to make ID distinct from tool-chrome
  cmd.run:
    - name: gpupdate /wait:0
    - onchanges:
      - Chromium forced policies are applied as Group Policy
      - Chromium recommended policies are applied as Group Policy

{%- elif 'Darwin' == grains.kernel %}

Chromium forced policies are applied as profile:
  macprofile.installed:
    - name: salt.tool.org.chromium.Chromium
    - description: Chromium default configuration managed by Salt state tool-chromium.policies
    - organization: salt.tool
    - removaldisallowed: False
    - ptype: org.chromium.Chromium
    - content:
      - {{ chromium._policies.forced | json }}

Chromium recommended policies are applied as plist:
  file.serialize:
    - name: /Library/Preferences/org.chromium.Chromium.plist
    - serializer: plist
    - merge_if_exists: True
    - user: root
    - group: wheel
    - mode: '0644'
    - dataset: {{ chromium._policies.recommended | json }}

MacOS plist cache is updated (Chromium):
  cmd.run:
    - name: defaults read /Library/Preferences/org.chromium.Chromium.plist
    - onchanges:
      - Chromium recommended policies are applied as plist

{%- else %}

Chromium enforced policies are synced to json file:
  file.serialize:
    - name: /etc/chromium/policies/managed/salt_tool_managed_policies.json
    - dataset: {{ chromium._policies.enforced | json }}
    - serializer: json
    - makedirs: true
    - user: root
    - group: root
    - mode: '0644'

Chromium recommended policies are synced to json file:
  file.serialize:
    - name: /etc/chromium/policies/recommended/salt_tool_recommended_policies.json
    - dataset: {{ chromium._policies.recommended | json }}
    - serializer: json
    - makedirs: true
    - user: root
    - group: root
    - mode: '0644'
{%- endif %}
