syscall_putchar:
  push dx
  push ax

  mov ah, 2
  mov dl, [bf_mem_reg]
  int 0x21

  pop ax
  pop dx
  ret

syscall_getchar:
  mov ah, 1
  int 0x21

  mov [bf_mem_reg], ah

  ret
