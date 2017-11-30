using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleAppInterview
{
    class Program
    {
        static void Main(string[] args)
        {
            //inheritance function priority
            //加载子类的字段，父类构造函数，子类构造函数，子类重写父类的方法，
            B b = new B();
            // static
            // static field >static function
            // static field 读取一次后直接使用
            Console.WriteLine($"x = {StaticSample.x}, y={StaticSample2.y}");
            Console.WriteLine($"y={StaticSample2.y}");
            //inheritance with new 
            // hide an inherited member from a base class member
            NewClass n = new NewClass();
            NewClass2 n2 = new NewClass2();
            n.Print(n);
            n2.Print(n2);
            n.Print2(n);
            n2.Print2(n2);
            n = new NewClass2();
            n.Print(n);
            n.Print2(n);//NewClass function
            Console.ReadLine();
        }
    }
}
