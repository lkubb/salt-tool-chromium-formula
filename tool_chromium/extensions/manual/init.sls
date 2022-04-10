# -*- coding: utf-8 -*-
# vim: ft=sls

{%- if grains.kernel != 'Linux' %}

include:
  - .download
  - .install
{%- endif %}
