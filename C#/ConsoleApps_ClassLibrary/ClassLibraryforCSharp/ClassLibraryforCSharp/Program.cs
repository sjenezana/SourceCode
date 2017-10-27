using System;
using MyCircle = MyNameSpace.Circle;
using Car;
using System.Reflection;
using System.Linq;

[assembly: CLSCompliant(true)]
namespace ClassLibraryforCSharp
{
    class Program
    {
        string str = string.Empty;

        static void Main(string[] args)
        {
            Console.WriteLine("Hello world!");

            NameSpaceMethod();

            ReflectionMethod();

            //TypeViewer();

            //DispalyTypesInAsm();

            //ReflectShareAssembly();

            LateBindMethod();

            Attributemethod();


            Console.ReadLine();

        }



        private static void Attributemethod()
        {
            //early binding
            Type type = typeof(Vehical);
            foreach (VehicalDescriptionAttribute v in type.GetCustomAttributes(false))
                Console.WriteLine("attribute : {0}",v.Description);
            //late binding 

            Assembly assembly = Assembly.Load("ClassLibraryforCSharp");
            Type vehicalType = assembly.GetType("ClassLibraryforCSharp.VehicalDescriptionAttribute");
            object[] objs;


            foreach (Type t in assembly.GetTypes())
            {
                objs = t.GetCustomAttributes(vehicalType,false);
                foreach (object o in objs)
                    Console.WriteLine("name {0}, value {1}",t.Name,vehicalType.GetProperty("Description").GetValue(o,null));
            }

        }

        private static void LateBindMethod()
        {
            Console.WriteLine("begin late bind...");

            try
            {
                Assembly assembly = Assembly.Load("ClassLibraryforCSharp");
                Type type = assembly.GetType("ClassLibraryforCSharp.Square");
                object obj = Activator.CreateInstance(type);
                Console.WriteLine("create a late bind type {0}", obj);

                MethodInfo methodInfo = type.GetMethod("ShowMessage");
                methodInfo.Invoke(obj, new object[] { null });
                methodInfo.Invoke(obj, new object[] { "custome message " });

            }
            catch (Exception e) { Console.WriteLine(e); }

        }

        private static void ReflectShareAssembly()
        {
            Assembly assembly = Assembly.Load(@"Car, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null");
            DisplayTypesInAssembly(assembly);
            assembly = Assembly.Load(@"mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089");
            DisplayTypesInAssembly(assembly);
        }

        private static void DispalyTypesInAsm()
        {
            Console.WriteLine("welcome to assembly viewer");
            string assemblyname;
            Assembly assembly;

            //path D:\Git\SourceCode\C#\ConsoleApps_ClassLibrary\ClassLibraryforCSharp\ClassLibraryforCSharp\bin\Debug\Car.dll
            //var path = @"D:\Git\SourceCode\C#\ConsoleApps_ClassLibrary\ClassLibraryforCSharp\ClassLibraryforCSharp\bin\Debug\Car.dll";

            do
            {
                Console.WriteLine("please input type(Q to exit):");
                assemblyname = Console.ReadLine();
                if (assemblyname.ToUpper().Equals("Q"))
                    break;
                try
                {
                    assembly = Assembly.Load(assemblyname);
                    //assembly = Assembly.LoadFrom(path);
                    //assembly = Assembly.LoadFile(path);
                    DisplayTypesInAssembly(assembly);

                }
                catch (Exception e) { }


            } while (true);


        }

        private static void DisplayTypesInAssembly(Assembly assembly)
        {
            Console.WriteLine("welcome to type DisplayTypesInAssembly");
            Console.WriteLine("FullName " + assembly.FullName);

            foreach (Type t in assembly.GetTypes())
                Console.WriteLine("type is {0}", t);

        }

        private static void TypeViewer()
        {
            Console.WriteLine("welcome to type viewer");
            string typename;
            do
            {
                Console.WriteLine("please input type(Q to exit):");
                typename = Console.ReadLine();
                if (typename.ToUpper().Equals("Q"))
                    break;
                try
                {
                    Type type = Type.GetType(typename);
                    ListReflects(type);
                }
                catch { }

            }
            while (true);
        }

        private static void ReflectionMethod()
        {
            Square square = new Square();
            square.Length = 6;
            square.Display();


            Type type = square.GetType();
            type = typeof(Square);
            type = Type.GetType("ClassLibraryforCSharp.Square", true, true);

            ListReflects(type);

        }

        private static void ListReflects(Type type)
        {
            var methods = from f in type.GetMethods() select f.Name;
            foreach (var v in methods)
                Console.WriteLine(" reflect method is {0}", v);
            var fileds = from f in type.GetFields() select f.Name;
            foreach (var v in fileds)
                Console.WriteLine(" reflect fileds is {0}", v);
            var pros = from f in type.GetProperties() select f.Name;
            foreach (var v in pros)
                Console.WriteLine(" reflect pros is {0}", v);
            var interfaces = from f in type.GetInterfaces() select f.Name;
            foreach (var v in interfaces)
                Console.WriteLine(" reflect interfaces is {0}", v);

            foreach (MethodInfo m in type.GetMethods())
            {
                var parameters = from f in m.GetParameters() select new { f.Name, f.ParameterType };
                foreach (var v in parameters)
                    Console.WriteLine(" reflect GetParameters is {0} {1}", v.Name, v.ParameterType);
            }
        }
        private static void NameSpaceMethod()
        {
            MyCircle mycircle = new MyCircle();
            Circle defalutCircle = new Circle();
            CarClass car = new CarClass();



        }

    }
}