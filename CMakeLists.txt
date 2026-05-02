cmake_minimum_required(VERSION 3.21)

project(OpenSSL C)

if(WIN32)
    enable_language(RC)
endif()

function(_openssl_collect_legacy_module_sources output_legacy)
    set(_legacy)

    foreach(_source IN LISTS ARGN)
        if(_source MATCHES "/providers/common/.*\\.c$"
            OR _source MATCHES "/providers/legacyprov\\.c$"
            OR _source MATCHES "/providers/prov_running\\.c$"
            OR _source MATCHES "/providers/implementations/ciphers/cipher_(blowfish|cast5|des|desx|rc2|rc4|rc5|seed).*\\.c$"
            OR _source MATCHES "/providers/implementations/ciphers/cipher_tdes_common\\.c$"
            OR _source MATCHES "/providers/implementations/digests/(digestcommon|md2_prov|md4_prov|mdc2_prov|ripemd_prov|wp_prov)\\.c$"
            OR _source MATCHES "/providers/implementations/kdfs/(pbkdf1|pvkkdf)\\.c$"
            OR _source MATCHES "/providers/implementations/skeymgmt/generic\\.c$")
            list(APPEND _legacy "${_source}")
        endif()
    endforeach()

    list(REMOVE_DUPLICATES _legacy)
    set(${output_legacy} "${_legacy}" PARENT_SCOPE)
endfunction()

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(OpenSSLBootstrap)
include(OpenSSLConfigureCompat)
include(OpenSSLDependencies)
include(OpenSSLSources)

openssl_cmake_load_version(
    "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.dat"
    OPENSSL_VERSION_MAJOR
    OPENSSL_VERSION_MINOR
    OPENSSL_VERSION_PATCH
    OPENSSL_VERSION_PRE_RELEASE
    OPENSSL_VERSION_BUILD_METADATA
    OPENSSL_VERSION_RELEASE_DATE
)

openssl_cmake_detect_target(OPENSSL_CMAKE_TARGET)

option(OPENSSL_CMAKE_BUILD_APPS "Build the openssl command line application" ON)
option(OPENSSL_CMAKE_BUILD_DOCS "Build OpenSSL documentation" OFF)
option(OPENSSL_CMAKE_BUILD_TESTS "Build OpenSSL tests" OFF)
option(OPENSSL_CMAKE_BUILD_SHARED "Build shared libcrypto/libssl" ON)
option(OPENSSL_CMAKE_ENABLE_ASM "Enable perlasm-generated assembly" OFF)
option(OPENSSL_CMAKE_ENABLE_FIPS "Enable the FIPS provider" OFF)
option(OPENSSL_CMAKE_ENABLE_JITTER "Enable libjitterentropy integration" OFF)
option(OPENSSL_CMAKE_ENABLE_KTLS "Enable Kernel TLS support when the target platform supports it" OFF)
option(OPENSSL_CMAKE_ENABLE_LEGACY "Build the built-in legacy provider" ON)
option(OPENSSL_CMAKE_ENABLE_MODULES "Build provider modules instead of built-in providers" OFF)
option(OPENSSL_CMAKE_ENABLE_SCTP "Enable SCTP support when the target platform provides the required headers" OFF)
option(OPENSSL_CMAKE_ENABLE_THREADS "Build with OpenSSL thread support" ON)
option(OPENSSL_CMAKE_ENABLE_ZLIB "Enable static zlib support" OFF)
option(OPENSSL_CMAKE_ENABLE_ZLIB_DYNAMIC "Enable dynamic zlib support" ON)

set(OPENSSL_CMAKE_CONFIGURE_OPTIONS "" CACHE STRING "Semicolon-separated upstream Configure-style options to translate into this CMake bootstrap")
set(OPENSSL_CMAKE_DEPS "AUTO" CACHE STRING "Dependency resolution for optional third-party deps: AUTO, DOWNLOAD, or LOCAL")
set_property(CACHE OPENSSL_CMAKE_DEPS PROPERTY STRINGS AUTO DOWNLOAD LOCAL)

