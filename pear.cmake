set(pear_module_dir "${CMAKE_CURRENT_LIST_DIR}")

include(bare)

bare_target(pear_host)

if(pear_host MATCHES "darwin")
  include(macos)
elseif(pear_host MATCHES "linux")
  include(app-image)
elseif(pear_host MATCHES "win32")
  include(msix)
  include(windows)
else()
  message(FATAL_ERROR "Unsupported target '${pear_host}'")
endif()

mirror_drive(
  SOURCE qogbhqbcxknrpeotyz7hk4x3mxuf6d9mhb1dxm6ms5sdn6hh1uso
  DESTINATION "${PROJECT_SOURCE_DIR}/prebuilds"
  PREFIX /${pear_host}
  CHECKOUT 128
  WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
)

mirror_drive(
  SOURCE excdougxjday9q8d13azwwjss8p8r66fhykb18kzjfk9bwaetkuo
  DESTINATION "${PROJECT_SOURCE_DIR}/prebuilds"
  PREFIX /${pear_host}
  CHECKOUT 31
  WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
)

if(NOT TARGET c++)
  add_library(c++ STATIC IMPORTED GLOBAL)

  find_library(
    c++
    NAMES c++ libc++
    PATHS "${PROJECT_SOURCE_DIR}/prebuilds/${pear_host}"
    REQUIRED
    NO_DEFAULT_PATH
    NO_CMAKE_FIND_ROOT_PATH
  )

  set_target_properties(
    c++
    PROPERTIES
    IMPORTED_LOCATION "${c++}"
  )
endif()

if(NOT TARGET v8)
  add_library(v8 STATIC IMPORTED GLOBAL)

  find_library(
    v8
    NAMES v8 libv8
    PATHS "${PROJECT_SOURCE_DIR}/prebuilds/${pear_host}"
    REQUIRED
    NO_DEFAULT_PATH
    NO_CMAKE_FIND_ROOT_PATH
  )

  set_target_properties(
    v8
    PROPERTIES
    IMPORTED_LOCATION "${v8}"
  )

  target_link_libraries(
    v8
    INTERFACE
      c++
  )

  if(pear_host MATCHES "linux")
    target_link_libraries(
      v8
      INTERFACE
        m
    )
  elseif(pear_host MATCHES "android")
    find_library(log log)

    target_link_libraries(
      v8
      INTERFACE
        "${log}"
    )
  elseif(pear_host MATCHES "win32")
    target_link_libraries(
      v8
      INTERFACE
        winmm
    )
  endif()
endif()

if(NOT TARGET js)
  add_library(js STATIC IMPORTED GLOBAL)

  find_library(
    js
    NAMES js libjs
    PATHS "${PROJECT_SOURCE_DIR}/prebuilds/${pear_host}"
    REQUIRED
    NO_DEFAULT_PATH
    NO_CMAKE_FIND_ROOT_PATH
  )

  set_target_properties(
    js
    PROPERTIES
    IMPORTED_LOCATION "${js}"
  )

  target_link_libraries(
    js
    INTERFACE
      v8
  )
endif()

if(NOT TARGET pear)
  add_library(pear STATIC IMPORTED GLOBAL)

  find_library(
    pear
    NAMES pear libpear
    PATHS "${PROJECT_SOURCE_DIR}/prebuilds/${pear_host}"
    REQUIRED
    NO_DEFAULT_PATH
    NO_CMAKE_FIND_ROOT_PATH
  )

  set_target_properties(
    pear
    PROPERTIES
    IMPORTED_LOCATION "${pear}"
  )

  target_include_directories(
    pear
    INTERFACE
      "${pear_module_dir}"
  )

  target_link_libraries(
    pear
    INTERFACE
      js
  )

  if(pear_host MATCHES "darwin")
    target_link_libraries(
      pear
      INTERFACE
        "-framework Foundation"
        "-framework CoreMedia"
        "-framework AppKit"
        "-framework AVFoundation"
        "-framework AVKit"
        "-framework WebKit"
    )
  endif()

  if(pear_host MATCHES "win32")
    target_link_libraries(
      pear
      INTERFACE
        Dbghelp
        Iphlpapi
        Shcore
        Userenv
        WindowsApp
    )
  endif()

  if(pear_host MATCHES "linux")
    find_package(PkgConfig REQUIRED)

    pkg_check_modules(GTK4 REQUIRED IMPORTED_TARGET gtk4)

    target_link_libraries(
      pear
      INTERFACE
        PkgConfig::GTK4
    )
  endif()
endif()

