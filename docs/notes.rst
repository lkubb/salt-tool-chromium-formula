.. _notes:

Notes
=====
General
~~~~~~~
- Chrome/Chromium somehow comply to XDG spec, but forcing it on MacOS would put cache into profile dir in XDG_CONFIG_HOME. Also dotfiles are not really a thing.
- Installation from local source is possible by adding `file:///absolute/path/*` to `ExtensionInstallSources` in **enforced** policies.
- Distinction between managed=forced and recommended:

  + Linux: /etc/chromium/policies/{managed, recommended}
  + MacOS: (system) profile (plist in `/Library/Managed Preferences[/$USER]`) vs plist in `~/Library/Preferences`
  + Windows: `Google Chrome` vs `Google Chrome – Default Settings (users can override)`

- ExtensionSettings needs to be `minified JSON on Windows <https://support.google.com/chrome/a/answer/7532015>`_.

User Data Directories
~~~~~~~~~~~~~~~~~~~~~
(relative to user home)

.. code-block:: yaml

  Windows: AppData/Local/Chromium/User Data
  Darwin: Library/Application Support/Chromium
  Linux: .config/chromium # actually XDG_CONFIG_HOME
