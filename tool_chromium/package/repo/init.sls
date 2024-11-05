# vim: ft=sls

{#-
    This state will install the configured Chromium repository.
    This works for apt/dnf/yum/zypper-based distributions only by default.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chromium with context %}

include:
{%- if chromium.lookup.pkg.manager in ["apt", "dnf", "yum", "zypper"] %}
  - {{ slsdotpath }}.install
{%- elif salt["state.sls_exists"](slsdotpath ~ "." ~ chromium.lookup.pkg.manager) %}
  - {{ slsdotpath }}.{{ chromium.lookup.pkg.manager }}
{%- else %}
  []
{%- endif %}