function(configure_pear_appling_macos target)
  set(one_value_keywords
    NAME
    VERSION
    AUTHOR
    SPLASH
    IDENTIFIER
    ICON
    CATEGORY
    SIGNING_IDENTITY
    SIGNING_KEYCHAIN
  )

  set(multi_value_keywords
    ENTITLEMENTS
  )

  cmake_parse_arguments(
    PARSE_ARGV 1 ARGV "" "${one_value_keywords}" "${multi_value_keywords}"
  )

  if(NOT ARGV_ICON)
    set(ARGV_ICON "assets/darwin/icon.png")
  endif()

  list(PREPEND ARGV_ENTITLEMENTS
    com.apple.security.cs.allow-jit
    com.apple.security.cs.allow-unsigned-executable-memory
    com.apple.security.cs.allow-dyld-environment-variables
    com.apple.security.cs.disable-library-validation
  )

  set_target_properties(
    ${target}
    PROPERTIES
    OUTPUT_NAME "${ARGV_NAME}"
  )

  add_macos_iconset(
    ${target}_icon
    ICONS
      "${ARGV_ICON}" 512 2x
  )

  add_macos_entitlements(
    ${target}_entitlements
    ENTITLEMENTS ${ARGV_ENTITLEMENTS}
  )

  add_macos_bundle_info(
    ${target}_bundle_info
    NAME "${ARGV_NAME}"
    VERSION "${ARGV_VERSION}"
    PUBLISHER_DISPLAY_NAME "${ARGV_AUTHOR}"
    IDENTIFIER "${ARGV_IDENTIFIER}"
    CATEGORY "${ARGV_CATEGORY}"
    TARGET ${target}
  )

  add_macos_bundle(
    ${target}_bundle
    DESTINATION "${ARGV_NAME}.app"
    TARGET ${target}
    RESOURCES
      FILE "${ARGV_SPLASH}" "splash.png"
    DEPENDS ${target}_icon
  )

  code_sign_macos(
    ${target}_sign
    PATH "${CMAKE_CURRENT_BINARY_DIR}/${ARGV_NAME}.app"
    IDENTITY "${ARGV_SIGNING_IDENTITY}"
    KEYCHAIN "${ARGV_SIGNING_KEYCHAIN}"
    DEPENDS ${target}_bundle
  )
endfunction()

function(configure_pear_appling_windows target)
  set(one_value_keywords
    NAME
    VERSION
    AUTHOR
    DESCRIPTION
    SPLASH
    ICON
    SIGNING_SUBJECT
    SIGNING_THUMBPRINT
  )

  cmake_parse_arguments(
    PARSE_ARGV 1 ARGV "" "${one_value_keywords}" ""
  )

  if(NOT ARGV_ICON)
    set(ARGV_ICON "assets/win32/icon.png")
  endif()

  set_target_properties(
    ${target}
    PROPERTIES
    OUTPUT_NAME "${ARGV_NAME}"
  )

  target_compile_options(
    ${target}
    PRIVATE
      /MT$<$<CONFIG:Debug>:d>
  )

  target_link_options(
    ${target}
    PRIVATE
      $<$<CONFIG:Release>:/subsystem:windows /entry:mainCRTStartup>
  )

  file(READ "${pear_module_dir}/pear.manifest" manifest)

  string(CONFIGURE "${manifest}" manifest)

  file(GENERATE OUTPUT "${ARGV_NAME}.manifest" CONTENT "${manifest}" NEWLINE_STYLE WIN32)

  target_sources(
    ${target}
    PRIVATE
      "${CMAKE_CURRENT_BINARY_DIR}/${ARGV_NAME}.manifest"
  )

  code_sign_windows(
    ${target}_signature
    TARGET ${target}
    THUMBPRINT "${ARGV_SIGNING_THUMBPRINT}"
  )

  add_appx_manifest(
    ${target}_manifest
    NAME "${ARGV_NAME}"
    VERSION "${ARGV_VERSION}"
    DESCRIPTION "${ARGV_DESCRIPTION}"
    PUBLISHER "${ARGV_SIGNING_SUBJECT}"
    PUBLISHER_DISPLAY_NAME "${ARGV_AUTHOR}"
    UNVIRTUALIZED_PATHS "$(KnownFolder:RoamingAppData)\\pear"
  )

  add_appx_mapping(
    ${target}_mapping
    ICON "${ARGV_ICON}"
    TARGET ${target}
    RESOURCES
      FILE "${ARGV_SPLASH}" "splash.png"
  )

  add_msix_package(
    ${target}_package
    DESTINATION "${ARGV_NAME}.msix"
    DEPENDS ${target} ${target}_signature
  )

  code_sign_windows(
    ${target}_package_signature
    PATH "${CMAKE_CURRENT_BINARY_DIR}/${ARGV_NAME}.msix"
    THUMBPRINT "${ARGV_SIGNING_THUMBPRINT}"
    DEPENDS ${target}_package
  )
