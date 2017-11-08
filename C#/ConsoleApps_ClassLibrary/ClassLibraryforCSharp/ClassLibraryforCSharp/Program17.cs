using System;
using System.Diagnostics;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Threading;

namespace ClassLibraryforCSharp
{
    class Program17
    {

        static void Main17(string[] args)
        {
            Console.WriteLine("Hello world!");

            //ProcessMethod();

            //AppDomainMethod();

            ContextBoundObjectMethod();
              
            Console.ReadLine();

        }

        private static void ContextBoundObjectMethod()
        {
            Console.WriteLine("ContextBoundObjectMethod...");

            SportsCar sc = new SportsCar();
            Console.WriteLine();

            SportsCar sc2 = new SportsCar();
            Console.WriteLine();

            SportsCar sc3 = new SportsCar();
            Console.WriteLine();

            SportsCarTS sct = new SportsCarTS();
            Console.WriteLine(); 

            SportsCarTS sct2 = new SportsCarTS();
            Console.WriteLine();

            SportsCarTS sct3 = new SportsCarTS();
            Console.WriteLine();
        }

        private static void AppDomainMethod()
        {
            AppDomain appD = AppDomain.CurrentDomain;
            Console.WriteLine("AppDomain FriendlyName is {0}, BaseDirectory is {1} ", appD.FriendlyName, appD.BaseDirectory);

            appD.AssemblyLoad += (sender, o) =>
             {
                 Console.WriteLine(" loaded assembly {0}", o.LoadedAssembly.GetName().Name);
             };

            ListAllAssembly(appD);
            // make new appdomain
            AppDomain newad = AppDomain.CreateDomain("secondAppdomain");
            ListAllAssembly(newad);
            newad.Load("Car");
            ListAllAssembly(newad);
            AppDomain.Unload(newad);
        }

        private static void ListAllAssembly(AppDomain appDomain)
        {
            var assembly = from domains in appDomain.GetAssemblies() orderby domains.GetName().Name select domains;
            foreach (var a in assembly)
                Console.WriteLine("Name is {0}, Version is {1}, ", a.GetName().Name, a.GetName().Version);
        }

        private static void ProcessMethod()
        {
            Process process = Process.GetCurrentProcess();
            Console.WriteLine("current Processid {1}, name {0}", process.ProcessName.ToString(), process.Id.ToString());
            ProcessThreadCollection threadCollection = process.Threads;
            foreach (ProcessThread t in threadCollection)
                Console.WriteLine("PID is {0}, StartTime is {1}, Site is {2}, PriorityLevel is {3}", t.Id, t.StartTime.ToShortDateString(), t.Site, t.PriorityLevel);

            foreach (ProcessModule m in process.Modules)
                Console.WriteLine("ModuleName is {0}, Container is {1} ", m.ModuleName, m.Container);

            var runProcs = from proc in Process.GetProcesses(".") orderby proc.Id select proc;
            foreach (var p in runProcs)
                Console.WriteLine("PID is {0}, Name is {1}", p.Id, p.ProcessName);

            try
            {
                Process processie = Process.Start("IExplore.exe", "www.baidu.com");
                Console.Write("Enter to kill IE browser");
                Console.ReadLine();
                processie.Kill();
                ProcessStartInfo processStartInfo = new ProcessStartInfo("IExplore.exe", "www.baidu.com");
                processStartInfo.WindowStyle = ProcessWindowStyle.Maximized;
                processie = Process.Start(processStartInfo);
                Console.Write("Enter to kill IE browser");
                Console.ReadLine();
                processie.Kill();

            }
            catch (Exception e) { }
        }

    }
    [Synchronization]
    internal class SportsCarTS : ContextBoundObject
    {
        public SportsCarTS()
        {
            Context context = Thread.CurrentContext;
            Console.WriteLine("object {0} is context {1}", this.ToString(), context.ContextID.ToString());
            foreach (var v in context.ContextProperties)
                Console.WriteLine("context pro is {0}", v.Name);
        }
    }

    [Synchronization]
    internal class SportsCar
    {
        public SportsCar()
        {
            Context context = Thread.CurrentContext;
            Console.WriteLine("object {0} is context {1}", this.ToString(), context.ContextID.ToString());
            foreach (var v in context.ContextProperties)
                Console.WriteLine("context pro is {0}", v.Name);
        }
    }
}