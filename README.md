# Chromium Formula
Sets up and configures Chromium.

## Usage
Applying `tool-chrome` will make sure Chromium browser is configured as specified.

If you have defined extensions and are using Ungoogled Chromium or Chromium with extensions from local source or somewhere different than the Chrome Web Store, the installation process will only be semi-automatic. That means Chromium will start and prompt for each extension. For vanilla Chromium on MacOS, during the first run of this formula, the flow that needs user input will be:

1. prompt for profile installation (allowing local sources, if you have defined local extensions or ones not on the Chrome Web Store)
2. Chromium will be started for each external extension, click `Add extension`
3. prompt for final profile installation (all settings)

The first point is not needed for Ungoogled Chromium or if all necessary external sources have already been allowed. Mind that, should the installation of a force_installed extension fail, subsequent installation requests will be denied. To solve the problem, delete the system profile and restart the setup.

### Differences from Google Chrome Formula
- MacOS/Windows: Extensions from other sources cannot be silently installed via Enterprise Policies
  + Chromium: on MacOS, [fails to recognize that the computer is managed](https://chromium.googlesource.com/chromium/src/+/HEAD/base/enterprise_util_mac.mm#168): `This computer is not detected as enterprise managed so policy can only automatically install extensions hosted on the Chrome Webstore.` I could not circumvent that, [even with](https://dev.chromium.org/administrators/pre-installed-extensions) `/Library/Application Support/Chromium/Chromium Master Preferences` (master preferences on Linux) or [external extensions](https://developer.chrome.com/docs/extensions/mv2/external_extensions/).
  + Ungoogled Chromium: In my testing, installation just failed silently without an error log (local sources). [Even Chrome Web Store extensions cannot be installed that way](https://github.com/Eloston/ungoogled-chromium/issues/1629) at the moment.
- Windows: There are [no official Chromium-specific ADMX/L templates](https://simeononsecurity.ch/github/chromium-admx-templates/). There are [Chromium ADMX/L templates](https://github.com/simeononsecurity/ChromiumADMX/tree/master/en-us) on Github, but they are labeled as "pre-alpha" and have not been updated for a while. They should not be installed with Brave Browser ADML/X templates at the same time.
- In essence, this formula is probably best used on Linux (and MacOS, with limitations). Testing on Windows has not been conducted currently. This formula will probably configure Chrome on there, not Chromium. Not sure.

### Differences Using Ungoogled Chromium
Note: Ungoogled Chromium generally requires the flag `chrome://flags/#extension-mime-request-handling` to be set to `Always prompt for install`. This is not necessary when installing local extensions via this formula since they are opened as `file://` scheme urls.

#### Formula
- Linux: Ungoogled Chromium is currently installed via OBS repositories. Proprietary codecs are not included there. This can be circumvented by using the [Flatpak version](https://flathub.org/apps/details/com.github.Eloston.UngoogledChromium), but I need to figure out [how to map policies and profiles there](https://github.com/flathub/org.chromium.Chromium#extension-points) exactly.
- Extensions: To (semi-)automatically install extensions, they need to be provided locally. Unless you set `override_update_url`, they will be updated as normal.

#### Versus Chromium
This list focuses on important differences for this formula, generally refer to the [official feature list](https://ungoogled-software.github.io/features/) or [FAQ](https://ungoogled-software.github.io/ungoogled-chromium-wiki/faq) instead. On top of or because of removing dependencies on Google services:

- The Chrome Web Store does not recognize it as compatible, therefore extension installation is manual. This can be fixed with [Chromium Web Store](https://github.com/NeverDecaf/chromium-web-store). There is a pillar configuration to install this extension (semi-)automatically.

### Local Extensions
This formula provides a way to (MacOS/(Windows): semi-) automatically install extensions from a local source.

Installing from local source has two implications:
1. You can easily install extensions not available from the Chrome Web Store. This is especially handy for [Chromium Web Store](https://github.com/NeverDecaf/chromium-web-store) installation.
2. Extensions can be configured to **not update automatically** (Ungoogled: ofc that's only different when having enabled autoupdate via Chromium Web Store), only when you are ready to do so yourself. This is done via "override_update_url". When set to false, update requests after installation will go to the url specified in the extension's `manifest.json`.

Generally, you need to define `ext_local_source`, which is the directory the local extensions should live in.

To get 1) working, you need to define the extension ID in a file that's mapped to `tool-chrome/policies/extensions/<name>.yml`.

Then (and also to get 2) working) specify the extension's version in your pillar. That is necessary to generate a sensible response for Chromium update requests. This will enable `override_update_url` for the extension as well. The extension has to be available from `tool-chrome/files/extensions/<name>.crx`.

When you update that file to a new version, remember to change the pillar version definition accordingly and apply the states. On the next run, Chromium will be notified of the new version and update.

### Local Extensions
This formula provides a way to (MacOS/(Windows): semi-) automatically install extensions from a local source. For Ungoogled Chromium, this is the only method to automatically install extensions with this formula currently. For vannilla Chromium, this is necessary to automatically install extensions that are absent from the Chrome Web Store (see [differences from Chrome formula](#differences-from-google-chrome-formula)).

Installing from local source means that extensions are **not updated automatically**, (Ungoogled: ofc that's only different when having enabled autoupdate via Chromium Web Store), only when you are ready to do so yourself. This is done via "override_update_url". When set to false, update requests after installation will go to the url specified in the extension's `manifest.json`.

1. Generally, you need to define `ext_local_source`, which is the directory the local extensions should live in.
2. Then specify the extension's version in your pillar. That is necessary to generate a sensible response for Chrome update requests. The extension has to be available from `tool-chrome/files/extensions/<name>.crx`.
3. When you update that file to a new version, remember to change the pillar version definition accordingly and apply the states. On the next run, Chrome will be notified of the new version and update.

In the future, I want to automate 2/3 in this formula.

## Configuration
### Pillar
#### General `tool` architecture
Since installing user environments is not the primary use case for saltstack, the architecture is currently a bit awkward. All `tool` formulas assume running as root. There are three scopes of configuration:
1. per-user `tool`-specific
  > e.g. generally force usage of XDG dirs in `tool` formulas for this user
2. per-user formula-specific
  > e.g. setup this tool with the following configuration values for this user
3. global formula-specific (All formulas will accept `defaults` for `users:username:formula` default values in this scope as well.)
  > e.g. setup system-wide configuration files like this

**3** goes into `tool:formula` (e.g. `tool:git`). Both user scopes (**1**+**2**) are mixed per user in `users`. `users` can be defined in `tool:users` and/or `tool:formula:users`, the latter taking precedence. (**1**) is namespaced directly under `username`, (**2**) is namespaced under `username: {formula: {}}`.

```yaml
tool:
######### user-scope 1+2 #########
  users:                         #
    username:                    #
      xdg: true                  #
      dotconfig: true            #
      formula:                   #
        config: value            #
####### user-scope 1+2 end #######
  formula:
    formulaspecificstuff:
      conf: val
    defaults:
      yetanotherconfig: somevalue
######### user-scope 1+2 #########
    users:                       #
      username:                  #
        xdg: false               #
        formula:                 #
          otherconfig: otherval  #
####### user-scope 1+2 end #######
```

#### User-specific
The following shows an example of `tool-chromium` pillar configuration. Namespace it to `tool:users` and/or `tool:chromium:users`.
```yaml
user:
  chromium:
    flags:    # Enable Chromium flags via Local State file.
      # This flag is specific to Ungoogled Chromium. It is needed to be set to 2
      # to be able to use Chromium Web Store.
      - extension-mime-request-handling@2
```

#### Formula-specific
```yaml
tool:
  chromium:
    version: latest                        # latest, ungoogled
    update_auto: false                     # install updates on subsequent runs automatically
    # When using policies.json on Linux, there are two global policy directories, therefore these
    # settings have to be global there. User-specific settings with policies are possible on MacOS
    # afaik where policies are installed via a profile.
    #################################################################################################
    # provide default values for ExtensionSettings
    # see https://support.google.com/chrome/a/answer/9867568?hl=en&ref_topic=9023246
    ext_defaults:
      installation_mode: normal_installed # When not specified, use this extension installation mode by default.
      # Setting update_url to something different than specified in the extension's manifest.json
      # and enabling override of update url will cause even update requests (not just installation)
      # to be routed there instead of the official source. For local extensions, this is set automatically.
      override_update_url: false
      # If you want to update from another repo by default, specify it here.
      # For local extensions, this is set automatically.
      update_url: https://clients2.google.com/service/update2/crx 
    # This formula allows using (Ungoogled: needs to use) extensions from the local file system.
    # Those extensions will not be updated automatically from the web. Since we simulate a local repo,
    # you will need to tell salt explicitly which version you're providing and need to change
    # the setting when you want to make Chromium aware the extension was updated on the next startup.
    ext_local_source: /some/path # when marking extensions as local, use this path to look for extension.crx by default
    ext_local_source_sync: true  # when using local source, sync extensions from salt://tool-chromium/files/extensions (you should leave that on, unless you know what you're doing)
    ext_forced: false            # add parsed extension config to forced policies (needed on MacOS/Win)
    ext_chromium_web_store: true # (semi-)automatically install Chromium Web Store extension for Ungoogled (needs ext_local_source on Mac/Win)
    # List of extensions that are to be installed. When using policies, can also be specified there
    # manually, but this provides convenience. see tool-chrome/policies/extensions for list of
    # available extensions
    extensions:
      - bitwarden
      # If you don't want the default extension settings for your policy, you can specify them
      # in a mapping like this:
      - ublock-origin:
          installation_mode: force_installed
          runtime_blocked_hosts:
            - '*://*.supersensitive.bank'
      # If you don't want an extension to be loaded from the Chrome Web Store (or can't),
      # but rather from a local directory specified in tool:chrome:ext_local_source,
      # set local to true and make sure to provide e.g. metamask.crx in there. You will
      # also need to specify the extension version and change it when you update the file
      # to make Chrome aware of it.
      - metamask:
          local: true
          local_version: '10.8.1'
          blocked_permissions:
            - geolocation
          toolbar_pin: force_pinned
    # Specify global Chromium policies here. There are two types, managed (=forced) and
    # recommended (default, but modifiable by users)
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
    # Windows-specific settings when using policies, defaults as seen below
    # To be able to use Group Policies, this formula needs to ensure the ADML/X templates are available. Currently, there are none specific to Chromium.
    # I did not test this formula on Windows so far. This might manage Chrome instead.
    win_gpo_owner: Administrators
    win_gpo_policy_dir: C:/Windows/PolicyDefinitions
    win_gpo_lang: en_US
    # this is the official source for the templates, it's not versioned. this is default
    win_gpo_source: https://dl.google.com/dl/edgedl/chrome/policy/policy_templates.zip
    # specify the source hash to enable verification. by default, verification is skipped (not recommended)
    win_gpo_source_hash: 25c6819e38e26bf87e44d3a0b9ac0cc0843776c271a6fa469679e7fae26a1591

    defaults:   # user-level defaults
      flags:    # Enable Chromium flags via Local State file.
        # This flag is specific to Ungoogled Chromium. It is needed to be set to 2
        # to be able to use Chromium Web Store.
        - extension-mime-request-handling@2
```

## Notes
- Chrome/Chromium somehow comply to XDG spec, but forcing it on MacOS would put cache into profile dir in XDG_CONFIG_HOME. also dotfiles are not really a thing
- installation from local source is possible by adding `file:///absolute/path/*` to `ExtensionInstallSources` in **enforced** policies
- distinction between managed=forced and recommended:
  + Linux: /etc/chromium/policies/{managed, recommended}
  + MacOS: (system) profile (plist in `/Library/Managed Preferences[/$USER]`) vs plist in `~/Library/Preferences`
  + Windows: `Google Chrome` vs `Google Chrome – Default Settings (users can override)`
- ExtensionSettings needs to be [minified JSON on Windows](https://support.google.com/chrome/a/answer/7532015).

### User Data Directories
(relative to user home)
```yaml
Windows: /AppData/Local/Chromium/User Data
Darwin: /Library/Application Support/Chromium
Linux: /.config/chromium # actually XDG_CONFIG_HOME
```

## Todo
- allow syncing master_preferences (default settings for new profiles)
- actually manage user-specific settings
- automatically download external extensions, only request link to `update.xml`

## References
- https://www.chromium.org/administrators/configuring-other-preferences
- https://www.chromium.org/administrators/linux-quick-start
- https://chromeenterprise.google/policies/
- https://support.google.com/chrome/a/answer/9037717
- https://chromium.googlesource.com/chromium/chromium/+/refs/heads/main/chrome/app/policy/policy_templates.json
- https://chromium.googlesource.com/chromium/chromium/+/refs/heads/main/chrome/app/policy/syntax_check_policy_template_json.py
- https://support.google.com/chrome/a/answer/187202?ref_topic=9023406&hl=en
- https://support.google.com/chrome/a/answer/2657289
- https://github.com/andrewpmontgomery/chrome-extension-store
- https://www.chromium.org/administrators/mac-quick-start
- https://support.google.com/chrome/a/answer/9867568?hl=en&ref_topic=9023246
- https://sunweavers.net/blog/node/135

## Further reading
- https://www.debugbear.com/chrome-extension-performance-lookup
