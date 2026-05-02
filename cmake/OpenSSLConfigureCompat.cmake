include_guard(GLOBAL)

set(_OPENSSL_CMAKE_KNOWN_PROTOCOL_OPTIONS
    cmp
    dtls
    dtls1
    dtls1-method
    dtls1_2
    dtls1_2-method
    http
    ktls
    ocsp
    quic
    sctp
    srp
    srtp
    tls
    tls-deprecated-ec
    tls1
    tls1-method
    tls1_1
    tls1_1-method
    tls1_2
    tls1_2-method
    tls1_3
)

set(_OPENSSL_CMAKE_KNOWN_ALGORITHM_OPTIONS
    argon2
    aria
    bf
    blake2
    brotli
    camellia
    cast
    chacha
    cmac
    cms
    comp
    des
    dh
    dsa
    ec
    ec2m
    ecx
    gost
    hmac-drbg-kdf
    idea
    ikev2kdf
    kbkdf
    krb5kdf
    lms
    md2
    md4
    md5
    mdc2
    ml-dsa
    ml-kem
    ocb
    poly1305
    psk
    pvkkdf
    rc2
    rc4
    rc5
    rmd160
    scrypt
    seed
    siphash
    slh-dsa
    siv
    sm2
    sm3
    sm4
    snmpkdf
    srtpkdf
    sshkdf
    sskdf
    whirlpool
    x942kdf
    x963kdf
    zlib
    zstd
)

set(_OPENSSL_CMAKE_KNOWN_FEATURE_OPTIONS
    acvp-tests
    allocfail-tests
    apps
    asan
    asm
    async
    atexit
    autoalginit
    autoerrinit
    autoload-config
    brotli-dynamic
    buildtest-c++
    bulk
    cached-fetch
    crmf
    crypto-mdebug
    ct
    ct-validation
    default-thread-pool
    demos
    deprecated
    docs
    dgram
    dso
    ech
    ec_explicit_curves
    ec_nistp_64_gcc_128
    egd
    err
    external-tests
    filenames
    fips
    fips-jitter
    fips-post
    fips-securitychecks
    fuzz-afl
    fuzz-libfuzzer
    h3demo
    hqinterop
    integrity-only-ciphers
    jitter
    legacy
    makedepend
    module
    msan
    multiblock
    nextprotoneg
    pic
    pie
    pinshared
    posix-io
    rdrand
    rfc3779
    secure-memory
    shared
    sm2-precomp
    sock
    sse2
    ssl-trace
    sslkeylog
    static-vcruntime
    stdio
    tests
    tfo
    thread-pool
    threads
    trace
    ts
    ubsan
    ui-console
    unit-test
    unstable-qlog
    uplink
    weak-ssl-ciphers
    winstore
    zlib-dynamic
    zstd-dynamic
)

set(_OPENSSL_CMAKE_GENERIC_FEATURE_OPTIONS
    async
    atexit
    autoerrinit
    autoload-config
    crmf
    ct
    dgram
    dso
    ech
    ec_explicit_curves
    egd
    err
    filenames
    fips-securitychecks
    integrity-only-ciphers
    multiblock
    nextprotoneg
    posix-io
    rdrand
    rfc3779
    sm2-precomp
    sock
    ssl-trace
    default-thread-pool
    tfo
    thread-pool
    trace
    ts
    ui-console
    uplink
    weak-ssl-ciphers
    winstore
)

set(_OPENSSL_CMAKE_CASCADE_ONLY_FEATURE_OPTIONS
    bulk
)

