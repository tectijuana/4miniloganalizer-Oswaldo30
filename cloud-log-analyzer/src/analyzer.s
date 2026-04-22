/*
===============================================================================
MINI CLOUD LOG ANALYZER (Variante B)
===============================================================================
ALUMNO: Gutierrez Morales Oswaldo
FECHA: 22 de Abril del 2026
Propósito:
Lee una lista de códigos de estado HTTP (ej. 200, 404, 500).
1. Cuenta cuántos son Éxitos (2xx), Errores de cliente (4xx) y de servidor (5xx).
2. Descubre cuál fue el código exacto que más se repitió.
===============================================================================
*/

.equ SYS_read,   63
.equ SYS_write,  64
.equ SYS_exit,   93
.equ STDIN_FD,    0
.equ STDOUT_FD,   1

/*-------------------------------------------------------------------------------
ESTRUCTURA DE LA MEMORIA (Variables)
Aquí reservamos el espacio necesario para que el programa trabaje.
-------------------------------------------------------------------------------
*/
.section .bss
    .align 4
buffer:         .skip 4096    // Buffer de lectura: Guarda el texto que ingresa el usuario.
num_buf:        .skip 32      // Buffer de números: Espacio para convertir números a texto.
frecuencias:    .skip 4000    // Arreglo de Frecuencias: 1000 "cajones" para contar cada código del 0 al 999.

.section .data
msg_titulo:         .asciz "=== Mini Cloud Log Analyzer ===\n"
msg_2xx:            .asciz "Éxitos 2xx: "
msg_4xx:            .asciz "Errores 4xx: "
msg_5xx:            .asciz "Errores 5xx: "
msg_frecuente:      .asciz "Código más frecuente: "
msg_fin_linea:      .asciz "\n"

.section .text
.global _start

_start:
    /* 1. INICIALIZACIÓN: Ponemos todos los contadores en cero */
    mov x19, #0                  // Contador global: exitos_2xx
    mov x20, #0                  // Contador global: errores_4xx
    mov x21, #0                  // Contador global: errores_5xx

    mov x22, #0                  // Aquí guardaremos el número que estamos armando
    mov x23, #0                  // Nos avisa si ya leímos algún dígito (0 = no, 1 = sí)

leer_bloque:
    /* 2. LECTURA DE DATOS: Tomamos un bloque de texto de la consola */
    mov x0, #STDIN_FD
    adrp x1, buffer
    add x1, x1, :lo12:buffer
    mov x2, #4096
    mov x8, #SYS_read
    svc #0

    cmp x0, #0
    beq fin_lectura               // Si ya no hay texto, vamos a mostrar los resultados
    blt salida_error              // Si hubo un error leyendo, salimos

    mov x24, #0                   // Empezamos a revisar desde la primera letra
    mov x25, x0                   // Guardamos cuántas letras leímos en total

procesar_byte:
    /* 3. PROCESAMIENTO: Analizamos el texto letra por letra */
    cmp x24, x25
    b.ge leer_bloque              // Si ya revisamos todo el bloque, pedimos más texto

    adrp x1, buffer
    add x1, x1, :lo12:buffer
    ldrb w26, [x1, x24]           // Tomamos una letra
    add x24, x24, #1

    // Si es un salto de línea (Enter), terminamos de armar el código y lo clasificamos
    cmp w26, #10
    b.eq fin_numero

    // Si la letra es un dígito del '0' al '9', lo unimos para armar el número (ej. 4 -> 40 -> 404)
    cmp w26, #'0'
    b.lt procesar_byte
    cmp w26, #'9'
    b.gt procesar_byte

    mov x27, #10
    mul x22, x22, x27
    sub w26, w26, #'0'
    uxtw x26, w26
    add x22, x22, x26
    mov x23, #1                   // Avisamos que ya tenemos un número en progreso
    b procesar_byte

fin_numero:
    // Enviamos el número terminado a clasificar
    cbz x23, reiniciar_numero
    mov x0, x22
    bl clasificar_codigo

reiniciar_numero:
    // Limpiamos la variable para empezar a armar el siguiente código
    mov x22, #0
    mov x23, #0
    b procesar_byte

fin_lectura:
    // Si se acabó el texto pero quedó un número a medias, lo clasificamos
    cbz x23, imprimir_reporte
    mov x0, x22
    bl clasificar_codigo

imprimir_reporte:
    /* 6. IMPRESIÓN DEL REPORTE: Mostramos los contadores generales en pantalla */
    adrp x0, msg_titulo
    add x0, x0, :lo12:msg_titulo
    bl write_cstr

    adrp x0, msg_2xx
    add x0, x0, :lo12:msg_2xx
    bl write_cstr
    mov x0, x19
    bl print_uint
    adrp x0, msg_fin_linea
    add x0, x0, :lo12:msg_fin_linea
    bl write_cstr

    adrp x0, msg_4xx
    add x0, x0, :lo12:msg_4xx
    bl write_cstr
    mov x0, x20
    bl print_uint
    adrp x0, msg_fin_linea
    add x0, x0, :lo12:msg_fin_linea
    bl write_cstr

    adrp x0, msg_5xx
    add x0, x0, :lo12:msg_5xx
    bl write_cstr
    mov x0, x21
    bl print_uint
    adrp x0, msg_fin_linea
    add x0, x0, :lo12:msg_fin_linea
    bl write_cstr

    /* 5. BÚSQUEDA DEL CÓDIGO MÁS FRECUENTE: Revisamos los 1000 cajones */
    mov x4, #0          // Empezamos en el cajón 0
    mov w5, #0          // Aquí guardaremos el récord (la cantidad más alta encontrada)
    mov w6, #0          // Aquí guardaremos el código ganador

    adrp x7, frecuencias
    add x7, x7, :lo12:frecuencias

