cmake_minimum_required(VERSION 3.13)
project(AssetStudioFBXNative)
set(CMAKE_CXX_STANDARD 17)

add_compile_definitions(DLL_EXPORTS _AS_DLL)

add_library(AssetStudioFBXNative SHARED
    SHARED
    asfbx_anim_context.cpp
    asfbx_context.cpp
    api.cpp
    asfbx_morph_context.cpp
    asfbx_skin_context.cpp
    utils.cpp
)

set(EXTRA_LIBS)
if(NOT DEFINED FBX_SDK_ROOT)
  message(FATAL_ERROR "FBX_SDK_ROOT must be defined")
endif()

if(WIN32)
  # Set /MT or /MD according to FBX_STATIC_RTL flags
  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /W4 ${FBX_CC_RTLd}")
  set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /W4 ${FBX_CC_RTLd}")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} ${FBX_CC_RTL}")
  set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} ${FBX_CC_RTL}")
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} ${FBX_CC_RTL}")
  set(CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO} ${FBX_CC_RTL}")
elseif(APPLE)
  find_library(CARBON_LIBRARY Carbon)
  find_library(CORE_FOUNDATION_LIBRARY CoreFoundation)

  if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set(EXTRA_LIBS "-framework CoreFoundation")
  else()
    set(EXTRA_LIBS "-framework Carbon")
  endif()
elseif(UNIX) # already excluded apple
  if(MXX STREQUAL "32")
    set(FBX_ARCH "x86")
    set_target_properties(AssetStudioFBXNative PROPERTIES COMPILE_FLAGS -m${MXX} LINK_FLAGS -m${MXX})
  endif()
endif()

include("fbx.cmake")

target_link_libraries(AssetStudioFBXNative PRIVATE 
                      ${FBX_REQUIRED_LIBS_DEPENDENCY}
                      ${EXTRA_LIBS}
)
target_include_directories(AssetStudioFBXNative PRIVATE
                           ${PROJECT_SOURCE_DIR}
                           "${FBX_ROOT}/include"
)

install(TARGETS AssetStudioFBXNative DESTINATION ${CMAKE_INSTALL_LIBDIR})
