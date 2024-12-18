# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chromium with context %}
{%- set mode = "latest" if chromium.get("update_auto") and grains.kernel != "Darwin" else "installed" %}

include:
  - {{ slsdotpath }}.repo


{%- if grains.kernel == "Windows" %}

Chromium is installed:
  chocolatey.{{ mode }}:
    - name: {{ chromium._pkg }}
{%- else %}

Chromium is installed:
  pkg.{{ mode }}:
    - name: {{ chromium._pkg }}
{%- endif %}

{%- if grains.kernel == "Darwin" %}

Chromium can be launched:
  cmd.run:
    - name: xattr -cr {{ chromium._path }}
    - require_in:
      - Chromium setup is completed
    - onchanges:
      - Chromium is installed
{%- endif %}

Chromium setup is completed:
  test.nop:
    - name: Hooray, Chromium setup has finished.
    - require:
      - Chromium is installed
