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
    acercaDe7 db "- S para pasar al siguiente nivel (invalida highscore)", 0
    acercaDe8 db "Objetivo: conseguir todos los tesoros y subir al siguiente nivel", 0
    acercaDe9 db "Opciones (18103129 #):", 0
    acercaDe10 db "  j: modo juego", 0
    acercaDe11 db "  e: modo editor", 0
    acercaDe12 db "  h: modo acerca de", 0

    archivoNivel db "original\orig001.txt", 0, '$'
    contadorNivel dw 1
    tamArchivoNivel dw (?)
    handleNivel dw (?)
    buffyNivel db 450 dup (?)


    ds_nivel db "Nivel", 0
    ds_vidas db "Men:", 0
    ds_GameOver db "Game Over", 0Ah, 0Dh, "Thanks for the run$"


    archivoHS db "hscores.txt", 0
    handleHS dw (?)
    ds_highscore db "Highscores", 0
    ds_highscore2 db "NOM LVL  SCORE", 0
    buffyHS db " 1 ___ ___ 00000000", 0Ah
     db " 2 ___ ___ 00000000", 0Ah
     db " 3 ___ ___ 00000000", 0Ah
     db " 4 ___ ___ 00000000", 0Ah
     db " 5 ___ ___ 00000000", 0Ah
     db " 6 ___ ___ 00000000", 0Ah
     db " 7 ___ ___ 00000000", 0Ah
     db " 8 ___ ___ 00000000", 0Ah
     db " 9 ___ ___ 00000000", 0Ah
     db "10 ___ ___ 00000000", 0Ah
     db "11 ___ ___ 00000000", 0Ah
     db "12 ___ ___ 00000000", 0Ah
     db "13 ___ ___ 00000000", 0Ah
     db "14 ___ ___ 00000000", 0Ah
     db "15 ___ ___ 00000000", 0Ah
     db "16 ___ ___ 00000000", 0Ah
     db "17 ___ ___ 00000000", 0Ah
     db "18 ___ ___ 00000000", 0Ah
     db "19 ___ ___ 00000000", 0Ah
     db "20 ___ ___ 00000000"

     tiempoPJ1 dw 1500
     tiempoPJ2 db 100

     posicionInicial dw ?
     posicionJugador dw ?
     vidasJugador db 5
     celdaVieja dw espacio
     direccionActual db 0
     scorePartida dw 0
     scoreText db '00000'

     modoVideo dw ?

     archivoNivelNuevo db "nuevos\nuevo001.txt", 0
     contadorNivelNuevo dw 1
     contadorLinea dw 0
     handleNivelNuevo dw (?)
     buffyNivelNuevo db 432 dup (?)



datos ends

azul EQU 00010001b
escalera EQU 0000011101001000b; fondo negro, char blanco, H
ladrillo EQU 0011100000101011b;fondo celeste, char gris, +
cemento EQU 0011001101000011b; fondo y char celeste, C
ladrilloF EQU 0011100000101101b;fondo celeste, char gris, -
espacio EQU 0000000000100000b; fondo y char negro, 32d
tesoro EQU 0110000001010100b; fondo amarillo, char negro, T
enemigo EQU 0000010001011000b; fondo negro, char rojo, X
personaje EQU 0000010101000000b; fondo negro, char cyan, @
cuerda EQU 0000011101111110b; fondo negro, char blanco, ~

puntosNivel EQU 1500
puntosTesoro EQU 250
puntosTrap EQU 75 ; tanto encerrar como respawn

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