set(_OPENSSL_CMAKE_DISABLE_CASCADE_BLAKE2 argon2)
set(_OPENSSL_CMAKE_DISABLE_CASCADE_BULK
    shared
    dso
    argon2
    aria
    async
    atexit
    autoload-config
    blake2
    bf
    camellia
    cast
    chacha
    cmac
    cms
    cmp
    comp
    ct
    des
    dgram
    dh
    dsa
    ec
    ech
    filenames
    hmac-drbg-kdf
    idea
    ikev2kdf
    kbkdf
    krb5kdf
    ktls
    lms
    md4
    ml-dsa
    ml-kem
    multiblock
    nextprotoneg
    ocsp
    ocb
    poly1305
    psk
    pvkkdf
    rc2
    rc4
    rmd160
    scrypt
    seed
    siphash
    siv
    slh-dsa
    sm3
    sm4
    snmpkdf
    srp
    srtp
    srtpkdf
    sshkdf
    sskdf
    ssl-trace
    tfo
    ts
    ui-console
    whirlpool
    x942kdf
    x963kdf
    fips-securitychecks
)
set(_OPENSSL_CMAKE_DISABLE_CASCADE_CMAC siv)
set(_OPENSSL_CMAKE_DISABLE_CASCADE_CMP crmf)
set(_OPENSSL_CMAKE_DISABLE_CASCADE_COMP zlib brotli zstd)
set(_OPENSSL_CMAKE_DISABLE_CASCADE_DES mdc2)
set(_OPENSSL_CMAKE_DISABLE_CASCADE_DGRAM dtls quic sctp)
set(_OPENSSL_CMAKE_DISABLE_CASCADE_DSO module)
set(_OPENSSL_CMAKE_DISABLE_CASCADE_DTLS dtls1 dtls1-method dtls1_2 dtls1_2-method)
set(_OPENSSL_CMAKE_DISABLE_CASCADE_EC ec2m ec_explicit_curves sm2 gost ecx tls-deprecated-ec)
set(_OPENSSL_CMAKE_DISABLE_CASCADE_HTTP ocsp)
set(_OPENSSL_CMAKE_DISABLE_CASCADE_LEGACY md2)
set(_OPENSSL_CMAKE_DISABLE_CASCADE_MODULE fips)
set(_OPENSSL_CMAKE_DISABLE_CASCADE_SHARED uplink)
set(_OPENSSL_CMAKE_DISABLE_CASCADE_SM3 sm2)
set(_OPENSSL_CMAKE_DISABLE_CASCADE_QUIC unstable-qlog)
set(_OPENSSL_CMAKE_DISABLE_CASCADE_SOCK dgram tfo)
set(_OPENSSL_CMAKE_DISABLE_CASCADE_STDIO apps egd)
set(_OPENSSL_CMAKE_DISABLE_CASCADE_THREADS thread-pool)
set(_OPENSSL_CMAKE_DISABLE_CASCADE_THREAD_POOL default-thread-pool)
set(_OPENSSL_CMAKE_DISABLE_CASCADE_TLS tls1 tls1-method tls1_1 tls1_1-method tls1_2 tls1_2-method tls1_3)
set(_OPENSSL_CMAKE_DISABLE_CASCADE_TLS1_3 quic)
set(_OPENSSL_CMAKE_DISABLE_CASCADE_ZLIB zlib-dynamic)

function(_openssl_cmake_option_to_key option_name out_var)
    string(TOUPPER "${option_name}" _key_name)
    string(REGEX REPLACE "[^A-Z0-9]" "_" _key_name "${_key_name}")
    set(${out_var} "${_key_name}" PARENT_SCOPE)
endfunction()

function(_openssl_cmake_option_to_define option_name out_var)
    string(TOUPPER "${option_name}" _define_name)
    string(REGEX REPLACE "[^A-Z0-9]" "_" _define_name "${_define_name}")
    set(${out_var} "OPENSSL_NO_${_define_name}" PARENT_SCOPE)
endfunction()

function(_openssl_cmake_normalize_configure_arg input_arg out_arg out_skip_var)
    set(_arg "${input_arg}")
    set(_skip FALSE)

    if(_arg MATCHES "^(enable|disable|no)-ui$")
        set(_arg "${CMAKE_MATCH_1}-ui-console")
    elseif(_arg MATCHES "^(enable|disable|no)-ripemd$")
        set(_arg "${CMAKE_MATCH_1}-rmd160")
    elseif(_arg MATCHES "^(enable|disable|no)-(ssl|ssl2|ssl3|ssl3-method)$")
        set(_skip TRUE)
    elseif(_arg MATCHES "^(enable|disable|no)-(engine|static-engine|dynamic-engine|afalgeng|capieng|devcryptoeng|loadereng|padlockeng|buf-freelists|hw|hw-padlock|heartbeats)$")
        set(_skip TRUE)
    elseif(_arg STREQUAL "shared")
        set(_arg "enable-shared")
    elseif(_arg STREQUAL "threads")
        set(_arg "enable-threads")
    elseif(_arg STREQUAL "sctp")
        set(_arg "enable-sctp")
    elseif(_arg STREQUAL "zlib")
        set(_arg "enable-zlib")
    elseif(_arg STREQUAL "zlib-dynamic")
        set(_arg "enable-zlib-dynamic")
    elseif(_arg STREQUAL "fips")
        set(_arg "enable-fips")
    endif()

    set(${out_arg} "${_arg}" PARENT_SCOPE)
    set(${out_skip_var} "${_skip}" PARENT_SCOPE)
