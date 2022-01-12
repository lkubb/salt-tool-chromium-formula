{%- from 'tool-chromium/map.jinja' import chromium -%}

{%- if chromium | traverse('_policies:forced:ExtensionInstallSources') %}
  {%- if 'Windows' == grains.kernel %}
include:
  - .winadm

Local Extension source is allowed to install:
  lgpo.set:
    - computer_policy: {{ {'ExtensionInstallSources': chromium._policies.forced.ExtensionInstallSources} | json }}
    - adml_language: {{ chromium.win_gpo_lang | default('en_US') }}
    - require:
      - sls: {{ slsdpath }}.winadm

Group policies are updated to allow local installation: # suffix to make ID distinct from tool-chrome
  cmd.run:
    - name: gpupdate /wait:0
    - onchanges:
      - Local Extension source is allowed to install

  {%- elif 'Darwin' == grains.kernel %}
    {%- set necessary = 'yes' if not
           chromium._policies.forced.ExtensionInstallSources ==
           salt['macprofile.item_keys']('salt.tool.org.chromium.Chromium') |
           traverse('ProfileItems:PayloadContent:ExtensionInstallSources') else '' %}

Local Extension source is allowed to install:
  macprofile.installed:
    - name: salt.tool.org.chromium.Chromium
    - description: Chromium default configuration managed by Salt state tool-chromium.policies
    - organization: salt.tool
    - removaldisallowed: False
    - ptype: org.chromium.Chromium
    - content:
      - {{ {'ExtensionInstallSources': chromium._policies.forced.ExtensionInstallSources} | json }}
    # hackityhack for requisites
    - onlyif:
      - test -n "{{ necessary }}"
  {%- endif %}
{%- endif %}
