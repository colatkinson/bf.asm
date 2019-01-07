[BITS 64]
DEFAULT REL

SECTION .data
%define bf_mem_sz 32768

; eax is the bf instruction pointer
%define bf_script_reg rbx
; ecx is the bf data pointer
%define bf_mem_reg rcx
; edx is the general computation register
%define comp_reg rdx

SECTION .bss

bf_mem: resb bf_mem_sz
read_buf: resb 3

SECTION .text

global bf_interp

; int bf_interp(const char *bf_str)
bf_interp:
    push rbp
    mov rbp, rsp

    .save_registers:
        push bf_script_reg
        push bf_mem_reg
        push comp_reg

    mov bf_script_reg, rdi
    mov bf_mem_reg, bf_mem + bf_mem_sz

    .clear_mem_loop:
        dec bf_mem_reg
        mov byte[bf_mem_reg], 0
        mov comp_reg, bf_mem
        cmp bf_mem_reg, comp_reg
        jnz .clear_mem_loop

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

        jmp .instr_end

    .loop_start_zero:
        ; Clear edx so we can use it for comparisons
        xor dx, dx
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

        ; If the current byte is 0, we don't go back to the loop start
        cmp dl, 0
        jz .instr_end

        ; Else, we return to the start of the loop
        jmp .loop_end_nonzero

    .loop_end_nonzero:
        xor dx, dx
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
        call syscall_putchar

        ; Continue the instruction loop
        jmp .instr_end


    .getc:
        ; Save the brainfuck IP
        push bf_script_reg
        ; Save the brainfuck mem pointer
        push bf_mem_reg

        ; Call getchar to read input
        call syscall_getchar

        ; Restore the mem pointer
        pop bf_mem_reg

        ; Save the byte from stdin to bf mem
        mov [bf_mem_reg], al

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
        inc bf_script_reg
        mov comp_reg, bf_mem
        add comp_reg, bf_mem_sz
        cmp bf_mem_reg, comp_reg
        jz .out_of_mem
        mov dl, byte[bf_script_reg]
        cmp dl, 0
        jnz .bf_loop

        xor eax, eax
        jmp .end

    .out_of_mem:
        ; 12 == ENOMEM
        mov eax, 12
        jmp .end

    .end:
        ; Restore registers
        pop comp_reg
        pop bf_mem_reg
        pop bf_script_reg

        ; Restore stack pointer
        pop rbp
        ret

%define syscall_write 1
%define STDOUT 1

; NOTE: This subroutine does not follow the C calling convention
; It takes its one parameter, the memory location to write, in bf_mem_reg
syscall_putchar:
    ; Save the base pointer
    push rbp
    mov rbp, rsp

    .save_regs:
        push rax
        push rdi
        push rsi
        push rdx
        push bf_mem_reg

    .syscall:
        mov rax, syscall_write
        mov rdi, STDOUT
        ; Note: As of right now, this is a noop (bf_mem_reg == ecx)
        mov rsi, bf_mem_reg
        ; Write one byte
        mov rdx, 1
        ; Linux syscall
        ; int 80h
        syscall

.restore:
  pop bf_mem_reg
        pop rdx
        pop rsi
        pop rdi
        pop rax

    .end:
        ; Restore the base pointer
        pop rbp
        ret

%define syscall_read 0
%define STDIN 0
; NOTE: This subroutine does not follow the C calling convention
; It takes its one parameter, the memory location to write, in bf_mem_reg
syscall_getchar:
    ; Save the base pointer
    push rbp
    mov rbp, rsp

    .save_regs:
        push rdi
        push rsi
        push rdx

    .syscall:
        mov rax, syscall_read
        mov rdi, STDIN
        ; Read into our special buffer
        mov rsi, read_buf
        ; Read two bytes, the second of
        mov rdx, 2
        ; Linux syscall
        ;int 80h
        syscall

        ; TODO Check return code of syscall

        ; Move the value we read into al
        xor rax, rax
        mov al, [read_buf]

        ; If we got EOF, read more
        cmp al, 0
        jl .syscall

        ; If we got newline, read more
        cmp al, 10
        je .syscall

    .restore:
        pop rdx
        pop rsi
        pop rdi

    .end:
        ; Restore the base pointer
        pop rbp
        ret