endfunction()

function(_openssl_cmake_collect_explicit_disabled_options input_list output_var)
    set(_disabled)

    foreach(_raw_arg IN LISTS input_list)
        string(STRIP "${_raw_arg}" _arg)
        if(_arg STREQUAL "")
            continue()
        endif()

        _openssl_cmake_normalize_configure_arg("${_arg}" _normalized_arg _skip_arg)
        if(_skip_arg)
            continue()
        endif()

        if(_normalized_arg MATCHES "^enable-(.+)$")
            list(REMOVE_ITEM _disabled "${CMAKE_MATCH_1}")
        elseif(_normalized_arg MATCHES "^(no|disable)-(.+)$")
            list(APPEND _disabled "${CMAKE_MATCH_2}")
            list(REMOVE_DUPLICATES _disabled)
        endif()
    endforeach()

    set(${output_var} "${_disabled}" PARENT_SCOPE)
endfunction()

function(_openssl_cmake_expand_disable_cascades input_list output_var)
    set(_pending ${input_list})
    set(_seen ${input_list})
    set(_cascade_args)

    while(_pending)
        list(POP_FRONT _pending _name)
        _openssl_cmake_option_to_key("${_name}" _cascade_key)
        set(_cascade_var "_OPENSSL_CMAKE_DISABLE_CASCADE_${_cascade_key}")
        if(NOT DEFINED ${_cascade_var})
            continue()
        endif()

        foreach(_child IN LISTS ${_cascade_var})
            list(FIND _seen "${_child}" _seen_index)
            if(NOT _seen_index EQUAL -1)
                continue()
            endif()
            list(APPEND _seen "${_child}")
            list(APPEND _pending "${_child}")
            list(APPEND _cascade_args "no-${_child}")
        endforeach()
    endwhile()

    set(${output_var} "${_cascade_args}" PARENT_SCOPE)
endfunction()