set(OPENSSL_CMAKE_INSTALL_OPENSSLDIR "etc/ssl" CACHE STRING "OpenSSL runtime configuration directory")
set(OPENSSL_CMAKE_INSTALL_MODULESDIR "lib/ossl-modules" CACHE STRING "OpenSSL provider modules directory")
set(OPENSSL_CMAKE_JITTER_INCLUDE_DIR "" CACHE PATH "Directory containing jitterentropy.h when OPENSSL_CMAKE_ENABLE_JITTER is ON")
set(OPENSSL_CMAKE_JITTER_LIBRARY "" CACHE FILEPATH "Path to or containing the jitterentropy library when OPENSSL_CMAKE_ENABLE_JITTER is ON")
set(OPENSSL_CMAKE_ZLIB_INCLUDE_DIR "" CACHE PATH "Directory containing zlib.h when zlib support is enabled")
set(OPENSSL_CMAKE_ZLIB_LIBRARY "" CACHE FILEPATH "Path to or containing the zlib library when static zlib support is enabled")

openssl_cmake_apply_configure_compat()

if(NOT OPENSSL_CMAKE_DEPS MATCHES "^(AUTO|DOWNLOAD|LOCAL)$")
    message(FATAL_ERROR "OPENSSL_CMAKE_DEPS must be one of AUTO, DOWNLOAD, or LOCAL.")
endif()

if(OPENSSL_CMAKE_ENABLE_ZLIB AND OPENSSL_CMAKE_ENABLE_ZLIB_DYNAMIC)
    message(FATAL_ERROR "OPENSSL_CMAKE_ENABLE_ZLIB and OPENSSL_CMAKE_ENABLE_ZLIB_DYNAMIC are mutually exclusive.")
endif()

if(OPENSSL_CMAKE_ENABLE_MODULES AND NOT OPENSSL_CMAKE_BUILD_SHARED)
    message(FATAL_ERROR "OPENSSL_CMAKE_ENABLE_MODULES currently requires OPENSSL_CMAKE_BUILD_SHARED=ON in this bootstrap.")
endif()

if(NOT WIN32 AND OPENSSL_CMAKE_ENABLE_THREADS)
    find_package(Threads REQUIRED)
endif()

openssl_cmake_resolve_zlib("${CMAKE_CURRENT_SOURCE_DIR}")
openssl_cmake_resolve_jitter("${CMAKE_CURRENT_SOURCE_DIR}")

if(OPENSSL_CMAKE_ENABLE_ASM)
    message(FATAL_ERROR "OPENSSL_CMAKE_ENABLE_ASM is not implemented yet. This bootstrap currently targets the no-asm path.")
endif()

if(OPENSSL_CMAKE_ENABLE_FIPS)
    message(FATAL_ERROR "OPENSSL_CMAKE_ENABLE_FIPS is not implemented yet. This bootstrap currently targets the no-fips path.")
endif()

if(OPENSSL_CMAKE_BUILD_TESTS)
    message(FATAL_ERROR "OPENSSL_CMAKE_BUILD_TESTS is not implemented yet in this bootstrap.")
endif()

if(OPENSSL_CMAKE_BUILD_DOCS)
    message(FATAL_ERROR "OPENSSL_CMAKE_BUILD_DOCS is not implemented yet in this bootstrap.")
endif()

openssl_cmake_configure_target(
    TARGET_NAME "${OPENSSL_CMAKE_TARGET}"
    ENABLE_THREADS ${OPENSSL_CMAKE_ENABLE_THREADS}
    ENABLE_ZLIB ${OPENSSL_CMAKE_ENABLE_ZLIB}
    ENABLE_ZLIB_DYNAMIC ${OPENSSL_CMAKE_ENABLE_ZLIB_DYNAMIC}
    ENABLE_MODULES ${OPENSSL_CMAKE_ENABLE_MODULES}
)

math(EXPR OPENSSL_CMAKE_CONFIGURED_API "${OPENSSL_VERSION_MAJOR} * 10000 + ${OPENSSL_VERSION_MINOR} * 100")
list(APPEND OPENSSL_CMAKE_OPENSSL_API_DEFINES "OPENSSL_CONFIGURED_API=${OPENSSL_CMAKE_CONFIGURED_API}")
if(NOT DEFINED OPENSSL_CMAKE_RAND_SEED_DEFINES OR OPENSSL_CMAKE_RAND_SEED_DEFINES STREQUAL "")
    set(OPENSSL_CMAKE_RAND_SEED_DEFINES OPENSSL_RAND_SEED_OS)
endif()

list(APPEND OPENSSL_CMAKE_OPENSSL_FEATURE_DEFINES ${OPENSSL_CMAKE_COMPAT_FEATURE_DEFINES})
list(APPEND OPENSSL_CMAKE_DISABLED_FEATURES ${OPENSSL_CMAKE_COMPAT_DISABLED_FEATURES})
list(APPEND OPENSSL_CMAKE_DISABLED_PROTOCOLS ${OPENSSL_CMAKE_COMPAT_DISABLED_PROTOCOLS})
list(APPEND OPENSSL_CMAKE_DISABLED_ALGORITHMS ${OPENSSL_CMAKE_COMPAT_DISABLED_ALGORITHMS})

