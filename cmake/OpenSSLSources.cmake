function(_openssl_prepend_root root input_list output_var)
    set(_result)
    foreach(_entry IN LISTS input_list)
        list(APPEND _result "${root}/${_entry}")
    endforeach()
    set(${output_var} "${_result}" PARENT_SCOPE)
endfunction()

function(_openssl_collect_disabled_options output_var)
    set(_disabled_options
        ${OPENSSL_CMAKE_DISABLED_ALGORITHMS}
        ${OPENSSL_CMAKE_DISABLED_FEATURES}
        ${OPENSSL_CMAKE_DISABLED_PROTOCOLS}
    )
    list(REMOVE_DUPLICATES _disabled_options)
    set(${output_var} "${_disabled_options}" PARENT_SCOPE)
endfunction()

function(_openssl_filter_disabled_regexes input_list disabled_options output_var)
    set(_filtered ${input_list})
    set(_filters ${ARGN})

    while(_filters)
        list(POP_FRONT _filters _disabled_name _filter_regex)
        if(_disabled_name IN_LIST disabled_options)
            list(FILTER _filtered EXCLUDE REGEX "${_filter_regex}")
        endif()
    endwhile()

    set(${output_var} "${_filtered}" PARENT_SCOPE)
endfunction()

function(openssl_cmake_collect_template_inputs source_dir output_var)
    file(GLOB_RECURSE _templates RELATIVE "${source_dir}" CONFIGURE_DEPENDS
        "include/openssl/*.h.in"
        "include/crypto/*.h.in"
        "apps/include/*.h.in"
        "providers/common/include/prov/*.h.in"
        "providers/common/der/*_gen.c.in"
        "providers/implementations/*.inc.in"
    )
    _openssl_collect_disabled_options(_disabled_options)
    _openssl_filter_disabled_regexes("${_templates}" "${_disabled_options}" _templates
        dsa "^providers/common/der/der_dsa_gen\.c\.in$"
        ec "^providers/common/der/der_ec_gen\.c\.in$"
        ecx "^providers/common/der/der_ecx_gen\.c\.in$"
        ml-dsa "^providers/common/der/der_ml_dsa_gen\.c\.in$"
        slh-dsa "^providers/common/der/der_slh_dsa_gen\.c\.in$"
        sm2 "^providers/common/der/der_sm2_gen\.c\.in$"
    )
    list(FILTER _templates EXCLUDE REGEX "^providers/fips/")
    list(SORT _templates)
    set(${output_var} "${_templates}" PARENT_SCOPE)
endfunction()

