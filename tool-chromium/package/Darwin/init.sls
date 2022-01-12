{%- from 'tool-chromium/map.jinja' import chromium -%}

Chromium is installed:
{# Homebrew always installs latest, mac_brew_pkg does not support upgrading a single package #}
  pkg.installed:
    - name: {{ chromium._package }}

Chromium can be launched:
  cmd.run:
    - name: xattr -cr {{ chromium._path }}
    - onchanges:
      - Chromium is installed

Chromium setup is completed:
  test.nop:
    - name: Chromium setup has finished, hooray.
    - require:
      - pkg: {{ chromium._package }}
      - Chromium can be launched
