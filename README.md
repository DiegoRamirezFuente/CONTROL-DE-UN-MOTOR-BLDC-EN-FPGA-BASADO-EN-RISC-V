# TFG: Control de Motor BLDC con RISC-V y FPGA

Este repositorio contiene el código y los archivos necesarios para el Trabajo de Fin de Grado (TFG) centrado en la implementación del procesador **RISC-V** en una **FPGA Nexys 4 DDR** para el control de un motor de corriente continua sin escobillas (**BLDC**). Se desarrolla un controlador **PID** en VHDL para la regulación de la velocidad del motor, mientras que el procesador RISC-V se encarga de la comunicación entre la FPGA y una **Interfaz Gráfica de Usuario (GUI)**.

## Motivación del Proyecto

La motivación principal de este proyecto es utilizar el procesador **RISC-V**, un estándar abierto, en el entorno de **Vivado** para gestionar la comunicación entre la **FPGA** y una **GUI**. El objetivo es implementar un sistema de control para un motor **BLDC** que utilice un controlador PID descrito en **VHDL** para garantizar un control preciso de la velocidad del motor. La FPGA se conectará a la GUI mediante **comunicación serial** gestionada por RISC-V, y el control del motor actuará como una demostración del sistema desarrollado.

## Estructura del Repositorio

Este repositorio está organizado en tres carpetas principales:

- **`IP/`**: Contiene el código VHDL necesario para implementar el controlador PID en la FPGA. Este controlador regula la velocidad del motor **BLDC** y se encargará de gestionar el control en tiempo real a través de la FPGA.

- **`GUI/`**: Aquí se encuentra el código de la **Interfaz Gráfica de Usuario (GUI)** desarrollada en **C#** utilizando **Visual Studio**. La GUI permite interactuar con el sistema, enviando comandos y recibiendo información sobre la velocidad del motor BLDC a través de la comunicación serial. También se puede encontrar en la carpeta **MatLab** el proyecto de **Simulink** para la graficación de la velocidad.

- **`RISC-V/`**: Esta carpeta contiene el código en **C** para el procesador **RISC-V**. La información detallada sobre la compilación de este código y su implementación en Vivado se encuentra en el siguiente repositorio: [NeoRV32 GitHub Repository](https://github.com/stnolting/neorv32). Este repositorio proporciona toda la documentación necesaria para compilar el código y cargarlo en la FPGA.

## Requisitos del Sistema

- **Vivado**: Software de síntesis y programación para la FPGA.
- **Nexys 4 DDR FPGA**: Plataforma hardware en la que se desarrollará el proyecto.
- **RISC-V Toolchain**: Necesaria para compilar el código en C para RISC-V (ver documentación en [NeoRV32](https://github.com/stnolting/neorv32)).
- **Visual Studio**: Utilizado para desarrollar la GUI en C#.
- **Conexión UART**: Para la comunicación serial entre la FPGA y la GUI.

## Instrucciones de Uso

### 1. Configuración de RISC-V en la FPGA

1. Navegue a la carpeta `RISC-V/`, donde encontrará el código fuente en C para el procesador RISC-V.
2. La información completa sobre cómo compilar y cargar el procesador RISC-V en la FPGA está disponible en el repositorio [NeoRV32](https://github.com/stnolting/neorv32). Siga las instrucciones allí para configurar el procesador en Vivado y compilar el código con la **RISC-V Toolchain**.

### 2. Implementación del Controlador PID en VHDL

1. Dentro de la carpeta `IP/`, encontrará el código VHDL para el controlador PID.
2. Asegurese de modificar el archivo de constraints según las necesidades de su motor y su driver.
3. Abra Vivado y siga los pasos para sintetizar y cargar el diseño en la FPGA.
4. El controlador PID regulará la velocidad del motor BLDC, asegurando un control eficiente.

### 3. Conexión con la GUI (Interfaz Gráfica de Usuario)

1. Diríjase a la carpeta `GUI/`, donde está el proyecto de **Visual Studio** para la GUI desarrollada en **C#** y el proyecto de **Simulink** para la graficación de los datos.
2. Abra el proyecto en Visual Studio, compílelo y ejecute la aplicación.
3. Asegúrese de conectar la GUI a la FPGA mediante la **comunicación serial (UART)**. Desde la GUI, podrá controlar la velocidad del motor BLDC y configurar el puerto serie "Read", para el intercambio de datos con la FPGA.
4. Para la conexión con **MatLab** para la graficación de la velocidad debe crear un puerto serie virtual mediante algún software como "VSPE", configurar el puerto "Write" y el puerto de comunicación de **Simulink**.

### 4. Verificación del Sistema

- Una vez cargado el código RISC-V en la FPGA y el controlador PID esté en funcionamiento, podrá usar la GUI para enviar comandos de velocidad al motor.
- La velocidad del motor BLDC será controlada y regulada por el sistema, y los datos se intercambiarán entre la GUI y la FPGA a través de RISC-V.