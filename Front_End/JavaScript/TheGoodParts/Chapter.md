#JavaScript: The Good Parts


## 1. Good Parts
### Why？
JavaScript 是面向浏览器的语言，运行的环境是浏览器；操作的对象是HTML DOM（Document object type）的节点。 
### Good Parts：
#### 函数
    基于词法作用域的顶级对象，第一个成为主流的lambda语言。披着C外衣的Lisp
    词法作用域的函数中遇到既不是形参也不是函数内部定义的局部变量的变量时，去函数定义时的环境中查询。
    动态域的函数中遇到既不是形参也不是函数内部定义的局部变量的变量时，到函数调用时的环境中查。
#### 弱类型和动态对象
    编译器不能检测出类型错误，但也无须建立复杂的类层次
    弱类型语言：可以绕过类型系统
    动态类型：在程序运行时会将值分类，每种类型有对应的限制，有冲突时，在运行时报出动态类型错误
        静态类型有自己的类型系统，在运行前的编译阶段（通过解释器或编译器）进行校验
#### 对象字面量表示法 expressive object literal notation
    通过列出对象的组成部分，他们就能被创建出来。JSON的灵感
#### 原型继承
    无类别的对象系统， 对象直接从其他对象继承
### 坏的想法
#### 全局变量的编程模型
    依赖全局变量进行连接。所有编译单元的所有顶级变量及河道一个公共命名空间-全局对象
    全局变量：所有作用域中都可见的变量,这也意味着全局变量可以在任意时间被程序的任意部分改变。而且全局变量与子程序中变量名称互相冲突会导致程序无法运行。
        定义全局变量的3种方式：
            1， 函数外部的var语句：　var foo = value;
            2, web浏览器中，全局对象名为window： window.foo = value;
            3， 隐式的全局变量， 未经声明的变量: foo = value;

JSLint：编程工具，分析javascript并报告包含的缺点


## 2. Grammer 语法
### 1，WhiteSpace 空白
用来分隔字符序列
注释的形式： // ， /* */
### 2，Names 标志符 
以字符开头，后面加字符/数字/_，不能使用保留字
[letter][letter|digit|_]* - reserves letter
### 3，Numbers 数字
只有一个单一的数字类型，内部表示为64位浮点数
没有整数类型：1和1.0是一致的
NaN是一个数值，表示不能产生正常结果的运算结果，NaN不等于任何值，可以用isNaN检测
Infinity表示大于1.7976e+308的值
Math是一套javscript作用于数字的方法：Math.floor(8.7)=8
### 4，Strings 字符串
字符串被单引号或双引号包围，可包含0或多个字符。所有字符都是16位的，因为Unicode是16位的
没有Char类型，‘c’ = "c"
字符串一旦创建就不能改变，但可以通过‘+’连接得到一个新的字符串: ‘i’+"s"==='is'
### 5，Statements 语句
一个编译单元包含一组可执行的语句，每个script标签提供一个已编译且立即执行的编译单元。
因为缺少链接器，javascript将所有代码抛入一个公共的全局命名空间中
代码块：javascript中的代码块不会创建新的作用域，因此变量应该定义在函数的顶端
var用在函数内部时定义的变量是函数的私有变量，作用域为函数内部。
语句执行顺序，默认是顺序的
    条件语句： if 和 switch
    循环语句： while，for，do
    强制跳转语句： break， return， throw
    函数
    if（）then {} else {}
    为假的值：false，null，undefined，空字符串‘’，数字0，数字NaN。字符串‘false’也被当作真
        if (typeof varSample != undefined) then { ... }
    switch （）{ case: ...; break; ... default: ...; }
    while () {}
    do {}while()
    for(initialization;condition;increment) condition如果被省略则返回真
    for（myvar in obj）{if (obj.hasOwnProperty(myvar){...})} 枚举对象的所有属性名(键名)
    try{ }catch(){ }
    return 使一个函数提前返回，可以指定返回的值。如果没有指定，返回值是undefined
        不允许在return和表达式之间换行
    break 退出循环语句或switch语句。可以指定标签
    continue 退出当前循环语句，进入下一次循环
        cars=["BMW","Volvo","Saab","Ford"];
        list:
        {
            document.write(cars[0] + "<br>");
            document.write(cars[1] + "<br>");
            document.write(cars[2] + "<br>");
            break list;
            document.write(cars[3] + "<br>");
        }
### 6，Expressions 表达式
    包括： 字面量值（字符串或数字），变量，内置的值（true，false，null，undefined，NaN和Infinity）
            new和delete前导的表达式，函数调用，三目运算符
    运算符优先级： 操作符在没有圆括号的情况下决定其执行优先级的属性
        属性存取及函数调用 . [] () 
        一元运算符 delete new typeof + - ! 
        乘除，取模，加减 
        不等式运算符，等式运算符
        与，或，三元 && || ？：
