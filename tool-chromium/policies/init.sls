{%- from 'tool-chromium/map.jinja' import chromium -%}

include:
{#- first sync provided extensions #}
{%- if chromium.get('_local_extensions') %}
  - .synclocalexts
{%- endif %}
{#- then download extensions marked for download #}
{%- if chromium.get('_download_extensions') %}
  - .downloadexts
{%- endif %}
{#- then, on MacOS/Windows, install locally provided exts before enforcing policies,
    otherwise the automatic installation will fail and manual one will be denied.
    We still need to whitelist the local folder, which will be taken care of by allowlocal.sls #}
{%- if grains['kernel'] in ['Windows', 'Darwin'] %}
  - .installexts
{%- endif %}
{#- then install enterprise policies to be able to install extensions from local source #}
  - .install
