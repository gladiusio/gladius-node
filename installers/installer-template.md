# Gladius Installer Template (0.3.0)
## Variables

**MyAppName: "Gladius Node"**

**MyAppVersion "0.3.0"**

**MyAppPublisher "Gladius Network, LLC"**

**MyAppURL: "https://gladius.io"**

**MyAppExeName: "gladius_electron.exe"** (This is the entry point for the desktop shortcut for Windows)

**$BASE_DIR: The main application folder**

**$CONFIG_DIR: The config folder**

## Resources

**LicenseFile: https://github.com/gladiusio/gladius-node/blob/master/LICENSE**

**InfoAfterFile: https://github.com/gladiusio/gladius-node/tree/master/installers/gladius-node-win-installer/AfterText.rtf**

**README: https://github.com/gladiusio/gladius-node/blob/master/README.md**

**Icons & Graphics: https://github.com/gladiusio/gladius-node/tree/master/installers & Gladius Resources (Google Drive)**

## Dirs & Files

### Dirs
`$BASE_DIR`
- Linux: TBD
- macOS: `Applications`
- Windows: `Program Files (x86)/Gladius Node`

`$CONFIG_DIR`
- Linux/macOS: `~/.config/gladius`
- Windows: `C:/Users/{user}/.gladius`

`$CONFIG_DIR/content`
- Take from latest release

### Files

**Source:** `gladius`
- **Destination Dir:** `$BASE_DIR`

**Source:** `gladius-networkd`
- **Destination Dir:** `$BASE_DIR`

**Source:** `gladius-controld`
- **Destination Dir:** `$BASE_DIR`

**Source:** `LICENSE.txt`
- **Destination Dir:** `$BASE_DIR`

**Source:** `AfterText.rtf`
- **Destination Dir:** `$BASE_DIR`

**Source:** `README.md`
- **Destination Dir:** `$BASE_DIR`

**Source:** Icons/Graphics \*
- **Destination Dir:** `$BASE_DIR`

**Source:** `Gladius-win32-x64\*`
- **Destination Dir:** `$BASE_DIR\Gladius-$OS-$ARCH`   

**Source:** `gladius-controld.toml`
- **Destination Dir:** `$CONFIG_DIR`

**Source:** `gladius-networkd.toml`
- **Destination Dir:** `$CONFIG_DIR`


## Actions

**Install**

- create desktop icon (Windows)

- create $BASE_DIR and $CONFIG_DIR

- add resources to $BASE_DIR and $CONFIG_DIR

- add binaries to path/bin

- install `controld` and `networkd` as services

- start `controld` and `networkd` as services


**Uninstall**

- remove gladius from path/bin

- remove gladius files from `$BASE_DIR`

- remove `/content`, `gladius-controld.toml`, and `gladius-networkd.toml` from `$CONFIG_DIR`

- stop `controld` and `networkd` services

- uninstall `controld` and `networkd` as services