conejo Macro salto,etiqueta
    local et1
    local et2

    salto et1
    jmp et2
    et1: jmp etiqueta
    et2:
endM

lineaH Macro color,N1,N2,F,C
    local linea1
    local linea2

        mov si, F*160; para comenzar en la fila indicada
        add si, C*2; para comenzar en la columna indicada

         mov cx, N1; cantidad de asteriscos a desplegar
         mov ah, color
         linea1:
            mov word ptr es:[si], ax
            inc si
            inc si
         loop linea1

         mov bx, 80
         add bx, C
         sub bx, N1+C
         shl bx, 1; calcula comienzo de siguiente posición (fila y columna)
         add si, bx; salta a siguiente fila
         add si, 160*N2; para saltar a fila indicada
         mov cx, N1; cantidad de asteriscos a desplegar

         linea2:
            mov word ptr es:[si], ax
            inc si
            inc si
         loop linea2
endM

lineaV Macro color,N1,N2,F,C
    local linea

    mov si, F*160; para comenzar en la fila indicada
    add si, C*2; para comenzar en la columna indicada

    mov ah, color; completa el word a desplegar
    mov cx, N1; cantidad de filas a pintar
    linea:
        mov word ptr es:[si], ax; pinta primer símbolo
        add si, N2*2; caracteres en medio x2 para saltar byte de características
        mov word ptr es:[si], ax; pinta segundo símbolo
        mov bx, 80
        add bx, C
        sub bx, N2+C
        shl bx, 1; calcula comienzo de siguiente posición (fila y columna)
        add si, bx; brinca a la siguiente fila
    loop linea
endM

cerrar_archivo Macro handle
    mov ax, 3E00h
    mov bx, handle
    int 21h
endM

numToText Macro varNum, varText
    local sigueDiv
    local noConv
    cmp varNum, 0
    je noConv

    lea bx, varText
    mov ax, varNum
    xor dx, dx
    mov cx, 10000
    xor si, si

    div cx
    cmp ax, 0

    ;jne
    add ax, 30h
    mov [bx+si], ax



    noConv:
endM
