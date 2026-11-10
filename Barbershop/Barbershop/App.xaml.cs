using System;
using System.Data.SqlClient;
using System.IO;
using System.Text.RegularExpressions;
using System.Windows;

public partial class App : Application
{
    protected override void OnStartup(StartupEventArgs e)
    {
        try
        {
            string path = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "script_full.sql");
            string script = File.ReadAllText(path);
            var batches = Regex.Split(script, @"^\s*GO\s*$",
                RegexOptions.Multiline | RegexOptions.IgnoreCase);

            using (var cn = new SqlConnection(
                "Data Source=.;Initial Catalog=master;Integrated Security=True;TrustServerCertificate=True"))
            {
                cn.Open();
                foreach (var batch in batches)
                {
                    if (string.IsNullOrWhiteSpace(batch)) continue;
                    using (var cmd = new SqlCommand(batch, cn) { CommandTimeout = 120 })
                        cmd.ExecuteNonQuery();
                }
            }
        }
        catch (Exception ex)
        {
            MessageBox.Show("Не удалось подготовить базу данных:\n" + ex.Message,
                "Barbershop", MessageBoxButton.OK, MessageBoxImage.Error);
            Shutdown();
            return;
        }
        base.OnStartup(e);
    }
}