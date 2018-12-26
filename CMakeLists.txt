cmake_minimum_required(VERSION 3.13)

project(bf C)


set(CMAKE_ASM_NASM_OBJECT_FORMAT elf)

enable_language(ASM_NASM)

if(NOT CMAKE_ASM_NASM_COMPILER_LOADED)
    MESSAGE(FATAL_ERROR "Could not find nasm")
endif()

add_executable(bf bf.asm)
set(CMAKE_ASM_NASM_LINK_EXECUTABLE "gcc -m32 <FLAGS> <CMAKE_ASM_NASM_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES>")
