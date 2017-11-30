using System;

namespace ConsoleAppInterview
{
    internal class NewClass
    {
        public NewClass()
        {
        }


        public virtual void Print(object o)
        {
            Console.WriteLine($"type is {o.GetType()}");
        }

        public virtual void Print2(object o)
        {
            Console.WriteLine($"type is {o.GetType()}");
        }

    }

    class NewClass2 : NewClass
    {
        public override void Print(object o)
        {
            Console.WriteLine($"type is {o.GetType()}");
        }

        public new void Print2(object o)
        {
            Console.WriteLine($"type is {o.GetType()}");
        }
    }


}