pintaHS proc far
    ; rutina para imprimir el highscore
    push ax
    push bx
    push cx
    push dx
    push di
    push si

    ; ********************* Maneja Archivo de Highscores ***********************
    mov ah, 3Dh; para abrir con int 21h
    mov al, 0; para modo de lectura
    lea dx, archivoHS
    int 21h
    jc creaFileHS
    mov handleHS, ax; para guardar el handle
    jmp leeArchivoHS

    creaFileHS:
        mov ax, 3C00h; para crear archivo en modo esctiruta
        xor cx, cx
        inc cx; modo escritura
        lea dx, archivoHS
        int 21h

    abreFileNuevoHS:
        mov ax, 3D01h; escritura en archivo
        lea dx, archivoHS
        int 21h
        conejo jc,final
        mov handleHS, ax
    escribeFileNuevoHS:
        mov ax, 4000h
        mov bx, handleHS
        mov cx, 399; tamaño del buffer
        lea dx, buffyHS
        int 21h
        conejo jc,final
        cerrar_archivo handleHS
        jmp pintaBufferHS

    leeArchivoHS:
        mov ax, 3F00h
        mov bx, handleHS
        mov cx, 399; tamaño del buffer
        lea dx, buffyHS
        int 21h

    ; ****************** Pinta Highscores a partir del buffer ******************
    pintaBufferHS:
    mov ah, 00000111b; fondo negro, letra blanca
    lea bx, buffyHS
    mov si, 738; comienzo de área de highscore
    xor di, di

    mov dx, 20
    loopHS:
        mov cx, 19
        loopLineaHS:
            mov al, byte ptr [bx + di]
            mov es:[si], ax
            inc si
            inc si
            inc di
        loop loopLineaHS
        inc di; salta enter
        add si, 122; siguiente línea del área de highscore
        dec dx
        cmp dx, 0
    jne loopHS

    finPintaHS:
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
pintaHS endP

actualizaHS proc far
    ret
actualizaHS endP

gameOver proc far
    call actualizaHS
    call pintaHS
    mov ah, 09h
    lea dx, ds_GameOver
    int 21h
    jmp final
gameOver endP

pintaVidas proc far
    ; rutina para imprimir cantidad de vidas
    push ax
    push bx
    push si

    mov ah, 00010111b
    mov si, 3390
    add vidasJugador, 30h
    lea bx, vidasJugador
    mov byte ptr ds:[bx+1], 0
    call print
    sub vidasJugador, 30h

    cmp vidasJugador, 0
    jne finPintaVidas
    call gameOver

    finPintaVidas:
    pop si
    pop bx
    pop ax
    ret
pintaVidas endP

siguienteNivel proc far
    ; Rutina para cambiar al siguiente nivel disponible
    push ax
    push bx
    push cx
    push di

    mov direccionActual, 0; para frenar el juego si está en proceso
    mov celdaVieja, espacio; para no traer basura del nivel anterior

    cmp contadorNivel, 150; para hacer cíclico el proceso
    jl normal
    mov contadorNivel, 1

    normal:
    xor ah, ah
    xor di, di
    mov di, 13
    lea bx, archivoNivel
    mov ax, contadorNivel
    mov cx, 10

    cmp ax, 10
    jl nsnUnDigito
    cmp ax, 100
    jl nsnDosDigitos

    div cl; contadorNivel / 10
    add ah, 30h; para ascii
    mov byte ptr [bx + 15], ah; último dígito queda en el ah
    xor ah, ah; queda solo al en el ax
    div cl; cociente de contadorNivel / 10
    add al, 30h
    mov byte ptr [bx + di], al
    inc di
    add ah, 30h
    mov byte ptr [bx + di], ah
    jmp finNsn

    nsnUnDigito:
        mov byte ptr [bx + di], '0'
        inc di
        mov byte ptr [bx + di], '0'
        inc di
        add al, 30h
        mov byte ptr [bx + di], al
        jmp finNsn
    nsnDosDigitos:
        mov byte ptr [bx + di], '0'
        inc di
        div cl
        add al, 30h
        mov byte ptr [bx + di], al
        inc di
        add ah, 30h
        mov byte ptr [bx + di], ah

    finNsn:
    pop di
    pop cx
    pop bx
    pop ax
    ret
siguienteNivel endP

siguienteNivelOriginal proc
    ; Rutina para cambiar al siguiente nivel original no creado
    push ax
    push bx
    push cx
    push di

    cmp contadorNivelNuevo, 150; para hacer cíclico el proceso
    jl normalOg
    mov contadorNivelNuevo, 1

    normalOg:
    xor ah, ah
    xor di, di
    mov di, 12
    lea bx, archivoNivelNuevo
    mov ax, contadorNivelNuevo
    mov cx, 10

    cmp ax, 10
    jl nsnUnDigitoOg
    cmp ax, 100
    jl nsnDosDigitosOg

    div cl; contadorNivel / 10
    add ah, 30h; para ascii
    mov byte ptr [bx + 14], ah; último dígito queda en el ah
    xor ah, ah; queda solo al en el ax
    div cl; cociente de contadorNivel / 10
    add al, 30h
    mov byte ptr [bx + di], al
    inc di
    add ah, 30h
    mov byte ptr [bx + di], ah
    jmp finNsnOg

    nsnUnDigitoOg:
        mov byte ptr [bx + di], '0'
        inc di
        mov byte ptr [bx + di], '0'
        inc di
        add al, 30h
        mov byte ptr [bx + di], al
        jmp finNsnOg
    nsnDosDigitosOg:
        mov byte ptr [bx + di], '0'
        inc di
        div cl
        add al, 30h
        mov byte ptr [bx + di], al
        inc di
        add ah, 30h
        mov byte ptr [bx + di], ah

    finNsnOg:
    inc contadorNivelNuevo
    pop di
    pop cx
    pop bx
    pop ax
    ret
