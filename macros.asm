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
