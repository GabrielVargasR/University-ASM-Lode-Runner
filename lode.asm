; Autor: Gabriel Vargas Rodríguez - 2018103129
; Arquitectura de Computadores - Grupo 2

include macros.asm

datos segment

    acercaDe1 db "LODE RUNNER - Autor: Gabriel Vargas Rodriguez - 2018103129", 0
    acercaDe2 db "Arquitectura de Computadores - Grupo 2", 0
    acercaDe3 db "Controles: ", 0
    acercaDe4 db "- Movimiento con flechas", 0
    acercaDe5 db "- Z y X para hacer agujeros", 0
    acercaDe6 db "- P para pausa", 0
    acercaDe7 db "Objetivo: conseguir todos los tesoros y subir al siguiente nivel", 0
    acercaDe8 db "Opciones (18103129 #):", 0
    acercaDe9 db "  j: modo juego", 0
    acercaDe10 db "  e: modo editor", 0
    acercaDe11 db "  h: modo acerca de", 0

    ds_highscore db "Highscores", 0
    ds_highscore2 db "NOM LVL  SCORE", 0
    highscore1 db " 1 ___ ___ 00000000", 0Ah, 0Dh
    highscore2 db " 2 ___ ___ 00000000", 0Ah, 0Dh
    highscore3 db " 3 ___ ___ 00000000", 0Ah, 0Dh
    highscore4 db " 4 ___ ___ 00000000", 0Ah, 0Dh
    highscore5 db " 5 ___ ___ 00000000", 0Ah, 0Dh
    highscore6 db " 6 ___ ___ 00000000", 0Ah, 0Dh
    highscore7 db " 7 ___ ___ 00000000", 0Ah, 0Dh
    highscore8 db " 8 ___ ___ 00000000", 0Ah, 0Dh
    highscore9 db " 9 ___ ___ 00000000", 0Ah, 0Dh
    highscore10 db "10 ___ ___ 00000000", 0Ah, 0Dh
    highscore11 db "11 ___ ___ 00000000", 0Ah, 0Dh
    highscore12 db "12 ___ ___ 00000000", 0Ah, 0Dh
    highscore13 db "13 ___ ___ 00000000", 0Ah, 0Dh
    highscore14 db "14 ___ ___ 00000000", 0Ah, 0Dh
    highscore15 db "15 ___ ___ 00000000", 0Ah, 0Dh
    highscore16 db "16 ___ ___ 00000000", 0Ah, 0Dh
    highscore17 db "17 ___ ___ 00000000", 0Ah, 0Dh
    highscore18 db "18 ___ ___ 00000000", 0Ah, 0Dh
    highscore19 db "19 ___ ___ 00000000", 0Ah, 0Dh
    highscore20 db "20 ___ ___ 00000000"
    archivoHS db "hscores.txt", 0
    hancleHS dw (?)

    archivoNivel db "original\orig021.txt", 0
    tamArchivoNivel dw (?)
    handleNivel dw (?)
    buffyNivel db 450 dup (?), '$'




datos ends

azul EQU 00010001b
escalera EQU 0000011101001000b; fondo negro, char blanco, H
ladrillo EQU 0011100000101011b;fondo celeste, char gris, +
cemento EQU 0011000101000011b; fondo y char celeste, C
ladrilloF EQU 0011100000101101b;fondo celeste, char gris, -
espacio EQU 0000000000100000b; fondo y char negro, 32d
tesoro EQU 0110000001010100b; fondo amarillo, char negro, T
enemigo EQU 0000010001011000b; fondo negro, char rojo, X
personaje EQU 0000010101000000b; fondo negro, char cyan, @
cuerda EQU 0000011101111110b; fondo negro, char blanco, ~

pila segment stack 'stack'

   dw 256 dup (?)

pila ends


codigo segment

   assume  cs:codigo, ds:datos, ss:pila

print proc far
    ; protocolo para imprimir un rótulo en la posición deseada
    ; espera posición en si, variable en bx y color en ah
    ; La variable debe venir en estilo like C
    push di

    xor di, di
    print_loop:
        cmp byte ptr [bx+di], 0
        je fin_print
        mov al, byte ptr [bx+di]; mueve caracter
        mov es:[si], ax; imprime caracter
        inc si
        inc si
        inc di
        jmp print_loop

    fin_print:
    pop di
    ret
print endP

