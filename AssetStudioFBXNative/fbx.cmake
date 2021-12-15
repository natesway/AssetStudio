# From Autodesk FBX SDK samples
# Copyright (C) 2015 Autodesk, Inc.

# ===================================================================================
#
# PRE-REQUISITES
#
# ===================================================================================

GET_FILENAME_COMPONENT(FBX_ROOT "${FBX_SDK_ROOT}" ABSOLUTE)
STRING(REGEX MATCH "[^/]+$" FBX_CMAKE_OUTPUT_FOLDER "${CMAKE_CURRENT_BINARY_DIR}")

SET(FBX_CMAKELIST_DEPENDENT)
IF(WIN32 AND CMAKE_SUPPRESS_REGENERATION)
    SET(FBX_CMAKELIST_DEPENDENT "CMakeLists.txt")
ENDIF(WIN32 AND CMAKE_SUPPRESS_REGENERATION)

IF (NOT WIN32 AND NOT APPLE)
   # assume we are on Linux
   SET(LINUX 1)
ENDIF()

# ===================================================================================
#
# COMMON SECTION
#
# ===================================================================================

# SET(FBX_SHARED)         # can be set at command line with -DFBX_SHARED=1
# SET(FBX_STATIC_RTL)     # can be set at command line with -DFBX_STATIC_RTL=1 (use static MSVCRT (/MT), otherwise use dynamic MSVCRT (/MD))
# SET(FBX_VARIANT)        # can be set at command line with -DFBX_VARIANT=debug or release (Unix only)
# SET(FBX_ARCH)           # can be set at command line with -DFBX_ARCH=x64 or x86 (Unix only)
# SET(FBX_LINKER_FLAGS)

IF (FBX_SHARED AND FBX_STATIC_RTL)
    SET(FBX_STATIC_RTL)
    MESSAGE("\nBoth FBX_SHARED and FBX_STATIC_RTL have been defined. They are mutually exclusive, considering FBX_SHARED only.")
ENDIF()

IF(NOT FBX_VARIANT)
    SET(FBX_VARIANT "debug")
ENDIF()

SET(FBX_DEBUG)
IF (FBX_VARIANT MATCHES "debug")
    SET(FBX_DEBUG 1)
ENDIF()

IF(NOT FBX_ARCH)
    IF(MSVC AND CMAKE_GENERATOR_PLATFORM)
        SET(FBX_ARCH ${CMAKE_GENERATOR_PLATFORM})
    ELSEIF(CMAKE_SIZEOF_VOID_P EQUAL 4)
        SET(FBX_ARCH "x86")
    ELSE()
        SET(FBX_ARCH "x64")
    ENDIF()
ENDIF()

IF(WIN32)
    SET(CMAKE_USE_RELATIVE_PATHS 1)
    SET(LIB_EXTENSION ".lib")
ELSE(WIN32)
    SET(LIB_EXTENSION ".a")
    IF(FBX_SHARED)
        IF(APPLE)
            SET(LIB_EXTENSION ".dylib")
        ELSEIF(LINUX)
            SET(LIB_EXTENSION ".so")
        ENDIF()
    ENDIF()
ENDIF(WIN32)

