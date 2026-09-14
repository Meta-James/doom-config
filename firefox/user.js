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

// Compact density is a Firefox feature that is hidden rather than absent: this
// pref only makes "Compact" appear in Customize's density menu, which still
// has to be picked once by hand. It pins nothing -- the density itself stays a
// UI choice -- which is why it belongs here and the density does not.
user_pref("browser.compactmode.show", true);

// One ordered list per role, shared with Emacs. `font.name-list.*' is a
// priority list -- the first installed family wins -- which is the same rule
// `+my/font-family' applies on the Emacs side, so the two ends agree by
// construction rather than by being kept in step. These three lines are
// generated from `+my/font-families' in config.org; edit the list there.
// Pinned, because the whole point is that both applications agree, which a
// setting fiddled with in one of them does not survive.
user_pref("font.name-list.serif.x-western", "Literata, IBM Plex Serif, EB Garamond, Vollkorn, Charis SIL, Noto Serif");
user_pref("font.name-list.sans-serif.x-western", "Ubuntu, IBM Plex Sans, Noto Sans, DejaVu Sans");
user_pref("font.name-list.monospace.x-western", "JetBrainsMono Nerd Font, JetBrains Mono, IBM Plex Mono, DejaVu Sans Mono");

// Nothing else. A pref set here cannot be changed from Firefox's own settings
// UI in any lasting way -- the next startup overwrites it. Add a line only for
// something that must be true on every machine, every time.
