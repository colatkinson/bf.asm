%include "pre.asm"

%include "regs.asm"

SECTION .text

%include "io.asm"

global bf_interp

; int bf_interp(const char *bf_str)
bf_interp:
    push base_ptr_reg
    mov base_ptr_reg, stack_ptr_reg

    .save_registers:
        push bf_script_reg
        push bf_mem_reg
        push comp_reg

    %include "set_script_mem.asm"

    mov comp_reg, bf_mem
    .clear_mem_loop:
        dec bf_mem_reg
        mov byte[bf_mem_reg], 0
        cmp bf_mem_reg, comp_reg
        jnz .clear_mem_loop

    .bf_loop:
        mov comp_lo, byte[bf_script_reg]

        cmp comp_lo, ','
        jz .getc

        cmp comp_lo, '.'
        jz .putc

        cmp comp_lo, '>'
        jz .move_right

        cmp comp_lo, '<'
        jz .move_left

        cmp comp_lo, '+'
        jz .incr_dp

        cmp comp_lo, '-'
        jz .decr_dp

        cmp comp_lo, '['
        jz .loop_start

        cmp comp_lo, ']'
        jz .loop_end

        jmp .instr_end

    .loop_start:
        mov comp_lo, byte[bf_mem_reg]
        cmp comp_lo, 0
        jz .loop_start_zero

        jmp .instr_end

    .loop_start_zero:
        ; Clear edx so we can use it for comparisons
        xor comp_reg, comp_reg
        inc comp_hi
        .lsz_loop:
            ; Move to the next bf instruction
            inc bf_script_reg
            ; Get the current instruction
            mov comp_lo, byte[bf_script_reg]
            ; Check if there's another nested loop
            cmp comp_lo, '['
            jnz .after_nest_check
            ; We use dh as a counter for the levels of nesting
            inc comp_hi
            .after_nest_check:
                ; Now we check if the current instruction is the end of a loop
                cmp comp_lo, ']'
                jnz .after_loop_close
                ; If it is, we decrement our counter
                dec comp_hi
            .after_loop_close:
                ; Now, if we haven't reached the exit point of the loop,
                ; we continue the loop
                cmp comp_hi, 0
                jnz .lsz_loop
        jmp .instr_end

    .loop_end:
        ; Read the byte from the bf data pointer
        mov comp_lo, byte[bf_mem_reg]

        ; If the current byte is 0, we don't go back to the loop start
        cmp comp_lo, 0
        jz .instr_end

        ; Else, we return to the start of the loop
        jmp .loop_end_nonzero

    .loop_end_nonzero:
        xor comp_reg, comp_reg
        inc comp_hi
        .loop:
            dec bf_script_reg
            mov comp_lo, byte[bf_script_reg]
            cmp comp_lo, ']'
            jnz .after_new_nest
            inc comp_hi
        .after_new_nest:
            cmp comp_lo, '['
            jnz .after_open
            dec comp_hi
        .after_open:
            cmp comp_hi, 0
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
        mov comp_lo, byte[bf_mem_reg]
        inc comp_lo
        mov [bf_mem_reg], comp_lo
        jmp .instr_end

    .decr_dp:
        mov comp_lo, byte[bf_mem_reg]
        dec comp_lo
        mov [bf_mem_reg], comp_lo
        jmp .instr_end

    .instr_end:
        ; Test if the current byte is \0
        ; TODO: Figure out how to prevent repetition
        inc bf_script_reg
        mov comp_reg, bf_mem
        add comp_reg, bf_mem_sz

        cmp bf_mem_reg, comp_reg
        jz .out_of_mem
        mov comp_lo, byte[bf_script_reg]
        cmp comp_lo, 0
        jnz .bf_loop

        xor ret_reg, ret_reg
        jmp .end

    .out_of_mem:
        ; 12 == ENOMEM
        mov ret_reg, 12
        jmp .end

    .end:
        ; Restore registers
        pop comp_reg
        pop bf_mem_reg
        pop bf_script_reg

        ; Restore stack pointer
        pop base_ptr_reg
        ret

%include "post.asm"
