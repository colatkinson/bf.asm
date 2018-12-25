extern putchar
extern getchar

SECTION .data
bf_script:    db ",.", 0
fmt: db "%s", 10, 0
bf_mem: times 512 db 36

SECTION .text
global main

; eax is the bf instruction pointer
; ecx is the bf data pointer

main:
push ebp
mov ebp, esp

mov eax, bf_script
mov ecx, bf_mem

putc_loop:
mov dl, byte[eax]

cmp dl, ','
jz getc

cmp dl, '.'
jz putc

jmp instr_end

putc:
; Save eax and ecx before putchar
push eax
push ecx
; Clear ebx
xor ebx, ebx
; Set bl = *eax
mov bl, byte[ecx]
; Push ebx as an argument to putchar
push ebx
call putchar
; Remove the argument from the stack
add esp, 4
; Restore the bf instruction pointer
pop ecx
; Restore the bf memory pointer
pop eax
; Continue the instruction loop
jmp instr_end


getc:
; Save the brainfuck IP
push eax
; Save the brainfuck mem pointer
push ecx
; Call getchar to read input
call getchar
; Restore the mem pointer
pop ecx
; Save the resulting byte to bf mem
mov [ecx], al
; Restore eax
pop eax
; Continue
jmp instr_end


instr_end:
; Test if the current byte is \0
; TODO: Figure out how to prevent repetition
add eax, 1
mov bl, byte[eax]
cmp ebx, 0
jnz putc_loop

; Reset the stack pointer
mov esp, ebp
pop ebp

; Return 0
xor eax, eax
ret

