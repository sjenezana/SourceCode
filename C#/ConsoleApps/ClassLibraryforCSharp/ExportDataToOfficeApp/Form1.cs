using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace ExportDataToOfficeApp
{
    public partial class Form1 : Form
    {
        List<Car> carsInStock = new List<Car>();
        public Form1()
        {
            InitializeComponent();
            Init_Event();

        }

        private void Init_Event()
        {
            this.button1.Click += Button1_Click;
            this.button2.Click += delegate { ExportToExcel(carsInStock); };
        }

        private void ExportToExcel(List<Car> carsInStock)
        {
            Microsoft.Office.Interop.Excel.Application excelApp = new Microsoft.Office.Interop.Excel.Application();
            excelApp.Visible = true;
            excelApp.Workbooks.Add();
            Microsoft.Office.Interop.Excel._Worksheet worksheet = excelApp.ActiveSheet;

            worksheet.Cells[1, "A"] = "Color";
            worksheet.Cells[1, "B"] = "Make";
            worksheet.Cells[1, "C"] = "Name";

            int row = 1;
            foreach (Car c in carsInStock)
            {
                row++;
                worksheet.Cells[row, "A"] = c.Color;
                worksheet.Cells[row, "B"] = c.Make;
                worksheet.Cells[row, "C"] = c.Name;
            }


            worksheet.SaveAs(string.Format(@"{0}\Inventory.xlsx", Environment.CurrentDirectory));
            excelApp.Quit();
            MessageBox.Show("please find Inventory.xslx in app folder", "Export complete");
        }

        private void Button1_Click(object sender, EventArgs e)
        {
            UpdateGrid();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            carsInStock = new List<Car> {
                new Car{ Color = "Red", Make = "make1", Name="name1"},
                new Car{ Color = "blue", Make = "make2", Name="name2"},
                new Car{ Color = "black", Make = "make3", Name="name3"},
                new Car{ Color = "white", Make = "make4", Name="name4"},
            };

            UpdateGrid();
        }

        private void UpdateGrid()
        {
            dataGridView1.DataSource = null;
            dataGridView1.DataSource = carsInStock;
        }
    }

    [Synchronization]
    public class ThreadClass : Form
    {
        CancellationTokenSource cancellationToken = new CancellationTokenSource();
        public object threadlock = new object();
        public void PrintNumRandom()
        {
            Random random;
            //lock (threadlock)
            //{
            //    for (int i = 0; i < 10; i++)
            //    {
            //        random = new Random();
            //        Thread.Sleep(1000 * random.Next(5));
            //        Console.WriteLine("thread {0} on {1}", Thread.CurrentThread.ManagedThreadId, i);
            //    }
            //}

            System.Threading.Monitor.Enter(threadlock);
            try
            {
                for (int i = 0; i < 10; i++)
                {
                    random = new Random();
                    Thread.Sleep(1000 * random.Next(5));
                    Console.WriteLine("thread {0} on {1}", Thread.CurrentThread.ManagedThreadId, i);
                }
            }
            finally { Monitor.Exit(threadlock); }
        }


        public void TPLMethodImp()
        {
            ParallelOptions parallelOptions = new ParallelOptions();
            parallelOptions.CancellationToken = cancellationToken.Token;
            parallelOptions.MaxDegreeOfParallelism = System.Environment.ProcessorCount;

            string[] files = Directory.GetFiles(@"C:\Users\v-gusong\Pictures\Saved Pictures", "*g", SearchOption.AllDirectories);
            string newDir = @"D:\home\images";
            Directory.CreateDirectory(newDir);

            foreach (string file in files)
            {
                string fileName = Path.GetFileName(file);
                using (Bitmap bitmap = new Bitmap(fileName))
                {
                    bitmap.RotateFlip(RotateFlipType.Rotate180FlipNone);
                    bitmap.Save(Path.Combine(newDir, fileName));

                    this.Invoke(new Action(delegate { }));
                    Task.Factory.StartNew(()=> { });
                }
            }
        }
    }

}
