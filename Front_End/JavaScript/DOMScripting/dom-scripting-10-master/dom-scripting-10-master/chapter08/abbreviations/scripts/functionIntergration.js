 function displayAbbreviations() {
   if (!document.getElementsByTagName || !document.createElement ||
     !document.createTextNode) return false;
   let abbreviations = document.getElementsByTagName("abbr");

   if (!abbreviations || abbreviations.length < 1) return false;

   let defs = new Array();
   for (let i = 0; i < abbreviations.length; i++) {
     if (abbreviations[i].childNodes.length < 1) continue; //保证IE6浏览器的平稳退化
     let definition = abbreviations[i].getAttribute("title");
     let key = abbreviations[i].lastChild.nodeValue;
     defs[key] = definition;
   }

   let dlist = document.createElement("dl");
   for (key in defs) {
     let dtitle = document.createElement("dt");
     let dtitle_text = document.createTextNode(key);

     dtitle.appendChild(dtitle_text);
     let ddesc = document.createElement("dd");
     let ddesc_text = document.createTextNode(defs[key]);
     ddesc.appendChild(ddesc_text);

     dlist.appendChild(dtitle);
     dlist.appendChild(ddesc);
   }

   let header = document.createElement("h2");
   let header_text = document.createTextNode("Abbreviations");
   header.appendChild(header_text);

   document.body.appendChild(header);
   document.body.appendChild(dlist);
 }
 addLoadEvent(displayAbbreviations);

 //show citations as super script
 function displayCitations() {
   if (!document.getElementsByTagName || !document.createElement ||
     !document.createTextNode) return false;

   let quotes = document.getElementsByTagName("blockquote");
   if (quotes.length < 1) return false;

   for (let i = 0; i < quotes.length; i++) {
     if (!quotes[i].getAttribute("cite")) continue;
     let url = quotes[i].getAttribute("cite");
     //lastChild contain textnode, we only wonder get element node
     let quoteElements = quotes[i].getElementsByTagName("*");
     let lastElem = quoteElements[quoteElements.length - 1];

     let link = document.createElement("a");
     let link_text = document.createTextNode("source");
     link.appendChild(link_text);
     link.setAttribute("href", url);

     let superscript = document.createElement("sup");
     superscript.appendChild(link);

     lastElem.appendChild(superscript);
   }
 }
 addLoadEvent(displayCitations);


 //show accesskeys
 function displayAccessKeys() {
   if (!document.getElementsByTagName || !document.createElement ||
     !document.createTextNode) return false;
   let links = document.getElementsByTagName("a");
   if (links.length < 1) return false;

   let akeys = new Array();
   for (let i = 0; i < links.length; i++) {
     let curr = links[i];

     if (!curr.getAttribute("accesskey")) continue;
     let key = curr.getAttribute("accesskey");
     akeys[key] = curr.lastChild.nodeValue;
   }

   let list = document.createElement("ul");
   for (key in akeys) {
     let item = document.createElement("li");
     let item_text = document.createTextNode(key + ' : ' + akeys[key] + "; ");

     item.appendChild(item_text);
     list.appendChild(item);
   }


   let header = document.createElement("h3");
   let header_text = document.createTextNode("AccessKeys");
   header.appendChild(header_text);

   document.body.appendChild(header);
   document.body.appendChild(list);
 }
 addLoadEvent(displayAccessKeys);