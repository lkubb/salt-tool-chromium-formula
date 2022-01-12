{#- For Fedora, this updates automatically. For other rpm-based distributions, I'm not even sure
    if the official rpm builds work. CentOS is dropped, but needed extra work. -#}

{%- set major = grains['osmajorrelease'] if 'Fedora' == grains['os'] else '35' -%}

Ungoogled Chromium RPM repository is available:
  pkgrepo.managed:
    - humanname: home_ungoogled_chromium
    - name: home:ungoogled_chromium (Fedora_{{ major }})
    - type: rpm-md
    - baseurl: https://download.opensuse.org/repositories/home:/ungoogled_chromium/Fedora_{{ major }}/
    - key_url: https://download.opensuse.org/repositories/home:/ungoogled_chromium/Fedora_{{ major }}/repodata/repomd.xml.key
    - gpgcheck: 1
