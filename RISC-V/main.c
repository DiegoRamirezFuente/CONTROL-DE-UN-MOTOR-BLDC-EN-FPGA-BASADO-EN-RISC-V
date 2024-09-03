#include <neorv32.h>

#define BAUD_RATE 9600  // Define el baud rate deseado

// Función para convertir una cadena binaria en un uint64_t
uint64_t binario_a_uint64(const char *binario) {
    uint64_t resultado = 0;
    while (*binario != '\0') {
        resultado <<= 1; // Desplazar el resultado un bit a la izquierda
        if (*binario == '1') {
            resultado |= 1; // Establecer el bit menos significativo si es '1'
        }
        binario++;
    }
    return resultado;
}

void uint16_a_binario(uint16_t valor, char *binario) {
    for (int i = 15; i >= 0; i--) {
        binario[15 - i] = (valor & (1 << i)) ? '1' : '0';
    }
    binario[16] = '\0'; // Terminar la cadena
}

void enviar_gpio_por_uart() {
    uint16_t gpio_valor = 0;
    for (int i = 0; i < 16; i++) {
        if (neorv32_gpio_pin_get(i)) {
            gpio_valor |= (1 << i);
        }
    }
    char buffer[19]; // 16 caracteres para los datos binarios + 's', 'e' y el terminador null

    buffer[0] = 's'; // Iniciar el buffer con 's'

    uint16_a_binario(gpio_valor, buffer + 1); // Convertir el valor en una cadena binaria y copiar al buffer

    buffer[17] = 'e'; // Terminar el buffer con 'e'
    buffer[18] = '\0'; // Terminador null

    // Enviar la cadena a través de UART
    neorv32_uart0_puts(buffer);
}

void leer_datos() {
    char buffer[41]; // 40 caracteres para los datos más el terminador null
    int len = 0;
    char c;

    // Leer caracteres hasta encontrar el identificador de inicio 's'
    do {
        c = neorv32_uart0_getc();
    } while (c != 's');

    // Leer los caracteres después de 's' hasta encontrar 'e' o alcanzar el límite del buffer
    while (len < 40) {
        c = neorv32_uart0_getc();
        if (c == 'e') {
            break; // Salir del bucle al encontrar 'e'
        }
        buffer[len++] = c;
    }

    buffer[len] = '\0'; // Terminar la cadena

    // Convertir la cadena binaria en un número entero (uint64_t)
    uint64_t gpio_data = binario_a_uint64(buffer);

    // Configurar los GPIOs con gpio_data
    neorv32_gpio_port_set(gpio_data & 0xFFFFFFFFFF);
}

int main() {
    // Configuración inicial del UART
    neorv32_uart0_setup(BAUD_RATE, 0);

    // Configuración inicial del GPIO
    neorv32_gpio_port_set(0);

    // Bucle infinito para simular el funcionamiento continuo
    while (1) {
        // Leer y enviar los datos del UART solo si hay caracteres disponibles para leer
        if (neorv32_uart0_char_received()) {
            leer_datos();
        }
        else {
            enviar_gpio_por_uart();
            // Opcional: esperar un breve período para no saturar la UART con datos
            neorv32_cpu_delay_ms(10); // Esperar 10 ms
        }        
    }

    return 0;
}