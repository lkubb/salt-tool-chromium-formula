# vim: ft=sls

{%- if grains.kernel != "Linux" %}

include:
  - .download
  - .install
{%- endif %}
