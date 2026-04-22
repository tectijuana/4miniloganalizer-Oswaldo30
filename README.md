[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/EbtZGzoI)
[![Open in Codespaces](https://classroom.github.com/assets/launch-codespace-2972f46106e565e64193e422d61a12cf1da4916b45550586e14ef0a7c637dd04.svg)](https://classroom.github.com/open-in-codespaces?assignment_repo_id=23682712)

# Práctica 1

## Alumno: Gutierrez Morales Oswaldo

## Implementación de un Mini Cloud Log Analyzer en ARM64

**Modalidad:** Individual
**Entorno de trabajo:** AWS Ubuntu ARM64 + GitHub Classroom
**Lenguaje:** ARM64 Assembly (GNU Assembler) + Bash + GNU Make

---

## Introducción

En esta fase del proyecto "Mini Cloud Log Analyzer", partimos de un programa base en Ensamblador ARM64 diseñado para procesar registros de un servidor web. 
La funcionalidad original permitía leer un flujo de texto con códigos de estado HTTP y agruparlos en categorías generales (Éxitos 2xx, Errores de cliente 4xx y Errores de servidor 5xx).

El objetivo principal de la Variante B fue dotar al programa de una capacidad de análisis estadístico más precisa: identificar cuál fue el código exacto que más se repitió en el registro.

El programa procesará códigos de estado HTTP suministrados mediante entrada estándar (stdin):

```bash id="y1gcmc"
cat logs.txt | ./analyzer
```

---

## Objetivo general

Desarrollar una herramienta de análisis de registros de servidor web (Mini Cloud Log Analyzer) en lenguaje Ensamblador ARM64, empleando exclusivamente llamadas al sistema (syscalls) de Linux, con el fin de procesar flujos de texto, clasificar códigos de estado HTTP por categorías e identificar estadísticamente el código más recurrente.

---

## Objetivos específicos

El estudiante aplicará:

* programación en ARM64 bajo Linux
* manejo de registros
* direccionamiento y acceso a memoria
* instrucciones de comparación
* estructuras iterativas en ensamblador
* saltos condicionales
* uso de syscalls Linux
* compilación con GNU Make
* control de versiones con GitHub Classroom

Estos temas se alinean con contenidos clásicos de flujo de control, herramientas GNU, manejo de datos y convenciones de programación en ensamblador.   

---

## Material proporcionado

Se entregará un repositorio preconfigurado que contiene:

* plantilla base en ARM64
* archivo `Makefile`
* script Bash de ejecución
* archivo de datos (`logs.txt`)
* pruebas iniciales
* secciones marcadas con `TODO`

El estudiante deberá completar la lógica correspondiente.

---

## Variante de mi práctica

### Variante B

Determinar el código de estado más frecuente.

## Compilación

```bash id="bmubtb"
make
```

---

## Ejecución

```bash id="gcqlf2"
cat logs.txt | ./analyzer
```

---

## Entregables

Cada estudiante deberá entregar en su repositorio:

* archivo fuente ARM64 funcional
* solución implementada
* README explicando diseño y lógica utilizada
* evidencia de ejecución
* commits realizados en GitHub Classroom

---

## Criterios de evaluación

| Criterio                    | Ponderación |
| --------------------------- | ----------- |
| Compilación correcta        | 20%         |
| Correctitud de la solución  | 35%         |
| Uso adecuado de ARM64       | 25%         |
| Documentación y comentarios | 10%         |
| Evidencia de pruebas        | 10%         |

---

## Restricciones

No está permitido:

* resolver la lógica en C
* resolver la lógica en Python
* modificar la variante asignada
* omitir el uso de ARM64 Assembly

---

## Competencia a desarrollar

Comprender cómo un problema de procesamiento de datos es implementado a nivel máquina mediante instrucciones ARM64.

---

## EVIDENCIA DE COMPILACIÓN Y EJECUCIÓN 

<img width="987" height="294" alt="imagen" src="https://github.com/user-attachments/assets/2136c005-cdf8-4594-af95-fc9424f6eaf1" />

La imagen muestra la ejecución exitosa del programa "Mini Cloud Log Analyzer" en una terminal de AWS. Tras verificar que el código fuente ya está correctamente compilado, se ejecuta el programa pasándole como entrada el archivo de pruebas data/logs_B.txt. Como resultado, el analizador procesa todos los datos e imprime un reporte que contabiliza 91 códigos de éxito (2xx), 132 errores de cliente (4xx) y 103 errores de servidor (5xx), logrando además identificar de manera precisa que el código 404 fue el más frecuente de todo el archivo.

## Nota

Aunque este problema puede resolverse fácilmente en lenguajes de alto nivel, el propósito de la práctica es implementar **cómo lo resolvería la arquitectura**, no únicamente obtener el resultado.

