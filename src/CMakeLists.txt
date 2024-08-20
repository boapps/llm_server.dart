# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(llm_server_dart_library VERSION 0.0.1 LANGUAGES C CXX)

add_custom_command(
        OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/output
        COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/generate_hpp.sh > ${CMAKE_CURRENT_SOURCE_DIR}/output
        COMMAND_ECHO STDOUT
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/generate_hpp.sh
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

add_custom_target(llm_server_dart_library ALL
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/output
)

add_subdirectory(llama.cpp)

set_target_properties(llama PROPERTIES PUBLIC_HEADER llama.cpp/include/llama.h)

add_library(llm_server_dart SHARED
        llm_server_dart.c
        llama.cpp/examples/server/server.cpp
        llama.cpp/examples/server/utils.hpp
        llama.cpp/examples/server/httplib.h
)

target_include_directories(llm_server_dart PRIVATE
        llama.cpp
        llama.cpp/examples/server
        llama.cpp/include
        llama.cpp/ggml/include
        llama.cpp/common
)

target_link_libraries(llm_server_dart PRIVATE
        common
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
