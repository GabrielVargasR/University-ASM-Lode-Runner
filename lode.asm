; Autor: Gabriel Vargas Rodríguez - 2018103129
; Arquitectura de Computadores - Grupo 2




; -------- Manual de usuario ----------


; -------- Análisis de resultados ---------



datos segment

   db dup (?)

datos ends


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

        ;carnita


final:
        mov ax, 4C00h ; para finalizacion en 21h
        int 21h ; termina programa

codigo ends

end inicio ; para que apunte a inicio cuando vaya a correr el programa