siguienteNivelOriginal endP

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
    inicioPintaNivel:
    mov ah, 3Dh; para abrir con int 21h
    mov al, 0; para modo de lectura
    lea dx, archivoNivel
    int 21h
    jc errorAbrir
    mov handleNivel, ax; para guardar el handle
    jmp leeArchivoNivel
    errorAbrir:
    cmp ax, 2; no encontró nombre de archivo
    conejo jne finPintaNivel; error fatal
    inc contadorNivel; para llevar conteo
    call siguienteNivel
    jmp inicioPintaNivel

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

    ; *************************** Pinta Rotulo Nivel ***************************
    lea bx, ds_nivel
    mov si, 676
    mov ah, 00010111b
    call print; imprime rótulo nivel

    mov si, 688
    mov ah, 00010111b
    lea bx, archivoNivel
    mov al, byte ptr [bx+13]
    mov word ptr es:[si], ax
    inc si
    inc si
    mov al, byte ptr [bx+14]
    mov word ptr es:[si], ax
    inc si
    inc si
    mov al, byte ptr [bx+15]
    mov word ptr es:[si], ax; imprime número de nivel

    ; *************************** Pinta Nivel **********************************
    mov posicionJugador, 0; para determinar después si hay jugador o no
    mov si, 410; primera posición del cuadro de juego
    shl si, 1
    xor di, di
    lea bx, buffyNivel
    mov dx, 16; 16 fila por columna
    loopNivel:
        mov cx, 26; 26 columnas
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
            mov posicionInicial, si; guarda posición inicial del jugador
            mov posicionJugador, si; guarda posición inicial del jugador

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
        conejo jne loopNivel

        mov si, posicionJugador
        cmp word ptr es:[si], personaje; si no son iguales, no hay jugador
        je finPintaNivel; si no encuentra personaje, no se puede jugar
        inc contadorNivel
        call siguienteNivel; prepara variable
        jmp inicioPintaNivel


    finPintaNivel:
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    ret
pintaNivel endP

pausaJugador proc far
    ; rutina para hacer una pausa de 100 x 1000 nops
    push cx

    mov cx, tiempoPJ1
    pausaJ1:
        push cx
        mov cl, tiempoPJ2
    pausaJ2:
        nop
    loop pausaJ2
    pop cx
    loop pausaJ1

    pop cx
    ret
pausaJugador endP

