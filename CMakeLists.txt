cmake_minimum_required(VERSION 3.13)

project(bf C)


set(CMAKE_ASM_NASM_OBJECT_FORMAT elf)
set(CMAKE_ASM_NASM_FLAGS "-l bf.lst")

enable_language(ASM_NASM)

if(NOT CMAKE_ASM_NASM_COMPILER_LOADED)
    MESSAGE(FATAL_ERROR "Could not find nasm")
endif()

set(CMAKE_ASM_NASM_LINK_EXECUTABLE "gcc -m32 <CMAKE_ASM_NASM_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES>")

add_executable(bf bin/main.asm)
add_library(bf-lib STATIC src/bf.asm)
target_link_libraries(bf bf-lib)

add_executable(c-test tests/test.c)
target_link_libraries(c-test bf-lib)
set_target_properties(c-test PROPERTIES COMPILE_FLAGS "-m32" LINK_FLAGS "-m32")
