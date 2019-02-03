cmake_minimum_required(VERSION 3.11)

project(bf C CXX)

set(BITS 32 CACHE STRING "The architecture to target")
set_property(CACHE BITS PROPERTY STRINGS 16 32 64)

if(BITS EQUAL 32)
  set(CMAKE_ASM_NASM_OBJECT_FORMAT elf)
elseif(BITS EQUAL 64)
  set(CMAKE_ASM_NASM_OBJECT_FORMAT elf64)
elseif(BITS EQUAL 16)
  set(CMAKE_ASM_NASM_OBJECT_FORMAT elf)
else()
  message(FATAL_ERROR "Invalid bit size")
endif()

set(CMAKE_ASM_NASM_FLAGS "-l ${CMAKE_BINARY_DIR}/bf.lst -I ${PROJECT_SOURCE_DIR}/src/${BITS}/")

enable_language(ASM_NASM)

if(NOT CMAKE_ASM_NASM_COMPILER_LOADED)
    MESSAGE(FATAL_ERROR "Could not find nasm")
endif()

#set(CMAKE_ASM_NASM_LINK_EXECUTABLE "gcc -m${BITS} <CMAKE_ASM_NASM_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES>")

#add_executable(bf bin/main.asm)
add_library(bf-lib STATIC src/bf.asm)
#target_link_libraries(bf bf-lib)

if(NOT BITS EQUAL 16)
  add_executable(c-test tests/test.c)
  target_link_libraries(c-test bf-lib)
  set_target_properties(c-test PROPERTIES COMPILE_FLAGS "-m${BITS}" LINK_FLAGS "-m${BITS}")

  add_executable(zoop tests/stdout_capture.cpp)
  target_link_libraries(zoop bf-lib)
  set_target_properties(zoop PROPERTIES COMPILE_FLAGS "-m${BITS}" LINK_FLAGS "-m${BITS}")
endif()

if(BITS EQUAL 16)
  add_subdirectory(dos)
endif()
