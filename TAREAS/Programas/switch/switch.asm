global _start
section .text

_start:
  xor cx, cx    ;Al hacer la XOR obtenemos un cero

loop1:
    nop       ;
    inc cx      ;Incrementamos nuestro registro en 1
    cmp cx,0x02   ;Comparamos si nuestro registro es igual a 10
    je case2   ;Si es menor o igual a 10 regresamos a nuestro loop
    cmp cx,0x04
    je case4
    cmp cx,0x08
    je case8
    cmp cx,0xa
    je salir
    jmp loop1

salir:
    mov eax,1   ;system call number (sys_exit)
    int 0x80    ;call kernel

case2:
  mov eax,0x41414141
  jmp loop1

case4:
  mov eax,0x42424242
  jmp loop1

case8:
  mov eax,0x43434343
  jmp loop1
