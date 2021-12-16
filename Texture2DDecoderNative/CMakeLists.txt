cmake_minimum_required(VERSION 3.13)

project(Texture2DDecoderNative)
set(CMAKE_CXX_STANDARD 17)

add_compile_definitions(_T2D_DLL)

add_library(Texture2DDecoderNative SHARED 
            astc.cpp
            atc.cpp
            bcn.cpp
            crunch.cpp
            dllmain.cpp
            etc.cpp
            pvrtc.cpp
            unitycrunch.cpp)

target_include_directories(Texture2DDecoderNative PRIVATE ${PROJECT_SOURCE_DIR})
install(TARGETS Texture2DDecoderNative DESTINATION ${CMAKE_INSTALL_LIBDIR})
