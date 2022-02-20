project (wave)
site_name (www.ostis.net)
cmake_minimum_required (VERSION 2.6)

set(SC_MACHINE_ROOT "/ostis/sc-machine/")
set(SCP_MACHINE_ROOT "${CMAKE_SOURCE_DIR}")

set(CMAKE_BUILD_TYPE Debug)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${SC_MACHINE_ROOT}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${SC_MACHINE_ROOT}/bin)
set( CMAKE_CXX_FLAGS "-std=c++11")

link_directories(${SC_MACHINE_ROOT}/bin)

set(SC_MEMORY_SRC "${SC_MACHINE_ROOT}/sc-memory/")

message(STATUS "CMake generates " ${CMAKE_GENERATOR})

include_directories(${SC_MEMORY_SRC} ${SC_MACHINE_ROOT})

# Example: add_executable(wave wavefindpath.cpp utils.cpp utils.h)
add_executable(<executable name> <source files names>)

# Example: target_link_libraries(wave sc-core sc-memory)
target_link_libraries(<executable name> <used libraries names>)
