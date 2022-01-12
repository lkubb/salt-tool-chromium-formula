include:
{%- if 'Debian' == grains['os_family'] %}
  - .apt
{%- else %}
  - .rpm
{%- endif %}
