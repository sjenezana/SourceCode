## DOM(Document of Model)
文档对象类型用树形结构完整的呈现了html文档,包括元素之间的关系和组成元素的内容及属性

### 浏览器如何处理html文档: how browser handle html document
    received html: server respoend with html no matter what it received.
    html tags are converted to tokens
    tokens are converted to nodes:令牌被转换成树节点
    nodes are converted to the Dom 


### 按id返回页面单一元素
#### document.getElementById('footer')
    Dom中id是唯一的,所以个通过id值返回一个唯一的对象.
    id字符串区分大小写
    返回查找元素的所有子节点


### 一次返回多个元素
#### document.getElementByClassName('classname');
返回所有包含此classname的htmlCollection
document.getElementsByClassName('line-numbers language-html')
多个classname以空格符分隔
rootElement.getElementsByClassName('classname');
可以被任何的根元素调用

#### document.getElementsByTagName('tagname');
返回所有指定标签名tag的htmlCollection,
只有后代元素会被搜索
标签名应使用小写
document.getElementById("toc").getElementsByTagName("*")
可以被任何根元素调用,* 返回所有元素


### Nodes,Elements and Interfaces
[Node](https://developer.mozilla.org/en-US/docs/Web/API/Node)是类,继承自EventTarget,是树结构的中间节点,包含实例node的所有属性和方法
[Element]()是类,继承自Node,是树结构的根节点,同样是Node,但是element实例具有具体属性和方法
JavaScript Interface主要指[Web APIs](https://developer.mozilla.org/en-US/docs/Web/API)
!##### Note: $0 默认指代页面上选中的元素

### more way to access element 
#### .querySelector() - returns a single element
// find and return the element with an ID of "header"
document.querySelector('#header');
// find and return the first element with the class "header"
document.querySelector('.header');
// find and return the first <header> element
document.querySelector('header');

#### .querySelectorAll() - returns a list of elements
// find and return the element with an ID of "header"
document.querySelector('#header');
// find and return a list of elements with the class "header"
document.querySelectorAll('.header');

const allHeaders = document.querySelectorAll('header');
for(let i = 0; i < allHeaders; i++){
    console.dir(allHeaders[i]);
}




## JavaScrip创建内容:增,删,改DOM节点

### 更新已存在的页面内容
####　innerhtml 返回子节点的html code
.innerhtml:
返回当前选中元素所有子元素的html内容,返回值是string
设置元素的html内容
.outerhtml:
返回当前选中元素,及其所有子元素的html内容
<h1 id="pick-me">Greetings To <span>All</span>!</h1>
const innerResults = document.querySelector('#pick-me').innerHTML;
console.log(innerResults); // logs the string: "Greetings To <span>All</span>!"
const outerResults = document.querySelector('#pick-me').outerHTML;
console.log(outerResults); // logs the string: "<h1 id="pick-me">Greetings To <span>All</span>!</h1>"

#### textContent 返回节点所有未经css修饰的文本内容
.textContent
返回当前选中元素及其子元素的文本内容,返回值是string或null
设置文本内容,html标签作为文本被显示
myElement.textContent = 'The <strong>Greatest</strong> Ice Cream Flavors'; // doesn't work as expected
myElement.innerHTML = 'The <strong>Greatest</strong> Ice Cream Flavors';  // works as expected
#### innerText 返回页面呈现的文本内容
.innerText
返回页面显示的文本内容,行内css和html标签不会显示
设置元素的显示文本内容,其中的css样式和html标签不会进行渲染,会被显示出来

### 新增页面内容 add new page content
#### createElement 
根据html标签创建元素,调用对象是document,所以并不会添加新创建的元素到页面(DOM)中
// creates and returns a <span> element
var newspan = document.createElement('span');
newspan.innerhtml = '<em> this is a new span string </em>';
#### appendChild
发起调用的必须是一个具体的元素,新的元素将被追加到调用元素的最后一个子元素
h1element=document.querySelector('h1');
h1element.appendChild(newspan);
##### Note: 
1. 更新文本内容来说,与其新增元素并追加不如直接更新已有元素的textContent属性
2. 新建的元素只能被追加一次
    const mainHeading = document.querySelector('#main-heading');//123
    const otherHeading = document.querySelector('#other-heading');//456
    const excitedText = document.createElement('span');
    excitedText.textContent = '!!!';
    mainHeading.appendChild(excitedText);//123
    otherHeading.appendChild(excitedText);//456!!!
#### insertAdjacentHTML
element.insertAdjacentHTML(position, text);
解析text字符串为html或xml节点,然后插入到调用元素的指定位置
position的可视化示例:   <!-- beforebegin --><p><!-- afterbegin -->foo
                        <!-- beforeend --></p><!-- afterend -->
var h1element = document.querySelector('h1');
//"<h1 class="white mb-half" style="">Learn ARKit</h1>"
h1element.insertAdjacentHTML("afterbegin",'<div>asdfasd</div>');
//"<h1 class="white mb-half" style=""><div>asdfasd</div>Learn ARKit</h1>"

### 删除页面内容
#### removeChild
var oldChild = node.removeChild(child);
父元素node删除其子元素child
oldChild指向被删除的子元素child,child不再DOM中.
如果没有oldChild引用,则仍会存在内存中一段时间,最终会自动删除
#### remove
node.remove();
从node的父元素中删除node
等价于: node.parentElement.removeChild(node);

ParentNode.firstElementChild
返回父元素的第一个子元素
ParentNode.firstChild
如果有,则返回空白符或回车符

### 样式页面内容 style page content
#### .style.<prop> 一次只能修改一个css样式属性
document.querySelector('h1').style.color = 'red'

CSS优先级 CSS specificity
拥有最高级别的css属性将被应用,样式规则距离元素越近,级别就越高.
样式表中的样式<style> < 具体元素中的style
样式表中的优先级别:类型选择器(h1)和伪元素(h1:before) 
< 类选择器(.example),属性选择器(type=“radio”)和伪类(img:hover) < ID选择器(#example)
##### Note: !important修饰的样式拥有最最高级别,核武器慎用
#### .cssText() 一次可以更新多个样式属性
Note:csstext将会覆盖原有的样式属性
设置的字符串必须与样式表中的css样式一致
const mainHeading = document.querySelector('h1');
mainHeading.style.cssText = 'color: blue; background-color: orange; font-size: 3.5em';

#### .setAttribute() 一次可以设置多个样式属性
还可以设置非样式属性,例如 ID
document.querySelectorAll('h6')[4].setAttribute('id','index4ofh6');
//document.querySelectorAll('h6')[4].setAttribute('id','index4ofh6')
document.querySelector('#index4ofh6').setAttribute('style','color: red; font-size:2em;')
//document.querySelector('#index4ofh6').setAttribute('style','color: red; font-size:2em;')
#### .className
var cName = elementNodeReference.className;
获取指定元素的类的字符串
elementNodeReference.className = cName;
设置元素类,会覆盖掉原有的类的值
var listOfClasses = document.querySelector('#main-heading');// large white
操作数组:
const arrayOfClasses = listOfClasses.split(' ');//(2) ["large", "white"]
arrayOfClasses.push("white2"); //3
for(let i=0; i < arrayOfClasses.length; i++){ console.log(arrayOfClasses[i]);};//large white white2
arrayOfClasses.pop("white2"); //white2
#### .classList
const elementClasses = elementNodeReference.classList;
将元素的类的信息以DOMTokenList数据结构返回
DOMTokenList结构有自己的默认方法:
add( String [, String [, ...]] ), remove( String [, String [, ...]] ) 要删除的类不存在则报错
item( Number ), contains( String ), replace( oldClass, newClass )
toggle( String [, force] ) 如果类存在则删除,不存在则增加;若第二个参数存在,根据其bool值进行增删
document.querySelector('h6.text-center').classList
//DOMTokenList ["text-center", value: "text-center"]
document.querySelector('h6.text-center').classList.toggle('example')//true
//DOMTokenList(2) ["text-center", "example", value: "text-center example"]