using System;
using System.IO.Ports;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;

namespace MotorDialog
{
    public partial class MainWindow : Window
    {
        int valVelConsig;
        int Kp, Ki, Kd;
        SerialPort serialPort, serialPortMatLab;
        private bool isReading = false;
        private bool isWriting = false;

        private SemaphoreSlim semaphore = new SemaphoreSlim(1, 1);


        public MainWindow()
        {
            InitializeComponent();
        }

        private void EnviarDatos()
        {
            // Convertir los valores a formato binario de longitud específica
            string binarioVelConsig = Convert.ToString(valVelConsig, 2).PadLeft(16, '0');
            string binarioKp = Convert.ToString(Kp, 2).PadLeft(8, '0');
            string binarioKi = Convert.ToString(Ki, 2).PadLeft(8, '0');
            string binarioKd = Convert.ToString(Kd, 2).PadLeft(8, '0');

            // Construir la cadena en formato binario
            string datos = $"s{binarioVelConsig}{binarioKp}{binarioKi}{binarioKd}e";

            Console.WriteLine("Escribiendo en el puerto serie...");
            serialPort.Write(datos);
            Console.WriteLine("Datos enviados.");
        }

        private void EnviarMedidaMatLab(short medida)
        {
            if (serialPortMatLab != null && serialPortMatLab.IsOpen)
            {
                // Convertir la medida a un array de 2 bytes (16 bits) en Little-Endian
                byte[] b = BitConverter.GetBytes(medida);

                // Verificar si el sistema es Little-Endian y convertir si es necesario
                if (!BitConverter.IsLittleEndian)
                {
                    Array.Reverse(b);
                }

                serialPortMatLab.Write(b, 0, 2);
                serialPortMatLab.Write("\n");

                Console.WriteLine("Datos de medida enviados por el puerto serie a MatLab.");
            }
            else
            {
                MessageBox.Show("Error: Puerto serie para MatLab no está abierto.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void ConvertirValor(TextBox textBox, ref int variableDestino, string nombre)
        {
            string valorIngresado = textBox.Text;

            if (decimal.TryParse(valorIngresado, out decimal numeroDecimal))
            {
                if (nombre == "velocidad de consigna")
                {
                    variableDestino = (int)numeroDecimal;
                }
                else
                {
                    variableDestino = (int)(numeroDecimal * 10);
                }
            }
            else
            {
                MessageBox.Show($"El valor ingresado en '{nombre}' no es un número válido.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private StringBuilder receivedMessage = new StringBuilder(); // Para acumular el mensaje recibido

        private void SerialPort_DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            Console.WriteLine("Leyendo del puerto serie...");

            string receivedData = serialPort.ReadExisting();
            bool dentroDelMensaje = false; // Indicador para saber si estamos procesando el mensaje

            foreach (char c in receivedData)
            {
                if (c == 's') // Inicio del mensaje
                {
                    dentroDelMensaje = true;
                    receivedMessage.Clear();
                }
                else if (c == 'e' && dentroDelMensaje) // Fin del mensaje
                {
                    try
                    {
                        semaphore.Wait(); // Bloquear el semáforo solo mientras procesamos el mensaje
                        ProcesarMensaje(receivedMessage.ToString()); // Procesar el mensaje completo
                    }
                    finally
                    {
                        dentroDelMensaje = false; // Terminamos de procesar el mensaje
                        semaphore.Release(); // Liberar el semáforo
                        receivedMessage.Clear();
                    }
                }
                else if (dentroDelMensaje) // Acumular caracteres dentro del mensaje
                {
                    receivedMessage.Append(c);
                }
            }
        }


        private void ProcesarMensaje(string mensaje)
        {
            // Verificar que el mensaje tenga exactamente 16 caracteres
            if (mensaje.Length == 16)
            {
                try
                {
                    // Convertir el dato binario a entero
                    short valorEntero = Convert.ToInt16(mensaje, 2);
                    EnviarMedidaMatLab(valorEntero);

                    // Actualizar el campo de texto en la interfaz de usuario
                    Dispatcher.Invoke(() =>
                    {
                        vMedida.Text = valorEntero.ToString();
                    });
                }
                catch (FormatException ex)
                {
                    MessageBox.Show($"Error al convertir el dato recibido: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            else
            {
                MessageBox.Show("El dato recibido no tiene 16 caracteres.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void OpenButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                if (CBox_WritePort.Text == CBox_ReadPort.Text)
                    MessageBox.Show($"Error: Los puertos de lectura y escritura no pueden ser el mismo", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                else
                {
                    // Apertura del puerto de lectura
                    serialPort = new SerialPort(CBox_ReadPort.Text, 9600, Parity.None, 8, StopBits.One);
                    serialPort.DataReceived += new SerialDataReceivedEventHandler(SerialPort_DataReceived);
                    serialPort.Open();

                    // Apertura del puerto de escritura
                    serialPortMatLab = new SerialPort(CBox_WritePort.Text, 9600, Parity.None, 8, StopBits.One);
                    serialPortMatLab.Open();

                    progressBar.Value = 100;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void CloseButton_Click(object sender, RoutedEventArgs e)
        {
            if (serialPort.IsOpen && serialPortMatLab.IsOpen)
            {
                serialPort.Close();
                serialPortMatLab.Close();
                progressBar.Value = 0;
            }
        }

        private async void Aplicar_Click(object sender, RoutedEventArgs e)
        {
            ConvertirValor(vConsig, ref valVelConsig, "velocidad de consigna");
            ConvertirValor(KpVal, ref Kp, "Kp");
            ConvertirValor(KiVal, ref Ki, "Ki");
            ConvertirValor(KdVal, ref Kd, "Kd");

            if (serialPort != null && serialPort.IsOpen)
            {
                try
                {
                    await semaphore.WaitAsync(); // Intenta adquirir el semáforo asincrónicamente

                    while (isReading)
                    {
                        await Task.Delay(100); // Espera asincrónicamente mientras se está leyendo
                    }

                    isWriting = true;
                    EnviarDatos();
                }
                finally
                {
                    isWriting = false;
                    semaphore.Release(); // Liberar el semáforo
                }
            }
            else
            {
                MessageBox.Show("Error: No se ha abierto el puerto de escritura", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }


        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            string[] ports = SerialPort.GetPortNames();
            foreach (var port in ports)
            {
                CBox_WritePort.Items.Add(port);
                CBox_ReadPort.Items.Add(port);
            }
        }
    }
}
