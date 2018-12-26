[BITS 32]

extern putchar
extern getchar
extern puts
extern scanf

SECTION .data
;bf_script:    db "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.---.+++++++.>,+.", 0
;bf_script: db "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++[.]", 0
;bf_script: db "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.", 0
;bf_script: db "++++++++++++++++++++[>+.]", 0
bf_script: db ",[.-[-->++<]>+]", 0
fmt: db "%s", 10, 0
bf_mem: times 16384 db 0
term_delim: db "> ", 0
bf_stack: times 512 db 0


SECTION .text
global main

; eax is the bf instruction pointer
; ecx is the bf data pointer

main:
push ebp
mov ebp, esp

mov eax, bf_script
mov edi, bf_stack
mov ecx, bf_mem

putc_loop:
mov dl, byte[eax]

cmp dl, ','
jz getc

cmp dl, '.'
jz putc

cmp dl, '>'
jz move_right

cmp dl, '<'
jz move_left

cmp dl, '+'
jz incr_dp

cmp dl, '-'
jz decr_dp

cmp dl, '['
jz loop_start

cmp dl, ']'
jz loop_end

jmp instr_end

loop_start:
mov dl, [ecx]
cmp dl, 0
jz loop_start_zero

mov [edi], eax
add edi, 4
jmp instr_end

loop_start_zero:
xor edx, edx
.loop:
inc eax
mov dl, byte[eax]
cmp dl, '['
jnz .not_new_nest
inc dh
.not_new_nest:
cmp dl, ']'
jnz .not_close
dec dh
.not_close:
cmp dh, 0
jnz .loop
jmp instr_end

loop_end:
mov dl, [ecx]
;cmp dl, 0
;jz instr_end
;jnz loop_end_nonzero
;jmp instr_end

sub edi, 4

cmp dl, 0
jz instr_end

mov eax, [edi]
;inc eax
dec eax
jmp instr_end

loop_end_nonzero:
xor edx, edx
.loop:
dec eax
mov dl, byte[eax]
cmp dl, ']'
jnz .not_new_nest
inc dh
.not_new_nest:
cmp dl, '['
jnz .not_open
dec dh
.not_open:
cmp dh, 0
jnz .loop
;inc eax
jmp instr_end

putc:
; Save eax and ecx before putchar
push eax
push edi
push ecx
; Clear ebx
xor ebx, ebx
; Set bl = *ecx
mov bl, byte[ecx]
; Push ebx as an argument to putchar
push ebx
call putchar
; Remove the argument from the stack
add esp, 4
; Restore the bf instruction pointer
pop ecx
; Restore the bf stack pointer
 pop edi
; Restore the bf memory pointer
pop eax
; Continue the instruction loop
jmp instr_end


getc:
; Save the brainfuck IP
push eax
; Save the bf stack
push edi
; Save the brainfuck mem pointer
push ecx
; Call getchar to read input
.getc_loop:
call getchar
; If the result is \n, ignore it
cmp al, 10
jz .getc_loop
; Restore the mem pointer
pop ecx
; Save the resulting byte to bf mem
mov [ecx], al
; Restore ebx
pop edi
; Restore eax
pop eax
; Continue
jmp instr_end


move_right:
add ecx, 1
jmp instr_end

move_left:
sub ecx, 1
jmp instr_end


incr_dp:
mov dl, byte[ecx]
inc dl
mov [ecx], dl
jmp instr_end


decr_dp:
mov dl, byte[ecx]
dec dl
mov [ecx], dl
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

