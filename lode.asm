; Autor: Gabriel Vargas Rodríguez - 2018103129
; Arquitectura de Computadores - Grupo 2

include macros.asm

datos segment

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

    archivo_nivel db "original\orig021.txt", 0
    handle_nivel dw (?)



datos ends

azul EQU 00010001b
celeste EQU 00110011b
escalera EQU 0000011101001000b; fondo negro, char blanco, H
ladrillo EQU 0011100000101011b;fondo celeste, char gris, +
cemento EQU 0011000101000011b; fondo y char celeste, C
ladrilloF EQU 0011100000101101b;fondo celeste, char gris, -
espacio EQU 0000000000100000b; fondo y char negro, 32d
tesoro EQU 0110000001001111b; fondo amarillo, char negro, O
enemigo EQU 0000010001010100b; fondo negro, char rojo, X
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

pinta_nivel proc far
    ; rutina para abrir el archivo del nivel y desplegarlo en pantalla
    ; espera el nombre del archivo en la variable archivo_nivel

    mov ah, 3Dh; para abrir con int 21h
    mov al, 0; para modo de lectura
    lea dx, archivo_nivel
    int 21h
    jc error_abrir
    mov handle_nivel, ax; para guardar el handle
    jmp fin_abrir
    error_abrir:
    mov dx, ax
    xor al, al
    mov ah, 02
    add dx, 30h
    int 21h
    jmp final
    fin_abrir:
    ret
pinta_nivel endP


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
        ;println ds_highscore
        jmp final


        modo_juego:
        mov ax, 0B800h; comienzo de memoria gráfica
            pinta_cuadrado:
                mov es, ax
                xor si, si
                mov al, '*'
                lineaH azul,28,16,4,9; imprime dos filas horizontales de 28 caracteres separadas por 16 filas a partir de 5ta fila, 10ma columna
                xor si, si
                lineaV azul,16,27,5,9; imprime 16 filas separadas por 26 columnas a partir de 6ta fila, 10ma columna

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

                call pinta_nivel





        jmp final

        modo_editor:
        jmp final



final:
        mov ax, 4C00h ; para finalizacion en 21h
        int 21h ; termina programa

codigo ends

end inicio ; para que apunte a inicio cuando vaya a correr el programa
