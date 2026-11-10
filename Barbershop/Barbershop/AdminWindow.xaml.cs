using Barbershop;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using Word = Microsoft.Office.Interop.Word;


namespace Barbershop
{
    /// <summary>
    /// Логика взаимодействия для AdminWindow.xaml
    /// </summary>
    public partial class AdminWindow : Window
    {
        private Employee _user;
        BarbershopEntities1 db = new BarbershopEntities1();
        private DateTime _selectedDate;
        private Client _selectedClient;
        public AdminWindow(Employee user) // Принимаем объект 
        {
            InitializeComponent();
            _user = user;

            txtUser.Text = "Соловаров Максим Максимович";//$"{_user.FIO}";
            txtRole.Text = "Администратор";
            _selectedDate = DateTime.Today;

            LoadData();
        }

        private void LoadData()
        {
            // Защита от преждевременного вызова: если таблица или календарь еще не созданы, выходим
            if (Table == null || MainDatePicker == null || MainDatePicker.SelectedDate == null) return;

            DateTime targetDate = MainDatePicker.SelectedDate.Value.Date;

            using (var db = new BarbershopEntities1())
            {
                var query = db.Visits
                              .Include("Client")
                              .Include("Employee")
                              .Include("Status_Visit")
                              .Include("Visit_Service.Service")
                              .Where(v => v.Visit_Date == targetDate);

                if (Sort != null && Sort.SelectedIndex == 1)
                {
                    query = query.OrderByDescending(v => v.Visit_Time);
                }
                else
                {
                    query = query.OrderBy(v => v.Visit_Time);
                }

                var visitsList = query.ToList();

                Table.ItemsSource = visitsList.Select(v => new ScheduleItemViewModel(v)).ToList();
            }
        }

        #region DatePicker
        // Вызывается при изменении даты в календаре
        private void MainDatePicker_SelectedDateChanged(object sender, SelectionChangedEventArgs e)
        {
            LoadData();
        }

        // Вызывается при изменении типа сортировки в ComboBox
        private void SortComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            LoadData();
        }

        // Логика кнопок переключения дней
        private void PrevDay_Click(object sender, RoutedEventArgs e)
        {
            if (MainDatePicker.SelectedDate.HasValue)
                MainDatePicker.SelectedDate = MainDatePicker.SelectedDate.Value.AddDays(-1);
        }

        private void NextDay_Click(object sender, RoutedEventArgs e)
        {
            if (MainDatePicker.SelectedDate.HasValue)
                MainDatePicker.SelectedDate = MainDatePicker.SelectedDate.Value.AddDays(1);
        }

        private void Today_Click(object sender, RoutedEventArgs e)
        {
            MainDatePicker.SelectedDate = DateTime.Today;
        }
        #endregion
        private void Button_Click(object sender, RoutedEventArgs e)
        {
            MainWindow main = new MainWindow();
            main.Show();
            this.Close();
        }

        private void EditAppointment_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var selectedItem = Table.SelectedItem as ScheduleItemViewModel;

                if (selectedItem == null)
                {
                    MessageBox.Show("Выберите запись!");
                    return;
                }

                txtManage.Visibility = Visibility.Visible;
                SaveAllButton.Visibility = Visibility.Visible;
                CancelVisitButton.Visibility = Visibility.Visible;
                DeleteVisitButton.Visibility = Visibility.Visible;

                Table.IsReadOnly = false;
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void SaveAllButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                foreach (ScheduleItemViewModel item in Table.Items)
                {
                    var visit = db.Visits
                                  .FirstOrDefault(x => x.ID_Visit == item.Visit.ID_Visit);

                    if (visit != null)
                    {
                        visit.Status_Visit.Name = item.StatusName;
                    }
                }

                db.SaveChanges();

                MessageBox.Show("Изменения сохранены!");

                Table.IsReadOnly = true;

                txtManage.Visibility = Visibility.Collapsed;
                SaveAllButton.Visibility = Visibility.Collapsed;
                CancelVisitButton.Visibility = Visibility.Collapsed;
                DeleteVisitButton.Visibility = Visibility.Collapsed;

                LoadData();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void CancelVisitButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var selectedItem = Table.SelectedItem as ScheduleItemViewModel;

                if (selectedItem == null)
                {
                    MessageBox.Show("Выберите запись!");
                    return;
                }

                var visit = db.Visits.Find(selectedItem.Visit.ID_Visit);

