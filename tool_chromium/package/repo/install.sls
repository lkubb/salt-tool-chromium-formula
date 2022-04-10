# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chromium with context %}

{%- if grains['os'] in ['Debian', 'Ubuntu'] %}

Ensure Chromium APT repository can be managed:
  pkg.installed:
    - pkgs:
      - python-apt                    # required by Salt
{%-   if 'Ubuntu' == grains['os'] %}
      - python-software-properties    # to better support PPA repositories
{%-   endif %}
{%- endif %}

{%- for reponame in chromium.lookup.pkg.enablerepo %}

Chromium {{ repo }} repository is available:
  pkgrepo.managed:
{%-   for conf, val in chromium.lookup.pkg.repos[reponame].items() %}
    - {{ conf }}: {{ val }}
{%-   endfor %}
{%-   if chromium.lookup.pkg.manager in ['dnf', 'yum', 'zypper'] %}
    - enabled: 1
{%-   endif %}
    - require_in:
      - Chromium is installed
{%- endfor %}

{%- for reponame, repodata in chromium.lookup.pkg.repos.items() %}
{%-   if reponame not in chromium.lookup.pkg.enablerepo %}

Chromium {{ reponame }} repository is disabled:
  pkgrepo.absent:
{%-     for conf in ['name', 'ppa', 'ppa_auth', 'keyid', 'keyid_ppa', 'copr'] %}
{%-       if conf in repodata %}
    - {{ conf }}: {{ repodata[conf] }}
{%-       endif %}
{%-     endfor %}
    - require_in:
      - Chromium is installed
{%-   endif %}
{%- endfor %}