### 7，Literals 字面量  
    字面量：直接量，用简单的字面值标记指向数字，字符串，数组，对象，函数等
    对象字面量：字面量名不是变量名，所以对象的属性在编译时才能知道。属性的值就是表达式
        var test = 'hello'; 
        test "hello";
        var testarr = ["arr1","arr2"];
        testarr[1] "arr2"
        var testobject = { o1: 'this is o1',fun: function () { return 'return form function'; } };
        testobject.fun  ƒ(){ return 'return form function'; };
        testobject.fun() "return form function"
### 8， Functions 函数
    函数字面量定义了函数值：函数名字，参数列表，函数主体（变量定义，语句）     


## 3 Objects 对象  
Javascript的简单类型：数字，字符串，布尔（true/false），null，undefined和对象(数组也是对象)。
对象是
    1. 可变的键控集合
    2. 是属性的容器，每个属性都拥有名字和值。名字可以是包含空字符串的任意字符串。只可以为除undefined的任意值
    3. 无类别的，对新属性的名字和值没有约束。适用于收集和管理数据。对象可以包含其他对象。
    4. 原型链特性，允许对象继承另一对象的属性
### 1，Object Literals 对象字面量
对象字面量是一种非常方便的创建新对象的表示法，本质上是一对包围在一对花括号中零或多个键/值对。
作用域等同于表达式
var student = {
    "first-name": 'song',
    first_name : 'song2'，
    "last-name": "ben",
    "age": 28，
    company：『
        name：‘ge’，
        strong：‘y’
    』
};
### 2，research 检索
检索不存在的成员元素得到undefined
|| 用来填充默认值
student【‘first-name’】；
‘name is ’||student。company。name；
检索undefined值导致TyoeError异常，用&&来避免错误
student【‘undefined’】//undefined
student【‘undefined’】&& student【‘undefined’】。anything//undefined
### 3， updates 更新
student【‘first-name’】=‘first-name’；
若属性名不存在则会被扩充到对象中
student【‘undefined’】= ‘nowdefined’；//nowdefined
### 4,reference 引用
对象通过引用传递，他们永远不会被拷贝
javascript按值传递，但当一个变量指向对象时，变量的值是这个指向对象的的地址
改变变量的值不会改变原始的基础类型或是object的值，只是将变量指向一个新的基础类型或是object
但是当变量指向对象的属性，改变变量值，就会改变对象的值
function f(a,b,c) {
    //基础类型按值传递，不会影响原始值，所以x还是4
    a = 3;
    //数组也是object，传进来的是原始值的地址，所以原始值也改变
    b.push("foo");
    // c指向z， 同数组，c是对象所以会直接改变传入的实参的值
    c.first = false;
}

var x = 4;
var y = ["eeny","miny","mo"];
var z = {first: true};
f(x,y,z);
console.log(x,y,z.first); // 4,["eeny","miny","mo","foo"],false

var a = ["1","2",{foo:"bar"}];
var b = a[1]; // 按值传递， b是"2";
var c = a[2]; // c是{foo:"bar"}
a[1] = "4";   // a is now ["1","4",{foo:"bar"}]; b仍是被声明时的值 2
a[2] = "5";   // a is now ["1","4","5"];  
console.log(b,c.foo); // "2" "bar"
b=13;
console.log(a); //["1","4","5"]


