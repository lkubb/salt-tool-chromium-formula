# vim: ft=sls

{#-
    This state will remove the configured Chromium repository.
    This works for apt/dnf/yum/zypper-based distributions only by default.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chromium with context %}


{%- if chromium.lookup.pkg.manager not in ["apt", "dnf", "yum", "zypper"] %}
{%-   if salt["state.sls_exists"](slsdotpath ~ "." ~ chromium.lookup.pkg.manager ~ ".clean") %}

include:
  - {{ slsdotpath ~ "." ~ chromium.lookup.pkg.manager ~ ".clean" }}
{%-   endif %}

{%- else %}


{%-   for reponame, repodata in chromium.lookup.pkg.repos.items() %}

Chromium {{ reponame }} repository is absent:
  pkgrepo.absent:
{%-     for conf in ["name", "ppa", "ppa_auth", "keyid", "keyid_ppa", "copr"] %}
{%-       if conf in repodata %}
    - {{ conf }}: {{ repodata[conf] }}
{%-       endif %}
{%-     endfor %}
{%-   endfor %}
{%- endif %}