buscar_max_loop:
    cmp x4, #1000
    b.eq imprimir_mas_frecuente   // Si ya revisamos los 1000 cajones, imprimimos al ganador

    // Vemos cuántas veces apareció el código actual
    ldr w8, [x7, x4, lsl #2]
    
    // Si no supera el récord, pasamos al siguiente cajón
    cmp w8, w5
    b.ls buscar_max_next

    // Si supera el récord, actualizamos al nuevo ganador
    mov w5, w8          // Nuevo récord de cantidad
    mov w6, w4          // Nuevo código ganador

buscar_max_next:
    add x4, x4, #1      // Pasamos al siguiente cajón
    b buscar_max_loop

imprimir_mas_frecuente:
    // Imprimimos al código ganador en la pantalla
    adrp x0, msg_frecuente
    add x0, x0, :lo12:msg_frecuente
    bl write_cstr

    uxtw x0, w6
    bl print_uint
    
    adrp x0, msg_fin_linea
    add x0, x0, :lo12:msg_fin_linea
    bl write_cstr

salida_ok:
    /* 7. FIN DEL PROGRAMA: Avisamos al sistema que terminamos con éxito */
    mov x0, #0
    mov x8, #SYS_exit
    svc #0

salida_error:
    mov x0, #1
    mov x8, #SYS_exit
    svc #0

/*
-------------------------------------------------------------------------------
SUBRUTINA: clasificar_codigo
4. CLASIFICACIÓN: Anota el código en su cajón y en su grupo general (2xx, 4xx, 5xx)
-------------------------------------------------------------------------------
*/
clasificar_codigo:
    // Paso A: Guardar en el arreglo de frecuencias (Variante B)
    cmp x0, #999
    b.hi continue_clasificacion  // Ignoramos si el número es mayor a 999 por seguridad

    adrp x4, frecuencias
    add x4, x4, :lo12:frecuencias
    ldr w5, [x4, x0, lsl #2]     // Buscamos el cajón del código
    add w5, w5, #1               // Le sumamos 1 a su contador
    str w5, [x4, x0, lsl #2]     // Guardamos el nuevo valor

continue_clasificacion:
    // Paso B: Clasificar en los contadores generales
    cmp x0, #200
    b.lt clasificar_fin
    cmp x0, #299
    b.gt revisar_4xx
    add x19, x19, #1             // Cayó en el rango 2xx
    b clasificar_fin

revisar_4xx:
    cmp x0, #400
    b.lt clasificar_fin
    cmp x0, #499
    b.gt revisar_5xx
    add x20, x20, #1             // Cayó en el rango 4xx
    b clasificar_fin

revisar_5xx:
    cmp x0, #500
    b.lt clasificar_fin
    cmp x0, #599
    b.gt clasificar_fin
    add x21, x21, #1             // Cayó en el rango 5xx

clasificar_fin:
    ret

/*
-------------------------------------------------------------------------------
FUNCIONES AUXILIARES (Para comunicarse con la pantalla)
-------------------------------------------------------------------------------
*/

// write_cstr: Toma una frase de texto y la dibuja en la pantalla.
write_cstr:
    mov x9, x0
    mov x10, #0

wc_len_loop:
    ldrb w11, [x9, x10]
    cbz w11, wc_len_done
    add x10, x10, #1
    b wc_len_loop

wc_len_done:
    mov x1, x9
    mov x2, x10
    mov x0, #STDOUT_FD
    mov x8, #SYS_write
    svc #0
    ret

// print_uint: Traduce un número puro de computadora a letras para poder leerlo.
print_uint:
    cbnz x0, pu_convertir
    adrp x1, num_buf
    add x1, x1, :lo12:num_buf
    mov w2, #'0'
    strb w2, [x1]
    mov x0, #STDOUT_FD
    mov x2, #1
    mov x8, #SYS_write
    svc #0
    ret

pu_convertir:
    adrp x12, num_buf
    add x12, x12, :lo12:num_buf
    add x12, x12, #31
    mov w13, #0
    strb w13, [x12]

    mov x14, #10
    mov x15, #0

pu_loop:
    udiv x16, x0, x14
    msub x17, x16, x14, x0
    add x17, x17, #'0'

    sub x12, x12, #1
    strb w17, [x12]
    add x15, x15, #1

    mov x0, x16
    cbnz x0, pu_loop

    mov x1, x12
    mov x2, x15
    mov x0, #STDOUT_FD
    mov x8, #SYS_write
    svc #0
    ret
