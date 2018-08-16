'<head>asdfasd<title>百度一下，你就知道</title>asdfasdf</head>asdf'.match(/<head>[\s\S]*?<title>[\s\S]*?<\/title>(?:(?!<\/head>)[\s\S])*/)

'fooooo'.match(/(?:foo{1,2})/) //直接匹配整个'foo' 而foo{1,2}只作用于第二个o
"fooo"

"\t asdfas asdf \n 123 321  ".replace(/^\s+|\s+$/g, "") // /g全局替换 
"asdfas asdf 
 123 321"