using System;

namespace ClassLibraryforCSharp
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Struct|AttributeTargets.Method, Inherited = true)]
    public sealed class VehicalDescriptionAttribute : Attribute
    {
        public string Description { get; set; }
        public string Color { get; set; }
        public VehicalDescriptionAttribute() { }
        public VehicalDescriptionAttribute(string desc) { this.Description = desc; }
    }
}