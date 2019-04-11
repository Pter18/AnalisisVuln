global _start
section .text

_start:
  xor cx, cx    ;Al hacer la XOR obtenemos un cero

loop1:
    nop
    inc cx
    cmp cx,10
    jle loop1

    mov eax,1
    int 0x080
    