if(NOT OPENSSL_CMAKE_ENABLE_JITTER)
    list(APPEND OPENSSL_CMAKE_OPENSSL_FEATURE_DEFINES OPENSSL_NO_JITTER)
    list(APPEND OPENSSL_CMAKE_DISABLED_FEATURES jitter)
endif()

if(NOT OPENSSL_CMAKE_ENABLE_LEGACY)
    list(APPEND OPENSSL_CMAKE_OPENSSL_FEATURE_DEFINES OPENSSL_NO_LEGACY)
    list(APPEND OPENSSL_CMAKE_DISABLED_FEATURES legacy)
endif()

if(OPENSSL_CMAKE_ENABLE_KTLS AND NOT CMAKE_SYSTEM_NAME MATCHES "Linux|FreeBSD")
    message(FATAL_ERROR "OPENSSL_CMAKE_ENABLE_KTLS is only supported on Linux and FreeBSD in this bootstrap.")
endif()
if(NOT OPENSSL_CMAKE_ENABLE_KTLS)
    list(APPEND OPENSSL_CMAKE_OPENSSL_FEATURE_DEFINES OPENSSL_NO_KTLS)
    list(APPEND OPENSSL_CMAKE_DISABLED_FEATURES ktls)
endif()

if(OPENSSL_CMAKE_ENABLE_SCTP AND WIN32)
    message(FATAL_ERROR "OPENSSL_CMAKE_ENABLE_SCTP is not supported on Windows in this bootstrap.")
endif()
if(NOT OPENSSL_CMAKE_ENABLE_SCTP)
    list(APPEND OPENSSL_CMAKE_OPENSSL_FEATURE_DEFINES OPENSSL_NO_SCTP)
    list(APPEND OPENSSL_CMAKE_DISABLED_FEATURES sctp)
endif()

list(APPEND OPENSSL_CMAKE_OPENSSL_FEATURE_DEFINES OPENSSL_NO_BROTLI OPENSSL_NO_ZSTD)
list(REMOVE_DUPLICATES OPENSSL_CMAKE_OPENSSL_FEATURE_DEFINES)
list(REMOVE_DUPLICATES OPENSSL_CMAKE_DISABLED_FEATURES)
list(REMOVE_DUPLICATES OPENSSL_CMAKE_DISABLED_PROTOCOLS)
list(REMOVE_DUPLICATES OPENSSL_CMAKE_DISABLED_ALGORITHMS)

message(STATUS "OpenSSL CMake bootstrap target: ${OPENSSL_CMAKE_TARGET}")
message(STATUS "OpenSSL version: ${OPENSSL_VERSION_MAJOR}.${OPENSSL_VERSION_MINOR}.${OPENSSL_VERSION_PATCH}${OPENSSL_VERSION_PRE_RELEASE}")
if(OPENSSL_CMAKE_ENABLE_ZLIB)
    message(STATUS "OpenSSL zlib support: ON (${OPENSSL_CMAKE_ZLIB_ORIGIN})")
elseif(OPENSSL_CMAKE_ENABLE_ZLIB_DYNAMIC)
    message(STATUS "OpenSSL zlib-dynamic support: ON (${OPENSSL_CMAKE_ZLIB_ORIGIN})")
else()
    message(STATUS "OpenSSL zlib support: OFF")
endif()
if(OPENSSL_CMAKE_ENABLE_JITTER)
    message(STATUS "OpenSSL jitter support: ON (${OPENSSL_CMAKE_JITTER_ORIGIN})")
else()
    message(STATUS "OpenSSL jitter support: OFF")
endif()
message(STATUS "OpenSSL legacy provider: ${OPENSSL_CMAKE_ENABLE_LEGACY}")
message(STATUS "OpenSSL KTLS support: ${OPENSSL_CMAKE_ENABLE_KTLS}")
message(STATUS "OpenSSL SCTP support: ${OPENSSL_CMAKE_ENABLE_SCTP}")
message(STATUS "OpenSSL dependency policy: ${OPENSSL_CMAKE_DEPS}")

set(OPENSSL_GENERATED_ROOT "${CMAKE_CURRENT_BINARY_DIR}/generated")

openssl_cmake_collect_template_inputs(
    "${CMAKE_CURRENT_SOURCE_DIR}"
    OPENSSL_TEMPLATE_INPUTS
)

