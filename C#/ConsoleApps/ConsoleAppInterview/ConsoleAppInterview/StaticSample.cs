using System;

namespace ConsoleAppInterview
{
    internal class StaticSample
    {
        public static int x;
        static StaticSample()
        {
            x = StaticSample2.y + 1;
        }
    }

    internal class StaticSample2
    {
        public static int y = StaticSample.x + 2;
        static StaticSample2()
        {
            Console.WriteLine("1");
        }
    }


}