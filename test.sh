#!/usr/bin/bash
set -e

cyan="\033[0;36m"
nc="\033[0m"

function err_check {
    echo -e ${1}

    if [[ ${1} != "Hello World! 255" ]]; then
        >&2 echo "Invalid output"
        exit 1
    fi
}

echo -e "${cyan}Building 64-bit${nc}"
mkdir -p build64
cd build64
cmake .. -DBITS=64
cmake --build .
echo -e "${cyan}Running 64-bit${nc}"
val=$(./c-test ../bitwidth.bf)
err_check "$val"
cd ..
echo

echo -e "${cyan}Building 32-bit${nc}"
mkdir -p build32
cd build32
cmake .. -DBITS=32
cmake --build .
echo -e "${cyan}Running 32-bit${nc}"
val=$(./c-test ../bitwidth.bf)
err_check "$val"
cd ..
echo

echo -e "${cyan}Building 16-bit${nc}"
mkdir -p build16
cd build16
cmake .. -DBITS=16
cmake --build .
echo -e "${cyan}Running 16-bit${nc}"
val=$(dosemu -dumb ./dos/dos_test.com 2>/dev/null)
err_check "$val"
