using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters.Binary;
using System.Runtime.Serialization.Formatters.Soap;
using System.Text;
using System.Xml.Serialization;

namespace ClassLibraryforCSharp
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello world!");


            ADONETMethod();
            Console.ReadLine();
        }

        private static void ADONETMethod()
        {
            //object linking and embedding
            //DataMethod();
            //System.Data.DataSet
        }

        public static void OpenConnection(IDbConnection cn)
        {
            cn.Open();
        }
}
 

}