SET(FBX_SDK libfbxsdk${LIB_EXTENSION})
IF(WIN32)
    IF(CMAKE_CONFIGURATION_TYPES)      
        set(CMAKE_CONFIGURATION_TYPES Debug Release RelWithDebInfo)
        set(CMAKE_CONFIGURATION_TYPES "${CMAKE_CONFIGURATION_TYPES}" CACHE STRING "Reset the configurations to what we need" FORCE)
    ENDIF()
    
    SET(FBX_VARIANT "$(Configuration)")
    
    IF(MSVC_VERSION GREATER 1699 AND MSVC_VERSION LESS 1800)
        SET(FBX_COMPILER "vs2012")
    ELSEIF(MSVC_VERSION GREATER 1799 AND MSVC_VERSION LESS 1900)
        SET(FBX_COMPILER "vs2013")
    ELSEIF(MSVC_VERSION GREATER 1899 AND MSVC_VERSION LESS 1911)
        SET(FBX_COMPILER "vs2015")
    ELSEIF(MSVC_VERSION GREATER 1910 AND MSVC_VERSION LESS 1920)
        SET(FBX_COMPILER "vs2017")
    ELSEIF(MSVC_VERSION GREATER 1920 AND MSVC_VERSION LESS 2000)
        SET(FBX_COMPILER "vs2019")
    ENDIF()
    SET(FBX_TARGET_LIBS_PATH "${FBX_ROOT}/lib/${FBX_COMPILER}/${FBX_ARCH}/${FBX_VARIANT}")
    SET(FBX_SDK_ABS ${FBX_TARGET_LIBS_PATH}/${FBX_SDK})
    SET(FBX_REQUIRED_LIBS_DEPENDENCY ${FBX_SDK_ABS})
    IF(NOT FBX_SHARED)
        IF(FBX_STATIC_RTL)
            SET(FBX_CC_RTL "/MT")
            SET(FBX_CC_RTLd "/MTd")
            SET(FBX_RTL_SUFFX "-mt")
        ELSE()
            SET(FBX_CC_RTL "/MD")
            SET(FBX_CC_RTLd "/MDd")
            SET(FBX_RTL_SUFFX "-md")
        ENDIF()        
        SET(FBX_REQUIRED_LIBS_DEPENDENCY 
            ${FBX_TARGET_LIBS_PATH}/libfbxsdk${FBX_RTL_SUFFX}${LIB_EXTENSION} 
            ${FBX_TARGET_LIBS_PATH}/libxml2${FBX_RTL_SUFFX}${LIB_EXTENSION} 
            ${FBX_TARGET_LIBS_PATH}/zlib${FBX_RTL_SUFFX}${LIB_EXTENSION})
    ENDIF()
ELSE()
    MESSAGE("Detecting compiler version used")
    IF(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        MESSAGE("Detected Clang ${CMAKE_CXX_COMPILER_VERSION}")
        SET(FBX_COMPILER "clang")
        SET(FBX_CLANG 1)
    ELSE()
        SET(FBX_COMPILER "gcc")
        IF(CMAKE_COMPILER_IS_GNUCC AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 4.0)
            MESSAGE( "Detected GCC >= 4.0" )
        ELSE()
            MESSAGE(FATAL_ERROR  "Detected " ${CMAKE_CXX_COMPILER_VERSION} " only GCC 4.x and higher supported")
        ENDIF()
    ENDIF()

    IF(APPLE)
        SET(FBX_TARGET_LIBS_PATH "${FBX_ROOT}/lib/${FBX_COMPILER}/${FBX_VARIANT}")
        IF(FBX_COMPILER STREQUAL "gcc")
            SET(FBX_TARGET_LIBS_PATH "${FBX_ROOT}/lib/${FBX_COMPILER}/ub/${FBX_VARIANT}")
        ENDIF()
        SET(FBX_EXTRA_LIBS_PATH ${FBX_TARGET_LIBS_PATH}/lib)
    ELSEIF(LINUX)
        SET(FBX_TARGET_LIBS_PATH "${FBX_ROOT}/lib/${FBX_COMPILER}/${FBX_ARCH}/${FBX_VARIANT}")
        SET(FBX_EXTRA_LIBS_PATH ${FBX_TARGET_LIBS_PATH}/lib)
    ENDIF()
    SET(FBX_SDK_ABS ${FBX_EXTRA_LIBS_PATH}fbxsdk${LIB_EXTENSION})
    SET(FBX_REQUIRED_LIBS_DEPENDENCY ${FBX_SDK_ABS} z xml2)
    
    if(APPLE)
        SET(FBX_REQUIRED_LIBS_DEPENDENCY ${FBX_REQUIRED_LIBS_DEPENDENCY} iconv)
    endif()
ENDIF()
