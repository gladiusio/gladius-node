# Gladius Node Manager Windows Installer 🔥

## About
Here lies the source code for the Gladius Node Manager Windows Installer. This is **NOT** the right place if you just want to install the Gladius Node Manager. To install the Gladius Node Manager all you need is the `gladius setup.exe`. This page is about how to use and build our Windows installer "from scratch".

## Installer
The installer was made using [Inno Setup](http://www.jrsoftware.org/isinfo.php)

#### To compile from source:
- Open `install-script.iss` in Inno Setup Compiler
- Download `gladius.exe`, `gladius-controld.exe`, `gladius-networkd.exe`, and `Gladius-win32-x64` from the latest release to the source directory (where the install script lives)
- Compile `(ctrl+f9)`

Please refer to the [Inno Setup Docs](http://www.jrsoftware.org/ishelp/) in order to see how to add or remove features, steps, files, etc...

#### Install Proccess
- Includes/saves all files from the source folder (where the installer script lives) into the install folder
- Create `.gladius` in the `User/$USER` directory and place the config files inside
- Adds `Gladius Node` (electron app) into programs and the desktop (optional)
- Adds the install location to the `PATH`
- Adds `gladius-controld` and `gladius-networkd` as services and starts them
- Assign icons to all of the programs

#### Uninstall Proccess
- Delete all the files from the install directory
- Delete the config files from `.gladius` and deletes `.gladius` if empty (does not delet wallet or key files if present)
- Removes `Gladius Node` from desktop and programs
- Removes install location from `PATH`
- Stops and deletes `gladius-controld` and `gladius-networkd` as services
