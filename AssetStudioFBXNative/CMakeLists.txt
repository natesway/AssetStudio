cmake_minimum_required(VERSION 3.13)
project(AssetStudioFBXNative)
set(CMAKE_CXX_STANDARD 17)

add_compile_definitions(DLL_EXPORTS _AS_DLL)

add_library(AssetStudioFBXNative SHARED 
            api.cpp
            asfbx_anim_context.cpp
            asfbx_context.cpp
            asfbx_morph_context.cpp
            asfbx_skin_context.cpp
            utils.cpp)

target_include_directories(AssetStudioFBXNative PRIVATE 
    ${PROJECT_SOURCE_DIR}
    ${FBX_INCLUDE}
)

IF(APPLE)
target_link_libraries(AssetStudioFBXNative
    PUBLIC optimized ${FBX_LIB}/libfbxsdk.dylib
)
ELSEIF(WIN32)
target_link_libraries(AssetStudioFBXNative 
    PUBLIC optimized ${FBX_LIB}/libfbxsdk-md.lib 
    PUBLIC optimized ${FBX_LIB}/libxml2-md.lib
    PUBLIC optimized ${FBX_LIB}/zlib-md.lib
)
ELSEIF(UNIX) # already excluded apple
set_target_properties(AssetStudioFBXNative PROPERTIES COMPILE_FLAGS -${MXX} LINK_FLAGS -${MXX})
ENDIF()
# Ubuntu version installs to /usr -> linker automatically finds it


install(TARGETS AssetStudioFBXNative DESTINATION ${CMAKE_INSTALL_LIBDIR})
