function addLoadEvent(func) {
    let oldonload = window.onload;
    if (typeof window.onload != 'function')
        window.onload = func();
    else
        window.onload = function () {
            oldonload();
            func();
        };

}

function insertAfter(newElement, targetElement) {
    let parent = targetElement.parenet;
    if (parent.lastChild == targetElement)
        targetElement.appendChild(newElement);
    else
        parent.insertBefore(newElement, targetElement.nextSibling);
}

function addClass(element, value) {
    if (!element.className) element.className = value;
    else element.className = element.className + ' ' + value;
}

function highlightPage() {
    if (!document.getElementsByTagName || !document.getElementById) return false;
    let headers = document.getElementsByTagName('header');
    if (headers.length <= 0) return false;
    let links = headers[0].getElementsByTagName('nav')[0].getElementsByTagName('a');
    for (let i = 0; i < links.length; i++) {
        if (window.location.href.indexOf(links[i].getAttribute("href")) != -1) {
            links[i].className = "here";
            document.body.setAttribute("id", links[i].lastChild.nodeValue.toLowerCase());
        }
    }
}
addLoadEvent(highlightPage);

function moveElement(elementID, fx, fy, interval) {
    if (!document.getElementById || !document.getElementById(elementID)) return false;
    let ele = document.getElementById(elementID);
    if (ele.movement) clearTimeout(ele.movement);

    if (!ele.style.left) ele.style.left = "0px";
    if (!ele.style.top) ele.style.top = "0px";

    let px = parseInt(ele.style.left);
    let py = parseInt(ele.style.top);

    if (px == fx && py == fy) return true;

    if (px < fx) px = px + Math.ceil((fx - px) / 10);
    if (px > fx) px = px - Math.ceil((px - fx) / 10);
    if (py < fy) py = py + Math.ceil((fy - py) / 10);
    if (py > fy) py = py - Math.ceil((py - fy) / 10);

    ele.style.left = px + "px";
    ele.style.top = py + "px";

    let repeat = "movement()";
}

function addLoadEvent(func) {
    let oldonload = window.onload;
    if (typeof window.onload != 'function')
        window.onload = func();
    else
        window.onload = function () {
            oldonload();
            func();
        };

}

function insertAfter(newElement, targetElement) {
    let parent = targetElement.parentNode;
    if (parent.lastChild == targetElement)
        targetElement.appendChild(newElement);
    else
        parent.insertBefore(newElement, targetElement.nextSibling);
}

function addClass(element, value) {
    if (!element.className) element.className = value;
    else element.className = element.className + ' ' + value;
}

//home
function highlightPage() {
    if (!document.getElementsByTagName || !document.getElementById) return false;
    let headers = document.getElementsByTagName('header');
    if (headers.length <= 0) return false;
    let links = headers[0].getElementsByTagName('nav')[0].getElementsByTagName('a');
    for (let i = 0; i < links.length; i++) {
        if (window.location.href.indexOf(links[i].getAttribute("href")) != -1) {
            links[i].className = "here";
            document.body.setAttribute("id", links[i].lastChild.nodeValue.toLowerCase());
        }
    }
}
addLoadEvent(highlightPage);

function moveElement(elementID, fx, fy, interval) {
    if (!document.getElementById || !document.getElementById(elementID)) return false;
    let ele = document.getElementById(elementID);
    if (ele.movement) clearTimeout(ele.movement);

    if (!ele.style.left) ele.style.left = "0px";
    if (!ele.style.top) ele.style.top = "0px";

    let px = parseInt(ele.style.left);
    let py = parseInt(ele.style.top);

    if (px == fx && py == fy) return true;

    if (px < fx) px = px + Math.ceil((fx - px) / 10);
    if (px > fx) px = px - Math.ceil((px - fx) / 10);
    if (py < fy) py = py + Math.ceil((fy - py) / 10);
    if (py > fy) py = py - Math.ceil((py - fy) / 10);

    ele.style.left = px + "px";
    ele.style.top = py + "px";

    let repeat = "moveElement('" + elementID + "'," + fx + "," + fy + "," + interval + ")";
    ele.movement = setTimeout(repeat, interval);
}

function prepareSlideShow() {
    if (!document.getElementById("intro")) return false;
    let intro = document.getElementById("intro");
    let slideshow = document.createElement("div");
    slideshow.setAttribute("id", "slideshow");
    let frame = document.createElement("img");
    frame.setAttribute("src", "images/frame.gif");
    frame.setAttribute("alt", "");
    frame.setAttribute("id", "frame");
    slideshow.appendChild(frame);

    let preview = document.createElement("img");
    preview.setAttribute("src", "images/slideshow.gif");
    preview.setAttribute("alt", "glimpse slide show");
    preview.setAttribute("id", "preview");
    slideshow.appendChild(preview);
    insertAfter(slideshow, intro);
    let links = document.getElementsByTagName("a");
    let destination;

    for (let i = 0; i < links.length; i++) {
        links[i].onmouseover = function () {
            destination = this.getAttribute("href");
            if (destination.indexOf("index.html") != -1) moveElement("preview", 0, 0, 5);
            if (destination.indexOf("about.html") != -1) moveElement("preview", -150, 0, 5);
            if (destination.indexOf("photos.html") != -1) moveElement("preview", -300, 0, 5);
            if (destination.indexOf("live.html") != -1) moveElement("preview", -450, 0, 5);
            if (destination.indexOf("contact.html") != -1) moveElement("preview", -600, 0, 5);
        }
    }


}
addLoadEvent(prepareSlideShow);


//about
function showSection(id) {
    let sections = document.getElementsByTagName("section");
}