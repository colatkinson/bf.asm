#!/usr/bin/bash
set -e

cyan="\033[0;36m"
nc="\033[0m"

echo -e "${cyan}Building 64-bit${nc}"
mkdir -p build64
cd build64
cmake .. -DBITS=64
cmake --build .
echo -e "${cyan}Running 64-bit${nc}"
./c-test ../bitwidth.bf
cd ..
echo

echo -e "${cyan}Building 32-bit${nc}"
mkdir -p build32
cd build32
cmake .. -DBITS=32
cmake --build .
echo -e "${cyan}Running 32-bit${nc}"
./c-test ../bitwidth.bf
cd ..
echo

echo -e "${cyan}Building 16-bit${nc}"
mkdir -p build16
cd build16
cmake .. -DBITS=16
cmake --build .
