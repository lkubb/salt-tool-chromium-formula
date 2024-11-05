# vim: ft=sls

{#-
    *Meta-state*.

    Undoes everything performed in the ``tool_chromium`` meta-state
    in reverse order.
#}

include:
  - .policies.clean
  - .flags.clean
  - .package.clean
