using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters.Binary;
using System.Runtime.Serialization.Formatters.Soap;
using System.Text;
using System.Xml.Serialization;

namespace ClassLibraryforCSharp
{
    class Program20
    {
        static void Main20(string[] args)
        {
            Console.WriteLine("Hello world!");
            //SystemIOMethod();

            //FileSystemWatcherMethod();

            SerializableAttributeMethod();
            Console.ReadLine();
        }

        private static void SerializableAttributeMethod()
        {
            User user = new User { Name = "tom", Gender = "man" };
            System.Runtime.Serialization.Formatters.Binary.BinaryFormatter binaryFormatter = new BinaryFormatter();
            System.Runtime.Serialization.Formatters.Soap.SoapFormatter soapFormatter = new SoapFormatter();
            System.Xml.Serialization.XmlSerializer xmlSerializer = new XmlSerializer(typeof(User));

            List<User> users = new List<User>();
            users.AddRange(new List<User> { new User { Name = "name1", Gender = "man" },
                new User { Name = "name2", Gender = "man" }, new User { Name = "name3", Gender = "woman" } });
            XmlSerializer xmlSerializers = new XmlSerializer(typeof(List<User>));
            using (Stream fs = new FileStream("user.txt", FileMode.OpenOrCreate, FileAccess.ReadWrite, FileShare.None))
                xmlSerializers.Serialize(fs, users);
        }

        private static void FileSystemWatcherMethod()
        {
            FileSystemWatcher fileSystemWatcher = new FileSystemWatcher();
            fileSystemWatcher.Path = @"d:\testc#";
            fileSystemWatcher.NotifyFilter = NotifyFilters.LastAccess | NotifyFilters.LastWrite | NotifyFilters.FileName |
                NotifyFilters.DirectoryName;
            fileSystemWatcher.Filter = "*.txt";

            fileSystemWatcher.Created += new FileSystemEventHandler(change2);
            fileSystemWatcher.Changed += new FileSystemEventHandler(change2);
            fileSystemWatcher.Deleted += new FileSystemEventHandler(change2);
            fileSystemWatcher.Renamed += new RenamedEventHandler(change);

            fileSystemWatcher.EnableRaisingEvents = true;

        }

        private static void change(object sender, RenamedEventArgs e)
        {
            Console.WriteLine($" origin path is {e.OldFullPath}, now is {e.FullPath}");
        }

        private static void change2(object sender, FileSystemEventArgs e)
        {
            Console.WriteLine($"name is {e.Name},full path is {e.FullPath}, change type {e.ChangeType}");
        }

        private static void SystemIOMethod()
        {

            ShowDirectoryInfo();

            ShowDriveInfo();

            ShowFileInfo();

        }

        private static void ShowFileInfo()
        {
            //static
            //File.Delete("");//Directory
            ////class instance
            FileInfo fileInfo = new FileInfo(@"d:\testc#\test.txt");//DirectoryInfo
            using (FileStream fs = fileInfo.Open(FileMode.OpenOrCreate, FileAccess.ReadWrite))
                fs.Write(Encoding.Unicode.GetBytes("this is file info"), 0, Encoding.Unicode.GetBytes("this is file info").Length);
            using (FileStream fs = fileInfo.Open(FileMode.OpenOrCreate, FileAccess.ReadWrite))
            {
                byte[] bytes = new byte[1024];
                while (fs.Read(bytes, 0, bytes.Length) > 0)
                    Console.WriteLine($"text already exist: {Encoding.Unicode.GetString(bytes)}");
            }

            string streamFile = @"d:\testc#\stream.txt";
            using (StreamWriter streamwt = File.CreateText(streamFile))
            {
                streamwt.WriteLine("this is a stream text");
                streamwt.WriteLine("nums:");
                for (int i = 0; i < 10; i++)
                    streamwt.WriteLine($"num is {i}");
            }

            using (StreamReader sr = new StreamReader(streamFile))
            {
                string input = null;
                while ((input = sr.ReadLine()) != null)
                    Console.WriteLine(input);
            }

            using (StringWriter sw = new StringWriter())
            {
                sw.WriteLine("this is write by stringwriter");
                Console.WriteLine($" now is {sw}");
                StringBuilder stringBuilder = sw.GetStringBuilder();
                stringBuilder.Insert(0, " hi , ");
                Console.WriteLine($" now is {sw}");

                using (StringReader sr = new StringReader(stringBuilder.ToString()))
                {
                    string input;
                    while ((input = sr.ReadLine()) != null)
                        Console.WriteLine(input);
                }
            }
            string strfile = @"d:\testc#\test2.txt";
            using (BinaryWriter bw = new BinaryWriter(File.OpenWrite(strfile)))
            {
                Console.WriteLine($"base stream is {bw.BaseStream}");
                int i = 123;
                string str = @"this";

                bw.Write(i);
                bw.Write(str);
            }
            using (BinaryReader bw = new BinaryReader(File.Open(strfile, FileMode.Open)))
            {
                Console.WriteLine($"binary reader is {bw.ReadInt32()}");
                Console.WriteLine($"binary reader is {bw.ReadString()}");
            }

        }

        private static void ShowDriveInfo()
        {
            var mydrives = DriveInfo.GetDrives();

            foreach (DriveInfo d in mydrives)
            {
                Console.WriteLine($"drive name is {d.Name}");
                Console.WriteLine($"drive DriveType is {d.DriveType}");
                if (d.IsReady)
                {
                    Console.WriteLine($"drive VolumeLabel is {d.VolumeLabel}");
                    Console.WriteLine($"drive DriveFormat is {d.DriveFormat}");
                }

            }

        }

        private static void ShowDirectoryInfo()
        {
            DirectoryInfo directoryInfo = new DirectoryInfo(@"d:\testc#");
            if (!directoryInfo.Exists)
                directoryInfo.Create();
            DirectoryInfo dirsub = directoryInfo.CreateSubdirectory(@"myfolder\data");

            Console.WriteLine($"fullname is {dirsub.FullName}");
            Console.WriteLine($"name is {dirsub.Name}");
            Console.WriteLine($"CreationTime is {dirsub.CreationTime}");
            Console.WriteLine($"path is {dirsub.Root}-{dirsub.Parent}");

            if (Directory.Exists(@"d:\testc#\myfolder\data"))
                Directory.Delete(@"d:\testc#\myfolder\data");
        }
    }

    [Serializable]
    public class User : ISerializable
    {
        public string Name { set; get; }
        public string Gender { set; get; }

        public User() { }
        public void GetObjectData(SerializationInfo info, StreamingContext context)
        {

        }
    }

}