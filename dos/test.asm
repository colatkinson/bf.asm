[bits 16]

section .text
extern bf_interp

%define bf 0x6000

start:
  ; 0x81 is the location of the command line arguments in the DOS PSP
  ; (Program Segment Prefix). The arguments may be of length at most 127
  ; (including the terminating CR)
  ; If 0x80 (the length prefix of the arguments) is higher than this, something
  ; funky is going on
  xor bx, bx
  mov bl, [0x80]
  cmp bl, 0x7E
  ja bad_exit

  ; Make the command line arguments NUL-temrinated
  mov byte [bx + 0x81], 0

  ; Open file handle
  mov ah, 0x3D
  mov al, 0
  mov dx, 0x82
  int 0x21

  ; If there was an error, exit early
  jc bad_exit

  ; Save the file handle for later
  push ax

  ; Read a set number of bytes from the file handle
  ; TODO(colin): Allow reading an arbitrary amount
  mov bx, ax
  mov ah, 0x3F
  mov cx, 0x4000
  mov dx, bf
  int 0x21

  jc bad_exit

  mov bx, ax
  mov byte [bf + bx], 0

  ; Call our brainfuck interpreter using the script we read
  mov ax, bf
  call bf_interp
  ; TODO(colin): Check return code

  ; Close the handle
  pop bx
  mov ah, 0x3E
  int 0x21
  jc bad_exit

exit:
  mov ah, 0x4C
  int 0x21

bad_exit:
  mov ah, 0x02
  mov dl, al
  int 0x21
  jmp exit
