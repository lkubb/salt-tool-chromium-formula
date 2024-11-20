.. _readme:

Chromium Formula
================

Manages (Ungoogled) Chromium browser in the user environment.

.. contents:: **Table of Contents**
   :depth: 1

Usage
-----
Applying ``tool_chromium`` will make sure (Ungoogled) Chromium is configured as specified.

Note on Local vs External Extensions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This formula provides several ways to install extensions, necessitated by the fact that policies are flaky on (Ungoogled) Chromium.

**Local extensions** are mostly the same as in ``tool_chrome``, i.e. they are sourced from a simulated repository on the minion local filesystem. You can optionally sync them, but need to provide them on the fileserver. The first installation on non-Linux systems is semi-automatic though. See `Local Extensions`_ for details.

**External extensions** are those unlisted on the Chrome Web Store. On non-Linux systems, they will be downloaded automatically and you will be prompted for installation. They will be updated as normal.

For Ungoogled Chromium, even regular extensions will behave as external extensions.

Notes on MacOS/Windows
~~~~~~~~~~~~~~~~~~~~~~
If you (1) have defined extensions and (2a) are using Ungoogled Chromium or (2b) Chromium with extensions from local source or somewhere different than the Chrome Web Store, the installation process will only be semi-automatic. That means Chromium will start and prompt for each affected extension. For vanilla Chromium on MacOS, during the first run of this formula, the flow that needs user input will be:

1. First system prompt for profile installation (allowing local sources, if you have defined local extensions or ones not on the Chrome Web Store).
2. Chromium will be started for each external extension, click ``Add extension``.
3. Second system prompt for final profile installation (all settings)

The first step is not needed for (a) Ungoogled Chromium or (b) if all necessary external sources have already been allowed.

Mind that, should the installation of a ``force_installed`` extension fail, subsequent installation requests **will be denied**. To solve the problem, **delete the system profile** and restart the setup.

All this is caused by Chromium not recognizing properly the computer is managed, unlike Chrome.

Differences from Google Chrome Formula
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- MacOS/Windows: Extensions from other sources cannot be silently installed via Enterprise Policies
  + Chromium: on MacOS, `fails to recognize that the computer is managed <https://chromium.googlesource.com/chromium/src/+/HEAD/base/enterprise_util_mac.mm#168>`_: ``This computer is not detected as enterprise managed so policy can only automatically install extensions hosted on the Chrome Webstore.`` I could not circumvent that, `even with <https://dev.chromium.org/administrators/pre-installed-extensions>`_ ``/Library/Application Support/Chromium/Chromium Master Preferences`` (master preferences on Linux) or `external extensions <https://developer.chrome.com/docs/extensions/mv2/external_extensions/>`_.
  + Ungoogled Chromium: In my testing, installation just failed silently without an error log (local sources). `Even Chrome Web Store extensions cannot be installed that way <https://github.com/Eloston/ungoogled-chromium/issues/1629>`_ at the moment.
- Windows: There are `no official Chromium-specific ADMX/L templates <https://simeononsecurity.ch/github/chromium-admx-templates/>`_. There are `Chromium ADMX/L templates <https://github.com/simeononsecurity/ChromiumADMX/tree/master/en-us>`_ on Github, but they are labeled as "pre-alpha" and have not been updated for a while. They should not be installed with Brave Browser ADML/X templates at the same time.
- In essence, this formula is probably best used on Linux (and MacOS, with limitations). Testing on Windows has not been conducted currently. This formula will probably configure Chrome on there as well, if installed. Not sure at the moment.

Differences when using Ungoogled Chromium
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ungoogled Chromium generally requires the flag ``chrome://flags/#extension-mime-request-handling`` to be set to ``Always prompt for install``. This is not necessary when installing extensions via this formula since they are opened as ``file://`` scheme urls.

Formula
^^^^^^^
- Linux: Ungoogled Chromium is currently installed via OBS repositories. Proprietary codecs are not included there. This can be circumvented by using the `Flatpak version <https://flathub.org/apps/details/com.github.Eloston.UngoogledChromium>`_, but I need to figure out `how to map policies and profiles there <https://github.com/flathub/org.chromium.Chromium#extension-points>`_) exactly.
- Extensions: To (semi-)automatically install extensions, they need to be provided locally once (this is done automatically). Unless you set ``override_update_url``, they will be updated as normal.

