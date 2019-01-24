[BITS 32]

%define bf_mem_sz 0x8000

SECTION .bss
bf_mem: resb bf_mem_sz
read_buf: resb 1
