using System;

namespace ClassLibraryforCSharp
{
    [Serializable]
    internal class Square : ITest
    {
        public int Length { get; set; }

        //[NonSerialized,Obsolete]
        //public string NameFiled2;
        //private string NameFiled;
        //public string NameFiled22;
        //protected string NameFiled3;
        //internal string NameField4;

        public Square() { }

        public void Display()
        {
            for (int i = 0; i < Length; i++)
            {
                for (int j = 0; j < Length; j++)
                    Console.Write("* ");

                Console.WriteLine();
            }
        }

        public void ShowMessage(string message = "default message")
        {
            Console.WriteLine("hello, this is message for show : {0} .",message);
        }
    }

    public interface ITest { }
}