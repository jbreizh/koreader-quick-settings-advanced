# koreader-quick-settings-advanced
Advanced version of quick-settings patch from qewer33. Mix of personnal and others forks ideas.

## Installation

Drop the `patches/***.lua` files into your `koreader/patches/` directory. Place all the icons in the `icons/` folder in your KOReader `icons/` directory.

## Patches

<details>
<summary>
<h3>2-quick-settings.lua</h3>
<img src="./assets/quicksettings.png" alt="quicksettings">
</summary>

Adds a Quick Settings tab as the first tab in the KOReader top menu. Provides fast access to common actions and device controls without navigating through menus.

**Action buttons** (circular icons with labels):
- Wi-Fi (shows connected SSID, active indicator when connected)
- Night mode (active indicator when enabled)
- Rotate screen
- USB mass storage
- Calibre wireless connection (active indicator when connected, disabled by default)
- Restart (with confirmation)
- Exit (with confirmation)
- Sleep/Suspend

**Sliders:**
- Frontlight brightness: `[−] [slider] [+] [Max]` with tappable progress bar
- Warmth (if device supports it): `[−] [segmented bar] [+] [Max]`

**Features:**
- Settings menu under **Settings > Quick settings**
- **Buttons** submenu: toggle individual buttons, drag to reorder
- Toggle frontlight and warmth sliders independently
- "Always open on this tab" option to default to Quick Settings when the menu opens
- Active buttons show a light gray fill indicator
- Works in both File Manager and Reader views

</details>

<details>
<summary><h3>2-menu-size.lua</h3></summary>

Increase the max size of the menu from 10 to 20 to use all the vertical space available.

</details>

<details>
<summary><h3>2-exit-button.lua</h3></summary>

**In filemanager :** Add an exit button with the standard cross icon at the left size of the top menu. This exit button close the top menu.

**In reader :** move the existing filemanager button to the left size of the top menu and change his icon with standard cross icon. This exit button close the reader and open the filemanager.

</details>

## Patch Settings

The Quick Settings patch can be configured from "Settings" (Gear icon) -> "Quick settings".

![settings_quicksettings](./assets/settings2.png)
