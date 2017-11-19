'use strict'; // without var lead to an error showed console in browser

// alert("this is file base.js");
console.log("now this is function.js !!!");

//annotation
/* document annotation*/
//judgement
var age = 15;
if (age > 18)
    console.log('adult');
else
    console.log(` teenager 
            is 
            multiline and age is ${age}`);

var i = 10;
var msg = "this is a test string with 'quote' and \"Double \"";
msg.toLowerCase();
console.log(msg.toUpperCase());
console.log(msg.indexOf("'"));
console.log(msg.substring(0, 6));
console.log(msg.slice(0, 6));


// object
var student = {
    name: "xiaoming",
    birth: 1999,
    weight: 88
}
student.weight = 66;
if (student.hasOwnProperty('name'))
    console.log(student.name);

//loop statement
/*
当前Array实例支持的一些运算方法属性
for...in会遍历对象proto以上能直接看到的属性
所以如果不确定iterable对象是否仅仅包含需要遍历的属性
最好还是用forEach,for...of,或者while这些*/

for (var temp in student)
    console.log(temp + ': ' + student[temp]);
console.log(JSON.stringify(student));

//{}  可视为其他语言中的Map/Dictionary
var m = new Map();//键值对
var s = new Set();//key的集合但是不存储value。且key值不重复

//iterable 
s = [1, 2, 3];
for (var temp of s)
    console.log(temp);