openssl_cmake_collect_sources(
    "${CMAKE_CURRENT_SOURCE_DIR}"
    ${OPENSSL_CMAKE_BUILD_SHARED}
    OPENSSL_CRYPTO_SOURCES
    OPENSSL_SSL_SOURCES
    OPENSSL_PROVIDER_SOURCES
    OPENSSL_APP_SOURCES
    OPENSSL_APP_LIB_SOURCES
)

set(OPENSSL_BUILTIN_PROVIDER_SOURCES ${OPENSSL_PROVIDER_SOURCES})
set(OPENSSL_LEGACY_MODULE_SOURCES)
if(OPENSSL_CMAKE_ENABLE_MODULES)
    list(FILTER OPENSSL_BUILTIN_PROVIDER_SOURCES EXCLUDE REGEX "/providers/legacyprov\.c$")
endif()
if(OPENSSL_CMAKE_ENABLE_MODULES AND OPENSSL_CMAKE_ENABLE_LEGACY)
    _openssl_collect_legacy_module_sources(
        OPENSSL_LEGACY_MODULE_SOURCES
        ${OPENSSL_PROVIDER_SOURCES}
    )
endif()

file(GLOB OPENSSL_DER_ASN1_FILES CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/providers/common/der/*.asn1")

set(OPENSSL_TEMPLATE_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/cmake/GenerateOpenSSLTemplate.cmake")
set(OPENSSL_BUILDINFO_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/cmake/GenerateOpenSSLBuildInfo.cmake")
set(OPENSSL_PROGS_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/cmake/GenerateOpenSSLProgs.cmake")
set(OPENSSL_TEMPLATE_COMMON_DEPENDS
    "${OPENSSL_TEMPLATE_SCRIPT}"
    "${CMAKE_CURRENT_SOURCE_DIR}/util/perl/OpenSSL/paramnames.pm"
    "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.dat"
    ${OPENSSL_DER_ASN1_FILES}
)

set(OPENSSL_TEMPLATE_OUTPUTS)
set(OPENSSL_GENERATED_INCLUDE_DIRS)
foreach(_template_rel IN LISTS OPENSSL_TEMPLATE_INPUTS)
    set(_template_in "${CMAKE_CURRENT_SOURCE_DIR}/${_template_rel}")
    string(REGEX REPLACE "\\.in$" "" _template_out_rel "${_template_rel}")
    set(_template_out "${OPENSSL_GENERATED_ROOT}/${_template_out_rel}")
    list(APPEND OPENSSL_TEMPLATE_OUTPUTS "${_template_out}")

    add_custom_command(
        OUTPUT "${_template_out}"
        COMMAND
            "${CMAKE_COMMAND}"
            "-DSOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}"
            "-DINPUT_FILE=${_template_in}"
            "-DOUTPUT_FILE=${_template_out}"
            "-DVERSION_MAJOR=${OPENSSL_VERSION_MAJOR}"
            "-DVERSION_MINOR=${OPENSSL_VERSION_MINOR}"
            "-DVERSION_PATCH=${OPENSSL_VERSION_PATCH}"
            "-DVERSION_PRE_RELEASE=${OPENSSL_VERSION_PRE_RELEASE}"
            "-DVERSION_BUILD_METADATA=${OPENSSL_VERSION_BUILD_METADATA}"
            "-DVERSION_RELEASE_DATE=${OPENSSL_VERSION_RELEASE_DATE}"
            "-DTARGET_NAME=${OPENSSL_CMAKE_TARGET}"
            "-DPROCESSOR=${OPENSSL_CMAKE_PROCESSOR}"
            "-DPOINTER_MODEL=${OPENSSL_CMAKE_POINTER_MODEL}"
            "-DRC4_INT=${OPENSSL_CMAKE_RC4_INT}"
            "-DDSO_EXTENSION=${OPENSSL_CMAKE_DSO_EXTENSION}"
            "-DDSO_SCHEME=${OPENSSL_CMAKE_DSO_SCHEME}"
            "-DSYS_DEFINES=${OPENSSL_CMAKE_OPENSSL_SYS_DEFINES}"
            "-DAPI_DEFINES=${OPENSSL_CMAKE_OPENSSL_API_DEFINES}"
            "-DFEATURE_DEFINES=${OPENSSL_CMAKE_OPENSSL_FEATURE_DEFINES}"
            "-DDISABLED_FEATURES=${OPENSSL_CMAKE_DISABLED_FEATURES}"
            "-DDISABLED_PROTOCOLS=${OPENSSL_CMAKE_DISABLED_PROTOCOLS}"
            "-DDISABLED_ALGORITHMS=${OPENSSL_CMAKE_DISABLED_ALGORITHMS}"
            -P "${OPENSSL_TEMPLATE_SCRIPT}"
        DEPENDS "${_template_in}" ${OPENSSL_TEMPLATE_COMMON_DEPENDS}
        VERBATIM
    )

    if(_template_out_rel MATCHES "^providers/implementations/.+\\.inc$")
        get_filename_component(_template_dir "${_template_out}" DIRECTORY)
        list(APPEND OPENSSL_GENERATED_INCLUDE_DIRS "${_template_dir}")
    endif()
endforeach()

set(OPENSSL_BUILDINF_H "${OPENSSL_GENERATED_ROOT}/crypto/buildinf.h")
add_custom_command(
    OUTPUT "${OPENSSL_BUILDINF_H}"
    COMMAND
        "${CMAKE_COMMAND}"
        "-DOUTPUT_FILE=${OPENSSL_BUILDINF_H}"
        "-DCOMPILER=${CMAKE_C_COMPILER_ID} ${CMAKE_C_COMPILER_VERSION} ${CMAKE_C_FLAGS}"
        "-DPLATFORM=${OPENSSL_CMAKE_TARGET}"
        -P "${OPENSSL_BUILDINFO_SCRIPT}"
    DEPENDS "${OPENSSL_BUILDINFO_SCRIPT}"
    VERBATIM
)

set(OPENSSL_PROGS_C "${OPENSSL_GENERATED_ROOT}/apps/progs.c")
set(OPENSSL_PROGS_H "${OPENSSL_GENERATED_ROOT}/apps/progs.h")
set(OPENSSL_APP_RC)
set(OPENSSL_RC_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/cmake/GenerateWindowsRc.cmake")
set(OPENSSL_PROGS_OUTPUTS)
if(OPENSSL_CMAKE_BUILD_APPS)
    set(OPENSSL_PROGS_OUTPUTS "${OPENSSL_PROGS_C}" "${OPENSSL_PROGS_H}")
    set(_app_scan_sources ${OPENSSL_APP_SOURCES} ${OPENSSL_APP_LIB_SOURCES})
    string(JOIN " " _app_scan_sources_arg ${_app_scan_sources})
    add_custom_command(
        OUTPUT ${OPENSSL_PROGS_OUTPUTS}
        COMMAND
            "${CMAKE_COMMAND}"
            "-DOUTPUT_C=${OPENSSL_PROGS_C}"
            "-DOUTPUT_H=${OPENSSL_PROGS_H}"
            "-DSOURCE_FILES=${_app_scan_sources_arg}"
            "-DDISABLED_FEATURES=${OPENSSL_CMAKE_DISABLED_FEATURES}"
            -P "${OPENSSL_PROGS_SCRIPT}"
        DEPENDS ${_app_scan_sources} "${OPENSSL_PROGS_SCRIPT}"
        VERBATIM
    )

    if(WIN32)
        set(OPENSSL_APP_RC "${OPENSSL_GENERATED_ROOT}/apps/openssl.rc")
        add_custom_command(
            OUTPUT "${OPENSSL_APP_RC}"
            COMMAND
                "${CMAKE_COMMAND}"
                "-DOUTPUT_FILE=${OPENSSL_APP_RC}"
                "-DVERSION_MAJOR=${OPENSSL_VERSION_MAJOR}"
                "-DVERSION_MINOR=${OPENSSL_VERSION_MINOR}"
                "-DVERSION_PATCH=${OPENSSL_VERSION_PATCH}"
                "-DVERSION_PRE_RELEASE=${OPENSSL_VERSION_PRE_RELEASE}"
                "-DVERSION_BUILD_METADATA=${OPENSSL_VERSION_BUILD_METADATA}"
                "-DFILE_NAME=openssl"
                "-DFILE_DESCRIPTION=OpenSSL application"
                "-DFILE_TYPE=APP"
                -P "${OPENSSL_RC_SCRIPT}"
            DEPENDS "${OPENSSL_RC_SCRIPT}" "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.dat"
            VERBATIM
        )
    endif()
endif()

set(OPENSSL_COMMON_GENERATED_FILES ${OPENSSL_TEMPLATE_OUTPUTS} "${OPENSSL_BUILDINF_H}")
set(OPENSSL_GENERATED_C_SOURCES)
foreach(_generated_file IN LISTS OPENSSL_COMMON_GENERATED_FILES)
    if(_generated_file MATCHES "\\.c$")
        list(APPEND OPENSSL_GENERATED_C_SOURCES "${_generated_file}")
    endif()
endforeach()

list(APPEND OPENSSL_GENERATED_INCLUDE_DIRS
    "${OPENSSL_GENERATED_ROOT}"
    "${OPENSSL_GENERATED_ROOT}/include"
    "${OPENSSL_GENERATED_ROOT}/crypto"
    "${OPENSSL_GENERATED_ROOT}/apps/include"
    "${OPENSSL_GENERATED_ROOT}/providers/implementations/include"
    "${OPENSSL_GENERATED_ROOT}/providers/common/include"
)
list(REMOVE_DUPLICATES OPENSSL_GENERATED_INCLUDE_DIRS)

set(OPENSSL_COMMON_INCLUDE_DIRS
    "${OPENSSL_GENERATED_ROOT}"
    "${OPENSSL_GENERATED_ROOT}/include"
    "${OPENSSL_GENERATED_ROOT}/crypto"
    "${OPENSSL_GENERATED_ROOT}/providers/implementations/include"
    "${OPENSSL_GENERATED_ROOT}/providers/common/include"
    "${CMAKE_CURRENT_SOURCE_DIR}"
    "${CMAKE_CURRENT_SOURCE_DIR}/include"
    "${CMAKE_CURRENT_SOURCE_DIR}/crypto"
    "${CMAKE_CURRENT_SOURCE_DIR}/providers/common/include"
    "${CMAKE_CURRENT_SOURCE_DIR}/providers/implementations/include"
    "${CMAKE_CURRENT_SOURCE_DIR}/providers/fips/include"
    ${OPENSSL_GENERATED_INCLUDE_DIRS}
)
list(REMOVE_DUPLICATES OPENSSL_COMMON_INCLUDE_DIRS)

set(OPENSSL_APP_INCLUDE_DIRS
    "${OPENSSL_GENERATED_ROOT}/apps"
    "${OPENSSL_GENERATED_ROOT}/apps/include"
    "${CMAKE_CURRENT_SOURCE_DIR}/apps/include"
    ${OPENSSL_COMMON_INCLUDE_DIRS}
)
list(REMOVE_DUPLICATES OPENSSL_APP_INCLUDE_DIRS)

set(OPENSSL_COMMON_DEFINES L_ENDIAN)
list(APPEND OPENSSL_COMMON_DEFINES ${OPENSSL_CMAKE_OS_DEFINES})
list(APPEND OPENSSL_COMMON_DEFINES ${OPENSSL_CMAKE_OPENSSL_FEATURE_DEFINES})
list(APPEND OPENSSL_COMMON_DEFINES ${OPENSSL_CMAKE_RAND_SEED_DEFINES})
if(WIN32)
    list(APPEND OPENSSL_COMMON_DEFINES UNICODE _UNICODE WIN32_LEAN_AND_MEAN _MT)
endif()
if(OPENSSL_CMAKE_ZLIB_ACTIVE)
    list(APPEND OPENSSL_COMMON_DEFINES ZLIB)
    if(OPENSSL_CMAKE_ENABLE_ZLIB_DYNAMIC)
        list(APPEND OPENSSL_COMMON_DEFINES ZLIB_SHARED)
    endif()
endif()

if(OPENSSL_CMAKE_BUILD_SHARED)
    set(OPENSSL_LIBRARY_TYPE SHARED)
else()
    set(OPENSSL_LIBRARY_TYPE STATIC)
endif()

set(OPENSSL_CRYPTO_DEFINES ${OPENSSL_COMMON_DEFINES})
if(OPENSSL_CMAKE_ENABLE_LEGACY AND NOT OPENSSL_CMAKE_ENABLE_MODULES)
    list(APPEND OPENSSL_CRYPTO_DEFINES STATIC_LEGACY)
endif()

add_library(crypto ${OPENSSL_LIBRARY_TYPE}
    ${OPENSSL_CRYPTO_SOURCES}
    ${OPENSSL_BUILTIN_PROVIDER_SOURCES}
    ${OPENSSL_COMMON_GENERATED_FILES}
    ${OPENSSL_GENERATED_C_SOURCES}
)

target_include_directories(crypto
    PUBLIC
        "${OPENSSL_GENERATED_ROOT}/include"
        "${CMAKE_CURRENT_SOURCE_DIR}/include"
    PRIVATE
        ${OPENSSL_COMMON_INCLUDE_DIRS}
)
target_compile_definitions(crypto PRIVATE ${OPENSSL_CRYPTO_DEFINES})
if(WIN32 AND OPENSSL_CMAKE_BUILD_SHARED)
    target_compile_definitions(crypto PRIVATE _WINDLL OPENSSL_BUILD_SHLIBCRYPTO)
endif()
if(OPENSSL_CMAKE_BUILD_SHARED AND OPENSSL_CMAKE_SHARED_LINK_OPTIONS)
    target_link_options(crypto PRIVATE ${OPENSSL_CMAKE_SHARED_LINK_OPTIONS})
endif()
target_link_libraries(crypto PRIVATE ${OPENSSL_CMAKE_SHARED_SYSTEM_LIBS})
if(OPENSSL_CMAKE_ZLIB_ACTIVE)
    target_link_libraries(crypto PRIVATE ${OPENSSL_CMAKE_ZLIB_TARGET})
endif()
if(OPENSSL_CMAKE_ENABLE_JITTER)
    target_link_libraries(crypto PRIVATE ${OPENSSL_CMAKE_JITTER_TARGET})
endif()
if(NOT WIN32 AND OPENSSL_CMAKE_ENABLE_THREADS)
    target_link_libraries(crypto PRIVATE Threads::Threads)
endif()
target_compile_definitions(crypto PRIVATE OPENSSLDIR="${OPENSSL_CMAKE_INSTALL_OPENSSLDIR}")
target_compile_definitions(crypto PRIVATE MODULESDIR="${OPENSSL_CMAKE_INSTALL_MODULESDIR}")

add_library(ssl ${OPENSSL_LIBRARY_TYPE}
    ${OPENSSL_SSL_SOURCES}
    ${OPENSSL_COMMON_GENERATED_FILES}
)
target_include_directories(ssl
    PUBLIC
        "${OPENSSL_GENERATED_ROOT}/include"
        "${CMAKE_CURRENT_SOURCE_DIR}/include"
    PRIVATE
        ${OPENSSL_COMMON_INCLUDE_DIRS}
)
target_compile_definitions(ssl PRIVATE ${OPENSSL_COMMON_DEFINES})
if(WIN32 AND OPENSSL_CMAKE_BUILD_SHARED)
    target_compile_definitions(ssl PRIVATE _WINDLL OPENSSL_BUILD_SHLIBSSL)
endif()
if(OPENSSL_CMAKE_BUILD_SHARED AND OPENSSL_CMAKE_SHARED_LINK_OPTIONS)
    target_link_options(ssl PRIVATE ${OPENSSL_CMAKE_SHARED_LINK_OPTIONS})
endif()
target_link_libraries(ssl PRIVATE crypto)
target_link_libraries(ssl PRIVATE ${OPENSSL_CMAKE_SHARED_SYSTEM_LIBS})

if(WIN32)
    if(OPENSSL_CMAKE_TARGET STREQUAL "mingw64")
        set(OPENSSL_CMAKE_DLL_SUFFIX "-x64")
    elseif(OPENSSL_CMAKE_TARGET STREQUAL "mingwarm64")
        set(OPENSSL_CMAKE_DLL_SUFFIX "-arm64")
    else()
        set(OPENSSL_CMAKE_DLL_SUFFIX "")
    endif()
else()
    set(OPENSSL_CMAKE_DLL_SUFFIX "")
endif()

set_target_properties(crypto PROPERTIES
    OUTPUT_NAME "crypto-${OPENSSL_VERSION_MAJOR}${OPENSSL_CMAKE_DLL_SUFFIX}"
    VERSION "${OPENSSL_VERSION_MAJOR}.${OPENSSL_VERSION_MINOR}.${OPENSSL_VERSION_PATCH}"
    SOVERSION "${OPENSSL_VERSION_MAJOR}"
)
set_target_properties(ssl PROPERTIES
    OUTPUT_NAME "ssl-${OPENSSL_VERSION_MAJOR}${OPENSSL_CMAKE_DLL_SUFFIX}"
    VERSION "${OPENSSL_VERSION_MAJOR}.${OPENSSL_VERSION_MINOR}.${OPENSSL_VERSION_PATCH}"
    SOVERSION "${OPENSSL_VERSION_MAJOR}"
)

if(OPENSSL_CMAKE_ENABLE_MODULES AND OPENSSL_CMAKE_ENABLE_LEGACY)
    set(OPENSSL_MODULE_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/providers")

    add_library(legacy MODULE
        ${OPENSSL_LEGACY_MODULE_SOURCES}
        ${OPENSSL_COMMON_GENERATED_FILES}
        ${OPENSSL_GENERATED_C_SOURCES}
    )
    target_include_directories(legacy PRIVATE
        ${OPENSSL_COMMON_INCLUDE_DIRS}
        "${OPENSSL_GENERATED_ROOT}/include"
        "${CMAKE_CURRENT_SOURCE_DIR}/include"
    )
    target_compile_definitions(legacy PRIVATE
        ${OPENSSL_COMMON_DEFINES}
        OPENSSLDIR="${OPENSSL_CMAKE_INSTALL_OPENSSLDIR}"
        MODULESDIR="${OPENSSL_CMAKE_INSTALL_MODULESDIR}"
    )
    if(WIN32 AND OPENSSL_CMAKE_BUILD_SHARED)
        set_target_properties(legacy PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
    endif()
    if(OPENSSL_CMAKE_SHARED_LINK_OPTIONS)
        target_link_options(legacy PRIVATE ${OPENSSL_CMAKE_SHARED_LINK_OPTIONS})
    endif()
    target_link_libraries(legacy PRIVATE crypto ${OPENSSL_CMAKE_SHARED_SYSTEM_LIBS})
    if(OPENSSL_CMAKE_ZLIB_ACTIVE)
        target_link_libraries(legacy PRIVATE ${OPENSSL_CMAKE_ZLIB_TARGET})
    endif()
    if(OPENSSL_CMAKE_ENABLE_JITTER)
        target_link_libraries(legacy PRIVATE ${OPENSSL_CMAKE_JITTER_TARGET})
    endif()
    if(NOT WIN32 AND OPENSSL_CMAKE_ENABLE_THREADS)
        target_link_libraries(legacy PRIVATE Threads::Threads)
    endif()
    set_target_properties(legacy PROPERTIES
        PREFIX ""
        OUTPUT_NAME "legacy"
        LIBRARY_OUTPUT_DIRECTORY "${OPENSSL_MODULE_OUTPUT_DIR}"
        RUNTIME_OUTPUT_DIRECTORY "${OPENSSL_MODULE_OUTPUT_DIR}"
        ARCHIVE_OUTPUT_DIRECTORY "${OPENSSL_MODULE_OUTPUT_DIR}"
    )
endif()

if(OPENSSL_CMAKE_BUILD_APPS)
    add_library(apps STATIC
        ${OPENSSL_APP_LIB_SOURCES}
        ${OPENSSL_COMMON_GENERATED_FILES}
    )
    target_include_directories(apps PRIVATE ${OPENSSL_APP_INCLUDE_DIRS})
    target_compile_definitions(apps PRIVATE ${OPENSSL_COMMON_DEFINES})
    target_link_libraries(apps PRIVATE crypto ssl)

    add_executable(openssl
        ${OPENSSL_APP_SOURCES}
        ${OPENSSL_PROGS_OUTPUTS}
        ${OPENSSL_APP_RC}
        ${OPENSSL_COMMON_GENERATED_FILES}
    )
    target_include_directories(openssl PRIVATE ${OPENSSL_APP_INCLUDE_DIRS})
    target_compile_definitions(openssl PRIVATE ${OPENSSL_COMMON_DEFINES})
    target_link_libraries(openssl PRIVATE apps ssl crypto)
    target_link_libraries(openssl PRIVATE ${OPENSSL_CMAKE_SHARED_SYSTEM_LIBS})
endif()

install(TARGETS crypto ssl
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
if(TARGET legacy)
    install(TARGETS legacy
        RUNTIME DESTINATION "${OPENSSL_CMAKE_INSTALL_MODULESDIR}"
        LIBRARY DESTINATION "${OPENSSL_CMAKE_INSTALL_MODULESDIR}"
    )
endif()
if(OPENSSL_CMAKE_BUILD_APPS)
    install(TARGETS openssl RUNTIME DESTINATION bin)
endif()
install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/include/openssl/" DESTINATION include/openssl FILES_MATCHING PATTERN "*.h" PATTERN "*.h.in" EXCLUDE)
install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/include/crypto/" DESTINATION include/crypto FILES_MATCHING PATTERN "*.h" PATTERN "*.h.in" EXCLUDE)
install(DIRECTORY "${OPENSSL_GENERATED_ROOT}/include/openssl/" DESTINATION include/openssl FILES_MATCHING PATTERN "*.h")
install(DIRECTORY "${OPENSSL_GENERATED_ROOT}/include/crypto/" DESTINATION include/crypto FILES_MATCHING PATTERN "*.h")
