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


            //ADONETMethod();
            Console.WriteLine("1" + 2 + 3);
            Console.WriteLine(1 + 2 + "3");

            FibonacciMethod();

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



        private static void FibonacciMethod()
        {
            Console.WriteLine(FiImp(5));

            int a = 1;
            var b = 1;

            for (int i = 3; i <= 9; i++)
            {
                b = checked(b + a);
                a = b - a;
            }

            Console.WriteLine(b);
        }

        private static int FiImp(int v)
        {
            if (v == null || v < 0)
                return 0;
            if (v == 0 || v == 1)
                return 1;

            return FiImp(v - 1) + FiImp(v - 2);
        }
    }




}