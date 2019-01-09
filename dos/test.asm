[bits 16]
;[org 0x100]
section .text
start:
mov dx, msg
mov ah, 9
int 0x21

mov ah, 0x4c
int 0x21

msg: db "Hello, world!", 0x0d, 0x0a, '$'