## 4 Functions 函数  
Javascript的函数包含一组语句，是基础模块单元，用于代码复用&信息隐藏&组合调用。
函数指定对象的行为。一般性的，编程就是将需求分解成一组函数与数据结构的技能。
### 1，Function Objects 函数对象
javascript中函数就是对象。对象=名/值对集合+连接到原型对象的隐藏连接
函数对象连接到Function。prototype（该原型本身连接到Object。prototype）。
函数对象创建时会设置一个‘调用’属性，调用函数可以理解为调用此函数的‘调用’属性
函数对象也有一个prototype属性，其值是拥有constructor属性的对象，该对象的值就是该函数。不同于Function。prototype
函数是对象，所以也可以被存放在变量，对象和数组中。函数也可以作为参数，可以返回函数，还可以拥有方法!与众不同之处是可以被调用
### 2， FunctionLiteral 函数字面量 
组成包括四个部分：保留字 function，函数名 可被省略，参数 逗号分隔，语句 包围在花括号中 是函数的主题
var add = function (a,b) { return a + b;};
通过函数字面量创建的函数对象包含一个连到外部上下文的连接，这被称为闭包
### 3,Invocation 调用
调用一个函数将暂停当前函数的执行，传递控制权和参数给新函数。
实参与形参不一致不会导致运行时错误，多的被忽略，少的补为undefined
每个方法都会收到两个附加参数：this和arguments。this的值取决于调用的模式，调用模式：方法，函数，构造器和apply调用模式
this被赋值发生在被调用的时刻。不同的调用模式可以用call方法实现
var myObject = {
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

### 3。1 The Method Invocation Pattern 方法调用模式 
方法：函数被保存为对象的属性.当方法被调用时，this被绑定到该对象
公共方法：通过this取得他们所属对象的上下文的方法
myObject.increment();
document.writeln(myObject.value);    // 1
底层实现： myObject.increment。call(myObject，0);
### 3.2 The Function Invocation Pattern 函数调用模式
当函数并非对象的属性时就被当作函数调用（有点废话。。），this被绑定到全局对象（window）
ECMAScript5中新增strict mode， 在这种模式中，为了尽早的暴露出问题，方便调试。this被绑定为undefined
var add = function (a,b) { return a + b;};
var sum = add（3，4）；// sum的值为7
底层实现：add。call（window，3，4）
        strict mode：add。call（undefined，3，4）
方法调用模式和函数调用模式的区别
function hello(thing) {
  console.log(this + " says hello " + thing);
}
person = { name: "Brendan Eich" }
person.hello = hello; 
person.hello("world") // [object Object] says hello world 等价于 person。hello。call（person，“world”）
hello("world") // "[object DOMWindow]world" 等价于 hello。call（window，“world”）
### 3.3 The Constructor Invocation Pattern
JavaScript是基于原型继承的语言，同时提供了一套基于类的语言的对象构建语法。
this指向new返回的对象
var Quo = function (string) {
    this.status = string;
}; 
Quo.prototype.get_status = function (  ) {
    return this.status;
};
var myQuo = new Quo("this is new quo"); //new容易漏写，有更优替换
myQuo.get_status(  );// this is new quo
### 3.4 The Apply Invocation Pattern
apply和call是javascript的内置参数，都是立刻将this绑定到函数,前者参数是数组，后者要一个个的传递
apply也是由call底层实现的
apply(this,arguments[]);
call(this,arg1,arg2...);
var person = {  
  name: "James Smith",
  hello: function(thing,thing2) {
    console.log(this.name + " says hello " + thing + thing2);
  }
}
person.hello.call({ name: "Jim Smith" },"world","!"); // output: "Jim Smith says hello world!"
var args = ["world","!"];
person.hello.apply({ name: "Jim Smith" },args); // output: "Jim Smith says hello world!"
相对的bind函数将绑定this到函数和调用函数分离开来，使得函数可以在一个特定的上下文中调用，尤其是事件
bind的apply实现
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
};
### 4 Arguments 参数
函数被调用时会附加一个参数arguments，通过它可以访问函数被调用时传递的参数列表，包括多余的参数.
arguments并不是真正的数组，是类似数组的对象。有length属性，但没有所有的数组方法
var sum = function() {
	let i,sum =0;
	for(i=0;i<arguments.length;i++){
	sum += arguments[i];	
}
return sum;
} 
document.writeln(sum(1,23,4,2,3,4,2,3,4543))//4585
### 5 Return 返回
函数被调用时，从第一个语句开始执行到}结束，将控制权交还给函数的调用部分。
return会立即交还给函数的调用部分
函数总会返回值，默认是undefined
以new方式调用的函数，若返回值不是对象，则返回this（新对象）
### 6 Exception 异常
throw语句中断函数的执行，抛出exception对象。该对象包含可识别异常类型的属性：name和message，及自定义属性
try代码块中抛出异常，则恐是全就跳转到catch从句
var add = function(a,b){
    if(typeof a != 'number' ||typeof b != 'number')
        throw {
            name : 'TypeError',
            message: 'add needs number'
        };

        return a+b;
}

var tryit = function(){
    try{
        add('ss');
    }catch(e){
        document.writeln(e.name + ':' + e.message);
    }
}
tryit();//TypeError:add needs number
### 7 Augmenting Types给类型增加方法
Javascript允许给基本类型增加方法。
for in语句在原型时表现很糟糕，可以用hasOwnProperty属性筛选出继承而来的属性
Function.prototype增加方法使得是对所有函数可用.通过给Function。prototype增加method方法，我们就不用键入prototype这个属性名
Function.prototype.method = function (name, func){
	if(!this.prototype[name]){
		this.prototype[name] = func;
	}
}
整数类型的取整函数
Number.method('integer', function (  ) {
    return Math[this < 0 ? 'ceil' : 'floor'](this);
});
document.writeln((-10 / 3).integer(  ));  // −3 
字符串去掉空白
String.method('trim',function(){
	return this.replace(/^\s+|\s+$/g,'');
})
document.writeln("begin."+"   3space3   ".trim()+"end");//begin.3space3end
### 8 Recursion 递归
递归函数是直接或间接的调用自身的一种函数.递归，将一个问题分解为一组相似的子问题，每个子问题用一个寻常解去解决。
递归函数可以非常高效的操作树形结构。
var walkTheDOM = function walk(node,func){
	func(node);
	node = node.firstChild;
	while(node){
	walk(node,func);
	node = node.nextSibling;	
}
}; 
var getElementsByAttribute = function(att, value){
var results = [];
walkTheDOM(document.body,function(node){
	var actual = node.nodeType === 1 && node.getAttribute(att);
	if(typeof actual === 'string' && (actual === value || typeof value !== 'string')){
		results.push(node);
	}
});
return results;
}