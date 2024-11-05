# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chromium with context %}


include:
  - {{ tplroot }}.extensions
{%- if "Windows" == grains.kernel %}
  - {{ slsdotpath }}.winadm
{%- endif %}


{%- if chromium.get("_policies") %}
{%-   if "Windows" == grains.kernel %}
{%-     if chromium._policies.get("forced") %}

Chromium forced policies are applied as Group Policy:
  lgpo.set:
    - computer_policy: {{ chromium._policies.forced | json }}
    - adml_language: {{ chromium.lookup.win_gpo.lang }}
    - watch_in:
      - Group policies are updated
    - require:
      - sls: {{ slsdotpath }}.winadm
      - sls: {{ tplroot }}.extensions
{%-     endif %}

{%-     if chromium._policies.get("recommended") %}

Chromium recommended policies are applied as Group Policy:
  lgpo.set:
    - user_policy: {{ chromium._policies.recommended | json }}
    - adml_language: {{ chromium.lookup.win_gpo.lang }}
    - watch_in:
      - Group policies are updated (Chromium)
    - require:
      - sls: {{ slsdotpath }}.winadm
      - sls: {{ tplroot }}.extensions
{%-     endif %}

# suffix to make ID distinct from tool-chrome
Group policies are updated (Chromium):
  cmd.wait:  # noqua 123
    - name: gpupdate /wait:0
    - watch: []

{%-   elif "Darwin" == grains.kernel %}
{%-     if chromium._policies.get("forced") %}

Chromium forced policies are applied as profile:
  macprofile.installed:
    - name: salt.tool.org.chromium.Chromium
    - displayname: Chromium configuration (salt-tool)
    - description: Chromium default configuration managed by Salt state tool_chromium.policies.install
    - organization: salt.tool
    - removaldisallowed: false
    - ptype: org.chromium.Chromium
    - content:
      - {{ chromium._policies.forced | json }}
    - require:
      - sls: {{ tplroot }}.extensions
{%-     endif %}

{%-     if chromium._policies.get("recommended") %}

Chromium recommended policies are applied as plist:
  file.serialize:
    - name: /Library/Preferences/org.chromium.Chromium.plist
    - serializer: plist
    - merge_if_exists: true
    - user: root
    - group: {{ chromium.lookup.rootgroup }}
    - mode: '0644'
    - dataset: {{ chromium._policies.recommended | json }}
    - require:
      - sls: {{ tplroot }}.extensions

MacOS plist cache is updated (Chromium):
  cmd.run:
    - name: defaults read /Library/Preferences/org.chromium.Chromium.plist
    - onchanges:
      - Chromium recommended policies are applied as plist
{%-     endif %}

{%-   else %}
{%-     if chromium._policies.get("forced") %}

Chromium enforced policies are synced to json file:
  file.serialize:
    - name: /etc/chromium/policies/managed/salt_tool_managed_policies.json
    - dataset: {{ chromium._policies.forced | json }}
    - serializer: json
    - makedirs: true
    - user: root
    - group: {{ chromium.lookup.rootgroup }}
    - mode: '0644'
    - require:
      - sls: {{ tplroot }}.extensions
{%-     endif %}

{%-     if chromium._policies.get("recommended") %}

Chromium recommended policies are synced to json file:
  file.serialize:
    - name: /etc/chromium/policies/recommended/salt_tool_recommended_policies.json
    - dataset: {{ chromium._policies.recommended | json }}
    - serializer: json
    - makedirs: true
    - user: root
    - group: {{ chromium.lookup.rootgroup }}
    - mode: '0644'
    - require:
      - sls: {{ tplroot }}.extensions
{%-     endif %}
{%-   endif %}
{%- endif %}