function(openssl_cmake_collect_sources source_dir build_shared out_crypto out_ssl out_provider out_apps out_apps_lib)
    file(GLOB_RECURSE _crypto_rel RELATIVE "${source_dir}" CONFIGURE_DEPENDS "crypto/*.c")
    _openssl_collect_disabled_options(_disabled_options)
    _openssl_filter_disabled_regexes("${_crypto_rel}" "${_disabled_options}" _crypto_rel
        aria "^crypto/aria/|^crypto/evp/e_aria\.c$"
        bf "^crypto/bf/|^crypto/evp/e_bf\.c$"
        blake2 "^crypto/evp/legacy_blake2\.c$"
        camellia "^crypto/camellia/|^crypto/evp/e_camellia\.c$"
        cast "^crypto/cast/|^crypto/evp/e_cast\.c$"
        chacha "^crypto/chacha/|^crypto/evp/e_chacha20_poly1305\.c$"
        cmac "^crypto/cmac/"
        cmp "^crypto/cmp/"
        cms "^crypto/cms/"
        crmf "^crypto/crmf/"
        ct "^crypto/ct/"
        des "^crypto/des/|^crypto/evp/e_des\.c$|^crypto/evp/e_des3\.c$"
        dh "^crypto/dh/"
        dsa "^crypto/dsa/"
        ec "^crypto/ec/"
        http "^crypto/http/"
        idea "^crypto/idea/|^crypto/evp/e_idea\.c$"
        lms "^crypto/lms/"
        md2 "^crypto/md2/|^crypto/evp/legacy_md2\.c$"
        md4 "^crypto/md4/|^crypto/evp/legacy_md4\.c$"
        mdc2 "^crypto/mdc2/|^crypto/evp/legacy_mdc2\.c$"
        ml-dsa "^crypto/ml_dsa/"
        ml-kem "^crypto/ml_kem/"
        ocsp "^crypto/ocsp/"
        poly1305 "^crypto/poly1305/|^crypto/evp/e_chacha20_poly1305\.c$"
        rc2 "^crypto/rc2/|^crypto/evp/e_rc2\.c$"
        rc4 "^crypto/rc4/|^crypto/evp/e_rc4\.c$|^crypto/evp/e_rc4_hmac_md5\.c$"
        rc5 "^crypto/rc5/|^crypto/evp/e_rc5\.c$"
        rmd160 "^crypto/ripemd/|^crypto/evp/legacy_ripemd\.c$"
        seed "^crypto/seed/|^crypto/evp/e_seed\.c$"
        siphash "^crypto/siphash/"
        slh-dsa "^crypto/slh_dsa/"
        sm2 "^crypto/sm2/"
        sm3 "^crypto/sm3/"
        sm4 "^crypto/sm4/|^crypto/evp/e_sm4\.c$"
        srp "^crypto/srp/"
        ts "^crypto/ts/"
        whirlpool "^crypto/whrlpool/|^crypto/evp/legacy_wp\.c$"
    )
    list(FILTER _crypto_rel EXCLUDE REGEX "^crypto/LPdir_.*\\.c$")
    list(FILTER _crypto_rel EXCLUDE REGEX "^crypto/des/ncbc_enc\.c$")
    list(FILTER _crypto_rel EXCLUDE REGEX "^crypto/poly1305/poly1305_(base2_44|ieee754)\\.c$")
    list(FILTER _crypto_rel EXCLUDE REGEX "^crypto/rsa/rsa_acvp_test_params\\.c$")
    if(NOT OPENSSL_CMAKE_ENABLE_ASM)
        list(FILTER _crypto_rel EXCLUDE REGEX "^crypto/.*/asm/.*\\.c$")
        list(FILTER _crypto_rel EXCLUDE REGEX "^crypto/(armcap|loongarchcap|ppccap|riscvcap|s390xcap|sparcv9cap)\\.c$")
        list(FILTER _crypto_rel EXCLUDE REGEX "^crypto/bn/bn_(ppc|s390x|sparc)\\.c$")
        list(FILTER _crypto_rel EXCLUDE REGEX "^crypto/bn/rsaz_exp(_x2)?\\.c$")
        list(FILTER _crypto_rel EXCLUDE REGEX "^crypto/(aes/aes_x86core|chacha/chacha_(ppc|riscv)|ec/ecp_(nistz256|ppc|sm2p256|s390x_nistp)|ec/ecp_(nistz256|sm2p256)_table|ec/ecx_s390x|hmac/hmac_s390x|md5/md5_riscv|poly1305/poly1305_ppc|sha/sha_(loongarch|ppc|riscv)|sm3/sm3_riscv)\.c$")
    endif()
    if(NOT WIN32)
        list(FILTER _crypto_rel EXCLUDE REGEX "^crypto/dllmain\\.c$")
    endif()
    _openssl_prepend_root("${source_dir}" "${_crypto_rel}" _crypto)

    file(GLOB_RECURSE _ssl_rel RELATIVE "${source_dir}" CONFIGURE_DEPENDS "ssl/*.c")
    _openssl_filter_disabled_regexes("${_ssl_rel}" "${_disabled_options}" _ssl_rel
        ech "^ssl/ech/"
    )
    if("quic" IN_LIST _disabled_options)
        list(FILTER _ssl_rel EXCLUDE REGEX "^ssl/quic/")
        list(APPEND _ssl_rel "ssl/quic/quic_tls.c" "ssl/quic/quic_tls_api.c")
        list(FILTER _ssl_rel EXCLUDE REGEX "^ssl/priority_queue\.c$")
    endif()
    if("qlog" IN_LIST _disabled_options)
        list(FILTER _ssl_rel EXCLUDE REGEX "^ssl/quic/(json_enc|qlog)\.c$")
    endif()
    if(NOT OPENSSL_CMAKE_ENABLE_KTLS)
        list(FILTER _ssl_rel EXCLUDE REGEX "^ssl/record/methods/ktls_meth\.c$")
    endif()
    _openssl_prepend_root("${source_dir}" "${_ssl_rel}" _ssl)
    if(build_shared)
        list(APPEND _ssl
            "${source_dir}/crypto/packet.c"
            "${source_dir}/crypto/quic_vlint.c"
            "${source_dir}/crypto/time.c"
        )
        if(NOT "quic" IN_LIST _disabled_options)
            list(APPEND _ssl
                "${source_dir}/crypto/hashtable/hashfunc.c"
                "${source_dir}/crypto/siphash/siphash.c"
            )
        endif()
    endif()
    list(REMOVE_DUPLICATES _ssl)

    file(GLOB_RECURSE _provider_common_rel RELATIVE "${source_dir}" CONFIGURE_DEPENDS "providers/common/*.c")
    file(GLOB_RECURSE _provider_impl_rel RELATIVE "${source_dir}" CONFIGURE_DEPENDS "providers/implementations/*.c")
    file(GLOB _provider_top_rel RELATIVE "${source_dir}" CONFIGURE_DEPENDS "providers/*.c")
    set(_provider_legacy_only_impl_rel
        "providers/implementations/ciphers/cipher_blowfish.c"
        "providers/implementations/ciphers/cipher_blowfish_hw.c"
        "providers/implementations/ciphers/cipher_cast5.c"
        "providers/implementations/ciphers/cipher_cast5_hw.c"
        "providers/implementations/ciphers/cipher_des.c"
        "providers/implementations/ciphers/cipher_des_hw.c"
        "providers/implementations/ciphers/cipher_desx.c"
        "providers/implementations/ciphers/cipher_desx_hw.c"
        "providers/implementations/ciphers/cipher_idea.c"
        "providers/implementations/ciphers/cipher_idea_hw.c"
        "providers/implementations/ciphers/cipher_rc2.c"
        "providers/implementations/ciphers/cipher_rc2_hw.c"
        "providers/implementations/ciphers/cipher_rc4.c"
        "providers/implementations/ciphers/cipher_rc4_hmac_md5.c"
        "providers/implementations/ciphers/cipher_rc4_hmac_md5_hw.c"
        "providers/implementations/ciphers/cipher_rc4_hw.c"
        "providers/implementations/ciphers/cipher_rc5.c"
        "providers/implementations/ciphers/cipher_rc5_hw.c"
        "providers/implementations/ciphers/cipher_seed.c"
        "providers/implementations/ciphers/cipher_seed_hw.c"
        "providers/implementations/digests/md2_prov.c"
        "providers/implementations/digests/md4_prov.c"
        "providers/implementations/digests/mdc2_prov.c"
        "providers/implementations/digests/wp_prov.c"
        "providers/implementations/kdfs/pbkdf1.c"
        "providers/implementations/kdfs/pvkkdf.c"
    )
    string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" _openssl_cmake_processor_lower)
    list(FILTER _provider_common_rel EXCLUDE REGEX "^providers/fips/")
    list(FILTER _provider_impl_rel EXCLUDE REGEX "^providers/fips/")
    list(FILTER _provider_impl_rel EXCLUDE REGEX "^providers/implementations/macs/blake2_mac_impl\.c$")
    if(NOT OPENSSL_CMAKE_TARGET MATCHES "[Vv][Mm][Ss]")
        list(FILTER _provider_impl_rel EXCLUDE REGEX "^providers/implementations/rands/seeding/rand_vms\.c$")
    endif()
    if(NOT OPENSSL_CMAKE_TARGET MATCHES "[Vv][Xx][Ww][Oo][Rr][Kk][Ss]")
        list(FILTER _provider_impl_rel EXCLUDE REGEX "^providers/implementations/rands/seeding/rand_vxworks\.c$")
    endif()
    if(_openssl_cmake_processor_lower MATCHES "^(aarch64|arm64)")
        list(FILTER _provider_impl_rel EXCLUDE REGEX "^providers/implementations/rands/seeding/rand_cpu_x86\.c$")
    else()
        list(FILTER _provider_impl_rel EXCLUDE REGEX "^providers/implementations/rands/seeding/rand_cpu_arm64\.c$")
    endif()
    if(NOT OPENSSL_CMAKE_ENABLE_FIPS)
        list(FILTER _provider_common_rel EXCLUDE REGEX "^providers/common/securitycheck_fips\\.c$")
        list(FILTER _provider_impl_rel EXCLUDE REGEX "^providers/implementations/rands/fips_crng_test\\.c$")
    endif()
    _openssl_filter_disabled_regexes("${_provider_common_rel}" "${_disabled_options}" _provider_common_rel
        dsa "^providers/common/der/der_dsa_(gen|key|sig)\.c$"
        ec "^providers/common/der/der_ec_(gen|key|sig)\.c$"
        ecx "^providers/common/der/der_ecx_(gen|key)\.c$"
        ml-dsa "^providers/common/der/der_ml_dsa_(gen|key)\.c$"
        slh-dsa "^providers/common/der/der_slh_dsa_(gen|key)\.c$"
        sm2 "^providers/common/der/der_sm2_(gen|key|sig)\.c$"
    )
    _openssl_filter_disabled_regexes("${_provider_impl_rel}" "${_disabled_options}" _provider_impl_rel
        argon2 "^providers/implementations/kdfs/argon2\.c$"
        aria "^providers/implementations/ciphers/cipher_aria.*\.c$"
        bf "^providers/implementations/ciphers/cipher_blowfish.*\.c$"
        blake2 "^providers/implementations/digests/blake2.*\.c$"
        camellia "^providers/implementations/ciphers/cipher_camellia.*\.c$"
        cast "^providers/implementations/ciphers/cipher_cast5.*\.c$"
        chacha "^providers/implementations/ciphers/cipher_chacha20.*\.c$"
        cmac "^providers/implementations/macs/cmac_prov\.c$"
        des "^providers/implementations/ciphers/cipher_(des|desx|tdes).*\.c$"
        dh "^providers/implementations/(exchange/dh_exch|keymgmt/dh_kmgmt)\.c$"
        dsa "^providers/implementations/(keymgmt/dsa_kmgmt|signature/dsa_sig)\.c$"
        ec "^providers/implementations/(encode_decode/encode_key2blob|exchange/ecdh_exch|keymgmt/ec_kmgmt|kem/ec_kem|signature/ecdsa_sig)\.c$"
        ecx "^providers/implementations/(exchange/ecx_exch|keymgmt/ecx_kmgmt|kem/ecx_kem|signature/eddsa_sig)\.c$"
        hmac-drbg-kdf "^providers/implementations/kdfs/hmacdrbg_kdf\.c$"
        idea "^providers/implementations/ciphers/cipher_idea.*\.c$"
        ikev2kdf "^providers/implementations/kdfs/ikev2kdf\.c$"
        kbkdf "^providers/implementations/kdfs/kbkdf\.c$"
        krb5kdf "^providers/implementations/kdfs/krb5kdf\.c$"
        lms "^providers/implementations/(encode_decode/decode_lmsxdr2key|encode_decode/lms_codecs|keymgmt/lms_kmgmt|signature/lms_signature)\.c$"
        md2 "^providers/implementations/digests/md2_prov\.c$"
        md4 "^providers/implementations/digests/md4_prov\.c$"
        mdc2 "^providers/implementations/digests/mdc2_prov\.c$"
        ml-dsa "^providers/implementations/(encode_decode/ml_common_codecs|encode_decode/ml_dsa_codecs|keymgmt/ml_dsa_kmgmt|signature/ml_dsa_sig)\.c$"
        ml-kem "^providers/implementations/(encode_decode/ml_common_codecs|encode_decode/ml_kem_codecs|kem/ml_kem_kem|keymgmt/ml_kem_kmgmt|keymgmt/mlx_kmgmt)\.c$"
        ocb "^providers/implementations/ciphers/cipher_aes_ocb.*\.c$"
        poly1305 "^providers/implementations/(ciphers/cipher_chacha20_poly1305.*|macs/poly1305_prov)\.c$"
        pvkkdf "^providers/implementations/kdfs/pvkkdf\.c$"
        rc2 "^providers/implementations/ciphers/cipher_rc2.*\.c$"
        rc4 "^providers/implementations/ciphers/cipher_rc4.*\.c$"
        rmd160 "^providers/implementations/digests/ripemd_prov\.c$"
        scrypt "^providers/implementations/kdfs/scrypt\.c$"
        seed "^providers/implementations/ciphers/cipher_seed.*\.c$"
        siphash "^providers/implementations/macs/siphash_prov\.c$"
        siv "^providers/implementations/ciphers/cipher_aes_(gcm_)?siv.*\.c$"
        slh-dsa "^providers/implementations/(keymgmt/slh_dsa_kmgmt|signature/slh_dsa_sig)\.c$"
        sm2 "^providers/implementations/(asymciphers/sm2_enc|signature/sm2_sig)\.c$"
        sm3 "^providers/implementations/digests/sm3_prov\.c$"
        sm4 "^providers/implementations/ciphers/cipher_sm4.*\.c$"
        snmpkdf "^providers/implementations/kdfs/snmpkdf\.c$"
        srtpkdf "^providers/implementations/kdfs/srtpkdf\.c$"
        sshkdf "^providers/implementations/kdfs/sshkdf\.c$"
        sskdf "^providers/implementations/kdfs/sskdf\.c$"
        whirlpool "^providers/implementations/digests/wp_prov\.c$"
        x942kdf "^providers/implementations/kdfs/x942kdf\.c$"
    )
    if(NOT OPENSSL_CMAKE_ENABLE_LEGACY)
        list(REMOVE_ITEM _provider_top_rel "providers/legacyprov.c")
        list(REMOVE_ITEM _provider_impl_rel ${_provider_legacy_only_impl_rel})
    endif()
    _openssl_prepend_root("${source_dir}" "${_provider_common_rel}" _provider_common)
    _openssl_prepend_root("${source_dir}" "${_provider_impl_rel}" _provider_impl)
    _openssl_prepend_root("${source_dir}" "${_provider_top_rel}" _provider_top)
    list(APPEND _provider_common
        "${source_dir}/ssl/record/methods/tls_pad.c"
    )
    list(APPEND _provider_impl
        "${source_dir}/ssl/record/methods/ssl3_cbc.c"
    )
    set(_provider ${_provider_top} ${_provider_common} ${_provider_impl})
    list(FILTER _provider EXCLUDE REGEX "/fips/")
    list(REMOVE_DUPLICATES _provider)

    file(GLOB _apps_rel RELATIVE "${source_dir}" CONFIGURE_DEPENDS "apps/*.c")
    file(GLOB _apps_lib_rel RELATIVE "${source_dir}" CONFIGURE_DEPENDS "apps/lib/*.c")
    _openssl_filter_disabled_regexes("${_apps_rel}" "${_disabled_options}" _apps_rel
        cmp "^apps/cmp\.c$"
        cms "^apps/cms\.c$"
        dh "^apps/dhparam\.c$"
        dsa "^apps/(dsa|dsaparam|gendsa)\.c$"
        ec "^apps/(ec|ecparam)\.c$"
        ocsp "^apps/ocsp\.c$"
        srp "^apps/srp\.c$"
        ts "^apps/ts\.c$"
    )
    _openssl_filter_disabled_regexes("${_apps_lib_rel}" "${_disabled_options}" _apps_lib_rel
        cmp "^apps/lib/cmp_mock_srv\.c$"
        srp "^apps/lib/tlssrp_depr\.c$"
    )
    list(FILTER _apps_rel EXCLUDE REGEX "^apps/vms_decc_init\\.c$")
    if(NOT WIN32)
        list(FILTER _apps_lib_rel EXCLUDE REGEX "^apps/lib/win32_init\.c$")
    endif()
    if(NOT OPENSSL_CMAKE_TARGET MATCHES "[Vv][Mm][Ss]")
        list(FILTER _apps_lib_rel EXCLUDE REGEX "^apps/lib/vms_(decc_argv|term_sock)\.c$")
    endif()
    _openssl_prepend_root("${source_dir}" "${_apps_rel}" _apps)
    _openssl_prepend_root("${source_dir}" "${_apps_lib_rel}" _apps_lib)

    set(${out_crypto} "${_crypto}" PARENT_SCOPE)
    set(${out_ssl} "${_ssl}" PARENT_SCOPE)
    set(${out_provider} "${_provider}" PARENT_SCOPE)
    set(${out_apps} "${_apps}" PARENT_SCOPE)
    set(${out_apps_lib} "${_apps_lib}" PARENT_SCOPE)
endfunction()