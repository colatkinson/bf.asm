[BITS 32]

SECTION .data
%define bf_mem_sz 32768

; eax is the bf instruction pointer
%define bf_script_reg eax
; ecx is the bf data pointer
%define bf_mem_reg ecx

extern putchar
extern getchar

bf_mem: times bf_mem_sz db 0

SECTION .text

global bf_interp

; int bf_interp(const char *bf_str)
bf_interp:
    push ebp
    mov ebp, esp

    mov bf_script_reg, [ebp + 8]
    mov bf_mem_reg, bf_mem

    .bf_loop:
        mov dl, byte[bf_script_reg]

        cmp dl, ','
        jz .getc

        cmp dl, '.'
        jz .putc

        cmp dl, '>'
        jz .move_right

        cmp dl, '<'
        jz .move_left

        cmp dl, '+'
        jz .incr_dp

        cmp dl, '-'
        jz .decr_dp

        cmp dl, '['
        jz .loop_start

        cmp dl, ']'
        jz .loop_end

        jmp .instr_end

    .loop_start:
        mov dl, byte[bf_mem_reg]
        cmp dl, 0
        jz .loop_start_zero

        ; mov [edi], eax
        ; add edi, 4
        jmp .instr_end

    .loop_start_zero:
        ; Clear edx so we can use it for comparisons
        xor edx, edx
        inc dh
        .lsz_loop:
            ; Move to the next bf instruction
            inc bf_script_reg
            ; Get the current instruction
            mov dl, byte[bf_script_reg]
            ; Check if there's another nested loop
            cmp dl, '['
            jnz .after_nest_check
            ; We use dh as a counter for the levels of nesting
            inc dh
            .after_nest_check:
                ; Now we check if the current instruction is the end of a loop
                cmp dl, ']'
                jnz .after_loop_close
                ; If it is, we decrement our counter
                dec dh
            .after_loop_close:
                ; Now, if we haven't reached the exit point of the loop,
                ; we continue the loop
                cmp dh, 0
                jnz .lsz_loop
        jmp .instr_end

    .loop_end:
        ; Read the byte from the bf data pointer
        mov dl, byte[bf_mem_reg]

        ; Remove a value from the stack
        sub edi, 4

        ; If the current byte is 0, we don't go back to the loop start
        cmp dl, 0
        jz .instr_end

        ; Else, we return to the start of the loop
        ; mov eax, [edi]
        ; dec eax
        jmp .loop_end_nonzero

    .loop_end_nonzero:
        xor edx, edx
        inc dh
        .loop:
            dec bf_script_reg
            mov dl, byte[bf_script_reg]
            cmp dl, ']'
            jnz .after_new_nest
            inc dh
        .after_new_nest:
            cmp dl, '['
            jnz .after_open
            dec dh
        .after_open:
            cmp dh, 0
            jnz .loop
            jmp .instr_end

    .putc:
        ; Save eax and ecx before putchar
        push bf_script_reg
        push edi
        push bf_mem_reg

        ; Clear ebx
        xor ebx, ebx

        ; Set bl = *bf_mem_reg
        mov bl, byte[bf_mem_reg]
        ; Push ebx as an argument to putchar
        push ebx
        call putchar
        ; Remove the argument from the stack
        add esp, 4

        ; Restore the bf instruction pointer
        pop bf_mem_reg
        ; Restore the bf stack pointer
        pop edi
        ; Restore the bf memory pointer
        pop bf_script_reg

        ; Continue the instruction loop
        jmp .instr_end


    .getc:
        ; Save the brainfuck IP
        push bf_script_reg
        ; Save the bf stack
        push edi
        ; Save the brainfuck mem pointer
        push bf_mem_reg

        ; Call getchar to read input
        .getc_loop:
            call getchar
            ; If the result is \n, ignore it
            cmp al, 10
            jz .getc_loop

        ; Restore the mem pointer
        pop bf_mem_reg

        ; Save the byte from stdin to bf mem
        mov [bf_mem_reg], al

        ; Restore ebx
        pop edi
        ; Restore eax
        pop bf_script_reg

        ; Continue
        jmp .instr_end


    .move_right:
        inc bf_mem_reg
        jmp .instr_end

    .move_left:
        dec bf_mem_reg
        jmp .instr_end


    .incr_dp:
        mov dl, byte[bf_mem_reg]
        inc dl
        mov [bf_mem_reg], dl
        jmp .instr_end

    .decr_dp:
        mov dl, byte[bf_mem_reg]
        dec dl
        mov [bf_mem_reg], dl
        jmp .instr_end

    .instr_end:
        ; Test if the current byte is \0
        ; TODO: Figure out how to prevent repetition
        add bf_script_reg, 1
        cmp bf_mem_reg, bf_mem + bf_mem_sz
        jz .out_of_mem
        mov bl, byte[bf_script_reg]
        cmp ebx, 0
        jnz .bf_loop

        xor eax, eax
        jmp .end

    .out_of_mem:
        mov eax, 12
        jmp .end

    .end:
        pop ebp
        ret