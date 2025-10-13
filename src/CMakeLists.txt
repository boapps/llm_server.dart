# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.14)

project(llm_server_dart_library VERSION 0.0.1 LANGUAGES C CXX)

# Explicitly disable CUDA to avoid GCC 14 compatibility issues
set(GGML_CUDA OFF CACHE BOOL "Disable CUDA" FORCE)
set(GGML_CUBLAS OFF CACHE BOOL "Disable CUBLAS" FORCE)

# set(CMAKE_BUILD_TYPE "Release")

set(GGML_BLAS ON)
set(GGML_BLAS_VENDOR OpenBLAS)

# Enable building common and tools libraries
set(LLAMA_BUILD_COMMON ON CACHE BOOL "Build common library" FORCE)
set(LLAMA_BUILD_TOOLS ON CACHE BOOL "Build tools including mtmd" FORCE)

add_subdirectory(llama.cpp)

set_target_properties(llama PROPERTIES PUBLIC_HEADER llama.cpp/include/llama.h)

# Generate header files from public assets
set(PUBLIC_ASSETS
    index.html.gz
    loading.html
)

set(PUBLIC_ASSET_HEADERS "")
foreach(asset ${PUBLIC_ASSETS})
    set(input "${CMAKE_CURRENT_SOURCE_DIR}/llama.cpp/tools/server/public/${asset}")
    set(output "${CMAKE_CURRENT_BINARY_DIR}/${asset}.hpp")
    list(APPEND PUBLIC_ASSET_HEADERS ${output})
    add_custom_command(
        DEPENDS "${input}"
        OUTPUT "${output}"
        COMMAND "${CMAKE_COMMAND}" "-DINPUT=${input}" "-DOUTPUT=${output}" -P "${CMAKE_CURRENT_SOURCE_DIR}/llama.cpp/scripts/xxd.cmake"
    )
    set_source_files_properties(${output} PROPERTIES GENERATED TRUE)
endforeach()

add_library(llm_server_dart SHARED
        llm_server_dart.c
        llama.cpp/tools/server/server.cpp
        llama.cpp/tools/server/utils.hpp
        ${PUBLIC_ASSET_HEADERS}
)

target_include_directories(llm_server_dart PRIVATE
        ${CMAKE_CURRENT_BINARY_DIR}
        llama.cpp
        llama.cpp/include
        llama.cpp/ggml/include
        llama.cpp/common
        llama.cpp/tools/server
        llama.cpp/tools/mtmd
        llama.cpp/vendor
)

target_link_libraries(llm_server_dart PRIVATE
        common
        mtmd
        ${CMAKE_THREAD_LIBS_INIT}
)

if (WIN32)
    target_link_libraries(llm_server_dart PRIVATE ws2_32)
endif()

set_target_properties(llm_server_dart PROPERTIES
  PUBLIC_HEADER llm_server_dart.h
  OUTPUT_NAME "llm_server_dart"
)

target_compile_definitions(llm_server_dart PUBLIC DART_SHARED_LIB)