                if (visit != null)
                {
                    visit.ID_Status_Visit = 3; // статус "Отменена"

                    db.SaveChanges();

                    MessageBox.Show("Запись отменена.");

                    LoadData();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void DeleteVisitButton_Click(object sender, RoutedEventArgs e)
        {
            var selectedItem = Table.SelectedItem as ScheduleItemViewModel;

            if (selectedItem == null)
            {
                MessageBox.Show("Выберите запись!");
                return;
            }

            if (MessageBox.Show(
                "Удалить запись?",
                "Подтверждение",
                MessageBoxButton.YesNo,
                MessageBoxImage.Question) == MessageBoxResult.Yes)
            {
                var visit = db.Visits.Find(selectedItem.Visit.ID_Visit);

                if (visit != null)
                {
                    // 1. Находим и удаляем все связанные услуги для этого визита
                    var relatedServices = db.Visit_Service.Where(vs => vs.ID_Visit == visit.ID_Visit);
                    db.Visit_Service.RemoveRange(relatedServices);

                    // 2. Теперь удаляем сам визит
                    db.Visits.Remove(visit);

                    // 3. Сохраняем изменения в базе данных
                    db.SaveChanges();

                    MessageBox.Show("Запись успешно удалена!");
                    LoadData();
                }

            }
        }
        private void ClientBtn_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var selectedItem = Table.SelectedItem as ScheduleItemViewModel;

                if (selectedItem == null)
                {
                    MessageBox.Show("Выберите запись!");
                    return;
                }

                var visit = db.Visits
                              .Include("Client")
                              .FirstOrDefault(x => x.ID_Visit == selectedItem.Visit.ID_Visit);

                if (visit == null || visit.Client == null)
                {
                    MessageBox.Show("Клиент не найден!");
                    return;
                }

                _selectedClient = visit.Client;

                txtSurname.Text = _selectedClient.Surname;
                txtName.Text = _selectedClient.Name;
                txtLastname.Text = _selectedClient.Patronymic;

                if (!string.IsNullOrEmpty(_selectedClient.Phone))
                {
                    // Пытаемся распарсить строку из БД (например "7.9006762e+010") в double
                    if (double.TryParse(_selectedClient.Phone, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out double phoneValue))
                    {
                        // Форматируем double как обычное целое число без экспоненты и добавляем плюс
                        txtPhone.Text = "+" + phoneValue.ToString("0");
                    }
                    else
                    {
                        txtPhone.Text = _selectedClient.Phone;
                    }
                }
                else
                {
                    txtPhone.Text = "";
                }

                if (_selectedClient.DateOfBirth != null)
                {
                    txtDate.Text = _selectedClient.DateOfBirth.Value.ToString("dd.MM.yyyy");
                }
                else
                {
                    txtDate.Text = "";
                }

                // скрываем расписание
                Table.Visibility = Visibility.Collapsed;
                MainDatePicker.Visibility = Visibility.Collapsed;
                Sort.Visibility = Visibility.Collapsed;

                // показываем карточку
                ClientCardGrid.Visibility = Visibility.Visible;
                SaveClient.Visibility = Visibility.Visible;
                txtManage.Visibility = Visibility.Visible;

            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка при открытии карточки: {ex.Message}");
            }
        }

        private void SaveClient_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                if (_selectedClient == null)
                {
                    MessageBox.Show("Клиент не выбран!");
                    return;
                }

                // Валидация обязательных полей
                if (string.IsNullOrWhiteSpace(txtName.Text) || string.IsNullOrWhiteSpace(txtSurname.Text))
                {
                    MessageBox.Show("Поля 'Имя' и 'Фамилия' должны быть заполнены!");
                    return;
                }

                _selectedClient.Surname = txtSurname.Text.Trim();
                _selectedClient.Name = txtName.Text.Trim();
                _selectedClient.Patronymic = txtLastname.Text.Trim();

                // Перед сохранением убираем '+' и пробелы, чтобы строка соответствовала числовому формату БД
                _selectedClient.Phone = txtPhone.Text.Replace("+", "").Trim();

                // Валидация и сохранение даты рождения
                if (!string.IsNullOrWhiteSpace(txtDate.Text))
                {
                    if (DateTime.TryParse(txtDate.Text.Trim(), out DateTime birthDate))
                    {
                        _selectedClient.DateOfBirth = birthDate;
                    }
                    else
                    {
                        MessageBox.Show("Некорректный формат даты! Используйте ДД.ММ.ГГГГ");
                        return;
                    }
                }
                else
                {
                    _selectedClient.DateOfBirth = null;
                }

                db.SaveChanges();

                MessageBox.Show("Данные клиента успешно сохранены!");

                // возвращаем расписание
                Table.Visibility = Visibility.Visible;
                MainDatePicker.Visibility = Visibility.Visible;
                Sort.Visibility = Visibility.Visible;

                ClientCardGrid.Visibility = Visibility.Collapsed;
                SaveClient.Visibility = Visibility.Collapsed;

                if (txtManage != null) txtManage.Visibility = Visibility.Collapsed;

                LoadData();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка при сохранении: {ex.Message}");
            }
        }

        private void BooKclient_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                CustomBtn.Visibility = Visibility.Collapsed;
                ClientBtn.Visibility = Visibility.Collapsed;

                Exit.Visibility = Visibility.Visible;
                var clients = db.Clients.ToList();

                ClientsTable.ItemsSource = clients;

                // скрываем расписание
                Table.Visibility = Visibility.Collapsed;

                MainDatePicker.Visibility = Visibility.Collapsed;
                Sort.Visibility = Visibility.Collapsed;

                // скрываем карточку клиента если открыта
                ClientCardGrid.Visibility = Visibility.Collapsed;

                // показываем справочник
                ClientsTable.Visibility = Visibility.Visible;

                txtManage.Visibility = Visibility.Visible;
                txtManage.Text = "СПРАВОЧНИК КЛИЕНТОВ";

                AddClientButton.Visibility = Visibility.Visible;
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void AddClientButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                int nextId = 1;

                if (db.Clients.Any())
                {
                    nextId = db.Clients.Max(x => x.ID_Client) + 1;
                }

                Client newClient = new Client();

                newClient.ID_Client = nextId;
                newClient.Name = "Новый";
                newClient.Surname = "Клиент";
                newClient.Patronymic = "";
                newClient.Phone = "";
                newClient.DateOfBirth = null;

                db.Clients.Add(newClient);

                db.SaveChanges();

                ClientsTable.ItemsSource = null;
                ClientsTable.ItemsSource = db.Clients.ToList();

                MessageBox.Show("Клиент успешно добавлен!");
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void Button_Click_1(object sender, RoutedEventArgs e)
        {
            CustomBtn.Visibility = Visibility.Visible;
            ClientBtn.Visibility = Visibility.Visible;


            Exit.Visibility = Visibility.Collapsed;
            Table.Visibility = Visibility.Visible;

            MainDatePicker.Visibility = Visibility.Visible;
            Sort.Visibility = Visibility.Visible;

            ClientsTable.Visibility = Visibility.Collapsed;
            ClientCardGrid.Visibility = Visibility.Collapsed;

            AddClientButton.Visibility = Visibility.Collapsed;

            txtManage.Visibility = Visibility.Collapsed;

            LoadData();
        }

        private void FinancialReport_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var selectedItem = Table.SelectedItem as ScheduleItemViewModel;

                if (selectedItem == null)
                {
                    MessageBox.Show("Выберите запись!");
                    return;
                }

                var visit = db.Visits
                    .Include("Client")
                    .Include("Status_Visit")
                    .Include("Visit_Service.Service")
                    .FirstOrDefault(x => x.ID_Visit == selectedItem.Visit.ID_Visit);

                if (visit == null)
                {
                    MessageBox.Show("Запись не найдена!");
                    return;
                }

                var service = visit.Visit_Service.FirstOrDefault();

                Word.Application wordApp = new Word.Application();
                wordApp.Visible = false;

                string templatePath = Environment.CurrentDirectory + @"\Чек_Барбершоп.docx";

                Word.Document doc = wordApp.Documents.Open(templatePath);

                ReplaceWord("{Surname}", visit.Client?.Surname ?? "", doc);
                ReplaceWord("{Name}", visit.Client?.Name ?? "", doc);
                ReplaceWord("{Phone}", visit.Client?.Phone ?? "", doc);

                ReplaceWord("{ID_Visit}", visit.ID_Visit.ToString(), doc);

                ReplaceWord("{Дата}",
                    DateTime.Now.ToString("dd.MM.yyyy HH:mm"),
                    doc);

                ReplaceWord("{Статус_визита}",
                    visit.Status_Visit?.Name ?? "",
                    doc);

                ReplaceWord("{{Название_услуги}}",
                    service?.Service?.Name ?? "",
                    doc);

                ReplaceWord("{{Total_Duration}}",
                    service?.Service?.Duration.ToString() ?? "0",
                    doc);

                ReplaceWord("{{Total_Price}}",
                    service?.Service?.Price?.ToString("0.00") ?? "0.00",
                    doc);

                string fileName =
                    $"Отчет_{visit.ID_Visit}_{DateTime.Now:ddMMyyyy_HHmm}.docx";

                string savePath =
                    Environment.CurrentDirectory + @"\" + fileName;

                doc.SaveAs2(savePath);

                doc.Close();
                wordApp.Quit();

                MessageBox.Show($"Финансовый отчет успешно сформирован и сохранен по пути:\n{savePath}");
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка формирования отчета: " + ex.Message);
            }
        }
        private void ReplaceWord(string findText, string replaceText, Word.Document doc)
        {
            var range = doc.Content;

            range.Find.ClearFormatting();

            range.Find.Execute(
                FindText: findText,
                ReplaceWith: replaceText,
                Replace: Word.WdReplace.wdReplaceAll
            );
        }
    }
}
        public class ScheduleItemViewModel
{
    public Visit Visit { get; set; }

    public string Time { get; set; }
    public string ClientName { get; set; }
    public string BarberName { get; set; }
    public string ServiceName { get; set; }
    public string StatusName { get; set; }

    public ScheduleItemViewModel(Visit v)
    {
        Visit = v;

        string dateStr = v.Visit_Date?.ToString("dd.MM.yyyy") ?? "";
        string timeStr = v.Visit_Time?.ToString(@"hh\:mm") ?? "";

        Time = $"{dateStr} {timeStr}".Trim();
        ClientName = v.Client != null ? $"{v.Client.Surname} {v.Client.Name}" : "—";
        BarberName = v.Employee?.FIO ?? "—";

        var firstService = v.Visit_Service?.FirstOrDefault()?.Service;
        ServiceName = firstService?.Name ?? "—";

        StatusName = v.Status_Visit?.Name ?? "—";
    }
}