endfunction()

function(configure_pear_appling_linux target)
  set(one_value_keywords
    NAME
    DESCRIPTION
    ICON
    CATEGORY
    SPLASH
  )

  cmake_parse_arguments(
    PARSE_ARGV 1 ARGV "" "${one_value_keywords}" ""
  )

  if(NOT ARGV_ICON)
    set(ARGV_ICON "assets/linux/icon.png")
  endif()

  string(TOLOWER "${ARGV_NAME}" ARGV_OUTPUT_NAME)

  set_target_properties(
    ${target}
    PROPERTIES
    OUTPUT_NAME "${ARGV_OUTPUT_NAME}"
  )

  add_app_image(
    ${target}_app_image
    NAME "${ARGV_NAME}"
    DESCRIPTION "${ARGV_DESCRIPTION}"
    ICON "${ARGV_ICON}"
    CATEGORY "${ARGV_CATEGORY}"
    TARGET ${target}
    RESOURCES
      FILE "${ARGV_SPLASH}" "splash.png"
  )
endfunction()

function(add_pear_appling target)
  set(one_value_keywords
    KEY
    NAME
    VERSION
    DESCRIPTION
    AUTHOR
    SPLASH

    MACOS_ICON
    MACOS_CATEGORY
    MACOS_IDENTIFIER
    MACOS_SIGNING_IDENTITY
    MACOS_SIGNING_KEYCHAIN

    WINDOWS_ICON
    WINDOWS_SIGNING_SUBJECT
    WINDOWS_SIGNING_THUMBPRINT

    LINUX_ICON
    LINUX_CATEGORY
  )

  set(multi_value_keywords
    MACOS_ENTITLEMENTS
  )

  cmake_parse_arguments(
    PARSE_ARGV 1 ARGV "" "${one_value_keywords}" "${multi_value_keywords}"
  )

  if(NOT ARGV_SPLASH)
    set(ARGV_SPLASH "assets/splash.png")
  endif()

  add_executable(${target})

  set_target_properties(
    ${target}
    PROPERTIES
    POSITION_INDEPENDENT_CODE ON
  )

  target_sources(
    ${target}
    PRIVATE
      "${pear_module_dir}/pear.c"
  )

  target_compile_definitions(
    ${target}
    PRIVATE
      KEY="${ARGV_KEY}"
      NAME="${ARGV_NAME}"
  )

  target_link_libraries(
    ${target}
    PRIVATE
      $<LINK_LIBRARY:WHOLE_ARCHIVE,pear>
  )

  if(pear_host MATCHES "darwin")
    configure_pear_appling_macos(
      ${target}
      NAME "${ARGV_NAME}"
      VERSION "${ARGV_VERSION}"
      AUTHOR "${ARGV_AUTHOR}"
      SPLASH "${ARGV_SPLASH}"
      ICON "${ARGV_MACOS_ICON}"
      CATEGORY "${ARGV_MACOS_CATEGORY}"
      IDENTIFIER "${ARGV_MACOS_IDENTIFIER}"
      ENTITLEMENTS ${ARGV_MACOS_ENTITLEMENTS}
      SIGNING_IDENTITY "${ARGV_MACOS_SIGNING_IDENTITY}"
      SIGNING_KEYCHAIN "${ARGV_MACOS_SIGNING_KEYCHAIN}"
    )
  elseif(pear_host MATCHES "win32")
    configure_pear_appling_windows(
      ${target}
      NAME "${ARGV_NAME}"
      VERSION "${ARGV_VERSION}"
      AUTHOR "${ARGV_AUTHOR}"
      DESCRIPTION "${ARGV_DESCRIPTION}"
      SPLASH "${ARGV_SPLASH}"
      ICON "${ARGV_WINDOWS_ICON}"
      SIGNING_SUBJECT "${ARGV_WINDOWS_SIGNING_SUBJECT}"
      SIGNING_THUMBPRINT "${ARGV_WINDOWS_SIGNING_THUMBPRINT}"
    )
  elseif(pear_host MATCHES "linux")
    configure_pear_appling_linux(
      ${target}
      NAME "${ARGV_NAME}"
      DESCRIPTION "${ARGV_DESCRIPTION}"
      SPLASH "${ARGV_SPLASH}"
      ICON "${ARGV_LINUX_ICON}"
      CATEGORY "${ARGV_LINUX_CATEGORY}"
    )
  endif()
endfunction()
