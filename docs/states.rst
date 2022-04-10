Available States
================

The following states are found in this formula:


extensions
----------
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


