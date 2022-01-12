{%- set os_code = grains['os'] | capitalize ~ '_' ~ grains['lsb_distrib_codename'] | capitalize -%}

Ensure Debian repositories can be managed by tool-chromium:
  pkg.installed:
    - pkgs:
      - python-apt

# Ungoogled Chromium is distributed via OBS repositories without proprietary codec support.
# Install Flatpak version to have them included. @TODO
Ungoogled Chromium apt repository is available:
  pkgrepo.managed:
    - humanname: Ungoogled Chromium
    - name: deb http://download.opensuse.org/repositories/home:/ungoogled_chromium/{{ os_code }}/ /
    - file: /etc/apt/sources.list.d/home-ungoogled_chromium.list
    - key_url: https://download.opensuse.org/repositories/home:/ungoogled_chromium/{{ os_code }}/Release.key
