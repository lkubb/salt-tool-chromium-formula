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



