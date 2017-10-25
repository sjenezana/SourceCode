using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using ConsoleApp;

namespace ClassLibrary1
{
    public class Class1
    {
        Person person = new Person();

        Car car = new Car();

        // 'Point' is inaccessible due to its protection level  -- assembly
        //Point point = new ConsoleApp.Point();
    }
}