pintaNivel proc far
    ; rutina para abrir el archivo del nivel y desplegarlo en pantalla
    ; espera el nombre del archivo en la variable archivoNivel
    ; regresa un 2 en el ax si el nivel del archivo no existe
    push bx
    push cx
    push dx
    push di
    push si

    ; ************************** Abre archivo de nivel *************************
    mov ah, 3Dh; para abrir con int 21h
    mov al, 0; para modo de lectura
    lea dx, archivoNivel
    int 21h
    jc errorAbrir
    mov handleNivel, ax; para guardar el handle
    jmp leeArchivoNivel
    errorAbrir:
    jmp finPintaNivel

    ; *************************** Lee archivo de nivel *************************
    leeArchivoNivel:
    xor cx, cx
    xor dx, dx; para hacer desplazamiento de 0
    mov ah, 42h; para mover file pointer
    mov al, 02; mueve file pointer desde el final del archivo
    mov bx, handleNivel
    int 21h
    mov tamArchivoNivel, ax; operación retorna tamaño en DX:AX

    mov ax, 4200h
    xor dx, dx
    int 21h ; regresa el file pointer al principio

    mov ax, 3F00h; para leer archivo con 21h
    mov bx, handleNivel
    mov cx, tamArchivoNivel
    lea dx, buffyNivel
    int 21h
    conejo jc,finPintaNivel

    ; *************************** Cierra archivo nivel *************************
    mov ax, 3E00h
    mov bx, handleNivel
    int 21h

    ; *************************** Pinta Nivel *************************
    mov si, 410; primera posición del cuadro de juego
    shl si, 1
    xor di, di
    lea bx, buffyNivel
    mov dx, 16
    loopNivel:
        mov cx, 26
        loopLinea:
            cmp byte ptr [bx+di], ' '
            je pintaNada
            cmp byte ptr [bx+di], 'L'
            je pintaLadrillo
            cmp byte ptr [bx+di], 'C'
            je pintaCemento
            cmp byte ptr [bx+di], 'E'
            je pintaEscalera
            cmp byte ptr [bx+di], 'F'
            je pintaFalso
            cmp byte ptr [bx+di], 'S'
            je pintaCuerda
            cmp byte ptr [bx+di], 'O'
            je pintaTesoro
            cmp byte ptr [bx+di], 'G'
            je guardaEscalera
            cmp byte ptr [bx+di], 'X'
            je pintaEnemigo
            cmp byte ptr [bx+di], '*'
            je pintaPersonaje
            ; Si no reconoce un character, pinta espacios en blanco
            pintaNada:
            mov ax, espacio
            jmp pintaChar
            pintaLadrillo:
            mov ax, ladrillo
            jmp pintaChar
            pintaCemento:
            mov ax, cemento
            jmp pintaChar
            pintaEscalera:
            mov ax, escalera
            jmp pintaChar
            pintaFalso:
            mov ax, ladrilloF
            jmp pintaChar
            pintaCuerda:
            mov ax, cuerda
            jmp pintaChar
            pintaTesoro:
            mov ax, tesoro
            jmp pintaChar
            guardaEscalera:
            mov ax, escalera
            jmp pintaChar
            pintaEnemigo:
            mov ax, enemigo
            jmp pintaChar
            pintaPersonaje:
            mov ax, personaje

            pintaChar:
            mov word ptr es:[si], ax
            inc di
            inc si
            inc si
            loop loopLinea
        add si, 108; apunta a siguiente línea
        inc di
        dec dx
        cmp dx, 0
        jne loopNivel




    finPintaNivel:
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    ret
pintaNivel endP

pintaHS proc far






    ret
pintaHS endP




inicio: mov ax, ds ; se mueve primero a un registro porque no se puede hacer un mov entre dos segmentos
        mov es, ax ; para no perder la direccion del psp

        mov ax, datos
        mov ds, ax

        mov ax, pila
        mov ss, ax

        opcion_juego:
        mov si, 82h
        cmp byte ptr es:[si], 'j'
        conejo je modo_juego

        opcion_editor:
        cmp byte ptr es:[si], 'e'
        conejo je modo_editor

        opcion_acerca:
            mov ax, 0B800h; comienzo de memoria gráfica
            mov es, ax
            mov ah, 00000100b; fondo negro letra roja

            lea bx, acercaDe1
            mov si, 818
            call print

            lea bx, acercaDe2
            mov si, 978
            call print

            lea bx, acercaDe3
            mov si, 1298
            call print

            lea bx, acercaDe4
            mov si, 1458
            call print

            lea bx, acercaDe5
            mov si, 1618
            call print

            lea bx, acercaDe6
            mov si, 1778
            call print

            lea bx, acercaDe7
            mov si, 2098
            call print

            lea bx, acercaDe8
            mov si, 2418
            call print

            lea bx, acercaDe9
            mov si, 2578
            call print

            lea bx, acercaDe10
            mov si, 2738
            call print

            lea bx, acercaDe11
            mov si, 2898
            call print

            jmp final

        modo_juego:
            mov ax, 0B800h; comienzo de memoria gráfica
            pinta_nivel:
                mov es, ax
                xor si, si
                mov al, '*'
                lineaH azul,28,16,4,9; imprime dos filas horizontales de 28 caracteres separadas por 16 filas a partir de 5ta fila, 10ma columna
                xor si, si
                lineaV azul,16,27,5,9; imprime 16 filas separadas por 26 columnas a partir de 6ta fila, 10ma columna
                call pintaNivel

            pinta_highscore:
                xor si, si
                lineaH azul,25,22,1,48; imprime dos filas horizontales de 25 caracteres separadas por 16 filas a partir de 5ta fila, columna 49
                xor si, si
                lineaV azul,22,24,2,48; imprime 16 filas separadas por 23 columnas a partir de 6ta fila, columna 49

                lea bx, ds_highscore
                mov si, 136
                shl si, 1; para posición del título
                mov ah, 00010111b; fondo azul, char blanco
                call print

                lea bx, ds_highscore2
                mov si, 213
                shl si, 1
                mov ah, 00000111b
                call print







        jmp final

        modo_editor:
        jmp final



final:
        mov ax, 4C00h ; para finalizacion en 21h
        int 21h ; termina programa

codigo ends

end inicio ; para que apunte a inicio cuando vaya a correr el programa
