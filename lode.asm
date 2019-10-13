; Autor: Gabriel Vargas Rodríguez - 2018103129
; Arquitectura de Computadores - Grupo 2

include macros.asm

datos segment

   abc db "Hello$"

datos ends

azul EQU 00010001b
rojo EQU 01000100b

pila segment stack 'stack'

   dw 256 dup (?)

pila ends


codigo segment

   assume  cs:codigo, ds:datos, ss:pila


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
        println abc
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
                lineaH rojo,25,16,4,48; imprime dos filas horizontales de 25 caracteres separadas por 16 filas a partir de 5ta fila, columna 49
                xor si, si
                lineaV rojo,16,24,5,48; imprime 16 filas separadas por 23 columnas a partir de 6ta fila, columna 49


        jmp final

        modo_editor:
        jmp final



final:
        mov ax, 4C00h ; para finalizacion en 21h
        int 21h ; termina programa

codigo ends

end inicio ; para que apunte a inicio cuando vaya a correr el programa
