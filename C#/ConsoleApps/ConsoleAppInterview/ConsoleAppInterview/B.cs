using System;

namespace ConsoleAppInterview
{

    internal class A
    {
        public A()
        {
            PrintFields();
        }

        public virtual void PrintFields()
        {
        }
    }

    internal class B : A
    {
        int x = 1;
        int y;

        public B()
        {
            y = -1;
        }

        public override void PrintFields()
        {
            Console.WriteLine($"x={x}, y={y}"); //x=1, y=0
        }

    }

}