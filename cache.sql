## Invocation 调用
调用一个函数将暂停当前函数的执行,传递控制权和参数给新函数.
实参与形参不一致不会导致运行时错误,多的被忽略,少的补为undefined
每个方法都会收到两个附加参数：this和arguments.this的值取决于调用的模式,调用模式：方法,函数,构造器和apply调用模式
this被赋值发生在被调用的时刻.不同的调用模式可以用call方法实现
`var myObject = {
    value: 0,
    increment: function (inc) {
        this.value += typeof inc === 'number' ? inc : 1;
    }
};
myObject.double = function(){
    var helper = function(){
        console.log(this);// this point to window
        }
    console.log(this);// this point to object myObject    
    helper();
}
myObject.double();//myObject  Window 
`
### 1 The Method Invocation Pattern 方法调用模式 
方法：函数被保存为对象的属性.当方法被调用时,this被绑定到该对象
公共方法：通过this取得他们所属对象的上下文的方法
`myObject.increment();
document.writeln(myObject.value);    // 1
底层实现： myObject.increment.call(myObject,0);`
### 2 The Function Invocation Pattern 函数调用模式
当函数并非对象的属性时就被当作函数调用（有点废话..）,this被绑定到全局对象（window）
ECMAScript5中新增strict mode, 在这种模式中,为了尽早的暴露出问题,方便调试.this被绑定为undefined
`var add = function (a,b) { return a + b;};
var sum = add（3,4）；// sum的值为7
底层实现：add.call（window,3,4）
        strict mode：add.call（undefined,3,4）`
方法调用模式和函数调用模式的区别
`function hello(thing) {
  console.log(this + " says hello " + thing);
}
person = { name: "Brendan Eich" }
person.hello = hello; 
person.hello("world") // [object Object] says hello world 等价于 person.hello.call（person,“world”）
hello("world") // "[object DOMWindow]world" 等价于 hello.call（window,“world”）`
### 3 The Constructor Invocation Pattern
JavaScript是基于原型继承的语言,同时提供了一套基于类的语言的对象构建语法.
this指向new返回的对象
`var Quo = function (string) {
    this.status = string;
}; 
Quo.prototype.get_status = function (  ) {
    return this.status;
};
var myQuo = new Quo("this is new quo"); //new容易漏写,有更优替换
myQuo.get_status(  );// this is new quo`
### 4 The Apply Invocation Pattern
apply和call是javascript的内置参数,都是立刻将this绑定到函数,前者参数是数组,后者要一个个的传递
apply也是由call底层实现的
`apply(this,arguments[]);
call(this,arg1,arg2...);
var person = {  
  name: "James Smith",
  hello: function(thing,thing2) {
    console.log(this.name + " says hello " + thing + thing2);
  }
}
person.hello.call({ name: "Jim Smith" },"world","!"); // output: "Jim Smith says hello world!"
var args = ["world","!"];
person.hello.apply({ name: "Jim Smith" },args); // output: "Jim Smith says hello world!"`
相对的,bind函数将绑定this到函数和调用函数分离开来,使得函数可以在一个特定的上下文中调用,尤其是事件
`bind的apply实现
Function.prototype.bind = function(ctx){
    var fn = this; //fn是绑定的function
    return function(){
        fn.apply(ctx, arguments);
    };
};
bind用于事件中
function MyObject(element) {
    this.elm = element;
    element.addEventListener('click', this.onClick.bind(this), false);
};
//this对象指向的是MyObject的实例
MyObject.prototype.onClick = function(e) { 
     var t=this;  //do something with [t]... 
};`

