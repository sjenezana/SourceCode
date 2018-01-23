'use strict';

// alert("this is function.js");
console.log("now this is standardobject.js !!!");


//JavaScript用typeof操作符获取对象的类型
//number, boolean, string, function, undefined
//判断Array Array.isArray(arr);
//判断null  myVar === null
//判断全局变量是否存在 typeof window.myVar === 'undefined'
//判断局部变量是否存在 typeof myVar === 'undefined'
//toString() null,undefined没有此方法
console.log('123 is ' + typeof 123); // 'number'
console.log('NaN is ' + typeof NaN); // 'number'
console.log('\'str\' is ' + typeof 'str'); // 'string'
console.log('true is ' + typeof true); // 'boolean'
console.log('undefined is ' + typeof undefined); // 'undefined'
console.log('Math.abs is ' + typeof Math.abs); // 'function'
console.log('null is ' + typeof null); // 'object'
console.log('[] is ' + typeof []); // 'object'
console.log('{} is ' + typeof {}); // 'object'

//包装对象 new Number/String/Boolean(); 1, New. 2, 首字母大写
console.log('new Number(123) is ' + typeof new Number(123)); // 'object' 
console.log('new string(\'str\') is ' + typeof new String('str')); // 'object'
console.log('new Boolean(true) is ' + typeof new Boolean(true)); // 'object'
//包装对象会重新分配内存,不要乱用包装对象
console.log("new String('str') === 'str' is ");
console.log(new String('str') === 'str'); // fasle

//parseInt,parseFloat/String/Boolean()三个函数只是将数据转化为对应的number,string,boolean
console.log('parseInt(123) is ' + typeof parseInt(123)); // 'number' 
console.log('string(\'str\') is ' + typeof String('str')); // 'string'
console.log('Boolean(true) is ' + typeof Boolean(true)); // 'boolean'

var myVar = 'window var';
console.log($'{window.myVar is not exists? ' + typeof window.myVar === 'undefined');
console.log('myVar is not exists? ' + typeof myVar1 === 'undefined');