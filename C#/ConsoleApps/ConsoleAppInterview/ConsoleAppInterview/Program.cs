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

            GenericMethod();
            //Interview();
            Console.ReadLine();

        }

        private static void GenericMethod()
        {
            Node<int, int> node = new Node<int, int>();
            Console.WriteLine(node.add(2, 1));
            Node<int, float> node2 = new Node<int, float>();
            Console.WriteLine(node2.add(2, 1.1f));
            Node<float, int> node3 = new Node<float, int>();
            Console.WriteLine(node3.add(2.2f, 1));
        }

        private static void Interview()
        {
            //inheritance function priority
            //继承类的方法的加载优先级：加载子类的字段，父类构造函数，子类构造函数，子类重写父类的方法，
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
        }


        public class Node<T, V>
        {
            public T add(T a, V b)
            {
                return a;
            }
            public T add(V a, T b)
            {
                return b;
            }

            public int add(int a, int b)
            {
                return a + b;
            }
        }
    }
}