mueveJugador proc far
    ; Rutina para mover al jugador
    push ax
    push si

    mov al, direccionActual
    mov si, posicionJugador
    mov di, si; se usa para la celda a moverse

    cmp celdaVieja, tesoro
    jne comparaDir
    add scorePartida, puntosTesoro
    mov celdaVieja, espacio

    comparaDir:
    cmp al, 0; puede ser que esté quieto o se esté cayendo
    jne isUp
    add di, 160; abajo del jugador
    cmp word ptr es:[di], espacio
    conejo je seCae
    sub di, 160; restaura di
    jmp finMueveJugador
    isUp:
    cmp al, 1
    jne isIzq
    jmp movUp
    isIzq:
    cmp al, 2
    jne isDer
    jmp movIzq
    isDer:
    cmp al, 3
    jne isDown
    jmp movDer
    isDown:
    cmp al, 4
    jmp movDown

    movUp:
        sub di, 160; celda de arriba
        cmp word ptr es:[di], enemigo
        conejo je muere
        mov bx, celdaVieja
        mov ax, word ptr es:[si]; guarda jugador en ax
        cmp bx, escalera
        conejo jne noUp
        mov word ptr es:[si], bx; restaura celda vieja
        mov bx, word ptr es:[di]
        mov celdaVieja, bx; guarda contenidos de la celda a moverse
        mov word ptr es:[di], ax; mueve jugador a la nueva posición
        jmp finMueveJugador

    movIzq:
        dec di
        dec di
        cmp word ptr es:[di], enemigo
        conejo je muere
        cmp word ptr es:[di], 0001000100101010b; delimitador de área de juego
        conejo je noIzq
        mov bx, celdaVieja
        mov ax, word ptr es:[si]; guarda jugador en ax
        mov word ptr es:[si], bx; restaura celda vieja
        mov bx, word ptr es:[di]
        mov celdaVieja, bx; guarda contenidos de la celda a moverse
        mov word ptr es:[di], ax; mueve jugador a la nueva posición
        cmp word ptr es:[di-2], cuerda; para ver si viene de una cuerda
        conejo je finMueveJugador
        cmp word ptr es:[di+2], cuerda; para ver si va a una cuerda
        conejo je finMueveJugador
        cmp word ptr es:[di+160], espacio; abajo es espacio?
        conejo jne finMueveJugador
        add di, 160
        jmp seVaACaer

    movDer:
        inc di
        inc di
        cmp word ptr es:[di], enemigo
        conejo je muere
        cmp word ptr es:[di], 0001000100101010b; delimitador de área de juego
        conejo je noIzq
        mov bx, celdaVieja
        mov ax, word ptr es:[si]; guarda jugador en ax
        mov word ptr es:[si], bx; restaura celda vieja
        mov bx, word ptr es:[di]
        mov celdaVieja, bx; guarda contenidos de la celda a moverse
        mov word ptr es:[di], ax; mueve jugador a la nueva posición
        cmp word ptr es:[di-2], cuerda; para ver si viene de una cuerda
        conejo je finMueveJugador
        cmp word ptr es:[di+2], cuerda; para ver si va a una cuerda
        conejo je finMueveJugador
        cmp word ptr es:[di+160], espacio
        conejo jne finMueveJugador
        add di, 160
        jmp seVaACaer

    movDown:
        add di, 160; celda de abajo
        cmp word ptr es:[di], enemigo
        conejo je muere
        cmp word ptr es:[di], escalera
        jne noDown
        mov bx, celdaVieja
        mov ax, word ptr es:[si]; guarda jugador en ax
        mov word ptr es:[si], bx; restaura celda vieja
        mov bx, word ptr es:[di]
        mov celdaVieja, bx; guarda contenidos de la celda a moverse
        mov word ptr es:[di], ax; mueve jugador a la nueva posición
        jmp finMueveJugador


    noUp:
        mov direccionActual, 0; no se puede mover hasta que se digite tecla válida
        mov di, si; revierte cambios al di
        jmp finMueveJugador
    noIzq:
        mov direccionActual, 0; no se puede mover hasta que se digite tecla válida
        mov di, si; revierte cambios al di
        jmp finMueveJugador
    noDer:
        mov direccionActual, 0; no se puede mover hasta que se digite tecla válida
        mov di, si; revierte cambios al di
        jmp finMueveJugador
    noDown:
        mov direccionActual, 0; no se puede mover hasta que se digite tecla válida
        mov di, si; revierte cambios al di
        jmp finMueveJugador
    seVaACaer:
        mov direccionActual, 0
        sub di, 160
        jmp finMueveJugador
    seCae:
        cmp word ptr es:[di], enemigo
        conejo je muere
        mov bx, celdaVieja
        mov ax, word ptr es:[si]; guarda jugador en ax
        mov word ptr es:[si], bx; restaura celda vieja
        mov bx, word ptr es:[di]
        mov celdaVieja, bx; guarda contenidos de la celda a moverse
        mov word ptr es:[di], ax; mueve jugador a la nueva posición
        add di, 160
        cmp word ptr es:[di], espacio
        je seVaACaer
        sub di, 160
        jmp finMueveJugador
    muere:
        mov ax, word ptr es:[si]; mueve jugador al ax
        mov bx, celdaVieja
        mov word ptr es:[si], bx; restaura lo que había
        mov si, posicionInicial
        mov posicionJugador, si
        mov word ptr es:[si], ax; regresa jugador a posición inicial
        dec vidasJugador
        call pintaVidas
        mov direccionActual, 0
        mov celdaVieja, espacio

    jmp finMueveJugador


    finMueveJugador:
    mov posicionJugador, di; guarda posición adónde se movió el jugador
    pop si
    pop ax
    ret
