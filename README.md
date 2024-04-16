# cmake-pear
This repository contains essential CMake functions and modules to streamline the build process and packaging of Pear applications within the [bare-dev](https://github.com/holepunchto/bare-dev) development environment.

## 
### Core Pear Libraries

- add_library(lib ...) : Imports and integrates the necessary libraries for the Appling, libraries include the standard `C++` lib, `V8` library for execution, `js` library to provide bindings to v8 and the `pear` library.


### Cross-Platform Appling Build Automation:

- `configure_pear_appling_macos`: Contains macOS-specific settings for the following:
    - App icon generation (`add_macos_iconset`)
    - Entitlements configuration (`add_macos_entitlements`)
    - Creation of the macOS app bundle (`add_macos_bundle`)
    - Code signing (`code_sign_macos`)
- `configure_pear_appling_windows`: Handles Windows-specific tasks like:
    - Manifest generation
    - MSIX package creation (`add_msix_package`)
    - Code signing (`code_sign_windows`)
- `configure_pear_appling_linux`: Responsible for Linux configurations, including:
    - AppImage generation (`add_app_image`).

### Pear Appling Creation:
- `add_pear_appling function`: Streamlines the process of defining and configuring  a new Pear appling. Takes care of:
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

## License

Apache-2.0
