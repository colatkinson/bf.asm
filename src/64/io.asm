%define syscall_write 1
%define STDOUT 1

; NOTE: This subroutine does not follow the C calling convention
; It takes its one parameter, the memory location to write, in bf_mem_reg
; TODO(colin): Clean all this up
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
        ; Note that while rdi is the second argument to write(), order of
        ; operations is important because bf_mem_reg == rdi
        mov rsi, bf_mem_reg
        mov rdi, STDOUT
        ; Write one byte
        mov rdx, 1
        ; Linux syscall
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
        mov rdx, 1
        ; Linux syscall
        syscall

        ; If we get zero bytes, we've gotten EOF
        ; We handle this case specially
        cmp rax, 0
        je .eof

        ; Move the value we read into al
        xor rax, rax
        mov al, [read_buf]

    .restore:
        pop rdx
        pop rsi
        pop rdi

    .end:
        ; Restore the base pointer
        pop rbp
        ret

    ; If we got EOF, we return -1 as a special value
    .eof:
        mov al, -1
        jmp .restore
