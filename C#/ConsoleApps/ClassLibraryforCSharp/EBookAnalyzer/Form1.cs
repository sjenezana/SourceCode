using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace EBookAnalyzer
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();

            InitEvent();
        }

        private void InitEvent()
        {
            this.btndownload.Click += delegate
            {
                using (WebClient webClient = new WebClient())
                {
                    webClient.DownloadStringCompleted += (sender, e) =>
                    {
                        this.txtShow.Text = e.Result;
                    };
                    webClient.DownloadStringAsync(new Uri("http://www.gutenberg.org/files/98/98-8.txt"));
                }
            };

            this.btnstatus.Click += (sender, arg) =>
            {
                string[] words = this.txtShow.Text.Split(new char[] { ' ', '\u000A', ',', '.', ':', '-', '?', '/' }).ToArray();
                string[] words2 = (string[])words.ToArray().Clone();
                string[] tenCommon = GetTenCommonWords(words);
                string longestWord = GetLongestWord(words2);
                string text = string.Join(",", tenCommon);
                text = $"{text} \n {longestWord}";

                this.txtShow.Text = text;
            };
        }

        private string GetLongestWord(string[] words)
        {
            return (from w in words.AsParallel() where w.Length > 6 orderby w.Length descending select w).FirstOrDefault();
        }

        private string[] GetTenCommonWords(string[] words)
        {
            var frequency = from w in words
                            where w.Length > 5
                            group w by w into g
                            orderby g.Count() descending
                            select g.Key;

            return frequency.Take(10).ToArray();
        }
    }
}
