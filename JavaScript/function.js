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
alert('now is valid');