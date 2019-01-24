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

echo -e "${cyan}Installing Python dependencies${nc}"
python3 -m pip install -r requirements.txt
echo

echo -e "${cyan}Linting Python code${nc}"
black --check bin_tests
echo

echo -e "${cyan}Building 64-bit${nc}"
mkdir -p build64
cd build64
cmake .. -DBITS=64
cmake --build .
cd ..
echo

echo -e "${cyan}Building 32-bit${nc}"
mkdir -p build32
cd build32
cmake .. -DBITS=32
cmake --build .
cd ..
echo

echo -e "${cyan}Building 16-bit${nc}"
mkdir -p build16
cd build16
cmake .. -DBITS=16
cmake --build .
cd ..
echo

echo -e "${cyan}Running Python tests${nc}"
pytest bin_tests/main.py
