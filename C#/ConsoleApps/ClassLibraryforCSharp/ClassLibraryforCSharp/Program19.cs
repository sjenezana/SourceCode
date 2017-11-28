using ExportDataToOfficeApp;
using System;
using System.Runtime.Remoting.Messaging;
using System.Threading;
using System.Windows.Forms;

namespace ClassLibraryforCSharp
{
    class Program19
    {
        public delegate int BinaryOp(int x, int y);
        private static bool isDone = false;
        private static AutoResetEvent waithandle = new AutoResetEvent(false);

        static void Main19(string[] args)
        {
            Console.WriteLine("Hello world!");

            //ThreadManual();

            //SynchronizationMethod();

            //TimerMethod();

            //ThreadPoolMethod();


            TPLMethod();
            Console.ReadLine();
        }

        private static void TPLMethod()
        {
            ThreadClass threadClass = new ThreadClass();
            threadClass.TPLMethodImp();

        }

        private static void ThreadPoolMethod()
        {
            WaitCallback waitCallback = new WaitCallback(ThreadPoolPrint);
            ThreadClass threadClass = new ThreadClass();

            for (int i = 0; i < 10; i++)
                ThreadPool.QueueUserWorkItem(waitCallback, threadClass);


        }

        private static void ThreadPoolPrint(object state)
        {
            Console.WriteLine($"current thread is {Thread.CurrentThread.ManagedThreadId}");
            ThreadClass threadClass = state as ThreadClass;
            threadClass.PrintNumRandom();
        }

        private static void TimerMethod()
        {
            TimerCallback timerCallback = new TimerCallback(PrintTime);
            System.Threading.Timer timer = new System.Threading.Timer(timerCallback, "this is state", 2000, 5000);
        }

        private static void PrintTime(object state)
        {
            Console.WriteLine($"the state is {state}");
            Console.WriteLine($"now the time is {DateTime.Now.ToLongTimeString()}");
        }

        private static void SynchronizationMethod()
        {
            ThreadClass threadClass = new ThreadClass();
            Thread[] threads = new Thread[10];
            for (int i = 0; i < 10; i++)
                threads[i] = new Thread(new ThreadStart(threadClass.PrintNumRandom));

            foreach (Thread r in threads)
                r.Start();



            //int a = 10;
            //Interlocked.Increment(ref a);

        }



        private static void ThreadManual()
        {
            Thread thread2 = new Thread(new ParameterizedThreadStart(a => ThreadManualMethod(10000)));
            thread2.Start();
            thread2.IsBackground = true;
            waithandle.WaitOne();
            MessageBox.Show("other handle has been done");
        }

        private static void ThreadManualMethod(int v)
        {
            Console.WriteLine("you need wait {0} on {1}", v / 1000, Thread.CurrentThread.ManagedThreadId);
            Thread.Sleep(v);
            waithandle.Set();
        }


        private static void ThreadMethod()
        {
            Thread thread = Thread.CurrentThread;
            Console.WriteLine("thread is {0},{1},Appdomain {2}, context {3}", thread.Name, thread.Priority,
                Thread.GetDomain().FriendlyName, Thread.CurrentContext.ContextID);

            Console.WriteLine("Main() invoked on thread {0}", Thread.CurrentThread.ManagedThreadId);
            //System.MulticastDelegate; 
            BinaryOp binaryOp = new BinaryOp(Add);
            IAsyncResult asyncResult = binaryOp.BeginInvoke(10, 10, new AsyncCallback(AddComplete), "this is the last rtn");
            while (!isDone)
            {
                Console.WriteLine("doing work in Main");
                Thread.Sleep(1000);
            }

            //int ans = binaryOp.EndInvoke(asyncResult);
            //Console.WriteLine("10 + 10 is {0}", ans); 

            Thread t = new Thread(new ParameterizedThreadStart(a => Add(1, 2)));
            t.Name = "newthread";
            t.Start();

            MessageBox.Show("I am busy...");
        }

        private static void AddComplete(IAsyncResult ar)
        {
            Console.WriteLine("AddComplete invoke on thread {0}", Thread.CurrentThread.ManagedThreadId);
            isDone = true;
            AsyncResult asyncResult = ar as AsyncResult;
            BinaryOp binaryOp = asyncResult.AsyncDelegate as BinaryOp;
            Console.WriteLine("10 + 10 is {0}, {1}", binaryOp.EndInvoke(ar), ar.AsyncState);
        }

        private static int Add(int x, int y)
        {
            Console.WriteLine("Main() invoked on thread {0}", Thread.CurrentThread.ManagedThreadId);
            Thread.Sleep(3000);
            return x + y;
        }


        private static void PrintNums()
        {
            Console.WriteLine("Your Num:");
            for (int i = 0; i < 10; i++)
            {
                Console.WriteLine("Your Num: {0}", i);
                Console.WriteLine("Your current thread id: {0}", Thread.CurrentThread.ManagedThreadId);
                Thread.Sleep(2000);
            }
        }

    }

  
}