function(openssl_cmake_apply_configure_compat)
    if(NOT DEFINED OPENSSL_CMAKE_CONFIGURE_OPTIONS OR OPENSSL_CMAKE_CONFIGURE_OPTIONS STREQUAL "")
        set(OPENSSL_CMAKE_COMPAT_FEATURE_DEFINES "" PARENT_SCOPE)
        set(OPENSSL_CMAKE_COMPAT_DISABLED_FEATURES "" PARENT_SCOPE)
        set(OPENSSL_CMAKE_COMPAT_DISABLED_PROTOCOLS "" PARENT_SCOPE)
        set(OPENSSL_CMAKE_COMPAT_DISABLED_ALGORITHMS "" PARENT_SCOPE)
        return()
    endif()

    set(_compat_feature_defines)
    set(_compat_disabled_features)
    set(_compat_disabled_protocols)
    set(_compat_disabled_algorithms)
    set(_unsupported_options)

    _openssl_cmake_collect_explicit_disabled_options("${OPENSSL_CMAKE_CONFIGURE_OPTIONS}" _explicit_disabled_options)
    _openssl_cmake_expand_disable_cascades("${_explicit_disabled_options}" _cascade_args)
    set(_compat_args ${OPENSSL_CMAKE_CONFIGURE_OPTIONS} ${_cascade_args})

    foreach(_raw_arg IN LISTS _compat_args)
        string(STRIP "${_raw_arg}" _arg)
        if(_arg STREQUAL "")
            continue()
        endif()

        _openssl_cmake_normalize_configure_arg("${_arg}" _arg _skip_arg)
        if(_skip_arg)
            continue()
        endif()

        if(_arg MATCHES "^--prefix=(.+)$")
            set(CMAKE_INSTALL_PREFIX "${CMAKE_MATCH_1}" CACHE PATH "Install prefix" FORCE)
            continue()
        endif()
        if(_arg MATCHES "^--openssldir=(.+)$")
            set(OPENSSL_CMAKE_INSTALL_OPENSSLDIR "${CMAKE_MATCH_1}" PARENT_SCOPE)
            continue()
        endif()
        if(_arg MATCHES "^--with-zlib-include=(.+)$")
            set(OPENSSL_CMAKE_ZLIB_INCLUDE_DIR "${CMAKE_MATCH_1}" PARENT_SCOPE)
            continue()
        endif()
        if(_arg MATCHES "^--with-zlib-lib=(.+)$")
            set(OPENSSL_CMAKE_ZLIB_LIBRARY "${CMAKE_MATCH_1}" PARENT_SCOPE)
            continue()
        endif()
        if(_arg MATCHES "^--with-jitter-include=(.+)$")
            set(OPENSSL_CMAKE_JITTER_INCLUDE_DIR "${CMAKE_MATCH_1}" PARENT_SCOPE)
            continue()
        endif()
        if(_arg MATCHES "^--with-jitter-lib=(.+)$")
            set(OPENSSL_CMAKE_JITTER_LIBRARY "${CMAKE_MATCH_1}" PARENT_SCOPE)
            continue()
        endif()
        if(_arg MATCHES "^--with-rand-seed=(.+)$")
            set(_seed_defines)
            string(REPLACE "," ";" _seed_list "${CMAKE_MATCH_1}")
            foreach(_seed IN LISTS _seed_list)
                if(_seed STREQUAL "getrandom")
                    list(APPEND _seed_defines OPENSSL_RAND_SEED_GETRANDOM)
                elseif(_seed STREQUAL "devrandom")
                    list(APPEND _seed_defines OPENSSL_RAND_SEED_DEVRANDOM)
                elseif(_seed STREQUAL "os")
                    list(APPEND _seed_defines OPENSSL_RAND_SEED_OS)
                elseif(_seed STREQUAL "egd")
                    list(APPEND _seed_defines OPENSSL_RAND_SEED_EGD)
                elseif(_seed STREQUAL "none")
                    list(APPEND _seed_defines OPENSSL_RAND_SEED_NONE)
                elseif(_seed STREQUAL "rdcpu")
                    list(APPEND _seed_defines OPENSSL_RAND_SEED_RDCPU)
                else()
                    list(APPEND _unsupported_options "${_arg}")
                endif()
            endforeach()
            if(_seed_defines)
                list(REMOVE_DUPLICATES _seed_defines)
                set(OPENSSL_CMAKE_RAND_SEED_DEFINES "${_seed_defines}" PARENT_SCOPE)
            endif()
            continue()
        endif()

        if(_arg MATCHES "^enable-(.+)$")
            set(_name "${CMAKE_MATCH_1}")
            if(_name STREQUAL "shared")
                set(OPENSSL_CMAKE_BUILD_SHARED ON PARENT_SCOPE)
            elseif(_name STREQUAL "apps")
                set(OPENSSL_CMAKE_BUILD_APPS ON PARENT_SCOPE)
            elseif(_name IN_LIST _OPENSSL_CMAKE_CASCADE_ONLY_FEATURE_OPTIONS)
                list(REMOVE_ITEM _compat_disabled_features "${_name}")
            elseif(_name STREQUAL "unstable-qlog")
                list(REMOVE_ITEM _compat_feature_defines OPENSSL_NO_QLOG)
                list(REMOVE_ITEM _compat_disabled_features "${_name}")
            elseif(_name STREQUAL "legacy")
                set(OPENSSL_CMAKE_ENABLE_LEGACY ON PARENT_SCOPE)
            elseif(_name STREQUAL "threads")
                set(OPENSSL_CMAKE_ENABLE_THREADS ON PARENT_SCOPE)
            elseif(_name STREQUAL "asm")
                set(OPENSSL_CMAKE_ENABLE_ASM ON PARENT_SCOPE)
            elseif(_name STREQUAL "fips")
                set(OPENSSL_CMAKE_ENABLE_FIPS ON PARENT_SCOPE)
            elseif(_name STREQUAL "jitter")
                set(OPENSSL_CMAKE_ENABLE_JITTER ON PARENT_SCOPE)
            elseif(_name STREQUAL "ktls")
                set(OPENSSL_CMAKE_ENABLE_KTLS ON PARENT_SCOPE)
            elseif(_name STREQUAL "module")
                set(OPENSSL_CMAKE_ENABLE_MODULES ON PARENT_SCOPE)
            elseif(_name STREQUAL "sctp")
                set(OPENSSL_CMAKE_ENABLE_SCTP ON PARENT_SCOPE)
            elseif(_name STREQUAL "zlib")
                set(OPENSSL_CMAKE_ENABLE_ZLIB ON PARENT_SCOPE)
                set(OPENSSL_CMAKE_ENABLE_ZLIB_DYNAMIC OFF PARENT_SCOPE)
            elseif(_name STREQUAL "zlib-dynamic")
                set(OPENSSL_CMAKE_ENABLE_ZLIB OFF PARENT_SCOPE)
                set(OPENSSL_CMAKE_ENABLE_ZLIB_DYNAMIC ON PARENT_SCOPE)
            elseif(_name IN_LIST _OPENSSL_CMAKE_KNOWN_PROTOCOL_OPTIONS)
                _openssl_cmake_option_to_define("${_name}" _define_name)
                list(REMOVE_ITEM _compat_feature_defines "${_define_name}")
                list(REMOVE_ITEM _compat_disabled_protocols "${_name}")
            elseif(_name IN_LIST _OPENSSL_CMAKE_KNOWN_ALGORITHM_OPTIONS)
                _openssl_cmake_option_to_define("${_name}" _define_name)
                list(REMOVE_ITEM _compat_feature_defines "${_define_name}")
                list(REMOVE_ITEM _compat_disabled_algorithms "${_name}")
            elseif(_name IN_LIST _OPENSSL_CMAKE_GENERIC_FEATURE_OPTIONS)
                _openssl_cmake_option_to_define("${_name}" _define_name)
                list(REMOVE_ITEM _compat_feature_defines "${_define_name}")
                list(REMOVE_ITEM _compat_disabled_features "${_name}")
            else()
                list(APPEND _unsupported_options "${_arg}")
            endif()
            continue()
        endif()

        if(_arg MATCHES "^(no|disable)-(.+)$")
            set(_name "${CMAKE_MATCH_2}")
            if(_name STREQUAL "shared")
                set(OPENSSL_CMAKE_BUILD_SHARED OFF PARENT_SCOPE)
            elseif(_name STREQUAL "apps")
                set(OPENSSL_CMAKE_BUILD_APPS OFF PARENT_SCOPE)
                list(APPEND _compat_disabled_features apps)
            elseif(_name IN_LIST _OPENSSL_CMAKE_CASCADE_ONLY_FEATURE_OPTIONS)
                list(APPEND _compat_disabled_features "${_name}")
            elseif(_name STREQUAL "unstable-qlog")
                list(APPEND _compat_feature_defines OPENSSL_NO_QLOG)
                list(APPEND _compat_disabled_features "${_name}")
            elseif(_name STREQUAL "legacy")
                set(OPENSSL_CMAKE_ENABLE_LEGACY OFF PARENT_SCOPE)
            elseif(_name STREQUAL "tests")
                set(OPENSSL_CMAKE_BUILD_TESTS OFF PARENT_SCOPE)
            elseif(_name STREQUAL "docs")
                set(OPENSSL_CMAKE_BUILD_DOCS OFF PARENT_SCOPE)
            elseif(_name STREQUAL "threads")
                set(OPENSSL_CMAKE_ENABLE_THREADS OFF PARENT_SCOPE)
                list(APPEND _compat_feature_defines OPENSSL_NO_THREADS)
                list(APPEND _compat_disabled_features threads)
            elseif(_name STREQUAL "asm")
                set(OPENSSL_CMAKE_ENABLE_ASM OFF PARENT_SCOPE)
            elseif(_name STREQUAL "fips")
                set(OPENSSL_CMAKE_ENABLE_FIPS OFF PARENT_SCOPE)
            elseif(_name STREQUAL "jitter")
                set(OPENSSL_CMAKE_ENABLE_JITTER OFF PARENT_SCOPE)
                list(APPEND _compat_disabled_features jitter)
            elseif(_name STREQUAL "ktls")
                set(OPENSSL_CMAKE_ENABLE_KTLS OFF PARENT_SCOPE)
                list(APPEND _compat_feature_defines OPENSSL_NO_KTLS)
                list(APPEND _compat_disabled_protocols ktls)
            elseif(_name STREQUAL "module")
                set(OPENSSL_CMAKE_ENABLE_MODULES OFF PARENT_SCOPE)
            elseif(_name STREQUAL "sctp")
                set(OPENSSL_CMAKE_ENABLE_SCTP OFF PARENT_SCOPE)
                list(APPEND _compat_feature_defines OPENSSL_NO_SCTP)
                list(APPEND _compat_disabled_protocols sctp)
            elseif(_name STREQUAL "zlib")
                set(OPENSSL_CMAKE_ENABLE_ZLIB OFF PARENT_SCOPE)
                set(OPENSSL_CMAKE_ENABLE_ZLIB_DYNAMIC OFF PARENT_SCOPE)
            elseif(_name STREQUAL "zlib-dynamic")
                set(OPENSSL_CMAKE_ENABLE_ZLIB_DYNAMIC OFF PARENT_SCOPE)
            elseif(_name STREQUAL "stdio")
                set(OPENSSL_CMAKE_BUILD_APPS OFF PARENT_SCOPE)
                set(OPENSSL_CMAKE_BUILD_TESTS OFF PARENT_SCOPE)
                list(APPEND _compat_feature_defines OPENSSL_NO_STDIO)
                list(APPEND _compat_disabled_features stdio)
            elseif(_name STREQUAL "autoalginit")
                set(OPENSSL_CMAKE_BUILD_SHARED OFF PARENT_SCOPE)
                _openssl_cmake_option_to_define("${_name}" _define_name)
                list(APPEND _compat_feature_defines "${_define_name}")
                list(APPEND _compat_disabled_features "${_name}")
            elseif(_name IN_LIST _OPENSSL_CMAKE_KNOWN_PROTOCOL_OPTIONS)
                _openssl_cmake_option_to_define("${_name}" _define_name)
                list(APPEND _compat_feature_defines "${_define_name}")
                list(APPEND _compat_disabled_protocols "${_name}")
            elseif(_name IN_LIST _OPENSSL_CMAKE_KNOWN_ALGORITHM_OPTIONS)
                _openssl_cmake_option_to_define("${_name}" _define_name)
                list(APPEND _compat_feature_defines "${_define_name}")
                list(APPEND _compat_disabled_algorithms "${_name}")
            elseif(_name IN_LIST _OPENSSL_CMAKE_GENERIC_FEATURE_OPTIONS)
                _openssl_cmake_option_to_define("${_name}" _define_name)
                list(APPEND _compat_feature_defines "${_define_name}")
                list(APPEND _compat_disabled_features "${_name}")
            else()
                list(APPEND _unsupported_options "${_arg}")
            endif()
            continue()
        endif()

        list(APPEND _unsupported_options "${_arg}")
    endforeach()

    list(REMOVE_DUPLICATES _compat_feature_defines)
    list(REMOVE_DUPLICATES _compat_disabled_features)
    list(REMOVE_DUPLICATES _compat_disabled_protocols)
    list(REMOVE_DUPLICATES _compat_disabled_algorithms)
    list(REMOVE_DUPLICATES _unsupported_options)

    if(_unsupported_options)
        string(JOIN ", " _unsupported_text ${_unsupported_options})
        message(FATAL_ERROR
            "The no-Perl CMake bootstrap recognized but does not implement these Configure-compatible options yet: ${_unsupported_text}"
        )
    endif()

    set(OPENSSL_CMAKE_COMPAT_FEATURE_DEFINES "${_compat_feature_defines}" PARENT_SCOPE)
    set(OPENSSL_CMAKE_COMPAT_DISABLED_FEATURES "${_compat_disabled_features}" PARENT_SCOPE)
    set(OPENSSL_CMAKE_COMPAT_DISABLED_PROTOCOLS "${_compat_disabled_protocols}" PARENT_SCOPE)
    set(OPENSSL_CMAKE_COMPAT_DISABLED_ALGORITHMS "${_compat_disabled_algorithms}" PARENT_SCOPE)
endfunction()