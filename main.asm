[BITS 32]

extern bf_interp

SECTION .data
;bf_script: db "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.", 0
bf_script: db ",[.-[->+<]>+]", 0

SECTION .text
global main


main:
    push ebp
    mov ebp, esp

    push bf_script
    call bf_interp
    add esp, 8

    ; Reset the stack pointer
    mov esp, ebp
    pop ebp
    ret