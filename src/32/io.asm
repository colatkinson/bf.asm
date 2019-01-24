
%define syscall_write 4
%define STDOUT 1

; NOTE: This subroutine does not follow the C calling convention
; It takes its one parameter, the memory location to write, in bf_mem_reg
syscall_putchar:
    ; Save the base pointer
    push ebp
    mov ebp, esp

    .save_regs:
        push eax
        push ebx
        push ecx
        push edx

    .syscall:
        mov eax, syscall_write
        mov ebx, STDOUT
        ; Note: As of right now, this is a noop (bf_mem_reg == ecx)
        mov ecx, bf_mem_reg
        ; Write one byte
        mov edx, 1
        ; Linux syscall
        int 80h

    .restore:
        pop edx
        pop ecx
        pop ebx
        pop eax

    .end:
        ; Restore the base pointer
        pop ebp
        ret

%define syscall_read 3
%define STDIN 0
; NOTE: This subroutine does not follow the C calling convention
; It takes its one parameter, the memory location to write, in bf_mem_reg
syscall_getchar:
    ; Save the base pointer
    push ebp
    mov ebp, esp

    .save_regs:
        push ebx
        push ecx
        push edx

    .syscall:
        mov eax, syscall_read
        mov ebx, STDIN
        ; Read into our special buffer
        mov ecx, read_buf
        ; Read two bytes, the second of
        mov edx, 1
        ; Linux syscall
        int 80h

        ; If we get zero bytes, we've gotten EOF
        ; We handle this case specially
        cmp eax, 0
        je .eof

        ; Move the value we read into al
        xor eax, eax
        mov al, [read_buf]

    .restore:
        pop edx
        pop ecx
        pop ebx

    .end:
        ; Restore the base pointer
        pop ebp
        ret

    ; If we got EOF, we return -1 as a special value
    .eof:
        mov al, -1
        jmp .restore
