// Generated from ~/.config/doom/config.org -- edit there, not here.
// Any change made directly to this file is lost on the next tangle.
// Installed into the active Firefox profile by ~/.local/bin/firefox-chrome-install.
// See docs/decisions.org ADR-043.

// Required since Firefox 69: without this, chrome/userChrome.css and
// chrome/userContent.css are never loaded.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Read by @media -moz-pref() in userChrome.css, not by Firefox itself.
// Puts the tab strip to the right of the address bar on the combined bar.
user_pref("userchrome.navbar-tabs-oneliner.tabs-on-right.enabled", true);

// Also read by @media -moz-pref(), not by Firefox itself. Each gates one
// optional section of userChrome.css, so an experiment can be turned off at
// about:config and judged on the next restart without a retangle. Flipping one
// here is permanent; flipping it at about:config lasts until the next startup.
user_pref("userchrome.autohide-bookmarks.enabled", true);
user_pref("userchrome.autohide-toolbox.enabled", true);

// Nothing else. A pref set here cannot be changed from Firefox's own settings
// UI in any lasting way -- the next startup overwrites it. Add a line only for
// something that must be true on every machine, every time.
