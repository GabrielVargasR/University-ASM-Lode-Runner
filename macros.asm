conejo Macro salto,etiqueta
    local et1
    local et2

    salto et1
    jmp et2
    et1: jmp etiqueta
    et2:
endM

abrir_archivo Macro nombre,modo,handle,final
    local error_abrir
    local fin_abrir
    mov ah, 3Dh; para abrir con int 21h
    mov al, modo; para modo de apertura
    lea dx, nombre
    int 21h
    jc error_abrir
    mov handle, ax; para guardar el handle
    jmp fin_abrir
    error_abrir:
    println dsmal_archivo
    jmp final
    fin_abrir:
endM


getTamanoArchivo Macro handle,vart
    xor cx, cx
    xor dx, dx; para hacer desplazamiento de 0
    mov ah, 42h
    mov al, 02
    mov bx, handle1
    int 21h
    mov tamarchivo1, ax; operación retorna tamaño en DX:AX

    mov ax, 4200h
    xor dx, dx
    int 21h ; regresa el file pointer al principio
endM


leer_archivo Macro han,tam,dir
    mov ax, 3F00h
    mov bx, han
    mov cx, tam
    lea dx, dir
    int 21h
endM


dump Macro handle,tam,buff
    ; Escribe todo un registro a un archivo
    mov ax, 4200h
    mov cx, tam
    mov bx, handle
    lea dx, buff
    int 21h
endM


cerrar_archivo Macro handle
    mov ax, 3E00h
    mov bx, handle
    int 21h
endM


println Macro var
    lea dx, var
    mov ah, 09h
    int 21h
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
