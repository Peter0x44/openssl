cmake_minimum_required(VERSION 3.21)

foreach(_required_var OUTPUT_FILE VERSION_MAJOR VERSION_MINOR VERSION_PATCH VERSION_PRE_RELEASE VERSION_BUILD_METADATA FILE_NAME FILE_DESCRIPTION FILE_TYPE)
    if(NOT DEFINED ${_required_var})
        message(FATAL_ERROR "${_required_var} is required")
    endif()
endforeach()

set(_numeric_version "${VERSION_MAJOR},${VERSION_MINOR},${VERSION_PATCH},0")
set(_full_version "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}${VERSION_PRE_RELEASE}")
if(NOT VERSION_BUILD_METADATA STREQUAL "")
    string(APPEND _full_version "+${VERSION_BUILD_METADATA}")
endif()

if(FILE_TYPE STREQUAL "APP")
    set(_file_type_token "VFT_APP")
elseif(FILE_TYPE STREQUAL "DLL")
    set(_file_type_token "VFT_DLL")
else()
    message(FATAL_ERROR "Unsupported FILE_TYPE=${FILE_TYPE}; expected APP or DLL")
endif()

string(TIMESTAMP _year "%Y" UTC)

get_filename_component(_output_dir "${OUTPUT_FILE}" DIRECTORY)
file(MAKE_DIRECTORY "${_output_dir}")

set(_rc_text [=[#include <winver.h>

LANGUAGE 0x09,0x01

1 VERSIONINFO
    FILEVERSION @_numeric_version@
    PRODUCTVERSION @_numeric_version@
  FILEFLAGSMASK 0x3fL
#ifdef _DEBUG
  FILEFLAGS 0x01L
#else
  FILEFLAGS 0x00L
#endif
  FILEOS VOS__WINDOWS32
    FILETYPE @_file_type_token@
  FILESUBTYPE 0x0L
BEGIN
    BLOCK "StringFileInfo"
    BEGIN
        BLOCK "040904b0"
        BEGIN
            VALUE "CompanyName", "The OpenSSL Project, https://www.openssl.org/\0"
                        VALUE "FileDescription", "@FILE_DESCRIPTION@\\0"
                        VALUE "FileVersion", "@_full_version@\\0"
                        VALUE "InternalName", "@FILE_NAME@\\0"
                        VALUE "OriginalFilename", "@FILE_NAME@\\0"
            VALUE "ProductName", "The OpenSSL Toolkit\0"
                        VALUE "ProductVersion", "@_full_version@\\0"
                        VALUE "LegalCopyright", "Copyright 1998-@_year@ The OpenSSL Authors. All rights reserved.\\0"
        END
    END
    BLOCK "VarFileInfo"
    BEGIN
        VALUE "Translation", 0x409, 0x4b0
    END
END
]=])

string(CONFIGURE "${_rc_text}" _rc_text @ONLY)
file(WRITE "${OUTPUT_FILE}" "${_rc_text}")