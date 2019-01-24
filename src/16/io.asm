syscall_putchar:
  push dx
  push ax

  mov ah, 2
  mov dl, [bf_mem_reg]
  int 0x21

  pop ax
  pop dx
  ret

dos_read_buf: db 2
dos_read_buf_ret: db 0
dos_read_buf_data: db 0, 0

syscall_getchar:
  push dx
  push bx
  push cx
;  push ax

  ;mov ah, 0x0A
  ;mov dx, dos_read_buf
  ;mov dl, 0xFF
  ;int 0x21
  mov ah, 0x3F
  mov bx, 0
  mov cx, 1
  mov dx, dos_read_buf_data
  int 0x21

  ;jc .eof

  cmp ax, 0
  je .eof

  ;jc .eof

  ;mov dl, [dos_read_buf_ret]
  ;jmp .eof

  ;mov dl, [dos_read_buf_ret]
  ;mov ah, 2
  ;int 0x21

  mov al, [dos_read_buf_data]
  ;mov dl, [dos_read_buf_ret]
  cmp al, -1
  je .eof

  ;mov [bf_mem_reg], ah

;  mov dl, ah
;  mov ah, 2
;  int 0x21

  ;cmp ah, 0xFF
  ;je .eof

.end:
  ;  pop ax
  pop cx
  pop bx
  pop dx
    ret

  .eof:
    ;mov ah, 2
  ;mov dl, 'Q'
  mov al, -1
    int 0x21
    jmp .end
