'use strict';

// alert("this is function.js");
console.log("now this is function.js !!!");
//define
function abs(x) {
    if (x >= 0)
        return x;
    else
        return -x;
}

console.log(abs(-5));
console.log(abs());

//arguments 作用域是函数内部，永远指向当前函数调用者传入的所有参数
function foo(x) {
    console.log(x);
    console.log(JSON.stringify(arguments))
}

foo(10, 2, 30);

//...rest只能位于参数最后，会收到一个数组，并取得所有未显式接收的参数
//return和返回的语句必须在同一行，JavaScript引擎会在行末自动添加分号
function sum(a, b, ...rest) {
    console.log(rest);
    var sum = 0;//需要付初值
    for (var temp of rest)
        sum += temp;
    sum = sum + a + b;
    return sum;
}

console.log(sum(1, 2.3, 1, 2, 31, 23));

//var 声明的变量有作用域， 'use strict';用来限制变量必须用var声明
//JavaScript会扫描所有函数体语句，把所有变量的声明提升到函数顶部，但是变量赋值位置不会变化
function foo() {
    var sum = 1; //名称一致但是作用域不同，不会出错
    var name;
    var x = "hello " + name;
    console.log(x);
    name = 'Jack';
}
window.foo();

//window: JavaScript默认的全局对象，全局作用域的变量实际上绑定为window的一个属性
var course = 'Learn JavaScript';
console.log(window.course);
var _alert = window.alert;
window.alert = function () { }
alert('now is invalid');
window.alert = _alert;//
// alert('now is valid');


//名字空间
var MYAPP = {};
MYAPP.name = 'myapp';
MYAPP.version = 1.0;
MYAPP.foo = function () {
    return 'MYAPP.foo';
}

//局部作用域
//for无法定义有局部作用域的变量，但let可以声明会计作用域的变量
function foo() {
    var x = 1;
    if (true) {
        var x = 2; console.log(x);
    }
    console.log(x);
}
function foo() {
    var x = 1;
    if (true) {
        let x = 2; console.log(x);
    }
    console.log(x);
}

//常量 大写 const
const PI = 3.14;
//MYPI = 3.1415926; //error
//PI = 3;//error
// MYPI = 3;//error
const CONARY = [];
CONARY.push('A');
console.log(CONARY[0]);
CONARY[0] = 'C';
console.log(CONARY[0]);
// CONARY = 'D';//error

//解构赋值
var employee = {
    name: "Jim",
    age: 90,
    gender: 'man',
    school: {
        city: 'tsing',
        school_name: 'school_name',
    }
};
var { name, gender, other = 'others', school: { school_name } } = employee;
//school 不是变量，只是为了构造合适的结构
console.log(name + ", " + gender + ", " + other + ", " + school_name);

//方法
//this在函数内部时，以对象的方法形式调用时指向被调用的对象；但单独调用时指向全局变量，window
//解决，var that=this; 必须用object.fun()形式调用；fun.apply(object,[paras]);
function getAge() {
    var y = new Date().getFullYear();
    return y - this.birth;
}
var Jim = {
    name: 'Jim',
    birth: 1990,
    age: getAge
}
console.log(getAge.apply(Jim, []));
console.log(Jim.age());
// console.log(getAge()); //Uncaught TypeError strict模式下让函数的this指向undefined
var Jack = {
    name: 'Jack',
    birth: 1990,
    age: function () {
        var that = this;
        function getBirth() {
            var y = new Date().getFullYear();
            return y - that.birth;
        }
        return getBirth();
    }
}
console.log('var that = this; ' + Jack.age());

//decorator
var count =  0;
var oldParseInt = parseInt;
window.




// var x =10;
// function test(){
//      console.log(a);
//      console.log(aa());
//      var a =1 ;
//      function aa(){
//          return 4;
//      }
// }
// test();