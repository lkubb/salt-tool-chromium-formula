# vim: ft=yaml
# yamllint disable rule:comments-indentation
---
tool_global:
  users:
    user:
      completions: .completions
      configsync: true
      persistenv: .bash_profile
      rchook: .bashrc
      xdg: true
      chromium:
        flags:
          - enable-webrtc-hide-local-ips-with-mdns@1
          - extension-mime-request-handling@2
tool_chromium:
  lookup:
    master: template-master
    # Just for testing purposes
    winner: lookup
    added_in_lookup: lookup_value

    pkg:
      name: chromium
      enable_repo:
        - stable
    paths:
      confdir: '.config/chromium'
      conffile: 'config'
  extensions:
    absent:
      - tampermonkey
    chromium_web_store: true
    defaults:
      installation_mode: normal_installed
      override_update_url: false
      update_url: https://clients2.google.com/service/update2/crx
    forced: false
    local:
      source: /opt/chromium_extensions
      sync: true
    wanted:
      - bitwarden
      - ublock-origin:
          installation_mode: force_installed
          runtime_blocked_hosts:
            - '*://*.supersensitive.bank'
      - metamask:
          blocked_permissions:
            - geolocation
          local: true
          local_version: 10.8.1
          toolbar_pin: force_pinned
  policies:
    forced:
      SSLErrorOverrideAllowed: false
      SSLVersionMin: tls1.2
    recommended:
      AutofillCreditCardEnabled: false
      BlockThirdPartyCookies: true
      BookmarkBarEnabled: true
      BrowserNetworkTimeQueriesEnabled: false
      BrowserSignin: 0
      BuiltInDnsClientEnabled: false
      MetricsReportingEnabled: false
      PromotionalTabsEnabled: false
      SafeBrowsingExtendedReportingEnabled: false
      SearchSuggestEnabled: false
      ShowFullUrlsInAddressBar: true
      SyncDisabled: true
      UrlKeyedAnonymizedDataCollectionEnabled: false
      UserFeedbackAllowed: false
  update_auto: true
  version: latest

  tofs:
    # The files_switch key serves as a selector for alternative
    # directories under the formula files directory. See TOFS pattern
    # doc for more info.
    # Note: Any value not evaluated by `config.get` will be used literally.
    # This can be used to set custom paths, as many levels deep as required.
    files_switch:
      - any/path/can/be/used/here
      - id
      - roles
      - osfinger
      - os
      - os_family
    # All aspects of path/file resolution are customisable using the options below.
    # This is unnecessary in most cases; there are sensible defaults.
    # path_prefix: template_alt
    # dirs:
    #   files: files_alt
    #   default: default_alt
    # The entries under `source_files` are prepended to the default source files
    # given for the state
    # source_files:
    #   tool-chromium-config-file-file-managed:
    #     - 'example_alt.tmpl'
    #     - 'example_alt.tmpl.jinja'

  # Just for testing purposes
  winner: pillar
  added_in_pillar: pillar_value
