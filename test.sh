#!/usr/bin/bash
set -e

mkdir -p build64
cd build64
cmake .. -DBITS=64
cmake --build .
./c-test ../bitwidth.bf
cd ..

mkdir -p build32
cd build32
cmake .. -DBITS=32
cmake --build .
./c-test ../bitwidth.bf
