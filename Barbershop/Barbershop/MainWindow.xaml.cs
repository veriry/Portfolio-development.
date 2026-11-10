using System;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Input;

namespace Barbershop
{
    /// <summary>
    /// Логика взаимодействия для MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        // Поле базы данных на уровне класса
        private BarbershopEntities1 db = new BarbershopEntities1();
        private int errorCount = 0;

        public MainWindow()
        {
            InitializeComponent();
        }

        #region Показ/скрытие пароля через кнопку-глаз

        // При нажатии на кнопку: копируем текст и показываем обычное текстовое поле
        private void BtnShowPass_PreviewMouseDown(object sender, RoutedEventArgs e)
        {
            PassText.Text = PassBox.Password;
            PassBox.Visibility = Visibility.Collapsed;
            PassText.Visibility = Visibility.Visible;
            PassText.Focus(); // Переводим фокус для удобства
        }

        // При отпускании мыши: возвращаем всё назад
        private void BtnShowPass_PreviewMouseUp(object sender, MouseButtonEventArgs e)
        {
            PassBox.Password = PassText.Text;
            PassText.Visibility = Visibility.Collapsed;
            PassBox.Visibility = Visibility.Visible;
            PassBox.Focus();
        }

        #endregion

        #region Капча и Блокировка

        private string GenerateCapcha()
        {
            string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            Random rand = new Random();
            char[] result = new char[6];
            for (int i = 0; i < result.Length; i++)
                result[i] = chars[rand.Next(chars.Length)];

            return new string(result);
        }

        private async Task BlockInput(int seconds)
        {
            this.IsEnabled = false;            // Блокируем интерфейс окна
            await Task.Delay(seconds * 1000);  // Асинхронно ждем без зависания UI
            this.IsEnabled = true;             // Разблокируем окно
        }

        #endregion

        #region Событие нажатия клавиши Enter

        public async void PassBox_KeyDown(object sender, KeyEventArgs e)
        {
            // Обрабатываем только нажатие клавиши Enter
            if (e.Key != Key.Enter) return;

            string login = LoginBox.Text;

            // Получаем актуальный пароль в зависимости от того, какое поле сейчас активно
            string password = PassBox.Visibility == Visibility.Visible ? PassBox.Password : PassText.Text;

            // 1. Проверка капчи (если блок капчи отображается на экране)
            if (CaptchaBlock.Visibility == Visibility.Visible)
            {
                // Используем правильное имя элемента 'CaptchaInput' из обновленного XAML
                if (CaptchaInput.Text != CaptchaText.Text)
                {
                    MessageBox.Show("Капча была введена неверно!");
                    MessageBox.Show("Блокировка интерфейса на 10 секунд");

                    CaptchaInput.Text = ""; // Очищаем поле ввода капчи
                    CaptchaText.Text = GenerateCapcha(); // Перегенерируем капчу

                    await BlockInput(10);
                    return; // Выходим из метода, к авторизации не переходим
                }
            }

            // 2. Авторизация пользователя через БД
            var user = db.Employees.FirstOrDefault(u => u.Login == login && u.Password == password);

            if (user != null)
            {
                MessageBox.Show("Авторизация успешна!");

                // Открытие соответствующего окна в зависимости от роли
                switch (user.ID_Role)
                {
                    case 1:
                        new AdminWindow(user).Show();
                        break;
                    case 2:
                        new BarberWindow(user).Show();
                        break;
                    default:
                        MessageBox.Show("Роль пользователя не распознана.");
                        return;
                }
                this.Close(); // Закрываем окно авторизации
            }
            else
            {
                // Если пользователь не найден — увеличиваем счетчик ошибок
                errorCount++;
                MessageBox.Show("Неверный логин или пароль!");

                // Если это первая или последующая ошибка — требуем ввод капчи
                if (errorCount >= 1)
                {
                    CaptchaBlock.Visibility = Visibility.Visible;
                    CaptchaText.Text = GenerateCapcha();
                    CaptchaInput.Text = ""; // Сбрасываем старый ввод
                }
            }
        }

        #endregion
    }
}
