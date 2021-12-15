cmake_minimum_required(VERSION 3.13)

project(AssetStudioFBXNative)
set(CMAKE_CXX_STANDARD 17)

add_compile_definitions(_AS_DLL)

if(NOT DEFINED FBX_SDK_ROOT)
  message(FATAL_ERROR "FBX_SDK_ROOT must be defined")
endif()

include("${FBX_SDK_ROOT}/samples/CMakeSettings.txt")

fbx_project(AssetStudioFBXNative .)

set(FBX_TARGET_SOURCE
    asfbx_anim_context.cpp
    asfbx_context.cpp
    api.cpp
    asfbx_morph_context.cpp
    asfbx_skin_context.cpp
    utils.cpp
)

add_library(
    ${FBX_TARGET_NAME}
    SHARED
    ${FBX_TARGET_SOURCE}
)

set_samples_global_flags()

target_include_directories(AssetStudioFBXNative PRIVATE ${PROJECT_SOURCE_DIR})
install(TARGETS AssetStudioFBXNative DESTINATION ${CMAKE_INSTALL_LIBDIR})