mueveJugador endP

nuevaLinea proc
    ; rutina que se encarga de insertar un "enter" en el buffer de editor cuando es necesario
    push ax

    mov ax, contadorLinea
    cmp ax, 26; si ya hay 26 caracteres, se terminó la línea y hay que insertar un cambio de línea para el archivo
    jne finNuevaLinea
    mov byte ptr [buffyNivelNuevo+si], 0Ah; mete cambio de línea
    inc si; apunta a siguiente char del buffer
    mov contadorLinea, 0; reinicia el comtador

    finNuevaLinea:
    pop ax
    ret
nuevaLinea endP

escribeTeclaEditor proc far
    ; rutina que escribe tecla digitada (al) en el buffer para guardar el archivo

    mov byte ptr [buffyNivelNuevo+si], al; la tecla está en el al
    inc si; apunta a la siguiente posición del buffer
    inc contadorLinea
    call nuevaLinea

    ret
escribeTeclaEditor endP

escribeNivelNuevo proc far
    ; rutina que toma el buffer y lo guarda en un nuevo archivo en formato para juego
    push ax
    push cx
    push dx

    intentaAbrir:
        mov ah, 3Dh; para abrir con int 21h
        mov al, 0; para modo de lectura
        lea dx, archivoNivelNuevo
        int 21h; intenta abrir archivo
        jc creaNivelNuevo
        call siguienteNivelOriginal
        jmp intentaAbrir

    creaNivelNuevo:
        cmp ax, 2
        conejo jne,final
        mov ax, 3C00h; para crear archivo en modo esctiruta
        xor cx, cx
        inc cx; modo escritura
        lea dx, archivoNivelNuevo
        int 21h

    abreFileNuevo:
        mov ax, 3D01h; escritura en archivo
        lea dx, archivoNivelNuevo
        int 21h
        conejo jc,final
        mov handleNivelNuevo, ax

    escribeArchivoNivelNuevo:
        mov ax, 4000h
        mov bx, handleNivelNuevo
        mov cx, 431; tamaño del buffer
        lea dx, buffyNivelNuevo
        int 21h
        conejo jc,final
        cerrar_archivo handleNivelNuevo

    pop dx
    pop cx
    pop ax
    ret
