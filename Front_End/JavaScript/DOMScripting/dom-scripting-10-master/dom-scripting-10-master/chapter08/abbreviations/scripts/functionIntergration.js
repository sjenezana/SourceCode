 function displayAbbreviations() {
   if (!document.getElementsByTagName || !document.createElement ||
     !document.createTextNode) return false;
   let abbreviations = document.getElementsByTagName("abbr");

   if (!abbreviations || abbreviations.length < 1) return false;

   let defs = new Array();
   for (let i = 0; i < abbreviations.length; i++) {
     if(abbreviations[i].childNodes.length<1) continue;//保证IE6浏览器的平稳退化
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


 fucntion displayCitations(){
  

 }