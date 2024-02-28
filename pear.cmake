set(pear_module_dir "${CMAKE_CURRENT_LIST_DIR}")

include(bare)

bare_target(pear_host)

if(pear_host MATCHES "darwin")
  include(macos)
elseif(pear_host MATCHES "linux")
  include(app-image)
elseif(pear_host MATCHES "win32")
  include(msix)
else()
  message(FATAL_ERROR "Unsupported target '${pear_host}'")
endif()

mirror_drive(
  SOURCE qogbhqbcxknrpeotyz7hk4x3mxuf6d9mhb1dxm6ms5sdn6hh1uso
  DESTINATION "${PROJECT_SOURCE_DIR}/prebuilds"
  PREFIX /${pear_host}
  CHECKOUT 113
  WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
)


mirror_drive(
  SOURCE excdougxjday9q8d13azwwjss8p8r66fhykb18kzjfk9bwaetkuo
  DESTINATION "${PROJECT_SOURCE_DIR}/prebuilds"
  PREFIX /${pear_host}
  CHECKOUT 2
  WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
)

if(NOT TARGET c++)
  add_library(c++ STATIC IMPORTED)

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
  add_library(v8 STATIC IMPORTED)

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
  add_library(js STATIC IMPORTED)

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
  add_library(pear STATIC IMPORTED)

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
endif()

function(configure_pear_appling_macos target)
  set(one_value_keywords
    NAME
    VERSION
    PUBLISHER
    IDENTIFIER
    ICON
    CATEGORY
  )

  cmake_parse_arguments(
    PARSE_ARGV 1 ARGV "" "${one_value_keywords}" ""
  )

  if(NOT ARGV_ICON)
    set(ARGV_ICON "assets/darwin/icon.icns")
  endif()

  set_target_properties(
    ${target}
    PROPERTIES
    OUTPUT_NAME "${ARGV_NAME}"
  )

  add_macos_bundle_info(
    ${target}_bundle_info
    NAME "${ARGV_NAME}"
    VERSION "${ARGV_VERSION}"
    PUBLISHER_DISPLAY_NAME "${ARGV_PUBLISHER}"
    IDENTIFIER "${ARGV_IDENTIFIER}"
    CATEGORY "${ARGV_CATEGORY}"
  )

  add_macos_bundle(
    ${target}_bundle
    DESTINATION "${ARGV_NAME}.app"
    ICON "${ARGV_ICON}"
    TARGET ${target}
  )
endfunction()

function(configure_pear_appling_windows target)
  set(one_value_keywords
    NAME
    VERSION
    PUBLISHER
    DESCRIPTION
    LOGO
    ICON
  )

  cmake_parse_arguments(
    PARSE_ARGV 1 ARGV "" "${one_value_keywords}" ""
  )

  if(NOT ARGV_LOGO)
    set(ARGV_LOGO "assets/win32/icon.png")
  endif()

  if(NOT ARGV_ICON)
    set(ARGV_ICON "assets/win32/icon.ico")
  endif()

  set_target_properties(
    ${target}
    PROPERTIES
    OUTPUT_NAME "${ARGV_NAME}"
  )

  target_link_options(
    ${target}
    PRIVATE
      $<$<CONFIG:Release>:/subsystem:windows /entry:mainCRTStartup>
  )

  add_appx_manifest(
    ${target}_manifest
    NAME "${ARGV_NAME}"
    VERSION "${ARGV_VERSION}"
    DESCRIPTION "${ARGV_DESCRIPTION}"
    PUBLISHER_DISPLAY_NAME "${ARGV_PUBLISHER}"
    UNVIRTUALIZED_PATHS "$(KnownFolder:RoamingAppData)\\pear"
  )

  add_appx_mapping(
    ${target}_mapping
    NAME "${ARGV_MAPPING}"
    LOGO "${ARGV_LOGO}"
    ICON "${ARGV_ICON}"
    TARGET ${target}
  )

  add_msix_package(
    ${target}_msix
    DESTINATION "${ARGV_NAME}.msix"
    DEPENDS ${target}
  )
endfunction()

function(configure_pear_appling_linux target)
  set(one_value_keywords
    NAME
    ICON
    CATEGORY
  )

  cmake_parse_arguments(
    PARSE_ARGV 1 ARGV "" "${one_value_keywords}" ""
  )

  if(NOT ARGV_ICON)
    set(ARGV_ICON "assets/linux/icon.png")
  endif()

  string(TOLOWER ARGV_NAME ARGV_OUTPUT_NAME)

  set_target_properties(
    ${target}
    PROPERTIES
    OUTPUT_NAME "${ARGV_OUTPUT_NAME}"
  )

  add_app_image(
    ${target}_app_image
    NAME "${ARGV_NAME}"
    ICON "${ARGV_ICON}"
    CATEGORIES "${ARGV_CATEGORY}"
    TARGET ${target}
  )
endfunction()

function(add_pear_appling target)
  set(one_value_keywords
    KEY
    NAME
    VERSION
    DESCRIPTION
    PUBLISHER

    MACOS_IDENTIFIER
    MACOS_ICON
    MACOS_CATEGORY

    WINDOWS_LOGO
    WINDOWS_ICON

    LINUX_ICON
    LINUX_CATEGORY
  )

  cmake_parse_arguments(
    PARSE_ARGV 1 ARGV "" "${one_value_keywords}" ""
  )

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
      pear
  )

  if(pear_host MATCHES "darwin")
    configure_pear_appling_macos(
      ${target}
      NAME "${ARGV_NAME}"
      VERSION "${ARGV_VERSION}"
      PUBLISHER "${ARGV_PUBLISHER}"
      IDENTIFIER "${ARGV_MACOS_IDENTIFIER}"
      ICON "${ARGV_MACOS_ICON}"
      CATEGORY "${ARGV_MACOS_CATEGORY}"
    )
  elseif(pear_host MATCHES "win32")
    configure_pear_appling_windows(
      ${target}
      NAME "${ARGV_NAME}"
      VERSION "${ARGV_VERSION}"
      DESCRIPTION "${ARGV_DESCRIPTION}"
      LOGO "${ARGV_WINDOWS_LOGO}"
      ICON "${ARGV_WINDOWS_ICON}"
    )
  elseif(pear_host MATCHES "linux")
    configure_pear_appling_linux(
      ${target}
      NAME "${ARGV_NAME}"
      ICON "${ARGV_LINUX_ICON}"
      CATEGORY "${ARGV_LINUX_CATEGORY}"
    )
  endif()
endfunction()