Versus Chromium
^^^^^^^^^^^^^^^
This list focuses on important differences for this formula, generally refer to the `official feature list <https://ungoogled-software.github.io/features/>`_ or `FAQ <https://ungoogled-software.github.io/ungoogled-chromium-wiki/faq>`_ instead. On top of or because of removing dependencies on Google services:

* The Chrome Web Store does not recognize it as compatible, therefore extension installation is manual. This can be fixed with `Chromium Web Store <https://github.com/NeverDecaf/chromium-web-store>`_. There is a configuration to install this extension (semi-)automatically, ``extensions:chromium_web_store``.

Local Extensions
~~~~~~~~~~~~~~~~
This formula provides a way to (MacOS/(Windows): semi-) automatically install extensions from a local source. For Ungoogled Chromium, this is the only method to automatically install extensions with this formula currently. For vannilla Chromium, this is necessary to automatically install extensions that are absent from the Chrome Web Store (see `Differences from Google Chrome Formula`_).

Installing from local source means that extensions are **not updated automatically**, (Ungoogled: ofc that's only different when having enabled autoupdate via Chromium Web Store), only when you are ready to do so yourself. This behavior is achieved via ``override_update_url: true``. When set to false, update requests after installation will go to the url specified in the extension's ``manifest.json``.

1. Generally, local extensions need to be found on the minion under the path specified by ``extensions:local:source``, named ``<extension_name>.crx``. E.g. for uBlock Origin on Linux, this would be ``/opt/chromium_extensions/ublock-origin.crx`` by default.

2. When requesting a local source for an extension with ``local: true``, you will need to specify its current version as ``local_version``. Since we are simulating a local repo, that is necessary to generate a sensible response for Chromium update requests.

3. When you update that file to a new version, remember to change the defined version accordingly and apply the states. On the next run, Chrome will be notified of the new version and update.

4. This formula uses a slightly modified TOFS pattern, as most of the ``tool`` formulae do. This is relevant when you provide the extension files for automatic syncing (recommended). They need to be found under one of the following paths (descending priority):

* ``salt://tool_chromium/extensions/<minion_id>/<extension_name>.crx``
* ``salt://tool_chromium/extensions/<os_family>/<extension_name>.crx``
* ``salt://tool_chromium/extensions/default/<extension_name>.crx``

You can disable the automatic syncing of local extensions, but beware that for manual management of your local repository, you need to manage the ``update`` file in there as well.

Configuration
-------------

This formula
~~~~~~~~~~~~
The general configuration structure is in line with all other formulae from the `tool` suite, for details see :ref:`toolsuite`. An example pillar is provided, see :ref:`pillar.example`. Note that you do not need to specify everything by pillar. Often, it's much easier and less resource-heavy to use the ``parameters/<grain>/<value>.yaml`` files for non-sensitive settings. The underlying logic is explained in :ref:`map.jinja`.

User-specific
^^^^^^^^^^^^^
The following shows an example of ``tool_chromium`` per-user configuration. If provided by pillar, namespace it to ``tool_global:users`` and/or ``tool_chromium:users``. For the ``parameters`` YAML file variant, it needs to be nested under a ``values`` parent key. The YAML files are expected to be found in

1. ``salt://tool_chromium/parameters/<grain>/<value>.yaml`` or
2. ``salt://tool_global/parameters/<grain>/<value>.yaml``.

.. code-block:: yaml

  user:

      # Force the usage of XDG directories for this user.
    xdg: true

      # Persist environment variables used by this formula for this
      # user to this file (will be appended to a file relative to $HOME)
    persistenv: '.config/zsh/zshenv'

      # Add runcom hooks specific to this formula to this file
      # for this user (will be appended to a file relative to $HOME)
    rchook: '.config/zsh/zshrc'

      # This user's configuration for this formula. Will be overridden by
      # user-specific configuration in `tool_chromium:users`.
      # Set this to `false` to disable configuration for this user.
    chromium:
        # Enable Chromium flags via Local State file. To find the correct syntax,
        # it is best to set them manually and look inside "Local State" (json)
        # `browser:enabled_labs_experiments`.
        # `chrome://version` will show an overview of enabled flags in the CLI variant
        # `chrome://flags` shows available flags and highlights
        # those different from default.
        # Mind that CLI switches will not be detected on that page.
      flags:
        - enable-webrtc-hide-local-ips-with-mdns@1
          # This flag is specific to Ungoogled Chromium. It is needed to be set to 2
          # to be able to use Chromium Web Store.
        - extension-mime-request-handling@2

Formula-specific
^^^^^^^^^^^^^^^^

.. code-block:: yaml

  tool_chromium:

      # Which Chromium version to install:
      # latest, ungoogled
    version: latest

      # Install updates on subsequent runs automatically.
    update_auto: true

    extensions:
        # List of extensions that should not be installed.
      absent:
        - tampermonkey
        # (Semi-)automatically install Chromium Web Store extension
        # for Ungoogled (needs user interaction on Mac/Win).
      chromium_web_store: true
        # Defaults for extension installation settings
      defaults:
        installation_mode: normal_installed
        override_update_url: false
        update_url: https://clients2.google.com/service/update2/crx
        # add generated ExtensionSettings to forced policies
        # (necessary on MacOS at least)
      forced: false
        # This formula allows using (Ungoogled: needs to use) extensions from the
        # local file system. Those extensions will not be updated automatically
        # from the web.
      local:
          # When marking extensions as local, use this path on the minion to look for
          # `<extension>.crx` by default.
        source: /opt/chromium_extensions
          # When using local source, sync extensions automatically from the fileserver.
          # You will need to provide the extensions as
          # `tool_chromium/extensions/<tofs_grain>/<extension>.crx`
        sync: true
        # List of extensions that are to be installed. When using policies, can also
        # be specified there manually, but this provides convenience. See
        # `tool_chromium/parameters/defaults.yaml` for a list of available extensions under
        # `lookup:extension_data`. Of course, you can also specify your own on top.
      wanted:
        - bitwarden
          # If you want to override defaults, you can specify them
          # in a mapping like this:
        - ublock-origin:
            installation_mode: force_installed
            runtime_blocked_hosts:
              - '*://*.supersensitive.bank'
          # If you don't want an extension to be loaded from the Chrome Web Store
          # (or it's unlisted there), but rather from a local directory specified in
          # `extensions:defaults:local_source`, set local to true and make sure to
          # provide e.g. `metamask.crx` in there.
          # Since we simulate a local repo, you will need to tell Salt explicitly
          # which version you're providing and need to change the value when you want to
          # make Chromium aware the extension was updated on the next startup.
        - metamask:
            blocked_permissions:
              - geolocation
            local: true
            local_version: 10.8.1
            toolbar_pin: force_pinned

      # This is where you specify enterprise policies.
      # See https://chromeenterprise.google/policies/ for available settings.
    policies:
        # These policies are installed as forced, i.e. cannot be changed
        # by the user. On MacOS at least, this is where ExtensionSettings
        # has to be specified to take effect.
      forced:
        SSLErrorOverrideAllowed: false
        SSLVersionMin: tls1.2
        # These policies are installed as recommended, i.e. only provide
        # default values.
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

      # Default formula configuration for all users.
    defaults:
      flags: default value for all users


Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``tool_chromium``
~~~~~~~~~~~~~~~~~
*Meta-state*.

Performs all operations described in this formula according to the specified configuration.


``tool_chromium.package``
~~~~~~~~~~~~~~~~~~~~~~~~~
Installs the Chromium package only.


``tool_chromium.package.repo``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This state will install the configured Chromium repository.
This works for apt/dnf/yum/zypper-based distributions only by default.


``tool_chromium.flags``
~~~~~~~~~~~~~~~~~~~~~~~



``tool_chromium.policies``
~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_chromium.policies.winadm``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_chromium.default_profile``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_chromium.extensions``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Installs extensions. This state does the following:

1. Syncs local extensions to minion filesystem, if requested.
2. On MacOS/Windows, Chromium extension installation via policies
   is flaky at best. More actions are needed.
3. Downloads extensions marked for download (this depends
   on vanilla Chromium vs Ungoogled, external vs CWS and
   Linux vs Mac/Win).
4. Allows installation from local source via policies, if
   necessary. **Needs user interaction**.
5. Installs extensions by opening them in the browser.
   **Needs user interaction**.

All this needs to happen before any requested extensions are
``force_installed`` via policies because subsequent installation
requests are denied for those. If this goes wrong, the user would
need to uninstall the policies and run this state again.


``tool_chromium.extensions.local``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_chromium.extensions.manual``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_chromium.extensions.manual.allow``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_chromium.extensions.manual.download``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_chromium.extensions.manual.install``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_chromium.clean``
~~~~~~~~~~~~~~~~~~~~~~~
*Meta-state*.

Undoes everything performed in the ``tool_chromium`` meta-state
in reverse order.


``tool_chromium.package.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Removes the Chromium package.


``tool_chromium.package.repo.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This state will remove the configured Chromium repository.
This works for apt/dnf/yum/zypper-based distributions only by default.


``tool_chromium.flags.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_chromium.policies.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_chromium.policies.winadm.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_chromium.extensions.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_chromium.extensions.local.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




Development
-----------

Contributing to this repo
~~~~~~~~~~~~~~~~~~~~~~~~~

Commit messages
^^^^^^^^^^^^^^^

Commit message formatting is significant.

Please see `How to contribute <https://github.com/saltstack-formulas/.github/blob/master/CONTRIBUTING.rst>`_ for more details.

pre-commit
^^^^^^^^^^

`pre-commit <https://pre-commit.com/>`_ is configured for this formula, which you may optionally use to ease the steps involved in submitting your changes.
First install  the ``pre-commit`` package manager using the appropriate `method <https://pre-commit.com/#installation>`_, then run ``bin/install-hooks`` and
now ``pre-commit`` will run automatically on each ``git commit``.

.. code-block:: console

  $ bin/install-hooks
  pre-commit installed at .git/hooks/pre-commit
  pre-commit installed at .git/hooks/commit-msg

State documentation
~~~~~~~~~~~~~~~~~~~
There is a script that semi-autodocuments available states: ``bin/slsdoc``.

If a ``.sls`` file begins with a Jinja comment, it will dump that into the docs. It can be configured differently depending on the formula. See the script source code for details currently.

This means if you feel a state should be documented, make sure to write a comment explaining it.

Todo
----
* allow syncing master_preferences (default settings for new profiles)
* `implement <https://www.reddit.com/r/uBlockOrigin/comments/qm0uxt/comment/hmpc5yl/?utm_source=share&utm_medium=web2x&context=3>`_ `extension-specific <https://github.com/uBlockOrigin/uBlock-issues/wiki/Deploying-uBlock-Origin>`_ `policies <https://dev.chromium.org/administrators/configuring-policy-for-extensions>`_

References
----------
* https://www.chromium.org/administrators/configuring-other-preferences
* https://www.chromium.org/administrators/linux-quick-start
* https://chromeenterprise.google/policies/
* https://support.google.com/chrome/a/answer/9037717
* https://chromium.googlesource.com/chromium/chromium/+/refs/heads/main/chrome/app/policy/policy_templates.json
* https://chromium.googlesource.com/chromium/chromium/+/refs/heads/main/chrome/app/policy/syntax_check_policy_template_json.py
* https://support.google.com/chrome/a/answer/187202?ref_topic=9023406&hl=en
* https://support.google.com/chrome/a/answer/2657289
* https://github.com/andrewpmontgomery/chrome-extension-store
* https://www.chromium.org/administrators/mac-quick-start
* https://support.google.com/chrome/a/answer/9867568?hl=en&ref_topic=9023246
* https://sunweavers.net/blog/node/135

Further reading
---------------
* https://www.debugbear.com/chrome-extension-performance-lookup
