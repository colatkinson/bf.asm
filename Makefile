all:
	nasm -f elf -l bf.lst bf.asm 
	gcc -m32 -o bf bf.o
