# bf.asm

A simple brainfuck interpreter, written entirely in x86 assembly. Works on Linux x86 and x86\_64, and (in theory) DOS-16.

[![CircleCI Status](https://img.shields.io/circleci/project/github/colatkinson/bf.asm/master.svg?style=flat-square)](https://circleci.com/gh/colatkinson/bf.asm) [![License](https://img.shields.io/github/license/colatkinson/bf.asm.svg?style=flat-square)](https://github.com/colatkinson/bf.asm/blob/master/LICENSE)

## Why

idk lmao

## Installation

### Prerequisites

 * Python 3
 * nasm
 * CMake >= 3.12
 * A functioning C++ compiler (use g++-multilib on Debian-based systems if you want to run the tests)
 * dosemu (for running tests)

### Building

#### Build and run tests

```bash
./test.sh
```

This will build for all architectures, and will run some tests on the resulting binaries.


#### Manually

```bash
mkdir build
cd build
cmake -DBITS=64 ..
make
./c-test [some brainfuck file]
```

## Future Work

This is very much a work in progress, especially since my laptop is currently bricked. Here's some notable improvements to make:

 * Cleaning up the code
 * Giving the binaries more sensible names
 * More elegant error handling on DOS
 * An overview of the architecture of the project
 * Tests for the C library
 * More bin tests
 * Usage of a stack-like system instead of manual searching for loops
 * Trying to decrease the size of the DOS binary to <= 296 bytes (the size of the original)
 * Allowing the use of non-static memory for the interpreter's memory area (so it can be used multithreaded!)
