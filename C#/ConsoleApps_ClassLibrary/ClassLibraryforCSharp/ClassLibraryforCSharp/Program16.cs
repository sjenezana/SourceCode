using System;
using MyCircle = MyNameSpace.Circle;
using Car;
using System.Reflection;
using System.Linq;
using System.Collections.Generic;


namespace ClassLibraryforCSharp
{
    class Program16
    {

        static void Main16(string[] args)
        {
            Console.WriteLine("Hello world!");


            ImplicitlyTypeVariable();



            DynamicWithlateBinding();

            DynamicWithCOMBinding();

            Console.ReadLine();

        }

        private static void DynamicWithCOMBinding()
        {

        }

        private static void DynamicWithlateBinding()
        {
            Type typeSquare = Assembly.Load("ClassLibraryforCSharp").GetType("ClassLibraryforCSharp.Square");
            MethodInfo methodInfo = typeSquare.GetMethod("ShowMessage");
            object objSquare = Activator.CreateInstance(typeSquare);
            methodInfo.Invoke(objSquare, new object[] { "" });

            dynamic dynSquare = Activator.CreateInstance(typeSquare);
            dynSquare.ShowMessage();

        }

        private static void ImplicitlyTypeVariable()
        {
            var a = new List<int>();
            a.Add(3);


            var v1 = "var";
            //Cannot implicitly convert type 'int' to 'string'   
            //v1 = 8;
            object o1 = "object";
            o1 = 8;
            dynamic d1 = "dynamic";
            d1 = 8;

            Console.WriteLine("var type is {0}", v1.GetType());
            Console.WriteLine("object type is {0}", o1.GetType());
            Console.WriteLine("dynamic type is {0}", d1.GetType());

            //DynamicMethod();
        }

        private static dynamic DynamicMethod()
        {
            dynamic textData = "Hello";
            Console.WriteLine(textData.ToUpper());
            Console.WriteLine(textData.toUpper());
            Console.WriteLine(textData.Foo("sad", DateTime.Now));
            return null;
        }
    }
}