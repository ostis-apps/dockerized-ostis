file(GLOB_RECURSE SOURCES "*.cpp" "*.hpp")

add_library (exampleModule SHARED ${SOURCES})

target_include_directories(exampleModule PRIVATE ${SC_MEMORY_SRC})
target_link_libraries(exampleModule sc-memory sc-core sc-kpm-common sc-agents-common)

add_dependencies(exampleModule sc-memory sc-core sc-kpm-common sc-agents-common)

sc_codegen(exampleModule ${CMAKE_CURRENT_LIST_DIR})