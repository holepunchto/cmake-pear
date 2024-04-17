# cmake-pear
This repository contains essential CMake functions and modules to streamline the build process and packaging of Pear applications within the [bare-dev](https://github.com/holepunchto/bare-dev) development environment.

## API
`add_pear_appling function`: Streamlines the process of defining and configuring  a new Pear appling. Takes care of:
- Linking the code to the core Pear libraries.
- Managing appling metadata (key, name, version, etc.).
- Calling the appropriate platform-specific packaging functions.


```c
add_pear_appling(
<target> 
KEY <string> 
NAME <string> 
VERSION <string> 
DESCRIPTION <string> 
AUTHOR <string> 

# Optional parameters:
[SPLASH <path>]
[MACOS_ICON <path>]
MACOS_CATEGORY <string>
MACOS_IDENTIFIER <string>
MACOS_SIGNING_IDENTITY <string>
[MACOS_SIGNING_KEYCHAIN <string>]
[MACOS_ENTITLEMENTS <entitlement...>]
[WINDOWS_ICON <path>]
WINDOWS_SIGNING_SUBJECT <string>
WINDOWS_SIGNING_THUMBPRINT <string>
[LINUX_ICON <path>]
LINUX_CATEGORY <string>)
```
### Options
#### Required Parameters
##### `<target>`
The name of the executable target that represents the Pear appling.\
Default  :

##### `KEY <string>`
A unique string identifier for the appling.\
Default  :

##### `NAME <string>`
The display name of the appling, shown to users.\
Default  :

##### `VERSION <string>` 
The version of the Pear appling (e.g., "1.0.0").\
Default  :

##### `DESCRIPTION <string>`
A short description of the app's functionality.\
Default  :

##### `AUTHOR <string>`
Author's name or the name of the organization creating the appling.\
Default  :

#### Optional Parameters
##### `SPLASH <path>`
The path to a splash screen image displayed during appling launch.\
Default  :

##### `MACOS_ICON <path>` 
The path to the icon for the macOS app bundle.\
Default  :

##### `MACOS_CATEGORY <string>`
The category for the app in the macOS App Store or Finder.\
Default  :

##### `MACOS_IDENTIFIER <string>`
A unique bundle identifier for the macOS app.\
Default  :

##### `MACOS_SIGNING_IDENTITY <string>`
macOS code signing identity (from a developer certificate).\
Default  :

##### `MACOS_SIGNING_KEYCHAIN <string>` 
The path to the keychain containing the signing identity.\
Default  :

##### `MACOS_ENTITLEMENTS <entitlement...>` 
A list of macOS entitlements for special permissions.\
Default  :

##### `WINDOWS_ICON <path>` 
The path to the icon for the Windows MSIX package.\
Default  :

##### `WINDOWS_SIGNING_SUBJECT <string>` 
Subject name for Windows code signing.\
Default  :

##### `WINDOWS_SIGNING_THUMBPRINT <string>` 
Thumbprint of the Windows code signing certificate.\
Default  :

##### `LINUX_ICON <path>` 
Path to the icon for the Linux AppImage.\
Default  :

##### `LINUX_CATEGORY <string>` 
The category for the app in Linux application menus.\
Default  :

## License

Apache-2.0