escribeNivelNuevo endP

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
            mov si, 1938
            call print

            lea bx, acercaDe8
            mov si, 2258
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

            lea bx, acercaDe12
            mov si, 3058
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
                mov si, 3380
                mov ah, 00010111b
                lea bx, ds_vidas
                call print
                call pintaVidas


            pinta_highscore:
                xor si, si
                lineaH azul,22,22,1,48; imprime dos filas horizontales de 22 caracteres separadas por 16 filas a partir de 5ta fila, columna 49
                xor si, si
                lineaV azul,22,21,2,48; imprime 16 filas separadas por 23 columnas a partir de 6ta fila, columna 49

                lea bx, ds_highscore
                mov si, 134
                shl si, 1; para posición del título
                mov ah, 00010111b; fondo azul, char blanco
                call print

                lea bx, ds_highscore2
                mov si, 212
                shl si, 1
                mov ah, 00000111b; fondo negro, char blanco
                call print; imprime rotulos
                call pintaHS; imprime high score



            comienza_juego:
                call mueveJugador
                call pausaJugador
                mov ah, 01
                int 16h
                jz comienza_juego; no hay tecla ingresada

                hayTecla:
                    xor ah, ah
                    int 16h
                    cmp al, 27; para ver si es esc
                    jne esASCII
                    mov ah, 06h
                    mov al, 23
                    int 10h; limpia la pantalla
                    mov ah, 09h
                    lea dx, ds_GameOver
                    int 21h; imprime mensaje final
                    jmp final

                esASCII:
                    cmp al, 0; para ver si es una tecla de función extendida
                    jz esDir

                    cmp al, 'z'
                    je esZ
                    cmp al, 'x'
                    je esX
                    cmp al, 'p'
                    je esPe
                    cmp al, 's'; para cambiar de nivel
                    jne comienza_juego
                    inc contadorNivel
                    call siguienteNivel
                    call pintaNivel
                    jmp comienza_juego

                    esZ:
                    jmp comienza_juego
                    esX:
                    jmp comienza_juego
                    esPe:
                    jmp comienza_juego

                esDir:
                    cmp ah, 72; flecha de arriba
                    jne cmpIzq
                    mov direccionActual, 1
                    jmp etCambiaDir
                    cmpIzq:
                    cmp ah, 75; flecha izquierda
                    jne cmpDer
                    mov direccionActual, 2
                    jmp etCambiaDir
                    cmpDer:
                    cmp ah, 77; flecha derecha
                    jne cmpUp
                    mov direccionActual, 3
                    jmp etCambiaDir
                    cmpUp:
                    cmp ah, 80; flecha de abajo
                    conejo jne comienza_juego
                    mov direccionActual, 4
                    etCambiaDir:
                    jmp comienza_juego

        modo_editor:
            mov ah, 0Fh
            int 10h; deja en ax el modo de video original
            mov modoVideo, ax; conserva modo de video original

            xor ah, ah; modo 00 de la 10h
            mov al, 12h; 640 x 480 a 16 colores
            int 10h; establece modo de video


            mov ax, 0A000h; comienzo de memoria gráfica para modo video
            mov es, ax

            ; Pinta cuadro editor
            ; Cursor parpadeando

                xor si, si
                comienza_editor:
                    mov ah, 01
                    int 16h; para ver si hay una tecla registrada en el buffer de teclado
                    jz comienza_editor; no hay tecla ingresada

                    hayTeclaEditor:
                        xor ah, ah
                        int 16h
                        cmp al, 27; para ver si es esc
                        jne editorGuardarNivel
                        finEditor:
                        mov ax, modoVideo; saca modo de video original
                        xor ah, ah
                        int 10h; restaura modo de video original
                        jmp final

                    editorGuardarNivel:
                        cmp al, 0Dh; para ver si es un enter
                        jne editorEsASCII
                        call escribeNivelNuevo
                        jmp finEditor

                    editorEsASCII:
                        cmp al, 0; para ver si es una tecla de función extendida
                        jz editorEsDir

                        cmp al, ' '
                        je editorEsSpc
                        cmp al, 'l'
                        je editorEsL
                        cmp al, 'c'
                        je editorEsC
                        cmp al, 'e'
                        je editorEsE
                        cmp al, 'f'
                        je editorEsF
                        cmp al, 's'
                        je editorEsS
                        cmp al, 'o'
                        je editorEsO
                        cmp al, 'g'
                        je editorEsG
                        cmp al, 'x'
                        je editorEsX
                        cmp al, '*'
                        jne editorEsSpc
                        ; despliega personaje
                        jmp editorSiguienteTecla


                        editorEsSpc:
                        jmp editorSiguienteTecla
                        editorEsL:
                        jmp editorSiguienteTecla
                        editorEsC:
                        jmp editorSiguienteTecla
                        editorEsE:
                        jmp editorSiguienteTecla
                        editorEsF:
                        jmp editorSiguienteTecla
                        editorEsS:
                        jmp editorSiguienteTecla
                        editorEsO:
                        jmp editorSiguienteTecla
                        editorEsG:
                        jmp editorSiguienteTecla
                        editorEsX:
                        jmp editorSiguienteTecla


                        editorSiguienteTecla:
                        ; desplegar caracter correspondiente
                        call escribeTeclaEditor; rutina que guarda la tecla indicada en el buffer para el nivel nuevo
                        ; inc contador pantalla
                        jmp comienza_editor


                    editorEsDir:
                        push si
                        cmp ah, 72; flecha de arriba
                        jne cmpIzqEd
                        sub si, 17
                        jmp edCambiaDir
                        cmpIzqEd:
                        cmp ah, 75; flecha izquierda
                        jne cmpDerEd
                        dec si
                        jmp edCambiaDir
                        cmpDerEd:
                        cmp ah, 77; flecha derecha
                        jne cmpDownEd
                        inc si
                        jmp edCambiaDir
                        cmpDownEd:
                        cmp ah, 80; flecha de abajo
                        conejo jne comienza_editor
                        add si, 17

                        edCambiaDir:
                        cmp si, 0
                        jl noMueve
                        cmp si, 432
                        jge noMueve



                        noMueve:
                        pop si
                        jmp comienza_editor

final:
        mov ax, 4C00h ; para finalizacion en 21h
        int 21h ; termina programa

codigo ends

end inicio ; para que apunte a inicio cuando vaya a correr el programa
