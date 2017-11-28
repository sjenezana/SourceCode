using NLog;
using System;

namespace ClassLibraryforCSharp
{
    [Serializable]
    internal class Square : ITest
    {
        private static Logger logger = LogManager.GetCurrentClassLogger();
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
            try { throw new Exception("new exception"); }
            catch (Exception e)
            {
                logger.Error(e, "message");
            }
        }

        public void ShowMessage(string message = "default message")
        {
            Console.WriteLine("hello, this is message for show : {0} .", message);
        }
    }

    public interface ITest { }
}